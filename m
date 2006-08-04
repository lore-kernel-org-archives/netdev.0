From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 7/9] [NET]: Convert link modification to new netlink api
Date: Sat, 05 Aug 2006 00:00:07 +0200
Message-ID: <20060805003537.456479778@postel.suug.ch>
References: <20060805003452.493542515@postel.suug.ch>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:11245 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1422682AbWHEAnf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2006 20:43:35 -0400
To: davem@davemloft.net
Content-Disposition: inline; filename=nl_link
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Transforms do_setlink() into rtnl_setlink() using the new
netlink api. A warning message printed to the console is
added in the event that a change request fails while part
of the change request has been comitted already. The ioctl()
based nature of net devices makes it almost impossible to
move on to atomic netlink operations without obsoleting
some of the functionality.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.19/net/core/rtnetlink.c
===================================================================
--- net-2.6.19.orig/net/core/rtnetlink.c
+++ net-2.6.19/net/core/rtnetlink.c
@@ -336,52 +336,69 @@ static int rtnetlink_dump_ifinfo(struct 
 	return skb->len;
 }
 
-static int do_setlink(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
+static struct nla_policy ifla_policy[IFLA_MAX+1] __read_mostly = {
+	[IFLA_IFNAME]		= { .type = NLA_STRING },
+	[IFLA_MAP]		= { .minlen = sizeof(struct rtnl_link_ifmap) },
+	[IFLA_MTU]		= { .type = NLA_U32 },
+	[IFLA_TXQLEN]		= { .type = NLA_U32 },
+	[IFLA_WEIGHT]		= { .type = NLA_U32 },
+	[IFLA_OPERSTATE]	= { .type = NLA_U8 },
+	[IFLA_LINKMODE]		= { .type = NLA_U8 },
+};
+
+static int rtnl_setlink(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 {
-	struct ifinfomsg  *ifm = NLMSG_DATA(nlh);
-	struct rtattr    **ida = arg;
+	struct ifinfomsg *ifm;
 	struct net_device *dev;
-	int err, send_addr_notify = 0;
+	int err, send_addr_notify = 0, modified = 0;
+	struct nlattr *tb[IFLA_MAX+1];
+	char ifname[IFNAMSIZ];
+
+	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFLA_MAX, ifla_policy);
+	if (err < 0)
+		goto errout;
+
+	if (tb[IFLA_IFNAME] &&
+	    nla_strlcpy(ifname, tb[IFLA_IFNAME], IFNAMSIZ) >= IFNAMSIZ)
+		return -EINVAL;
 
+	err = -EINVAL;
+	ifm = nlmsg_data(nlh);
 	if (ifm->ifi_index >= 0)
 		dev = dev_get_by_index(ifm->ifi_index);
-	else if (ida[IFLA_IFNAME - 1]) {
-		char ifname[IFNAMSIZ];
-
-		if (rtattr_strlcpy(ifname, ida[IFLA_IFNAME - 1],
-		                   IFNAMSIZ) >= IFNAMSIZ)
-			return -EINVAL;
+	else if (tb[IFLA_IFNAME])
 		dev = dev_get_by_name(ifname);
-	} else
-		return -EINVAL;
+	else
+		goto errout;
 
-	if (!dev)
-		return -ENODEV;
+	if (dev == NULL) {
+		err = -ENODEV;
+		goto errout;
+	}
 
-	err = -EINVAL;
+	if (tb[IFLA_ADDRESS] &&
+	    nla_len(tb[IFLA_ADDRESS]) < dev->addr_len)
+		goto errout_dev;
 
-	if (ifm->ifi_flags)
-		dev_change_flags(dev, ifm->ifi_flags);
+	if (tb[IFLA_BROADCAST] &&
+	    nla_len(tb[IFLA_BROADCAST]) < dev->addr_len)
+		goto errout_dev;
 
-	if (ida[IFLA_MAP - 1]) {
+	if (tb[IFLA_MAP]) {
 		struct rtnl_link_ifmap *u_map;
 		struct ifmap k_map;
 
 		if (!dev->set_config) {
 			err = -EOPNOTSUPP;
-			goto out;
+			goto errout_dev;
 		}
 
 		if (!netif_device_present(dev)) {
 			err = -ENODEV;
-			goto out;
+			goto errout_dev;
 		}
-		
-		if (ida[IFLA_MAP - 1]->rta_len != RTA_LENGTH(sizeof(*u_map)))
-			goto out;
-
-		u_map = RTA_DATA(ida[IFLA_MAP - 1]);
 
+		u_map = nla_data(tb[IFLA_MAP]);
 		k_map.mem_start = (unsigned long) u_map->mem_start;
 		k_map.mem_end = (unsigned long) u_map->mem_end;
 		k_map.base_addr = (unsigned short) u_map->base_addr;
@@ -390,106 +407,97 @@ static int do_setlink(struct sk_buff *sk
 		k_map.port = (unsigned char) u_map->port;
 
 		err = dev->set_config(dev, &k_map);
+		if (err < 0)
+			goto errout_dev;
 
-		if (err)
-			goto out;
+		modified = 1;
 	}
 
-	if (ida[IFLA_ADDRESS - 1]) {
+	if (tb[IFLA_ADDRESS]) {
 		if (!dev->set_mac_address) {
 			err = -EOPNOTSUPP;
-			goto out;
+			goto errout_dev;
 		}
+
 		if (!netif_device_present(dev)) {
 			err = -ENODEV;
-			goto out;
+			goto errout_dev;
 		}
-		if (ida[IFLA_ADDRESS - 1]->rta_len != RTA_LENGTH(dev->addr_len))
-			goto out;
 
-		err = dev->set_mac_address(dev, RTA_DATA(ida[IFLA_ADDRESS - 1]));
-		if (err)
-			goto out;
+		err = dev->set_mac_address(dev, nla_data(tb[IFLA_ADDRESS]));
+		if (err < 0)
+			goto errout_dev;
 		send_addr_notify = 1;
+		modified = 1;
 	}
 
-	if (ida[IFLA_BROADCAST - 1]) {
-		if (ida[IFLA_BROADCAST - 1]->rta_len != RTA_LENGTH(dev->addr_len))
-			goto out;
-		memcpy(dev->broadcast, RTA_DATA(ida[IFLA_BROADCAST - 1]),
-		       dev->addr_len);
-		send_addr_notify = 1;
+	if (tb[IFLA_MTU]) {
+		err = dev_set_mtu(dev, nla_get_u32(tb[IFLA_MTU]));
+		if (err < 0)
+			goto errout_dev;
+		modified = 1;
+	}
+
+	/*
+	 * Interface selected by interface index but interface
+	 * name provided implies that a name change has been
+	 * requested.
+	 */
+	if (ifm->ifi_index >= 0 && ifname[0]) {
+		err = dev_change_name(dev, ifname);
+		if (err < 0)
+			goto errout_dev;
+		modified = 1;
 	}
 
-	if (ida[IFLA_MTU - 1]) {
-		if (ida[IFLA_MTU - 1]->rta_len != RTA_LENGTH(sizeof(u32)))
-			goto out;
-		err = dev_set_mtu(dev, *((u32 *) RTA_DATA(ida[IFLA_MTU - 1])));
-
-		if (err)
-			goto out;
-
+#ifdef CONFIG_NET_WIRELESS_RTNETLINK
+	if (tb[IFLA_WIRELESS]) {
+		/* Call Wireless Extensions.
+		 * Various stuff checked in there... */
+		err = wireless_rtnetlink_set(dev, nla_data(tb[IFLA_WIRELESS]),
+					     nla_len(tb[IFLA_WIRELESS]));
+		if (err < 0)
+			goto errout_dev;
 	}
+#endif	/* CONFIG_NET_WIRELESS_RTNETLINK */
 
-	if (ida[IFLA_TXQLEN - 1]) {
-		if (ida[IFLA_TXQLEN - 1]->rta_len != RTA_LENGTH(sizeof(u32)))
-			goto out;
-
-		dev->tx_queue_len = *((u32 *) RTA_DATA(ida[IFLA_TXQLEN - 1]));
+	if (tb[IFLA_BROADCAST]) {
+		nla_memcpy(dev->broadcast, tb[IFLA_BROADCAST], dev->addr_len);
+		send_addr_notify = 1;
 	}
 
-	if (ida[IFLA_WEIGHT - 1]) {
-		if (ida[IFLA_WEIGHT - 1]->rta_len != RTA_LENGTH(sizeof(u32)))
-			goto out;
-
-		dev->weight = *((u32 *) RTA_DATA(ida[IFLA_WEIGHT - 1]));
-	}
+	if (ifm->ifi_flags)
+		dev_change_flags(dev, ifm->ifi_flags);
 
-	if (ida[IFLA_OPERSTATE - 1]) {
-		if (ida[IFLA_OPERSTATE - 1]->rta_len != RTA_LENGTH(sizeof(u8)))
-			goto out;
+	if (tb[IFLA_TXQLEN])
+		dev->tx_queue_len = nla_get_u32(tb[IFLA_TXQLEN]);
 
-		set_operstate(dev, *((u8 *) RTA_DATA(ida[IFLA_OPERSTATE - 1])));
-	}
+	if (tb[IFLA_WEIGHT])
+		dev->weight = nla_get_u32(tb[IFLA_WEIGHT]);
 
-	if (ida[IFLA_LINKMODE - 1]) {
-		if (ida[IFLA_LINKMODE - 1]->rta_len != RTA_LENGTH(sizeof(u8)))
-			goto out;
+	if (tb[IFLA_OPERSTATE])
+		set_operstate(dev, nla_get_u8(tb[IFLA_OPERSTATE]));
 
+	if (tb[IFLA_LINKMODE]) {
 		write_lock_bh(&dev_base_lock);
-		dev->link_mode = *((u8 *) RTA_DATA(ida[IFLA_LINKMODE - 1]));
+		dev->link_mode = nla_get_u8(tb[IFLA_LINKMODE]);
 		write_unlock_bh(&dev_base_lock);
 	}
 
-	if (ifm->ifi_index >= 0 && ida[IFLA_IFNAME - 1]) {
-		char ifname[IFNAMSIZ];
-
-		if (rtattr_strlcpy(ifname, ida[IFLA_IFNAME - 1],
-		                   IFNAMSIZ) >= IFNAMSIZ)
-			goto out;
-		err = dev_change_name(dev, ifname);
-		if (err)
-			goto out;
-	}
-
-#ifdef CONFIG_NET_WIRELESS_RTNETLINK
-	if (ida[IFLA_WIRELESS - 1]) {
-
-		/* Call Wireless Extensions.
-		 * Various stuff checked in there... */
-		err = wireless_rtnetlink_set(dev, RTA_DATA(ida[IFLA_WIRELESS - 1]), ida[IFLA_WIRELESS - 1]->rta_len);
-		if (err)
-			goto out;
-	}
-#endif	/* CONFIG_NET_WIRELESS_RTNETLINK */
-
 	err = 0;
 
-out:
+errout_dev:
+	if (err < 0 && modified && net_ratelimit())
+		printk(KERN_WARNING "A link change request failed with "
+		       "some changes comitted already. Interface %s may "
+		       "have been left with an inconsistent configuration, "
+		       "please check.\n", dev->name);
+
 	if (send_addr_notify)
 		call_netdevice_notifiers(NETDEV_CHANGEADDR, dev);
 
 	dev_put(dev);
+errout:
 	return err;
 }
 
@@ -740,7 +748,7 @@ static struct rtnetlink_link link_rtnetl
 					 .doit   = do_getlink,
 #endif	/* CONFIG_NET_WIRELESS_RTNETLINK */
 					 .dumpit = rtnetlink_dump_ifinfo },
-	[RTM_SETLINK     - RTM_BASE] = { .doit   = do_setlink		 },
+	[RTM_SETLINK     - RTM_BASE] = { .doit   = rtnl_setlink		 },
 	[RTM_GETADDR     - RTM_BASE] = { .dumpit = rtnetlink_dump_all	 },
 	[RTM_GETROUTE    - RTM_BASE] = { .dumpit = rtnetlink_dump_all	 },
 	[RTM_NEWNEIGH    - RTM_BASE] = { .doit   = neigh_add		 },

