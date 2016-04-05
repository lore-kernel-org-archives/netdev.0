From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/16] fm10k: add helper functions to set strings and data for ethtool stats
Date: Tue,  5 Apr 2016 01:01:24 -0700
Message-ID: <1459843288-40623-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1459843288-40623-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:2972 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757547AbcDEIC0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2016 04:02:26 -0400
In-Reply-To: <1459843288-40623-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Reduce duplicate code and the amount of indentation by adding
fm10k_add_stat_strings and fm10k_add_ethtool_stats functions which help
add fm10k_stat structures to the ethtool stats callbacks. This helps
increase ease of use for future stat additions, and increases code
readability. Skip handling of the per-queue stats as these will be
reworked in a following patch.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c | 164 ++++++++++++-----------
 1 file changed, 83 insertions(+), 81 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c b/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
index 6a9f988..1496c4b 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
@@ -153,57 +153,51 @@ static const char fm10k_prv_flags[FM10K_PRV_FLAG_LEN][ETH_GSTRING_LEN] = {
 	"debug-statistics",
 };
 
+static void fm10k_add_stat_strings(char **p, const char *prefix,
+				   const struct fm10k_stats stats[],
+				   const unsigned int size)
+{
+	unsigned int i;
+
+	for (i = 0; i < size; i++) {
+		snprintf(*p, ETH_GSTRING_LEN, "%s%s",
+			 prefix, stats[i].stat_string);
+		*p += ETH_GSTRING_LEN;
+	}
+}
+
 static void fm10k_get_stat_strings(struct net_device *dev, u8 *data)
 {
 	struct fm10k_intfc *interface = netdev_priv(dev);
 	struct fm10k_iov_data *iov_data = interface->iov_data;
 	char *p = (char *)data;
 	unsigned int i;
-	unsigned int j;
 
-	for (i = 0; i < FM10K_NETDEV_STATS_LEN; i++) {
-		memcpy(p, fm10k_gstrings_net_stats[i].stat_string,
-		       ETH_GSTRING_LEN);
-		p += ETH_GSTRING_LEN;
-	}
+	fm10k_add_stat_strings(&p, "", fm10k_gstrings_net_stats,
+			       FM10K_NETDEV_STATS_LEN);
 
-	for (i = 0; i < FM10K_GLOBAL_STATS_LEN; i++) {
-		memcpy(p, fm10k_gstrings_global_stats[i].stat_string,
-		       ETH_GSTRING_LEN);
-		p += ETH_GSTRING_LEN;
-	}
+	fm10k_add_stat_strings(&p, "", fm10k_gstrings_global_stats,
+			       FM10K_GLOBAL_STATS_LEN);
 
-	if (interface->flags & FM10K_FLAG_DEBUG_STATS) {
-		for (i = 0; i < FM10K_DEBUG_STATS_LEN; i++) {
-			memcpy(p, fm10k_gstrings_debug_stats[i].stat_string,
-			       ETH_GSTRING_LEN);
-			p += ETH_GSTRING_LEN;
-		}
-	}
+	if (interface->flags & FM10K_FLAG_DEBUG_STATS)
+		fm10k_add_stat_strings(&p, "", fm10k_gstrings_debug_stats,
+				       FM10K_DEBUG_STATS_LEN);
 
-	for (i = 0; i < FM10K_MBX_STATS_LEN; i++) {
-		memcpy(p, fm10k_gstrings_mbx_stats[i].stat_string,
-		       ETH_GSTRING_LEN);
-		p += ETH_GSTRING_LEN;
-	}
+	fm10k_add_stat_strings(&p, "", fm10k_gstrings_mbx_stats,
+			       FM10K_MBX_STATS_LEN);
 
-	if (interface->hw.mac.type != fm10k_mac_vf) {
-		for (i = 0; i < FM10K_PF_STATS_LEN; i++) {
-			memcpy(p, fm10k_gstrings_pf_stats[i].stat_string,
-			       ETH_GSTRING_LEN);
-			p += ETH_GSTRING_LEN;
-		}
-	}
+	if (interface->hw.mac.type != fm10k_mac_vf)
+		fm10k_add_stat_strings(&p, "", fm10k_gstrings_pf_stats,
+				       FM10K_PF_STATS_LEN);
 
 	if ((interface->flags & FM10K_FLAG_DEBUG_STATS) && iov_data) {
 		for (i = 0; i < iov_data->num_vfs; i++) {
-			for (j = 0; j < FM10K_MBX_STATS_LEN; j++) {
-				snprintf(p,
-					 ETH_GSTRING_LEN,
-					 "vf_%u_%s", i,
-					 fm10k_gstrings_mbx_stats[j].stat_string);
-				p += ETH_GSTRING_LEN;
-			}
+			char prefix[ETH_GSTRING_LEN];
+
+			snprintf(prefix, ETH_GSTRING_LEN, "vf_%u_", i);
+			fm10k_add_stat_strings(&p, prefix,
+					       fm10k_gstrings_mbx_stats,
+					       FM10K_MBX_STATS_LEN);
 		}
 	}
 
@@ -271,6 +265,41 @@ static int fm10k_get_sset_count(struct net_device *dev, int sset)
 	}
 }
 
+static void fm10k_add_ethtool_stats(u64 **data, void *pointer,
+				    const struct fm10k_stats stats[],
+				    const unsigned int size)
+{
+	unsigned int i;
+	char *p;
+
+	/* simply skip forward if we were not given a valid pointer */
+	if (!pointer) {
+		*data += size;
+		return;
+	}
+
+	for (i = 0; i < size; i++) {
+		p = (char *)pointer + stats[i].stat_offset;
+
+		switch (stats[i].sizeof_stat) {
+		case sizeof(u64):
+			*((*data)++) = *(u64 *)p;
+			break;
+		case sizeof(u32):
+			*((*data)++) = *(u32 *)p;
+			break;
+		case sizeof(u16):
+			*((*data)++) = *(u16 *)p;
+			break;
+		case sizeof(u8):
+			*((*data)++) = *(u8 *)p;
+			break;
+		default:
+			*((*data)++) = 0;
+		}
+	}
+}
+
 static void fm10k_get_ethtool_stats(struct net_device *netdev,
 				    struct ethtool_stats __always_unused *stats,
 				    u64 *data)
@@ -279,47 +308,29 @@ static void fm10k_get_ethtool_stats(struct net_device *netdev,
 	struct fm10k_intfc *interface = netdev_priv(netdev);
 	struct fm10k_iov_data *iov_data = interface->iov_data;
 	struct net_device_stats *net_stats = &netdev->stats;
-	char *p;
 	int i, j;
 
 	fm10k_update_stats(interface);
 
-	for (i = 0; i < FM10K_NETDEV_STATS_LEN; i++) {
-		p = (char *)net_stats + fm10k_gstrings_net_stats[i].stat_offset;
-		*(data++) = (fm10k_gstrings_net_stats[i].sizeof_stat ==
-			sizeof(u64)) ? *(u64 *)p : *(u32 *)p;
-	}
+	fm10k_add_ethtool_stats(&data, net_stats, fm10k_gstrings_net_stats,
+				FM10K_NETDEV_STATS_LEN);
 
-	for (i = 0; i < FM10K_GLOBAL_STATS_LEN; i++) {
-		p = (char *)interface +
-		    fm10k_gstrings_global_stats[i].stat_offset;
-		*(data++) = (fm10k_gstrings_global_stats[i].sizeof_stat ==
-			sizeof(u64)) ? *(u64 *)p : *(u32 *)p;
-	}
+	fm10k_add_ethtool_stats(&data, interface, fm10k_gstrings_global_stats,
+				FM10K_GLOBAL_STATS_LEN);
 
-	if (interface->flags & FM10K_FLAG_DEBUG_STATS) {
-		for (i = 0; i < FM10K_DEBUG_STATS_LEN; i++) {
-			p = (char *)interface +
-				fm10k_gstrings_debug_stats[i].stat_offset;
-			*(data++) = (fm10k_gstrings_debug_stats[i].sizeof_stat ==
-				     sizeof(u64)) ? *(u64 *)p : *(u32 *)p;
-		}
-	}
+	if (interface->flags & FM10K_FLAG_DEBUG_STATS)
+		fm10k_add_ethtool_stats(&data, interface,
+					fm10k_gstrings_debug_stats,
+					FM10K_DEBUG_STATS_LEN);
 
-	for (i = 0; i < FM10K_MBX_STATS_LEN; i++) {
-		p = (char *)&interface->hw.mbx +
-			fm10k_gstrings_mbx_stats[i].stat_offset;
-		*(data++) = (fm10k_gstrings_mbx_stats[i].sizeof_stat ==
-			sizeof(u64)) ? *(u64 *)p : *(u32 *)p;
-	}
+	fm10k_add_ethtool_stats(&data, &interface->hw.mbx,
+				fm10k_gstrings_mbx_stats,
+				FM10K_MBX_STATS_LEN);
 
 	if (interface->hw.mac.type != fm10k_mac_vf) {
-		for (i = 0; i < FM10K_PF_STATS_LEN; i++) {
-			p = (char *)interface +
-			    fm10k_gstrings_pf_stats[i].stat_offset;
-			*(data++) = (fm10k_gstrings_pf_stats[i].sizeof_stat ==
-				     sizeof(u64)) ? *(u64 *)p : *(u32 *)p;
-		}
+		fm10k_add_ethtool_stats(&data, interface,
+					fm10k_gstrings_pf_stats,
+					FM10K_PF_STATS_LEN);
 	}
 
 	if ((interface->flags & FM10K_FLAG_DEBUG_STATS) && iov_data) {
@@ -328,18 +339,9 @@ static void fm10k_get_ethtool_stats(struct net_device *netdev,
 
 			vf_info = &iov_data->vf_info[i];
 
-			/* skip stats if we don't have a vf info */
-			if (!vf_info) {
-				data += FM10K_MBX_STATS_LEN;
-				continue;
-			}
-
-			for (j = 0; j < FM10K_MBX_STATS_LEN; j++) {
-				p = (char *)&vf_info->mbx +
-					fm10k_gstrings_mbx_stats[j].stat_offset;
-				*(data++) = (fm10k_gstrings_mbx_stats[j].sizeof_stat ==
-					     sizeof(u64)) ? *(u64 *)p : *(u32 *)p;
-			}
+			fm10k_add_ethtool_stats(&data, &vf_info->mbx,
+						fm10k_gstrings_mbx_stats,
+						FM10K_MBX_STATS_LEN);
 		}
 	}
 
-- 
2.5.5
