From: Imre Palik <imrep.amz@gmail.com>
Subject: [RFC PATCH v2] bridge: make it possible for packets to traverse the bridge without hitting netfilter
Date: Mon, 23 Feb 2015 16:26:03 +0100
Message-ID: <1424705163-13428-1-git-send-email-imrep.amz@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, fw@strlen.de,
	"Palik, Imre" <imrep@amazon.de>,
	Anthony Liguori <aliguori@amazon.com>
To: bridge@lists.linux-foundation.org,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Palik, Imre" <imrep@amazon.de>

The netfilter code is made with flexibility instead of performance in mind.
So when all we want is to pass packets between different interfaces, the
performance penalty of hitting netfilter code can be considerable, even when
all the firewalling is disabled for the bridge.

This change makes it possible to disable netfilter on a per bridge basis.
In the case interesting to us, this can lead to more than 15% speedup
compared to the case when only bridge-iptables is disabled.

Cc: Anthony Liguori <aliguori@amazon.com>
Signed-off-by: Imre Palik <imrep@amazon.de>
---
 net/bridge/br_device.c   |    2 ++
 net/bridge/br_forward.c  |   23 +++++++++++++++++++++--
 net/bridge/br_input.c    |    4 ++--
 net/bridge/br_private.h  |    1 +
 net/bridge/br_sysfs_br.c |   23 +++++++++++++++++++++++
 5 files changed, 49 insertions(+), 4 deletions(-)

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index ffd379d..6fb0343 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -381,6 +381,8 @@ void br_dev_setup(struct net_device *dev)
 
 	ether_addr_copy(br->group_addr, eth_reserved_addr_base);
 
+	br->call_nf = 1;
+
 	br->stp_enabled = BR_NO_STP;
 	br->group_fwd_mask = BR_GROUPFWD_DEFAULT;
 	br->group_fwd_mask_required = BR_GROUPFWD_DEFAULT;
diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index f96933a..aa944d0 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -81,6 +81,26 @@ static void __br_deliver(const struct net_bridge_port *to, struct sk_buff *skb)
 		br_forward_finish);
 }
 
+static int br_nf_do_forward(struct sk_buff *skb, struct net_device *indev)
+{
+	struct net_bridge_port *p;
+	struct net_bridge *br;
+
+	p = br_port_get_rcu(indev);
+	if (!p) {
+		kfree(skb);
+		return NF_DROP;
+	}
+	br = p->br;
+	if (!br->call_nf) {
+		skb_push(skb, ETH_HLEN);
+		return dev_queue_xmit(skb);
+	} else {
+		return NF_HOOK(NFPROTO_BRIDGE, NF_BR_FORWARD, skb, indev,
+			skb->dev, br_forward_finish);
+	}
+}
+
 static void __br_forward(const struct net_bridge_port *to, struct sk_buff *skb)
 {
 	struct net_device *indev;
@@ -98,8 +118,7 @@ static void __br_forward(const struct net_bridge_port *to, struct sk_buff *skb)
 	skb->dev = to->dev;
 	skb_forward_csum(skb);
 
-	NF_HOOK(NFPROTO_BRIDGE, NF_BR_FORWARD, skb, indev, skb->dev,
-		br_forward_finish);
+	br_nf_do_forward(skb, indev);
 }
 
 /* called with rcu_read_lock */
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index e2aa7be..04af67f 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -299,8 +299,8 @@ forward:
 		if (ether_addr_equal(p->br->dev->dev_addr, dest))
 			skb->pkt_type = PACKET_HOST;
 
-		NF_HOOK(NFPROTO_BRIDGE, NF_BR_PRE_ROUTING, skb, skb->dev, NULL,
-			br_handle_frame_finish);
+		NF_HOOK_COND(NFPROTO_BRIDGE, NF_BR_PRE_ROUTING, skb, skb->dev,
+			NULL, br_handle_frame_finish, p->br->call_nf);
 		break;
 	default:
 drop:
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index de09199..a27f4ad 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -219,6 +219,7 @@ struct net_bridge
 	bool				nf_call_ip6tables;
 	bool				nf_call_arptables;
 #endif
+	bool				call_nf;
 	u16				group_fwd_mask;
 	u16				group_fwd_mask_required;
 
diff --git a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
index 4c97fc5..b5061592 100644
--- a/net/bridge/br_sysfs_br.c
+++ b/net/bridge/br_sysfs_br.c
@@ -344,6 +344,28 @@ static ssize_t flush_store(struct device *d,
 }
 static DEVICE_ATTR_WO(flush);
 
+static ssize_t call_nf_show(
+	struct device *d, struct device_attribute *attr, char *buf)
+{
+	struct net_bridge *br = to_bridge(d);
+	return sprintf(buf, "%u\n", br->call_nf);
+}
+
+static int set_call_nf(struct net_bridge *br, unsigned long val)
+{
+	br->call_nf = val ? true : false;
+	return 0;
+}
+
+static ssize_t call_nf_store(
+	struct device *d, struct device_attribute *attr, const char *buf,
+	size_t len)
+{
+	return store_bridge_parm(d, buf, len, set_call_nf);
+}
+static DEVICE_ATTR(call_nf, S_IRUGO | S_IWUSR,
+		   call_nf_show, call_nf_store);
+
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 static ssize_t multicast_router_show(struct device *d,
 				     struct device_attribute *attr, char *buf)
@@ -763,6 +785,7 @@ static struct attribute *bridge_attrs[] = {
 	&dev_attr_gc_timer.attr,
 	&dev_attr_group_addr.attr,
 	&dev_attr_flush.attr,
+	&dev_attr_call_nf.attr,
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 	&dev_attr_multicast_router.attr,
 	&dev_attr_multicast_snooping.attr,
-- 
1.7.9.5
