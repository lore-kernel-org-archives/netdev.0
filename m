From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next] net: Fix continued iteration in
 rtnl_bridge_getlink()
Date: Fri, 2 Nov 2012 22:56:52 +0000
Message-ID: <1351897012.2703.17.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	John Fastabend <john.r.fastabend@intel.com>,
	Stephen Hemminger <shemminger@vyatta.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:50222 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1759634Ab2KBW44 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Nov 2012 18:56:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit e5a55a898720096f43bc24938f8875c0a1b34cd7 ('net: create generic
bridge ops') broke the handling of a non-zero starting index in
rtnl_bridge_getlink() (based on the old br_dump_ifinfo()).

When the starting index is non-zero, we need to increment the current
index for each entry that we are skipping.  Also, we need to check the
index before both cases, since we may previously have stopped
iteration between getting information about a device from its master
and from itself.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
This is compile-tested only, as I don't know what userland code to test
with.  I'm still not sure it's correct to break iteration if
ndo_bridge_getlink returns -EOPNOTSUPP (possible if the driver supports
a mixture of bridging and non-bridging devices).

Ben.

 net/core/rtnetlink.c |   23 +++++++----------------
 1 files changed, 7 insertions(+), 16 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 51dc58f..a0e35076 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2315,28 +2315,19 @@ static int rtnl_bridge_getlink(struct sk_buff *skb, struct netlink_callback *cb)
 		const struct net_device_ops *ops = dev->netdev_ops;
 		struct net_device *master = dev->master;
 
-		if (idx < cb->args[0])
-			continue;
-
 		if (master && master->netdev_ops->ndo_bridge_getlink) {
-			const struct net_device_ops *bops = master->netdev_ops;
-			int err = bops->ndo_bridge_getlink(skb, portid,
-							   seq, dev);
-
-			if (err < 0)
+			if (idx >= cb->args[0] &&
+			    master->netdev_ops->ndo_bridge_getlink(
+				    skb, portid, seq, dev) < 0)
 				break;
-			else
-				idx++;
+			idx++;
 		}
 
 		if (ops->ndo_bridge_getlink) {
-			int err = ops->ndo_bridge_getlink(skb, portid,
-							  seq, dev);
-
-			if (err < 0)
+			if (idx >= cb->args[0] &&
+			    ops->ndo_bridge_getlink(skb, portid, seq, dev) < 0)
 				break;
-			else
-				idx++;
+			idx++;
 		}
 	}
 	rcu_read_unlock();
-- 
1.7.7.6


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
