From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH net-next 5/7] nfp: add set ipv4 header action flower offload
Date: Fri,  6 Oct 2017 10:21:24 +0200
Message-ID: <1507278086-3102-6-git-send-email-simon.horman@netronome.com>
References: <1507278086-3102-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com,
        Pieter Jansen van Vuuren
        <pieter.jansenvanvuuren@netronome.com>,
        Simon Horman <simon.horman@netronome.com>
To: David Miller <davem@davemloft.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:54406 "EHLO
        mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750908AbdJFIVj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 04:21:39 -0400
Received: by mail-wm0-f43.google.com with SMTP id i124so6347630wmf.3
        for <netdev@vger.kernel.org>; Fri, 06 Oct 2017 01:21:38 -0700 (PDT)
In-Reply-To: <1507278086-3102-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pieter Jansen van Vuuren <pieter.jansenvanvuuren@netronome.com>

Previously we did not have offloading support for set IPv4 actions. This
patch enables TC flower offload of set IPv4 src and dst address actions.

Signed-off-by: Pieter Jansen van Vuuren <pieter.jansenvanvuuren@netronome.com>
Reviewed-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/flower/action.c | 46 ++++++++++++++++++++++
 drivers/net/ethernet/netronome/nfp/flower/cmsg.h   | 10 +++++
 2 files changed, 56 insertions(+)

diff --git a/drivers/net/ethernet/netronome/nfp/flower/action.c b/drivers/net/ethernet/netronome/nfp/flower/action.c
index 631ea4b7d08e..2f886a529ee4 100644
--- a/drivers/net/ethernet/netronome/nfp/flower/action.c
+++ b/drivers/net/ethernet/netronome/nfp/flower/action.c
@@ -266,14 +266,53 @@ nfp_fl_set_eth(const struct tc_action *action, int idx, u32 off,
 }
 
 static int
+nfp_fl_set_ip4(const struct tc_action *action, int idx, u32 off,
+	       struct nfp_fl_set_ip4_addrs *set_ip_addr)
+{
+	u16 tmp_set_ipv4_op;
+	__be32 exact, mask;
+
+	/* We are expecting tcf_pedit to return a big endian value */
+	mask = (__force __be32)~tcf_pedit_mask(action, idx);
+	exact = (__force __be32)tcf_pedit_val(action, idx);
+
+	if (exact & ~mask)
+		return -EOPNOTSUPP;
+
+	switch (off) {
+	case offsetof(struct iphdr, daddr):
+		set_ip_addr->ipv4_dst_mask = mask;
+		set_ip_addr->ipv4_dst = exact;
+		break;
+	case offsetof(struct iphdr, saddr):
+		set_ip_addr->ipv4_src_mask = mask;
+		set_ip_addr->ipv4_src = exact;
+		break;
+	default:
+		return -EOPNOTSUPP;
+	}
+
+	set_ip_addr->reserved = cpu_to_be16(0);
+	tmp_set_ipv4_op = FIELD_PREP(NFP_FL_ACT_LEN_LW,
+				     sizeof(*set_ip_addr) >> NFP_FL_LW_SIZ) |
+			  FIELD_PREP(NFP_FL_ACT_JMP_ID,
+				     NFP_FL_ACTION_OPCODE_SET_IPV4_ADDRS);
+	set_ip_addr->a_op = cpu_to_be16(tmp_set_ipv4_op);
+
+	return 0;
+}
+
+static int
 nfp_fl_pedit(const struct tc_action *action, char *nfp_action, int *a_len)
 {
+	struct nfp_fl_set_ip4_addrs set_ip_addr;
 	struct nfp_fl_set_eth set_eth;
 	enum pedit_header_type htype;
 	int idx, nkeys, err;
 	size_t act_size;
 	u32 offset, cmd;
 
+	memset(&set_ip_addr, 0, sizeof(set_ip_addr));
 	memset(&set_eth, 0, sizeof(set_eth));
 	nkeys = tcf_pedit_nkeys(action);
 
@@ -289,6 +328,9 @@ nfp_fl_pedit(const struct tc_action *action, char *nfp_action, int *a_len)
 		case TCA_PEDIT_KEY_EX_HDR_TYPE_ETH:
 			err = nfp_fl_set_eth(action, idx, offset, &set_eth);
 			break;
+		case TCA_PEDIT_KEY_EX_HDR_TYPE_IP4:
+			err = nfp_fl_set_ip4(action, idx, offset, &set_ip_addr);
+			break;
 		default:
 			return -EOPNOTSUPP;
 		}
@@ -300,6 +342,10 @@ nfp_fl_pedit(const struct tc_action *action, char *nfp_action, int *a_len)
 		act_size = sizeof(set_eth);
 		memcpy(nfp_action, &set_eth, act_size);
 		*a_len += act_size;
+	} else if (set_ip_addr.a_op) {
+		act_size = sizeof(set_ip_addr);
+		memcpy(nfp_action, &set_ip_addr, act_size);
+		*a_len += act_size;
 	}
 
 	return 0;
diff --git a/drivers/net/ethernet/netronome/nfp/flower/cmsg.h b/drivers/net/ethernet/netronome/nfp/flower/cmsg.h
index ffeaf85aa420..7ace557fdf84 100644
--- a/drivers/net/ethernet/netronome/nfp/flower/cmsg.h
+++ b/drivers/net/ethernet/netronome/nfp/flower/cmsg.h
@@ -78,6 +78,7 @@
 #define NFP_FL_ACTION_OPCODE_POP_VLAN		2
 #define NFP_FL_ACTION_OPCODE_SET_IPV4_TUNNEL	6
 #define NFP_FL_ACTION_OPCODE_SET_ETHERNET	7
+#define NFP_FL_ACTION_OPCODE_SET_IPV4_ADDRS	9
 #define NFP_FL_ACTION_OPCODE_PRE_TUNNEL		17
 #define NFP_FL_ACTION_OPCODE_NUM		32
 
@@ -115,6 +116,15 @@ struct nfp_fl_set_eth {
 	u8 eth_addr_val[ETH_ALEN * 2];
 };
 
+struct nfp_fl_set_ip4_addrs {
+	__be16 a_op;
+	__be16 reserved;
+	__be32 ipv4_src_mask;
+	__be32 ipv4_src;
+	__be32 ipv4_dst_mask;
+	__be32 ipv4_dst;
+};
+
 struct nfp_fl_output {
 	__be16 a_op;
 	__be16 flags;
-- 
2.1.4
