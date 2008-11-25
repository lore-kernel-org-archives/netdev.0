From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 37/53] netns xfrm: flushing/pruning bundles in netns
Date: Tue, 25 Nov 2008 20:27:09 +0300
Message-ID: <1227634045-27534-37-git-send-email-adobriyan@gmail.com>
References: <1227634045-27534-1-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-2-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-3-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-4-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-5-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-6-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-7-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-8-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-9-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-10-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-11-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-12-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-13-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-14-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-15-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-16-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-17-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-18-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-19-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-20-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-21-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-22-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-23-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-24-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-25-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-26-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-27-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-28-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-29-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-30-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-31-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-32-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-33-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-34-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-35-git-send-email-adobriyan@gmail.com>
 <1227634045-27534-36-git-send-email-adobriyan@gmail.com>
Cc: herbert@gondor.apana.org.au, kuznet@ms2.inr.ac.ru,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	Alexey Dobriyan <adobriyan@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.24]:40948 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754351AbYKYRZJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 12:25:09 -0500
Received: by ey-out-2122.google.com with SMTP id 6so23228eyi.37
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2008 09:25:09 -0800 (PST)
In-Reply-To: <1227634045-27534-36-git-send-email-adobriyan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow netdevice notifier as result.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 net/xfrm/xfrm_policy.c |   19 ++++++++-----------
 1 files changed, 8 insertions(+), 11 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 54b50a2..49e0898 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -2137,7 +2137,7 @@ static void prune_one_bundle(struct xfrm_policy *pol, int (*func)(struct dst_ent
 	write_unlock(&pol->lock);
 }
 
-static void xfrm_prune_bundles(int (*func)(struct dst_entry *))
+static void xfrm_prune_bundles(struct net *net, int (*func)(struct dst_entry *))
 {
 	struct dst_entry *gc_list = NULL;
 	int dir;
@@ -2150,11 +2150,11 @@ static void xfrm_prune_bundles(int (*func)(struct dst_entry *))
 		int i;
 
 		hlist_for_each_entry(pol, entry,
-				     &init_net.xfrm.policy_inexact[dir], bydst)
+				     &net->xfrm.policy_inexact[dir], bydst)
 			prune_one_bundle(pol, func, &gc_list);
 
-		table = init_net.xfrm.policy_bydst[dir].table;
-		for (i = init_net.xfrm.policy_bydst[dir].hmask; i >= 0; i--) {
+		table = net->xfrm.policy_bydst[dir].table;
+		for (i = net->xfrm.policy_bydst[dir].hmask; i >= 0; i--) {
 			hlist_for_each_entry(pol, entry, table + i, bydst)
 				prune_one_bundle(pol, func, &gc_list);
 		}
@@ -2175,12 +2175,12 @@ static int unused_bundle(struct dst_entry *dst)
 
 static void __xfrm_garbage_collect(void)
 {
-	xfrm_prune_bundles(unused_bundle);
+	xfrm_prune_bundles(&init_net, unused_bundle);
 }
 
-static int xfrm_flush_bundles(void)
+static int xfrm_flush_bundles(struct net *net)
 {
-	xfrm_prune_bundles(stale_bundle);
+	xfrm_prune_bundles(net, stale_bundle);
 	return 0;
 }
 
@@ -2366,12 +2366,9 @@ static int xfrm_dev_event(struct notifier_block *this, unsigned long event, void
 {
 	struct net_device *dev = ptr;
 
-	if (!net_eq(dev_net(dev), &init_net))
-		return NOTIFY_DONE;
-
 	switch (event) {
 	case NETDEV_DOWN:
-		xfrm_flush_bundles();
+		xfrm_flush_bundles(dev_net(dev));
 	}
 	return NOTIFY_DONE;
 }
-- 
1.5.6.5

