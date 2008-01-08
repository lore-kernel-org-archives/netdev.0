From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [XFRM]: xfrm_algo_clone() allocates too much memory
Date: Tue, 08 Jan 2008 19:37:22 +0100
Message-ID: <4783C2E2.5060102@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010405020806020607090208"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:48323 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752884AbYAHShd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2008 13:37:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010405020806020607090208
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

alg_key_len is the length in bits of the key, not in bytes.

Best way to fix this is to move alg_len() function from net/xfrm/xfrm_user.c 
to include/net/xfrm.h, and to use it in xfrm_algo_clone()

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

  include/net/xfrm.h   |    7 ++++++-
  net/xfrm/xfrm_user.c |    5 -----
  2 files changed, 6 insertions(+), 6 deletions(-)





--------------010405020806020607090208
Content-Type: text/plain;
 name="xfrm_algo_clone.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="xfrm_algo_clone.patch"

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 58dfa82..731f0a8 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1188,10 +1188,15 @@ static inline int xfrm_aevent_is_on(void)
 	return ret;
 }
 
+static inline int alg_len(struct xfrm_algo *alg)
+{
+	return sizeof(*alg) + ((alg->alg_key_len + 7) / 8);
+}
+
 #ifdef CONFIG_XFRM_MIGRATE
 static inline struct xfrm_algo *xfrm_algo_clone(struct xfrm_algo *orig)
 {
-	return (struct xfrm_algo *)kmemdup(orig, sizeof(*orig) + orig->alg_key_len, GFP_KERNEL);
+	return kmemdup(orig, alg_len(orig), GFP_KERNEL);
 }
 
 static inline void xfrm_states_put(struct xfrm_state **states, int n)
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index e75dbdc..aa667a4 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -31,11 +31,6 @@
 #include <linux/in6.h>
 #endif
 
-static inline int alg_len(struct xfrm_algo *alg)
-{
-	return sizeof(*alg) + ((alg->alg_key_len + 7) / 8);
-}
-
 static int verify_one_alg(struct nlattr **attrs, enum xfrm_attr_type_t type)
 {
 	struct nlattr *rt = attrs[type];

--------------010405020806020607090208--
