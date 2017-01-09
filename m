From: Florian Westphal <fw@strlen.de>
Subject: [PATCH ipsec-next 4/6] xfrm: add and use xfrm_state_afinfo_get_rcu
Date: Mon,  9 Jan 2017 14:20:48 +0100
Message-ID: <1483968050-788-5-git-send-email-fw@strlen.de>
References: <1483968050-788-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:48774 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1761532AbdAINUp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 08:20:45 -0500
In-Reply-To: <1483968050-788-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

xfrm_init_tempstate is always called from within rcu read side section.
We can thus use a simpler function that doesn't call rcu_read_lock
again.

While at it, also make xfrm_init_tempstate return value void, the
return value was never tested.

A followup patch will replace remaining callers of xfrm_state_get_afinfo
with xfrm_state_afinfo_get_rcu variant and then remove the 'old'
get_afinfo interface.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/net/xfrm.h    |  1 +
 net/xfrm/xfrm_state.c | 25 +++++++++++++++----------
 2 files changed, 16 insertions(+), 10 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 957d0cc30691..c52197cf51dc 100644
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
index 8a9ec1b80bf5..ee1309e2b8b5 100644
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
2.7.3
