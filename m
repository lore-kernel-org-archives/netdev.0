From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 8/9] [NET]: Convert link dumping to new netlink api
Date: Sat, 05 Aug 2006 00:00:08 +0200
Message-ID: <20060805003537.773433163@postel.suug.ch>
References: <20060805003452.493542515@postel.suug.ch>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:12013 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1422681AbWHEAnl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2006 20:43:41 -0400
To: davem@davemloft.net
Content-Disposition: inline; filename=nl_link_dump
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Transforms netlink code to dump link tables to use the new
netlink api. Makes rtnl_getlink() available regardless of the
availability of the wireless extensions.

Adding copy_rtnl_link_stats() avoids the structural dependency
of struct rtnl_link_stats on struct net_device_stats and thus
avoids troubles later on.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.19/net/core/rtnetlink.c
===================================================================
--- net-2.6.19.orig/net/core/rtnetlink.c
+++ net-2.6.19/net/core/rtnetlink.c
@@ -218,41 +218,73 @@ static void set_operstate(struct net_dev
 	}
 }
 
-static int rtnetlink_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
-				 int type, u32 pid, u32 seq, u32 change, 
-				 unsigned int flags)
-{
-	struct ifinfomsg *r;
-	struct nlmsghdr  *nlh;
-	unsigned char	 *b = skb->tail;
-
-	nlh = NLMSG_NEW(skb, pid, seq, type, sizeof(*r), flags);
-	r = NLMSG_DATA(nlh);
-	r->ifi_family = AF_UNSPEC;
-	r->__ifi_pad = 0;
-	r->ifi_type = dev->type;
-	r->ifi_index = dev->ifindex;
-	r->ifi_flags = dev_get_flags(dev);
-	r->ifi_change = change;
+static void copy_rtnl_link_stats(struct rtnl_link_stats *a,
+				 struct net_device_stats *b)
+{
+	a->rx_packets = b->rx_packets;
+	a->tx_packets = b->tx_packets;
+	a->rx_bytes = b->rx_bytes;
+	a->tx_bytes = b->tx_bytes;
+	a->rx_errors = b->rx_errors;
+	a->tx_errors = b->tx_errors;
+	a->rx_dropped = b->rx_dropped;
+	a->tx_dropped = b->tx_dropped;
+
+	a->multicast = b->multicast;
+	a->collisions = b->collisions;
+
+	a->rx_length_errors = b->rx_length_errors;
+	a->rx_over_errors = b->rx_over_errors;
+	a->rx_crc_errors = b->rx_crc_errors;
+	a->rx_frame_errors = b->rx_frame_errors;
+	a->rx_fifo_errors = b->rx_fifo_errors;
+	a->rx_missed_errors = b->rx_missed_errors;
+
+	a->tx_aborted_errors = b->tx_aborted_errors;
+	a->tx_carrier_errors = b->tx_carrier_errors;
+	a->tx_fifo_errors = b->tx_fifo_errors;
+	a->tx_heartbeat_errors = b->tx_heartbeat_errors;
+	a->tx_window_errors = b->tx_window_errors;
 
-	RTA_PUT(skb, IFLA_IFNAME, strlen(dev->name)+1, dev->name);
+	a->rx_compressed = b->rx_compressed;
+	a->tx_compressed = b->tx_compressed;
+};
 
-	if (1) {
-		u32 txqlen = dev->tx_queue_len;
-		RTA_PUT(skb, IFLA_TXQLEN, sizeof(txqlen), &txqlen);
-	}
+static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
+			    void *iwbuf, int iwbuflen, int type, u32 pid,
+			    u32 seq, u32 change, unsigned int flags)
+{
+	struct ifinfomsg *ifm;
+	struct nlmsghdr *nlh;
 
-	if (1) {
-		u32 weight = dev->weight;
-		RTA_PUT(skb, IFLA_WEIGHT, sizeof(weight), &weight);
-	}
+	nlh = nlmsg_put(skb, pid, seq, type, sizeof(*ifm), flags);
+	if (nlh == NULL)
+		return -ENOBUFS;
 
-	if (1) {
-		u8 operstate = netif_running(dev)?dev->operstate:IF_OPER_DOWN;
-		u8 link_mode = dev->link_mode;
-		RTA_PUT(skb, IFLA_OPERSTATE, sizeof(operstate), &operstate);
-		RTA_PUT(skb, IFLA_LINKMODE, sizeof(link_mode), &link_mode);
-	}
+	ifm = nlmsg_data(nlh);
+	ifm->ifi_family = AF_UNSPEC;
+	ifm->__ifi_pad = 0;
+	ifm->ifi_type = dev->type;
+	ifm->ifi_index = dev->ifindex;
+	ifm->ifi_flags = dev_get_flags(dev);
+	ifm->ifi_change = change;
+
+	NLA_PUT_STRING(skb, IFLA_IFNAME, dev->name);
+	NLA_PUT_U32(skb, IFLA_TXQLEN, dev->tx_queue_len);
+	NLA_PUT_U32(skb, IFLA_WEIGHT, dev->weight);
+	NLA_PUT_U8(skb, IFLA_OPERSTATE,
+		   netif_running(dev) ? dev->operstate : IF_OPER_DOWN);
+	NLA_PUT_U8(skb, IFLA_LINKMODE, dev->link_mode);
+	NLA_PUT_U32(skb, IFLA_MTU, dev->mtu);
+
+	if (dev->ifindex != dev->iflink)
+		NLA_PUT_U32(skb, IFLA_LINK, dev->iflink);
+
+	if (dev->master)
+		NLA_PUT_U32(skb, IFLA_MASTER, dev->master->ifindex);
+
+	if (dev->qdisc_sleeping)
+		NLA_PUT_STRING(skb, IFLA_QDISC, dev->qdisc_sleeping->ops->id);
 
 	if (1) {
 		struct rtnl_link_ifmap map = {
@@ -263,58 +295,38 @@ static int rtnetlink_fill_ifinfo(struct 
 			.dma         = dev->dma,
 			.port        = dev->if_port,
 		};
-		RTA_PUT(skb, IFLA_MAP, sizeof(map), &map);
+		NLA_PUT(skb, IFLA_MAP, sizeof(map), &map);
 	}
 
 	if (dev->addr_len) {
-		RTA_PUT(skb, IFLA_ADDRESS, dev->addr_len, dev->dev_addr);
-		RTA_PUT(skb, IFLA_BROADCAST, dev->addr_len, dev->broadcast);
-	}
-
-	if (1) {
-		u32 mtu = dev->mtu;
-		RTA_PUT(skb, IFLA_MTU, sizeof(mtu), &mtu);
-	}
-
-	if (dev->ifindex != dev->iflink) {
-		u32 iflink = dev->iflink;
-		RTA_PUT(skb, IFLA_LINK, sizeof(iflink), &iflink);
-	}
-
-	if (dev->qdisc_sleeping)
-		RTA_PUT(skb, IFLA_QDISC,
-			strlen(dev->qdisc_sleeping->ops->id) + 1,
-			dev->qdisc_sleeping->ops->id);
-	
-	if (dev->master) {
-		u32 master = dev->master->ifindex;
-		RTA_PUT(skb, IFLA_MASTER, sizeof(master), &master);
+		NLA_PUT(skb, IFLA_ADDRESS, dev->addr_len, dev->dev_addr);
+		NLA_PUT(skb, IFLA_BROADCAST, dev->addr_len, dev->broadcast);
 	}
 
 	if (dev->get_stats) {
-		unsigned long *stats = (unsigned long*)dev->get_stats(dev);
+		struct net_device_stats *stats = dev->get_stats(dev);
 		if (stats) {
-			struct rtattr  *a;
-			__u32	       *s;
-			int		i;
-			int		n = sizeof(struct rtnl_link_stats)/4;
-
-			a = __RTA_PUT(skb, IFLA_STATS, n*4);
-			s = RTA_DATA(a);
-			for (i=0; i<n; i++)
-				s[i] = stats[i];
+			struct nlattr *attr;
+
+			attr = nla_reserve(skb, IFLA_STATS,
+					   sizeof(struct rtnl_link_stats));
+			if (attr == NULL)
+				goto nla_put_failure;
+
+			copy_rtnl_link_stats(nla_data(attr), stats);
 		}
 	}
-	nlh->nlmsg_len = skb->tail - b;
-	return skb->len;
 
-nlmsg_failure:
-rtattr_failure:
-	skb_trim(skb, b - skb->data);
-	return -1;
+	if (iwbuf)
+		NLA_PUT(skb, IFLA_WIRELESS, iwbuflen, iwbuf);
+
+	return nlmsg_end(skb, nlh);
+
+nla_put_failure:
+	return nlmsg_cancel(skb, nlh);
 }
 
-static int rtnetlink_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
+static int rtnl_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	int idx;
 	int s_idx = cb->args[0];
@@ -324,10 +336,9 @@ static int rtnetlink_dump_ifinfo(struct 
 	for (dev=dev_base, idx=0; dev; dev = dev->next, idx++) {
 		if (idx < s_idx)
 			continue;
-		if (rtnetlink_fill_ifinfo(skb, dev, RTM_NEWLINK,
-					  NETLINK_CB(cb->skb).pid,
-					  cb->nlh->nlmsg_seq, 0,
-					  NLM_F_MULTI) <= 0)
+		if (rtnl_fill_ifinfo(skb, dev, NULL, 0, RTM_NEWLINK,
+				     NETLINK_CB(cb->skb).pid,
+				     cb->nlh->nlmsg_seq, 0, NLM_F_MULTI) <= 0)
 			break;
 	}
 	read_unlock(&dev_base_lock);
@@ -501,84 +512,69 @@ errout:
 	return err;
 }
 
-#ifdef CONFIG_NET_WIRELESS_RTNETLINK
-static int do_getlink(struct sk_buff *in_skb, struct nlmsghdr* in_nlh, void *arg)
+static int rtnl_getlink(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
 {
-	struct ifinfomsg  *ifm = NLMSG_DATA(in_nlh);
-	struct rtattr    **ida = arg;
-	struct net_device *dev;
-	struct ifinfomsg *r;
-	struct nlmsghdr  *nlh;
-	int err = -ENOBUFS;
-	struct sk_buff *skb;
-	unsigned char	 *b;
-	char *iw_buf = NULL;
+	struct ifinfomsg *ifm;
+	struct nlattr *tb[IFLA_MAX+1];
+	struct net_device *dev = NULL;
+	struct sk_buff *nskb;
+	char *iw_buf = NULL, *iw = NULL;
 	int iw_buf_len = 0;
+	int err, payload;
 
-	if (ifm->ifi_index >= 0)
+	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFLA_MAX, ifla_policy);
+	if (err < 0)
+		goto errout;
+
+	ifm = nlmsg_data(nlh);
+	if (ifm->ifi_index >= 0) {
 		dev = dev_get_by_index(ifm->ifi_index);
-	else
+		if (dev == NULL)
+			return -ENODEV;
+	} else
 		return -EINVAL;
-	if (!dev)
-		return -ENODEV;
 
-#ifdef CONFIG_NET_WIRELESS_RTNETLINK
-	if (ida[IFLA_WIRELESS - 1]) {
 
+#ifdef CONFIG_NET_WIRELESS_RTNETLINK
+	if (tb[IFLA_WIRELESS]) {
 		/* Call Wireless Extensions. We need to know the size before
 		 * we can alloc. Various stuff checked in there... */
-		err = wireless_rtnetlink_get(dev, RTA_DATA(ida[IFLA_WIRELESS - 1]), ida[IFLA_WIRELESS - 1]->rta_len, &iw_buf, &iw_buf_len);
-		if (err)
-			goto out;
+		err = wireless_rtnetlink_get(dev, nla_data(tb[IFLA_WIRELESS]),
+					     nla_len(tb[IFLA_WIRELESS]),
+					     &iw_buf, &iw_buf_len);
+		if (err < 0)
+			goto errout;
+
+		iw += IW_EV_POINT_OFF;
 	}
 #endif	/* CONFIG_NET_WIRELESS_RTNETLINK */
 
-	/* Create a skb big enough to include all the data.
-	 * Some requests are way bigger than 4k... Jean II */
-	skb = alloc_skb((NLMSG_LENGTH(sizeof(*r))) + (RTA_SPACE(iw_buf_len)),
-			GFP_KERNEL);
-	if (!skb)
-		goto out;
-	b = skb->tail;
-
-	/* Put in the message the usual good stuff */
-	nlh = NLMSG_PUT(skb, NETLINK_CB(in_skb).pid, in_nlh->nlmsg_seq,
-			RTM_NEWLINK, sizeof(*r));
-	r = NLMSG_DATA(nlh);
-	r->ifi_family = AF_UNSPEC;
-	r->__ifi_pad = 0;
-	r->ifi_type = dev->type;
-	r->ifi_index = dev->ifindex;
-	r->ifi_flags = dev->flags;
-	r->ifi_change = 0;
-
-	/* Put the wireless payload if it exist */
-	if(iw_buf != NULL)
-		RTA_PUT(skb, IFLA_WIRELESS, iw_buf_len,
-			iw_buf + IW_EV_POINT_OFF);
-
-	nlh->nlmsg_len = skb->tail - b;
+	payload = NLMSG_ALIGN(sizeof(struct ifinfomsg) +
+			      nla_total_size(iw_buf_len));
+	nskb = nlmsg_new(nlmsg_total_size(payload), GFP_KERNEL);
+	if (nskb == NULL) {
+		err = -ENOBUFS;
+		goto errout;
+	}
 
-	/* Needed ? */
-	NETLINK_CB(skb).dst_pid = NETLINK_CB(in_skb).pid;
+	err = rtnl_fill_ifinfo(nskb, dev, iw, iw_buf_len, RTM_NEWLINK,
+			       NETLINK_CB(skb).pid, nlh->nlmsg_seq, 0, 0);
+	if (err <= 0) {
+		kfree_skb(skb);
+		goto errout;
+	}
 
-	err = netlink_unicast(rtnl, skb, NETLINK_CB(in_skb).pid, MSG_DONTWAIT);
+	err = netlink_unicast(rtnl, skb, NETLINK_CB(skb).pid, MSG_DONTWAIT);
 	if (err > 0)
 		err = 0;
-out:
-	if(iw_buf != NULL)
-		kfree(iw_buf);
+errout:
+	kfree(iw_buf);
 	dev_put(dev);
-	return err;
 
-rtattr_failure:
-nlmsg_failure:
-	kfree_skb(skb);
-	goto out;
+	return err;
 }
-#endif	/* CONFIG_NET_WIRELESS_RTNETLINK */
 
-static int rtnetlink_dump_all(struct sk_buff *skb, struct netlink_callback *cb)
+static int rtnl_dump_all(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	int idx;
 	int s_idx = cb->family;
@@ -609,11 +605,11 @@ void rtmsg_ifinfo(int type, struct net_d
 			       sizeof(struct rtnl_link_ifmap) +
 			       sizeof(struct rtnl_link_stats) + 128);
 
-	skb = alloc_skb(size, GFP_KERNEL);
+	skb = nlmsg_new(size, GFP_KERNEL);
 	if (!skb)
 		return;
 
-	if (rtnetlink_fill_ifinfo(skb, dev, type, 0, 0, change, 0) < 0) {
+	if (rtnl_fill_ifinfo(skb, dev, NULL, 0, type, 0, 0, change, 0) < 0) {
 		kfree_skb(skb);
 		return;
 	}
@@ -743,14 +739,11 @@ static void rtnetlink_rcv(struct sock *s
 
 static struct rtnetlink_link link_rtnetlink_table[RTM_NR_MSGTYPES] =
 {
-	[RTM_GETLINK     - RTM_BASE] = {
-#ifdef CONFIG_NET_WIRELESS_RTNETLINK
-					 .doit   = do_getlink,
-#endif	/* CONFIG_NET_WIRELESS_RTNETLINK */
-					 .dumpit = rtnetlink_dump_ifinfo },
+	[RTM_GETLINK     - RTM_BASE] = { .doit   = rtnl_getlink,
+					 .dumpit = rtnl_dump_ifinfo	 },
 	[RTM_SETLINK     - RTM_BASE] = { .doit   = rtnl_setlink		 },
-	[RTM_GETADDR     - RTM_BASE] = { .dumpit = rtnetlink_dump_all	 },
-	[RTM_GETROUTE    - RTM_BASE] = { .dumpit = rtnetlink_dump_all	 },
+	[RTM_GETADDR     - RTM_BASE] = { .dumpit = rtnl_dump_all	 },
+	[RTM_GETROUTE    - RTM_BASE] = { .dumpit = rtnl_dump_all	 },
 	[RTM_NEWNEIGH    - RTM_BASE] = { .doit   = neigh_add		 },
 	[RTM_DELNEIGH    - RTM_BASE] = { .doit   = neigh_delete		 },
 	[RTM_GETNEIGH    - RTM_BASE] = { .dumpit = neigh_dump_info	 },
@@ -758,7 +751,7 @@ static struct rtnetlink_link link_rtnetl
 	[RTM_NEWRULE     - RTM_BASE] = { .doit   = fib_nl_newrule	 },
 	[RTM_DELRULE     - RTM_BASE] = { .doit   = fib_nl_delrule	 },
 #endif
-	[RTM_GETRULE     - RTM_BASE] = { .dumpit = rtnetlink_dump_all	 },
+	[RTM_GETRULE     - RTM_BASE] = { .dumpit = rtnl_dump_all	 },
 	[RTM_GETNEIGHTBL - RTM_BASE] = { .dumpit = neightbl_dump_info	 },
 	[RTM_SETNEIGHTBL - RTM_BASE] = { .doit   = neightbl_set		 },
 };

