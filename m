From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH net-next 6/7] openvswitch: add skb mark matching and set action
Date: Thu, 29 Nov 2012 10:35:48 -0800
Message-ID: <1354214149-33651-7-git-send-email-jesse@nicira.com>
References: <1354214149-33651-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	Ansis Atteka <aatteka@nicira.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog128.obsmtp.com ([74.125.149.141]:36746 "HELO
	na3sys009aog128.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754550Ab2K2SgF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2012 13:36:05 -0500
Received: by mail-pb0-f70.google.com with SMTP id ro2so16813605pbb.1
        for <netdev@vger.kernel.org>; Thu, 29 Nov 2012 10:36:04 -0800 (PST)
In-Reply-To: <1354214149-33651-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ansis Atteka <aatteka@nicira.com>

This patch adds support for skb mark matching and set action.

Signed-off-by: Ansis Atteka <aatteka@nicira.com>
Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 include/linux/openvswitch.h |    1 +
 net/openvswitch/actions.c   |    4 ++++
 net/openvswitch/datapath.c  |    3 +++
 net/openvswitch/flow.c      |   19 ++++++++++++++++++-
 net/openvswitch/flow.h      |    8 +++++---
 5 files changed, 31 insertions(+), 4 deletions(-)

diff --git a/include/linux/openvswitch.h b/include/linux/openvswitch.h
index eb1efa5..d42e174 100644
--- a/include/linux/openvswitch.h
+++ b/include/linux/openvswitch.h
@@ -243,6 +243,7 @@ enum ovs_key_attr {
 	OVS_KEY_ATTR_ICMPV6,    /* struct ovs_key_icmpv6 */
 	OVS_KEY_ATTR_ARP,       /* struct ovs_key_arp */
 	OVS_KEY_ATTR_ND,        /* struct ovs_key_nd */
+	OVS_KEY_ATTR_SKB_MARK,  /* u32 skb mark */
 	__OVS_KEY_ATTR_MAX
 };
 
diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index a58ed27..ac2defe 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -428,6 +428,10 @@ static int execute_set_action(struct sk_buff *skb,
 		skb->priority = nla_get_u32(nested_attr);
 		break;
 
+	case OVS_KEY_ATTR_SKB_MARK:
+		skb->mark = nla_get_u32(nested_attr);
+		break;
+
 	case OVS_KEY_ATTR_ETHERNET:
 		err = set_eth_addr(skb, nla_data(nested_attr));
 		break;
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 7b1d6d2..f996db3 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -482,6 +482,7 @@ static int validate_set(const struct nlattr *a,
 	const struct ovs_key_ipv6 *ipv6_key;
 
 	case OVS_KEY_ATTR_PRIORITY:
+	case OVS_KEY_ATTR_SKB_MARK:
 	case OVS_KEY_ATTR_ETHERNET:
 		break;
 
@@ -695,6 +696,7 @@ static int ovs_packet_cmd_execute(struct sk_buff *skb, struct genl_info *info)
 		goto err_flow_free;
 
 	err = ovs_flow_metadata_from_nlattrs(&flow->key.phy.priority,
+					     &flow->key.phy.skb_mark,
 					     &flow->key.phy.in_port,
 					     a[OVS_PACKET_ATTR_KEY]);
 	if (err)
@@ -714,6 +716,7 @@ static int ovs_packet_cmd_execute(struct sk_buff *skb, struct genl_info *info)
 
 	OVS_CB(packet)->flow = flow;
 	packet->priority = flow->key.phy.priority;
+	packet->mark = flow->key.phy.skb_mark;
 
 	rcu_read_lock();
 	dp = get_dp(sock_net(skb->sk), ovs_header->dp_ifindex);
diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index e6ce902..c3294ce 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -604,6 +604,7 @@ int ovs_flow_extract(struct sk_buff *skb, u16 in_port, struct sw_flow_key *key,
 
 	key->phy.priority = skb->priority;
 	key->phy.in_port = in_port;
+	key->phy.skb_mark = skb->mark;
 
 	skb_reset_mac_header(skb);
 
@@ -803,6 +804,7 @@ const int ovs_key_lens[OVS_KEY_ATTR_MAX + 1] = {
 	[OVS_KEY_ATTR_ENCAP] = -1,
 	[OVS_KEY_ATTR_PRIORITY] = sizeof(u32),
 	[OVS_KEY_ATTR_IN_PORT] = sizeof(u32),
+	[OVS_KEY_ATTR_SKB_MARK] = sizeof(u32),
 	[OVS_KEY_ATTR_ETHERNET] = sizeof(struct ovs_key_ethernet),
 	[OVS_KEY_ATTR_VLAN] = sizeof(__be16),
 	[OVS_KEY_ATTR_ETHERTYPE] = sizeof(__be16),
@@ -988,6 +990,10 @@ int ovs_flow_from_nlattrs(struct sw_flow_key *swkey, int *key_lenp,
 	} else {
 		swkey->phy.in_port = DP_MAX_PORTS;
 	}
+	if (attrs & (1 << OVS_KEY_ATTR_SKB_MARK)) {
+		swkey->phy.skb_mark = nla_get_u32(a[OVS_KEY_ATTR_SKB_MARK]);
+		attrs &= ~(1 << OVS_KEY_ATTR_SKB_MARK);
+	}
 
 	/* Data attributes. */
 	if (!(attrs & (1 << OVS_KEY_ATTR_ETHERNET)))
@@ -1115,6 +1121,8 @@ int ovs_flow_from_nlattrs(struct sw_flow_key *swkey, int *key_lenp,
 
 /**
  * ovs_flow_metadata_from_nlattrs - parses Netlink attributes into a flow key.
+ * @priority: receives the skb priority
+ * @mark: receives the skb mark
  * @in_port: receives the extracted input port.
  * @key: Netlink attribute holding nested %OVS_KEY_ATTR_* Netlink attribute
  * sequence.
@@ -1124,7 +1132,7 @@ int ovs_flow_from_nlattrs(struct sw_flow_key *swkey, int *key_lenp,
  * get the metadata, that is, the parts of the flow key that cannot be
  * extracted from the packet itself.
  */
-int ovs_flow_metadata_from_nlattrs(u32 *priority, u16 *in_port,
+int ovs_flow_metadata_from_nlattrs(u32 *priority, u32 *mark, u16 *in_port,
 			       const struct nlattr *attr)
 {
 	const struct nlattr *nla;
@@ -1132,6 +1140,7 @@ int ovs_flow_metadata_from_nlattrs(u32 *priority, u16 *in_port,
 
 	*in_port = DP_MAX_PORTS;
 	*priority = 0;
+	*mark = 0;
 
 	nla_for_each_nested(nla, attr, rem) {
 		int type = nla_type(nla);
@@ -1150,6 +1159,10 @@ int ovs_flow_metadata_from_nlattrs(u32 *priority, u16 *in_port,
 					return -EINVAL;
 				*in_port = nla_get_u32(nla);
 				break;
+
+			case OVS_KEY_ATTR_SKB_MARK:
+				*mark = nla_get_u32(nla);
+				break;
 			}
 		}
 	}
@@ -1171,6 +1184,10 @@ int ovs_flow_to_nlattrs(const struct sw_flow_key *swkey, struct sk_buff *skb)
 	    nla_put_u32(skb, OVS_KEY_ATTR_IN_PORT, swkey->phy.in_port))
 		goto nla_put_failure;
 
+	if (swkey->phy.skb_mark &&
+	    nla_put_u32(skb, OVS_KEY_ATTR_SKB_MARK, swkey->phy.skb_mark))
+		goto nla_put_failure;
+
 	nla = nla_reserve(skb, OVS_KEY_ATTR_ETHERNET, sizeof(*eth_key));
 	if (!nla)
 		goto nla_put_failure;
diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
index 14a324e..a7bb60f 100644
--- a/net/openvswitch/flow.h
+++ b/net/openvswitch/flow.h
@@ -43,6 +43,7 @@ struct sw_flow_actions {
 struct sw_flow_key {
 	struct {
 		u32	priority;	/* Packet QoS priority. */
+		u32	skb_mark;	/* SKB mark. */
 		u16	in_port;	/* Input switch port (or DP_MAX_PORTS). */
 	} phy;
 	struct {
@@ -144,6 +145,7 @@ u64 ovs_flow_used_time(unsigned long flow_jiffies);
  *                         ------  ---  ------  -----
  *  OVS_KEY_ATTR_PRIORITY      4    --     4      8
  *  OVS_KEY_ATTR_IN_PORT       4    --     4      8
+ *  OVS_KEY_ATTR_SKB_MARK      4    --     4      8
  *  OVS_KEY_ATTR_ETHERNET     12    --     4     16
  *  OVS_KEY_ATTR_ETHERTYPE     2     2     4      8  (outer VLAN ethertype)
  *  OVS_KEY_ATTR_8021Q         4    --     4      8
@@ -153,14 +155,14 @@ u64 ovs_flow_used_time(unsigned long flow_jiffies);
  *  OVS_KEY_ATTR_ICMPV6        2     2     4      8
  *  OVS_KEY_ATTR_ND           28    --     4     32
  *  -------------------------------------------------
- *  total                                       144
+ *  total                                       152
  */
-#define FLOW_BUFSIZE 144
+#define FLOW_BUFSIZE 152
 
 int ovs_flow_to_nlattrs(const struct sw_flow_key *, struct sk_buff *);
 int ovs_flow_from_nlattrs(struct sw_flow_key *swkey, int *key_lenp,
 		      const struct nlattr *);
-int ovs_flow_metadata_from_nlattrs(u32 *priority, u16 *in_port,
+int ovs_flow_metadata_from_nlattrs(u32 *priority, u32 *mark, u16 *in_port,
 			       const struct nlattr *);
 
 #define MAX_ACTIONS_BUFSIZE    (16 * 1024)
-- 
1.7.9.5
