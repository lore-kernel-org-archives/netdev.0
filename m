From: margitsw@t-online.de (Margit Schubert-While)
Subject: [PATCH 6/17 linux-2.6.7-rc2] prism54: Kernel compatibility (resend)
Date: Sat, 5 Jun 2004 14:48:08 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200406051448.08292.margitsw@t-online.de>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_IEcwA9i+0zpj2K4"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--Boundary-00=_IEcwA9i+0zpj2K4
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

2004-03-20      Margit Schubert-While <margitsw@t-online.de>

* isl_38xx.[ch], isl_ioctl.c, islpci_dev.[ch], islpci_eth.c
  islpci_hotplug.c, islpci_mgt.[ch], oid_mgt.c, prismcompat.h:
  Adopt new prism54 kernel compatibility.
  Remove remaining kernel version ifdefs.



--Boundary-00=_IEcwA9i+0zpj2K4
Content-Type: text/x-diff;
  charset="us-ascii";
  name="06-kernel-compatibility.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="06-kernel-compatibility.patch"

diff -Naur linux-2.6.6ct/drivers/net/wireless/prism54/isl_38xx.c linux-2.6.6-01/drivers/net/wireless/prism54/isl_38xx.c
--- linux-2.6.6ct/drivers/net/wireless/prism54/isl_38xx.c	2004-06-05 13:39:20.000000000 +0200
+++ linux-2.6.6-01/drivers/net/wireless/prism54/isl_38xx.c	2004-06-05 13:45:32.000000000 +0200
@@ -25,17 +25,11 @@
 #include <linux/types.h>
 #include <linux/delay.h>
 
-#include "isl_38xx.h"
-#include <linux/firmware.h>
-
 #include <asm/uaccess.h>
 #include <asm/io.h>
 
-#include <linux/config.h>
-#if !defined(CONFIG_FW_LOADER) && !defined(CONFIG_FW_LOADER_MODULE)
-#error No Firmware Loading configured in the kernel !
-#endif
-
+#include "prismcompat.h"
+#include "isl_38xx.h"
 #include "islpci_dev.h"
 #include "islpci_mgt.h"
 
@@ -236,130 +230,6 @@
 }
 
 int
-isl38xx_upload_firmware(char *fw_id, _REQ_FW_DEV_T dev, void *device_base,
-			dma_addr_t host_address)
-{
-	u32 reg, rc;
-
-#if VERBOSE > SHOW_ERROR_MESSAGES
-	DEBUG(SHOW_ERROR_MESSAGES, "isl38xx_upload_firmware(0x%lx, 0x%lx)\n",
-	      (long) device_base, (long) host_address);
-#endif
-
-	/* clear the RAMBoot and the Reset bit */
-	reg = readl(device_base + ISL38XX_CTRL_STAT_REG);
-	reg &= ~ISL38XX_CTRL_STAT_RESET;
-	reg &= ~ISL38XX_CTRL_STAT_RAMBOOT;
-	writel(reg, device_base + ISL38XX_CTRL_STAT_REG);
-	wmb();
-	udelay(ISL38XX_WRITEIO_DELAY);
-
-	/* set the Reset bit without reading the register ! */
-	reg |= ISL38XX_CTRL_STAT_RESET;
-	writel(reg, device_base + ISL38XX_CTRL_STAT_REG);
-	wmb();
-	udelay(ISL38XX_WRITEIO_DELAY);
-
-	/* clear the Reset bit */
-	reg &= ~ISL38XX_CTRL_STAT_RESET;
-	writel(reg, device_base + ISL38XX_CTRL_STAT_REG);
-	wmb();
-
-	/* wait a while for the device to reboot */
-	mdelay(50);
-
-	{
-		const struct firmware *fw_entry = 0;
-		long fw_len;
-		const u32 *fw_ptr;
-
-		rc = request_firmware(&fw_entry, fw_id, dev);
-		if (rc) {
-			printk(KERN_ERR
-			       "%s: request_firmware() failed for '%s'\n",
-			       "prism54", fw_id);
-			return rc;
-		}
-		/* prepare the Direct Memory Base register */
-		reg = ISL38XX_DEV_FIRMWARE_ADDRES;
-
-		fw_ptr = (u32 *) fw_entry->data;
-		fw_len = fw_entry->size;
-
-		if (fw_len % 4) {
-			printk(KERN_ERR
-			       "%s: firmware '%s' size is not multiple of 32bit, aborting!\n",
-			       "prism54", fw_id);
-			release_firmware(fw_entry);
-			return EILSEQ; /* Illegal byte sequence  */;
-		}
-
-		while (fw_len > 0) {
-			long _fw_len =
-			    (fw_len >
-			     ISL38XX_MEMORY_WINDOW_SIZE) ?
-			    ISL38XX_MEMORY_WINDOW_SIZE : fw_len;
-			u32 *dev_fw_ptr = device_base + ISL38XX_DIRECT_MEM_WIN;
-
-			/* set the cards base address for writting the data */
-			isl38xx_w32_flush(device_base, reg,
-					  ISL38XX_DIR_MEM_BASE_REG);
-			wmb();	/* be paranoid */
-
-			/* increment the write address for next iteration */
-			reg += _fw_len;
-			fw_len -= _fw_len;
-
-			/* write the data to the Direct Memory Window 32bit-wise */
-			/* memcpy_toio() doesn't guarantee 32bit writes :-| */
-			while (_fw_len > 0) {
-				/* use non-swapping writel() */
-				__raw_writel(*fw_ptr, dev_fw_ptr);
-				fw_ptr++, dev_fw_ptr++;
-				_fw_len -= 4;
-			}
-
-			/* flush PCI posting */
-			(void) readl(device_base + ISL38XX_PCI_POSTING_FLUSH);
-			wmb();	/* be paranoid again */
-
-			BUG_ON(_fw_len != 0);
-		}
-
-		BUG_ON(fw_len != 0);
-
-		release_firmware(fw_entry);
-	}
-
-	/* now reset the device
-	 * clear the Reset & ClkRun bit, set the RAMBoot bit */
-	reg = readl(device_base + ISL38XX_CTRL_STAT_REG);
-	reg &= ~ISL38XX_CTRL_STAT_CLKRUN;
-	reg &= ~ISL38XX_CTRL_STAT_RESET;
-	reg |= ISL38XX_CTRL_STAT_RAMBOOT;
-	isl38xx_w32_flush(device_base, reg, ISL38XX_CTRL_STAT_REG);
-	wmb();
-	udelay(ISL38XX_WRITEIO_DELAY);
-
-	/* set the reset bit latches the host override and RAMBoot bits
-	 * into the device for operation when the reset bit is reset */
-	reg |= ISL38XX_CTRL_STAT_RESET;
-	writel(reg, device_base + ISL38XX_CTRL_STAT_REG);
-	/* don't do flush PCI posting here! */
-	wmb();
-	udelay(ISL38XX_WRITEIO_DELAY);
-
-	/* clear the reset bit should start the whole circus */
-	reg &= ~ISL38XX_CTRL_STAT_RESET;
-	writel(reg, device_base + ISL38XX_CTRL_STAT_REG);
-	/* don't do flush PCI posting here! */
-	wmb();
-	udelay(ISL38XX_WRITEIO_DELAY);
-
-	return 0;
-}
-
-int
 isl38xx_in_queue(isl38xx_control_block *cb, int queue)
 {
 	const s32 delta = (le32_to_cpu(cb->driver_curr_frag[queue]) -
diff -Naur linux-2.6.6ct/drivers/net/wireless/prism54/isl_38xx.h linux-2.6.6-01/drivers/net/wireless/prism54/isl_38xx.h
--- linux-2.6.6ct/drivers/net/wireless/prism54/isl_38xx.h	2004-06-05 13:39:20.000000000 +0200
+++ linux-2.6.6-01/drivers/net/wireless/prism54/isl_38xx.h	2004-06-05 13:45:32.000000000 +0200
@@ -22,14 +22,6 @@
 
 #include <linux/version.h>
 #include <asm/io.h>
-
-#if (LINUX_VERSION_CODE > KERNEL_VERSION(2,5,75))
-#include <linux/device.h>
-# define _REQ_FW_DEV_T struct device *
-#else
-# define _REQ_FW_DEV_T char *
-#endif
-
 #include <asm/byteorder.h>
 
 #define ISL38XX_CB_RX_QSIZE                     8
@@ -174,6 +166,4 @@
 void isl38xx_trigger_device(int, void *);
 void isl38xx_interface_reset(void *, dma_addr_t);
 
-int isl38xx_upload_firmware(char *, _REQ_FW_DEV_T, void *, dma_addr_t);
-
 #endif				/* _ISL_38XX_H */
diff -Naur linux-2.6.6ct/drivers/net/wireless/prism54/isl_ioctl.c linux-2.6.6-01/drivers/net/wireless/prism54/isl_ioctl.c
--- linux-2.6.6ct/drivers/net/wireless/prism54/isl_ioctl.c	2004-06-05 13:39:34.000000000 +0200
+++ linux-2.6.6-01/drivers/net/wireless/prism54/isl_ioctl.c	2004-06-05 13:44:14.000000000 +0200
@@ -25,10 +25,10 @@
 #include <linux/kernel.h>
 #include <linux/if_arp.h>
 #include <linux/pci.h>
-#include <linux/moduleparam.h>
 
 #include <asm/uaccess.h>
 
+#include "prismcompat.h"
 #include "isl_ioctl.h"
 #include "islpci_mgt.h"
 #include "isl_oid.h"		/* additional types and defs for isl38xx fw */
diff -Naur linux-2.6.6ct/drivers/net/wireless/prism54/islpci_dev.c linux-2.6.6-01/drivers/net/wireless/prism54/islpci_dev.c
--- linux-2.6.6ct/drivers/net/wireless/prism54/islpci_dev.c	2004-06-05 13:39:34.000000000 +0200
+++ linux-2.6.6-01/drivers/net/wireless/prism54/islpci_dev.c	2004-06-05 13:45:32.000000000 +0200
@@ -30,6 +30,7 @@
 
 #include <asm/io.h>
 
+#include "prismcompat.h"
 #include "isl_38xx.h"
 #include "isl_ioctl.h"
 #include "islpci_dev.h"
@@ -37,12 +38,6 @@
 #include "islpci_eth.h"
 #include "oid_mgt.h"
 
-#if LINUX_VERSION_CODE <= KERNEL_VERSION(2,5,0)
-#define prism54_synchronize_irq(irq) synchronize_irq()
-#else
-#define prism54_synchronize_irq(irq) synchronize_irq(irq)
-#endif
-
 #define ISL3877_IMAGE_FILE	"isl3877"
 #define ISL3890_IMAGE_FILE	"isl3890"
 
@@ -55,6 +50,125 @@
  * ndev->set_mac_address. Jean II */
 const unsigned char	dummy_mac[6] = { 0x00, 0x30, 0xB4, 0x00, 0x00, 0x00 };
 
+static int
+isl_upload_firmware(islpci_private *priv)
+{
+	u32 reg, rc;
+	void *device_base = priv->device_base;
+
+	/* clear the RAMBoot and the Reset bit */
+	reg = readl(device_base + ISL38XX_CTRL_STAT_REG);
+	reg &= ~ISL38XX_CTRL_STAT_RESET;
+	reg &= ~ISL38XX_CTRL_STAT_RAMBOOT;
+	writel(reg, device_base + ISL38XX_CTRL_STAT_REG);
+	wmb();
+	udelay(ISL38XX_WRITEIO_DELAY);
+
+	/* set the Reset bit without reading the register ! */
+	reg |= ISL38XX_CTRL_STAT_RESET;
+	writel(reg, device_base + ISL38XX_CTRL_STAT_REG);
+	wmb();
+	udelay(ISL38XX_WRITEIO_DELAY);
+
+	/* clear the Reset bit */
+	reg &= ~ISL38XX_CTRL_STAT_RESET;
+	writel(reg, device_base + ISL38XX_CTRL_STAT_REG);
+	wmb();
+
+	/* wait a while for the device to reboot */
+	mdelay(50);
+
+	{
+		const struct firmware *fw_entry = 0;
+		long fw_len;
+		const u32 *fw_ptr;
+
+		rc = request_firmware(&fw_entry, priv->firmware, PRISM_FW_PDEV);
+		if (rc) {
+			printk(KERN_ERR
+			       "%s: request_firmware() failed for '%s'\n",
+			       "prism54", priv->firmware);
+			return rc;
+		}
+		/* prepare the Direct Memory Base register */
+		reg = ISL38XX_DEV_FIRMWARE_ADDRES;
+
+		fw_ptr = (u32 *) fw_entry->data;
+		fw_len = fw_entry->size;
+
+		if (fw_len % 4) {
+			printk(KERN_ERR
+			       "%s: firmware '%s' size is not multiple of 32bit, aborting!\n",
+			       "prism54", priv->firmware);
+			release_firmware(fw_entry);
+			return EILSEQ; /* Illegal byte sequence  */;
+		}
+
+		while (fw_len > 0) {
+			long _fw_len =
+			    (fw_len >
+			     ISL38XX_MEMORY_WINDOW_SIZE) ?
+			    ISL38XX_MEMORY_WINDOW_SIZE : fw_len;
+			u32 *dev_fw_ptr = device_base + ISL38XX_DIRECT_MEM_WIN;
+
+			/* set the cards base address for writting the data */
+			isl38xx_w32_flush(device_base, reg,
+					  ISL38XX_DIR_MEM_BASE_REG);
+			wmb();	/* be paranoid */
+
+			/* increment the write address for next iteration */
+			reg += _fw_len;
+			fw_len -= _fw_len;
+
+			/* write the data to the Direct Memory Window 32bit-wise */
+			/* memcpy_toio() doesn't guarantee 32bit writes :-| */
+			while (_fw_len > 0) {
+				/* use non-swapping writel() */
+				__raw_writel(*fw_ptr, dev_fw_ptr);
+				fw_ptr++, dev_fw_ptr++;
+				_fw_len -= 4;
+			}
+
+			/* flush PCI posting */
+			(void) readl(device_base + ISL38XX_PCI_POSTING_FLUSH);
+			wmb();	/* be paranoid again */
+
+			BUG_ON(_fw_len != 0);
+		}
+
+		BUG_ON(fw_len != 0);
+
+		release_firmware(fw_entry);
+	}
+
+	/* now reset the device
+	 * clear the Reset & ClkRun bit, set the RAMBoot bit */
+	reg = readl(device_base + ISL38XX_CTRL_STAT_REG);
+	reg &= ~ISL38XX_CTRL_STAT_CLKRUN;
+	reg &= ~ISL38XX_CTRL_STAT_RESET;
+	reg |= ISL38XX_CTRL_STAT_RAMBOOT;
+	isl38xx_w32_flush(device_base, reg, ISL38XX_CTRL_STAT_REG);
+	wmb();
+	udelay(ISL38XX_WRITEIO_DELAY);
+
+	/* set the reset bit latches the host override and RAMBoot bits
+	 * into the device for operation when the reset bit is reset */
+	reg |= ISL38XX_CTRL_STAT_RESET;
+	writel(reg, device_base + ISL38XX_CTRL_STAT_REG);
+	/* don't do flush PCI posting here! */
+	wmb();
+	udelay(ISL38XX_WRITEIO_DELAY);
+
+	/* clear the reset bit should start the whole circus */
+	reg &= ~ISL38XX_CTRL_STAT_RESET;
+	writel(reg, device_base + ISL38XX_CTRL_STAT_REG);
+	/* don't do flush PCI posting here! */
+	wmb();
+	udelay(ISL38XX_WRITEIO_DELAY);
+
+	return 0;
+}
+
 /******************************************************************************
     Device Interrupt Handler
 ******************************************************************************/
@@ -324,14 +438,7 @@
 
 	printk(KERN_DEBUG "%s: uploading firmware...\n", priv->ndev->name);
 
-	rc = isl38xx_upload_firmware(priv->firmware,
-#if (LINUX_VERSION_CODE > KERNEL_VERSION(2,5,75))
-		&priv->pdev->dev,
-#else
-		pci_name(priv->pdev),
-#endif
-		priv->device_base,
-		priv->device_host_address);
+	rc = isl_upload_firmware(priv);
 	if (rc) {
 		/* error uploading the firmware */
 		printk(KERN_ERR "%s: could not upload firmware ('%s')\n",
@@ -357,15 +464,8 @@
 	int result = -ETIME;
 	int count;
 
-#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,0)
-	/* This is 2.6 specific, nicer, shorter, but not in 2.4 yet */
 	DEFINE_WAIT(wait);
 	prepare_to_wait(&priv->reset_done, &wait, TASK_UNINTERRUPTIBLE);
-#else
-	DECLARE_WAITQUEUE(wait, current);
-	set_current_state(TASK_UNINTERRUPTIBLE);
-	add_wait_queue(&priv->reset_done, &wait);
-#endif
 	
 	/* now the last step is to reset the interface */
 	isl38xx_interface_reset(priv->device_base, priv->device_host_address);
@@ -390,13 +490,7 @@
 
 	}
 
-#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,0)
-	/* 2.6 specific too */
 	finish_wait(&priv->reset_done, &wait);
-#else
-	remove_wait_queue(&priv->reset_done, &wait);
-	set_current_state(TASK_RUNNING);
-#endif
 
 	if(result)
 		return result;
diff -Naur linux-2.6.6ct/drivers/net/wireless/prism54/islpci_dev.h linux-2.6.6-01/drivers/net/wireless/prism54/islpci_dev.h
--- linux-2.6.6ct/drivers/net/wireless/prism54/islpci_dev.h	2004-06-05 13:39:34.000000000 +0200
+++ linux-2.6.6-01/drivers/net/wireless/prism54/islpci_dev.h	2004-06-05 13:44:14.000000000 +0200
@@ -29,20 +29,6 @@
 #include <net/iw_handler.h>
 #include <linux/list.h>
 
-#if LINUX_VERSION_CODE > KERNEL_VERSION(2,5,41)
-# include <linux/workqueue.h>
-#else
-# include <linux/tqueue.h>
-# define work_struct tq_struct
-# define INIT_WORK INIT_TQUEUE
-# define schedule_work schedule_task
-#endif
-
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2,4,23)
-#define free_netdev(x) kfree(x) 
-#define pci_name(x) x->slot_name 
-#endif
-
 #include "isl_38xx.h"
 #include "isl_oid.h"
 #include "islpci_mgt.h"
@@ -210,12 +196,6 @@
 
 #define ISLPCI_TX_TIMEOUT               (2*HZ)
 
-#if (LINUX_VERSION_CODE <= KERNEL_VERSION(2,5,75))
-# define irqreturn_t void
-# define IRQ_HANDLED
-# define IRQ_NONE
-#endif
-
 irqreturn_t islpci_interrupt(int, void *, struct pt_regs *);
 
 int prism54_post_setup(islpci_private *, int);
diff -Naur linux-2.6.6ct/drivers/net/wireless/prism54/islpci_eth.c linux-2.6.6-01/drivers/net/wireless/prism54/islpci_eth.c
--- linux-2.6.6ct/drivers/net/wireless/prism54/islpci_eth.c	2004-06-05 13:39:34.000000000 +0200
+++ linux-2.6.6-01/drivers/net/wireless/prism54/islpci_eth.c	2004-06-05 13:44:14.000000000 +0200
@@ -26,6 +26,7 @@
 #include <linux/etherdevice.h>
 #include <linux/if_arp.h>
 
+#include "prismcompat.h"
 #include "isl_38xx.h"
 #include "islpci_eth.h"
 #include "islpci_mgt.h"
diff -Naur linux-2.6.6ct/drivers/net/wireless/prism54/islpci_hotplug.c linux-2.6.6-01/drivers/net/wireless/prism54/islpci_hotplug.c
--- linux-2.6.6ct/drivers/net/wireless/prism54/islpci_hotplug.c	2004-06-05 13:39:20.000000000 +0200
+++ linux-2.6.6-01/drivers/net/wireless/prism54/islpci_hotplug.c	2004-06-05 13:44:14.000000000 +0200
@@ -24,6 +24,7 @@
 #include <linux/delay.h>
 #include <linux/init.h> /* For __init, __exit */
 
+#include "prismcompat.h"
 #include "islpci_dev.h"
 #include "islpci_mgt.h"		/* for pc_debug */
 #include "isl_oid.h"
diff -Naur linux-2.6.6ct/drivers/net/wireless/prism54/islpci_mgt.c linux-2.6.6-01/drivers/net/wireless/prism54/islpci_mgt.c
--- linux-2.6.6ct/drivers/net/wireless/prism54/islpci_mgt.c	2004-06-05 13:39:20.000000000 +0200
+++ linux-2.6.6-01/drivers/net/wireless/prism54/islpci_mgt.c	2004-06-05 13:44:14.000000000 +0200
@@ -22,12 +22,12 @@
 #include <linux/netdevice.h>
 #include <linux/module.h>
 #include <linux/pci.h>
-#include <linux/moduleparam.h>
 
 #include <asm/io.h>
 #include <asm/system.h>
 #include <linux/if_arp.h>
 
+#include "prismcompat.h"
 #include "isl_38xx.h"
 #include "islpci_mgt.h"
 #include "isl_oid.h"		/* additional types and defs for isl38xx fw */
@@ -456,21 +456,12 @@
 	const long wait_cycle_jiffies = (ISL38XX_WAIT_CYCLE * 10 * HZ) / 1000;
 	long timeout_left = ISL38XX_MAX_WAIT_CYCLES * wait_cycle_jiffies;
 	int err;
-#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,0)
 	DEFINE_WAIT(wait);
-#else
-	DECLARE_WAITQUEUE(wait, current);
-#endif
 
 	if (down_interruptible(&priv->mgmt_sem))
 		return -ERESTARTSYS;
 
-#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,0)
 	prepare_to_wait(&priv->mgmt_wqueue, &wait, TASK_UNINTERRUPTIBLE);
-#else
-	set_current_state(TASK_UNINTERRUPTIBLE);
-	add_wait_queue(&priv->mgmt_wqueue, &wait);
-#endif
 	err = islpci_mgt_transmit(ndev, operation, oid, senddata, sendlen);
 	if(err)
 		goto out;
@@ -499,12 +490,7 @@
 
 	/* TODO: we should reset the device here */     
  out:
-#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,0)
 	finish_wait(&priv->mgmt_wqueue, &wait);
-#else
-	remove_wait_queue(&priv->mgmt_wqueue, &wait);
-	set_current_state(TASK_RUNNING);
-#endif
 	up(&priv->mgmt_sem);
 	return err;
 }
diff -Naur linux-2.6.6ct/drivers/net/wireless/prism54/islpci_mgt.h linux-2.6.6-01/drivers/net/wireless/prism54/islpci_mgt.h
--- linux-2.6.6ct/drivers/net/wireless/prism54/islpci_mgt.h	2004-06-05 13:39:20.000000000 +0200
+++ linux-2.6.6-01/drivers/net/wireless/prism54/islpci_mgt.h	2004-06-05 13:44:14.000000000 +0200
@@ -24,15 +24,6 @@
 #include <linux/wireless.h>
 #include <linux/skbuff.h>
 
-#if LINUX_VERSION_CODE > KERNEL_VERSION(2,5,41)
-# include <linux/workqueue.h>
-#else
-# include <linux/tqueue.h>
-# define work_struct tq_struct
-# define INIT_WORK INIT_TQUEUE
-# define schedule_work schedule_task
-#endif
-
 /*
  *  Function definitions
  */
diff -Naur linux-2.6.6ct/drivers/net/wireless/prism54/oid_mgt.c linux-2.6.6-01/drivers/net/wireless/prism54/oid_mgt.c
--- linux-2.6.6ct/drivers/net/wireless/prism54/oid_mgt.c	2004-06-05 13:39:34.000000000 +0200
+++ linux-2.6.6-01/drivers/net/wireless/prism54/oid_mgt.c	2004-06-05 13:44:14.000000000 +0200
@@ -16,6 +16,7 @@
  *
  */
 
+#include "prismcompat.h"
 #include "islpci_dev.h"
 #include "islpci_mgt.h"
 #include "isl_oid.h"
diff -Naur linux-2.6.6ct/drivers/net/wireless/prism54/prismcompat.h linux-2.6.6-01/drivers/net/wireless/prism54/prismcompat.h
--- linux-2.6.6ct/drivers/net/wireless/prism54/prismcompat.h	1970-01-01 01:00:00.000000000 +0100
+++ linux-2.6.6-01/drivers/net/wireless/prism54/prismcompat.h	2004-06-05 13:45:32.000000000 +0200
@@ -0,0 +1,46 @@
+/*  
+ *  (C) 2004 Margit Schubert-While <margitsw@t-online.de>
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License as published by
+ *  the Free Software Foundation; either version 2 of the License
+ *
+ *  This program is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *  GNU General Public License for more details.
+ *
+ *  You should have received a copy of the GNU General Public License
+ *  along with this program; if not, write to the Free Software
+ *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ *
+ */
+
+/*  
+ *	Compatibility header file to aid support of different kernel versions
+ */
+
+#ifdef PRISM54_COMPAT24
+#include "prismcompat24.h"
+#else	/* PRISM54_COMPAT24 */
+
+#ifndef _PRISM_COMPAT_H
+#define _PRISM_COMPAT_H
+
+#include <linux/device.h>
+#include <linux/firmware.h>
+#include <linux/config.h>
+#include <linux/moduleparam.h>
+#include <linux/workqueue.h>
+#include <linux/compiler.h>
+
+#if !defined(CONFIG_FW_LOADER) && !defined(CONFIG_FW_LOADER_MODULE)
+#error Firmware Loading is not configured in the kernel !
+#endif
+
+#define prism54_synchronize_irq(irq) synchronize_irq(irq)
+
+#define PRISM_FW_PDEV		&priv->pdev->dev
+
+#endif				/* _PRISM_COMPAT_H */
+#endif				/* PRISM54_COMPAT24 */

--Boundary-00=_IEcwA9i+0zpj2K4--
