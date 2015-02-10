From: Imre Palik <imrep.amz@gmail.com>
Subject: [PATCH] bridge: make it possible for packets to traverse the bridge withour hitting netfilter
Date: Tue, 10 Feb 2015 10:32:24 +0100
Message-ID: <1423560744-19011-1-git-send-email-imrep.amz@gmail.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, "Palik, Imre" <imrep@amazon.de>,
	Anthony Liguori <aliguori@amazon.com>
To: bridge@lists.linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Palik, Imre" <imrep@amazon.de>

The netfilter code is made with flexibility instead of performance in mind.
So when all we want is to pass packets between different interfaces, the
performance penalty of hitting netfilter code can be considerable, even when
all the firewalling is disabled for the bridge.

This change makes it possible to disable netfilter both on a per bridge basis,
or for the whole bridging subsystem.  In the case interesting to us, this can
lead to more than 10% speedup compared to the case when only bridge-iptables
are disabled.

Cc: Anthony Liguori <aliguori@amazon.com>
Signed-off-by: Imre Palik <imrep@amazon.de>
---
 net/bridge/br_forward.c   |    3 +--
 net/bridge/br_input.c     |    3 +--
 net/bridge/br_netfilter.c |   48 +++++++++++++++++++++++++++++++++++++++++++++
 net/bridge/br_private.h   |    9 +++++++++
 net/bridge/br_sysfs_br.c  |   23 ++++++++++++++++++++++
 5 files changed, 82 insertions(+), 4 deletions(-)

diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index f96933a..2931d2a 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -98,8 +98,7 @@ static void __br_forward(const struct net_bridge_port *to, struct sk_buff *skb)
 	skb->dev = to->dev;
 	skb_forward_csum(skb);
 
-	NF_HOOK(NFPROTO_BRIDGE, NF_BR_FORWARD, skb, indev, skb->dev,
-		br_forward_finish);
+	br_nf_do_forward(skb, indev);
 }
 
 /* called with rcu_read_lock */
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index e2aa7be..0edd1d6 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -299,8 +299,7 @@ forward:
 		if (ether_addr_equal(p->br->dev->dev_addr, dest))
 			skb->pkt_type = PACKET_HOST;
 
-		NF_HOOK(NFPROTO_BRIDGE, NF_BR_PRE_ROUTING, skb, skb->dev, NULL,
-			br_handle_frame_finish);
+		br_nf_do_prerouting(skb, p);
 		break;
 	default:
 drop:
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index c190d22..b29c14f 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -50,6 +50,7 @@
 
 #ifdef CONFIG_SYSCTL
 static struct ctl_table_header *brnf_sysctl_header;
+static int brnf_call_netfilter __read_mostly = 1;
 static int brnf_call_iptables __read_mostly = 1;
 static int brnf_call_ip6tables __read_mostly = 1;
 static int brnf_call_arptables __read_mostly = 1;
@@ -57,6 +58,7 @@ static int brnf_filter_vlan_tagged __read_mostly = 0;
 static int brnf_filter_pppoe_tagged __read_mostly = 0;
 static int brnf_pass_vlan_indev __read_mostly = 0;
 #else
+#define brnf_call_netfilter 1
 #define brnf_call_iptables 1
 #define brnf_call_ip6tables 1
 #define brnf_call_arptables 1
@@ -523,6 +525,25 @@ bad:
 
 }
 
+int br_nf_do_prerouting(struct sk_buff *skb, struct net_bridge_port *p)
+{
+	struct net_bridge *br;
+
+	br = p->br;
+
+	if (!brnf_call_netfilter && !br->call_nf) {
+		__u32 len = nf_bridge_encap_header_len(skb);
+
+		if (likely(pskb_may_pull(skb, len)))
+			return br_handle_frame_finish(skb);
+		kfree(skb);
+		return -EPERM;
+	}
+
+	return NF_HOOK(NFPROTO_BRIDGE, NF_BR_PRE_ROUTING, skb, skb->dev, NULL,
+		br_handle_frame_finish);
+}
+
 /* Replicate the checks that IPv6 does on packet reception and pass the packet
  * to ip6tables, which doesn't support NAT, so things are fairly simple. */
 static unsigned int br_nf_pre_routing_ipv6(const struct nf_hook_ops *ops,
@@ -667,6 +688,26 @@ static int br_nf_forward_finish(struct sk_buff *skb)
 	return 0;
 }
 
+int br_nf_do_forward(struct sk_buff *skb, struct net_device *indev)
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
+	if (!brnf_call_netfilter && !br->call_nf) {
+		skb_push(skb, ETH_HLEN);
+		br_drop_fake_rtable(skb);
+		return dev_queue_xmit(skb);
+	} else {
+		return NF_HOOK(NFPROTO_BRIDGE, NF_BR_FORWARD, skb, indev,
+			skb->dev, br_forward_finish);
+	}
+}
 
 /* This is the 'purely bridged' case.  For IP, we pass the packet to
  * netfilter with indev and outdev set to the bridge device,
@@ -929,6 +970,13 @@ int brnf_sysctl_call_tables(struct ctl_table *ctl, int write,
 
 static struct ctl_table brnf_table[] = {
 	{
+		.procname	= "bridge-call-netfilter",
+		.data		= &brnf_call_netfilter,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= brnf_sysctl_call_tables,
+	},
+	{
 		.procname	= "bridge-nf-call-arptables",
 		.data		= &brnf_call_arptables,
 		.maxlen		= sizeof(int),
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index aea3d13..6b0aad9 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -215,6 +215,7 @@ struct net_bridge
 	struct hlist_head		hash[BR_HASH_SIZE];
 #if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
 	struct rtable 			fake_rtable;
+	bool				call_nf;
 	bool				nf_call_iptables;
 	bool				nf_call_ip6tables;
 	bool				nf_call_arptables;
@@ -763,10 +764,18 @@ static inline int br_vlan_enabled(struct net_bridge *br)
 int br_nf_core_init(void);
 void br_nf_core_fini(void);
 void br_netfilter_rtable_init(struct net_bridge *);
+int br_nf_do_prerouting(struct sk_buff *skb, struct net_bridge_port *p);
+int br_nf_do_forward(struct sk_buff *skb, struct net_device *indev);
 #else
 static inline int br_nf_core_init(void) { return 0; }
 static inline void br_nf_core_fini(void) {}
 #define br_netfilter_rtable_init(x)
+#define br_nf_do_prerouting(skb, p) \
+	NF_HOOK(NFPROTO_BRIDGE, NF_BR_PRE_ROUTING, skb, skb->dev, NULL, \
+		br_handle_frame_finish)
+#define br_nf_do_forward(skb, indev) \
+	NF_HOOK(NFPROTO_BRIDGE, NF_BR_FORWARD, skb, indev, skb->dev, \
+		br_forward_finish)
 #endif
 
 /* br_stp.c */
diff --git a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
index 4c97fc5..707b994 100644
--- a/net/bridge/br_sysfs_br.c
+++ b/net/bridge/br_sysfs_br.c
@@ -630,6 +630,28 @@ static ssize_t multicast_startup_query_interval_store(
 static DEVICE_ATTR_RW(multicast_startup_query_interval);
 #endif
 #if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
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
 static ssize_t nf_call_iptables_show(
 	struct device *d, struct device_attribute *attr, char *buf)
 {
@@ -780,6 +802,7 @@ static struct attribute *bridge_attrs[] = {
 	&dev_attr_multicast_startup_query_interval.attr,
 #endif
 #if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
+	&dev_attr_call_nf.attr,
 	&dev_attr_nf_call_iptables.attr,
 	&dev_attr_nf_call_ip6tables.attr,
 	&dev_attr_nf_call_arptables.attr,
-- 
1.7.9.5
