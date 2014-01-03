From: Fan Du <fan.du@windriver.com>
Subject: [PATCHv4 net-next 2/8] {pktgen, xfrm} Add statistics counting when transforming
Date: Fri, 3 Jan 2014 11:18:28 +0800
Message-ID: <1388719114-26244-3-git-send-email-fan.du@windriver.com>
References: <1388719114-26244-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:47819 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753548AbaACDSm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 22:18:42 -0500
In-Reply-To: <1388719114-26244-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

so /proc/net/xfrm_stat could give user clue about what's
wrong in this process.

Signed-off-by: Fan Du <fan.du@windriver.com>
---
 net/core/pktgen.c |   10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index b007586..156d57b 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -2479,6 +2479,7 @@ static int pktgen_output_ipsec(struct sk_buff *skb, struct pktgen_dev *pkt_dev)
 {
 	struct xfrm_state *x = pkt_dev->flows[pkt_dev->curfl].x;
 	int err = 0;
+	struct net *net = dev_net(pkt_dev->odev);
 
 	if (!x)
 		return 0;
@@ -2488,12 +2489,15 @@ static int pktgen_output_ipsec(struct sk_buff *skb, struct pktgen_dev *pkt_dev)
 		return 0;
 
 	err = x->outer_mode->output(x, skb);
-	if (err)
+	if (err) {
+		XFRM_INC_STATS(net, LINUX_MIB_XFRMOUTSTATEMODEERROR);
 		goto error;
+	}
 	err = x->type->output(x, skb);
-	if (err)
+	if (err) {
+		XFRM_INC_STATS(net, LINUX_MIB_XFRMOUTSTATEPROTOERROR);
 		goto error;
-
+	}
 	spin_lock_bh(&x->lock);
 	x->curlft.bytes += skb->len;
 	x->curlft.packets++;
-- 
1.7.9.5
