From: Roopa Prabhu <roprabhu@cisco.com>
Subject: [net-next-2.6 PATCH 4/6 v4] rtnetlink: Add support to get MAC/VLAN
	filters
Date: Tue, 08 Nov 2011 23:55:56 -0800
Message-ID: <20111109075556.13549.81380.stgit@rhel6.1>
References: <20111109075449.13549.58135.stgit@rhel6.1>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: chrisw@redhat.com, sri@us.ibm.com, dragos.tatulea@gmail.com,
	kvm@vger.kernel.org, arnd@arndb.de, mst@redhat.com,
	gregory.v.rose@intel.com, mchan@broadcom.com, dwang2@cisco.com,
	shemminger@vyatta.com, eric.dumazet@gmail.com, kaber@trash.net,
	benve@cisco.com
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20111109075449.13549.58135.stgit@rhel6.1>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Roopa Prabhu <roprabhu@cisco.com>

This patch adds support in rtnetlink for IFLA_RX_VF_FILTERS and
IFLA_RX_FILTER get. It gets the size of the filters using
netdev_ops->get_rx_filter_addr_size and netdev_ops->get_rx_filter_vlan_size
and uses netdev_ops->get_rx_filter_addr and netdev_ops->get_rx_filter_vlan.
In case of IFLA_RX_VF_FILTERS it loops through all vf's to get the filter
data

Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: Christian Benvenuti <benve@cisco.com>
Signed-off-by: David Wang <dwang2@cisco.com>
---
 net/core/rtnetlink.c |  159 ++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 158 insertions(+), 1 deletions(-)


diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index a042910..ea861b4 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -475,6 +475,62 @@ static size_t rtnl_link_get_af_size(const struct net_device *dev)
 	return size;
 }
 
+static size_t rtnl_vf_rx_filter_size(const struct net_device *dev, int vf)
+{
+	const struct net_device_ops *ops = dev->netdev_ops;
+	size_t size;
+
+	/* IFLA_RX_FILTER  or IFLA_VF_RX_FILTER */
+	size = nla_total_size(sizeof(struct nlattr));
+
+	if (vf != SELF_VF)
+		size = nla_total_size(4); /* IFLA_RX_FILTER_VF */
+
+	if (ops->ndo_get_rx_filter_addr_size) {
+		size_t rx_filter_addr_size =
+				ops->ndo_get_rx_filter_addr_size(dev, vf);
+
+		if (rx_filter_addr_size)
+			/* IFLA_RX_FILTER_ADDR */
+			size += nla_total_size(sizeof(struct nlattr)) +
+					rx_filter_addr_size;
+	}
+
+	if (ops->ndo_get_rx_filter_vlan_size) {
+		size_t rx_filter_vlan_size =
+				ops->ndo_get_rx_filter_vlan_size(dev, vf);
+
+		if (rx_filter_vlan_size)
+			/* IFLA_RX_FILTER_VLAN */
+			size += nla_total_size(sizeof(struct nlattr)) +
+					rx_filter_vlan_size;
+	}
+
+	return size;
+}
+
+static size_t rtnl_rx_filter_size(const struct net_device *dev)
+{
+	const struct net_device_ops *ops = dev->netdev_ops;
+	int vf = SELF_VF;
+	size_t size;
+
+	if (!ops->ndo_get_rx_filter_addr_size &&
+	    !ops->ndo_get_rx_filter_vlan_size)
+		return 0;
+
+	size = rtnl_vf_rx_filter_size(dev, vf); /* SELF_VF */
+
+	if (dev->dev.parent && dev_num_vf(dev->dev.parent)) {
+		/* IFLA_VF_RX_FILTERS */
+		size = nla_total_size(sizeof(struct nlattr));
+		for (vf = 0; vf < dev_num_vf(dev->dev.parent); vf++)
+			size += rtnl_vf_rx_filter_size(dev, vf);
+	}
+
+	return size;
+}
+
 static int rtnl_link_fill(struct sk_buff *skb, const struct net_device *dev)
 {
 	const struct rtnl_link_ops *ops = dev->rtnl_link_ops;
@@ -513,6 +569,102 @@ out:
 	return err;
 }
 
+static int rtnl_vf_rx_filter_fill(struct sk_buff *skb,
+				  const struct net_device *dev, int vf)
+{
+	const struct net_device_ops *ops = dev->netdev_ops;
+	struct nlattr *addr_filter = NULL, *vlan_filter = NULL;
+	struct nlattr *rx_filter;
+	int err = -EMSGSIZE;
+	int filter_attrtype =
+		(vf == SELF_VF ? IFLA_RX_FILTER : IFLA_VF_RX_FILTER);
+
+	rx_filter = nla_nest_start(skb, filter_attrtype);
+	if (rx_filter == NULL)
+		goto nla_put_failure;
+
+	if (vf != SELF_VF)
+		NLA_PUT_U32(skb, IFLA_RX_FILTER_VF, vf);
+
+	if (ops->ndo_get_rx_filter_addr) {
+		addr_filter = nla_nest_start(skb, IFLA_RX_FILTER_ADDR);
+		if (addr_filter == NULL)
+			goto err_cancel_rx_filter;
+		err = ops->ndo_get_rx_filter_addr(dev, vf, skb);
+		if (err == -ENODATA)
+			nla_nest_cancel(skb, addr_filter);
+		else if (err < 0)
+			goto err_cancel_addr_filter;
+		else
+			nla_nest_end(skb, addr_filter);
+	}
+
+	if (ops->ndo_get_rx_filter_vlan) {
+		vlan_filter = nla_nest_start(skb, IFLA_RX_FILTER_VLAN);
+		if (vlan_filter == NULL)
+			goto err_cancel_addr_filter;
+		err = ops->ndo_get_rx_filter_vlan(dev, vf, skb);
+		if (err == -ENODATA)
+			nla_nest_cancel(skb, vlan_filter);
+		else if (err)
+			goto err_cancel_vlan_filter;
+		else
+			nla_nest_end(skb, vlan_filter);
+	}
+	nla_nest_end(skb, rx_filter);
+
+	return 0;
+
+err_cancel_vlan_filter:
+	if (vlan_filter)
+		nla_nest_cancel(skb, vlan_filter);
+err_cancel_addr_filter:
+	if (addr_filter)
+		nla_nest_cancel(skb, addr_filter);
+err_cancel_rx_filter:
+	nla_nest_cancel(skb, rx_filter);
+nla_put_failure:
+	return err;
+}
+
+static int rtnl_rx_filter_fill(struct sk_buff *skb,
+			       const struct net_device *dev)
+{
+	struct nlattr *vf_rx_filters = NULL;
+	int vf = SELF_VF;
+	int err;
+
+	if (!dev->netdev_ops->ndo_get_rx_filter_addr &&
+	    !dev->netdev_ops->ndo_get_rx_filter_vlan)
+		return 0;
+
+	err = rtnl_vf_rx_filter_fill(skb, dev, vf); /* SELF_VF */
+	if (err)
+		return err;
+
+	if (dev->dev.parent && dev_num_vf(dev->dev.parent)) {
+		vf_rx_filters = nla_nest_start(skb, IFLA_VF_RX_FILTERS);
+		if (!vf_rx_filters)
+			return -EMSGSIZE;
+
+		for (vf = 0; vf < dev_num_vf(dev->dev.parent); vf++) {
+			err = rtnl_vf_rx_filter_fill(skb, dev, vf);
+			if (err == -EMSGSIZE)
+				goto err_cancel_nest_vf_rx_filters;
+		}
+
+		nla_nest_end(skb, vf_rx_filters);
+	}
+
+	return 0;
+
+err_cancel_nest_vf_rx_filters:
+	if (vf_rx_filters)
+		nla_nest_cancel(skb, vf_rx_filters);
+
+	return err;
+}
+
 static const int rtm_min[RTM_NR_FAMILIES] =
 {
 	[RTM_FAM(RTM_NEWLINK)]      = NLMSG_LENGTH(sizeof(struct ifinfomsg)),
@@ -786,7 +938,9 @@ static noinline size_t if_nlmsg_size(const struct net_device *dev)
 	       + rtnl_vfinfo_size(dev) /* IFLA_VFINFO_LIST */
 	       + rtnl_port_size(dev) /* IFLA_VF_PORTS + IFLA_PORT_SELF */
 	       + rtnl_link_get_size(dev) /* IFLA_LINKINFO */
-	       + rtnl_link_get_af_size(dev); /* IFLA_AF_SPEC */
+	       + rtnl_link_get_af_size(dev) /* IFLA_AF_SPEC */
+		/* IFLA_VF_RX_FILTERS + IFLA_RX_FILTER */
+	       + rtnl_rx_filter_size(dev);
 }
 
 static int rtnl_vf_ports_fill(struct sk_buff *skb, struct net_device *dev)
@@ -996,6 +1150,9 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 	if (rtnl_port_fill(skb, dev))
 		goto nla_put_failure;
 
+	if (rtnl_rx_filter_fill(skb, dev) < 0)
+		goto nla_put_failure;
+
 	if (dev->rtnl_link_ops) {
 		if (rtnl_link_fill(skb, dev) < 0)
 			goto nla_put_failure;

