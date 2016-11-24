From: Joe Perches <joe@perches.com>
Subject: [PATCH 7/8] irda: w83977af_ir: Neaten logging
Date: Thu, 24 Nov 2016 11:10:34 -0800
Message-ID: <ad7e52fe85dd1a7129bfc0a5144f389ba9485b76.1480014088.git.joe@perches.com>
References: <cover.1480014088.git.joe@perches.com>
Cc: Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Samuel Ortiz <samuel@sortiz.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1480014088.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use more common logging style, standardize function output logging use.

Miscellanea:

o Add and use pr_fmt
o Convert printks to pr_<level>

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/irda/w83977af_ir.c | 48 ++++++++++++++++++++----------------------
 1 file changed, 23 insertions(+), 25 deletions(-)

diff --git a/drivers/net/irda/w83977af_ir.c b/drivers/net/irda/w83977af_ir.c
index 9c5b780b1d39..19b171af0e81 100644
--- a/drivers/net/irda/w83977af_ir.c
+++ b/drivers/net/irda/w83977af_ir.c
@@ -39,6 +39,8 @@
  *
  ********************************************************************/
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/types.h>
@@ -155,7 +157,7 @@ static int w83977af_open(int i, unsigned int iobase, unsigned int irq,
 
 	/* Lock the port that we need */
 	if (!request_region(iobase, CHIP_IO_EXTENT, driver_name)) {
-		pr_debug("%s(), can't get iobase of 0x%03x\n",
+		pr_debug("%s: can't get iobase of 0x%03x\n",
 			 __func__, iobase);
 		return -ENODEV;
 	}
@@ -169,8 +171,7 @@ static int w83977af_open(int i, unsigned int iobase, unsigned int irq,
 	 */
 	dev = alloc_irdadev(sizeof(struct w83977af_ir));
 	if (!dev) {
-		printk(KERN_ERR "IrDA: Can't allocate memory for "
-			"IrDA control block!\n");
+		pr_err("IrDA: Can't allocate memory for IrDA control block!\n");
 		err = -ENOMEM;
 		goto err_out;
 	}
@@ -280,8 +281,7 @@ static int w83977af_close(struct w83977af_ir *self)
 	unregister_netdev(self->netdev);
 
 	/* Release the PORT that this driver is using */
-	pr_debug("%s(), Releasing Region %03x\n",
-		 __func__, self->io.fir_base);
+	pr_debug("%s: Releasing Region %03x\n", __func__, self->io.fir_base);
 	release_region(self->io.fir_base, self->io.fir_ext);
 
 	if (self->tx_buff.head)
@@ -389,7 +389,7 @@ static int w83977af_probe(int iobase, int irq, int dma)
 			return 0;
 		} else {
 			/* Try next extented function register address */
-			pr_debug("%s(), Wrong chip version", __func__);
+			pr_debug("%s: Wrong chip version\n", __func__);
 		}
 	}
 	return -1;
@@ -425,19 +425,19 @@ static void w83977af_change_speed(struct w83977af_ir *self, __u32 speed)
 	case 115200: outb(0x01, iobase + ABLL); break;
 	case 576000:
 		ir_mode = HCR_MIR_576;
-		pr_debug("%s(), handling baud of 576000\n", __func__);
+		pr_debug("%s: handling baud of 576000\n", __func__);
 		break;
 	case 1152000:
 		ir_mode = HCR_MIR_1152;
-		pr_debug("%s(), handling baud of 1152000\n", __func__);
+		pr_debug("%s: handling baud of 1152000\n", __func__);
 		break;
 	case 4000000:
 		ir_mode = HCR_FIR;
-		pr_debug("%s(), handling baud of 4000000\n", __func__);
+		pr_debug("%s: handling baud of 4000000\n", __func__);
 		break;
 	default:
 		ir_mode = HCR_FIR;
-		pr_debug("%s(), unknown baud rate of %d\n", __func__, speed);
+		pr_debug("%s: unknown baud rate of %d\n", __func__, speed);
 		break;
 	}
 
@@ -489,8 +489,7 @@ static netdev_tx_t w83977af_hard_xmit(struct sk_buff *skb,
 
 	iobase = self->io.fir_base;
 
-	pr_debug("%s(%ld), skb->len=%d\n", __func__, jiffies,
-		 (int)skb->len);
+	pr_debug("%s: %ld, skb->len=%d\n", __func__, jiffies, (int)skb->len);
 
 	/* Lock transmit buffer */
 	netif_stop_queue(dev);
@@ -517,7 +516,7 @@ static netdev_tx_t w83977af_hard_xmit(struct sk_buff *skb,
 		self->tx_buff.len = skb->len;
 
 		mtt = irda_get_mtt(skb);
-		pr_debug("%s(%ld), mtt=%d\n", __func__, jiffies, mtt);
+		pr_debug("%s: %ld, mtt=%d\n", __func__, jiffies, mtt);
 			if (mtt > 1000)
 				mdelay(mtt / 1000);
 			else if (mtt)
@@ -554,7 +553,7 @@ static void w83977af_dma_write(struct w83977af_ir *self, int iobase)
 {
 	__u8 set;
 
-	pr_debug("%s(), len=%d\n", __func__, self->tx_buff.len);
+	pr_debug("%s: len=%d\n", __func__, self->tx_buff.len);
 
 	/* Save current set */
 	set = inb(iobase + SSR);
@@ -594,11 +593,10 @@ static int w83977af_pio_write(int iobase, __u8 *buf, int len, int fifo_size)
 
 	switch_bank(iobase, SET0);
 	if (!(inb_p(iobase + USR) & USR_TSRE)) {
-		pr_debug("%s(), warning, FIFO not empty yet!\n", __func__);
+		pr_debug("%s: warning, FIFO not empty yet!\n", __func__);
 
 		fifo_size -= 17;
-		pr_debug("%s(), %d bytes left in tx fifo\n",
-			 __func__, fifo_size);
+		pr_debug("%s: %d bytes left in tx fifo\n", __func__, fifo_size);
 	}
 
 	/* Fill FIFO with current frame */
@@ -607,7 +605,7 @@ static int w83977af_pio_write(int iobase, __u8 *buf, int len, int fifo_size)
 		outb(buf[actual++], iobase + TBR);
 	}
 
-	pr_debug("%s(), fifo_size %d ; %d sent of %d\n",
+	pr_debug("%s: fifo_size %d ; %d sent of %d\n",
 		 __func__, fifo_size, actual, len);
 
 	/* Restore bank */
@@ -628,7 +626,7 @@ static void w83977af_dma_xmit_complete(struct w83977af_ir *self)
 	int iobase;
 	__u8 set;
 
-	pr_debug("%s(%ld)\n", __func__, jiffies);
+	pr_debug("%s: %ld\n", __func__, jiffies);
 
 	IRDA_ASSERT(self, return;);
 
@@ -643,7 +641,7 @@ static void w83977af_dma_xmit_complete(struct w83977af_ir *self)
 
 	/* Check for underrun! */
 	if (inb(iobase + AUDR) & AUDR_UNDR) {
-		pr_debug("%s(), Transmit underrun!\n", __func__);
+		pr_debug("%s: Transmit underrun!\n", __func__);
 
 		self->netdev->stats.tx_errors++;
 		self->netdev->stats.tx_fifo_errors++;
@@ -820,8 +818,8 @@ static int w83977af_dma_receive_complete(struct w83977af_ir *self)
 
 			skb = dev_alloc_skb(len + 1);
 			if (!skb)  {
-				printk(KERN_INFO
-				       "%s(), memory squeeze, dropping frame.\n", __func__);
+				pr_info("%s: memory squeeze, dropping frame\n",
+					__func__);
 				/* Restore set register */
 				outb(set, iobase + SSR);
 
@@ -896,7 +894,7 @@ static __u8 w83977af_sir_interrupt(struct w83977af_ir *self, int isr)
 	__u8 set;
 	int iobase;
 
-	pr_debug("%s(), isr=%#x\n", __func__, isr);
+	pr_debug("%s: isr=%#x\n", __func__, isr);
 
 	iobase = self->io.fir_base;
 	/* Transmit FIFO low on data */
@@ -932,7 +930,7 @@ static __u8 w83977af_sir_interrupt(struct w83977af_ir *self, int isr)
 	if (isr & ISR_TXEMP_I) {
 		/* Check if we need to change the speed? */
 		if (self->new_speed) {
-			pr_debug("%s(), Changing speed!\n", __func__);
+			pr_debug("%s: Changing speed!\n", __func__);
 			w83977af_change_speed(self, self->new_speed);
 			self->new_speed = 0;
 		}
@@ -1229,7 +1227,7 @@ static int w83977af_net_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 
 	IRDA_ASSERT(self, return -1;);
 
-	pr_debug("%s(), %s, (cmd=0x%X)\n", __func__, dev->name, cmd);
+	pr_debug("%s: %s, (cmd=0x%X)\n", __func__, dev->name, cmd);
 
 	spin_lock_irqsave(&self->lock, flags);
 
-- 
2.10.0.rc2.1.g053435c
