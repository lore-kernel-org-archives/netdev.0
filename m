From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] phonet netlink: allow multiple messages per skb in route dump
Date: Mon, 19 Jan 2015 12:15:24 +0100
Message-ID: <1421666124-16055-1-git-send-email-johannes@sipsolutions.net>
Cc: Sakari Ailus <sakari.ailus@nokia.com>,
	Remi Denis-Courmont <courmisch@gmail.com>,
	Johannes Berg <johannes.berg@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:33150 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751143AbbASLPd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Jan 2015 06:15:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

My previous patch to this file changed the code to be bug-compatible
towards userspace. Unless userspace (which I wasn't able to find)
implements the dump reader by hand in a wrong way, this isn't needed.
If it uses libnl or similar code putting multiple messages into a
single SKB is far more efficient.

Change the code to do this. While at it, also clean it up and don't
use so many variables - just store the address in the callback args
directly.

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 net/phonet/pn_netlink.c | 22 +++++++---------------
 1 file changed, 7 insertions(+), 15 deletions(-)

diff --git a/net/phonet/pn_netlink.c b/net/phonet/pn_netlink.c
index 54d766842c2b..bc5ee5fbe6ae 100644
--- a/net/phonet/pn_netlink.c
+++ b/net/phonet/pn_netlink.c
@@ -272,31 +272,23 @@ static int route_doit(struct sk_buff *skb, struct nlmsghdr *nlh)
 static int route_dumpit(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	struct net *net = sock_net(skb->sk);
-	u8 addr, addr_idx = 0, addr_start_idx = cb->args[0];
+	u8 addr;
 
 	rcu_read_lock();
-	for (addr = 0; addr < 64; addr++) {
-		struct net_device *dev;
+	for (addr = cb->args[0]; addr < 64; addr++) {
+		struct net_device *dev = phonet_route_get_rcu(net, addr << 2);
 
-		dev = phonet_route_get_rcu(net, addr << 2);
 		if (!dev)
 			continue;
 
-		if (addr_idx++ < addr_start_idx)
-			continue;
-		fill_route(skb, dev, addr << 2, NETLINK_CB(cb->skb).portid,
-			   cb->nlh->nlmsg_seq, RTM_NEWROUTE);
-		/* fill_route() used to return > 0 (or negative errors) but
-		 * never 0 - ignore the return value and just go out to
-		 * call dumpit again from outside to preserve the behavior
-		 */
-		goto out;
+		if (fill_route(skb, dev, addr << 2, NETLINK_CB(cb->skb).portid,
+			       cb->nlh->nlmsg_seq, RTM_NEWROUTE) < 0)
+			goto out;
 	}
 
 out:
 	rcu_read_unlock();
-	cb->args[0] = addr_idx;
-	cb->args[1] = 0;
+	cb->args[0] = addr;
 
 	return skb->len;
 }
-- 
2.1.4
