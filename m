From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 09/53] netns xfrm: per-netns xfrm_state counts
Date: Tue, 25 Nov 2008 20:26:41 +0300
Message-ID: <1227634045-27534-9-git-send-email-adobriyan@gmail.com>
References: <1227634045-27534-1-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-2-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-3-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-4-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-5-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-6-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-7-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-8-git-send-email-adobriyan@gmail.com>
Cc: herbert@gondor.apana.org.au, kuznet@ms2.inr.ac.ru,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	Alexey Dobriyan <adobriyan@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.190]:3932 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754402AbYKYRXy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 12:23:54 -0500
Received: by nf-out-0910.google.com with SMTP id d3so28136nfc.21
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2008 09:23:51 -0800 (PST)
In-Reply-To: <1227634045-27534-8-git-send-email-adobriyan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 include/net/netns/xfrm.h |    1 +
 net/xfrm/xfrm_state.c    |   14 +++++++-------
 2 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/include/net/netns/xfrm.h b/include/net/netns/xfrm.h
index dbbc0e9..492b471 100644
--- a/include/net/netns/xfrm.h
+++ b/include/net/netns/xfrm.h
@@ -17,6 +17,7 @@ struct netns_xfrm {
 	struct hlist_head	*state_bysrc;
 	struct hlist_head	*state_byspi;
 	unsigned int		state_hmask;
+	unsigned int		state_num;
 };
 
 #endif
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index de08ed9..7ecf6ee 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -45,7 +45,6 @@ u32 sysctl_xfrm_acq_expires __read_mostly = 30;
 static DEFINE_SPINLOCK(xfrm_state_lock);
 
 static unsigned int xfrm_state_hashmax __read_mostly = 1 * 1024 * 1024;
-static unsigned int xfrm_state_num;
 static unsigned int xfrm_state_genid;
 
 static struct xfrm_state_afinfo *xfrm_state_get_afinfo(unsigned int family);
@@ -548,7 +547,7 @@ int __xfrm_state_delete(struct xfrm_state *x)
 		hlist_del(&x->bysrc);
 		if (x->id.spi)
 			hlist_del(&x->byspi);
-		xfrm_state_num--;
+		init_net.xfrm.state_num--;
 		spin_unlock(&xfrm_state_lock);
 
 		/* All xfrm_state objects are created by xfrm_state_alloc.
@@ -650,7 +649,7 @@ EXPORT_SYMBOL(xfrm_state_flush);
 void xfrm_sad_getinfo(struct xfrmk_sadinfo *si)
 {
 	spin_lock_bh(&xfrm_state_lock);
-	si->sadcnt = xfrm_state_num;
+	si->sadcnt = init_net.xfrm.state_num;
 	si->sadhcnt = init_net.xfrm.state_hmask;
 	si->sadhmcnt = xfrm_state_hashmax;
 	spin_unlock_bh(&xfrm_state_lock);
@@ -754,7 +753,7 @@ static void xfrm_hash_grow_check(int have_hash_collision)
 {
 	if (have_hash_collision &&
 	    (init_net.xfrm.state_hmask + 1) < xfrm_state_hashmax &&
-	    xfrm_state_num > init_net.xfrm.state_hmask)
+	    init_net.xfrm.state_num > init_net.xfrm.state_hmask)
 		schedule_work(&xfrm_hash_work);
 }
 
@@ -855,7 +854,7 @@ xfrm_state_find(xfrm_address_t *daddr, xfrm_address_t *saddr,
 			x->lft.hard_add_expires_seconds = sysctl_xfrm_acq_expires;
 			x->timer.expires = jiffies + sysctl_xfrm_acq_expires*HZ;
 			add_timer(&x->timer);
-			xfrm_state_num++;
+			init_net.xfrm.state_num++;
 			xfrm_hash_grow_check(x->bydst.next != NULL);
 		} else {
 			x->km.state = XFRM_STATE_DEAD;
@@ -935,7 +934,7 @@ static void __xfrm_state_insert(struct xfrm_state *x)
 
 	wake_up(&km_waitq);
 
-	xfrm_state_num++;
+	init_net.xfrm.state_num++;
 
 	xfrm_hash_grow_check(x->bydst.next != NULL);
 }
@@ -1047,7 +1046,7 @@ static struct xfrm_state *__find_acq_core(unsigned short family, u8 mode, u32 re
 		h = xfrm_src_hash(daddr, saddr, family);
 		hlist_add_head(&x->bysrc, init_net.xfrm.state_bysrc+h);
 
-		xfrm_state_num++;
+		init_net.xfrm.state_num++;
 
 		xfrm_hash_grow_check(x->bydst.next != NULL);
 	}
@@ -2089,6 +2088,7 @@ int __net_init xfrm_state_init(struct net *net)
 		goto out_byspi;
 	net->xfrm.state_hmask = ((sz / sizeof(struct hlist_head)) - 1);
 
+	net->xfrm.state_num = 0;
 	INIT_WORK(&xfrm_state_gc_work, xfrm_state_gc_task);
 	return 0;
 
-- 
1.5.6.5

