From: Greg Rose <gregory.v.rose@intel.com>
Subject: [RFC net-next PATCH 4/4] ixgbe: Add support for new ethtool settings
Date: Wed, 27 Jul 2011 15:18:04 -0700
Message-ID: <20110727221804.8435.97686.stgit@gitlad.jf.intel.com>
References: <20110727221406.8435.44324.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, bhutchings@solarflare.com,
	jeffrey.t.kirsher@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:23389 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755304Ab1G0WSI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jul 2011 18:18:08 -0400
In-Reply-To: <20110727221406.8435.44324.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds ixgbe driver support for new ethtool settings for SR-IOV re-init,
number of VM queues and anti-spoofing ON/OFF switch.


Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
---

 drivers/net/ixgbe/ixgbe.h         |    1 
 drivers/net/ixgbe/ixgbe_ethtool.c |   96 +++++++++++++++++++++++++++++++++++++
 drivers/net/ixgbe/ixgbe_main.c    |    5 ++
 drivers/net/ixgbe/ixgbe_sriov.c   |    2 -
 drivers/net/ixgbe/ixgbe_sriov.h   |    3 -
 5 files changed, 103 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index ed9836f..c826d7e 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -504,6 +504,7 @@ struct ixgbe_adapter {
 	struct hlist_head fdir_filter_list;
 	union ixgbe_atr_input fdir_mask;
 	int fdir_filter_count;
+	const struct ixgbe_info *saved_ii;
 };
 
 struct ixgbe_fdir_filter {
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index dc64955..4a8d3e5 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -38,6 +38,7 @@
 #include <linux/uaccess.h>
 
 #include "ixgbe.h"
+#include "ixgbe_sriov.h"
 
 
 #define IXGBE_ALL_RAR_ENTRIES 16
@@ -314,6 +315,67 @@ static int ixgbe_get_settings(struct net_device *netdev,
 	return 0;
 }
 
+static int ixgbe_reinit_sriov(struct net_device *netdev, int new_vfs)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	struct pci_dev *pdev = adapter->pdev;
+	int err;
+	int i;
+
+	if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED) {
+		if (ixgbe_check_vf_assignment(adapter)) {
+			netdev_warn(netdev, "%s	",
+				    "reconfigure of SR-IOV VFs "
+				    "not supported while VFs are "
+				    "assigned to guest VMs\n");
+			return -EBUSY;
+		}
+	}
+	if (netif_running(netdev)) {
+		netdev_warn(netdev, "%s",
+			    "Cannot reconfigure SR-IOV "
+			    "while interface is up\n"
+			    "Please bring the interface "
+			    "down first\n");
+		return -EBUSY;
+	}
+
+	ixgbe_clear_interrupt_scheme(adapter);
+
+	if (adapter->num_vfs)
+		ixgbe_disable_sriov(adapter);
+
+	adapter->num_vfs = (new_vfs > 63) ? 63 : new_vfs;
+
+	if (adapter->num_vfs) {
+		ixgbe_enable_sriov(adapter, adapter->saved_ii);
+		for (i = 0; i < adapter->num_vfs; i++)
+			ixgbe_vf_configure(pdev, (i | 0x10000000));
+	}
+
+	if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED) {
+		adapter->flags &= ~(IXGBE_FLAG_RSS_ENABLED |
+				    IXGBE_FLAG_DCB_ENABLED);
+		netdev->features &= ~NETIF_F_RXHASH;
+	} else {
+		adapter->flags |= IXGBE_FLAG_RSS_ENABLED;
+		netdev->features |= NETIF_F_RXHASH;
+	}
+
+	err = ixgbe_init_interrupt_scheme(adapter);
+	/*
+	 * If we can't init some sort of interrupt scheme then the device
+	 * is hosed - just print a warning and bail.  Nothing will work
+	 * but at least we've put a message in the system log telling why.
+	 */
+	if (err)
+		e_dev_err("Cannot initialize interrupts for device\n");
+	else
+		ixgbe_reset(adapter);
+
+	return err;
+}
+
 static int ixgbe_set_settings(struct net_device *netdev,
                               struct ethtool_cmd *ecmd)
 {
@@ -322,6 +384,40 @@ static int ixgbe_set_settings(struct net_device *netdev,
 	u32 advertised, old;
 	s32 err = 0;
 
+	if (hw->mac.type == ixgbe_mac_82598EB)
+		goto skip_sriov_checks;
+
+	if (ecmd->num_vfs != adapter->num_vfs) {
+		if (!(adapter->flags & IXGBE_FLAG_DCB_ENABLED)) {
+			err = ixgbe_reinit_sriov(netdev, ecmd->num_vfs);
+			if (err)
+				return err;
+		} else {
+			return -EINVAL;
+		}
+	}
+
+	if ((ecmd->spoof_check == SPOOFCHECK_ENABLE)
+	    && !adapter->antispoofing_enabled) {
+		int i;
+		hw->mac.ops.set_mac_anti_spoofing(hw, true,
+						  adapter->num_vfs);
+		for (i = 0; i < adapter->num_vfs; i++)
+			hw->mac.ops.set_vlan_anti_spoofing(hw, true, i);
+		adapter->antispoofing_enabled = true;
+	} else if ((ecmd->spoof_check == SPOOFCHECK_DISABLE)
+		 && adapter->antispoofing_enabled) {
+		int i;
+		hw->mac.ops.set_mac_anti_spoofing(hw, false,
+						  adapter->num_vfs);
+		for (i = 0; i < adapter->num_vfs; i++)
+			hw->mac.ops.set_vlan_anti_spoofing(hw, false, i);
+		adapter->antispoofing_enabled = false;
+	}
+
+skip_sriov_checks:
+
+
 	if ((hw->phy.media_type == ixgbe_media_type_copper) ||
 	    (hw->phy.multispeed_fiber)) {
 		/* 10000/copper and 1000/copper must autoneg
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 06ba9f2..fba7ff0 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -7206,6 +7206,9 @@ static void __devinit ixgbe_probe_vf(struct ixgbe_adapter *adapter,
 	if (hw->mac.type == ixgbe_mac_82598EB)
 		return;
 
+	/* need to save this away in case SR-IOV is reconfigured */
+	adapter->saved_ii = ii;
+
 	/* The 82599 supports up to 64 VFs per physical function
 	 * but this implementation limits allocation to 63 so that
 	 * basic networking resources are still available to the
@@ -7589,7 +7592,7 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED) {
 		e_info(probe, "IOV is enabled with %d VFs\n", adapter->num_vfs);
 		for (i = 0; i < adapter->num_vfs; i++)
-			ixgbe_vf_configuration(pdev, (i | 0x10000000));
+			ixgbe_vf_configure(pdev, (i | 0x10000000));
 	}
 
 	/* Inform firmware of driver version */
diff --git a/drivers/net/ixgbe/ixgbe_sriov.c b/drivers/net/ixgbe/ixgbe_sriov.c
index cdb2f0c..0da639e 100644
--- a/drivers/net/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ixgbe/ixgbe_sriov.c
@@ -437,7 +437,7 @@ int ixgbe_check_vf_assignment(struct ixgbe_adapter *adapter)
 	return false;
 }
 
-int ixgbe_vf_configuration(struct pci_dev *pdev, unsigned int event_mask)
+int ixgbe_vf_configure(struct pci_dev *pdev, unsigned int event_mask)
 {
 	unsigned char vf_mac_addr[6];
 	struct ixgbe_adapter *adapter = pci_get_drvdata(pdev);
diff --git a/drivers/net/ixgbe/ixgbe_sriov.h b/drivers/net/ixgbe/ixgbe_sriov.h
index 2781847..f588bf5 100644
--- a/drivers/net/ixgbe/ixgbe_sriov.h
+++ b/drivers/net/ixgbe/ixgbe_sriov.h
@@ -30,7 +30,7 @@
 
 void ixgbe_restore_vf_multicasts(struct ixgbe_adapter *adapter);
 void ixgbe_msg_task(struct ixgbe_adapter *adapter);
-int ixgbe_vf_configuration(struct pci_dev *pdev, unsigned int event_mask);
+int ixgbe_vf_configure(struct pci_dev *pdev, unsigned int event_mask);
 void ixgbe_disable_tx_rx(struct ixgbe_adapter *adapter);
 void ixgbe_ping_all_vfs(struct ixgbe_adapter *adapter);
 void ixgbe_dump_registers(struct ixgbe_adapter *adapter);
@@ -46,6 +46,5 @@ void ixgbe_enable_sriov(struct ixgbe_adapter *adapter,
 			const struct ixgbe_info *ii);
 int ixgbe_check_vf_assignment(struct ixgbe_adapter *adapter);
 
-
 #endif /* _IXGBE_SRIOV_H_ */
 

