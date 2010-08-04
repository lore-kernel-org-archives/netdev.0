From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] act_nat: fix on the TX path
Date: Wed,  4 Aug 2010 11:39:18 +0800
Message-ID: <1280893158-22103-1-git-send-email-xiaosuo@gmail.com>
Cc: Jamal Hadi Salim <hadi@cyberus.ca>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:47138 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758121Ab0HDDjn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Aug 2010 23:39:43 -0400
Received: by pwi5 with SMTP id 5so1858221pwi.19
        for <netdev@vger.kernel.org>; Tue, 03 Aug 2010 20:39:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On the TX path, skb->data points to the ethernet header, not the network
header. So when validating the packet length for accessing we should
take the ethernet header into account.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 net/sched/act_nat.c |   23 +++++++++++++----------
 1 file changed, 13 insertions(+), 10 deletions(-)
diff --git a/net/sched/act_nat.c b/net/sched/act_nat.c
index d0386a4..509a2d5 100644
--- a/net/sched/act_nat.c
+++ b/net/sched/act_nat.c
@@ -114,6 +114,7 @@ static int tcf_nat(struct sk_buff *skb, struct tc_action *a,
 	int egress;
 	int action;
 	int ihl;
+	int noff;
 
 	spin_lock(&p->tcf_lock);
 
@@ -132,7 +133,8 @@ static int tcf_nat(struct sk_buff *skb, struct tc_action *a,
 	if (unlikely(action == TC_ACT_SHOT))
 		goto drop;
 
-	if (!pskb_may_pull(skb, sizeof(*iph)))
+	noff = skb_network_offset(skb);
+	if (!pskb_may_pull(skb, sizeof(*iph) + noff))
 		goto drop;
 
 	iph = ip_hdr(skb);
@@ -144,7 +146,7 @@ static int tcf_nat(struct sk_buff *skb, struct tc_action *a,
 
 	if (!((old_addr ^ addr) & mask)) {
 		if (skb_cloned(skb) &&
-		    !skb_clone_writable(skb, sizeof(*iph)) &&
+		    !skb_clone_writable(skb, sizeof(*iph) + noff) &&
 		    pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
 			goto drop;
 
@@ -172,9 +174,9 @@ static int tcf_nat(struct sk_buff *skb, struct tc_action *a,
 	{
 		struct tcphdr *tcph;
 
-		if (!pskb_may_pull(skb, ihl + sizeof(*tcph)) ||
+		if (!pskb_may_pull(skb, ihl + sizeof(*tcph) + noff) ||
 		    (skb_cloned(skb) &&
-		     !skb_clone_writable(skb, ihl + sizeof(*tcph)) &&
+		     !skb_clone_writable(skb, ihl + sizeof(*tcph) + noff) &&
 		     pskb_expand_head(skb, 0, 0, GFP_ATOMIC)))
 			goto drop;
 
@@ -186,9 +188,9 @@ static int tcf_nat(struct sk_buff *skb, struct tc_action *a,
 	{
 		struct udphdr *udph;
 
-		if (!pskb_may_pull(skb, ihl + sizeof(*udph)) ||
+		if (!pskb_may_pull(skb, ihl + sizeof(*udph) + noff) ||
 		    (skb_cloned(skb) &&
-		     !skb_clone_writable(skb, ihl + sizeof(*udph)) &&
+		     !skb_clone_writable(skb, ihl + sizeof(*udph) + noff) &&
 		     pskb_expand_head(skb, 0, 0, GFP_ATOMIC)))
 			goto drop;
 
@@ -205,7 +207,7 @@ static int tcf_nat(struct sk_buff *skb, struct tc_action *a,
 	{
 		struct icmphdr *icmph;
 
-		if (!pskb_may_pull(skb, ihl + sizeof(*icmph)))
+		if (!pskb_may_pull(skb, ihl + sizeof(*icmph) + noff))
 			goto drop;
 
 		icmph = (void *)(skb_network_header(skb) + ihl);
@@ -215,7 +217,8 @@ static int tcf_nat(struct sk_buff *skb, struct tc_action *a,
 		    (icmph->type != ICMP_PARAMETERPROB))
 			break;
 
-		if (!pskb_may_pull(skb, ihl + sizeof(*icmph) + sizeof(*iph)))
+		if (!pskb_may_pull(skb, ihl + sizeof(*icmph) + sizeof(*iph) +
+					noff))
 			goto drop;
 
 		icmph = (void *)(skb_network_header(skb) + ihl);
@@ -229,8 +232,8 @@ static int tcf_nat(struct sk_buff *skb, struct tc_action *a,
 			break;
 
 		if (skb_cloned(skb) &&
-		    !skb_clone_writable(skb,
-					ihl + sizeof(*icmph) + sizeof(*iph)) &&
+		    !skb_clone_writable(skb, ihl + sizeof(*icmph) +
+					     sizeof(*iph) + noff) &&
 		    pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
 			goto drop;
 
