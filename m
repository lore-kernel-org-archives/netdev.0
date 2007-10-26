From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 2/2] [CRYPTO] users: Fix up scatterlist conversion errors
Date: Fri, 26 Oct 2007 23:00:05 +0800
Message-ID: <E1IlQfN-0003cW-00@gondolin.me.apana.org.au>
References: <20071026145905.GA13850@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3091 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751972AbXJZPAI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2007 11:00:08 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[CRYPTO] users: Fix up scatterlist conversion errors

This patch fixes the errors made in the users of the crypto layer during
the sg_init_table conversion.  It also adds a few conversions that were
missing altogether.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 drivers/crypto/padlock-sha.c          |    4 +-
 drivers/md/dm-crypt.c                 |    2 -
 drivers/net/ppp_mppe.c                |   10 ++++-
 drivers/scsi/iscsi_tcp.c              |    5 +-
 fs/ecryptfs/crypto.c                  |    2 +
 net/ipv4/esp4.c                       |    7 ++-
 net/ipv6/esp6.c                       |    8 +++-
 net/rxrpc/rxkad.c                     |   66 +++++++++++++++++-----------------
 net/sctp/auth.c                       |    3 -
 net/sctp/sm_make_chunk.c              |    6 +--
 net/sunrpc/auth_gss/gss_krb5_crypto.c |   34 +++++++++++++----
 net/sunrpc/auth_gss/gss_spkm3_seal.c  |    2 -
 net/sunrpc/xdr.c                      |    2 +
 13 files changed, 93 insertions(+), 58 deletions(-)

diff --git a/drivers/crypto/padlock-sha.c b/drivers/crypto/padlock-sha.c
index 4e8de16..c666b4e 100644
--- a/drivers/crypto/padlock-sha.c
+++ b/drivers/crypto/padlock-sha.c
@@ -55,7 +55,7 @@ static void padlock_sha_bypass(struct crypto_tfm *tfm)
 	if (ctx(tfm)->data && ctx(tfm)->used) {
 		struct scatterlist sg;
 
-		sg_set_buf(&sg, ctx(tfm)->data, ctx(tfm)->used);
+		sg_init_one(&sg, ctx(tfm)->data, ctx(tfm)->used);
 		crypto_hash_update(&ctx(tfm)->fallback, &sg, sg.length);
 	}
 
@@ -79,7 +79,7 @@ static void padlock_sha_update(struct crypto_tfm *tfm,
 
 	if (unlikely(ctx(tfm)->bypass)) {
 		struct scatterlist sg;
-		sg_set_buf(&sg, (uint8_t *)data, length);
+		sg_init_one(&sg, (uint8_t *)data, length);
 		crypto_hash_update(&ctx(tfm)->fallback, &sg, length);
 		return;
 	}
diff --git a/drivers/md/dm-crypt.c b/drivers/md/dm-crypt.c
index 1c159ac..28c6ae0 100644
--- a/drivers/md/dm-crypt.c
+++ b/drivers/md/dm-crypt.c
@@ -168,7 +168,7 @@ static int crypt_iv_essiv_ctr(struct crypt_config *cc, struct dm_target *ti,
 		return -ENOMEM;
 	}
 
-	sg_set_buf(&sg, cc->key, cc->key_size);
+	sg_init_one(&sg, cc->key, cc->key_size);
 	desc.tfm = hash_tfm;
 	desc.flags = CRYPTO_TFM_REQ_MAY_SLEEP;
 	err = crypto_hash_digest(&desc, &sg, cc->key_size, salt);
diff --git a/drivers/net/ppp_mppe.c b/drivers/net/ppp_mppe.c
index bcb0885..b35d794 100644
--- a/drivers/net/ppp_mppe.c
+++ b/drivers/net/ppp_mppe.c
@@ -68,7 +68,7 @@ MODULE_VERSION("1.0.2");
 static unsigned int
 setup_sg(struct scatterlist *sg, const void *address, unsigned int length)
 {
-	sg_init_one(sg, address, length);
+	sg_set_buf(sg, address, length);
 	return length;
 }
 
@@ -140,6 +140,8 @@ static void get_new_key_from_sha(struct ppp_mppe_state * state)
 	struct scatterlist sg[4];
 	unsigned int nbytes;
 
+	sg_init_table(sg, 4);
+
 	nbytes = setup_sg(&sg[0], state->master_key, state->keylen);
 	nbytes += setup_sg(&sg[1], sha_pad->sha_pad1,
 			   sizeof(sha_pad->sha_pad1));
@@ -166,6 +168,8 @@ static void mppe_rekey(struct ppp_mppe_state * state, int initial_key)
 	if (!initial_key) {
 		crypto_blkcipher_setkey(state->arc4, state->sha1_digest,
 					state->keylen);
+		sg_init_table(sg_in, 1);
+		sg_init_table(sg_out, 1);
 		setup_sg(sg_in, state->sha1_digest, state->keylen);
 		setup_sg(sg_out, state->session_key, state->keylen);
 		if (crypto_blkcipher_encrypt(&desc, sg_out, sg_in,
@@ -421,6 +425,8 @@ mppe_compress(void *arg, unsigned char *ibuf, unsigned char *obuf,
 	isize -= 2;
 
 	/* Encrypt packet */
+	sg_init_table(sg_in, 1);
+	sg_init_table(sg_out, 1);
 	setup_sg(sg_in, ibuf, isize);
 	setup_sg(sg_out, obuf, osize);
 	if (crypto_blkcipher_encrypt(&desc, sg_out, sg_in, isize) != 0) {
@@ -608,6 +614,8 @@ mppe_decompress(void *arg, unsigned char *ibuf, int isize, unsigned char *obuf,
 	 * Decrypt the first byte in order to check if it is
 	 * a compressed or uncompressed protocol field.
 	 */
+	sg_init_table(sg_in, 1);
+	sg_init_table(sg_out, 1);
 	setup_sg(sg_in, ibuf, 1);
 	setup_sg(sg_out, obuf, 1);
 	if (crypto_blkcipher_decrypt(&desc, sg_out, sg_in, 1) != 0) {
diff --git a/drivers/scsi/iscsi_tcp.c b/drivers/scsi/iscsi_tcp.c
index 097a136..4bcf916 100644
--- a/drivers/scsi/iscsi_tcp.c
+++ b/drivers/scsi/iscsi_tcp.c
@@ -674,9 +674,8 @@ partial_sg_digest_update(struct hash_desc *desc, struct scatterlist *sg,
 {
 	struct scatterlist temp;
 
-	memcpy(&temp, sg, sizeof(struct scatterlist));
-	temp.offset = offset;
-	temp.length = length;
+	sg_init_table(&temp, 1);
+	sg_set_page(&temp, sg_page(sg), length, offset);
 	crypto_hash_update(desc, &temp, length);
 }
 
diff --git a/fs/ecryptfs/crypto.c b/fs/ecryptfs/crypto.c
index 7a472b1..9d70289 100644
--- a/fs/ecryptfs/crypto.c
+++ b/fs/ecryptfs/crypto.c
@@ -279,6 +279,8 @@ int virt_to_scatterlist(const void *addr, int size, struct scatterlist *sg,
 	int offset;
 	int remainder_of_page;
 
+	sg_init_table(sg, sg_size);
+
 	while (size > 0 && i < sg_size) {
 		pg = virt_to_page(addr);
 		offset = offset_in_page(addr);
diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index ba98401..194b1e7 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -111,7 +111,9 @@ static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
 				goto unlock;
 		}
 		sg_init_table(sg, nfrags);
-		skb_to_sgvec(skb, sg, esph->enc_data+esp->conf.ivlen-skb->data, clen);
+		sg_mark_end(sg, skb_to_sgvec(skb, sg, esph->enc_data +
+						      esp->conf.ivlen -
+						      skb->data, clen));
 		err = crypto_blkcipher_encrypt(&desc, sg, sg, clen);
 		if (unlikely(sg != &esp->sgbuf[0]))
 			kfree(sg);
@@ -203,7 +205,8 @@ static int esp_input(struct xfrm_state *x, struct sk_buff *skb)
 			goto out;
 	}
 	sg_init_table(sg, nfrags);
-	skb_to_sgvec(skb, sg, sizeof(*esph) + esp->conf.ivlen, elen);
+	sg_mark_end(sg, skb_to_sgvec(skb, sg, sizeof(*esph) + esp->conf.ivlen,
+				     elen));
 	err = crypto_blkcipher_decrypt(&desc, sg, sg, elen);
 	if (unlikely(sg != &esp->sgbuf[0]))
 		kfree(sg);
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index f67d51a..f992405 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -110,7 +110,9 @@ static int esp6_output(struct xfrm_state *x, struct sk_buff *skb)
 				goto unlock;
 		}
 		sg_init_table(sg, nfrags);
-		skb_to_sgvec(skb, sg, esph->enc_data+esp->conf.ivlen-skb->data, clen);
+		sg_mark_end(sg, skb_to_sgvec(skb, sg, esph->enc_data +
+						      esp->conf.ivlen -
+						      skb->data, clen));
 		err = crypto_blkcipher_encrypt(&desc, sg, sg, clen);
 		if (unlikely(sg != &esp->sgbuf[0]))
 			kfree(sg);
@@ -207,7 +209,9 @@ static int esp6_input(struct xfrm_state *x, struct sk_buff *skb)
 			}
 		}
 		sg_init_table(sg, nfrags);
-		skb_to_sgvec(skb, sg, sizeof(*esph) + esp->conf.ivlen, elen);
+		sg_mark_end(sg, skb_to_sgvec(skb, sg,
+					     sizeof(*esph) + esp->conf.ivlen,
+					     elen));
 		ret = crypto_blkcipher_decrypt(&desc, sg, sg, elen);
 		if (unlikely(sg != &esp->sgbuf[0]))
 			kfree(sg);
diff --git a/net/rxrpc/rxkad.c b/net/rxrpc/rxkad.c
index ac3cabd..eebefb6 100644
--- a/net/rxrpc/rxkad.c
+++ b/net/rxrpc/rxkad.c
@@ -135,9 +135,8 @@ static void rxkad_prime_packet_security(struct rxrpc_connection *conn)
 	tmpbuf.x[2] = 0;
 	tmpbuf.x[3] = htonl(conn->security_ix);
 
-	memset(sg, 0, sizeof(sg));
-	sg_set_buf(&sg[0], &tmpbuf, sizeof(tmpbuf));
-	sg_set_buf(&sg[1], &tmpbuf, sizeof(tmpbuf));
+	sg_init_one(&sg[0], &tmpbuf, sizeof(tmpbuf));
+	sg_init_one(&sg[1], &tmpbuf, sizeof(tmpbuf));
 	crypto_blkcipher_encrypt_iv(&desc, &sg[0], &sg[1], sizeof(tmpbuf));
 
 	memcpy(&conn->csum_iv, &tmpbuf.x[2], sizeof(conn->csum_iv));
@@ -180,9 +179,8 @@ static int rxkad_secure_packet_auth(const struct rxrpc_call *call,
 	desc.info = iv.x;
 	desc.flags = 0;
 
-	memset(sg, 0, sizeof(sg));
-	sg_set_buf(&sg[0], &tmpbuf, sizeof(tmpbuf));
-	sg_set_buf(&sg[1], &tmpbuf, sizeof(tmpbuf));
+	sg_init_one(&sg[0], &tmpbuf, sizeof(tmpbuf));
+	sg_init_one(&sg[1], &tmpbuf, sizeof(tmpbuf));
 	crypto_blkcipher_encrypt_iv(&desc, &sg[0], &sg[1], sizeof(tmpbuf));
 
 	memcpy(sechdr, &tmpbuf, sizeof(tmpbuf));
@@ -227,9 +225,8 @@ static int rxkad_secure_packet_encrypt(const struct rxrpc_call *call,
 	desc.info = iv.x;
 	desc.flags = 0;
 
-	memset(sg, 0, sizeof(sg[0]) * 2);
-	sg_set_buf(&sg[0], sechdr, sizeof(rxkhdr));
-	sg_set_buf(&sg[1], &rxkhdr, sizeof(rxkhdr));
+	sg_init_one(&sg[0], sechdr, sizeof(rxkhdr));
+	sg_init_one(&sg[1], &rxkhdr, sizeof(rxkhdr));
 	crypto_blkcipher_encrypt_iv(&desc, &sg[0], &sg[1], sizeof(rxkhdr));
 
 	/* we want to encrypt the skbuff in-place */
@@ -240,7 +237,7 @@ static int rxkad_secure_packet_encrypt(const struct rxrpc_call *call,
 	len = data_size + call->conn->size_align - 1;
 	len &= ~(call->conn->size_align - 1);
 
-	skb_to_sgvec(skb, sg, 0, len);
+	sg_init_table(sg, skb_to_sgvec(skb, sg, 0, len));
 	crypto_blkcipher_encrypt_iv(&desc, sg, sg, len);
 
 	_leave(" = 0");
@@ -290,9 +287,8 @@ static int rxkad_secure_packet(const struct rxrpc_call *call,
 	tmpbuf.x[0] = sp->hdr.callNumber;
 	tmpbuf.x[1] = x;
 
-	memset(&sg, 0, sizeof(sg));
-	sg_set_buf(&sg[0], &tmpbuf, sizeof(tmpbuf));
-	sg_set_buf(&sg[1], &tmpbuf, sizeof(tmpbuf));
+	sg_init_one(&sg[0], &tmpbuf, sizeof(tmpbuf));
+	sg_init_one(&sg[1], &tmpbuf, sizeof(tmpbuf));
 	crypto_blkcipher_encrypt_iv(&desc, &sg[0], &sg[1], sizeof(tmpbuf));
 
 	x = ntohl(tmpbuf.x[1]);
@@ -332,20 +328,23 @@ static int rxkad_verify_packet_auth(const struct rxrpc_call *call,
 	struct rxrpc_skb_priv *sp;
 	struct blkcipher_desc desc;
 	struct rxrpc_crypt iv;
-	struct scatterlist sg[2];
+	struct scatterlist sg[16];
 	struct sk_buff *trailer;
 	u32 data_size, buf;
 	u16 check;
+	int nsg;
 
 	_enter("");
 
 	sp = rxrpc_skb(skb);
 
 	/* we want to decrypt the skbuff in-place */
-	if (skb_cow_data(skb, 0, &trailer) < 0)
+	nsg = skb_cow_data(skb, 0, &trailer);
+	if (nsg < 0 || nsg > 16)
 		goto nomem;
 
-	skb_to_sgvec(skb, sg, 0, 8);
+	sg_init_table(sg, nsg);
+	sg_mark_end(sg, skb_to_sgvec(skb, sg, 0, 8));
 
 	/* start the decryption afresh */
 	memset(&iv, 0, sizeof(iv));
@@ -426,7 +425,8 @@ static int rxkad_verify_packet_encrypt(const struct rxrpc_call *call,
 			goto nomem;
 	}
 
-	skb_to_sgvec(skb, sg, 0, skb->len);
+	sg_init_table(sg, nsg);
+	sg_mark_end(sg, skb_to_sgvec(skb, sg, 0, skb->len));
 
 	/* decrypt from the session key */
 	payload = call->conn->key->payload.data;
@@ -521,9 +521,8 @@ static int rxkad_verify_packet(const struct rxrpc_call *call,
 	tmpbuf.x[0] = call->call_id;
 	tmpbuf.x[1] = x;
 
-	memset(&sg, 0, sizeof(sg));
-	sg_set_buf(&sg[0], &tmpbuf, sizeof(tmpbuf));
-	sg_set_buf(&sg[1], &tmpbuf, sizeof(tmpbuf));
+	sg_init_one(&sg[0], &tmpbuf, sizeof(tmpbuf));
+	sg_init_one(&sg[1], &tmpbuf, sizeof(tmpbuf));
 	crypto_blkcipher_encrypt_iv(&desc, &sg[0], &sg[1], sizeof(tmpbuf));
 
 	x = ntohl(tmpbuf.x[1]);
@@ -690,16 +689,20 @@ static void rxkad_calc_response_checksum(struct rxkad_response *response)
 static void rxkad_sg_set_buf2(struct scatterlist sg[2],
 			      void *buf, size_t buflen)
 {
+	int nsg = 1;
 
-	memset(sg, 0, sizeof(sg));
+	sg_init_table(sg, 2);
 
 	sg_set_buf(&sg[0], buf, buflen);
 	if (sg[0].offset + buflen > PAGE_SIZE) {
 		/* the buffer was split over two pages */
 		sg[0].length = PAGE_SIZE - sg[0].offset;
 		sg_set_buf(&sg[1], buf + sg[0].length, buflen - sg[0].length);
+		nsg++;
 	}
 
+	sg_mark_end(sg, nsg);
+
 	ASSERTCMP(sg[0].length + sg[1].length, ==, buflen);
 }
 
@@ -712,7 +715,7 @@ static void rxkad_encrypt_response(struct rxrpc_connection *conn,
 {
 	struct blkcipher_desc desc;
 	struct rxrpc_crypt iv;
-	struct scatterlist ssg[2], dsg[2];
+	struct scatterlist sg[2];
 
 	/* continue encrypting from where we left off */
 	memcpy(&iv, s2->session_key, sizeof(iv));
@@ -720,9 +723,8 @@ static void rxkad_encrypt_response(struct rxrpc_connection *conn,
 	desc.info = iv.x;
 	desc.flags = 0;
 
-	rxkad_sg_set_buf2(ssg, &resp->encrypted, sizeof(resp->encrypted));
-	memcpy(dsg, ssg, sizeof(dsg));
-	crypto_blkcipher_encrypt_iv(&desc, dsg, ssg, sizeof(resp->encrypted));
+	rxkad_sg_set_buf2(sg, &resp->encrypted, sizeof(resp->encrypted));
+	crypto_blkcipher_encrypt_iv(&desc, sg, sg, sizeof(resp->encrypted));
 }
 
 /*
@@ -817,7 +819,7 @@ static int rxkad_decrypt_ticket(struct rxrpc_connection *conn,
 {
 	struct blkcipher_desc desc;
 	struct rxrpc_crypt iv, key;
-	struct scatterlist ssg[1], dsg[1];
+	struct scatterlist sg[1];
 	struct in_addr addr;
 	unsigned life;
 	time_t issue, now;
@@ -850,9 +852,8 @@ static int rxkad_decrypt_ticket(struct rxrpc_connection *conn,
 	desc.info = iv.x;
 	desc.flags = 0;
 
-	sg_init_one(&ssg[0], ticket, ticket_len);
-	memcpy(dsg, ssg, sizeof(dsg));
-	crypto_blkcipher_decrypt_iv(&desc, dsg, ssg, ticket_len);
+	sg_init_one(&sg[0], ticket, ticket_len);
+	crypto_blkcipher_decrypt_iv(&desc, sg, sg, ticket_len);
 
 	p = ticket;
 	end = p + ticket_len;
@@ -961,7 +962,7 @@ static void rxkad_decrypt_response(struct rxrpc_connection *conn,
 				   const struct rxrpc_crypt *session_key)
 {
 	struct blkcipher_desc desc;
-	struct scatterlist ssg[2], dsg[2];
+	struct scatterlist sg[2];
 	struct rxrpc_crypt iv;
 
 	_enter(",,%08x%08x",
@@ -979,9 +980,8 @@ static void rxkad_decrypt_response(struct rxrpc_connection *conn,
 	desc.info = iv.x;
 	desc.flags = 0;
 
-	rxkad_sg_set_buf2(ssg, &resp->encrypted, sizeof(resp->encrypted));
-	memcpy(dsg, ssg, sizeof(dsg));
-	crypto_blkcipher_decrypt_iv(&desc, dsg, ssg, sizeof(resp->encrypted));
+	rxkad_sg_set_buf2(sg, &resp->encrypted, sizeof(resp->encrypted));
+	crypto_blkcipher_decrypt_iv(&desc, sg, sg, sizeof(resp->encrypted));
 	mutex_unlock(&rxkad_ci_mutex);
 
 	_leave("");
diff --git a/net/sctp/auth.c b/net/sctp/auth.c
index 621113a..7cf9666 100644
--- a/net/sctp/auth.c
+++ b/net/sctp/auth.c
@@ -726,8 +726,7 @@ void sctp_auth_calculate_hmac(const struct sctp_association *asoc,
 
 	/* set up scatter list */
 	end = skb_tail_pointer(skb);
-	sg_init_table(&sg, 1);
-	sg_set_buf(&sg, auth, end - (unsigned char *)auth);
+	sg_init_one(&sg, auth, end - (unsigned char *)auth);
 
 	desc.tfm = asoc->ep->auth_hmacs[hmac_id];
 	desc.flags = 0;
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index c055212..c377e4e 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -1513,8 +1513,7 @@ static sctp_cookie_param_t *sctp_pack_cookie(const struct sctp_endpoint *ep,
 		struct hash_desc desc;
 
 		/* Sign the message.  */
-		sg_init_table(&sg, 1);
-		sg_set_buf(&sg, &cookie->c, bodysize);
+		sg_init_one(&sg, &cookie->c, bodysize);
 		keylen = SCTP_SECRET_SIZE;
 		key = (char *)ep->secret_key[ep->current_key];
 		desc.tfm = sctp_sk(ep->base.sk)->hmac;
@@ -1584,8 +1583,7 @@ struct sctp_association *sctp_unpack_cookie(
 
 	/* Check the signature.  */
 	keylen = SCTP_SECRET_SIZE;
-	sg_init_table(&sg, 1);
-	sg_set_buf(&sg, bear_cookie, bodysize);
+	sg_init_one(&sg, bear_cookie, bodysize);
 	key = (char *)ep->secret_key[ep->current_key];
 	desc.tfm = sctp_sk(ep->base.sk)->hmac;
 	desc.flags = 0;
diff --git a/net/sunrpc/auth_gss/gss_krb5_crypto.c b/net/sunrpc/auth_gss/gss_krb5_crypto.c
index 24711be..91cd8f0 100644
--- a/net/sunrpc/auth_gss/gss_krb5_crypto.c
+++ b/net/sunrpc/auth_gss/gss_krb5_crypto.c
@@ -75,7 +75,7 @@ krb5_encrypt(
 		memcpy(local_iv, iv, crypto_blkcipher_ivsize(tfm));
 
 	memcpy(out, in, length);
-	sg_set_buf(sg, out, length);
+	sg_init_one(sg, out, length);
 
 	ret = crypto_blkcipher_encrypt_iv(&desc, sg, sg, length);
 out:
@@ -110,7 +110,7 @@ krb5_decrypt(
 		memcpy(local_iv,iv, crypto_blkcipher_ivsize(tfm));
 
 	memcpy(out, in, length);
-	sg_set_buf(sg, out, length);
+	sg_init_one(sg, out, length);
 
 	ret = crypto_blkcipher_decrypt_iv(&desc, sg, sg, length);
 out:
@@ -146,7 +146,7 @@ make_checksum(char *cksumname, char *header, int hdrlen, struct xdr_buf *body,
 	err = crypto_hash_init(&desc);
 	if (err)
 		goto out;
-	sg_set_buf(sg, header, hdrlen);
+	sg_init_one(sg, header, hdrlen);
 	err = crypto_hash_update(&desc, sg, hdrlen);
 	if (err)
 		goto out;
@@ -188,8 +188,6 @@ encryptor(struct scatterlist *sg, void *data)
 	/* Worst case is 4 fragments: head, end of page 1, start
 	 * of page 2, tail.  Anything more is a bug. */
 	BUG_ON(desc->fragno > 3);
-	desc->infrags[desc->fragno] = *sg;
-	desc->outfrags[desc->fragno] = *sg;
 
 	page_pos = desc->pos - outbuf->head[0].iov_len;
 	if (page_pos >= 0 && page_pos < outbuf->page_len) {
@@ -199,7 +197,10 @@ encryptor(struct scatterlist *sg, void *data)
 	} else {
 		in_page = sg_page(sg);
 	}
-	sg_assign_page(&desc->infrags[desc->fragno], in_page);
+	sg_set_page(&desc->infrags[desc->fragno], in_page, sg->length,
+		    sg->offset);
+	sg_set_page(&desc->outfrags[desc->fragno], sg_page(sg), sg->length,
+		    sg->offset);
 	desc->fragno++;
 	desc->fraglen += sg->length;
 	desc->pos += sg->length;
@@ -210,10 +211,17 @@ encryptor(struct scatterlist *sg, void *data)
 	if (thislen == 0)
 		return 0;
 
+	sg_mark_end(desc->infrags, desc->fragno);
+	sg_mark_end(desc->outfrags, desc->fragno);
+
 	ret = crypto_blkcipher_encrypt_iv(&desc->desc, desc->outfrags,
 					  desc->infrags, thislen);
 	if (ret)
 		return ret;
+
+	sg_init_table(desc->infrags, 4);
+	sg_init_table(desc->outfrags, 4);
+
 	if (fraglen) {
 		sg_set_page(&desc->outfrags[0], sg_page(sg), fraglen,
 				sg->offset + sg->length - fraglen);
@@ -247,6 +255,9 @@ gss_encrypt_xdr_buf(struct crypto_blkcipher *tfm, struct xdr_buf *buf,
 	desc.fragno = 0;
 	desc.fraglen = 0;
 
+	sg_init_table(desc.infrags, 4);
+	sg_init_table(desc.outfrags, 4);
+
 	ret = xdr_process_buf(buf, offset, buf->len - offset, encryptor, &desc);
 	return ret;
 }
@@ -271,7 +282,8 @@ decryptor(struct scatterlist *sg, void *data)
 	/* Worst case is 4 fragments: head, end of page 1, start
 	 * of page 2, tail.  Anything more is a bug. */
 	BUG_ON(desc->fragno > 3);
-	desc->frags[desc->fragno] = *sg;
+	sg_set_page(&desc->frags[desc->fragno], sg_page(sg), sg->length,
+		    sg->offset);
 	desc->fragno++;
 	desc->fraglen += sg->length;
 
@@ -281,10 +293,15 @@ decryptor(struct scatterlist *sg, void *data)
 	if (thislen == 0)
 		return 0;
 
+	sg_mark_end(desc->frags, desc->fragno);
+
 	ret = crypto_blkcipher_decrypt_iv(&desc->desc, desc->frags,
 					  desc->frags, thislen);
 	if (ret)
 		return ret;
+
+	sg_init_table(desc->frags, 4);
+
 	if (fraglen) {
 		sg_set_page(&desc->frags[0], sg_page(sg), fraglen,
 				sg->offset + sg->length - fraglen);
@@ -312,6 +329,9 @@ gss_decrypt_xdr_buf(struct crypto_blkcipher *tfm, struct xdr_buf *buf,
 	desc.desc.flags = 0;
 	desc.fragno = 0;
 	desc.fraglen = 0;
+
+	sg_init_table(desc.frags, 4);
+
 	return xdr_process_buf(buf, offset, buf->len - offset, decryptor, &desc);
 }
 
diff --git a/net/sunrpc/auth_gss/gss_spkm3_seal.c b/net/sunrpc/auth_gss/gss_spkm3_seal.c
index d158635..abf17ce 100644
--- a/net/sunrpc/auth_gss/gss_spkm3_seal.c
+++ b/net/sunrpc/auth_gss/gss_spkm3_seal.c
@@ -173,7 +173,7 @@ make_spkm3_checksum(s32 cksumtype, struct xdr_netobj *key, char *header,
 	if (err)
 		goto out;
 
-	sg_set_buf(sg, header, hdrlen);
+	sg_init_one(sg, header, hdrlen);
 	crypto_hash_update(&desc, sg, sg->length);
 
 	xdr_process_buf(body, body_offset, body->len - body_offset,
diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index f38dac3..fdc5e6d 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -1030,6 +1030,8 @@ xdr_process_buf(struct xdr_buf *buf, unsigned int offset, unsigned int len,
 	unsigned page_len, thislen, page_offset;
 	struct scatterlist      sg[1];
 
+	sg_init_table(sg, 1);
+
 	if (offset >= buf->head[0].iov_len) {
 		offset -= buf->head[0].iov_len;
 	} else {
