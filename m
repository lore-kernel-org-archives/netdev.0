From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH net-next 7/7] nfp: add set tcp and udp header action flower offload
Date: Fri,  6 Oct 2017 10:21:26 +0200
Message-ID: <1507278086-3102-8-git-send-email-simon.horman@netronome.com>
References: <1507278086-3102-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com,
        Pieter Jansen van Vuuren
        <pieter.jansenvanvuuren@netronome.com>,
        Simon Horman <simon.horman@netronome.com>
To: David Miller <davem@davemloft.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:46472 "EHLO
        mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751705AbdJFIVm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 04:21:42 -0400
Received: by mail-wm0-f47.google.com with SMTP id m72so6132585wmc.1
        for <netdev@vger.kernel.org>; Fri, 06 Oct 2017 01:21:41 -0700 (PDT)
In-Reply-To: <1507278086-3102-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pieter Jansen van Vuuren <pieter.jansenvanvuuren@netronome.com>

Previously we did not have offloading support for set TCP/UDP actions. This
patch enables TC flower offload of set TCP/UDP sport and dport actions.

Signed-off-by: Pieter Jansen van Vuuren <pieter.jansenvanvuuren@netronome.com>
Reviewed-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/flower/action.c | 42 ++++++++++++++++++++++
 drivers/net/ethernet/netronome/nfp/flower/cmsg.h   |  9 +++++
 2 files changed, 51 insertions(+)

diff --git a/drivers/net/ethernet/netronome/nfp/flower/action.c b/drivers/net/ethernet/netronome/nfp/flower/action.c
index 4394e4f15fdb..1194c47ef827 100644
--- a/drivers/net/ethernet/netronome/nfp/flower/action.c
+++ b/drivers/net/ethernet/netronome/nfp/flower/action.c
@@ -348,10 +348,39 @@ nfp_fl_set_ip6(const struct tc_action *action, int idx, u32 off,
 }
 
 static int
+nfp_fl_set_tport(const struct tc_action *action, int idx, u32 off,
+		 struct nfp_fl_set_tport *set_tport, int opcode)
+{
+	u32 exact, mask;
+	u16 tmp_set_op;
+
+	if (off)
+		return -EOPNOTSUPP;
+
+	mask = ~tcf_pedit_mask(action, idx);
+	exact = tcf_pedit_val(action, idx);
+
+	if (exact & ~mask)
+		return -EOPNOTSUPP;
+
+	nfp_fl_set_helper32(exact, mask, set_tport->tp_port_val,
+			    set_tport->tp_port_mask);
+
+	set_tport->reserved = cpu_to_be16(0);
+	tmp_set_op = FIELD_PREP(NFP_FL_ACT_LEN_LW,
+				sizeof(*set_tport) >> NFP_FL_LW_SIZ);
+	tmp_set_op |= FIELD_PREP(NFP_FL_ACT_JMP_ID, opcode);
+	set_tport->a_op = cpu_to_be16(tmp_set_op);
+
+	return 0;
+}
+
+static int
 nfp_fl_pedit(const struct tc_action *action, char *nfp_action, int *a_len)
 {
 	struct nfp_fl_set_ipv6_addr set_ip6_dst, set_ip6_src;
 	struct nfp_fl_set_ip4_addrs set_ip_addr;
+	struct nfp_fl_set_tport set_tport;
 	struct nfp_fl_set_eth set_eth;
 	enum pedit_header_type htype;
 	int idx, nkeys, err;
@@ -361,6 +390,7 @@ nfp_fl_pedit(const struct tc_action *action, char *nfp_action, int *a_len)
 	memset(&set_ip6_dst, 0, sizeof(set_ip6_dst));
 	memset(&set_ip6_src, 0, sizeof(set_ip6_src));
 	memset(&set_ip_addr, 0, sizeof(set_ip_addr));
+	memset(&set_tport, 0, sizeof(set_tport));
 	memset(&set_eth, 0, sizeof(set_eth));
 	nkeys = tcf_pedit_nkeys(action);
 
@@ -383,6 +413,14 @@ nfp_fl_pedit(const struct tc_action *action, char *nfp_action, int *a_len)
 			err = nfp_fl_set_ip6(action, idx, offset, &set_ip6_dst,
 					     &set_ip6_src);
 			break;
+		case TCA_PEDIT_KEY_EX_HDR_TYPE_TCP:
+			err = nfp_fl_set_tport(action, idx, offset, &set_tport,
+					       NFP_FL_ACTION_OPCODE_SET_TCP);
+			break;
+		case TCA_PEDIT_KEY_EX_HDR_TYPE_UDP:
+			err = nfp_fl_set_tport(action, idx, offset, &set_tport,
+					       NFP_FL_ACTION_OPCODE_SET_UDP);
+			break;
 		default:
 			return -EOPNOTSUPP;
 		}
@@ -418,6 +456,10 @@ nfp_fl_pedit(const struct tc_action *action, char *nfp_action, int *a_len)
 		act_size = sizeof(set_ip6_src);
 		memcpy(nfp_action, &set_ip6_src, act_size);
 		*a_len += act_size;
+	} else if (set_tport.a_op) {
+		act_size = sizeof(set_tport);
+		memcpy(nfp_action, &set_tport, act_size);
+		*a_len += act_size;
 	}
 
 	return 0;
diff --git a/drivers/net/ethernet/netronome/nfp/flower/cmsg.h b/drivers/net/ethernet/netronome/nfp/flower/cmsg.h
index 527914e294d7..f7b7242a22bc 100644
--- a/drivers/net/ethernet/netronome/nfp/flower/cmsg.h
+++ b/drivers/net/ethernet/netronome/nfp/flower/cmsg.h
@@ -81,6 +81,8 @@
 #define NFP_FL_ACTION_OPCODE_SET_IPV4_ADDRS	9
 #define NFP_FL_ACTION_OPCODE_SET_IPV6_SRC	11
 #define NFP_FL_ACTION_OPCODE_SET_IPV6_DST	12
+#define NFP_FL_ACTION_OPCODE_SET_UDP		14
+#define NFP_FL_ACTION_OPCODE_SET_TCP		15
 #define NFP_FL_ACTION_OPCODE_PRE_TUNNEL		17
 #define NFP_FL_ACTION_OPCODE_NUM		32
 
@@ -136,6 +138,13 @@ struct nfp_fl_set_ipv6_addr {
 	} ipv6[4];
 };
 
+struct nfp_fl_set_tport {
+	__be16 a_op;
+	__be16 reserved;
+	u8 tp_port_mask[4];
+	u8 tp_port_val[4];
+};
+
 struct nfp_fl_output {
 	__be16 a_op;
 	__be16 flags;
-- 
2.1.4
