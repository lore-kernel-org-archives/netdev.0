From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 4/5] xfrm: Clone states properly on migration
Date: Thu, 27 Feb 2014 07:16:38 +0100
Message-ID: <1393481799-20492-5-git-send-email-steffen.klassert@secunet.com>
References: <1393481799-20492-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:57454 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751613AbaB0GQx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Feb 2014 01:16:53 -0500
In-Reply-To: <1393481799-20492-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We loose a lot of information of the original state if we
clone it with xfrm_state_clone(). In particular, there is
no crypto algorithm attached if the original state uses
an aead algorithm. This patch add the missing information
to the clone state.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/xfrm.h    |   11 +++++++++++
 net/xfrm/xfrm_state.c |    8 ++++++++
 net/xfrm/xfrm_user.c  |    5 -----
 3 files changed, 19 insertions(+), 5 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index afa5730..fb5654a 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1648,6 +1648,11 @@ static inline int xfrm_aevent_is_on(struct net *net)
 }
 #endif
 
+static inline int aead_len(struct xfrm_algo_aead *alg)
+{
+	return sizeof(*alg) + ((alg->alg_key_len + 7) / 8);
+}
+
 static inline int xfrm_alg_len(const struct xfrm_algo *alg)
 {
 	return sizeof(*alg) + ((alg->alg_key_len + 7) / 8);
@@ -1686,6 +1691,12 @@ static inline int xfrm_replay_clone(struct xfrm_state *x,
 	return 0;
 }
 
+static inline struct xfrm_algo_aead *xfrm_algo_aead_clone(struct xfrm_algo_aead *orig)
+{
+	return kmemdup(orig, aead_len(orig), GFP_KERNEL);
+}
+
+
 static inline struct xfrm_algo *xfrm_algo_clone(struct xfrm_algo *orig)
 {
 	return kmemdup(orig, xfrm_alg_len(orig), GFP_KERNEL);
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index c101023..40f1b3e 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -1159,6 +1159,11 @@ static struct xfrm_state *xfrm_state_clone(struct xfrm_state *orig, int *errp)
 	}
 	x->props.aalgo = orig->props.aalgo;
 
+	if (orig->aead) {
+		x->aead = xfrm_algo_aead_clone(orig->aead);
+		if (!x->aead)
+			goto error;
+	}
 	if (orig->ealg) {
 		x->ealg = xfrm_algo_clone(orig->ealg);
 		if (!x->ealg)
@@ -1201,6 +1206,9 @@ static struct xfrm_state *xfrm_state_clone(struct xfrm_state *orig, int *errp)
 	x->props.flags = orig->props.flags;
 	x->props.extra_flags = orig->props.extra_flags;
 
+	x->tfcpad = orig->tfcpad;
+	x->replay_maxdiff = orig->replay_maxdiff;
+	x->replay_maxage = orig->replay_maxage;
 	x->curlft.add_time = orig->curlft.add_time;
 	x->km.state = orig->km.state;
 	x->km.seq = orig->km.seq;
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 1ae3ec7..c274179 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -32,11 +32,6 @@
 #include <linux/in6.h>
 #endif
 
-static inline int aead_len(struct xfrm_algo_aead *alg)
-{
-	return sizeof(*alg) + ((alg->alg_key_len + 7) / 8);
-}
-
 static int verify_one_alg(struct nlattr **attrs, enum xfrm_attr_type_t type)
 {
 	struct nlattr *rt = attrs[type];
-- 
1.7.9.5
