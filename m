From: "Choi, David" <David.Choi@Micrel.Com>
Subject: [PATCH linux-2.6.35-rc3] ks8842 driver
Date: Wed, 7 Jul 2010 08:24:33 -0700
Message-ID: <C43529A246480145B0A6D0234BDB0F0D0212A4@MELANITE.micrel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Choi, David" <David.Choi@Micrel.Com>,
	"Li, Charles" <Charles.Li@Micrel.Com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from p01c12o147.mxlogic.net ([208.65.145.70]:52239 "EHLO
	p01c12o147.mxlogic.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755025Ab0GGP3w convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jul 2010 11:29:52 -0400
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To whom it may have concerned,

It seems that there are differences between Micrel ks8842 device and Timberdale FPGA based device with generic bus interface. In order to check the differences, I have sent several times but have not received any response. This patch is to support ks8841/ks8842 device from Micrel.

From: David J. Choi <david.choi@micrel.com>

Body of the explanation: 
   -support 16bit and 32bit bus width.
   -add device reset for ks8842/8841 Micrel device.
   -set 100Mbps as a default for Micrel device.
   -set MAC address in both MAC/Switch layer with different sequence for Micrel device, 
    as mentioned in data sheet.

Signed-off-by: David J. Choi <david.choi@micrel.com>

---
--- linux-2.6.35-rc3/drivers/net/ks8842.c.orig	2010-07-01 16:26:50.000000000 -0700
+++ linux-2.6.35-rc3/drivers/net/ks8842.c	2010-07-07 07:41:03.000000000 -0700
@@ -18,6 +18,7 @@
 
 /* Supports:
  * The Micrel KS8842 behind the timberdale FPGA
+ * The genuine Micrel KS8841/42 device with ISA 16/32bit bus interface
  */
 
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
@@ -191,6 +192,12 @@ static inline u32 ks8842_read32(struct k
 
 static void ks8842_reset(struct ks8842_adapter *adapter)
 {
+#ifdef CONFIG_MICREL_KS884X
+	ks8842_write16(adapter, 3, 1, REG_GRR);
+	msleep(10);
+	iowrite16(0, adapter->hw_addr + REG_GRR);
+
+#else
 	/* The KS8842 goes haywire when doing softare reset
 	 * a work around in the timberdale IP is implemented to
 	 * do a hardware reset instead
@@ -201,6 +208,7 @@ static void ks8842_reset(struct ks8842_a
 	iowrite16(32, adapter->hw_addr + REG_SELECT_BANK);
 	iowrite32(0x1, adapter->hw_addr + REG_TIMB_RST);
 	msleep(20);
+#endif
 }
 
 static void ks8842_update_link_status(struct net_device *netdev,
@@ -269,8 +277,11 @@ static void ks8842_reset_hw(struct ks884
 
 	/* restart port auto-negotiation */
 	ks8842_enable_bits(adapter, 49, 1 << 13, REG_P1CR4);
+
+#ifndef CONFIG_MICREL_KS884X
 	/* only advertise 10Mbps */
 	ks8842_clear_bits(adapter, 49, 3 << 2, REG_P1CR4);
+#endif
 
 	/* Enable the transmitter */
 	ks8842_enable_tx(adapter);
@@ -296,6 +307,20 @@ static void ks8842_read_mac_addr(struct 
 	for (i = 0; i < ETH_ALEN; i++)
 		dest[ETH_ALEN - i - 1] = ks8842_read8(adapter, 2, REG_MARL + i);
 
+#ifdef CONFIG_MICREL_KS884X
+	/*
+		the sequence of saving mac addr between MAC and Switch is
+		different.
+	*/
+
+	mac = ks8842_read16(adapter, 2, REG_MARL);
+	ks8842_write16(adapter, 39, mac, REG_MACAR3);
+	mac = ks8842_read16(adapter, 2, REG_MARM);
+	ks8842_write16(adapter, 39, mac, REG_MACAR2);
+	mac = ks8842_read16(adapter, 2, REG_MARH);
+	ks8842_write16(adapter, 39, mac, REG_MACAR1);
+#else
+
 	/* make sure the switch port uses the same MAC as the QMU */
 	mac = ks8842_read16(adapter, 2, REG_MARL);
 	ks8842_write16(adapter, 39, mac, REG_MACAR1);
@@ -303,6 +328,7 @@ static void ks8842_read_mac_addr(struct 
 	ks8842_write16(adapter, 39, mac, REG_MACAR2);
 	mac = ks8842_read16(adapter, 2, REG_MARH);
 	ks8842_write16(adapter, 39, mac, REG_MACAR3);
+#endif
 }
 
 static void ks8842_write_mac_addr(struct ks8842_adapter *adapter, u8 *mac)
@@ -313,8 +339,13 @@ static void ks8842_write_mac_addr(struct
 	spin_lock_irqsave(&adapter->lock, flags);
 	for (i = 0; i < ETH_ALEN; i++) {
 		ks8842_write8(adapter, 2, mac[ETH_ALEN - i - 1], REG_MARL + i);
+#ifdef CONFIG_MICREL_KS884X
+		ks8842_write8(adapter, 39, mac[ETH_ALEN - i - 1],
+			REG_MACAR3 + 1 - i);
+#else
 		ks8842_write8(adapter, 39, mac[ETH_ALEN - i - 1],
 			REG_MACAR1 + i);
+#endif
 	}
 	spin_unlock_irqrestore(&adapter->lock, flags);
 }
@@ -328,8 +359,12 @@ static int ks8842_tx_frame(struct sk_buf
 {
 	struct ks8842_adapter *adapter = netdev_priv(netdev);
 	int len = skb->len;
+#ifdef CONFIG_KS884X_16BIT
+	u16 *ptr16 = (u16 *)skb->data;
+#else
 	u32 *ptr = (u32 *)skb->data;
 	u32 ctrl;
+#endif
 
 	dev_dbg(&adapter->pdev->dev,
 		"%s: len %u head %p data %p tail %p end %p\n",
@@ -340,6 +375,18 @@ static int ks8842_tx_frame(struct sk_buf
 	if (ks8842_tx_fifo_space(adapter) < len + 8)
 		return NETDEV_TX_BUSY;
 
+#ifdef CONFIG_KS884X_16BIT
+	ks8842_write16(adapter, 17, 0x8000 | 0x100, REG_QMU_DATA_LO);
+	ks8842_write16(adapter, 17, (u16)len, REG_QMU_DATA_HI);
+	netdev->stats.tx_bytes += len;
+
+	/* copy buffer */
+	while (len > 0) {
+		iowrite16(*ptr16++, adapter->hw_addr + REG_QMU_DATA_LO);
+		iowrite16(*ptr16++, adapter->hw_addr + REG_QMU_DATA_HI);
+		len -= sizeof(u32);
+	}
+#else
 	/* the control word, enable IRQ, port 1 and the length */
 	ctrl = 0x8000 | 0x100 | (len << 16);
 	ks8842_write32(adapter, 17, ctrl, REG_QMU_DATA_LO);
@@ -352,6 +399,7 @@ static int ks8842_tx_frame(struct sk_buf
 		len -= sizeof(u32);
 		ptr++;
 	}
+#endif
 
 	/* enqueue packet */
 	ks8842_write16(adapter, 17, 1, REG_TXQCR);
@@ -364,10 +412,15 @@ static int ks8842_tx_frame(struct sk_buf
 static void ks8842_rx_frame(struct net_device *netdev,
 	struct ks8842_adapter *adapter)
 {
+#ifdef CONFIG_KS884X_16BIT
+	u16 status = ks8842_read16(adapter, 17, REG_QMU_DATA_LO);
+	int len  = (int)ks8842_read16(adapter, 17, REG_QMU_DATA_HI) & 0xffff;
+#else
 	u32 status = ks8842_read32(adapter, 17, REG_QMU_DATA_LO);
 	int len = (status >> 16) & 0x7ff;
 
 	status &= 0xffff;
+#endif
 
 	dev_dbg(&adapter->pdev->dev, "%s - rx_data: status: %x\n",
 		__func__, status);
@@ -379,13 +432,28 @@ static void ks8842_rx_frame(struct net_d
 		dev_dbg(&adapter->pdev->dev, "%s, got package, len: %d\n",
 			__func__, len);
 		if (skb) {
+#ifdef CONFIG_KS884X_16BIT
+			u16 *data16;
+#else
 			u32 *data;
+#endif
 
 			netdev->stats.rx_packets++;
 			netdev->stats.rx_bytes += len;
 			if (status & RXSR_MULTICAST)
 				netdev->stats.multicast++;
 
+#ifdef CONFIG_KS884X_16BIT
+			data16 = (u16 *)skb_put(skb, len);
+			ks8842_select_bank(adapter, 17);
+			while (len > 0) {
+				*data16++ = ioread16(adapter->hw_addr +
+					REG_QMU_DATA_LO);
+				*data16++ = ioread16(adapter->hw_addr +
+					REG_QMU_DATA_HI);
+				len -= sizeof(u32);
+			}
+#else
 			data = (u32 *)skb_put(skb, len);
 
 			ks8842_select_bank(adapter, 17);
@@ -397,6 +465,7 @@ static void ks8842_rx_frame(struct net_d
 
 			skb->protocol = eth_type_trans(skb, netdev);
 			netif_rx(skb);
+#endif
 		} else
 			netdev->stats.rx_dropped++;
 	} else {
--- linux-2.6.35-rc3/drivers/net/Kconfig.orig	2010-07-02 15:52:41.000000000 -0700
+++ linux-2.6.35-rc3/drivers/net/Kconfig	2010-07-07 07:45:47.000000000 -0700
@@ -1748,11 +1748,29 @@ config TLAN
 	  Please email feedback to <torben.mathiasen@compaq.com>.
 
 config KS8842
-	tristate "Micrel KSZ8842"
+	tristate "Micrel KSZ8841/42 with generic bus interface"
 	depends on HAS_IOMEM
 	help
-	  This platform driver is for Micrel KSZ8842 / KS8842
-	  2-port ethernet switch chip (managed, VLAN, QoS).
+	  This platform driver is for KSZ8841(1-port) / KS8842(2-port) 
+	  ethernet switch chip (managed, VLAN, QoS) from Micrel or
+	  Timberdale(FPGA).
+
+if KS8842
+config MICREL_KS884X
+	boolean "KSZ8841/42 device from Micrel"
+	default n
+	help
+	  Say Y to use Micrel device. Otherwise Timberdale(FPGA) device is 
+	  selected.
+
+config KS884X_16BIT
+	boolean "16bit bus width"
+	default y
+	help
+	  This option specifies 16bit or 32bit bus interface. Say Y to use 
+	  16bit bus. Otherwise 32bit bus is selected.
+
+endif # KS8842
 
 config KS8851
        tristate "Micrel KS8851 SPI"
---
