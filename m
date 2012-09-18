From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [RFC net-next] netpoll: use static branch
Date: Tue, 18 Sep 2012 14:10:14 -0700
Message-ID: <20120918141014.573734db@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, Cong Wang <amwang@redhat.com>,
	Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:50194 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755100Ab2IRVKn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Sep 2012 17:10:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an attempt to optimize netpoll when not used.

Since distro's enable everything and netpoll is only occasionally
used, improve performance by getting netpoll condition check
out of the Rx fastpath.

Compile tested only, I have no real use for netpoll.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 include/linux/netpoll.h |   28 ++++++++++++++++++++--------
 net/core/netpoll.c      |    8 +++++++-
 2 files changed, 27 insertions(+), 9 deletions(-)

--- a/include/linux/netpoll.h	2012-09-18 13:25:15.575750004 -0700
+++ b/include/linux/netpoll.h	2012-09-18 13:29:16.245323347 -0700
@@ -66,10 +66,16 @@ static inline void netpoll_send_skb(stru
 
 
 #ifdef CONFIG_NETPOLL
+extern struct static_key netpoll_needed;
+
 static inline bool netpoll_rx_on(struct sk_buff *skb)
 {
-	struct netpoll_info *npinfo = rcu_dereference_bh(skb->dev->npinfo);
+	struct netpoll_info *npinfo;
+
+	if (static_key_true(&netpoll_needed))
+		return false;
 
+	npinfo = rcu_dereference_bh(skb->dev->npinfo);
 	return npinfo && (!list_empty(&npinfo->rx_np) || npinfo->rx_flags);
 }
 
@@ -79,12 +85,14 @@ static inline bool netpoll_rx(struct sk_
 	unsigned long flags;
 	bool ret = false;
 
-	local_irq_save(flags);
+	if (static_key_true(&netpoll_needed))
+		return false;
 
-	if (!netpoll_rx_on(skb))
+	local_irq_save(flags);
+	npinfo = rcu_dereference_bh(skb->dev->npinfo);
+	if (!npinfo || (list_empty(&npinfo->rx_np) && !npinfo->rx_flags))
 		goto out;
 
-	npinfo = rcu_dereference_bh(skb->dev->npinfo);
 	spin_lock(&npinfo->rx_lock);
 	/* check rx_flags again with the lock held */
 	if (npinfo->rx_flags && __netpoll_rx(skb, npinfo))
@@ -96,11 +104,15 @@ out:
 	return ret;
 }
 
-static inline int netpoll_receive_skb(struct sk_buff *skb)
+static inline bool netpoll_receive_skb(struct sk_buff *skb)
 {
+	if (static_key_true(&netpoll_needed))
+		return false;
+
 	if (!list_empty(&skb->dev->napi_list))
 		return netpoll_rx(skb);
-	return 0;
+
+	return false;
 }
 
 static inline void *netpoll_poll_lock(struct napi_struct *napi)
@@ -139,9 +151,9 @@ static inline bool netpoll_rx_on(struct
 {
 	return false;
 }
-static inline int netpoll_receive_skb(struct sk_buff *skb)
+static inline bool netpoll_receive_skb(struct sk_buff *skb)
 {
-	return 0;
+	return false;
 }
 static inline void *netpoll_poll_lock(struct napi_struct *napi)
 {
--- a/net/core/netpoll.c	2012-09-18 13:25:15.575750004 -0700
+++ b/net/core/netpoll.c	2012-09-18 13:26:44.330855089 -0700
@@ -67,6 +67,8 @@ module_param(carrier_timeout, uint, 0644
 #define np_notice(np, fmt, ...)				\
 	pr_notice("%s: " fmt, np->name, ##__VA_ARGS__)
 
+struct static_key netpoll_needed __read_mostly;
+
 static void queue_process(struct work_struct *work)
 {
 	struct netpoll_info *npinfo =
@@ -786,6 +788,8 @@ int __netpoll_setup(struct netpoll *np,
 		npinfo->rx_flags |= NETPOLL_RX_ENABLED;
 		list_add_tail(&np->rx, &npinfo->rx_np);
 		spin_unlock_irqrestore(&npinfo->rx_lock, flags);
+
+		static_key_slow_inc(&netpoll_needed);
 	}
 
 	/* last thing to do is link it to the net device structure */
@@ -926,8 +930,10 @@ void __netpoll_cleanup(struct netpoll *n
 	if (!list_empty(&npinfo->rx_np)) {
 		spin_lock_irqsave(&npinfo->rx_lock, flags);
 		list_del(&np->rx);
-		if (list_empty(&npinfo->rx_np))
+		if (list_empty(&npinfo->rx_np)) {
 			npinfo->rx_flags &= ~NETPOLL_RX_ENABLED;
+			static_key_slow_dec(&netpoll_needed);
+		}
 		spin_unlock_irqrestore(&npinfo->rx_lock, flags);
 	}
 
