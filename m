From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/14] igb: Enable use of "bridge fdb add" to set unicast table entries
Date: Mon, 15 Feb 2016 19:21:54 -0800
Message-ID: <1455592915-82261-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1455592915-82261-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <aduyck@mirantis.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:14083 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753355AbcBPDWF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Feb 2016 22:22:05 -0500
In-Reply-To: <1455592915-82261-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>

This change makes it so that we can use the bridge utility to add a FDB
entry for the PF to an igb port.  By doing this we can enable the VFs to
talk to virtual ports residing on top of the PF.

In addition this should also address issues with MACVLANs trying to reside
on top of the PF as well as they would have had similar issues when added
to the PF with SR-IOV enabled.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 39 ++++++++++++++++++++++++-------
 1 file changed, 30 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index bb5be40..e9bdad7 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -2067,6 +2067,25 @@ static int igb_set_features(struct net_device *netdev,
 	return 0;
 }
 
+static int igb_ndo_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
+			   struct net_device *dev,
+			   const unsigned char *addr, u16 vid,
+			   u16 flags)
+{
+	/* guarantee we can provide a unique filter for the unicast address */
+	if (is_unicast_ether_addr(addr) || is_link_local_ether_addr(addr)) {
+		struct igb_adapter *adapter = netdev_priv(dev);
+		struct e1000_hw *hw = &adapter->hw;
+		int vfn = adapter->vfs_allocated_count;
+		int rar_entries = hw->mac.rar_entry_count - (vfn + 1);
+
+		if (netdev_uc_count(dev) >= rar_entries)
+			return -ENOMEM;
+	}
+
+	return ndo_dflt_fdb_add(ndm, tb, dev, addr, vid, flags);
+}
+
 static const struct net_device_ops igb_netdev_ops = {
 	.ndo_open		= igb_open,
 	.ndo_stop		= igb_close,
@@ -2090,6 +2109,7 @@ static const struct net_device_ops igb_netdev_ops = {
 #endif
 	.ndo_fix_features	= igb_fix_features,
 	.ndo_set_features	= igb_set_features,
+	.ndo_fdb_add		= igb_ndo_fdb_add,
 	.ndo_features_check	= passthru_features_check,
 };
 
@@ -4132,15 +4152,16 @@ static void igb_set_rx_mode(struct net_device *netdev)
 				vmolr |= E1000_VMOLR_ROMPE;
 			}
 		}
-		/* Write addresses to available RAR registers, if there is not
-		 * sufficient space to store all the addresses then enable
-		 * unicast promiscuous mode
-		 */
-		count = igb_write_uc_addr_list(netdev);
-		if (count < 0) {
-			rctl |= E1000_RCTL_UPE;
-			vmolr |= E1000_VMOLR_ROPE;
-		}
+	}
+
+	/* Write addresses to available RAR registers, if there is not
+	 * sufficient space to store all the addresses then enable
+	 * unicast promiscuous mode
+	 */
+	count = igb_write_uc_addr_list(netdev);
+	if (count < 0) {
+		rctl |= E1000_RCTL_UPE;
+		vmolr |= E1000_VMOLR_ROPE;
 	}
 
 	/* enable VLAN filtering by default */
-- 
2.5.0
