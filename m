From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 5/5] bridge: Sanitize IFLA_EXT_MASK for AF_BRIDGE:RTM_GETLINK
Date: Wed, 26 Nov 2014 13:42:20 +0100
Message-ID: <e88d89f25d1f6f110cef58074323c0253be7a5db.1417005245.git.tgraf@suug.ch>
References: <cover.1417005245.git.tgraf@suug.ch>
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
	Vlad Yasevich <vyasevic@redhat.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:56934 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750969AbaKZMme (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2014 07:42:34 -0500
In-Reply-To: <cover.1417005245.git.tgraf@suug.ch>
In-Reply-To: <cover.1417005245.git.tgraf@suug.ch>
References: <cover.1417005245.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Only search for IFLA_EXT_MASK if the message actually carries a
ifinfomsg header and validate minimal length requirements for
IFLA_EXT_MASK.

Fixes: 6cbdceeb ("bridge: Dump vlan information from a bridge port")
Cc: Vlad Yasevich <vyasevic@redhat.com>
Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 net/core/rtnetlink.c | 17 ++++++++++++-----
 1 file changed, 12 insertions(+), 5 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 5a853f8..b9b7dfa 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2685,13 +2685,20 @@ static int rtnl_bridge_getlink(struct sk_buff *skb, struct netlink_callback *cb)
 	int idx = 0;
 	u32 portid = NETLINK_CB(cb->skb).portid;
 	u32 seq = cb->nlh->nlmsg_seq;
-	struct nlattr *extfilt;
 	u32 filter_mask = 0;
 
-	extfilt = nlmsg_find_attr(cb->nlh, sizeof(struct ifinfomsg),
-				  IFLA_EXT_MASK);
-	if (extfilt)
-		filter_mask = nla_get_u32(extfilt);
+	if (nlmsg_len(cb->nlh) > sizeof(struct ifinfomsg)) {
+		struct nlattr *extfilt;
+
+		extfilt = nlmsg_find_attr(cb->nlh, sizeof(struct ifinfomsg),
+					  IFLA_EXT_MASK);
+		if (extfilt) {
+			if (nla_len(extfilt) < sizeof(filter_mask))
+				return -EINVAL;
+
+			filter_mask = nla_get_u32(extfilt);
+		}
+	}
 
 	rcu_read_lock();
 	for_each_netdev_rcu(net, dev) {
-- 
1.9.3
