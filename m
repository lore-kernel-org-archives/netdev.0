From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 5/5] bridge: implement rtnl_link_ops->changelink
Date: Fri,  5 Sep 2014 15:51:32 +0200
Message-ID: <1409925092-17808-6-git-send-email-jiri@resnulli.us>
References: <1409925092-17808-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, stephen@networkplumber.org,
	sfeldma@cumulusnetworks.com, arvid.brodin@alten.se,
	sucheta.chakraborty@qlogic.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:45706 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932273AbaIENv6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2014 09:51:58 -0400
Received: by mail-wi0-f181.google.com with SMTP id e4so3011393wiv.14
        for <netdev@vger.kernel.org>; Fri, 05 Sep 2014 06:51:52 -0700 (PDT)
In-Reply-To: <1409925092-17808-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow rtnetlink users to set bridge master info via IFLA_INFO_DATA attr
This initial part implements forward_delay, hello_time, max_age options.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/bridge/br_netlink.c | 39 +++++++++++++++++++++++++++++++++++++++
 1 file changed, 39 insertions(+)

diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index bcac09f..7c97a26 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -484,6 +484,42 @@ static size_t br_port_get_slave_size(const struct net_device *brdev,
 	return br_port_info_size();
 }
 
+static const struct nla_policy br_policy[IFLA_BR_MAX + 1] = {
+	[IFLA_BR_FORWARD_DELAY]	= { .type = NLA_U32 },
+	[IFLA_BR_HELLO_TIME]	= { .type = NLA_U32 },
+	[IFLA_BR_MAX_AGE]	= { .type = NLA_U32 },
+};
+
+static int br_changelink(struct net_device *brdev, struct nlattr *tb[],
+			 struct nlattr *data[])
+{
+	struct net_bridge *br = netdev_priv(brdev);
+	int err;
+
+	if (!data)
+		return 0;
+
+	if (data[IFLA_BR_FORWARD_DELAY]) {
+		err = br_set_forward_delay(br, nla_get_u32(data[IFLA_BR_FORWARD_DELAY]));
+		if (err)
+			return err;
+	}
+
+	if (data[IFLA_BR_HELLO_TIME]) {
+		err = br_set_hello_time(br, nla_get_u32(data[IFLA_BR_HELLO_TIME]));
+		if (err)
+			return err;
+	}
+
+	if (data[IFLA_BR_MAX_AGE]) {
+		err = br_set_max_age(br, nla_get_u32(data[IFLA_BR_MAX_AGE]));
+		if (err)
+			return err;
+	}
+
+	return 0;
+}
+
 static size_t br_get_size(const struct net_device *brdev)
 {
 	return nla_total_size(sizeof(u32)) +	/* IFLA_BR_FORWARD_DELAY  */
@@ -534,8 +570,11 @@ struct rtnl_link_ops br_link_ops __read_mostly = {
 	.kind			= "bridge",
 	.priv_size		= sizeof(struct net_bridge),
 	.setup			= br_dev_setup,
+	.maxtype		= IFLA_BRPORT_MAX,
+	.policy			= br_policy,
 	.validate		= br_validate,
 	.newlink		= br_dev_newlink,
+	.changelink		= br_changelink,
 	.dellink		= br_dev_delete,
 	.get_size		= br_get_size,
 	.fill_info		= br_fill_info,
-- 
1.9.3
