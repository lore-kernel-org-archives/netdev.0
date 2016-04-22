From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH net v2 2/9] macsec: take rtnl lock before for_each_netdev
Date: Fri, 22 Apr 2016 11:28:02 +0200
Message-ID: <7cbdf80a0b692611d0e0303ebc5f6a7628747413.1461315621.git.sd@queasysnail.net>
References: <cover.1461315621.git.sd@queasysnail.net>
Cc: Lance Richardson <lrichard@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	Sabrina Dubroca <sd@queasysnail.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60098 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754064AbcDVJ2d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Apr 2016 05:28:33 -0400
In-Reply-To: <cover.1461315621.git.sd@queasysnail.net>
In-Reply-To: <cover.1461315621.git.sd@queasysnail.net>
References: <cover.1461315621.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes: c09440f7dcb3 ("macsec: introduce IEEE 802.1AE driver")
Reported-by: Johannes Berg <johannes@sipsolutions.net>
Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 drivers/net/macsec.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/macsec.c b/drivers/net/macsec.c
index f691030ee3df..5f3ea8026074 100644
--- a/drivers/net/macsec.c
+++ b/drivers/net/macsec.c
@@ -2268,8 +2268,6 @@ static int dump_secy(struct macsec_secy *secy, struct net_device *dev,
 	if (!hdr)
 		return -EMSGSIZE;
 
-	rtnl_lock();
-
 	if (nla_put_u32(skb, MACSEC_ATTR_IFINDEX, dev->ifindex))
 		goto nla_put_failure;
 
@@ -2429,14 +2427,11 @@ static int dump_secy(struct macsec_secy *secy, struct net_device *dev,
 
 	nla_nest_end(skb, rxsc_list);
 
-	rtnl_unlock();
-
 	genlmsg_end(skb, hdr);
 
 	return 0;
 
 nla_put_failure:
-	rtnl_unlock();
 	genlmsg_cancel(skb, hdr);
 	return -EMSGSIZE;
 }
@@ -2450,6 +2445,7 @@ static int macsec_dump_txsc(struct sk_buff *skb, struct netlink_callback *cb)
 	dev_idx = cb->args[0];
 
 	d = 0;
+	rtnl_lock();
 	for_each_netdev(net, dev) {
 		struct macsec_secy *secy;
 
@@ -2467,6 +2463,7 @@ next:
 	}
 
 done:
+	rtnl_unlock();
 	cb->args[0] = d;
 	return skb->len;
 }
-- 
2.8.0
