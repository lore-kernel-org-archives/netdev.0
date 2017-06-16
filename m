From: Wei Wang <tracywwnj@gmail.com>
Subject: [PATCH net-next 05/21] net: introduce a new function dst_dev_put()
Date: Fri, 16 Jun 2017 10:47:28 -0700
Message-ID: <20170616174744.139688-6-tracywwnj@gmail.com>
References: <20170616174744.139688-1-tracywwnj@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>,
        Martin KaFai Lau <kafai@fb.com>, Wei Wang <weiwan@google.com>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35849 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752406AbdFPRsY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 13:48:24 -0400
Received: by mail-pf0-f193.google.com with SMTP id y7so7563921pfd.3
        for <netdev@vger.kernel.org>; Fri, 16 Jun 2017 10:48:23 -0700 (PDT)
In-Reply-To: <20170616174744.139688-1-tracywwnj@gmail.com>
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
 net/core/dst.c    | 23 +++++++++++++++++++++++
 2 files changed, 24 insertions(+)

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
index 551834c3363f..2031f778bf2a 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -296,6 +296,29 @@ static void dst_destroy_rcu(struct rcu_head *head)
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
+
 void dst_release(struct dst_entry *dst)
 {
 	if (dst) {
-- 
2.13.1.518.g3df882009-goog
