From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (13/16) smsc-ircc2 -- replace check_region with
 request_region
Date: Tue, 30 Sep 2003 15:14:58 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030930151458.2f7f8499.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: irda-users@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jean Tourrilhes <jt@bougret.hpl.hp.com>,
        "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Another place where better to use request_region (earlier in the process)
rather than using check_region.

diff -Nru a/drivers/net/irda/smsc-ircc2.c b/drivers/net/irda/smsc-ircc2.c
--- a/drivers/net/irda/smsc-ircc2.c	Tue Sep 30 14:26:54 2003
+++ b/drivers/net/irda/smsc-ircc2.c	Tue Sep 30 14:26:54 2003
@@ -140,7 +140,7 @@
 
 static int smsc_ircc_open(unsigned int firbase, unsigned int sirbase, u8 dma, u8 irq);
 static int smsc_ircc_present(unsigned int fir_base, unsigned int sir_base);
-static int smsc_ircc_setup_io(struct smsc_ircc_cb *self, unsigned int fir_base, unsigned int sir_base, u8 dma, u8 irq);
+static void smsc_ircc_setup_io(struct smsc_ircc_cb *self, unsigned int fir_base, unsigned int sir_base, u8 dma, u8 irq);
 static int smsc_ircc_setup_buffers(struct smsc_ircc_cb *self);
 static void smsc_ircc_setup_qos(struct smsc_ircc_cb *self);
 static int smsc_ircc_setup_netdev(struct smsc_ircc_cb *self);
@@ -370,12 +370,14 @@
 	
 	IRDA_DEBUG(1, "%s\n", __FUNCTION__);
 
-	err= smsc_ircc_present(fir_base, sir_base);
-	if(err) return -ENODEV;
+	err = smsc_ircc_present(fir_base, sir_base);
+	if(err) 
+		goto err_out;
 		
+	err = -ENOMEM;
 	if (dev_count>DIM(dev_self)) {
 	        WARNING("%s(), too many devices!\n", __FUNCTION__);
-		return -ENOMEM;
+		goto err_out1;
 	}
 
 	/*
@@ -385,7 +387,7 @@
 	if (self == NULL) {
 		ERROR("%s, Can't allocate memory for control block!\n",
                       driver_name);
-		return -ENOMEM;
+		goto err_out1;
 	}
 	memset(self, 0, sizeof(struct smsc_ircc_cb));
 
@@ -394,10 +396,10 @@
 	spin_lock_init(&self->lock);
 
 	err = smsc_ircc_setup_buffers(self);
-	if(err) return err;
+	if(err)
+		goto err_out1;
 	   
-	err= smsc_ircc_setup_io(self, fir_base, sir_base, dma, irq);
-	if(err) return err;
+	smsc_ircc_setup_io(self, fir_base, sir_base, dma, irq);
 
 	smsc_ircc_setup_qos(self);
 
@@ -409,13 +411,20 @@
 	else smsc_ircc_probe_transceiver(self);
 
 	err = smsc_ircc_setup_netdev(self);
-	if(err) return err;
+	if(err) 
+		goto err_out1;
 
 	self->pmdev = pm_register(PM_SYS_DEV, PM_SYS_IRDA, smsc_ircc_pmproc);
 	if (self->pmdev)
 		self->pmdev->data = self;
 
 	return 0;
+
+ err_out1:
+	release_region(fir_base, SMSC_IRCC2_FIR_CHIP_IO_EXTENT);
+	release_region(sir_base, SMSC_IRCC2_SIR_CHIP_IO_EXTENT);
+ err_out:
+	return err;
 }
 
 /*
@@ -428,18 +437,20 @@
 {
 	unsigned char low, high, chip, config, dma, irq, version;
 
-	if (check_region(fir_base, SMSC_IRCC2_FIR_CHIP_IO_EXTENT) < 0) {
+	if (!request_region(fir_base, SMSC_IRCC2_FIR_CHIP_IO_EXTENT,
+			    driver_name)) {
 		WARNING("%s: can't get fir_base of 0x%03x\n",
 			__FUNCTION__, fir_base);
-		return -ENODEV;
+		goto out1;
 	}
-#if POSSIBLE_USED_BY_SERIAL_DRIVER
-	if (check_region(sir_base, SMSC_IRCC2_SIR_CHIP_IO_EXTENT) < 0) {
+
+	if (!request_region(sir_base, SMSC_IRCC2_SIR_CHIP_IO_EXTENT,
+			    driver_name)) {
 		WARNING("%s: can't get sir_base of 0x%03x\n",
 			__FUNCTION__, sir_base);
-		return -ENODEV;
+		goto out2;
 	}
-#endif
+
 
 	register_bank(fir_base, 3);
 
@@ -454,13 +465,20 @@
 	if (high != 0x10 || low != 0xb8 || (chip != 0xf1 && chip != 0xf2)) { 
 	        WARNING("%s(), addr 0x%04x - no device found!\n",
 			__FUNCTION__, fir_base);
-		return -ENODEV;
+		goto out3;
 	}
+
 	MESSAGE("SMsC IrDA Controller found\n IrCC version %d.%d, "
 		"firport 0x%03x, sirport 0x%03x dma=%d, irq=%d\n",
 		chip & 0x0f, version, fir_base, sir_base, dma, irq);
 
 	return 0;
+ out3:
+	release_region(fir_base, SMSC_IRCC2_FIR_CHIP_IO_EXTENT);
+ out2:
+	release_region(fir_base, SMSC_IRCC2_FIR_CHIP_IO_EXTENT);
+ out1:
+	return -ENODEV;
 }
 
 /*
@@ -510,10 +528,11 @@
  *    Setup I/O
  *
  */
-static int smsc_ircc_setup_io(struct smsc_ircc_cb *self, unsigned int fir_base, unsigned int sir_base, u8 dma, u8 irq)
+static void smsc_ircc_setup_io(struct smsc_ircc_cb *self, 
+			       unsigned int fir_base, unsigned int sir_base, 
+			       u8 dma, u8 irq)
 {
 	unsigned char config, chip_dma, chip_irq;
-	void *ret;
 
 	register_bank(fir_base, 3);
 	config  = inb(fir_base+IRCC_INTERFACE);
@@ -545,27 +564,6 @@
 	else
 		self->io.dma = chip_dma;
 
-	ret = request_region(self->io.fir_base, self->io.fir_ext, driver_name);
-	if (!ret) { 
-		WARNING("%s(), can't get iobase of 0x%03x\n",
-			__FUNCTION__, self->io.fir_base);
-		kfree(self->tx_buff.head);
-		kfree(self->rx_buff.head);
-		kfree(self);
-		return -ENODEV;
-	}
-	ret = request_region(self->io.sir_base, self->io.sir_ext, driver_name);
-	if (!ret) { 
-		WARNING("%s(), can't get iobase of 0x%03x\n",
-			__FUNCTION__, self->io.sir_base);
-		release_region(self->io.fir_base, self->io.fir_ext);
-		kfree(self->tx_buff.head);
-		kfree(self->rx_buff.head);
-		kfree(self);
-		return -ENODEV;
-	}
-
-	return 0;
 }
 
 /*
