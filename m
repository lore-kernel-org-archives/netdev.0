From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Doing crypto in small stack buffers (bluetooth vs vmalloc-stack
 crash, etc)
Date: Thu, 23 Jun 2016 14:41:37 +0800
Message-ID: <20160623064137.GA8958@gondor.apana.org.au>
References: <CALCETrVJzzKkRsSbgsUmVd_+ArKEgoRSVdG1tVp7CXzFoPyVgA@mail.gmail.com>
 <20160622004214.GA27134@gondor.apana.org.au>
 <CALCETrUnzasc+c5Dxmw+g6U07dTNU4RF0ug1bHj8j2en+7Xj1A@mail.gmail.com>
 <CALCETrUWyNz91WO6O3dNb+YELeZy5q4+oTo6dLRR67P2WvBB8g@mail.gmail.com>
 <CALCETrXJAvtty-zrjZR0URyT92rMZ4HhiTLtd4r5CzFjZOj=-Q@mail.gmail.com>
 <20160623034825.GB7819@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Lutomirski <luto@kernel.org>, linux-bluetooth@vger.kernel.org,
	Johan Hedberg <johan.hedberg@gmail.com>,
	Gustavo Padovan <gustavo@padovan.org>,
	Marcel Holtmann <marcel@holtmann.org>,
	linux-crypto@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	netdev@vger.kernel.org
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160623034825.GB7819@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 23, 2016 at 11:48:25AM +0800, Herbert Xu wrote:
> 
> No we never had such an API in the kernel.  However, I see that
> rxkad does some pretty silly things and we should be able to avoid
> using the stack in pretty much all cases.  Let me try to come up with
> something.

Here it is:

---8<---
Subject: rxrpc: Avoid using stack memory in SG lists in rxkad

rxkad uses stack memory in SG lists which would not work if stacks
were allocated from vmalloc memory.  In fact, in most cases this
isn't even necessary as the stack memory ends up getting copied
over to kmalloc memory.

This patch eliminates all the unnecessary stack memory uses by
supplying the final destination directly to the crypto API.  In
two instances where a temporary buffer is actually needed we also
switch use the skb->cb area instead of the stack.

Finally there is no need to split a split-page buffer into two SG
entries so code dealing with that has been removed.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index f0b807a..8ee5933 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -277,6 +277,7 @@ struct rxrpc_connection {
 	struct key		*key;		/* security for this connection (client) */
 	struct key		*server_key;	/* security for this service */
 	struct crypto_skcipher	*cipher;	/* encryption handle */
+	struct rxrpc_crypt	csum_iv_head;	/* leading block for csum_iv */
 	struct rxrpc_crypt	csum_iv;	/* packet checksum base */
 	unsigned long		events;
 #define RXRPC_CONN_CHALLENGE	0		/* send challenge packet */
diff --git a/net/rxrpc/rxkad.c b/net/rxrpc/rxkad.c
index 6b726a0..ee142de 100644
--- a/net/rxrpc/rxkad.c
+++ b/net/rxrpc/rxkad.c
@@ -105,11 +105,9 @@ static void rxkad_prime_packet_security(struct rxrpc_connection *conn)
 {
 	struct rxrpc_key_token *token;
 	SKCIPHER_REQUEST_ON_STACK(req, conn->cipher);
-	struct scatterlist sg[2];
+	struct rxrpc_crypt *csum_iv;
+	struct scatterlist sg;
 	struct rxrpc_crypt iv;
-	struct {
-		__be32 x[4];
-	} tmpbuf __attribute__((aligned(16))); /* must all be in same page */
 
 	_enter("");
 
@@ -119,24 +117,21 @@ static void rxkad_prime_packet_security(struct rxrpc_connection *conn)
 	token = conn->key->payload.data[0];
 	memcpy(&iv, token->kad->session_key, sizeof(iv));
 
-	tmpbuf.x[0] = htonl(conn->epoch);
-	tmpbuf.x[1] = htonl(conn->cid);
-	tmpbuf.x[2] = 0;
-	tmpbuf.x[3] = htonl(conn->security_ix);
+	csum_iv = &conn->csum_iv_head;
+	csum_iv[0].x[0] = htonl(conn->epoch);
+	csum_iv[0].x[1] = htonl(conn->cid);
+	csum_iv[1].x[0] = 0;
+	csum_iv[1].x[1] = htonl(conn->security_ix);
 
-	sg_init_one(&sg[0], &tmpbuf, sizeof(tmpbuf));
-	sg_init_one(&sg[1], &tmpbuf, sizeof(tmpbuf));
+	sg_init_one(&sg, csum_iv, 16);
 
 	skcipher_request_set_tfm(req, conn->cipher);
 	skcipher_request_set_callback(req, 0, NULL, NULL);
-	skcipher_request_set_crypt(req, &sg[1], &sg[0], sizeof(tmpbuf), iv.x);
+	skcipher_request_set_crypt(req, &sg, &sg, 16, iv.x);
 
 	crypto_skcipher_encrypt(req);
 	skcipher_request_zero(req);
 
-	memcpy(&conn->csum_iv, &tmpbuf.x[2], sizeof(conn->csum_iv));
-	ASSERTCMP((u32 __force)conn->csum_iv.n[0], ==, (u32 __force)tmpbuf.x[2]);
-
 	_leave("");
 }
 
@@ -150,12 +145,9 @@ static int rxkad_secure_packet_auth(const struct rxrpc_call *call,
 {
 	struct rxrpc_skb_priv *sp;
 	SKCIPHER_REQUEST_ON_STACK(req, call->conn->cipher);
+	struct rxkad_level1_hdr hdr;
 	struct rxrpc_crypt iv;
-	struct scatterlist sg[2];
-	struct {
-		struct rxkad_level1_hdr hdr;
-		__be32	first;	/* first four bytes of data and padding */
-	} tmpbuf __attribute__((aligned(8))); /* must all be in same page */
+	struct scatterlist sg;
 	u16 check;
 
 	sp = rxrpc_skb(skb);
@@ -165,24 +157,21 @@ static int rxkad_secure_packet_auth(const struct rxrpc_call *call,
 	check = sp->hdr.seq ^ sp->hdr.callNumber;
 	data_size |= (u32)check << 16;
 
-	tmpbuf.hdr.data_size = htonl(data_size);
-	memcpy(&tmpbuf.first, sechdr + 4, sizeof(tmpbuf.first));
+	hdr.data_size = htonl(data_size);
+	memcpy(sechdr, &hdr, sizeof(hdr));
 
 	/* start the encryption afresh */
 	memset(&iv, 0, sizeof(iv));
 
-	sg_init_one(&sg[0], &tmpbuf, sizeof(tmpbuf));
-	sg_init_one(&sg[1], &tmpbuf, sizeof(tmpbuf));
+	sg_init_one(&sg, sechdr, 8);
 
 	skcipher_request_set_tfm(req, call->conn->cipher);
 	skcipher_request_set_callback(req, 0, NULL, NULL);
-	skcipher_request_set_crypt(req, &sg[1], &sg[0], sizeof(tmpbuf), iv.x);
+	skcipher_request_set_crypt(req, &sg, &sg, 8, iv.x);
 
 	crypto_skcipher_encrypt(req);
 	skcipher_request_zero(req);
 
-	memcpy(sechdr, &tmpbuf, sizeof(tmpbuf));
-
 	_leave(" = 0");
 	return 0;
 }
@@ -196,8 +185,7 @@ static int rxkad_secure_packet_encrypt(const struct rxrpc_call *call,
 				       void *sechdr)
 {
 	const struct rxrpc_key_token *token;
-	struct rxkad_level2_hdr rxkhdr
-		__attribute__((aligned(8))); /* must be all on one page */
+	struct rxkad_level2_hdr rxkhdr;
 	struct rxrpc_skb_priv *sp;
 	SKCIPHER_REQUEST_ON_STACK(req, call->conn->cipher);
 	struct rxrpc_crypt iv;
@@ -216,17 +204,17 @@ static int rxkad_secure_packet_encrypt(const struct rxrpc_call *call,
 
 	rxkhdr.data_size = htonl(data_size | (u32)check << 16);
 	rxkhdr.checksum = 0;
+	memcpy(sechdr, &rxkhdr, sizeof(rxkhdr));
 
 	/* encrypt from the session key */
 	token = call->conn->key->payload.data[0];
 	memcpy(&iv, token->kad->session_key, sizeof(iv));
 
 	sg_init_one(&sg[0], sechdr, sizeof(rxkhdr));
-	sg_init_one(&sg[1], &rxkhdr, sizeof(rxkhdr));
 
 	skcipher_request_set_tfm(req, call->conn->cipher);
 	skcipher_request_set_callback(req, 0, NULL, NULL);
-	skcipher_request_set_crypt(req, &sg[1], &sg[0], sizeof(rxkhdr), iv.x);
+	skcipher_request_set_crypt(req, &sg[0], &sg[0], sizeof(rxkhdr), iv.x);
 
 	crypto_skcipher_encrypt(req);
 
@@ -265,10 +253,11 @@ static int rxkad_secure_packet(const struct rxrpc_call *call,
 	struct rxrpc_skb_priv *sp;
 	SKCIPHER_REQUEST_ON_STACK(req, call->conn->cipher);
 	struct rxrpc_crypt iv;
-	struct scatterlist sg[2];
-	struct {
+	struct scatterlist sg;
+	union {
 		__be32 x[2];
-	} tmpbuf __attribute__((aligned(8))); /* must all be in same page */
+		__be64 xl;
+	} tmpbuf;
 	u32 x, y;
 	int ret;
 
@@ -294,16 +283,19 @@ static int rxkad_secure_packet(const struct rxrpc_call *call,
 	tmpbuf.x[0] = htonl(sp->hdr.callNumber);
 	tmpbuf.x[1] = htonl(x);
 
-	sg_init_one(&sg[0], &tmpbuf, sizeof(tmpbuf));
-	sg_init_one(&sg[1], &tmpbuf, sizeof(tmpbuf));
+	swap(tmpbuf.xl, *(__be64 *)sp);
+
+	sg_init_one(&sg, sp, sizeof(tmpbuf));
 
 	skcipher_request_set_tfm(req, call->conn->cipher);
 	skcipher_request_set_callback(req, 0, NULL, NULL);
-	skcipher_request_set_crypt(req, &sg[1], &sg[0], sizeof(tmpbuf), iv.x);
+	skcipher_request_set_crypt(req, &sg, &sg, sizeof(tmpbuf), iv.x);
 
 	crypto_skcipher_encrypt(req);
 	skcipher_request_zero(req);
 
+	swap(tmpbuf.xl, *(__be64 *)sp);
+
 	y = ntohl(tmpbuf.x[1]);
 	y = (y >> 16) & 0xffff;
 	if (y == 0)
@@ -503,10 +495,11 @@ static int rxkad_verify_packet(const struct rxrpc_call *call,
 	SKCIPHER_REQUEST_ON_STACK(req, call->conn->cipher);
 	struct rxrpc_skb_priv *sp;
 	struct rxrpc_crypt iv;
-	struct scatterlist sg[2];
-	struct {
+	struct scatterlist sg;
+	union {
 		__be32 x[2];
-	} tmpbuf __attribute__((aligned(8))); /* must all be in same page */
+		__be64 xl;
+	} tmpbuf;
 	u16 cksum;
 	u32 x, y;
 	int ret;
@@ -534,16 +527,19 @@ static int rxkad_verify_packet(const struct rxrpc_call *call,
 	tmpbuf.x[0] = htonl(call->call_id);
 	tmpbuf.x[1] = htonl(x);
 
-	sg_init_one(&sg[0], &tmpbuf, sizeof(tmpbuf));
-	sg_init_one(&sg[1], &tmpbuf, sizeof(tmpbuf));
+	swap(tmpbuf.xl, *(__be64 *)sp);
+
+	sg_init_one(&sg, sp, sizeof(tmpbuf));
 
 	skcipher_request_set_tfm(req, call->conn->cipher);
 	skcipher_request_set_callback(req, 0, NULL, NULL);
-	skcipher_request_set_crypt(req, &sg[1], &sg[0], sizeof(tmpbuf), iv.x);
+	skcipher_request_set_crypt(req, &sg, &sg, sizeof(tmpbuf), iv.x);
 
 	crypto_skcipher_encrypt(req);
 	skcipher_request_zero(req);
 
+	swap(tmpbuf.xl, *(__be64 *)sp);
+
 	y = ntohl(tmpbuf.x[1]);
 	cksum = (y >> 16) & 0xffff;
 	if (cksum == 0)
@@ -708,26 +704,13 @@ static void rxkad_calc_response_checksum(struct rxkad_response *response)
 }
 
 /*
- * load a scatterlist with a potentially split-page buffer
+ * load a scatterlist
  */
-static void rxkad_sg_set_buf2(struct scatterlist sg[2],
+static void rxkad_sg_set_buf2(struct scatterlist sg[1],
 			      void *buf, size_t buflen)
 {
-	int nsg = 1;
-
-	sg_init_table(sg, 2);
-
+	sg_init_table(sg, 1);
 	sg_set_buf(&sg[0], buf, buflen);
-	if (sg[0].offset + buflen > PAGE_SIZE) {
-		/* the buffer was split over two pages */
-		sg[0].length = PAGE_SIZE - sg[0].offset;
-		sg_set_buf(&sg[1], buf + sg[0].length, buflen - sg[0].length);
-		nsg++;
-	}
-
-	sg_mark_end(&sg[nsg - 1]);
-
-	ASSERTCMP(sg[0].length + sg[1].length, ==, buflen);
 }
 
 /*
@@ -739,7 +722,7 @@ static void rxkad_encrypt_response(struct rxrpc_connection *conn,
 {
 	SKCIPHER_REQUEST_ON_STACK(req, conn->cipher);
 	struct rxrpc_crypt iv;
-	struct scatterlist sg[2];
+	struct scatterlist sg[1];
 
 	/* continue encrypting from where we left off */
 	memcpy(&iv, s2->session_key, sizeof(iv));
@@ -999,7 +982,7 @@ static void rxkad_decrypt_response(struct rxrpc_connection *conn,
 				   const struct rxrpc_crypt *session_key)
 {
 	SKCIPHER_REQUEST_ON_STACK(req, rxkad_ci);
-	struct scatterlist sg[2];
+	struct scatterlist sg[1];
 	struct rxrpc_crypt iv;
 
 	_enter(",,%08x%08x",
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
