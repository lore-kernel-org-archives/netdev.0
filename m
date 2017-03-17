From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] sch_dsmark: fix invalid skb_cow() usage
Date: Fri, 17 Mar 2017 08:05:28 -0700
Message-ID: <1489763128.28631.286.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Wei Wang <weiwan@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:34964 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751311AbdCQPGF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Mar 2017 11:06:05 -0400
Received: by mail-pg0-f66.google.com with SMTP id g2so10201162pge.2
        for <netdev@vger.kernel.org>; Fri, 17 Mar 2017 08:05:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

skb_cow(skb, sizeof(ip header)) is not very helpful in this context.

First we need to use pskb_may_pull() to make sure the ip header
is in skb linear part, then use skb_try_make_writable() to
address clones issues.

Fixes: 4c30719f4f55 ("[PKT_SCHED] dsmark: handle cloned and non-linear skb's")
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/sched/sch_dsmark.c |   10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
index 802ac7c2e5e87eed1341ba4c09d3e5d70bc75876..5334e309f17f0ef4416dddcdc9278c14ecb5585d 100644
--- a/net/sched/sch_dsmark.c
+++ b/net/sched/sch_dsmark.c
@@ -201,9 +201,13 @@ static int dsmark_enqueue(struct sk_buff *skb, struct Qdisc *sch,
 	pr_debug("%s(skb %p,sch %p,[qdisc %p])\n", __func__, skb, sch, p);
 
 	if (p->set_tc_index) {
+		int wlen = skb_network_offset(skb);
+
 		switch (tc_skb_protocol(skb)) {
 		case htons(ETH_P_IP):
-			if (skb_cow_head(skb, sizeof(struct iphdr)))
+			wlen += sizeof(struct iphdr);
+			if (!pskb_may_pull(skb, wlen) ||
+			    skb_try_make_writable(skb, wlen))
 				goto drop;
 
 			skb->tc_index = ipv4_get_dsfield(ip_hdr(skb))
@@ -211,7 +215,9 @@ static int dsmark_enqueue(struct sk_buff *skb, struct Qdisc *sch,
 			break;
 
 		case htons(ETH_P_IPV6):
-			if (skb_cow_head(skb, sizeof(struct ipv6hdr)))
+			wlen += sizeof(struct ipv6hdr);
+			if (!pskb_may_pull(skb, wlen) ||
+			    skb_try_make_writable(skb, wlen))
 				goto drop;
 
 			skb->tc_index = ipv6_get_dsfield(ipv6_hdr(skb))
