From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/10] ixgbe: Limit reporting of redirection table if SR-IOV is enabled
Date: Fri, 23 Sep 2016 00:51:41 -0700
Message-ID: <1474617103-59530-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1474617103-59530-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:8864 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757625AbcIWHvs (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 23 Sep 2016 03:51:48 -0400
In-Reply-To: <1474617103-59530-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The hardware redirection table can support more queues then the PF
currently has when SR-IOV is enabled.  In order to account for this use the
RSS mask to trim of the bits that are not used.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index 2d872be..f49f803 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -2947,9 +2947,13 @@ static u32 ixgbe_rss_indir_size(struct net_device *netdev)
 static void ixgbe_get_reta(struct ixgbe_adapter *adapter, u32 *indir)
 {
 	int i, reta_size = ixgbe_rss_indir_tbl_entries(adapter);
+	u16 rss_m = adapter->ring_feature[RING_F_RSS].mask;
+
+	if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED)
+		rss_m = adapter->ring_feature[RING_F_RSS].indices - 1;
 
 	for (i = 0; i < reta_size; i++)
-		indir[i] = adapter->rss_indir_tbl[i];
+		indir[i] = adapter->rss_indir_tbl[i] & rss_m;
 }
 
 static int ixgbe_get_rxfh(struct net_device *netdev, u32 *indir, u8 *key,
-- 
2.7.4
