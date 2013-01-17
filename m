From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/14] igb: Add support for SW timestamping
Date: Thu, 17 Jan 2013 03:35:15 -0800
Message-ID: <1358422519-20981-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1358422519-20981-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Matthew Vick <matthew.vick@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Richard Cochran <richardcochran@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:58527 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756413Ab3AQLfk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jan 2013 06:35:40 -0500
In-Reply-To: <1358422519-20981-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthew Vick <matthew.vick@intel.com>

Enable SW timestamping for situations where the user may prefer it over HW
timestamping or there may not be HW timestamping.

Cc: Richard Cochran <richardcochran@gmail.com>
Signed-off-by: Matthew Vick <matthew.vick@intel.com>
Acked-by: Jacob Keller <Jacob.e.keller@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_ethtool.c | 9 +++++++++
 drivers/net/ethernet/intel/igb/igb_main.c    | 2 ++
 2 files changed, 11 insertions(+)

diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
index bfe9208..6180303 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -2272,12 +2272,21 @@ static int igb_get_ts_info(struct net_device *dev,
 	struct igb_adapter *adapter = netdev_priv(dev);
 
 	switch (adapter->hw.mac.type) {
+	case e1000_82575:
+		info->so_timestamping =
+			SOF_TIMESTAMPING_TX_SOFTWARE |
+			SOF_TIMESTAMPING_RX_SOFTWARE |
+			SOF_TIMESTAMPING_SOFTWARE;
+		return 0;
 	case e1000_82576:
 	case e1000_82580:
 	case e1000_i350:
 	case e1000_i210:
 	case e1000_i211:
 		info->so_timestamping =
+			SOF_TIMESTAMPING_TX_SOFTWARE |
+			SOF_TIMESTAMPING_RX_SOFTWARE |
+			SOF_TIMESTAMPING_SOFTWARE |
 			SOF_TIMESTAMPING_TX_HARDWARE |
 			SOF_TIMESTAMPING_RX_HARDWARE |
 			SOF_TIMESTAMPING_RAW_HARDWARE;
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 2c66ec8..1b5e9a5 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -4610,6 +4610,8 @@ netdev_tx_t igb_xmit_frame_ring(struct sk_buff *skb,
 	first->bytecount = skb->len;
 	first->gso_segs = 1;
 
+	skb_tx_timestamp(skb);
+
 	if (unlikely((skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP) &&
 		     !(adapter->ptp_tx_skb))) {
 		skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
-- 
1.7.11.7
