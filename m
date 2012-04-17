From: "Peter Huang (Peng)" <peter.huangpeng@huawei.com>
Subject: [PATCH] set fake_rtable's dst to NULL to avoid kernel Oops.
Date: Tue, 17 Apr 2012 14:22:26 +0800
Message-ID: <000001cd1c62$75d10de0$617329a0$%huangpeng@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7BIT
Cc: eric.dumazet@gmail.com, linux-kernel@vger.kernel.org,
	ctrix+debianbugs@navynet.it, peter.huangpeng@huawei.com,
	peter.huangpeng@gmail.com, harry.majun@huawei.com
To: shemminger@vyatta.com, "'David S. Miller'" <davem@davemloft.net>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-language: zh-cn
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When bridge is deleted before tap/vif device's delete, kernel may encounter an oops because of NULL reference to fake_rtable's dst.
Set fake_rtable's dst to NULL before sending packets out can solve this problem.


Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Peter Huang <peter.huangpeng@huawei.com>
---
include/linux/netfilter_bridge.h |    8 ++++++++
 net/bridge/br_forward.c          |    1 +
 net/bridge/br_netfilter.c        |    6 +-----
 3 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/include/linux/netfilter_bridge.h b/include/linux/netfilter_bridge.h
index 0ddd161..70744fe 100644
--- a/include/linux/netfilter_bridge.h
+++ b/include/linux/netfilter_bridge.h
@@ -104,9 +104,17 @@ struct bridge_skb_cb {
 	} daddr;
 };
 
+static inline void br_drop_fake_rtable(struct sk_buff *skb) {
+	struct dst_entry *dst = skb_dst(skb);
+	/* abuse fact that only fake_rtable has DST_NOPEER set */
+	if (dst && (dst->flags & DST_NOPEER))
+		skb_dst_drop(skb);
+}
+
 #else
 #define nf_bridge_maybe_copy_header(skb)	(0)
 #define nf_bridge_pad(skb)			(0)
+#define br_drop_fake_rtable(skb)		(0)
 #endif /* CONFIG_BRIDGE_NETFILTER */
 
 #endif /* __KERNEL__ */
diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c index 61f6534..a2098e3 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -47,6 +47,7 @@ int br_dev_queue_push_xmit(struct sk_buff *skb)
 		kfree_skb(skb);
 	} else {
 		skb_push(skb, ETH_HLEN);
+		br_drop_fake_rtable(skb);
 		dev_queue_xmit(skb);
 	}
 
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c index dec4f38..946dcb0 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -694,11 +694,7 @@ static unsigned int br_nf_local_in(unsigned int hook, struct sk_buff *skb,
 				   const struct net_device *out,
 				   int (*okfn)(struct sk_buff *))
 {
-	struct rtable *rt = skb_rtable(skb);
-
-	if (rt && rt == bridge_parent_rtable(in))
-		skb_dst_drop(skb);
-
+	br_drop_fake_rtable(skb);
 	return NF_ACCEPT;
 }
--------------------------------
Peter Huang(peng)
