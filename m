From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 2.6.8.1-mm4 6/11] r8169: sync the names of a few bits with the 8139cp driver
Date: Tue, 24 Aug 2004 00:51:20 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040823225120.GF20726@electric-eye.fr.zoreil.com>
References: <20040823224100.GA14680@electric-eye.fr.zoreil.com> <20040823224425.GA20726@electric-eye.fr.zoreil.com> <20040823224548.GB20726@electric-eye.fr.zoreil.com> <20040823224706.GC20726@electric-eye.fr.zoreil.com> <20040823224813.GD20726@electric-eye.fr.zoreil.com> <20040823224927.GE20726@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.comr
Content-Disposition: inline
In-Reply-To: <20040823224927.GE20726@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Sync the names of the descriptor with these which are used in the 8139cp
driver. Though not exactly identical the descriptors are forward compatible.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

diff -puN drivers/net/r8169.c~r8169-060 drivers/net/r8169.c
--- linux-2.6.8.1/drivers/net/r8169.c~r8169-060	2004-08-23 23:30:01.000000000 +0200
+++ linux-2.6.8.1-fr/drivers/net/r8169.c	2004-08-23 23:30:01.000000000 +0200
@@ -308,23 +308,23 @@ enum RTL8169_register_content {
 };
 
 enum _DescStatusBit {
-	OWNbit = 0x80000000,
-	EORbit = 0x40000000,
-	FSbit = 0x20000000,
-	LSbit = 0x10000000,
+	DescOwn		= (1 << 31), /* Descriptor is owned by NIC */
+	RingEnd		= (1 << 30), /* End of descriptor ring */
+	FirstFrag	= (1 << 29), /* First segment of a packet */
+	LastFrag	= (1 << 28), /* Final segment of a packet */
 };
 
 #define RsvdMask	0x3fffc000
 
 struct TxDesc {
-	u32 status;
-	u32 vlan_tag;
+	u32 opts1;
+	u32 opts2;
 	u64 addr;
 };
 
 struct RxDesc {
-	u32 status;
-	u32 vlan_tag;
+	u32 opts1;
+	u32 opts2;
 	u64 addr;
 };
 
@@ -1381,7 +1381,7 @@ rtl8169_hw_start(struct net_device *dev)
 static inline void rtl8169_make_unusable_by_asic(struct RxDesc *desc)
 {
 	desc->addr = 0x0badbadbadbadbadull;
-	desc->status &= ~cpu_to_le32(OWNbit | RsvdMask);
+	desc->opts1 &= ~cpu_to_le32(DescOwn | RsvdMask);
 }
 
 static void rtl8169_free_rx_skb(struct rtl8169_private *tp,
@@ -1398,14 +1398,14 @@ static void rtl8169_free_rx_skb(struct r
 
 static inline void rtl8169_return_to_asic(struct RxDesc *desc, int rx_buf_sz)
 {
-	desc->status |= cpu_to_le32(OWNbit + rx_buf_sz);
+	desc->opts1 |= cpu_to_le32(DescOwn + rx_buf_sz);
 }
 
 static inline void rtl8169_give_to_asic(struct RxDesc *desc, dma_addr_t mapping,
 					int rx_buf_sz)
 {
 	desc->addr = cpu_to_le64(mapping);
-	desc->status |= cpu_to_le32(OWNbit + rx_buf_sz);
+	desc->opts1 |= cpu_to_le32(DescOwn + rx_buf_sz);
 }
 
 static int rtl8169_alloc_rx_skb(struct pci_dev *pdev, struct sk_buff **sk_buff,
@@ -1469,7 +1469,7 @@ static u32 rtl8169_rx_fill(struct rtl816
 
 static inline void rtl8169_mark_as_last_descriptor(struct RxDesc *desc)
 {
-	desc->status |= cpu_to_le32(EORbit);
+	desc->opts1 |= cpu_to_le32(RingEnd);
 }
 
 static int rtl8169_init_ring(struct net_device *dev)
@@ -1565,7 +1565,7 @@ rtl8169_start_xmit(struct sk_buff *skb, 
 		len = ETH_ZLEN;
 	}
 	
-	if (!(le32_to_cpu(tp->TxDescArray[entry].status) & OWNbit)) {
+	if (!(le32_to_cpu(tp->TxDescArray[entry].opts1) & DescOwn)) {
 		dma_addr_t mapping;
 		u32 status;
 
@@ -1576,9 +1576,9 @@ rtl8169_start_xmit(struct sk_buff *skb, 
 		tp->TxDescArray[entry].addr = cpu_to_le64(mapping);
 
 		/* anti gcc 2.95.3 bugware */
-		status = OWNbit | FSbit | LSbit | len |
-			 (EORbit * !((entry + 1) % NUM_TX_DESC));
-		tp->TxDescArray[entry].status = cpu_to_le32(status);
+		status = DescOwn | FirstFrag | LastFrag | len |
+			 (RingEnd * !((entry + 1) % NUM_TX_DESC));
+		tp->TxDescArray[entry].opts1 = cpu_to_le32(status);
 			
 		RTL_W8(TxPoll, 0x40);	//set polling bit
 
@@ -1628,8 +1628,8 @@ rtl8169_tx_interrupt(struct net_device *
 		u32 status;
 
 		rmb();
-		status = le32_to_cpu(tp->TxDescArray[entry].status);
-		if (status & OWNbit)
+		status = le32_to_cpu(tp->TxDescArray[entry].opts1);
+		if (status & DescOwn)
 			break;
 
 		/* FIXME: is it really accurate for TxErr ? */
@@ -1692,9 +1692,9 @@ rtl8169_rx_interrupt(struct net_device *
 		u32 status;
 
 		rmb();
-		status = le32_to_cpu(tp->RxDescArray[entry].status);
+		status = le32_to_cpu(tp->RxDescArray[entry].opts1);
 
-		if (status & OWNbit)
+		if (status & DescOwn)
 			break;
 		if (status & RxRES) {
 			printk(KERN_INFO "%s: Rx ERROR!!!\n", dev->name);

_
