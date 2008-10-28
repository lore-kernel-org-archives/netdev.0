From: Vivien Chappelier <vivien.chappelier@thomson.net>
Subject: [PATCH 5/6] netlink: add IFLA_NET_NS to move interface to network
	namespace by nsid
Date: Tue, 28 Oct 2008 18:45:54 +0100
Message-ID: <20081028174554.GE8471@thomson.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Benjamin Thery <benjamin.thery@bull.net>, jleu@mindspring.com,
	linux-vrf-general@lists.sourceforge.net
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.thmulti.com ([141.11.234.72]:33468 "EHLO
	dmzraw4.extranet.thmulti.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752745AbYJ1Rp4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2008 13:45:56 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This corresponds exactly to IFLA_NET_NS_PID except it takes a nsid parameter instead of a pid.
---
 include/linux/if_link.h |    1 +
 net/core/rtnetlink.c    |   16 ++++++++++++++++
 2 files changed, 17 insertions(+), 0 deletions(-)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index f9032c8..9e473eb 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -80,6 +80,7 @@ enum
 #define IFLA_LINKINFO IFLA_LINKINFO
 	IFLA_NET_NS_PID,
 	IFLA_IFALIAS,
+	IFLA_NET_NS,
 	__IFLA_MAX
 };
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 31f29d2..3e90c0b 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -718,6 +718,7 @@ const struct nla_policy ifla_policy[IFLA_MAX+1] = {
 	[IFLA_LINKINFO]		= { .type = NLA_NESTED },
 	[IFLA_NET_NS_PID]	= { .type = NLA_U32 },
 	[IFLA_IFALIAS]	        = { .type = NLA_STRING, .len = IFALIASZ-1 },
+	[IFLA_NET_NS]		= { .type = NLA_U32 },
 };
 
 static const struct nla_policy ifla_info_policy[IFLA_INFO_MAX+1] = {
@@ -779,6 +780,21 @@ static int do_setlink(struct net_device *dev, struct ifinfomsg *ifm,
 		modified = 1;
 	}
 
+	if (tb[IFLA_NET_NS]) {
+		struct net *net;
+
+		net = __get_net_ns_by_id(nla_get_u32(tb[IFLA_NET_NS]));
+		if (net == NULL) {
+			err = -EINVAL;
+			goto errout;
+		}
+		err = dev_change_net_namespace(dev, net, ifname);
+		put_net(net);
+		if (err)
+			goto errout;
+		modified = 1;
+	}
+
 	if (tb[IFLA_MAP]) {
 		struct rtnl_link_ifmap *u_map;
 		struct ifmap k_map;
-- 
1.5.4.4

