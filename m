From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 2.6.8.1-mm4 10/11] r8169: Rx checksum support
Date: Tue, 24 Aug 2004 00:57:13 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040823225713.GJ20726@electric-eye.fr.zoreil.com>
References: <20040823224100.GA14680@electric-eye.fr.zoreil.com> <20040823224425.GA20726@electric-eye.fr.zoreil.com> <20040823224548.GB20726@electric-eye.fr.zoreil.com> <20040823224706.GC20726@electric-eye.fr.zoreil.com> <20040823224813.GD20726@electric-eye.fr.zoreil.com> <20040823224927.GE20726@electric-eye.fr.zoreil.com> <20040823225120.GF20726@electric-eye.fr.zoreil.com> <20040823225335.GG20726@electric-eye.fr.zoreil.com> <20040823225505.GH20726@electric-eye.fr.zoreil.com> <20040823225620.GI20726@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Content-Disposition: inline
In-Reply-To: <20040823225620.GI20726@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Rx IP checksumming support.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

diff -puN drivers/net/r8169.c~r8169-100 drivers/net/r8169.c
--- linux-2.6.8.1/drivers/net/r8169.c~r8169-100	2004-08-23 23:30:08.000000000 +0200
+++ linux-2.6.8.1-fr/drivers/net/r8169.c	2004-08-23 23:30:08.000000000 +0200
@@ -320,6 +320,19 @@ enum _DescStatusBit {
 	IPCS		= (1 << 18), /* Calculate IP checksum */
 	UDPCS		= (1 << 17), /* Calculate UDP/IP checksum */
 	TCPCS		= (1 << 16), /* Calculate TCP/IP checksum */
+
+	/* Rx private */
+	PID1		= (1 << 18), /* Protocol ID bit 1/2 */
+	PID0		= (1 << 17), /* Protocol ID bit 2/2 */
+
+#define RxProtoUDP	(PID1)
+#define RxProtoTCP	(PID0)
+#define RxProtoIP	(PID1 | PID0)
+#define RxProtoMask	RxProtoIP
+
+	IPFail		= (1 << 16), /* IP checksum failed */
+	UDPFail		= (1 << 15), /* UDP/IP checksum failed */
+	TCPFail		= (1 << 14), /* TCP/IP checksum failed */
 };
 
 #define RsvdMask	0x3fffc000
@@ -623,6 +636,34 @@ static int rtl8169_set_settings(struct n
 	return ret;
 }
 
+static u32 rtl8169_get_rx_csum(struct net_device *dev)
+{
+	struct rtl8169_private *tp = netdev_priv(dev);
+
+	return !!(tp->cp_cmd & RxChkSum);
+}
+
+static int rtl8169_set_rx_csum(struct net_device *dev,  u32 data)
+{
+	struct rtl8169_private *tp = netdev_priv(dev);
+	void *ioaddr = tp->mmio_addr;
+	unsigned long flags;
+
+	spin_lock_irqsave(&tp->lock, flags);
+
+	if (data)
+		tp->cp_cmd |= RxChkSum;
+	else
+		tp->cp_cmd &= ~RxChkSum;
+
+	RTL_W16(CPlusCmd, tp->cp_cmd);
+	RTL_R16(CPlusCmd);
+
+	spin_unlock_irqrestore(&tp->lock, flags);
+
+	return 0;
+}
+
 static void rtl8169_gset_tbi(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
@@ -716,6 +757,8 @@ static struct ethtool_ops rtl8169_ethtoo
 	.get_link		= ethtool_op_get_link,
 	.get_settings		= rtl8169_get_settings,
 	.set_settings		= rtl8169_set_settings,
+	.get_rx_csum		= rtl8169_get_rx_csum,
+	.set_rx_csum		= rtl8169_set_rx_csum,
 	.get_tx_csum		= ethtool_op_get_tx_csum,
 	.set_tx_csum		= ethtool_op_set_tx_csum,
 	.get_sg			= ethtool_op_get_sg,
@@ -1746,6 +1789,19 @@ rtl8169_tx_interrupt(struct net_device *
 	}
 }
 
+static inline void rtl8169_rx_csum(struct sk_buff *skb, struct RxDesc *desc)
+{
+	u32 opts1 = desc->opts1;
+	u32 status = opts1 & RxProtoMask;
+
+	if (((status == RxProtoTCP) && !(opts1 & TCPFail)) ||
+	    ((status == RxProtoUDP) && !(opts1 & UDPFail)) ||
+	    ((status == RxProtoIP) && !(opts1 & IPFail)))
+		skb->ip_summed = CHECKSUM_UNNECESSARY;
+	else
+		skb->ip_summed = CHECKSUM_NONE;
+}
+
 static inline int rtl8169_try_rx_copy(struct sk_buff **sk_buff, int pkt_size,
 				      struct RxDesc *desc, int rx_buf_sz)
 {
@@ -1804,7 +1860,8 @@ rtl8169_rx_interrupt(struct net_device *
 			void (*pci_action)(struct pci_dev *, dma_addr_t,
 				size_t, int) = pci_dma_sync_single_for_device;
 
-
+			rtl8169_rx_csum(skb, desc);
+			
 			pci_dma_sync_single_for_cpu(tp->pci_dev,
 				le64_to_cpu(desc->addr), tp->rx_buf_sz,
 				PCI_DMA_FROMDEVICE);

_
