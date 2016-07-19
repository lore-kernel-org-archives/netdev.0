From: Brenden Blanco <bblanco@plumgrid.com>
Subject: [PATCH v10 03/12] net: add ndo to setup/query xdp prog in adapter rx
Date: Tue, 19 Jul 2016 12:16:48 -0700
Message-ID: <1468955817-10604-4-git-send-email-bblanco@plumgrid.com>
References: <1468955817-10604-1-git-send-email-bblanco@plumgrid.com>
Cc: Brenden Blanco <bblanco@plumgrid.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Saeed Mahameed <saeedm@dev.mellanox.co.il>,
	Martin KaFai Lau <kafai@fb.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Ari Saha <as754m@att.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Or Gerlitz <gerlitz.or@gmail.com>, john.fastabend@gmail.com,
	hannes@stressinduktion.org, Thomas Graf <tgraf@suug.ch>,
	Tom Herbert <tom@herbertland.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Tariq Toukan <ttoukan.linux@gmail.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:35104 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751864AbcGSTR0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2016 15:17:26 -0400
Received: by mail-pa0-f48.google.com with SMTP id iw10so9699320pac.2
        for <netdev@vger.kernel.org>; Tue, 19 Jul 2016 12:17:26 -0700 (PDT)
In-Reply-To: <1468955817-10604-1-git-send-email-bblanco@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add one new netdev op for drivers implementing the BPF_PROG_TYPE_XDP
filter. The single op is used for both setup/query of the xdp program,
modelled after ndo_setup_tc.

Signed-off-by: Brenden Blanco <bblanco@plumgrid.com>
---
 include/linux/netdevice.h | 34 ++++++++++++++++++++++++++++++++++
 net/core/dev.c            | 33 +++++++++++++++++++++++++++++++++
 2 files changed, 67 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 49736a3..fab9a1c 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -63,6 +63,7 @@ struct wpan_dev;
 struct mpls_dev;
 /* UDP Tunnel offloads */
 struct udp_tunnel_info;
+struct bpf_prog;
 
 void netdev_set_default_ethtool_ops(struct net_device *dev,
 				    const struct ethtool_ops *ops);
@@ -799,6 +800,33 @@ struct tc_to_netdev {
 	};
 };
 
+/* These structures hold the attributes of xdp state that are being passed
+ * to the netdevice through the xdp op.
+ */
+enum xdp_netdev_command {
+	/* Set or clear a bpf program used in the earliest stages of packet
+	 * rx. The prog will have been loaded as BPF_PROG_TYPE_XDP. The callee
+	 * is responsible for calling bpf_prog_put on any old progs that are
+	 * stored. In case of error, the callee need not release the new prog
+	 * reference, but on success it takes ownership and must bpf_prog_put
+	 * when it is no longer used.
+	 */
+	XDP_SETUP_PROG,
+	/* Check if a bpf program is set on the device.  The callee should
+	 * return true if a program is currently attached and running.
+	 */
+	XDP_QUERY_PROG,
+};
+
+struct netdev_xdp {
+	enum xdp_netdev_command command;
+	union {
+		/* XDP_SETUP_PROG */
+		struct bpf_prog *prog;
+		/* XDP_QUERY_PROG */
+		bool prog_attached;
+	};
+};
 
 /*
  * This structure defines the management hooks for network devices.
@@ -1087,6 +1115,9 @@ struct tc_to_netdev {
  *	appropriate rx headroom value allows avoiding skb head copy on
  *	forward. Setting a negative value resets the rx headroom to the
  *	default value.
+ * int (*ndo_xdp)(struct net_device *dev, struct netdev_xdp *xdp);
+ *	This function is used to set or query state related to XDP on the
+ *	netdevice. See definition of enum xdp_netdev_command for details.
  *
  */
 struct net_device_ops {
@@ -1271,6 +1302,8 @@ struct net_device_ops {
 						       struct sk_buff *skb);
 	void			(*ndo_set_rx_headroom)(struct net_device *dev,
 						       int needed_headroom);
+	int			(*ndo_xdp)(struct net_device *dev,
+					   struct netdev_xdp *xdp);
 };
 
 /**
@@ -3257,6 +3290,7 @@ int dev_get_phys_port_id(struct net_device *dev,
 int dev_get_phys_port_name(struct net_device *dev,
 			   char *name, size_t len);
 int dev_change_proto_down(struct net_device *dev, bool proto_down);
+int dev_change_xdp_fd(struct net_device *dev, int fd);
 struct sk_buff *validate_xmit_skb_list(struct sk_buff *skb, struct net_device *dev);
 struct sk_buff *dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 				    struct netdev_queue *txq, int *ret);
diff --git a/net/core/dev.c b/net/core/dev.c
index 7894e40..2a9c39f 100644
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
@@ -6615,6 +6616,38 @@ int dev_change_proto_down(struct net_device *dev, bool proto_down)
 EXPORT_SYMBOL(dev_change_proto_down);
 
 /**
+ *	dev_change_xdp_fd - set or clear a bpf program for a device rx path
+ *	@dev: device
+ *	@fd: new program fd or negative value to clear
+ *
+ *	Set or clear a bpf program for a device
+ */
+int dev_change_xdp_fd(struct net_device *dev, int fd)
+{
+	const struct net_device_ops *ops = dev->netdev_ops;
+	struct bpf_prog *prog = NULL;
+	struct netdev_xdp xdp = {};
+	int err;
+
+	if (!ops->ndo_xdp)
+		return -EOPNOTSUPP;
+	if (fd >= 0) {
+		prog = bpf_prog_get_type(fd, BPF_PROG_TYPE_XDP);
+		if (IS_ERR(prog))
+			return PTR_ERR(prog);
+	}
+
+	xdp.command = XDP_SETUP_PROG;
+	xdp.prog = prog;
+	err = ops->ndo_xdp(dev, &xdp);
+	if (err < 0 && prog)
+		bpf_prog_put(prog);
+
+	return err;
+}
+EXPORT_SYMBOL(dev_change_xdp_fd);
+
+/**
  *	dev_new_index	-	allocate an ifindex
  *	@net: the applicable net namespace
  *
-- 
2.8.2
