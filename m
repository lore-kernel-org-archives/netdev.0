From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 04/15] xfrm: avoid rcu sparse warning
Date: Wed, 1 Feb 2017 09:17:46 +0100
Message-ID: <1485937077-612-5-git-send-email-steffen.klassert@secunet.com>
References: <1485937077-612-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:37054 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751711AbdBAISJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 1 Feb 2017 03:18:09 -0500
In-Reply-To: <1485937077-612-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

xfrm/xfrm_state.c:1973:21: error: incompatible types in comparison expression (different address spaces)

Harmless, but lets fix it to reduce the noise.

While at it, get rid of unneeded NULL check, its never hit:

net/ipv4/xfrm4_state.c: xfrm_state_register_afinfo(&xfrm4_state_afinfo);
net/ipv6/xfrm6_state.c: return xfrm_state_register_afinfo(&xfrm6_state_afinfo);
net/ipv6/xfrm6_state.c: xfrm_state_unregister_afinfo(&xfrm6_state_afinfo);

... are the only callsites.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_state.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 6b3366f..57e9578 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -1932,10 +1932,10 @@ int xfrm_unregister_km(struct xfrm_mgr *km)
 int xfrm_state_register_afinfo(struct xfrm_state_afinfo *afinfo)
 {
 	int err = 0;
-	if (unlikely(afinfo == NULL))
-		return -EINVAL;
-	if (unlikely(afinfo->family >= NPROTO))
+
+	if (WARN_ON(afinfo->family >= NPROTO))
 		return -EAFNOSUPPORT;
+
 	spin_lock_bh(&xfrm_state_afinfo_lock);
 	if (unlikely(xfrm_state_afinfo[afinfo->family] != NULL))
 		err = -EEXIST;
@@ -1948,14 +1948,14 @@ int xfrm_state_register_afinfo(struct xfrm_state_afinfo *afinfo)
 
 int xfrm_state_unregister_afinfo(struct xfrm_state_afinfo *afinfo)
 {
-	int err = 0;
-	if (unlikely(afinfo == NULL))
-		return -EINVAL;
-	if (unlikely(afinfo->family >= NPROTO))
+	int err = 0, family = afinfo->family;
+
+	if (WARN_ON(family >= NPROTO))
 		return -EAFNOSUPPORT;
+
 	spin_lock_bh(&xfrm_state_afinfo_lock);
 	if (likely(xfrm_state_afinfo[afinfo->family] != NULL)) {
-		if (unlikely(xfrm_state_afinfo[afinfo->family] != afinfo))
+		if (rcu_access_pointer(xfrm_state_afinfo[family]) != afinfo)
 			err = -EINVAL;
 		else
 			RCU_INIT_POINTER(xfrm_state_afinfo[afinfo->family], NULL);
-- 
1.9.1
