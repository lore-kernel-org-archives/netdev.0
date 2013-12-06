From: Fan Du <fan.du@windriver.com>
Subject: [PATCHv2 net-next 5/5] {pktgen, xfrm} Correct xfrm state lock usage when transforming
Date: Fri, 6 Dec 2013 17:53:34 +0800
Message-ID: <1386323614-5077-6-git-send-email-fan.du@windriver.com>
References: <1386323614-5077-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <steffen.klassert@secunet.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:50719 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757292Ab3LFJxn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 04:53:43 -0500
In-Reply-To: <1386323614-5077-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

xfrm_state lock protects its state, i.e., VALID/DEAD and statistics,
not the transforming procedure, as both mode/type output functions
are reentrant.

Signed-off-by: Fan Du <fan.du@windriver.com>
---
 net/core/pktgen.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index f2a2a98..10237a3 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -2499,8 +2499,6 @@ static int pktgen_output_ipsec(struct sk_buff *skb, struct pktgen_dev *pkt_dev)
 	if (x->props.mode == XFRM_MODE_TUNNEL)
 		__skb_dst_set_noref(skb, &pkt_dev->dst, true);
 
-	spin_lock(&x->lock);
-
 	err = x->outer_mode->output(x, skb);
 	if (err)
 		goto error;
@@ -2508,10 +2506,11 @@ static int pktgen_output_ipsec(struct sk_buff *skb, struct pktgen_dev *pkt_dev)
 	if (err)
 		goto error;
 
+	spin_lock(&x->lock);
 	x->curlft.bytes += skb->len;
 	x->curlft.packets++;
-error:
 	spin_unlock(&x->lock);
+error:
 	return err;
 }
 
-- 
1.7.9.5
