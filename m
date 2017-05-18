From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [RFC net-next PATCH 3/5] net: introduce XDP driver features
 interface
Date: Thu, 18 May 2017 17:41:43 +0200
Message-ID: <149512210317.14733.15039298820296846614.stgit@firesoul>
References: <149512205297.14733.15729847433404265933.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.r.fastabend@intel.com>,
        netdev@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>
To: Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58204 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933838AbdERPlv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 18 May 2017 11:41:51 -0400
In-Reply-To: <149512205297.14733.15729847433404265933.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a fundamental difference between normal eBPF programs
and (XDP) eBPF programs getting attached in a driver. For normal
eBPF programs it is easy to add a new bpf feature, like a bpf
helper, because is it strongly tied to the feature being
available in the current core kernel code.  When drivers invoke a
bpf_prog, then it is not sufficient to simply relying on whether
a bpf_helper exists or not.  When a driver haven't implemented a
given feature yet, then it is possible to expose uninitialized
parts of xdp_buff.  The driver pass in a pointer to xdp_buff,
usually "allocated" on the stack, which must not be exposed.

Only two user visible NETIF_F_XDP_* net_device feature flags are
exposed via ethtool (-k) seen as "xdp" and "xdp-partial".
The "xdp-partial" is detected when there is not feature equality
between kernel and driver, and a netdev_warn is given.

The idea is that XDP_DRV_* feature bits define a contract between
the driver and the kernel, giving a reliable way to know that XDP
features a driver promised to implement. Thus, knowing what bpf
side features are safe to allow.

There are 3 levels of features: "required", "devel" and "optional".

The motivation is pushing driver vendors forward to support all
the new XDP features.  Once a given feature bit is moved into
the "required" features, the kernel will reject loading XDP
program if feature isn't implemented by driver.  Features under
developement, require help from the bpf infrastrucure to detect
when a given helper or direct-access is used, using a bpf_prog
bit to mark a need for the feature, and pulling in this bit in
the xdp_features_check().  When all drivers have implemented
a "devel" feature, it can be moved to the "required" feature and
the bpf_prog bit can be refurbished. The "optional" features are
for things that are handled safely runtime, but drivers will
still get flagged as "xdp-partial" if not implementing those.
---
 include/linux/netdev_features.h |   32 ++++++++++++++++++++++++++++++++
 include/linux/netdevice.h       |    1 +
 net/core/dev.c                  |   34 ++++++++++++++++++++++++++++++++++
 net/core/ethtool.c              |    2 ++
 4 files changed, 69 insertions(+)

diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
index 1d4737cffc71..ff81ee231410 100644
--- a/include/linux/netdev_features.h
+++ b/include/linux/netdev_features.h
@@ -77,6 +77,8 @@ enum {
 	NETIF_F_HW_ESP_BIT,		/* Hardware ESP transformation offload */
 	NETIF_F_HW_ESP_TX_CSUM_BIT,	/* ESP with TX checksum offload */
 
+	NETIF_F_XDP_BASELINE_BIT,	/* Driver supports XDP */
+	NETIF_F_XDP_PARTIAL_BIT,	/* not supporting all XDP features */
 	/*
 	 * Add your fresh new feature above and remember to update
 	 * netdev_features_strings[] in net/core/ethtool.c and maybe
@@ -140,6 +142,8 @@ enum {
 #define NETIF_F_HW_TC		__NETIF_F(HW_TC)
 #define NETIF_F_HW_ESP		__NETIF_F(HW_ESP)
 #define NETIF_F_HW_ESP_TX_CSUM	__NETIF_F(HW_ESP_TX_CSUM)
+#define NETIF_F_XDP_BASELINE	__NETIF_F(XDP_BASELINE)
+#define NETIF_F_XDP_PARTIAL	__NETIF_F(XDP_PARTIAL)
 
 #define for_each_netdev_feature(mask_addr, bit)	\
 	for_each_set_bit(bit, (unsigned long *)mask_addr, NETDEV_FEATURE_COUNT)
@@ -212,4 +216,32 @@ enum {
 				 NETIF_F_GSO_UDP_TUNNEL |		\
 				 NETIF_F_GSO_UDP_TUNNEL_CSUM)
 
+/* XDP driver flags */
+enum {
+	XDP_DRV_F_ENABLED_BIT,
+};
+
+#define __XDP_DRV_F_BIT(bit)	((netdev_features_t)1 << (bit))
+#define __XDP_DRV_F(name)	__XDP_DRV_F_BIT(XDP_DRV_F_##name##_BIT)
+#define XDP_DRV_F_ENABLED	__XDP_DRV_F(ENABLED)
+
+/* XDP driver MUST support these features, else kernel MUST reject
+ * bpf_prog to guarantee safe access to data structures
+ */
+#define XDP_DRV_FEATURES_REQUIRED	XDP_DRV_F_ENABLED
+
+/* Some XDP features are under development. Based on bpf_prog loading
+ * detect if kernel feature can be activated.
+ */
+#define XDP_DRV_FEATURES_DEVEL		0
+
+/* Some XDP features are optional, like action return code, as they
+ * are handled safely runtime.
+ */
+#define XDP_DRV_FEATURES_OPTIONAL	0
+
+#define XDP_DRV_FEATURES_MASK		(XDP_DRV_FEATURES_REQUIRED |	\
+					 XDP_DRV_FEATURES_DEVEL |	\
+					 XDP_DRV_FEATURES_OPTIONAL)
+
 #endif	/* _LINUX_NETDEV_FEATURES_H */
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 9c23bd2efb56..329ae156ff65 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1685,6 +1685,7 @@ struct net_device {
 	netdev_features_t	hw_enc_features;
 	netdev_features_t	mpls_features;
 	netdev_features_t	gso_partial_features;
+	netdev_features_t	xdp_features;
 
 	int			ifindex;
 	int			group;
diff --git a/net/core/dev.c b/net/core/dev.c
index 35a06cebb282..b4af5fbbd9da 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6851,6 +6851,25 @@ int dev_change_proto_down(struct net_device *dev, bool proto_down)
 }
 EXPORT_SYMBOL(dev_change_proto_down);
 
+bool xdp_features_check(struct net_device *dev, struct bpf_prog *xdp_prog,
+			struct netlink_ext_ack *extack, u32 flags)
+{
+	netdev_features_t req_features = XDP_DRV_FEATURES_REQUIRED;
+	netdev_features_t dev_xdp_features;
+
+	/* Generic XDP naturally support all features */
+	if (flags & XDP_FLAGS_SKB_MODE)
+		return true;
+
+	dev_xdp_features = dev->xdp_features & XDP_DRV_FEATURES_MASK;
+	if (req_features & ~dev_xdp_features) {
+		NL_SET_ERR_MSG(extack,
+			       "Required XDP feature not supported by device");
+		return false;
+	}
+	return true;
+}
+
 /**
  *	dev_change_xdp_fd - set or clear a bpf program for a device rx path
  *	@dev: device
@@ -6890,6 +6909,11 @@ int dev_change_xdp_fd(struct net_device *dev, struct netlink_ext_ack *extack,
 		prog = bpf_prog_get_type(fd, BPF_PROG_TYPE_XDP);
 		if (IS_ERR(prog))
 			return PTR_ERR(prog);
+
+		if (!xdp_features_check(dev, prog, extack, flags)) {
+			bpf_prog_put(prog);
+			return -EOPNOTSUPP;
+		}
 	}
 
 	memset(&xdp, 0, sizeof(xdp));
@@ -7402,6 +7426,16 @@ int register_netdevice(struct net_device *dev)
 	dev->features |= NETIF_F_SOFT_FEATURES;
 	dev->wanted_features = dev->features & dev->hw_features;
 
+	/* Transfer XDP features and detect mismatch */
+	if (dev->netdev_ops->ndo_xdp) {
+		dev->xdp_features |= XDP_DRV_F_ENABLED;
+		dev->features     |= NETIF_F_XDP_BASELINE;
+		if (dev->xdp_features ^ XDP_DRV_FEATURES_MASK) {
+			netdev_warn(dev, "Partial XDP support in driver\n");
+			dev->features |= NETIF_F_XDP_PARTIAL;
+		}
+	}
+
 	if (!(dev->flags & IFF_LOOPBACK))
 		dev->hw_features |= NETIF_F_NOCACHE_COPY;
 
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 03111a2d6653..d283cdc9ee25 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -106,6 +106,8 @@ static const char netdev_features_strings[NETDEV_FEATURE_COUNT][ETH_GSTRING_LEN]
 	[NETIF_F_HW_TC_BIT] =		 "hw-tc-offload",
 	[NETIF_F_HW_ESP_BIT] =		 "esp-hw-offload",
 	[NETIF_F_HW_ESP_TX_CSUM_BIT] =	 "esp-tx-csum-hw-offload",
+	[NETIF_F_XDP_BASELINE_BIT] =	 "xdp",
+	[NETIF_F_XDP_PARTIAL_BIT] =	 "xdp-partial", /* "xdp-challenged"? */
 };
 
 static const char
