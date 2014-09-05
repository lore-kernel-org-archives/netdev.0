From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 3/5] bridge: implement rtnl_link_ops->slave_changelink
Date: Fri,  5 Sep 2014 15:51:30 +0200
Message-ID: <1409925092-17808-4-git-send-email-jiri@resnulli.us>
References: <1409925092-17808-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, stephen@networkplumber.org,
	sfeldma@cumulusnetworks.com, arvid.brodin@alten.se,
	sucheta.chakraborty@qlogic.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f52.google.com ([74.125.82.52]:52540 "EHLO
	mail-wg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932273AbaIENvy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2014 09:51:54 -0400
Received: by mail-wg0-f52.google.com with SMTP id m15so11679577wgh.23
        for <netdev@vger.kernel.org>; Fri, 05 Sep 2014 06:51:48 -0700 (PDT)
In-Reply-To: <1409925092-17808-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow rtnetlink users to set port info via IFLA_INFO_SLAVE_DATA attr

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/bridge/br_netlink.c | 18 ++++++++++++++++--
 1 file changed, 16 insertions(+), 2 deletions(-)

diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 80d2347..05aeea1 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -276,7 +276,7 @@ static int br_afspec(struct net_bridge *br,
 	return err;
 }
 
-static const struct nla_policy ifla_brport_policy[IFLA_BRPORT_MAX + 1] = {
+static const struct nla_policy br_port_policy[IFLA_BRPORT_MAX + 1] = {
 	[IFLA_BRPORT_STATE]	= { .type = NLA_U8 },
 	[IFLA_BRPORT_COST]	= { .type = NLA_U32 },
 	[IFLA_BRPORT_PRIORITY]	= { .type = NLA_U16 },
@@ -382,7 +382,7 @@ int br_setlink(struct net_device *dev, struct nlmsghdr *nlh)
 	if (p && protinfo) {
 		if (protinfo->nla_type & NLA_F_NESTED) {
 			err = nla_parse_nested(tb, IFLA_BRPORT_MAX,
-					       protinfo, ifla_brport_policy);
+					       protinfo, br_port_policy);
 			if (err)
 				return err;
 
@@ -461,6 +461,16 @@ static int br_dev_newlink(struct net *src_net, struct net_device *dev,
 	return register_netdevice(dev);
 }
 
+static int br_port_slave_changelink(struct net_device *brdev,
+				    struct net_device *dev,
+				    struct nlattr *tb[],
+				    struct nlattr *data[])
+{
+	if (!data)
+		return 0;
+	return br_setport(br_port_get_rtnl(dev), data);
+}
+
 static int br_port_fill_slave_info(struct sk_buff *skb,
 				   const struct net_device *brdev,
 				   const struct net_device *dev)
@@ -504,6 +514,10 @@ struct rtnl_link_ops br_link_ops __read_mostly = {
 	.validate		= br_validate,
 	.newlink		= br_dev_newlink,
 	.dellink		= br_dev_delete,
+
+	.slave_maxtype		= IFLA_BRPORT_MAX,
+	.slave_policy		= br_port_policy,
+	.slave_changelink	= br_port_slave_changelink,
 	.get_slave_size		= br_port_get_slave_size,
 	.fill_slave_info	= br_port_fill_slave_info,
 };
-- 
1.9.3
