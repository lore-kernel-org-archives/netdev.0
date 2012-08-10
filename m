From: Cong Wang <amwang@redhat.com>
Subject: [PATCH 05/14] netpoll: use netpoll_rx_on() in netpoll_rx()
Date: Fri, 10 Aug 2012 15:10:28 +0800
Message-ID: <1344582637-18261-6-git-send-email-amwang@redhat.com>
References: <1344582637-18261-1-git-send-email-amwang@redhat.com>
Cc: Cong Wang <amwang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33965 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751831Ab2HJHLG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Aug 2012 03:11:06 -0400
In-Reply-To: <1344582637-18261-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The logic of the code is same, just call netpoll_rx_on().

Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 include/linux/netpoll.h |   18 +++++++++---------
 1 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/include/linux/netpoll.h b/include/linux/netpoll.h
index 5d881c3..2d178ba 100644
--- a/include/linux/netpoll.h
+++ b/include/linux/netpoll.h
@@ -63,6 +63,13 @@ static inline void netpoll_send_skb(struct netpoll *np, struct sk_buff *skb)
 
 
 #ifdef CONFIG_NETPOLL
+static inline int netpoll_rx_on(struct sk_buff *skb)
+{
+	struct netpoll_info *npinfo = rcu_dereference_bh(skb->dev->npinfo);
+
+	return npinfo && (!list_empty(&npinfo->rx_np) || npinfo->rx_flags);
+}
+
 static inline bool netpoll_rx(struct sk_buff *skb)
 {
 	struct netpoll_info *npinfo;
@@ -70,11 +77,11 @@ static inline bool netpoll_rx(struct sk_buff *skb)
 	bool ret = false;
 
 	local_irq_save(flags);
-	npinfo = rcu_dereference_bh(skb->dev->npinfo);
 
-	if (!npinfo || (list_empty(&npinfo->rx_np) && !npinfo->rx_flags))
+	if (!netpoll_rx_on(skb))
 		goto out;
 
+	npinfo = rcu_dereference_bh(skb->dev->npinfo);
 	spin_lock(&npinfo->rx_lock);
 	/* check rx_flags again with the lock held */
 	if (npinfo->rx_flags && __netpoll_rx(skb, npinfo))
@@ -86,13 +93,6 @@ out:
 	return ret;
 }
 
-static inline int netpoll_rx_on(struct sk_buff *skb)
-{
-	struct netpoll_info *npinfo = rcu_dereference_bh(skb->dev->npinfo);
-
-	return npinfo && (!list_empty(&npinfo->rx_np) || npinfo->rx_flags);
-}
-
 static inline int netpoll_receive_skb(struct sk_buff *skb)
 {
 	if (!list_empty(&skb->dev->napi_list))
-- 
1.7.7.6
