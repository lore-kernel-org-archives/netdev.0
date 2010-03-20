From: Timo Teras <timo.teras@iki.fi>
Subject: [PATCH] xfrm: implement basic garbage collection for bundles
Date: Sat, 20 Mar 2010 14:15:41 +0200
Message-ID: <1269087341-7009-1-git-send-email-timo.teras@iki.fi>
Cc: Timo Teras <timo.teras@iki.fi>,
	Neil Horman <nhorman@tuxdriver.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f216.google.com ([209.85.219.216]:43957 "EHLO
	mail-ew0-f216.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751032Ab0CTMPw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Mar 2010 08:15:52 -0400
Received: by ewy8 with SMTP id 8so231112ewy.28
        for <netdev@vger.kernel.org>; Sat, 20 Mar 2010 05:15:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The dst core calls garbage collection only from dst_alloc when
the dst entry threshold is exceeded. Xfrm core currently checks
bundles only on NETDEV_DOWN event.

Previously this has not been a big problem since xfrm gc threshold
was small, and they were generated all the time due to another bug.

Since after a33bc5c15154c835aae26f16e6a3a7d9ad4acb45
("xfrm: select sane defaults for xfrm[4|6] gc_thresh") we can have
large gc threshold sizes (>200000 on machines with normal amount
of memory) the garbage collection does not get triggered under
normal circumstances. This can result in enormous amount of stale
bundles. Further more, each of these stale bundles keep a reference
to ipv4/ipv6 rtable entries which are already gargage collected and
put to dst core "destroy free'd dst's" list. Now this list can grow
to be very large, and the dst core periodic job can bring even a fast
machine to it's knees.

Signed-off-by: Timo Teras <timo.teras@iki.fi>
Cc: Neil Horman <nhorman@tuxdriver.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
---
 net/xfrm/xfrm_policy.c |   20 +++++++++++++++++++-
 1 files changed, 19 insertions(+), 1 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 843e066..f3f3d36 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -44,6 +44,9 @@ static struct xfrm_policy_afinfo *xfrm_policy_afinfo[NPROTO];
 
 static struct kmem_cache *xfrm_dst_cache __read_mostly;
 
+static int xfrm_gc_interval __read_mostly = 5 * 60 * HZ;
+static struct delayed_work expires_work;
+
 static HLIST_HEAD(xfrm_policy_gc_list);
 static DEFINE_SPINLOCK(xfrm_policy_gc_lock);
 
@@ -2203,6 +2206,16 @@ static int xfrm_flush_bundles(struct net *net)
 	return 0;
 }
 
+static void xfrm_gc_worker_func(struct work_struct *work)
+{
+	struct net *net;
+
+	for_each_net(net)
+		xfrm_flush_bundles(net);
+
+	schedule_delayed_work(&expires_work, xfrm_gc_interval);
+}
+
 static void xfrm_init_pmtu(struct dst_entry *dst)
 {
 	do {
@@ -2498,8 +2511,13 @@ static int __net_init xfrm_policy_init(struct net *net)
 
 	INIT_LIST_HEAD(&net->xfrm.policy_all);
 	INIT_WORK(&net->xfrm.policy_hash_work, xfrm_hash_resize);
-	if (net_eq(net, &init_net))
+	if (net_eq(net, &init_net)) {
 		register_netdevice_notifier(&xfrm_dev_notifier);
+
+		INIT_DELAYED_WORK_DEFERRABLE(&expires_work, xfrm_gc_worker_func);
+		schedule_delayed_work(&expires_work,
+			net_random() % xfrm_gc_interval + xfrm_gc_interval);
+	}
 	return 0;
 
 out_bydst:
-- 
1.6.3.3

