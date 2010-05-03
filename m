From: Simon Arlott <simon@fire.lp0.eu>
Subject: [PATCH v2 1/2] ppp_generic: pull 2 bytes so that PPP_PROTO(skb) is
 valid
Date: Mon, 03 May 2010 21:19:33 +0100
Message-ID: <4BDF2FD5.2030509@simon.arlott.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, paulus@samba.org,
	linux-ppp@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from proxima.lp0.eu ([81.2.80.65]:54324 "EHLO proxima.lp0.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756776Ab0ECUTg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 May 2010 16:19:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In ppp_input(), PPP_PROTO(skb) may refer to invalid data in the skb.

If this happens and (proto >= 0xc000 || proto == PPP_CCPFRAG) then
the packet is passed directly to pppd.

This occurs frequently when using PPPoE with an interface MTU
greater than 1500 because the skb is more likely to be non-linear.

The next 2 bytes need to be pulled in ppp_input(). The pull of 2
bytes in ppp_receive_frame() has been removed as it is no longer
required.

Signed-off-by: Simon Arlott <simon@fire.lp0.eu>
---
 drivers/net/ppp_generic.c |   29 ++++++++++++++++++-----------
 1 files changed, 18 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ppp_generic.c b/drivers/net/ppp_generic.c
index 6e281bc..75e8903 100644
--- a/drivers/net/ppp_generic.c
+++ b/drivers/net/ppp_generic.c
@@ -1567,13 +1567,22 @@ ppp_input(struct ppp_channel *chan, struct sk_buff *skb)
 	struct channel *pch = chan->ppp;
 	int proto;
 
-	if (!pch || skb->len == 0) {
+	if (!pch) {
 		kfree_skb(skb);
 		return;
 	}
 
-	proto = PPP_PROTO(skb);
 	read_lock_bh(&pch->upl);
+	if (!pskb_may_pull(skb, 2)) {
+		kfree_skb(skb);
+		if (pch->ppp) {
+			++pch->ppp->dev->stats.rx_length_errors;
+			ppp_receive_error(pch->ppp);
+		}
+		goto done;
+	}
+
+	proto = PPP_PROTO(skb);
 	if (!pch->ppp || proto >= 0xc000 || proto == PPP_CCPFRAG) {
 		/* put it on the channel queue */
 		skb_queue_tail(&pch->file.rq, skb);
@@ -1585,6 +1594,8 @@ ppp_input(struct ppp_channel *chan, struct sk_buff *skb)
 	} else {
 		ppp_do_recv(pch->ppp, skb, pch);
 	}
+
+done:
 	read_unlock_bh(&pch->upl);
 }
 
@@ -1617,7 +1628,8 @@ ppp_input_error(struct ppp_channel *chan, int code)
 static void
 ppp_receive_frame(struct ppp *ppp, struct sk_buff *skb, struct channel *pch)
 {
-	if (pskb_may_pull(skb, 2)) {
+	/* note: a 0-length skb is used as an error indication */
+	if (skb->len > 0) {
 #ifdef CONFIG_PPP_MULTILINK
 		/* XXX do channel-level decompression here */
 		if (PPP_PROTO(skb) == PPP_MP)
@@ -1625,15 +1637,10 @@ ppp_receive_frame(struct ppp *ppp, struct sk_buff *skb, struct channel *pch)
 		else
 #endif /* CONFIG_PPP_MULTILINK */
 			ppp_receive_nonmp_frame(ppp, skb);
-		return;
+	} else {
+		kfree_skb(skb);
+		ppp_receive_error(ppp);
 	}
-
-	if (skb->len > 0)
-		/* note: a 0-length skb is used as an error indication */
-		++ppp->dev->stats.rx_length_errors;
-
-	kfree_skb(skb);
-	ppp_receive_error(ppp);
 }
 
 static void
-- 
1.7.0.4

-- 
Simon Arlott
