From: David Miller <davem@davemloft.net>
Subject: [PATCH 4/18] decnet: dn_rtmsg: Move away from NLMSG_PUT().
Date: Tue, 26 Jun 2012 22:02:12 -0700 (PDT)
Message-ID: <20120626.220212.95832879147124137.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39195 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750810Ab2F0FCM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 01:02:12 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 276CB584192
	for <netdev@vger.kernel.org>; Tue, 26 Jun 2012 22:02:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


And use nlmsg_data() while we're here too.

Also, remove pointless kernel log message.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/decnet/netfilter/dn_rtmsg.c |   20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

diff --git a/net/decnet/netfilter/dn_rtmsg.c b/net/decnet/netfilter/dn_rtmsg.c
index e6f8862..b8f7f5b 100644
--- a/net/decnet/netfilter/dn_rtmsg.c
+++ b/net/decnet/netfilter/dn_rtmsg.c
@@ -42,23 +42,23 @@ static struct sk_buff *dnrmg_build_message(struct sk_buff *rt_skb, int *errp)
 	size = NLMSG_SPACE(rt_skb->len);
 	size += NLMSG_ALIGN(sizeof(struct nf_dn_rtmsg));
 	skb = alloc_skb(size, GFP_ATOMIC);
-	if (!skb)
-		goto nlmsg_failure;
+	if (!skb) {
+		*errp = -ENOMEM;
+		return NULL;
+	}
 	old_tail = skb->tail;
-	nlh = NLMSG_PUT(skb, 0, 0, 0, size - sizeof(*nlh));
+	nlh = nlmsg_put(skb, 0, 0, 0, size - sizeof(*nlh), 0);
+	if (!nlh) {
+		kfree_skb(skb);
+		*errp = -ENOMEM;
+		return NULL;
+	}
 	rtm = (struct nf_dn_rtmsg *)NLMSG_DATA(nlh);
 	rtm->nfdn_ifindex = rt_skb->dev->ifindex;
 	ptr = NFDN_RTMSG(rtm);
 	skb_copy_from_linear_data(rt_skb, ptr, rt_skb->len);
 	nlh->nlmsg_len = skb->tail - old_tail;
 	return skb;
-
-nlmsg_failure:
-	if (skb)
-		kfree_skb(skb);
-	*errp = -ENOMEM;
-	net_err_ratelimited("dn_rtmsg: error creating netlink message\n");
-	return NULL;
 }
 
 static void dnrmg_send_peer(struct sk_buff *skb)
-- 
1.7.10.2
