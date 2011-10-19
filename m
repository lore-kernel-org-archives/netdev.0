From: Roopa Prabhu <roprabhu@cisco.com>
Subject: [net-next-2.6 PATCH 4/8 RFC v2] rtnetlink: Add support to get
	MAC/VLAN filters
Date: Tue, 18 Oct 2011 23:26:15 -0700
Message-ID: <20111019062615.7242.99896.stgit@savbu-pc100.cisco.com>
References: <20111019062543.7242.3969.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: sri@us.ibm.com, dragos.tatulea@gmail.com, arnd@arndb.de,
	kvm@vger.kernel.org, mst@redhat.com, davem@davemloft.net,
	mchan@broadcom.com, dwang2@cisco.com, shemminger@vyatta.com,
	eric.dumazet@gmail.com, kaber@trash.net, benve@cisco.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtv-iport-3.cisco.com ([173.36.130.14]:21047 "EHLO
	mtv-iport-3.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751469Ab1JSG0P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2011 02:26:15 -0400
In-Reply-To: <20111019062543.7242.3969.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roprabhu@cisco.com>

This patch adds support in rtnetlink for IFLA_RX_FILTER get.
It adds new function rtnl_rx_filter_get_size to get the size
of rx filters by calling rtnl_link_ops->get_rx_addr_filter_size
and rtnl_link_ops->get_rx_vlan_filter_size

Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: Christian Benvenuti <benve@cisco.com>
Signed-off-by: David Wang <dwang2@cisco.com>
---
 net/core/rtnetlink.c |   90 +++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 89 insertions(+), 1 deletions(-)


diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index bc1074d..6a709db 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -475,6 +475,37 @@ static size_t rtnl_link_get_af_size(const struct net_device *dev)
 	return size;
 }
 
+static size_t rtnl_rx_filter_get_size(const struct net_device *dev)
+{
+	const struct rtnl_link_ops *ops = dev->rtnl_link_ops;
+	size_t size;
+
+	if (!ops)
+		return 0;
+
+	size = nla_total_size(sizeof(struct nlattr)); /* IFLA_RX_FILTER */
+
+	if (ops->get_rx_addr_filter_size) {
+		size_t rx_addr_filter_size = ops->get_rx_addr_filter_size(dev);
+
+		if (rx_addr_filter_size)
+			/* IFLA_RX_ADDR_FILTER */
+			size += nla_total_size(sizeof(struct nlattr)) +
+					rx_addr_filter_size;
+	}
+
+	if (ops->get_rx_vlan_filter_size) {
+		size_t rx_vlan_filter_size = ops->get_rx_vlan_filter_size(dev);
+
+		if (rx_vlan_filter_size)
+			/* IFLA_RX_VLAN_FILTER */
+			size += nla_total_size(sizeof(struct nlattr)) +
+					rx_vlan_filter_size;
+	}
+
+	return size;
+}
+
 static int rtnl_link_fill(struct sk_buff *skb, const struct net_device *dev)
 {
 	const struct rtnl_link_ops *ops = dev->rtnl_link_ops;
@@ -513,6 +544,59 @@ out:
 	return err;
 }
 
+static int rtnl_rx_filter_fill(struct sk_buff *skb,
+			       const struct net_device *dev)
+{
+	const struct rtnl_link_ops *ops = dev->rtnl_link_ops;
+	struct nlattr *rx_filter, *uninitialized_var(addr_filter);
+	struct nlattr *uninitialized_var(vlan_filter);
+	int err = -EMSGSIZE;
+
+	rx_filter = nla_nest_start(skb, IFLA_RX_FILTER);
+	if (rx_filter == NULL)
+		goto out;
+
+	if (ops->fill_rx_addr_filter) {
+		addr_filter = nla_nest_start(skb, IFLA_RX_ADDR_FILTER);
+		if (addr_filter == NULL)
+			goto err_cancel_rx_filter;
+		err = ops->fill_rx_addr_filter(skb, dev);
+		if (err == -ENODATA)
+			nla_nest_cancel(skb, addr_filter);
+		else if (err < 0)
+			goto err_cancel_addr_filter;
+		else
+			nla_nest_end(skb, addr_filter);
+	}
+
+	if (ops->fill_rx_vlan_filter) {
+		vlan_filter = nla_nest_start(skb, IFLA_RX_VLAN_FILTER);
+		if (vlan_filter == NULL)
+			goto err_cancel_addr_filter;
+		err = ops->fill_rx_vlan_filter(skb, dev);
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
+	if (ops->fill_rx_vlan_filter)
+		nla_nest_cancel(skb, vlan_filter);
+err_cancel_addr_filter:
+	if (ops->fill_rx_addr_filter)
+		nla_nest_cancel(skb, addr_filter);
+err_cancel_rx_filter:
+	nla_nest_cancel(skb, rx_filter);
+out:
+	return err;
+}
+
 static const int rtm_min[RTM_NR_FAMILIES] =
 {
 	[RTM_FAM(RTM_NEWLINK)]      = NLMSG_LENGTH(sizeof(struct ifinfomsg)),
@@ -786,7 +870,8 @@ static noinline size_t if_nlmsg_size(const struct net_device *dev)
 	       + rtnl_vfinfo_size(dev) /* IFLA_VFINFO_LIST */
 	       + rtnl_port_size(dev) /* IFLA_VF_PORTS + IFLA_PORT_SELF */
 	       + rtnl_link_get_size(dev) /* IFLA_LINKINFO */
-	       + rtnl_link_get_af_size(dev); /* IFLA_AF_SPEC */
+	       + rtnl_link_get_af_size(dev) /* IFLA_AF_SPEC */
+	       + rtnl_rx_filter_get_size(dev); /* IFLA_RX_FILTER */
 }
 
 static int rtnl_vf_ports_fill(struct sk_buff *skb, struct net_device *dev)
@@ -997,6 +1082,9 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 		goto nla_put_failure;
 
 	if (dev->rtnl_link_ops) {
+		if (rtnl_rx_filter_fill(skb, dev) < 0)
+			goto nla_put_failure;
+
 		if (rtnl_link_fill(skb, dev) < 0)
 			goto nla_put_failure;
 	}
