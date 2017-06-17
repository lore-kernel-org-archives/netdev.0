From: Wei Wang <tracywwnj@gmail.com>
Subject: [PATCH v2 net-next 05/21] net: introduce a new function dst_dev_put()
Date: Sat, 17 Jun 2017 10:42:28 -0700
Message-ID: <20170617174244.132862-6-tracywwnj@gmail.com>
References: <20170617174244.132862-1-tracywwnj@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>,
        Martin KaFai Lau <kafai@fb.com>, Wei Wang <weiwan@google.com>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:34941 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752502AbdFQRnh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Jun 2017 13:43:37 -0400
Received: by mail-pf0-f195.google.com with SMTP id s66so11093269pfs.2
        for <netdev@vger.kernel.org>; Sat, 17 Jun 2017 10:43:36 -0700 (PDT)
In-Reply-To: <20170617174244.132862-1-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>

This function should be called when removing routes from fib tree after
the dst gc is no longer in use.
We first mark DST_OBSOLETE_DEAD on this dst to make sure next
dst_ops->check() fails and returns NULL.
Secondly, as we no longer keep the gc_list, we need to properly
release dst->dev right at the moment when the dst is removed from
the fib/fib6 tree.
It does the following:
1. change dst->input and output pointers to dst_discard/dst_dscard_out to
   discard all packets
2. replace dst->dev with loopback interface

Signed-off-by: Wei Wang <weiwan@google.com>
Acked-by: Martin KaFai Lau <kafai@fb.com>
---
 include/net/dst.h |  1 +
 net/core/dst.c    | 24 ++++++++++++++++++++++++
 2 files changed, 25 insertions(+)

diff --git a/include/net/dst.h b/include/net/dst.h
index 2735d5a1e774..11d779803c0d 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -428,6 +428,7 @@ void dst_init(struct dst_entry *dst, struct dst_ops *ops,
 	      unsigned short flags);
 void __dst_free(struct dst_entry *dst);
 struct dst_entry *dst_destroy(struct dst_entry *dst);
+void dst_dev_put(struct dst_entry *dst);
 
 static inline void dst_free(struct dst_entry *dst)
 {
diff --git a/net/core/dst.c b/net/core/dst.c
index 551834c3363f..56998f69b84e 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -296,6 +296,30 @@ static void dst_destroy_rcu(struct rcu_head *head)
 		__dst_free(dst);
 }
 
+/* Operations to mark dst as DEAD and clean up the net device referenced
+ * by dst:
+ * 1. put the dst under loopback interface and discard all tx/rx packets
+ *    on this route.
+ * 2. release the net_device
+ * This function should be called when removing routes from the fib tree
+ * in preparation for a NETDEV_DOWN/NETDEV_UNREGISTER event and also to
+ * make the next dst_ops->check() fail.
+ */
+void dst_dev_put(struct dst_entry *dst)
+{
+	struct net_device *dev = dst->dev;
+
+	dst->obsolete = DST_OBSOLETE_DEAD;
+	if (dst->ops->ifdown)
+		dst->ops->ifdown(dst, dev, true);
+	dst->input = dst_discard;
+	dst->output = dst_discard_out;
+	dst->dev = dev_net(dst->dev)->loopback_dev;
+	dev_hold(dst->dev);
+	dev_put(dev);
+}
+EXPORT_SYMBOL(dst_dev_put);
+
 void dst_release(struct dst_entry *dst)
 {
 	if (dst) {
-- 
2.13.1.518.g3df882009-goog
