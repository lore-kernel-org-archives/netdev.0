From: Amritha Nambiar <amritha.nambiar@intel.com>
Subject: [RFC PATCH v2 2/6] [net-next]net: i40e: Maintain a mapping of TCs
 with the VSI seids
Date: Thu, 17 Aug 2017 03:26:56 -0700
Message-ID: <150296561607.16910.15787227064709574787.stgit@anamdev.jf.intel.com>
References: <150296538797.16910.13738130623106637990.stgit@anamdev.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, kiran.patil@intel.com,
        amritha.nambiar@intel.com, netdev@vger.kernel.org,
        mitch.a.williams@intel.com, alexander.duyck@gmail.com,
        neerav.parikh@intel.com, sridhar.samudrala@intel.com,
        carolyn.wyborny@intel.com
To: intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:40640 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752483AbdHQK1r (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 17 Aug 2017 06:27:47 -0400
In-Reply-To: <150296538797.16910.13738130623106637990.stgit@anamdev.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add mapping of TCs with the seids of the channel VSIs. TC0
will be mapped to the main VSI seid and all other TCs are
mapped to the seid of the channel VSI.

Signed-off-by: Amritha Nambiar <amritha.nambiar@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h      |    1 +
 drivers/net/ethernet/intel/i40e/i40e_main.c |    2 ++
 2 files changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 8852ac0..1391e5d 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -738,6 +738,7 @@ struct i40e_vsi {
 	atomic_t next_base_queue;
 
 	struct list_head ch_list;
+	u16 tc_seid_map[I40E_MAX_TRAFFIC_CLASS];
 
 	void *priv;	/* client driver data reference. */
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 601a86d..b02da99 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -6127,6 +6127,7 @@ static int i40e_configure_queue_channels(struct i40e_vsi *vsi)
 	int ret = 0, i;
 
 	/* Create app vsi with the TCs. Main VSI with TC0 is already set up */
+	vsi->tc_seid_map[0] = vsi->seid;
 	for (i = 1; i < I40E_MAX_TRAFFIC_CLASS; i++)
 		if (vsi->tc_config.enabled_tc & BIT(i)) {
 			ch = kzalloc(sizeof(*ch), GFP_KERNEL);
@@ -6156,6 +6157,7 @@ static int i40e_configure_queue_channels(struct i40e_vsi *vsi)
 					i, ch->num_queue_pairs);
 				goto err_free;
 			}
+			vsi->tc_seid_map[i] = ch->seid;
 		}
 	return ret;
 
