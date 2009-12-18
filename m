From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC PATCH v2 5/6] rtnetlink: Add VF config code to rtnetlink
Date: Thu, 17 Dec 2009 17:35:01 -0800
Message-ID: <20091218013500.4510.55153.stgit@localhost.localdomain>
References: <20091218013329.4510.25937.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: gospo@redhat.com, Mitch Williams <mitch.a.williams@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta08.westchester.pa.mail.comcast.net ([76.96.62.80]:59583
	"EHLO QMTA08.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753277AbZLRBfT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2009 20:35:19 -0500
In-Reply-To: <20091218013329.4510.25937.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Williams, Mitch A <mitch.a.williams@intel.com>

Add code to allow rtnetlink clients to query and set VF information through
the PF driver.

Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 net/core/rtnetlink.c |   59 ++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 59 insertions(+), 0 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 794bcb8..090b9fc 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -580,6 +580,11 @@ static void copy_rtnl_link_stats(struct rtnl_link_stats *a,
 	a->tx_compressed = b->tx_compressed;
 };
 
+static inline int rtnl_vfinfo_size(const struct net_device *dev)
+{
+	return netif_num_vf(dev) * sizeof(struct ifla_vf_info);
+}
+
 static inline size_t if_nlmsg_size(const struct net_device *dev)
 {
 	return NLMSG_ALIGN(sizeof(struct ifinfomsg))
@@ -597,6 +602,8 @@ static inline size_t if_nlmsg_size(const struct net_device *dev)
 	       + nla_total_size(4) /* IFLA_MASTER */
 	       + nla_total_size(1) /* IFLA_OPERSTATE */
 	       + nla_total_size(1) /* IFLA_LINKMODE */
+	       + nla_total_size(4) /* IFLA_NUM_VF */
+	       + nla_total_size(rtnl_vfinfo_size(dev)) /* IFLA_VFINFO */
 	       + rtnl_link_get_size(dev); /* IFLA_LINKINFO */
 }
 
@@ -665,6 +672,16 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 	stats = dev_get_stats(dev);
 	copy_rtnl_link_stats(nla_data(attr), stats);
 
+	if ((dev->netdev_ops->ndo_get_vf_config) && netif_num_vf(dev)) {
+		int i;
+		struct ifla_vf_info ivi;
+		NLA_PUT_U32(skb, IFLA_NUM_VF, netif_num_vf(dev));
+		for (i = 0; i < netif_num_vf(dev); i++) {
+			if (dev->netdev_ops->ndo_get_vf_config(dev, i, &ivi))
+				break;
+			NLA_PUT(skb, IFLA_VFINFO, sizeof(ivi), &ivi);
+		}
+	}
 	if (dev->rtnl_link_ops) {
 		if (rtnl_link_fill(skb, dev) < 0)
 			goto nla_put_failure;
@@ -725,6 +742,12 @@ const struct nla_policy ifla_policy[IFLA_MAX+1] = {
 	[IFLA_LINKINFO]		= { .type = NLA_NESTED },
 	[IFLA_NET_NS_PID]	= { .type = NLA_U32 },
 	[IFLA_IFALIAS]	        = { .type = NLA_STRING, .len = IFALIASZ-1 },
+	[IFLA_VF_MAC]		= { .type = NLA_BINARY,
+				    .len = sizeof(struct ifla_vf_mac) },
+	[IFLA_VF_VLAN]		= { .type = NLA_BINARY,
+				    .len = sizeof(struct ifla_vf_vlan) },
+	[IFLA_VF_TX_RATE]	= { .type = NLA_BINARY,
+				    .len = sizeof(struct ifla_vf_tx_rate) },
 };
 EXPORT_SYMBOL(ifla_policy);
 
@@ -898,6 +921,42 @@ static int do_setlink(struct net_device *dev, struct ifinfomsg *ifm,
 		write_unlock_bh(&dev_base_lock);
 	}
 
+	if (tb[IFLA_VF_MAC]) {
+		struct ifla_vf_mac *ivm;
+		ivm = nla_data(tb[IFLA_VF_MAC]);
+		write_lock_bh(&dev_base_lock);
+		if (ops->ndo_set_vf_mac)
+			err = ops->ndo_set_vf_mac(dev, ivm->vf, ivm->mac);
+		write_unlock_bh(&dev_base_lock);
+		if (err < 0)
+			goto errout;
+		modified = 1;
+	}
+
+	if (tb[IFLA_VF_VLAN]) {
+		struct ifla_vf_vlan *ivv;
+		ivv = nla_data(tb[IFLA_VF_VLAN]);
+		write_lock_bh(&dev_base_lock);
+		if (ops->ndo_set_vf_vlan)
+			err = ops->ndo_set_vf_vlan(dev, ivv->vf, ivv->vlan);
+		write_unlock_bh(&dev_base_lock);
+		if (err < 0)
+			goto errout;
+		modified = 1;
+	}
+	err = 0;
+
+	if (tb[IFLA_VF_TX_RATE]) {
+		struct ifla_vf_tx_rate *ivt;
+		ivt = nla_data(tb[IFLA_VF_TX_RATE]);
+		write_lock_bh(&dev_base_lock);
+		if (ops->ndo_set_vf_tx_rate)
+			err = ops->ndo_set_vf_tx_rate(dev, ivt->vf, ivt->rate);
+		write_unlock_bh(&dev_base_lock);
+		if (err < 0)
+			goto errout;
+		modified = 1;
+	}
 	err = 0;
 
 errout:

