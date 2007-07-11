From: Patrick McHardy <kaber@trash.net>
Subject: [RTNETLINK 04/04]: rtnl_link: allow specifying initial device address
Date: Wed, 11 Jul 2007 19:38:19 +0200 (MEST)
Message-ID: <20070711173818.18369.51589.sendpatchset@localhost.localdomain>
References: <20070711173812.18369.47109.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, greearb@candelatech.com,
	Patrick McHardy <kaber@trash.net>, xemul@openvz.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:58357 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757705AbXGKRiU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2007 13:38:20 -0400
In-Reply-To: <20070711173812.18369.47109.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[RTNETLINK]: rtnl_link: allow specifying initial device address

Drivers need to validate the initial addresses in their netlink attribute
validation function or manually reject them if they can't support this.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 2b73b83f72018cea40557afa0bce0a1b40a717be
tree e1f492495fe9d12bcbc5d623704c2ee476ffb914
parent 88fcde1e75dbfad7e7210642c0364850eed2591e
author Patrick McHardy <kaber@trash.net> Wed, 11 Jul 2007 19:28:17 +0200
committer Patrick McHardy <kaber@trash.net> Wed, 11 Jul 2007 19:28:17 +0200

 drivers/net/dummy.c      |   12 ++++++++++++
 drivers/net/ifb.c        |   12 ++++++++++++
 net/8021q/vlan.c         |    8 ++++++--
 net/8021q/vlan_netlink.c |    7 +++++++
 net/core/rtnetlink.c     |    9 +++++++--
 5 files changed, 44 insertions(+), 4 deletions(-)

diff --git a/drivers/net/dummy.c b/drivers/net/dummy.c
index 373ff70..756a6bc 100644
--- a/drivers/net/dummy.c
+++ b/drivers/net/dummy.c
@@ -84,9 +84,21 @@ static int dummy_xmit(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int dummy_validate(struct nlattr *tb[], struct nlattr *data[])
+{
+	if (tb[IFLA_ADDRESS]) {
+		if (nla_len(tb[IFLA_ADDRESS]) != ETH_ALEN)
+			return -EINVAL;
+		if (!is_valid_ether_addr(nla_data(tb[IFLA_ADDRESS])))
+			return -EADDRNOTAVAIL;
+	}
+	return 0;
+}
+
 static struct rtnl_link_ops dummy_link_ops __read_mostly = {
 	.kind		= "dummy",
 	.setup		= dummy_setup,
+	.validate	= dummy_validate,
 };
 
 /* Number of dummy devices to be set up by this module. */
diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index c8e7c8f..f5c3598 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -221,10 +221,22 @@ static int ifb_open(struct net_device *dev)
 	return 0;
 }
 
+static int ifb_validate(struct nlattr *tb[], struct nlattr *data[])
+{
+	if (tb[IFLA_ADDRESS]) {
+		if (nla_len(tb[IFLA_ADDRESS]) != ETH_ALEN)
+			return -EINVAL;
+		if (!is_valid_ether_addr(nla_data(tb[IFLA_ADDRESS])))
+			return -EADDRNOTAVAIL;
+	}
+	return 0;
+}
+
 static struct rtnl_link_ops ifb_link_ops __read_mostly = {
 	.kind		= "ifb",
 	.priv_size	= sizeof(struct ifb_private),
 	.setup		= ifb_setup,
+	.validate	= ifb_validate,
 };
 
 /* Number of ifb devices to be set up by this module. */
diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index ec0c58a..1a5e0f2 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -324,8 +324,10 @@ static int vlan_dev_init(struct net_device *dev)
 					  (1<<__LINK_STATE_DORMANT))) |
 		      (1<<__LINK_STATE_PRESENT);
 
-	memcpy(dev->broadcast, real_dev->broadcast, real_dev->addr_len);
-	memcpy(dev->dev_addr, real_dev->dev_addr, real_dev->addr_len);
+	if (is_zero_ether_addr(dev->dev_addr))
+		memcpy(dev->dev_addr, real_dev->dev_addr, dev->addr_len);
+	if (is_zero_ether_addr(dev->broadcast))
+		memcpy(dev->broadcast, real_dev->broadcast, dev->addr_len);
 
 	if (real_dev->features & NETIF_F_HW_VLAN_TX) {
 		dev->hard_header     = real_dev->hard_header;
@@ -373,6 +375,8 @@ void vlan_setup(struct net_device *new_dev)
 	new_dev->set_multicast_list = vlan_dev_set_multicast_list;
 	new_dev->destructor = free_netdev;
 	new_dev->do_ioctl = vlan_dev_ioctl;
+
+	memset(new_dev->broadcast, 0, sizeof(ETH_ALEN));
 }
 
 static void vlan_transfer_operstate(const struct net_device *dev, struct net_device *vlandev)
diff --git a/net/8021q/vlan_netlink.c b/net/8021q/vlan_netlink.c
index 844c7e4..6cdd1e0 100644
--- a/net/8021q/vlan_netlink.c
+++ b/net/8021q/vlan_netlink.c
@@ -41,6 +41,13 @@ static int vlan_validate(struct nlattr *tb[], struct nlattr *data[])
 	u16 id;
 	int err;
 
+	if (tb[IFLA_ADDRESS]) {
+		if (nla_len(tb[IFLA_ADDRESS]) != ETH_ALEN)
+			return -EINVAL;
+		if (!is_valid_ether_addr(nla_data(tb[IFLA_ADDRESS])))
+			return -EADDRNOTAVAIL;
+	}
+
 	if (!data)
 		return -EINVAL;
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 7b6b163..864cbdf 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1032,8 +1032,7 @@ replay:
 
 		if (ifm->ifi_index || ifm->ifi_flags || ifm->ifi_change)
 			return -EOPNOTSUPP;
-		if (tb[IFLA_ADDRESS] || tb[IFLA_BROADCAST] || tb[IFLA_MAP] ||
-		    tb[IFLA_MASTER] || tb[IFLA_PROTINFO])
+		if (tb[IFLA_MAP] || tb[IFLA_MASTER] || tb[IFLA_PROTINFO])
 			return -EOPNOTSUPP;
 
 		if (!ops) {
@@ -1065,6 +1064,12 @@ replay:
 
 		if (tb[IFLA_MTU])
 			dev->mtu = nla_get_u32(tb[IFLA_MTU]);
+		if (tb[IFLA_ADDRESS])
+			memcpy(dev->dev_addr, nla_data(tb[IFLA_ADDRESS]),
+			       nla_len(tb[IFLA_ADDRESS]));
+		if (tb[IFLA_BROADCAST])
+			memcpy(dev->broadcast, nla_data(tb[IFLA_BROADCAST]),
+			       nla_len(tb[IFLA_BROADCAST]));
 		if (tb[IFLA_TXQLEN])
 			dev->tx_queue_len = nla_get_u32(tb[IFLA_TXQLEN]);
 		if (tb[IFLA_WEIGHT])
