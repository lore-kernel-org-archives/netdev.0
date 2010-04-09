From: "Choi, David" <David.Choi@Micrel.Com>
Subject: [PATCH linux-2.6.34-rc3] drivers/net: ks8851 MLL ethernet network driver
Date: Fri, 9 Apr 2010 10:50:27 -0700
Message-ID: <C43529A246480145B0A6D0234BDB0F0D02129D@MELANITE.micrel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from p01c12o144.mxlogic.net ([208.65.145.67]:43939 "EHLO
	p01c12o144.mxlogic.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753359Ab0DISBJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Apr 2010 14:01:09 -0400
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello

>From : David J. Choi (david.choi@micrel.com)
Summary :
 1.Support big Endian mode
 2.Receive interrupt consolidation: a receive interrupt happens when 2 consecutive packets are
   received continuously within a certain period of time in order to enhance performance.
 3.Change a register name, which was caused by mis-type.
 4.Disable the device interrupt by controlling a device register, instead of host register
   ,when packet transmit starts.
 5.Display network interface name after the device registration for maintenance purpose.
 6.Fix to unmap of memory when the device is removed.

Signed-off-by : David J. Choi

---
--- linux-2.6.34-rc3/drivers/net/ks8851_mll.c.orig	2010-04-09 10:23:35.000000000 -0700
+++ linux-2.6.34-rc3/drivers/net/ks8851_mll.c	2010-04-09 10:23:23.000000000 -0700
@@ -41,6 +41,7 @@ static u8 KS_DEFAULT_MAC_ADDRESS[] = { 0
 #define RX_BUF_SIZE			2000
 
 #define KS_CCR				0x08
+#define CCR_ENDIAN			(1 << 10)
 #define CCR_EEPROM			(1 << 9)
 #define CCR_SPI				(1 << 8)
 #define CCR_8BIT			(1 << 7)
@@ -143,7 +144,7 @@ static u8 KS_DEFAULT_MAC_ADDRESS[] = { 0
 #define RXCR1_RXAE			(1 << 4)
 #define RXCR1_RXINVF			(1 << 1)
 #define RXCR1_RXE			(1 << 0)
-#define RXCR1_FILTER_MASK    		(RXCR1_RXINVF | RXCR1_RXAE | \
+#define RXCR1_FILTER_MASK		(RXCR1_RXINVF | RXCR1_RXAE | \
 					 RXCR1_RXMAFMA | RXCR1_RXPAFMA)
 
 #define KS_RXCR2			0x76
@@ -199,7 +200,7 @@ static u8 KS_DEFAULT_MAC_ADDRESS[] = { 0
 #define RXQCR_ADRFE			(1 << 4)
 #define RXQCR_SDA			(1 << 3)
 #define RXQCR_RRXEF			(1 << 0)
-#define RXQCR_CMD_CNTL                	(RXQCR_RXFCTE|RXQCR_ADRFE)
+#define RXQCR_CMD_CNTL			(RXQCR_RXFCTE|RXQCR_ADRFE|RXQCR_RXDTTE)
 
 #define KS_TXFDPR			0x84
 #define TXFDPR_TXFPAI			(1 << 14)
@@ -208,6 +209,7 @@ static u8 KS_DEFAULT_MAC_ADDRESS[] = { 0
 
 #define KS_RXFDPR			0x86
 #define RXFDPR_RXFPAI			(1 << 14)
+#define RXFDPR_ENDIAN			(1 << 11)
 
 #define KS_RXDTTR			0x8C
 #define KS_RXDBCTR			0x8E
@@ -229,7 +231,7 @@ static u8 KS_DEFAULT_MAC_ADDRESS[] = { 0
 #define IRQ_DEDI			(1 << 0)
 
 #define KS_RXFCTR			0x9C
-#define RXFCTR_THRESHOLD_MASK     	0x00FF
+#define RXFCTR_THRESHOLD_MASK		0x00FF
 
 #define KS_RXFC				0x9D
 #define RXFCTR_RXFC_MASK		(0xff << 8)
@@ -265,7 +267,7 @@ static u8 KS_DEFAULT_MAC_ADDRESS[] = { 0
 #define IACR_ADDR_SHIFT			(0)
 
 #define KS_IADLR			0xD0
-#define KS_IAHDR			0xD2
+#define KS_IADHR			0xD2
 
 #define KS_PMECR			0xD4
 #define PMECR_PME_DELAY			(1 << 14)
@@ -361,6 +363,10 @@ static u8 KS_DEFAULT_MAC_ADDRESS[] = { 0
 #define MAX_MCAST_LST			32
 #define HW_MCAST_SIZE			8
 #define MAC_ADDR_LEN			6
+/* count to consolidate rx packets */
+#define	CONSOLIDATE_INT_FIRE_CNT 2
+/* nsec to trigger an interrupt */
+#define	CONSOLIDATE_INT_FIRE_DUR 100
 
 /**
  * union ks_tx_hdr - tx header data
@@ -378,34 +384,34 @@ union ks_tx_hdr {
 
 /**
  * struct ks_net - KS8851 driver private data
- * @net_device 	: The network device we're bound to
+ * @net_device	: The network device we're bound to
  * @hw_addr	: start address of data register.
  * @hw_addr_cmd	: start address of command register.
- * @txh    	: temporaly buffer to save status/length.
+ * @txh		: temporaly buffer to save status/length.
  * @lock	: Lock to ensure that the device is not accessed when busy.
  * @pdev	: Pointer to platform device.
  * @mii		: The MII state information for the mii calls.
- * @frame_head_info   	: frame header information for multi-pkt rx.
+ * @frame_head_info	: frame header information for multi-pkt rx.
  * @statelock	: Lock on this structure for tx list.
  * @msg_enable	: The message flags controlling driver output (see ethtool).
- * @frame_cnt  	: number of frames received.
- * @bus_width  	: i/o bus width.
- * @irq    	: irq number assigned to this device.
+ * @frame_cnt	: number of frames received.
+ * @bus_width	: i/o bus width.
+ * @irq		: irq number assigned to this device.
  * @rc_rxqcr	: Cached copy of KS_RXQCR.
  * @rc_txcr	: Cached copy of KS_TXCR.
  * @rc_ier	: Cached copy of KS_IER.
- * @sharedbus  	: Multipex(addr and data bus) mode indicator.
+ * @sharedbus	: Multipex(addr and data bus) mode indicator.
  * @cmd_reg_cache	: command register cached.
  * @cmd_reg_cache_int	: command register cached. Used in the irq handler.
  * @promiscuous	: promiscuous mode indicator.
- * @all_mcast  	: mutlicast indicator.
- * @mcast_lst_size   	: size of multicast list.
- * @mcast_lst    	: multicast list.
- * @mcast_bits    	: multicast enabed.
- * @mac_addr   		: MAC address assigned to this device.
- * @fid    		: frame id.
- * @extra_byte    	: number of extra byte prepended rx pkt.
- * @enabled    		: indicator this device works.
+ * @all_mcast	: mutlicast indicator.
+ * @mcast_lst_size	: size of multicast list.
+ * @mcast_lst		: multicast list.
+ * @mcast_bits		: multicast enabed.
+ * @mac_addr		: MAC address assigned to this device.
+ * @fid			: frame id.
+ * @extra_byte		: number of extra byte prepended rx pkt.
+ * @enabled		: indicator this device works.
  *
  * The @lock ensures that the chip is protected when certain operations are
  * in progress. When the read or write packet transfer is in progress, most
@@ -426,10 +432,10 @@ struct type_frame_head {
 
 struct ks_net {
 	struct net_device	*netdev;
-	void __iomem    	*hw_addr;
-	void __iomem    	*hw_addr_cmd;
+	void __iomem		*hw_addr;
+	void __iomem		*hw_addr_cmd;
 	union ks_tx_hdr		txh ____cacheline_aligned;
-	struct mutex      	lock; /* spinlock to be interrupt safe */
+	struct mutex		lock; /* spinlock to be interrupt safe */
 	struct platform_device *pdev;
 	struct mii_if_info	mii;
 	struct type_frame_head	*frame_head_info;
@@ -437,7 +443,7 @@ struct ks_net {
 	u32			msg_enable;
 	u32			frame_cnt;
 	int			bus_width;
-	int             	irq;
+	int			irq;
 
 	u16			rc_rxqcr;
 	u16			rc_txcr;
@@ -463,10 +469,27 @@ static int msg_enable;
 #define ks_dbg(_ks, _msg...) dev_dbg(&(_ks)->pdev->dev, _msg)
 #define ks_err(_ks, _msg...) dev_err(&(_ks)->pdev->dev, _msg)
 
+#if defined(__LITTLE_ENDIAN)
 #define BE3             0x8000      /* Byte Enable 3 */
 #define BE2             0x4000      /* Byte Enable 2 */
 #define BE1             0x2000      /* Byte Enable 1 */
 #define BE0             0x1000      /* Byte Enable 0 */
+#define MAKE_ADDR16(offset)	((u16)offset | ((BE1 | BE0) << (offset & 0x02)))
+#define MAKE_ADDR8(offset, shift_bit)	((u16)offset | (BE0 << shift_bit))
+#define	MAKE_SHIFT_INDEX(offset)	((offset & 1) << 3)
+#define	MAKE_SHIFT_VALUE(offset)	((offset & 1) << 8)
+#define	CONV_MAC_VALUE(u)	(((u & 0xFF) << 8) | ((u >> 8) & 0xFF))
+#else
+#define BE3             0x1000      /* Byte Enable 3 */
+#define BE2             0x2000      /* Byte Enable 2 */
+#define BE1             0x4000      /* Byte Enable 1 */
+#define BE0             0x8000      /* Byte Enable 0 */
+#define MAKE_ADDR16(offset)	((u16)offset | ((BE1 | BE0) >> (offset & 0x02)))
+#define MAKE_ADDR8(offset, shift_bit)	((u16)offset | (BE0 >> shift_bit))
+#define	MAKE_SHIFT_INDEX(offset)	(!(offset & 1) << 3)
+#define	MAKE_SHIFT_VALUE(offset)	(!(offset & 1) << 8)
+#define	CONV_MAC_VALUE(u)		u
+#endif
 
 /**
  * register read/write calls.
@@ -487,8 +510,8 @@ static u8 ks_rdreg8(struct ks_net *ks, i
 {
 	u16 data;
 	u8 shift_bit = offset & 0x03;
-	u8 shift_data = (offset & 1) << 3;
-	ks->cmd_reg_cache = (u16) offset | (u16)(BE0 << shift_bit);
+	u8 shift_data = MAKE_SHIFT_VALUE(offset);
+	ks->cmd_reg_cache = MAKE_ADDR8(offset, shift_bit);
 	iowrite16(ks->cmd_reg_cache, ks->hw_addr_cmd);
 	data  = ioread16(ks->hw_addr);
 	return (u8)(data >> shift_data);
@@ -504,7 +527,7 @@ static u8 ks_rdreg8(struct ks_net *ks, i
 
 static u16 ks_rdreg16(struct ks_net *ks, int offset)
 {
-	ks->cmd_reg_cache = (u16)offset | ((BE1 | BE0) << (offset & 0x02));
+	ks->cmd_reg_cache = MAKE_ADDR16(offset);
 	iowrite16(ks->cmd_reg_cache, ks->hw_addr_cmd);
 	return ioread16(ks->hw_addr);
 }
@@ -519,8 +542,8 @@ static u16 ks_rdreg16(struct ks_net *ks,
 static void ks_wrreg8(struct ks_net *ks, int offset, u8 value)
 {
 	u8  shift_bit = (offset & 0x03);
-	u16 value_write = (u16)(value << ((offset & 1) << 3));
-	ks->cmd_reg_cache = (u16)offset | (BE0 << shift_bit);
+	u16 value_write = (u16)(value << (MAKE_SHIFT_INDEX(offset)));
+	ks->cmd_reg_cache = MAKE_ADDR8(offset, shift_bit);
 	iowrite16(ks->cmd_reg_cache, ks->hw_addr_cmd);
 	iowrite16(value_write, ks->hw_addr);
 }
@@ -535,7 +558,7 @@ static void ks_wrreg8(struct ks_net *ks,
 
 static void ks_wrreg16(struct ks_net *ks, int offset, u16 value)
 {
-	ks->cmd_reg_cache = (u16)offset | ((BE1 | BE0) << (offset & 0x02));
+	ks->cmd_reg_cache = MAKE_ADDR16(offset);
 	iowrite16(ks->cmd_reg_cache, ks->hw_addr_cmd);
 	iowrite16(value, ks->hw_addr);
 }
@@ -571,6 +594,9 @@ static inline void ks_outblk(struct ks_n
 static void ks_disable_int(struct ks_net *ks)
 {
 	ks_wrreg16(ks, KS_IER, 0x0000);
+	/* guarantee that device interrupt is disabled. */
+	ks_rdreg16(ks, KS_IER);
+
 }  /* ks_disable_int */
 
 static void ks_enable_int(struct ks_net *ks)
@@ -603,7 +629,7 @@ static inline void ks_save_cmd_reg(struc
 
 /**
  * ks_restore_cmd_reg - restore the command register from the cache and
- * 	write to hardware register.
+ * write to hardware register.
  * @ks: The chip information
  *
  */
@@ -639,8 +665,10 @@ static void ks_set_powermode(struct ks_n
  * ks_read_config - read chip configuration of bus width.
  * @ks: The chip information
  *
+ * When Endianness does not match between hardware and softwae, return false.
+ *
  */
-static void ks_read_config(struct ks_net *ks)
+static bool ks_read_config(struct ks_net *ks)
 {
 	u16 reg_data = 0;
 
@@ -648,6 +676,17 @@ static void ks_read_config(struct ks_net
 	reg_data = ks_rdreg8(ks, KS_CCR) & 0x00FF;
 	reg_data |= ks_rdreg8(ks, KS_CCR+1) << 8;
 
+#if defined(__LITTLE_ENDIAN)
+	if (!reg_data & CCR_ENDIAN) {
+		printk(KERN_ERR "%s: Endian mode error\n", __func__);
+		return false;
+	}
+#else
+	if (reg_data & CCR_ENDIAN) {
+		printk(KERN_ERR "%s: Endian mode error\n", __func__);
+		return false;
+	}
+#endif
 	/* addr/data bus are multiplexed */
 	ks->sharedbus = (reg_data & CCR_SHARED) == CCR_SHARED;
 
@@ -665,6 +704,7 @@ static void ks_read_config(struct ks_net
 		ks->bus_width = ENUM_BUS_32BIT;
 		ks->extra_byte = 4;
 	}
+	return true;
 }
 
 /**
@@ -809,7 +849,7 @@ static void ks_rcv(struct ks_net *ks, st
 			skb->protocol = eth_type_trans(skb, netdev);
 			netif_rx(skb);
 		} else {
-			printk(KERN_ERR "%s: err:skb alloc\n", __func__);
+			printk(KERN_ERR "err:skb alloc or frame\n");
 			ks_wrreg16(ks, KS_RXQCR, (ks->rc_rxqcr | RXQCR_RRXEF));
 			if (skb)
 				dev_kfree_skb_irq(skb);
@@ -985,9 +1025,13 @@ static int ks_net_stop(struct net_device
 static void ks_write_qmu(struct ks_net *ks, u8 *pdata, u16 len)
 {
 	/* start header at txb[0] to align txw entries */
+#if defined(__LITTLE_ENDIAN)
 	ks->txh.txw[0] = 0;
 	ks->txh.txw[1] = cpu_to_le16(len);
-
+#else
+	ks->txh.txw[0] = 0;
+	ks->txh.txw[1] = cpu_to_be16(len);
+#endif
 	/* 1. set sudo-DMA mode */
 	ks_wrreg8(ks, KS_RXQCR, (ks->rc_rxqcr | RXQCR_SDA) & 0xff);
 	/* 2. write status/lenth info */
@@ -1017,7 +1061,6 @@ static int ks_start_xmit(struct sk_buff 
 	int retv = NETDEV_TX_OK;
 	struct ks_net *ks = netdev_priv(netdev);
 
-	disable_irq(netdev->irq);
 	ks_disable_int(ks);
 	spin_lock(&ks->statelock);
 
@@ -1032,7 +1075,6 @@ static int ks_start_xmit(struct sk_buff 
 		retv = NETDEV_TX_BUSY;
 	spin_unlock(&ks->statelock);
 	ks_enable_int(ks);
-	enable_irq(netdev->irq);
 	return retv;
 }
 
@@ -1224,20 +1266,16 @@ static void ks_set_rx_mode(struct net_de
 static void ks_set_mac(struct ks_net *ks, u8 *data)
 {
 	u16 *pw = (u16 *)data;
-	u16 w, u;
+	u16 w;
 
 	ks_stop_rx(ks);  /* Stop receiving for reconfiguration */
-
-	u = *pw++;
-	w = ((u & 0xFF) << 8) | ((u >> 8) & 0xFF);
+	w = CONV_MAC_VALUE(*pw);
 	ks_wrreg16(ks, KS_MARH, w);
 
-	u = *pw++;
-	w = ((u & 0xFF) << 8) | ((u >> 8) & 0xFF);
+	w = CONV_MAC_VALUE(*(pw+1));
 	ks_wrreg16(ks, KS_MARM, w);
 
-	u = *pw;
-	w = ((u & 0xFF) << 8) | ((u >> 8) & 0xFF);
+	w = CONV_MAC_VALUE(*(pw+2));
 	ks_wrreg16(ks, KS_MARL, w);
 
 	memcpy(ks->mac_addr, data, 6);
@@ -1461,8 +1499,10 @@ static void ks_setup(struct ks_net *ks)
 	/* Setup Receive Frame Data Pointer Auto-Increment */
 	ks_wrreg16(ks, KS_RXFDPR, RXFDPR_RXFPAI);
 
-	/* Setup Receive Frame Threshold - 1 frame (RXFCTFC) */
-	ks_wrreg16(ks, KS_RXFCTR, 1 & RXFCTR_THRESHOLD_MASK);
+
+	/* Setup Receive Frame Threshold */
+	ks_wrreg16(ks, KS_RXFCTR, CONSOLIDATE_INT_FIRE_CNT);
+	ks_wrreg16(ks, KS_RXDTTR, CONSOLIDATE_INT_FIRE_DUR);
 
 	/* Setup RxQ Command Control (RXQCR) */
 	ks->rc_rxqcr = RXQCR_CMD_CNTL;
@@ -1585,7 +1625,19 @@ static int __devinit ks8851_probe(struct
 	ks->msg_enable = netif_msg_init(msg_enable, (NETIF_MSG_DRV |
 						     NETIF_MSG_PROBE |
 						     NETIF_MSG_LINK));
-	ks_read_config(ks);
+	/* set endian mode, which is write-only */
+	data = ks_rdreg16(ks, KS_RXFDPR);
+#if defined(__LITTLE_ENDIAN)
+	data &= ~RXFDPR_ENDIAN;
+#else
+	data |= RXFDPR_ENDIAN;
+#endif
+	ks_wrreg16(ks, KS_RXFDPR, data);
+
+	if (!ks_read_config(ks)) {
+		err = -ENODEV;
+		goto err_register;
+	}
 
 	/* simple check for a valid chip being connected to the bus */
 	if ((ks_rdreg16(ks, KS_CIDER) & ~CIDER_REV_MASK) != CIDER_ID) {
@@ -1604,6 +1656,7 @@ static int __devinit ks8851_probe(struct
 	if (err)
 		goto err_register;
 
+	printk(KERN_INFO "Network Interface of ks8851: %s\n", netdev->name);
 	platform_set_drvdata(pdev, netdev);
 
 	ks_soft_reset(ks, GRR_GSR);
@@ -1655,6 +1708,7 @@ static int __devexit ks8851_remove(struc
 	kfree(ks->frame_head_info);
 	unregister_netdev(netdev);
 	iounmap(ks->hw_addr);
+	iounmap(ks->hw_addr_cmd);
 	free_netdev(netdev);
 	release_mem_region(iomem->start, resource_size(iomem));
 	platform_set_drvdata(pdev, NULL);

---
