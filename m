From: sjur.brandeland@stericsson.com
Subject: [PATCH net-next-2.6 v8 12/12] net-caif-driver: add CAIF serial driver
 (ldisc)
Date: Wed, 31 Mar 2010 01:56:30 +0200
Message-ID: <1269993390-23830-13-git-send-email-sjur.brandeland@stericsson.com>
References: <1269993390-23830-1-git-send-email-sjur.brandeland@stericsson.com>
 <1269993390-23830-2-git-send-email-sjur.brandeland@stericsson.com>
 <1269993390-23830-3-git-send-email-sjur.brandeland@stericsson.com>
 <1269993390-23830-4-git-send-email-sjur.brandeland@stericsson.com>
 <1269993390-23830-5-git-send-email-sjur.brandeland@stericsson.com>
 <1269993390-23830-6-git-send-email-sjur.brandeland@stericsson.com>
 <1269993390-23830-7-git-send-email-sjur.brandeland@stericsson.com>
 <1269993390-23830-8-git-send-email-sjur.brandeland@stericsson.com>
 <1269993390-23830-9-git-send-email-sjur.brandeland@stericsson.com>
 <1269993390-23830-10-git-send-email-sjur.brandeland@stericsson.com>
 <1269993390-23830-11-git-send-email-sjur.brandeland@stericsson.com>
 <1269993390-23830-12-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN
Content-Transfer-Encoding: 7BIT
Cc: daniel.martensson@stericsson.com, sjurbr@gmail.com,
	Sjur Braendeland <sjur.brandeland@stericsson.com>
To: davem@davemloft.net, netdev@vger.kernel.org, marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eterpe-smout.broadpark.no ([80.202.8.16]:63548 "EHLO
	eterpe-smout.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756648Ab0C3X53 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Mar 2010 19:57:29 -0400
Received: from ignis-smin.broadpark.no ([unknown] [80.202.8.11])
 by eterpe-smout.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-12.01 64bit (built Oct 15 2009))
 with ESMTP id <0L0400CCYD6XAR20@eterpe-smout.broadpark.no> for
 netdev@vger.kernel.org; Wed, 31 Mar 2010 01:56:57 +0200 (CEST)
Received: from localhost.localdomain ([unknown] [84.49.77.207])
 by ignis-smin.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-12.01 64bit (built Oct 15 2009))
 with ESMTP id <0L04003KXD6FYY70@ignis-smin.broadpark.no> for
 netdev@vger.kernel.org; Wed, 31 Mar 2010 01:56:57 +0200 (CEST)
In-reply-to: <1269993390-23830-12-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sjur Braendeland <sjur.brandeland@stericsson.com>

Add CAIF Serial driver. This driver is implemented as a line discipline.

caif_serial uses the following module parameters:
ser_use_stx - specifies if STart of frame eXtension is in use.
ser_loop    - sets the interface in loopback mode.

Signed-off-by: Sjur Braendeland <sjur.brandeland@stericsson.com>
---
 drivers/net/Kconfig            |    2 +
 drivers/net/Makefile           |    1 +
 drivers/net/caif/Kconfig       |   17 ++
 drivers/net/caif/Makefile      |   12 +
 drivers/net/caif/caif_serial.c |  441 ++++++++++++++++++++++++++++++++++++++++
 include/linux/tty.h            |    4 +-
 6 files changed, 475 insertions(+), 2 deletions(-)
 create mode 100644 drivers/net/caif/Kconfig
 create mode 100644 drivers/net/caif/Makefile
 create mode 100644 drivers/net/caif/caif_serial.c

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index dd9a09c..c2e670c 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2789,6 +2789,8 @@ source "drivers/ieee802154/Kconfig"
 
 source "drivers/s390/net/Kconfig"
 
+source "drivers/net/caif/Kconfig"
+
 config XEN_NETDEV_FRONTEND
 	tristate "Xen network device frontend driver"
 	depends on XEN
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index ad1346d..b7ffa35 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -285,5 +285,6 @@ obj-$(CONFIG_VIRTIO_NET) += virtio_net.o
 obj-$(CONFIG_SFC) += sfc/
 
 obj-$(CONFIG_WIMAX) += wimax/
+obj-$(CONFIG_CAIF) += caif/
 
 obj-$(CONFIG_OCTEON_MGMT_ETHERNET) += octeon/
diff --git a/drivers/net/caif/Kconfig b/drivers/net/caif/Kconfig
new file mode 100644
index 0000000..0b28e01
--- /dev/null
+++ b/drivers/net/caif/Kconfig
@@ -0,0 +1,17 @@
+#
+# CAIF physical drivers
+#
+
+if CAIF
+
+comment "CAIF transport drivers"
+
+config CAIF_TTY
+	tristate "CAIF TTY transport driver"
+	default n
+	---help---
+	The CAIF TTY transport driver is a Line Discipline (ldisc)
+	identified as N_CAIF. When this ldisc is opened from user space
+	it will redirect the TTY's traffic into the CAIF stack.
+
+endif # CAIF
diff --git a/drivers/net/caif/Makefile b/drivers/net/caif/Makefile
new file mode 100644
index 0000000..52b6d1f
--- /dev/null
+++ b/drivers/net/caif/Makefile
@@ -0,0 +1,12 @@
+ifeq ($(CONFIG_CAIF_DEBUG),1)
+CAIF_DBG_FLAGS := -DDEBUG
+endif
+
+KBUILD_EXTRA_SYMBOLS=net/caif/Module.symvers
+
+ccflags-y := $(CAIF_FLAGS) $(CAIF_DBG_FLAGS)
+clean-dirs:= .tmp_versions
+clean-files:= Module.symvers modules.order *.cmd *~ \
+
+# Serial interface
+obj-$(CONFIG_CAIF_TTY) += caif_serial.o
diff --git a/drivers/net/caif/caif_serial.c b/drivers/net/caif/caif_serial.c
new file mode 100644
index 0000000..3502f60
--- /dev/null
+++ b/drivers/net/caif/caif_serial.c
@@ -0,0 +1,441 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2010
+ * Author:	Sjur Brendeland / sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#include <linux/init.h>
+#include <linux/version.h>
+#include <linux/module.h>
+#include <linux/device.h>
+#include <linux/types.h>
+#include <linux/skbuff.h>
+#include <linux/netdevice.h>
+#include <linux/rtnetlink.h>
+#include <linux/tty.h>
+#include <linux/file.h>
+#include <linux/if_arp.h>
+#include <net/caif/caif_device.h>
+#include <net/caif/cfcnfg.h>
+#include <linux/err.h>
+#include <linux/debugfs.h>
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Sjur Brendeland<sjur.brandeland@stericsson.com>");
+MODULE_DESCRIPTION("CAIF serial device TTY line discipline");
+MODULE_LICENSE("GPL");
+MODULE_ALIAS_LDISC(N_CAIF);
+
+#define SEND_QUEUE_LOW 10
+#define SEND_QUEUE_HIGH 100
+#define CAIF_SENDING	        1 /* Bit 1 = 0x02*/
+#define CAIF_FLOW_OFF_SENT	4 /* Bit 4 = 0x10 */
+#define MAX_WRITE_CHUNK	     4096
+#define ON 1
+#define OFF 0
+#define CAIF_MAX_MTU 4096
+
+/*This list is protected by the rtnl lock. */
+static LIST_HEAD(ser_list);
+
+static int ser_loop;
+module_param(ser_loop, bool, S_IRUGO);
+MODULE_PARM_DESC(ser_loop, "Run in simulated loopback mode.");
+
+static int ser_use_stx = 1;
+module_param(ser_use_stx, bool, S_IRUGO);
+MODULE_PARM_DESC(ser_use_stx, "STX enabled or not.");
+
+static int ser_use_fcs = 1;
+
+module_param(ser_use_fcs, bool, S_IRUGO);
+MODULE_PARM_DESC(ser_use_fcs, "FCS enabled or not.");
+
+static int ser_write_chunk = MAX_WRITE_CHUNK;
+module_param(ser_write_chunk, int, S_IRUGO);
+
+MODULE_PARM_DESC(ser_write_chunk, "Maximum size of data written to UART.");
+
+static struct dentry *debugfsdir;
+
+static int caif_net_open(struct net_device *dev);
+static int caif_net_close(struct net_device *dev);
+
+struct ser_device {
+	struct caif_dev_common common;
+	struct list_head node;
+	struct net_device *dev;
+	struct sk_buff_head head;
+	struct tty_struct *tty;
+	bool tx_started;
+	unsigned long state;
+	char *tty_name;
+#ifdef CONFIG_DEBUG_FS
+	struct dentry *debugfs_tty_dir;
+	struct debugfs_blob_wrapper tx_blob;
+	struct debugfs_blob_wrapper rx_blob;
+	u8 rx_data[128];
+	u8 tx_data[128];
+	u8 tty_status;
+
+#endif
+};
+
+static void caifdev_setup(struct net_device *dev);
+static void ldisc_tx_wakeup(struct tty_struct *tty);
+#ifdef CONFIG_DEBUG_FS
+static inline void update_tty_status(struct ser_device *ser)
+{
+	ser->tty_status =
+		ser->tty->stopped << 5 |
+		ser->tty->hw_stopped << 4 |
+		ser->tty->flow_stopped << 3 |
+		ser->tty->packet << 2 |
+		ser->tty->low_latency << 1 |
+		ser->tty->warned;
+}
+static inline void debugfs_init(struct ser_device *ser, struct tty_struct *tty)
+{
+	ser->debugfs_tty_dir =
+			debugfs_create_dir(tty->name, debugfsdir);
+	if (!IS_ERR(ser->debugfs_tty_dir)) {
+		debugfs_create_blob("last_tx_msg", S_IRUSR,
+				ser->debugfs_tty_dir,
+				&ser->tx_blob);
+
+		debugfs_create_blob("last_rx_msg", S_IRUSR,
+				ser->debugfs_tty_dir,
+				&ser->rx_blob);
+
+		debugfs_create_x32("ser_state", S_IRUSR,
+				ser->debugfs_tty_dir,
+				(u32 *)&ser->state);
+
+		debugfs_create_x8("tty_status", S_IRUSR,
+				ser->debugfs_tty_dir,
+				&ser->tty_status);
+
+	}
+	ser->tx_blob.data = ser->tx_data;
+	ser->tx_blob.size = 0;
+	ser->rx_blob.data = ser->rx_data;
+	ser->rx_blob.size = 0;
+}
+
+static inline void debugfs_deinit(struct ser_device *ser)
+{
+	debugfs_remove_recursive(ser->debugfs_tty_dir);
+}
+
+static inline void debugfs_rx(struct ser_device *ser, const u8 *data, int size)
+{
+	if (size > sizeof(ser->rx_data))
+		size = sizeof(ser->rx_data);
+	memcpy(ser->rx_data, data, size);
+	ser->rx_blob.data = ser->rx_data;
+	ser->rx_blob.size = size;
+}
+
+static inline void debugfs_tx(struct ser_device *ser, const u8 *data, int size)
+{
+	if (size > sizeof(ser->tx_data))
+		size = sizeof(ser->tx_data);
+	memcpy(ser->tx_data, data, size);
+	ser->tx_blob.data = ser->tx_data;
+	ser->tx_blob.size = size;
+}
+#else
+static inline void debugfs_init(struct ser_device *ser, struct tty_struct *tty)
+{
+}
+
+static inline void debugfs_deinit(struct ser_device *ser)
+{
+}
+
+static inline void update_tty_status(struct ser_device *ser)
+{
+}
+
+static inline void debugfs_rx(struct ser_device *ser, const u8 *data, int size)
+{
+}
+
+static inline void debugfs_tx(struct ser_device *ser, const u8 *data, int size)
+{
+}
+
+#endif
+
+static void ldisc_receive(struct tty_struct *tty, const u8 *data,
+			char *flags, int count)
+{
+	struct sk_buff *skb = NULL;
+	struct ser_device *ser;
+	int ret;
+	u8 *p;
+	ser = tty->disc_data;
+
+	/*
+	 * NOTE: flags may contain information about break or overrun.
+	 * This is not yet handled.
+	 */
+
+
+	/*
+	 * Workaround for garbage at start of transmission,
+	 * only enable if STX handling is not enabled.
+	 */
+	if (!ser->common.use_stx && !ser->tx_started) {
+		dev_info(&ser->dev->dev,
+			"Bytes received before initial transmission -"
+			"bytes discarded.\n");
+		return;
+	}
+
+	BUG_ON(ser->dev == NULL);
+
+	/* Get a suitable caif packet and copy in data. */
+	skb = netdev_alloc_skb(ser->dev, count+1);
+	BUG_ON(skb == NULL);
+	p = skb_put(skb, count);
+	memcpy(p, data, count);
+
+	skb->protocol = htons(ETH_P_CAIF);
+	skb_reset_mac_header(skb);
+	skb->dev = ser->dev;
+	debugfs_rx(ser, data, count);
+	/* Push received packet up the stack. */
+	ret = netif_rx_ni(skb);
+	if (!ret) {
+		ser->dev->stats.rx_packets++;
+		ser->dev->stats.rx_bytes += count;
+	} else
+		++ser->dev->stats.rx_dropped;
+	update_tty_status(ser);
+}
+
+static int handle_tx(struct ser_device *ser)
+{
+	struct tty_struct *tty;
+	struct sk_buff *skb;
+	int tty_wr, len, room;
+	tty = ser->tty;
+	ser->tx_started = true;
+
+	/* Enter critical section */
+	if (test_and_set_bit(CAIF_SENDING, &ser->state))
+		return 0;
+
+	/* skb_peek is safe because handle_tx is called after skb_queue_tail */
+	while ((skb = skb_peek(&ser->head)) != NULL) {
+
+		/* Make sure you don't write too much */
+		len = skb->len;
+		room = tty_write_room(tty);
+		if (!room)
+			break;
+		if (room > ser_write_chunk)
+			room = ser_write_chunk;
+		if (len > room)
+			len = room;
+
+		/* Write to tty or loopback */
+		if (!ser_loop) {
+			tty_wr = tty->ops->write(tty, skb->data, len);
+			update_tty_status(ser);
+		} else {
+			tty_wr = len;
+			ldisc_receive(tty, skb->data, NULL, len);
+		}
+		ser->dev->stats.tx_packets++;
+		ser->dev->stats.tx_bytes += tty_wr;
+
+		/* Error on TTY ?! */
+		if (tty_wr < 0)
+			goto error;
+		/* Reduce buffer written, and discard if empty */
+		skb_pull(skb, tty_wr);
+		if (skb->len == 0) {
+			struct sk_buff *tmp = skb_dequeue(&ser->head);
+			BUG_ON(tmp != skb);
+			if (in_interrupt())
+				dev_kfree_skb_irq(skb);
+			else
+				kfree_skb(skb);
+		}
+	}
+	/* Send flow off if queue is empty */
+	if (ser->head.qlen <= SEND_QUEUE_LOW &&
+		test_and_clear_bit(CAIF_FLOW_OFF_SENT, &ser->state) &&
+		ser->common.flowctrl != NULL)
+				ser->common.flowctrl(ser->dev, ON);
+	clear_bit(CAIF_SENDING, &ser->state);
+	return 0;
+error:
+	clear_bit(CAIF_SENDING, &ser->state);
+	return tty_wr;
+}
+
+static int caif_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct ser_device *ser;
+	BUG_ON(dev == NULL);
+	ser = netdev_priv(dev);
+
+	/* Send flow off once, on high water mark */
+	if (ser->head.qlen > SEND_QUEUE_HIGH &&
+		!test_and_set_bit(CAIF_FLOW_OFF_SENT, &ser->state) &&
+		ser->common.flowctrl != NULL)
+
+		ser->common.flowctrl(ser->dev, OFF);
+
+	skb_queue_tail(&ser->head, skb);
+	return handle_tx(ser);
+}
+
+
+static void ldisc_tx_wakeup(struct tty_struct *tty)
+{
+	struct ser_device *ser;
+	ser = tty->disc_data;
+	BUG_ON(ser == NULL);
+	BUG_ON(ser->tty != tty);
+	handle_tx(ser);
+}
+
+
+static int ldisc_open(struct tty_struct *tty)
+{
+	struct ser_device *ser;
+	struct net_device *dev;
+	char name[64];
+	int result;
+
+	sprintf(name, "cf%s", tty->name);
+	dev = alloc_netdev(sizeof(*ser), name, caifdev_setup);
+	ser = netdev_priv(dev);
+	ser->tty = tty;
+	ser->dev = dev;
+	debugfs_init(ser, tty);
+	tty->receive_room = N_TTY_BUF_SIZE;
+	tty->disc_data = ser;
+	set_bit(TTY_DO_WRITE_WAKEUP, &tty->flags);
+	rtnl_lock();
+	result = register_netdevice(dev);
+	if (result) {
+		rtnl_unlock();
+		free_netdev(dev);
+		return -ENODEV;
+	}
+
+	list_add(&ser->node, &ser_list);
+	rtnl_unlock();
+	netif_stop_queue(dev);
+	update_tty_status(ser);
+	return 0;
+}
+
+static void ldisc_close(struct tty_struct *tty)
+{
+	struct ser_device *ser = tty->disc_data;
+	/* Remove may be called inside or outside of rtnl_lock */
+	int islocked = rtnl_is_locked();
+	if (!islocked)
+		rtnl_lock();
+	/* device is freed automagically by net-sysfs */
+	dev_close(ser->dev);
+	unregister_netdevice(ser->dev);
+	list_del(&ser->node);
+	debugfs_deinit(ser);
+	if (!islocked)
+		rtnl_unlock();
+}
+
+/* The line discipline structure. */
+static struct tty_ldisc_ops caif_ldisc = {
+	.owner =	THIS_MODULE,
+	.magic =	TTY_LDISC_MAGIC,
+	.name =		"n_caif",
+	.open =		ldisc_open,
+	.close =	ldisc_close,
+	.receive_buf =	ldisc_receive,
+	.write_wakeup =	ldisc_tx_wakeup
+};
+
+static int register_ldisc(void)
+{
+	int result;
+	result = tty_register_ldisc(N_CAIF, &caif_ldisc);
+	if (result < 0) {
+		pr_err("cannot register CAIF ldisc=%d err=%d\n", N_CAIF,
+			result);
+		return result;
+	}
+	return result;
+}
+static const struct net_device_ops netdev_ops = {
+	.ndo_open = caif_net_open,
+	.ndo_stop = caif_net_close,
+	.ndo_start_xmit = caif_xmit
+};
+
+static void caifdev_setup(struct net_device *dev)
+{
+	struct ser_device *serdev = netdev_priv(dev);
+	dev->features = 0;
+	dev->netdev_ops = &netdev_ops;
+	dev->type = ARPHRD_CAIF;
+	dev->flags = IFF_POINTOPOINT | IFF_NOARP;
+	dev->mtu = CAIF_MAX_MTU;
+	dev->hard_header_len = CAIF_NEEDED_HEADROOM;
+	dev->tx_queue_len = 0;
+	dev->destructor = free_netdev;
+	skb_queue_head_init(&serdev->head);
+	serdev->common.link_select = CAIF_LINK_LOW_LATENCY;
+	serdev->common.use_frag = true;
+	serdev->common.use_stx = ser_use_stx;
+	serdev->common.use_fcs = ser_use_fcs;
+	serdev->dev = dev;
+}
+
+
+static int caif_net_open(struct net_device *dev)
+{
+	struct ser_device *ser;
+	ser = netdev_priv(dev);
+	netif_wake_queue(dev);
+	return 0;
+}
+
+static int caif_net_close(struct net_device *dev)
+{
+	netif_stop_queue(dev);
+	return 0;
+}
+
+static int __init caif_ser_init(void)
+{
+	int ret;
+	ret = register_ldisc();
+	debugfsdir = debugfs_create_dir("caif_serial", NULL);
+	return ret;
+}
+
+static void __exit caif_ser_exit(void)
+{
+	struct ser_device *ser = NULL;
+	struct list_head *node;
+	struct list_head *_tmp;
+	list_for_each_safe(node, _tmp, &ser_list) {
+		ser = list_entry(node, struct ser_device, node);
+		dev_close(ser->dev);
+		unregister_netdevice(ser->dev);
+		list_del(node);
+	}
+	tty_unregister_ldisc(N_CAIF);
+	debugfs_remove_recursive(debugfsdir);
+}
+
+module_init(caif_ser_init);
+module_exit(caif_ser_exit);
diff --git a/include/linux/tty.h b/include/linux/tty.h
index ef3a294..5dd674b 100644
--- a/include/linux/tty.h
+++ b/include/linux/tty.h
@@ -23,7 +23,7 @@
  */
 #define NR_UNIX98_PTY_DEFAULT	4096      /* Default maximum for Unix98 ptys */
 #define NR_UNIX98_PTY_MAX	(1 << MINORBITS) /* Absolute limit */
-#define NR_LDISCS		20
+#define NR_LDISCS		21
 
 /* line disciplines */
 #define N_TTY		0
@@ -46,8 +46,8 @@
 #define N_GIGASET_M101	16	/* Siemens Gigaset M101 serial DECT adapter */
 #define N_SLCAN		17	/* Serial / USB serial CAN Adaptors */
 #define N_PPS		18	/* Pulse per Second */
-
 #define N_V253		19	/* Codec control over voice modem */
+#define N_CAIF		20      /* CAIF protocol for talking to modems */
 
 /*
  * This character is the same as _POSIX_VDISABLE: it cannot be used as
-- 
1.6.3.3

