From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 10/11] netpoll: rx optimization
Date: Sat, 03 Nov 2007 11:43:24 -0700
Message-ID: <20071103184338.982195631@linux-foundation.org>
References: <20071103184314.216145305@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Satyam Sharma <satyam@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:51863 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758136AbXKCXjQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Nov 2007 19:39:16 -0400
Content-Disposition: inline; filename=netpoll-rx.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch makes netpoll work for non-NAPI devices that call
netif_receive_skb. Devices are allowed to call netif_receive_skb
if they are receiving packets in softirq (ie in tasklet).
One side effect of this is that received packets will be looked
at twice for the non-NAPI case, but this is harmless.

Move the locking out of the inline hook and into the internal
function.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>


--- a/include/linux/netpoll.h	2007-11-03 11:05:33.000000000 -0700
+++ b/include/linux/netpoll.h	2007-11-03 11:08:36.000000000 -0700
@@ -30,6 +30,9 @@ struct netpoll_info {
 	struct delayed_work tx_work;
 };
 
+
+#ifdef CONFIG_NETPOLL
+
 void netpoll_poll(struct netpoll *np);
 void netpoll_send_udp(struct netpoll *np, const char *msg, int len);
 void netpoll_print_options(const char *prefix, struct netpoll *np);
@@ -38,32 +41,18 @@ int netpoll_setup(struct netpoll *np, st
 int netpoll_trap(void);
 void netpoll_set_trap(int trap);
 void netpoll_cleanup(struct netpoll *np);
-int __netpoll_rx(struct sk_buff *skb);
+bool __netpoll_rx(struct sk_buff *skb);
 
 
-#ifdef CONFIG_NETPOLL
-static inline int netpoll_rx(struct sk_buff *skb)
+/* Hijack incoming packet for use by netpoll.
+ * NB: may be called twice for NAPI case
+ */
+static inline bool netpoll_rx(struct sk_buff *skb)
 {
-	struct netpoll_info *npinfo = skb->dev->npinfo;
-	unsigned long flags;
-	int ret = 0;
-
-	if (!npinfo || !npinfo->rx_np)
-		return 0;
-
-	spin_lock_irqsave(&npinfo->rx_lock, flags);
-	if (__netpoll_rx(skb))
-		ret = 1;
-	spin_unlock_irqrestore(&npinfo->rx_lock, flags);
+	if (unlikely(skb->dev->npinfo))
+		return __netpoll_rx(skb);
 
-	return ret;
-}
-
-static inline int netpoll_receive_skb(struct sk_buff *skb)
-{
-	if (!list_empty(&skb->dev->napi_list))
-		return netpoll_rx(skb);
-	return 0;
+	return false;
 }
 
 static inline void *netpoll_poll_lock(struct napi_struct *napi)
--- a/net/core/dev.c	2007-11-03 11:05:33.000000000 -0700
+++ b/net/core/dev.c	2007-11-03 11:08:36.000000000 -0700
@@ -2020,8 +2020,7 @@ int netif_receive_skb(struct sk_buff *sk
 	int ret = NET_RX_DROP;
 	__be16 type;
 
-	/* if we've gotten here through NAPI, check netpoll */
-	if (netpoll_receive_skb(skb))
+	if (netpoll_rx(skb))
 		return NET_RX_DROP;
 
 	if (!skb->tstamp.tv64)
--- a/net/core/netpoll.c	2007-11-03 11:08:23.000000000 -0700
+++ b/net/core/netpoll.c	2007-11-03 11:08:36.000000000 -0700
@@ -458,16 +458,23 @@ static void arp_reply(struct sk_buff *sk
 	netpoll_send_skb(np, send_skb);
 }
 
-int __netpoll_rx(struct sk_buff *skb)
+bool __netpoll_rx(struct sk_buff *skb)
 {
 	int proto, len, ulen;
 	struct iphdr *iph;
 	struct udphdr *uh;
 	struct netpoll_info *npi = skb->dev->npinfo;
-	struct netpoll *np = npi->rx_np;
+	struct netpoll *np;
+	unsigned long flags;
+
+	if (!npi)
+		return false;
 
+	spin_lock_irqsave(&npi->rx_lock, flags);
+	np = npi->rx_np;
 	if (!np)
 		goto out;
+
 	if (skb->dev->type != ARPHRD_ETHER)
 		goto out;
 
@@ -528,20 +535,22 @@ int __netpoll_rx(struct sk_buff *skb)
 	np->rx_hook(np, ntohs(uh->source),
 		    (char *)(uh+1),
 		    ulen - sizeof(struct udphdr));
+	spin_unlock_irqrestore(&npi->rx_lock, flags);
 
 	kfree_skb(skb);
-	return 1;
+	return true;
 
 out:
+	spin_unlock_irqrestore(&npi->rx_lock, flags);
 	/* If packet received while already in poll then just
 	 * silently drop.
 	 */
 	if (atomic_read(&trapped)) {
 		kfree_skb(skb);
-		return 1;
+		return true;
 	}
 
-	return 0;
+	return false;
 }
 
 void netpoll_print_options(const char *name, struct netpoll *np)

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

