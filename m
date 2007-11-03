From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 04/11] netpoll: alternative implementation of dropping
Date: Sat, 03 Nov 2007 11:43:18 -0700
Message-ID: <20071103184338.637309632@linux-foundation.org>
References: <20071103184314.216145305@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Satyam Sharma <satyam@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:48033 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757845AbXKCXgf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Nov 2007 19:36:35 -0400
Content-Disposition: inline; filename=netpoll-drop-flag.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- a/net/core/netpoll.c	2007-11-03 09:19:34.000000000 -0700
+++ b/net/core/netpoll.c	2007-11-03 09:33:31.000000000 -0700
@@ -40,7 +40,6 @@ static atomic_t trapped;
 
 #define USEC_PER_POLL	50
 #define NETPOLL_RX_ENABLED  1
-#define NETPOLL_RX_DROP     2
 
 #define MAX_SKB_SIZE \
 		(MAX_UDP_CHUNK + sizeof(struct udphdr) + \
@@ -128,13 +127,11 @@ static int poll_one_napi(struct netpoll_
 	if (!test_bit(NAPI_STATE_SCHED, &napi->state))
 		return budget;
 
-	npinfo->rx_flags |= NETPOLL_RX_DROP;
 	atomic_inc(&trapped);
 
 	work = napi->poll(napi, budget);
 
 	atomic_dec(&trapped);
-	npinfo->rx_flags &= ~NETPOLL_RX_DROP;
 
 	return budget - work;
 }
@@ -475,7 +472,7 @@ int __netpoll_rx(struct sk_buff *skb)
 	if (skb->dev->type != ARPHRD_ETHER)
 		goto out;
 
-	/* check if netpoll clients need ARP */
+	/* if receive ARP during middle of NAPI poll, then queue */
 	if (skb->protocol == htons(ETH_P_ARP) &&
 	    atomic_read(&trapped)) {
 		skb_queue_tail(&npi->arp_tx, skb);
@@ -537,6 +534,9 @@ int __netpoll_rx(struct sk_buff *skb)
 	return 1;
 
 out:
+	/* If packet received while already in poll then just
+	 * silently drop.
+	 */
 	if (atomic_read(&trapped)) {
 		kfree_skb(skb);
 		return 1;

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

