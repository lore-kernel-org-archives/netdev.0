From: David Miller <davem@davemloft.net>
Subject: [PATCH 3/18] netfilter: ebt_ulog: Move away from NLMSG_PUT().
Date: Tue, 26 Jun 2012 22:02:09 -0700 (PDT)
Message-ID: <20120626.220209.105965835466925156.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39193 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751470Ab2F0FCK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 01:02:10 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 31065584192
	for <netdev@vger.kernel.org>; Tue, 26 Jun 2012 22:02:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


And use nlmsg_data() while we're here too.

Also, free and NULL out skb when nlmsg_put() fails and remove
pointless kernel log message.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/bridge/netfilter/ebt_ulog.c |   23 ++++++++++-------------
 1 file changed, 10 insertions(+), 13 deletions(-)

diff --git a/net/bridge/netfilter/ebt_ulog.c b/net/bridge/netfilter/ebt_ulog.c
index 5449294..1bd1732 100644
--- a/net/bridge/netfilter/ebt_ulog.c
+++ b/net/bridge/netfilter/ebt_ulog.c
@@ -145,19 +145,24 @@ static void ebt_ulog_packet(unsigned int hooknr, const struct sk_buff *skb,
 
 	if (!ub->skb) {
 		if (!(ub->skb = ulog_alloc_skb(size)))
-			goto alloc_failure;
+			goto unlock;
 	} else if (size > skb_tailroom(ub->skb)) {
 		ulog_send(group);
 
 		if (!(ub->skb = ulog_alloc_skb(size)))
-			goto alloc_failure;
+			goto unlock;
 	}
 
-	nlh = NLMSG_PUT(ub->skb, 0, ub->qlen, 0,
-			size - NLMSG_ALIGN(sizeof(*nlh)));
+	nlh = nlmsg_put(ub->skb, 0, ub->qlen, 0,
+			size - NLMSG_ALIGN(sizeof(*nlh)), 0);
+	if (!nlh) {
+		kfree(ub->skb);
+		ub->skb = NULL;
+		goto unlock;
+	}
 	ub->qlen++;
 
-	pm = NLMSG_DATA(nlh);
+	pm = nlmsg_data(nlh);
 
 	/* Fill in the ulog data */
 	pm->version = EBT_ULOG_VERSION;
@@ -209,14 +214,6 @@ static void ebt_ulog_packet(unsigned int hooknr, const struct sk_buff *skb,
 
 unlock:
 	spin_unlock_bh(lock);
-
-	return;
-
-nlmsg_failure:
-	pr_debug("error during NLMSG_PUT. This should "
-		 "not happen, please report to author.\n");
-alloc_failure:
-	goto unlock;
 }
 
 /* this function is registered with the netfilter core */
-- 
1.7.10.2
