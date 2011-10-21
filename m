From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH v2 1/3] net: hold sock reference while processing tx timestamps
Date: Fri, 21 Oct 2011 12:49:15 +0200
Message-ID: <f13715e7d094e7989581f5eacf0efe9d15379e10.1319193734.git.richard.cochran@omicron.at>
References: <cover.1319193734.git.richard.cochran@omicron.at>
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	<stable@vger.kernel.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:53783 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754343Ab1JUKtk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2011 06:49:40 -0400
In-Reply-To: <cover.1319193734.git.richard.cochran@omicron.at>
In-Reply-To: <cover.1319193734.git.richard.cochran@omicron.at>
References: <56185ca8a7dc0223031ca0f0996302cac1b497eb.1318444117.git.richard.cochran@omicron.at> <cover.1319193734.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The pair of functions,

 * skb_clone_tx_timestamp()
 * skb_complete_tx_timestamp()

were designed to allow timestamping in PHY devices. The first
function, called during the MAC driver's hard_xmit method, identifies
PTP protocol packets, clones them, and gives them to the PHY device
driver. The PHY driver may hold onto the packet and deliver it at a
later time using the second function, which adds the packet to the
socket's error queue.

As pointed out by Johannes, nothing prevents the socket from
disappearing while the cloned packet is sitting in the PHY driver
awaiting a timestamp. This patch fixes the issue by taking a reference
on the socket for each such packet. In addition, the comments
regarding the usage of these function are expanded to highlight the
rule that PHY drivers must use skb_complete_tx_timestamp() to release
the packet, in order to release the socket reference, too.

These functions first appeared in v2.6.36.

Reported-by: Johannes Berg <johannes@sipsolutions.net>
Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
Cc: <stable@vger.kernel.org>
---
 include/linux/phy.h     |    2 +-
 include/linux/skbuff.h  |    7 ++++++-
 net/core/timestamping.c |   12 ++++++++++--
 3 files changed, 17 insertions(+), 4 deletions(-)

diff --git a/include/linux/phy.h b/include/linux/phy.h
index 54fc413..79f337c 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -420,7 +420,7 @@ struct phy_driver {
 
 	/*
 	 * Requests a Tx timestamp for 'skb'. The phy driver promises
-	 * to deliver it to the socket's error queue as soon as a
+	 * to deliver it using skb_complete_tx_timestamp() as soon as a
 	 * timestamp becomes available. One of the PTP_CLASS_ values
 	 * is passed in 'type'.
 	 */
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 8bd383c..0f96646 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2020,8 +2020,13 @@ static inline bool skb_defer_rx_timestamp(struct sk_buff *skb)
 /**
  * skb_complete_tx_timestamp() - deliver cloned skb with tx timestamps
  *
+ * PHY drivers may accept clones of transmitted packets for
+ * timestamping via their phy_driver.txtstamp method. These drivers
+ * must call this function to return the skb back to the stack, with
+ * or without a timestamp.
+ *
  * @skb: clone of the the original outgoing packet
- * @hwtstamps: hardware time stamps
+ * @hwtstamps: hardware time stamps, may be NULL if not available
  *
  */
 void skb_complete_tx_timestamp(struct sk_buff *skb,
diff --git a/net/core/timestamping.c b/net/core/timestamping.c
index 98a5264..82fb288 100644
--- a/net/core/timestamping.c
+++ b/net/core/timestamping.c
@@ -57,9 +57,13 @@ void skb_clone_tx_timestamp(struct sk_buff *skb)
 	case PTP_CLASS_V2_VLAN:
 		phydev = skb->dev->phydev;
 		if (likely(phydev->drv->txtstamp)) {
+			if (!atomic_inc_not_zero(&sk->sk_refcnt))
+				return;
 			clone = skb_clone(skb, GFP_ATOMIC);
-			if (!clone)
+			if (!clone) {
+				sock_put(sk);
 				return;
+			}
 			clone->sk = sk;
 			phydev->drv->txtstamp(phydev, clone, type);
 		}
@@ -77,8 +81,11 @@ void skb_complete_tx_timestamp(struct sk_buff *skb,
 	struct sock_exterr_skb *serr;
 	int err;
 
-	if (!hwtstamps)
+	if (!hwtstamps) {
+		sock_put(sk);
+		kfree_skb(skb);
 		return;
+	}
 
 	*skb_hwtstamps(skb) = *hwtstamps;
 	serr = SKB_EXT_ERR(skb);
@@ -87,6 +94,7 @@ void skb_complete_tx_timestamp(struct sk_buff *skb,
 	serr->ee.ee_origin = SO_EE_ORIGIN_TIMESTAMPING;
 	skb->sk = NULL;
 	err = sock_queue_err_skb(sk, skb);
+	sock_put(sk);
 	if (err)
 		kfree_skb(skb);
 }
-- 
1.7.2.5
