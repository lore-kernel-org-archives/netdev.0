From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 2.6] 2.6.0-test11 - rtl8169 endianness
Date: Thu, 4 Dec 2003 00:26:10 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031204002610.A25405@electric-eye.fr.zoreil.com>
References: <1070212415.1607.17.camel@oxygenium> <20031201020453.A16405@electric-eye.fr.zoreil.com> <20031202010649.A27879@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="6c2NcOVqGQ03X4Wi"
Cc: =?unknown-8bit?Q?Fernando_Alencar_Mar=F3stica?= <famarost@unimep.br>,
        Brad House <brad@mcve.com>, Matthew Gregan <kinetik@orcon.net.nz>,
        jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20031202010649.A27879@electric-eye.fr.zoreil.com>; from romieu@fr.zoreil.com on Tue, Dec 02, 2003 at 01:06:49AM +0100
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--6c2NcOVqGQ03X4Wi
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

See patch in attachment.

Francois Romieu <romieu@fr.zoreil.com> :
[...]
> o Pure 2.6.0-test11:
> 
> Get:
> http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.0-test11/r8169-blob.tar.bz2 
> debuntarzipe and apply/compile/test in following order:
> r8169-dma-api-tx.patch
[...]
> r8169-suspend.patch

Insert here.

[...]
> o 2.6.0-test11 + 2.6.0-test9-bk25-netdrvr-exp1
> 
> Get:
> http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.0-test11-netdrv/r8169-blob.tar.bz2 
> Same thing as above with:
> r8169-mac-phy-version.patch
[...]
> r8169-suspend.patch
> r8169-dma-api-rx-buffers-ahum.patch

Or here.

--
Ueimor

--6c2NcOVqGQ03X4Wi
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="r8169-endianness.patch"


Endianness update (original idea from Alexandra N. Kossovsky):
- descriptors status (bitfields enumerated as _DescStatusBit);
- address of buffers stored in Rx/Tx descriptors.



 drivers/net/r8169.c |   31 ++++++++++++++++---------------
 1 files changed, 16 insertions(+), 15 deletions(-)

diff -puN drivers/net/r8169.c~r8169-endianness drivers/net/r8169.c
--- linux-2.6.0-test11/drivers/net/r8169.c~r8169-endianness	2003-12-03 23:29:40.000000000 +0100
+++ linux-2.6.0-test11-fr/drivers/net/r8169.c	2003-12-03 23:50:54.000000000 +0100
@@ -1123,13 +1123,14 @@ rtl8169_hw_start(struct net_device *dev)
 static inline void rtl8169_make_unusable_by_asic(struct RxDesc *desc)
 {
 	desc->buf_addr = 0xdeadbeef;
-	desc->status &= ~(OWNbit | RsvdMask);
+	desc->status &= ~cpu_to_le32(OWNbit | RsvdMask);
 }
 
 static void rtl8169_free_rx_skb(struct pci_dev *pdev, struct sk_buff **sk_buff,
 				struct RxDesc *desc)
 {
-	pci_unmap_single(pdev, desc->buf_addr, RX_BUF_SIZE, PCI_DMA_FROMDEVICE);
+	pci_unmap_single(pdev, le32_to_cpu(desc->buf_addr), RX_BUF_SIZE,
+			 PCI_DMA_FROMDEVICE);
 	dev_kfree_skb(*sk_buff);
 	*sk_buff = NULL;
 	rtl8169_make_unusable_by_asic(desc);
@@ -1137,13 +1138,13 @@ static void rtl8169_free_rx_skb(struct p
 
 static inline void rtl8169_return_to_asic(struct RxDesc *desc)
 {
-	desc->status |= OWNbit + RX_BUF_SIZE;
+	desc->status |= cpu_to_le32(OWNbit + RX_BUF_SIZE);
 }
 
 static inline void rtl8169_give_to_asic(struct RxDesc *desc, dma_addr_t mapping)
 {
-	desc->buf_addr = mapping;
-	desc->status |= OWNbit + RX_BUF_SIZE;
+	desc->buf_addr = cpu_to_le32(mapping);
+	desc->status |= cpu_to_le32(OWNbit + RX_BUF_SIZE);
 }
 
 static int rtl8169_alloc_rx_skb(struct pci_dev *pdev, struct net_device *dev,
@@ -1208,7 +1209,7 @@ static u32 rtl8169_rx_fill(struct rtl816
 
 static inline void rtl8169_mark_as_last_descriptor(struct RxDesc *desc)
 {
-	desc->status |= EORbit;
+	desc->status |= cpu_to_le32(EORbit);
 }
 
 static int rtl8169_init_ring(struct net_device *dev)
@@ -1240,8 +1241,8 @@ static void rtl8169_unmap_tx_skb(struct 
 {
 	u32 len = sk_buff[0]->len;
 
-	pci_unmap_single(pdev, desc->buf_addr, len < ETH_ZLEN ? ETH_ZLEN : len,
-			 PCI_DMA_TODEVICE);
+	pci_unmap_single(pdev, le32_to_cpu(desc->buf_addr),
+			 len < ETH_ZLEN ? ETH_ZLEN : len, PCI_DMA_TODEVICE);
 	desc->buf_addr = 0x00;
 	*sk_buff = NULL;
 }
@@ -1307,17 +1308,17 @@ rtl8169_start_xmit(struct sk_buff *skb, 
 	
 	spin_lock_irq(&tp->lock);
 
-	if ((tp->TxDescArray[entry].status & OWNbit) == 0) {
+	if (!(le32_to_cpu(tp->TxDescArray[entry].status) & OWNbit)) {
 		dma_addr_t mapping;
 
 		mapping = pci_map_single(tp->pci_dev, skb->data, len,
 					 PCI_DMA_TODEVICE);
 
 		tp->Tx_skbuff[entry] = skb;
-		tp->TxDescArray[entry].buf_addr = mapping;
+		tp->TxDescArray[entry].buf_addr = cpu_to_le32(mapping);
 
-		tp->TxDescArray[entry].status = OWNbit | FSbit | LSbit | len |
-				(EORbit * !((entry + 1) % NUM_TX_DESC));
+		tp->TxDescArray[entry].status = cpu_to_le32(OWNbit | FSbit |
+			LSbit | len | (EORbit * !((entry + 1) % NUM_TX_DESC)));
 			
 		RTL_W8(TxPoll, 0x40);	//set polling bit
 
@@ -1358,7 +1359,7 @@ rtl8169_tx_interrupt(struct net_device *
 	tx_left = tp->cur_tx - dirty_tx;
 
 	while (tx_left > 0) {
-		if ((tp->TxDescArray[entry].status & OWNbit) == 0) {
+		if (!(le32_to_cpu(tp->TxDescArray[entry].status) & OWNbit)) {
 			int cur = dirty_tx % NUM_TX_DESC;
 			struct sk_buff *skb = tp->Tx_skbuff[cur];
 
@@ -1416,8 +1417,8 @@ rtl8169_rx_interrupt(struct net_device *
 
 	cur_rx = tp->cur_rx % RX_BUF_SIZE;
 
-	while ((tp->RxDescArray[cur_rx].status & OWNbit) == 0) {
-		u32 status = tp->RxDescArray[cur_rx].status;
+	while (!(le32_to_cpu(tp->RxDescArray[cur_rx].status) & OWNbit)) {
+		u32 status = le32_to_cpu(tp->RxDescArray[cur_rx].status);
 
 		if (status & RxRES) {
 			printk(KERN_INFO "%s: Rx ERROR!!!\n", dev->name);

_

--6c2NcOVqGQ03X4Wi--
