From: sjur.brandeland@stericsson.com
Subject: [PATCH 6/8] [RFC] CAIF Protocol Stack
Date: Wed, 23 Sep 2009 19:31:31 +0200
Message-ID: <1253727091-10383-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN
Content-Transfer-Encoding: 7BIT
Cc: Kim.xx.Lilliestierna@ericsson.com, sjur.brandeland@stericsson.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bgo1smout1.broadpark.no ([217.13.4.94]:55556 "EHLO
	bgo1smout1.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753243AbZIWSbl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2009 14:31:41 -0400
Received: from bgo1sminn1.broadpark.no ([217.13.4.93])
 by bgo1smout1.broadpark.no
 (Sun Java(tm) System Messaging Server 6.3-3.01 (built Jul 12 2007; 32bit))
 with ESMTP id <0KQF003RKQ0MF560@bgo1smout1.broadpark.no> for
 netdev@vger.kernel.org; Wed, 23 Sep 2009 19:31:34 +0200 (CEST)
Received: from localhost.localdomain ([84.49.68.131])
 by bgo1sminn1.broadpark.no
 (Sun Java(tm) System Messaging Server 6.3-3.01 (built Jul 12 2007; 32bit))
 with ESMTP id <0KQF004H3Q0KNGG0@bgo1sminn1.broadpark.no> for
 netdev@vger.kernel.org; Wed, 23 Sep 2009 19:31:34 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kim Lilliestierna <Kim.xx.Lilliestierna@ericsson.com>

Signed-off-by: sjur.brandeland@stericsson.com

---
 drivers/net/caif/Kconfig      |   64 +++
 drivers/net/caif/Makefile     |   29 ++
 drivers/net/caif/chnl_tty.c   |  220 +++++++++++
 drivers/net/caif/phyif_loop.c |  309 +++++++++++++++
 drivers/net/caif/phyif_ser.c  |  189 +++++++++
 drivers/net/caif/phyif_shm.c  |  870 +++++++++++++++++++++++++++++++++++++++++
 drivers/net/caif/shm.h        |   95 +++++
 drivers/net/caif/shm_cfgifc.c |   60 +++
 drivers/net/caif/shm_mbxifc.c |   98 +++++
 drivers/net/caif/shm_smbx.c   |   81 ++++
 10 files changed, 2015 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/caif/Kconfig
 create mode 100644 drivers/net/caif/Makefile
 create mode 100644 drivers/net/caif/chnl_tty.c
 create mode 100644 drivers/net/caif/phyif_loop.c
 create mode 100644 drivers/net/caif/phyif_ser.c
 create mode 100644 drivers/net/caif/phyif_shm.c
 create mode 100644 drivers/net/caif/shm.h
 create mode 100644 drivers/net/caif/shm_cfgifc.c
 create mode 100644 drivers/net/caif/shm_mbxifc.c
 create mode 100644 drivers/net/caif/shm_smbx.c

diff --git a/drivers/net/caif/Kconfig b/drivers/net/caif/Kconfig
new file mode 100644
index 0000000..3cbe302
--- /dev/null
+++ b/drivers/net/caif/Kconfig
@@ -0,0 +1,64 @@
+#
+# CAIF net configurations
+#
+
+if CAIF
+
+# Include physical drivers
+# should be broken out into its own config file
+# source "drivers/net/caif/Kconfig"
+
+# Some options here should be mande platform dependent
+
+comment "CAIF physical drivers"
+
+config CAIF_TTY
+	tristate "CAIF TTY transport driver "
+	default CAIF
+	---help---
+	The CAIF TTY transport driver
+	If sou say yes here you will also need to build a users space utility to set the line disicpline on the the
+	tty, see Documentation/net/caif/examples/linedsc
+
+config CAIF_SHM
+	tristate "CAIF shared memory transport driver"
+	default n
+	---help---
+	The caif low level driver for the shared memory driver
+	Be aware that if you enable this you need to also enable a low level shared memory driver
+        the default is to include the loopback test driver.
+
+config CAIF_LOOPBACK
+	tristate "CAIF loopback driver test driver"
+	default CAIF
+	---help---
+	Loopback test driver
+
+if CAIF_SHM
+
+comment "CAIF shared memory low level physical drivers"
+
+config CAIF_SHM_LOOPBACK
+	tristate "Caif shared memory loopback driver"
+	default CAIF_USE_SHM
+	---help---
+	loop back driver that emulates a real shared memory transport
+	mainly used for debugging.
+
+config CAIF_MBXIF
+	tristate "Caif shared mailbox interface"
+	default CAIF_SHM
+	---help---
+	Generic shared mailbox interface
+
+config CAIF_SMBX
+	tristate "Use Simluated Mail box"
+	default CAIF_MBXIF
+	---help---
+	Answer y if you whant to use a simulated mail box interface for caif shared memory transport
+	Mainly used for debugging and as example driver
+	This can also be built as a module
+
+endif #CAIF_USE_SHM
+
+endif # CAIF
diff --git a/drivers/net/caif/Makefile b/drivers/net/caif/Makefile
new file mode 100644
index 0000000..f983289
--- /dev/null
+++ b/drivers/net/caif/Makefile
@@ -0,0 +1,29 @@
+ifeq ($(CONFIG_CAIF_DEBUG),1)
+CAIF_FLAGS+=-DCAIF_DEBUG_ON
+endif
+
+
+ccflags-y := -DCAIF_KERNEL -DKERN_VERSION_2_6_27 $(CAIF_FLAGS) -Iinclude/net/caif -Iinclude/linux/caif -Iinclude/net/caif/generic
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
+
+# Shared memmory
+obj-$(CONFIG_CAIF_SHM) += phyif_shm.o
+
+# Mail box geneirc
+obj-$(CONFIG_CAIF_MBXIF) += shm_mbxifc.o
+
+# Simulated mail box
+obj-$(CONFIG_CAIF_SMBX) += shm_smbx.o
+
+export-objs := caif_chr.o caif_test_chdev.o caif_kapi_test.o
diff --git a/drivers/net/caif/chnl_tty.c b/drivers/net/caif/chnl_tty.c
new file mode 100644
index 0000000..03fe0d3
--- /dev/null
+++ b/drivers/net/caif/chnl_tty.c
@@ -0,0 +1,220 @@
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
+#include <linux/fs.h>
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/tty.h>
+#include <linux/tty_flip.h>
+
+#include "caif_layer.h"
+#include "cfcnfg.h"
+#include "cfpkt.h"
+
+#include "caif_chr.h"
+#include "caif_ioctl.h"
+
+MODULE_LICENSE("GPL");
+
+#define TTY_CHNL_DEVICES 1
+
+static bool tty_registered;
+
+struct chnl_tty {
+	layer_t chnl;
+	struct tty_driver *tty_drv;
+	struct tty_struct *tty;
+};
+
+static struct chnl_tty ttydev;
+
+static int chnl_recv_cb(layer_t *layr, cfpkt_t *pkt)
+{
+	unsigned char *flip = NULL;
+	caif_packet_funcs_t f;
+	int len;
+	size_t max;
+	int count;
+
+	/* Get caif packet functions. */
+	f = cfcnfg_get_packet_funcs();
+
+	len = cfpkt_getlen(pkt);
+
+	printk(KERN_INFO "AT received: %d bytes.\n", len);
+
+	/* Get a buffer from the TTY framework. */
+	count = tty_prepare_flip_string(ttydev.tty, &flip, len);
+
+	if (len > count) {
+		printk(KERN_INFO
+		       "TTY buffer to small, dropping %d bytes.\n",
+		       (len - count));
+	}
+
+	/* Check max length that can be copied. */
+	max = len > count ? count : len;
+
+	/* Extract packet to the TTY buffer. */
+	f.cfpkt_extract(pkt, flip, count, &max);
+
+	/* Liberate packet. */
+	f.cfpkt_destroy(pkt);
+
+	/* Push data to the ldisc. */
+	tty_schedule_flip(ttydev.tty);
+
+	return 0;
+}
+
+static void chnl_flowctrl_cb(layer_t *layr, caif_flowctrl_t on)
+{
+	printk("AT flowctrl func called flow: %s.\n",
+	       on == CAIF_FLOWCTRL_ON ? "ON" : "OFF or INIT");
+
+	if (on == CAIF_FLOWCTRL_INIT && tty_registered == false) {
+		/* Register a tty device. */
+		struct device *dev =
+		    tty_register_device(ttydev.tty_drv, 0, NULL);
+		if (IS_ERR(dev)) {
+			int result = PTR_ERR(dev);
+			printk(KERN_WARNING
+			       "chnl: err: %d, can't register tty device.\n",
+			       result);
+			goto err_tty_device_register_failed;
+		}
+		tty_registered = true;
+	}
+
+err_tty_device_register_failed:
+	return;
+}
+
+int chnl_tty_open(struct tty_struct *tty, struct file *filp)
+{
+	ttydev.tty = tty;
+
+	return 0;
+}
+
+void chnl_tty_close(struct tty_struct *tty, struct file *filp)
+{
+	ttydev.tty = NULL;
+}
+
+int chnl_tty_write(struct tty_struct *tty, const unsigned char *buf, int count)
+{
+	cfpkt_t *pkt = NULL;
+	caif_packet_funcs_t f;
+
+	/* Get caif packet functions. */
+	f = cfcnfg_get_packet_funcs();
+
+	/* Create a caif packet based on the tty buffer. */
+	pkt = f.cfpkt_create_xmit_pkt(buf, count);
+	if (!pkt) {
+		printk(KERN_INFO "chnl_tty_write: cfpkt_create failed.\n");
+		goto err_cfpkt_create;
+	}
+
+	/* Send the packet down the stack. */
+	ttydev.chnl.dn->transmit(ttydev.chnl.dn, NULL, pkt);
+
+	return count;
+
+err_cfpkt_create:
+	return 0;
+}
+
+struct tty_operations chnl_tty_ops = {
+	.open = chnl_tty_open,
+	.close = chnl_tty_close,
+	.write = chnl_tty_write,
+};
+
+void chnl_tty_exit_module(void)
+{
+	if (ttydev.tty) {
+		tty_unregister_device(ttydev.tty_drv, 0);
+		ttydev.tty = NULL;
+	}
+	tty_unregister_driver(ttydev.tty_drv);
+	put_tty_driver(ttydev.tty_drv);
+	ttydev.tty_drv = NULL;
+}
+
+int chnl_tty_init_module(void)
+{
+	struct caif_service_config config;
+	int result;
+
+	ttydev.tty_drv = alloc_tty_driver(TTY_CHNL_DEVICES);
+	if (ttydev.tty_drv == NULL) {
+		printk(KERN_WARNING
+		       "chnl_tty_init_module: err: "
+		       "can't allocate tty driver.\n");
+		result = -ENOMEM;
+		goto err_alloc_tty_driver_failed;
+	}
+
+	ttydev.tty_drv->driver_name = "caif_tty";
+	ttydev.tty_drv->name = "cftty";
+	ttydev.tty_drv->type = TTY_DRIVER_TYPE_SERIAL;
+	ttydev.tty_drv->subtype = SERIAL_TYPE_NORMAL;
+	ttydev.tty_drv->init_termios = tty_std_termios;
+	ttydev.tty_drv->flags = TTY_DRIVER_REAL_RAW | TTY_DRIVER_DYNAMIC_DEV;
+
+	/* Register the TTY driver. */
+	tty_set_operations(ttydev.tty_drv, &chnl_tty_ops);
+
+	result = tty_register_driver(ttydev.tty_drv);
+	if (result < 0) {
+		printk(KERN_WARNING
+		       "chnl_tty_init_module: err: "
+		       "%d, can't register tty driver.\n",
+		       result);
+		goto err_tty_driver_register_failed;
+	}
+
+	/* Fill in channel information. */
+	ttydev.chnl.receive = chnl_recv_cb;
+	ttydev.chnl.flowctrl = chnl_flowctrl_cb;
+
+	memset(&config, 0, sizeof(config));
+	config.service = CAIF_SRVC_AT;
+	config.phy_type = CAIF_PHY_LOW_LAT;
+	config.priority = CAIF_PRIO_NORMAL;
+
+	/* Register this channel. */
+	result = caifdev_adapt_register(&config, &ttydev.chnl);
+	if (result < 0) {
+		printk(KERN_WARNING
+		       "chnl_tty_init_module: err:"
+		       " %d, can't register channel.\n",
+		       result);
+		goto err_register_chnl;
+	}
+
+	return result;
+
+err_register_chnl:
+	tty_unregister_driver(ttydev.tty_drv);
+err_tty_driver_register_failed:
+	put_tty_driver(ttydev.tty_drv);
+	ttydev.tty_drv = NULL;
+err_alloc_tty_driver_failed:
+	return -ENODEV;
+}
+
+module_init(chnl_tty_init_module);
+module_exit(chnl_tty_exit_module);
diff --git a/drivers/net/caif/phyif_loop.c b/drivers/net/caif/phyif_loop.c
new file mode 100644
index 0000000..2bfa42b
--- /dev/null
+++ b/drivers/net/caif/phyif_loop.c
@@ -0,0 +1,309 @@
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
+#include "caif_log.h"
+#include "caif_layer.h"
+#include "cfcnfg.h"
+#include "cfpkt.h"
+
+#include "caif_chr.h"
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
+	/*phyif_assert( !ring_buffer_full(&my_ring_buffer) );*/
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
+static void phyif_loop_exit(void)
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
index 0000000..5dc3da6
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
+#include "caif_layer.h"
+#include "cfcnfg.h"
+#include "cfpkt.h"
+#include "caif_chr.h"
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
+static void phyif_ser_exit(void)
+{
+	(void) tty_unregister_ldisc(N_MOUSE);
+}
+
+module_init(phyif_ser_init);
+module_exit(phyif_ser_exit);
+
+MODULE_ALIAS_LDISC(N_MOUSE);
diff --git a/drivers/net/caif/phyif_shm.c b/drivers/net/caif/phyif_shm.c
new file mode 100644
index 0000000..c192d11
--- /dev/null
+++ b/drivers/net/caif/phyif_shm.c
@@ -0,0 +1,870 @@
+/*
+*      Copyright (C) ST-Ericsson AB 2009
+*
+*      Author: Daniel Martensson / Daniel.Martensson@stericsson.com
+*
+*      License terms: GNU General Public License (GPL), version 2.
+*
+*/
+
+#include <linux/version.h>
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/device.h>
+#include <linux/spinlock.h>
+#include <linux/sched.h>
+
+#if (LINUX_VERSION_CODE >= KERNEL_VERSION(2, 6, 27))
+#include <linux/semaphore.h>
+#else
+#include <linux/semaphore.h>
+#endif				/* KERN_VERSION_2_6_27 */
+#include <linux/list.h>
+#include <linux/workqueue.h>
+
+#ifdef PHYIF_SHM_USE_DMA
+#include <linux/dma-mapping.h>
+#endif				/* PHYIF_SHM_USE_DMA */
+#include <linux/io.h>
+
+/* Caif header files. */
+#include "caif_layer.h"
+#include "cfcnfg.h"
+#include "cfpkt.h"
+
+/* Caif linux header files. */
+#include "caif_chr.h"
+#include "shm.h"
+
+MODULE_LICENSE("GPL");
+
+#define SHM_INSTANCES		1
+
+static char *mbxifc_name = "cfmbx";
+module_param(mbxifc_name, charp, S_IRUGO);
+MODULE_PARM_DESC(mbxifc_name,
+		 "Name of the shared memory mailbox interface.");
+
+static char *mbxcfg_name = "cfcfg";
+module_param(mbxcfg_name, charp, S_IRUGO);
+MODULE_PARM_DESC(mbxcfg_name,
+		 "Name of the shared memory configuration interface.");
+
+#define SHM_CMD_DUMMY		0x00
+
+#define SHM_CMD_MASK		(0x3F << 10)
+#define SHM_FULL_MASK		(0x0F << 0)
+#define SHM_EMPTY_MASK		(0x0F << 4)
+
+#define SHM_SET_CMD(x)		((x & 0x3F) << 10)
+#define SHM_GET_CMD(x)		((x >>	10) & 0x3F)
+
+#define SHM_SET_FULL(x)		(((x+1) & 0x0F) << 0)
+#define SHM_GET_FULL(x)		(((x >> 0) & 0x0F) - 1)
+
+#define SHM_SET_EMPTY(x)	(((x+1) & 0x0F) << 4)
+#define SHM_GET_EMPTY(x)	(((x >> 4) & 0x0F) - 1)
+
+typedef struct {
+	/* Offset from start of shared memory area to start of
+	 * shared memory CAIF frame. */
+	uint32 frm_ofs;
+	/* Length of CAIF frame. */
+	uint32 frm_len;
+} shm_pck_desc_t, *pshm_pck_desc_t;
+
+typedef struct {
+	/* Number of bytes of padding before the CAIF frame. */
+	uint8 hdr_ofs;
+} shm_caif_frm_t, *pshm_caif_frm_t;
+
+/* Maximum number of CAIF buffers per shared memory buffer. */
+#define SHM_MAX_CAIF_FRMS_PER_BUF	10
+
+/* Size in bytes of the descriptor area
+ * (With end of descriptor signalling). */
+#define SHM_CAIF_DESC_SIZE	((SHM_MAX_CAIF_FRMS_PER_BUF + 1) * \
+				  sizeof(shm_pck_desc_t))
+
+/* Offset to the first CAIF frame within a shared memory buffer.
+ * Aligned on 32 bytes. */
+#define SHM_CAIF_FRM_OFS	(SHM_CAIF_DESC_SIZE + (SHM_CAIF_DESC_SIZE % 32))
+/* Number of bytes for CAIF shared memory header. */
+#define SHM_HDR_LEN					1
+/* Number of bytes for alignment of the CAIF service layer payload. */
+#define SHM_PAYLOAD_ALIGN_LEN		4
+/* Number of padding bytes for the complete CAIF frame. */
+#define SHM_FRM_PAD_LEN				4
+
+typedef struct _shm_layer_t {
+	layer_t shm_phy;
+	shm_cfgifc_t *cfg_ifc;
+	shm_mbxifc_t *mbx_ifc;
+	char cfg_name[16];
+	shm_mbxclient_t mbx_client;
+	char mbx_name[16];
+#ifdef PHYIF_SHM_USE_DMA
+	struct dmaifc_t *dma_ifc;
+#endif				/* PHYIF_SHM_USE_DMA */
+	/* Lists for shared memory buffer synchronization and handling. */
+	struct list_head tx_empty_list;
+	struct list_head rx_empty_list;
+	struct list_head tx_pend_list;
+	struct list_head rx_pend_list;
+	struct list_head tx_full_list;
+	struct list_head rx_full_list;
+	struct work_struct sig_work;
+	struct work_struct rx_work;
+	struct work_struct flow_work;
+	struct workqueue_struct *sig_work_queue;
+	struct workqueue_struct *rx_work_queue;
+	struct workqueue_struct *flow_work_queue;
+
+    /* wait queue for sender to check for space to write in mailbox */
+    wait_queue_head_t mbx_space_wq;
+	int tx_empty_available;
+
+} shm_layer_t;
+
+static shm_layer_t shm_layer[SHM_INSTANCES];
+
+/* Shared memory buffer structure. */
+typedef struct {
+	int index;
+	int len;
+	int frames;
+	unsigned char *desc_ptr;
+	int frm_ofs;
+	int phy_addr;
+#ifdef PHYIF_SHM_USE_DMA
+	dma_addr_t *dma_ptr;
+#endif				/* PHYIF_SHM_USE_DMA */
+	struct list_head list;
+} shm_buf_t;
+
+static DEFINE_SPINLOCK(lock);
+
+static void phyif_shm_sig_work_func(struct work_struct *work);
+static void phyif_shm_rx_work_func(struct work_struct *work);
+static void phyif_shm_flow_work_func(struct work_struct *work);
+
+static void phyif_shm_sig_work_func(struct work_struct *work)
+{
+	/* TODO: We assume that this call is not reentrant as
+	 *	 that might change the order of the buffers which
+	 * is not allowed. Option is to lock the whole function.    */
+
+	int ret;
+	uint16 mbox_msg;
+	shm_layer_t *pshm = container_of(work, shm_layer_t, sig_work);
+
+	do {
+		shm_buf_t *pbuf;
+		unsigned long flags;
+
+		/* Initialize mailbox message. */
+		mbox_msg = 0x00;
+
+		spin_lock(&lock);
+
+		/* Check for pending transmit buffers. */
+		if (!list_empty(&pshm->tx_pend_list)) {
+			pbuf =
+			    list_entry(pshm->tx_pend_list.next,
+				       shm_buf_t, list);
+			list_del_init(&pbuf->list);
+
+			/* Release mutex. */
+			spin_unlock(&lock);
+
+			/* Grab spin lock. */
+			spin_lock_irqsave(&lock, flags);
+
+			list_add_tail(&pbuf->list, &pshm->tx_full_list);
+
+			/* Release spin lock. */
+			spin_unlock_irqrestore(&lock, flags);
+
+			/* Value index is never changed,
+			 * read access should be safe. */
+			mbox_msg |= SHM_SET_FULL(pbuf->index);
+
+			spin_lock(&lock);
+		}
+
+		/* Check for pending receive buffers. */
+		if (!list_empty(&pshm->rx_pend_list)) {
+
+			pbuf = list_entry(pshm->rx_pend_list.next,
+				       shm_buf_t, list);
+			list_del_init(&pbuf->list);
+
+			/* Release mutex. */
+			spin_unlock(&lock);
+
+			/* Grab spin lock. */
+			spin_lock_irqsave(&lock, flags);
+
+			list_add_tail(&pbuf->list, &pshm->rx_empty_list);
+
+			/* Release spin lock. */
+			spin_unlock_irqrestore(&lock, flags);
+
+			/* Value index is never changed,
+			 * read access should be safe. */
+			mbox_msg |= SHM_SET_EMPTY(pbuf->index);
+
+			spin_lock(&lock);
+		}
+
+		/* Release mutex. */
+		spin_unlock(&lock);
+
+		if (mbox_msg) {
+			do {
+				long timeout = 3;
+				ret = pshm->mbx_ifc->send_msg(mbox_msg,
+					pshm->mbx_ifc->priv);
+
+				if (ret) {
+					interruptible_sleep_on_timeout(
+						&pshm->mbx_space_wq, timeout);
+				}
+
+			} while (ret);
+		}
+
+	} while (mbox_msg);
+}
+
+static void phyif_shm_rx_work_func(struct work_struct *work)
+{
+	shm_buf_t *pbuf;
+	caif_packet_funcs_t f;
+	struct _cfpkt_t *pkt;
+	unsigned long flags;
+	shm_layer_t *pshm;
+	/* TODO: We assume that this call is not reentrant as that might
+	 *	 change the order of the buffers which is not possible.
+	 *	 Option is to lock the whole function.	  */
+
+	pshm = container_of(work, shm_layer_t, rx_work);
+
+	/* Get caif packet functions. */
+	f = cfcnfg_get_packet_funcs();
+
+	do {
+		pshm_pck_desc_t pck_desc;
+
+		/* Grab spin lock. */
+		spin_lock_irqsave(&lock, flags);
+
+		/* Check for received buffers. */
+	if (list_empty(&pshm->rx_full_list)) {
+			/* Release spin lock. */
+			spin_unlock_irqrestore(&lock, flags);
+			break;
+		}
+		pbuf =
+		    list_entry(pshm->rx_full_list.next, shm_buf_t, list);
+		list_del_init(&pbuf->list);
+
+		/* Release spin lock. */
+		spin_unlock_irqrestore(&lock, flags);
+
+		/* Retrieve pointer to start of the packet descriptor area. */
+		pck_desc = (pshm_pck_desc_t) pbuf->desc_ptr;
+
+		/* Check if descriptor contains a CAIF shared memory frame. */
+		while (pck_desc->frm_ofs) {
+			unsigned int frm_buf_ofs;
+			unsigned int frm_pck_ofs;
+			unsigned int frm_pck_len;
+
+			/* Check if offset is within buffer limits (lower). */
+			if (pck_desc->frm_ofs <
+			    (pbuf->phy_addr - shm_base_addr)) {
+				printk(KERN_WARNING
+				       "phyif_shm_rx_work_func:"
+				       " Frame offset too small: %d\n",
+				       pck_desc->frm_ofs);
+				break;
+			}
+
+			/* Check if offset is within buffer limits (higher). */
+			if (pck_desc->frm_ofs >
+			    ((pbuf->phy_addr - shm_base_addr) +
+			     pbuf->len)) {
+				printk(KERN_WARNING
+				       "phyif_shm_rx_work_func:"
+				       " Frame offset too big: %d\n",
+				       pck_desc->frm_ofs);
+				break;
+			}
+
+			/* Calculate offset from start of buffer. */
+			frm_buf_ofs =
+			    pck_desc->frm_ofs - (pbuf->phy_addr -
+						 shm_base_addr);
+
+			/* Calculate offset and length of CAIF packet while
+			 * taking care of the shared memory header. */
+			frm_pck_ofs =
+			    frm_buf_ofs + SHM_HDR_LEN +
+			    (*(pbuf->desc_ptr + frm_buf_ofs));
+			frm_pck_len =
+			    (pck_desc->frm_len - SHM_HDR_LEN -
+			     (*(pbuf->desc_ptr + frm_buf_ofs)));
+
+			/* Check if CAIF packet is within buffer limits. */
+			if ((frm_pck_ofs + pck_desc->frm_len) > pbuf->len) {
+				printk(KERN_WARNING
+				       "phyif_shm_rx_work_func: "
+				       "caif packet too big: offset:"
+				       "%d, len: %d\n",
+				       frm_pck_ofs, pck_desc->frm_len);
+				break;
+			}
+
+			/* Get a suitable caif packet and copy in data. */
+			pkt =
+			    f.cfpkt_create_recv_pkt((pbuf->desc_ptr +
+						     frm_pck_ofs),
+						    frm_pck_len);
+
+			/* Push received packet up the stack. */
+			pshm->shm_phy.up->receive(pshm->shm_phy.up, pkt);
+
+			/* Move to next packet descriptor. */
+			pck_desc++;
+		};
+
+		spin_lock(&lock);
+		list_add_tail(&pbuf->list, &pshm->rx_pend_list);
+		spin_unlock(&lock);
+
+	} while (1);
+
+	/* Schedule signaling work queue. */
+	(void) queue_work(pshm->sig_work_queue, &pshm->sig_work);
+}
+
+static void phyif_shm_flow_work_func(struct work_struct *work)
+{
+	shm_layer_t *pshm;
+
+	pshm = container_of(work, shm_layer_t, flow_work);
+
+	if (!pshm->shm_phy.up->ctrlcmd) {
+		printk(KERN_WARNING "phyif_shm_flow_work_func: No flow up.\n");
+		return;
+	}
+
+	/* Re-enable the flow.*/
+	pshm->shm_phy.up->ctrlcmd(pshm->shm_phy.up,
+		_CAIF_CTRLCMD_PHYIF_FLOW_ON_IND, 0);
+}
+
+static int phyif_shm_mbx_msg_cb(u16 mbx_msg, void *priv)
+{
+	shm_layer_t *pshm;
+	shm_buf_t *pbuf;
+	unsigned long flags;
+
+	pshm = (shm_layer_t *) priv;
+	/* TODO: Do we need the spin locks since this is assumed to be
+	 * called from an IRQ context. */
+
+	/*	 We are also assuming that this call is not be reentrant as
+	 *	 that might change the order of the buffers which is not
+	 *	 possible. Option is to lock the whole function. */
+
+	/* Check for received buffers. */
+	if (mbx_msg & SHM_FULL_MASK) {
+		int idx;
+
+		/* Grab spin lock. */
+		spin_lock_irqsave(&lock, flags);
+
+		/* Check if we have any outstanding buffers. */
+		if (list_empty(&pshm->rx_empty_list)) {
+			/* Release spin lock. */
+			spin_unlock_irqrestore(&lock, flags);
+
+			/* We print even in IRQ context... */
+			printk(KERN_WARNING
+			    "phyif_shm_mbx_msg_cb:"
+			    " No empty Rx buffers to fill: msg:%x \n",
+			    mbx_msg);
+
+			/* Bail out. */
+			goto err_rx_sync;
+		}
+
+		pbuf =
+		    list_entry(pshm->rx_empty_list.next, shm_buf_t, list);
+		idx = pbuf->index;
+
+		/* Check buffer synchronization. */
+		if (idx != SHM_GET_FULL(mbx_msg)) {
+			/* Release spin lock. */
+			spin_unlock_irqrestore(&lock, flags);
+
+			/* We print even in IRQ context... */
+			printk(KERN_WARNING
+			       "phyif_shm_mbx_msg_cb: RX full out of sync:"
+			       " idx:%d, msg:%x \n",
+			       idx, mbx_msg);
+
+			/* Bail out. */
+			goto err_rx_sync;
+		}
+
+		list_del_init(&pbuf->list);
+		list_add_tail(&pbuf->list, &pshm->rx_full_list);
+
+		/* Release spin lock. */
+		spin_unlock_irqrestore(&lock, flags);
+
+		/* Schedule RX work queue. */
+		(void) queue_work(pshm->rx_work_queue, &pshm->rx_work);
+	}
+
+err_rx_sync:
+
+	/* Check for emptied buffers. */
+	if (mbx_msg & SHM_EMPTY_MASK) {
+		int idx;
+
+		/* Grab spin lock. */
+		spin_lock_irqsave(&lock, flags);
+
+		/* Check if we have any outstanding buffers. */
+	if (list_empty(&pshm->tx_full_list)) {
+			/* Release spin lock. */
+			spin_unlock_irqrestore(&lock, flags);
+
+			/* We print even in IRQ context... */
+			printk(KERN_WARNING
+				"phyif_shm_mbx_msg_cb:"
+				" No TX to empty: msg:%x \n",
+			       mbx_msg);
+
+			/* Bail out. */
+			goto err_tx_sync;
+		}
+
+		pbuf =
+		    list_entry(pshm->tx_full_list.next, shm_buf_t, list);
+		idx = pbuf->index;
+
+		/* Check buffer synchronization. */
+		if (idx != SHM_GET_EMPTY(mbx_msg)) {
+			/* Release spin lock. */
+			spin_unlock_irqrestore(&lock, flags);
+
+			/* We print even in IRQ context... */
+			printk(KERN_WARNING
+			       "phyif_shm_mbx_msg_cb: TX empty out of sync:"
+			       " idx:%d, msg:%x \n",
+			       idx, mbx_msg);
+
+			/* Bail out. */
+			goto err_tx_sync;
+		}
+
+		list_del_init(&pbuf->list);
+
+		/* Reset buffer parameters. */
+		pbuf->frames = 0;
+		pbuf->frm_ofs = SHM_CAIF_FRM_OFS;
+
+		list_add_tail(&pbuf->list, &pshm->tx_empty_list);
+
+		/* Check if we have to wake up transmitter. */
+		if (!pshm->tx_empty_available) {
+			pshm->tx_empty_available = 1;
+
+			/* Release spin lock. */
+			spin_unlock_irqrestore(&lock, flags);
+
+			/* Schedule flow re-enable work queue. */
+			(void) queue_work(pshm->flow_work_queue,
+					  &pshm->flow_work);
+
+		} else {
+			/* Release spin lock. */
+			spin_unlock_irqrestore(&lock, flags);
+		}
+	}
+
+err_tx_sync:
+
+	/* Check for command buffers.
+	if (mbx_msg & SHM_CMD_MASK) {
+	}
+	*/
+
+    return ESUCCESS;
+}
+
+void shm_phy_fctrl(layer_t *layr, caif_ctrlcmd_t on, int phyid)
+{
+	/* We have yet not added flow control. */
+}
+
+static int shm_send_pkt(shm_layer_t *pshm, cfpkt_t *cfpkt, bool append)
+{
+	unsigned long flags;
+	shm_buf_t *pbuf;
+	unsigned int extlen;
+	unsigned int frmlen = 0;
+	pshm_pck_desc_t pck_desc;
+	pshm_caif_frm_t frm;
+	caif_packet_funcs_t f;
+
+	/* Get caif packet functions. */
+	f = cfcnfg_get_packet_funcs();
+
+	/* Grab spin lock. */
+	spin_lock_irqsave(&lock, flags);
+
+	if (append) {
+		if (list_empty(&pshm->tx_pend_list)) {
+			/* Release spin lock. */
+			spin_unlock_irqrestore(&lock, flags);
+			return CFGLU_ERETRY;
+		}
+
+		/* Get the last pending buffer. */
+		pbuf = list_entry(pshm->tx_pend_list.prev, shm_buf_t, list);
+
+		/* Check that we don't exceed the descriptor area. */
+		if (pbuf->frames >= SHM_MAX_CAIF_FRMS_PER_BUF) {
+			/* Release spin lock. */
+			spin_unlock_irqrestore(&lock, flags);
+			return CFGLU_ERETRY;
+		}
+	} else {
+		if (list_empty(&pshm->tx_empty_list)) {
+			/* Update blocking condition. */
+			pshm->tx_empty_available = 0;
+
+			/* Release spin lock. */
+			spin_unlock_irqrestore(&lock, flags);
+
+			if (!pshm->shm_phy.up->ctrlcmd) {
+				printk(KERN_WARNING "shm_phy_tx: No flow up.\n");
+				return CFGLU_ERETRY;
+			}
+
+			pshm->shm_phy.up->ctrlcmd(pshm->shm_phy.up,
+				_CAIF_CTRLCMD_PHYIF_FLOW_OFF_IND, 0);
+
+			return CFGLU_ERETRY;
+		}
+
+		/* Get the first free buffer. */
+		pbuf = list_entry(pshm->tx_empty_list.next, shm_buf_t, list);
+	}
+
+	list_del_init(&pbuf->list);
+
+	/* Release spin lock. */
+	spin_unlock_irqrestore(&lock, flags);
+
+	/* TODO: The CAIF stack will have to give a hint on what is
+	 *	 payload in order to align it. */
+	frm = (pshm_caif_frm_t) (pbuf->desc_ptr + pbuf->frm_ofs);
+	frm->hdr_ofs = 0;
+	frmlen += SHM_HDR_LEN + frm->hdr_ofs;
+
+	/* Add length of CAIF frame. */
+	frmlen += f.cfpkt_getlen(cfpkt);
+
+	/* Add tail padding if needed. */
+	if (frmlen % SHM_FRM_PAD_LEN)
+		frmlen += SHM_FRM_PAD_LEN - (frmlen % SHM_FRM_PAD_LEN);
+
+
+	/* Verify that packet, header and additional padding can fit
+	 * within the buffer frame area. */
+	if (frmlen >= (pbuf->len - pbuf->frm_ofs)) {
+		if (append) {
+			/* Put back packet as end of pending queue. */
+			list_add_tail(&pbuf->list, &pshm->tx_pend_list);
+			return CFGLU_ENOSPC;
+		} else {
+			/* Put back packet as start of empty queue. */
+			list_add(&pbuf->list, &pshm->tx_empty_list);
+			return CFGLU_ENOSPC;
+		}
+	}
+
+	/* Extract data from the packet to the shared memory CAIF frame
+	 * taking into account the shared memory header byte and possible
+	 * payload alignment bytes. */
+
+	f.cfpkt_extract(cfpkt,
+			(pbuf->desc_ptr + pbuf->frm_ofs + SHM_HDR_LEN +
+			 frm->hdr_ofs), pbuf->len, &extlen);
+
+	/* Fill in the shared memory packet descriptor area. */
+	pck_desc = (pshm_pck_desc_t) (pbuf->desc_ptr);
+	/* Forward to current frame. */
+	pck_desc += pbuf->frames;
+	pck_desc->frm_ofs =
+	    (pbuf->phy_addr - shm_base_addr) + pbuf->frm_ofs;
+	pck_desc->frm_len = frmlen;
+
+	/* Terminate packet descriptor area. */
+	pck_desc++;
+	pck_desc->frm_ofs = 0;
+
+	/* Update buffer parameters. */
+	pbuf->frames++;
+	pbuf->frm_ofs += frmlen + (frmlen % 32);
+
+	spin_lock(&lock);
+	/* Assign buffer as pending. */
+	list_add_tail(&pbuf->list, &pshm->tx_pend_list);
+	spin_unlock(&lock);
+
+	/* Schedule signaling work queue. */
+	(void) queue_work(pshm->sig_work_queue, &pshm->sig_work);
+
+	/* The packet is sent. As we have come to the end of the line we need
+	 * to free the packet. */
+	f.cfpkt_destroy(cfpkt);
+
+	return ESUCCESS;
+}
+
+int shm_phy_tx(layer_t *layr, transmt_info *info, cfpkt_t *cfpkt)
+{
+	shm_layer_t *pshm;
+	int result;
+
+	/* TODO: We need a mutex here if this function can be called from
+	 * different contexts. */
+
+	pshm = container_of(layr, shm_layer_t, shm_phy);
+
+	/* First try to append the frame. */
+	result = shm_send_pkt(pshm, cfpkt, true);
+	if (!result)
+		return result;
+
+	/* Try a new buffer. */
+	result = shm_send_pkt(pshm, cfpkt, false);
+
+	return result;
+}
+
+static int __init phyif_shm_init(void)
+{
+	int result = -1;
+	int i, j;
+
+	/* Initialize the shared memory instances. */
+	for (i = 0; i < SHM_INSTANCES; i++) {
+		/* Initialize structures in a clean state. */
+		memset(&shm_layer[i], 0, sizeof(shm_layer[i]));
+
+		/* Fill in some information about our PHY. */
+		shm_layer[i].shm_phy.transmit = shm_phy_tx;
+		shm_layer[i].shm_phy.receive = NULL;
+		shm_layer[i].shm_phy.ctrlcmd = shm_phy_fctrl;
+
+		/* TODO: Instance number should be appended. */
+		sprintf(shm_layer[i].cfg_name, "%s%d", mbxcfg_name, i);
+		sprintf(shm_layer[i].mbx_name, "%s%d", mbxifc_name, i);
+
+		/* Initialize queues. */
+		INIT_LIST_HEAD(&(shm_layer[i].tx_empty_list));
+		INIT_LIST_HEAD(&(shm_layer[i].rx_empty_list));
+		INIT_LIST_HEAD(&(shm_layer[i].tx_pend_list));
+		INIT_LIST_HEAD(&(shm_layer[i].rx_pend_list));
+		INIT_LIST_HEAD(&(shm_layer[i].tx_full_list));
+		INIT_LIST_HEAD(&(shm_layer[i].rx_full_list));
+
+		INIT_WORK(&shm_layer[i].sig_work, phyif_shm_sig_work_func);
+		INIT_WORK(&shm_layer[i].rx_work, phyif_shm_rx_work_func);
+		INIT_WORK(&shm_layer[i].flow_work, phyif_shm_flow_work_func);
+
+		/* Create the RX work thread.
+		 * TODO: Instance number should be appended. */
+		shm_layer[i].rx_work_queue =
+		    create_singlethread_workqueue("phyif_shm_rx");
+
+		/* Create the signaling work thread.
+		 * TODO: Instance number should be appended. */
+
+		shm_layer[i].sig_work_queue =
+		    create_singlethread_workqueue("phyif_shm_sig");
+
+		/* Create the flow re-enable work thread.
+		 * TODO: Instance number should be appended. */
+		shm_layer[i].flow_work_queue =
+			create_singlethread_workqueue("phyif_shm_flow");
+
+		init_waitqueue_head(&(shm_layer[i].mbx_space_wq));
+		shm_layer[i].tx_empty_available = 1;
+
+		/* Connect to the shared memory configuration module. */
+		/*shm_layer[i].cfg_ifc = cfgifc_get(shm_layer[i].cfg_name);*/
+
+		/* Initialize the shared memory transmit buffer queues. */
+		for (j = 0; j < shm_nr_tx_buf; j++) {
+			shm_buf_t *tx_buf =
+			    kmalloc(sizeof(shm_buf_t), GFP_KERNEL);
+			tx_buf->index = j;
+			tx_buf->len = shm_tx_buf_len;
+			if ((i % 2) == 0) {
+				tx_buf->phy_addr =
+				    shm_tx_addr + (shm_tx_buf_len * j);
+			} else {
+				tx_buf->phy_addr =
+				    shm_rx_addr + (shm_tx_buf_len * j);
+			}
+			tx_buf->desc_ptr =
+			    ioremap(tx_buf->phy_addr, shm_tx_buf_len);
+			tx_buf->frames = 0;
+			tx_buf->frm_ofs = SHM_CAIF_FRM_OFS;
+			list_add_tail(&tx_buf->list,
+				      &shm_layer[i].tx_empty_list);
+		}
+
+		/* Initialize the shared memory receive buffer queues. */
+		for (j = 0; j < shm_nr_rx_buf; j++) {
+			shm_buf_t *rx_buf =
+			    kmalloc(sizeof(shm_buf_t), GFP_KERNEL);
+			rx_buf->index = j;
+			rx_buf->len = shm_rx_buf_len;
+			if ((i % 2) == 0) {
+				rx_buf->phy_addr =
+				    shm_rx_addr + (shm_rx_buf_len * j);
+			} else {
+				rx_buf->phy_addr =
+				    shm_tx_addr + (shm_rx_buf_len * j);
+			}
+			rx_buf->desc_ptr =
+			    ioremap(rx_buf->phy_addr, shm_rx_buf_len);
+			list_add_tail(&rx_buf->list,
+				      &shm_layer[i].rx_empty_list);
+		}
+
+		/* Connect to the shared memory mailbox module. */
+		shm_layer[i].mbx_ifc = mbxifc_get(shm_layer[i].mbx_name);
+		if (!shm_layer[i].mbx_ifc) {
+			printk(KERN_WARNING
+			       "phyif_shm_init: can't find mailbox: %s.\n",
+			       shm_layer[i].mbx_name);
+			/* CLEANUP !!! */
+			return CFGLU_ENXIO;
+		}
+
+		/* Fill in some info about ourselves. */
+		shm_layer[i].mbx_client.cb = phyif_shm_mbx_msg_cb;
+		shm_layer[i].mbx_client.priv = (void *) &shm_layer[i];
+
+		shm_layer[i].mbx_ifc->init(&shm_layer[i].mbx_client,
+					   shm_layer[i].mbx_ifc->priv);
+
+		if ((i % 2) == 0) {
+			/* Register physical interface. */
+			result =
+			    caifdev_phy_register(&shm_layer[i].shm_phy,
+						 CFPHYTYPE_SHM,
+						 CFPHYPREF_UNSPECIFIED);
+		} else {
+			/* Register loop interface. */
+			result =
+			    caifdev_phy_loop_register(&shm_layer
+						      [i].shm_phy,
+						      CFPHYTYPE_SHM);
+		}
+
+		if (result < 0) {
+			printk(KERN_WARNING
+			       "phyif_shm_init: err: %d, "
+			       "can't register phy layer.\n",
+			       result);
+			/* CLEANUP !!! */
+		}
+
+	}
+
+	return result;
+}
+
+static void phyif_shm_exit(void)
+{
+	shm_buf_t *pbuf;
+	uint8 i = 0;
+	for (i = 0; i < SHM_INSTANCES; i++) {
+
+		/* unregister callbacks from mailbox interface */
+		shm_layer[i].mbx_client.cb = NULL;
+
+		/* TODO: wait for completetion or timeout */
+		while (!(list_empty(&shm_layer[i].tx_pend_list))) {
+			pbuf =
+			    list_entry(shm_layer[i].tx_pend_list.next,
+			       shm_buf_t, list);
+
+			kfree(pbuf);
+			list_del(&pbuf->list);
+		}
+
+		/* TODO: wait for completetion or timeout */
+		while (!(list_empty(&shm_layer[i].tx_full_list))) {
+			pbuf =
+			    list_entry(shm_layer[i].tx_full_list.next,
+				       shm_buf_t, list);
+			kfree(pbuf);
+			list_del(&pbuf->list);
+		}
+
+		while (!(list_empty(&shm_layer[i].tx_empty_list))) {
+			pbuf =
+			    list_entry(shm_layer[i].tx_empty_list.next,
+			       shm_buf_t, list);
+			kfree(pbuf);
+			list_del(&pbuf->list);
+		}
+
+		/* TODO: wait for completetion or timeout */
+		while (!(list_empty(&shm_layer[i].rx_full_list))) {
+			pbuf =
+			    list_entry(shm_layer[i].tx_full_list.next,
+			       shm_buf_t, list);
+			kfree(pbuf);
+			list_del(&pbuf->list);
+		}
+
+		/* TODO: wait for completetion or timeout */
+		while (!(list_empty(&shm_layer[i].rx_pend_list))) {
+			pbuf =
+			    list_entry(shm_layer[i].tx_pend_list.next,
+				       shm_buf_t, list);
+			kfree(pbuf);
+			list_del(&pbuf->list);
+		}
+
+		while (!(list_empty(&shm_layer[i].rx_empty_list))) {
+			pbuf =
+			    list_entry(shm_layer[i].rx_empty_list.next,
+				       shm_buf_t, list);
+			kfree(pbuf);
+			list_del(&pbuf->list);
+		}
+	}
+
+	/* destroy work queues */
+	destroy_workqueue(shm_layer[i].rx_work_queue);
+	destroy_workqueue(shm_layer[i].sig_work_queue);
+}
+
+module_init(phyif_shm_init);
+module_exit(phyif_shm_exit);
diff --git a/drivers/net/caif/shm.h b/drivers/net/caif/shm.h
new file mode 100644
index 0000000..d117b0a
--- /dev/null
+++ b/drivers/net/caif/shm.h
@@ -0,0 +1,95 @@
+/*
+*      Copyright (C) ST-Ericsson AB 2009
+*
+*      Author: Daniel Martensson / Daniel.Martensson@stericsson.com
+*
+*      License terms: GNU General Public License (GPL), version 2.
+*
+*/
+
+#ifndef SHM_H_
+#define SHM_H_
+
+#include <linux/list.h>
+/*#include <linux/init.h>
+#include <linux/workqueue.h>*/
+#include "caif_layer.h"
+
+#define ESUCCESS    0
+
+typedef int (*mbxifc_cb_t) (u16 mbx_msg, void *priv);
+
+/*FIXME:why is the client here??*/
+/* Shared memory mailbox client structure. */
+typedef struct _shm_mbxclient_t {
+	mbxifc_cb_t cb;
+	void *priv;
+} shm_mbxclient_t;
+
+typedef int (*mbxifc_init_t) (shm_mbxclient_t *mbx_client, void *priv);
+
+typedef int (*mbxifc_send_t) (u16 mbx_msg, void *priv);
+
+/* Shared memory mailbox interface structure. */
+typedef struct _shm_mbxifc_t {
+	mbxifc_init_t init;
+	mbxifc_send_t send_msg;
+	char name[16];
+	void *priv;
+	shm_mbxclient_t *client;
+	struct list_head list;
+} shm_mbxifc_t;
+
+int mbxifc_register(shm_mbxifc_t *client);
+
+int mbxifc_send(u16 mbx_msg, void *priv);
+shm_mbxifc_t *mbxifc_get(unsigned char *name);
+void mbxifc_put(shm_mbxifc_t *mbx_ifc);
+
+/* emardan: Use B380 setup for the first CAIF channel.*/
+/* TODO: This needs to go into a shared memory interface. */
+static int shm_base_addr = 0x81F00000;
+module_param(shm_base_addr, int, S_IRUGO);
+MODULE_PARM_DESC(shm_base_addr,
+		 "Physical base address of the shared memory area");
+
+static int shm_tx_addr = 0x81F00000;
+module_param(shm_tx_addr, int, S_IRUGO);
+MODULE_PARM_DESC(shm_tx_addr, "Physical start address for transmission area");
+
+static int shm_rx_addr = 0x81F0C000;
+module_param(shm_rx_addr, int, S_IRUGO);
+MODULE_PARM_DESC(shm_rx_addr, "Physical start address for reception area");
+
+static int shm_nr_tx_buf = 6;
+module_param(shm_nr_tx_buf, int, S_IRUGO);
+MODULE_PARM_DESC(shm_nr_tx_buf, "number of transmit buffers");
+
+static int shm_nr_rx_buf = 6;
+module_param(shm_nr_rx_buf, int, S_IRUGO);
+MODULE_PARM_DESC(shm_nr_rx_buf, "number of receive buffers");
+
+static int shm_tx_buf_len = 0x2000;
+module_param(shm_tx_buf_len, int, S_IRUGO);
+MODULE_PARM_DESC(shm_tx_buf_len, "size of transmit buffers");
+
+static int shm_rx_buf_len = 0x2000;
+module_param(shm_rx_buf_len, int, S_IRUGO);
+MODULE_PARM_DESC(shm_rx_buf_len, "size of receive buffers");
+
+/* Shared memory interface structure. */
+typedef struct _shm_cfgifc_t {
+	int base_addr;
+	int tx_addr;
+	int rx_addr;
+	int nr_tx_buf;
+	int nr_rx_buf;
+	int tx_buf_len;
+	int rx_buf_len;
+	char name[16];
+	struct list_head list;
+} shm_cfgifc_t;
+
+shm_cfgifc_t *cfgifc_get(unsigned char *name);
+
+#endif				/* SHM_H_ */
diff --git a/drivers/net/caif/shm_cfgifc.c b/drivers/net/caif/shm_cfgifc.c
new file mode 100644
index 0000000..bf00ce0
--- /dev/null
+++ b/drivers/net/caif/shm_cfgifc.c
@@ -0,0 +1,60 @@
+/*
+*      Copyright (C) ST-Ericsson AB 2009
+*
+*      Author: Daniel Martensson / Daniel.Martensson@stericsson.com
+*
+*      License terms: GNU General Public License (GPL), version 2.
+*
+*/
+
+/* Standard includes. */
+#include <linux/fs.h>
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/list.h>
+
+#include "shm.h"
+
+MODULE_LICENSE("GPL");
+
+static struct list_head cfgifc_list;
+
+void cfgifc_exit_module(void)
+{
+
+}
+
+int cfgifc_init_module(void)
+{
+	return -ENODEV;
+}
+
+int cfgifc_register(shm_cfgifc_t *mbx_ifc)
+{
+	return 0;
+}
+EXPORT_SYMBOL(cfgifc_register);
+
+shm_cfgifc_t *cfgifc_get(unsigned char *name)
+{
+	/* Hook up the adaptation layer. TODO: Make phy_type dynamic. */
+	cfcnfg_add_adapt_layer(caifdev.cfg, linktype, connid,
+			       CFPHYTYPE_SERIAL, adap_layer);
+
+	return NULL;
+}
+EXPORT_SYMBOL(cfgifc_get);
+
+void cfgifc_put(shm_cfgifc_t *mbx_ifc)
+{
+	/* Hook up the adaptation layer. TODO: Make phy_type dynamic. */
+	cfcnfg_add_adapt_layer(caifdev.cfg, linktype, connid,
+			       CFPHYTYPE_SERIAL, adap_layer);
+
+	return 0;
+}
+EXPORT_SYMBOL(cfgifc_put);
+
+
+module_init(cfgifc_init_module);
+module_exit(cfgifc_exit_module);
diff --git a/drivers/net/caif/shm_mbxifc.c b/drivers/net/caif/shm_mbxifc.c
new file mode 100644
index 0000000..f108799
--- /dev/null
+++ b/drivers/net/caif/shm_mbxifc.c
@@ -0,0 +1,98 @@
+/*
+*      Copyright (C) ST-Ericsson AB 2009
+*
+*      Author: Daniel Martensson / Daniel.Martensson@stericsson.com
+*
+*      License terms: GNU General Public License (GPL), version 2.
+*
+*/
+
+/* Standard includes. */
+#include <linux/fs.h>
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/list.h>
+
+#include "shm.h"
+
+MODULE_LICENSE("GPL");
+
+static struct list_head mbxifc_list;
+
+void mbxifc_exit_module(void)
+{
+
+}
+
+int mbxifc_init_module(void)
+{
+	INIT_LIST_HEAD(&mbxifc_list);
+
+	return ESUCCESS;
+}
+
+int mbxifc_register(shm_mbxifc_t *mbxifc)
+{
+	if (!mbxifc)
+		return -EINVAL;
+
+	list_add_tail(&mbxifc->list, &mbxifc_list);
+	printk(KERN_WARNING
+	       "mbxifc_register: mailbox: %s at 0x%p added.\n",
+	       mbxifc->name, mbxifc);
+
+	return ESUCCESS;
+}
+EXPORT_SYMBOL(mbxifc_register);
+
+int mbxifc_unregister(shm_mbxifc_t *mbx_ifc)
+{
+	shm_mbxifc_t *mbxifcreg;
+
+	while (!(list_empty(&mbxifc_list))) {
+		mbxifcreg = list_entry(mbxifc_list.next, shm_mbxifc_t, list);
+		if (mbxifcreg == mbx_ifc) {
+			list_del(&mbxifcreg->list);
+			break;
+		}
+	}
+
+	return ESUCCESS;
+}
+EXPORT_SYMBOL(mbxifc_unregister);
+
+shm_mbxifc_t *mbxifc_get(unsigned char *name)
+{
+	shm_mbxifc_t *mbxifc;
+	struct list_head *pos;
+	list_for_each(pos, &mbxifc_list) {
+		mbxifc = list_entry(pos, shm_mbxifc_t, list);
+		if (strcmp(mbxifc->name, name) == 0) {
+			list_del(&mbxifc->list);
+			printk(KERN_WARNING
+			       "mbxifc_get: mailbox: %s at 0x%p found.\n",
+			       mbxifc->name, mbxifc);
+			return mbxifc;
+		}
+	}
+
+	printk(KERN_WARNING "mbxifc_get: no mailbox: %s found.\n", name);
+
+	return NULL;
+}
+EXPORT_SYMBOL(mbxifc_get);
+
+void mbxifc_put(shm_mbxifc_t *mbx_ifc)
+{
+	if (!mbx_ifc)
+		return;
+
+	list_add_tail(&mbx_ifc->list, &mbxifc_list);
+
+	return;
+}
+EXPORT_SYMBOL(mbxifc_put);
+
+
+module_init(mbxifc_init_module);
+module_exit(mbxifc_exit_module);
diff --git a/drivers/net/caif/shm_smbx.c b/drivers/net/caif/shm_smbx.c
new file mode 100644
index 0000000..57770d4
--- /dev/null
+++ b/drivers/net/caif/shm_smbx.c
@@ -0,0 +1,81 @@
+/*
+*      Copyright (C) ST-Ericsson AB 2009
+*
+*      Author: Daniel Martensson / Daniel.Martensson@stericsson.com
+*
+*      License terms: GNU General Public License (GPL), version 2.
+*
+*/
+
+/* Very simple simulated mailbox interface supporting
+ * multiple mailbox instances. */
+
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/device.h>
+
+#include "shm.h"
+
+MODULE_LICENSE("GPL");
+
+#define MBX_NR_OF_INSTANCES	2
+#define MBX_SMBX_NAME		"cfmbx"
+
+typedef struct _shm_smbx_t {
+	shm_mbxifc_t local;
+	shm_mbxifc_t *peer;
+} shm_smbx_t;
+
+static shm_smbx_t shm_smbx[MBX_NR_OF_INSTANCES];
+
+static int smbx_ifc_init(shm_mbxclient_t *mbx_client, void *priv)
+{
+	shm_smbx_t *mbx = (shm_smbx_t *) priv;
+
+	mbx->local.client = mbx_client;
+
+	return 0;
+}
+
+static int smbx_ifc_send_msg(u16 mbx_msg, void *priv)
+{
+	shm_smbx_t *mbx = (shm_smbx_t *) priv;
+
+	mbx->peer->client->cb(mbx_msg, mbx->peer->client->priv);
+
+	return 0;
+
+}
+
+static int __init shm_smbx_init(void)
+{
+	int i;
+
+	for (i = 0; i < MBX_NR_OF_INSTANCES; i++) {
+		/* Set up the mailbox interface. */
+		shm_smbx[i].local.init = smbx_ifc_init;
+		shm_smbx[i].local.send_msg = smbx_ifc_send_msg;
+		sprintf(shm_smbx[i].local.name, "%s%d", MBX_SMBX_NAME, i);
+		shm_smbx[i].local.priv = &shm_smbx[i];
+
+		/* Set up the correct peer.
+		 * (0 is connected to one and so forth). */
+		if (i % 2)
+			shm_smbx[i].peer = &shm_smbx[i - 1].local;
+		else
+			shm_smbx[i].peer = &shm_smbx[i + 1].local;
+
+
+		mbxifc_register(&(shm_smbx[i].local));
+	}
+
+	return 0;
+}
+
+static void shm_smbx_exit(void)
+{
+	/* Nothing to do. */
+}
+
+module_init(shm_smbx_init);
+module_exit(shm_smbx_exit);
-- 
1.6.0.4

