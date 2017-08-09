From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/12] igb: Fix error of RX network flow classification
Date: Wed,  9 Aug 2017 14:47:35 -0700
Message-ID: <20170809214746.28139-2-jeffrey.t.kirsher@intel.com>
References: <20170809214746.28139-1-jeffrey.t.kirsher@intel.com>
Cc: Gangfeng Huang <gangfeng.huang@ni.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:44498 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752251AbdHIVrz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 9 Aug 2017 17:47:55 -0400
In-Reply-To: <20170809214746.28139-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gangfeng Huang <gangfeng.huang@ni.com>

After add an ethertype filter, if user change the adapter speed several
times, the error "ethtool -N: etype filters are all used" is reported by
igb driver.

In older patch, function igb_nfc_filter_exit() and igb_nfc_filter_restore()
is not paried. igb_nfc_filter_restore() exist in igb_up(), but function
igb_nfc_filter_exit() is exist in __igb_close(). In the process of speed
changing, only igb_nfc_filter_restore() is called, it will take a position
of ethertype bitmap.

Reproduce steps:
Step 1: Add a etype filter by ethtool
$ethtool -N eth0 flow-type ether proto 0x88F8 action 1
Step 2: Change the adapter speed to 100M/full duplex
$ethtool -s eth0 speed 100 duplex full
Step 3: Change the adapter speed to 1000M/full duplex
ethtool -s eth0 speed 1000 duplex full
Repeat step2 and step3, then dmesg the system log, you can find the error
message, add new ethtype filter is also failed.

This fixing is move igb_nfc_filter_exit() from __igb_close() to igb_down()
to make igb_nfc_filter_restore()/igb_nfc_filter_exit() is paired.

Signed-off-by: Gangfeng Huang <gangfeng.huang@ni.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index ec62410b035a..6a63ea564a57 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -1791,6 +1791,8 @@ void igb_down(struct igb_adapter *adapter)
 	wr32(E1000_RCTL, rctl & ~E1000_RCTL_EN);
 	/* flush and sleep below */
 
+	igb_nfc_filter_exit(adapter);
+
 	netif_carrier_off(netdev);
 	netif_tx_stop_all_queues(netdev);
 
@@ -3317,8 +3319,6 @@ static int __igb_close(struct net_device *netdev, bool suspending)
 	igb_down(adapter);
 	igb_free_irq(adapter);
 
-	igb_nfc_filter_exit(adapter);
-
 	igb_free_all_tx_resources(adapter);
 	igb_free_all_rx_resources(adapter);
 
-- 
2.13.3
