From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: [PATCH v3 2/3] VSOCK: Add vsockmon device
Date: Wed, 12 Apr 2017 17:08:24 +0100
Message-ID: <20170412160825.21037-3-stefanha@redhat.com>
References: <20170412160825.21037-1-stefanha@redhat.com>
Cc: Zhu Yanjun <zyjzyj2000@gmail.com>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Gerard Garcia <ggarcia@abra.uab.cat>,
        Jorgen Hansen <jhansen@vmware.com>,
        Stefan Hajnoczi <stefanha@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48958 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752888AbdDLQJS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 12 Apr 2017 12:09:18 -0400
In-Reply-To: <20170412160825.21037-1-stefanha@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerard Garcia <ggarcia@deic.uab.cat>

Add vsockmon virtual network device that receives packets from the vsock
transports and exposes them to user space.

Based on the nlmon device.

Signed-off-by: Gerard Garcia <ggarcia@deic.uab.cat>
Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
---
v3:
 * Fix DEFAULT_MTU macro definition [Zhu Yanjun]
 * Rename af_vsockmon_hdr->t field ->transport for clarity
 * Update .ndo_get_stats64() return type since it has changed
---
 drivers/net/Makefile          |   1 +
 include/uapi/linux/vsockmon.h |  57 ++++++++++++++
 drivers/net/vsockmon.c        | 167 ++++++++++++++++++++++++++++++++++++++++++
 drivers/net/Kconfig           |   8 ++
 include/uapi/linux/Kbuild     |   1 +
 5 files changed, 234 insertions(+)
 create mode 100644 include/uapi/linux/vsockmon.h
 create mode 100644 drivers/net/vsockmon.c

diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 98ed4d9..2d54930 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -30,6 +30,7 @@ obj-$(CONFIG_GENEVE) += geneve.o
 obj-$(CONFIG_GTP) += gtp.o
 obj-$(CONFIG_NLMON) += nlmon.o
 obj-$(CONFIG_NET_VRF) += vrf.o
+obj-$(CONFIG_VSOCKMON) += vsockmon.o
 
 #
 # Networking Drivers
diff --git a/include/uapi/linux/vsockmon.h b/include/uapi/linux/vsockmon.h
new file mode 100644
index 0000000..484e59e
--- /dev/null
+++ b/include/uapi/linux/vsockmon.h
@@ -0,0 +1,57 @@
+#ifndef _UAPI_VSOCKMON_H
+#define _UAPI_VSOCKMON_H
+
+#include <linux/virtio_vsock.h>
+
+/*
+ * vsockmon is the AF_VSOCK packet capture device.  Packets captured have the
+ * following layout:
+ *
+ *   +-----------------------------------+
+ *   |           vsockmon header         |
+ *   |      (struct af_vsockmon_hdr)     |
+ *   +-----------------------------------+
+ *   |          transport header         |
+ *   | (af_vsockmon_hdr->len bytes long) |
+ *   +-----------------------------------+
+ *   |              payload              |
+ *   |       (until end of packet)       |
+ *   +-----------------------------------+
+ *
+ * The vsockmon header is a transport-independent description of the packet.
+ * It duplicates some of the information from the transport header so that
+ * no transport-specific knowledge is necessary to process packets.
+ *
+ * The transport header is useful for low-level transport-specific packet
+ * analysis.  Transport type is given in af_vsockmon_hdr->transport and
+ * transport header length is given in af_vsockmon_hdr->len.
+ *
+ * If af_vsockmon_hdr->op is AF_VSOCK_OP_PAYLOAD then the payload follows the
+ * transport header.  Other ops do not have a payload.
+ */
+
+struct af_vsockmon_hdr {
+	__le64 src_cid;
+	__le64 dst_cid;
+	__le32 src_port;
+	__le32 dst_port;
+	__le16 op;			/* enum af_vsockmon_op */
+	__le16 transport;		/* enum af_vsockmon_transport */
+	__le16 len;			/* Transport header length */
+} __attribute__((packed));
+
+enum af_vsockmon_op {
+	AF_VSOCK_OP_UNKNOWN = 0,
+	AF_VSOCK_OP_CONNECT = 1,
+	AF_VSOCK_OP_DISCONNECT = 2,
+	AF_VSOCK_OP_CONTROL = 3,
+	AF_VSOCK_OP_PAYLOAD = 4,
+};
+
+enum af_vsockmon_transport {
+	AF_VSOCK_TRANSPORT_UNKNOWN = 0,
+	AF_VSOCK_TRANSPORT_NO_INFO = 1,	/* No transport information */
+	AF_VSOCK_TRANSPORT_VIRTIO = 2,	/* Virtio transport header (struct virtio_vsock_hdr) */
+};
+
+#endif
diff --git a/drivers/net/vsockmon.c b/drivers/net/vsockmon.c
new file mode 100644
index 0000000..0bff1e9
--- /dev/null
+++ b/drivers/net/vsockmon.c
@@ -0,0 +1,167 @@
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/if_arp.h>
+#include <net/rtnetlink.h>
+#include <net/sock.h>
+#include <net/af_vsock.h>
+#include <uapi/linux/vsockmon.h>
+#include <linux/virtio_vsock.h>
+
+/* Virtio transport max packet size plus header */
+#define DEFAULT_MTU (VIRTIO_VSOCK_MAX_PKT_BUF_SIZE + \
+		     sizeof(struct af_vsockmon_hdr))
+
+struct pcpu_lstats {
+	u64 rx_packets;
+	u64 rx_bytes;
+	struct u64_stats_sync syncp;
+};
+
+static int vsockmon_dev_init(struct net_device *dev)
+{
+	dev->lstats = netdev_alloc_pcpu_stats(struct pcpu_lstats);
+	return dev->lstats == NULL ? -ENOMEM : 0;
+}
+
+static void vsockmon_dev_uninit(struct net_device *dev)
+{
+	free_percpu(dev->lstats);
+}
+
+struct vsockmon {
+	struct vsock_tap vt;
+};
+
+static int vsockmon_open(struct net_device *dev)
+{
+	struct vsockmon *vsockmon = netdev_priv(dev);
+
+	vsockmon->vt.dev = dev;
+	vsockmon->vt.module = THIS_MODULE;
+	return vsock_add_tap(&vsockmon->vt);
+}
+
+static int vsockmon_close(struct net_device *dev) {
+	struct vsockmon *vsockmon = netdev_priv(dev);
+
+	return vsock_remove_tap(&vsockmon->vt);
+}
+
+static netdev_tx_t vsockmon_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	int len = skb->len;
+	struct pcpu_lstats *stats = this_cpu_ptr(dev->lstats);
+
+	u64_stats_update_begin(&stats->syncp);
+	stats->rx_bytes += len;
+	stats->rx_packets++;
+	u64_stats_update_end(&stats->syncp);
+
+	dev_kfree_skb(skb);
+
+	return NETDEV_TX_OK;
+}
+
+static void
+vsockmon_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
+{
+	int i;
+	u64 bytes = 0, packets = 0;
+
+	for_each_possible_cpu(i) {
+		const struct pcpu_lstats *vstats;
+		u64 tbytes, tpackets;
+		unsigned int start;
+
+		vstats = per_cpu_ptr(dev->lstats, i);
+
+		do {
+			start = u64_stats_fetch_begin_irq(&vstats->syncp);
+			tbytes = vstats->rx_bytes;
+			tpackets = vstats->rx_packets;
+		} while (u64_stats_fetch_retry_irq(&vstats->syncp, start));
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
+}
+
+static int vsockmon_is_valid_mtu(int new_mtu)
+{
+	return new_mtu >= (int) sizeof(struct af_vsockmon_hdr);
+}
+
+static int vsockmon_change_mtu(struct net_device *dev, int new_mtu)
+{
+	if (!vsockmon_is_valid_mtu(new_mtu))
+		return -EINVAL;
+
+	dev->mtu = new_mtu;
+	return 0;
+}
+
+static const struct net_device_ops vsockmon_ops = {
+	.ndo_init = vsockmon_dev_init,
+	.ndo_uninit = vsockmon_dev_uninit,
+	.ndo_open = vsockmon_open,
+	.ndo_stop = vsockmon_close,
+	.ndo_start_xmit = vsockmon_xmit,
+	.ndo_get_stats64 = vsockmon_get_stats64,
+	.ndo_change_mtu = vsockmon_change_mtu,
+};
+
+static u32 always_on(struct net_device *dev)
+{
+	return 1;
+}
+
+static const struct ethtool_ops vsockmon_ethtool_ops = {
+	.get_link = always_on,
+};
+
+static void vsockmon_setup(struct net_device *dev)
+{
+	dev->type = ARPHRD_VSOCKMON;
+	dev->priv_flags |= IFF_NO_QUEUE;
+
+	dev->netdev_ops	= &vsockmon_ops;
+	dev->ethtool_ops = &vsockmon_ethtool_ops;
+	dev->destructor	= free_netdev;
+
+	dev->features = NETIF_F_SG | NETIF_F_FRAGLIST |
+			NETIF_F_HIGHDMA | NETIF_F_LLTX;
+
+	dev->flags = IFF_NOARP;
+
+	dev->mtu = DEFAULT_MTU;
+}
+
+static struct rtnl_link_ops vsockmon_link_ops __read_mostly = {
+	.kind			= "vsockmon",
+	.priv_size		= sizeof(struct vsockmon),
+	.setup			= vsockmon_setup,
+};
+
+static __init int vsockmon_register(void)
+{
+	return rtnl_link_register(&vsockmon_link_ops);
+}
+
+static __exit void vsockmon_unregister(void)
+{
+	rtnl_link_unregister(&vsockmon_link_ops);
+}
+
+module_init(vsockmon_register);
+module_exit(vsockmon_unregister);
+
+MODULE_LICENSE("GPL v2");
+MODULE_AUTHOR("Gerard Garcia <ggarcia@deic.uab.cat>");
+MODULE_DESCRIPTION("Vsock monitoring device. Based on nlmon device.");
+MODULE_ALIAS_RTNL_LINK("vsockmon");
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 100fbdc..83a1616 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -355,6 +355,14 @@ config NET_VRF
 	  This option enables the support for mapping interfaces into VRF's. The
 	  support enables VRF devices.
 
+config VSOCKMON
+    tristate "Virtual vsock monitoring device"
+    depends on VHOST_VSOCK
+    ---help---
+     This option enables a monitoring net device for vsock sockets. It is
+     mostly intended for developers or support to debug vsock issues. If
+     unsure, say N.
+
 endif # NET_CORE
 
 config SUNGEM_PHY
diff --git a/include/uapi/linux/Kbuild b/include/uapi/linux/Kbuild
index dd9820b..9165e87 100644
--- a/include/uapi/linux/Kbuild
+++ b/include/uapi/linux/Kbuild
@@ -476,6 +476,7 @@ header-y += virtio_types.h
 header-y += virtio_vsock.h
 header-y += virtio_crypto.h
 header-y += vm_sockets.h
+header-y += vsockmon.h
 header-y += vt.h
 header-y += vtpm_proxy.h
 header-y += wait.h
-- 
2.9.3
