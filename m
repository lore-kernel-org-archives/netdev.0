From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 2.6] 2.6.0-test11 - more rtl8169
Date: Tue, 2 Dec 2003 01:06:49 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031202010649.A27879@electric-eye.fr.zoreil.com>
References: <1070212415.1607.17.camel@oxygenium> <20031201020453.A16405@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="Kj7319i9nmIyA2yE"
Cc: =?unknown-8bit?Q?Fernando_Alencar_Mar=F3stica?= <famarost@unimep.br>,
        Brad House <brad@mcve.com>, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20031201020453.A16405@electric-eye.fr.zoreil.com>; from romieu@fr.zoreil.com on Mon, Dec 01, 2003 at 02:04:53AM +0100
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--Kj7319i9nmIyA2yE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Francois Romieu <romieu@fr.zoreil.com> :
[...]
> Btw, there is a flaw in r8169-dma-api-rx-buffers.patch so don't bother
> testing it. I'll do it again tomorrow.

Attached patch should fix it.

Executive summary:

o Pure 2.6.0-test11:

Get:
http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.0-test11/r8169-blob.tar.bz2 
debuntarzipe and apply/compile/test in following order:
r8169-dma-api-tx.patch
r8169-dma-api-rx-buffers.patch       <-+ Do not test these two patches
r8169-dma-api-rx-buffers-ahum.patch  <-+ separately
r8169-start-xmit-fixes.patch
r8169-dma-api-tx-buffers.patch
r8169-rx_copybreak.patch
r8169-mac-phy-version.patch
r8169-init_one.patch
r8169-timer.patch
r8169-hw_start.patch
r8169-missing-tx-stats.patch
r8169-intr_mask.patch
r8169-suspend.patch

The same directory contains each patch alone as well.

o 2.6.0-test11 + 2.6.0-test9-bk25-netdrvr-exp1

Get:
http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.0-test11-netdrv/r8169-blob.tar.bz2 
Same thing as above with:
r8169-mac-phy-version.patch
r8169-init_one.patch
r8169-timer.patch
r8169-hw_start.patch
r8169-missing-tx-stats.patch
r8169-intr_mask.patch
r8169-suspend.patch
r8169-dma-api-rx-buffers-ahum.patch

Applying r8169-dma-api-rx-buffers-ahum.patch before
r8169-mac-phy-version.patch generates a few offsets but works as well.

--
Ueimor

--Kj7319i9nmIyA2yE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="r8169-dma-api-rx-buffers-ahum.patch"


Brown paper bag time: the Rx descriptors are contiguous and EORbit only
marks the last descriptor in the array. OWNbit implicitly marks the end
of the Rx descriptors segment which is owned by the nic.


 drivers/net/r8169.c |   20 ++++++--------------
 1 files changed, 6 insertions(+), 14 deletions(-)

diff -puN drivers/net/r8169.c~r8169-dma-api-rx-buffers-ahum drivers/net/r8169.c
--- linux-2.6.0-test11/drivers/net/r8169.c~r8169-dma-api-rx-buffers-ahum	2003-12-02 00:22:41.000000000 +0100
+++ linux-2.6.0-test11-fr/drivers/net/r8169.c	2003-12-02 00:22:41.000000000 +0100
@@ -283,6 +283,8 @@ enum _DescStatusBit {
 	LSbit = 0x10000000,
 };
 
+#define RsvdMask	0x3fffc000
+
 struct TxDesc {
 	u32 status;
 	u32 vlan_tag;
@@ -1121,7 +1123,7 @@ rtl8169_hw_start(struct net_device *dev)
 static inline void rtl8169_make_unusable_by_asic(struct RxDesc *desc)
 {
 	desc->buf_addr = 0xdeadbeef;
-	desc->status = EORbit; 
+	desc->status &= ~(OWNbit | RsvdMask);
 }
 
 static void rtl8169_free_rx_skb(struct pci_dev *pdev, struct sk_buff **sk_buff,
@@ -1141,7 +1143,7 @@ static inline void rtl8169_return_to_asi
 static inline void rtl8169_give_to_asic(struct RxDesc *desc, dma_addr_t mapping)
 {
 	desc->buf_addr = mapping;
-	desc->status = OWNbit + RX_BUF_SIZE;
+	desc->status |= OWNbit + RX_BUF_SIZE;
 }
 
 static int rtl8169_alloc_rx_skb(struct pci_dev *pdev, struct net_device *dev,
@@ -1209,11 +1211,6 @@ static inline void rtl8169_mark_as_last_
 	desc->status |= EORbit;
 }
 
-static inline void rtl8169_unmark_as_last_descriptor(struct RxDesc *desc)
-{
-	desc->status &= ~EORbit;
-}
-
 static int rtl8169_init_ring(struct net_device *dev)
 {
 	struct rtl8169_private *tp = dev->priv;
@@ -1460,14 +1457,9 @@ rtl8169_rx_interrupt(struct net_device *
 	}
 
 	delta = rtl8169_rx_fill(tp, dev, tp->dirty_rx, tp->cur_rx);
-	if (delta > 0) {
-		u32 old_last = (tp->dirty_rx - 1) % NUM_RX_DESC;
-
+	if (delta > 0)
 		tp->dirty_rx += delta;
-		rtl8169_mark_as_last_descriptor(tp->RxDescArray +
-						(tp->dirty_rx - 1)%NUM_RX_DESC);
-		rtl8169_unmark_as_last_descriptor(tp->RxDescArray + old_last);
-	} else if (delta < 0)
+	else if (delta < 0)
 		printk(KERN_INFO "%s: no Rx buffer allocated\n", dev->name);
 
 	/*

_

--Kj7319i9nmIyA2yE--
