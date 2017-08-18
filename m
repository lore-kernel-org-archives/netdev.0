From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 10/12] nfp: add ethtool statistics for representors
Date: Fri, 18 Aug 2017 15:48:20 -0700
Message-ID: <20170818224822.8409-11-jakub.kicinski@netronome.com>
References: <20170818224822.8409-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:32835 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751781AbdHRWtc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 18:49:32 -0400
Received: by mail-pg0-f50.google.com with SMTP id t3so44445738pgt.0
        for <netdev@vger.kernel.org>; Fri, 18 Aug 2017 15:49:32 -0700 (PDT)
In-Reply-To: <20170818224822.8409-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Representors may be associated with both VFs or more importantly
with physical ports.  Allow vNIC and MAC statistics to be read
with ethtool -S on representors.  In case of vNICs we reuse
the vNIC statistic helper, we just need to swap RX and TX to
give statistics the "switch perspective."

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 .../net/ethernet/netronome/nfp/nfp_net_ethtool.c   | 70 ++++++++++++++++++++--
 drivers/net/ethernet/netronome/nfp/nfp_port.h      |  5 ++
 2 files changed, 71 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
index f33c341844be..07969f06df10 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
@@ -180,6 +180,7 @@ static const struct nfp_et_stat nfp_mac_et_stats[] = {
 };
 
 #define NN_ET_GLOBAL_STATS_LEN ARRAY_SIZE(nfp_net_et_stats)
+#define NN_ET_SWITCH_STATS_LEN 9
 #define NN_ET_RVEC_GATHER_STATS 7
 
 static void nfp_net_get_nspinfo(struct nfp_app *app, char *version)
@@ -497,11 +498,24 @@ nfp_vnic_get_hw_stats_count(unsigned int rx_rings, unsigned int tx_rings)
 
 static u8 *
 nfp_vnic_get_hw_stats_strings(u8 *data, unsigned int rx_rings,
-			      unsigned int tx_rings)
+			      unsigned int tx_rings, bool repr)
 {
-	int i;
+	int swap_off, i;
 
-	for (i = 0; i < NN_ET_GLOBAL_STATS_LEN; i++)
+	BUILD_BUG_ON(NN_ET_GLOBAL_STATS_LEN < NN_ET_SWITCH_STATS_LEN * 2);
+	/* If repr is true first add SWITCH_STATS_LEN and then subtract it
+	 * effectively swapping the RX and TX statistics (giving us the RX
+	 * and TX from perspective of the switch).
+	 */
+	swap_off = repr * NN_ET_SWITCH_STATS_LEN;
+
+	for (i = 0; i < NN_ET_SWITCH_STATS_LEN; i++)
+		data = nfp_pr_et(data, nfp_net_et_stats[i + swap_off].name);
+
+	for (i = NN_ET_SWITCH_STATS_LEN; i < NN_ET_SWITCH_STATS_LEN * 2; i++)
+		data = nfp_pr_et(data, nfp_net_et_stats[i - swap_off].name);
+
+	for (i = NN_ET_SWITCH_STATS_LEN * 2; i < NN_ET_GLOBAL_STATS_LEN; i++)
 		data = nfp_pr_et(data, nfp_net_et_stats[i].name);
 
 	for (i = 0; i < tx_rings; i++) {
@@ -589,7 +603,8 @@ static void nfp_net_get_strings(struct net_device *netdev,
 	case ETH_SS_STATS:
 		data = nfp_vnic_get_sw_stats_strings(netdev, data);
 		data = nfp_vnic_get_hw_stats_strings(data, nn->dp.num_rx_rings,
-						     nn->dp.num_tx_rings);
+						     nn->dp.num_tx_rings,
+						     false);
 		data = nfp_mac_get_stats_strings(netdev, data);
 		break;
 	}
@@ -622,6 +637,50 @@ static int nfp_net_get_sset_count(struct net_device *netdev, int sset)
 	}
 }
 
+static void nfp_port_get_strings(struct net_device *netdev,
+				 u32 stringset, u8 *data)
+{
+	struct nfp_port *port = nfp_port_from_netdev(netdev);
+
+	switch (stringset) {
+	case ETH_SS_STATS:
+		if (nfp_port_is_vnic(port))
+			data = nfp_vnic_get_hw_stats_strings(data, 0, 0, true);
+		else
+			data = nfp_mac_get_stats_strings(netdev, data);
+		break;
+	}
+}
+
+static void
+nfp_port_get_stats(struct net_device *netdev, struct ethtool_stats *stats,
+		   u64 *data)
+{
+	struct nfp_port *port = nfp_port_from_netdev(netdev);
+
+	if (nfp_port_is_vnic(port))
+		data = nfp_vnic_get_hw_stats(data, port->vnic, 0, 0);
+	else
+		data = nfp_mac_get_stats(netdev, data);
+}
+
+static int nfp_port_get_sset_count(struct net_device *netdev, int sset)
+{
+	struct nfp_port *port = nfp_port_from_netdev(netdev);
+	unsigned int count;
+
+	switch (sset) {
+	case ETH_SS_STATS:
+		if (nfp_port_is_vnic(port))
+			count = nfp_vnic_get_hw_stats_count(0, 0);
+		else
+			count = nfp_mac_get_stats_count(netdev);
+		return count;
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
 /* RX network flow classification (RSS, filters, etc)
  */
 static u32 ethtool_flow_to_nfp_flag(u32 flow_type)
@@ -1085,6 +1144,9 @@ static const struct ethtool_ops nfp_net_ethtool_ops = {
 const struct ethtool_ops nfp_port_ethtool_ops = {
 	.get_drvinfo		= nfp_app_get_drvinfo,
 	.get_link		= ethtool_op_get_link,
+	.get_strings		= nfp_port_get_strings,
+	.get_ethtool_stats	= nfp_port_get_stats,
+	.get_sset_count		= nfp_port_get_sset_count,
 	.set_dump		= nfp_app_set_dump,
 	.get_dump_flag		= nfp_app_get_dump_flag,
 	.get_dump_data		= nfp_app_get_dump_data,
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_port.h b/drivers/net/ethernet/netronome/nfp/nfp_port.h
index 81c034018133..51dcb9c603ee 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_port.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_port.h
@@ -116,6 +116,11 @@ extern const struct switchdev_ops nfp_port_switchdev_ops;
 int nfp_port_setup_tc(struct net_device *netdev, enum tc_setup_type type,
 		      void *type_data);
 
+static inline bool nfp_port_is_vnic(const struct nfp_port *port)
+{
+	return port->type == NFP_PORT_PF_PORT || port->type == NFP_PORT_VF_PORT;
+}
+
 struct nfp_port *nfp_port_from_netdev(struct net_device *netdev);
 struct nfp_port *
 nfp_port_from_id(struct nfp_pf *pf, enum nfp_port_type type, unsigned int id);
-- 
2.11.0
