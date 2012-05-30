From: John Fastabend <john.r.fastabend@intel.com>
Subject: [RFC PATCH v1 2/3] net: add VEPA, VEB bridge mode
Date: Tue, 29 May 2012 20:07:06 -0700
Message-ID: <20120530030705.7443.22155.stgit@jf-dev1-dcblab>
References: <20120530030531.7443.72024.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: sri@us.ibm.com, gregory.v.rose@intel.com, netdev@vger.kernel.org,
	bhutchings@solarflare.com, jeffrey.t.kirsher@intel.com,
	eric.w.multanen@intel.com
To: krkumar2@in.ibm.com, hadi@cyberus.ca, shemminger@vyatta.com,
	mst@redhat.com, buytenh@wantstofly.org, eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:6104 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932261Ab2E3DVR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 May 2012 23:21:17 -0400
In-Reply-To: <20120530030531.7443.72024.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hardware switches may support enabling and disabling the
loopback switch which puts the device in a VEPA mode defined
in the IEEE 802.1Qbg specification. In this mode frames are
not switched in the hardware but sent directly to the switch.
SR-IOV capabable NICs will likely support this mode I am
aware of at least two such devices.

This patch adds an additional IFLA_BRIDGE_MODE attribute
that can be set and dumped via the PF_BRIDGE:{SET|GET}LINK
operations. Also anticipating bridge attributes that may
be common for both embedded bridges and software bridges
this adds a flags attribute IFLA_BRIDGE_FLAGS currently
used to determine if the IFLA_BRIDGE command or event is
being generated to/from an embedded bridge or software
bridge. Finally, the event generation is pulled out of
the bridge module and into rtnetlink proper.

For example using the macvlan driver in VEPA mode on top of
an embedded switch requires putting the embedded switch into
a VEPA mode to get the expected results.

	--------  --------
        | VEPA |  | VEPA |       <-- macvlan vepa edge relays
        --------  --------
           |        |
           |        |
        ------------------
        |      VEPA      |       <-- embedded switch in NIC
        ------------------
                |
                |
        -------------------
        | external switch |      <-- shiny new physical
	-------------------          switch with VEPA support

A packet sent from the macvlan VEPA at the top could be
loopbacked on the embedded switch and never seen by the
external switch. So in order for this to work the embedded
switch needs to be set in the VEPA state via the above
described commands.

CC: Lennert Buytenhek <buytenh@wantstofly.org>
CC: Stephen Hemminger <shemminger@vyatta.com>
Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 include/linux/if_link.h |   16 ++++++++++
 net/bridge/br_netlink.c |    2 -
 net/core/rtnetlink.c    |   73 ++++++++++++++++++++++++++++++++++++++++++-----
 3 files changed, 82 insertions(+), 9 deletions(-)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index f715750..30489e5 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -139,6 +139,7 @@ enum {
 	IFLA_NET_NS_FD,
 	IFLA_EXT_MASK,		/* Extended info mask, VFs, etc */
 	IFLA_PROMISCUITY,	/* Promiscuity count: > 0 means acts PROMISC */
+	IFLA_BRIDGE,		/* Bridge attributes */
 #define IFLA_PROMISCUITY IFLA_PROMISCUITY
 	__IFLA_MAX
 };
@@ -396,4 +397,19 @@ struct ifla_port_vsi {
 	__u8 pad[3];
 };
 
+/* Bridge Flags */
+#define BRIDGE_FLAGS_MASTER	0	/* Bridge command to/from master */
+#define BRIDGE_FLAGS_SELF	1	/* Bridge command to/from lowerdev */
+
+#define BRIDGE_MODE_VEB		0	/* Default loopback mode */
+#define BRIDGE_MODE_VEPA	1	/* 802.1Qbg defined VEPA mode */
+
+/* Bridge management nested attributes */
+enum {
+	IFLA_BRIDGE_FLAGS,
+	IFLA_BRIDGE_MODE,
+	__IFLA_BRIDGE_MAX,
+};
+#define IFLA_BRIDGE_MAX (__IFLA_BRIDGE_MAX - 1)
+
 #endif /* _LINUX_IF_LINK_H */
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index f207234..8edbe0d 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -166,8 +166,6 @@ int br_setlink(struct net_device *dev, struct nlmsghdr *nlh)
 	br_port_state_selection(p->br);
 	spin_unlock_bh(&p->br->lock);
 
-	br_ifinfo_notify(RTM_NEWLINK, p);
-
 	return 0;
 }
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index de6c371..9cd50ab 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1121,6 +1121,7 @@ const struct nla_policy ifla_policy[IFLA_MAX+1] = {
 	[IFLA_AF_SPEC]		= { .type = NLA_NESTED },
 	[IFLA_EXT_MASK]		= { .type = NLA_U32 },
 	[IFLA_PROMISCUITY]	= { .type = NLA_U32 },
+	[IFLA_BRIDGE]		= { .type = NLA_NESTED },
 };
 EXPORT_SYMBOL(ifla_policy);
 
@@ -1158,6 +1159,11 @@ static const struct nla_policy ifla_port_policy[IFLA_PORT_MAX+1] = {
 	[IFLA_PORT_RESPONSE]	= { .type = NLA_U16, },
 };
 
+static const struct nla_policy bridge_policy[IFLA_BRIDGE_MAX + 1] = {
+	[IFLA_BRIDGE_FLAGS]	= { .type = NLA_U16 },
+	[IFLA_BRIDGE_MODE]	= { .type = NLA_U16 },
+};
+
 struct net *rtnl_link_get_net(struct net *src_net, struct nlattr *tb[])
 {
 	struct net *net;
@@ -2280,13 +2286,60 @@ static int rtnl_bridge_getlink(struct sk_buff *skb, struct netlink_callback *cb)
 	return skb->len;
 }
 
+static inline size_t bridge_nlmsg_size(void)
+{
+	return NLMSG_ALIGN(sizeof(struct ifinfomsg))
+		+ nla_total_size(IFNAMSIZ)	/* IFLA_IFNAME */
+		+ nla_total_size(MAX_ADDR_LEN)	/* IFLA_ADDRESS */
+		+ nla_total_size(sizeof(u32))	/* IFLA_MASTER */
+		+ nla_total_size(sizeof(u32))	/* IFLA_MTU */
+		+ nla_total_size(sizeof(u32))	/* IFLA_LINK */
+		+ nla_total_size(sizeof(u32))	/* IFLA_OPERSTATE */
+		+ nla_total_size(sizeof(u8))	/* IFLA_PROTINFO */
+		+ nla_total_size(sizeof(struct nlattr))	/* IFLA_BRIDGE */
+		+ nla_total_size(sizeof(u16))	/* IFLA_BRIDGE_FLAGS */
+		+ nla_total_size(sizeof(u16));	/* IFLA_BRIDGE_MODE */
+}
+
+static int rtnl_bridge_notify(struct net_device *dev, u16 flags)
+{
+	struct net *net = dev_net(dev);
+	struct net_device *master = dev->master;
+	struct sk_buff *skb;
+	int err = -EOPNOTSUPP;
+
+	skb = nlmsg_new(bridge_nlmsg_size(), GFP_ATOMIC);
+	if (!skb) {
+		err = -ENOMEM;
+		goto errout;
+	}
+
+	if (!flags && master && master->netdev_ops->ndo_bridge_getlink)
+		err = master->netdev_ops->ndo_bridge_getlink(skb, 0, 0, dev);
+	else if (dev->netdev_ops->ndo_bridge_getlink)
+		err = dev->netdev_ops->ndo_bridge_getlink(skb, 0, 0, dev);
+
+	if (err < 0)
+		goto errout;
+
+	rtnl_notify(skb, net, 0, RTNLGRP_LINK, NULL, GFP_ATOMIC);
+	return 0;
+errout:
+	WARN_ON(err == -EMSGSIZE);
+	kfree_skb(skb);
+	rtnl_set_sk_err(net, RTNLGRP_LINK, err);
+	return err;
+}
+
 static int rtnl_bridge_setlink(struct sk_buff *skb, struct nlmsghdr *nlh,
 			       void *arg)
 {
 	struct net *net = sock_net(skb->sk);
 	struct ifinfomsg *ifm;
 	struct net_device *dev;
-	int err = -EINVAL;
+	struct nlattr *bridge, *attr;
+	int rem, err = -EOPNOTSUPP;
+	u16 flags = 0;
 
 	if (nlmsg_len(nlh) < sizeof(*ifm))
 		return -EINVAL;
@@ -2301,16 +2354,22 @@ static int rtnl_bridge_setlink(struct sk_buff *skb, struct nlmsghdr *nlh,
 		return -ENODEV;
 	}
 
-	if (dev->master && dev->master->netdev_ops->ndo_bridge_setlink) {
-		err = dev->master->netdev_ops->ndo_bridge_setlink(dev, nlh);
-		if (err)
-			goto out;
+	bridge = nlmsg_find_attr(nlh, sizeof(struct ifinfomsg), IFLA_BRIDGE);
+	nla_for_each_nested(attr, bridge, rem) {
+		if (nla_type(attr) == IFLA_BRIDGE_FLAGS)
+			flags = nla_get_u16(attr);
 	}
 
-	if (dev->netdev_ops->ndo_bridge_setlink)
+	if (!flags && dev->master &&
+	    dev->master->netdev_ops->ndo_bridge_setlink)
+		err = dev->master->netdev_ops->ndo_bridge_setlink(dev, nlh);
+	else if ((flags & BRIDGE_FLAGS_SELF) &&
+		   dev->netdev_ops->ndo_bridge_setlink)
 		err = dev->netdev_ops->ndo_bridge_setlink(dev, nlh);
 
-out:
+	/* Generate event to notify upper layer of bridge change */
+	if (!err)
+		err = rtnl_bridge_notify(dev, flags);
 	return err;
 }
 
