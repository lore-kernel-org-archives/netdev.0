From: Thomas Graf <tgraf@suug.ch>
Subject: [BRIDGE] netlink: Convert bridge netlink code to new netlink interface
Date: Sun, 19 Nov 2006 18:10:02 +0100
Message-ID: <20061119171002.GH8693@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:42162 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1756796AbWKSRJm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Nov 2006 12:09:42 -0500
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Removes dependency on buggy rta_buf, fixes a memory corruption bug due to
a unvalidated netlink attribute, and simplifies the code.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.20/net/bridge/br_netlink.c
===================================================================
--- net-2.6.20.orig/net/bridge/br_netlink.c	2006-11-19 17:41:03.000000000 +0100
+++ net-2.6.20/net/bridge/br_netlink.c	2006-11-19 18:01:10.000000000 +0100
@@ -36,51 +36,43 @@
 {
 	const struct net_bridge *br = port->br;
 	const struct net_device *dev = port->dev;
-	struct ifinfomsg *r;
+	struct ifinfomsg *hdr;
 	struct nlmsghdr *nlh;
-	unsigned char *b = skb->tail;
-	u32 mtu = dev->mtu;
 	u8 operstate = netif_running(dev) ? dev->operstate : IF_OPER_DOWN;
-	u8 portstate = port->state;
 
 	pr_debug("br_fill_info event %d port %s master %s\n",
 		 event, dev->name, br->dev->name);
 
-	nlh = NLMSG_NEW(skb, pid, seq, event, sizeof(*r), flags);
-	r = NLMSG_DATA(nlh);
-	r->ifi_family = AF_BRIDGE;
-	r->__ifi_pad = 0;
-	r->ifi_type = dev->type;
-	r->ifi_index = dev->ifindex;
-	r->ifi_flags = dev_get_flags(dev);
-	r->ifi_change = 0;
-
-	RTA_PUT(skb, IFLA_IFNAME, strlen(dev->name)+1, dev->name);
-
-	RTA_PUT(skb, IFLA_MASTER, sizeof(int), &br->dev->ifindex);
+	nlh = nlmsg_put(skb, pid, seq, event, sizeof(*hdr), flags);
+	if (nlh == NULL)
+		return -ENOBUFS;
+
+	hdr = nlmsg_data(nlh);
+	hdr->ifi_family = AF_BRIDGE;
+	hdr->__ifi_pad = 0;
+	hdr->ifi_type = dev->type;
+	hdr->ifi_index = dev->ifindex;
+	hdr->ifi_flags = dev_get_flags(dev);
+	hdr->ifi_change = 0;
+
+	NLA_PUT_STRING(skb, IFLA_IFNAME, dev->name);
+	NLA_PUT_U32(skb, IFLA_MASTER, br->dev->ifindex);
+	NLA_PUT_U32(skb, IFLA_MTU, dev->mtu);
+	NLA_PUT_U8(skb, IFLA_OPERSTATE, operstate);
 
 	if (dev->addr_len)
-		RTA_PUT(skb, IFLA_ADDRESS, dev->addr_len, dev->dev_addr);
+		NLA_PUT(skb, IFLA_ADDRESS, dev->addr_len, dev->dev_addr);
 
-	RTA_PUT(skb, IFLA_MTU, sizeof(mtu), &mtu);
 	if (dev->ifindex != dev->iflink)
-		RTA_PUT(skb, IFLA_LINK, sizeof(int), &dev->iflink);
-
-
-	RTA_PUT(skb, IFLA_OPERSTATE, sizeof(operstate), &operstate);
+		NLA_PUT_U32(skb, IFLA_LINK, dev->iflink);
 
 	if (event == RTM_NEWLINK)
-		RTA_PUT(skb, IFLA_PROTINFO, sizeof(portstate), &portstate);
-
-	nlh->nlmsg_len = skb->tail - b;
-
-	return skb->len;
+		NLA_PUT_U8(skb, IFLA_PROTINFO, port->state);
 
-nlmsg_failure:
-rtattr_failure:
+	return nlmsg_end(skb, nlh);
 
-	skb_trim(skb, b - skb->data);
-	return -EINVAL;
+nla_put_failure:
+	return nlmsg_cancel(skb, nlh);
 }
 
 /*
@@ -113,25 +105,18 @@
 {
 	struct net_device *dev;
 	int idx;
-	int s_idx = cb->args[0];
-	int err = 0;
 
 	read_lock(&dev_base_lock);
 	for (dev = dev_base, idx = 0; dev; dev = dev->next) {
-		struct net_bridge_port *p = dev->br_port;
-
 		/* not a bridge port */
-		if (!p)
-			continue;
-
-		if (idx < s_idx)
-			goto cont;
+		if (dev->br_port == NULL || idx < cb->args[0])
+			goto skip;
 
-		err = br_fill_ifinfo(skb, p, NETLINK_CB(cb->skb).pid,
-				     cb->nlh->nlmsg_seq, RTM_NEWLINK, NLM_F_MULTI);
-		if (err <= 0)
+		if (br_fill_ifinfo(skb, dev->br_port, NETLINK_CB(cb->skb).pid,
+				   cb->nlh->nlmsg_seq, RTM_NEWLINK,
+				   NLM_F_MULTI) < 0)
 			break;
-cont:
+skip:
 		++idx;
 	}
 	read_unlock(&dev_base_lock);
@@ -147,26 +132,27 @@
  */
 static int br_rtm_setlink(struct sk_buff *skb,  struct nlmsghdr *nlh, void *arg)
 {
-	struct rtattr  **rta = arg;
-	struct ifinfomsg *ifm = NLMSG_DATA(nlh);
+	struct ifinfomsg *ifm;
+	struct nlattr *protinfo;
 	struct net_device *dev;
 	struct net_bridge_port *p;
 	u8 new_state;
 
+	if (nlmsg_len(nlh) < sizeof(*ifm))
+		return -EINVAL;
+
+	ifm = nlmsg_data(nlh);
 	if (ifm->ifi_family != AF_BRIDGE)
 		return -EPFNOSUPPORT;
 
-	/* Must pass valid state as PROTINFO */
-	if (rta[IFLA_PROTINFO-1]) {
-		u8 *pstate = RTA_DATA(rta[IFLA_PROTINFO-1]);
-		new_state = *pstate;
-	} else
+	protinfo = nlmsg_find_attr(nlh, sizeof(*ifm), IFLA_PROTINFO);
+	if (!protinfo || nla_len(protinfo) < sizeof(u8))
 		return -EINVAL;
 
+	new_state = nla_get_u8(protinfo);
 	if (new_state > BR_STATE_BLOCKING)
 		return -EINVAL;
 
-	/* Find bridge port */
 	dev = __dev_get_by_index(ifm->ifi_index);
 	if (!dev)
 		return -ENODEV;
@@ -179,10 +165,8 @@
 	if (p->br->stp_enabled)
 		return -EBUSY;
 
-	if (!netif_running(dev))
-		return -ENETDOWN;
-
-	if (!netif_carrier_ok(dev) && new_state != BR_STATE_DISABLED)
+	if (!netif_running(dev) ||
+	    (!netif_carrier_ok(dev) && new_state != BR_STATE_DISABLED))
 		return -ENETDOWN;
 
 	p->state = new_state;
