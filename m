From: Jiri Benc <jbenc@redhat.com>
Subject: [RFC PATCH net-next 8/9] rtnetlink: support strict checking for newlink, setlink and dellink
Date: Thu, 15 Oct 2015 18:39:13 +0200
Message-ID: <76938fae11a8858c9594db1dc65de8c44c27ab07.1444926905.git.jbenc@redhat.com>
References: <cover.1444926905.git.jbenc@redhat.com>
Cc: Thomas Graf <tgraf@suug.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39706 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753458AbbJOQjm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Oct 2015 12:39:42 -0400
In-Reply-To: <cover.1444926905.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 net/core/rtnetlink.c | 84 +++++++++++++++++++++++++++++++---------------------
 1 file changed, 51 insertions(+), 33 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 9d08ad6ee5c3..1af929e468cf 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1465,7 +1465,8 @@ struct net *rtnl_link_get_net(struct net *src_net, struct nlattr *tb[])
 }
 EXPORT_SYMBOL(rtnl_link_get_net);
 
-static int validate_linkmsg(struct net_device *dev, struct nlattr *tb[])
+static int validate_linkmsg(struct net_device *dev, struct nlattr *tb[],
+			    bool strict)
 {
 	if (dev) {
 		if (tb[IFLA_ADDRESS] &&
@@ -1492,7 +1493,7 @@ static int validate_linkmsg(struct net_device *dev, struct nlattr *tb[])
 
 			if (af_ops->validate_link_af) {
 				err = af_ops->validate_link_af(dev, af,
-							       false);
+							       strict);
 				if (err < 0)
 					return err;
 			}
@@ -1637,7 +1638,8 @@ static int do_set_master(struct net_device *dev, int ifindex)
 #define DO_SETLINK_NOTIFY	0x03
 static int do_setlink(const struct sk_buff *skb,
 		      struct net_device *dev, struct ifinfomsg *ifm,
-		      struct nlattr **tb, char *ifname, int status)
+		      struct nlattr **tb, char *ifname, int status,
+		      bool strict)
 {
 	const struct net_device_ops *ops = dev->netdev_ops;
 	int err;
@@ -1799,8 +1801,9 @@ static int do_setlink(const struct sk_buff *skb,
 				err = -EINVAL;
 				goto errout;
 			}
-			err = nla_parse_nested(vfinfo, IFLA_VF_MAX, attr,
-					       ifla_vf_policy);
+			err = nla_strict_parse_nested(vfinfo, IFLA_VF_MAX,
+						      strict, attr,
+						      ifla_vf_policy);
 			if (err < 0)
 				goto errout;
 			err = do_setvfinfo(dev, vfinfo);
@@ -1827,8 +1830,9 @@ static int do_setlink(const struct sk_buff *skb,
 				err = -EINVAL;
 				goto errout;
 			}
-			err = nla_parse_nested(port, IFLA_PORT_MAX, attr,
-					       ifla_port_policy);
+			err = nla_strict_parse_nested(port, IFLA_PORT_MAX,
+						      strict, attr,
+						      ifla_port_policy);
 			if (err < 0)
 				goto errout;
 			if (!port[IFLA_PORT_VF]) {
@@ -1847,8 +1851,9 @@ static int do_setlink(const struct sk_buff *skb,
 	if (tb[IFLA_PORT_SELF]) {
 		struct nlattr *port[IFLA_PORT_MAX+1];
 
-		err = nla_parse_nested(port, IFLA_PORT_MAX,
-			tb[IFLA_PORT_SELF], ifla_port_policy);
+		err = nla_strict_parse_nested(port, IFLA_PORT_MAX, strict,
+					      tb[IFLA_PORT_SELF],
+					      ifla_port_policy);
 		if (err < 0)
 			goto errout;
 
@@ -1908,8 +1913,10 @@ static int rtnl_setlink(struct sk_buff *skb, struct nlmsghdr *nlh)
 	int err;
 	struct nlattr *tb[IFLA_MAX+1];
 	char ifname[IFNAMSIZ];
+	bool strict = nlh->nlmsg_flags & NLM_F_STRICT;
 
-	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFLA_MAX, ifla_policy);
+	err = nlmsg_strict_parse(nlh, sizeof(*ifm), tb, IFLA_MAX, strict,
+				 ifla_policy);
 	if (err < 0)
 		goto errout;
 
@@ -1932,11 +1939,11 @@ static int rtnl_setlink(struct sk_buff *skb, struct nlmsghdr *nlh)
 		goto errout;
 	}
 
-	err = validate_linkmsg(dev, tb);
+	err = validate_linkmsg(dev, tb, strict);
 	if (err < 0)
 		goto errout;
 
-	err = do_setlink(skb, dev, ifm, tb, ifname, 0);
+	err = do_setlink(skb, dev, ifm, tb, ifname, 0, strict);
 errout:
 	return err;
 }
@@ -2000,9 +2007,11 @@ static int rtnl_dellink(struct sk_buff *skb, struct nlmsghdr *nlh)
 	struct ifinfomsg *ifm;
 	char ifname[IFNAMSIZ];
 	struct nlattr *tb[IFLA_MAX+1];
+	bool strict = nlh->nlmsg_flags & NLM_F_STRICT;
 	int err;
 
-	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFLA_MAX, ifla_policy);
+	err = nlmsg_strict_parse(nlh, sizeof(*ifm), tb, IFLA_MAX, strict,
+				 ifla_policy);
 	if (err < 0)
 		return err;
 
@@ -2102,14 +2111,14 @@ EXPORT_SYMBOL(rtnl_create_link);
 static int rtnl_group_changelink(const struct sk_buff *skb,
 		struct net *net, int group,
 		struct ifinfomsg *ifm,
-		struct nlattr **tb)
+		struct nlattr **tb, bool strict)
 {
 	struct net_device *dev, *aux;
 	int err;
 
 	for_each_netdev_safe(net, dev, aux) {
 		if (dev->group == group) {
-			err = do_setlink(skb, dev, ifm, tb, NULL, 0);
+			err = do_setlink(skb, dev, ifm, tb, NULL, 0, strict);
 			if (err < 0)
 				return err;
 		}
@@ -2131,12 +2140,14 @@ static int rtnl_newlink(struct sk_buff *skb, struct nlmsghdr *nlh)
 	struct nlattr *tb[IFLA_MAX+1];
 	struct nlattr *linkinfo[IFLA_INFO_MAX+1];
 	unsigned char name_assign_type = NET_NAME_USER;
+	bool strict = nlh->nlmsg_flags & NLM_F_STRICT;
 	int err;
 
 #ifdef CONFIG_MODULES
 replay:
 #endif
-	err = nlmsg_parse(nlh, sizeof(*ifm), tb, IFLA_MAX, ifla_policy);
+	err = nlmsg_strict_parse(nlh, sizeof(*ifm), tb, IFLA_MAX, strict,
+				 ifla_policy);
 	if (err < 0)
 		return err;
 
@@ -2161,13 +2172,14 @@ replay:
 			m_ops = master_dev->rtnl_link_ops;
 	}
 
-	err = validate_linkmsg(dev, tb);
+	err = validate_linkmsg(dev, tb, strict);
 	if (err < 0)
 		return err;
 
 	if (tb[IFLA_LINKINFO]) {
-		err = nla_parse_nested(linkinfo, IFLA_INFO_MAX,
-				       tb[IFLA_LINKINFO], ifla_info_policy);
+		err = nla_strict_parse_nested(linkinfo, IFLA_INFO_MAX,
+					      strict, tb[IFLA_LINKINFO],
+					      ifla_info_policy);
 		if (err < 0)
 			return err;
 	} else
@@ -2190,15 +2202,16 @@ replay:
 
 		if (ops) {
 			if (ops->maxtype && linkinfo[IFLA_INFO_DATA]) {
-				err = nla_parse_nested(attr, ops->maxtype,
-						       linkinfo[IFLA_INFO_DATA],
-						       ops->policy);
+				err = nla_strict_parse_nested(attr, ops->maxtype,
+							      strict,
+							      linkinfo[IFLA_INFO_DATA],
+							      ops->policy);
 				if (err < 0)
 					return err;
 				data = attr;
 			}
 			if (ops->validate) {
-				err = ops->validate(tb, data, false);
+				err = ops->validate(tb, data, strict);
 				if (err < 0)
 					return err;
 			}
@@ -2207,17 +2220,18 @@ replay:
 		if (m_ops) {
 			if (m_ops->slave_maxtype &&
 			    linkinfo[IFLA_INFO_SLAVE_DATA]) {
-				err = nla_parse_nested(slave_attr,
-						       m_ops->slave_maxtype,
-						       linkinfo[IFLA_INFO_SLAVE_DATA],
-						       m_ops->slave_policy);
+				err = nla_strict_parse_nested(slave_attr,
+							      m_ops->slave_maxtype,
+							      strict,
+							      linkinfo[IFLA_INFO_SLAVE_DATA],
+							      m_ops->slave_policy);
 				if (err < 0)
 					return err;
 				slave_data = slave_attr;
 			}
 			if (m_ops->slave_validate) {
 				err = m_ops->slave_validate(tb, slave_data,
-							    false);
+							    strict);
 				if (err < 0)
 					return err;
 			}
@@ -2253,14 +2267,15 @@ replay:
 				status |= DO_SETLINK_NOTIFY;
 			}
 
-			return do_setlink(skb, dev, ifm, tb, ifname, status);
+			return do_setlink(skb, dev, ifm, tb, ifname, status,
+					  strict);
 		}
 
 		if (!(nlh->nlmsg_flags & NLM_F_CREATE)) {
 			if (ifm->ifi_index == 0 && tb[IFLA_GROUP])
 				return rtnl_group_changelink(skb, net,
 						nla_get_u32(tb[IFLA_GROUP]),
-						ifm, tb);
+						ifm, tb, strict);
 			return -ENODEV;
 		}
 
@@ -3443,9 +3458,12 @@ void __init rtnetlink_init(void)
 
 	rtnl_register(PF_UNSPEC, RTM_GETLINK, rtnl_getlink,
 		      rtnl_dump_ifinfo, rtnl_calcit);
-	rtnl_register(PF_UNSPEC, RTM_SETLINK, rtnl_setlink, NULL, NULL);
-	rtnl_register(PF_UNSPEC, RTM_NEWLINK, rtnl_newlink, NULL, NULL);
-	rtnl_register(PF_UNSPEC, RTM_DELLINK, rtnl_dellink, NULL, NULL);
+	rtnl_register_flags(PF_UNSPEC, RTM_SETLINK, rtnl_setlink, NULL, NULL,
+			    RTNL_F_STRICT);
+	rtnl_register_flags(PF_UNSPEC, RTM_NEWLINK, rtnl_newlink, NULL, NULL,
+			    RTNL_F_STRICT);
+	rtnl_register_flags(PF_UNSPEC, RTM_DELLINK, rtnl_dellink, NULL, NULL,
+			    RTNL_F_STRICT);
 
 	rtnl_register(PF_UNSPEC, RTM_GETADDR, NULL, rtnl_dump_all, NULL);
 	rtnl_register(PF_UNSPEC, RTM_GETROUTE, NULL, rtnl_dump_all, NULL);
-- 
1.8.3.1
