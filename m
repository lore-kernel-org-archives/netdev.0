From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next] net: sctp: remove unused multiple cookie keys
Date: Mon, 11 Feb 2013 15:50:07 +0100
Message-ID: <c1d3c108e6dc72f14e6251543b9ff826f56f5f78.1360593589.git.dborkman@redhat.com>
References: <cover.1360593589.git.dborkman@redhat.com>
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	Vlad Yasevich <vyasevic@redhat.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10295 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756510Ab3BKOuW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Feb 2013 09:50:22 -0500
In-Reply-To: <cover.1360593589.git.dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vlad says: The whole multiple cookie keys code is completely unused
and has been all this time. Noone uses anything other then the
secret_key[0] since there is no changeover support anywhere.

Thus, for now clean up its left-over fragments.

Cc: Vlad Yasevich <vyasevic@redhat.com>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 include/net/sctp/constants.h |  2 +-
 include/net/sctp/structs.h   |  5 +----
 net/sctp/endpointola.c       |  9 ++-------
 net/sctp/sm_make_chunk.c     | 24 ++++++------------------
 4 files changed, 10 insertions(+), 30 deletions(-)

diff --git a/include/net/sctp/constants.h b/include/net/sctp/constants.h
index c29707d..a7dd5c5 100644
--- a/include/net/sctp/constants.h
+++ b/include/net/sctp/constants.h
@@ -303,7 +303,7 @@ enum { SCTP_MAX_GABS = 16 };
                                          * to which we will raise the P-MTU.
 					 */
 #define SCTP_DEFAULT_MINSEGMENT 512	/* MTU size ... if no mtu disc */
-#define SCTP_HOW_MANY_SECRETS 2		/* How many secrets I keep */
+
 #define SCTP_SECRET_SIZE 32		/* Number of octets in a 256 bits. */
 
 #define SCTP_SIGNATURE_SIZE 20	        /* size of a SLA-1 signature */
diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index fdeb85a..0e0f9d2 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -1236,10 +1236,7 @@ struct sctp_endpoint {
 	 *	      Discussion in [RFC1750] can be helpful in
 	 *	      selection of the key.
 	 */
-	__u8 secret_key[SCTP_HOW_MANY_SECRETS][SCTP_SECRET_SIZE];
-	int current_key;
-	int last_key;
-	int key_changed_at;
+	__u8 secret_key[SCTP_SECRET_SIZE];
 
  	/* digest:  This is a digest of the sctp cookie.  This field is
  	 * 	    only used on the receive path when we try to validate
diff --git a/net/sctp/endpointola.c b/net/sctp/endpointola.c
index 1a9c5fb..73aad3d 100644
--- a/net/sctp/endpointola.c
+++ b/net/sctp/endpointola.c
@@ -151,9 +151,7 @@ static struct sctp_endpoint *sctp_endpoint_init(struct sctp_endpoint *ep,
 	ep->rcvbuf_policy = net->sctp.rcvbuf_policy;
 
 	/* Initialize the secret key used with cookie. */
-	get_random_bytes(&ep->secret_key[0], SCTP_SECRET_SIZE);
-	ep->last_key = ep->current_key = 0;
-	ep->key_changed_at = jiffies;
+	get_random_bytes(ep->secret_key, sizeof(ep->secret_key));
 
 	/* SCTP-AUTH extensions*/
 	INIT_LIST_HEAD(&ep->endpoint_shared_keys);
@@ -249,8 +247,6 @@ void sctp_endpoint_free(struct sctp_endpoint *ep)
 /* Final destructor for endpoint.  */
 static void sctp_endpoint_destroy(struct sctp_endpoint *ep)
 {
-	int i;
-
 	SCTP_ASSERT(ep->base.dead, "Endpoint is not dead", return);
 
 	/* Free up the HMAC transform. */
@@ -273,8 +269,7 @@ static void sctp_endpoint_destroy(struct sctp_endpoint *ep)
 	sctp_inq_free(&ep->base.inqueue);
 	sctp_bind_addr_free(&ep->base.bind_addr);
 
-	for (i = 0; i < SCTP_HOW_MANY_SECRETS; ++i)
-		memset(&ep->secret_key[i], 0, SCTP_SECRET_SIZE);
+	memset(ep->secret_key, 0, sizeof(ep->secret_key));
 
 	/* Remove and free the port */
 	if (sctp_sk(ep->base.sk)->bind_hash)
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index e1c5fc2..1063b83 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -1650,8 +1650,8 @@ static sctp_cookie_param_t *sctp_pack_cookie(const struct sctp_endpoint *ep,
 
 		/* Sign the message.  */
 		sg_init_one(&sg, &cookie->c, bodysize);
-		keylen = SCTP_SECRET_SIZE;
-		key = (char *)ep->secret_key[ep->current_key];
+		keylen = sizeof(ep->secret_key);
+		key = (char *) ep->secret_key;
 		desc.tfm = sctp_sk(ep->base.sk)->hmac;
 		desc.flags = 0;
 
@@ -1718,9 +1718,9 @@ struct sctp_association *sctp_unpack_cookie(
 		goto no_hmac;
 
 	/* Check the signature.  */
-	keylen = SCTP_SECRET_SIZE;
 	sg_init_one(&sg, bear_cookie, bodysize);
-	key = (char *)ep->secret_key[ep->current_key];
+	keylen = sizeof(ep->secret_key);
+	key = (char *) ep->secret_key;
 	desc.tfm = sctp_sk(ep->base.sk)->hmac;
 	desc.flags = 0;
 
@@ -1732,20 +1732,8 @@ struct sctp_association *sctp_unpack_cookie(
 	}
 
 	if (memcmp(digest, cookie->signature, SCTP_SIGNATURE_SIZE)) {
-		/* Try the previous key. */
-		key = (char *)ep->secret_key[ep->last_key];
-		memset(digest, 0x00, SCTP_SIGNATURE_SIZE);
-		if (crypto_hash_setkey(desc.tfm, key, keylen) ||
-		    crypto_hash_digest(&desc, &sg, bodysize, digest)) {
-			*error = -SCTP_IERROR_NOMEM;
-			goto fail;
-		}
-
-		if (memcmp(digest, cookie->signature, SCTP_SIGNATURE_SIZE)) {
-			/* Yikes!  Still bad signature! */
-			*error = -SCTP_IERROR_BAD_SIG;
-			goto fail;
-		}
+		*error = -SCTP_IERROR_BAD_SIG;
+		goto fail;
 	}
 
 no_hmac:
-- 
1.7.11.7
