From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCHv2 net] netpoll: fix rx_hook() interface by passing the skb
Date: Wed, 23 Oct 2013 23:36:30 +0200
Message-ID: <1382564190-334-1-git-send-email-antonio@meshcoding.com>
References: <20131023.161603.1190144528425577653.davem@davemloft.net>
Cc: netdev@vger.kernel.org, David.Laight@ACULAB.COM,
	Antonio Quartulli <antonio@meshcoding.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:21095 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751504Ab3JWVhd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Oct 2013 17:37:33 -0400
In-Reply-To: <20131023.161603.1190144528425577653.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Right now skb->data is passed to rx_hook() even if the skb
has not been linearised and without giving rx_hook() a way
to linearise it.

Change the rx_hook() interface and make it accept the skb
and the offset to the UDP payload as arguments. rx_hook() is
also renamed to rx_skb_hook() to ensure that out of the tree
users notice the API change.

In this way any rx_skb_hook() implementation can perform all
the needed operations to properly (and safely) access the
skb data.

Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 include/linux/netpoll.h |  5 +++--
 net/core/netpoll.c      | 31 ++++++++++++++++++-------------
 2 files changed, 21 insertions(+), 15 deletions(-)

diff --git a/include/linux/netpoll.h b/include/linux/netpoll.h
index f3c7c24..fbfdb9d 100644
--- a/include/linux/netpoll.h
+++ b/include/linux/netpoll.h
@@ -24,7 +24,8 @@ struct netpoll {
 	struct net_device *dev;
 	char dev_name[IFNAMSIZ];
 	const char *name;
-	void (*rx_hook)(struct netpoll *, int, char *, int);
+	void (*rx_skb_hook)(struct netpoll *np, int source, struct sk_buff *skb,
+			    int offset, int len);
 
 	union inet_addr local_ip, remote_ip;
 	bool ipv6;
@@ -41,7 +42,7 @@ struct netpoll_info {
 	unsigned long rx_flags;
 	spinlock_t rx_lock;
 	struct semaphore dev_lock;
-	struct list_head rx_np; /* netpolls that registered an rx_hook */
+	struct list_head rx_np; /* netpolls that registered an rx_skb_hook */
 
 	struct sk_buff_head neigh_tx; /* list of neigh requests to reply to */
 	struct sk_buff_head txq;
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index fc75c9e..8f97199 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -636,8 +636,9 @@ static void netpoll_neigh_reply(struct sk_buff *skb, struct netpoll_info *npinfo
 
 			netpoll_send_skb(np, send_skb);
 
-			/* If there are several rx_hooks for the same address,
-			   we're fine by sending a single reply */
+			/* If there are several rx_skb_hooks for the same
+			 * address we're fine by sending a single reply
+			 */
 			break;
 		}
 		spin_unlock_irqrestore(&npinfo->rx_lock, flags);
@@ -719,8 +720,9 @@ static void netpoll_neigh_reply(struct sk_buff *skb, struct netpoll_info *npinfo
 
 			netpoll_send_skb(np, send_skb);
 
-			/* If there are several rx_hooks for the same address,
-			   we're fine by sending a single reply */
+			/* If there are several rx_skb_hooks for the same
+			 * address, we're fine by sending a single reply
+			 */
 			break;
 		}
 		spin_unlock_irqrestore(&npinfo->rx_lock, flags);
@@ -756,11 +758,12 @@ static bool pkt_is_ns(struct sk_buff *skb)
 
 int __netpoll_rx(struct sk_buff *skb, struct netpoll_info *npinfo)
 {
-	int proto, len, ulen;
-	int hits = 0;
+	int proto, len, ulen, data_len;
+	int hits = 0, offset;
 	const struct iphdr *iph;
 	struct udphdr *uh;
 	struct netpoll *np, *tmp;
+	uint16_t source;
 
 	if (list_empty(&npinfo->rx_np))
 		goto out;
@@ -820,7 +823,10 @@ int __netpoll_rx(struct sk_buff *skb, struct netpoll_info *npinfo)
 
 		len -= iph->ihl*4;
 		uh = (struct udphdr *)(((char *)iph) + iph->ihl*4);
+		offset = (unsigned char *)(uh + 1) - skb->data;
 		ulen = ntohs(uh->len);
+		data_len = skb->len - offset;
+		source = ntohs(uh->source);
 
 		if (ulen != len)
 			goto out;
@@ -834,9 +840,7 @@ int __netpoll_rx(struct sk_buff *skb, struct netpoll_info *npinfo)
 			if (np->local_port && np->local_port != ntohs(uh->dest))
 				continue;
 
-			np->rx_hook(np, ntohs(uh->source),
-				       (char *)(uh+1),
-				       ulen - sizeof(struct udphdr));
+			np->rx_skb_hook(np, source, skb, offset, data_len);
 			hits++;
 		}
 	} else {
@@ -859,7 +863,10 @@ int __netpoll_rx(struct sk_buff *skb, struct netpoll_info *npinfo)
 		if (!pskb_may_pull(skb, sizeof(struct udphdr)))
 			goto out;
 		uh = udp_hdr(skb);
+		offset = (unsigned char *)(uh + 1) - skb->data;
 		ulen = ntohs(uh->len);
+		data_len = skb->len - offset;
+		source = ntohs(uh->source);
 		if (ulen != skb->len)
 			goto out;
 		if (udp6_csum_init(skb, uh, IPPROTO_UDP))
@@ -872,9 +879,7 @@ int __netpoll_rx(struct sk_buff *skb, struct netpoll_info *npinfo)
 			if (np->local_port && np->local_port != ntohs(uh->dest))
 				continue;
 
-			np->rx_hook(np, ntohs(uh->source),
-				       (char *)(uh+1),
-				       ulen - sizeof(struct udphdr));
+			np->rx_skb_hook(np, source, skb, offset, data_len);
 			hits++;
 		}
 #endif
@@ -1062,7 +1067,7 @@ int __netpoll_setup(struct netpoll *np, struct net_device *ndev, gfp_t gfp)
 
 	npinfo->netpoll = np;
 
-	if (np->rx_hook) {
+	if (np->rx_skb_hook) {
 		spin_lock_irqsave(&npinfo->rx_lock, flags);
 		npinfo->rx_flags |= NETPOLL_RX_ENABLED;
 		list_add_tail(&np->rx, &npinfo->rx_np);
-- 
1.8.4
