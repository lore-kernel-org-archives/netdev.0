From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: [PATCH] xen network backend driver
Date: Wed, 19 Jan 2011 15:01:58 +0000
Message-ID: <1295449318.14981.3484.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jeremy Fitzhardinge <jeremy@goop.org>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
To: <netdev@vger.kernel.org>, xen-devel <xen-devel@lists.xensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:18531 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754568Ab1ASPCC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jan 2011 10:02:02 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

The following patch implements the Xen network backend driver for
upstream Linux. This is the host side counterpart to the frontend driver
in drivers/net/xen-netfront.c. The PV protocol is also implemented by
frontend drivers in other OSes too, such as the BSDs and even Windows.

This driver has a long history as an out of tree driver but I am
submitting it here as a single monolithic patch to aid review. Once it
has been reviewed and is considered suitable for merging can we perhaps
consider merging the equivalent git branch which maintains much of
history?

The patch is based on the driver from the xen.git pvops kernel tree but
has been put through the checkpatch.pl wringer plus several manual
cleanup passes. It has also been moved from drivers/xen/netback to
drivers/net/xen-netback.

More significantly the guest transmit path (i.e. what looks like receive
to netback) has been significantly reworked to remove the dependency on
the out of tree PageForeign page flag (a core kernel patch which enables
a per page destructor callback on the final put_page). This page flag is
needed in order to implement a grant map based transmit path (where
guest pages are mapped directly into SKB frags). Instead this version of
netback uses grant copy operations into regular memory belonging to the
backend domain. Reinstating the grant map functionality is something
which I would like to revisit in the future.

The patch is also available in git at

  git://xenbits.xen.org/people/ianc/linux-2.6.git upstream/dom0/backend/netback

(based on mainline 329620a878cf89184b28500d37fa33cc870a3357)

The upstream/dom0/backend/netback-base branch contains the history which
is imported from the xen.git tree. This is followed by
upstream/dom0/backend/netback-cleanup which is the checkpatch and other
cleanups and finally upstream/dom0/backend/netback has the upstreaming
specific changes.

The complete patch's diffstat looks like:

 drivers/net/Kconfig                 |    7 
 drivers/net/Makefile                |    1 
 drivers/net/xen-netback/Makefile    |    3 
 drivers/net/xen-netback/common.h    |  250 +++++
 drivers/net/xen-netback/interface.c |  413 ++++++++
 drivers/net/xen-netback/netback.c   | 1756 ++++++++++++++++++++++++++++++++++++
 drivers/net/xen-netback/xenbus.c    |  485 +++++++++
 include/xen/interface/io/netif.h    |    4 
 include/xen/interface/io/ring.h     |   19 
 9 files changed, 2935 insertions(+), 3 deletions(-)

To give an idea how much has changed versus the xen.git version the
diffstat between upstream/dom0/backend/netback-base and
upstream/dom0/backend/netback is:

 drivers/net/Kconfig                                |    7 +
 drivers/net/Makefile                               |    1 +
 drivers/{xen/netback => net/xen-netback}/Makefile  |    0 
 drivers/{xen/netback => net/xen-netback}/common.h  |   89 +---
 .../{xen/netback => net/xen-netback}/interface.c   |   79 +--
 drivers/{xen/netback => net/xen-netback}/netback.c |  633 ++++++++------------
 drivers/{xen/netback => net/xen-netback}/xenbus.c  |   76 +--
 drivers/xen/Kconfig                                |    7 -
 drivers/xen/Makefile                               |    1 -
 9 files changed, 313 insertions(+), 580 deletions(-)
 rename drivers/{xen/netback => net/xen-netback}/Makefile (100%)
 rename drivers/{xen/netback => net/xen-netback}/common.h (75%)
 rename drivers/{xen/netback => net/xen-netback}/interface.c (85%)
 rename drivers/{xen/netback => net/xen-netback}/netback.c (75%)
 rename drivers/{xen/netback => net/xen-netback}/xenbus.c (85%)

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>

Ian.

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index cbf0635..5b088f5 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2970,6 +2970,13 @@ config XEN_NETDEV_FRONTEND
 	  if you are compiling a kernel for a Xen guest, you almost
 	  certainly want to enable this.
 
+config XEN_NETDEV_BACKEND
+	tristate "Xen backend network device"
+	depends on XEN_BACKEND
+	help
+	  Implement the network backend driver, which passes packets
+	  from the guest domain's frontend drivers to the network.
+
 config ISERIES_VETH
 	tristate "iSeries Virtual Ethernet driver support"
 	depends on PPC_ISERIES
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index b90738d..145dfd7 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -171,6 +171,7 @@ obj-$(CONFIG_SLIP) += slip.o
 obj-$(CONFIG_SLHC) += slhc.o
 
 obj-$(CONFIG_XEN_NETDEV_FRONTEND) += xen-netfront.o
+obj-$(CONFIG_XEN_NETDEV_BACKEND) += xen-netback/
 
 obj-$(CONFIG_DUMMY) += dummy.o
 obj-$(CONFIG_IFB) += ifb.o
diff --git a/drivers/net/xen-netback/Makefile b/drivers/net/xen-netback/Makefile
new file mode 100644
index 0000000..e346e81
--- /dev/null
+++ b/drivers/net/xen-netback/Makefile
@@ -0,0 +1,3 @@
+obj-$(CONFIG_XEN_NETDEV_BACKEND) := xen-netback.o
+
+xen-netback-y := netback.o xenbus.o interface.o
diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
new file mode 100644
index 0000000..2d55ed6
--- /dev/null
+++ b/drivers/net/xen-netback/common.h
@@ -0,0 +1,250 @@
+/******************************************************************************
+ * arch/xen/drivers/netif/backend/common.h
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation; or, when distributed
+ * separately from the Linux kernel or incorporated into other
+ * software packages, subject to the following license:
+ *
+ * Permission is hereby granted, free of charge, to any person obtaining a copy
+ * of this source file (the "Software"), to deal in the Software without
+ * restriction, including without limitation the rights to use, copy, modify,
+ * merge, publish, distribute, sublicense, and/or sell copies of the Software,
+ * and to permit persons to whom the Software is furnished to do so, subject to
+ * the following conditions:
+ *
+ * The above copyright notice and this permission notice shall be included in
+ * all copies or substantial portions of the Software.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
+ * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
+ * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
+ * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
+ * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
+ * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
+ * IN THE SOFTWARE.
+ */
+
+#ifndef __NETIF__BACKEND__COMMON_H__
+#define __NETIF__BACKEND__COMMON_H__
+
+#define pr_fmt(fmt) KBUILD_MODNAME ":%s: " fmt, __func__
+
+#include <linux/version.h>
+#include <linux/module.h>
+#include <linux/interrupt.h>
+#include <linux/slab.h>
+#include <linux/ip.h>
+#include <linux/in.h>
+#include <linux/io.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/wait.h>
+#include <linux/sched.h>
+
+#include <xen/interface/io/netif.h>
+#include <asm/pgalloc.h>
+#include <xen/interface/grant_table.h>
+#include <xen/grant_table.h>
+#include <xen/xenbus.h>
+
+struct xen_netif {
+	/* Unique identifier for this interface. */
+	domid_t          domid;
+	int              group;
+	unsigned int     handle;
+
+	u8               fe_dev_addr[6];
+
+	/* Physical parameters of the comms window. */
+	grant_handle_t   tx_shmem_handle;
+	grant_ref_t      tx_shmem_ref;
+	grant_handle_t   rx_shmem_handle;
+	grant_ref_t      rx_shmem_ref;
+	unsigned int     irq;
+
+	/* The shared rings and indexes. */
+	struct xen_netif_tx_back_ring tx;
+	struct xen_netif_rx_back_ring rx;
+	struct vm_struct *tx_comms_area;
+	struct vm_struct *rx_comms_area;
+
+	/* Flags that must not be set in dev->features */
+	int features_disabled;
+
+	/* Frontend feature information. */
+	u8 can_sg:1;
+	u8 gso:1;
+	u8 gso_prefix:1;
+	u8 csum:1;
+
+	/* Internal feature information. */
+	u8 can_queue:1;	    /* can queue packets for receiver? */
+
+	/* Allow netif_be_start_xmit() to peek ahead in the rx request
+	 * ring.  This is a prediction of what rx_req_cons will be once
+	 * all queued skbs are put on the ring. */
+	RING_IDX rx_req_cons_peek;
+
+	/* Transmit shaping: allow 'credit_bytes' every 'credit_usec'. */
+	unsigned long   credit_bytes;
+	unsigned long   credit_usec;
+	unsigned long   remaining_credit;
+	struct timer_list credit_timeout;
+
+	/* Miscellaneous private stuff. */
+	struct list_head list;  /* scheduling list */
+	atomic_t         refcnt;
+	struct net_device *dev;
+	struct net_device_stats stats;
+
+	unsigned int carrier;
+
+	wait_queue_head_t waiting_to_free;
+};
+
+/*
+ * Implement our own carrier flag: the network stack's version causes delays
+ * when the carrier is re-enabled (in particular, dev_activate() may not
+ * immediately be called, which can cause packet loss; also the etherbridge
+ * can be rather lazy in activating its port).
+ */
+#define netback_carrier_on(netif)	((netif)->carrier = 1)
+#define netback_carrier_off(netif)	((netif)->carrier = 0)
+#define netback_carrier_ok(netif)	((netif)->carrier)
+
+struct backend_info {
+	struct xenbus_device *dev;
+	struct xen_netif *netif;
+	enum xenbus_state frontend_state;
+	struct xenbus_watch hotplug_status_watch;
+	int have_hotplug_status_watch:1;
+};
+
+#define NET_TX_RING_SIZE __RING_SIZE((struct xen_netif_tx_sring *)0, PAGE_SIZE)
+#define NET_RX_RING_SIZE __RING_SIZE((struct xen_netif_rx_sring *)0, PAGE_SIZE)
+
+void netif_disconnect(struct xen_netif *netif);
+
+void netif_set_features(struct xen_netif *netif);
+struct xen_netif *netif_alloc(struct device *parent, domid_t domid,
+			      unsigned int handle);
+int netif_map(struct xen_netif *netif, unsigned long tx_ring_ref,
+	      unsigned long rx_ring_ref, unsigned int evtchn);
+
+static inline void netif_get(struct xen_netif *netif)
+{
+	atomic_inc(&netif->refcnt);
+}
+
+static inline void  netif_put(struct xen_netif *netif)
+{
+	if (atomic_dec_and_test(&netif->refcnt))
+		wake_up(&netif->waiting_to_free);
+}
+
+int netif_xenbus_init(void);
+
+#define netif_schedulable(netif)				\
+	(netif_running((netif)->dev) && netback_carrier_ok(netif))
+
+void netif_schedule_work(struct xen_netif *netif);
+void netif_deschedule_work(struct xen_netif *netif);
+
+int netif_be_start_xmit(struct sk_buff *skb, struct net_device *dev);
+struct net_device_stats *netif_be_get_stats(struct net_device *dev);
+irqreturn_t netif_be_int(int irq, void *dev_id);
+
+static inline int netbk_can_queue(struct net_device *dev)
+{
+	struct xen_netif *netif = netdev_priv(dev);
+	return netif->can_queue;
+}
+
+static inline int netbk_can_sg(struct net_device *dev)
+{
+	struct xen_netif *netif = netdev_priv(dev);
+	return netif->can_sg;
+}
+
+struct pending_tx_info {
+	struct xen_netif_tx_request req;
+	struct xen_netif *netif;
+};
+typedef unsigned int pending_ring_idx_t;
+
+struct netbk_rx_meta {
+	int id;
+	int size;
+	int gso_size;
+};
+
+#define MAX_PENDING_REQS 256
+
+#define MAX_BUFFER_OFFSET PAGE_SIZE
+
+/* extra field used in struct page */
+union page_ext {
+	struct {
+#if BITS_PER_LONG < 64
+#define IDX_WIDTH   8
+#define GROUP_WIDTH (BITS_PER_LONG - IDX_WIDTH)
+		unsigned int group:GROUP_WIDTH;
+		unsigned int idx:IDX_WIDTH;
+#else
+		unsigned int group, idx;
+#endif
+	} e;
+	void *mapping;
+};
+
+struct xen_netbk {
+	union {
+		struct {
+			struct tasklet_struct net_tx_tasklet;
+			struct tasklet_struct net_rx_tasklet;
+		} tasklet;
+
+		struct {
+			wait_queue_head_t netbk_action_wq;
+			struct task_struct *task;
+		} kthread;
+	};
+
+	struct sk_buff_head rx_queue;
+	struct sk_buff_head tx_queue;
+
+	struct timer_list net_timer;
+
+	struct page *mmap_pages[MAX_PENDING_REQS];
+
+	pending_ring_idx_t pending_prod;
+	pending_ring_idx_t pending_cons;
+	struct list_head net_schedule_list;
+
+	/* Protect the net_schedule_list in netif. */
+	spinlock_t net_schedule_list_lock;
+
+	atomic_t netfront_count;
+
+	struct pending_tx_info pending_tx_info[MAX_PENDING_REQS];
+	struct gnttab_copy tx_copy_ops[MAX_PENDING_REQS];
+
+	u16 pending_ring[MAX_PENDING_REQS];
+
+	/*
+	 * Each head or fragment can be up to 4096 bytes. Given
+	 * MAX_BUFFER_OFFSET of 4096 the worst case is that each
+	 * head/fragment uses 2 copy operation.
+	 */
+	struct gnttab_copy grant_copy_op[2*NET_RX_RING_SIZE];
+	unsigned char rx_notify[NR_IRQS];
+	u16 notify_list[NET_RX_RING_SIZE];
+	struct netbk_rx_meta meta[2*NET_RX_RING_SIZE];
+};
+
+extern struct xen_netbk *xen_netbk;
+extern int xen_netbk_group_nr;
+
+#endif /* __NETIF__BACKEND__COMMON_H__ */
diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
new file mode 100644
index 0000000..295ab3d
--- /dev/null
+++ b/drivers/net/xen-netback/interface.c
@@ -0,0 +1,413 @@
+/******************************************************************************
+ * arch/xen/drivers/netif/backend/interface.c
+ *
+ * Network-device interface management.
+ *
+ * Copyright (c) 2004-2005, Keir Fraser
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation; or, when distributed
+ * separately from the Linux kernel or incorporated into other
+ * software packages, subject to the following license:
+ *
+ * Permission is hereby granted, free of charge, to any person obtaining a copy
+ * of this source file (the "Software"), to deal in the Software without
+ * restriction, including without limitation the rights to use, copy, modify,
+ * merge, publish, distribute, sublicense, and/or sell copies of the Software,
+ * and to permit persons to whom the Software is furnished to do so, subject to
+ * the following conditions:
+ *
+ * The above copyright notice and this permission notice shall be included in
+ * all copies or substantial portions of the Software.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
+ * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
+ * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
+ * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
+ * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
+ * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
+ * IN THE SOFTWARE.
+ */
+
+#include "common.h"
+
+#include <linux/ethtool.h>
+#include <linux/rtnetlink.h>
+
+#include <xen/events.h>
+#include <asm/xen/hypercall.h>
+
+/*
+ * Module parameter 'queue_length':
+ *
+ * Enables queuing in the network stack when a client has run out of receive
+ * descriptors.
+ */
+static unsigned long netbk_queue_length = 32;
+module_param_named(queue_length, netbk_queue_length, ulong, 0644);
+
+static void netbk_add_netif(struct xen_netbk *netbk, int group_nr,
+			   struct xen_netif *netif)
+{
+	int i;
+	int min_netfront_count;
+	int min_group = 0;
+	min_netfront_count = atomic_read(&netbk[0].netfront_count);
+	for (i = 0; i < group_nr; i++) {
+		int netfront_count = atomic_read(&netbk[i].netfront_count);
+		if (netfront_count < min_netfront_count) {
+			min_group = i;
+			min_netfront_count = netfront_count;
+		}
+	}
+
+	netif->group = min_group;
+	atomic_inc(&netbk[netif->group].netfront_count);
+}
+
+static void netbk_remove_netif(struct xen_netbk *netbk, struct xen_netif *netif)
+{
+	atomic_dec(&netbk[netif->group].netfront_count);
+}
+
+static void __netif_up(struct xen_netif *netif)
+{
+	netbk_add_netif(xen_netbk, xen_netbk_group_nr, netif);
+	enable_irq(netif->irq);
+	netif_schedule_work(netif);
+}
+
+static void __netif_down(struct xen_netif *netif)
+{
+	disable_irq(netif->irq);
+	netif_deschedule_work(netif);
+	netbk_remove_netif(xen_netbk, netif);
+}
+
+static int net_open(struct net_device *dev)
+{
+	struct xen_netif *netif = netdev_priv(dev);
+	if (netback_carrier_ok(netif)) {
+		__netif_up(netif);
+		netif_start_queue(dev);
+	}
+	return 0;
+}
+
+static int net_close(struct net_device *dev)
+{
+	struct xen_netif *netif = netdev_priv(dev);
+	if (netback_carrier_ok(netif))
+		__netif_down(netif);
+	netif_stop_queue(dev);
+	return 0;
+}
+
+static int netbk_change_mtu(struct net_device *dev, int mtu)
+{
+	int max = netbk_can_sg(dev) ? 65535 - ETH_HLEN : ETH_DATA_LEN;
+
+	if (mtu > max)
+		return -EINVAL;
+	dev->mtu = mtu;
+	return 0;
+}
+
+void netif_set_features(struct xen_netif *netif)
+{
+	struct net_device *dev = netif->dev;
+	int features = dev->features;
+
+	if (netif->can_sg)
+		features |= NETIF_F_SG;
+	if (netif->gso || netif->gso_prefix)
+		features |= NETIF_F_TSO;
+	if (netif->csum)
+		features |= NETIF_F_IP_CSUM;
+
+	features &= ~(netif->features_disabled);
+
+	if (!(features & NETIF_F_SG) && dev->mtu > ETH_DATA_LEN)
+		dev->mtu = ETH_DATA_LEN;
+
+	dev->features = features;
+}
+
+static int netbk_set_tx_csum(struct net_device *dev, u32 data)
+{
+	struct xen_netif *netif = netdev_priv(dev);
+	if (data) {
+		if (!netif->csum)
+			return -ENOSYS;
+		netif->features_disabled &= ~NETIF_F_IP_CSUM;
+	} else {
+		netif->features_disabled |= NETIF_F_IP_CSUM;
+	}
+
+	netif_set_features(netif);
+	return 0;
+}
+
+static int netbk_set_sg(struct net_device *dev, u32 data)
+{
+	struct xen_netif *netif = netdev_priv(dev);
+	if (data) {
+		if (!netif->can_sg)
+			return -ENOSYS;
+		netif->features_disabled &= ~NETIF_F_SG;
+	} else {
+		netif->features_disabled |= NETIF_F_SG;
+	}
+
+	netif_set_features(netif);
+	return 0;
+}
+
+static int netbk_set_tso(struct net_device *dev, u32 data)
+{
+	struct xen_netif *netif = netdev_priv(dev);
+	if (data) {
+		if (!netif->gso && !netif->gso_prefix)
+			return -ENOSYS;
+		netif->features_disabled &= ~NETIF_F_TSO;
+	} else {
+		netif->features_disabled |= NETIF_F_TSO;
+	}
+
+	netif_set_features(netif);
+	return 0;
+}
+
+static struct ethtool_ops network_ethtool_ops = {
+	.get_tx_csum = ethtool_op_get_tx_csum,
+	.set_tx_csum = netbk_set_tx_csum,
+	.get_sg = ethtool_op_get_sg,
+	.set_sg = netbk_set_sg,
+	.get_tso = ethtool_op_get_tso,
+	.set_tso = netbk_set_tso,
+	.get_link = ethtool_op_get_link,
+
+};
+
+static struct net_device_ops netback_ops = {
+	.ndo_start_xmit	= netif_be_start_xmit,
+	.ndo_get_stats	= netif_be_get_stats,
+	.ndo_open	= net_open,
+	.ndo_stop	= net_close,
+	.ndo_change_mtu	= netbk_change_mtu,
+};
+
+struct xen_netif *netif_alloc(struct device *parent, domid_t domid,
+			      unsigned int handle)
+{
+	int err = 0;
+	struct net_device *dev;
+	struct xen_netif *netif;
+	char name[IFNAMSIZ] = {};
+
+	snprintf(name, IFNAMSIZ - 1, "vif%u.%u", domid, handle);
+	dev = alloc_netdev(sizeof(struct xen_netif), name, ether_setup);
+	if (dev == NULL) {
+		pr_debug("Could not allocate netdev\n");
+		return ERR_PTR(-ENOMEM);
+	}
+
+	SET_NETDEV_DEV(dev, parent);
+
+	netif = netdev_priv(dev);
+	memset(netif, 0, sizeof(*netif));
+	netif->domid  = domid;
+	netif->group  = -1;
+	netif->handle = handle;
+	netif->can_sg = 1;
+	netif->csum = 1;
+	atomic_set(&netif->refcnt, 1);
+	init_waitqueue_head(&netif->waiting_to_free);
+	netif->dev = dev;
+	INIT_LIST_HEAD(&netif->list);
+
+	netback_carrier_off(netif);
+
+	netif->credit_bytes = netif->remaining_credit = ~0UL;
+	netif->credit_usec  = 0UL;
+	init_timer(&netif->credit_timeout);
+	/* Initialize 'expires' now: it's used to track the credit window. */
+	netif->credit_timeout.expires = jiffies;
+
+	dev->netdev_ops	= &netback_ops;
+	netif_set_features(netif);
+	SET_ETHTOOL_OPS(dev, &network_ethtool_ops);
+
+	dev->tx_queue_len = netbk_queue_length;
+
+	/*
+	 * Initialise a dummy MAC address. We choose the numerically
+	 * largest non-broadcast address to prevent the address getting
+	 * stolen by an Ethernet bridge for STP purposes.
+	 * (FE:FF:FF:FF:FF:FF)
+	 */
+	memset(dev->dev_addr, 0xFF, ETH_ALEN);
+	dev->dev_addr[0] &= ~0x01;
+
+	rtnl_lock();
+	err = register_netdevice(dev);
+	rtnl_unlock();
+	if (err) {
+		pr_debug("Could not register new net device %s: err=%d\n",
+			 dev->name, err);
+		free_netdev(dev);
+		return ERR_PTR(err);
+	}
+
+	pr_debug("Successfully created netif\n");
+	return netif;
+}
+
+static int map_frontend_pages(struct xen_netif *netif,
+			      grant_ref_t tx_ring_ref,
+			      grant_ref_t rx_ring_ref)
+{
+	struct gnttab_map_grant_ref op;
+
+	gnttab_set_map_op(&op, (unsigned long)netif->tx_comms_area->addr,
+			  GNTMAP_host_map, tx_ring_ref, netif->domid);
+
+	if (HYPERVISOR_grant_table_op(GNTTABOP_map_grant_ref, &op, 1))
+		BUG();
+
+	if (op.status) {
+		pr_debug("Gnttab failure mapping tx_ring_ref!\n");
+		return op.status;
+	}
+
+	netif->tx_shmem_ref    = tx_ring_ref;
+	netif->tx_shmem_handle = op.handle;
+
+	gnttab_set_map_op(&op, (unsigned long)netif->rx_comms_area->addr,
+			  GNTMAP_host_map, rx_ring_ref, netif->domid);
+
+	if (HYPERVISOR_grant_table_op(GNTTABOP_map_grant_ref, &op, 1))
+		BUG();
+
+	if (op.status) {
+		struct gnttab_unmap_grant_ref unop;
+
+		gnttab_set_unmap_op(&unop,
+				    (unsigned long)netif->tx_comms_area->addr,
+				    GNTMAP_host_map, netif->tx_shmem_handle);
+		HYPERVISOR_grant_table_op(GNTTABOP_unmap_grant_ref, &unop, 1);
+		pr_debug("Gnttab failure mapping rx_ring_ref!\n");
+		return op.status;
+	}
+
+	netif->rx_shmem_ref    = rx_ring_ref;
+	netif->rx_shmem_handle = op.handle;
+
+	return 0;
+}
+
+static void unmap_frontend_pages(struct xen_netif *netif)
+{
+	struct gnttab_unmap_grant_ref op;
+
+	gnttab_set_unmap_op(&op, (unsigned long)netif->tx_comms_area->addr,
+			    GNTMAP_host_map, netif->tx_shmem_handle);
+
+	if (HYPERVISOR_grant_table_op(GNTTABOP_unmap_grant_ref, &op, 1))
+		BUG();
+
+	gnttab_set_unmap_op(&op, (unsigned long)netif->rx_comms_area->addr,
+			    GNTMAP_host_map, netif->rx_shmem_handle);
+
+	if (HYPERVISOR_grant_table_op(GNTTABOP_unmap_grant_ref, &op, 1))
+		BUG();
+}
+
+int netif_map(struct xen_netif *netif, unsigned long tx_ring_ref,
+	      unsigned long rx_ring_ref, unsigned int evtchn)
+{
+	int err = -ENOMEM;
+	struct xen_netif_tx_sring *txs;
+	struct xen_netif_rx_sring *rxs;
+
+	/* Already connected through? */
+	if (netif->irq)
+		return 0;
+
+	netif->tx_comms_area = alloc_vm_area(PAGE_SIZE);
+	if (netif->tx_comms_area == NULL)
+		return -ENOMEM;
+	netif->rx_comms_area = alloc_vm_area(PAGE_SIZE);
+	if (netif->rx_comms_area == NULL)
+		goto err_rx;
+
+	err = map_frontend_pages(netif, tx_ring_ref, rx_ring_ref);
+	if (err)
+		goto err_map;
+
+	err = bind_interdomain_evtchn_to_irqhandler(
+		netif->domid, evtchn, netif_be_int, 0,
+		netif->dev->name, netif);
+	if (err < 0)
+		goto err_hypervisor;
+	netif->irq = err;
+	disable_irq(netif->irq);
+
+	txs = (struct xen_netif_tx_sring *)netif->tx_comms_area->addr;
+	BACK_RING_INIT(&netif->tx, txs, PAGE_SIZE);
+
+	rxs = (struct xen_netif_rx_sring *)
+		((char *)netif->rx_comms_area->addr);
+	BACK_RING_INIT(&netif->rx, rxs, PAGE_SIZE);
+
+	netif->rx_req_cons_peek = 0;
+
+	netif_get(netif);
+
+	rtnl_lock();
+	netback_carrier_on(netif);
+	if (netif_running(netif->dev))
+		__netif_up(netif);
+	rtnl_unlock();
+
+	return 0;
+err_hypervisor:
+	unmap_frontend_pages(netif);
+err_map:
+	free_vm_area(netif->rx_comms_area);
+err_rx:
+	free_vm_area(netif->tx_comms_area);
+	return err;
+}
+
+void netif_disconnect(struct xen_netif *netif)
+{
+	if (netback_carrier_ok(netif)) {
+		rtnl_lock();
+		netback_carrier_off(netif);
+		netif_carrier_off(netif->dev); /* discard queued packets */
+		if (netif_running(netif->dev))
+			__netif_down(netif);
+		rtnl_unlock();
+		netif_put(netif);
+	}
+
+	atomic_dec(&netif->refcnt);
+	wait_event(netif->waiting_to_free, atomic_read(&netif->refcnt) == 0);
+
+	del_timer_sync(&netif->credit_timeout);
+
+	if (netif->irq)
+		unbind_from_irqhandler(netif->irq, netif);
+
+	unregister_netdev(netif->dev);
+
+	if (netif->tx.sring) {
+		unmap_frontend_pages(netif);
+		free_vm_area(netif->tx_comms_area);
+		free_vm_area(netif->rx_comms_area);
+	}
+
+	free_netdev(netif->dev);
+}
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
new file mode 100644
index 0000000..b7b9341
--- /dev/null
+++ b/drivers/net/xen-netback/netback.c
@@ -0,0 +1,1756 @@
+/*
+ * Back-end of the driver for virtual network devices. This portion of the
+ * driver exports a 'unified' network-device interface that can be accessed
+ * by any operating system that implements a compatible front end. A
+ * reference front-end implementation can be found in:
+ *  drivers/net/xen-netfront.c
+ *
+ * Copyright (c) 2002-2005, K A Fraser
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation; or, when distributed
+ * separately from the Linux kernel or incorporated into other
+ * software packages, subject to the following license:
+ *
+ * Permission is hereby granted, free of charge, to any person obtaining a copy
+ * of this source file (the "Software"), to deal in the Software without
+ * restriction, including without limitation the rights to use, copy, modify,
+ * merge, publish, distribute, sublicense, and/or sell copies of the Software,
+ * and to permit persons to whom the Software is furnished to do so, subject to
+ * the following conditions:
+ *
+ * The above copyright notice and this permission notice shall be included in
+ * all copies or substantial portions of the Software.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
+ * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
+ * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
+ * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
+ * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
+ * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
+ * IN THE SOFTWARE.
+ */
+
+#include "common.h"
+
+#include <linux/kthread.h>
+#include <linux/if_vlan.h>
+#include <linux/udp.h>
+
+#include <net/tcp.h>
+
+#include <xen/events.h>
+#include <xen/interface/memory.h>
+
+#include <asm/xen/hypercall.h>
+#include <asm/xen/page.h>
+
+/*define NETBE_DEBUG_INTERRUPT*/
+
+struct xen_netbk *xen_netbk;
+int xen_netbk_group_nr;
+
+static void netif_idx_release(struct xen_netbk *netbk, u16 pending_idx);
+static void make_tx_response(struct xen_netif *netif,
+			     struct xen_netif_tx_request *txp,
+			     s8       st);
+static struct xen_netif_rx_response *make_rx_response(struct xen_netif *netif,
+					     u16      id,
+					     s8       st,
+					     u16      offset,
+					     u16      size,
+					     u16      flags);
+
+static void net_tx_action(unsigned long data);
+
+static void net_rx_action(unsigned long data);
+
+static inline unsigned long idx_to_pfn(struct xen_netbk *netbk,
+				       unsigned int idx)
+{
+	return page_to_pfn(netbk->mmap_pages[idx]);
+}
+
+static inline unsigned long idx_to_kaddr(struct xen_netbk *netbk,
+					 unsigned int idx)
+{
+	return (unsigned long)pfn_to_kaddr(idx_to_pfn(netbk, idx));
+}
+
+/* extra field used in struct page */
+static inline void netif_set_page_ext(struct page *pg, struct xen_netbk *netbk,
+		unsigned int idx)
+{
+	unsigned int group = netbk - xen_netbk;
+	union page_ext ext = { .e = { .group = group + 1, .idx = idx } };
+
+	BUILD_BUG_ON(sizeof(ext) > sizeof(ext.mapping));
+	pg->mapping = ext.mapping;
+}
+
+static int netif_get_page_ext(struct page *pg,
+			      unsigned int *_group, unsigned int *_idx)
+{
+	union page_ext ext = { .mapping = pg->mapping };
+	struct xen_netbk *netbk;
+	unsigned int group, idx;
+
+	group = ext.e.group - 1;
+
+	if (group < 0 || group >= xen_netbk_group_nr)
+		return 0;
+
+	netbk = &xen_netbk[group];
+
+	idx = ext.e.idx;
+
+	if ((idx < 0) || (idx >= MAX_PENDING_REQS))
+		return 0;
+
+	if (netbk->mmap_pages[idx] != pg)
+		return 0;
+
+	*_group = group;
+	*_idx = idx;
+
+	return 1;
+}
+
+/*
+ * This is the amount of packet we copy rather than map, so that the
+ * guest can't fiddle with the contents of the headers while we do
+ * packet processing on them (netfilter, routing, etc).
+ */
+#define PKT_PROT_LEN    (ETH_HLEN + \
+			 VLAN_HLEN + \
+			 sizeof(struct iphdr) + MAX_IPOPTLEN + \
+			 sizeof(struct tcphdr) + MAX_TCP_OPTION_SPACE)
+
+static inline pending_ring_idx_t pending_index(unsigned i)
+{
+	return i & (MAX_PENDING_REQS-1);
+}
+
+static inline pending_ring_idx_t nr_pending_reqs(struct xen_netbk *netbk)
+{
+	return MAX_PENDING_REQS -
+		netbk->pending_prod + netbk->pending_cons;
+}
+
+static int MODPARM_netback_kthread;
+module_param_named(netback_kthread, MODPARM_netback_kthread, bool, 0);
+MODULE_PARM_DESC(netback_kthread, "Use kernel thread to replace tasklet");
+
+/*
+ * Netback bottom half handler.
+ * dir indicates the data direction.
+ * rx: 1, tx: 0.
+ */
+static inline void xen_netbk_bh_handler(struct xen_netbk *netbk, int dir)
+{
+	if (MODPARM_netback_kthread)
+		wake_up(&netbk->kthread.netbk_action_wq);
+	else if (dir)
+		tasklet_schedule(&netbk->tasklet.net_rx_tasklet);
+	else
+		tasklet_schedule(&netbk->tasklet.net_tx_tasklet);
+}
+
+static inline void maybe_schedule_tx_action(struct xen_netbk *netbk)
+{
+	smp_mb();
+	if ((nr_pending_reqs(netbk) < (MAX_PENDING_REQS/2)) &&
+	    !list_empty(&netbk->net_schedule_list))
+		xen_netbk_bh_handler(netbk, 0);
+}
+
+static struct sk_buff *netbk_copy_skb(struct sk_buff *skb)
+{
+	struct skb_shared_info *ninfo;
+	struct sk_buff *nskb;
+	unsigned long offset;
+	int ret;
+	int len;
+	int headlen;
+
+	BUG_ON(skb_shinfo(skb)->frag_list != NULL);
+
+	nskb = alloc_skb(SKB_MAX_HEAD(0), GFP_ATOMIC | __GFP_NOWARN);
+	if (unlikely(!nskb))
+		goto err;
+
+	skb_reserve(nskb, NET_SKB_PAD + NET_IP_ALIGN);
+	headlen = skb_end_pointer(nskb) - nskb->data;
+	if (headlen > skb_headlen(skb))
+		headlen = skb_headlen(skb);
+	ret = skb_copy_bits(skb, 0, __skb_put(nskb, headlen), headlen);
+	BUG_ON(ret);
+
+	ninfo = skb_shinfo(nskb);
+	ninfo->gso_size = skb_shinfo(skb)->gso_size;
+	ninfo->gso_type = skb_shinfo(skb)->gso_type;
+
+	offset = headlen;
+	len = skb->len - headlen;
+
+	nskb->len = skb->len;
+	nskb->data_len = len;
+	nskb->truesize += len;
+
+	while (len) {
+		struct page *page;
+		int copy;
+		int zero;
+
+		if (unlikely(ninfo->nr_frags >= MAX_SKB_FRAGS)) {
+			dump_stack();
+			goto err_free;
+		}
+
+		copy = len >= PAGE_SIZE ? PAGE_SIZE : len;
+		zero = len >= PAGE_SIZE ? 0 : __GFP_ZERO;
+
+		page = alloc_page(GFP_ATOMIC | __GFP_NOWARN | zero);
+		if (unlikely(!page))
+			goto err_free;
+
+		ret = skb_copy_bits(skb, offset, page_address(page), copy);
+		BUG_ON(ret);
+
+		ninfo->frags[ninfo->nr_frags].page = page;
+		ninfo->frags[ninfo->nr_frags].page_offset = 0;
+		ninfo->frags[ninfo->nr_frags].size = copy;
+		ninfo->nr_frags++;
+
+		offset += copy;
+		len -= copy;
+	}
+
+#ifdef NET_SKBUFF_DATA_USES_OFFSET
+	offset = 0;
+#else
+	offset = nskb->data - skb->data;
+#endif
+
+	nskb->transport_header = skb->transport_header + offset;
+	nskb->network_header = skb->network_header + offset;
+	nskb->mac_header = skb->mac_header + offset;
+
+	return nskb;
+
+ err_free:
+	kfree_skb(nskb);
+ err:
+	return NULL;
+}
+
+static inline int netbk_max_required_rx_slots(struct xen_netif *netif)
+{
+	if (netif->can_sg || netif->gso || netif->gso_prefix)
+		return MAX_SKB_FRAGS + 2; /* header + extra_info + frags */
+	return 1; /* all in one */
+}
+
+static inline int netbk_queue_full(struct xen_netif *netif)
+{
+	RING_IDX peek   = netif->rx_req_cons_peek;
+	RING_IDX needed = netbk_max_required_rx_slots(netif);
+
+	return ((netif->rx.sring->req_prod - peek) < needed) ||
+	       ((netif->rx.rsp_prod_pvt + NET_RX_RING_SIZE - peek) < needed);
+}
+
+/*
+ * Returns true if we should start a new receive buffer instead of
+ * adding 'size' bytes to a buffer which currently contains 'offset'
+ * bytes.
+ */
+static bool start_new_rx_buffer(int offset, unsigned long size, int head)
+{
+	/* simple case: we have completely filled the current buffer. */
+	if (offset == MAX_BUFFER_OFFSET)
+		return true;
+
+	/*
+	 * complex case: start a fresh buffer if the current frag
+	 * would overflow the current buffer but only if:
+	 *     (i)   this frag would fit completely in the next buffer
+	 * and (ii)  there is already some data in the current buffer
+	 * and (iii) this is not the head buffer.
+	 *
+	 * Where:
+	 * - (i) stops us splitting a frag into two copies
+	 *   unless the frag is too large for a single buffer.
+	 * - (ii) stops us from leaving a buffer pointlessly empty.
+	 * - (iii) stops us leaving the first buffer
+	 *   empty. Strictly speaking this is already covered
+	 *   by (ii) but is explicitly checked because
+	 *   netfront relies on the first buffer being
+	 *   non-empty and can crash otherwise.
+	 *
+	 * This means we will effectively linearise small
+	 * frags but do not needlessly split large buffers
+	 * into multiple copies tend to give large frags their
+	 * own buffers as before.
+	 */
+	if ((offset + size > MAX_BUFFER_OFFSET) &&
+	    (size <= MAX_BUFFER_OFFSET) && offset && !head)
+		return true;
+
+	return false;
+}
+
+/*
+ * Figure out how many ring slots we're going to need to send @skb to
+ * the guest. This function is essentially a dry run of
+ * netbk_gop_frag_copy.
+ */
+static unsigned int count_skb_slots(struct sk_buff *skb, struct xen_netif *netif)
+{
+	unsigned int count = 1;
+	int i, copy_off = 0;
+
+	BUG_ON(offset_in_page(skb->data)+skb_headlen(skb) > MAX_BUFFER_OFFSET);
+
+	copy_off = skb_headlen(skb);
+
+	if (skb_shinfo(skb)->gso_size)
+		count++;
+
+	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
+		unsigned long size = skb_shinfo(skb)->frags[i].size;
+		unsigned long bytes;
+		while (size > 0) {
+			BUG_ON(copy_off > MAX_BUFFER_OFFSET);
+
+			if (start_new_rx_buffer(copy_off, size, 0)) {
+				count++;
+				copy_off = 0;
+			}
+
+			bytes = size;
+			if (copy_off + bytes > MAX_BUFFER_OFFSET)
+				bytes = MAX_BUFFER_OFFSET - copy_off;
+
+			copy_off += bytes;
+			size -= bytes;
+		}
+	}
+	return count;
+}
+
+int netif_be_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct xen_netif *netif = netdev_priv(dev);
+	struct xen_netbk *netbk;
+
+	BUG_ON(skb->dev != dev);
+
+	if (netif->group == -1)
+		goto drop;
+
+	netbk = &xen_netbk[netif->group];
+
+	/* Drop the packet if the target domain has no receive buffers. */
+	if (unlikely(!netif_schedulable(netif) || netbk_queue_full(netif)))
+		goto drop;
+
+	/*
+	 * XXX For now we also copy skbuffs whose head crosses a page
+	 * boundary, because netbk_gop_skb can't handle them.
+	 */
+	if ((skb_headlen(skb) + offset_in_page(skb->data)) >= PAGE_SIZE) {
+		struct sk_buff *nskb = netbk_copy_skb(skb);
+		if (unlikely(nskb == NULL))
+			goto drop;
+		/* Copy only the header fields we use in this driver. */
+		nskb->dev = skb->dev;
+		nskb->ip_summed = skb->ip_summed;
+		dev_kfree_skb(skb);
+		skb = nskb;
+	}
+
+	/* Reserve ring slots for the worst-case number of fragments. */
+	netif->rx_req_cons_peek += count_skb_slots(skb, netif);
+	netif_get(netif);
+
+	if (netbk_can_queue(dev) && netbk_queue_full(netif)) {
+		netif->rx.sring->req_event = netif->rx_req_cons_peek +
+			netbk_max_required_rx_slots(netif);
+		mb(); /* request notification /then/ check & stop the queue */
+		if (netbk_queue_full(netif))
+			netif_stop_queue(dev);
+	}
+	skb_queue_tail(&netbk->rx_queue, skb);
+
+	xen_netbk_bh_handler(netbk, 1);
+
+	return 0;
+
+ drop:
+	netif->stats.tx_dropped++;
+	dev_kfree_skb(skb);
+	return 0;
+}
+
+struct netrx_pending_operations {
+	unsigned copy_prod, copy_cons;
+	unsigned meta_prod, meta_cons;
+	struct gnttab_copy *copy;
+	struct netbk_rx_meta *meta;
+	int copy_off;
+	grant_ref_t copy_gref;
+};
+
+static struct netbk_rx_meta *get_next_rx_buffer(struct xen_netif *netif,
+						struct netrx_pending_operations *npo)
+{
+	struct netbk_rx_meta *meta;
+	struct xen_netif_rx_request *req;
+
+	req = RING_GET_REQUEST(&netif->rx, netif->rx.req_cons++);
+
+	meta = npo->meta + npo->meta_prod++;
+	meta->gso_size = 0;
+	meta->size = 0;
+	meta->id = req->id;
+
+	npo->copy_off = 0;
+	npo->copy_gref = req->gref;
+
+	return meta;
+}
+
+/*
+ * Set up the grant operations for this fragment. If it's a flipping
+ * interface, we also set up the unmap request from here.
+ */
+static void netbk_gop_frag_copy(struct xen_netif *netif,
+				struct netrx_pending_operations *npo,
+				struct page *page, unsigned long size,
+				unsigned long offset, int head)
+{
+	struct gnttab_copy *copy_gop;
+	struct netbk_rx_meta *meta;
+	/*
+	 * These variables a used iff netif_get_page_ext returns true,
+	 * in which case they are guaranteed to be initialized.
+	 */
+	unsigned int uninitialized_var(group), uninitialized_var(idx);
+	int foreign = netif_get_page_ext(page, &group, &idx);
+	unsigned long bytes;
+
+	/* Data must not cross a page boundary. */
+	BUG_ON(size + offset > PAGE_SIZE);
+
+	meta = npo->meta + npo->meta_prod - 1;
+
+	while (size > 0) {
+		BUG_ON(npo->copy_off > MAX_BUFFER_OFFSET);
+
+		if (start_new_rx_buffer(npo->copy_off, size, head)) {
+			/*
+			 * Netfront requires there to be some data in
+			 * the head buffer.
+			 */
+			BUG_ON(head);
+
+			meta = get_next_rx_buffer(netif, npo);
+		}
+
+		bytes = size;
+		if (npo->copy_off + bytes > MAX_BUFFER_OFFSET)
+			bytes = MAX_BUFFER_OFFSET - npo->copy_off;
+
+		copy_gop = npo->copy + npo->copy_prod++;
+		copy_gop->flags = GNTCOPY_dest_gref;
+		if (foreign) {
+			struct xen_netbk *netbk = &xen_netbk[group];
+			struct pending_tx_info *src_pend;
+
+			src_pend = &netbk->pending_tx_info[idx];
+
+			copy_gop->source.domid = src_pend->netif->domid;
+			copy_gop->source.u.ref = src_pend->req.gref;
+			copy_gop->flags |= GNTCOPY_source_gref;
+		} else {
+			void *vaddr = page_address(page);
+			copy_gop->source.domid = DOMID_SELF;
+			copy_gop->source.u.gmfn = virt_to_mfn(vaddr);
+		}
+		copy_gop->source.offset = offset;
+		copy_gop->dest.domid = netif->domid;
+
+		copy_gop->dest.offset = npo->copy_off;
+		copy_gop->dest.u.ref = npo->copy_gref;
+		copy_gop->len = bytes;
+
+		npo->copy_off += bytes;
+		meta->size += bytes;
+
+		offset += bytes;
+		size -= bytes;
+		head = 0; /* There must be something in this buffer now. */
+	}
+}
+
+/*
+ * Prepare an SKB to be transmitted to the frontend.
+ *
+ * This function is responsible for allocating grant operations, meta
+ * structures, etc.
+ *
+ * It returns the number of meta structures consumed. The number of
+ * ring slots used is always equal to the number of meta slots used
+ * plus the number of GSO descriptors used. Currently, we use either
+ * zero GSO descriptors (for non-GSO packets) or one descriptor (for
+ * frontend-side LRO).
+ */
+static int netbk_gop_skb(struct sk_buff *skb,
+			 struct netrx_pending_operations *npo)
+{
+	struct xen_netif *netif = netdev_priv(skb->dev);
+	int nr_frags = skb_shinfo(skb)->nr_frags;
+	int i;
+	struct xen_netif_rx_request *req;
+	struct netbk_rx_meta *meta;
+	int old_meta_prod;
+
+	old_meta_prod = npo->meta_prod;
+
+	/* Set up a GSO prefix descriptor, if necessary */
+	if (skb_shinfo(skb)->gso_size && netif->gso_prefix) {
+		req = RING_GET_REQUEST(&netif->rx, netif->rx.req_cons++);
+		meta = npo->meta + npo->meta_prod++;
+		meta->gso_size = skb_shinfo(skb)->gso_size;
+		meta->size = 0;
+		meta->id = req->id;
+	}
+
+	req = RING_GET_REQUEST(&netif->rx, netif->rx.req_cons++);
+	meta = npo->meta + npo->meta_prod++;
+
+	if (!netif->gso_prefix)
+		meta->gso_size = skb_shinfo(skb)->gso_size;
+	else
+		meta->gso_size = 0;
+
+	meta->size = 0;
+	meta->id = req->id;
+	npo->copy_off = 0;
+	npo->copy_gref = req->gref;
+
+	netbk_gop_frag_copy(netif,
+			    npo, virt_to_page(skb->data),
+			    skb_headlen(skb),
+			    offset_in_page(skb->data), 1);
+
+	/* Leave a gap for the GSO descriptor. */
+	if (skb_shinfo(skb)->gso_size && !netif->gso_prefix)
+		netif->rx.req_cons++;
+
+	for (i = 0; i < nr_frags; i++) {
+		netbk_gop_frag_copy(netif, npo,
+				    skb_shinfo(skb)->frags[i].page,
+				    skb_shinfo(skb)->frags[i].size,
+				    skb_shinfo(skb)->frags[i].page_offset,
+				    0);
+	}
+
+	return npo->meta_prod - old_meta_prod;
+}
+
+/*
+ * This is a twin to netbk_gop_skb.  Assume that netbk_gop_skb was
+ * used to set up the operations on the top of
+ * netrx_pending_operations, which have since been done.  Check that
+ * they didn't give any errors and advance over them.
+ */
+static int netbk_check_gop(int nr_meta_slots, domid_t domid,
+			   struct netrx_pending_operations *npo)
+{
+	struct gnttab_copy     *copy_op;
+	int status = NETIF_RSP_OKAY;
+	int i;
+
+	for (i = 0; i < nr_meta_slots; i++) {
+		copy_op = npo->copy + npo->copy_cons++;
+		if (copy_op->status != GNTST_okay) {
+				pr_debug("Bad status %d from copy to DOM%d.\n",
+					 copy_op->status, domid);
+				status = NETIF_RSP_ERROR;
+			}
+	}
+
+	return status;
+}
+
+static void netbk_add_frag_responses(struct xen_netif *netif, int status,
+				     struct netbk_rx_meta *meta,
+				     int nr_meta_slots)
+{
+	int i;
+	unsigned long offset;
+
+	/* No fragments used */
+	if (nr_meta_slots <= 1)
+		return;
+
+	nr_meta_slots--;
+
+	for (i = 0; i < nr_meta_slots; i++) {
+		int flags;
+		if (i == nr_meta_slots - 1)
+			flags = 0;
+		else
+			flags = NETRXF_more_data;
+
+		offset = 0;
+		make_rx_response(netif, meta[i].id, status, offset,
+				 meta[i].size, flags);
+	}
+}
+
+struct skb_cb_overlay {
+	int meta_slots_used;
+};
+
+static void net_rx_action(unsigned long data)
+{
+	struct xen_netif *netif = NULL;
+	struct xen_netbk *netbk = (struct xen_netbk *)data;
+	s8 status;
+	u16 irq, flags;
+	struct xen_netif_rx_response *resp;
+	struct sk_buff_head rxq;
+	struct sk_buff *skb;
+	int notify_nr = 0;
+	int ret;
+	int nr_frags;
+	int count;
+	unsigned long offset;
+	struct skb_cb_overlay *sco;
+
+	struct netrx_pending_operations npo = {
+		.copy  = netbk->grant_copy_op,
+		.meta  = netbk->meta,
+	};
+
+	skb_queue_head_init(&rxq);
+
+	count = 0;
+
+	while ((skb = skb_dequeue(&netbk->rx_queue)) != NULL) {
+		netif = netdev_priv(skb->dev);
+		nr_frags = skb_shinfo(skb)->nr_frags;
+
+		sco = (struct skb_cb_overlay *)skb->cb;
+		sco->meta_slots_used = netbk_gop_skb(skb, &npo);
+
+		count += nr_frags + 1;
+
+		__skb_queue_tail(&rxq, skb);
+
+		/* Filled the batch queue? */
+		if (count + MAX_SKB_FRAGS >= NET_RX_RING_SIZE)
+			break;
+	}
+
+	BUG_ON(npo.meta_prod > ARRAY_SIZE(netbk->meta));
+
+	if (!npo.copy_prod)
+		return;
+
+	BUG_ON(npo.copy_prod > ARRAY_SIZE(netbk->grant_copy_op));
+	ret = HYPERVISOR_grant_table_op(GNTTABOP_copy, &netbk->grant_copy_op,
+					npo.copy_prod);
+	BUG_ON(ret != 0);
+
+	while ((skb = __skb_dequeue(&rxq)) != NULL) {
+		sco = (struct skb_cb_overlay *)skb->cb;
+
+		netif = netdev_priv(skb->dev);
+
+		if (netbk->meta[npo.meta_cons].gso_size && netif->gso_prefix) {
+			resp = RING_GET_RESPONSE(&netif->rx,
+						netif->rx.rsp_prod_pvt++);
+
+			resp->flags = NETRXF_gso_prefix | NETRXF_more_data;
+
+			resp->offset = netbk->meta[npo.meta_cons].gso_size;
+			resp->id = netbk->meta[npo.meta_cons].id;
+			resp->status = sco->meta_slots_used;
+
+			npo.meta_cons++;
+			sco->meta_slots_used--;
+		}
+
+
+		netif->stats.tx_bytes += skb->len;
+		netif->stats.tx_packets++;
+
+		status = netbk_check_gop(sco->meta_slots_used,
+					 netif->domid, &npo);
+
+		if (sco->meta_slots_used == 1)
+			flags = 0;
+		else
+			flags = NETRXF_more_data;
+
+		if (skb->ip_summed == CHECKSUM_PARTIAL) /* local packet? */
+			flags |= NETRXF_csum_blank | NETRXF_data_validated;
+		else if (skb->ip_summed == CHECKSUM_UNNECESSARY)
+			/* remote but checksummed. */
+			flags |= NETRXF_data_validated;
+
+		offset = 0;
+		resp = make_rx_response(netif, netbk->meta[npo.meta_cons].id,
+					status, offset,
+					netbk->meta[npo.meta_cons].size,
+					flags);
+
+		if (netbk->meta[npo.meta_cons].gso_size && !netif->gso_prefix) {
+			struct xen_netif_extra_info *gso =
+				(struct xen_netif_extra_info *)
+				RING_GET_RESPONSE(&netif->rx,
+						  netif->rx.rsp_prod_pvt++);
+
+			resp->flags |= NETRXF_extra_info;
+
+			gso->u.gso.size = netbk->meta[npo.meta_cons].gso_size;
+			gso->u.gso.type = XEN_NETIF_GSO_TYPE_TCPV4;
+			gso->u.gso.pad = 0;
+			gso->u.gso.features = 0;
+
+			gso->type = XEN_NETIF_EXTRA_TYPE_GSO;
+			gso->flags = 0;
+		}
+
+		netbk_add_frag_responses(netif, status,
+					 netbk->meta + npo.meta_cons + 1,
+					 sco->meta_slots_used);
+
+		RING_PUSH_RESPONSES_AND_CHECK_NOTIFY(&netif->rx, ret);
+		irq = netif->irq;
+		if (ret && !netbk->rx_notify[irq]) {
+			netbk->rx_notify[irq] = 1;
+			netbk->notify_list[notify_nr++] = irq;
+		}
+
+		if (netif_queue_stopped(netif->dev) &&
+		    netif_schedulable(netif) &&
+		    !netbk_queue_full(netif))
+			netif_wake_queue(netif->dev);
+
+		netif_put(netif);
+		npo.meta_cons += sco->meta_slots_used;
+		dev_kfree_skb(skb);
+	}
+
+	while (notify_nr != 0) {
+		irq = netbk->notify_list[--notify_nr];
+		netbk->rx_notify[irq] = 0;
+		notify_remote_via_irq(irq);
+	}
+
+	/* More work to do? */
+	if (!skb_queue_empty(&netbk->rx_queue) &&
+			!timer_pending(&netbk->net_timer))
+		xen_netbk_bh_handler(netbk, 1);
+}
+
+static void net_alarm(unsigned long data)
+{
+	struct xen_netbk *netbk = (struct xen_netbk *)data;
+	xen_netbk_bh_handler(netbk, 1);
+}
+
+struct net_device_stats *netif_be_get_stats(struct net_device *dev)
+{
+	struct xen_netif *netif = netdev_priv(dev);
+	return &netif->stats;
+}
+
+static int __on_net_schedule_list(struct xen_netif *netif)
+{
+	return !list_empty(&netif->list);
+}
+
+/* Must be called with net_schedule_list_lock held */
+static void remove_from_net_schedule_list(struct xen_netif *netif)
+{
+	if (likely(__on_net_schedule_list(netif))) {
+		list_del_init(&netif->list);
+		netif_put(netif);
+	}
+}
+
+static struct xen_netif *poll_net_schedule_list(struct xen_netbk *netbk)
+{
+	struct xen_netif *netif = NULL;
+
+	spin_lock_irq(&netbk->net_schedule_list_lock);
+	if (list_empty(&netbk->net_schedule_list))
+		goto out;
+
+	netif = list_first_entry(&netbk->net_schedule_list,
+				 struct xen_netif, list);
+	if (!netif)
+		goto out;
+
+	netif_get(netif);
+
+	remove_from_net_schedule_list(netif);
+out:
+	spin_unlock_irq(&netbk->net_schedule_list_lock);
+	return netif;
+}
+
+static void add_to_net_schedule_list_tail(struct xen_netif *netif)
+{
+	unsigned long flags;
+
+	struct xen_netbk *netbk = &xen_netbk[netif->group];
+	if (__on_net_schedule_list(netif))
+		return;
+
+	spin_lock_irqsave(&netbk->net_schedule_list_lock, flags);
+	if (!__on_net_schedule_list(netif) &&
+	    likely(netif_schedulable(netif))) {
+		list_add_tail(&netif->list, &netbk->net_schedule_list);
+		netif_get(netif);
+	}
+	spin_unlock_irqrestore(&netbk->net_schedule_list_lock, flags);
+}
+
+void netif_schedule_work(struct xen_netif *netif)
+{
+	struct xen_netbk *netbk = &xen_netbk[netif->group];
+	int more_to_do;
+
+	RING_FINAL_CHECK_FOR_REQUESTS(&netif->tx, more_to_do);
+
+	if (more_to_do) {
+		add_to_net_schedule_list_tail(netif);
+		maybe_schedule_tx_action(netbk);
+	}
+}
+
+void netif_deschedule_work(struct xen_netif *netif)
+{
+	struct xen_netbk *netbk = &xen_netbk[netif->group];
+	spin_lock_irq(&netbk->net_schedule_list_lock);
+	remove_from_net_schedule_list(netif);
+	spin_unlock_irq(&netbk->net_schedule_list_lock);
+}
+
+
+static void tx_add_credit(struct xen_netif *netif)
+{
+	unsigned long max_burst, max_credit;
+
+	/*
+	 * Allow a burst big enough to transmit a jumbo packet of up to 128kB.
+	 * Otherwise the interface can seize up due to insufficient credit.
+	 */
+	max_burst = RING_GET_REQUEST(&netif->tx, netif->tx.req_cons)->size;
+	max_burst = min(max_burst, 131072UL);
+	max_burst = max(max_burst, netif->credit_bytes);
+
+	/* Take care that adding a new chunk of credit doesn't wrap to zero. */
+	max_credit = netif->remaining_credit + netif->credit_bytes;
+	if (max_credit < netif->remaining_credit)
+		max_credit = ULONG_MAX; /* wrapped: clamp to ULONG_MAX */
+
+	netif->remaining_credit = min(max_credit, max_burst);
+}
+
+static void tx_credit_callback(unsigned long data)
+{
+	struct xen_netif *netif = (struct xen_netif *)data;
+	tx_add_credit(netif);
+	netif_schedule_work(netif);
+}
+
+static void netbk_tx_err(struct xen_netif *netif,
+		struct xen_netif_tx_request *txp, RING_IDX end)
+{
+	RING_IDX cons = netif->tx.req_cons;
+
+	do {
+		make_tx_response(netif, txp, NETIF_RSP_ERROR);
+		if (cons >= end)
+			break;
+		txp = RING_GET_REQUEST(&netif->tx, cons++);
+	} while (1);
+	netif->tx.req_cons = cons;
+	netif_schedule_work(netif);
+	netif_put(netif);
+}
+
+static int netbk_count_requests(struct xen_netif *netif,
+				struct xen_netif_tx_request *first,
+				struct xen_netif_tx_request *txp,
+				int work_to_do)
+{
+	RING_IDX cons = netif->tx.req_cons;
+	int frags = 0;
+
+	if (!(first->flags & NETTXF_more_data))
+		return 0;
+
+	do {
+		if (frags >= work_to_do) {
+			printk(KERN_CRIT "Need more frags\n");
+			return -frags;
+		}
+
+		if (unlikely(frags >= MAX_SKB_FRAGS)) {
+			printk(KERN_CRIT "Too many frags\n");
+			return -frags;
+		}
+
+		memcpy(txp, RING_GET_REQUEST(&netif->tx, cons + frags),
+		       sizeof(*txp));
+		if (txp->size > first->size) {
+			printk(KERN_CRIT "Frags galore\n");
+			return -frags;
+		}
+
+		first->size -= txp->size;
+		frags++;
+
+		if (unlikely((txp->offset + txp->size) > PAGE_SIZE)) {
+			printk(KERN_CRIT "txp->offset: %x, size: %u\n",
+				txp->offset, txp->size);
+			return -frags;
+		}
+	} while ((txp++)->flags & NETTXF_more_data);
+	return frags;
+}
+
+static struct page *netif_alloc_page(struct xen_netbk *netbk,
+				     struct sk_buff *skb,
+				     unsigned long pending_idx)
+{
+	struct page *page;
+	page = alloc_page(GFP_KERNEL|__GFP_COLD);
+	if (!page)
+		return NULL;
+	netif_set_page_ext(page, netbk, pending_idx);
+	netbk->mmap_pages[pending_idx] = page;
+	return page;
+}
+
+static struct gnttab_copy *netbk_get_requests(struct xen_netbk *netbk,
+					      struct xen_netif *netif,
+					      struct sk_buff *skb,
+					      struct xen_netif_tx_request *txp,
+					      struct gnttab_copy *gop)
+{
+	struct skb_shared_info *shinfo = skb_shinfo(skb);
+	skb_frag_t *frags = shinfo->frags;
+	unsigned long pending_idx = *((u16 *)skb->data);
+	int i, start;
+
+	/* Skip first skb fragment if it is on same page as header fragment. */
+	start = ((unsigned long)shinfo->frags[0].page == pending_idx);
+
+	for (i = start; i < shinfo->nr_frags; i++, txp++) {
+		struct page *page;
+		pending_ring_idx_t index;
+		struct pending_tx_info *pending_tx_info =
+			netbk->pending_tx_info;
+
+		index = pending_index(netbk->pending_cons++);
+		pending_idx = netbk->pending_ring[index];
+		page = netif_alloc_page(netbk, skb, pending_idx);
+		if (!page)
+			return NULL;
+
+		netbk->mmap_pages[pending_idx] = page;
+
+		gop->source.u.ref = txp->gref;
+		gop->source.domid = netif->domid;
+		gop->source.offset = txp->offset;
+
+		gop->dest.u.gmfn = virt_to_mfn(page_address(page));
+		gop->dest.domid = DOMID_SELF;
+		gop->dest.offset = txp->offset;
+
+		gop->len = txp->size;
+		gop->flags = GNTCOPY_source_gref;
+
+		gop++;
+
+		memcpy(&pending_tx_info[pending_idx].req, txp, sizeof(*txp));
+		netif_get(netif);
+		pending_tx_info[pending_idx].netif = netif;
+		frags[i].page = (void *)pending_idx;
+	}
+
+	return gop;
+}
+
+static int netbk_tx_check_gop(struct xen_netbk *netbk,
+			      struct sk_buff *skb,
+			      struct gnttab_copy **gopp)
+{
+	struct gnttab_copy *gop = *gopp;
+	int pending_idx = *((u16 *)skb->data);
+	struct pending_tx_info *pending_tx_info = netbk->pending_tx_info;
+	struct xen_netif *netif = pending_tx_info[pending_idx].netif;
+	struct xen_netif_tx_request *txp;
+	struct skb_shared_info *shinfo = skb_shinfo(skb);
+	int nr_frags = shinfo->nr_frags;
+	int i, err, start;
+
+	/* Check status of header. */
+	err = gop->status;
+	if (unlikely(err)) {
+		pending_ring_idx_t index;
+		index = pending_index(netbk->pending_prod++);
+		txp = &pending_tx_info[pending_idx].req;
+		make_tx_response(netif, txp, NETIF_RSP_ERROR);
+		netbk->pending_ring[index] = pending_idx;
+		netif_put(netif);
+	}
+
+	/* Skip first skb fragment if it is on same page as header fragment. */
+	start = ((unsigned long)shinfo->frags[0].page == pending_idx);
+
+	for (i = start; i < nr_frags; i++) {
+		int j, newerr;
+		pending_ring_idx_t index;
+
+		pending_idx = (unsigned long)shinfo->frags[i].page;
+
+		/* Check error status: if okay then remember grant handle. */
+		newerr = (++gop)->status;
+		if (likely(!newerr)) {
+			/* Had a previous error? Invalidate this fragment. */
+			if (unlikely(err))
+				netif_idx_release(netbk, pending_idx);
+			continue;
+		}
+
+		/* Error on this fragment: respond to client with an error. */
+		txp = &netbk->pending_tx_info[pending_idx].req;
+		make_tx_response(netif, txp, NETIF_RSP_ERROR);
+		index = pending_index(netbk->pending_prod++);
+		netbk->pending_ring[index] = pending_idx;
+		netif_put(netif);
+
+		/* Not the first error? Preceding frags already invalidated. */
+		if (err)
+			continue;
+
+		/* First error: invalidate header and preceding fragments. */
+		pending_idx = *((u16 *)skb->data);
+		netif_idx_release(netbk, pending_idx);
+		for (j = start; j < i; j++) {
+			pending_idx = (unsigned long)shinfo->frags[i].page;
+			netif_idx_release(netbk, pending_idx);
+		}
+
+		/* Remember the error: invalidate all subsequent fragments. */
+		err = newerr;
+	}
+
+	*gopp = gop + 1;
+	return err;
+}
+
+static void netbk_fill_frags(struct xen_netbk *netbk, struct sk_buff *skb)
+{
+	struct skb_shared_info *shinfo = skb_shinfo(skb);
+	int nr_frags = shinfo->nr_frags;
+	int i;
+
+	for (i = 0; i < nr_frags; i++) {
+		skb_frag_t *frag = shinfo->frags + i;
+		struct xen_netif_tx_request *txp;
+		unsigned long pending_idx;
+
+		pending_idx = (unsigned long)frag->page;
+
+		txp = &netbk->pending_tx_info[pending_idx].req;
+		frag->page = virt_to_page(idx_to_kaddr(netbk, pending_idx));
+		frag->size = txp->size;
+		frag->page_offset = txp->offset;
+
+		skb->len += txp->size;
+		skb->data_len += txp->size;
+		skb->truesize += txp->size;
+
+		/* Take an extra reference to offset netif_idx_release */
+		get_page(netbk->mmap_pages[pending_idx]);
+		netif_idx_release(netbk, pending_idx);
+	}
+}
+
+int netbk_get_extras(struct xen_netif *netif,
+		     struct xen_netif_extra_info *extras,
+		     int work_to_do)
+{
+	struct xen_netif_extra_info extra;
+	RING_IDX cons = netif->tx.req_cons;
+
+	do {
+		if (unlikely(work_to_do-- <= 0)) {
+			pr_debug("Missing extra info\n");
+			return -EBADR;
+		}
+
+		memcpy(&extra, RING_GET_REQUEST(&netif->tx, cons),
+		       sizeof(extra));
+		if (unlikely(!extra.type ||
+			     extra.type >= XEN_NETIF_EXTRA_TYPE_MAX)) {
+			netif->tx.req_cons = ++cons;
+			pr_debug("Invalid extra type: %d\n", extra.type);
+			return -EINVAL;
+		}
+
+		memcpy(&extras[extra.type - 1], &extra, sizeof(extra));
+		netif->tx.req_cons = ++cons;
+	} while (extra.flags & XEN_NETIF_EXTRA_FLAG_MORE);
+
+	return work_to_do;
+}
+
+static int netbk_set_skb_gso(struct sk_buff *skb,
+			     struct xen_netif_extra_info *gso)
+{
+	if (!gso->u.gso.size) {
+		pr_debug("GSO size must not be zero.\n");
+		return -EINVAL;
+	}
+
+	/* Currently only TCPv4 S.O. is supported. */
+	if (gso->u.gso.type != XEN_NETIF_GSO_TYPE_TCPV4) {
+		pr_debug("Bad GSO type %d.\n", gso->u.gso.type);
+		return -EINVAL;
+	}
+
+	skb_shinfo(skb)->gso_size = gso->u.gso.size;
+	skb_shinfo(skb)->gso_type = SKB_GSO_TCPV4;
+
+	/* Header must be checked, and gso_segs computed. */
+	skb_shinfo(skb)->gso_type |= SKB_GSO_DODGY;
+	skb_shinfo(skb)->gso_segs = 0;
+
+	return 0;
+}
+
+static int skb_checksum_setup(struct sk_buff *skb)
+{
+	struct iphdr *iph;
+	unsigned char *th;
+	int err = -EPROTO;
+
+	if (skb->protocol != htons(ETH_P_IP))
+		goto out;
+
+	iph = (void *)skb->data;
+	th = skb->data + 4 * iph->ihl;
+	if (th >= skb_tail_pointer(skb))
+		goto out;
+
+	skb->csum_start = th - skb->head;
+	switch (iph->protocol) {
+	case IPPROTO_TCP:
+		skb->csum_offset = offsetof(struct tcphdr, check);
+		break;
+	case IPPROTO_UDP:
+		skb->csum_offset = offsetof(struct udphdr, check);
+		break;
+	default:
+		if (net_ratelimit())
+			printk(KERN_ERR "Attempting to checksum a non-"
+			       "TCP/UDP packet, dropping a protocol"
+			       " %d packet", iph->protocol);
+		goto out;
+	}
+
+	if ((th + skb->csum_offset + 2) > skb_tail_pointer(skb))
+		goto out;
+
+	err = 0;
+
+out:
+	return err;
+}
+
+static bool tx_credit_exceeded(struct xen_netif *netif, unsigned size)
+{
+	unsigned long now = jiffies;
+	unsigned long next_credit =
+		netif->credit_timeout.expires +
+		msecs_to_jiffies(netif->credit_usec / 1000);
+
+	/* Timer could already be pending in rare cases. */
+	if (timer_pending(&netif->credit_timeout))
+		return true;
+
+	/* Passed the point where we can replenish credit? */
+	if (time_after_eq(now, next_credit)) {
+		netif->credit_timeout.expires = now;
+		tx_add_credit(netif);
+	}
+
+	/* Still too big to send right now? Set a callback. */
+	if (size > netif->remaining_credit) {
+		netif->credit_timeout.data     =
+			(unsigned long)netif;
+		netif->credit_timeout.function =
+			tx_credit_callback;
+		mod_timer(&netif->credit_timeout,
+			  next_credit);
+
+		return true;
+	}
+
+	return false;
+}
+
+static unsigned net_tx_build_gops(struct xen_netbk *netbk)
+{
+	struct gnttab_copy *gop = netbk->tx_copy_ops, *request_gop;
+	struct sk_buff *skb;
+	int ret;
+
+	while (((nr_pending_reqs(netbk) + MAX_SKB_FRAGS) < MAX_PENDING_REQS) &&
+		!list_empty(&netbk->net_schedule_list)) {
+		struct xen_netif *netif;
+		struct xen_netif_tx_request txreq;
+		struct xen_netif_tx_request txfrags[MAX_SKB_FRAGS];
+		struct page *page;
+		struct xen_netif_extra_info extras[XEN_NETIF_EXTRA_TYPE_MAX-1];
+		u16 pending_idx;
+		RING_IDX idx;
+		int work_to_do;
+		unsigned int data_len;
+		pending_ring_idx_t index;
+
+		/* Get a netif from the list with work to do. */
+		netif = poll_net_schedule_list(netbk);
+		if (!netif)
+			continue;
+
+		RING_FINAL_CHECK_FOR_REQUESTS(&netif->tx, work_to_do);
+		if (!work_to_do) {
+			netif_put(netif);
+			continue;
+		}
+
+		idx = netif->tx.req_cons;
+		rmb(); /* Ensure that we see the request before we copy it. */
+		memcpy(&txreq, RING_GET_REQUEST(&netif->tx, idx), sizeof(txreq));
+
+		/* Credit-based scheduling. */
+		if (txreq.size > netif->remaining_credit &&
+		    tx_credit_exceeded(netif, txreq.size)) {
+			netif_put(netif);
+			continue;
+		}
+
+		netif->remaining_credit -= txreq.size;
+
+		work_to_do--;
+		netif->tx.req_cons = ++idx;
+
+		memset(extras, 0, sizeof(extras));
+		if (txreq.flags & NETTXF_extra_info) {
+			work_to_do = netbk_get_extras(netif, extras,
+						      work_to_do);
+			idx = netif->tx.req_cons;
+			if (unlikely(work_to_do < 0)) {
+				netbk_tx_err(netif, &txreq, idx);
+				continue;
+			}
+		}
+
+		ret = netbk_count_requests(netif, &txreq, txfrags, work_to_do);
+		if (unlikely(ret < 0)) {
+			netbk_tx_err(netif, &txreq, idx - ret);
+			continue;
+		}
+		idx += ret;
+
+		if (unlikely(txreq.size < ETH_HLEN)) {
+			pr_debug("Bad packet size: %d\n", txreq.size);
+			netbk_tx_err(netif, &txreq, idx);
+			continue;
+		}
+
+		/* No crossing a page as the payload mustn't fragment. */
+		if (unlikely((txreq.offset + txreq.size) > PAGE_SIZE)) {
+			pr_debug("txreq.offset: %x, size: %u, end: %lu\n",
+				 txreq.offset, txreq.size,
+				 (txreq.offset&~PAGE_MASK) + txreq.size);
+			netbk_tx_err(netif, &txreq, idx);
+			continue;
+		}
+
+		index = pending_index(netbk->pending_cons);
+		pending_idx = netbk->pending_ring[index];
+
+		data_len = (txreq.size > PKT_PROT_LEN &&
+			    ret < MAX_SKB_FRAGS) ?
+			PKT_PROT_LEN : txreq.size;
+
+		skb = alloc_skb(data_len + NET_SKB_PAD + NET_IP_ALIGN,
+				GFP_ATOMIC | __GFP_NOWARN);
+		if (unlikely(skb == NULL)) {
+			pr_debug("Can't allocate a skb in start_xmit.\n");
+			netbk_tx_err(netif, &txreq, idx);
+			break;
+		}
+
+		/* Packets passed to netif_rx() must have some headroom. */
+		skb_reserve(skb, NET_SKB_PAD + NET_IP_ALIGN);
+
+		if (extras[XEN_NETIF_EXTRA_TYPE_GSO - 1].type) {
+			struct xen_netif_extra_info *gso;
+			gso = &extras[XEN_NETIF_EXTRA_TYPE_GSO - 1];
+
+			if (netbk_set_skb_gso(skb, gso)) {
+				kfree_skb(skb);
+				netbk_tx_err(netif, &txreq, idx);
+				continue;
+			}
+		}
+
+		/* XXX could copy straight to head */
+		page = netif_alloc_page(netbk, skb, pending_idx);
+		if (!page) {
+			kfree_skb(skb);
+			netbk_tx_err(netif, &txreq, idx);
+			continue;
+		}
+
+		netbk->mmap_pages[pending_idx] = page;
+
+		gop->source.u.ref = txreq.gref;
+		gop->source.domid = netif->domid;
+		gop->source.offset = txreq.offset;
+
+		gop->dest.u.gmfn = virt_to_mfn(page_address(page));
+		gop->dest.domid = DOMID_SELF;
+		gop->dest.offset = txreq.offset;
+
+		gop->len = txreq.size;
+		gop->flags = GNTCOPY_source_gref;
+
+		gop++;
+
+		memcpy(&netbk->pending_tx_info[pending_idx].req,
+		       &txreq, sizeof(txreq));
+		netbk->pending_tx_info[pending_idx].netif = netif;
+		*((u16 *)skb->data) = pending_idx;
+
+		__skb_put(skb, data_len);
+
+		skb_shinfo(skb)->nr_frags = ret;
+		if (data_len < txreq.size) {
+			skb_shinfo(skb)->nr_frags++;
+			skb_shinfo(skb)->frags[0].page =
+				(void *)(unsigned long)pending_idx;
+		} else {
+			/* Discriminate from any valid pending_idx value. */
+			skb_shinfo(skb)->frags[0].page = (void *)~0UL;
+		}
+
+		__skb_queue_tail(&netbk->tx_queue, skb);
+
+		netbk->pending_cons++;
+
+		request_gop = netbk_get_requests(netbk, netif,
+						 skb, txfrags, gop);
+		if (request_gop == NULL) {
+			kfree_skb(skb);
+			netbk_tx_err(netif, &txreq, idx);
+			continue;
+		}
+		gop = request_gop;
+
+		netif->tx.req_cons = idx;
+		netif_schedule_work(netif);
+
+		if ((gop-netbk->tx_copy_ops) >= ARRAY_SIZE(netbk->tx_copy_ops))
+			break;
+	}
+
+	return gop - netbk->tx_copy_ops;
+}
+
+static void net_tx_submit(struct xen_netbk *netbk)
+{
+	struct gnttab_copy *gop = netbk->tx_copy_ops;
+	struct sk_buff *skb;
+
+	while ((skb = __skb_dequeue(&netbk->tx_queue)) != NULL) {
+		struct xen_netif_tx_request *txp;
+		struct xen_netif *netif;
+		u16 pending_idx;
+		unsigned data_len;
+
+		pending_idx = *((u16 *)skb->data);
+		netif = netbk->pending_tx_info[pending_idx].netif;
+		txp = &netbk->pending_tx_info[pending_idx].req;
+
+		/* Check the remap error code. */
+		if (unlikely(netbk_tx_check_gop(netbk, skb, &gop))) {
+			pr_debug("netback grant failed.\n");
+			skb_shinfo(skb)->nr_frags = 0;
+			kfree_skb(skb);
+			continue;
+		}
+
+		data_len = skb->len;
+		memcpy(skb->data,
+		       (void *)(idx_to_kaddr(netbk, pending_idx)|txp->offset),
+		       data_len);
+		if (data_len < txp->size) {
+			/* Append the packet payload as a fragment. */
+			txp->offset += data_len;
+			txp->size -= data_len;
+		} else {
+			/* Schedule a response immediately. */
+			netif_idx_release(netbk, pending_idx);
+		}
+
+		if (txp->flags & NETTXF_csum_blank)
+			skb->ip_summed = CHECKSUM_PARTIAL;
+		else if (txp->flags & NETTXF_data_validated)
+			skb->ip_summed = CHECKSUM_UNNECESSARY;
+
+		netbk_fill_frags(netbk, skb);
+
+		/*
+		 * If the initial fragment was < PKT_PROT_LEN then
+		 * pull through some bytes from the other fragments to
+		 * increase the linear region to PKT_PROT_LEN bytes.
+		 */
+		if (skb_headlen(skb) < PKT_PROT_LEN && skb_is_nonlinear(skb)) {
+			int target = min_t(int, skb->len, PKT_PROT_LEN);
+			__pskb_pull_tail(skb, target - skb_headlen(skb));
+		}
+
+		skb->dev      = netif->dev;
+		skb->protocol = eth_type_trans(skb, skb->dev);
+
+		if (skb->ip_summed == CHECKSUM_PARTIAL) {
+			if (skb_checksum_setup(skb)) {
+				pr_debug("skb_checksum_setup failed\n");
+				kfree_skb(skb);
+				continue;
+			}
+		} else if (skb_is_gso(skb)) {
+			pr_debug("GSO SKB checksum is not partial\n");
+			kfree_skb(skb);
+			continue;
+		}
+
+		netif->stats.rx_bytes += skb->len;
+		netif->stats.rx_packets++;
+
+		netif_rx_ni(skb);
+		netif->dev->last_rx = jiffies;
+	}
+}
+
+/* Called after netfront has transmitted */
+static void net_tx_action(unsigned long data)
+{
+	struct xen_netbk *netbk = (struct xen_netbk *)data;
+	unsigned nr_gops;
+	int ret;
+
+	nr_gops = net_tx_build_gops(netbk);
+
+	if (nr_gops == 0)
+		return;
+	ret = HYPERVISOR_grant_table_op(GNTTABOP_copy,
+					netbk->tx_copy_ops, nr_gops);
+	BUG_ON(ret);
+
+	net_tx_submit(netbk);
+
+}
+
+static void netif_idx_release(struct xen_netbk *netbk, u16 pending_idx)
+{
+	struct xen_netif *netif;
+	struct pending_tx_info *pending_tx_info;
+	pending_ring_idx_t index;
+
+	/* Already complete? */
+	if (netbk->mmap_pages[pending_idx] == NULL)
+		return;
+
+	pending_tx_info = &netbk->pending_tx_info[pending_idx];
+
+	netif = pending_tx_info->netif;
+
+	make_tx_response(netif, &pending_tx_info->req,
+			 NETIF_RSP_OKAY);
+
+	index = pending_index(netbk->pending_prod++);
+	netbk->pending_ring[index] = pending_idx;
+
+	netif_put(netif);
+
+	netbk->mmap_pages[pending_idx]->mapping = 0;
+	put_page(netbk->mmap_pages[pending_idx]);
+	netbk->mmap_pages[pending_idx] = NULL;
+}
+
+irqreturn_t netif_be_int(int irq, void *dev_id)
+{
+	struct xen_netif *netif = dev_id;
+	struct xen_netbk *netbk;
+
+	if (netif->group == -1)
+		return IRQ_NONE;
+
+	netbk = &xen_netbk[netif->group];
+
+	add_to_net_schedule_list_tail(netif);
+	maybe_schedule_tx_action(netbk);
+
+	if (netif_schedulable(netif) && !netbk_queue_full(netif))
+		netif_wake_queue(netif->dev);
+
+	return IRQ_HANDLED;
+}
+
+static void make_tx_response(struct xen_netif *netif,
+			     struct xen_netif_tx_request *txp,
+			     s8       st)
+{
+	RING_IDX i = netif->tx.rsp_prod_pvt;
+	struct xen_netif_tx_response *resp;
+	int notify;
+
+	resp = RING_GET_RESPONSE(&netif->tx, i);
+	resp->id     = txp->id;
+	resp->status = st;
+
+	if (txp->flags & NETTXF_extra_info)
+		RING_GET_RESPONSE(&netif->tx, ++i)->status = NETIF_RSP_NULL;
+
+	netif->tx.rsp_prod_pvt = ++i;
+	RING_PUSH_RESPONSES_AND_CHECK_NOTIFY(&netif->tx, notify);
+	if (notify)
+		notify_remote_via_irq(netif->irq);
+}
+
+static struct xen_netif_rx_response *make_rx_response(struct xen_netif *netif,
+					     u16      id,
+					     s8       st,
+					     u16      offset,
+					     u16      size,
+					     u16      flags)
+{
+	RING_IDX i = netif->rx.rsp_prod_pvt;
+	struct xen_netif_rx_response *resp;
+
+	resp = RING_GET_RESPONSE(&netif->rx, i);
+	resp->offset     = offset;
+	resp->flags      = flags;
+	resp->id         = id;
+	resp->status     = (s16)size;
+	if (st < 0)
+		resp->status = (s16)st;
+
+	netif->rx.rsp_prod_pvt = ++i;
+
+	return resp;
+}
+
+#ifdef NETBE_DEBUG_INTERRUPT
+static irqreturn_t netif_be_dbg(int irq, void *dev_id, struct pt_regs *regs)
+{
+	struct list_head *ent;
+	struct xen_netif *netif;
+	int i = 0;
+	int group = 0;
+
+	printk(KERN_ALERT "netif_schedule_list:\n");
+
+	for (group = 0; group < xen_netbk_group_nr; group++) {
+		struct xen_netbk *netbk = &xen_netbk[group];
+		spin_lock_irq(&netbk->net_schedule_list_lock);
+		printk(KERN_ALERT "xen_netback group number: %d\n", group);
+		list_for_each(ent, &netbk->net_schedule_list) {
+			netif = list_entry(ent, struct xen_netif, list);
+			printk(KERN_ALERT " %d: private(rx_req_cons=%08x "
+				"rx_resp_prod=%08x\n",
+				i, netif->rx.req_cons, netif->rx.rsp_prod_pvt);
+			printk(KERN_ALERT
+				"   tx_req_cons=%08x, tx_resp_prod=%08x)\n",
+				netif->tx.req_cons, netif->tx.rsp_prod_pvt);
+			printk(KERN_ALERT
+				"   shared(rx_req_prod=%08x "
+				"rx_resp_prod=%08x\n",
+				netif->rx.sring->req_prod,
+				netif->rx.sring->rsp_prod);
+			printk(KERN_ALERT
+				"   rx_event=%08x, tx_req_prod=%08x\n",
+				netif->rx.sring->rsp_event,
+				netif->tx.sring->req_prod);
+			printk(KERN_ALERT
+				"   tx_resp_prod=%08x, tx_event=%08x)\n",
+				netif->tx.sring->rsp_prod,
+				netif->tx.sring->rsp_event);
+			i++;
+		}
+		spin_unlock_irq(&netbk->net_schedule_list_lock);
+	}
+
+	printk(KERN_ALERT " ** End of netif_schedule_list **\n");
+
+	return IRQ_HANDLED;
+}
+#endif
+
+static inline int rx_work_todo(struct xen_netbk *netbk)
+{
+	return !skb_queue_empty(&netbk->rx_queue);
+}
+
+static inline int tx_work_todo(struct xen_netbk *netbk)
+{
+
+	if (((nr_pending_reqs(netbk) + MAX_SKB_FRAGS) < MAX_PENDING_REQS) &&
+			!list_empty(&netbk->net_schedule_list))
+		return 1;
+
+	return 0;
+}
+
+static int netbk_action_thread(void *data)
+{
+	struct xen_netbk *netbk = (struct xen_netbk *)data;
+	while (!kthread_should_stop()) {
+		wait_event_interruptible(netbk->kthread.netbk_action_wq,
+				rx_work_todo(netbk)
+				|| tx_work_todo(netbk)
+				|| kthread_should_stop());
+		cond_resched();
+
+		if (kthread_should_stop())
+			break;
+
+		if (rx_work_todo(netbk))
+			net_rx_action((unsigned long)netbk);
+
+		if (tx_work_todo(netbk))
+			net_tx_action((unsigned long)netbk);
+	}
+
+	return 0;
+}
+
+static int __init netback_init(void)
+{
+	int i;
+	int rc = 0;
+	int group;
+
+	if (!xen_pv_domain())
+		return -ENODEV;
+
+	xen_netbk_group_nr = num_online_cpus();
+	xen_netbk = vmalloc(sizeof(struct xen_netbk) * xen_netbk_group_nr);
+	if (!xen_netbk) {
+		printk(KERN_ALERT "%s: out of memory\n", __func__);
+		return -ENOMEM;
+	}
+	memset(xen_netbk, 0, sizeof(struct xen_netbk) * xen_netbk_group_nr);
+
+	for (group = 0; group < xen_netbk_group_nr; group++) {
+		struct xen_netbk *netbk = &xen_netbk[group];
+		skb_queue_head_init(&netbk->rx_queue);
+		skb_queue_head_init(&netbk->tx_queue);
+
+		init_timer(&netbk->net_timer);
+		netbk->net_timer.data = (unsigned long)netbk;
+		netbk->net_timer.function = net_alarm;
+
+		netbk->pending_cons = 0;
+		netbk->pending_prod = MAX_PENDING_REQS;
+		for (i = 0; i < MAX_PENDING_REQS; i++)
+			netbk->pending_ring[i] = i;
+
+		if (MODPARM_netback_kthread) {
+			init_waitqueue_head(&netbk->kthread.netbk_action_wq);
+			netbk->kthread.task =
+				kthread_create(netbk_action_thread,
+					       (void *)netbk,
+					       "netback/%u", group);
+
+			if (!IS_ERR(netbk->kthread.task)) {
+				kthread_bind(netbk->kthread.task, group);
+			} else {
+				printk(KERN_ALERT
+					"kthread_run() fails at netback\n");
+				del_timer(&netbk->net_timer);
+				rc = PTR_ERR(netbk->kthread.task);
+				goto failed_init;
+			}
+		} else {
+			tasklet_init(&netbk->tasklet.net_tx_tasklet,
+				     net_tx_action,
+				     (unsigned long)netbk);
+			tasklet_init(&netbk->tasklet.net_rx_tasklet,
+				     net_rx_action,
+				     (unsigned long)netbk);
+		}
+
+		INIT_LIST_HEAD(&netbk->net_schedule_list);
+
+		spin_lock_init(&netbk->net_schedule_list_lock);
+
+		atomic_set(&netbk->netfront_count, 0);
+		if (MODPARM_netback_kthread)
+			wake_up_process(netbk->kthread.task);
+	}
+
+	rc = netif_xenbus_init();
+	if (rc)
+		goto failed_init;
+
+#ifdef NETBE_DEBUG_INTERRUPT
+	(void)bind_virq_to_irqhandler(VIRQ_DEBUG,
+				      0,
+				      netif_be_dbg,
+				      IRQF_SHARED,
+				      "net-be-dbg",
+				      &netif_be_dbg);
+#endif
+
+	return 0;
+
+failed_init:
+	for (i = 0; i < group; i++) {
+		struct xen_netbk *netbk = &xen_netbk[i];
+		int j;
+		for (j = 0; j < MAX_PENDING_REQS; j++) {
+			if (netbk->mmap_pages[i])
+				__free_page(netbk->mmap_pages[i]);
+		}
+		del_timer(&netbk->net_timer);
+		if (MODPARM_netback_kthread)
+			kthread_stop(netbk->kthread.task);
+	}
+	vfree(xen_netbk);
+	return rc;
+
+}
+
+module_init(netback_init);
+
+MODULE_LICENSE("Dual BSD/GPL");
diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xenbus.c
new file mode 100644
index 0000000..0aa3366
--- /dev/null
+++ b/drivers/net/xen-netback/xenbus.c
@@ -0,0 +1,485 @@
+/*  Xenbus code for netif backend
+ * Copyright (C) 2005 Rusty Russell <rusty@rustcorp.com.au>
+ * Copyright (C) 2005 XenSource Ltd
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+*/
+
+#include "common.h"
+
+static int connect_rings(struct backend_info *);
+static void connect(struct backend_info *);
+static void backend_create_netif(struct backend_info *be);
+static void unregister_hotplug_status_watch(struct backend_info *be);
+
+static int netback_remove(struct xenbus_device *dev)
+{
+	struct backend_info *be = dev_get_drvdata(&dev->dev);
+
+	unregister_hotplug_status_watch(be);
+	if (be->netif) {
+		kobject_uevent(&dev->dev.kobj, KOBJ_OFFLINE);
+		xenbus_rm(XBT_NIL, dev->nodename, "hotplug-status");
+		netif_disconnect(be->netif);
+		be->netif = NULL;
+	}
+	kfree(be);
+	dev_set_drvdata(&dev->dev, NULL);
+	return 0;
+}
+
+
+/**
+ * Entry point to this code when a new device is created.  Allocate the basic
+ * structures and switch to InitWait.
+ */
+static int netback_probe(struct xenbus_device *dev,
+			 const struct xenbus_device_id *id)
+{
+	const char *message;
+	struct xenbus_transaction xbt;
+	int err;
+	int sg;
+	struct backend_info *be = kzalloc(sizeof(struct backend_info),
+					  GFP_KERNEL);
+	if (!be) {
+		xenbus_dev_fatal(dev, -ENOMEM,
+				 "allocating backend structure");
+		return -ENOMEM;
+	}
+
+	be->dev = dev;
+	dev_set_drvdata(&dev->dev, be);
+
+	sg = 1;
+
+	do {
+		err = xenbus_transaction_start(&xbt);
+		if (err) {
+			xenbus_dev_fatal(dev, err, "starting transaction");
+			goto fail;
+		}
+
+		err = xenbus_printf(xbt, dev->nodename, "feature-sg", "%d", sg);
+		if (err) {
+			message = "writing feature-sg";
+			goto abort_transaction;
+		}
+
+		err = xenbus_printf(xbt, dev->nodename, "feature-gso-tcpv4",
+				    "%d", sg);
+		if (err) {
+			message = "writing feature-gso-tcpv4";
+			goto abort_transaction;
+		}
+
+		/* We support rx-copy path. */
+		err = xenbus_printf(xbt, dev->nodename,
+				    "feature-rx-copy", "%d", 1);
+		if (err) {
+			message = "writing feature-rx-copy";
+			goto abort_transaction;
+		}
+
+		/*
+		 * We don't support rx-flip path (except old guests who don't
+		 * grok this feature flag).
+		 */
+		err = xenbus_printf(xbt, dev->nodename,
+				    "feature-rx-flip", "%d", 0);
+		if (err) {
+			message = "writing feature-rx-flip";
+			goto abort_transaction;
+		}
+
+		err = xenbus_transaction_end(xbt, 0);
+	} while (err == -EAGAIN);
+
+	if (err) {
+		xenbus_dev_fatal(dev, err, "completing transaction");
+		goto fail;
+	}
+
+	err = xenbus_switch_state(dev, XenbusStateInitWait);
+	if (err)
+		goto fail;
+
+	/* This kicks hotplug scripts, so do it immediately. */
+	backend_create_netif(be);
+
+	return 0;
+
+abort_transaction:
+	xenbus_transaction_end(xbt, 1);
+	xenbus_dev_fatal(dev, err, "%s", message);
+fail:
+	pr_debug("failed");
+	netback_remove(dev);
+	return err;
+}
+
+
+/*
+ * Handle the creation of the hotplug script environment.  We add the script
+ * and vif variables to the environment, for the benefit of the vif-* hotplug
+ * scripts.
+ */
+static int netback_uevent(struct xenbus_device *xdev,
+			  struct kobj_uevent_env *env)
+{
+	struct backend_info *be = dev_get_drvdata(&xdev->dev);
+	char *val;
+
+	val = xenbus_read(XBT_NIL, xdev->nodename, "script", NULL);
+	if (IS_ERR(val)) {
+		int err = PTR_ERR(val);
+		xenbus_dev_fatal(xdev, err, "reading script");
+		return err;
+	} else {
+		if (add_uevent_var(env, "script=%s", val)) {
+			kfree(val);
+			return -ENOMEM;
+		}
+		kfree(val);
+	}
+
+	if (!be || !be->netif)
+		return 0;
+
+	return add_uevent_var(env, "vif=%s", be->netif->dev->name);
+}
+
+
+static void backend_create_netif(struct backend_info *be)
+{
+	int err;
+	long handle;
+	struct xenbus_device *dev = be->dev;
+
+	if (be->netif != NULL)
+		return;
+
+	err = xenbus_scanf(XBT_NIL, dev->nodename, "handle", "%li", &handle);
+	if (err != 1) {
+		xenbus_dev_fatal(dev, err, "reading handle");
+		return;
+	}
+
+	be->netif = netif_alloc(&dev->dev, dev->otherend_id, handle);
+	if (IS_ERR(be->netif)) {
+		err = PTR_ERR(be->netif);
+		be->netif = NULL;
+		xenbus_dev_fatal(dev, err, "creating interface");
+		return;
+	}
+
+	kobject_uevent(&dev->dev.kobj, KOBJ_ONLINE);
+}
+
+
+static void disconnect_backend(struct xenbus_device *dev)
+{
+	struct backend_info *be = dev_get_drvdata(&dev->dev);
+
+	if (be->netif) {
+		xenbus_rm(XBT_NIL, dev->nodename, "hotplug-status");
+		netif_disconnect(be->netif);
+		be->netif = NULL;
+	}
+}
+
+/**
+ * Callback received when the frontend's state changes.
+ */
+static void frontend_changed(struct xenbus_device *dev,
+			     enum xenbus_state frontend_state)
+{
+	struct backend_info *be = dev_get_drvdata(&dev->dev);
+
+	pr_debug("frontend state %s", xenbus_strstate(frontend_state));
+
+	be->frontend_state = frontend_state;
+
+	switch (frontend_state) {
+	case XenbusStateInitialising:
+		if (dev->state == XenbusStateClosed) {
+			printk(KERN_INFO "%s: %s: prepare for reconnect\n",
+			       __func__, dev->nodename);
+			xenbus_switch_state(dev, XenbusStateInitWait);
+		}
+		break;
+
+	case XenbusStateInitialised:
+		break;
+
+	case XenbusStateConnected:
+		if (dev->state == XenbusStateConnected)
+			break;
+		backend_create_netif(be);
+		if (be->netif)
+			connect(be);
+		break;
+
+	case XenbusStateClosing:
+		if (be->netif)
+			kobject_uevent(&dev->dev.kobj, KOBJ_OFFLINE);
+		disconnect_backend(dev);
+		xenbus_switch_state(dev, XenbusStateClosing);
+		break;
+
+	case XenbusStateClosed:
+		xenbus_switch_state(dev, XenbusStateClosed);
+		if (xenbus_dev_is_online(dev))
+			break;
+		/* fall through if not online */
+	case XenbusStateUnknown:
+		device_unregister(&dev->dev);
+		break;
+
+	default:
+		xenbus_dev_fatal(dev, -EINVAL, "saw state %d at frontend",
+				 frontend_state);
+		break;
+	}
+}
+
+
+static void xen_net_read_rate(struct xenbus_device *dev,
+			      unsigned long *bytes, unsigned long *usec)
+{
+	char *s, *e;
+	unsigned long b, u;
+	char *ratestr;
+
+	/* Default to unlimited bandwidth. */
+	*bytes = ~0UL;
+	*usec = 0;
+
+	ratestr = xenbus_read(XBT_NIL, dev->nodename, "rate", NULL);
+	if (IS_ERR(ratestr))
+		return;
+
+	s = ratestr;
+	b = simple_strtoul(s, &e, 10);
+	if ((s == e) || (*e != ','))
+		goto fail;
+
+	s = e + 1;
+	u = simple_strtoul(s, &e, 10);
+	if ((s == e) || (*e != '\0'))
+		goto fail;
+
+	*bytes = b;
+	*usec = u;
+
+	kfree(ratestr);
+	return;
+
+ fail:
+	pr_warn("Failed to parse network rate limit. Traffic unlimited.\n");
+	kfree(ratestr);
+}
+
+static int xen_net_read_mac(struct xenbus_device *dev, u8 mac[])
+{
+	char *s, *e, *macstr;
+	int i;
+
+	macstr = s = xenbus_read(XBT_NIL, dev->nodename, "mac", NULL);
+	if (IS_ERR(macstr))
+		return PTR_ERR(macstr);
+
+	for (i = 0; i < ETH_ALEN; i++) {
+		mac[i] = simple_strtoul(s, &e, 16);
+		if ((s == e) || (*e != ((i == ETH_ALEN-1) ? '\0' : ':'))) {
+			kfree(macstr);
+			return -ENOENT;
+		}
+		s = e+1;
+	}
+
+	kfree(macstr);
+	return 0;
+}
+
+static void unregister_hotplug_status_watch(struct backend_info *be)
+{
+	if (be->have_hotplug_status_watch) {
+		unregister_xenbus_watch(&be->hotplug_status_watch);
+		kfree(be->hotplug_status_watch.node);
+	}
+	be->have_hotplug_status_watch = 0;
+}
+
+static void hotplug_status_changed(struct xenbus_watch *watch,
+				   const char **vec,
+				   unsigned int vec_size)
+{
+	struct backend_info *be = container_of(watch,
+					       struct backend_info,
+					       hotplug_status_watch);
+	char *str;
+	unsigned int len;
+
+	str = xenbus_read(XBT_NIL, be->dev->nodename, "hotplug-status", &len);
+	if (IS_ERR(str))
+		return;
+	if (len == sizeof("connected")-1 && !memcmp(str, "connected", len)) {
+		xenbus_switch_state(be->dev, XenbusStateConnected);
+		/* Not interested in this watch anymore. */
+		unregister_hotplug_status_watch(be);
+	}
+	kfree(str);
+}
+
+static void connect(struct backend_info *be)
+{
+	int err;
+	struct xenbus_device *dev = be->dev;
+
+	err = connect_rings(be);
+	if (err)
+		return;
+
+	err = xen_net_read_mac(dev, be->netif->fe_dev_addr);
+	if (err) {
+		xenbus_dev_fatal(dev, err, "parsing %s/mac", dev->nodename);
+		return;
+	}
+
+	xen_net_read_rate(dev, &be->netif->credit_bytes,
+			  &be->netif->credit_usec);
+	be->netif->remaining_credit = be->netif->credit_bytes;
+
+	unregister_hotplug_status_watch(be);
+	err = xenbus_watch_pathfmt(dev, &be->hotplug_status_watch,
+				   hotplug_status_changed,
+				   "%s/%s", dev->nodename, "hotplug-status");
+	if (err) {
+		/* Switch now, since we can't do a watch. */
+		xenbus_switch_state(dev, XenbusStateConnected);
+	} else {
+		be->have_hotplug_status_watch = 1;
+	}
+
+	netif_wake_queue(be->netif->dev);
+}
+
+
+static int connect_rings(struct backend_info *be)
+{
+	struct xen_netif *netif = be->netif;
+	struct xenbus_device *dev = be->dev;
+	unsigned long tx_ring_ref, rx_ring_ref;
+	unsigned int evtchn, rx_copy;
+	int err;
+	int val;
+
+	err = xenbus_gather(XBT_NIL, dev->otherend,
+			    "tx-ring-ref", "%lu", &tx_ring_ref,
+			    "rx-ring-ref", "%lu", &rx_ring_ref,
+			    "event-channel", "%u", &evtchn, NULL);
+	if (err) {
+		xenbus_dev_fatal(dev, err,
+				 "reading %s/ring-ref and event-channel",
+				 dev->otherend);
+		return err;
+	}
+
+	err = xenbus_scanf(XBT_NIL, dev->otherend, "request-rx-copy", "%u",
+			   &rx_copy);
+	if (err == -ENOENT) {
+		err = 0;
+		rx_copy = 0;
+	}
+	if (err < 0) {
+		xenbus_dev_fatal(dev, err, "reading %s/request-rx-copy",
+				 dev->otherend);
+		return err;
+	}
+	if (!rx_copy)
+		return -EOPNOTSUPP;
+
+	if (netif->dev->tx_queue_len != 0) {
+		if (xenbus_scanf(XBT_NIL, dev->otherend,
+				 "feature-rx-notify", "%d", &val) < 0)
+			val = 0;
+		if (val)
+			netif->can_queue = 1;
+		else
+			/* Must be non-zero for pfifo_fast to work. */
+			netif->dev->tx_queue_len = 1;
+	}
+
+	if (xenbus_scanf(XBT_NIL, dev->otherend, "feature-sg",
+			 "%d", &val) < 0)
+		val = 0;
+	netif->can_sg = !!val;
+
+	if (xenbus_scanf(XBT_NIL, dev->otherend, "feature-gso-tcpv4",
+			 "%d", &val) < 0)
+		val = 0;
+	netif->gso = !!val;
+
+	if (xenbus_scanf(XBT_NIL, dev->otherend, "feature-gso-tcpv4-prefix",
+			 "%d", &val) < 0)
+		val = 0;
+	netif->gso_prefix = !!val;
+
+	if (xenbus_scanf(XBT_NIL, dev->otherend, "feature-no-csum-offload",
+			 "%d", &val) < 0)
+		val = 0;
+	netif->csum = !val;
+
+	/* Set dev->features */
+	netif_set_features(netif);
+
+	/* Map the shared frame, irq etc. */
+	err = netif_map(netif, tx_ring_ref, rx_ring_ref, evtchn);
+	if (err) {
+		xenbus_dev_fatal(dev, err,
+				 "mapping shared-frames %lu/%lu port %u",
+				 tx_ring_ref, rx_ring_ref, evtchn);
+		return err;
+	}
+	return 0;
+}
+
+
+/* ** Driver Registration ** */
+
+
+static const struct xenbus_device_id netback_ids[] = {
+	{ "vif" },
+	{ "" }
+};
+
+
+static struct xenbus_driver netback = {
+	.name = "vif",
+	.owner = THIS_MODULE,
+	.ids = netback_ids,
+	.probe = netback_probe,
+	.remove = netback_remove,
+	.uevent = netback_uevent,
+	.otherend_changed = frontend_changed,
+};
+
+
+int netif_xenbus_init(void)
+{
+	printk(KERN_CRIT "registering netback\n");
+	return xenbus_register_backend(&netback);
+}
diff --git a/include/xen/interface/io/netif.h b/include/xen/interface/io/netif.h
index 518481c..8309344 100644
--- a/include/xen/interface/io/netif.h
+++ b/include/xen/interface/io/netif.h
@@ -131,6 +131,10 @@ struct xen_netif_rx_request {
 #define _NETRXF_extra_info     (3)
 #define  NETRXF_extra_info     (1U<<_NETRXF_extra_info)
 
+/* GSO Prefix descriptor. */
+#define _NETRXF_gso_prefix     (4)
+#define  NETRXF_gso_prefix     (1U<<_NETRXF_gso_prefix)
+
 struct xen_netif_rx_response {
     uint16_t id;
     uint16_t offset;       /* Offset in page of start of received packet  */
diff --git a/include/xen/interface/io/ring.h b/include/xen/interface/io/ring.h
index e8cbf43..c868d86 100644
--- a/include/xen/interface/io/ring.h
+++ b/include/xen/interface/io/ring.h
@@ -24,8 +24,15 @@ typedef unsigned int RING_IDX;
  * A ring contains as many entries as will fit, rounded down to the nearest
  * power of two (so we can mask with (size-1) to loop around).
  */
-#define __RING_SIZE(_s, _sz) \
-    (__RD32(((_sz) - (long)&(_s)->ring + (long)(_s)) / sizeof((_s)->ring[0])))
+#define __CONST_RING_SIZE(_s, _sz)				\
+	(__RD32(((_sz) - offsetof(struct _s##_sring, ring)) /	\
+		sizeof(((struct _s##_sring *)0)->ring[0])))
+
+/*
+ * The same for passing in an actual pointer instead of a name tag.
+ */
+#define __RING_SIZE(_s, _sz)						\
+	(__RD32(((_sz) - (long)&(_s)->ring + (long)(_s)) / sizeof((_s)->ring[0])))
 
 /*
  * Macros to make the correct C datatypes for a new kind of ring.
@@ -73,7 +80,13 @@ union __name##_sring_entry {						\
 struct __name##_sring {							\
     RING_IDX req_prod, req_event;					\
     RING_IDX rsp_prod, rsp_event;					\
-    uint8_t  pad[48];							\
+    union {								\
+        struct {							\
+            uint8_t msg;						\
+        } tapif_user;							\
+        uint8_t pvt_pad[4];						\
+    } private;								\
+    uint8_t pad[44];							\
     union __name##_sring_entry ring[1]; /* variable-length */		\
 };									\
 									\


