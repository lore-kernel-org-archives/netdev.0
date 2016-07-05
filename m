From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 04/24] rxrpc: Avoid using stack memory in SG lists
 in rxkad
Date: Tue, 05 Jul 2016 14:12:39 +0100
Message-ID: <146772435939.21657.15502992311223735001.stgit@warthog.procyon.org.uk>
References: <146772433082.21657.14046392058484946464.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, dhowells@redhat.com,
	Andy Lutomirski <luto@kernel.org>,
	linux-afs@lists.infradead.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <146772433082.21657.14046392058484946464.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>

rxkad uses stack memory in SG lists which would not work if stacks were
allocated from vmalloc memory.  In fact, in most cases this isn't even
necessary as the stack memory ends up getting copied over to kmalloc
memory.

This patch eliminates all the unnecessary stack memory uses by supplying
the final destination directly to the crypto API.  In two instances where a
temporary buffer is actually needed we also switch use a scratch area in
the rxrpc_call struct (only one DATA packet will be being secured or
verified at a time).

Finally there is no need to split a split-page buffer into two SG entries
so code dealing with that has been removed.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
Signed-off-by: Andy Lutomirski <luto@kernel.org>
Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/ar-internal.h |    8 +--
 net/rxrpc/conn_event.c  |    5 +-
 net/rxrpc/conn_object.c |    6 ++
 net/rxrpc/insecure.c    |    7 +-
 net/rxrpc/rxkad.c       |  150 +++++++++++++++--------------------------------
 5 files changed, 65 insertions(+), 111 deletions(-)

diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 702db72196fb..796368d1fb25 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -141,17 +141,16 @@ struct rxrpc_security {
 	int (*init_connection_security)(struct rxrpc_connection *);
 
 	/* prime a connection's packet security */
-	void (*prime_packet_security)(struct rxrpc_connection *);
+	int (*prime_packet_security)(struct rxrpc_connection *);
 
 	/* impose security on a packet */
-	int (*secure_packet)(const struct rxrpc_call *,
+	int (*secure_packet)(struct rxrpc_call *,
 			     struct sk_buff *,
 			     size_t,
 			     void *);
 
 	/* verify the security on a received packet */
-	int (*verify_packet)(const struct rxrpc_call *, struct sk_buff *,
-			     u32 *);
+	int (*verify_packet)(struct rxrpc_call *, struct sk_buff *, u32 *);
 
 	/* issue a challenge */
 	int (*issue_challenge)(struct rxrpc_connection *);
@@ -399,6 +398,7 @@ struct rxrpc_call {
 	struct sk_buff_head	rx_oos_queue;	/* packets received out of sequence */
 	struct sk_buff		*tx_pending;	/* Tx socket buffer being filled */
 	wait_queue_head_t	tx_waitq;	/* wait for Tx window space to become available */
+	__be32			crypto_buf[2];	/* Temporary packet crypto buffer */
 	unsigned long		user_call_ID;	/* user-defined call ID */
 	unsigned long		creation_jif;	/* time of call creation */
 	unsigned long		flags;
diff --git a/net/rxrpc/conn_event.c b/net/rxrpc/conn_event.c
index bf6971555eac..6a3c96707831 100644
--- a/net/rxrpc/conn_event.c
+++ b/net/rxrpc/conn_event.c
@@ -188,7 +188,10 @@ static int rxrpc_process_event(struct rxrpc_connection *conn,
 		if (ret < 0)
 			return ret;
 
-		conn->security->prime_packet_security(conn);
+		ret = conn->security->prime_packet_security(conn);
+		if (ret < 0)
+			return ret;
+
 		read_lock_bh(&conn->lock);
 		spin_lock(&conn->state_lock);
 
diff --git a/net/rxrpc/conn_object.c b/net/rxrpc/conn_object.c
index 2c2456ff2853..c2c0926af546 100644
--- a/net/rxrpc/conn_object.c
+++ b/net/rxrpc/conn_object.c
@@ -138,7 +138,9 @@ rxrpc_alloc_client_connection(struct rxrpc_conn_parameters *cp, gfp_t gfp)
 	if (ret < 0)
 		goto error_1;
 
-	conn->security->prime_packet_security(conn);
+	ret = conn->security->prime_packet_security(conn);
+	if (ret < 0)
+		goto error_2;
 
 	write_lock(&rxrpc_connection_lock);
 	list_add_tail(&conn->link, &rxrpc_connections);
@@ -152,6 +154,8 @@ rxrpc_alloc_client_connection(struct rxrpc_conn_parameters *cp, gfp_t gfp)
 	_leave(" = %p", conn);
 	return conn;
 
+error_2:
+	conn->security->clear(conn);
 error_1:
 	rxrpc_put_client_connection_id(conn);
 error_0:
diff --git a/net/rxrpc/insecure.c b/net/rxrpc/insecure.c
index e571403613c1..c21ad213b337 100644
--- a/net/rxrpc/insecure.c
+++ b/net/rxrpc/insecure.c
@@ -17,11 +17,12 @@ static int none_init_connection_security(struct rxrpc_connection *conn)
 	return 0;
 }
 
-static void none_prime_packet_security(struct rxrpc_connection *conn)
+static int none_prime_packet_security(struct rxrpc_connection *conn)
 {
+	return 0;
 }
 
-static int none_secure_packet(const struct rxrpc_call *call,
+static int none_secure_packet(struct rxrpc_call *call,
 			       struct sk_buff *skb,
 			       size_t data_size,
 			       void *sechdr)
@@ -29,7 +30,7 @@ static int none_secure_packet(const struct rxrpc_call *call,
 	return 0;
 }
 
-static int none_verify_packet(const struct rxrpc_call *call,
+static int none_verify_packet(struct rxrpc_call *call,
 			       struct sk_buff *skb,
 			       u32 *_abort_code)
 {
diff --git a/net/rxrpc/rxkad.c b/net/rxrpc/rxkad.c
index 23c05ec6fa28..3acc7c1241d4 100644
--- a/net/rxrpc/rxkad.c
+++ b/net/rxrpc/rxkad.c
@@ -103,43 +103,43 @@ error:
  * prime the encryption state with the invariant parts of a connection's
  * description
  */
-static void rxkad_prime_packet_security(struct rxrpc_connection *conn)
+static int rxkad_prime_packet_security(struct rxrpc_connection *conn)
 {
 	struct rxrpc_key_token *token;
 	SKCIPHER_REQUEST_ON_STACK(req, conn->cipher);
-	struct scatterlist sg[2];
+	struct scatterlist sg;
 	struct rxrpc_crypt iv;
-	struct {
-		__be32 x[4];
-	} tmpbuf __attribute__((aligned(16))); /* must all be in same page */
+	__be32 *tmpbuf;
+	size_t tmpsize = 4 * sizeof(__be32);
 
 	_enter("");
 
 	if (!conn->params.key)
-		return;
+		return 0;
+
+	tmpbuf = kmalloc(tmpsize, GFP_KERNEL);
+	if (!tmpbuf)
+		return -ENOMEM;
 
 	token = conn->params.key->payload.data[0];
 	memcpy(&iv, token->kad->session_key, sizeof(iv));
 
-	tmpbuf.x[0] = htonl(conn->proto.epoch);
-	tmpbuf.x[1] = htonl(conn->proto.cid);
-	tmpbuf.x[2] = 0;
-	tmpbuf.x[3] = htonl(conn->security_ix);
-
-	sg_init_one(&sg[0], &tmpbuf, sizeof(tmpbuf));
-	sg_init_one(&sg[1], &tmpbuf, sizeof(tmpbuf));
+	tmpbuf[0] = htonl(conn->proto.epoch);
+	tmpbuf[1] = htonl(conn->proto.cid);
+	tmpbuf[2] = 0;
+	tmpbuf[3] = htonl(conn->security_ix);
 
+	sg_init_one(&sg, tmpbuf, tmpsize);
 	skcipher_request_set_tfm(req, conn->cipher);
 	skcipher_request_set_callback(req, 0, NULL, NULL);
-	skcipher_request_set_crypt(req, &sg[1], &sg[0], sizeof(tmpbuf), iv.x);
-
+	skcipher_request_set_crypt(req, &sg, &sg, tmpsize, iv.x);
 	crypto_skcipher_encrypt(req);
 	skcipher_request_zero(req);
 
-	memcpy(&conn->csum_iv, &tmpbuf.x[2], sizeof(conn->csum_iv));
-	ASSERTCMP((u32 __force)conn->csum_iv.n[0], ==, (u32 __force)tmpbuf.x[2]);
-
-	_leave("");
+	memcpy(&conn->csum_iv, tmpbuf + 2, sizeof(conn->csum_iv));
+	kfree(tmpbuf);
+	_leave(" = 0");
+	return 0;
 }
 
 /*
@@ -152,12 +152,9 @@ static int rxkad_secure_packet_auth(const struct rxrpc_call *call,
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
@@ -167,24 +164,19 @@ static int rxkad_secure_packet_auth(const struct rxrpc_call *call,
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
-
+	sg_init_one(&sg, sechdr, 8);
 	skcipher_request_set_tfm(req, call->conn->cipher);
 	skcipher_request_set_callback(req, 0, NULL, NULL);
-	skcipher_request_set_crypt(req, &sg[1], &sg[0], sizeof(tmpbuf), iv.x);
-
+	skcipher_request_set_crypt(req, &sg, &sg, 8, iv.x);
 	crypto_skcipher_encrypt(req);
 	skcipher_request_zero(req);
 
-	memcpy(sechdr, &tmpbuf, sizeof(tmpbuf));
-
 	_leave(" = 0");
 	return 0;
 }
@@ -198,8 +190,7 @@ static int rxkad_secure_packet_encrypt(const struct rxrpc_call *call,
 				       void *sechdr)
 {
 	const struct rxrpc_key_token *token;
-	struct rxkad_level2_hdr rxkhdr
-		__attribute__((aligned(8))); /* must be all on one page */
+	struct rxkad_level2_hdr rxkhdr;
 	struct rxrpc_skb_priv *sp;
 	SKCIPHER_REQUEST_ON_STACK(req, call->conn->cipher);
 	struct rxrpc_crypt iv;
@@ -218,18 +209,16 @@ static int rxkad_secure_packet_encrypt(const struct rxrpc_call *call,
 
 	rxkhdr.data_size = htonl(data_size | (u32)check << 16);
 	rxkhdr.checksum = 0;
+	memcpy(sechdr, &rxkhdr, sizeof(rxkhdr));
 
 	/* encrypt from the session key */
 	token = call->conn->params.key->payload.data[0];
 	memcpy(&iv, token->kad->session_key, sizeof(iv));
 
 	sg_init_one(&sg[0], sechdr, sizeof(rxkhdr));
-	sg_init_one(&sg[1], &rxkhdr, sizeof(rxkhdr));
-
 	skcipher_request_set_tfm(req, call->conn->cipher);
 	skcipher_request_set_callback(req, 0, NULL, NULL);
-	skcipher_request_set_crypt(req, &sg[1], &sg[0], sizeof(rxkhdr), iv.x);
-
+	skcipher_request_set_crypt(req, &sg[0], &sg[0], sizeof(rxkhdr), iv.x);
 	crypto_skcipher_encrypt(req);
 
 	/* we want to encrypt the skbuff in-place */
@@ -243,9 +232,7 @@ static int rxkad_secure_packet_encrypt(const struct rxrpc_call *call,
 
 	sg_init_table(sg, nsg);
 	skb_to_sgvec(skb, sg, 0, len);
-
 	skcipher_request_set_crypt(req, sg, sg, len, iv.x);
-
 	crypto_skcipher_encrypt(req);
 
 	_leave(" = 0");
@@ -259,7 +246,7 @@ out:
 /*
  * checksum an RxRPC packet header
  */
-static int rxkad_secure_packet(const struct rxrpc_call *call,
+static int rxkad_secure_packet(struct rxrpc_call *call,
 			       struct sk_buff *skb,
 			       size_t data_size,
 			       void *sechdr)
@@ -267,10 +254,7 @@ static int rxkad_secure_packet(const struct rxrpc_call *call,
 	struct rxrpc_skb_priv *sp;
 	SKCIPHER_REQUEST_ON_STACK(req, call->conn->cipher);
 	struct rxrpc_crypt iv;
-	struct scatterlist sg[2];
-	struct {
-		__be32 x[2];
-	} tmpbuf __attribute__((aligned(8))); /* must all be in same page */
+	struct scatterlist sg;
 	u32 x, y;
 	int ret;
 
@@ -293,20 +277,17 @@ static int rxkad_secure_packet(const struct rxrpc_call *call,
 	/* calculate the security checksum */
 	x = call->channel << (32 - RXRPC_CIDSHIFT);
 	x |= sp->hdr.seq & 0x3fffffff;
-	tmpbuf.x[0] = htonl(sp->hdr.callNumber);
-	tmpbuf.x[1] = htonl(x);
-
-	sg_init_one(&sg[0], &tmpbuf, sizeof(tmpbuf));
-	sg_init_one(&sg[1], &tmpbuf, sizeof(tmpbuf));
+	call->crypto_buf[0] = htonl(sp->hdr.callNumber);
+	call->crypto_buf[1] = htonl(x);
 
+	sg_init_one(&sg, call->crypto_buf, 8);
 	skcipher_request_set_tfm(req, call->conn->cipher);
 	skcipher_request_set_callback(req, 0, NULL, NULL);
-	skcipher_request_set_crypt(req, &sg[1], &sg[0], sizeof(tmpbuf), iv.x);
-
+	skcipher_request_set_crypt(req, &sg, &sg, 8, iv.x);
 	crypto_skcipher_encrypt(req);
 	skcipher_request_zero(req);
 
-	y = ntohl(tmpbuf.x[1]);
+	y = ntohl(call->crypto_buf[1]);
 	y = (y >> 16) & 0xffff;
 	if (y == 0)
 		y = 1; /* zero checksums are not permitted */
@@ -367,7 +348,6 @@ static int rxkad_verify_packet_auth(const struct rxrpc_call *call,
 	skcipher_request_set_tfm(req, call->conn->cipher);
 	skcipher_request_set_callback(req, 0, NULL, NULL);
 	skcipher_request_set_crypt(req, sg, sg, 8, iv.x);
-
 	crypto_skcipher_decrypt(req);
 	skcipher_request_zero(req);
 
@@ -452,7 +432,6 @@ static int rxkad_verify_packet_encrypt(const struct rxrpc_call *call,
 	skcipher_request_set_tfm(req, call->conn->cipher);
 	skcipher_request_set_callback(req, 0, NULL, NULL);
 	skcipher_request_set_crypt(req, sg, sg, skb->len, iv.x);
-
 	crypto_skcipher_decrypt(req);
 	skcipher_request_zero(req);
 	if (sg != _sg)
@@ -498,17 +477,14 @@ nomem:
 /*
  * verify the security on a received packet
  */
-static int rxkad_verify_packet(const struct rxrpc_call *call,
+static int rxkad_verify_packet(struct rxrpc_call *call,
 			       struct sk_buff *skb,
 			       u32 *_abort_code)
 {
 	SKCIPHER_REQUEST_ON_STACK(req, call->conn->cipher);
 	struct rxrpc_skb_priv *sp;
 	struct rxrpc_crypt iv;
-	struct scatterlist sg[2];
-	struct {
-		__be32 x[2];
-	} tmpbuf __attribute__((aligned(8))); /* must all be in same page */
+	struct scatterlist sg;
 	u16 cksum;
 	u32 x, y;
 	int ret;
@@ -533,20 +509,17 @@ static int rxkad_verify_packet(const struct rxrpc_call *call,
 	/* validate the security checksum */
 	x = call->channel << (32 - RXRPC_CIDSHIFT);
 	x |= sp->hdr.seq & 0x3fffffff;
-	tmpbuf.x[0] = htonl(call->call_id);
-	tmpbuf.x[1] = htonl(x);
-
-	sg_init_one(&sg[0], &tmpbuf, sizeof(tmpbuf));
-	sg_init_one(&sg[1], &tmpbuf, sizeof(tmpbuf));
+	call->crypto_buf[0] = htonl(call->call_id);
+	call->crypto_buf[1] = htonl(x);
 
+	sg_init_one(&sg, call->crypto_buf, 8);
 	skcipher_request_set_tfm(req, call->conn->cipher);
 	skcipher_request_set_callback(req, 0, NULL, NULL);
-	skcipher_request_set_crypt(req, &sg[1], &sg[0], sizeof(tmpbuf), iv.x);
-
+	skcipher_request_set_crypt(req, &sg, &sg, 8, iv.x);
 	crypto_skcipher_encrypt(req);
 	skcipher_request_zero(req);
 
-	y = ntohl(tmpbuf.x[1]);
+	y = ntohl(call->crypto_buf[1]);
 	cksum = (y >> 16) & 0xffff;
 	if (cksum == 0)
 		cksum = 1; /* zero checksums are not permitted */
@@ -710,29 +683,6 @@ static void rxkad_calc_response_checksum(struct rxkad_response *response)
 }
 
 /*
- * load a scatterlist with a potentially split-page buffer
- */
-static void rxkad_sg_set_buf2(struct scatterlist sg[2],
-			      void *buf, size_t buflen)
-{
-	int nsg = 1;
-
-	sg_init_table(sg, 2);
-
-	sg_set_buf(&sg[0], buf, buflen);
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
-}
-
-/*
  * encrypt the response packet
  */
 static void rxkad_encrypt_response(struct rxrpc_connection *conn,
@@ -741,17 +691,16 @@ static void rxkad_encrypt_response(struct rxrpc_connection *conn,
 {
 	SKCIPHER_REQUEST_ON_STACK(req, conn->cipher);
 	struct rxrpc_crypt iv;
-	struct scatterlist sg[2];
+	struct scatterlist sg[1];
 
 	/* continue encrypting from where we left off */
 	memcpy(&iv, s2->session_key, sizeof(iv));
 
-	rxkad_sg_set_buf2(sg, &resp->encrypted, sizeof(resp->encrypted));
-
+	sg_init_table(sg, 1);
+	sg_set_buf(sg, &resp->encrypted, sizeof(resp->encrypted));
 	skcipher_request_set_tfm(req, conn->cipher);
 	skcipher_request_set_callback(req, 0, NULL, NULL);
 	skcipher_request_set_crypt(req, sg, sg, sizeof(resp->encrypted), iv.x);
-
 	crypto_skcipher_encrypt(req);
 	skcipher_request_zero(req);
 }
@@ -887,10 +836,8 @@ static int rxkad_decrypt_ticket(struct rxrpc_connection *conn,
 	}
 
 	sg_init_one(&sg[0], ticket, ticket_len);
-
 	skcipher_request_set_callback(req, 0, NULL, NULL);
 	skcipher_request_set_crypt(req, sg, sg, ticket_len, iv.x);
-
 	crypto_skcipher_decrypt(req);
 	skcipher_request_free(req);
 
@@ -1001,7 +948,7 @@ static void rxkad_decrypt_response(struct rxrpc_connection *conn,
 				   const struct rxrpc_crypt *session_key)
 {
 	SKCIPHER_REQUEST_ON_STACK(req, rxkad_ci);
-	struct scatterlist sg[2];
+	struct scatterlist sg[1];
 	struct rxrpc_crypt iv;
 
 	_enter(",,%08x%08x",
@@ -1016,12 +963,11 @@ static void rxkad_decrypt_response(struct rxrpc_connection *conn,
 
 	memcpy(&iv, session_key, sizeof(iv));
 
-	rxkad_sg_set_buf2(sg, &resp->encrypted, sizeof(resp->encrypted));
-
+	sg_init_table(sg, 1);
+	sg_set_buf(sg, &resp->encrypted, sizeof(resp->encrypted));
 	skcipher_request_set_tfm(req, rxkad_ci);
 	skcipher_request_set_callback(req, 0, NULL, NULL);
 	skcipher_request_set_crypt(req, sg, sg, sizeof(resp->encrypted), iv.x);
-
 	crypto_skcipher_decrypt(req);
 	skcipher_request_zero(req);
 
