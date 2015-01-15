From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next v5 4/4] rtnl: allow to create device with IFLA_LINK_NETNSID set
Date: Thu, 15 Jan 2015 15:11:18 +0100
Message-ID: <1421331078-21622-5-git-send-email-nicolas.dichtel@6wind.com>
References: <87wq7g831b.fsf@x220.int.ebiederm.org>
 <1421331078-21622-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, ebiederm@xmission.com,
	stephen@networkplumber.org, akpm@linux-foundation.org,
	luto@amacapital.net, cwang@twopensource.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, linux-api@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:49141 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754852AbbAOOLm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 09:11:42 -0500
In-Reply-To: <1421331078-21622-1-git-send-email-nicolas.dichtel@6wind.com>
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
index ab78ba9a34e8..b2f6d8285a24 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1247,6 +1247,7 @@ static const struct nla_policy ifla_policy[IFLA_MAX+1] = {
 	[IFLA_PHYS_PORT_ID]	= { .type = NLA_BINARY, .len = MAX_PHYS_ITEM_ID_LEN },
 	[IFLA_CARRIER_CHANGES]	= { .type = NLA_U32 },  /* ignored */
 	[IFLA_PHYS_SWITCH_ID]	= { .type = NLA_BINARY, .len = MAX_PHYS_ITEM_ID_LEN },
+	[IFLA_LINK_NETNSID]	= { .type = NLA_S32 },
 };
 
 static const struct nla_policy ifla_info_policy[IFLA_INFO_MAX+1] = {
@@ -2020,7 +2021,7 @@ replay:
 		struct nlattr *slave_attr[m_ops ? m_ops->slave_maxtype + 1 : 0];
 		struct nlattr **data = NULL;
 		struct nlattr **slave_data = NULL;
-		struct net *dest_net;
+		struct net *dest_net, *link_net = NULL;
 
 		if (ops) {
 			if (ops->maxtype && linkinfo[IFLA_INFO_DATA]) {
@@ -2126,7 +2127,18 @@ replay:
 		if (IS_ERR(dest_net))
 			return PTR_ERR(dest_net);
 
-		dev = rtnl_create_link(dest_net, ifname, name_assign_type, ops, tb);
+		if (tb[IFLA_LINK_NETNSID]) {
+			int id = nla_get_s32(tb[IFLA_LINK_NETNSID]);
+
+			link_net = get_net_ns_by_id(dest_net, id);
+			if (!link_net) {
+				err =  -EINVAL;
+				goto out;
+			}
+		}
+
+		dev = rtnl_create_link(link_net ? : dest_net, ifname,
+				       name_assign_type, ops, tb);
 		if (IS_ERR(dev)) {
 			err = PTR_ERR(dev);
 			goto out;
@@ -2154,9 +2166,16 @@ replay:
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
+			err = dev_change_net_namespace(dev, dest_net, ifname);
 out:
+		if (link_net)
+			put_net(link_net);
 		put_net(dest_net);
 		return err;
 	}
-- 
2.2.2
