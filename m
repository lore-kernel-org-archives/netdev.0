From: sjur.brandeland@stericsson.com
Subject: [PATCH v2] caif-driver: Add CAIF-SPI Protocol driver.
Date: Mon, 21 Jun 2010 23:58:04 +0200
Message-ID: <1277157484-29981-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN
Content-Transfer-Encoding: 7BIT
Cc: marcel@holtmann.org, daniel.martensson@stericsson.com,
	linus.walleij@stericsson.com,
	Sjur Braendeland <sjur.brandeland@stericsson.com>
To: sjurbr@gmail.com, netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from thalia-smout.broadpark.no ([80.202.8.21]:63335 "EHLO
	thalia-smout.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932318Ab0FUV63 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jun 2010 17:58:29 -0400
Received: from terra-smin.broadpark.no ([unknown] [80.202.8.13])
 by thalia-smout.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-12.01 64bit (built Oct 15 2009))
 with ESMTP id <0L4D0047YX1D7Z90@thalia-smout.broadpark.no> for
 netdev@vger.kernel.org; Mon, 21 Jun 2010 23:58:26 +0200 (CEST)
Received: from localhost.localdomain ([unknown] [84.49.77.68])
 by terra-smin.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-12.01 64bit (built Oct 15 2009))
 with ESMTP id <0L4D00KMCX19Y270@terra-smin.broadpark.no> for
 netdev@vger.kernel.org; Mon, 21 Jun 2010 23:58:25 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sjur Braendeland <sjur.brandeland@stericsson.com>

This patch introduces the CAIF SPI Protocol Driver for
CAIF Link Layer.

This driver implements a platform driver to accommodate for a
platform specific SPI device. A general platform driver is not
possible as there are no SPI Slave side Kernel API defined.
A sample CAIF SPI Platform device can be found in
.../Documentation/networking/caif/spi_porting.txt

Signed-off-by: Sjur Braendeland <sjur.brandeland@stericsson.com>
---
David Miller wrote:
>You should never set CONFIG_* defines from the Makefile
>commands, always set them in your Kconfig statements.

Changes from last version: Removed CONFIG_* defines from Makefile.


 Documentation/networking/caif/spi_porting.txt |  208 ++++++
 drivers/net/caif/Kconfig                      |   20 +
 drivers/net/caif/Makefile                     |    4 +
 drivers/net/caif/caif_spi.c                   |  849 +++++++++++++++++++++++++
 drivers/net/caif/caif_spi_slave.c             |  252 ++++++++
 include/net/caif/caif_spi.h                   |  153 +++++
 6 files changed, 1486 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/networking/caif/spi_porting.txt
 create mode 100644 drivers/net/caif/caif_spi.c
 create mode 100644 drivers/net/caif/caif_spi_slave.c
 create mode 100644 include/net/caif/caif_spi.h

diff --git a/Documentation/networking/caif/spi_porting.txt b/Documentation/networking/caif/spi_porting.txt
new file mode 100644
index 0000000..61d7c92
--- /dev/null
+++ b/Documentation/networking/caif/spi_porting.txt
@@ -0,0 +1,208 @@
+- CAIF SPI porting -
+
+- CAIF SPI basics:
+
+Running CAIF over SPI needs some extra setup, owing to the nature of SPI.
+Two extra GPIOs have been added in order to negotiate the transfers
+ between the master and the slave. The minimum requirement for running
+CAIF over SPI is a SPI slave chip and two GPIOs (more details below).
+Please note that running as a slave implies that you need to keep up
+with the master clock. An overrun or underrun event is fatal.
+
+- CAIF SPI framework:
+
+To make porting as easy as possible, the CAIF SPI has been divided in
+two parts. The first part (called the interface part) deals with all
+generic functionality such as length framing, SPI frame negotiation
+and SPI frame delivery and transmission. The other part is the CAIF
+SPI slave device part, which is the module that you have to write if
+you want to run SPI CAIF on a new hardware. This part takes care of
+the physical hardware, both with regard to SPI and to GPIOs.
+
+- Implementing a CAIF SPI device:
+
+	- Functionality provided by the CAIF SPI slave device:
+
+	In order to implement a SPI device you will, as a minimum,
+	need to implement the following
+	functions:
+
+	int (*init_xfer) (struct cfspi_xfer * xfer, struct cfspi_dev *dev):
+
+	This function is called by the CAIF SPI interface to give
+	you a chance to set up your hardware to be ready to receive
+	a stream of data from the master. The xfer structure contains
+	both physical and logical adresses, as well as the total length
+	of the transfer in both directions.The dev parameter can be used
+	to map to different CAIF SPI slave devices.
+
+	void (*sig_xfer) (bool xfer, struct cfspi_dev *dev):
+
+	This function is called by the CAIF SPI interface when the output
+	(SPI_INT) GPIO needs to change state. The boolean value of the xfer
+	variable indicates whether the GPIO should be asserted (HIGH) or
+	deasserted (LOW). The dev parameter can be used to map to different CAIF
+	SPI slave devices.
+
+	- Functionality provided by the CAIF SPI interface:
+
+	void (*ss_cb) (bool assert, struct cfspi_ifc *ifc);
+
+	This function is called by the CAIF SPI slave device in order to
+	signal a change of state of the input GPIO (SS) to the interface.
+	Only active edges are mandatory to be reported.
+	This function can be called from IRQ context (recommended in order
+	not to introduce latency). The ifc parameter should be the pointer
+	returned from the platform probe function in the SPI device structure.
+
+	void (*xfer_done_cb) (struct cfspi_ifc *ifc);
+
+	This function is called by the CAIF SPI slave device in order to
+	report that a transfer is completed. This function should only be
+	called once both the transmission and the reception are completed.
+	This function can be called from IRQ context (recommended in order
+	not to introduce latency). The ifc parameter should be the pointer
+	returned from the platform probe function in the SPI device structure.
+
+	- Connecting the bits and pieces:
+
+		- Filling in the SPI slave device structure:
+
+		Connect the necessary callback functions.
+		Indicate clock speed (used to calculate toggle delays).
+		Chose a suitable name (helps debugging if you use several CAIF
+		SPI slave devices).
+		Assign your private data (can be used to map to your structure).
+
+		- Filling in the SPI slave platform device structure:
+		Add name of driver to connect to ("cfspi_sspi").
+		Assign the SPI slave device structure as platform data.
+
+- Padding:
+
+In order to optimize throughput, a number of SPI padding options are provided.
+Padding can be enabled independently for uplink and downlink transfers.
+Padding can be enabled for the head, the tail and for the total frame size.
+The padding needs to be correctly configured on both sides of the link.
+The padding can be changed via module parameters in cfspi_sspi.c or via
+the sysfs directory of the cfspi_sspi driver (before device registration).
+
+- CAIF SPI device template:
+
+/*
+ *	Copyright (C) ST-Ericsson AB 2010
+ *	Author: Daniel Martensson / Daniel.Martensson@stericsson.com
+ *	License terms: GNU General Public License (GPL), version 2.
+ *
+ */
+
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/device.h>
+#include <linux/wait.h>
+#include <linux/interrupt.h>
+#include <linux/dma-mapping.h>
+#include <net/caif/caif_spi.h>
+
+MODULE_LICENSE("GPL");
+
+struct sspi_struct {
+	struct cfspi_dev sdev;
+	struct cfspi_xfer *xfer;
+};
+
+static struct sspi_struct slave;
+static struct platform_device slave_device;
+
+static irqreturn_t sspi_irq(int irq, void *arg)
+{
+	/* You only need to trigger on an edge to the active state of the
+	 * SS signal. Once a edge is detected, the ss_cb() function should be
+	 * called with the parameter assert set to true. It is OK
+	 * (and even advised) to call the ss_cb() function in IRQ context in
+	 * order not to add any delay. */
+
+	return IRQ_HANDLED;
+}
+
+static void sspi_complete(void *context)
+{
+	/* Normally the DMA or the SPI framework will call you back
+	 * in something similar to this. The only thing you need to
+	 * do is to call the xfer_done_cb() function, providing the pointer
+	 * to the CAIF SPI interface. It is OK to call this function
+	 * from IRQ context. */
+}
+
+static int sspi_init_xfer(struct cfspi_xfer *xfer, struct cfspi_dev *dev)
+{
+	/* Store transfer info. For a normal implementation you should
+	 * set up your DMA here and make sure that you are ready to
+	 * receive the data from the master SPI. */
+
+	struct sspi_struct *sspi = (struct sspi_struct *)dev->priv;
+
+	sspi->xfer = xfer;
+
+	return 0;
+}
+
+void sspi_sig_xfer(bool xfer, struct cfspi_dev *dev)
+{
+	/* If xfer is true then you should assert the SPI_INT to indicate to
+	 * the master that you are ready to recieve the data from the master
+	 * SPI. If xfer is false then you should de-assert SPI_INT to indicate
+	 * that the transfer is done.
+	 */
+
+	struct sspi_struct *sspi = (struct sspi_struct *)dev->priv;
+}
+
+static void sspi_release(struct device *dev)
+{
+	/*
+	 * Here you should release your SPI device resources.
+	 */
+}
+
+static int __init sspi_init(void)
+{
+	/* Here you should initialize your SPI device by providing the
+	 * necessary functions, clock speed, name and private data. Once
+	 * done, you can register your device with the
+	 * platform_device_register() function. This function will return
+	 * with the CAIF SPI interface initialized. This is probably also
+	 * the place where you should set up your GPIOs, interrupts and SPI
+	 * resources. */
+
+	int res = 0;
+
+	/* Initialize slave device. */
+	slave.sdev.init_xfer = sspi_init_xfer;
+	slave.sdev.sig_xfer = sspi_sig_xfer;
+	slave.sdev.clk_mhz = 13;
+	slave.sdev.priv = &slave;
+	slave.sdev.name = "spi_sspi";
+	slave_device.dev.release = sspi_release;
+
+	/* Initialize platform device. */
+	slave_device.name = "cfspi_sspi";
+	slave_device.dev.platform_data = &slave.sdev;
+
+	/* Register platform device. */
+	res = platform_device_register(&slave_device);
+	if (res) {
+		printk(KERN_WARNING "sspi_init: failed to register dev.\n");
+		return -ENODEV;
+	}
+
+	return res;
+}
+
+static void __exit sspi_exit(void)
+{
+	platform_device_del(&slave_device);
+}
+
+module_init(sspi_init);
+module_exit(sspi_exit);
diff --git a/drivers/net/caif/Kconfig b/drivers/net/caif/Kconfig
index 0b28e01..372508e 100644
--- a/drivers/net/caif/Kconfig
+++ b/drivers/net/caif/Kconfig
@@ -14,4 +14,24 @@ config CAIF_TTY
 	identified as N_CAIF. When this ldisc is opened from user space
 	it will redirect the TTY's traffic into the CAIF stack.
 
+config CAIF_SPI_SLAVE
+	tristate "CAIF SPI transport driver for slave interface"
+	default n
+	---help---
+	The CAIF Link layer SPI Protocol driver for Slave SPI interface.
+	This driver implements a platform driver to accommodate for a
+	platform specific SPI device. A sample CAIF SPI Platform device is
+	provided in Documentation/networking/caif/spi_porting.txt
+
+if CAIF_SPI_SLAVE
+config CAIF_SPI_SYNC
+	bool "Next command and length in start of frame"
+	default n
+	---help---
+	Putting the next command and length in the start of the frame can
+	help to synchronize to the next transfer in case of over or under-runs.
+	This option also needs to be enabled on the modem.
+
+endif # CAIF_SPI_SLAVE
+
 endif # CAIF
diff --git a/drivers/net/caif/Makefile b/drivers/net/caif/Makefile
index 52b6d1f..6cbe4b6 100644
--- a/drivers/net/caif/Makefile
+++ b/drivers/net/caif/Makefile
@@ -10,3 +10,7 @@ clean-files:= Module.symvers modules.order *.cmd *~ \
 
 # Serial interface
 obj-$(CONFIG_CAIF_TTY) += caif_serial.o
+
+# SPI slave physical interfaces module
+cfspi_slave-objs := caif_spi.o caif_spi_slave.o
+obj-$(CONFIG_CAIF_SPI_SLAVE) += cfspi_slave.o
diff --git a/drivers/net/caif/caif_spi.c b/drivers/net/caif/caif_spi.c
new file mode 100644
index 0000000..c99b07e
--- /dev/null
+++ b/drivers/net/caif/caif_spi.c
@@ -0,0 +1,849 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2010
+ * Contact: Sjur Brendeland / sjur.brandeland@stericsson.com
+ * Author:  Daniel Martensson / Daniel.Martensson@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2.
+ */
+
+#include <linux/version.h>
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/device.h>
+#include <linux/platform_device.h>
+#include <linux/string.h>
+#include <linux/workqueue.h>
+#include <linux/completion.h>
+#include <linux/list.h>
+#include <linux/interrupt.h>
+#include <linux/dma-mapping.h>
+#include <linux/delay.h>
+#include <linux/sched.h>
+#include <linux/debugfs.h>
+#include <linux/if_arp.h>
+#include <net/caif/caif_layer.h>
+#include <net/caif/caif_spi.h>
+
+#ifndef CONFIG_CAIF_SPI_SYNC
+#define FLAVOR "Flavour: Vanilla.\n"
+#else
+#define FLAVOR "Flavour: Master CMD&LEN at start.\n"
+#endif /* CONFIG_CAIF_SPI_SYNC */
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Daniel Martensson<daniel.martensson@stericsson.com>");
+MODULE_DESCRIPTION("CAIF SPI driver");
+
+static int spi_loop;
+module_param(spi_loop, bool, S_IRUGO);
+MODULE_PARM_DESC(spi_loop, "SPI running in loopback mode.");
+
+/* SPI frame alignment. */
+module_param(spi_frm_align, int, S_IRUGO);
+MODULE_PARM_DESC(spi_frm_align, "SPI frame alignment.");
+
+/* SPI padding options. */
+module_param(spi_up_head_align, int, S_IRUGO);
+MODULE_PARM_DESC(spi_up_head_align, "SPI uplink head alignment.");
+
+module_param(spi_up_tail_align, int, S_IRUGO);
+MODULE_PARM_DESC(spi_up_tail_align, "SPI uplink tail alignment.");
+
+module_param(spi_down_head_align, int, S_IRUGO);
+MODULE_PARM_DESC(spi_down_head_align, "SPI downlink head alignment.");
+
+module_param(spi_down_tail_align, int, S_IRUGO);
+MODULE_PARM_DESC(spi_down_tail_align, "SPI downlink tail alignment.");
+
+#ifdef CONFIG_ARM
+#define BYTE_HEX_FMT "%02X"
+#else
+#define BYTE_HEX_FMT "%02hhX"
+#endif
+#define ON 1
+#define OFF 0
+
+#define SPI_MAX_PAYLOAD_SIZE 4096
+/*
+ * Threshold values for the SPI packet queue. Flowcontrol will be asserted
+ * when the number of packets exceeds HIGH_WATER_MARK. It will not be
+ * deasserted before the number of packets drops below LOW_WATER_MARK.
+ */
+#define LOW_WATER_MARK   100
+#define HIGH_WATER_MARK  (LOW_WATER_MARK*5)
+
+#ifdef CONFIG_UML
+
+/*
+ * We sometimes use UML for debugging, but it cannot handle
+ * dma_alloc_coherent so we have to wrap it.
+ */
+static inline void *dma_alloc(dma_addr_t *daddr)
+{
+	return kmalloc(SPI_DMA_BUF_LEN, GFP_KERNEL);
+}
+
+static inline void dma_free(void *cpu_addr, dma_addr_t handle)
+{
+	kfree(cpu_addr);
+}
+
+#else
+
+static inline void *dma_alloc(dma_addr_t *daddr)
+{
+	return dma_alloc_coherent(NULL, SPI_DMA_BUF_LEN, daddr,
+				GFP_KERNEL);
+}
+
+static inline void dma_free(void *cpu_addr, dma_addr_t handle)
+{
+	dma_free_coherent(NULL, SPI_DMA_BUF_LEN, cpu_addr, handle);
+}
+#endif	/* CONFIG_UML */
+
+#ifdef CONFIG_DEBUG_FS
+
+#define DEBUGFS_BUF_SIZE	4096
+
+static struct dentry *dbgfs_root;
+
+static inline void driver_debugfs_create(void)
+{
+	dbgfs_root = debugfs_create_dir(cfspi_spi_driver.driver.name, NULL);
+}
+
+static inline void driver_debugfs_remove(void)
+{
+	debugfs_remove(dbgfs_root);
+}
+
+static inline void dev_debugfs_rem(struct cfspi *cfspi)
+{
+	debugfs_remove(cfspi->dbgfs_frame);
+	debugfs_remove(cfspi->dbgfs_state);
+	debugfs_remove(cfspi->dbgfs_dir);
+}
+
+static int dbgfs_open(struct inode *inode, struct file *file)
+{
+	file->private_data = inode->i_private;
+	return 0;
+}
+
+static ssize_t dbgfs_state(struct file *file, char __user *user_buf,
+			   size_t count, loff_t *ppos)
+{
+	char *buf;
+	int len = 0;
+	ssize_t size;
+	struct cfspi *cfspi = (struct cfspi *)file->private_data;
+
+	buf = kzalloc(DEBUGFS_BUF_SIZE, GFP_KERNEL);
+	if (!buf)
+		return 0;
+
+	/* Print out debug information. */
+	len += snprintf((buf + len), (DEBUGFS_BUF_SIZE - len),
+			"CAIF SPI debug information:\n");
+
+	len += snprintf((buf + len), (DEBUGFS_BUF_SIZE - len), FLAVOR);
+
+	len += snprintf((buf + len), (DEBUGFS_BUF_SIZE - len),
+			"STATE: %d\n", cfspi->dbg_state);
+	len += snprintf((buf + len), (DEBUGFS_BUF_SIZE - len),
+			"Previous CMD: 0x%x\n", cfspi->pcmd);
+	len += snprintf((buf + len), (DEBUGFS_BUF_SIZE - len),
+			"Current CMD: 0x%x\n", cfspi->cmd);
+	len += snprintf((buf + len), (DEBUGFS_BUF_SIZE - len),
+			"Previous TX len: %d\n", cfspi->tx_ppck_len);
+	len += snprintf((buf + len), (DEBUGFS_BUF_SIZE - len),
+			"Previous RX len: %d\n", cfspi->rx_ppck_len);
+	len += snprintf((buf + len), (DEBUGFS_BUF_SIZE - len),
+			"Current TX len: %d\n", cfspi->tx_cpck_len);
+	len += snprintf((buf + len), (DEBUGFS_BUF_SIZE - len),
+			"Current RX len: %d\n", cfspi->rx_cpck_len);
+	len += snprintf((buf + len), (DEBUGFS_BUF_SIZE - len),
+			"Next TX len: %d\n", cfspi->tx_npck_len);
+	len += snprintf((buf + len), (DEBUGFS_BUF_SIZE - len),
+			"Next RX len: %d\n", cfspi->rx_npck_len);
+
+	size = simple_read_from_buffer(user_buf, count, ppos, buf, len);
+	kfree(buf);
+
+	return size;
+}
+
+static ssize_t print_frame(char *buf, size_t size, char *frm,
+			   size_t count, size_t cut)
+{
+	int len = 0;
+	int i;
+	for (i = 0; i < count; i++) {
+		len += snprintf((buf + len), (size - len),
+					"[0x" BYTE_HEX_FMT "]",
+					frm[i]);
+		if ((i == cut) && (count > (cut * 2))) {
+			/* Fast forward. */
+			i = count - cut;
+			len += snprintf((buf + len), (size - len),
+					"--- %u bytes skipped ---\n",
+					(int)(count - (cut * 2)));
+		}
+
+		if ((!(i % 10)) && i) {
+			len += snprintf((buf + len), (DEBUGFS_BUF_SIZE - len),
+					"\n");
+		}
+	}
+	len += snprintf((buf + len), (DEBUGFS_BUF_SIZE - len), "\n");
+	return len;
+}
+
+static ssize_t dbgfs_frame(struct file *file, char __user *user_buf,
+			   size_t count, loff_t *ppos)
+{
+	char *buf;
+	int len = 0;
+	ssize_t size;
+	struct cfspi *cfspi;
+
+	cfspi = (struct cfspi *)file->private_data;
+	buf = kzalloc(DEBUGFS_BUF_SIZE, GFP_KERNEL);
+	if (!buf)
+		return 0;
+
+	/* Print out debug information. */
+	len += snprintf((buf + len), (DEBUGFS_BUF_SIZE - len),
+			"Current frame:\n");
+
+	len += snprintf((buf + len), (DEBUGFS_BUF_SIZE - len),
+			"Tx data (Len: %d):\n", cfspi->tx_cpck_len);
+
+	len += print_frame((buf + len), (DEBUGFS_BUF_SIZE - len),
+			   cfspi->xfer.va_tx,
+			   (cfspi->tx_cpck_len + SPI_CMD_SZ), 100);
+
+	len += snprintf((buf + len), (DEBUGFS_BUF_SIZE - len),
+			"Rx data (Len: %d):\n", cfspi->rx_cpck_len);
+
+	len += print_frame((buf + len), (DEBUGFS_BUF_SIZE - len),
+			   cfspi->xfer.va_rx,
+			   (cfspi->rx_cpck_len + SPI_CMD_SZ), 100);
+
+	size = simple_read_from_buffer(user_buf, count, ppos, buf, len);
+	kfree(buf);
+
+	return size;
+}
+
+static const struct file_operations dbgfs_state_fops = {
+	.open = dbgfs_open,
+	.read = dbgfs_state,
+	.owner = THIS_MODULE
+};
+
+static const struct file_operations dbgfs_frame_fops = {
+	.open = dbgfs_open,
+	.read = dbgfs_frame,
+	.owner = THIS_MODULE
+};
+
+static inline void dev_debugfs_add(struct cfspi *cfspi)
+{
+	cfspi->dbgfs_dir = debugfs_create_dir(cfspi->pdev->name, dbgfs_root);
+	cfspi->dbgfs_state = debugfs_create_file("state", S_IRUGO,
+						 cfspi->dbgfs_dir, cfspi,
+						 &dbgfs_state_fops);
+	cfspi->dbgfs_frame = debugfs_create_file("frame", S_IRUGO,
+						 cfspi->dbgfs_dir, cfspi,
+						 &dbgfs_frame_fops);
+}
+
+inline void cfspi_dbg_state(struct cfspi *cfspi, int state)
+{
+	cfspi->dbg_state = state;
+};
+#else
+
+static inline void driver_debugfs_create(void)
+{
+}
+
+static inline void driver_debugfs_remove(void)
+{
+}
+
+static inline void dev_debugfs_add(struct cfspi *cfspi)
+{
+}
+
+static inline void dev_debugfs_rem(struct cfspi *cfspi)
+{
+}
+
+inline void cfspi_dbg_state(struct cfspi *cfspi, int state)
+{
+}
+#endif				/* CONFIG_DEBUG_FS */
+
+static LIST_HEAD(cfspi_list);
+static spinlock_t cfspi_list_lock;
+
+/* SPI uplink head alignment. */
+static ssize_t show_up_head_align(struct device_driver *driver, char *buf)
+{
+	return sprintf(buf, "%d\n", spi_up_head_align);
+}
+
+static DRIVER_ATTR(up_head_align, S_IRUSR, show_up_head_align, NULL);
+
+/* SPI uplink tail alignment. */
+static ssize_t show_up_tail_align(struct device_driver *driver, char *buf)
+{
+	return sprintf(buf, "%d\n", spi_up_tail_align);
+}
+
+static DRIVER_ATTR(up_tail_align, S_IRUSR, show_up_tail_align, NULL);
+
+/* SPI downlink head alignment. */
+static ssize_t show_down_head_align(struct device_driver *driver, char *buf)
+{
+	return sprintf(buf, "%d\n", spi_down_head_align);
+}
+
+static DRIVER_ATTR(down_head_align, S_IRUSR, show_down_head_align, NULL);
+
+/* SPI downlink tail alignment. */
+static ssize_t show_down_tail_align(struct device_driver *driver, char *buf)
+{
+	return sprintf(buf, "%d\n", spi_down_tail_align);
+}
+
+static DRIVER_ATTR(down_tail_align, S_IRUSR, show_down_tail_align, NULL);
+
+/* SPI frame alignment. */
+static ssize_t show_frame_align(struct device_driver *driver, char *buf)
+{
+	return sprintf(buf, "%d\n", spi_frm_align);
+}
+
+static DRIVER_ATTR(frame_align, S_IRUSR, show_frame_align, NULL);
+
+int cfspi_xmitfrm(struct cfspi *cfspi, uint8_t *buf, size_t len)
+{
+	uint8_t *dst = buf;
+	caif_assert(buf);
+
+	do {
+		struct sk_buff *skb;
+		struct caif_payload_info *info;
+		int spad = 0;
+		int epad;
+
+		skb = skb_dequeue(&cfspi->chead);
+		if (!skb)
+			break;
+
+		/*
+		 * Calculate length of frame including SPI padding.
+		 * The payload position is found in the control buffer.
+		 */
+		info = (struct caif_payload_info *)&skb->cb;
+
+		/*
+		 * Compute head offset i.e. number of bytes to add to
+		 * get the start of the payload aligned.
+		 */
+		if (spi_up_head_align) {
+			spad = 1 + ((info->hdr_len + 1) & spi_up_head_align);
+			*dst = (uint8_t)(spad - 1);
+			dst += spad;
+		}
+
+		/* Copy in CAIF frame. */
+		skb_copy_bits(skb, 0, dst, skb->len);
+		dst += skb->len;
+		cfspi->ndev->stats.tx_packets++;
+		cfspi->ndev->stats.tx_bytes += skb->len;
+
+		/*
+		 * Compute tail offset i.e. number of bytes to add to
+		 * get the complete CAIF frame aligned.
+		 */
+		epad = (skb->len + spad) & spi_up_tail_align;
+		dst += epad;
+
+		kfree_skb(skb);
+
+	} while ((dst - buf) < len);
+
+	return dst - buf;
+}
+
+int cfspi_xmitlen(struct cfspi *cfspi)
+{
+	struct sk_buff *skb = NULL;
+	int frm_len = 0;
+	int pkts = 0;
+
+	/*
+	 * Decommit previously commited frames.
+	 * skb_queue_splice_tail(&cfspi->chead,&cfspi->qhead)
+	 */
+	while (skb_peek(&cfspi->chead)) {
+		skb = skb_dequeue_tail(&cfspi->chead);
+		skb_queue_head(&cfspi->qhead, skb);
+	}
+
+	do {
+		struct caif_payload_info *info = NULL;
+		int spad = 0;
+		int epad = 0;
+
+		skb = skb_dequeue(&cfspi->qhead);
+		if (!skb)
+			break;
+
+		/*
+		 * Calculate length of frame including SPI padding.
+		 * The payload position is found in the control buffer.
+		 */
+		info = (struct caif_payload_info *)&skb->cb;
+
+		/*
+		 * Compute head offset i.e. number of bytes to add to
+		 * get the start of the payload aligned.
+		 */
+		if (spi_up_head_align)
+			spad = 1 + ((info->hdr_len + 1) & spi_up_head_align);
+
+		/*
+		 * Compute tail offset i.e. number of bytes to add to
+		 * get the complete CAIF frame aligned.
+		 */
+		epad = (skb->len + spad) & spi_up_tail_align;
+
+		if ((skb->len + spad + epad + frm_len) <= CAIF_MAX_SPI_FRAME) {
+			skb_queue_tail(&cfspi->chead, skb);
+			pkts++;
+			frm_len += skb->len + spad + epad;
+		} else {
+			/* Put back packet. */
+			skb_queue_head(&cfspi->qhead, skb);
+		}
+	} while (pkts <= CAIF_MAX_SPI_PKTS);
+
+	/*
+	 * Send flow on if previously sent flow off
+	 * and now go below the low water mark
+	 */
+	if (cfspi->flow_off_sent && cfspi->qhead.qlen < cfspi->qd_low_mark &&
+		cfspi->cfdev.flowctrl) {
+		cfspi->flow_off_sent = 0;
+		cfspi->cfdev.flowctrl(cfspi->ndev, ON);
+	}
+
+	return frm_len;
+}
+
+static void cfspi_ss_cb(bool assert, struct cfspi_ifc *ifc)
+{
+	struct cfspi *cfspi = (struct cfspi *)ifc->priv;
+
+	if (!in_interrupt())
+		spin_lock(&cfspi->lock);
+	if (assert) {
+		set_bit(SPI_SS_ON, &cfspi->state);
+		set_bit(SPI_XFER, &cfspi->state);
+	} else {
+		set_bit(SPI_SS_OFF, &cfspi->state);
+	}
+	if (!in_interrupt())
+		spin_unlock(&cfspi->lock);
+
+	/* Wake up the xfer thread. */
+	wake_up_interruptible(&cfspi->wait);
+}
+
+static void cfspi_xfer_done_cb(struct cfspi_ifc *ifc)
+{
+	struct cfspi *cfspi = (struct cfspi *)ifc->priv;
+
+	/* Transfer done, complete work queue */
+	complete(&cfspi->comp);
+}
+
+static int cfspi_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct cfspi *cfspi = NULL;
+	unsigned long flags;
+	if (!dev)
+		return -EINVAL;
+
+	cfspi = netdev_priv(dev);
+
+	skb_queue_tail(&cfspi->qhead, skb);
+
+	spin_lock_irqsave(&cfspi->lock, flags);
+	if (!test_and_set_bit(SPI_XFER, &cfspi->state)) {
+		/* Wake up xfer thread. */
+		wake_up_interruptible(&cfspi->wait);
+	}
+	spin_unlock_irqrestore(&cfspi->lock, flags);
+
+	/* Send flow off if number of bytes is above high water mark */
+	if (!cfspi->flow_off_sent &&
+		cfspi->qhead.qlen > cfspi->qd_high_mark &&
+		cfspi->cfdev.flowctrl) {
+		cfspi->flow_off_sent = 1;
+		cfspi->cfdev.flowctrl(cfspi->ndev, OFF);
+	}
+
+	return 0;
+}
+
+int cfspi_rxfrm(struct cfspi *cfspi, uint8_t *buf, size_t len)
+{
+	uint8_t *src = buf;
+
+	caif_assert(buf != NULL);
+
+	do {
+		int res;
+		struct sk_buff *skb = NULL;
+		int spad = 0;
+		int epad = 0;
+		uint8_t *dst = NULL;
+		int pkt_len = 0;
+
+		/*
+		 * Compute head offset i.e. number of bytes added to
+		 * get the start of the payload aligned.
+		 */
+		if (spi_down_head_align) {
+			spad = 1 + *src;
+			src += spad;
+		}
+
+		/* Read length of CAIF frame (little endian). */
+		pkt_len = *src;
+		pkt_len |= ((*(src+1)) << 8) & 0xFF00;
+		pkt_len += 2;	/* Add FCS fields. */
+
+		/* Get a suitable caif packet and copy in data. */
+
+		skb = netdev_alloc_skb(cfspi->ndev, pkt_len + 1);
+		caif_assert(skb != NULL);
+
+		dst = skb_put(skb, pkt_len);
+		memcpy(dst, src, pkt_len);
+		src += pkt_len;
+
+		skb->protocol = htons(ETH_P_CAIF);
+		skb_reset_mac_header(skb);
+		skb->dev = cfspi->ndev;
+
+		/*
+		 * Push received packet up the stack.
+		 */
+		if (!spi_loop)
+			res = netif_rx(skb);
+		else
+			res = cfspi_xmit(skb, cfspi->ndev);
+
+		if (!res) {
+			cfspi->ndev->stats.rx_packets++;
+			cfspi->ndev->stats.rx_bytes += pkt_len;
+		} else
+			cfspi->ndev->stats.rx_dropped++;
+
+		/*
+		 * Compute tail offset i.e. number of bytes added to
+		 * get the complete CAIF frame aligned.
+		 */
+		epad = (pkt_len + spad) & spi_down_tail_align;
+		src += epad;
+	} while ((src - buf) < len);
+
+	return src - buf;
+}
+
+static int cfspi_open(struct net_device *dev)
+{
+	netif_wake_queue(dev);
+	return 0;
+}
+
+static int cfspi_close(struct net_device *dev)
+{
+	netif_stop_queue(dev);
+	return 0;
+}
+static const struct net_device_ops cfspi_ops = {
+	.ndo_open = cfspi_open,
+	.ndo_stop = cfspi_close,
+	.ndo_start_xmit = cfspi_xmit
+};
+
+static void cfspi_setup(struct net_device *dev)
+{
+	struct cfspi *cfspi = netdev_priv(dev);
+	dev->features = 0;
+	dev->netdev_ops = &cfspi_ops;
+	dev->type = ARPHRD_CAIF;
+	dev->flags = IFF_NOARP | IFF_POINTOPOINT;
+	dev->tx_queue_len = 0;
+	dev->mtu = SPI_MAX_PAYLOAD_SIZE;
+	dev->destructor = free_netdev;
+	skb_queue_head_init(&cfspi->qhead);
+	skb_queue_head_init(&cfspi->chead);
+	cfspi->cfdev.link_select = CAIF_LINK_HIGH_BANDW;
+	cfspi->cfdev.use_frag = false;
+	cfspi->cfdev.use_stx = false;
+	cfspi->cfdev.use_fcs = false;
+	cfspi->ndev = dev;
+}
+
+int cfspi_spi_probe(struct platform_device *pdev)
+{
+	struct cfspi *cfspi = NULL;
+	struct net_device *ndev;
+	struct cfspi_dev *dev;
+	int res;
+	dev = (struct cfspi_dev *)pdev->dev.platform_data;
+
+	ndev = alloc_netdev(sizeof(struct cfspi),
+			"cfspi%d", cfspi_setup);
+	if (!dev)
+		return -ENODEV;
+
+	cfspi = netdev_priv(ndev);
+	netif_stop_queue(ndev);
+	cfspi->ndev = ndev;
+	cfspi->pdev = pdev;
+
+	/* Set flow info */
+	cfspi->flow_off_sent = 0;
+	cfspi->qd_low_mark = LOW_WATER_MARK;
+	cfspi->qd_high_mark = HIGH_WATER_MARK;
+
+	/* Assign the SPI device. */
+	cfspi->dev = dev;
+	/* Assign the device ifc to this SPI interface. */
+	dev->ifc = &cfspi->ifc;
+
+	/* Allocate DMA buffers. */
+	cfspi->xfer.va_tx = dma_alloc(&cfspi->xfer.pa_tx);
+	if (!cfspi->xfer.va_tx) {
+		printk(KERN_WARNING
+		       "CFSPI: failed to allocate dma TX buffer.\n");
+		res = -ENODEV;
+		goto err_dma_alloc_tx;
+	}
+
+	cfspi->xfer.va_rx = dma_alloc(&cfspi->xfer.pa_rx);
+
+	if (!cfspi->xfer.va_rx) {
+		printk(KERN_WARNING
+		       "CFSPI: failed to allocate dma TX buffer.\n");
+		res = -ENODEV;
+		goto err_dma_alloc_rx;
+	}
+
+	/* Initialize the work queue. */
+	INIT_WORK(&cfspi->work, cfspi_xfer);
+
+	/* Initialize spin locks. */
+	spin_lock_init(&cfspi->lock);
+
+	/* Initialize flow control state. */
+	cfspi->flow_stop = false;
+
+	/* Initialize wait queue. */
+	init_waitqueue_head(&cfspi->wait);
+
+	/* Create work thread. */
+	cfspi->wq = create_singlethread_workqueue(dev->name);
+	if (!cfspi->wq) {
+		printk(KERN_WARNING "CFSPI: failed to create work queue.\n");
+		res = -ENODEV;
+		goto err_create_wq;
+	}
+
+	/* Initialize work queue. */
+	init_completion(&cfspi->comp);
+
+	/* Create debugfs entries. */
+	dev_debugfs_add(cfspi);
+
+	/* Set up the ifc. */
+	cfspi->ifc.ss_cb = cfspi_ss_cb;
+	cfspi->ifc.xfer_done_cb = cfspi_xfer_done_cb;
+	cfspi->ifc.priv = cfspi;
+
+	/* Add CAIF SPI device to list. */
+	spin_lock(&cfspi_list_lock);
+	list_add_tail(&cfspi->list, &cfspi_list);
+	spin_unlock(&cfspi_list_lock);
+
+	/* Schedule the work queue. */
+	queue_work(cfspi->wq, &cfspi->work);
+
+	/* Register network device. */
+	res = register_netdev(ndev);
+	if (res) {
+		printk(KERN_ERR "CFSPI: Reg. error: %d.\n", res);
+		goto err_net_reg;
+	}
+	return res;
+
+ err_net_reg:
+	dev_debugfs_rem(cfspi);
+	set_bit(SPI_TERMINATE, &cfspi->state);
+	wake_up_interruptible(&cfspi->wait);
+	destroy_workqueue(cfspi->wq);
+ err_create_wq:
+	dma_free(cfspi->xfer.va_rx, cfspi->xfer.pa_rx);
+ err_dma_alloc_rx:
+	dma_free(cfspi->xfer.va_tx, cfspi->xfer.pa_tx);
+ err_dma_alloc_tx:
+	free_netdev(ndev);
+
+	return res;
+}
+
+int cfspi_spi_remove(struct platform_device *pdev)
+{
+	struct list_head *list_node;
+	struct list_head *n;
+	struct cfspi *cfspi = NULL;
+	struct cfspi_dev *dev;
+
+	dev = (struct cfspi_dev *)pdev->dev.platform_data;
+	spin_lock(&cfspi_list_lock);
+	list_for_each_safe(list_node, n, &cfspi_list) {
+		cfspi = list_entry(list_node, struct cfspi, list);
+		/* Find the corresponding device. */
+		if (cfspi->dev == dev) {
+			/* Remove from list. */
+			list_del(list_node);
+			/* Free DMA buffers. */
+			dma_free(cfspi->xfer.va_rx, cfspi->xfer.pa_rx);
+			dma_free(cfspi->xfer.va_tx, cfspi->xfer.pa_tx);
+			set_bit(SPI_TERMINATE, &cfspi->state);
+			wake_up_interruptible(&cfspi->wait);
+			destroy_workqueue(cfspi->wq);
+			/* Destroy debugfs directory and files. */
+			dev_debugfs_rem(cfspi);
+			unregister_netdev(cfspi->ndev);
+			spin_unlock(&cfspi_list_lock);
+			return 0;
+		}
+	}
+	spin_unlock(&cfspi_list_lock);
+	return -ENODEV;
+}
+
+static void __exit cfspi_exit_module(void)
+{
+	struct list_head *list_node;
+	struct list_head *n;
+	struct cfspi *cfspi = NULL;
+
+	list_for_each_safe(list_node, n, &cfspi_list) {
+		cfspi = list_entry(list_node, struct cfspi, list);
+		platform_device_unregister(cfspi->pdev);
+	}
+
+	/* Destroy sysfs files. */
+	driver_remove_file(&cfspi_spi_driver.driver,
+			   &driver_attr_up_head_align);
+	driver_remove_file(&cfspi_spi_driver.driver,
+			   &driver_attr_up_tail_align);
+	driver_remove_file(&cfspi_spi_driver.driver,
+			   &driver_attr_down_head_align);
+	driver_remove_file(&cfspi_spi_driver.driver,
+			   &driver_attr_down_tail_align);
+	driver_remove_file(&cfspi_spi_driver.driver, &driver_attr_frame_align);
+	/* Unregister platform driver. */
+	platform_driver_unregister(&cfspi_spi_driver);
+	/* Destroy debugfs root directory. */
+	driver_debugfs_remove();
+}
+
+static int __init cfspi_init_module(void)
+{
+	int result;
+
+	/* Initialize spin lock. */
+	spin_lock_init(&cfspi_list_lock);
+
+	/* Register platform driver. */
+	result = platform_driver_register(&cfspi_spi_driver);
+	if (result) {
+		printk(KERN_ERR "Could not register platform SPI driver.\n");
+		goto err_dev_register;
+	}
+
+	/* Create sysfs files. */
+	result =
+	    driver_create_file(&cfspi_spi_driver.driver,
+			       &driver_attr_up_head_align);
+	if (result) {
+		printk(KERN_ERR "Sysfs creation failed 1.\n");
+		goto err_create_up_head_align;
+	}
+
+	result =
+	    driver_create_file(&cfspi_spi_driver.driver,
+			       &driver_attr_up_tail_align);
+	if (result) {
+		printk(KERN_ERR "Sysfs creation failed 2.\n");
+		goto err_create_up_tail_align;
+	}
+
+	result =
+	    driver_create_file(&cfspi_spi_driver.driver,
+			       &driver_attr_down_head_align);
+	if (result) {
+		printk(KERN_ERR "Sysfs creation failed 3.\n");
+		goto err_create_down_head_align;
+	}
+
+	result =
+	    driver_create_file(&cfspi_spi_driver.driver,
+			       &driver_attr_down_tail_align);
+	if (result) {
+		printk(KERN_ERR "Sysfs creation failed 4.\n");
+		goto err_create_down_tail_align;
+	}
+
+	result =
+	    driver_create_file(&cfspi_spi_driver.driver,
+			       &driver_attr_frame_align);
+	if (result) {
+		printk(KERN_ERR "Sysfs creation failed 5.\n");
+		goto err_create_frame_align;
+	}
+	driver_debugfs_create();
+	return result;
+
+ err_create_frame_align:
+	driver_remove_file(&cfspi_spi_driver.driver,
+			   &driver_attr_down_tail_align);
+ err_create_down_tail_align:
+	driver_remove_file(&cfspi_spi_driver.driver,
+			   &driver_attr_down_head_align);
+ err_create_down_head_align:
+	driver_remove_file(&cfspi_spi_driver.driver,
+			   &driver_attr_up_tail_align);
+ err_create_up_tail_align:
+	driver_remove_file(&cfspi_spi_driver.driver,
+			   &driver_attr_up_head_align);
+ err_create_up_head_align:
+ err_dev_register:
+	return result;
+}
+
+module_init(cfspi_init_module);
+module_exit(cfspi_exit_module);
diff --git a/drivers/net/caif/caif_spi_slave.c b/drivers/net/caif/caif_spi_slave.c
new file mode 100644
index 0000000..83eaf91
--- /dev/null
+++ b/drivers/net/caif/caif_spi_slave.c
@@ -0,0 +1,252 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2010
+ * Contact: Sjur Brendeland / sjur.brandeland@stericsson.com
+ * Author:  Daniel Martensson / Daniel.Martensson@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2.
+ */
+#include <linux/version.h>
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/device.h>
+#include <linux/platform_device.h>
+#include <linux/string.h>
+#include <linux/semaphore.h>
+#include <linux/workqueue.h>
+#include <linux/completion.h>
+#include <linux/list.h>
+#include <linux/interrupt.h>
+#include <linux/dma-mapping.h>
+#include <linux/delay.h>
+#include <linux/sched.h>
+#include <linux/debugfs.h>
+#include <net/caif/caif_spi.h>
+
+#ifndef CONFIG_CAIF_SPI_SYNC
+#define SPI_DATA_POS SPI_CMD_SZ
+static inline int forward_to_spi_cmd(struct cfspi *cfspi)
+{
+	return cfspi->rx_cpck_len;
+}
+#else
+#define SPI_DATA_POS 0
+static inline int forward_to_spi_cmd(struct cfspi *cfspi)
+{
+	return 0;
+}
+#endif
+
+int spi_frm_align = 2;
+int spi_up_head_align = 1;
+int spi_up_tail_align;
+int spi_down_head_align = 3;
+int spi_down_tail_align = 1;
+
+#ifdef CONFIG_DEBUG_FS
+static inline void debugfs_store_prev(struct cfspi *cfspi)
+{
+	/* Store previous command for debugging reasons.*/
+	cfspi->pcmd = cfspi->cmd;
+	/* Store previous transfer. */
+	cfspi->tx_ppck_len = cfspi->tx_cpck_len;
+	cfspi->rx_ppck_len = cfspi->rx_cpck_len;
+}
+#else
+static inline void debugfs_store_prev(struct cfspi *cfspi)
+{
+}
+#endif
+
+void cfspi_xfer(struct work_struct *work)
+{
+	struct cfspi *cfspi;
+	uint8_t *ptr = NULL;
+	unsigned long flags;
+	int ret;
+	cfspi = container_of(work, struct cfspi, work);
+
+	/* Initialize state. */
+	cfspi->cmd = SPI_CMD_EOT;
+
+	for (;;) {
+
+		cfspi_dbg_state(cfspi, CFSPI_STATE_WAITING);
+
+		/* Wait for master talk or transmit event. */
+		wait_event_interruptible(cfspi->wait,
+				 test_bit(SPI_XFER, &cfspi->state) ||
+				 test_bit(SPI_TERMINATE, &cfspi->state));
+
+		if (test_bit(SPI_TERMINATE, &cfspi->state))
+			return;
+
+#if CFSPI_DBG_PREFILL
+		/* Prefill buffers for easier debugging. */
+		memset(cfspi->xfer.va_tx, 0xFF, SPI_DMA_BUF_LEN);
+		memset(cfspi->xfer.va_rx, 0xFF, SPI_DMA_BUF_LEN);
+#endif	/* CFSPI_DBG_PREFILL */
+
+		cfspi_dbg_state(cfspi, CFSPI_STATE_AWAKE);
+
+	/* Check whether we have a committed frame. */
+		if (cfspi->tx_cpck_len) {
+			int len;
+
+			cfspi_dbg_state(cfspi, CFSPI_STATE_FETCH_PKT);
+
+			/* Copy commited SPI frames after the SPI indication. */
+			ptr = (uint8_t *) cfspi->xfer.va_tx;
+			ptr += SPI_IND_SZ;
+			len = cfspi_xmitfrm(cfspi, ptr, cfspi->tx_cpck_len);
+			WARN_ON(len != cfspi->tx_cpck_len);
+	}
+
+		cfspi_dbg_state(cfspi, CFSPI_STATE_GET_NEXT);
+
+		/* Get length of next frame to commit. */
+		cfspi->tx_npck_len = cfspi_xmitlen(cfspi);
+
+		WARN_ON(cfspi->tx_npck_len > SPI_DMA_BUF_LEN);
+
+		/*
+		 * Add indication and length at the beginning of the frame,
+		 * using little endian.
+		 */
+		ptr = (uint8_t *) cfspi->xfer.va_tx;
+		*ptr++ = SPI_CMD_IND;
+		*ptr++ = (SPI_CMD_IND  & 0xFF00) >> 8;
+		*ptr++ = cfspi->tx_npck_len & 0x00FF;
+		*ptr++ = (cfspi->tx_npck_len & 0xFF00) >> 8;
+
+		/* Calculate length of DMAs. */
+		cfspi->xfer.tx_dma_len = cfspi->tx_cpck_len + SPI_IND_SZ;
+		cfspi->xfer.rx_dma_len = cfspi->rx_cpck_len + SPI_CMD_SZ;
+
+		/* Add SPI TX frame alignment padding, if necessary. */
+		if (cfspi->tx_cpck_len &&
+			(cfspi->xfer.tx_dma_len % spi_frm_align)) {
+
+			cfspi->xfer.tx_dma_len += spi_frm_align -
+			    (cfspi->xfer.tx_dma_len % spi_frm_align);
+		}
+
+		/* Add SPI RX frame alignment padding, if necessary. */
+		if (cfspi->rx_cpck_len &&
+			(cfspi->xfer.rx_dma_len % spi_frm_align)) {
+
+			cfspi->xfer.rx_dma_len += spi_frm_align -
+			    (cfspi->xfer.rx_dma_len % spi_frm_align);
+		}
+
+		cfspi_dbg_state(cfspi, CFSPI_STATE_INIT_XFER);
+
+		/* Start transfer. */
+		ret = cfspi->dev->init_xfer(&cfspi->xfer, cfspi->dev);
+		WARN_ON(ret);
+
+		cfspi_dbg_state(cfspi, CFSPI_STATE_WAIT_ACTIVE);
+
+		/*
+		 * TODO: We might be able to make an assumption if this is the
+		 * first loop. Make sure that minimum toggle time is respected.
+		 */
+		udelay(MIN_TRANSITION_TIME_USEC);
+
+		cfspi_dbg_state(cfspi, CFSPI_STATE_SIG_ACTIVE);
+
+		/* Signal that we are ready to recieve data. */
+		cfspi->dev->sig_xfer(true, cfspi->dev);
+
+		cfspi_dbg_state(cfspi, CFSPI_STATE_WAIT_XFER_DONE);
+
+		/* Wait for transfer completion. */
+		wait_for_completion(&cfspi->comp);
+
+		cfspi_dbg_state(cfspi, CFSPI_STATE_XFER_DONE);
+
+		if (cfspi->cmd == SPI_CMD_EOT) {
+			/*
+			 * Clear the master talk bit. A xfer is always at
+			 *  least two bursts.
+			 */
+			clear_bit(SPI_SS_ON, &cfspi->state);
+		}
+
+		cfspi_dbg_state(cfspi, CFSPI_STATE_WAIT_INACTIVE);
+
+		/* Make sure that the minimum toggle time is respected. */
+		if (SPI_XFER_TIME_USEC(cfspi->xfer.tx_dma_len,
+					cfspi->dev->clk_mhz) <
+			MIN_TRANSITION_TIME_USEC) {
+
+			udelay(MIN_TRANSITION_TIME_USEC -
+				SPI_XFER_TIME_USEC
+				(cfspi->xfer.tx_dma_len, cfspi->dev->clk_mhz));
+		}
+
+		cfspi_dbg_state(cfspi, CFSPI_STATE_SIG_INACTIVE);
+
+		/* De-assert transfer signal. */
+		cfspi->dev->sig_xfer(false, cfspi->dev);
+
+		/* Check whether we received a CAIF packet. */
+		if (cfspi->rx_cpck_len) {
+			int len;
+
+			cfspi_dbg_state(cfspi, CFSPI_STATE_DELIVER_PKT);
+
+			/* Parse SPI frame. */
+			ptr = ((uint8_t *)(cfspi->xfer.va_rx + SPI_DATA_POS));
+
+			len = cfspi_rxfrm(cfspi, ptr, cfspi->rx_cpck_len);
+			WARN_ON(len != cfspi->rx_cpck_len);
+		}
+
+		/* Check the next SPI command and length. */
+		ptr = (uint8_t *) cfspi->xfer.va_rx;
+
+		ptr += forward_to_spi_cmd(cfspi);
+
+		cfspi->cmd = *ptr++;
+		cfspi->cmd |= ((*ptr++) << 8) & 0xFF00;
+		cfspi->rx_npck_len = *ptr++;
+		cfspi->rx_npck_len |= ((*ptr++) << 8) & 0xFF00;
+
+		WARN_ON(cfspi->rx_npck_len > SPI_DMA_BUF_LEN);
+		WARN_ON(cfspi->cmd > SPI_CMD_EOT);
+
+		debugfs_store_prev(cfspi);
+
+		/* Check whether the master issued an EOT command. */
+		if (cfspi->cmd == SPI_CMD_EOT) {
+			/* Reset state. */
+			cfspi->tx_cpck_len = 0;
+			cfspi->rx_cpck_len = 0;
+		} else {
+			/* Update state. */
+			cfspi->tx_cpck_len = cfspi->tx_npck_len;
+			cfspi->rx_cpck_len = cfspi->rx_npck_len;
+		}
+
+		/*
+		 * Check whether we need to clear the xfer bit.
+		 * Spin lock needed for packet insertion.
+		 * Test and clear of different bits
+		 * are not supported.
+		 */
+		spin_lock_irqsave(&cfspi->lock, flags);
+		if (cfspi->cmd == SPI_CMD_EOT && !cfspi_xmitlen(cfspi)
+			&& !test_bit(SPI_SS_ON, &cfspi->state))
+			clear_bit(SPI_XFER, &cfspi->state);
+
+		spin_unlock_irqrestore(&cfspi->lock, flags);
+	}
+}
+
+struct platform_driver cfspi_spi_driver = {
+	.probe = cfspi_spi_probe,
+	.remove = cfspi_spi_remove,
+	.driver = {
+		   .name = "cfspi_sspi",
+		   .owner = THIS_MODULE,
+		   },
+};
diff --git a/include/net/caif/caif_spi.h b/include/net/caif/caif_spi.h
new file mode 100644
index 0000000..11df2c5
--- /dev/null
+++ b/include/net/caif/caif_spi.h
@@ -0,0 +1,153 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2010
+ * Author:	Daniel Martensson / Daniel.Martensson@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#ifndef CAIF_SPI_H_
+#define CAIF_SPI_H_
+
+#include <net/caif/caif_device.h>
+
+#define SPI_CMD_WR			0x00
+#define SPI_CMD_RD			0x01
+#define SPI_CMD_EOT			0x02
+#define SPI_CMD_IND			0x04
+
+#define SPI_DMA_BUF_LEN			8192
+
+#define WL_SZ				2	/* 16 bits. */
+#define SPI_CMD_SZ			4	/* 32 bits. */
+#define SPI_IND_SZ			4	/* 32 bits. */
+
+#define SPI_XFER			0
+#define SPI_SS_ON			1
+#define SPI_SS_OFF			2
+#define SPI_TERMINATE			3
+
+/* Minimum time between different levels is 50 microseconds. */
+#define MIN_TRANSITION_TIME_USEC	50
+
+/* Defines for calculating duration of SPI transfers for a particular
+ * number of bytes.
+ */
+#define SPI_MASTER_CLK_MHZ		13
+#define SPI_XFER_TIME_USEC(bytes, clk) (((bytes) * 8) / clk)
+
+/* Normally this should be aligned on the modem in order to benefit from full
+ * duplex transfers. However a size of 8188 provokes errors when running with
+ * the modem. These errors occur when packet sizes approaches 4 kB of data.
+ */
+#define CAIF_MAX_SPI_FRAME 4092
+
+/* Maximum number of uplink CAIF frames that can reside in the same SPI frame.
+ * This number should correspond with the modem setting. The application side
+ * CAIF accepts any number of embedded downlink CAIF frames.
+ */
+#define CAIF_MAX_SPI_PKTS 9
+
+/* Decides if SPI buffers should be prefilled with 0xFF pattern for easier
+ * debugging. Both TX and RX buffers will be filled before the transfer.
+ */
+#define CFSPI_DBG_PREFILL		0
+
+/* Structure describing a SPI transfer. */
+struct cfspi_xfer {
+	uint16_t tx_dma_len;
+	uint16_t rx_dma_len;
+	void *va_tx;
+	dma_addr_t pa_tx;
+	void *va_rx;
+	dma_addr_t pa_rx;
+};
+
+/* Structure implemented by the SPI interface. */
+struct cfspi_ifc {
+	void (*ss_cb) (bool assert, struct cfspi_ifc *ifc);
+	void (*xfer_done_cb) (struct cfspi_ifc *ifc);
+	void *priv;
+};
+
+/* Structure implemented by SPI clients. */
+struct cfspi_dev {
+	int (*init_xfer) (struct cfspi_xfer *xfer, struct cfspi_dev *dev);
+	void (*sig_xfer) (bool xfer, struct cfspi_dev *dev);
+	struct cfspi_ifc *ifc;
+	char *name;
+	uint32_t clk_mhz;
+	void *priv;
+};
+
+/* Enumeration describing the CAIF SPI state. */
+enum cfspi_state {
+	CFSPI_STATE_WAITING = 0,
+	CFSPI_STATE_AWAKE,
+	CFSPI_STATE_FETCH_PKT,
+	CFSPI_STATE_GET_NEXT,
+	CFSPI_STATE_INIT_XFER,
+	CFSPI_STATE_WAIT_ACTIVE,
+	CFSPI_STATE_SIG_ACTIVE,
+	CFSPI_STATE_WAIT_XFER_DONE,
+	CFSPI_STATE_XFER_DONE,
+	CFSPI_STATE_WAIT_INACTIVE,
+	CFSPI_STATE_SIG_INACTIVE,
+	CFSPI_STATE_DELIVER_PKT,
+	CFSPI_STATE_MAX,
+};
+
+/* Structure implemented by SPI physical interfaces. */
+struct cfspi {
+	struct caif_dev_common cfdev;
+	struct net_device *ndev;
+	struct platform_device *pdev;
+	struct sk_buff_head qhead;
+	struct sk_buff_head chead;
+	uint16_t cmd;
+	uint16_t tx_cpck_len;
+	uint16_t tx_npck_len;
+	uint16_t rx_cpck_len;
+	uint16_t rx_npck_len;
+	struct cfspi_ifc ifc;
+	struct cfspi_xfer xfer;
+	struct cfspi_dev *dev;
+	unsigned long state;
+	struct work_struct work;
+	struct workqueue_struct *wq;
+	struct list_head list;
+	int    flow_off_sent;
+	uint32_t qd_low_mark;
+	uint32_t qd_high_mark;
+	struct completion comp;
+	wait_queue_head_t wait;
+	spinlock_t lock;
+	bool flow_stop;
+#ifdef CONFIG_DEBUG_FS
+	enum cfspi_state dbg_state;
+	uint16_t pcmd;
+	uint16_t tx_ppck_len;
+	uint16_t rx_ppck_len;
+	struct dentry *dbgfs_dir;
+	struct dentry *dbgfs_state;
+	struct dentry *dbgfs_frame;
+#endif				/* CONFIG_DEBUG_FS */
+};
+
+extern int spi_frm_align;
+extern int spi_up_head_align;
+extern int spi_up_tail_align;
+extern int spi_down_head_align;
+extern int spi_down_tail_align;
+extern struct platform_driver cfspi_spi_driver;
+
+void cfspi_dbg_state(struct cfspi *cfspi, int state);
+int cfspi_xmitfrm(struct cfspi *cfspi, uint8_t *buf, size_t len);
+int cfspi_xmitlen(struct cfspi *cfspi);
+int cfspi_rxfrm(struct cfspi *cfspi, uint8_t *buf, size_t len);
+int cfspi_spi_remove(struct platform_device *pdev);
+int cfspi_spi_probe(struct platform_device *pdev);
+int cfspi_xmitfrm(struct cfspi *cfspi, uint8_t *buf, size_t len);
+int cfspi_xmitlen(struct cfspi *cfspi);
+int cfspi_rxfrm(struct cfspi *cfspi, uint8_t *buf, size_t len);
+void cfspi_xfer(struct work_struct *work);
+
+#endif				/* CAIF_SPI_H_ */
-- 
1.6.3.3

