From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [RFC PATCH net-next 3/5] dev/netns: allow to get netns from nsindex in rtnl msg
Date: Wed, 12 Dec 2012 18:17:08 +0100
Message-ID: <1355332630-4256-4-git-send-email-nicolas.dichtel@6wind.com>
References: <1355332630-4256-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, ebiederm@xmission.com, aatteka@nicira.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:39198 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754563Ab2LLRxv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2012 12:53:51 -0500
In-Reply-To: <1355332630-4256-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch allows to move a netdevice to another netns by giving the nsindex.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/net/net_namespace.h  |  1 +
 include/uapi/linux/if_link.h |  1 +
 net/core/net_namespace.c     | 14 ++++++++++++++
 net/core/rtnetlink.c         |  7 ++++++-
 4 files changed, 22 insertions(+), 1 deletion(-)

diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index c373f2e..68e7a36 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -151,6 +151,7 @@ extern struct list_head net_namespace_list;
 
 extern struct net *get_net_ns_by_pid(pid_t pid);
 extern struct net *get_net_ns_by_fd(int pid);
+extern struct net *get_net_ns_by_nsindex(int nsindex);
 
 #ifdef CONFIG_NET_NS
 extern void __put_net(struct net *net);
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 60f3b6b..6720a47 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -142,6 +142,7 @@ enum {
 #define IFLA_PROMISCUITY IFLA_PROMISCUITY
 	IFLA_NUM_TX_QUEUES,
 	IFLA_NUM_RX_QUEUES,
+	IFLA_NET_NS_INDEX,
 	__IFLA_MAX
 };
 
diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index 2ae22b0..18fc62f 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -399,6 +399,20 @@ struct net *get_net_ns_by_pid(pid_t pid)
 }
 EXPORT_SYMBOL_GPL(get_net_ns_by_pid);
 
+struct net *get_net_ns_by_nsindex(int nsindex)
+{
+	struct net *net;
+
+	ASSERT_RTNL();
+	for_each_net(net)
+		if (net->nsindex == nsindex) {
+			get_net(net);
+			break;
+		}
+	return net;
+}
+EXPORT_SYMBOL_GPL(get_net_ns_by_nsindex);
+
 static struct genl_family netns_nl_family = {
 	.id		= GENL_ID_GENERATE,
 	.name		= NETNS_GENL_NAME,
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 1868625..e22954a 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1115,6 +1115,7 @@ const struct nla_policy ifla_policy[IFLA_MAX+1] = {
 	[IFLA_LINKINFO]		= { .type = NLA_NESTED },
 	[IFLA_NET_NS_PID]	= { .type = NLA_U32 },
 	[IFLA_NET_NS_FD]	= { .type = NLA_U32 },
+	[IFLA_NET_NS_INDEX]	= { .type = NLA_U32 },
 	[IFLA_IFALIAS]	        = { .type = NLA_STRING, .len = IFALIASZ-1 },
 	[IFLA_VFINFO_LIST]	= {. type = NLA_NESTED },
 	[IFLA_VF_PORTS]		= { .type = NLA_NESTED },
@@ -1171,6 +1172,8 @@ struct net *rtnl_link_get_net(struct net *src_net, struct nlattr *tb[])
 		net = get_net_ns_by_pid(nla_get_u32(tb[IFLA_NET_NS_PID]));
 	else if (tb[IFLA_NET_NS_FD])
 		net = get_net_ns_by_fd(nla_get_u32(tb[IFLA_NET_NS_FD]));
+	else if (tb[IFLA_NET_NS_INDEX])
+		net = get_net_ns_by_nsindex(nla_get_u32(tb[IFLA_NET_NS_INDEX]));
 	else
 		net = get_net(src_net);
 	return net;
@@ -1310,7 +1313,9 @@ static int do_setlink(struct net_device *dev, struct ifinfomsg *ifm,
 	int send_addr_notify = 0;
 	int err;
 
-	if (tb[IFLA_NET_NS_PID] || tb[IFLA_NET_NS_FD]) {
+	if (tb[IFLA_NET_NS_PID] ||
+	    tb[IFLA_NET_NS_FD] ||
+	    tb[IFLA_NET_NS_INDEX]) {
 		struct net *net = rtnl_link_get_net(dev_net(dev), tb);
 		if (IS_ERR(net)) {
 			err = PTR_ERR(net);
-- 
1.8.0.1
