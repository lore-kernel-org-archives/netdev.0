From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 10/53] netns xfrm: per-netns xfrm_hash_work
Date: Tue, 25 Nov 2008 20:26:42 +0300
Message-ID: <1227634045-27534-10-git-send-email-adobriyan@gmail.com>
References: <1227634045-27534-1-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-2-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-3-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-4-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-5-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-6-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-7-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-8-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-9-git-send-email-adobriyan@gmail.com>
Cc: herbert@gondor.apana.org.au, kuznet@ms2.inr.ac.ru,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	Alexey Dobriyan <adobriyan@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:28929 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753842AbYKYRXz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 12:23:55 -0500
Received: by ug-out-1314.google.com with SMTP id 39so1144223ugf.37
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2008 09:23:54 -0800 (PST)
In-Reply-To: <1227634045-27534-9-git-send-email-adobriyan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All of this is implicit passing which netns's hashes should be resized.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 include/net/netns/xfrm.h |    2 ++
 net/xfrm/xfrm_state.c    |   35 +++++++++++++++++------------------
 2 files changed, 19 insertions(+), 18 deletions(-)

diff --git a/include/net/netns/xfrm.h b/include/net/netns/xfrm.h
index 492b471..bd68802 100644
--- a/include/net/netns/xfrm.h
+++ b/include/net/netns/xfrm.h
@@ -2,6 +2,7 @@
 #define __NETNS_XFRM_H
 
 #include <linux/list.h>
+#include <linux/workqueue.h>
 
 struct netns_xfrm {
 	struct list_head	state_all;
@@ -18,6 +19,7 @@ struct netns_xfrm {
 	struct hlist_head	*state_byspi;
 	unsigned int		state_hmask;
 	unsigned int		state_num;
+	struct work_struct	state_hash_work;
 };
 
 #endif
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 7ecf6ee..1b2a72c 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -109,16 +109,16 @@ static void xfrm_hash_transfer(struct hlist_head *list,
 	}
 }
 
-static unsigned long xfrm_hash_new_size(void)
+static unsigned long xfrm_hash_new_size(unsigned int state_hmask)
 {
-	return ((init_net.xfrm.state_hmask + 1) << 1) *
-		sizeof(struct hlist_head);
+	return ((state_hmask + 1) << 1) * sizeof(struct hlist_head);
 }
 
 static DEFINE_MUTEX(hash_resize_mutex);
 
-static void xfrm_hash_resize(struct work_struct *__unused)
+static void xfrm_hash_resize(struct work_struct *work)
 {
+	struct net *net = container_of(work, struct net, xfrm.state_hash_work);
 	struct hlist_head *ndst, *nsrc, *nspi, *odst, *osrc, *ospi;
 	unsigned long nsize, osize;
 	unsigned int nhashmask, ohashmask;
@@ -126,7 +126,7 @@ static void xfrm_hash_resize(struct work_struct *__unused)
 
 	mutex_lock(&hash_resize_mutex);
 
-	nsize = xfrm_hash_new_size();
+	nsize = xfrm_hash_new_size(net->xfrm.state_hmask);
 	ndst = xfrm_hash_alloc(nsize);
 	if (!ndst)
 		goto out_unlock;
@@ -145,19 +145,19 @@ static void xfrm_hash_resize(struct work_struct *__unused)
 	spin_lock_bh(&xfrm_state_lock);
 
 	nhashmask = (nsize / sizeof(struct hlist_head)) - 1U;
-	for (i = init_net.xfrm.state_hmask; i >= 0; i--)
-		xfrm_hash_transfer(init_net.xfrm.state_bydst+i, ndst, nsrc, nspi,
+	for (i = net->xfrm.state_hmask; i >= 0; i--)
+		xfrm_hash_transfer(net->xfrm.state_bydst+i, ndst, nsrc, nspi,
 				   nhashmask);
 
-	odst = init_net.xfrm.state_bydst;
-	osrc = init_net.xfrm.state_bysrc;
-	ospi = init_net.xfrm.state_byspi;
-	ohashmask = init_net.xfrm.state_hmask;
+	odst = net->xfrm.state_bydst;
+	osrc = net->xfrm.state_bysrc;
+	ospi = net->xfrm.state_byspi;
+	ohashmask = net->xfrm.state_hmask;
 
-	init_net.xfrm.state_bydst = ndst;
-	init_net.xfrm.state_bysrc = nsrc;
-	init_net.xfrm.state_byspi = nspi;
-	init_net.xfrm.state_hmask = nhashmask;
+	net->xfrm.state_bydst = ndst;
+	net->xfrm.state_bysrc = nsrc;
+	net->xfrm.state_byspi = nspi;
+	net->xfrm.state_hmask = nhashmask;
 
 	spin_unlock_bh(&xfrm_state_lock);
 
@@ -170,8 +170,6 @@ out_unlock:
 	mutex_unlock(&hash_resize_mutex);
 }
 
-static DECLARE_WORK(xfrm_hash_work, xfrm_hash_resize);
-
 DECLARE_WAIT_QUEUE_HEAD(km_waitq);
 EXPORT_SYMBOL(km_waitq);
 
@@ -754,7 +752,7 @@ static void xfrm_hash_grow_check(int have_hash_collision)
 	if (have_hash_collision &&
 	    (init_net.xfrm.state_hmask + 1) < xfrm_state_hashmax &&
 	    init_net.xfrm.state_num > init_net.xfrm.state_hmask)
-		schedule_work(&xfrm_hash_work);
+		schedule_work(&init_net.xfrm.state_hash_work);
 }
 
 struct xfrm_state *
@@ -2089,6 +2087,7 @@ int __net_init xfrm_state_init(struct net *net)
 	net->xfrm.state_hmask = ((sz / sizeof(struct hlist_head)) - 1);
 
 	net->xfrm.state_num = 0;
+	INIT_WORK(&net->xfrm.state_hash_work, xfrm_hash_resize);
 	INIT_WORK(&xfrm_state_gc_work, xfrm_state_gc_task);
 	return 0;
 
-- 
1.5.6.5

