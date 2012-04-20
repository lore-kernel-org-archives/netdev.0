From: "Peter Huang(Peng)" <peter.huangpeng@huawei.com>
Subject: [PATCH v4] set fake_rtable's dst to NULL to avoid kernel Oops
Date: Fri, 20 Apr 2012 14:12:51 +0800
Message-ID: <4F90FE63.9060800@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7BIT
Cc: Eric Dumazet <eric.dumazet@gmail.com>, peter.huangpeng@gmail.com,
	linux-kernel@vger.kernel.org, harry.majun@huawei.com,
	peter.huangpeng@huawei.com,
	Massimo Cetra <ctrix+debianbugs@navynet.it>
To: Stephen Hemminger <shemminger@vyatta.com>,
	"'David S. Miller'" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([58.251.152.64]:51155 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751830Ab2DTGN7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2012 02:13:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bridge: set fake_rtable's dst to NULL to avoid kernel Oops

when bridge is deleted before tap/vif device's delete, kernel may
encounter an oops because of NULL reference to fake_rtable's dst.
Set fake_rtable's dst to NULL before sending packets out can solve
this problem.

v4 reformat, change br_drop_fake_rtable(skb) to {}

v3 enrich commit header

v2 introducing new flag DST_FAKE_RTABLE to dst_entry struct.

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Peter Huang <peter.huangpeng@huawei.com>
---
 include/linux/netfilter_bridge.h |    9 +++++++++
 include/net/dst.h                |    1 +
 net/bridge/br_forward.c          |    1 +
 net/bridge/br_netfilter.c        |    8 ++------
 4 files changed, 13 insertions(+), 6 deletions(-)

diff --git a/include/linux/netfilter_bridge.h b/include/linux/netfilter_bridge.h
index 0ddd161..3da2798 100644
--- a/include/linux/netfilter_bridge.h
+++ b/include/linux/netfilter_bridge.h
@@ -104,9 +104,18 @@ struct bridge_skb_cb {
 	} daddr;
 };
 
+static inline void br_drop_fake_rtable(struct sk_buff *skb)
+{
+	struct dst_entry *dst = skb_dst(skb);
+
+	if (dst && (dst->flags & DST_FAKE_RTABLE))
+		skb_dst_drop(skb);
+}
+
 #else
 #define nf_bridge_maybe_copy_header(skb)	(0)
 #define nf_bridge_pad(skb)			(0)
+#define br_drop_fake_rtable(skb)	        {}
 #endif /* CONFIG_BRIDGE_NETFILTER */
 
 #endif /* __KERNEL__ */
diff --git a/include/net/dst.h b/include/net/dst.h
index 59c5d18..b094030 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -55,6 +55,7 @@ struct dst_entry {
 #define DST_NOCACHE		0x0010
 #define DST_NOCOUNT		0x0020
 #define DST_NOPEER		0x0040
+#define DST_FAKE_RTABLE		0x0080
 
 	short			error;
 	short			obsolete;
diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index 61f6534..a2098e3 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -47,6 +47,7 @@ int br_dev_queue_push_xmit(struct sk_buff *skb)
 		kfree_skb(skb);
 	} else {
 		skb_push(skb, ETH_HLEN);
+		br_drop_fake_rtable(skb);
 		dev_queue_xmit(skb);
 	}
 
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index dec4f38..d7f49b6 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -156,7 +156,7 @@ void br_netfilter_rtable_init(struct net_bridge *br)
 	rt->dst.dev = br->dev;
 	rt->dst.path = &rt->dst;
 	dst_init_metrics(&rt->dst, br_dst_default_metrics, true);
-	rt->dst.flags	= DST_NOXFRM | DST_NOPEER;
+	rt->dst.flags	= DST_NOXFRM | DST_NOPEER | DST_FAKE_RTABLE;
 	rt->dst.ops = &fake_dst_ops;
 }
 
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
 
-- 
1.7.1
