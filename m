From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IRDA] Remove uses of isa_virt_to_bus
Date: Sun, 23 Nov 2003 17:16:01 +1100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031123061601.GA14072@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="h31gzZEtNLTqOjlF"
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--h31gzZEtNLTqOjlF
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi:

This patch removes the references to isa_virt_to_bus in the
relevant ISA IRDA drivers by calling dma_alloc_coherent.

Cheers,
-- 
Debian GNU/Linux 3.0 is out! ( http://www.debian.org/ )
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--h31gzZEtNLTqOjlF
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

Index: kernel-source-2.5/include/asm-i386/dma-mapping.h
===================================================================
RCS file: /home/gondolin/herbert/src/CVS/debian/kernel-source-2.5/include/asm-i386/dma-mapping.h,v
retrieving revision 1.1.1.2
diff -u -r1.1.1.2 dma-mapping.h
--- kernel-source-2.5/include/asm-i386/dma-mapping.h	17 Jan 2003 02:23:00 -0000	1.1.1.2
+++ kernel-source-2.5/include/asm-i386/dma-mapping.h	23 Nov 2003 04:27:00 -0000
@@ -2,6 +2,8 @@
 #define _ASM_I386_DMA_MAPPING_H
 
 #include <asm/cache.h>
+#include <asm/io.h>
+#include <asm/scatterlist.h>
 
 #define dma_alloc_noncoherent(d, s, h, f) dma_alloc_coherent(d, s, h, f)
 #define dma_free_noncoherent(d, s, v, h) dma_free_coherent(d, s, v, h)
Index: kernel-source-2.5/net/irda/irda_device.c
===================================================================
RCS file: /home/gondolin/herbert/src/CVS/debian/kernel-source-2.5/net/irda/irda_device.c,v
retrieving revision 1.1.1.8
diff -u -r1.1.1.8 irda_device.c
--- kernel-source-2.5/net/irda/irda_device.c	8 Oct 2003 19:24:05 -0000	1.1.1.8
+++ kernel-source-2.5/net/irda/irda_device.c	3 Nov 2003 10:54:42 -0000
@@ -557,7 +557,7 @@
  *    Setup the DMA channel. Commonly used by ISA FIR drivers
  *
  */
-void setup_dma(int channel, char *buffer, int count, int mode)
+void setup_dma(int channel, dma_addr_t buffer, int count, int mode)
 {
 	unsigned long flags;
 
@@ -566,7 +566,7 @@
 	disable_dma(channel);
 	clear_dma_ff(channel);
 	set_dma_mode(channel, mode);
-	set_dma_addr(channel, isa_virt_to_bus(buffer));
+	set_dma_addr(channel, buffer);
 	set_dma_count(channel, count);
 	enable_dma(channel);
 
Index: kernel-source-2.5/include/net/irda/ali-ircc.h
===================================================================
RCS file: /home/gondolin/herbert/src/CVS/debian/kernel-source-2.5/include/net/irda/ali-ircc.h,v
retrieving revision 1.1.1.1
diff -u -r1.1.1.1 ali-ircc.h
--- kernel-source-2.5/include/net/irda/ali-ircc.h	19 Oct 2002 04:01:57 -0000	1.1.1.1
+++ kernel-source-2.5/include/net/irda/ali-ircc.h	23 Nov 2003 03:42:16 -0000
@@ -26,6 +26,7 @@
 
 #include <linux/spinlock.h>
 #include <linux/pm.h>
+#include <linux/types.h>
 #include <asm/io.h>
 
 /* SIR Register */
@@ -198,6 +199,8 @@
 	chipio_t io;               /* IrDA controller information */
 	iobuff_t tx_buff;          /* Transmit buffer */
 	iobuff_t rx_buff;          /* Receive buffer */
+	dma_addr_t tx_buff_dma;
+	dma_addr_t rx_buff_dma;
 
 	__u8 ier;                  /* Interrupt enable register */
 	
Index: kernel-source-2.5/include/net/irda/irda_device.h
===================================================================
RCS file: /home/gondolin/herbert/src/CVS/debian/kernel-source-2.5/include/net/irda/irda_device.h,v
retrieving revision 1.1.1.6
diff -u -r1.1.1.6 irda_device.h
--- kernel-source-2.5/include/net/irda/irda_device.h	8 Oct 2003 19:24:53 -0000	1.1.1.6
+++ kernel-source-2.5/include/net/irda/irda_device.h	3 Nov 2003 10:57:29 -0000
@@ -39,11 +39,13 @@
 #ifndef IRDA_DEVICE_H
 #define IRDA_DEVICE_H
 
+#include <linux/config.h>
 #include <linux/tty.h>
 #include <linux/netdevice.h>
 #include <linux/spinlock.h>
 #include <linux/skbuff.h>		/* struct sk_buff */
 #include <linux/irda.h>
+#include <linux/types.h>
 
 #include <net/irda/irda.h>
 #include <net/irda/qos.h>		/* struct qos_info */
@@ -233,7 +235,7 @@
 int irda_device_dongle_cleanup(dongle_t *dongle);
 
 #ifdef CONFIG_ISA
-void setup_dma(int channel, char *buffer, int count, int mode);
+void setup_dma(int channel, dma_addr_t buffer, int count, int mode);
 #endif
 
 void irda_task_delete(struct irda_task *task);
Index: kernel-source-2.5/include/net/irda/nsc-ircc.h
===================================================================
RCS file: /home/gondolin/herbert/src/CVS/debian/kernel-source-2.5/include/net/irda/nsc-ircc.h,v
retrieving revision 1.1.1.3
diff -u -r1.1.1.3 nsc-ircc.h
--- kernel-source-2.5/include/net/irda/nsc-ircc.h	27 Sep 2003 00:02:02 -0000	1.1.1.3
+++ kernel-source-2.5/include/net/irda/nsc-ircc.h	23 Nov 2003 03:49:38 -0000
@@ -32,6 +32,7 @@
 
 #include <linux/spinlock.h>
 #include <linux/pm.h>
+#include <linux/types.h>
 #include <asm/io.h>
 
 /* DMA modes needed */
@@ -255,6 +256,8 @@
 	chipio_t io;               /* IrDA controller information */
 	iobuff_t tx_buff;          /* Transmit buffer */
 	iobuff_t rx_buff;          /* Receive buffer */
+	dma_addr_t tx_buff_dma;
+	dma_addr_t rx_buff_dma;
 
 	__u8 ier;                  /* Interrupt enable register */
 
Index: kernel-source-2.5/include/net/irda/w83977af_ir.h
===================================================================
RCS file: /home/gondolin/herbert/src/CVS/debian/kernel-source-2.5/include/net/irda/w83977af_ir.h,v
retrieving revision 1.1.1.1
diff -u -r1.1.1.1 w83977af_ir.h
--- kernel-source-2.5/include/net/irda/w83977af_ir.h	19 Oct 2002 04:01:09 -0000	1.1.1.1
+++ kernel-source-2.5/include/net/irda/w83977af_ir.h	23 Nov 2003 04:05:52 -0000
@@ -26,6 +26,7 @@
 #define W83977AF_IR_H
 
 #include <asm/io.h>
+#include <linux/types.h>
 
 /* Flags for configuration register CRF0 */
 #define ENBNKSEL	0x01
@@ -179,6 +180,8 @@
 	chipio_t io;               /* IrDA controller information */
 	iobuff_t tx_buff;          /* Transmit buffer */
 	iobuff_t rx_buff;          /* Receive buffer */
+	dma_addr_t tx_buff_dma;
+	dma_addr_t rx_buff_dma;
 
 	/* Note : currently locking is *very* incomplete, but this
 	 * will get you started. Check in nsc-ircc.c for a proper
Index: kernel-source-2.5/drivers/net/irda/ali-ircc.c
===================================================================
RCS file: /home/gondolin/herbert/src/CVS/debian/kernel-source-2.5/drivers/net/irda/ali-ircc.c,v
retrieving revision 1.1.1.9
diff -u -r1.1.1.9 ali-ircc.c
--- kernel-source-2.5/drivers/net/irda/ali-ircc.c	8 Oct 2003 19:24:04 -0000	1.1.1.9
+++ kernel-source-2.5/drivers/net/irda/ali-ircc.c	23 Nov 2003 04:28:10 -0000
@@ -31,6 +31,7 @@
 #include <linux/init.h>
 #include <linux/rtnetlink.h>
 #include <linux/serial_reg.h>
+#include <linux/dma-mapping.h>
 
 #include <asm/io.h>
 #include <asm/dma.h>
@@ -303,16 +304,18 @@
 	self->tx_buff.truesize = 14384;
 
 	/* Allocate memory if needed */
-	self->rx_buff.head = (__u8 *) kmalloc(self->rx_buff.truesize,
-					      GFP_KERNEL |GFP_DMA); 
+	self->rx_buff.head =
+		dma_alloc_coherent(NULL, self->rx_buff.truesize,
+				   &self->rx_buff_dma, GFP_KERNEL); 
 	if (self->rx_buff.head == NULL) {
 		err = -ENOMEM;
 		goto err_out2;
 	}
 	memset(self->rx_buff.head, 0, self->rx_buff.truesize);
 	
-	self->tx_buff.head = (__u8 *) kmalloc(self->tx_buff.truesize, 
-					      GFP_KERNEL|GFP_DMA); 
+	self->tx_buff.head =
+		dma_alloc_coherent(NULL, self->tx_buff.truesize,
+				   &self->tx_buff_dma, GFP_KERNEL); 
 	if (self->tx_buff.head == NULL) {
 		err = -ENOMEM;
 		goto err_out3;
@@ -361,9 +364,11 @@
 	return 0;
 
  err_out4:
-	kfree(self->tx_buff.head);
+	dma_free_coherent(NULL, self->tx_buff.truesize,
+			  self->tx_buff.head, self->tx_buff_dma);
  err_out3:
-	kfree(self->rx_buff.head);
+	dma_free_coherent(NULL, self->rx_buff.truesize,
+			  self->rx_buff.head, self->rx_buff_dma);
  err_out2:
 	release_region(self->io.fir_base, self->io.fir_ext);
  err_out1:
@@ -397,10 +402,12 @@
 	release_region(self->io.fir_base, self->io.fir_ext);
 
 	if (self->tx_buff.head)
-		kfree(self->tx_buff.head);
+		dma_free_coherent(NULL, self->tx_buff.truesize,
+				  self->tx_buff.head, self->tx_buff_dma);
 	
 	if (self->rx_buff.head)
-		kfree(self->rx_buff.head);
+		dma_free_coherent(NULL, self->rx_buff.truesize,
+				  self->rx_buff.head, self->rx_buff_dma);
 
 	dev_self[self->index] = NULL;
 	free_netdev(self->netdev);
@@ -1567,7 +1574,8 @@
 	self->io.direction = IO_XMIT;
 	
 	setup_dma(self->io.dma, 
-		  self->tx_fifo.queue[self->tx_fifo.ptr].start, 
+		  ((u8 *)self->tx_fifo.queue[self->tx_fifo.ptr].start -
+		   self->tx_buff.head) + self->tx_buff_dma,
 		  self->tx_fifo.queue[self->tx_fifo.ptr].len, 
 		  DMA_TX_MODE);
 		
@@ -1719,7 +1727,7 @@
 	self->st_fifo.len = self->st_fifo.pending_bytes = 0;
 	self->st_fifo.tail = self->st_fifo.head = 0;
 		
-	setup_dma(self->io.dma, self->rx_buff.data, self->rx_buff.truesize, 
+	setup_dma(self->io.dma, self->rx_buff_dma, self->rx_buff.truesize, 
 		  DMA_RX_MODE);	
 	 
 	/* Set Receive Mode,Brick Wall */
Index: kernel-source-2.5/drivers/net/irda/nsc-ircc.c
===================================================================
RCS file: /home/gondolin/herbert/src/CVS/debian/kernel-source-2.5/drivers/net/irda/nsc-ircc.c,v
retrieving revision 1.1.1.9
diff -u -r1.1.1.9 nsc-ircc.c
--- kernel-source-2.5/drivers/net/irda/nsc-ircc.c	8 Oct 2003 19:24:00 -0000	1.1.1.9
+++ kernel-source-2.5/drivers/net/irda/nsc-ircc.c	23 Nov 2003 04:28:17 -0000
@@ -52,6 +52,7 @@
 #include <linux/slab.h>
 #include <linux/init.h>
 #include <linux/rtnetlink.h>
+#include <linux/dma-mapping.h>
 
 #include <asm/io.h>
 #include <asm/dma.h>
@@ -309,8 +310,9 @@
 	self->tx_buff.truesize = 14384;
 
 	/* Allocate memory if needed */
-	self->rx_buff.head = (__u8 *) kmalloc(self->rx_buff.truesize,
-					      GFP_KERNEL|GFP_DMA);
+	self->rx_buff.head =
+		dma_alloc_coherent(NULL, self->rx_buff.truesize,
+				   &self->rx_buff_dma, GFP_KERNEL);
 	if (self->rx_buff.head == NULL) {
 		err = -ENOMEM;
 		goto out2;
@@ -318,8 +320,9 @@
 	}
 	memset(self->rx_buff.head, 0, self->rx_buff.truesize);
 	
-	self->tx_buff.head = (__u8 *) kmalloc(self->tx_buff.truesize, 
-					      GFP_KERNEL|GFP_DMA);
+	self->tx_buff.head =
+		dma_alloc_coherent(NULL, self->tx_buff.truesize,
+				   &self->tx_buff_dma, GFP_KERNEL);
 	if (self->tx_buff.head == NULL) {
 		err = -ENOMEM;
 		goto out3;
@@ -370,9 +373,11 @@
 
 	return 0;
  out4:
-	kfree(self->tx_buff.head);
+	dma_free_coherent(NULL, self->tx_buff.truesize,
+			  self->tx_buff.head, self->tx_buff_dma);
  out3:
-	kfree(self->rx_buff.head);
+	dma_free_coherent(NULL, self->rx_buff.truesize,
+			  self->rx_buff.head, self->rx_buff_dma);
  out2:
 	release_region(self->io.fir_base, self->io.fir_ext);
  out1:
@@ -406,10 +411,12 @@
 	release_region(self->io.fir_base, self->io.fir_ext);
 
 	if (self->tx_buff.head)
-		kfree(self->tx_buff.head);
+		dma_free_coherent(NULL, self->tx_buff.truesize,
+				  self->tx_buff.head, self->tx_buff_dma);
 	
 	if (self->rx_buff.head)
-		kfree(self->rx_buff.head);
+		dma_free_coherent(NULL, self->rx_buff.truesize,
+				  self->rx_buff.head, self->rx_buff_dma);
 
 	dev_self[self->index] = NULL;
 	free_netdev(self->netdev);
@@ -1411,7 +1418,8 @@
 	outb(ECR1_DMASWP|ECR1_DMANF|ECR1_EXT_SL, iobase+ECR1);
 	
 	setup_dma(self->io.dma, 
-		  self->tx_fifo.queue[self->tx_fifo.ptr].start, 
+		  ((u8 *)self->tx_fifo.queue[self->tx_fifo.ptr].start -
+		   self->tx_buff.head) + self->tx_buff_dma,
 		  self->tx_fifo.queue[self->tx_fifo.ptr].len, 
 		  DMA_TX_MODE);
 
@@ -1568,7 +1576,7 @@
 	self->st_fifo.len = self->st_fifo.pending_bytes = 0;
 	self->st_fifo.tail = self->st_fifo.head = 0;
 	
-	setup_dma(self->io.dma, self->rx_buff.data, self->rx_buff.truesize, 
+	setup_dma(self->io.dma, self->rx_buff_dma, self->rx_buff.truesize, 
 		  DMA_RX_MODE);
 
 	/* Enable DMA */
Index: kernel-source-2.5/drivers/net/irda/smsc-ircc2.c
===================================================================
RCS file: /home/gondolin/herbert/src/CVS/debian/kernel-source-2.5/drivers/net/irda/smsc-ircc2.c,v
retrieving revision 1.1.1.2
diff -u -r1.1.1.2 smsc-ircc2.c
--- kernel-source-2.5/drivers/net/irda/smsc-ircc2.c	8 Oct 2003 19:24:16 -0000	1.1.1.2
+++ kernel-source-2.5/drivers/net/irda/smsc-ircc2.c	23 Nov 2003 04:30:19 -0000
@@ -52,6 +52,7 @@
 #include <linux/init.h>
 #include <linux/rtnetlink.h>
 #include <linux/serial_reg.h>
+#include <linux/dma-mapping.h>
 
 #include <asm/io.h>
 #include <asm/dma.h>
@@ -112,6 +113,8 @@
 	chipio_t io;               /* IrDA controller information */
 	iobuff_t tx_buff;          /* Transmit buffer */
 	iobuff_t rx_buff;          /* Receive buffer */
+	dma_addr_t tx_buff_dma;
+	dma_addr_t rx_buff_dma;
 
 	struct qos_info qos;       /* QoS capabilities for this device */
 
@@ -413,16 +416,18 @@
 	self->rx_buff.truesize = SMSC_IRCC2_RX_BUFF_TRUESIZE; 
 	self->tx_buff.truesize = SMSC_IRCC2_TX_BUFF_TRUESIZE;
 
-	self->rx_buff.head = (u8 *) kmalloc(self->rx_buff.truesize,
-					      GFP_KERNEL|GFP_DMA);
+	self->rx_buff.head =
+		dma_alloc_coherent(NULL, self->rx_buff.truesize, 
+				   &self->rx_buff_dma, GFP_KERNEL);
 	if (self->rx_buff.head == NULL) {
 		ERROR("%s, Can't allocate memory for receive buffer!\n",
                       driver_name);
 		goto err_out2;
 	}
 
-	self->tx_buff.head = (u8 *) kmalloc(self->tx_buff.truesize, 
-					      GFP_KERNEL|GFP_DMA);
+	self->tx_buff.head =
+		dma_alloc_coherent(NULL, self->tx_buff.truesize, 
+				   &self->tx_buff_dma, GFP_KERNEL);
 	if (self->tx_buff.head == NULL) {
 		ERROR("%s, Can't allocate memory for transmit buffer!\n",
                       driver_name);
@@ -466,9 +471,11 @@
 
 	return 0;
  err_out4:
-	kfree(self->tx_buff.head);
+	dma_free_coherent(NULL, self->tx_buff.truesize,
+			  self->tx_buff.head, self->tx_buff_dma);
  err_out3:
-	kfree(self->rx_buff.head);
+	dma_free_coherent(NULL, self->rx_buff.truesize,
+			  self->rx_buff.head, self->rx_buff_dma);
  err_out2:
 	free_netdev(self->netdev);
 	dev_self[--dev_count] = NULL;
@@ -1161,7 +1168,7 @@
 	     IRCC_CFGB_DMA_BURST, iobase+IRCC_SCE_CFGB);
 
 	/* Setup DMA controller (must be done after enabling chip DMA) */
-	setup_dma(self->io.dma, self->tx_buff.data, self->tx_buff.len, 
+	setup_dma(self->io.dma, self->tx_buff_dma, self->tx_buff.len,
 		  DMA_TX_MODE);
 
 	/* Enable interrupt */
@@ -1251,7 +1258,7 @@
 	outb(2050 & 0xff, iobase+IRCC_RX_SIZE_LO);
 
 	/* Setup DMA controller */
-	setup_dma(self->io.dma, self->rx_buff.data, self->rx_buff.truesize, 
+	setup_dma(self->io.dma, self->rx_buff_dma, self->rx_buff.truesize, 
 		  DMA_RX_MODE);
 
 	/* Enable burst mode chip Rx DMA */
@@ -1717,10 +1724,12 @@
 	release_region(self->io.sir_base, self->io.sir_ext);
 
 	if (self->tx_buff.head)
-		kfree(self->tx_buff.head);
+		dma_free_coherent(NULL, self->tx_buff.truesize,
+				  self->tx_buff.head, self->tx_buff_dma);
 	
 	if (self->rx_buff.head)
-		kfree(self->rx_buff.head);
+		dma_free_coherent(NULL, self->rx_buff.truesize,
+				  self->rx_buff.head, self->rx_buff_dma);
 
 	free_netdev(self->netdev);
 
Index: kernel-source-2.5/drivers/net/irda/via-ircc.c
===================================================================
RCS file: /home/gondolin/herbert/src/CVS/debian/kernel-source-2.5/drivers/net/irda/via-ircc.c,v
retrieving revision 1.1.1.4
diff -u -r1.1.1.4 via-ircc.c
--- kernel-source-2.5/drivers/net/irda/via-ircc.c	8 Oct 2003 19:24:00 -0000	1.1.1.4
+++ kernel-source-2.5/drivers/net/irda/via-ircc.c	23 Nov 2003 04:28:28 -0000
@@ -39,6 +39,7 @@
 #include <linux/init.h>
 #include <linux/rtnetlink.h>
 #include <linux/pci.h>
+#include <linux/dma-mapping.h>
 
 #include <asm/io.h>
 #include <asm/dma.h>
@@ -386,7 +387,8 @@
 
 	/* Allocate memory if needed */
 	self->rx_buff.head =
-	    (__u8 *) kmalloc(self->rx_buff.truesize, GFP_KERNEL | GFP_DMA);
+		dma_alloc_coherent(NULL, self->rx_buff.truesize,
+				   &self->rx_buff_dma, GFP_KERNEL);
 	if (self->rx_buff.head == NULL) {
 		err = -ENOMEM;
 		goto err_out2;
@@ -394,7 +396,8 @@
 	memset(self->rx_buff.head, 0, self->rx_buff.truesize);
 
 	self->tx_buff.head =
-	    (__u8 *) kmalloc(self->tx_buff.truesize, GFP_KERNEL | GFP_DMA);
+		dma_alloc_coherent(NULL, self->tx_buff.truesize,
+				   &self->tx_buff_dma, GFP_KERNEL);
 	if (self->tx_buff.head == NULL) {
 		err = -ENOMEM;
 		goto err_out3;
@@ -435,9 +438,11 @@
 
 	return 0;
  err_out4:
-	kfree(self->tx_buff.head);
+	dma_free_coherent(NULL, self->tx_buff.truesize,
+			  self->tx_buff.head, self->tx_buff_dma);
  err_out3:
-	kfree(self->rx_buff.head);
+	dma_free_coherent(NULL, self->rx_buff.truesize,
+			  self->rx_buff.head, self->rx_buff_dma);
  err_out2:
 	release_region(self->io.fir_base, self->io.fir_ext);
  err_out1:
@@ -471,9 +476,11 @@
 		   __FUNCTION__, self->io.fir_base);
 	release_region(self->io.fir_base, self->io.fir_ext);
 	if (self->tx_buff.head)
-		kfree(self->tx_buff.head);
+		dma_free_coherent(NULL, self->tx_buff.truesize,
+				  self->tx_buff.head, self->tx_buff_dma);
 	if (self->rx_buff.head)
-		kfree(self->rx_buff.head);
+		dma_free_coherent(NULL, self->rx_buff.truesize,
+				  self->rx_buff.head, self->rx_buff_dma);
 	dev_self[self->index] = NULL;
 
 	free_netdev(self->netdev);
@@ -819,7 +826,7 @@
 	EnTXDMA(iobase, ON);
 	EnRXDMA(iobase, OFF);
 
-	setup_dma(self->io.dma, self->tx_buff.data, self->tx_buff.len,
+	setup_dma(self->io.dma, self->tx_buff_dma, self->tx_buff.len,
 		  DMA_TX_MODE);
 
 	SetSendByte(iobase, self->tx_buff.len);
@@ -900,7 +907,8 @@
 	EnTXDMA(iobase, ON);
 	EnRXDMA(iobase, OFF);
 	setup_dma(self->io.dma,
-		  self->tx_fifo.queue[self->tx_fifo.ptr].start,
+		  ((u8 *)self->tx_fifo.queue[self->tx_fifo.ptr].start -
+		   self->tx_buff.head) + self->tx_buff_dma,
 		  self->tx_fifo.queue[self->tx_fifo.ptr].len, DMA_TX_MODE);
 #ifdef	DBGMSG
 	DBG(printk
@@ -1025,7 +1033,7 @@
 	EnAllInt(iobase, ON);
 	EnTXDMA(iobase, OFF);
 	EnRXDMA(iobase, ON);
-	setup_dma(self->io.dma2, self->rx_buff.data,
+	setup_dma(self->io.dma2, self->rx_buff_dma,
 		  self->rx_buff.truesize, DMA_RX_MODE);
 	TXStart(iobase, OFF);
 	RXStart(iobase, ON);
Index: kernel-source-2.5/drivers/net/irda/via-ircc.h
===================================================================
RCS file: /home/gondolin/herbert/src/CVS/debian/kernel-source-2.5/drivers/net/irda/via-ircc.h,v
retrieving revision 1.1.1.1
diff -u -r1.1.1.1 via-ircc.h
--- kernel-source-2.5/drivers/net/irda/via-ircc.h	9 Aug 2003 08:11:57 -0000	1.1.1.1
+++ kernel-source-2.5/drivers/net/irda/via-ircc.h	23 Nov 2003 04:01:15 -0000
@@ -33,6 +33,7 @@
 #include <linux/time.h>
 #include <linux/spinlock.h>
 #include <linux/pm.h>
+#include <linux/types.h>
 #include <asm/io.h>
 
 #define MAX_TX_WINDOW 7
@@ -102,6 +103,8 @@
 	chipio_t io;		/* IrDA controller information */
 	iobuff_t tx_buff;	/* Transmit buffer */
 	iobuff_t rx_buff;	/* Receive buffer */
+	dma_addr_t tx_buff_dma;
+	dma_addr_t rx_buff_dma;
 
 	__u8 ier;		/* Interrupt enable register */
 
Index: kernel-source-2.5/drivers/net/irda/w83977af_ir.c
===================================================================
RCS file: /home/gondolin/herbert/src/CVS/debian/kernel-source-2.5/drivers/net/irda/w83977af_ir.c,v
retrieving revision 1.1.1.8
diff -u -r1.1.1.8 w83977af_ir.c
--- kernel-source-2.5/drivers/net/irda/w83977af_ir.c	8 Oct 2003 19:24:04 -0000	1.1.1.8
+++ kernel-source-2.5/drivers/net/irda/w83977af_ir.c	23 Nov 2003 04:28:34 -0000
@@ -50,6 +50,7 @@
 #include <linux/slab.h>
 #include <linux/init.h>
 #include <linux/rtnetlink.h>
+#include <linux/dma-mapping.h>
 
 #include <asm/io.h>
 #include <asm/dma.h>
@@ -209,8 +210,9 @@
 	self->tx_buff.truesize = 4000;
 	
 	/* Allocate memory if needed */
-	self->rx_buff.head = (__u8 *) kmalloc(self->rx_buff.truesize,
-					      GFP_KERNEL|GFP_DMA);
+	self->rx_buff.head =
+		dma_alloc_coherent(NULL, self->rx_buff.truesize,
+				   &self->rx_buff_dma, GFP_KERNEL);
 	if (self->rx_buff.head == NULL) {
 		err = -ENOMEM;
 		goto err_out1;
@@ -218,8 +220,9 @@
 
 	memset(self->rx_buff.head, 0, self->rx_buff.truesize);
 	
-	self->tx_buff.head = (__u8 *) kmalloc(self->tx_buff.truesize, 
-					      GFP_KERNEL|GFP_DMA);
+	self->tx_buff.head =
+		dma_alloc_coherent(NULL, self->tx_buff.truesize,
+				   &self->tx_buff_dma, GFP_KERNEL);
 	if (self->tx_buff.head == NULL) {
 		err = -ENOMEM;
 		goto err_out2;
@@ -254,9 +257,11 @@
 	
 	return 0;
 err_out3:
-	kfree(self->tx_buff.head);
+	dma_free_coherent(NULL, self->tx_buff.truesize,
+			  self->tx_buff.head, self->tx_buff_dma);
 err_out2:	
-	kfree(self->rx_buff.head);
+	dma_free_coherent(NULL, self->rx_buff.truesize,
+			  self->rx_buff.head, self->rx_buff_dma);
 err_out1:
 	free_netdev(dev);
 err_out:
@@ -299,10 +304,12 @@
 	release_region(self->io.fir_base, self->io.fir_ext);
 
 	if (self->tx_buff.head)
-		kfree(self->tx_buff.head);
+		dma_free_coherent(NULL, self->tx_buff.truesize,
+				  self->tx_buff.head, self->tx_buff_dma);
 	
 	if (self->rx_buff.head)
-		kfree(self->rx_buff.head);
+		dma_free_coherent(NULL, self->rx_buff.truesize,
+				  self->rx_buff.head, self->rx_buff_dma);
 
 	free_netdev(self->netdev);
 
@@ -608,10 +615,10 @@
 	disable_dma(self->io.dma);
 	clear_dma_ff(self->io.dma);
 	set_dma_mode(self->io.dma, DMA_MODE_READ);
-	set_dma_addr(self->io.dma, isa_virt_to_bus(self->tx_buff.data));
+	set_dma_addr(self->io.dma, self->tx_buff_dma);
 	set_dma_count(self->io.dma, self->tx_buff.len);
 #else
-	setup_dma(self->io.dma, self->tx_buff.data, self->tx_buff.len, 
+	setup_dma(self->io.dma, self->tx_buff_dma, self->tx_buff.len, 
 		  DMA_MODE_WRITE);	
 #endif
 	self->io.direction = IO_XMIT;
@@ -765,10 +772,10 @@
 	disable_dma(self->io.dma);
 	clear_dma_ff(self->io.dma);
 	set_dma_mode(self->io.dma, DMA_MODE_READ);
-	set_dma_addr(self->io.dma, isa_virt_to_bus(self->rx_buff.data));
+	set_dma_addr(self->io.dma, self->rx_buff_dma);
 	set_dma_count(self->io.dma, self->rx_buff.truesize);
 #else
-	setup_dma(self->io.dma, self->rx_buff.data, self->rx_buff.truesize, 
+	setup_dma(self->io.dma, self->rx_buff_dma, self->rx_buff.truesize, 
 		  DMA_MODE_READ);
 #endif
 	/* 

--h31gzZEtNLTqOjlF--
