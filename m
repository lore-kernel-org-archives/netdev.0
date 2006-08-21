From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 5/7] [SCTP]: Use HMAC template and hash interface
Date: Tue, 22 Aug 2006 00:27:53 +1000
Message-ID: <E1GFAkr-00074T-00@gondolin.me.apana.org.au>
References: <20060821142407.GA26988@gondor.apana.org.au>
Return-path: <linux-crypto-owner@vger.kernel.org>
To: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[SCTP]: Use HMAC template and hash interface

This patch converts SCTP to use the new HMAC template and hash interface.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
Signed-off-by: David S. Miller <davem@davemloft.net>
---

 include/net/sctp/constants.h |    4 ++--
 include/net/sctp/sctp.h      |   11 -----------
 include/net/sctp/structs.h   |    3 ++-
 net/sctp/endpointola.c       |    2 +-
 net/sctp/sm_make_chunk.c     |   37 +++++++++++++++++++++++++++----------
 net/sctp/socket.c            |    6 +++---
 6 files changed, 35 insertions(+), 28 deletions(-)

diff --git a/include/net/sctp/constants.h b/include/net/sctp/constants.h
--- a/include/net/sctp/constants.h
+++ b/include/net/sctp/constants.h
@@ -312,9 +312,9 @@ enum { SCTP_MAX_GABS = 16 };
 				 */
 
 #if defined (CONFIG_SCTP_HMAC_MD5)
-#define SCTP_COOKIE_HMAC_ALG "md5"
+#define SCTP_COOKIE_HMAC_ALG "hmac(md5)"
 #elif defined (CONFIG_SCTP_HMAC_SHA1)
-#define SCTP_COOKIE_HMAC_ALG "sha1"
+#define SCTP_COOKIE_HMAC_ALG "hmac(sha1)"
 #else
 #define SCTP_COOKIE_HMAC_ALG NULL
 #endif
diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -330,17 +330,6 @@ static inline void sctp_v6_exit(void) { 
 
 #endif /* #if defined(CONFIG_IPV6) */
 
-/* Some wrappers, in case crypto not available. */
-#if defined (CONFIG_CRYPTO_HMAC)
-#define sctp_crypto_alloc_tfm crypto_alloc_tfm
-#define sctp_crypto_free_tfm crypto_free_tfm
-#define sctp_crypto_hmac crypto_hmac
-#else
-#define sctp_crypto_alloc_tfm(x...) NULL
-#define sctp_crypto_free_tfm(x...)
-#define sctp_crypto_hmac(x...)
-#endif
-
 
 /* Map an association to an assoc_id. */
 static inline sctp_assoc_t sctp_assoc2id(const struct sctp_association *asoc)
diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -87,6 +87,7 @@ struct sctp_bind_addr;
 struct sctp_ulpq;
 struct sctp_ep_common;
 struct sctp_ssnmap;
+struct crypto_hash;
 
 
 #include <net/sctp/tsnmap.h>
@@ -264,7 +265,7 @@ struct sctp_sock {
 	struct sctp_pf *pf;
 
 	/* Access to HMAC transform. */
-	struct crypto_tfm *hmac;
+	struct crypto_hash *hmac;
 
 	/* What is our base endpointer? */
 	struct sctp_endpoint *ep;
diff --git a/net/sctp/endpointola.c b/net/sctp/endpointola.c
--- a/net/sctp/endpointola.c
+++ b/net/sctp/endpointola.c
@@ -172,7 +172,7 @@ static void sctp_endpoint_destroy(struct
 	sctp_unhash_endpoint(ep);
 
 	/* Free up the HMAC transform. */
-	sctp_crypto_free_tfm(sctp_sk(ep->base.sk)->hmac);
+	crypto_free_hash(sctp_sk(ep->base.sk)->hmac);
 
 	/* Cleanup. */
 	sctp_inq_free(&ep->base.inqueue);
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -1294,10 +1294,8 @@ static sctp_cookie_param_t *sctp_pack_co
 
 	retval = kmalloc(*cookie_len, GFP_ATOMIC);
 
-	if (!retval) {
-		*cookie_len = 0;
+	if (!retval)
 		goto nodata;
-	}
 
 	/* Clear this memory since we are sending this data structure
 	 * out on the network.
@@ -1333,19 +1331,29 @@ static sctp_cookie_param_t *sctp_pack_co
 	       ntohs(init_chunk->chunk_hdr->length), raw_addrs, addrs_len);
 
   	if (sctp_sk(ep->base.sk)->hmac) {
+		struct hash_desc desc;
+
 		/* Sign the message.  */
 		sg.page = virt_to_page(&cookie->c);
 		sg.offset = (unsigned long)(&cookie->c) % PAGE_SIZE;
 		sg.length = bodysize;
 		keylen = SCTP_SECRET_SIZE;
 		key = (char *)ep->secret_key[ep->current_key];
+  		desc.tfm = sctp_sk(ep->base.sk)->hmac;
+  		desc.flags = 0;
 
-		sctp_crypto_hmac(sctp_sk(ep->base.sk)->hmac, key, &keylen,
-				 &sg, 1, cookie->signature);
+		if (crypto_hash_setkey(desc.tfm, key, keylen) ||
+		    crypto_hash_digest(&desc, &sg, bodysize, cookie->signature))
+			goto free_cookie;
 	}
 
-nodata:
 	return retval;
+
+free_cookie:
+	kfree(retval);
+nodata:
+	*cookie_len = 0;
+	return NULL;
 }
 
 /* Unpack the cookie from COOKIE ECHO chunk, recreating the association.  */
@@ -1366,6 +1374,7 @@ struct sctp_association *sctp_unpack_coo
 	sctp_scope_t scope;
 	struct sk_buff *skb = chunk->skb;
 	struct timeval tv;
+	struct hash_desc desc;
 
 	/* Header size is static data prior to the actual cookie, including
 	 * any padding.
@@ -1401,17 +1410,25 @@ struct sctp_association *sctp_unpack_coo
 	sg.offset = (unsigned long)(bear_cookie) % PAGE_SIZE;
 	sg.length = bodysize;
 	key = (char *)ep->secret_key[ep->current_key];
+	desc.tfm = sctp_sk(ep->base.sk)->hmac;
+	desc.flags = 0;
 
 	memset(digest, 0x00, SCTP_SIGNATURE_SIZE);
-	sctp_crypto_hmac(sctp_sk(ep->base.sk)->hmac, key, &keylen, &sg,
-			 1, digest);
+	if (crypto_hash_setkey(desc.tfm, key, keylen) ||
+	    crypto_hash_digest(&desc, &sg, bodysize, digest)) {
+		*error = -SCTP_IERROR_NOMEM;
+		goto fail;
+	}
 
 	if (memcmp(digest, cookie->signature, SCTP_SIGNATURE_SIZE)) {
 		/* Try the previous key. */
 		key = (char *)ep->secret_key[ep->last_key];
 		memset(digest, 0x00, SCTP_SIGNATURE_SIZE);
-		sctp_crypto_hmac(sctp_sk(ep->base.sk)->hmac, key, &keylen,
-				 &sg, 1, digest);
+		if (crypto_hash_setkey(desc.tfm, key, keylen) ||
+		    crypto_hash_digest(&desc, &sg, bodysize, digest)) {
+			*error = -SCTP_IERROR_NOMEM;
+			goto fail;
+		}
 
 		if (memcmp(digest, cookie->signature, SCTP_SIGNATURE_SIZE)) {
 			/* Yikes!  Still bad signature! */
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -4842,7 +4842,7 @@ SCTP_STATIC int sctp_stream_listen(struc
 int sctp_inet_listen(struct socket *sock, int backlog)
 {
 	struct sock *sk = sock->sk;
-	struct crypto_tfm *tfm=NULL;
+	struct crypto_hash *tfm = NULL;
 	int err = -EINVAL;
 
 	if (unlikely(backlog < 0))
@@ -4855,7 +4855,7 @@ int sctp_inet_listen(struct socket *sock
 
 	/* Allocate HMAC for generating cookie. */
 	if (sctp_hmac_alg) {
-		tfm = sctp_crypto_alloc_tfm(sctp_hmac_alg, 0);
+		tfm = crypto_alloc_hash(sctp_hmac_alg, 0, CRYPTO_ALG_ASYNC);
 		if (!tfm) {
 			err = -ENOSYS;
 			goto out;
@@ -4881,7 +4881,7 @@ out:
 	sctp_release_sock(sk);
 	return err;
 cleanup:
-	sctp_crypto_free_tfm(tfm);
+	crypto_free_hash(tfm);
 	goto out;
 }
 
