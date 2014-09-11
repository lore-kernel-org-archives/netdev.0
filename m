From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next 1/4] datapath: refactor ovs flow extract API.
Date: Thu, 11 Sep 2014 15:01:42 -0700
Message-ID: <1410472902-1446-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na6sys009bog024.obsmtp.com ([74.125.150.88]:43004 "HELO
	na6sys009bog024.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754316AbaIKWua (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2014 18:50:30 -0400
Received: by mail-pd0-f177.google.com with SMTP id y10so6462561pdj.22
        for <netdev@vger.kernel.org>; Thu, 11 Sep 2014 15:50:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

OVS flow extract is called on packet receive or packet
execute code path.  Following patch defines separate API
for extracting flow-key in packet execute code path.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
Acked-by: Andy Zhou <azhou@nicira.com>
---
 net/openvswitch/datapath.c     | 26 ++++++++++++++---------
 net/openvswitch/datapath.h     |  5 ++++-
 net/openvswitch/flow.c         | 48 +++++++++++++++++++++++++++++++-----------
 net/openvswitch/flow.h         |  6 +++++-
 net/openvswitch/flow_netlink.c | 22 ++++++-------------
 net/openvswitch/flow_netlink.h |  4 ++--
 net/openvswitch/vport.c        |  3 ++-
 7 files changed, 72 insertions(+), 42 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 91d66b7..7c3939a 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -237,8 +237,9 @@ void ovs_dp_detach_port(struct vport *p)
 }
 
 /* Must be called with rcu_read_lock. */
-void ovs_dp_process_received_packet(struct vport *p, struct sk_buff *skb)
+void ovs_dp_process_received_packet(struct sk_buff *skb)
 {
+	const struct vport *p = OVS_CB(skb)->input_vport;
 	struct datapath *dp = p->dp;
 	struct sw_flow *flow;
 	struct dp_stats_percpu *stats;
@@ -250,7 +251,7 @@ void ovs_dp_process_received_packet(struct vport *p, struct sk_buff *skb)
 	stats = this_cpu_ptr(dp->stats_percpu);
 
 	/* Extract flow from 'skb' into 'key'. */
-	error = ovs_flow_extract(skb, p->port_no, &key);
+	error = ovs_flow_key_extract(skb, &key);
 	if (unlikely(error)) {
 		kfree_skb(skb);
 		return;
@@ -273,9 +274,7 @@ void ovs_dp_process_received_packet(struct vport *p, struct sk_buff *skb)
 		stats_counter = &stats->n_missed;
 		goto out;
 	}
-
 	OVS_CB(skb)->flow = flow;
-	OVS_CB(skb)->pkt_key = &key;
 
 	ovs_flow_stats_update(OVS_CB(skb)->flow, key.tp.flags, skb);
 	ovs_execute_actions(dp, skb);
@@ -340,7 +339,7 @@ static int queue_gso_packets(struct datapath *dp, struct sk_buff *skb,
 			break;
 
 		if (skb == segs && gso_type & SKB_GSO_UDP) {
-			/* The initial flow key extracted by ovs_flow_extract()
+			/* The initial flow key extracted by ovs-key-extract()
 			 * in this case is for a first fragment, so we need to
 			 * properly mark later fragments.
 			 */
@@ -515,6 +514,7 @@ static int ovs_packet_cmd_execute(struct sk_buff *skb, struct genl_info *info)
 	struct sw_flow *flow;
 	struct datapath *dp;
 	struct ethhdr *eth;
+	struct vport *input_vport;
 	int len;
 	int err;
 
@@ -549,13 +549,11 @@ static int ovs_packet_cmd_execute(struct sk_buff *skb, struct genl_info *info)
 	if (IS_ERR(flow))
 		goto err_kfree_skb;
 
-	err = ovs_flow_extract(packet, -1, &flow->key);
+	err = ovs_flow_key_extract_userspace(a[OVS_PACKET_ATTR_KEY], packet,
+					     &flow->key);
 	if (err)
 		goto err_flow_free;
 
-	err = ovs_nla_get_flow_metadata(flow, a[OVS_PACKET_ATTR_KEY]);
-	if (err)
-		goto err_flow_free;
 	acts = ovs_nla_alloc_flow_actions(nla_len(a[OVS_PACKET_ATTR_ACTIONS]));
 	err = PTR_ERR(acts);
 	if (IS_ERR(acts))
@@ -568,7 +566,6 @@ static int ovs_packet_cmd_execute(struct sk_buff *skb, struct genl_info *info)
 		goto err_flow_free;
 
 	OVS_CB(packet)->flow = flow;
-	OVS_CB(packet)->pkt_key = &flow->key;
 	packet->priority = flow->key.phy.priority;
 	packet->mark = flow->key.phy.skb_mark;
 
@@ -578,6 +575,15 @@ static int ovs_packet_cmd_execute(struct sk_buff *skb, struct genl_info *info)
 	if (!dp)
 		goto err_unlock;
 
+	input_vport = ovs_vport_rcu(dp, flow->key.phy.in_port);
+	if (!input_vport)
+		input_vport = ovs_vport_rcu(dp, OVSP_LOCAL);
+
+	if (!input_vport)
+		goto err_unlock;
+
+	OVS_CB(packet)->input_vport = input_vport;
+
 	local_bh_disable();
 	err = ovs_execute_actions(dp, packet);
 	local_bh_enable();
diff --git a/net/openvswitch/datapath.h b/net/openvswitch/datapath.h
index 701b573..9d5b7d1 100644
--- a/net/openvswitch/datapath.h
+++ b/net/openvswitch/datapath.h
@@ -98,11 +98,14 @@ struct datapath {
  * @pkt_key: The flow information extracted from the packet.  Must be nonnull.
  * @tun_key: Key for the tunnel that encapsulated this packet. NULL if the
  * packet is not being tunneled.
+ * @input_vport: The original vport packet came in on. This value is cached
+ * when a packet is received by OVS.
  */
 struct ovs_skb_cb {
 	struct sw_flow		*flow;
 	struct sw_flow_key	*pkt_key;
 	struct ovs_key_ipv4_tunnel  *tun_key;
+	struct vport		*input_vport;
 };
 #define OVS_CB(skb) ((struct ovs_skb_cb *)(skb)->cb)
 
@@ -183,7 +186,7 @@ static inline struct vport *ovs_vport_ovsl(const struct datapath *dp, int port_n
 extern struct notifier_block ovs_dp_device_notifier;
 extern struct genl_family dp_vport_genl_family;
 
-void ovs_dp_process_received_packet(struct vport *, struct sk_buff *);
+void ovs_dp_process_received_packet(struct sk_buff *);
 void ovs_dp_detach_port(struct vport *);
 int ovs_dp_upcall(struct datapath *, struct sk_buff *,
 		  const struct dp_upcall_info *);
diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index 7064da9..8c82376 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -16,8 +16,6 @@
  * 02110-1301, USA
  */
 
-#include "flow.h"
-#include "datapath.h"
 #include <linux/uaccess.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
@@ -46,6 +44,10 @@
 #include <net/ipv6.h>
 #include <net/ndisc.h>
 
+#include "datapath.h"
+#include "flow.h"
+#include "flow_netlink.h"
+
 u64 ovs_flow_used_time(unsigned long flow_jiffies)
 {
 	struct timespec cur_ts;
@@ -420,7 +422,7 @@ invalid:
 }
 
 /**
- * ovs_flow_extract - extracts a flow key from an Ethernet frame.
+ * key_extract - extracts a flow key from an Ethernet frame.
  * @skb: sk_buff that contains the frame, with skb->data pointing to the
  * Ethernet header
  * @in_port: port number on which @skb was received.
@@ -442,19 +444,11 @@ invalid:
  *      of a correct length, otherwise the same as skb->network_header.
  *      For other key->eth.type values it is left untouched.
  */
-int ovs_flow_extract(struct sk_buff *skb, u16 in_port, struct sw_flow_key *key)
+static int key_extract(struct sk_buff *skb, struct sw_flow_key *key)
 {
 	int error;
 	struct ethhdr *eth;
 
-	memset(key, 0, sizeof(*key));
-
-	key->phy.priority = skb->priority;
-	if (OVS_CB(skb)->tun_key)
-		memcpy(&key->tun_key, OVS_CB(skb)->tun_key, sizeof(key->tun_key));
-	key->phy.in_port = in_port;
-	key->phy.skb_mark = skb->mark;
-
 	skb_reset_mac_header(skb);
 
 	/* Link layer.  We are guaranteed to have at least the 14 byte Ethernet
@@ -611,5 +605,35 @@ int ovs_flow_extract(struct sk_buff *skb, u16 in_port, struct sw_flow_key *key)
 		}
 	}
 
+	OVS_CB(skb)->pkt_key = key;
 	return 0;
 }
+
+int ovs_flow_key_extract(struct sk_buff *skb, struct sw_flow_key *key)
+{
+	/* Extract metadata from packet. */
+	memset(key, 0, sizeof(*key));
+	if (OVS_CB(skb)->tun_key)
+		memcpy(&key->tun_key, OVS_CB(skb)->tun_key, sizeof(key->tun_key));
+
+	key->phy.priority = skb->priority;
+	key->phy.in_port = OVS_CB(skb)->input_vport->port_no;
+	key->phy.skb_mark = skb->mark;
+
+	return key_extract(skb, key);
+}
+
+int ovs_flow_key_extract_userspace(const struct nlattr *attr,
+				   struct sk_buff *skb,
+				   struct sw_flow_key *key)
+{
+	int err;
+
+	memset(key, 0, sizeof(*key));
+	/* Extract metadata from netlink attributes. */
+	err = ovs_nla_get_flow_metadata(attr, key);
+	if (err)
+		return err;
+
+	return key_extract(skb, key);
+}
diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
index 5e5aaed..251789b 100644
--- a/net/openvswitch/flow.h
+++ b/net/openvswitch/flow.h
@@ -187,6 +187,10 @@ void ovs_flow_stats_get(const struct sw_flow *, struct ovs_flow_stats *,
 void ovs_flow_stats_clear(struct sw_flow *);
 u64 ovs_flow_used_time(unsigned long flow_jiffies);
 
-int ovs_flow_extract(struct sk_buff *, u16 in_port, struct sw_flow_key *);
+int ovs_flow_key_extract(struct sk_buff *skb, struct sw_flow_key *key);
+/* Extract key from packet coming from userspace. */
+int ovs_flow_key_extract_userspace(const struct nlattr *attr,
+				   struct sk_buff *skb,
+				   struct sw_flow_key *key);
 
 #endif /* flow.h */
diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index d757848..630b320 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -836,7 +836,7 @@ int ovs_nla_get_match(struct sw_flow_match *match,
 
 /**
  * ovs_nla_get_flow_metadata - parses Netlink attributes into a flow key.
- * @flow: Receives extracted in_port, priority, tun_key and skb_mark.
+ * @key: Receives extracted in_port, priority, tun_key and skb_mark.
  * @attr: Netlink attribute holding nested %OVS_KEY_ATTR_* Netlink attribute
  * sequence.
  *
@@ -846,32 +846,24 @@ int ovs_nla_get_match(struct sw_flow_match *match,
  * extracted from the packet itself.
  */
 
-int ovs_nla_get_flow_metadata(struct sw_flow *flow,
-			      const struct nlattr *attr)
+int ovs_nla_get_flow_metadata(const struct nlattr *attr,
+			      struct sw_flow_key *key)
 {
-	struct ovs_key_ipv4_tunnel *tun_key = &flow->key.tun_key;
 	const struct nlattr *a[OVS_KEY_ATTR_MAX + 1];
+	struct sw_flow_match match;
 	u64 attrs = 0;
 	int err;
-	struct sw_flow_match match;
-
-	flow->key.phy.in_port = DP_MAX_PORTS;
-	flow->key.phy.priority = 0;
-	flow->key.phy.skb_mark = 0;
-	memset(tun_key, 0, sizeof(flow->key.tun_key));
 
 	err = parse_flow_nlattrs(attr, a, &attrs);
 	if (err)
 		return -EINVAL;
 
 	memset(&match, 0, sizeof(match));
-	match.key = &flow->key;
+	match.key = key;
 
-	err = metadata_from_nlattrs(&match, &attrs, a, false);
-	if (err)
-		return err;
+	key->phy.in_port = DP_MAX_PORTS;
 
-	return 0;
+	return metadata_from_nlattrs(&match, &attrs, a, false);
 }
 
 int ovs_nla_put_flow(const struct sw_flow_key *swkey,
diff --git a/net/openvswitch/flow_netlink.h b/net/openvswitch/flow_netlink.h
index 4401510..206e45a 100644
--- a/net/openvswitch/flow_netlink.h
+++ b/net/openvswitch/flow_netlink.h
@@ -42,8 +42,8 @@ void ovs_match_init(struct sw_flow_match *match,
 
 int ovs_nla_put_flow(const struct sw_flow_key *,
 		     const struct sw_flow_key *, struct sk_buff *);
-int ovs_nla_get_flow_metadata(struct sw_flow *flow,
-			      const struct nlattr *attr);
+int ovs_nla_get_flow_metadata(const struct nlattr *, struct sw_flow_key *);
+
 int ovs_nla_get_match(struct sw_flow_match *match,
 		      const struct nlattr *,
 		      const struct nlattr *);
diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index f7e63f9..d21251f 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -443,7 +443,8 @@ void ovs_vport_receive(struct vport *vport, struct sk_buff *skb,
 	u64_stats_update_end(&stats->syncp);
 
 	OVS_CB(skb)->tun_key = tun_key;
-	ovs_dp_process_received_packet(vport, skb);
+	OVS_CB(skb)->input_vport = vport;
+	ovs_dp_process_received_packet(skb);
 }
 
 /**
-- 
1.9.3
