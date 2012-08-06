From: Cong Wang <amwang@redhat.com>
Subject: [PATCH 4/8] netpoll: take rcu_read_lock_bh() in netpoll_rx()
Date: Mon,  6 Aug 2012 22:23:28 +0800
Message-ID: <1344263012-4031-5-git-send-email-amwang@redhat.com>
References: <1344263012-4031-1-git-send-email-amwang@redhat.com>
Cc: Cong Wang <amwang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45910 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756571Ab2HFOXz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Aug 2012 10:23:55 -0400
In-Reply-To: <1344263012-4031-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In __netpoll_rx(), it dereferences ->npinfo without rcu_dereference_bh(),
this patch fixes it by using the 'npinfo' passed from netpoll_rx()
where it is already dereferenced with rcu_dereference_bh().

Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 include/linux/netpoll.h |    4 ++--
 net/core/netpoll.c      |    3 +--
 2 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/include/linux/netpoll.h b/include/linux/netpoll.h
index 907812e..5d881c3 100644
--- a/include/linux/netpoll.h
+++ b/include/linux/netpoll.h
@@ -52,7 +52,7 @@ void netpoll_set_trap(int trap);
 void __netpoll_cleanup(struct netpoll *np);
 void __netpoll_free_rcu(struct netpoll *np);
 void netpoll_cleanup(struct netpoll *np);
-int __netpoll_rx(struct sk_buff *skb);
+int __netpoll_rx(struct sk_buff *skb, struct netpoll_info *npinfo);
 void netpoll_send_skb_on_dev(struct netpoll *np, struct sk_buff *skb,
 			     struct net_device *dev);
 static inline void netpoll_send_skb(struct netpoll *np, struct sk_buff *skb)
@@ -77,7 +77,7 @@ static inline bool netpoll_rx(struct sk_buff *skb)
 
 	spin_lock(&npinfo->rx_lock);
 	/* check rx_flags again with the lock held */
-	if (npinfo->rx_flags && __netpoll_rx(skb))
+	if (npinfo->rx_flags && __netpoll_rx(skb, npinfo))
 		ret = true;
 	spin_unlock(&npinfo->rx_lock);
 
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index dc17f1d..d055bb0 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -543,13 +543,12 @@ static void arp_reply(struct sk_buff *skb)
 	spin_unlock_irqrestore(&npinfo->rx_lock, flags);
 }
 
-int __netpoll_rx(struct sk_buff *skb)
+int __netpoll_rx(struct sk_buff *skb, struct netpoll_info *npinfo)
 {
 	int proto, len, ulen;
 	int hits = 0;
 	const struct iphdr *iph;
 	struct udphdr *uh;
-	struct netpoll_info *npinfo = skb->dev->npinfo;
 	struct netpoll *np, *tmp;
 
 	if (list_empty(&npinfo->rx_np))
-- 
1.7.7.6
