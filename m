From: "Choi, David" <David.Choi@Micrel.Com>
Subject: RE: [PATCH v2 linux-2.6.35-rc3] ks8842 driver
Date: Fri, 9 Jul 2010 14:22:35 -0700
Message-ID: <C43529A246480145B0A6D0234BDB0F0D0212A5@MELANITE.micrel.com>
References: <C43529A246480145B0A6D0234BDB0F0D0212A4@MELANITE.micrel.com> <20100708075245.GA21371@verge.net.au> <C43529A246480145B0A6D0234BDB0F0D481D67@MELANITE.micrel.com> <20100708.214101.39178389.davem@davemloft.net> <20100709060808.GA20370@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <netdev@vger.kernel.org>, "Li, Charles" <Charles.Li@Micrel.Com>
To: "Simon Horman" <horms@verge.net.au>,
	"David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from p01c11o147.mxlogic.net ([208.65.144.70]:51580 "EHLO
	p01c11o147.mxlogic.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751241Ab0GIVWh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jul 2010 17:22:37 -0400
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I change the ks8842 driver so that the platform private data is used to pass
different parameters like selection of 16/32bit, as suggested.

---

--- linux-2.6.35-rc3/drivers/net/ks8842.c.orig	2010-07-01 16:26:50.000000000 -0700
+++ linux-2.6.35-rc3/drivers/net/ks8842.c	2010-07-09 13:27:37.000000000 -0700
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
 	struct platform_device *pdev;
@@ -191,16 +197,22 @@ static inline u32 ks8842_read32(struct k
 
 static void ks8842_reset(struct ks8842_adapter *adapter)
 {
-	/* The KS8842 goes haywire when doing softare reset
-	 * a work around in the timberdale IP is implemented to
-	 * do a hardware reset instead
-	ks8842_write16(adapter, 3, 1, REG_GRR);
-	msleep(10);
-	iowrite16(0, adapter->hw_addr + REG_GRR);
-	*/
-	iowrite16(32, adapter->hw_addr + REG_SELECT_BANK);
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
+		iowrite16(32, adapter->hw_addr + REG_SELECT_BANK);
+		iowrite32(0x1, adapter->hw_addr + REG_TIMB_RST);
+		msleep(20);
+	}
 }
 
 static void ks8842_update_link_status(struct net_device *netdev,
@@ -269,8 +281,10 @@ static void ks8842_reset_hw(struct ks884
 
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
@@ -296,13 +310,28 @@ static void ks8842_read_mac_addr(struct 
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
@@ -313,8 +342,25 @@ static void ks8842_write_mac_addr(struct
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
@@ -328,8 +374,6 @@ static int ks8842_tx_frame(struct sk_buf
 {
 	struct ks8842_adapter *adapter = netdev_priv(netdev);
 	int len = skb->len;
-	u32 *ptr = (u32 *)skb->data;
-	u32 ctrl;
 
 	dev_dbg(&adapter->pdev->dev,
 		"%s: len %u head %p data %p tail %p end %p\n",
@@ -340,17 +384,34 @@ static int ks8842_tx_frame(struct sk_buf
 	if (ks8842_tx_fifo_space(adapter) < len + 8)
 		return NETDEV_TX_BUSY;
 
-	/* the control word, enable IRQ, port 1 and the length */
-	ctrl = 0x8000 | 0x100 | (len << 16);
-	ks8842_write32(adapter, 17, ctrl, REG_QMU_DATA_LO);
-
-	netdev->stats.tx_bytes += len;
-
-	/* copy buffer */
-	while (len > 0) {
-		iowrite32(*ptr, adapter->hw_addr + REG_QMU_DATA_LO);
-		len -= sizeof(u32);
-		ptr++;
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
+
+		netdev->stats.tx_bytes += len;
+
+		/* copy buffer */
+		while (len > 0) {
+			iowrite32(*ptr, adapter->hw_addr + REG_QMU_DATA_LO);
+			len -= sizeof(u32);
+			ptr++;
+		}
 	}
 
 	/* enqueue packet */
@@ -364,13 +425,23 @@ static int ks8842_tx_frame(struct sk_buf
 static void ks8842_rx_frame(struct net_device *netdev,
 	struct ks8842_adapter *adapter)
 {
-	u32 status = ks8842_read32(adapter, 17, REG_QMU_DATA_LO);
-	int len = (status >> 16) & 0x7ff;
-
-	status &= 0xffff;
-
-	dev_dbg(&adapter->pdev->dev, "%s - rx_data: status: %x\n",
-		__func__, status);
+	u16 status16;
+	u32 status;
+	int len;
+
+	if (adapter->conf_flags & KS884X_16BIT) {
+		status16 = ks8842_read16(adapter, 17, REG_QMU_DATA_LO);
+		len  = (int)ks8842_read16(adapter, 17, REG_QMU_DATA_HI);
+		len &= 0xffff;
+		dev_dbg(&adapter->pdev->dev, "%s - rx_data: status: %x\n",
+			__func__, status16);
+	} else {
+		status = ks8842_read32(adapter, 17, REG_QMU_DATA_LO);
+		len = (status >> 16) & 0x7ff;
+		status &= 0xffff;
+		dev_dbg(&adapter->pdev->dev, "%s - rx_data: status: %x\n",
+			__func__, status);
+	}
 
 	/* check the status */
 	if ((status & RXSR_VALID) && !(status & RXSR_ERROR)) {
@@ -379,22 +450,32 @@ static void ks8842_rx_frame(struct net_d
 		dev_dbg(&adapter->pdev->dev, "%s, got package, len: %d\n",
 			__func__, len);
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
@@ -654,6 +735,8 @@ static int __devinit ks8842_probe(struct
 
 	adapter = netdev_priv(netdev);
 	adapter->hw_addr = ioremap(iomem->start, resource_size(iomem));
+	adapter->conf_flags = iomem->flags;
+
 	if (!adapter->hw_addr)
 		goto err_ioremap;
 
--- linux-2.6.35-rc3/drivers/net/Kconfig.orig	2010-07-02 15:52:41.000000000 -0700
+++ linux-2.6.35-rc3/drivers/net/Kconfig	2010-07-09 13:33:56.000000000 -0700
@@ -1748,11 +1748,12 @@ config TLAN
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

---

-----Original Message-----
From: Simon Horman [mailto:horms@verge.net.au]
Sent: Thu 7/8/2010 11:08 PM
To: David Miller
Cc: Choi, David; netdev@vger.kernel.org; Li, Charles
Subject: Re: [PATCH linux-2.6.35-rc3] ks8842 driver
 
On Thu, Jul 08, 2010 at 09:41:01PM -0700, David Miller wrote:
> From: "Choi, David" <David.Choi@Micrel.Com>
> Date: Thu, 8 Jul 2010 12:01:51 -0700
> 
> > The original ks8842 driver is designed to work on the customized bus
> > interface based on an FPGA. This patch is intended to address the more
> > commonly used generic bus interface available on the majority of SoC in
> > the market.
> > 
> > It is unlikely that for a system to use both FPGA based and generic bus
> > interface for ks8842, I am quite certain that those 2 devices are used
> > mutual exclusively.
> 
> Like Simon, I'm not to thrilled with this approach.
> 
> Any flag bit test you'd need to add to the driver to handle both cases
> will have zero performance impact since the cost of the MMIO accesses
> will dominate such tests entirely.
> 
> Add a boolean flag bit to the driver software state, set it based upon
> some platform_device private setting, and test it in these paths to
> device what to do.
> 
> As a bonus, anyone who enables this driver at all in their build will
> test the compilation of both code paths.  And to me, that extra
> compilation testing trumps whatever arguments you may make for not
> making this support dynamic.

I was thinking more in terms of needing fewer kernels,
but yes build coverage is a big win.


