From: Niranjana Vishwanathapura <nvishwan@codeaurora.org>
Subject: [PATCH v2] msm: rmnet: msm rmnet smd virtual network driver
Date: Wed,  9 Feb 2011 11:32:41 -0800
Message-ID: <1297279961-22386-1-git-send-email-nvishwan@codeaurora.org>
Cc: linux-arm-msm@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, swetland@google.com,
	dima@android.com,
	Niranjana Vishwanathapura <nvishwan@codeaurora.org>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-arm-msm-owner@vger.kernel.org>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Virtual network interface for MSM RMNET SMD transport.
This driver creates network devices which use underlying
SMD ports as transport.  This driver enables sending and
receving IP packets to baseband processor in MSM chipsets.

Cc: Brian Swetland <swetland@google.com>
Signed-off-by: Niranjana Vishwanathapura <nvishwan@codeaurora.org>
---
 drivers/net/Kconfig         |   10 ++
 drivers/net/Makefile        |    1 +
 drivers/net/msm_rmnet_smd.c |  213 +++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 224 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/msm_rmnet_smd.c

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 0382332..b4f39bb 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -3422,4 +3422,14 @@ config VMXNET3
 	  To compile this driver as a module, choose M here: the
 	  module will be called vmxnet3.
 
+config MSM_RMNET_SMD
+	bool "MSM RMNET Virtual Network Device over SMD transport"
+	depends on MSM_SMD
+	default n
+	help
+	  Virtual network interface for MSM RMNET SMD transport.
+	  This driver creates network devices which use underlying
+	  SMD ports as transport.  This driver enables sending and
+	  receving IP packets to baseband processor in MSM chipsets.
+
 endif # NETDEVICES
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index b90738d..2bb4025 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -302,3 +302,4 @@ obj-$(CONFIG_CAIF) += caif/
 obj-$(CONFIG_OCTEON_MGMT_ETHERNET) += octeon/
 obj-$(CONFIG_PCH_GBE) += pch_gbe/
 obj-$(CONFIG_TILE_NET) += tile/
+obj-$(CONFIG_MSM_RMNET_SMD) += msm_rmnet_smd.o
diff --git a/drivers/net/msm_rmnet_smd.c b/drivers/net/msm_rmnet_smd.c
new file mode 100644
index 0000000..03a0d14
--- /dev/null
+++ b/drivers/net/msm_rmnet_smd.c
@@ -0,0 +1,213 @@
+/* drivers/net/msm_rmnet_smd.c
+ *
+ * Virtual Ethernet Interface for MSM7K Networking
+ *
+ * Copyright (C) 2007 Google, Inc.
+ * Copyright (c) 2011, Code Aurora Forum. All rights reserved.
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
+struct rmnet_private {
+	smd_channel_t *ch;
+	const char *chname;
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
+					pr_err("rmnet_recv() smd read fail\n");
+					ptr = 0;
+					dev_kfree_skb_irq(skb);
+				} else {
+					skb->protocol = eth_type_trans(skb,
+								       dev);
+					if (count_this_packet(ptr, skb->len)) {
+						dev->stats.rx_packets++;
+						dev->stats.rx_bytes += skb->len;
+					}
+					netif_receive_skb(skb);
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
+			dev->stats.tx_packets++;
+			dev->stats.tx_bytes += skb->len;
+		}
+	}
+
+	dev_kfree_skb_irq(skb);
+	return 0;
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
+
+		ret = register_netdev(dev);
+		if (ret) {
+			free_netdev(dev);
+			return ret;
+		}
+	}
+	return 0;
+}
+
+module_init(rmnet_init);
-- 
1.5.6.3

Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum.

