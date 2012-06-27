From: David Miller <davem@davemloft.net>
Subject: [PATCH 6/18] netfilter: ipt_ULOG: Move away from NLMSG_PUT().
Date: Tue, 26 Jun 2012 22:02:20 -0700 (PDT)
Message-ID: <20120626.220220.2130008385943761567.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39202 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751772Ab2F0FCV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 01:02:21 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 996E3584191
	for <netdev@vger.kernel.org>; Tue, 26 Jun 2012 22:02:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


And use nlmsg_data() while we're here too.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/netfilter/ipt_ULOG.c |   15 ++++++++-------
 1 file changed, 8 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/netfilter/ipt_ULOG.c b/net/ipv4/netfilter/ipt_ULOG.c
index ba5756d..99b3f53 100644
--- a/net/ipv4/netfilter/ipt_ULOG.c
+++ b/net/ipv4/netfilter/ipt_ULOG.c
@@ -196,12 +196,15 @@ static void ipt_ulog_packet(unsigned int hooknum,
 
 	pr_debug("qlen %d, qthreshold %Zu\n", ub->qlen, loginfo->qthreshold);
 
-	/* NLMSG_PUT contains a hidden goto nlmsg_failure !!! */
-	nlh = NLMSG_PUT(ub->skb, 0, ub->qlen, ULOG_NL_EVENT,
-			sizeof(*pm)+copy_len);
+	nlh = nlmsg_put(ub->skb, 0, ub->qlen, ULOG_NL_EVENT,
+			sizeof(*pm)+copy_len, 0);
+	if (!nlh) {
+		pr_debug("error during nlmsg_put\n");
+		goto out_unlock;
+	}
 	ub->qlen++;
 
-	pm = NLMSG_DATA(nlh);
+	pm = nlmsg_data(nlh);
 
 	/* We might not have a timestamp, get one */
 	if (skb->tstamp.tv64 == 0)
@@ -261,13 +264,11 @@ static void ipt_ulog_packet(unsigned int hooknum,
 			nlh->nlmsg_type = NLMSG_DONE;
 		ulog_send(groupnum);
 	}
-
+out_unlock:
 	spin_unlock_bh(&ulog_lock);
 
 	return;
 
-nlmsg_failure:
-	pr_debug("error during NLMSG_PUT\n");
 alloc_failure:
 	pr_debug("Error building netlink message\n");
 	spin_unlock_bh(&ulog_lock);
-- 
1.7.10.2
