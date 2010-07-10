From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] act_nat: not all of the ICMP packets need an IP header payload
Date: Sat, 10 Jul 2010 09:33:25 +0800
Message-ID: <1278725605-28598-1-git-send-email-xiaosuo@gmail.com>
Cc: Jamal Hadi Salim <hadi@cyberus.ca>,
	=?UTF-8?q?Rodrigo=20Partearroyo=20Gonz=C3=A1lez?=
	<rpartearroyo@albentia.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Iratxo Pichel Ortiz <ipichel@albentia.com>,
	=?UTF-8?q?Noelia=20Mor=C3=B3n?= <nmoron@albentia.com>,
	netdev@vger.kernel.org, Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:35522 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751053Ab0GJBgA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jul 2010 21:36:00 -0400
Received: by pxi14 with SMTP id 14so1087200pxi.19
        for <netdev@vger.kernel.org>; Fri, 09 Jul 2010 18:35:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

act_nat: not all of the ICMP packets need an IP header payload

not all of the ICMP packets need an IP header payload, so we check the length
of the skbs only when the packets should have an IP header payload.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
 net/sched/act_nat.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)
diff --git a/net/sched/act_nat.c b/net/sched/act_nat.c
index 0be49a4..24e614c 100644
--- a/net/sched/act_nat.c
+++ b/net/sched/act_nat.c
@@ -205,7 +205,7 @@ static int tcf_nat(struct sk_buff *skb, struct tc_action *a,
 	{
 		struct icmphdr *icmph;
 
-		if (!pskb_may_pull(skb, ihl + sizeof(*icmph) + sizeof(*iph)))
+		if (!pskb_may_pull(skb, ihl + sizeof(*icmph)))
 			goto drop;
 
 		icmph = (void *)(skb_network_header(skb) + ihl);
@@ -215,6 +215,9 @@ static int tcf_nat(struct sk_buff *skb, struct tc_action *a,
 		    (icmph->type != ICMP_PARAMETERPROB))
 			break;
 
+		if (!pskb_may_pull(skb, ihl + sizeof(*icmph) + sizeof(*iph)))
+			goto drop;
+
 		iph = (void *)(icmph + 1);
 		if (egress)
 			addr = iph->daddr;
