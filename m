From: Cong Wang <amwang@redhat.com>
Subject: [PATCH 7/7] netpoll: take rcu_read_lock_bh() in netpoll_send_skb_on_dev()
Date: Fri, 27 Jul 2012 23:38:04 +0800
Message-ID: <1343403484-29347-8-git-send-email-amwang@redhat.com>
References: <1343403484-29347-1-git-send-email-amwang@redhat.com>
Cc: Cong Wang <amwang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Joe Perches <joe@perches.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35681 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751773Ab2G0Pjq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Jul 2012 11:39:46 -0400
In-Reply-To: <1343403484-29347-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes several problems in the call path of
netpoll_send_skb_on_dev():

1. We already disable IRQ's before calling netpoll_send_skb_on_dev(),
   so we don't need to disable IRQ's again.
2. All the callees of netpoll_send_skb_on_dev() should use
   rcu_dereference_bh() to dereference ->npinfo.
3. Rename arp_reply() to netpoll_arp_reply(), the former is too generic.

Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 net/core/netpoll.c |   31 +++++++++++++++++--------------
 1 files changed, 17 insertions(+), 14 deletions(-)

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 3965fdb..d6e192b 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -54,7 +54,7 @@ static atomic_t trapped;
 	 MAX_UDP_CHUNK)
 
 static void zap_completion_queue(void);
-static void arp_reply(struct sk_buff *skb);
+static void netpoll_arp_reply(struct sk_buff *skb, struct netpoll_info *npinfo);
 
 static unsigned int carrier_timeout = 4;
 module_param(carrier_timeout, uint, 0644);
@@ -170,7 +170,8 @@ static void poll_napi(struct net_device *dev)
 	list_for_each_entry(napi, &dev->napi_list, dev_list) {
 		if (napi->poll_owner != smp_processor_id() &&
 		    spin_trylock(&napi->poll_lock)) {
-			budget = poll_one_napi(dev->npinfo, napi, budget);
+			budget = poll_one_napi(rcu_dereference_bh(dev->npinfo),
+					       napi, budget);
 			spin_unlock(&napi->poll_lock);
 
 			if (!budget)
@@ -185,13 +186,14 @@ static void service_arp_queue(struct netpoll_info *npi)
 		struct sk_buff *skb;
 
 		while ((skb = skb_dequeue(&npi->arp_tx)))
-			arp_reply(skb);
+			netpoll_arp_reply(skb, npi);
 	}
 }
 
 static void netpoll_poll_dev(struct net_device *dev)
 {
 	const struct net_device_ops *ops;
+	struct netpoll_info *ni = rcu_dereference_bh(dev->npinfo);
 
 	if (!dev || !netif_running(dev))
 		return;
@@ -206,17 +208,18 @@ static void netpoll_poll_dev(struct net_device *dev)
 	poll_napi(dev);
 
 	if (dev->flags & IFF_SLAVE) {
-		if (dev->npinfo) {
+		if (ni) {
 			struct net_device *bond_dev = dev->master;
 			struct sk_buff *skb;
-			while ((skb = skb_dequeue(&dev->npinfo->arp_tx))) {
+			struct netpoll_info *bond_ni = rcu_dereference_bh(bond_dev->npinfo);
+			while ((skb = skb_dequeue(&ni->arp_tx))) {
 				skb->dev = bond_dev;
-				skb_queue_tail(&bond_dev->npinfo->arp_tx, skb);
+				skb_queue_tail(&bond_ni->arp_tx, skb);
 			}
 		}
 	}
 
-	service_arp_queue(dev->npinfo);
+	service_arp_queue(ni);
 
 	zap_completion_queue();
 }
@@ -302,6 +305,7 @@ static int netpoll_owner_active(struct net_device *dev)
 	return 0;
 }
 
+/* call with IRQ disabled */
 void netpoll_send_skb_on_dev(struct netpoll *np, struct sk_buff *skb,
 			     struct net_device *dev)
 {
@@ -309,8 +313,11 @@ void netpoll_send_skb_on_dev(struct netpoll *np, struct sk_buff *skb,
 	unsigned long tries;
 	const struct net_device_ops *ops = dev->netdev_ops;
 	/* It is up to the caller to keep npinfo alive. */
-	struct netpoll_info *npinfo = np->dev->npinfo;
+	struct netpoll_info *npinfo;
+
+	WARN_ON_ONCE(!irqs_disabled());
 
+	npinfo = rcu_dereference_bh(np->dev->npinfo);
 	if (!npinfo || !netif_running(dev) || !netif_device_present(dev)) {
 		__kfree_skb(skb);
 		return;
@@ -319,11 +326,9 @@ void netpoll_send_skb_on_dev(struct netpoll *np, struct sk_buff *skb,
 	/* don't get messages out of order, and no recursion */
 	if (skb_queue_len(&npinfo->txq) == 0 && !netpoll_owner_active(dev)) {
 		struct netdev_queue *txq;
-		unsigned long flags;
 
 		txq = netdev_get_tx_queue(dev, skb_get_queue_mapping(skb));
 
-		local_irq_save(flags);
 		/* try until next clock tick */
 		for (tries = jiffies_to_usecs(1)/USEC_PER_POLL;
 		     tries > 0; --tries) {
@@ -347,10 +352,9 @@ void netpoll_send_skb_on_dev(struct netpoll *np, struct sk_buff *skb,
 		}
 
 		WARN_ONCE(!irqs_disabled(),
-			"netpoll_send_skb(): %s enabled interrupts in poll (%pF)\n",
+			"netpoll_send_skb_on_dev(): %s enabled interrupts in poll (%pF)\n",
 			dev->name, ops->ndo_start_xmit);
 
-		local_irq_restore(flags);
 	}
 
 	if (status != NETDEV_TX_OK) {
@@ -423,9 +427,8 @@ void netpoll_send_udp(struct netpoll *np, const char *msg, int len)
 }
 EXPORT_SYMBOL(netpoll_send_udp);
 
-static void arp_reply(struct sk_buff *skb)
+static void netpoll_arp_reply(struct sk_buff *skb, struct netpoll_info *npinfo)
 {
-	struct netpoll_info *npinfo = skb->dev->npinfo;
 	struct arphdr *arp;
 	unsigned char *arp_ptr;
 	int size, type = ARPOP_REPLY, ptype = ETH_P_ARP;
-- 
1.7.7.6
