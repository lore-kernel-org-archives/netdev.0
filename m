From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH 1/1] net: hold sock reference while processing tx timestamps
Date: Wed, 12 Oct 2011 20:36:33 +0200
Message-ID: <56185ca8a7dc0223031ca0f0996302cac1b497eb.1318444117.git.richard.cochran@omicron.at>
References: <1318007501.3988.20.camel@jlt3.sipsolutions.net>
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Johannes Berg <johannes@sipsolutions.net>, <stable@kernel.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:57303 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751758Ab1JLSgf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Oct 2011 14:36:35 -0400
Received: by mail-ey0-f174.google.com with SMTP id 27so1043219eye.19
        for <netdev@vger.kernel.org>; Wed, 12 Oct 2011 11:36:34 -0700 (PDT)
In-Reply-To: <1318007501.3988.20.camel@jlt3.sipsolutions.net>
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
Cc: <stable@kernel.org>
---
 include/linux/phy.h     |    2 +-
 include/linux/skbuff.h  |    7 ++++++-
 net/core/timestamping.c |    7 ++++++-
 3 files changed, 13 insertions(+), 3 deletions(-)

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
index 98a5264..29e59d6 100644
--- a/net/core/timestamping.c
+++ b/net/core/timestamping.c
@@ -60,6 +60,7 @@ void skb_clone_tx_timestamp(struct sk_buff *skb)
 			clone = skb_clone(skb, GFP_ATOMIC);
 			if (!clone)
 				return;
+			sock_hold(sk);
 			clone->sk = sk;
 			phydev->drv->txtstamp(phydev, clone, type);
 		}
@@ -77,8 +78,11 @@ void skb_complete_tx_timestamp(struct sk_buff *skb,
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
@@ -87,6 +91,7 @@ void skb_complete_tx_timestamp(struct sk_buff *skb,
 	serr->ee.ee_origin = SO_EE_ORIGIN_TIMESTAMPING;
 	skb->sk = NULL;
 	err = sock_queue_err_skb(sk, skb);
+	sock_put(sk);
 	if (err)
 		kfree_skb(skb);
 }
-- 
1.7.2.5
