From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/15] ixgbe: Use __dev_uc_sync and __dev_uc_unsync for unicast addresses
Date: Wed,  2 Dec 2015 04:31:00 -0800
Message-ID: <1449059468-87025-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1449059468-87025-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <aduyck@mirantis.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:1811 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756180AbbLBMbO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Dec 2015 07:31:14 -0500
In-Reply-To: <1449059468-87025-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>

This change replaces the ixgbe_write_uc_addr_list call in ixgbe_set_rx_mode
with a call to __dev_uc_sync instead.  This works much better with the MAC
addr list code that was already in place and solves an issue in which you
couldn't remove an FDB address without having to reset the port.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
Tested-by: Darin Miller <darin.j.miller@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 28 ++++++++++++++++++++++++---
 1 file changed, 25 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 29f1a36..708e210 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -4212,6 +4212,25 @@ static int ixgbe_write_uc_addr_list(struct net_device *netdev, int vfn)
 	return count;
 }
 
+static int ixgbe_uc_sync(struct net_device *netdev, const unsigned char *addr)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	int ret;
+
+	ret = ixgbe_add_mac_filter(adapter, addr, VMDQ_P(0));
+
+	return min_t(int, ret, 0);
+}
+
+static int ixgbe_uc_unsync(struct net_device *netdev, const unsigned char *addr)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+
+	ixgbe_del_mac_filter(adapter, addr, VMDQ_P(0));
+
+	return 0;
+}
+
 /**
  * ixgbe_set_rx_mode - Unicast, Multicast and Promiscuous mode set
  * @netdev: network interface device structure
@@ -4267,8 +4286,7 @@ void ixgbe_set_rx_mode(struct net_device *netdev)
 	 * sufficient space to store all the addresses then enable
 	 * unicast promiscuous mode
 	 */
-	count = ixgbe_write_uc_addr_list(netdev, VMDQ_P(0));
-	if (count < 0) {
+	if (__dev_uc_sync(netdev, ixgbe_uc_sync, ixgbe_uc_unsync)) {
 		fctrl |= IXGBE_FCTRL_UPE;
 		vmolr |= IXGBE_VMOLR_ROPE;
 	}
@@ -5106,8 +5124,12 @@ void ixgbe_reset(struct ixgbe_adapter *adapter)
 	}
 
 	clear_bit(__IXGBE_IN_SFP_INIT, &adapter->state);
-	/* do not flush user set addresses */
+
+	/* flush entries out of MAC table */
 	ixgbe_flush_sw_mac_table(adapter);
+	__dev_uc_unsync(netdev, NULL);
+
+	/* do not flush user set addresses */
 	ixgbe_mac_set_default_filter(adapter);
 
 	/* update SAN MAC vmdq pool selection */
-- 
2.5.0
