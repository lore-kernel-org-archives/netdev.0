From: Hadar Hen Zion <hadarh@mellanox.com>
Subject: [PATCH net-next 3/4] net_sched: flower: Add vlan support
Date: Wed, 10 Aug 2016 16:32:22 +0300
Message-ID: <1470835943-9042-4-git-send-email-hadarh@mellanox.com>
References: <1470835943-9042-1-git-send-email-hadarh@mellanox.com>
Cc: netdev@vger.kernel.org, Jiri Pirko <jiri@mellanox.com>,
	Tom Herbert <tom@herbertland.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Hadar Hen Zion <hadarh@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:45348 "EHLO
	mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933537AbcHJT17 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Aug 2016 15:27:59 -0400
In-Reply-To: <1470835943-9042-1-git-send-email-hadarh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enhance flower to support 802.1Q vlan protocol classification.
Currently, the supported fields are vlan_id and vlan_priority.

Example:

	# add a flower filter with vlan id and priority classification
	tc filter add dev ens4f0 protocol 802.1Q parent ffff: \
		flower \
		indev ens4f0 \
		vlan_ethtype ipv4 \
		vlan_id 100 \
		vlan_prio 3 \
	action vlan pop

Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
---
 include/uapi/linux/pkt_cls.h |  3 ++
 net/sched/cls_flower.c       | 69 ++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 69 insertions(+), 3 deletions(-)

diff --git a/include/uapi/linux/pkt_cls.h b/include/uapi/linux/pkt_cls.h
index d1c1cca..51b5b24 100644
--- a/include/uapi/linux/pkt_cls.h
+++ b/include/uapi/linux/pkt_cls.h
@@ -428,6 +428,9 @@ enum {
 	TCA_FLOWER_KEY_UDP_DST,		/* be16 */
 
 	TCA_FLOWER_FLAGS,
+	TCA_FLOWER_KEY_VLAN_ID,
+	TCA_FLOWER_KEY_VLAN_PRIO,
+	TCA_FLOWER_KEY_VLAN_ETH_TYPE,
 	__TCA_FLOWER_MAX,
 };
 
diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index 5060801..4e249be 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -28,6 +28,7 @@ struct fl_flow_key {
 	struct flow_dissector_key_control control;
 	struct flow_dissector_key_basic basic;
 	struct flow_dissector_key_eth_addrs eth;
+	struct flow_dissector_key_vlan vlan;
 	struct flow_dissector_key_addrs ipaddrs;
 	union {
 		struct flow_dissector_key_ipv4_addrs ipv4;
@@ -293,6 +294,10 @@ static const struct nla_policy fl_policy[TCA_FLOWER_MAX + 1] = {
 	[TCA_FLOWER_KEY_TCP_DST]	= { .type = NLA_U16 },
 	[TCA_FLOWER_KEY_UDP_SRC]	= { .type = NLA_U16 },
 	[TCA_FLOWER_KEY_UDP_DST]	= { .type = NLA_U16 },
+	[TCA_FLOWER_KEY_VLAN_ID]	= { .type = NLA_U16 },
+	[TCA_FLOWER_KEY_VLAN_PRIO]	= { .type = NLA_U8 },
+	[TCA_FLOWER_KEY_VLAN_ETH_TYPE]	= { .type = NLA_U16 },
+
 };
 
 static void fl_set_key_val(struct nlattr **tb,
@@ -308,9 +313,28 @@ static void fl_set_key_val(struct nlattr **tb,
 		memcpy(mask, nla_data(tb[mask_type]), len);
 }
 
+static void fl_set_key_vlan(struct nlattr **tb,
+			    struct flow_dissector_key_vlan *key_val,
+			    struct flow_dissector_key_vlan *key_mask)
+{
+#define VLAN_PRIORITY_MASK	0x7
+
+	if (tb[TCA_FLOWER_KEY_VLAN_ID]) {
+		key_val->vlan_id =
+			nla_get_u16(tb[TCA_FLOWER_KEY_VLAN_ID]) & VLAN_VID_MASK;
+		key_mask->vlan_id = VLAN_VID_MASK;
+	}
+	if (tb[TCA_FLOWER_KEY_VLAN_PRIO]) {
+		key_val->vlan_priority =
+			nla_get_u8(tb[TCA_FLOWER_KEY_VLAN_PRIO]) & VLAN_PRIORITY_MASK;
+		key_mask->vlan_priority = VLAN_PRIORITY_MASK;
+	}
+}
+
 static int fl_set_key(struct net *net, struct nlattr **tb,
 		      struct fl_flow_key *key, struct fl_flow_key *mask)
 {
+	__be16 ethertype;
 #ifdef CONFIG_NET_CLS_IND
 	if (tb[TCA_FLOWER_INDEV]) {
 		int err = tcf_change_indev(net, tb[TCA_FLOWER_INDEV]);
@@ -328,9 +352,19 @@ static int fl_set_key(struct net *net, struct nlattr **tb,
 		       mask->eth.src, TCA_FLOWER_KEY_ETH_SRC_MASK,
 		       sizeof(key->eth.src));
 
-	fl_set_key_val(tb, &key->basic.n_proto, TCA_FLOWER_KEY_ETH_TYPE,
-		       &mask->basic.n_proto, TCA_FLOWER_UNSPEC,
-		       sizeof(key->basic.n_proto));
+	if (tb[TCA_FLOWER_KEY_ETH_TYPE])
+		ethertype = nla_get_be16(tb[TCA_FLOWER_KEY_ETH_TYPE]);
+
+	if (ethertype == htons(ETH_P_8021Q)) {
+		fl_set_key_vlan(tb, &key->vlan, &mask->vlan);
+		fl_set_key_val(tb, &key->basic.n_proto,
+			       TCA_FLOWER_KEY_VLAN_ETH_TYPE,
+			       &mask->basic.n_proto, TCA_FLOWER_UNSPEC,
+			       sizeof(key->basic.n_proto));
+	} else {
+		key->basic.n_proto = ethertype;
+		mask->basic.n_proto = cpu_to_be16(~0);
+	}
 
 	if (key->basic.n_proto == htons(ETH_P_IP) ||
 	    key->basic.n_proto == htons(ETH_P_IPV6)) {
@@ -440,6 +474,8 @@ static void fl_init_dissector(struct cls_fl_head *head,
 			       FLOW_DISSECTOR_KEY_IPV6_ADDRS, ipv6);
 	FL_KEY_SET_IF_IN_RANGE(mask, keys, cnt,
 			       FLOW_DISSECTOR_KEY_PORTS, tp);
+	FL_KEY_SET_IF_IN_RANGE(mask, keys, cnt,
+			       FLOW_DISSECTOR_KEY_VLAN, vlan);
 
 	skb_flow_dissector_init(&head->dissector, keys, cnt);
 }
@@ -668,6 +704,29 @@ static int fl_dump_key_val(struct sk_buff *skb,
 	return 0;
 }
 
+static int fl_dump_key_vlan(struct sk_buff *skb,
+			    struct flow_dissector_key_vlan *vlan_key,
+			    struct flow_dissector_key_vlan *vlan_mask)
+{
+	int err;
+
+	if (!memchr_inv(vlan_mask, 0, sizeof(*vlan_mask)))
+		return 0;
+	if (vlan_mask->vlan_id) {
+		err = nla_put_u16(skb, TCA_FLOWER_KEY_VLAN_ID,
+				  vlan_key->vlan_id);
+		if (err)
+			return err;
+	}
+	if (vlan_mask->vlan_priority) {
+		err = nla_put_u8(skb, TCA_FLOWER_KEY_VLAN_PRIO,
+				 vlan_key->vlan_priority);
+		if (err)
+			return err;
+	}
+	return 0;
+}
+
 static int fl_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 		   struct sk_buff *skb, struct tcmsg *t)
 {
@@ -712,6 +771,10 @@ static int fl_dump(struct net *net, struct tcf_proto *tp, unsigned long fh,
 			    &mask->basic.n_proto, TCA_FLOWER_UNSPEC,
 			    sizeof(key->basic.n_proto)))
 		goto nla_put_failure;
+
+	if (fl_dump_key_vlan(skb, &key->vlan, &mask->vlan))
+		goto nla_put_failure;
+
 	if ((key->basic.n_proto == htons(ETH_P_IP) ||
 	     key->basic.n_proto == htons(ETH_P_IPV6)) &&
 	    fl_dump_key_val(skb, &key->basic.ip_proto, TCA_FLOWER_KEY_IP_PROTO,
-- 
1.8.3.1
