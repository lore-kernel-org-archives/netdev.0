From: Daniel Borkmann <dborkman@redhat.com>
Subject: [RFC PATCH net-next 3/3] packet: nlmon: virtual netlink monitoring device for packet sockets
Date: Wed, 19 Jun 2013 20:04:46 +0200
Message-ID: <1371665086-19677-4-git-send-email-dborkman@redhat.com>
References: <1371665086-19677-1-git-send-email-dborkman@redhat.com>
Cc: tgraf@suug.ch, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6415 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934993Ab3FSSFQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Jun 2013 14:05:16 -0400
In-Reply-To: <1371665086-19677-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, there is no good possibility to debug netlink traffic that
is being exchanged between kernel and user space. Therefore, this patch
implements a netlink virtual device, so that netlink messages will be
made visible to PF_PACKET sockets. Once there was an approach with a
similar idea [1], but it got forgotten somehow.

I think it makes most sense to accept the "overhead" of an extra netlink
net device over implementing the same functionality from PF_PACKET
sockets once again into netlink sockets. We have BPF filters that can
already be easily applied which even have netlink extensions, we have
RX_RING zero-copy between kernel- and user space that can be reused,
and much more features. So instead of re-implementing all of this, we
simply pass the skb to a given PF_PACKET socket for further analysis.

Another nice benefit that comes from that is that no code needs to be
changed in user space packet analyzers (maybe adding a dissector, but
not more), thus out of the box, we can already capture pcap files of
netlink traffic to debug/troubleshoot netlink problems.

 [1] http://marc.info/?l=linux-netdev&m=113813401516110

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 drivers/net/Kconfig  |  11 ++++
 drivers/net/Makefile |   1 +
 drivers/net/nlmon.c  | 169 +++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 181 insertions(+)
 create mode 100644 drivers/net/nlmon.c

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 3835321..a698732 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -244,6 +244,17 @@ config VIRTIO_NET
 	  This is the virtual network driver for virtio.  It can be used with
 	  lguest or QEMU based VMMs (like KVM or Xen).  Say Y or M.
 
+config NLMON
+	tristate "Virtual netlink monitoring device"
+	default n
+	---help---
+	  This option enables a monitoring net device for netlink skbs. The
+	  purpose of this is to analyze netlink messages with packet sockets.
+	  Thus applications like tcpdump will be able to see local netlink
+	  messages if they tap into the netlink device, record pcaps for further
+	  diagnostics, etc. This is mostly intended for developers or support
+	  to debug netlink issues. If unsure, say N.
+
 endif # NET_CORE
 
 config SUNGEM_PHY
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index ef3d090..3fef8a8 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -22,6 +22,7 @@ obj-$(CONFIG_TUN) += tun.o
 obj-$(CONFIG_VETH) += veth.o
 obj-$(CONFIG_VIRTIO_NET) += virtio_net.o
 obj-$(CONFIG_VXLAN) += vxlan.o
+obj-$(CONFIG_NLMON) += nlmon.o
 
 #
 # Networking Drivers
diff --git a/drivers/net/nlmon.c b/drivers/net/nlmon.c
new file mode 100644
index 0000000..082553a
--- /dev/null
+++ b/drivers/net/nlmon.c
@@ -0,0 +1,169 @@
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/netdevice.h>
+#include <linux/netlink.h>
+#include <net/net_namespace.h>
+#include <linux/if_arp.h>
+
+struct pcpu_lstats {
+	u64 packets;
+	u64 bytes;
+	struct u64_stats_sync syncp;
+};
+
+static struct netlink_tap nlmon_tap;
+
+static netdev_tx_t nlmon_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	int len = skb->len;
+	struct pcpu_lstats *stats = this_cpu_ptr(dev->lstats);
+
+	u64_stats_update_begin(&stats->syncp);
+	stats->bytes += len;
+	stats->packets++;
+	u64_stats_update_end(&stats->syncp);
+
+	dev_kfree_skb(skb);
+
+	return NETDEV_TX_OK;
+}
+
+static int nlmon_dev_init(struct net_device *dev)
+{
+	dev->lstats = alloc_percpu(struct pcpu_lstats);
+	if (dev->lstats == NULL)
+		return -ENOMEM;
+
+	netlink_add_tap(&nlmon_tap);
+	return 0;
+}
+
+static void nlmon_dev_uninit(struct net_device *dev)
+{
+	netlink_remove_tap(&nlmon_tap);
+	free_percpu(dev->lstats);
+}
+
+static struct rtnl_link_stats64 *
+nlmon_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
+{
+	int i;
+	u64 bytes = 0, packets = 0;
+
+	for_each_possible_cpu(i) {
+		const struct pcpu_lstats *nl_stats;
+		u64 tbytes, tpackets;
+		unsigned int start;
+
+		nl_stats = per_cpu_ptr(dev->lstats, i);
+
+		do {
+			start = u64_stats_fetch_begin_bh(&nl_stats->syncp);
+			tbytes = nl_stats->bytes;
+			tpackets = nl_stats->packets;
+		} while (u64_stats_fetch_retry_bh(&nl_stats->syncp, start));
+
+		packets += tpackets;
+		bytes += tbytes;
+	}
+
+	stats->rx_packets = packets;
+	stats->tx_packets = 0;
+
+	stats->rx_bytes = bytes;
+	stats->tx_bytes = 0;
+
+	return stats;
+}
+
+static u32 always_on(struct net_device *dev)
+{
+	return 1;
+}
+
+static int nlmon_receive_skb(struct sk_buff *skb, struct net_device *dev)
+{
+	struct sk_buff *nskb;
+	int err = -ENOMEM;
+
+	dev_hold(dev);
+
+	if ((dev->flags & IFF_UP) != IFF_UP) {
+		err = -ENETDOWN;
+		goto out;
+	}
+
+	nskb = skb_clone(skb, GFP_ATOMIC);
+	if (nskb) {
+		nskb->dev = dev;
+		err = dev_queue_xmit(nskb);
+		if (unlikely(err > 0))
+			err = net_xmit_errno(err);
+	}
+out:
+	dev_put(dev);
+	return err;
+}
+
+static const struct ethtool_ops nlmon_ethtool_ops = {
+	.get_link = always_on,
+};
+
+static const struct net_device_ops nlmon_ops = {
+	.ndo_init = nlmon_dev_init,
+	.ndo_uninit = nlmon_dev_uninit,
+	.ndo_start_xmit = nlmon_xmit,
+	.ndo_get_stats64 = nlmon_get_stats64,
+};
+
+static struct netlink_tap nlmon_tap __read_mostly = {
+	.func = nlmon_receive_skb,
+	.module = THIS_MODULE,
+};
+
+static void nlmon_setup(struct net_device *dev)
+{
+	dev->type = ARPHRD_NETLINK;
+	dev->tx_queue_len = 0;
+
+	dev->netdev_ops	= &nlmon_ops;
+	dev->ethtool_ops = &nlmon_ethtool_ops;
+	dev->destructor	= free_netdev;
+
+	dev->features = NETIF_F_FRAGLIST | NETIF_F_HIGHDMA;
+	dev->flags = IFF_NOARP;
+
+	/* That's rather a softlimit here, which, of course,
+	 * can be altered. Not a real MTU, but what is to be
+	 * expected in most cases.
+	 */
+	dev->mtu = NLMSG_GOODSIZE;
+}
+
+static __init int nlmon_register(void)
+{
+	int err;
+	struct net_device *nldev;
+
+	nldev = nlmon_tap.dev = alloc_netdev(0, "netlink", nlmon_setup);
+	if (unlikely(nldev == NULL))
+		return -ENOMEM;
+
+	err = register_netdev(nldev);
+	if (unlikely(err))
+		free_netdev(nldev);
+
+	return err;
+}
+
+static __exit void nlmon_unregister(void)
+{
+}
+
+module_init(nlmon_register);
+module_exit(nlmon_unregister);
+
+MODULE_LICENSE("GPL v2");
+MODULE_AUTHOR("Daniel Borkmann <dborkman@redhat.com>");
+MODULE_AUTHOR("Mathieu Geli <geli@enseirb.fr>");
+MODULE_DESCRIPTION("Netlink monitoring device");
-- 
1.7.11.7
