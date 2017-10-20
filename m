From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH net-next] nfp: use struct fields for 8 bit-wide access
Date: Fri, 20 Oct 2017 19:49:52 +0200
Message-ID: <20171020174952.23572-1-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com,
        Pieter Jansen van Vuuren
        <pieter.jansenvanvuuren@netronome.com>,
        Simon Horman <simon.horman@netronome.com>
To: David Miller <davem@davemloft.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:49578 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753796AbdJTRuR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2017 13:50:17 -0400
Received: by mail-wm0-f65.google.com with SMTP id b189so23233282wmd.4
        for <netdev@vger.kernel.org>; Fri, 20 Oct 2017 10:50:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pieter Jansen van Vuuren <pieter.jansenvanvuuren@netronome.com>

Use direct access struct fields rather than PREP_FIELD()
macros to manipulate the jump ID and length, both of which
are exactly 8-bits wide. This simplifies the code somewhat.

Signed-off-by: Simon Horman <simon.horman@netronome.com>
Signed-off-by: Pieter Jansen van Vuuren <pieter.jansenvanvuuren@netronome.com>
Acked-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/flower/action.c | 87 +++++++---------------
 drivers/net/ethernet/netronome/nfp/flower/cmsg.h   | 26 ++++---
 2 files changed, 39 insertions(+), 74 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/flower/action.c b/drivers/net/ethernet/netronome/nfp/flower/action.c
index 1194c47ef827..0a5fc9f8545f 100644
--- a/drivers/net/ethernet/netronome/nfp/flower/action.c
+++ b/drivers/net/ethernet/netronome/nfp/flower/action.c
@@ -47,13 +47,9 @@
 static void nfp_fl_pop_vlan(struct nfp_fl_pop_vlan *pop_vlan)
 {
 	size_t act_size = sizeof(struct nfp_fl_pop_vlan);
-	u16 tmp_pop_vlan_op;
 
-	tmp_pop_vlan_op =
-		FIELD_PREP(NFP_FL_ACT_LEN_LW, act_size >> NFP_FL_LW_SIZ) |
-		FIELD_PREP(NFP_FL_ACT_JMP_ID, NFP_FL_ACTION_OPCODE_POP_VLAN);
-
-	pop_vlan->a_op = cpu_to_be16(tmp_pop_vlan_op);
+	pop_vlan->head.jump_id = NFP_FL_ACTION_OPCODE_POP_VLAN;
+	pop_vlan->head.len_lw = act_size >> NFP_FL_LW_SIZ;
 	pop_vlan->reserved = 0;
 }
 
@@ -64,14 +60,9 @@ nfp_fl_push_vlan(struct nfp_fl_push_vlan *push_vlan,
 	size_t act_size = sizeof(struct nfp_fl_push_vlan);
 	struct tcf_vlan *vlan = to_vlan(action);
 	u16 tmp_push_vlan_tci;
-	u16 tmp_push_vlan_op;
-
-	tmp_push_vlan_op =
-		FIELD_PREP(NFP_FL_ACT_LEN_LW, act_size >> NFP_FL_LW_SIZ) |
-		FIELD_PREP(NFP_FL_ACT_JMP_ID, NFP_FL_ACTION_OPCODE_PUSH_VLAN);
 
-	push_vlan->a_op = cpu_to_be16(tmp_push_vlan_op);
-	/* Set action push vlan parameters. */
+	push_vlan->head.jump_id = NFP_FL_ACTION_OPCODE_PUSH_VLAN;
+	push_vlan->head.len_lw = act_size >> NFP_FL_LW_SIZ;
 	push_vlan->reserved = 0;
 	push_vlan->vlan_tpid = tcf_vlan_push_proto(action);
 
@@ -101,16 +92,12 @@ nfp_fl_output(struct nfp_fl_output *output, const struct tc_action *action,
 	      int *tun_out_cnt)
 {
 	size_t act_size = sizeof(struct nfp_fl_output);
-	u16 tmp_output_op, tmp_flags;
 	struct net_device *out_dev;
+	u16 tmp_flags;
 	int ifindex;
 
-	/* Set action opcode to output action. */
-	tmp_output_op =
-		FIELD_PREP(NFP_FL_ACT_LEN_LW, act_size >> NFP_FL_LW_SIZ) |
-		FIELD_PREP(NFP_FL_ACT_JMP_ID, NFP_FL_ACTION_OPCODE_OUTPUT);
-
-	output->a_op = cpu_to_be16(tmp_output_op);
+	output->head.jump_id = NFP_FL_ACTION_OPCODE_OUTPUT;
+	output->head.len_lw = act_size >> NFP_FL_LW_SIZ;
 
 	ifindex = tcf_mirred_ifindex(action);
 	out_dev = __dev_get_by_index(dev_net(in_dev), ifindex);
@@ -161,7 +148,6 @@ static struct nfp_fl_pre_tunnel *nfp_fl_pre_tunnel(char *act_data, int act_len)
 {
 	size_t act_size = sizeof(struct nfp_fl_pre_tunnel);
 	struct nfp_fl_pre_tunnel *pre_tun_act;
-	u16 tmp_pre_tun_op;
 
 	/* Pre_tunnel action must be first on action list.
 	 * If other actions already exist they need pushed forward.
@@ -173,11 +159,8 @@ static struct nfp_fl_pre_tunnel *nfp_fl_pre_tunnel(char *act_data, int act_len)
 
 	memset(pre_tun_act, 0, act_size);
 
-	tmp_pre_tun_op =
-		FIELD_PREP(NFP_FL_ACT_LEN_LW, act_size >> NFP_FL_LW_SIZ) |
-		FIELD_PREP(NFP_FL_ACT_JMP_ID, NFP_FL_ACTION_OPCODE_PRE_TUNNEL);
-
-	pre_tun_act->a_op = cpu_to_be16(tmp_pre_tun_op);
+	pre_tun_act->head.jump_id = NFP_FL_ACTION_OPCODE_PRE_TUNNEL;
+	pre_tun_act->head.len_lw = act_size >> NFP_FL_LW_SIZ;
 
 	return pre_tun_act;
 }
@@ -190,7 +173,6 @@ nfp_fl_set_vxlan(struct nfp_fl_set_vxlan *set_vxlan,
 	struct ip_tunnel_info *vxlan = tcf_tunnel_info(action);
 	size_t act_size = sizeof(struct nfp_fl_set_vxlan);
 	u32 tmp_set_vxlan_type_index = 0;
-	u16 tmp_set_vxlan_op;
 	/* Currently support one pre-tunnel so index is always 0. */
 	int pretun_idx = 0;
 
@@ -199,12 +181,8 @@ nfp_fl_set_vxlan(struct nfp_fl_set_vxlan *set_vxlan,
 		return -EOPNOTSUPP;
 	}
 
-	tmp_set_vxlan_op =
-		FIELD_PREP(NFP_FL_ACT_LEN_LW, act_size >> NFP_FL_LW_SIZ) |
-		FIELD_PREP(NFP_FL_ACT_JMP_ID,
-			   NFP_FL_ACTION_OPCODE_SET_IPV4_TUNNEL);
-
-	set_vxlan->a_op = cpu_to_be16(tmp_set_vxlan_op);
+	set_vxlan->head.jump_id = NFP_FL_ACTION_OPCODE_SET_IPV4_TUNNEL;
+	set_vxlan->head.len_lw = act_size >> NFP_FL_LW_SIZ;
 
 	/* Set tunnel type and pre-tunnel index. */
 	tmp_set_vxlan_type_index |=
@@ -240,7 +218,6 @@ static int
 nfp_fl_set_eth(const struct tc_action *action, int idx, u32 off,
 	       struct nfp_fl_set_eth *set_eth)
 {
-	u16 tmp_set_eth_op;
 	u32 exact, mask;
 
 	if (off + 4 > ETH_ALEN * 2)
@@ -256,11 +233,8 @@ nfp_fl_set_eth(const struct tc_action *action, int idx, u32 off,
 			    &set_eth->eth_addr_mask[off]);
 
 	set_eth->reserved = cpu_to_be16(0);
-	tmp_set_eth_op = FIELD_PREP(NFP_FL_ACT_LEN_LW,
-				    sizeof(*set_eth) >> NFP_FL_LW_SIZ) |
-			 FIELD_PREP(NFP_FL_ACT_JMP_ID,
-				    NFP_FL_ACTION_OPCODE_SET_ETHERNET);
-	set_eth->a_op = cpu_to_be16(tmp_set_eth_op);
+	set_eth->head.jump_id = NFP_FL_ACTION_OPCODE_SET_ETHERNET;
+	set_eth->head.len_lw = sizeof(*set_eth) >> NFP_FL_LW_SIZ;
 
 	return 0;
 }
@@ -269,7 +243,6 @@ static int
 nfp_fl_set_ip4(const struct tc_action *action, int idx, u32 off,
 	       struct nfp_fl_set_ip4_addrs *set_ip_addr)
 {
-	u16 tmp_set_ipv4_op;
 	__be32 exact, mask;
 
 	/* We are expecting tcf_pedit to return a big endian value */
@@ -293,11 +266,8 @@ nfp_fl_set_ip4(const struct tc_action *action, int idx, u32 off,
 	}
 
 	set_ip_addr->reserved = cpu_to_be16(0);
-	tmp_set_ipv4_op = FIELD_PREP(NFP_FL_ACT_LEN_LW,
-				     sizeof(*set_ip_addr) >> NFP_FL_LW_SIZ) |
-			  FIELD_PREP(NFP_FL_ACT_JMP_ID,
-				     NFP_FL_ACTION_OPCODE_SET_IPV4_ADDRS);
-	set_ip_addr->a_op = cpu_to_be16(tmp_set_ipv4_op);
+	set_ip_addr->head.jump_id = NFP_FL_ACTION_OPCODE_SET_IPV4_ADDRS;
+	set_ip_addr->head.len_lw = sizeof(*set_ip_addr) >> NFP_FL_LW_SIZ;
 
 	return 0;
 }
@@ -306,16 +276,12 @@ static void
 nfp_fl_set_ip6_helper(int opcode_tag, int idx, __be32 exact, __be32 mask,
 		      struct nfp_fl_set_ipv6_addr *ip6)
 {
-	u16 tmp_set_op;
-
 	ip6->ipv6[idx % 4].mask = mask;
 	ip6->ipv6[idx % 4].exact = exact;
 
 	ip6->reserved = cpu_to_be16(0);
-	tmp_set_op = FIELD_PREP(NFP_FL_ACT_LEN_LW, sizeof(*ip6) >>
-				NFP_FL_LW_SIZ) |
-		     FIELD_PREP(NFP_FL_ACT_JMP_ID, opcode_tag);
-	ip6->a_op = cpu_to_be16(tmp_set_op);
+	ip6->head.jump_id = opcode_tag;
+	ip6->head.len_lw = sizeof(*ip6) >> NFP_FL_LW_SIZ;
 }
 
 static int
@@ -352,7 +318,6 @@ nfp_fl_set_tport(const struct tc_action *action, int idx, u32 off,
 		 struct nfp_fl_set_tport *set_tport, int opcode)
 {
 	u32 exact, mask;
-	u16 tmp_set_op;
 
 	if (off)
 		return -EOPNOTSUPP;
@@ -367,10 +332,8 @@ nfp_fl_set_tport(const struct tc_action *action, int idx, u32 off,
 			    set_tport->tp_port_mask);
 
 	set_tport->reserved = cpu_to_be16(0);
-	tmp_set_op = FIELD_PREP(NFP_FL_ACT_LEN_LW,
-				sizeof(*set_tport) >> NFP_FL_LW_SIZ);
-	tmp_set_op |= FIELD_PREP(NFP_FL_ACT_JMP_ID, opcode);
-	set_tport->a_op = cpu_to_be16(tmp_set_op);
+	set_tport->head.jump_id = opcode;
+	set_tport->head.len_lw = sizeof(*set_tport) >> NFP_FL_LW_SIZ;
 
 	return 0;
 }
@@ -428,15 +391,15 @@ nfp_fl_pedit(const struct tc_action *action, char *nfp_action, int *a_len)
 			return err;
 	}
 
-	if (set_eth.a_op) {
+	if (set_eth.head.len_lw) {
 		act_size = sizeof(set_eth);
 		memcpy(nfp_action, &set_eth, act_size);
 		*a_len += act_size;
-	} else if (set_ip_addr.a_op) {
+	} else if (set_ip_addr.head.len_lw) {
 		act_size = sizeof(set_ip_addr);
 		memcpy(nfp_action, &set_ip_addr, act_size);
 		*a_len += act_size;
-	} else if (set_ip6_dst.a_op && set_ip6_src.a_op) {
+	} else if (set_ip6_dst.head.len_lw && set_ip6_src.head.len_lw) {
 		/* TC compiles set src and dst IPv6 address as a single action,
 		 * the hardware requires this to be 2 separate actions.
 		 */
@@ -448,15 +411,15 @@ nfp_fl_pedit(const struct tc_action *action, char *nfp_action, int *a_len)
 		memcpy(&nfp_action[sizeof(set_ip6_src)], &set_ip6_dst,
 		       act_size);
 		*a_len += act_size;
-	} else if (set_ip6_dst.a_op) {
+	} else if (set_ip6_dst.head.len_lw) {
 		act_size = sizeof(set_ip6_dst);
 		memcpy(nfp_action, &set_ip6_dst, act_size);
 		*a_len += act_size;
-	} else if (set_ip6_src.a_op) {
+	} else if (set_ip6_src.head.len_lw) {
 		act_size = sizeof(set_ip6_src);
 		memcpy(nfp_action, &set_ip6_src, act_size);
 		*a_len += act_size;
-	} else if (set_tport.a_op) {
+	} else if (set_tport.head.len_lw) {
 		act_size = sizeof(set_tport);
 		memcpy(nfp_action, &set_tport, act_size);
 		*a_len += act_size;
diff --git a/drivers/net/ethernet/netronome/nfp/flower/cmsg.h b/drivers/net/ethernet/netronome/nfp/flower/cmsg.h
index f7b7242a22bc..64e87f8e7089 100644
--- a/drivers/net/ethernet/netronome/nfp/flower/cmsg.h
+++ b/drivers/net/ethernet/netronome/nfp/flower/cmsg.h
@@ -86,9 +86,6 @@
 #define NFP_FL_ACTION_OPCODE_PRE_TUNNEL		17
 #define NFP_FL_ACTION_OPCODE_NUM		32
 
-#define NFP_FL_ACT_JMP_ID		GENMASK(15, 8)
-#define NFP_FL_ACT_LEN_LW		GENMASK(7, 0)
-
 #define NFP_FL_OUT_FLAGS_LAST		BIT(15)
 #define NFP_FL_OUT_FLAGS_USE_TUN	BIT(4)
 #define NFP_FL_OUT_FLAGS_TYPE_IDX	GENMASK(2, 0)
@@ -113,15 +110,20 @@ enum nfp_flower_tun_type {
 	NFP_FL_TUNNEL_VXLAN =	2,
 };
 
+struct nfp_fl_act_head {
+	u8 jump_id;
+	u8 len_lw;
+};
+
 struct nfp_fl_set_eth {
-	__be16 a_op;
+	struct nfp_fl_act_head head;
 	__be16 reserved;
 	u8 eth_addr_mask[ETH_ALEN * 2];
 	u8 eth_addr_val[ETH_ALEN * 2];
 };
 
 struct nfp_fl_set_ip4_addrs {
-	__be16 a_op;
+	struct nfp_fl_act_head head;
 	__be16 reserved;
 	__be32 ipv4_src_mask;
 	__be32 ipv4_src;
@@ -130,7 +132,7 @@ struct nfp_fl_set_ip4_addrs {
 };
 
 struct nfp_fl_set_ipv6_addr {
-	__be16 a_op;
+	struct nfp_fl_act_head head;
 	__be16 reserved;
 	struct {
 		__be32 mask;
@@ -139,27 +141,27 @@ struct nfp_fl_set_ipv6_addr {
 };
 
 struct nfp_fl_set_tport {
-	__be16 a_op;
+	struct nfp_fl_act_head head;
 	__be16 reserved;
 	u8 tp_port_mask[4];
 	u8 tp_port_val[4];
 };
 
 struct nfp_fl_output {
-	__be16 a_op;
+	struct nfp_fl_act_head head;
 	__be16 flags;
 	__be32 port;
 };
 
 struct nfp_fl_push_vlan {
-	__be16 a_op;
+	struct nfp_fl_act_head head;
 	__be16 reserved;
 	__be16 vlan_tpid;
 	__be16 vlan_tci;
 };
 
 struct nfp_fl_pop_vlan {
-	__be16 a_op;
+	struct nfp_fl_act_head head;
 	__be16 reserved;
 };
 
@@ -178,7 +180,7 @@ struct nfp_flower_meta_one {
 };
 
 struct nfp_fl_pre_tunnel {
-	__be16 a_op;
+	struct nfp_fl_act_head head;
 	__be16 reserved;
 	__be32 ipv4_dst;
 	/* reserved for use with IPv6 addresses */
@@ -186,7 +188,7 @@ struct nfp_fl_pre_tunnel {
 };
 
 struct nfp_fl_set_vxlan {
-	__be16 a_op;
+	struct nfp_fl_act_head head;
 	__be16 reserved;
 	__be64 tun_id;
 	__be32 tun_type_index;
-- 
2.11.0
