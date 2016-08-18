From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/15] i40e: don't allow reduction of channels below active FD rules
Date: Thu, 18 Aug 2016 14:57:28 -0700
Message-ID: <1471557456-136741-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1471557456-136741-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:36966 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754067AbcHSAt6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 18 Aug 2016 20:49:58 -0400
In-Reply-To: <1471557456-136741-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

If a driver is unable to maintain all current user supplied settings
from ethtool (or other sources), it is not ok for a user request to
succeed and silently trample over previous configuration.

To that end, if you change the number of channels, it must not be
allowed to reduce the number of channels (queues) below the current
flow director filter rules targets. In this case, return -EINVAL when
a request to reduce the number of channels would do so. In addition
log a warning to the kernel buffer explaining why we failed, and report
the rules which prevent us from lowering the number of channels.

Change-ID: If41464d63d7aab11cedf09e4f3aa1a69e21ffd88
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 24 ++++++++++++++++++++++++
 1 file changed, 24 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index c912e04..a49552f 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -2744,11 +2744,15 @@ static void i40e_get_channels(struct net_device *dev,
 static int i40e_set_channels(struct net_device *dev,
 			      struct ethtool_channels *ch)
 {
+	const u8 drop = I40E_FILTER_PROGRAM_DESC_DEST_DROP_PACKET;
 	struct i40e_netdev_priv *np = netdev_priv(dev);
 	unsigned int count = ch->combined_count;
 	struct i40e_vsi *vsi = np->vsi;
 	struct i40e_pf *pf = vsi->back;
+	struct i40e_fdir_filter *rule;
+	struct hlist_node *node2;
 	int new_count;
+	int err = 0;
 
 	/* We do not support setting channels for any other VSI at present */
 	if (vsi->type != I40E_VSI_MAIN)
@@ -2766,6 +2770,26 @@ static int i40e_set_channels(struct net_device *dev,
 	if (count > i40e_max_channels(vsi))
 		return -EINVAL;
 
+	/* verify that the number of channels does not invalidate any current
+	 * flow director rules
+	 */
+	hlist_for_each_entry_safe(rule, node2,
+				  &pf->fdir_filter_list, fdir_node) {
+		if (rule->dest_ctl != drop && count <= rule->q_index) {
+			dev_warn(&pf->pdev->dev,
+				 "Existing user defined filter %d assigns flow to queue %d\n",
+				 rule->fd_id, rule->q_index);
+			err = -EINVAL;
+		}
+	}
+
+	if (err) {
+		dev_err(&pf->pdev->dev,
+			"Existing filter rules must be deleted to reduce combined channel count to %d\n",
+			count);
+		return err;
+	}
+
 	/* update feature limits from largest to smallest supported values */
 	/* TODO: Flow director limit, DCB etc */
 
-- 
2.7.4
