From: Jon Mason <jon.mason@exar.com>
Subject: [PATCH] s2io: add dynamic LRO disable support
Date: Thu, 24 Jun 2010 23:45:10 -0500
Message-ID: <20100625044510.GC2739@exar.com>
References: <20100622085415.5566.22523.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sgruszka@redhat.com" <sgruszka@redhat.com>,
	"herbert.xu@redhat.com" <herbert.xu@redhat.com>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	Ramkrishna Vepa <Ramkrishna.Vepa@exar.com>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Amerigo Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:39598 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751250Ab0FYEoe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jun 2010 00:44:34 -0400
Received: by pvg2 with SMTP id 2so677317pvg.19
        for <netdev@vger.kernel.org>; Thu, 24 Jun 2010 21:44:33 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20100622085415.5566.22523.sendpatchset@localhost.localdomain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds dynamic LRO disable support for s2io net driver,
enables LRO by default, increases the driver version number, and
corrects the name of the LRO modparm.

This is mostly Wang's patch based on Neil's initial work, heavily
modified based on Ramkrishna's suggestions.  This has been tested on
a Neterion Xframe adapter and verified via adapter LRO statistics.

Signed-off-by: Jon Mason <jon.mason@exar.com>
Signed-off-by: WANG Cong <amwang@redhat.com>
Signed-off-by: Neil Horman <nhorman@redhat.com>
Acked-by: Neil Horman <nhorman@redhat.com>
Reviewed-by: Stanislaw Gruszka <sgruszka@redhat.com>
Cc: Ramkrishna Vepa <Ramkrishna.Vepa@exar.com>

---

diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 668327c..a032d72 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -38,7 +38,7 @@
  * Tx descriptors that can be associated with each corresponding FIFO.
  * intr_type: This defines the type of interrupt. The values can be 0(INTA),
  *     2(MSI_X). Default value is '2(MSI_X)'
- * lro_enable: Specifies whether to enable Large Receive Offload (LRO) or not.
+ * lro: Specifies whether to enable Large Receive Offload (LRO) or not.
  *     Possible values '1' for enable '0' for disable. Default is '0'
  * lro_max_pkts: This parameter defines maximum number of packets can be
  *     aggregated as a single large packet
@@ -90,7 +90,7 @@
 #include "s2io.h"
 #include "s2io-regs.h"
 
-#define DRV_VERSION "2.0.26.25"
+#define DRV_VERSION "2.0.26.26"
 
 /* S2io Driver name & version. */
 static char s2io_driver_name[] = "Neterion";
@@ -496,7 +496,7 @@ S2IO_PARM_INT(rxsync_frequency, 3);
 /* Interrupt type. Values can be 0(INTA), 2(MSI_X) */
 S2IO_PARM_INT(intr_type, 2);
 /* Large receive offload feature */
-static unsigned int lro_enable;
+static unsigned int lro_enable = 1;
 module_param_named(lro, lro_enable, uint, 0);
 
 /* Max pkts to be aggregated by LRO at one time. If not specified,
@@ -795,7 +795,6 @@ static int init_shared_mem(struct s2io_nic *nic)
 		ring->rx_curr_put_info.ring_len = rx_cfg->num_rxd - 1;
 		ring->nic = nic;
 		ring->ring_no = i;
-		ring->lro = lro_enable;
 
 		blk_cnt = rx_cfg->num_rxd / (rxd_count[nic->rxd_mode] + 1);
 		/*  Allocating all the Rx blocks */
@@ -6675,6 +6674,7 @@ static u32 s2io_ethtool_op_get_tso(struct net_device *dev)
 {
 	return (dev->features & NETIF_F_TSO) != 0;
 }
+
 static int s2io_ethtool_op_set_tso(struct net_device *dev, u32 data)
 {
 	if (data)
@@ -6685,6 +6685,42 @@ static int s2io_ethtool_op_set_tso(struct net_device *dev, u32 data)
 	return 0;
 }
 
+static int s2io_ethtool_set_flags(struct net_device *dev, u32 data)
+{
+	struct s2io_nic *sp = netdev_priv(dev);
+	int rc = 0;
+	int changed = 0;
+
+	if (data & ~ETH_FLAG_LRO)
+		return -EOPNOTSUPP;
+
+	if (data & ETH_FLAG_LRO) {
+		if (lro_enable) {
+			if (!(dev->features & NETIF_F_LRO)) {
+				dev->features |= NETIF_F_LRO;
+				changed = 1;
+			}
+		} else
+			rc = -EINVAL;
+	} else if (dev->features & NETIF_F_LRO) {
+		dev->features &= ~NETIF_F_LRO;
+		changed = 1;
+	}
+
+	if (changed && netif_running(dev)) {
+		s2io_stop_all_tx_queue(sp);
+		s2io_card_down(sp);
+		sp->lro = !!(dev->features & NETIF_F_LRO);
+		rc = s2io_card_up(sp);
+		if (rc)
+			s2io_reset(sp);
+		else
+			s2io_start_all_tx_queue(sp);
+	}
+
+	return rc;
+}
+
 static const struct ethtool_ops netdev_ethtool_ops = {
 	.get_settings = s2io_ethtool_gset,
 	.set_settings = s2io_ethtool_sset,
@@ -6701,6 +6737,8 @@ static const struct ethtool_ops netdev_ethtool_ops = {
 	.get_rx_csum = s2io_ethtool_get_rx_csum,
 	.set_rx_csum = s2io_ethtool_set_rx_csum,
 	.set_tx_csum = s2io_ethtool_op_set_tx_csum,
+	.set_flags = s2io_ethtool_set_flags,
+	.get_flags = ethtool_op_get_flags,
 	.set_sg = ethtool_op_set_sg,
 	.get_tso = s2io_ethtool_op_get_tso,
 	.set_tso = s2io_ethtool_op_set_tso,
@@ -7229,6 +7267,7 @@ static int s2io_card_up(struct s2io_nic *sp)
 		struct ring_info *ring = &mac_control->rings[i];
 
 		ring->mtu = dev->mtu;
+		ring->lro = sp->lro;
 		ret = fill_rx_buffers(sp, ring, 1);
 		if (ret) {
 			DBG_PRINT(ERR_DBG, "%s: Out of memory in Open\n",
@@ -7974,7 +8013,8 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 	dev->netdev_ops = &s2io_netdev_ops;
 	SET_ETHTOOL_OPS(dev, &netdev_ethtool_ops);
 	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
-
+	if (lro_enable)
+		dev->features |= NETIF_F_LRO;
 	dev->features |= NETIF_F_SG | NETIF_F_IP_CSUM;
 	if (sp->high_dma_flag == true)
 		dev->features |= NETIF_F_HIGHDMA;
