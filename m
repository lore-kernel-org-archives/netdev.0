From: Fan Du <fan.du@windriver.com>
Subject: [PATCHv3 net-next 2/7] {pktgen, xfrm} Add statistics counting when transforming
Date: Sun, 15 Dec 2013 15:57:59 +0800
Message-ID: <1387094284-2901-3-git-send-email-fan.du@windriver.com>
References: <1387094284-2901-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <steffen.klassert@secunet.com>, <hadi@cyberus.ca>,
	<netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:38623 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751147Ab3LOH6z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Dec 2013 02:58:55 -0500
In-Reply-To: <1387094284-2901-1-git-send-email-fan.du@windriver.com>
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
