From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net 3/8] net/mlx5e: Allow TC csum offload if applied together with pedit action
Date: Tue, 23 May 2017 17:16:05 +0300
Message-ID: <20170523141610.27833-4-saeedm@mellanox.com>
References: <20170523141610.27833-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:44677 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S934078AbdEWOQb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 10:16:31 -0400
In-Reply-To: <20170523141610.27833-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

When offloading header re-writes, the HW re-calculates the relevant L3/L4
checksums. Hence, when upper layers (as done by OVS) ask for TC checksum action
offload together with pedit offload, don't err. This command now works:

tc filter add dev ens1f0 protocol ip parent ffff: prio 20 flower skip_sw
	ip_proto tcp dst_port 9001
	action pedit ex munge tcp dport set 0x1234 pipe
        action csum tcp

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Reported-by: Paul Blakey <paulb@mellanox.com>
Reviewed-by: Paul Blakey <paulb@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c | 39 +++++++++++++++++++++++++
 1 file changed, 39 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index a90dd26ea51c..9dd83c7e4c51 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -43,6 +43,7 @@
 #include <net/tc_act/tc_vlan.h>
 #include <net/tc_act/tc_tunnel_key.h>
 #include <net/tc_act/tc_pedit.h>
+#include <net/tc_act/tc_csum.h>
 #include <net/vxlan.h>
 #include <net/arp.h>
 #include "en.h"
@@ -1109,6 +1110,28 @@ static int parse_tc_pedit_action(struct mlx5e_priv *priv,
 	return err;
 }
 
+static bool csum_offload_supported(struct mlx5e_priv *priv, u32 action, u32 update_flags)
+{
+	u32 prot_flags = TCA_CSUM_UPDATE_FLAG_IPV4HDR | TCA_CSUM_UPDATE_FLAG_TCP |
+			 TCA_CSUM_UPDATE_FLAG_UDP;
+
+	/*  The HW recalcs checksums only if re-writing headers */
+	if (!(action & MLX5_FLOW_CONTEXT_ACTION_MOD_HDR)) {
+		netdev_warn(priv->netdev,
+			    "TC csum action is only offloaded with pedit\n");
+		return false;
+	}
+
+	if (update_flags & ~prot_flags) {
+		netdev_warn(priv->netdev,
+			    "can't offload TC csum action for some header/s - flags %#x\n",
+			    update_flags);
+		return false;
+	}
+
+	return true;
+}
+
 static int parse_tc_nic_actions(struct mlx5e_priv *priv, struct tcf_exts *exts,
 				struct mlx5e_tc_flow_parse_attr *parse_attr,
 				struct mlx5e_tc_flow *flow)
@@ -1149,6 +1172,14 @@ static int parse_tc_nic_actions(struct mlx5e_priv *priv, struct tcf_exts *exts,
 			continue;
 		}
 
+		if (is_tcf_csum(a)) {
+			if (csum_offload_supported(priv, attr->action,
+						   tcf_csum_update_flags(a)))
+				continue;
+
+			return -EOPNOTSUPP;
+		}
+
 		if (is_tcf_skbedit_mark(a)) {
 			u32 mark = tcf_skbedit_mark(a);
 
@@ -1651,6 +1682,14 @@ static int parse_tc_fdb_actions(struct mlx5e_priv *priv, struct tcf_exts *exts,
 			continue;
 		}
 
+		if (is_tcf_csum(a)) {
+			if (csum_offload_supported(priv, attr->action,
+						   tcf_csum_update_flags(a)))
+				continue;
+
+			return -EOPNOTSUPP;
+		}
+
 		if (is_tcf_mirred_egress_redirect(a)) {
 			int ifindex = tcf_mirred_ifindex(a);
 			struct net_device *out_dev, *encap_dev = NULL;
-- 
2.11.0
