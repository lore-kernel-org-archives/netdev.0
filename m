From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 06/15] xfrm: add and use xfrm_state_afinfo_get_rcu
Date: Wed, 1 Feb 2017 09:17:48 +0100
Message-ID: <1485937077-612-7-git-send-email-steffen.klassert@secunet.com>
References: <1485937077-612-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:37074 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751437AbdBAISK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 1 Feb 2017 03:18:10 -0500
In-Reply-To: <1485937077-612-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

xfrm_init_tempstate is always called from within rcu read side section.
We can thus use a simpler function that doesn't call rcu_read_lock
again.

While at it, also make xfrm_init_tempstate return value void, the
return value was never tested.

A followup patch will replace remaining callers of xfrm_state_get_afinfo
with xfrm_state_afinfo_get_rcu variant and then remove the 'old'
get_afinfo interface.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/xfrm.h    |  1 +
 net/xfrm/xfrm_state.c | 25 +++++++++++++++----------
 2 files changed, 16 insertions(+), 10 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 957d0cc..c52197c 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -343,6 +343,7 @@ struct xfrm_state_afinfo {
 int xfrm_state_register_afinfo(struct xfrm_state_afinfo *afinfo);
 int xfrm_state_unregister_afinfo(struct xfrm_state_afinfo *afinfo);
 struct xfrm_state_afinfo *xfrm_state_get_afinfo(unsigned int family);
+struct xfrm_state_afinfo *xfrm_state_afinfo_get_rcu(unsigned int family);
 
 struct xfrm_input_afinfo {
 	unsigned int		family;
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 7830844..b5dad89 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -639,26 +639,23 @@ void xfrm_sad_getinfo(struct net *net, struct xfrmk_sadinfo *si)
 }
 EXPORT_SYMBOL(xfrm_sad_getinfo);
 
-static int
+static void
 xfrm_init_tempstate(struct xfrm_state *x, const struct flowi *fl,
 		    const struct xfrm_tmpl *tmpl,
 		    const xfrm_address_t *daddr, const xfrm_address_t *saddr,
 		    unsigned short family)
 {
-	struct xfrm_state_afinfo *afinfo = xfrm_state_get_afinfo(family);
-	if (!afinfo)
-		return -1;
-	afinfo->init_tempsel(&x->sel, fl);
+	struct xfrm_state_afinfo *afinfo = xfrm_state_afinfo_get_rcu(family);
+
+	if (afinfo)
+		afinfo->init_tempsel(&x->sel, fl);
 
 	if (family != tmpl->encap_family) {
-		rcu_read_unlock();
-		afinfo = xfrm_state_get_afinfo(tmpl->encap_family);
+		afinfo = xfrm_state_afinfo_get_rcu(tmpl->encap_family);
 		if (!afinfo)
-			return -1;
+			return;
 	}
 	afinfo->init_temprop(x, tmpl, daddr, saddr);
-	rcu_read_unlock();
-	return 0;
 }
 
 static struct xfrm_state *__xfrm_state_lookup(struct net *net, u32 mark,
@@ -1966,6 +1963,14 @@ int xfrm_state_unregister_afinfo(struct xfrm_state_afinfo *afinfo)
 }
 EXPORT_SYMBOL(xfrm_state_unregister_afinfo);
 
+struct xfrm_state_afinfo *xfrm_state_afinfo_get_rcu(unsigned int family)
+{
+	if (unlikely(family >= NPROTO))
+		return NULL;
+
+	return rcu_dereference(xfrm_state_afinfo[family]);
+}
+
 struct xfrm_state_afinfo *xfrm_state_get_afinfo(unsigned int family)
 {
 	struct xfrm_state_afinfo *afinfo;
-- 
1.9.1
