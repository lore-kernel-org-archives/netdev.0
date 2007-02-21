From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: [patch 24/24] Xen-paravirt_ops: Add the Xen virtual network device
	driver.
Date: Wed, 21 Feb 2007 12:53:18 -0800
Message-ID: <20070221205324.299230511@goop.org>
References: <20070221205254.169835700@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Chris Wright <chrisw@sous-sol.org>, virtualization@lists.osdl.org,
   xen-devel@lists.xensource.com, Ian Pratt <ian.pratt@xensource.com>,
   netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
   linux-kernel@vger.kernel.org
To: Andi Kleen <ak@muc.de>
Return-path: <virtualization-bounces@lists.osdl.org>
Content-Disposition: inline; filename=xen-netfront.patch
List-Unsubscribe: <https://lists.osdl.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.osdl.org?subject=unsubscribe>
List-Archive: <http://lists.osdl.org/pipermail/virtualization>
List-Post: <mailto:virtualization@lists.osdl.org>
List-Help: <mailto:virtualization-request@lists.osdl.org?subject=help>
List-Subscribe: <https://lists.osdl.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.osdl.org?subject=subscribe>
Sender: virtualization-bounces@lists.osdl.org
Errors-To: virtualization-bounces@lists.osdl.org
List-Id: netdev.vger.kernel.org

The network device frontend driver allows the kernel to access network
devices exported exported by a virtual machine containing a physical
network device driver.

Signed-off-by: Ian Pratt <ian.pratt@xensource.com>
Signed-off-by: Christian Limpach <Christian.Limpach@cl.cam.ac.uk>
Signed-off-by: Chris Wright <chrisw@sous-sol.org>
Signed-off-by: Jeremy Fitzhardinge <jeremy@xensource.com>
Cc: netdev@vger.kernel.org

---
 drivers/net/Kconfig        |   12 =

 drivers/net/Makefile       |    2 =

 drivers/net/xen-netfront.c | 2066 ++++++++++++++++++++++++++++++++++++++++=
++++
 include/xen/events.h       |    2 =

 4 files changed, 2082 insertions(+)

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2525,6 +2525,18 @@ source "drivers/atm/Kconfig"
 =

 source "drivers/s390/net/Kconfig"
 =

+config XEN_NETDEV_FRONTEND
+	tristate "Xen network device frontend driver"
+	depends on XEN
+	default y
+	help
+	  The network device frontend driver allows the kernel to
+	  access network devices exported exported by a virtual
+	  machine containing a physical network device driver. The
+	  frontend driver is intended for unprivileged guest domains;
+	  if you are compiling a kernel for a Xen guest, you almost
+	  certainly want to enable this.
+
 config ISERIES_VETH
 	tristate "iSeries Virtual Ethernet driver support"
 	depends on PPC_ISERIES
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -218,3 +218,5 @@ obj-$(CONFIG_FS_ENET) +=3D fs_enet/
 obj-$(CONFIG_FS_ENET) +=3D fs_enet/
 =

 obj-$(CONFIG_NETXEN_NIC) +=3D netxen/
+
+obj-$(CONFIG_XEN_NETDEV_FRONTEND) +=3D xen-netfront.o
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- /dev/null
+++ b/drivers/net/xen-netfront.c
@@ -0,0 +1,2066 @@
+/*************************************************************************=
*****
+ * Virtual network driver for conversing with remote driver backends.
+ *
+ * Copyright (c) 2002-2005, K A Fraser
+ * Copyright (c) 2005, XenSource Ltd
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation; or, when distributed
+ * separately from the Linux kernel or incorporated into other
+ * software packages, subject to the following license:
+ *
+ * Permission is hereby granted, free of charge, to any person obtaining a=
 copy
+ * of this source file (the "Software"), to deal in the Software without
+ * restriction, including without limitation the rights to use, copy, modi=
fy,
+ * merge, publish, distribute, sublicense, and/or sell copies of the Softw=
are,
+ * and to permit persons to whom the Software is furnished to do so, subje=
ct to
+ * the following conditions:
+ *
+ * The above copyright notice and this permission notice shall be included=
 in
+ * all copies or substantial portions of the Software.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS=
 OR
+ * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
+ * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL=
 THE
+ * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
+ * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
+ * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEA=
LINGS
+ * IN THE SOFTWARE.
+ */
+
+#include <linux/module.h>
+#include <linux/version.h>
+#include <linux/kernel.h>
+#include <linux/sched.h>
+#include <linux/slab.h>
+#include <linux/string.h>
+#include <linux/errno.h>
+#include <linux/netdevice.h>
+#include <linux/inetdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/skbuff.h>
+#include <linux/init.h>
+#include <linux/bitops.h>
+#include <linux/ethtool.h>
+#include <linux/in.h>
+#include <linux/if_ether.h>
+#include <linux/io.h>
+#include <linux/moduleparam.h>
+#include <net/sock.h>
+#include <net/pkt_sched.h>
+#include <net/arp.h>
+#include <net/route.h>
+#include <asm/uaccess.h>
+#include <xen/xenbus.h>
+#include <xen/interface/io/netif.h>
+#include <xen/interface/memory.h>
+#ifdef CONFIG_XEN_BALLOON
+#include <xen/balloon.h>
+#endif
+#include <asm/page.h>
+#include <xen/interface/grant_table.h>
+
+#include <xen/events.h>
+#include <xen/page.h>
+#include <xen/grant_table.h>
+
+/*
+ * Mutually-exclusive module options to select receive data path:
+ *  rx_copy : Packets are copied by network backend into local memory
+ *  rx_flip : Page containing packet data is transferred to our ownership
+ * For fully-virtualised guests there is no option - copying must be used.
+ * For paravirtualised guests, flipping is the default.
+ */
+#ifdef CONFIG_XEN
+static int MODPARM_rx_copy =3D 0;
+module_param_named(rx_copy, MODPARM_rx_copy, bool, 0);
+MODULE_PARM_DESC(rx_copy, "Copy packets from network card (rather than fli=
p)");
+static int MODPARM_rx_flip =3D 0;
+module_param_named(rx_flip, MODPARM_rx_flip, bool, 0);
+MODULE_PARM_DESC(rx_flip, "Flip packets from network card (rather than cop=
y)");
+#else
+static const int MODPARM_rx_copy =3D 1;
+static const int MODPARM_rx_flip =3D 0;
+#endif
+
+#define RX_COPY_THRESHOLD 256
+
+#define GRANT_INVALID_REF	0
+
+#define NET_TX_RING_SIZE __RING_SIZE((struct netif_tx_sring *)0, PAGE_SIZE)
+#define NET_RX_RING_SIZE __RING_SIZE((struct netif_rx_sring *)0, PAGE_SIZE)
+
+struct netfront_info {
+	struct list_head list;
+	struct net_device *netdev;
+
+	struct net_device_stats stats;
+
+	struct netif_tx_front_ring tx;
+	struct netif_rx_front_ring rx;
+
+	spinlock_t   tx_lock;
+	spinlock_t   rx_lock;
+
+	unsigned int evtchn, irq;
+	unsigned int copying_receiver;
+
+	/* Receive-ring batched refills. */
+#define RX_MIN_TARGET 8
+#define RX_DFL_MIN_TARGET 64
+#define RX_MAX_TARGET min_t(int, NET_RX_RING_SIZE, 256)
+	unsigned rx_min_target, rx_max_target, rx_target;
+	struct sk_buff_head rx_batch;
+
+	struct timer_list rx_refill_timer;
+
+	/*
+	 * {tx,rx}_skbs store outstanding skbuffs. The first entry in tx_skbs
+	 * is an index into a chain of free entries.
+	 */
+	struct sk_buff *tx_skbs[NET_TX_RING_SIZE+1];
+	struct sk_buff *rx_skbs[NET_RX_RING_SIZE];
+
+#define TX_MAX_TARGET min_t(int, NET_RX_RING_SIZE, 256)
+	grant_ref_t gref_tx_head;
+	grant_ref_t grant_tx_ref[NET_TX_RING_SIZE + 1];
+	grant_ref_t gref_rx_head;
+	grant_ref_t grant_rx_ref[NET_RX_RING_SIZE];
+
+	struct xenbus_device *xbdev;
+	int tx_ring_ref;
+	int rx_ring_ref;
+	u8 mac[ETH_ALEN];
+
+	unsigned long rx_pfn_array[NET_RX_RING_SIZE];
+	struct multicall_entry rx_mcl[NET_RX_RING_SIZE+1];
+	struct mmu_update rx_mmu[NET_RX_RING_SIZE];
+};
+
+struct netfront_rx_info {
+	struct netif_rx_response rx;
+	struct netif_extra_info extras[XEN_NETIF_EXTRA_TYPE_MAX - 1];
+};
+
+/*
+ * Access macros for acquiring freeing slots in tx_skbs[].
+ */
+
+static inline void add_id_to_freelist(struct sk_buff **list, unsigned shor=
t id)
+{
+	list[id] =3D list[0];
+	list[0]  =3D (void *)(unsigned long)id;
+}
+
+static inline unsigned short get_id_from_freelist(struct sk_buff **list)
+{
+	unsigned int id =3D (unsigned int)(unsigned long)list[0];
+	list[0] =3D list[id];
+	return id;
+}
+
+static inline int xennet_rxidx(RING_IDX idx)
+{
+	return idx & (NET_RX_RING_SIZE - 1);
+}
+
+static inline struct sk_buff *xennet_get_rx_skb(struct netfront_info *np,
+						RING_IDX ri)
+{
+	int i =3D xennet_rxidx(ri);
+	struct sk_buff *skb =3D np->rx_skbs[i];
+	np->rx_skbs[i] =3D NULL;
+	return skb;
+}
+
+static inline grant_ref_t xennet_get_rx_ref(struct netfront_info *np,
+					    RING_IDX ri)
+{
+	int i =3D xennet_rxidx(ri);
+	grant_ref_t ref =3D np->grant_rx_ref[i];
+	np->grant_rx_ref[i] =3D GRANT_INVALID_REF;
+	return ref;
+}
+
+#define DPRINTK(fmt, args...)				\
+	pr_debug("netfront (%s:%d) " fmt,		\
+		 __FUNCTION__, __LINE__, ##args)
+#define IPRINTK(fmt, args...)				\
+	printk(KERN_INFO "netfront: " fmt, ##args)
+#define WPRINTK(fmt, args...)				\
+	printk(KERN_WARNING "netfront: " fmt, ##args)
+
+static int setup_device(struct xenbus_device *, struct netfront_info *);
+static struct net_device *create_netdev(struct xenbus_device *);
+
+static void netfront_closing(struct xenbus_device *);
+
+static void end_access(int, void *);
+static void netif_disconnect_backend(struct netfront_info *);
+static int open_netdev(struct netfront_info *);
+static void close_netdev(struct netfront_info *);
+
+static int network_connect(struct net_device *);
+static void network_tx_buf_gc(struct net_device *);
+static void network_alloc_rx_buffers(struct net_device *);
+static int send_fake_arp(struct net_device *);
+
+static irqreturn_t netif_int(int irq, void *dev_id);
+
+#ifdef CONFIG_SYSFS
+static int xennet_sysfs_addif(struct net_device *netdev);
+static void xennet_sysfs_delif(struct net_device *netdev);
+#else /* !CONFIG_SYSFS */
+#define xennet_sysfs_addif(dev) (0)
+#define xennet_sysfs_delif(dev) do { } while(0)
+#endif
+
+static inline int xennet_can_sg(struct net_device *dev)
+{
+	return dev->features & NETIF_F_SG;
+}
+
+/**
+ * Entry point to this code when a new device is created.  Allocate the ba=
sic
+ * structures and the ring buffers for communication with the backend, and
+ * inform the backend of the appropriate details for those.
+ */
+static int __devinit netfront_probe(struct xenbus_device *dev,
+				    const struct xenbus_device_id *id)
+{
+	int err;
+	struct net_device *netdev;
+	struct netfront_info *info;
+
+	netdev =3D create_netdev(dev);
+	if (IS_ERR(netdev)) {
+		err =3D PTR_ERR(netdev);
+		xenbus_dev_fatal(dev, err, "creating netdev");
+		return err;
+	}
+
+	info =3D netdev_priv(netdev);
+	dev->dev.driver_data =3D info;
+
+	err =3D open_netdev(info);
+	if (err)
+		goto fail;
+
+	return 0;
+
+ fail:
+	free_netdev(netdev);
+	dev->dev.driver_data =3D NULL;
+	return err;
+}
+
+
+/**
+ * We are reconnecting to the backend, due to a suspend/resume, or a backe=
nd
+ * driver restart.  We tear down our netif structure and recreate it, but
+ * leave the device-layer structures intact so that this is transparent to=
 the
+ * rest of the kernel.
+ */
+static int netfront_resume(struct xenbus_device *dev)
+{
+	struct netfront_info *info =3D dev->dev.driver_data;
+
+	DPRINTK("%s\n", dev->nodename);
+
+	netif_disconnect_backend(info);
+	return 0;
+}
+
+static int xen_net_read_mac(struct xenbus_device *dev, u8 mac[])
+{
+	char *s, *e, *macstr;
+	int i;
+
+	macstr =3D s =3D xenbus_read(XBT_NIL, dev->nodename, "mac", NULL);
+	if (IS_ERR(macstr))
+		return PTR_ERR(macstr);
+
+	for (i =3D 0; i < ETH_ALEN; i++) {
+		mac[i] =3D simple_strtoul(s, &e, 16);
+		if ((s =3D=3D e) || (*e !=3D ((i =3D=3D ETH_ALEN-1) ? '\0' : ':'))) {
+			kfree(macstr);
+			return -ENOENT;
+		}
+		s =3D e+1;
+	}
+
+	kfree(macstr);
+	return 0;
+}
+
+/* Common code used when first setting up, and when resuming. */
+static int talk_to_backend(struct xenbus_device *dev,
+			   struct netfront_info *info)
+{
+	const char *message;
+	struct xenbus_transaction xbt;
+	int err;
+
+	err =3D xen_net_read_mac(dev, info->mac);
+	if (err) {
+		xenbus_dev_fatal(dev, err, "parsing %s/mac", dev->nodename);
+		goto out;
+	}
+
+	/* Create shared ring, alloc event channel. */
+	err =3D setup_device(dev, info);
+	if (err)
+		goto out;
+
+again:
+	err =3D xenbus_transaction_start(&xbt);
+	if (err) {
+		xenbus_dev_fatal(dev, err, "starting transaction");
+		goto destroy_ring;
+	}
+
+	err =3D xenbus_printf(xbt, dev->nodename, "tx-ring-ref","%u",
+			    info->tx_ring_ref);
+	if (err) {
+		message =3D "writing tx ring-ref";
+		goto abort_transaction;
+	}
+	err =3D xenbus_printf(xbt, dev->nodename, "rx-ring-ref","%u",
+			    info->rx_ring_ref);
+	if (err) {
+		message =3D "writing rx ring-ref";
+		goto abort_transaction;
+	}
+	err =3D xenbus_printf(xbt, dev->nodename,
+			    "event-channel", "%u", info->evtchn);
+	if (err) {
+		message =3D "writing event-channel";
+		goto abort_transaction;
+	}
+
+	err =3D xenbus_printf(xbt, dev->nodename, "request-rx-copy", "%u",
+			    info->copying_receiver);
+	if (err) {
+		message =3D "writing request-rx-copy";
+		goto abort_transaction;
+	}
+
+	err =3D xenbus_printf(xbt, dev->nodename, "feature-rx-notify", "%d", 1);
+	if (err) {
+		message =3D "writing feature-rx-notify";
+		goto abort_transaction;
+	}
+
+	err =3D xenbus_printf(xbt, dev->nodename, "feature-sg", "%d", 1);
+	if (err) {
+		message =3D "writing feature-sg";
+		goto abort_transaction;
+	}
+
+	err =3D xenbus_printf(xbt, dev->nodename, "feature-gso-tcpv4", "%d", 1);
+	if (err) {
+		message =3D "writing feature-gso-tcpv4";
+		goto abort_transaction;
+	}
+
+	err =3D xenbus_transaction_end(xbt, 0);
+	if (err) {
+		if (err =3D=3D -EAGAIN)
+			goto again;
+		xenbus_dev_fatal(dev, err, "completing transaction");
+		goto destroy_ring;
+	}
+
+	return 0;
+
+ abort_transaction:
+	xenbus_transaction_end(xbt, 1);
+	xenbus_dev_fatal(dev, err, "%s", message);
+ destroy_ring:
+	netif_disconnect_backend(info);
+ out:
+	return err;
+}
+
+static int setup_device(struct xenbus_device *dev, struct netfront_info *i=
nfo)
+{
+	struct netif_tx_sring *txs;
+	struct netif_rx_sring *rxs;
+	int err;
+	struct net_device *netdev =3D info->netdev;
+
+	info->tx_ring_ref =3D GRANT_INVALID_REF;
+	info->rx_ring_ref =3D GRANT_INVALID_REF;
+	info->rx.sring =3D NULL;
+	info->tx.sring =3D NULL;
+	info->irq =3D 0;
+
+	txs =3D (struct netif_tx_sring *)get_zeroed_page(GFP_KERNEL);
+	if (!txs) {
+		err =3D -ENOMEM;
+		xenbus_dev_fatal(dev, err, "allocating tx ring page");
+		goto fail;
+	}
+	SHARED_RING_INIT(txs);
+	FRONT_RING_INIT(&info->tx, txs, PAGE_SIZE);
+
+	err =3D xenbus_grant_ring(dev, virt_to_mfn(txs));
+	if (err < 0) {
+		free_page((unsigned long)txs);
+		goto fail;
+	}
+
+	info->tx_ring_ref =3D err;
+	rxs =3D (struct netif_rx_sring *)get_zeroed_page(GFP_KERNEL);
+	if (!rxs) {
+		err =3D -ENOMEM;
+		xenbus_dev_fatal(dev, err, "allocating rx ring page");
+		goto fail;
+	}
+	SHARED_RING_INIT(rxs);
+	FRONT_RING_INIT(&info->rx, rxs, PAGE_SIZE);
+
+	err =3D xenbus_grant_ring(dev, virt_to_mfn(rxs));
+	if (err < 0) {
+		free_page((unsigned long)rxs);
+		goto fail;
+	}
+	info->rx_ring_ref =3D err;
+
+	err =3D xenbus_alloc_evtchn(dev, &info->evtchn);
+	if (err)
+		goto fail;
+
+	memcpy(netdev->dev_addr, info->mac, ETH_ALEN);
+	err =3D bind_evtchn_to_irqhandler(info->evtchn, netif_int,
+					SA_SAMPLE_RANDOM, netdev->name,
+					netdev);
+	if (err < 0)
+		goto fail;
+	info->irq =3D err;
+	return 0;
+
+ fail:
+	return err;
+}
+
+/**
+ * Callback received when the backend's state changes.
+ */
+static void backend_changed(struct xenbus_device *dev,
+			    enum xenbus_state backend_state)
+{
+	struct netfront_info *np =3D dev->dev.driver_data;
+	struct net_device *netdev =3D np->netdev;
+
+	DPRINTK("%s\n", xenbus_strstate(backend_state));
+
+	switch (backend_state) {
+	case XenbusStateInitialising:
+	case XenbusStateInitialised:
+	case XenbusStateConnected:
+	case XenbusStateUnknown:
+	case XenbusStateClosed:
+		break;
+
+	case XenbusStateInitWait:
+		if (dev->state !=3D XenbusStateInitialising)
+			break;
+		if (network_connect(netdev) !=3D 0)
+			break;
+		xenbus_switch_state(dev, XenbusStateConnected);
+		(void)send_fake_arp(netdev);
+		break;
+
+	case XenbusStateClosing:
+		if (dev->state =3D=3D XenbusStateClosed)
+			break;
+		netfront_closing(dev);
+		break;
+	}
+}
+
+/** Send a packet on a net device to encourage switches to learn the
+ * MAC. We send a fake ARP request.
+ *
+ * @param dev device
+ * @return 0 on success, error code otherwise
+ */
+static int send_fake_arp(struct net_device *dev)
+{
+	struct sk_buff *skb;
+	u32             src_ip, dst_ip;
+
+	dst_ip =3D INADDR_BROADCAST;
+	src_ip =3D inet_select_addr(dev, dst_ip, RT_SCOPE_LINK);
+
+	/* No IP? Then nothing to do. */
+	if (src_ip =3D=3D 0)
+		return 0;
+
+	skb =3D arp_create(ARPOP_REPLY, ETH_P_ARP,
+			 dst_ip, dev, src_ip,
+			 /*dst_hw*/ NULL, /*src_hw*/ NULL,
+			 /*target_hw*/ dev->dev_addr);
+	if (skb =3D=3D NULL)
+		return -ENOMEM;
+
+	return dev_queue_xmit(skb);
+}
+
+static int network_open(struct net_device *dev)
+{
+	struct netfront_info *np =3D netdev_priv(dev);
+
+	memset(&np->stats, 0, sizeof(np->stats));
+
+	spin_lock(&np->rx_lock);
+	if (netif_carrier_ok(dev)) {
+		network_alloc_rx_buffers(dev);
+		np->rx.sring->rsp_event =3D np->rx.rsp_cons + 1;
+		if (RING_HAS_UNCONSUMED_RESPONSES(&np->rx))
+			netif_rx_schedule(dev);
+	}
+	spin_unlock(&np->rx_lock);
+
+	netif_start_queue(dev);
+
+	return 0;
+}
+
+static inline int netfront_tx_slot_available(struct netfront_info *np)
+{
+	return RING_FREE_REQUESTS(&np->tx) >=3D MAX_SKB_FRAGS + 2;
+}
+
+static inline void network_maybe_wake_tx(struct net_device *dev)
+{
+	struct netfront_info *np =3D netdev_priv(dev);
+
+	if (unlikely(netif_queue_stopped(dev)) &&
+	    netfront_tx_slot_available(np) &&
+	    likely(netif_running(dev)))
+		netif_wake_queue(dev);
+}
+
+static void network_tx_buf_gc(struct net_device *dev)
+{
+	RING_IDX cons, prod;
+	unsigned short id;
+	struct netfront_info *np =3D netdev_priv(dev);
+	struct sk_buff *skb;
+
+	BUG_ON(!netif_carrier_ok(dev));
+
+	do {
+		prod =3D np->tx.sring->rsp_prod;
+		rmb(); /* Ensure we see responses up to 'rp'. */
+
+		for (cons =3D np->tx.rsp_cons; cons !=3D prod; cons++) {
+			struct netif_tx_response *txrsp;
+
+			txrsp =3D RING_GET_RESPONSE(&np->tx, cons);
+			if (txrsp->status =3D=3D NETIF_RSP_NULL)
+				continue;
+
+			id  =3D txrsp->id;
+			skb =3D np->tx_skbs[id];
+			if (unlikely(gnttab_query_foreign_access(
+				np->grant_tx_ref[id]) !=3D 0)) {
+				printk(KERN_ALERT "network_tx_buf_gc: warning "
+				       "-- grant still in use by backend "
+				       "domain.\n");
+				BUG();
+			}
+			gnttab_end_foreign_access_ref(
+				np->grant_tx_ref[id], GNTMAP_readonly);
+			gnttab_release_grant_reference(
+				&np->gref_tx_head, np->grant_tx_ref[id]);
+			np->grant_tx_ref[id] =3D GRANT_INVALID_REF;
+			add_id_to_freelist(np->tx_skbs, id);
+			dev_kfree_skb_irq(skb);
+		}
+
+		np->tx.rsp_cons =3D prod;
+
+		/*
+		 * Set a new event, then check for race with update of tx_cons.
+		 * Note that it is essential to schedule a callback, no matter
+		 * how few buffers are pending. Even if there is space in the
+		 * transmit ring, higher layers may be blocked because too much
+		 * data is outstanding: in such cases notification from Xen is
+		 * likely to be the only kick that we'll get.
+		 */
+		np->tx.sring->rsp_event =3D
+			prod + ((np->tx.sring->req_prod - prod) >> 1) + 1;
+		mb();
+	} while ((cons =3D=3D prod) && (prod !=3D np->tx.sring->rsp_prod));
+
+	network_maybe_wake_tx(dev);
+}
+
+static void rx_refill_timeout(unsigned long data)
+{
+	struct net_device *dev =3D (struct net_device *)data;
+	netif_rx_schedule(dev);
+}
+
+static void network_alloc_rx_buffers(struct net_device *dev)
+{
+	unsigned short id;
+	struct netfront_info *np =3D netdev_priv(dev);
+	struct sk_buff *skb;
+	struct page *page;
+	int i, batch_target, notify;
+	RING_IDX req_prod =3D np->rx.req_prod_pvt;
+	struct xen_memory_reservation reservation;
+	grant_ref_t ref;
+	unsigned long pfn;
+	void *vaddr;
+	int nr_flips;
+	struct netif_rx_request *req;
+
+	if (unlikely(!netif_carrier_ok(dev)))
+		return;
+
+	/*
+	 * Allocate skbuffs greedily, even though we batch updates to the
+	 * receive ring. This creates a less bursty demand on the memory
+	 * allocator, so should reduce the chance of failed allocation requests
+	 * both for ourself and for other kernel subsystems.
+	 */
+	batch_target =3D np->rx_target - (req_prod - np->rx.rsp_cons);
+	for (i =3D skb_queue_len(&np->rx_batch); i < batch_target; i++) {
+		/*
+		 * Allocate an skb and a page. Do not use __dev_alloc_skb as
+		 * that will allocate page-sized buffers which is not
+		 * necessary here.
+		 * 16 bytes added as necessary headroom for netif_receive_skb.
+		 */
+		skb =3D alloc_skb(RX_COPY_THRESHOLD + 16 + NET_IP_ALIGN,
+				GFP_ATOMIC | __GFP_NOWARN);
+		if (unlikely(!skb))
+			goto no_skb;
+
+		page =3D alloc_page(GFP_ATOMIC | __GFP_NOWARN);
+		if (!page) {
+			kfree_skb(skb);
+no_skb:
+			/* Any skbuffs queued for refill? Force them out. */
+			if (i !=3D 0)
+				goto refill;
+			/* Could not allocate any skbuffs. Try again later. */
+			mod_timer(&np->rx_refill_timer,
+				  jiffies + (HZ/10));
+			break;
+		}
+
+		skb_reserve(skb, 16 + NET_IP_ALIGN); /* mimic dev_alloc_skb() */
+		skb_shinfo(skb)->frags[0].page =3D page;
+		skb_shinfo(skb)->nr_frags =3D 1;
+		__skb_queue_tail(&np->rx_batch, skb);
+	}
+
+	/* Is the batch large enough to be worthwhile? */
+	if (i < (np->rx_target/2)) {
+		if (req_prod > np->rx.sring->req_prod)
+			goto push;
+		return;
+	}
+
+	/* Adjust our fill target if we risked running out of buffers. */
+	if (((req_prod - np->rx.sring->rsp_prod) < (np->rx_target / 4)) &&
+	    ((np->rx_target *=3D 2) > np->rx_max_target))
+		np->rx_target =3D np->rx_max_target;
+
+ refill:
+	for (nr_flips =3D i =3D 0; ; i++) {
+		if ((skb =3D __skb_dequeue(&np->rx_batch)) =3D=3D NULL)
+			break;
+
+		skb->dev =3D dev;
+
+		id =3D xennet_rxidx(req_prod + i);
+
+		BUG_ON(np->rx_skbs[id]);
+		np->rx_skbs[id] =3D skb;
+
+		ref =3D gnttab_claim_grant_reference(&np->gref_rx_head);
+		BUG_ON((signed short)ref < 0);
+		np->grant_rx_ref[id] =3D ref;
+
+		pfn =3D page_to_pfn(skb_shinfo(skb)->frags[0].page);
+		vaddr =3D page_address(skb_shinfo(skb)->frags[0].page);
+
+		req =3D RING_GET_REQUEST(&np->rx, req_prod + i);
+		if (!np->copying_receiver) {
+			gnttab_grant_foreign_transfer_ref(ref,
+							  np->xbdev->otherend_id,
+							  pfn);
+			np->rx_pfn_array[nr_flips] =3D pfn_to_mfn(pfn);
+			if (!xen_feature(XENFEAT_auto_translated_physmap)) {
+				/* Remove this page before passing
+				 * back to Xen. */
+				set_phys_to_machine(pfn, INVALID_P2M_ENTRY);
+				MULTI_update_va_mapping(np->rx_mcl+i,
+							(unsigned long)vaddr,
+							__pte(0), 0);
+			}
+			nr_flips++;
+		} else {
+			gnttab_grant_foreign_access_ref(ref,
+							np->xbdev->otherend_id,
+							pfn_to_mfn(pfn),
+							0);
+		}
+
+		req->id =3D id;
+		req->gref =3D ref;
+	}
+
+	if ( nr_flips !=3D 0 ) {
+#ifdef CONFIG_XEN_BALLOON
+		/* Tell the ballon driver what is going on. */
+		balloon_update_driver_allowance(i);
+#endif
+
+		reservation.extent_start =3D np->rx_pfn_array;
+		reservation.nr_extents   =3D nr_flips;
+		reservation.extent_order =3D 0;
+		reservation.address_bits =3D 0;
+		reservation.domid        =3D DOMID_SELF;
+
+		if (!xen_feature(XENFEAT_auto_translated_physmap)) {
+			/* After all PTEs have been zapped, flush the TLB. */
+			np->rx_mcl[i-1].args[MULTI_UVMFLAGS_INDEX] =3D
+				UVMF_TLB_FLUSH|UVMF_ALL;
+
+			/* Give away a batch of pages. */
+			np->rx_mcl[i].op =3D __HYPERVISOR_memory_op;
+			np->rx_mcl[i].args[0] =3D XENMEM_decrease_reservation;
+			np->rx_mcl[i].args[1] =3D (unsigned long)&reservation;
+
+			/* Zap PTEs and give away pages in one big
+			 * multicall. */
+			(void)HYPERVISOR_multicall(np->rx_mcl, i+1);
+
+			/* Check return status of HYPERVISOR_memory_op(). */
+			if (unlikely(np->rx_mcl[i].result !=3D i))
+				panic("Unable to reduce memory reservation\n");
+		} else {
+			if (HYPERVISOR_memory_op(XENMEM_decrease_reservation,
+						 &reservation) !=3D i)
+				panic("Unable to reduce memory reservation\n");
+		}
+	} else {
+		wmb();
+	}
+
+	/* Above is a suitable barrier to ensure backend will see requests. */
+	np->rx.req_prod_pvt =3D req_prod + i;
+ push:
+	RING_PUSH_REQUESTS_AND_CHECK_NOTIFY(&np->rx, notify);
+	if (notify)
+		notify_remote_via_irq(np->irq);
+}
+
+static void xennet_move_rx_slot(struct netfront_info *np, struct sk_buff *=
skb,
+				grant_ref_t ref)
+{
+	int new =3D xennet_rxidx(np->rx.req_prod_pvt);
+
+	BUG_ON(np->rx_skbs[new]);
+	np->rx_skbs[new] =3D skb;
+	np->grant_rx_ref[new] =3D ref;
+	RING_GET_REQUEST(&np->rx, np->rx.req_prod_pvt)->id =3D new;
+	RING_GET_REQUEST(&np->rx, np->rx.req_prod_pvt)->gref =3D ref;
+	np->rx.req_prod_pvt++;
+}
+
+static void xennet_make_frags(struct sk_buff *skb, struct net_device *dev,
+			      struct netif_tx_request *tx)
+{
+	struct netfront_info *np =3D netdev_priv(dev);
+	char *data =3D skb->data;
+	unsigned long mfn;
+	RING_IDX prod =3D np->tx.req_prod_pvt;
+	int frags =3D skb_shinfo(skb)->nr_frags;
+	unsigned int offset =3D offset_in_page(data);
+	unsigned int len =3D skb_headlen(skb);
+	unsigned int id;
+	grant_ref_t ref;
+	int i;
+
+	while (len > PAGE_SIZE - offset) {
+		tx->size =3D PAGE_SIZE - offset;
+		tx->flags |=3D NETTXF_more_data;
+		len -=3D tx->size;
+		data +=3D tx->size;
+		offset =3D 0;
+
+		id =3D get_id_from_freelist(np->tx_skbs);
+		np->tx_skbs[id] =3D skb_get(skb);
+		tx =3D RING_GET_REQUEST(&np->tx, prod++);
+		tx->id =3D id;
+		ref =3D gnttab_claim_grant_reference(&np->gref_tx_head);
+		BUG_ON((signed short)ref < 0);
+
+		mfn =3D virt_to_mfn(data);
+		gnttab_grant_foreign_access_ref(ref, np->xbdev->otherend_id,
+						mfn, GNTMAP_readonly);
+
+		tx->gref =3D np->grant_tx_ref[id] =3D ref;
+		tx->offset =3D offset;
+		tx->size =3D len;
+		tx->flags =3D 0;
+	}
+
+	for (i =3D 0; i < frags; i++) {
+		skb_frag_t *frag =3D skb_shinfo(skb)->frags + i;
+
+		tx->flags |=3D NETTXF_more_data;
+
+		id =3D get_id_from_freelist(np->tx_skbs);
+		np->tx_skbs[id] =3D skb_get(skb);
+		tx =3D RING_GET_REQUEST(&np->tx, prod++);
+		tx->id =3D id;
+		ref =3D gnttab_claim_grant_reference(&np->gref_tx_head);
+		BUG_ON((signed short)ref < 0);
+
+		mfn =3D pfn_to_mfn(page_to_pfn(frag->page));
+		gnttab_grant_foreign_access_ref(ref, np->xbdev->otherend_id,
+						mfn, GNTMAP_readonly);
+
+		tx->gref =3D np->grant_tx_ref[id] =3D ref;
+		tx->offset =3D frag->page_offset;
+		tx->size =3D frag->size;
+		tx->flags =3D 0;
+	}
+
+	np->tx.req_prod_pvt =3D prod;
+}
+  =

+static int network_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	unsigned short id;
+	struct netfront_info *np =3D netdev_priv(dev);
+	struct netif_tx_request *tx;
+	struct netif_extra_info *extra;
+	char *data =3D skb->data;
+	RING_IDX i;
+	grant_ref_t ref;
+	unsigned long mfn;
+	int notify;
+	int frags =3D skb_shinfo(skb)->nr_frags;
+	unsigned int offset =3D offset_in_page(data);
+	unsigned int len =3D skb_headlen(skb);
+
+	frags +=3D (offset + len + PAGE_SIZE - 1) / PAGE_SIZE;
+	if (unlikely(frags > MAX_SKB_FRAGS + 1)) {
+		printk(KERN_ALERT "xennet: skb rides the rocket: %d frags\n",
+		       frags);
+		dump_stack();
+		goto drop;
+	}
+
+	spin_lock_irq(&np->tx_lock);
+
+	if (unlikely(!netif_carrier_ok(dev) ||
+		     (frags > 1 && !xennet_can_sg(dev)) ||
+		     netif_needs_gso(dev, skb))) {
+		spin_unlock_irq(&np->tx_lock);
+		goto drop;
+	}
+
+	i =3D np->tx.req_prod_pvt;
+
+	id =3D get_id_from_freelist(np->tx_skbs);
+	np->tx_skbs[id] =3D skb;
+
+	tx =3D RING_GET_REQUEST(&np->tx, i);
+
+	tx->id   =3D id;
+	ref =3D gnttab_claim_grant_reference(&np->gref_tx_head);
+	BUG_ON((signed short)ref < 0);
+	mfn =3D virt_to_mfn(data);
+	gnttab_grant_foreign_access_ref(
+		ref, np->xbdev->otherend_id, mfn, GNTMAP_readonly);
+	tx->gref =3D np->grant_tx_ref[id] =3D ref;
+	tx->offset =3D offset;
+	tx->size =3D len;
+	extra =3D NULL;
+
+ 	tx->flags =3D 0;
+ 	if (skb->ip_summed =3D=3D CHECKSUM_PARTIAL) /* local packet? */
+ 		tx->flags |=3D NETTXF_csum_blank | NETTXF_data_validated;
+
+	if (skb_shinfo(skb)->gso_size) {
+		struct netif_extra_info *gso =3D (struct netif_extra_info *)
+			RING_GET_REQUEST(&np->tx, ++i);
+
+		if (extra)
+			extra->flags |=3D XEN_NETIF_EXTRA_FLAG_MORE;
+		else
+			tx->flags |=3D NETTXF_extra_info;
+
+		gso->u.gso.size =3D skb_shinfo(skb)->gso_size;
+		gso->u.gso.type =3D XEN_NETIF_GSO_TYPE_TCPV4;
+		gso->u.gso.pad =3D 0;
+		gso->u.gso.features =3D 0;
+
+		gso->type =3D XEN_NETIF_EXTRA_TYPE_GSO;
+		gso->flags =3D 0;
+		extra =3D gso;
+	}
+
+	np->tx.req_prod_pvt =3D i + 1;
+
+	xennet_make_frags(skb, dev, tx);
+	tx->size =3D skb->len;
+
+	RING_PUSH_REQUESTS_AND_CHECK_NOTIFY(&np->tx, notify);
+	if (notify)
+		notify_remote_via_irq(np->irq);
+
+	network_tx_buf_gc(dev);
+
+	if (!netfront_tx_slot_available(np))
+		netif_stop_queue(dev);
+
+	spin_unlock_irq(&np->tx_lock);
+
+	np->stats.tx_bytes +=3D skb->len;
+	np->stats.tx_packets++;
+
+	return 0;
+
+ drop:
+	np->stats.tx_dropped++;
+	dev_kfree_skb(skb);
+	return 0;
+}
+
+static irqreturn_t netif_int(int irq, void *dev_id)
+{
+	struct net_device *dev =3D dev_id;
+	struct netfront_info *np =3D netdev_priv(dev);
+	unsigned long flags;
+
+	spin_lock_irqsave(&np->tx_lock, flags);
+
+	if (likely(netif_carrier_ok(dev))) {
+		network_tx_buf_gc(dev);
+		/* Under tx_lock: protects access to rx shared-ring indexes. */
+		if (RING_HAS_UNCONSUMED_RESPONSES(&np->rx))
+			netif_rx_schedule(dev);
+	}
+
+	spin_unlock_irqrestore(&np->tx_lock, flags);
+
+	return IRQ_HANDLED;
+}
+
+static void handle_incoming_queue(struct net_device *dev, struct sk_buff_h=
ead *rxq)
+{
+	struct sk_buff *skb;
+
+	while ((skb =3D __skb_dequeue(rxq)) !=3D NULL) {
+		struct page *page =3D (struct page *)skb->nh.raw;
+		void *vaddr =3D page_address(page);
+
+		memcpy(skb->data, vaddr + (skb->h.raw - skb->nh.raw),
+		       skb_headlen(skb));
+
+		if (page !=3D skb_shinfo(skb)->frags[0].page)
+			__free_page(page);
+
+		/* Ethernet work: Delayed to here as it peeks the header. */
+		skb->protocol =3D eth_type_trans(skb, dev);
+
+		/* Pass it up. */
+		netif_receive_skb(skb);
+		dev->last_rx =3D jiffies;
+	}
+}
+
+int xennet_get_extras(struct netfront_info *np,
+		      struct netif_extra_info *extras, RING_IDX rp)
+
+{
+	struct netif_extra_info *extra;
+	RING_IDX cons =3D np->rx.rsp_cons;
+	int err =3D 0;
+
+	do {
+		struct sk_buff *skb;
+		grant_ref_t ref;
+
+		if (unlikely(cons + 1 =3D=3D rp)) {
+			if (net_ratelimit())
+				WPRINTK("Missing extra info\n");
+			err =3D -EBADR;
+			break;
+		}
+
+		extra =3D (struct netif_extra_info *)
+			RING_GET_RESPONSE(&np->rx, ++cons);
+
+		if (unlikely(!extra->type ||
+			     extra->type >=3D XEN_NETIF_EXTRA_TYPE_MAX)) {
+			if (net_ratelimit())
+				WPRINTK("Invalid extra type: %d\n",
+					extra->type);
+			err =3D -EINVAL;
+		} else {
+			memcpy(&extras[extra->type - 1], extra,
+			       sizeof(*extra));
+		}
+
+		skb =3D xennet_get_rx_skb(np, cons);
+		ref =3D xennet_get_rx_ref(np, cons);
+		xennet_move_rx_slot(np, skb, ref);
+	} while (extra->flags & XEN_NETIF_EXTRA_FLAG_MORE);
+
+	np->rx.rsp_cons =3D cons;
+	return err;
+}
+
+static int xennet_get_responses(struct netfront_info *np,
+				struct netfront_rx_info *rinfo, RING_IDX rp,
+				struct sk_buff_head *list,
+				int *pages_flipped_p)
+{
+	int pages_flipped =3D *pages_flipped_p;
+	struct mmu_update *mmu;
+	struct multicall_entry *mcl;
+	struct netif_rx_response *rx =3D &rinfo->rx;
+	struct netif_extra_info *extras =3D rinfo->extras;
+	RING_IDX cons =3D np->rx.rsp_cons;
+	struct sk_buff *skb =3D xennet_get_rx_skb(np, cons);
+	grant_ref_t ref =3D xennet_get_rx_ref(np, cons);
+	int max =3D MAX_SKB_FRAGS + (rx->status <=3D RX_COPY_THRESHOLD);
+	int frags =3D 1;
+	int err =3D 0;
+	unsigned long ret;
+
+	if (rx->flags & NETRXF_extra_info) {
+		err =3D xennet_get_extras(np, extras, rp);
+		cons =3D np->rx.rsp_cons;
+	}
+
+	for (;;) {
+		unsigned long mfn;
+
+		if (unlikely(rx->status < 0 ||
+			     rx->offset + rx->status > PAGE_SIZE)) {
+			if (net_ratelimit())
+				WPRINTK("rx->offset: %x, size: %u\n",
+					rx->offset, rx->status);
+			xennet_move_rx_slot(np, skb, ref);
+			err =3D -EINVAL;
+			goto next;
+		}
+
+		/*
+		 * This definitely indicates a bug, either in this driver or in
+		 * the backend driver. In future this should flag the bad
+		 * situation to the system controller to reboot the backed.
+		 */
+		if (ref =3D=3D GRANT_INVALID_REF) {
+			if (net_ratelimit())
+				WPRINTK("Bad rx response id %d.\n", rx->id);
+			err =3D -EINVAL;
+			goto next;
+		}
+
+		if (!np->copying_receiver) {
+			/* Memory pressure, insufficient buffer
+			 * headroom, ... */
+			mfn =3D gnttab_end_foreign_transfer_ref(ref);
+			if (!mfn) {
+				if (net_ratelimit())
+					WPRINTK("Unfulfilled rx req "
+						"(id=3D%d, st=3D%d).\n",
+						rx->id, rx->status);
+				xennet_move_rx_slot(np, skb, ref);
+				err =3D -ENOMEM;
+				goto next;
+			}
+
+			if (!xen_feature(XENFEAT_auto_translated_physmap)) {
+				/* Remap the page. */
+				struct page *page =3D
+					skb_shinfo(skb)->frags[0].page;
+				unsigned long pfn =3D page_to_pfn(page);
+				void *vaddr =3D page_address(page);
+
+				mcl =3D np->rx_mcl + pages_flipped;
+				mmu =3D np->rx_mmu + pages_flipped;
+
+				MULTI_update_va_mapping(mcl,
+							(unsigned long)vaddr,
+							mfn_pte(mfn, PAGE_KERNEL),
+							0);
+				mmu->ptr =3D ((u64)mfn << PAGE_SHIFT)
+					| MMU_MACHPHYS_UPDATE;
+				mmu->val =3D pfn;
+
+				set_phys_to_machine(pfn, mfn);
+			}
+			pages_flipped++;
+		} else {
+			ret =3D gnttab_end_foreign_access_ref(ref, 0);
+			BUG_ON(!ret);
+		}
+
+		gnttab_release_grant_reference(&np->gref_rx_head, ref);
+
+		__skb_queue_tail(list, skb);
+
+next:
+		if (!(rx->flags & NETRXF_more_data))
+			break;
+
+		if (cons + frags =3D=3D rp) {
+			if (net_ratelimit())
+				WPRINTK("Need more frags\n");
+			err =3D -ENOENT;
+			break;
+		}
+
+		rx =3D RING_GET_RESPONSE(&np->rx, cons + frags);
+		skb =3D xennet_get_rx_skb(np, cons + frags);
+		ref =3D xennet_get_rx_ref(np, cons + frags);
+		frags++;
+	}
+
+	if (unlikely(frags > max)) {
+		if (net_ratelimit())
+			WPRINTK("Too many frags\n");
+		err =3D -E2BIG;
+	}
+
+	if (unlikely(err))
+		np->rx.rsp_cons =3D cons + frags;
+
+	*pages_flipped_p =3D pages_flipped;
+
+	return err;
+}
+
+static RING_IDX xennet_fill_frags(struct netfront_info *np,
+				  struct sk_buff *skb,
+				  struct sk_buff_head *list)
+{
+	struct skb_shared_info *shinfo =3D skb_shinfo(skb);
+	int nr_frags =3D shinfo->nr_frags;
+	RING_IDX cons =3D np->rx.rsp_cons;
+	skb_frag_t *frag =3D shinfo->frags + nr_frags;
+	struct sk_buff *nskb;
+
+	while ((nskb =3D __skb_dequeue(list))) {
+		struct netif_rx_response *rx =3D
+			RING_GET_RESPONSE(&np->rx, ++cons);
+
+		frag->page =3D skb_shinfo(nskb)->frags[0].page;
+		frag->page_offset =3D rx->offset;
+		frag->size =3D rx->status;
+
+		skb->data_len +=3D rx->status;
+
+		skb_shinfo(nskb)->nr_frags =3D 0;
+		kfree_skb(nskb);
+
+		frag++;
+		nr_frags++;
+	}
+
+	shinfo->nr_frags =3D nr_frags;
+	return cons;
+}
+
+static int xennet_set_skb_gso(struct sk_buff *skb, struct netif_extra_info=
 *gso)
+{
+	if (!gso->u.gso.size) {
+		if (net_ratelimit())
+			WPRINTK("GSO size must not be zero.\n");
+		return -EINVAL;
+	}
+
+	/* Currently only TCPv4 S.O. is supported. */
+	if (gso->u.gso.type !=3D XEN_NETIF_GSO_TYPE_TCPV4) {
+		if (net_ratelimit())
+			WPRINTK("Bad GSO type %d.\n", gso->u.gso.type);
+		return -EINVAL;
+	}
+
+	skb_shinfo(skb)->gso_size =3D gso->u.gso.size;
+	skb_shinfo(skb)->gso_type =3D SKB_GSO_TCPV4;
+
+	/* Header must be checked, and gso_segs computed. */
+	skb_shinfo(skb)->gso_type |=3D SKB_GSO_DODGY;
+	skb_shinfo(skb)->gso_segs =3D 0;
+
+	return 0;
+}
+
+static int netif_poll(struct net_device *dev, int *pbudget)
+{
+	struct netfront_info *np =3D netdev_priv(dev);
+	struct sk_buff *skb;
+	struct netfront_rx_info rinfo;
+	struct netif_rx_response *rx =3D &rinfo.rx;
+	struct netif_extra_info *extras =3D rinfo.extras;
+	RING_IDX i, rp;
+	struct multicall_entry *mcl;
+	int work_done, budget, more_to_do =3D 1;
+	struct sk_buff_head rxq;
+	struct sk_buff_head errq;
+	struct sk_buff_head tmpq;
+	unsigned long flags;
+	unsigned int len;
+	int pages_flipped =3D 0;
+	int err;
+
+	spin_lock(&np->rx_lock);
+
+	if (unlikely(!netif_carrier_ok(dev))) {
+		spin_unlock(&np->rx_lock);
+		return 0;
+	}
+
+	skb_queue_head_init(&rxq);
+	skb_queue_head_init(&errq);
+	skb_queue_head_init(&tmpq);
+
+	if ((budget =3D *pbudget) > dev->quota)
+		budget =3D dev->quota;
+	rp =3D np->rx.sring->rsp_prod;
+	rmb(); /* Ensure we see queued responses up to 'rp'. */
+
+	i =3D np->rx.rsp_cons;
+	work_done =3D 0;
+	while ((i !=3D rp) && (work_done < budget)) {
+		memcpy(rx, RING_GET_RESPONSE(&np->rx, i), sizeof(*rx));
+		memset(extras, 0, sizeof(extras));
+
+		err =3D xennet_get_responses(np, &rinfo, rp, &tmpq,
+					   &pages_flipped);
+
+		if (unlikely(err)) {
+err:	=

+			while ((skb =3D __skb_dequeue(&tmpq)))
+				__skb_queue_tail(&errq, skb);
+			np->stats.rx_errors++;
+			i =3D np->rx.rsp_cons;
+			continue;
+		}
+
+		skb =3D __skb_dequeue(&tmpq);
+
+		if (extras[XEN_NETIF_EXTRA_TYPE_GSO - 1].type) {
+			struct netif_extra_info *gso;
+			gso =3D &extras[XEN_NETIF_EXTRA_TYPE_GSO - 1];
+
+			if (unlikely(xennet_set_skb_gso(skb, gso))) {
+				__skb_queue_head(&tmpq, skb);
+				np->rx.rsp_cons +=3D skb_queue_len(&tmpq);
+				goto err;
+			}
+		}
+
+		skb->nh.raw =3D (void *)skb_shinfo(skb)->frags[0].page;
+		skb->h.raw =3D skb->nh.raw + rx->offset;
+
+		len =3D rx->status;
+		if (len > RX_COPY_THRESHOLD)
+			len =3D RX_COPY_THRESHOLD;
+		skb_put(skb, len);
+
+		if (rx->status > len) {
+			skb_shinfo(skb)->frags[0].page_offset =3D
+				rx->offset + len;
+			skb_shinfo(skb)->frags[0].size =3D rx->status - len;
+			skb->data_len =3D rx->status - len;
+		} else {
+			skb_shinfo(skb)->frags[0].page =3D NULL;
+			skb_shinfo(skb)->nr_frags =3D 0;
+		}
+
+		i =3D xennet_fill_frags(np, skb, &tmpq);
+
+		/*
+		 * Truesize must approximates the size of true data plus
+		 * any supervisor overheads. Adding hypervisor overheads
+		 * has been shown to significantly reduce achievable
+		 * bandwidth with the default receive buffer size. It is
+		 * therefore not wise to account for it here.
+		 *
+		 * After alloc_skb(RX_COPY_THRESHOLD), truesize is set to
+		 * RX_COPY_THRESHOLD + the supervisor overheads. Here, we
+		 * add the size of the data pulled in xennet_fill_frags().
+		 *
+		 * We also adjust for any unused space in the main data
+		 * area by subtracting (RX_COPY_THRESHOLD - len). This is
+		 * especially important with drivers which split incoming
+		 * packets into header and data, using only 66 bytes of
+		 * the main data area (see the e1000 driver for example.)
+		 * On such systems, without this last adjustement, our
+		 * achievable receive throughout using the standard receive
+		 * buffer size was cut by 25%(!!!).
+		 */
+		skb->truesize +=3D skb->data_len - (RX_COPY_THRESHOLD - len);
+		skb->len +=3D skb->data_len;
+
+		if (rx->flags & NETRXF_data_validated)
+			skb->ip_summed =3D CHECKSUM_UNNECESSARY;
+
+		np->stats.rx_packets++;
+		np->stats.rx_bytes +=3D skb->len;
+
+		__skb_queue_tail(&rxq, skb);
+
+		np->rx.rsp_cons =3D ++i;
+		work_done++;
+	}
+
+	if (pages_flipped) {
+#ifdef CONFIG_XEN_BALLOON
+		/* Some pages are no longer absent... */
+		balloon_update_driver_allowance(-pages_flipped);
+#endif
+		/* Do all the remapping work, and M2P updates. */
+		if (!xen_feature(XENFEAT_auto_translated_physmap)) {
+			mcl =3D np->rx_mcl + pages_flipped;
+			MULTI_mmu_update(mcl, np->rx_mmu,
+					 pages_flipped, 0, DOMID_SELF);
+			(void)HYPERVISOR_multicall(np->rx_mcl,
+						   pages_flipped + 1);
+		}
+	}
+
+	while ((skb =3D __skb_dequeue(&errq)))
+		kfree_skb(skb);
+
+	handle_incoming_queue(dev, &rxq);
+
+	/* If we get a callback with very few responses, reduce fill target. */
+	/* NB. Note exponential increase, linear decrease. */
+	if (((np->rx.req_prod_pvt - np->rx.sring->rsp_prod) >
+	     ((3*np->rx_target) / 4)) &&
+	    (--np->rx_target < np->rx_min_target))
+		np->rx_target =3D np->rx_min_target;
+
+	network_alloc_rx_buffers(dev);
+
+	*pbudget   -=3D work_done;
+	dev->quota -=3D work_done;
+
+	if (work_done < budget) {
+		local_irq_save(flags);
+
+		RING_FINAL_CHECK_FOR_RESPONSES(&np->rx, more_to_do);
+		if (!more_to_do)
+			__netif_rx_complete(dev);
+
+		local_irq_restore(flags);
+	}
+
+	spin_unlock(&np->rx_lock);
+
+	return more_to_do;
+}
+
+static void netif_release_tx_bufs(struct netfront_info *np)
+{
+	struct sk_buff *skb;
+	int i;
+
+	for (i =3D 1; i <=3D NET_TX_RING_SIZE; i++) {
+		if ((unsigned long)np->tx_skbs[i] < PAGE_OFFSET)
+			continue;
+
+		skb =3D np->tx_skbs[i];
+		gnttab_end_foreign_access_ref(
+			np->grant_tx_ref[i], GNTMAP_readonly);
+		gnttab_release_grant_reference(
+			&np->gref_tx_head, np->grant_tx_ref[i]);
+		np->grant_tx_ref[i] =3D GRANT_INVALID_REF;
+		add_id_to_freelist(np->tx_skbs, i);
+		dev_kfree_skb_irq(skb);
+	}
+}
+
+static void netif_release_rx_bufs(struct netfront_info *np)
+{
+	struct mmu_update      *mmu =3D np->rx_mmu;
+	struct multicall_entry *mcl =3D np->rx_mcl;
+	struct sk_buff_head free_list;
+	struct sk_buff *skb;
+	unsigned long mfn;
+	int xfer =3D 0, noxfer =3D 0, unused =3D 0;
+	int id, ref;
+
+	if (np->copying_receiver) {
+		printk("%s: fix me for copying receiver.\n", __FUNCTION__);
+		return;
+	}
+
+	skb_queue_head_init(&free_list);
+
+	spin_lock(&np->rx_lock);
+
+	for (id =3D 0; id < NET_RX_RING_SIZE; id++) {
+		if ((ref =3D np->grant_rx_ref[id]) =3D=3D GRANT_INVALID_REF) {
+			unused++;
+			continue;
+		}
+
+		skb =3D np->rx_skbs[id];
+		mfn =3D gnttab_end_foreign_transfer_ref(ref);
+		gnttab_release_grant_reference(&np->gref_rx_head, ref);
+		np->grant_rx_ref[id] =3D GRANT_INVALID_REF;
+		add_id_to_freelist(np->rx_skbs, id);
+
+		if (0 =3D=3D mfn) {
+#ifdef CONFIG_XEN_BALLOON
+			struct page *page =3D skb_shinfo(skb)->frags[0].page;
+			balloon_release_driver_page(page);
+#endif
+			skb_shinfo(skb)->nr_frags =3D 0;
+			dev_kfree_skb(skb);
+			noxfer++;
+			continue;
+		}
+
+		if (!xen_feature(XENFEAT_auto_translated_physmap)) {
+			/* Remap the page. */
+			struct page *page =3D skb_shinfo(skb)->frags[0].page;
+			unsigned long pfn =3D page_to_pfn(page);
+			void *vaddr =3D page_address(page);
+
+			MULTI_update_va_mapping(mcl, (unsigned long)vaddr,
+						mfn_pte(mfn, PAGE_KERNEL),
+						0);
+			mcl++;
+			mmu->ptr =3D ((u64)mfn << PAGE_SHIFT)
+				| MMU_MACHPHYS_UPDATE;
+			mmu->val =3D pfn;
+			mmu++;
+
+			set_phys_to_machine(pfn, mfn);
+		}
+		__skb_queue_tail(&free_list, skb);
+		xfer++;
+	}
+
+	printk("%s: %d xfer, %d noxfer, %d unused\n",
+	       __FUNCTION__, xfer, noxfer, unused);
+
+	if (xfer) {
+#ifdef CONFIG_XEN_BALLOON
+		/* Some pages are no longer absent... */
+		balloon_update_driver_allowance(-xfer);
+#endif
+
+		if (!xen_feature(XENFEAT_auto_translated_physmap)) {
+			/* Do all the remapping work and M2P updates. */
+			mcl->op =3D __HYPERVISOR_mmu_update;
+			mcl->args[0] =3D (unsigned long)np->rx_mmu;
+			mcl->args[1] =3D mmu - np->rx_mmu;
+			mcl->args[2] =3D 0;
+			mcl->args[3] =3D DOMID_SELF;
+			mcl++;
+			HYPERVISOR_multicall(np->rx_mcl, mcl - np->rx_mcl);
+		}
+	}
+
+	while ((skb =3D __skb_dequeue(&free_list)) !=3D NULL)
+		dev_kfree_skb(skb);
+
+	spin_unlock(&np->rx_lock);
+}
+
+static int network_close(struct net_device *dev)
+{
+	struct netfront_info *np =3D netdev_priv(dev);
+	netif_stop_queue(np->netdev);
+	return 0;
+}
+
+
+static struct net_device_stats *network_get_stats(struct net_device *dev)
+{
+	struct netfront_info *np =3D netdev_priv(dev);
+	return &np->stats;
+}
+
+static int xennet_change_mtu(struct net_device *dev, int mtu)
+{
+	int max =3D xennet_can_sg(dev) ? 65535 - ETH_HLEN : ETH_DATA_LEN;
+
+	if (mtu > max)
+		return -EINVAL;
+	dev->mtu =3D mtu;
+	return 0;
+}
+
+static int xennet_set_sg(struct net_device *dev, u32 data)
+{
+	if (data) {
+		struct netfront_info *np =3D netdev_priv(dev);
+		int val;
+
+		if (xenbus_scanf(XBT_NIL, np->xbdev->otherend, "feature-sg",
+				 "%d", &val) < 0)
+			val =3D 0;
+		if (!val)
+			return -ENOSYS;
+	} else if (dev->mtu > ETH_DATA_LEN)
+		dev->mtu =3D ETH_DATA_LEN;
+
+	return ethtool_op_set_sg(dev, data);
+}
+
+static int xennet_set_tso(struct net_device *dev, u32 data)
+{
+	if (data) {
+		struct netfront_info *np =3D netdev_priv(dev);
+		int val;
+
+		if (xenbus_scanf(XBT_NIL, np->xbdev->otherend,
+				 "feature-gso-tcpv4", "%d", &val) < 0)
+			val =3D 0;
+		if (!val)
+			return -ENOSYS;
+	}
+
+	return ethtool_op_set_tso(dev, data);
+}
+
+static void xennet_set_features(struct net_device *dev)
+{
+	/* Turn off all GSO bits except ROBUST. */
+	dev->features &=3D (1 << NETIF_F_GSO_SHIFT) - 1;
+	dev->features |=3D NETIF_F_GSO_ROBUST;
+	xennet_set_sg(dev, 0);
+
+	/* We need checksum offload to enable scatter/gather and TSO. */
+	if (!(dev->features & NETIF_F_IP_CSUM))
+		return;
+
+	if (!xennet_set_sg(dev, 1))
+		xennet_set_tso(dev, 1);
+}
+
+static int network_connect(struct net_device *dev)
+{
+	struct netfront_info *np =3D netdev_priv(dev);
+	int i, requeue_idx, err;
+	struct sk_buff *skb;
+	grant_ref_t ref;
+	struct netif_rx_request *req;
+	unsigned int feature_rx_copy, feature_rx_flip;
+
+	err =3D xenbus_scanf(XBT_NIL, np->xbdev->otherend,
+			   "feature-rx-copy", "%u", &feature_rx_copy);
+	if (err !=3D 1)
+		feature_rx_copy =3D 0;
+	err =3D xenbus_scanf(XBT_NIL, np->xbdev->otherend,
+			   "feature-rx-flip", "%u", &feature_rx_flip);
+	if (err !=3D 1)
+		feature_rx_flip =3D 1;
+
+	/*
+	 * Copy packets on receive path if:
+	 *  (a) This was requested by user, and the backend supports it; or
+	 *  (b) Flipping was requested, but this is unsupported by the backend.
+	 */
+	np->copying_receiver =3D ((MODPARM_rx_copy && feature_rx_copy) ||
+				(MODPARM_rx_flip && !feature_rx_flip));
+
+	err =3D talk_to_backend(np->xbdev, np);
+	if (err)
+		return err;
+
+	xennet_set_features(dev);
+
+	IPRINTK("device %s has %sing receive path.\n",
+		dev->name, np->copying_receiver ? "copy" : "flipp");
+
+	spin_lock_irq(&np->tx_lock);
+	spin_lock(&np->rx_lock);
+
+	/*
+	 * Recovery procedure:
+	 *  NB. Freelist index entries are always going to be less than
+	 *  PAGE_OFFSET, whereas pointers to skbs will always be equal or
+	 *  greater than PAGE_OFFSET: we use this property to distinguish
+	 *  them.
+	 */
+
+	/* Step 1: Discard all pending TX packet fragments. */
+	netif_release_tx_bufs(np);
+
+	/* Step 2: Rebuild the RX buffer freelist and the RX ring itself. */
+	for (requeue_idx =3D 0, i =3D 0; i < NET_RX_RING_SIZE; i++) {
+		if (!np->rx_skbs[i])
+			continue;
+
+		skb =3D np->rx_skbs[requeue_idx] =3D xennet_get_rx_skb(np, i);
+		ref =3D np->grant_rx_ref[requeue_idx] =3D xennet_get_rx_ref(np, i);
+		req =3D RING_GET_REQUEST(&np->rx, requeue_idx);
+
+		if (!np->copying_receiver) {
+			gnttab_grant_foreign_transfer_ref(
+				ref, np->xbdev->otherend_id,
+				page_to_pfn(skb_shinfo(skb)->frags->page));
+		} else {
+			gnttab_grant_foreign_access_ref(
+				ref, np->xbdev->otherend_id,
+				pfn_to_mfn(page_to_pfn(skb_shinfo(skb)->
+						       frags->page)),
+				0);
+		}
+		req->gref =3D ref;
+		req->id   =3D requeue_idx;
+
+		requeue_idx++;
+	}
+
+	np->rx.req_prod_pvt =3D requeue_idx;
+
+	/*
+	 * Step 3: All public and private state should now be sane.  Get
+	 * ready to start sending and receiving packets and give the driver
+	 * domain a kick because we've probably just requeued some
+	 * packets.
+	 */
+	netif_carrier_on(dev);
+	notify_remote_via_irq(np->irq);
+	network_tx_buf_gc(dev);
+	network_alloc_rx_buffers(dev);
+
+	spin_unlock(&np->rx_lock);
+	spin_unlock_irq(&np->tx_lock);
+
+	return 0;
+}
+
+static void netif_uninit(struct net_device *dev)
+{
+	struct netfront_info *np =3D netdev_priv(dev);
+	netif_release_tx_bufs(np);
+	netif_release_rx_bufs(np);
+	gnttab_free_grant_references(np->gref_tx_head);
+	gnttab_free_grant_references(np->gref_rx_head);
+}
+
+static struct ethtool_ops network_ethtool_ops =3D
+{
+	.get_tx_csum =3D ethtool_op_get_tx_csum,
+	.set_tx_csum =3D ethtool_op_set_tx_csum,
+	.get_sg =3D ethtool_op_get_sg,
+	.set_sg =3D xennet_set_sg,
+	.get_tso =3D ethtool_op_get_tso,
+	.set_tso =3D xennet_set_tso,
+	.get_link =3D ethtool_op_get_link,
+};
+
+#ifdef CONFIG_SYSFS
+static ssize_t show_rxbuf_min(struct device *dev, =

+			      struct device_attribute *attr, char *buf)
+{
+	struct net_device *netdev =3D to_net_dev(dev);
+	struct netfront_info *info =3D netdev_priv(netdev);
+
+	return sprintf(buf, "%u\n", info->rx_min_target);
+}
+
+static ssize_t store_rxbuf_min(struct device *dev,
+			       struct device_attribute *attr,
+			       const char *buf, size_t len)
+{
+	struct net_device *netdev =3D to_net_dev(dev);
+	struct netfront_info *np =3D netdev_priv(netdev);
+	char *endp;
+	unsigned long target;
+
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	target =3D simple_strtoul(buf, &endp, 0);
+	if (endp =3D=3D buf)
+		return -EBADMSG;
+
+	if (target < RX_MIN_TARGET)
+		target =3D RX_MIN_TARGET;
+	if (target > RX_MAX_TARGET)
+		target =3D RX_MAX_TARGET;
+
+	spin_lock(&np->rx_lock);
+	if (target > np->rx_max_target)
+		np->rx_max_target =3D target;
+	np->rx_min_target =3D target;
+	if (target > np->rx_target)
+		np->rx_target =3D target;
+
+	network_alloc_rx_buffers(netdev);
+
+	spin_unlock(&np->rx_lock);
+	return len;
+}
+
+static ssize_t show_rxbuf_max(struct device *dev,
+			      struct device_attribute *attr, char *buf)
+{
+	struct net_device *netdev =3D to_net_dev(dev);
+	struct netfront_info *info =3D netdev_priv(netdev);
+
+	return sprintf(buf, "%u\n", info->rx_max_target);
+}
+
+static ssize_t store_rxbuf_max(struct device *dev,
+			       struct device_attribute *attr,
+			       const char *buf, size_t len)
+{
+	struct net_device *netdev =3D to_net_dev(dev);
+	struct netfront_info *np =3D netdev_priv(netdev);
+	char *endp;
+	unsigned long target;
+
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	target =3D simple_strtoul(buf, &endp, 0);
+	if (endp =3D=3D buf)
+		return -EBADMSG;
+
+	if (target < RX_MIN_TARGET)
+		target =3D RX_MIN_TARGET;
+	if (target > RX_MAX_TARGET)
+		target =3D RX_MAX_TARGET;
+
+	spin_lock(&np->rx_lock);
+	if (target < np->rx_min_target)
+		np->rx_min_target =3D target;
+	np->rx_max_target =3D target;
+	if (target < np->rx_target)
+		np->rx_target =3D target;
+
+	network_alloc_rx_buffers(netdev);
+
+	spin_unlock(&np->rx_lock);
+	return len;
+}
+
+static ssize_t show_rxbuf_cur(struct device *dev,
+			      struct device_attribute *attr, char *buf)
+{
+	struct net_device *netdev =3D to_net_dev(dev);
+	struct netfront_info *info =3D netdev_priv(netdev);
+
+	return sprintf(buf, "%u\n", info->rx_target);
+}
+
+static struct device_attribute xennet_attrs[] =3D {
+	__ATTR(rxbuf_min, S_IRUGO|S_IWUSR, show_rxbuf_min, store_rxbuf_min),
+	__ATTR(rxbuf_max, S_IRUGO|S_IWUSR, show_rxbuf_max, store_rxbuf_max),
+	__ATTR(rxbuf_cur, S_IRUGO, show_rxbuf_cur, NULL),
+};
+
+static int xennet_sysfs_addif(struct net_device *netdev)
+{
+	int i;
+	int error =3D 0;
+
+	for (i =3D 0; i < ARRAY_SIZE(xennet_attrs); i++) {
+		error =3D device_create_file(&netdev->dev, =

+					   &xennet_attrs[i]);
+		if (error)
+			goto fail;
+	}
+	return 0;
+
+ fail:
+	while (--i >=3D 0)
+		device_remove_file(&netdev->dev, &xennet_attrs[i]);
+	return error;
+}
+
+static void xennet_sysfs_delif(struct net_device *netdev)
+{
+	int i;
+
+	for (i =3D 0; i < ARRAY_SIZE(xennet_attrs); i++) {
+		device_remove_file(&netdev->dev, &xennet_attrs[i]);
+	}
+}
+
+#endif /* CONFIG_SYSFS */
+
+
+/*
+ * Nothing to do here. Virtual interface is point-to-point and the
+ * physical interface is probably promiscuous anyway.
+ */
+static void network_set_multicast_list(struct net_device *dev)
+{
+}
+
+static struct net_device * __devinit create_netdev(struct xenbus_device *d=
ev)
+{
+	int i, err =3D 0;
+	struct net_device *netdev =3D NULL;
+	struct netfront_info *np =3D NULL;
+
+	netdev =3D alloc_etherdev(sizeof(struct netfront_info));
+	if (!netdev) {
+		printk(KERN_WARNING "%s> alloc_etherdev failed.\n",
+		       __FUNCTION__);
+		return ERR_PTR(-ENOMEM);
+	}
+
+	np                   =3D netdev_priv(netdev);
+	np->xbdev            =3D dev;
+
+	netif_carrier_off(netdev);
+
+	spin_lock_init(&np->tx_lock);
+	spin_lock_init(&np->rx_lock);
+
+	skb_queue_head_init(&np->rx_batch);
+	np->rx_target     =3D RX_DFL_MIN_TARGET;
+	np->rx_min_target =3D RX_DFL_MIN_TARGET;
+	np->rx_max_target =3D RX_MAX_TARGET;
+
+	init_timer(&np->rx_refill_timer);
+	np->rx_refill_timer.data =3D (unsigned long)netdev;
+	np->rx_refill_timer.function =3D rx_refill_timeout;
+
+	/* Initialise {tx,rx}_skbs as a free chain containing every entry. */
+	for (i =3D 0; i <=3D NET_TX_RING_SIZE; i++) {
+		np->tx_skbs[i] =3D (void *)((unsigned long) i+1);
+		np->grant_tx_ref[i] =3D GRANT_INVALID_REF;
+	}
+
+	for (i =3D 0; i < NET_RX_RING_SIZE; i++) {
+		np->rx_skbs[i] =3D NULL;
+		np->grant_rx_ref[i] =3D GRANT_INVALID_REF;
+	}
+
+	/* A grant for every tx ring slot */
+	if (gnttab_alloc_grant_references(TX_MAX_TARGET,
+					  &np->gref_tx_head) < 0) {
+		printk(KERN_ALERT "#### netfront can't alloc tx grant refs\n");
+		err =3D -ENOMEM;
+		goto exit;
+	}
+	/* A grant for every rx ring slot */
+	if (gnttab_alloc_grant_references(RX_MAX_TARGET,
+					  &np->gref_rx_head) < 0) {
+		printk(KERN_ALERT "#### netfront can't alloc rx grant refs\n");
+		err =3D -ENOMEM;
+		goto exit_free_tx;
+	}
+
+	netdev->open            =3D network_open;
+	netdev->hard_start_xmit =3D network_start_xmit;
+	netdev->stop            =3D network_close;
+	netdev->get_stats       =3D network_get_stats;
+	netdev->poll            =3D netif_poll;
+	netdev->set_multicast_list =3D network_set_multicast_list;
+	netdev->uninit          =3D netif_uninit;
+	netdev->change_mtu	=3D xennet_change_mtu;
+	netdev->weight          =3D 64;
+	netdev->features        =3D NETIF_F_IP_CSUM;
+
+	SET_ETHTOOL_OPS(netdev, &network_ethtool_ops);
+	SET_MODULE_OWNER(netdev);
+	SET_NETDEV_DEV(netdev, &dev->dev);
+
+	np->netdev =3D netdev;
+	return netdev;
+
+ exit_free_tx:
+	gnttab_free_grant_references(np->gref_tx_head);
+ exit:
+	free_netdev(netdev);
+	return ERR_PTR(err);
+}
+
+/*
+ * We use this notifier to send out a fake ARP reply to reset switches and
+ * router ARP caches when an IP interface is brought up on a VIF.
+ */
+static int
+inetdev_notify(struct notifier_block *this, unsigned long event, void *ptr)
+{
+	struct in_ifaddr  *ifa =3D (struct in_ifaddr *)ptr;
+	struct net_device *dev =3D ifa->ifa_dev->dev;
+
+	/* UP event and is it one of our devices? */
+	if (event =3D=3D NETDEV_UP && dev->open =3D=3D network_open)
+		(void)send_fake_arp(dev);
+
+	return NOTIFY_DONE;
+}
+
+
+/* ** Close down ** */
+
+
+/**
+ * Handle the change of state of the backend to Closing.  We must delete o=
ur
+ * device-layer structures now, to ensure that writes are flushed through =
to
+ * the backend.  Once is this done, we can switch to Closed in
+ * acknowledgement.
+ */
+static void netfront_closing(struct xenbus_device *dev)
+{
+	struct netfront_info *info =3D dev->dev.driver_data;
+
+	DPRINTK("%s\n", dev->nodename);
+
+	close_netdev(info);
+	xenbus_frontend_closed(dev);
+}
+
+
+static int __devexit netfront_remove(struct xenbus_device *dev)
+{
+	struct netfront_info *info =3D dev->dev.driver_data;
+
+	DPRINTK("%s\n", dev->nodename);
+
+	netif_disconnect_backend(info);
+	free_netdev(info->netdev);
+
+	return 0;
+}
+
+
+static int open_netdev(struct netfront_info *info)
+{
+	int err;
+	=

+	err =3D register_netdev(info->netdev);
+	if (err) {
+		printk(KERN_WARNING "%s: register_netdev err=3D%d\n",
+		       __FUNCTION__, err);
+		return err;
+	}
+
+	err =3D xennet_sysfs_addif(info->netdev);
+	if (err) {
+		unregister_netdev(info->netdev);
+		printk(KERN_WARNING "%s: add sysfs failed err=3D%d\n",
+		       __FUNCTION__, err);
+		return err;
+	}
+
+	return 0;
+}
+
+static void close_netdev(struct netfront_info *info)
+{
+	del_timer_sync(&info->rx_refill_timer);
+
+	xennet_sysfs_delif(info->netdev);
+	unregister_netdev(info->netdev);
+}
+
+
+static void netif_disconnect_backend(struct netfront_info *info)
+{
+	/* Stop old i/f to prevent errors whilst we rebuild the state. */
+	spin_lock_irq(&info->tx_lock);
+	spin_lock(&info->rx_lock);
+	netif_carrier_off(info->netdev);
+	spin_unlock(&info->rx_lock);
+	spin_unlock_irq(&info->tx_lock);
+
+	if (info->irq)
+		unbind_from_irqhandler(info->irq, info->netdev);
+	info->evtchn =3D info->irq =3D 0;
+
+	end_access(info->tx_ring_ref, info->tx.sring);
+	end_access(info->rx_ring_ref, info->rx.sring);
+	info->tx_ring_ref =3D GRANT_INVALID_REF;
+	info->rx_ring_ref =3D GRANT_INVALID_REF;
+	info->tx.sring =3D NULL;
+	info->rx.sring =3D NULL;
+}
+
+
+static void end_access(int ref, void *page)
+{
+	if (ref !=3D GRANT_INVALID_REF)
+		gnttab_end_foreign_access(ref, 0, (unsigned long)page);
+}
+
+
+/* ** Driver registration ** */
+
+
+static struct xenbus_device_id netfront_ids[] =3D {
+	{ "vif" },
+	{ "" }
+};
+
+
+static struct xenbus_driver netfront =3D {
+	.name =3D "vif",
+	.owner =3D THIS_MODULE,
+	.ids =3D netfront_ids,
+	.probe =3D netfront_probe,
+	.remove =3D __devexit_p(netfront_remove),
+	.resume =3D netfront_resume,
+	.otherend_changed =3D backend_changed,
+};
+
+
+static struct notifier_block notifier_inetdev =3D {
+	.notifier_call  =3D inetdev_notify,
+};
+
+static int __init netif_init(void)
+{
+	if (!is_running_on_xen())
+		return -ENODEV;
+
+#ifdef CONFIG_XEN
+	if (MODPARM_rx_flip && MODPARM_rx_copy) {
+		WPRINTK("Cannot specify both rx_copy and rx_flip.\n");
+		return -EINVAL;
+	}
+
+	if (!MODPARM_rx_flip && !MODPARM_rx_copy)
+		MODPARM_rx_flip =3D 1; /* Default is to flip. */
+#endif
+
+	if (is_initial_xendomain())
+		return 0;
+
+	IPRINTK("Initialising virtual ethernet driver.\n");
+
+	(void)register_inetaddr_notifier(&notifier_inetdev);
+
+	return xenbus_register_frontend(&netfront);
+}
+module_init(netif_init);
+
+
+static void __exit netif_exit(void)
+{
+	if (is_initial_xendomain())
+		return;
+
+	unregister_inetaddr_notifier(&notifier_inetdev);
+
+	return xenbus_unregister_driver(&netfront);
+}
+module_exit(netif_exit);
+
+MODULE_LICENSE("Dual BSD/GPL");
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- a/include/xen/events.h
+++ b/include/xen/events.h
@@ -2,6 +2,8 @@
 #define _XEN_EVENTS_H
 =

 #include <linux/irq.h>
+#include <xen/interface/event_channel.h>
+#include <asm/xen/hypercall.h>
 =

 int bind_evtchn_to_irqhandler(unsigned int evtchn,
 			      irqreturn_t (*handler)(int, void *),

-- =
