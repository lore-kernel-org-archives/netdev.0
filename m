From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH, net-next] i40e: avoid 64-bit division where possible
Date: Tue, 17 Oct 2017 12:23:36 +0200
Message-ID: <20171017102351.492492-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
        Jacob Keller <jacob.e.keller@intel.com>,
        Mitch Williams <mitch.a.williams@intel.com>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        Amritha Nambiar <amritha.nambiar@intel.com>,
        Filip Sadowski <filip.sadowski@intel.com>,
        "David S. Miller" <davem@davemloft.net>,
        =?UTF-8?q?Bj=C3=B6rn=20T=C3=B6pel?= <bjorn.topel@intel.com>,
        intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The new bandwidth calculation causes a link error on 32-bit
architectures, like

ERROR: "__aeabi_uldivmod" [drivers/net/ethernet/intel/i40e/i40e.ko] undefined!

The problem is the max_tx_rate calculation that uses 64-bit integers.
This is not really necessary since the numbers are in MBit/s so
they won't be higher than 40000 for the highest support rate, and
are guaranteed to not exceed 2^32 in future generations either.

This changes the representation to 'u32' when dealing with MBit/s
and uses div_u64() to convert from u64 numbers in byte/s.

Fixes: 2027d4deacb1 ("i40e: Add support setting TC max bandwidth rates")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/intel/i40e/i40e.h      |  4 ++--
 drivers/net/ethernet/intel/i40e/i40e_main.c | 27 ++++++++++++++-------------
 2 files changed, 16 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 266e1dc5e786..45155ef15d24 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -359,7 +359,7 @@ struct i40e_channel {
 	u8 enabled_tc;
 	struct i40e_aqc_vsi_properties_data info;
 
-	u64 max_tx_rate;
+	u32 max_tx_rate; /* in Mbits/s */
 
 	/* track this channel belongs to which VSI */
 	struct i40e_vsi *parent_vsi;
@@ -1045,5 +1045,5 @@ static inline bool i40e_enabled_xdp_vsi(struct i40e_vsi *vsi)
 }
 
 int i40e_create_queue_channel(struct i40e_vsi *vsi, struct i40e_channel *ch);
-int i40e_set_bw_limit(struct i40e_vsi *vsi, u16 seid, u64 max_tx_rate);
+int i40e_set_bw_limit(struct i40e_vsi *vsi, u16 seid, u32 max_tx_rate);
 #endif /* _I40E_H_ */
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 624a2bc8a1df..e71fece72506 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5439,7 +5439,7 @@ int i40e_get_link_speed(struct i40e_vsi *vsi)
  *
  * Helper function to set BW limit for a given VSI
  **/
-int i40e_set_bw_limit(struct i40e_vsi *vsi, u16 seid, u64 max_tx_rate)
+int i40e_set_bw_limit(struct i40e_vsi *vsi, u16 seid, u32 max_tx_rate)
 {
 	struct i40e_pf *pf = vsi->back;
 	int speed = 0;
@@ -5448,7 +5448,7 @@ int i40e_set_bw_limit(struct i40e_vsi *vsi, u16 seid, u64 max_tx_rate)
 	speed = i40e_get_link_speed(vsi);
 	if (max_tx_rate > speed) {
 		dev_err(&pf->pdev->dev,
-			"Invalid max tx rate %llu specified for VSI seid %d.",
+			"Invalid max tx rate %u specified for VSI seid %d.",
 			max_tx_rate, seid);
 		return -EINVAL;
 	}
@@ -5464,7 +5464,7 @@ int i40e_set_bw_limit(struct i40e_vsi *vsi, u16 seid, u64 max_tx_rate)
 					  I40E_MAX_BW_INACTIVE_ACCUM, NULL);
 	if (ret)
 		dev_err(&pf->pdev->dev,
-			"Failed set tx rate (%llu Mbps) for vsi->seid %u, err %s aq_err %s\n",
+			"Failed set tx rate (%u Mbps) for vsi->seid %u, err %s aq_err %s\n",
 			max_tx_rate, seid, i40e_stat_str(&pf->hw, ret),
 			i40e_aq_str(&pf->hw, pf->hw.aq.asq_last_status));
 	return ret;
@@ -6067,7 +6067,7 @@ int i40e_create_queue_channel(struct i40e_vsi *vsi,
 			return -EINVAL;
 
 		dev_dbg(&pf->pdev->dev,
-			"Set tx rate of %llu Mbps (count of 50Mbps %llu) for vsi->seid %u\n",
+			"Set tx rate of %u Mbps (count of 50Mbps %u) for vsi->seid %u\n",
 			ch->max_tx_rate,
 			ch->max_tx_rate / I40E_BW_CREDIT_DIVISOR, ch->seid);
 	}
@@ -6110,8 +6110,8 @@ static int i40e_configure_queue_channels(struct i40e_vsi *vsi)
 			/* Bandwidth limit through tc interface is in bytes/s,
 			 * change to Mbit/s
 			 */
-			ch->max_tx_rate =
-				vsi->mqprio_qopt.max_rate[i] / (1000000 / 8);
+			ch->max_tx_rate = div_u64(vsi->mqprio_qopt.max_rate[i],
+						  1000000 / 8);
 
 			list_add_tail(&ch->list, &vsi->ch_list);
 
@@ -6554,7 +6554,7 @@ static int i40e_validate_mqprio_qopt(struct i40e_vsi *vsi,
 				"Invalid min tx rate (greater than 0) specified\n");
 			return -EINVAL;
 		}
-		sum_max_rate += (mqprio_qopt->max_rate[i] / (1000000 / 8));
+		sum_max_rate += div_u64(mqprio_qopt->max_rate[i], 1000000 / 8);
 
 		if (i >= mqprio_qopt->qopt.num_tc - 1)
 			break;
@@ -6698,12 +6698,12 @@ static int i40e_setup_tc(struct net_device *netdev, void *type_data)
 
 	if (pf->flags & I40E_FLAG_TC_MQPRIO) {
 		if (vsi->mqprio_qopt.max_rate[0]) {
-			u64 max_tx_rate = vsi->mqprio_qopt.max_rate[0] /
-								(1000000 / 8);
+			u32 max_tx_rate = div_u64(vsi->mqprio_qopt.max_rate[0],
+						  1000000 / 8);
 			ret = i40e_set_bw_limit(vsi, vsi->seid, max_tx_rate);
 			if (!ret) {
 				dev_dbg(&vsi->back->pdev->dev,
-					"Set tx rate of %llu Mbps (count of 50Mbps %llu) for vsi->seid %u\n",
+					"Set tx rate of %u Mbps (count of 50Mbps %u) for vsi->seid %u\n",
 					max_tx_rate,
 					max_tx_rate / I40E_BW_CREDIT_DIVISOR,
 					vsi->seid);
@@ -8171,7 +8171,7 @@ static int i40e_rebuild_channels(struct i40e_vsi *vsi)
 				return -EINVAL;
 
 			dev_dbg(&vsi->back->pdev->dev,
-				"Set tx rate of %llu Mbps (count of 50Mbps %llu) for vsi->seid %u\n",
+				"Set tx rate of %u Mbps (count of 50Mbps %u) for vsi->seid %u\n",
 				ch->max_tx_rate,
 				ch->max_tx_rate / I40E_BW_CREDIT_DIVISOR,
 				ch->seid);
@@ -8446,12 +8446,13 @@ static void i40e_rebuild(struct i40e_pf *pf, bool reinit, bool lock_acquired)
 	}
 
 	if (vsi->mqprio_qopt.max_rate[0]) {
-		u64 max_tx_rate = vsi->mqprio_qopt.max_rate[0] / (1000000 / 8);
+		u32 max_tx_rate = div_u64(vsi->mqprio_qopt.max_rate[0],
+					  1000000 / 8);
 
 		ret = i40e_set_bw_limit(vsi, vsi->seid, max_tx_rate);
 		if (!ret)
 			dev_dbg(&vsi->back->pdev->dev,
-				"Set tx rate of %llu Mbps (count of 50Mbps %llu) for vsi->seid %u\n",
+				"Set tx rate of %u Mbps (count of 50Mbps %u) for vsi->seid %u\n",
 				max_tx_rate,
 				max_tx_rate / I40E_BW_CREDIT_DIVISOR,
 				vsi->seid);
-- 
2.9.0
