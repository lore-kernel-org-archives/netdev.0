From: Brenden Blanco <bblanco@plumgrid.com>
Subject: [RFC PATCH v2 2/5] net: add ndo to set bpf prog in adapter rx
Date: Thu,  7 Apr 2016 21:48:47 -0700
Message-ID: <1460090930-11219-2-git-send-email-bblanco@plumgrid.com>
References: <1460090930-11219-1-git-send-email-bblanco@plumgrid.com>
Cc: Brenden Blanco <bblanco@plumgrid.com>, netdev@vger.kernel.org,
	tom@herbertland.com, alexei.starovoitov@gmail.com,
	ogerlitz@mellanox.com, daniel@iogearbox.net, brouer@redhat.com,
	eric.dumazet@gmail.com, ecree@solarflare.com,
	john.fastabend@gmail.com, tgraf@suug.ch, johannes@sipsolutions.net,
	eranlinuxmellanox@gmail.com, lorenzo@google.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:34368 "EHLO
	mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754861AbcDHEs5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2016 00:48:57 -0400
Received: by mail-pf0-f177.google.com with SMTP id c20so69090758pfc.1
        for <netdev@vger.kernel.org>; Thu, 07 Apr 2016 21:48:56 -0700 (PDT)
In-Reply-To: <1460090930-11219-1-git-send-email-bblanco@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add two new set/get netdev ops for drivers implementing the
BPF_PROG_TYPE_PHYS_DEV filter.

Signed-off-by: Brenden Blanco <bblanco@plumgrid.com>
---
 include/linux/netdevice.h | 13 +++++++++++++
 net/core/dev.c            | 38 ++++++++++++++++++++++++++++++++++++++
 2 files changed, 51 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index cb4e508..3acf732 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -61,6 +61,7 @@ struct wireless_dev;
 /* 802.15.4 specific */
 struct wpan_dev;
 struct mpls_dev;
+struct bpf_prog;
 
 void netdev_set_default_ethtool_ops(struct net_device *dev,
 				    const struct ethtool_ops *ops);
@@ -1102,6 +1103,14 @@ struct tc_to_netdev {
  *	appropriate rx headroom value allows avoiding skb head copy on
  *	forward. Setting a negative value resets the rx headroom to the
  *	default value.
+ * int  (*ndo_bpf_set)(struct net_device *dev, struct bpf_prog *prog);
+ *	This function is used to set or clear a bpf program used in the
+ *	earliest stages of packet rx. The prog will have been loaded as
+ *	BPF_PROG_TYPE_PHYS_DEV. The callee is responsible for calling
+ *	bpf_prog_put on any old progs that are stored, but not on the passed
+ *	in prog.
+ * bool (*ndo_bpf_get)(struct net_device *dev);
+ *	This function is used to check if a bpf program is set on the device.
  *
  */
 struct net_device_ops {
@@ -1292,6 +1301,9 @@ struct net_device_ops {
 						       struct sk_buff *skb);
 	void			(*ndo_set_rx_headroom)(struct net_device *dev,
 						       int needed_headroom);
+	int			(*ndo_bpf_set)(struct net_device *dev,
+					       struct bpf_prog *prog);
+	bool			(*ndo_bpf_get)(struct net_device *dev);
 };
 
 /**
@@ -3251,6 +3263,7 @@ int dev_get_phys_port_id(struct net_device *dev,
 int dev_get_phys_port_name(struct net_device *dev,
 			   char *name, size_t len);
 int dev_change_proto_down(struct net_device *dev, bool proto_down);
+int dev_change_bpf_fd(struct net_device *dev, int fd);
 struct sk_buff *validate_xmit_skb_list(struct sk_buff *skb, struct net_device *dev);
 struct sk_buff *dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 				    struct netdev_queue *txq, int *ret);
diff --git a/net/core/dev.c b/net/core/dev.c
index 273f10d..7cf749c 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -94,6 +94,7 @@
 #include <linux/ethtool.h>
 #include <linux/notifier.h>
 #include <linux/skbuff.h>
+#include <linux/bpf.h>
 #include <net/net_namespace.h>
 #include <net/sock.h>
 #include <net/busy_poll.h>
@@ -6483,6 +6484,43 @@ int dev_change_proto_down(struct net_device *dev, bool proto_down)
 EXPORT_SYMBOL(dev_change_proto_down);
 
 /**
+ *	dev_change_bpf_fd - set or clear a bpf program for a device
+ *	@dev: device
+ *	@fd: new program fd or negative value to clear
+ *
+ *	Set or clear a bpf program for a device
+ */
+int dev_change_bpf_fd(struct net_device *dev, int fd)
+{
+	const struct net_device_ops *ops = dev->netdev_ops;
+	struct bpf_prog *prog = NULL;
+	int err;
+
+	if (!ops->ndo_bpf_set)
+		return -EOPNOTSUPP;
+	if (!netif_device_present(dev))
+		return -ENODEV;
+
+	if (fd >= 0) {
+		prog = bpf_prog_get(fd);
+		if (IS_ERR(prog))
+			return PTR_ERR(prog);
+
+		if (prog->type != BPF_PROG_TYPE_PHYS_DEV) {
+			bpf_prog_put(prog);
+			return -EINVAL;
+		}
+	}
+
+	err = ops->ndo_bpf_set(dev, prog);
+	if (err < 0 && prog)
+		bpf_prog_put(prog);
+
+	return err;
+}
+EXPORT_SYMBOL(dev_change_bpf_fd);
+
+/**
  *	dev_new_index	-	allocate an ifindex
  *	@net: the applicable net namespace
  *
-- 
2.8.0
