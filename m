From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 07/15] {pktgen, xfrm} Add statistics counting when transforming
Date: Tue, 14 Jan 2014 07:49:11 +0100
Message-ID: <1389682159-3260-8-git-send-email-steffen.klassert@secunet.com>
References: <1389682159-3260-1-git-send-email-steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:60087 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751892AbaANGti (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jan 2014 01:49:38 -0500
In-Reply-To: <1389682159-3260-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fan Du <fan.du@windriver.com>

so /proc/net/xfrm_stat could give user clue about what's
wrong in this process.

Signed-off-by: Fan Du <fan.du@windriver.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
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
