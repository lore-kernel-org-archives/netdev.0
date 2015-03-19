From: Robert Shearman <rshearma@brocade.com>
Subject: [PATCH net-next 4/5] mpls: Per-device enabling of packet forwarding
Date: Thu, 19 Mar 2015 21:32:51 +0000
Message-ID: <1426800772-22378-5-git-send-email-rshearma@brocade.com>
References: <1426800772-22378-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Robert Shearman <rshearma@brocade.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:32728 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750932AbbCSVen (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2015 17:34:43 -0400
In-Reply-To: <1426800772-22378-1-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

An MPLS network is a single trust domain where the edges must be in
control of what labels make their way into the core. The simplest way
of ensuring for the edge device to always impose the labels, and not
allow forward labeled traffic from untrusted neighbours. This is
achieved by allowing a per-device configuration of whether MPLS
traffic received over that interface should be forwarded or not.

To be secure by default, MPLS is now intially disabled on all
interfaces (except the loopback) until explicitly enabled and no
global option is provided to change the default. Whilst this differs
from other protocols (e.g. IPv6), network operators are used to
explicitly enabling MPLS forwarding on interfaces, and with the number
of links to the MPLS core typically fairly low this doesn't present
too much of a burden on operators.

Cc: "Eric W. Biederman" <ebiederm@xmission.com>
Signed-off-by: Robert Shearman <rshearma@brocade.com>
---
 Documentation/networking/mpls-sysctl.txt |   9 +++
 include/linux/netdevice.h                |   4 ++
 net/mpls/af_mpls.c                       | 115 ++++++++++++++++++++++++++++++-
 net/mpls/internal.h                      |   6 ++
 4 files changed, 133 insertions(+), 1 deletion(-)

diff --git a/Documentation/networking/mpls-sysctl.txt b/Documentation/networking/mpls-sysctl.txt
index 639ddf0..f48772c 100644
--- a/Documentation/networking/mpls-sysctl.txt
+++ b/Documentation/networking/mpls-sysctl.txt
@@ -18,3 +18,12 @@ platform_labels - INTEGER
 
 	Possible values: 0 - 1048575
 	Default: 0
+
+conf/<interface>/forwarding - BOOL
+	Forward packets received on this interface.
+
+	If disabled, packets will be discarded without further
+	processing.
+
+	0 - disabled (default)
+	not 0 - enabled
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 76951c5..ee4ca06 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -60,6 +60,7 @@ struct phy_device;
 struct wireless_dev;
 /* 802.15.4 specific */
 struct wpan_dev;
+struct mpls_dev;
 
 void netdev_set_default_ethtool_ops(struct net_device *dev,
 				    const struct ethtool_ops *ops);
@@ -1615,6 +1616,9 @@ struct net_device {
 	void			*ax25_ptr;
 	struct wireless_dev	*ieee80211_ptr;
 	struct wpan_dev		*ieee802154_ptr;
+#if IS_ENABLED(CONFIG_MPLS_ROUTING)
+	struct mpls_dev __rcu	*mpls_ptr;
+#endif
 
 /*
  * Cache lines mostly used on receive path (including eth_type_trans())
diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index e3586a7..14c7e76 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -54,6 +54,11 @@ static struct mpls_route *mpls_route_input_rcu(struct net *net, unsigned index)
 	return rt;
 }
 
+static inline struct mpls_dev *mpls_dev_get(const struct net_device *dev)
+{
+	return rcu_dereference_rtnl(dev->mpls_ptr);
+}
+
 static bool mpls_output_possible(const struct net_device *dev)
 {
 	return dev && (dev->flags & IFF_UP) && netif_carrier_ok(dev);
@@ -137,6 +142,7 @@ static int mpls_forward(struct sk_buff *skb, struct net_device *dev,
 	struct mpls_route *rt;
 	struct mpls_entry_decoded dec;
 	struct net_device *out_dev;
+	struct mpls_dev *mdev;
 	unsigned int hh_len;
 	unsigned int new_header_size;
 	unsigned int mtu;
@@ -144,6 +150,10 @@ static int mpls_forward(struct sk_buff *skb, struct net_device *dev,
 
 	/* Careful this entire function runs inside of an rcu critical section */
 
+	mdev = mpls_dev_get(dev);
+	if (!mdev || !mdev->fwd_enabled)
+		goto drop;
+
 	if (skb->pkt_type != PACKET_HOST)
 		goto drop;
 
@@ -440,10 +450,96 @@ errout:
 	return err;
 }
 
+#define MPLS_PERDEV_SYSCTL_OFFSET(field)	\
+	(&((struct mpls_dev *)0)->field)
+
+static const struct ctl_table mpls_dev_table[] = {
+	{
+		.procname	= "forwarding",
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+		.data		= MPLS_PERDEV_SYSCTL_OFFSET(fwd_enabled),
+	},
+	{ }
+};
+
+static int mpls_dev_sysctl_register(struct net_device *dev,
+				    struct mpls_dev *mdev)
+{
+	char path[sizeof("net/mpls/conf/") + IFNAMSIZ];
+	struct ctl_table *table;
+	int i;
+
+	table = kmemdup(&mpls_dev_table, sizeof(mpls_dev_table), GFP_KERNEL);
+	if (!table)
+		goto out;
+
+	/* Table data contains only offsets relative to the base of
+	 * the mdev at this point, so make them absolute.
+	 */
+	for (i = 0; i < ARRAY_SIZE(mpls_dev_table); i++)
+		table[i].data = (char *)mdev + (uintptr_t)table[i].data;
+
+	snprintf(path, sizeof(path), "net/mpls/conf/%s", dev->name);
+
+	mdev->sysctl = register_net_sysctl(dev_net(dev), path, table);
+	if (!mdev->sysctl)
+		goto free;
+
+	return 0;
+
+free:
+	kfree(table);
+out:
+	return -ENOBUFS;
+}
+
+static void mpls_dev_sysctl_unregister(struct mpls_dev *mdev)
+{
+	struct ctl_table *table;
+
+	table = mdev->sysctl->ctl_table_arg;
+	unregister_net_sysctl_table(mdev->sysctl);
+	kfree(table);
+}
+
+static struct mpls_dev *mpls_add_dev(struct net_device *dev)
+{
+	struct mpls_dev *mdev;
+	int err = -ENOMEM;
+
+	ASSERT_RTNL();
+
+	mdev = kzalloc(sizeof(*mdev), GFP_KERNEL);
+	if (!mdev)
+		return ERR_PTR(err);
+
+	/* Enable MPLS by default on loopback devices, since this
+	 * doesn't represent a security boundary and is required for the
+	 * lookup of inner labels for LSPs terminating on this router.
+	 */
+	if (dev->flags & IFF_LOOPBACK)
+		mdev->fwd_enabled = 1;
+
+	err = mpls_dev_sysctl_register(dev, mdev);
+	if (err)
+		goto free;
+
+	rcu_assign_pointer(dev->mpls_ptr, mdev);
+
+	return mdev;
+
+free:
+	kfree(mdev);
+	return ERR_PTR(err);
+}
+
 static void mpls_ifdown(struct net_device *dev)
 {
 	struct mpls_route __rcu **platform_label;
 	struct net *net = dev_net(dev);
+	struct mpls_dev *mdev;
 	unsigned index;
 
 	platform_label = rtnl_dereference(net->mpls.platform_label);
@@ -455,14 +551,31 @@ static void mpls_ifdown(struct net_device *dev)
 			continue;
 		rt->rt_dev = NULL;
 	}
+
+	mdev = mpls_dev_get(dev);
+	if (!mdev)
+		return;
+
+	mpls_dev_sysctl_unregister(mdev);
+
+	RCU_INIT_POINTER(dev->mpls_ptr, NULL);
+
+	kfree(mdev);
 }
 
 static int mpls_dev_notify(struct notifier_block *this, unsigned long event,
 			   void *ptr)
 {
 	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
+	struct mpls_dev *mdev;
 
 	switch(event) {
+	case NETDEV_REGISTER:
+		mdev = mpls_add_dev(dev);
+		if (IS_ERR(mdev))
+			return notifier_from_errno(PTR_ERR(mdev));
+		break;
+
 	case NETDEV_UNREGISTER:
 		mpls_ifdown(dev);
 		break;
@@ -924,7 +1037,7 @@ static int mpls_platform_labels(struct ctl_table *table, int write,
 	return ret;
 }
 
-static struct ctl_table mpls_table[] = {
+static const struct ctl_table mpls_table[] = {
 	{
 		.procname	= "platform_labels",
 		.data		= NULL,
diff --git a/net/mpls/internal.h b/net/mpls/internal.h
index d06dff9..b839f5c 100644
--- a/net/mpls/internal.h
+++ b/net/mpls/internal.h
@@ -23,6 +23,12 @@ struct mpls_entry_decoded {
 	u8 bos;
 };
 
+struct mpls_dev {
+	int			fwd_enabled;
+
+	struct ctl_table_header *sysctl;
+};
+
 struct sk_buff;
 
 static inline struct mpls_shim_hdr *mpls_hdr(const struct sk_buff *skb)
-- 
2.1.4
