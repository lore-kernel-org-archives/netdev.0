From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH 1/9] AF_RXRPC: Add blkcipher accessors for using kernel data directly
Date: Tue, 03 Apr 2007 14:52:53 +0100
Message-ID: <19944.1175608373@redhat.com>
References: <20070403035019.GA4798@gondor.apana.org.au>  <20070402224449.31568.17833.stgit@warthog.cambridge.redhat.com> <20070402224458.31568.45303.stgit@warthog.cambridge.redhat.com> <20070402.202215.21596343.davem@davemloft.net>
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:47713 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965907AbXDCNxN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Apr 2007 09:53:13 -0400
In-Reply-To: <20070403035019.GA4798@gondor.apana.org.au> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Would it be possible to just use the existing scatterlist interface
> for now? We can simplify it later when things settle down.

I'll apply the attached patch for now and drop the bypass patch.  It's a bit
messy, but it does let me use the sg-list interface.

Note that it does paste stack space into sg-list elements, which I think
should be okay, and it asks the compiler to get it appropriately aligned bits
of stack.

David

diff --git a/net/rxrpc/rxkad.c b/net/rxrpc/rxkad.c
index b3bd399..1eaf529 100644
--- a/net/rxrpc/rxkad.c
+++ b/net/rxrpc/rxkad.c
@@ -111,8 +111,11 @@ static void rxkad_prime_packet_security(struct rxrpc_connection *conn)
 {
 	struct rxrpc_key_payload *payload;
 	struct blkcipher_desc desc;
+	struct scatterlist sg[2];
 	struct rxrpc_crypt iv;
-	__be32 tmpbuf[4];
+	struct {
+		__be32 x[4];
+	} tmpbuf __attribute__((aligned(16))); /* must all be in same page */
 
 	_enter("");
 
@@ -126,16 +129,18 @@ static void rxkad_prime_packet_security(struct rxrpc_connection *conn)
 	desc.info = iv.x;
 	desc.flags = 0;
 
-	tmpbuf[0] = conn->epoch;
-	tmpbuf[1] = conn->cid;
-	tmpbuf[2] = 0;
-	tmpbuf[3] = htonl(conn->security_ix);
+	tmpbuf.x[0] = conn->epoch;
+	tmpbuf.x[1] = conn->cid;
+	tmpbuf.x[2] = 0;
+	tmpbuf.x[3] = htonl(conn->security_ix);
 
-	crypto_blkcipher_encrypt_kernel_iv(&desc, (void *) tmpbuf,
-					   (void *) tmpbuf, sizeof(tmpbuf));
+	memset(sg, 0, sizeof(sg));
+	sg_set_buf(&sg[0], &tmpbuf, sizeof(tmpbuf));
+	sg_set_buf(&sg[1], &tmpbuf, sizeof(tmpbuf));
+	crypto_blkcipher_encrypt_iv(&desc, &sg[0], &sg[1], sizeof(tmpbuf));
 
-	memcpy(&conn->csum_iv, &tmpbuf[2], sizeof(conn->csum_iv));
-	ASSERTCMP(conn->csum_iv.n[0], ==, tmpbuf[2]);
+	memcpy(&conn->csum_iv, &tmpbuf.x[2], sizeof(conn->csum_iv));
+	ASSERTCMP(conn->csum_iv.n[0], ==, tmpbuf.x[2]);
 
 	_leave("");
 }
@@ -151,10 +156,11 @@ static int rxkad_secure_packet_auth(const struct rxrpc_call *call,
 	struct rxrpc_skb_priv *sp;
 	struct blkcipher_desc desc;
 	struct rxrpc_crypt iv;
+	struct scatterlist sg[2];
 	struct {
 		struct rxkad_level1_hdr hdr;
 		__be32	first;	/* first four bytes of data and padding */
-	} buf;
+	} tmpbuf __attribute__((aligned(8))); /* must all be in same page */
 	u16 check;
 
 	sp = rxrpc_skb(skb);
@@ -164,8 +170,8 @@ static int rxkad_secure_packet_auth(const struct rxrpc_call *call,
 	check = ntohl(sp->hdr.seq ^ sp->hdr.callNumber);
 	data_size |= (u32) check << 16;
 
-	buf.hdr.data_size = htonl(data_size);
-	memcpy(&buf.first, sechdr + 4, sizeof(buf.first));
+	tmpbuf.hdr.data_size = htonl(data_size);
+	memcpy(&tmpbuf.first, sechdr + 4, sizeof(tmpbuf.first));
 
 	/* start the encryption afresh */
 	memset(&iv, 0, sizeof(iv));
@@ -173,10 +179,12 @@ static int rxkad_secure_packet_auth(const struct rxrpc_call *call,
 	desc.info = iv.x;
 	desc.flags = 0;
 
-	crypto_blkcipher_encrypt_kernel_iv(&desc, (void *) &buf,
-					   (void *) &buf, sizeof(buf));
+	memset(sg, 0, sizeof(sg));
+	sg_set_buf(&sg[0], &tmpbuf, sizeof(tmpbuf));
+	sg_set_buf(&sg[1], &tmpbuf, sizeof(tmpbuf));
+	crypto_blkcipher_encrypt_iv(&desc, &sg[0], &sg[1], sizeof(tmpbuf));
 
-	memcpy(sechdr, &buf, sizeof(buf));
+	memcpy(sechdr, &tmpbuf, sizeof(tmpbuf));
 
 	_leave(" = 0");
 	return 0;
@@ -191,7 +199,8 @@ static int rxkad_secure_packet_encrypt(const struct rxrpc_call *call,
 					void *sechdr)
 {
 	const struct rxrpc_key_payload *payload;
-	struct rxkad_level2_hdr rxkhdr;
+	struct rxkad_level2_hdr rxkhdr
+		__attribute__((aligned(8))); /* must be all on one page */
 	struct rxrpc_skb_priv *sp;
 	struct blkcipher_desc desc;
 	struct rxrpc_crypt iv;
@@ -217,8 +226,10 @@ static int rxkad_secure_packet_encrypt(const struct rxrpc_call *call,
 	desc.info = iv.x;
 	desc.flags = 0;
 
-	crypto_blkcipher_encrypt_kernel_iv(&desc, (void *) sechdr,
-					   (void *) &rxkhdr, sizeof(rxkhdr));
+	memset(sg, 0, sizeof(sg[0]) * 2);
+	sg_set_buf(&sg[0], sechdr, sizeof(rxkhdr));
+	sg_set_buf(&sg[1], &rxkhdr, sizeof(rxkhdr));
+	crypto_blkcipher_encrypt_iv(&desc, &sg[0], &sg[1], sizeof(rxkhdr));
 
 	/* we want to encrypt the skbuff in-place */
 	nsg = skb_cow_data(skb, 0, &trailer);
@@ -246,7 +257,11 @@ static int rxkad_secure_packet(const struct rxrpc_call *call,
 	struct rxrpc_skb_priv *sp;
 	struct blkcipher_desc desc;
 	struct rxrpc_crypt iv;
-	__be32 tmpbuf[2], x;
+	struct scatterlist sg[2];
+	struct {
+		__be32 x[2];
+	} tmpbuf __attribute__((aligned(8))); /* must all be in same page */
+	__be32 x;
 	int ret;
 
 	sp = rxrpc_skb(skb);
@@ -271,13 +286,15 @@ static int rxkad_secure_packet(const struct rxrpc_call *call,
 	/* calculate the security checksum */
 	x = htonl(call->channel << (32 - RXRPC_CIDSHIFT));
 	x |= sp->hdr.seq & __constant_cpu_to_be32(0x3fffffff);
-	tmpbuf[0] = sp->hdr.callNumber;
-	tmpbuf[1] = x;
+	tmpbuf.x[0] = sp->hdr.callNumber;
+	tmpbuf.x[1] = x;
 
-	crypto_blkcipher_encrypt_kernel_iv(&desc, (void *) tmpbuf,
-					   (void *) tmpbuf, sizeof(tmpbuf));
+	memset(&sg, 0, sizeof(sg));
+	sg_set_buf(&sg[0], &tmpbuf, sizeof(tmpbuf));
+	sg_set_buf(&sg[1], &tmpbuf, sizeof(tmpbuf));
+	crypto_blkcipher_encrypt_iv(&desc, &sg[0], &sg[1], sizeof(tmpbuf));
 
-	x = ntohl(tmpbuf[1]);
+	x = ntohl(tmpbuf.x[1]);
 	x = (x >> 16) & 0xffff;
 	if (x == 0)
 		x = 1; /* zero checksums are not permitted */
@@ -468,7 +485,11 @@ static int rxkad_verify_packet(const struct rxrpc_call *call,
 	struct blkcipher_desc desc;
 	struct rxrpc_skb_priv *sp;
 	struct rxrpc_crypt iv;
-	__be32 tmpbuf[2], x;
+	struct scatterlist sg[2];
+	struct {
+		__be32 x[2];
+	} tmpbuf __attribute__((aligned(8))); /* must all be in same page */
+	__be32 x;
 	__be16 cksum;
 	int ret;
 
@@ -496,13 +517,15 @@ static int rxkad_verify_packet(const struct rxrpc_call *call,
 	/* validate the security checksum */
 	x = htonl(call->channel << (32 - RXRPC_CIDSHIFT));
 	x |= sp->hdr.seq & __constant_cpu_to_be32(0x3fffffff);
-	tmpbuf[0] = call->call_id;
-	tmpbuf[1] = x;
+	tmpbuf.x[0] = call->call_id;
+	tmpbuf.x[1] = x;
 
-	crypto_blkcipher_encrypt_kernel_iv(&desc, (void *) tmpbuf,
-					   (void *) tmpbuf, sizeof(tmpbuf));
+	memset(&sg, 0, sizeof(sg));
+	sg_set_buf(&sg[0], &tmpbuf, sizeof(tmpbuf));
+	sg_set_buf(&sg[1], &tmpbuf, sizeof(tmpbuf));
+	crypto_blkcipher_encrypt_iv(&desc, &sg[0], &sg[1], sizeof(tmpbuf));
 
-	x = ntohl(tmpbuf[1]);
+	x = ntohl(tmpbuf.x[1]);
 	x = (x >> 16) & 0xffff;
 	if (x == 0)
 		x = 1; /* zero checksums are not permitted */
@@ -661,6 +684,25 @@ static void rxkad_calc_response_checksum(struct rxkad_response *response)
 }
 
 /*
+ * load a scatterlist with a potentially split-page buffer
+ */
+static void rxkad_sg_set_buf2(struct scatterlist sg[2],
+			      void *buf, size_t buflen)
+{
+
+	memset(sg, 0, sizeof(sg));
+
+	sg_set_buf(&sg[0], buf, buflen);
+	if (sg[0].offset + buflen > PAGE_SIZE) {
+		/* the buffer was split over two pages */
+		sg[0].length = PAGE_SIZE - sg[0].offset;
+		sg_set_buf(&sg[1], buf + sg[0].length, buflen - sg[0].length);
+	}
+
+	ASSERTCMP(sg[0].length + sg[1].length, ==, buflen);
+}
+
+/*
  * encrypt the response packet
  */
 static void rxkad_encrypt_response(struct rxrpc_connection *conn,
@@ -669,6 +711,7 @@ static void rxkad_encrypt_response(struct rxrpc_connection *conn,
 {
 	struct blkcipher_desc desc;
 	struct rxrpc_crypt iv;
+	struct scatterlist ssg[2], dsg[2];
 
 	/* continue encrypting from where we left off */
 	memcpy(&iv, s2->session_key, sizeof(iv));
@@ -676,10 +719,9 @@ static void rxkad_encrypt_response(struct rxrpc_connection *conn,
 	desc.info = iv.x;
 	desc.flags = 0;
 
-	crypto_blkcipher_encrypt_kernel_iv(&desc,
-					   (void *) &resp->encrypted,
-					   (void *) &resp->encrypted,
-					   sizeof(resp->encrypted));
+	rxkad_sg_set_buf2(ssg, &resp->encrypted, sizeof(resp->encrypted));
+	memcpy(dsg, ssg, sizeof(dsg));
+	crypto_blkcipher_encrypt_iv(&desc, dsg, ssg, sizeof(resp->encrypted));
 }
 
 /*
@@ -691,7 +733,8 @@ static int rxkad_respond_to_challenge(struct rxrpc_connection *conn,
 {
 	const struct rxrpc_key_payload *payload;
 	struct rxkad_challenge challenge;
-	struct rxkad_response resp;
+	struct rxkad_response resp
+		__attribute__((aligned(8))); /* must be aligned for crypto */
 	struct rxrpc_skb_priv *sp;
 	u32 version, nonce, min_level, abort_code;
 	int ret;
@@ -773,6 +816,7 @@ static int rxkad_decrypt_ticket(struct rxrpc_connection *conn,
 {
 	struct blkcipher_desc desc;
 	struct rxrpc_crypt iv, key;
+	struct scatterlist ssg[1], dsg[1];
 	struct in_addr addr;
 	unsigned life;
 	time_t issue, now;
@@ -797,6 +841,7 @@ static int rxkad_decrypt_ticket(struct rxrpc_connection *conn,
 	}
 
 	ASSERT(conn->server_key->payload.data != NULL);
+	ASSERTCMP((unsigned long) ticket & 7UL, ==, 0);
 
 	memcpy(&iv, &conn->server_key->type_data, sizeof(iv));
 
@@ -804,7 +849,9 @@ static int rxkad_decrypt_ticket(struct rxrpc_connection *conn,
 	desc.info = iv.x;
 	desc.flags = 0;
 
-	crypto_blkcipher_decrypt_kernel_iv(&desc, ticket, ticket, ticket_len);
+	sg_init_one(&ssg[0], ticket, ticket_len);
+	memcpy(dsg, ssg, sizeof(dsg));
+	crypto_blkcipher_decrypt_iv(&desc, dsg, ssg, ticket_len);
 
 	p = ticket;
 	end = p + ticket_len;
@@ -913,6 +960,7 @@ static void rxkad_decrypt_response(struct rxrpc_connection *conn,
 				   const struct rxrpc_crypt *session_key)
 {
 	struct blkcipher_desc desc;
+	struct scatterlist ssg[2], dsg[2];
 	struct rxrpc_crypt iv;
 
 	_enter(",,%08x%08x",
@@ -930,10 +978,9 @@ static void rxkad_decrypt_response(struct rxrpc_connection *conn,
 	desc.info = iv.x;
 	desc.flags = 0;
 
-	crypto_blkcipher_decrypt_kernel_iv(&desc,
-					   (void *) &resp->encrypted,
-					   (void *) &resp->encrypted,
-					   sizeof(resp->encrypted));
+	rxkad_sg_set_buf2(ssg, &resp->encrypted, sizeof(resp->encrypted));
+	memcpy(dsg, ssg, sizeof(dsg));
+	crypto_blkcipher_decrypt_iv(&desc, dsg, ssg, sizeof(resp->encrypted));
 	mutex_unlock(&rxkad_ci_mutex);
 
 	_leave("");
@@ -946,7 +993,8 @@ static int rxkad_verify_response(struct rxrpc_connection *conn,
 				 struct sk_buff *skb,
 				 u32 *_abort_code)
 {
-	struct rxkad_response response;
+	struct rxkad_response response
+		__attribute__((aligned(8))); /* must be aligned for crypto */
 	struct rxrpc_skb_priv *sp;
 	struct rxrpc_crypt session_key;
 	time_t expiry;
