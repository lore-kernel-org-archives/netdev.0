From: sjur.brandeland@stericsson.com
Subject: [RFC PATCH v3  6/8] CAIF Protocol Stack
Date: Mon, 30 Nov 2009 16:00:50 +0100
Message-ID: <1259593252-2493-7-git-send-email-sjur.brandeland@stericsson.com>
References: <1259593252-2493-1-git-send-email-sjur.brandeland@stericsson.com>
 <1259593252-2493-2-git-send-email-sjur.brandeland@stericsson.com>
 <1259593252-2493-3-git-send-email-sjur.brandeland@stericsson.com>
 <1259593252-2493-4-git-send-email-sjur.brandeland@stericsson.com>
 <1259593252-2493-5-git-send-email-sjur.brandeland@stericsson.com>
 <1259593252-2493-6-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN
Content-Transfer-Encoding: 7BIT
Cc: randy.dunlap@oracle.com, kim.xx.lilliestierna@stericsson.com,
	christian.bejram@stericsson.com, daniel.martensson@stericsson.com,
	Sjur Braendeland <sjur.brandeland@stericsson.com>
To: netdev@vger.kernel.org, stefano.babic@babic.homelinux.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bgo1smout1.broadpark.no ([217.13.4.94]:55205 "EHLO
	bgo1smout1.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752784AbZK3QBy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 11:01:54 -0500
Received: from bgo1sminn1.broadpark.no ([217.13.4.93])
 by bgo1smout1.broadpark.no
 (Sun Java(tm) System Messaging Server 6.3-3.01 (built Jul 12 2007; 32bit))
 with ESMTP id <0KTX00146GF0KF20@bgo1smout1.broadpark.no> for
 netdev@vger.kernel.org; Mon, 30 Nov 2009 16:01:48 +0100 (CET)
Received: from localhost.localdomain ([84.49.68.131])
 by bgo1sminn1.broadpark.no
 (Sun Java(tm) System Messaging Server 6.3-3.01 (built Jul 12 2007; 32bit))
 with ESMTP id <0KTX00IAMGDW9QV1@bgo1sminn1.broadpark.no> for
 netdev@vger.kernel.org; Mon, 30 Nov 2009 16:01:48 +0100 (CET)
In-reply-to: <1259593252-2493-6-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sjur Braendeland <sjur.brandeland@stericsson.com>

Signed-off-by: Sjur Braendeland <sjur.brandeland@stericsson.com>
---
 drivers/net/caif/Kconfig       |   22 +++
 drivers/net/caif/Makefile      |   26 +++
 drivers/net/caif/caif_loop.c   |  235 +++++++++++++++++++++++
 drivers/net/caif/caif_serial.c |  406 ++++++++++++++++++++++++++++++++++++++++
 4 files changed, 689 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/caif/Kconfig
 create mode 100644 drivers/net/caif/Makefile
 create mode 100644 drivers/net/caif/caif_loop.c
 create mode 100644 drivers/net/caif/caif_serial.c

diff --git a/drivers/net/caif/Kconfig b/drivers/net/caif/Kconfig
new file mode 100644
index 0000000..adf6f7c
--- /dev/null
+++ b/drivers/net/caif/Kconfig
@@ -0,0 +1,22 @@
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
+	The CAIF TTY transport driver.
+
+config CAIF_LOOPBACK
+	tristate "CAIF loopback test driver"
+	default n
+	---help---
+	Loopback test driver
+
+
+endif # CAIF
diff --git a/drivers/net/caif/Makefile b/drivers/net/caif/Makefile
new file mode 100644
index 0000000..b712ccb
--- /dev/null
+++ b/drivers/net/caif/Makefile
@@ -0,0 +1,26 @@
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
+ifdef CAIF_DIR
+KBUILD_EXTRA_SYMBOLS=$(CAIF_DIR)/net/caif/Module.symvers
+endif
+
+ccflags-y :=  $(CAIF_FLAGS)
+
+clean-dirs:= .tmp_versions
+clean-files:= Module.symvers modules.order *.cmd *~ \
+
+# --- Physical drivers --
+# Serial interface
+obj-$(CONFIG_CAIF_TTY) += caif_serial.o
+
+# Loopback
+obj-$(CONFIG_CAIF_LOOPBACK) += caif_loop.o
diff --git a/drivers/net/caif/caif_loop.c b/drivers/net/caif/caif_loop.c
new file mode 100644
index 0000000..9606f0e
--- /dev/null
+++ b/drivers/net/caif/caif_loop.c
@@ -0,0 +1,235 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2009
+ * Author:	Sjur Brendeland / sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#include <linux/version.h>
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <linux/netdevice.h>
+#include <net/pkt_sched.h>
+#include <net/caif/caif_dev.h>
+#include <net/caif/caif_log.h>
+#include <net/caif/generic/caif_layer.h>
+#include <net/caif/generic/caif_layer.h>
+#include <net/caif/generic/cfcnfg.h>
+
+MODULE_LICENSE("GPL");
+
+struct caif_loop_dev {
+	struct caif_dev_common common;
+	struct net_device *dev;
+	int flow_on;
+	int queue_on;
+};
+#define CAIF_MAX_MTU 4096
+
+static ssize_t store_queue_on(struct device *dev,
+			      struct device_attribute *attr,
+			      const char *buf, size_t len)
+{
+	unsigned long val;
+	struct net_device *netdev = to_net_dev(dev);
+	struct caif_loop_dev *loopdev = netdev_priv(netdev);
+	strict_strtoul(buf, 10, &val);
+	loopdev->queue_on = val;
+	if (loopdev && loopdev->common.flowctrl)
+		loopdev->common.flowctrl(netdev, (int)val);
+	else
+		printk(KERN_WARNING "caif_loop:flowctrl not set\n");
+	return len;
+}
+
+static ssize_t show_queue_on(struct device *dev,
+			     struct device_attribute *attr, char *buf)
+{
+	struct net_device *netdev = to_net_dev(dev);
+	struct caif_loop_dev *loopdev = netdev_priv(netdev);
+	return sprintf(buf, "%u\n", loopdev->queue_on);
+}
+
+static ssize_t store_flow_on(struct device *dev,
+			  struct device_attribute *attr,
+			  const char *buf, size_t len)
+{
+	unsigned long val;
+	struct net_device *netdev = to_net_dev(dev);
+	struct caif_loop_dev *loopdev = netdev_priv(netdev);
+	strict_strtoul(buf, 10, &val);
+	loopdev->flow_on = val;
+	return len;
+}
+
+static ssize_t show_flow_on(struct device *dev,
+			 struct device_attribute *attr, char *buf)
+{
+	struct net_device *netdev = to_net_dev(dev);
+	struct caif_loop_dev *loopdev = netdev_priv(netdev);
+	return sprintf(buf, "%u\n", loopdev->flow_on);
+}
+
+static struct device_attribute attrs[] = {
+	__ATTR(flow_on, S_IRUGO | S_IWUSR, show_flow_on, store_flow_on),
+	__ATTR(queue_on, S_IRUGO | S_IWUSR, show_queue_on, store_queue_on),
+};
+
+static int sysfs_add(struct net_device *netdev)
+{
+	int i;
+	int err;
+	for (i = 0; i < ARRAY_SIZE(attrs); i++) {
+		err = device_create_file(&netdev->dev, &attrs[i]);
+		if (err)
+			goto fail;
+	}
+	return 0;
+
+ fail:
+	while (--i >= 0)
+		device_remove_file(&netdev->dev, &attrs[i]);
+	return err;
+}
+
+static void sysfs_rem(struct net_device *netdev)
+{
+	int i;
+	for (i = 0; i < ARRAY_SIZE(attrs); i++)
+		device_remove_file(&netdev->dev, &attrs[i]);
+}
+
+/*
+ * Send a SKB from net_device to the CAIF stack.
+ */
+static int caif_recv(struct net_device *dev, struct sk_buff *skb)
+{
+	int ret;
+	struct caif_loop_dev *caifd;
+	skb->protocol = htons(ETH_P_CAIF);
+	skb_reset_mac_header(skb);
+	skb->dev = dev;
+	dev->stats.rx_packets++;
+	dev->stats.rx_bytes += skb->len;
+	caifd = netdev_priv(dev);
+
+	if (caifd->flow_on > 0) {
+		--caifd->flow_on;
+		return NET_XMIT_DROP;
+	}
+	ret = netif_rx(skb);
+	if (ret == NET_RX_DROP)
+		return NET_XMIT_DROP;
+	return 0;
+}
+
+void debug_netdev(struct net_device *dev)
+{
+	struct netdev_queue *txq;
+	struct Qdisc *q;
+	txq = netdev_get_tx_queue(dev, 0);
+	q = rcu_dereference(txq->qdisc);
+	printk(KERN_INFO "txq:%p q:%p enqueue:%p - %s\n",
+	       txq, q, q ? q->enqueue : NULL, q->ops ? q->ops->id : "");
+}
+
+static int caif_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	return caif_recv(dev, skb);
+}
+
+static int caif_open(struct net_device *dev)
+{
+	struct caif_loop_dev *caifd;
+	netif_wake_queue(dev);
+	caifd = netdev_priv(dev);
+	caifd->flow_on = 0;
+	return 0;
+}
+
+static int caif_close(struct net_device *dev)
+{
+	netif_stop_queue(dev);
+	return 0;
+}
+
+#if (LINUX_VERSION_CODE > KERNEL_VERSION(2, 6, 28))
+static const struct net_device_ops netdev_ops = {
+	.ndo_open = caif_open,
+	.ndo_stop = caif_close,
+	.ndo_start_xmit = caif_xmit
+};
+#endif
+
+static void caifdev_setup(struct net_device *dev)
+{
+	struct caif_loop_dev *loopdev = netdev_priv(dev);
+	dev->features = 0;
+#if (LINUX_VERSION_CODE <= KERNEL_VERSION(2, 6, 28))
+	dev->open = caif_open;
+	dev->stop = caif_close;
+	dev->hard_start_xmit = caif_xmit;
+#else
+
+	dev->netdev_ops = &netdev_ops;
+#endif
+	dev->type = ARPHRD_CAIF;
+	dev->flags = IFF_POINTOPOINT | IFF_NOARP;
+	dev->mtu = CAIF_MAX_MTU;
+	dev->hard_header_len = CAIF_NEEDED_HEADROOM;
+	dev->tx_queue_len = 1;
+	dev->destructor = free_netdev;
+	loopdev->common.phy_type = CFPHYTYPE_SHM;
+	loopdev->common.phy_pref = CFPHYPREF_LOW_LAT;
+	loopdev->common.net_dev_module = THIS_MODULE;
+}
+
+int create_caif_phy_dev(char *ifname, struct net_device **dev)
+{
+	struct caif_loop_dev *caifd;
+	int err;
+	if (!dev)
+		return -1;
+	*dev = alloc_netdev(sizeof(*caifd), ifname, caifdev_setup);
+	if (!*dev)
+		return -ENOMEM;
+	caifd = netdev_priv(*dev);
+	caifd->flow_on = 1;
+	netif_stop_queue(*dev);
+	caifd->dev = *dev;
+	err = register_netdev(*dev);
+	sysfs_add(*dev);
+	if (err)
+		goto err;
+	return 0;
+ err:
+	printk(KERN_WARNING "Error in create_phy_loop\n");
+	free_netdev(*dev);
+	return err;
+}
+
+static void remove_caif_phy_dev(struct net_device *dev)
+{
+	sysfs_rem(dev);
+	rtnl_lock();
+	dev_close(dev);
+	/* device is freed automagically by net-sysfs */
+	unregister_netdevice(dev);
+	rtnl_unlock();
+}
+
+static struct net_device *caif_phy_dev_inst;
+static int __init phyif_loop_init(void)
+{
+	int result;
+	result = create_caif_phy_dev("loop%d", &caif_phy_dev_inst);
+	return result;
+}
+
+static void __exit phyif_loop_exit(void)
+{
+	remove_caif_phy_dev(caif_phy_dev_inst);
+}
+
+module_init(phyif_loop_init);
+module_exit(phyif_loop_exit);
diff --git a/drivers/net/caif/caif_serial.c b/drivers/net/caif/caif_serial.c
new file mode 100644
index 0000000..bf55f6c
--- /dev/null
+++ b/drivers/net/caif/caif_serial.c
@@ -0,0 +1,406 @@
+/*
+ * Copyright (C) ST-Ericsson AB 2009
+ * Author:	Sjur Brendeland / sjur.brandeland@stericsson.com
+ * License terms: GNU General Public License (GPL) version 2
+ */
+
+#include <linux/init.h>
+#include <linux/version.h>
+#include <linux/module.h>
+#include <linux/device.h>
+#include <linux/tty.h>
+#include <linux/types.h>
+#include <linux/skbuff.h>
+#include <linux/netdevice.h>
+#include <linux/rtnetlink.h>
+#include <linux/tty.h>
+#include <linux/file.h>
+#include <net/caif/caif_dev.h>
+#include <net/caif/generic/caif_layer.h>
+#include <net/caif/generic/cfcnfg.h>
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Sjur Brendeland<sjur.brandeland@stericsson.com>");
+MODULE_DESCRIPTION("CAIF serial device TTY line discipline");
+MODULE_LICENSE("GPL");
+MODULE_ALIAS_LDISC(N_CAIF);
+
+/* FIXME:Remove this when CAIF is included in tty.h */
+#ifndef N_CAIF
+#define N_CAIF N_MOUSE
+#endif
+
+#define CAIF_SENDING	1
+#define CAIF_UART_TX_COMPLETED	2
+#define CAIF_FLOW_OFF_SENT	4
+#define MAX_WRITE_CHUNK	      256
+#define ON 1
+#define OFF 0
+#define CAIF_MAX_MTU 4096
+
+#if (LINUX_VERSION_CODE < KERNEL_VERSION(2, 6, 27))
+#define tty_ldisc tty_ldisc_ops
+#endif
+
+
+
+struct net_device *device;
+char *ser_ttyname = "/dev/ttyS0";
+module_param(ser_ttyname, charp, S_IRUGO);
+MODULE_PARM_DESC(ser_ttyname, "TTY to open");
+
+int ser_loop;
+module_param(ser_loop, bool, S_IRUGO);
+MODULE_PARM_DESC(ser_loop, "Run in simulated loopback mode.");
+
+int ser_use_stx;
+module_param(ser_use_stx, bool, S_IRUGO);
+MODULE_PARM_DESC(ser_use_stx, "STX enabled or not.");
+
+static int caif_net_open(struct net_device *dev);
+static int caif_net_close(struct net_device *dev);
+
+struct ser_device {
+	struct caif_dev_common common;
+	struct net_device *dev;
+	struct sk_buff_head head;
+	int xoff;
+	int queue_on;
+	struct tty_struct *tty;
+	int use_stx;
+	bool tx_started;
+	unsigned long state;
+	u8 buf[MAX_WRITE_CHUNK];
+	struct file *file;
+	char *tty_name;
+};
+
+static int ser_phy_tx(struct ser_device *ser, struct sk_buff *skb);
+static void caifdev_setup(struct net_device *dev);
+static void ser_tx_wakeup(struct tty_struct *tty);
+
+static void ser_receive(struct tty_struct *tty, const u8 *data,
+			char *flags, int count)
+{
+	struct sk_buff *skb = NULL;
+	struct ser_device *ser;
+	int ret;
+	ser = tty->disc_data;
+
+	/* Workaround for garbage at start of transmission,
+	 * only enable if STX handling is not enables */
+	if (!ser->use_stx && !ser->tx_started) {
+		printk(KERN_WARNING "Bytes received before first transmission."
+		       "Bytes discarded. \n");
+		return;
+	}
+
+	BUG_ON(ser->dev == NULL);
+
+	/* Get a suitable caif packet and copy in data. */
+	skb = netdev_alloc_skb(ser->dev, count+1);
+	BUG_ON(skb == NULL);
+	{
+	  u8 *p = skb_put(skb, count);
+	  memcpy(p, data, count);
+	}
+	skb->protocol = htons(ETH_P_CAIF);
+	skb_reset_mac_header(skb);
+	skb->dev = ser->dev;
+
+	/* Push received packet up the stack. */
+	ret = netif_rx(skb);
+}
+
+static int handle_tx(struct ser_device *ser)
+{
+	struct tty_struct *tty;
+	struct sk_buff *skb;
+	char *buf;
+	int tty_wr, len, room, pktlen;
+	tty = ser->tty;
+
+	/* NOTE: This workaround is not really needed when STX is enabled.
+	 *  Remove? */
+	if (ser->tx_started == false)
+		ser->tx_started = true;
+
+	if (test_and_set_bit(CAIF_SENDING, &ser->state)) {
+		set_bit(CAIF_UART_TX_COMPLETED, &ser->state);
+		return 0;
+	}
+
+	do {
+		skb = skb_peek(&ser->head);
+		if (skb != NULL && skb->len == 0) {
+			struct sk_buff *tmp;
+			tmp = skb_dequeue(&ser->head);
+			BUG_ON(tmp != skb);
+			kfree_skb(skb);
+			skb = skb_peek(&ser->head);
+		}
+
+		if (skb ==  NULL) {
+			if (test_and_clear_bit(
+				    CAIF_FLOW_OFF_SENT,
+				    &ser->state)) {
+				if (ser->common.flowctrl != NULL)
+					ser->common.flowctrl(ser->dev, ON);
+			}
+			break;
+		}
+
+
+		buf = skb->data;
+		pktlen = len = skb->len;
+
+		clear_bit(CAIF_UART_TX_COMPLETED, &ser->state);
+		room = tty_write_room(tty);
+		if (room > MAX_WRITE_CHUNK)
+			room = MAX_WRITE_CHUNK;
+
+		if (len > room)
+			len = room;
+
+		if (!ser_loop) {
+			tty_wr = tty->ops->write(tty, buf, len);
+		} else {
+			tty_wr = len;
+			ser_receive(tty, buf, 0, len);
+		}
+
+		if (tty_wr > 0)
+			skb_pull(skb, tty_wr);
+
+		if (ser_loop)
+			ser_tx_wakeup(tty);
+
+	} while (test_bit(CAIF_UART_TX_COMPLETED, &(ser->state)));
+
+	clear_bit(CAIF_SENDING, &ser->state);
+	return 0;
+}
+
+static int ser_phy_tx(struct ser_device *ser, struct sk_buff *skb)
+{
+	if (skb_peek(&ser->head) !=  NULL) {
+		if (!test_and_set_bit(CAIF_FLOW_OFF_SENT,
+					&ser->state)
+		    && ser->common.flowctrl != NULL) {
+			ser->common.flowctrl(ser->dev, OFF);
+		}
+	}
+	skb_queue_tail(&ser->head, skb);
+	if (!test_bit(CAIF_SENDING, &ser->state))
+		handle_tx(ser);
+	return 0;
+}
+
+static int caif_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct ser_device *ser;
+	if (!dev)
+		return -EINVAL;
+	ser = netdev_priv(dev);
+	return ser_phy_tx(ser, skb);
+}
+
+
+static void ser_tx_wakeup(struct tty_struct *tty)
+{
+	struct ser_device *ser;
+	ser = tty->disc_data;
+	if (ser == NULL)
+		return;
+	set_bit(CAIF_UART_TX_COMPLETED, &ser->state);
+	if (ser->tty != tty)
+		return;
+	handle_tx(ser);
+}
+
+static void remove_caif_phy_dev(struct net_device *dev)
+{
+	/* Remove may be called inside or outside of rtnl_lock */
+	int islocked = rtnl_is_locked();
+	if (!islocked)
+		rtnl_lock();
+	dev_close(dev);
+	/* device is freed automagically by net-sysfs */
+	unregister_netdevice(dev);
+	if (!islocked)
+		rtnl_unlock();
+}
+
+static int ser_open(struct tty_struct *tty)
+{
+	struct ser_device *ser;
+	/* Use global device to map tty with ser */
+	ser = netdev_priv(device);
+	if (ser->file == NULL ||
+		tty != (struct tty_struct *)ser->file->private_data) {
+		printk(KERN_WARNING "Can not install ldisc from userspace!");
+		return -EINVAL;
+	}
+	tty->receive_room = 4096;
+	ser->tty = tty;
+	tty->disc_data = ser;
+	set_bit(TTY_DO_WRITE_WAKEUP, &tty->flags);
+	return 0;
+}
+
+static void ser_close(struct tty_struct *tty)
+{
+	struct ser_device *ser;
+	ser = tty->disc_data;
+	return ;
+}
+
+static int start_ldisc(struct ser_device *ser)
+{
+	struct file *f;
+	mm_segment_t oldfs;
+	struct termios tio;
+	int ldiscnr = N_CAIF;
+	f = filp_open(ser->tty_name, 0, 0);
+	if (f == NULL ||
+		f->f_op == NULL ||
+		f->f_op->unlocked_ioctl == NULL) {
+		return -EINVAL;
+	}
+	ser->file = f;
+	oldfs = get_fs();
+	set_fs(KERNEL_DS);
+
+
+	f->f_op->unlocked_ioctl(f, TCFLSH, 0x2);
+	memset(&tio, 0, sizeof(tio));
+	tio.c_cflag = B115200 | CRTSCTS | CS8 | CLOCAL | CREAD;
+	f->f_op->unlocked_ioctl(f, TCSETS, (long unsigned int)&tio);
+	f->f_op->unlocked_ioctl(f, TIOCSETD, (long unsigned int)&ldiscnr);
+	set_fs(oldfs);
+
+	return 0;
+}
+
+/*
+ * The line discipline structure.
+ */
+
+static struct tty_ldisc_ops caif_ldisc = {
+	.owner =        THIS_MODULE,
+	.magic =        TTY_LDISC_MAGIC,
+	.name =         "n_caif",
+	.open =         ser_open,
+	.close =        ser_close,
+	.receive_buf =  ser_receive,
+	.write_wakeup = ser_tx_wakeup
+};
+
+
+static int register_ldisc(struct ser_device *ser)
+{
+	int result;
+	result = tty_register_ldisc(N_CAIF, &caif_ldisc);
+
+	if (result < 0) {
+		printk(KERN_WARNING "caif_ser: err: %d,"
+			 "can't register ldisc.\n", result);
+		return result;
+	}
+	return result;
+}
+
+#if (LINUX_VERSION_CODE > KERNEL_VERSION(2, 6, 28))
+static const struct net_device_ops netdev_ops = {
+	.ndo_open = caif_net_open,
+	.ndo_stop = caif_net_close,
+	.ndo_start_xmit = caif_xmit
+};
+#endif
+
+static void caifdev_setup(struct net_device *dev)
+{
+	struct ser_device *serdev = netdev_priv(dev);
+	dev->features = 0;
+#if (LINUX_VERSION_CODE <= KERNEL_VERSION(2, 6, 28))
+
+	dev->open = caif_net_open;
+	dev->stop = caif_net_close;
+	dev->hard_start_xmit = caif_xmit;
+#else
+	dev->netdev_ops = &netdev_ops;
+#endif
+	dev->type = ARPHRD_CAIF;
+	dev->flags = IFF_POINTOPOINT | IFF_NOARP;
+	dev->mtu = CAIF_MAX_MTU;
+	dev->hard_header_len = CAIF_NEEDED_HEADROOM;
+	dev->tx_queue_len = 0;
+	dev->destructor = free_netdev;
+	skb_queue_head_init(&serdev->head);
+	serdev->common.phy_type = CFPHYTYPE_SERIAL;
+	serdev->common.phy_pref = CFPHYPREF_LOW_LAT;
+	serdev->common.net_dev_module = THIS_MODULE;
+	serdev->use_stx = ser_use_stx;
+	serdev->xoff = 0;
+	serdev->dev = dev;
+}
+
+static int caif_net_open(struct net_device *dev)
+{
+	struct ser_device *ser;
+	ser = netdev_priv(dev);
+	register_ldisc(ser);
+	start_ldisc(ser);
+	netif_wake_queue(dev);
+	ser->xoff = 0;
+	return 0;
+}
+
+static int caif_net_close(struct net_device *dev)
+{
+	struct ser_device *ser = netdev_priv(dev);
+	netif_stop_queue(dev);
+	/* Close the file handle */
+	if (ser->file)
+		fput(ser->file);
+	return tty_unregister_ldisc(N_CAIF);
+}
+
+static int register_setenv(char *ttyname,
+			   struct net_device **device)
+{
+	struct net_device *dev;
+	struct ser_device *ser;
+	int result;
+	printk(KERN_WARNING "caif_serial:ttyname=%s\n", ttyname);
+	dev = alloc_netdev(sizeof(*ser), "caifser%d", caifdev_setup);
+	if (!dev)
+		return -ENODEV;
+	ser = netdev_priv(dev);
+	ser->tty_name = ttyname;
+	netif_stop_queue(dev);
+	ser->dev = dev;
+
+	*device = dev;
+	result = register_netdev(dev);
+	if (result) {
+		free_netdev(dev);
+		*device = 0;
+		return -ENODEV;
+	}
+	return 0;
+}
+
+static int __init caif_ser_init(void)
+{
+	return register_setenv(ser_ttyname, &device);
+
+}
+
+static void __exit caif_ser_exit(void)
+{
+	remove_caif_phy_dev(device);
+}
+
+module_init(caif_ser_init);
+module_exit(caif_ser_exit);
-- 
1.6.2.2.1669.g7eaf8

