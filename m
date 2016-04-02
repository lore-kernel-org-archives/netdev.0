From: Brenden Blanco <bblanco@plumgrid.com>
Subject: [RFC PATCH 2/5] net: add ndo to set bpf prog in adapter rx
Date: Fri,  1 Apr 2016 18:21:55 -0700
Message-ID: <1459560118-5582-3-git-send-email-bblanco@plumgrid.com>
References: <1459560118-5582-1-git-send-email-bblanco@plumgrid.com>
Cc: Brenden Blanco <bblanco@plumgrid.com>, netdev@vger.kernel.org,
	tom@herbertland.com, alexei.starovoitov@gmail.com,
	gerlitz@mellanox.com, daniel@iogearbox.net,
	john.fastabend@gmail.com, brouer@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:36519 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757046AbcDBBWO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2016 21:22:14 -0400
Received: by mail-pa0-f42.google.com with SMTP id tt10so102625768pab.3
        for <netdev@vger.kernel.org>; Fri, 01 Apr 2016 18:22:13 -0700 (PDT)
In-Reply-To: <1459560118-5582-1-git-send-email-bblanco@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a new netdev op for drivers implementing the BPF_PROG_TYPE_PHYS_DEV
filter to get configuration. Since the fd is only used by the driver to
fetch the prog, the netdev should just keep a bit to indicate the
program is valid.

Signed-off-by: Brenden Blanco <bblanco@plumgrid.com>
---
 include/linux/netdevice.h |  8 ++++++++
 net/core/dev.c            | 12 ++++++++++++
 2 files changed, 20 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index cb0d5d0..c46e2e3 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1102,6 +1102,11 @@ struct tc_to_netdev {
  *	appropriate rx headroom value allows avoiding skb head copy on
  *	forward. Setting a negative value resets the rx headroom to the
  *	default value.
+ * int  (*ndo_bpf_set)(struct net_device *dev, int fd);
+ *	This function is used to set or clear a bpf program used in the
+ *	earliest stages of packet rx. The fd must be a program loaded as
+ *	BPF_PROG_TYPE_PHYS_DEV. Negative values of fd indicate the program
+ *	should be removed.
  *
  */
 struct net_device_ops {
@@ -1292,6 +1297,7 @@ struct net_device_ops {
 						       struct sk_buff *skb);
 	void			(*ndo_set_rx_headroom)(struct net_device *dev,
 						       int needed_headroom);
+	int			(*ndo_bpf_set)(struct net_device *dev, int fd);
 };
 
 /**
@@ -1875,6 +1881,7 @@ struct net_device {
 	struct phy_device	*phydev;
 	struct lock_class_key	*qdisc_tx_busylock;
 	bool			proto_down;
+	bool			bpf_valid;
 };
 #define to_net_dev(d) container_of(d, struct net_device, dev)
 
@@ -3268,6 +3275,7 @@ int dev_get_phys_port_id(struct net_device *dev,
 int dev_get_phys_port_name(struct net_device *dev,
 			   char *name, size_t len);
 int dev_change_proto_down(struct net_device *dev, bool proto_down);
+int dev_change_bpf_fd(struct net_device *dev, int fd);
 struct sk_buff *validate_xmit_skb_list(struct sk_buff *skb, struct net_device *dev);
 struct sk_buff *dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 				    struct netdev_queue *txq, int *ret);
diff --git a/net/core/dev.c b/net/core/dev.c
index b9bcbe7..eb93414 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6480,6 +6480,18 @@ int dev_change_proto_down(struct net_device *dev, bool proto_down)
 }
 EXPORT_SYMBOL(dev_change_proto_down);
 
+int dev_change_bpf_fd(struct net_device *dev, int fd)
+{
+	const struct net_device_ops *ops = dev->netdev_ops;
+
+	if (!ops->ndo_bpf_set)
+		return -EOPNOTSUPP;
+	if (!netif_device_present(dev))
+		return -ENODEV;
+	return ops->ndo_bpf_set(dev, fd);
+}
+EXPORT_SYMBOL(dev_change_bpf_fd);
+
 /**
  *	dev_new_index	-	allocate an ifindex
  *	@net: the applicable net namespace
-- 
2.8.0
