From: Florian Westphal <fw@strlen.de>
Subject: [PATCH ipsec-next 2/6] xfrm: avoid rcu sparse warning
Date: Mon,  9 Jan 2017 14:20:46 +0100
Message-ID: <1483968050-788-3-git-send-email-fw@strlen.de>
References: <1483968050-788-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:48766 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1761424AbdAINUi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 08:20:38 -0500
In-Reply-To: <1483968050-788-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

xfrm/xfrm_state.c:1973:21: error: incompatible types in comparison expression (different address spaces)

Harmless, but lets fix it to reduce the noise.

While at it, get rid of unneeded NULL check, its never hit:

net/ipv4/xfrm4_state.c: xfrm_state_register_afinfo(&xfrm4_state_afinfo);
net/ipv6/xfrm6_state.c: return xfrm_state_register_afinfo(&xfrm6_state_afinfo);
net/ipv6/xfrm6_state.c: xfrm_state_unregister_afinfo(&xfrm6_state_afinfo);

... are the only callsites.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/xfrm/xfrm_state.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 64e3c82eedf6..e3c15ad1b246 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -1932,10 +1932,10 @@ EXPORT_SYMBOL(xfrm_unregister_km);
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
@@ -1948,14 +1948,14 @@ EXPORT_SYMBOL(xfrm_state_register_afinfo);
 
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
2.7.3
