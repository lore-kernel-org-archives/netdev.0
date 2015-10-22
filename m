From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH 2/3] ixgbe: Use __dev_uc_sync and __dev_uc_unsync
 for unicast addresses
Date: Thu, 22 Oct 2015 16:26:36 -0700
Message-ID: <20151022232636.24612.12045.stgit@ahduyck-vm-fedora22>
References: <20151022232228.24612.81341.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
	jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:34469 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965756AbbJVX0i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2015 19:26:38 -0400
Received: by padhk11 with SMTP id hk11so99458445pad.1
        for <netdev@vger.kernel.org>; Thu, 22 Oct 2015 16:26:37 -0700 (PDT)
In-Reply-To: <20151022232228.24612.81341.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change replaces the ixgbe_write_uc_addr_list call in ixgbe_set_rx_mode
with a call to __dev_uc_sync instead.  This works much better with the MAC
addr list code that was already in place and solves an issue in which you
couldn't remove an fdb address without having to reset the port.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   28 ++++++++++++++++++++++---
 1 file changed, 25 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 650c9526bbde..ba5c0d5b95b9 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -4215,6 +4215,25 @@ static int ixgbe_write_uc_addr_list(struct net_device *netdev, int vfn)
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
@@ -4270,8 +4289,7 @@ void ixgbe_set_rx_mode(struct net_device *netdev)
 	 * sufficient space to store all the addresses then enable
 	 * unicast promiscuous mode
 	 */
-	count = ixgbe_write_uc_addr_list(netdev, VMDQ_P(0));
-	if (count < 0) {
+	if (__dev_uc_sync(netdev, ixgbe_uc_sync, ixgbe_uc_unsync)) {
 		fctrl |= IXGBE_FCTRL_UPE;
 		vmolr |= IXGBE_VMOLR_ROPE;
 	}
@@ -5109,8 +5127,12 @@ void ixgbe_reset(struct ixgbe_adapter *adapter)
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
