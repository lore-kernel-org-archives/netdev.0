From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 20/23] igb: add pci_dev in few spots to clean up
	use of dev_err/info/warn
Date: Wed, 28 Oct 2009 02:51:55 -0700
Message-ID: <20091028095154.13156.59689.stgit@localhost.localdomain>
References: <20091028094540.13156.2637.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta06.emeryville.ca.mail.comcast.net ([76.96.30.56]:52498 "EHLO
	QMTA06.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752981AbZJ1Jzj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2009 05:55:39 -0400
In-Reply-To: <20091028094540.13156.2637.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch relpaces several references to adapter->pdev->dev with just
pdev->dev.  This allows for cleanup of several multiline dev_err/info
calls.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |   24 ++++++++++++------------
 1 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index b2c0c97..264ff00 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -1173,6 +1173,7 @@ void igb_reinit_locked(struct igb_adapter *adapter)
 
 void igb_reset(struct igb_adapter *adapter)
 {
+	struct pci_dev *pdev = adapter->pdev;
 	struct e1000_hw *hw = &adapter->hw;
 	struct e1000_mac_info *mac = &hw->mac;
 	struct e1000_fc_info *fc = &hw->fc;
@@ -1275,7 +1276,7 @@ void igb_reset(struct igb_adapter *adapter)
 	wr32(E1000_WUC, 0);
 
 	if (hw->mac.ops.init_hw(hw))
-		dev_err(&adapter->pdev->dev, "Hardware Error\n");
+		dev_err(&pdev->dev, "Hardware Error\n");
 
 	igb_update_mng_vlan(adapter);
 
@@ -3704,17 +3705,18 @@ static struct net_device_stats *igb_get_stats(struct net_device *netdev)
 static int igb_change_mtu(struct net_device *netdev, int new_mtu)
 {
 	struct igb_adapter *adapter = netdev_priv(netdev);
+	struct pci_dev *pdev = adapter->pdev;
 	int max_frame = new_mtu + ETH_HLEN + ETH_FCS_LEN;
 	u32 rx_buffer_len, i;
 
 	if ((max_frame < ETH_ZLEN + ETH_FCS_LEN) ||
 	    (max_frame > MAX_JUMBO_FRAME_SIZE)) {
-		dev_err(&adapter->pdev->dev, "Invalid MTU setting\n");
+		dev_err(&pdev->dev, "Invalid MTU setting\n");
 		return -EINVAL;
 	}
 
 	if (max_frame > MAX_STD_JUMBO_FRAME_SIZE) {
-		dev_err(&adapter->pdev->dev, "MTU > 9216 not supported.\n");
+		dev_err(&pdev->dev, "MTU > 9216 not supported.\n");
 		return -EINVAL;
 	}
 
@@ -3739,7 +3741,7 @@ static int igb_change_mtu(struct net_device *netdev, int new_mtu)
 	if (netif_running(netdev))
 		igb_down(adapter);
 
-	dev_info(&adapter->pdev->dev, "changing MTU from %d to %d\n",
+	dev_info(&pdev->dev, "changing MTU from %d to %d\n",
 		 netdev->mtu, new_mtu);
 	netdev->mtu = new_mtu;
 
@@ -4053,6 +4055,7 @@ static int __igb_notify_dca(struct device *dev, void *data)
 {
 	struct net_device *netdev = dev_get_drvdata(dev);
 	struct igb_adapter *adapter = netdev_priv(netdev);
+	struct pci_dev *pdev = adapter->pdev;
 	struct e1000_hw *hw = &adapter->hw;
 	unsigned long event = *(unsigned long *)data;
 
@@ -4061,12 +4064,9 @@ static int __igb_notify_dca(struct device *dev, void *data)
 		/* if already enabled, don't do it again */
 		if (adapter->flags & IGB_FLAG_DCA_ENABLED)
 			break;
-		/* Always use CB2 mode, difference is masked
-		 * in the CB driver. */
-		wr32(E1000_DCA_CTRL, E1000_DCA_CTRL_DCA_MODE_CB2);
 		if (dca_add_requester(dev) == 0) {
 			adapter->flags |= IGB_FLAG_DCA_ENABLED;
-			dev_info(&adapter->pdev->dev, "DCA enabled\n");
+			dev_info(&pdev->dev, "DCA enabled\n");
 			igb_setup_dca(adapter);
 			break;
 		}
@@ -4076,7 +4076,7 @@ static int __igb_notify_dca(struct device *dev, void *data)
 			/* without this a class_device is left
 			 * hanging around in the sysfs model */
 			dca_remove_requester(dev);
-			dev_info(&adapter->pdev->dev, "DCA disabled\n");
+			dev_info(&pdev->dev, "DCA disabled\n");
 			adapter->flags &= ~IGB_FLAG_DCA_ENABLED;
 			wr32(E1000_DCA_CTRL, E1000_DCA_CTRL_DCA_MODE_DISABLE);
 		}
@@ -4471,7 +4471,7 @@ static void igb_rcv_msg_from_vf(struct igb_adapter *adapter, u32 vf)
 		retval = igb_set_vf_vlan(adapter, msgbuf, vf);
 		break;
 	default:
-		dev_err(&adapter->pdev->dev, "Unhandled Msg %08x\n", msgbuf[0]);
+		dev_err(&pdev->dev, "Unhandled Msg %08x\n", msgbuf[0]);
 		retval = -1;
 		break;
 	}
@@ -5472,6 +5472,7 @@ static void igb_restore_vlan(struct igb_adapter *adapter)
 
 int igb_set_spd_dplx(struct igb_adapter *adapter, u16 spddplx)
 {
+	struct pci_dev *pdev = adapter->pdev;
 	struct e1000_mac_info *mac = &adapter->hw.mac;
 
 	mac->autoneg = 0;
@@ -5495,8 +5496,7 @@ int igb_set_spd_dplx(struct igb_adapter *adapter, u16 spddplx)
 		break;
 	case SPEED_1000 + DUPLEX_HALF: /* not supported */
 	default:
-		dev_err(&adapter->pdev->dev,
-			"Unsupported Speed/Duplex configuration\n");
+		dev_err(&pdev->dev, "Unsupported Speed/Duplex configuration\n");
 		return -EINVAL;
 	}
 	return 0;

