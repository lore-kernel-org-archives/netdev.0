From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [RFC PATCH net-next 5/5] rtnl: allow to create device with IFLA_LINK_NETNSID set
Date: Wed,  2 Jul 2014 13:59:06 +0200
Message-ID: <1404302346-4507-6-git-send-email-nicolas.dichtel@6wind.com>
References: <537327F1.4060603@6wind.com>
 <1404302346-4507-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, ebiederm@xmission.com,
	stephen@networkplumber.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:53376 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751056AbaGBMIm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2014 08:08:42 -0400
In-Reply-To: <1404302346-4507-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the ability to create a netdevice in a specified netns and
then move it into the final netns. In fact, it allows to have a symetry between
get and set rtnl messages.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/core/rtnetlink.c | 25 ++++++++++++++++++++++---
 1 file changed, 22 insertions(+), 3 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index d99b98b41045..37fb96f51d2b 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1211,6 +1211,7 @@ static const struct nla_policy ifla_policy[IFLA_MAX+1] = {
 	[IFLA_NUM_RX_QUEUES]	= { .type = NLA_U32 },
 	[IFLA_PHYS_PORT_ID]	= { .type = NLA_BINARY, .len = MAX_PHYS_PORT_ID_LEN },
 	[IFLA_CARRIER_CHANGES]	= { .type = NLA_U32 },  /* ignored */
+	[IFLA_LINK_NETNSID]	= { .type = NLA_U32 },
 };
 
 static const struct nla_policy ifla_info_policy[IFLA_INFO_MAX+1] = {
@@ -1963,7 +1964,7 @@ replay:
 		struct nlattr *slave_attr[m_ops ? m_ops->slave_maxtype + 1 : 0];
 		struct nlattr **data = NULL;
 		struct nlattr **slave_data = NULL;
-		struct net *dest_net;
+		struct net *dest_net, *link_net = NULL;
 
 		if (ops) {
 			if (ops->maxtype && linkinfo[IFLA_INFO_DATA]) {
@@ -2067,7 +2068,18 @@ replay:
 		if (IS_ERR(dest_net))
 			return PTR_ERR(dest_net);
 
-		dev = rtnl_create_link(dest_net, ifname, ops, tb);
+		if (tb[IFLA_LINK_NETNSID]) {
+			link_net =
+				get_net_from_netnsid(dest_net,
+						     nla_get_u32(tb[IFLA_LINK_NETNSID]));
+
+			if (link_net &&
+			    !netlink_ns_capable(skb, link_net->user_ns,
+						CAP_NET_ADMIN))
+				return -EPERM;
+		}
+
+		dev = rtnl_create_link(link_net ? : dest_net, ifname, ops, tb);
 		if (IS_ERR(dev)) {
 			err = PTR_ERR(dev);
 			goto out;
@@ -2095,9 +2107,16 @@ replay:
 			}
 		}
 		err = rtnl_configure_link(dev, ifm);
-		if (err < 0)
+		if (err < 0) {
 			unregister_netdevice(dev);
+			goto out;
+		}
+
+		if (link_net)
+			err = dev_change_net_namespace(dev, net, ifname);
 out:
+		if (link_net)
+			put_net(link_net);
 		put_net(dest_net);
 		return err;
 	}
-- 
1.9.0
