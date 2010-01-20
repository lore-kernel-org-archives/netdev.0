From: sjur.brandeland@stericsson.com
Subject: [PATCH net-next-2.6 13/13] net-caif-driver: add CAIF serial driver
 (ldisc)
Date: Wed, 20 Jan 2010 23:55:30 +0100
Message-ID: <1264028130-14364-14-git-send-email-sjur.brandeland@stericsson.com>
References: <1264028130-14364-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN
Content-Transfer-Encoding: 7BIT
Cc: davem@davemloft.net, marcel@holtmann.org,
	stefano.babic@babic.homelinux.org, randy.dunlap@oracle.com,
	Sjur Braendeland <sjur.brandeland@stericsson.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bgo1smout1.broadpark.no ([217.13.4.94]:52371 "EHLO
	bgo1smout1.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754576Ab0ATX4p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2010 18:56:45 -0500
Received: from bgo1sminn1.broadpark.no ([217.13.4.93])
 by bgo1smout1.broadpark.no
 (Sun Java(tm) System Messaging Server 6.3-3.01 (built Jul 12 2007; 32bit))
 with ESMTP id <0KWK00CG0IDSGCC0@bgo1smout1.broadpark.no> for
 netdev@vger.kernel.org; Wed, 20 Jan 2010 23:56:16 +0100 (CET)
Received: from localhost.localdomain ([84.49.71.7]) by bgo1sminn1.broadpark.no
 (Sun Java(tm) System Messaging Server 6.3-3.01 (built Jul 12 2007; 32bit))
 with ESMTP id <0KWK00LQBICIDUE0@bgo1sminn1.broadpark.no> for
 netdev@vger.kernel.org; Wed, 20 Jan 2010 23:56:16 +0100 (CET)
In-reply-to: <1264028130-14364-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sjur Braendeland <sjur.brandeland@stericsson.com>

Add CAIF Serial driver. This driver is implemented as a line discipline.
The TTY is opened from inside the kernel module.

caif_serial uses the following module parameters:
ser_ttyname - specifies the tty name.
ser_use_stx - specifies if STart of frame eXtension is in use.
ser_loop    - sets the interface in loopback mode.

Signed-off-by: Sjur Braendeland <sjur.brandeland@stericsson.com>
---
 drivers/net/Kconfig            |    2 +
 drivers/net/Makefile           |    1 +
 drivers/net/caif/Kconfig       |   15 ++
 drivers/net/caif/Makefile      |   14 ++
 drivers/net/caif/caif_serial.c |  420 ++++++++++++++++++++++++++++++++++++++++
 include/linux/tty.h            |    4 +-
 6 files changed, 454 insertions(+), 2 deletions(-)
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
index 0000000..8a1a273
--- /dev/null
+++ b/drivers/net/caif/Kconfig
@@ -0,0 +1,15 @@
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
+endif # CAIF
diff --git a/drivers/net/caif/Makefile b/drivers/net/caif/Makefile
new file mode 100644
index 0000000..01784a0
--- /dev/null
+++ b/drivers/net/caif/Makefile
@@ -0,0 +1,14 @@
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
+
+
diff --git a/drivers/net/caif/caif_serial.c b/drivers/net/caif/caif_serial.c
new file mode 100644
index 0000000..7d6636b
--- /dev/null
+++ b/drivers/net/caif/caif_serial.c
@@ -0,0 +1,420 @@
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
+#include <net/caif/generic/caif_layer.h>
+#include <net/caif/generic/cfcnfg.h>
+#include <linux/err.h>
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Sjur Brendeland<sjur.brandeland@stericsson.com>");
+MODULE_DESCRIPTION("CAIF serial device TTY line discipline");
+MODULE_LICENSE("GPL");
+MODULE_ALIAS_LDISC(N_CAIF);
+
+#define CAIF_SENDING	1
+#define CAIF_UART_TX_COMPLETED	2
+#define CAIF_FLOW_OFF_SENT	4
+#define MAX_WRITE_CHUNK	     4096
+#define ON 1
+#define OFF 0
+#define CAIF_MAX_MTU 4096
+
+struct net_device *device;
+char *ser_ttyname = "/dev/ttyS0";
+module_param(ser_ttyname, charp, S_IRUGO);
+MODULE_PARM_DESC(ser_ttyname, "TTY to open.");
+
+int ser_loop;
+module_param(ser_loop, bool, S_IRUGO);
+MODULE_PARM_DESC(ser_loop, "Run in simulated loopback mode.");
+
+int ser_use_stx;
+module_param(ser_use_stx, bool, S_IRUGO);
+MODULE_PARM_DESC(ser_use_stx, "STX enabled or not.");
+
+int ser_write_chunk = MAX_WRITE_CHUNK;
+module_param(ser_write_chunk, int, S_IRUGO);
+
+MODULE_PARM_DESC(ser_write_chunk, "Maximum size of data written to UART.");
+
+
+static int caif_net_open(struct net_device *dev);
+static int caif_net_close(struct net_device *dev);
+
+struct ser_device {
+	struct caif_dev_common common;
+	struct net_device *dev;
+	struct sk_buff_head head;
+	int xoff;
+	struct tty_struct *tty;
+	bool tx_started;
+	unsigned long state;
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
+	u8 *p;
+	ser = tty->disc_data;
+
+	/*
+	 * Workaround for garbage at start of transmission,
+	 * only enable if STX handling is not enables
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
+
+	/* Push received packet up the stack. */
+	ret = netif_rx(skb);
+	if (!ret) {
+		ser->dev->stats.rx_packets++;
+		ser->dev->stats.rx_bytes += count;
+	} else
+		++ser->dev->stats.rx_dropped;
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
+	/*
+	 * NOTE: This workaround is not really needed when STX is enabled.
+	 * Remove?
+	 */
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
+		if (skb == NULL) {
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
+		if (room > ser_write_chunk)
+			room = ser_write_chunk;
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
+		ser->dev->stats.tx_packets++;
+		ser->dev->stats.tx_bytes += tty_wr;
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
+		if (!test_and_set_bit(CAIF_FLOW_OFF_SENT, &ser->state)
+		    && ser->common.flowctrl != NULL)
+			ser->common.flowctrl(ser->dev, OFF);
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
+		dev_err(&ser->dev->dev,
+			  "Cannot install ldisc %s from userspace!",
+			  tty->name);
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
+}
+
+static int start_ldisc(struct ser_device *ser)
+{
+	struct file *f;
+	mm_segment_t oldfs;
+	struct termios tio;
+	int ldiscnr = N_CAIF;
+	int ret;
+	f = filp_open(ser->tty_name, 0, 0);
+	if (IS_ERR(f)) {
+		dev_err(&ser->dev->dev, "CAIF cannot open:%s\n", ser->tty_name);
+		ret = -EINVAL;
+		goto error;
+	}
+	if (f == NULL || f->f_op == NULL || f->f_op->unlocked_ioctl == NULL) {
+		dev_err(&ser->dev->dev, "TTY cannot do IOCTL:%s\n",
+			ser->tty_name);
+		ret = -EINVAL;
+		goto error;
+	}
+
+	ser->file = f;
+	oldfs = get_fs();
+	set_fs(KERNEL_DS);
+
+	f->f_op->unlocked_ioctl(f, TCFLSH, 0x2);
+	memset(&tio, 0, sizeof(tio));
+	tio.c_cflag = B115200 | CRTSCTS | CS8 | CLOCAL | CREAD;
+	f->f_op->unlocked_ioctl(f, TCSETS, (long unsigned int)&tio);
+	f->f_op->unlocked_ioctl(f, TIOCSETD, (long unsigned int)&ldiscnr);
+	set_fs(oldfs);
+	return 0;
+error:
+	oldfs = get_fs();
+	set_fs(KERNEL_DS);
+	return ret;
+}
+
+/* The line discipline structure. */
+static struct tty_ldisc_ops caif_ldisc = {
+	.owner =	THIS_MODULE,
+	.magic =	TTY_LDISC_MAGIC,
+	.name =		"n_caif",
+	.open =		ser_open,
+	.close =	ser_close,
+	.receive_buf =	ser_receive,
+	.write_wakeup =	ser_tx_wakeup
+};
+
+
+static int register_ldisc(struct ser_device *ser)
+{
+	int result;
+	result = tty_register_ldisc(N_CAIF, &caif_ldisc);
+
+	if (result < 0) {
+		dev_err(&ser->dev->dev,
+			"cannot register CAIF ldisc=%d err=%d\n",
+			N_CAIF,
+			result);
+		return result;
+	}
+	return result;
+}
+
+static const struct net_device_ops netdev_ops = {
+	.ndo_open = caif_net_open,
+	.ndo_stop = caif_net_close,
+	.ndo_start_xmit = caif_xmit
+};
+static void caifdev_setup(struct net_device *dev)
+{
+	struct ser_device *serdev = netdev_priv(dev);
+	dev->features = 0;
+
+	dev->netdev_ops = &netdev_ops;
+
+	dev->type = ARPHRD_CAIF;
+	dev->flags = IFF_POINTOPOINT | IFF_NOARP | IFF_POINTOPOINT;
+	dev->mtu = CAIF_MAX_MTU;
+	dev->hard_header_len = CAIF_NEEDED_HEADROOM;
+	dev->tx_queue_len = 0;
+	dev->destructor = free_netdev;
+	skb_queue_head_init(&serdev->head);
+	serdev->common.link_select = CAIF_LINK_LOW_LATENCY;
+	serdev->common.use_frag = true;
+	serdev->common.use_stx = ser_use_stx;
+	serdev->common.use_fcs = true;
+	serdev->xoff = 0;
+	serdev->dev = dev;
+}
+
+static int caif_net_open(struct net_device *dev)
+{
+	struct ser_device *ser;
+	int ret;
+	ser = netdev_priv(dev);
+	ret = register_ldisc(ser);
+	if (ret)
+		return ret;
+	ret = start_ldisc(ser);
+	if (ret) {
+		dev_err(&ser->dev->dev, "CAIF: %s() - open failed:%d\n",
+			__func__, ret);
+		tty_unregister_ldisc(N_CAIF);
+		return ret;
+	}
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
+	dev = alloc_netdev(sizeof(*ser), "caifser%d", caifdev_setup);
+	if (!dev)
+		return -ENODEV;
+	ser = netdev_priv(dev);
+	pr_info("CAIF: %s(): "
+		"Starting CAIF Physical LDisc on tty:%s\n",
+		__func__, ttyname);
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
+}
+
+static void __exit caif_ser_exit(void)
+{
+	remove_caif_phy_dev(device);
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

