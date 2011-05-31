From: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Subject: [PATCH] ftrace: tracepoint of net_dev_xmit sees freed skb and causes
 panic
Date: Tue, 31 May 2011 16:48:34 +0900
Message-ID: <4DE49D52.709@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com,
	rostedt@goodmis.org, mingo@elte.hu, fweisbec@gmail.com,
	mathieu.desnoyers@efficios.com, tglx@linutronix.de,
	kosaki.motohiro@jp.fujitsu.com, izumi.taku@jp.fujitsu.com,
	kaneshige.kenji@jp.fujitsu.com
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Because there is a possibility that skb is kfree_skb()ed and zero cleared
after ndo_start_xmit, we should not see the contents of skb like skb->len and
skb->dev->name after ndo_start_xmit. But trace_net_dev_xmit does that
and causes panic by NULL pointer dereference.
This patch fixes trace_net_dev_xmit not to see the contents of skb directly.

If you want to reproduce this panic,

1. Get tracepoint of net_dev_xmit on
2. Create 2 guests on KVM
2. Make 2 guests use virtio_net
4. Execute netperf from one to another for a long time as a network burden
5. host will panic(It takes about 30 minutes)

Signed-off-by: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
---
 include/trace/events/net.h |   12 +++++++-----
 net/core/dev.c             |    7 +++++--
 2 files changed, 12 insertions(+), 7 deletions(-)

diff --git a/include/trace/events/net.h b/include/trace/events/net.h
index 5f247f5..f99645d 100644
--- a/include/trace/events/net.h
+++ b/include/trace/events/net.h
@@ -12,22 +12,24 @@
 TRACE_EVENT(net_dev_xmit,
 
 	TP_PROTO(struct sk_buff *skb,
-		 int rc),
+		 int rc,
+		 struct net_device *dev,
+		 unsigned int skb_len),
 
-	TP_ARGS(skb, rc),
+	TP_ARGS(skb, rc, dev, skb_len),
 
 	TP_STRUCT__entry(
 		__field(	void *,		skbaddr		)
 		__field(	unsigned int,	len		)
 		__field(	int,		rc		)
-		__string(	name,		skb->dev->name	)
+		__string(	name,		dev->name	)
 	),
 
 	TP_fast_assign(
 		__entry->skbaddr = skb;
-		__entry->len = skb->len;
+		__entry->len = skb_len;
 		__entry->rc = rc;
-		__assign_str(name, skb->dev->name);
+		__assign_str(name, dev->name);
 	),
 
 	TP_printk("dev=%s skbaddr=%p len=%u rc=%d",
diff --git a/net/core/dev.c b/net/core/dev.c
index d945379..f0e15df 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2089,6 +2089,7 @@ int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 {
 	const struct net_device_ops *ops = dev->netdev_ops;
 	int rc = NETDEV_TX_OK;
+	unsigned int skb_len;
 
 	if (likely(!skb->next)) {
 		u32 features;
@@ -2139,8 +2140,9 @@ int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 			}
 		}
 
+		skb_len = skb->len;
 		rc = ops->ndo_start_xmit(skb, dev);
-		trace_net_dev_xmit(skb, rc);
+		trace_net_dev_xmit(skb, rc, dev, skb_len);
 		if (rc == NETDEV_TX_OK)
 			txq_trans_update(txq);
 		return rc;
@@ -2160,8 +2162,9 @@ gso:
 		if (dev->priv_flags & IFF_XMIT_DST_RELEASE)
 			skb_dst_drop(nskb);
 
+		skb_len = nskb->len;
 		rc = ops->ndo_start_xmit(nskb, dev);
-		trace_net_dev_xmit(nskb, rc);
+		trace_net_dev_xmit(nskb, rc, dev, skb_len);
 		if (unlikely(rc != NETDEV_TX_OK)) {
 			if (rc & ~NETDEV_TX_MASK)
 				goto out_kfree_gso_skb;
