From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 2.6.35-rc3] drivers/net: ks8842 driver
Date: Tue, 13 Jul 2010 10:14:34 -0700 (PDT)
Message-ID: <20100713.101434.180417674.davem@davemloft.net>
References: <C43529A246480145B0A6D0234BDB0F0D0212A7@MELANITE.micrel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Charles.Li@Micrel.Com, horms@verge.net.au
To: David.Choi@Micrel.Com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46531
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757138Ab0GMROT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jul 2010 13:14:19 -0400
In-Reply-To: <C43529A246480145B0A6D0234BDB0F0D0212A7@MELANITE.micrel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Choi, David" <David.Choi@Micrel.Com>
Date: Tue, 13 Jul 2010 08:42:41 -0700

> From: David J. Choi <david.choi@micrel.com>
> 
> Body of the explanation: 
>    -support 16bit and 32bit bus width.
>    -add device reset for ks8842/8841 Micrel device.
>    -set 100Mbps as a default for Micrel device.
>    -set MAC address in both MAC/Switch layer with different sequence for Micrel
>     device, as mentioned in data sheet.
>    -use private data to set options both 16/32bit bus width and Micrel device/
>     Timberdale(FPGA).
>    -update Kconfig in order to put more information about ks8842 device.
> 
> Signed-off-by: David J. Choi <david.choi@micrel.com>

This patch doesn't apply to net-next-2.6 because the bank select I/O
write has been removed from the reset function, and the driver now
uses netdev_*() instead of dev_*() logging functions.

Also, your patch subject line should be more descriptive, it doesn't
say what this patch is doing, it just says "ks8842 driver", well this
driver already supports ks8842 chips just not "Micrel KS8842/8841"
ones.  So I changed the subject line to describe what this patch is
actually doing.

Also, when you want to make side-commentary to us which is not meant
to go into the commit, place it after the commit message (not before),
seperated from the commit message with "---" on a line by itself.

I fixed all of this up and applied your patch as follows:

--------------------
>From 28bd620c7a1244e59459d6293ca11f162e0a67b9 Mon Sep 17 00:00:00 2001
From: David J. Choi <david.choi@micrel.com>
Date: Tue, 13 Jul 2010 10:09:19 -0700
Subject: [PATCH] drivers/net: Add Micrel KS8841/42 support to ks8842 driver

Body of the explanation:
   -support 16bit and 32bit bus width.
   -add device reset for ks8842/8841 Micrel device.
   -set 100Mbps as a default for Micrel device.
   -set MAC address in both MAC/Switch layer with different sequence for Micrel
    device, as mentioned in data sheet.
   -use private data to set options both 16/32bit bus width and Micrel device/
    Timberdale(FPGA).
   -update Kconfig in order to put more information about ks8842 device.

Signed-off-by: David J. Choi <david.choi@micrel.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/Kconfig  |    7 +-
 drivers/net/ks8842.c |  174 +++++++++++++++++++++++++++++++++++++-------------
 2 files changed, 133 insertions(+), 48 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index f65857e..8829476 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1750,11 +1750,12 @@ config TLAN
 	  Please email feedback to <torben.mathiasen@compaq.com>.
 
 config KS8842
-	tristate "Micrel KSZ8842"
+	tristate "Micrel KSZ8841/42 with generic bus interface"
 	depends on HAS_IOMEM
 	help
-	  This platform driver is for Micrel KSZ8842 / KS8842
-	  2-port ethernet switch chip (managed, VLAN, QoS).
+	 This platform driver is for KSZ8841(1-port) / KS8842(2-port)
+	 ethernet switch chip (managed, VLAN, QoS) from Micrel or
+	 Timberdale(FPGA).
 
 config KS8851
        tristate "Micrel KS8851 SPI"
diff --git a/drivers/net/ks8842.c b/drivers/net/ks8842.c
index 0be9261..ee69dea 100644
--- a/drivers/net/ks8842.c
+++ b/drivers/net/ks8842.c
@@ -18,6 +18,7 @@
 
 /* Supports:
  * The Micrel KS8842 behind the timberdale FPGA
+ * The genuine Micrel KS8841/42 device with ISA 16/32bit bus interface
  */
 
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
@@ -114,9 +115,14 @@
 #define REG_P1CR4		0x02
 #define REG_P1SR		0x04
 
+/* flags passed by platform_device for configuration */
+#define	MICREL_KS884X		0x01	/* 0=Timeberdale(FPGA), 1=Micrel */
+#define	KS884X_16BIT		0x02	/*  1=16bit, 0=32bit */
+
 struct ks8842_adapter {
 	void __iomem	*hw_addr;
 	int		irq;
+	unsigned long	conf_flags;	/* copy of platform_device config */
 	struct tasklet_struct	tasklet;
 	spinlock_t	lock; /* spinlock to be interrupt safe */
 	struct work_struct timeout_work;
@@ -192,15 +198,21 @@ static inline u32 ks8842_read32(struct ks8842_adapter *adapter, u16 bank,
 
 static void ks8842_reset(struct ks8842_adapter *adapter)
 {
-	/* The KS8842 goes haywire when doing softare reset
-	 * a work around in the timberdale IP is implemented to
-	 * do a hardware reset instead
-	ks8842_write16(adapter, 3, 1, REG_GRR);
-	msleep(10);
-	iowrite16(0, adapter->hw_addr + REG_GRR);
-	*/
-	iowrite32(0x1, adapter->hw_addr + REG_TIMB_RST);
-	msleep(20);
+	if (adapter->conf_flags & MICREL_KS884X) {
+		ks8842_write16(adapter, 3, 1, REG_GRR);
+		msleep(10);
+		iowrite16(0, adapter->hw_addr + REG_GRR);
+	} else {
+		/* The KS8842 goes haywire when doing softare reset
+		* a work around in the timberdale IP is implemented to
+		* do a hardware reset instead
+		ks8842_write16(adapter, 3, 1, REG_GRR);
+		msleep(10);
+		iowrite16(0, adapter->hw_addr + REG_GRR);
+		*/
+		iowrite32(0x1, adapter->hw_addr + REG_TIMB_RST);
+		msleep(20);
+	}
 }
 
 static void ks8842_update_link_status(struct net_device *netdev,
@@ -269,8 +281,10 @@ static void ks8842_reset_hw(struct ks8842_adapter *adapter)
 
 	/* restart port auto-negotiation */
 	ks8842_enable_bits(adapter, 49, 1 << 13, REG_P1CR4);
-	/* only advertise 10Mbps */
-	ks8842_clear_bits(adapter, 49, 3 << 2, REG_P1CR4);
+
+	if (!(adapter->conf_flags & MICREL_KS884X))
+		/* only advertise 10Mbps */
+		ks8842_clear_bits(adapter, 49, 3 << 2, REG_P1CR4);
 
 	/* Enable the transmitter */
 	ks8842_enable_tx(adapter);
@@ -296,13 +310,28 @@ static void ks8842_read_mac_addr(struct ks8842_adapter *adapter, u8 *dest)
 	for (i = 0; i < ETH_ALEN; i++)
 		dest[ETH_ALEN - i - 1] = ks8842_read8(adapter, 2, REG_MARL + i);
 
-	/* make sure the switch port uses the same MAC as the QMU */
-	mac = ks8842_read16(adapter, 2, REG_MARL);
-	ks8842_write16(adapter, 39, mac, REG_MACAR1);
-	mac = ks8842_read16(adapter, 2, REG_MARM);
-	ks8842_write16(adapter, 39, mac, REG_MACAR2);
-	mac = ks8842_read16(adapter, 2, REG_MARH);
-	ks8842_write16(adapter, 39, mac, REG_MACAR3);
+	if (adapter->conf_flags & MICREL_KS884X) {
+		/*
+		the sequence of saving mac addr between MAC and Switch is
+		different.
+		*/
+
+		mac = ks8842_read16(adapter, 2, REG_MARL);
+		ks8842_write16(adapter, 39, mac, REG_MACAR3);
+		mac = ks8842_read16(adapter, 2, REG_MARM);
+		ks8842_write16(adapter, 39, mac, REG_MACAR2);
+		mac = ks8842_read16(adapter, 2, REG_MARH);
+		ks8842_write16(adapter, 39, mac, REG_MACAR1);
+	} else {
+
+		/* make sure the switch port uses the same MAC as the QMU */
+		mac = ks8842_read16(adapter, 2, REG_MARL);
+		ks8842_write16(adapter, 39, mac, REG_MACAR1);
+		mac = ks8842_read16(adapter, 2, REG_MARM);
+		ks8842_write16(adapter, 39, mac, REG_MACAR2);
+		mac = ks8842_read16(adapter, 2, REG_MARH);
+		ks8842_write16(adapter, 39, mac, REG_MACAR3);
+	}
 }
 
 static void ks8842_write_mac_addr(struct ks8842_adapter *adapter, u8 *mac)
@@ -313,8 +342,25 @@ static void ks8842_write_mac_addr(struct ks8842_adapter *adapter, u8 *mac)
 	spin_lock_irqsave(&adapter->lock, flags);
 	for (i = 0; i < ETH_ALEN; i++) {
 		ks8842_write8(adapter, 2, mac[ETH_ALEN - i - 1], REG_MARL + i);
-		ks8842_write8(adapter, 39, mac[ETH_ALEN - i - 1],
-			REG_MACAR1 + i);
+		if (!(adapter->conf_flags & MICREL_KS884X))
+			ks8842_write8(adapter, 39, mac[ETH_ALEN - i - 1],
+				REG_MACAR1 + i);
+	}
+
+	if (adapter->conf_flags & MICREL_KS884X) {
+		/*
+		the sequence of saving mac addr between MAC and Switch is
+		different.
+		*/
+
+		u16 mac;
+
+		mac = ks8842_read16(adapter, 2, REG_MARL);
+		ks8842_write16(adapter, 39, mac, REG_MACAR3);
+		mac = ks8842_read16(adapter, 2, REG_MARM);
+		ks8842_write16(adapter, 39, mac, REG_MACAR2);
+		mac = ks8842_read16(adapter, 2, REG_MARH);
+		ks8842_write16(adapter, 39, mac, REG_MACAR1);
 	}
 	spin_unlock_irqrestore(&adapter->lock, flags);
 }
@@ -328,8 +374,6 @@ static int ks8842_tx_frame(struct sk_buff *skb, struct net_device *netdev)
 {
 	struct ks8842_adapter *adapter = netdev_priv(netdev);
 	int len = skb->len;
-	u32 *ptr = (u32 *)skb->data;
-	u32 ctrl;
 
 	netdev_dbg(netdev, "%s: len %u head %p data %p tail %p end %p\n",
 		__func__, skb->len, skb->head, skb->data,
@@ -339,17 +383,34 @@ static int ks8842_tx_frame(struct sk_buff *skb, struct net_device *netdev)
 	if (ks8842_tx_fifo_space(adapter) < len + 8)
 		return NETDEV_TX_BUSY;
 
-	/* the control word, enable IRQ, port 1 and the length */
-	ctrl = 0x8000 | 0x100 | (len << 16);
-	ks8842_write32(adapter, 17, ctrl, REG_QMU_DATA_LO);
+	if (adapter->conf_flags & KS884X_16BIT) {
+		u16 *ptr16 = (u16 *)skb->data;
+		ks8842_write16(adapter, 17, 0x8000 | 0x100, REG_QMU_DATA_LO);
+		ks8842_write16(adapter, 17, (u16)len, REG_QMU_DATA_HI);
+		netdev->stats.tx_bytes += len;
+
+		/* copy buffer */
+		while (len > 0) {
+			iowrite16(*ptr16++, adapter->hw_addr + REG_QMU_DATA_LO);
+			iowrite16(*ptr16++, adapter->hw_addr + REG_QMU_DATA_HI);
+			len -= sizeof(u32);
+		}
+	} else {
+
+		u32 *ptr = (u32 *)skb->data;
+		u32 ctrl;
+		/* the control word, enable IRQ, port 1 and the length */
+		ctrl = 0x8000 | 0x100 | (len << 16);
+		ks8842_write32(adapter, 17, ctrl, REG_QMU_DATA_LO);
 
-	netdev->stats.tx_bytes += len;
+		netdev->stats.tx_bytes += len;
 
-	/* copy buffer */
-	while (len > 0) {
-		iowrite32(*ptr, adapter->hw_addr + REG_QMU_DATA_LO);
-		len -= sizeof(u32);
-		ptr++;
+		/* copy buffer */
+		while (len > 0) {
+			iowrite32(*ptr, adapter->hw_addr + REG_QMU_DATA_LO);
+			len -= sizeof(u32);
+			ptr++;
+		}
 	}
 
 	/* enqueue packet */
@@ -363,12 +424,23 @@ static int ks8842_tx_frame(struct sk_buff *skb, struct net_device *netdev)
 static void ks8842_rx_frame(struct net_device *netdev,
 	struct ks8842_adapter *adapter)
 {
-	u32 status = ks8842_read32(adapter, 17, REG_QMU_DATA_LO);
-	int len = (status >> 16) & 0x7ff;
+	u16 status16;
+	u32 status;
+	int len;
 
-	status &= 0xffff;
-
-	netdev_dbg(netdev, "%s - rx_data: status: %x\n", __func__, status);
+	if (adapter->conf_flags & KS884X_16BIT) {
+		status16 = ks8842_read16(adapter, 17, REG_QMU_DATA_LO);
+		len  = (int)ks8842_read16(adapter, 17, REG_QMU_DATA_HI);
+		len &= 0xffff;
+		netdev_dbg(netdev, "%s - rx_data: status: %x\n",
+			   __func__, status16);
+	} else {
+		status = ks8842_read32(adapter, 17, REG_QMU_DATA_LO);
+		len = (status >> 16) & 0x7ff;
+		status &= 0xffff;
+		netdev_dbg(netdev, "%s - rx_data: status: %x\n",
+			   __func__, status);
+	}
 
 	/* check the status */
 	if ((status & RXSR_VALID) && !(status & RXSR_ERROR)) {
@@ -376,22 +448,32 @@ static void ks8842_rx_frame(struct net_device *netdev,
 
 		netdev_dbg(netdev, "%s, got package, len: %d\n", __func__, len);
 		if (skb) {
-			u32 *data;
 
 			netdev->stats.rx_packets++;
 			netdev->stats.rx_bytes += len;
 			if (status & RXSR_MULTICAST)
 				netdev->stats.multicast++;
 
-			data = (u32 *)skb_put(skb, len);
-
-			ks8842_select_bank(adapter, 17);
-			while (len > 0) {
-				*data++ = ioread32(adapter->hw_addr +
-					REG_QMU_DATA_LO);
-				len -= sizeof(u32);
+			if (adapter->conf_flags & KS884X_16BIT) {
+				u16 *data16 = (u16 *)skb_put(skb, len);
+				ks8842_select_bank(adapter, 17);
+				while (len > 0) {
+					*data16++ = ioread16(adapter->hw_addr +
+						REG_QMU_DATA_LO);
+					*data16++ = ioread16(adapter->hw_addr +
+						REG_QMU_DATA_HI);
+					len -= sizeof(u32);
+				}
+			} else {
+				u32 *data = (u32 *)skb_put(skb, len);
+
+				ks8842_select_bank(adapter, 17);
+				while (len > 0) {
+					*data++ = ioread32(adapter->hw_addr +
+						REG_QMU_DATA_LO);
+					len -= sizeof(u32);
+				}
 			}
-
 			skb->protocol = eth_type_trans(skb, netdev);
 			netif_rx(skb);
 		} else
@@ -669,6 +751,8 @@ static int __devinit ks8842_probe(struct platform_device *pdev)
 	adapter->netdev = netdev;
 	INIT_WORK(&adapter->timeout_work, ks8842_tx_timeout_work);
 	adapter->hw_addr = ioremap(iomem->start, resource_size(iomem));
+	adapter->conf_flags = iomem->flags;
+
 	if (!adapter->hw_addr)
 		goto err_ioremap;
 
-- 
1.7.1.1

