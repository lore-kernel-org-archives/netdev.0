From: Greg Rose <gregory.v.rose@intel.com>
Subject: [RFC PATCH V2 2/2] ixgbe: Add support for new ethtool IOV
	configuration commands
Date: Thu, 22 Sep 2011 14:35:28 -0700
Message-ID: <20110922213527.26654.48496.stgit@gitlad.jf.intel.com>
References: <20110922213522.26654.59301.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:63625 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753939Ab1IVVfa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Sep 2011 17:35:30 -0400
Received: from gitlad.jf.intel.com (gitlad.jf.intel.com [127.0.0.1])
	by gitlad.jf.intel.com (8.14.2/8.14.2) with ESMTP id p8MLZS9l026700
	for <netdev@vger.kernel.org>; Thu, 22 Sep 2011 14:35:28 -0700
In-Reply-To: <20110922213522.26654.59301.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement driver support for the new ethtool command to configure
the number of VFs per PF independently.  The framework is in place
for support of two other features that allow the user to partition
some of the I/O resources of the device to additional semi-independent
net devices and to set the number of queues per VF.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
---

 drivers/net/ethernet/intel/ixgbe/ixgbe.h         |    1 
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |  110 ++++++++++++++++++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |    3 +
 3 files changed, 113 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 8fab322..cea2323 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -528,6 +528,7 @@ struct ixgbe_adapter {
 	int fdir_filter_count;
 	u32 timer_event_accumulator;
 	u32 vferr_refcount;
+	const struct ixgbe_info *saved_ii;
 };
 
 struct ixgbe_fdir_filter {
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index 08c9994..c695362 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -38,7 +38,7 @@
 #include <linux/uaccess.h>
 
 #include "ixgbe.h"
-
+#include "ixgbe_sriov.h"
 
 #define IXGBE_ALL_RAR_ENTRIES 16
 
@@ -2577,6 +2577,112 @@ static int ixgbe_set_rxnfc(struct net_device *dev, struct ethtool_rxnfc *cmd)
 	return ret;
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
+			netdev_warn(netdev, "%s ",
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
+		 return -EBUSY;
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
+			ixgbe_vf_configuration(pdev, (i | 0x10000000));
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
+static int ixgbe_iov_set_cmd(struct net_device *dev,
+			     struct ethtool_iov_set_cmd *iov_cmd)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(dev);
+	struct ixgbe_hw *hw = &adapter->hw;
+	int err = 0;
+
+	if (iov_cmd->set_cmd == ETHTOOL_IOV_CMD_CONFIGURE_SRIOV &&
+	    hw->mac.type == ixgbe_mac_82598EB)
+		return -EOPNOTSUPP;
+
+	switch (iov_cmd->set_cmd) {
+	case ETHTOOL_IOV_CMD_CONFIGURE_SRIOV:
+		if (iov_cmd->cmd_param != adapter->num_vfs &&
+		    !(adapter->flags & IXGBE_FLAG_DCB_ENABLED))
+			err = ixgbe_reinit_sriov(dev, iov_cmd->cmd_param);
+		else
+			err = -EINVAL;
+		break;
+	case ETHTOOL_IOV_CMD_CONFIGURE_NETDEVS:
+		err = -ENOTSUPP;
+		break;
+	case ETHTOOL_IOV_CMD_CONFIGURE_VF_QUEUES:
+		err = -ENOTSUPP;
+		break;
+	default:
+		err = -EINVAL;
+		break;
+	}
+
+	return err;
+}
+
+static int ixgbe_iov_get_cmd(struct net_device *dev,
+			     struct ethtool_iov_get_cmd *iov_cmd)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(dev);
+
+	iov_cmd->mode = ETHTOOL_IOV_MODE_NONE;
+	if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED)
+		iov_cmd->mode = ETHTOOL_IOV_MODE_SRIOV;
+
+	return 0;
+}
+
 static const struct ethtool_ops ixgbe_ethtool_ops = {
 	.get_settings           = ixgbe_get_settings,
 	.set_settings           = ixgbe_set_settings,
@@ -2605,6 +2711,8 @@ static const struct ethtool_ops ixgbe_ethtool_ops = {
 	.set_coalesce           = ixgbe_set_coalesce,
 	.get_rxnfc		= ixgbe_get_rxnfc,
 	.set_rxnfc		= ixgbe_set_rxnfc,
+	.iov_set_cmd		= ixgbe_iov_set_cmd,
+	.iov_get_cmd		= ixgbe_iov_get_cmd,
 };
 
 void ixgbe_set_ethtool_ops(struct net_device *netdev)
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 99ff8b2..546f3ba 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7591,6 +7591,9 @@ static void __devinit ixgbe_probe_vf(struct ixgbe_adapter *adapter,
 	if (hw->mac.type == ixgbe_mac_82598EB)
 		return;
 
+	/* need to save this away in case SR-IOV is reconfigured */
+	adapter->saved_ii = ii;
+
 	/* The 82599 supports up to 64 VFs per physical function
 	 * but this implementation limits allocation to 63 so that
 	 * basic networking resources are still available to the
