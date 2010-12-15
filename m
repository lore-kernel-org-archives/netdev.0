From: Niranjana Vishwanathapura <nvishwan@codeaurora.org>
Subject: [PATCH] msm: rmnet: msm rmnet smd virtual ethernet driver
Date: Wed, 15 Dec 2010 10:31:06 -0800
Message-ID: <1292437866-11652-1-git-send-email-nvishwan@codeaurora.org>
Cc: linux-arm-msm@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	Niranjana Vishwanathapura <nvishwan@codeaurora.org>,
	Brian Swetland <swetland@google.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Virtual ethernet interface for MSM RMNET SMD transport.
This driver creates network devices which use underlaying
SMD ports as transport.  This driver enables sending and
receving IP packets to baseband processor in MSM chipsets.

Cc: Brian Swetland <swetland@google.com>
Signed-off-by: Niranjana Vishwanathapura <nvishwan@codeaurora.org>
---
 drivers/net/Kconfig         |   17 ++
 drivers/net/Makefile        |    1 +
 drivers/net/msm_rmnet_smd.c |  357 +++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 375 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/msm_rmnet_smd.c

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index f6668cd..94ddee3 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -3407,4 +3407,21 @@ config VMXNET3
          To compile this driver as a module, choose M here: the
          module will be called vmxnet3.
 
+config MSM_RMNET_SMD
+	bool "MSM RMNET Virtual Network Device over SMD transport"
+	depends on MSM_SMD
+	default n
+	help
+	  Virtual ethernet interface for MSM RMNET SMD transport.
+	  This driver creates network devices which use underlaying
+	  SMD ports as transport.  This driver enables sending and
+	  receving IP packets to baseband processor in MSM chipsets.
+
+config MSM_RMNET_DEBUG
+	bool "MSM RMNET debug interface"
+	depends on MSM_RMNET_SMD
+	default n
+	help
+	  Debug stats on wakeup counts for MSM RMNET devices.
+
 endif # NETDEVICES
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 652fc6b..51c0443 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -301,3 +301,4 @@ obj-$(CONFIG_CAIF) += caif/
 
 obj-$(CONFIG_OCTEON_MGMT_ETHERNET) += octeon/
 obj-$(CONFIG_PCH_GBE) += pch_gbe/
+obj-$(CONFIG_MSM_RMNET_SMD) += msm_rmnet_smd.o
diff --git a/drivers/net/msm_rmnet_smd.c b/drivers/net/msm_rmnet_smd.c
new file mode 100644
index 0000000..465da4e
--- /dev/null
+++ b/drivers/net/msm_rmnet_smd.c
@@ -0,0 +1,357 @@
+/* drivers/net/msm_rmnet.c
+ *
+ * Virtual Ethernet Interface for MSM7K Networking
+ *
+ * Copyright (C) 2007 Google, Inc.
+ * Copyright (c) 2010, Code Aurora Forum. All rights reserved.
+ * Author: Brian Swetland <swetland@google.com>
+ *
+ * This software is licensed under the terms of the GNU General Public
+ * License version 2, as published by the Free Software Foundation, and
+ * may be copied, distributed, and modified under those terms.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ */
+
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/string.h>
+#include <linux/delay.h>
+#include <linux/errno.h>
+#include <linux/interrupt.h>
+#include <linux/init.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/skbuff.h>
+
+#include <mach/msm_smd.h>
+
+#define POLL_DELAY 1000000 /* 1 second delay interval */
+
+struct rmnet_private {
+	smd_channel_t *ch;
+	struct net_device_stats stats;
+	const char *chname;
+#ifdef CONFIG_MSM_RMNET_DEBUG
+	ktime_t last_packet;
+	short active_countdown; /* Number of times left to check */
+	short restart_count; /* Number of polls seems so far */
+	unsigned long wakeups_xmit;
+	unsigned long wakeups_rcv;
+	unsigned long timeout_us;
+	unsigned long awake_time_ms;
+	struct delayed_work work;
+#endif
+};
+
+static int count_this_packet(void *_hdr, int len)
+{
+	struct ethhdr *hdr = _hdr;
+
+	if (len >= ETH_HLEN && hdr->h_proto == htons(ETH_P_ARP))
+		return 0;
+
+	return 1;
+}
+
+#ifdef CONFIG_MSM_RMNET_DEBUG
+static unsigned long timeout_us;
+static struct workqueue_struct *rmnet_wq;
+
+static void do_check_active(struct work_struct *work)
+{
+	struct rmnet_private *p =
+		container_of(work, struct rmnet_private, work.work);
+
+	p->restart_count++;
+	if (--p->active_countdown == 0) {
+		p->awake_time_ms += p->restart_count * POLL_DELAY / 1000;
+		p->restart_count = 0;
+	} else {
+		queue_delayed_work(rmnet_wq, &p->work,
+				   usecs_to_jiffies(POLL_DELAY));
+	}
+}
+
+/* Returns 1 if packet caused rmnet to wakeup, 0 otherwise. */
+static int rmnet_cause_wakeup(struct rmnet_private *p)
+{
+	int ret = 0;
+	ktime_t now;
+	if (p->timeout_us == 0) /* Check if disabled */
+		return 0;
+
+	/* Start timer on a wakeup packet */
+	if (p->active_countdown == 0) {
+		ret = 1;
+		now = ktime_get_real();
+		p->last_packet = now;
+		queue_delayed_work(rmnet_wq, &p->work,
+				usecs_to_jiffies(POLL_DELAY));
+	}
+
+	p->active_countdown = p->timeout_us / POLL_DELAY;
+
+	return ret;
+}
+
+static ssize_t wakeups_xmit_show(struct device *d,
+				 struct device_attribute *attr,
+				 char *buf)
+{
+	struct rmnet_private *p = netdev_priv(to_net_dev(d));
+	return sprintf(buf, "%lu\n", p->wakeups_xmit);
+}
+
+DEVICE_ATTR(wakeups_xmit, 0444, wakeups_xmit_show, NULL);
+
+static ssize_t wakeups_rcv_show(struct device *d, struct device_attribute *attr,
+				char *buf)
+{
+	struct rmnet_private *p = netdev_priv(to_net_dev(d));
+	return sprintf(buf, "%lu\n", p->wakeups_rcv);
+}
+
+DEVICE_ATTR(wakeups_rcv, 0444, wakeups_rcv_show, NULL);
+
+/* Set timeout in us. */
+static ssize_t timeout_store(struct device *d, struct device_attribute *attr,
+			     const char *buf, size_t n)
+{
+	if (strict_strtoul(buf, 10, &timeout_us))
+		return -EINVAL;
+	else
+		return n;
+}
+
+static ssize_t timeout_show(struct device *d, struct device_attribute *attr,
+			    char *buf)
+{
+	struct rmnet_private *p = netdev_priv(to_net_dev(d));
+	p = netdev_priv(to_net_dev(d));
+	return sprintf(buf, "%lu\n", timeout_us);
+}
+
+DEVICE_ATTR(timeout, 0664, timeout_show, timeout_store);
+
+/* Show total radio awake time in ms */
+static ssize_t awake_time_show(struct device *d, struct device_attribute *attr,
+			       char *buf)
+{
+	struct rmnet_private *p = netdev_priv(to_net_dev(d));
+	return sprintf(buf, "%lu\n", p->awake_time_ms);
+}
+DEVICE_ATTR(awake_time_ms, 0444, awake_time_show, NULL);
+
+#endif
+
+/* Called in soft-irq context */
+static void smd_net_data_handler(unsigned long arg)
+{
+	struct net_device *dev = (struct net_device *) arg;
+	struct rmnet_private *p = netdev_priv(dev);
+	struct sk_buff *skb;
+	void *ptr = 0;
+	int sz;
+
+	for (;;) {
+		sz = smd_cur_packet_size(p->ch);
+		if (sz == 0)
+			break;
+		if (smd_read_avail(p->ch) < sz)
+			break;
+
+		if (sz > 1514) {
+			pr_err("rmnet_recv() discarding %d len\n", sz);
+			ptr = 0;
+		} else {
+			skb = dev_alloc_skb(sz + NET_IP_ALIGN);
+			if (skb == NULL) {
+				pr_err("rmnet_recv() cannot allocate skb\n");
+			} else {
+				skb->dev = dev;
+				skb_reserve(skb, NET_IP_ALIGN);
+				ptr = skb_put(skb, sz);
+				if (smd_read(p->ch, ptr, sz) != sz) {
+					pr_err("rmnet_recv() "
+					       "smd lied about avail?!");
+					ptr = 0;
+					dev_kfree_skb_irq(skb);
+				} else {
+					skb->protocol = eth_type_trans(skb,
+								       dev);
+					if (count_this_packet(ptr, skb->len)) {
+#ifdef CONFIG_MSM_RMNET_DEBUG
+						p->wakeups_rcv +=
+							rmnet_cause_wakeup(p);
+#endif
+						p->stats.rx_packets++;
+						p->stats.rx_bytes += skb->len;
+					}
+					netif_rx(skb);
+				}
+				continue;
+			}
+		}
+		if (smd_read(p->ch, ptr, sz) != sz)
+			pr_err("rmnet_recv() smd lied about avail?!");
+	}
+}
+
+static DECLARE_TASKLET(smd_net_data_tasklet, smd_net_data_handler, 0);
+
+static void smd_net_notify(void *_dev, unsigned event)
+{
+	if (event != SMD_EVENT_DATA)
+		return;
+
+	smd_net_data_tasklet.data = (unsigned long) _dev;
+
+	tasklet_schedule(&smd_net_data_tasklet);
+}
+
+static int rmnet_open(struct net_device *dev)
+{
+	int r;
+	struct rmnet_private *p = netdev_priv(dev);
+
+	pr_info("rmnet_open()\n");
+	if (!p->ch) {
+		r = smd_open(p->chname, &p->ch, dev, smd_net_notify);
+
+		if (r < 0)
+			return -ENODEV;
+	}
+
+	netif_start_queue(dev);
+	return 0;
+}
+
+static int rmnet_stop(struct net_device *dev)
+{
+	pr_info("rmnet_stop()\n");
+	netif_stop_queue(dev);
+	return 0;
+}
+
+static int rmnet_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct rmnet_private *p = netdev_priv(dev);
+	smd_channel_t *ch = p->ch;
+
+	if (smd_write_atomic(ch, skb->data, skb->len) != skb->len) {
+		pr_err("rmnet fifo full, dropping packet\n");
+	} else {
+		if (count_this_packet(skb->data, skb->len)) {
+			p->stats.tx_packets++;
+			p->stats.tx_bytes += skb->len;
+#ifdef CONFIG_MSM_RMNET_DEBUG
+			p->wakeups_xmit += rmnet_cause_wakeup(p);
+#endif
+		}
+	}
+
+	dev_kfree_skb_irq(skb);
+	return 0;
+}
+
+static struct net_device_stats *rmnet_get_stats(struct net_device *dev)
+{
+	struct rmnet_private *p = netdev_priv(dev);
+	return &p->stats;
+}
+
+static void rmnet_set_multicast_list(struct net_device *dev)
+{
+}
+
+static void rmnet_tx_timeout(struct net_device *dev)
+{
+	pr_info("rmnet_tx_timeout()\n");
+}
+
+static struct net_device_ops rmnet_ops = {
+	.ndo_open = rmnet_open,
+	.ndo_stop = rmnet_stop,
+	.ndo_start_xmit = rmnet_xmit,
+	.ndo_get_stats = rmnet_get_stats,
+	.ndo_set_multicast_list = rmnet_set_multicast_list,
+	.ndo_tx_timeout = rmnet_tx_timeout,
+};
+
+static void __init rmnet_setup(struct net_device *dev)
+{
+	dev->netdev_ops = &rmnet_ops;
+
+	dev->watchdog_timeo = 20;
+
+	ether_setup(dev);
+
+	random_ether_addr(dev->dev_addr);
+}
+
+
+static const char *ch_name[3] = {
+	"SMD_DATA5",
+	"SMD_DATA6",
+	"SMD_DATA7",
+};
+
+static int __init rmnet_init(void)
+{
+	int ret;
+	struct device *d;
+	struct net_device *dev;
+	struct rmnet_private *p;
+	unsigned n;
+
+#ifdef CONFIG_MSM_RMNET_DEBUG
+	timeout_us = 0;
+#endif
+
+#ifdef CONFIG_MSM_RMNET_DEBUG
+	rmnet_wq = create_workqueue("rmnet");
+#endif
+
+	for (n = 0; n < 3; n++) {
+		dev = alloc_netdev(sizeof(struct rmnet_private),
+				   "rmnet%d", rmnet_setup);
+
+		if (!dev)
+			return -ENOMEM;
+
+		d = &(dev->dev);
+		p = netdev_priv(dev);
+		p->chname = ch_name[n];
+#ifdef CONFIG_MSM_RMNET_DEBUG
+		p->timeout_us = timeout_us;
+		p->awake_time_ms = p->wakeups_xmit = p->wakeups_rcv = 0;
+		p->active_countdown = p->restart_count = 0;
+		INIT_DELAYED_WORK_DEFERRABLE(&p->work, do_check_active);
+#endif
+
+		ret = register_netdev(dev);
+		if (ret) {
+			free_netdev(dev);
+			return ret;
+		}
+
+#ifdef CONFIG_MSM_RMNET_DEBUG
+		if (device_create_file(d, &dev_attr_timeout))
+			continue;
+		if (device_create_file(d, &dev_attr_wakeups_xmit))
+			continue;
+		if (device_create_file(d, &dev_attr_wakeups_rcv))
+			continue;
+		if (device_create_file(d, &dev_attr_awake_time_ms))
+			continue;
+#endif
+	}
+	return 0;
+}
+
+module_init(rmnet_init);
-- 
1.5.6.3

Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum.
