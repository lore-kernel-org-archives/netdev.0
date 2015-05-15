From: Florian Westphal <fw@strlen.de>
Subject: [PATCH -next 3/3] net: core: use skb_tc_state to skip ingress classifiers
Date: Fri, 15 May 2015 10:50:50 +0200
Message-ID: <1431679850-31896-4-git-send-email-fw@strlen.de>
References: <1431679850-31896-1-git-send-email-fw@strlen.de>
Cc: jhs@mojatatu.com, alexei.starovoitov@gmail.com,
	daniel@iogearbox.net, Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:48186 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932940AbbEOIvB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2015 04:51:01 -0400
In-Reply-To: <1431679850-31896-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We can use either the tc_verd NCLS bit or tc_skb_state for this purpose.

If skb was received from network, both are zero.

If the skb was re-injected via sch_ingress + ifb driver, then
NCLS is set, but skb->tc_skb_state retains last value set up by
mirred action that brought us to ifb in first place (TC_FROM_INGRESS).

We can thus also use tc_skb_state instead to detect ifb
reinject-to-ingress.

After this patch NCLS bit is only used by ifb to skip the classsifiers
attached to its egress device.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/core/dev.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 802b9b9..e817fa9 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3805,9 +3805,9 @@ another_round:
 	}
 
 #ifdef CONFIG_NET_CLS_ACT
-	if (skb->tc_verd & TC_NCLS) {
-		skb->tc_verd = CLR_TC_NCLS(skb->tc_verd);
-		goto ncls;
+	if (skb->skb_tc_state) {
+		skb->skb_tc_state = 0;
+		goto skip_tc_ingress;
 	}
 #endif
 
@@ -3839,7 +3839,7 @@ skip_taps:
 #endif
 #ifdef CONFIG_NET_CLS_ACT
 	skb->tc_verd = 0;
-ncls:
+skip_tc_ingress:
 #endif
 	if (pfmemalloc && !skb_pfmemalloc_protocol(skb))
 		goto drop;
-- 
2.0.5
