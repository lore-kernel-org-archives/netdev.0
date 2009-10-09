From: sjur.brandeland@stericsson.com
Subject: [PATCH] [CAIF-RFC 6/8-v2] CAIF Protocol Stack
Date: Fri, 09 Oct 2009 15:39:29 +0200
Message-ID: <1255095571-6501-7-git-send-email-sjur.brandeland@stericsson.com>
References: <1255095571-6501-1-git-send-email-sjur.brandeland@stericsson.com>
 <1255095571-6501-2-git-send-email-sjur.brandeland@stericsson.com>
 <1255095571-6501-3-git-send-email-sjur.brandeland@stericsson.com>
 <1255095571-6501-4-git-send-email-sjur.brandeland@stericsson.com>
 <1255095571-6501-5-git-send-email-sjur.brandeland@stericsson.com>
 <1255095571-6501-6-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN
Content-Transfer-Encoding: 7BIT
Cc: stefano.babic@babic.homelinux.org, randy.dunlap@oracle.com,
	kim.xx.lilliestierna@stericsson.com,
	christian.bejram@stericsson.com, daniel.martensson@stericsson.com,
	Sjur Braendeland <sjur.brandeland@stericsson.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bgo1smout1.broadpark.no ([217.13.4.94]:51694 "EHLO
	bgo1smout1.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755540AbZJINmm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Oct 2009 09:42:42 -0400
Received: from bgo1sminn1.broadpark.no ([217.13.4.93])
 by bgo1smout1.broadpark.no
 (Sun Java(tm) System Messaging Server 6.3-3.01 (built Jul 12 2007; 32bit))
 with ESMTP id <0KR90029T1Z5VL90@bgo1smout1.broadpark.no> for
 netdev@vger.kernel.org; Fri, 09 Oct 2009 15:40:17 +0200 (CEST)
Received: from localhost.localdomain ([84.49.68.131])
 by bgo1sminn1.broadpark.no
 (Sun Java(tm) System Messaging Server 6.3-3.01 (built Jul 12 2007; 32bit))
 with ESMTP id <0KR900DNY1Y4LSP0@bgo1sminn1.broadpark.no> for
 netdev@vger.kernel.org; Fri, 09 Oct 2009 15:40:17 +0200 (CEST)
In-reply-to: <1255095571-6501-6-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sjur Braendeland <sjur.brandeland@stericsson.com>

Change-Id: I7888e9b5aed8914036a87fdc6622697eacb27b2e
Signed-off-by: Sjur Braendeland <sjur.brandeland@stericsson.com>
---
 drivers/net/caif/Kconfig      |   23 +++
 drivers/net/caif/Makefile     |   26 ++++
 drivers/net/caif/phyif_loop.c |  308 +++++++++++++++++++++++++++++++++++++++++
 drivers/net/caif/phyif_ser.c  |  189 +++++++++++++++++++++++++
 4 files changed, 546 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/caif/Kconfig
 create mode 100644 drivers/net/caif/Makefile
 create mode 100644 drivers/net/caif/phyif_loop.c
 create mode 100644 drivers/net/caif/phyif_ser.c

diff --git a/drivers/net/caif/Kconfig b/drivers/net/caif/Kconfig
new file mode 100644
index 0000000..bc19226
--- /dev/null
+++ b/drivers/net/caif/Kconfig
@@ -0,0 +1,23 @@
+#
+# CAIF Physical drivers
+#
+
+if CAIF
+
+comment "CAIF physical drivers"
+
+config CAIF_TTY
+	tristate "CAIF TTY transport driver"
+	default n
+	---help---
+	The CAIF TTY transport driver.
+	If you say yes here you will also need to build a userspace utility to set the line disicpline on the
+	tty, see Documentation/CAIF/linedsc.
+
+config CAIF_LOOPBACK
+	tristate "CAIF loopback driver test driver"
+	default n
+	---help---
+	Loopback test driver
+
+endif # CAIF
diff --git a/drivers/net/caif/Makefile b/drivers/net/caif/Makefile
new file mode 100644
index 0000000..a84049a
--- /dev/null
+++ b/drivers/net/caif/Makefile
@@ -0,0 +1,26 @@
+
+ifeq ($(CONFIG_CAIF_USE_PLAIN),1)
+CFPKT:=plain
+else
+CFPKT:=skbuff
+CAIF_FLAGS+=-DCAIF_USE_SKB
+endif
+
+ifeq ($(CONFIG_CAIF_DEBUG),1)
+CAIF_FLAGS+=-DCAIF_DEBUG_ON
+endif
+
+
+ccflags-y :=  $(CAIF_FLAGS)
+
+
+clean-dirs:= .tmp_versions
+clean-files:= Module.symvers modules.order *.cmd *~ \
+
+
+# --- Physical drivers --
+# Serial interface
+obj-$(CONFIG_CAIF_TTY) += phyif_ser.o
+
+# Loop back
+obj-$(CONFIG_CAIF_LOOPBACK) += phyif_loop.o
\ No newline at end of file
diff --git a/drivers/net/caif/phyif_loop.c b/drivers/net/caif/phyif_loop.c
new file mode 100644
index 0000000..bb17bc7
--- /dev/null
+++ b/drivers/net/caif/phyif_loop.c
@@ -0,0 +1,308 @@
+/*
+ *	Copyright (C) ST-Ericsson AB 2009
+ *
+ *	Author: Daniel Martensson / Daniel.Martensson@stericsson.com
+ *		Per Sigmond / Per.Sigmond@stericsson.com
+ *
+ *	License terms: GNU General Public License (GPL), version 2.
+ *
+ */
+
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/device.h>
+#include <linux/workqueue.h>
+#include <linux/spinlock.h>
+
+
+#include <linux/semaphore.h>
+#include <linux/list.h>
+#include <linux/sched.h>
+/* Caif header files. */
+#include <net/caif/caif_log.h>
+#include <net/caif/generic/caif_layer.h>
+#include <net/caif/generic/cfcnfg.h>
+#include <net/caif/generic/cfpkt.h>
+
+#include <net/caif/caif_chr.h>
+
+#include <linux/delay.h>
+
+
+MODULE_LICENSE("GPL");
+
+
+
+static int reentrant;
+static int direct;
+static int serial;
+module_param(reentrant, bool, S_IRUGO);
+module_param(direct, bool, S_IRUGO);
+module_param(serial, bool, S_IRUGO);
+MODULE_PARM_DESC(reentrant,
+		 "Reentrant or not (defualt is workqueue implementation)");
+MODULE_PARM_DESC(direct,
+		 "Direct mode, looping packets directly back up the stack");
+
+static layer_t cf_phy;
+static layer_t loop_phy;
+static spinlock_t ring_buffer_lock;
+
+
+/* Start ring buffer */
+#define RING_MAX_BUFFERS 16384
+
+struct ring_buffer_element {
+	struct _cfpkt_t *cfpkt;
+};
+
+static struct {
+	struct ring_buffer_element ring_buffer[RING_MAX_BUFFERS];
+	int head_index;
+	int tail_index;
+} my_ring_buffer;
+
+#define ring_buffer_index_plus_one(index) \
+    ((index+1) < RING_MAX_BUFFERS ? (index + 1) : 0)
+
+#define ring_buffer_increment_tail(rb) \
+    ((rb)->tail_index = ring_buffer_index_plus_one((rb)->tail_index))
+
+#define ring_buffer_increment_head(rb) \
+    ((rb)->head_index = ring_buffer_index_plus_one((rb)->head_index))
+
+#define ring_buffer_empty(rb) ((rb)->head_index == (rb)->tail_index)
+#define ring_buffer_full(rb) (ring_buffer_index_plus_one((rb)->head_index)\
+			      == (rb)->tail_index)
+#define ring_buffer_tail_element(rb) ((rb)->ring_buffer[(rb)->tail_index])
+#define ring_buffer_head_element(rb) ((rb)->ring_buffer[(rb)->head_index])
+#define ring_buffer_size(rb) (((rb)->head_index >= (rb)->tail_index)) ?\
+  ((rb)->head_index - (rb)->tail_index) : \
+    (RING_MAX_BUFFERS - ((rb)->tail_index - (rb)->head_index))
+/* End ring buffer */
+
+
+
+static void work_func(struct work_struct *work);
+static struct workqueue_struct *ploop_work_queue;
+static DECLARE_WORK(loop_work, work_func);
+static wait_queue_head_t buf_available;
+
+
+#define phyif_assert(assert) BUG_ON(!(assert))
+
+
+
+
+
+
+
+
+
+
+
+
+
+static void work_func(struct work_struct *work)
+{
+
+	CAIFLOG_ENTER("");
+
+	while (!ring_buffer_empty(&my_ring_buffer)) {
+		struct _cfpkt_t *cfpkt;
+
+		/* Get packet */
+		cfpkt = ring_buffer_tail_element(&my_ring_buffer).cfpkt;
+		ring_buffer_tail_element(&my_ring_buffer).cfpkt = NULL;
+
+		ring_buffer_increment_tail(&my_ring_buffer);
+
+		/* Wake up writer */
+		wake_up_interruptible(&buf_available);
+
+
+		/* Push received packet up the caif stack. */
+		cf_phy.up->receive(cf_phy.up, cfpkt);
+
+	}
+
+	/* Release access to loop queue. */
+	CAIFLOG_EXIT("");
+}
+
+static int cf_phy_modemcmd(layer_t *layr, caif_modemcmd_t ctrl)
+{
+	switch (ctrl) {
+	case _CAIF_MODEMCMD_PHYIF_USEFULL:
+		CAIFLOG_TRACE("phyif_loop:Usefull");
+
+		try_module_get(THIS_MODULE);
+		break;
+	case _CAIF_MODEMCMD_PHYIF_USELESS:
+		CAIFLOG_TRACE("phyif_loop:Useless");
+		module_put(THIS_MODULE);
+		break;
+	default:
+		break;
+	}
+	return 0;
+}
+
+static int cf_phy_tx(layer_t *layr, transmt_info *info, cfpkt_t *pkt)
+{
+	int ret;
+	CAIFLOG_ENTER("");
+
+	/* Push received packet up the loop stack. */
+	ret = loop_phy.up->receive(loop_phy.up, pkt);
+
+	CAIFLOG_EXIT("");
+	return ret;
+}
+
+
+static int
+loop_phy_tx_reent(layer_t *layr, transmt_info *info, struct _cfpkt_t *cfpkt)
+{
+	CAIFLOG_ENTER("");
+
+	/* Push received packet up the caif stack. */
+	cf_phy.up->receive(cf_phy.up, cfpkt);
+
+	CAIFLOG_EXIT("");
+	return 0;
+}
+
+
+static int
+loop_phy_tx(layer_t *layr, transmt_info *info, struct _cfpkt_t *cfpkt)
+{
+
+	CAIFLOG_ENTER("");
+
+	/* Block writer as long as ring buffer is full */
+
+	spin_lock(&ring_buffer_lock);
+
+	while (ring_buffer_full(&my_ring_buffer)) {
+		spin_unlock(&ring_buffer_lock);
+
+		if (wait_event_interruptible
+		    (buf_available,
+		     !ring_buffer_full(&my_ring_buffer)) == -ERESTARTSYS) {
+			printk(KERN_WARNING
+			       "loop_phy_tx: "
+			       "wait_event_interruptible woken by a signal\n");
+			return -ERESTARTSYS;
+		}
+
+
+		spin_lock(&ring_buffer_lock);
+	}
+
+
+	ring_buffer_head_element(&my_ring_buffer).cfpkt = cfpkt;
+	ring_buffer_increment_head(&my_ring_buffer);
+	spin_unlock(&ring_buffer_lock);
+
+	/* Add this  work to the queue as we don't want to
+	 * loop in the same context.
+	 */
+	(void) queue_work(ploop_work_queue, &loop_work);
+
+	CAIFLOG_EXIT("");
+	return 0;
+}
+
+static int cf_phy_tx_direct(layer_t *layr, transmt_info *info, cfpkt_t *pkt)
+{
+	int ret;
+
+	CAIFLOG_ENTER("");
+	CAIFLOG_TRACE("[%s] up:%p pkt:%p\n", __func__, cf_phy.up,
+		    pkt);
+	/* Push received packet back up the caif stack,
+	 * via loop_phy_tx's work-queue */
+	ret = loop_phy_tx(layr, info, pkt);
+	CAIFLOG_EXIT("");
+	return ret;
+}
+
+
+static int __init phyif_loop_init(void)
+{
+	int result;
+
+	CAIFLOG_ENTER("");
+	printk("\nCompiled:%s:%s\nreentrant=%s direct=%s\n",
+	       __DATE__, __TIME__,
+	       (reentrant ? "yes" : "no"),
+	       (direct ? "yes" : "no"));
+	/* Fill in some information about our PHYs. */
+	if (direct) {
+		cf_phy.transmit = cf_phy_tx_direct;
+		cf_phy.receive = NULL;
+	} else {
+		cf_phy.transmit = cf_phy_tx;
+		cf_phy.receive = NULL;
+	}
+	if (reentrant)
+		loop_phy.transmit = loop_phy_tx_reent;
+	else
+		loop_phy.transmit = loop_phy_tx;
+
+	loop_phy.receive = NULL;
+	cf_phy.modemcmd = cf_phy_modemcmd;
+
+	/* Create work thread. */
+	ploop_work_queue = create_singlethread_workqueue("phyif_loop");
+
+	init_waitqueue_head(&buf_available);
+
+	/* Initialize ring buffer */
+	memset(&my_ring_buffer, 0, sizeof(my_ring_buffer));
+	spin_lock_init(&ring_buffer_lock);
+	cf_phy.id = -1;
+	if (serial)
+		result =
+		    caifdev_phy_register(&cf_phy, CFPHYTYPE_SERIAL,
+					 CFPHYPREF_UNSPECIFIED);
+	else
+		result =
+		    caifdev_phy_register(&cf_phy, CFPHYTYPE_MSL,
+					 CFPHYPREF_UNSPECIFIED);
+
+	printk(KERN_WARNING "phyif_loop: ID = %d\n", cf_phy.id);
+
+	if (result < 0) {
+		printk(KERN_WARNING
+		       "phyif_loop: err: %d, can't register phy.\n", result);
+	}
+
+	if (serial)
+		result =
+		    caifdev_phy_loop_register(&loop_phy, CFPHYTYPE_SERIAL);
+	else
+		result = caifdev_phy_loop_register(&loop_phy, CFPHYTYPE_MSL);
+
+	if (result < 0) {
+		printk(KERN_WARNING
+		       "phyif_loop: err: %d, can't register loop phy.\n",
+		       result);
+	}
+
+	printk(KERN_WARNING "phyif_loop: ID = %d\n", cf_phy.id);
+	CAIFLOG_EXIT("");
+	return result;
+}
+
+static void __exit phyif_loop_exit(void)
+{
+	printk(KERN_WARNING "phyif_loop: ID = %d\n", cf_phy.id);
+
+	caifdev_phy_unregister(&cf_phy);
+	cf_phy.id = -1;
+}
+
+module_init(phyif_loop_init);
+module_exit(phyif_loop_exit);
diff --git a/drivers/net/caif/phyif_ser.c b/drivers/net/caif/phyif_ser.c
new file mode 100644
index 0000000..6e1337c
--- /dev/null
+++ b/drivers/net/caif/phyif_ser.c
@@ -0,0 +1,189 @@
+/*
+*      Copyright (C) ST-Ericsson AB 2009
+*
+*      Author: Daniel Martensson / Daniel.Martensson@stericsson.com
+*
+*      License terms: GNU General Public License (GPL), version 2.
+*
+*/
+
+
+
+
+
+#include <linux/version.h>
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/device.h>
+#include <linux/tty.h>
+
+#include <net/caif/generic/caif_layer.h>
+#include <net/caif/generic/cfcnfg.h>
+#include <net/caif/generic/cfpkt.h>
+#include <net/caif/caif_chr.h>
+
+
+MODULE_LICENSE("GPL");
+
+module_param(serial_use_stx, bool, S_IRUGO);
+MODULE_PARM_DESC(serial_use_stx, "STX enabled or not.");
+
+#define WRITE_BUF_SIZE	256
+#define READ_BUF_SIZE	256
+
+unsigned char sbuf_wr[WRITE_BUF_SIZE];
+
+layer_t ser_phy;
+
+#if (LINUX_VERSION_CODE >= KERNEL_VERSION(2, 6, 27))
+static struct tty_ldisc_ops phyif_ldisc;
+#else
+static struct tty_ldisc phyif_ldisc;
+#endif				/* KERN_VERSION_2_6_27 */
+
+struct tty_struct *pser_tty;
+
+
+static bool tx_started;
+
+static int ser_open(struct tty_struct *tty)
+{
+	int result;
+
+	pser_tty = tty;
+
+	/* Configure the attached TTY. */
+
+	/* Register physical interface. */
+	result =
+	    caifdev_phy_register(&ser_phy, CFPHYTYPE_SERIAL,
+				 CFPHYPREF_LOW_LAT);
+	if (result < 0) {
+		printk(KERN_WARNING
+		       "phyif_ser: err: %d, can't register phy.\n", result);
+	}
+
+	return result;
+}
+
+static void ser_receive(struct tty_struct *tty, const u8 *data,
+			char *flags, int count)
+{
+	cfpkt_t *pkt = NULL;
+	caif_packet_funcs_t f;
+	/*int i; */
+
+	/* Get caif packet functions. */
+	f = cfcnfg_get_packet_funcs();
+
+
+	/* Workaround for garbage at start of transmission,
+	 * only enable if STX handling is not enables */
+	if (!serial_use_stx && !tx_started) {
+		printk(KERN_WARNING
+		       "Bytes received before first transmission."
+		       " Bytes discarded. \n");
+		return;
+	}
+
+	/* Get a suitable caif packet and copy in data. */
+	pkt = f.cfpkt_create_recv_pkt(data, count);
+
+	/* Push received packet up the stack. */
+	ser_phy.up->receive(ser_phy.up, pkt);
+}
+
+
+int ser_phy_tx(layer_t *layr, transmt_info *info, struct _cfpkt_t *cfpkt)
+{
+	size_t tty_wr, actual_len;
+	bool cont;
+	caif_packet_funcs_t f;
+	/*int i; */
+
+	if (!pser_tty)
+		return CFGLU_ENOTCONN;
+
+	/* Get caif packet functions. */
+	f = cfcnfg_get_packet_funcs();
+
+	/* NOTE: This workaround is not really needed when STX is enabled.
+	 *  Remove? */
+	if (tx_started == false)
+		tx_started = true;
+
+
+	do {
+		char *bufp;
+		/* By default we assume that we will extract
+		 * all data in one go. */
+		cont = false;
+
+		/* Extract data from the packet. */
+		f.cfpkt_extract(cfpkt, sbuf_wr, WRITE_BUF_SIZE, &actual_len);
+
+		/* Check if we need to extract more data. */
+		if (actual_len == WRITE_BUF_SIZE)
+			cont = true;
+
+		bufp = sbuf_wr;
+		/* Write the data on the tty driver.
+		 * NOTE: This loop will be spinning until UART is ready for
+		 *	 sending data.
+		 *	 It might be looping forever if we get UART problems.
+		 *	 This part should be re-written!
+		 */
+		do {
+			tty_wr =
+			    pser_tty->ops->write(pser_tty, bufp, actual_len);
+			/* When not whole buffer is written,
+			 * forward buffer pointer and try again */
+			actual_len -= tty_wr;
+			bufp += tty_wr;
+		} while (actual_len);
+	} while (cont == true);
+
+	/* The packet is sent. As we have come to the end of the
+	 * line we need to free the packet. */
+	f.cfpkt_destroy(cfpkt);
+
+	return 0;
+}
+
+static int __init phyif_ser_init(void)
+{
+	int result;
+
+	/* Fill in some information about our PHY. */
+	ser_phy.transmit = ser_phy_tx;
+	ser_phy.receive = NULL;
+	ser_phy.ctrlcmd = NULL;
+	ser_phy.modemcmd = NULL;
+
+	memset(&phyif_ldisc, 0, sizeof(phyif_ldisc));
+	phyif_ldisc.magic = TTY_LDISC_MAGIC;
+	phyif_ldisc.name = "n_phyif";
+	phyif_ldisc.open = ser_open;
+	phyif_ldisc.receive_buf = ser_receive;
+	phyif_ldisc.owner = THIS_MODULE;
+
+	result = tty_register_ldisc(N_MOUSE, &phyif_ldisc);
+
+	if (result < 0) {
+		printk(KERN_WARNING
+		       "phyif_ser: err: %d, can't register ldisc.\n", result);
+		return result;
+	}
+
+	return result;
+}
+
+static void __exit phyif_ser_exit(void)
+{
+	(void) tty_unregister_ldisc(N_MOUSE);
+}
+
+module_init(phyif_ser_init);
+module_exit(phyif_ser_exit);
+
+MODULE_ALIAS_LDISC(N_MOUSE);
-- 
1.6.0.4

