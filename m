From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/16] 8139too: Support RX-ALL logic.
Date: Fri, 24 Feb 2012 02:13:02 -0800
Message-ID: <1330078389-8203-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1330078389-8203-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Ben Greear <greearb@candelatech.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:43469 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756819Ab2BXKNR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Feb 2012 05:13:17 -0500
In-Reply-To: <1330078389-8203-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

This allows the NIC to receive Runts and frames with bad
Ethernet Frame Checksums (FCS).

Useful to sniffing & diagnosing bad networks.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
 drivers/net/ethernet/realtek/8139too.c |   52 ++++++++++++++++++++++++++++++++
 1 files changed, 52 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/realtek/8139too.c b/drivers/net/ethernet/realtek/8139too.c
index 1c3feb0..1b9a090 100644
--- a/drivers/net/ethernet/realtek/8139too.c
+++ b/drivers/net/ethernet/realtek/8139too.c
@@ -907,6 +907,33 @@ err_out:
 	return ERR_PTR(rc);
 }
 
+static int rtl8139_set_features(struct net_device *dev, netdev_features_t features)
+{
+	struct rtl8139_private *tp = netdev_priv(dev);
+	unsigned long flags;
+	netdev_features_t changed = features ^ dev->features;
+	void __iomem *ioaddr = tp->mmio_addr;
+
+	if (!(changed & (NETIF_F_RXALL)))
+		return 0;
+
+	spin_lock_irqsave(&tp->lock, flags);
+
+	if (changed & NETIF_F_RXALL) {
+		int rx_mode = tp->rx_config;
+		if (features & NETIF_F_RXALL)
+			rx_mode |= (AcceptErr | AcceptRunt);
+		else
+			rx_mode &= ~(AcceptErr | AcceptRunt);
+		tp->rx_config = rtl8139_rx_config | rx_mode;
+		RTL_W32_F(RxConfig, tp->rx_config);
+	}
+
+	spin_unlock_irqrestore(&tp->lock, flags);
+
+	return 0;
+}
+
 static const struct net_device_ops rtl8139_netdev_ops = {
 	.ndo_open		= rtl8139_open,
 	.ndo_stop		= rtl8139_close,
@@ -921,6 +948,7 @@ static const struct net_device_ops rtl8139_netdev_ops = {
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= rtl8139_poll_controller,
 #endif
+	.ndo_set_features	= rtl8139_set_features,
 };
 
 static int __devinit rtl8139_init_one (struct pci_dev *pdev,
@@ -994,6 +1022,8 @@ static int __devinit rtl8139_init_one (struct pci_dev *pdev,
 	dev->features |= NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_HIGHDMA;
 	dev->vlan_features = dev->features;
 
+	dev->hw_features |= NETIF_F_RXALL;
+
 	dev->irq = pdev->irq;
 
 	/* tp zeroed and aligned in alloc_etherdev */
@@ -1978,11 +2008,30 @@ no_early_rx:
 		if (unlikely((rx_size > (MAX_ETH_FRAME_SIZE+4)) ||
 			     (rx_size < 8) ||
 			     (!(rx_status & RxStatusOK)))) {
+			if ((dev->features & NETIF_F_RXALL) &&
+			    (rx_size <= (MAX_ETH_FRAME_SIZE + 4)) &&
+			    (rx_size >= 8) &&
+			    (!(rx_status & RxStatusOK))) {
+				/* Length is at least mostly OK, but pkt has
+				 * error.  I'm hoping we can handle some of these
+				 * errors without resetting the chip. --Ben
+				 */
+				dev->stats.rx_errors++;
+				if (rx_status & RxCRCErr) {
+					dev->stats.rx_crc_errors++;
+					goto keep_pkt;
+				}
+				if (rx_status & RxRunt) {
+					dev->stats.rx_length_errors++;
+					goto keep_pkt;
+				}
+			}
 			rtl8139_rx_err (rx_status, dev, tp, ioaddr);
 			received = -1;
 			goto out;
 		}
 
+keep_pkt:
 		/* Malloc up new buffer, compatible with net-2e. */
 		/* Omit the four octet CRC from the length. */
 
@@ -2515,6 +2564,9 @@ static void __set_rx_mode (struct net_device *dev)
 		}
 	}
 
+	if (dev->features & NETIF_F_RXALL)
+		rx_mode |= (AcceptErr | AcceptRunt);
+
 	/* We can safely update without stopping the chip. */
 	tmp = rtl8139_rx_config | rx_mode;
 	if (tp->rx_config != tmp) {
-- 
1.7.7.6
