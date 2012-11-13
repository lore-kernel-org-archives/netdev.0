From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next 1/4] bridge: bridge port parameters over netlink
Date: Tue, 13 Nov 2012 09:53:05 -0800
Message-ID: <20121113175346.513407677@vyatta.com>
References: <20121113175304.628996029@vyatta.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from fiji.vyatta.com ([76.74.103.50]:36667 "EHLO fiji.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752295Ab2KMR56 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Nov 2012 12:57:58 -0500
Content-Disposition: inline; filename=bridge-port-flags-netlink.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Expose bridge port parameter over netlink. By switching to a nested
message, this can be used for other bridge parameters.

This changes IFLA_PROTINFO attribute from one byte to a full nested
set of attributes. This is safe for application interface because the
old message used IFLA_PROTINFO and new one uses
 IFLA_PROTINFO | NLA_F_NESTED.

The code adapts to old format requests, and therefore stays
compatible with user mode RSTP daemon. Since the type field
for nested and unnested attributes are different, and the old
code in libnetlink doesn't do the mask, it is also safe to use
with old versions of bridge monitor command.

Note: although mode is only a boolean, treating it as a
full byte since in the future someone will probably want to add more
values (like macvlan has).

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
v2 - adapt to new bridge generic setlink infrastructure
     fix cost/priority width in policy

 include/uapi/linux/if_link.h |   10 ++
 net/bridge/br_netlink.c      |  145 ++++++++++++++++++++++++++++++++-----------
 2 files changed, 119 insertions(+), 36 deletions(-)

--- a/include/uapi/linux/if_link.h	2012-11-12 07:58:35.000000000 -0800
+++ b/include/uapi/linux/if_link.h	2012-11-12 13:33:53.558390820 -0800
@@ -205,6 +205,21 @@ enum {
 
 #define IFLA_INET6_MAX	(__IFLA_INET6_MAX - 1)
 
+enum {
+	BRIDGE_MODE_UNSPEC,
+	BRIDGE_MODE_HAIRPIN,
+};
+
+enum {
+	IFLA_BRPORT_UNSPEC,
+	IFLA_BRPORT_STATE,	/* Spanning tree state     */
+	IFLA_BRPORT_PRIORITY,	/* "             priority  */
+	IFLA_BRPORT_COST,	/* "             cost      */
+	IFLA_BRPORT_MODE,	/* mode (hairpin)          */
+	__IFLA_BRPORT_MAX
+};
+#define IFLA_BRPORT_MAX (__IFLA_BRPORT_MAX - 1)
+
 struct ifla_cacheinfo {
 	__u32	max_reasm_len;
 	__u32	tstamp;		/* ipv6InterfaceTable updated timestamp */
--- a/net/bridge/br_netlink.c	2012-11-12 07:58:45.000000000 -0800
+++ b/net/bridge/br_netlink.c	2012-11-12 13:51:24.367861973 -0800
@@ -20,16 +20,39 @@
 #include "br_private.h"
 #include "br_private_stp.h"
 
+static inline size_t br_port_info_size(void)
+{
+	return nla_total_size(1)	/* IFLA_BRPORT_STATE  */
+		+ nla_total_size(2)	/* IFLA_BRPORT_PRIORITY */
+		+ nla_total_size(4)	/* IFLA_BRPORT_COST */
+		+ nla_total_size(1)	/* IFLA_BRPORT_MODE */
+		+ 0;
+}
+
 static inline size_t br_nlmsg_size(void)
 {
 	return NLMSG_ALIGN(sizeof(struct ifinfomsg))
-	       + nla_total_size(IFNAMSIZ) /* IFLA_IFNAME */
-	       + nla_total_size(MAX_ADDR_LEN) /* IFLA_ADDRESS */
-	       + nla_total_size(4) /* IFLA_MASTER */
-	       + nla_total_size(4) /* IFLA_MTU */
-	       + nla_total_size(4) /* IFLA_LINK */
-	       + nla_total_size(1) /* IFLA_OPERSTATE */
-	       + nla_total_size(1); /* IFLA_PROTINFO */
+		+ nla_total_size(IFNAMSIZ) /* IFLA_IFNAME */
+		+ nla_total_size(MAX_ADDR_LEN) /* IFLA_ADDRESS */
+		+ nla_total_size(4) /* IFLA_MASTER */
+		+ nla_total_size(4) /* IFLA_MTU */
+		+ nla_total_size(4) /* IFLA_LINK */
+		+ nla_total_size(1) /* IFLA_OPERSTATE */
+		+ nla_total_size(br_port_info_size()); /* IFLA_PROTINFO */
+}
+
+static int br_port_fill_attrs(struct sk_buff *skb,
+			      const struct net_bridge_port *p)
+{
+	u8 mode = !!(p->flags & BR_HAIRPIN_MODE);
+
+	if (nla_put_u8(skb, IFLA_BRPORT_STATE, p->state) ||
+	    nla_put_u16(skb, IFLA_BRPORT_PRIORITY, p->priority) ||
+	    nla_put_u32(skb, IFLA_BRPORT_COST, p->path_cost) ||
+	    nla_put_u8(skb, IFLA_BRPORT_MODE, mode))
+		return -EMSGSIZE;
+
+	return 0;
 }
 
 /*
@@ -67,10 +90,18 @@ static int br_fill_ifinfo(struct sk_buff
 	    (dev->addr_len &&
 	     nla_put(skb, IFLA_ADDRESS, dev->addr_len, dev->dev_addr)) ||
 	    (dev->ifindex != dev->iflink &&
-	     nla_put_u32(skb, IFLA_LINK, dev->iflink)) ||
-	    (event == RTM_NEWLINK &&
-	     nla_put_u8(skb, IFLA_PROTINFO, port->state)))
+	     nla_put_u32(skb, IFLA_LINK, dev->iflink)))
 		goto nla_put_failure;
+
+	if (event == RTM_NEWLINK) {
+		struct nlattr *nest
+			= nla_nest_start(skb, IFLA_PROTINFO | NLA_F_NESTED);
+
+		if (nest == NULL || br_port_fill_attrs(skb, port) < 0)
+			goto nla_put_failure;
+		nla_nest_end(skb, nest);
+	}
+
 	return nlmsg_end(skb, nlh);
 
 nla_put_failure:
@@ -126,49 +157,117 @@ out:
 	return err;
 }
 
-/*
- * Change state of port (ie from forwarding to blocking etc)
- * Used by spanning tree in user space.
- */
-int br_setlink(struct net_device *dev, struct nlmsghdr *nlh)
-{
-	struct ifinfomsg *ifm;
-	struct nlattr *protinfo;
-	struct net_bridge_port *p;
-	u8 new_state;
-
-	ifm = nlmsg_data(nlh);
+static const struct nla_policy ifla_brport_policy[IFLA_BRPORT_MAX + 1] = {
+	[IFLA_BRPORT_STATE]	= { .type = NLA_U8 },
+	[IFLA_BRPORT_COST]	= { .type = NLA_U32 },
+	[IFLA_BRPORT_PRIORITY]	= { .type = NLA_U16 },
+	[IFLA_BRPORT_MODE]	= { .type = NLA_U8 },
+};
 
-	protinfo = nlmsg_find_attr(nlh, sizeof(*ifm), IFLA_PROTINFO);
-	if (!protinfo || nla_len(protinfo) < sizeof(u8))
-		return -EINVAL;
-
-	new_state = nla_get_u8(protinfo);
-	if (new_state > BR_STATE_BLOCKING)
-		return -EINVAL;
-
-	p = br_port_get_rtnl(dev);
-	if (!p)
+/* Change the state of the port and notify spanning tree */
+static int br_set_port_state(struct net_bridge_port *p, u8 state)
+{
+	if (state > BR_STATE_BLOCKING)
 		return -EINVAL;
 
 	/* if kernel STP is running, don't allow changes */
 	if (p->br->stp_enabled == BR_KERNEL_STP)
 		return -EBUSY;
 
-	if (!netif_running(dev) ||
-	    (!netif_carrier_ok(dev) && new_state != BR_STATE_DISABLED))
+	if (!netif_running(p->dev) ||
+	    (!netif_carrier_ok(p->dev) && state != BR_STATE_DISABLED))
 		return -ENETDOWN;
 
-	p->state = new_state;
+	p->state = state;
 	br_log_state(p);
-
-	spin_lock_bh(&p->br->lock);
 	br_port_state_selection(p->br);
-	spin_unlock_bh(&p->br->lock);
+	return 0;
+}
+
+/* Set/clear or port flags based on attribute */
+static void br_set_port_flag(struct net_bridge_port *p, struct nlattr *tb[],
+			   int attrtype, unsigned long mask)
+{
+	if (tb[attrtype]) {
+		u8 flag = nla_get_u8(tb[attrtype]);
+		if (flag)
+			p->flags |= mask;
+		else
+			p->flags &= ~mask;
+	}
+}
+
+/* Process bridge protocol info on port */
+static int br_setport(struct net_bridge_port *p, struct nlattr *tb[])
+{
+	int err;
 
+	br_set_port_flag(p, tb, IFLA_BRPORT_MODE, BR_HAIRPIN_MODE);
+
+	if (tb[IFLA_BRPORT_COST]) {
+		err = br_stp_set_path_cost(p, nla_get_u32(tb[IFLA_BRPORT_COST]));
+		if (err)
+			return err;
+	}
+
+	if (tb[IFLA_BRPORT_PRIORITY]) {
+		err = br_stp_set_port_priority(p, nla_get_u16(tb[IFLA_BRPORT_PRIORITY]));
+		if (err)
+			return err;
+	}
+
+	if (tb[IFLA_BRPORT_STATE]) {
+		err = br_set_port_state(p, nla_get_u8(tb[IFLA_BRPORT_STATE]));
+		if (err)
+			return err;
+	}
 	return 0;
 }
 
+/* Change state and parameters on port. */
+int br_setlink(struct net_device *dev, struct nlmsghdr *nlh)
+{
+	struct ifinfomsg *ifm;
+	struct nlattr *protinfo;
+	struct net_bridge_port *p;
+	struct nlattr *tb[IFLA_BRPORT_MAX];
+	int err;
+
+	ifm = nlmsg_data(nlh);
+
+	protinfo = nlmsg_find_attr(nlh, sizeof(*ifm), IFLA_PROTINFO);
+	if (!protinfo)
+		return 0;
+
+ 	p = br_port_get_rtnl(dev);
+	if (!p)
+		return -EINVAL;
+
+	if (protinfo->nla_type & NLA_F_NESTED) {
+		err = nla_parse_nested(tb, IFLA_BRPORT_MAX,
+				       protinfo, ifla_brport_policy);
+		if (err)
+			return err;
+
+		spin_lock_bh(&p->br->lock);
+		err = br_setport(p, tb);
+		spin_unlock_bh(&p->br->lock);
+	} else {
+		/* Binary compatability with old RSTP */
+		if (nla_len(protinfo) < sizeof(u8))
+			return -EINVAL;
+
+		spin_lock_bh(&p->br->lock);
+		err = br_set_port_state(p, nla_get_u8(protinfo));
+		spin_unlock_bh(&p->br->lock);
+	}
+
+	if (err == 0)
+		br_ifinfo_notify(RTM_NEWLINK, p);
+
+	return err;
+}
+
 static int br_validate(struct nlattr *tb[], struct nlattr *data[])
 {
 	if (tb[IFLA_ADDRESS]) {
