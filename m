From: Florian Westphal <fw@strlen.de>
Subject: [PATCH -next] bridge: fix potential use-after-free when hook returns QUEUE or STOLEN verdict
Date: Sat, 12 Mar 2016 11:14:42 +0100
Message-ID: <1457777682-24689-1-git-send-email-fw@strlen.de>
Cc: stephen@networkplumber.org, Florian Westphal <fw@strlen.de>,
	Felix Fietkau <nbd@openwrt.org>,
	Zefir Kurtisi <zefir.kurtisi@neratec.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:47664 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751241AbcCLKOf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Mar 2016 05:14:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Zefir Kurtisi reported kernel panic with an openwrt specific patch.
However, it turns out that mainline has a similar bug waiting to happen.

Once NF_HOOK() returns the skb is in undefined state and must not be
used.   Moreover, the okfn must consume the skb to support async
processing (NF_QUEUE).

Current okfn in this spot doesn't consume it and caller assumes that
NF_HOOK return value tells us if skb was freed or not, but thats wrong.

It "works" because no in-tree user registers a NFPROTO_BRIDGE hook at
LOCAL_IN that returns STOLEN or NF_QUEUE verdicts.

Once we add NF_QUEUE support for nftables bridge this will break --
NF_QUEUE holds the skb for async processing, caller will erronoulsy
return RX_HANDLER_PASS and on reinject netfilter will access free'd skb.

Fix this by pushing skb up the stack in the okfn instead.

NB: It also seems dubious to use LOCAL_IN while bypassing PRE_ROUTING
completely in this case but this is how its been forever so it seems
preferable to not change this.

Cc: Felix Fietkau <nbd@openwrt.org>
Cc: Zefir Kurtisi <zefir.kurtisi@neratec.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 
 net/bridge/br_input.c | 16 +++++++---------
 1 file changed, 7 insertions(+), 9 deletions(-)

diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index f7fba74..1607977 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -222,7 +222,10 @@ static int br_handle_local_finish(struct net *net, struct sock *sk, struct sk_bu
 	/* check if vlan is allowed, to avoid spoofing */
 	if (p->flags & BR_LEARNING && br_should_learn(p, skb, &vid))
 		br_fdb_update(p->br, p, eth_hdr(skb)->h_source, vid, false);
-	return 0;	 /* process further */
+
+	BR_INPUT_SKB_CB(skb)->brdev = p->br->dev;
+	br_pass_frame_up(skb);
+	return 0;
 }
 
 /*
@@ -284,14 +287,9 @@ rx_handler_result_t br_handle_frame(struct sk_buff **pskb)
 		}
 
 		/* Deliver packet to local host only */
-		if (NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_IN,
-			    dev_net(skb->dev), NULL, skb, skb->dev, NULL,
-			    br_handle_local_finish)) {
-			return RX_HANDLER_CONSUMED; /* consumed by filter */
-		} else {
-			*pskb = skb;
-			return RX_HANDLER_PASS;	/* continue processing */
-		}
+		NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_IN, dev_net(skb->dev),
+			NULL, skb, skb->dev, NULL, br_handle_local_finish);
+		return RX_HANDLER_CONSUMED;
 	}
 
 forward:
-- 
2.4.10
