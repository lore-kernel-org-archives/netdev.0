From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 14/30] ipv4: Only compute net once in ip_rcv_finish
Date: Tue, 15 Sep 2015 20:04:02 -0500
Message-ID: <1442365458-16349-14-git-send-email-ebiederm@xmission.com>
References: <87mvwn18my.fsf@x220.int.ebiederm.org>
Cc: netfilter-devel@vger.kernel.org, <netdev@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:39405 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752226AbbIPBNm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2015 21:13:42 -0400
In-Reply-To: <87mvwn18my.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/ipv4/ip_input.c | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index ff908863f22e..cc242b9501d9 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -314,6 +314,7 @@ EXPORT_SYMBOL(sysctl_ip_early_demux);
 static int ip_rcv_finish(struct sock *sk, struct sk_buff *skb)
 {
 	const struct iphdr *iph = ip_hdr(skb);
+	struct net *net = dev_net(skb->dev);
 	struct rtable *rt;
 
 	if (sysctl_ip_early_demux && !skb_dst(skb) && !skb->sk) {
@@ -337,8 +338,7 @@ static int ip_rcv_finish(struct sock *sk, struct sk_buff *skb)
 					       iph->tos, skb->dev);
 		if (unlikely(err)) {
 			if (err == -EXDEV)
-				NET_INC_STATS_BH(dev_net(skb->dev),
-						 LINUX_MIB_IPRPFILTER);
+				NET_INC_STATS_BH(net, LINUX_MIB_IPRPFILTER);
 			goto drop;
 		}
 	}
@@ -359,11 +359,9 @@ static int ip_rcv_finish(struct sock *sk, struct sk_buff *skb)
 
 	rt = skb_rtable(skb);
 	if (rt->rt_type == RTN_MULTICAST) {
-		IP_UPD_PO_STATS_BH(dev_net(rt->dst.dev), IPSTATS_MIB_INMCAST,
-				skb->len);
+		IP_UPD_PO_STATS_BH(net, IPSTATS_MIB_INMCAST, skb->len);
 	} else if (rt->rt_type == RTN_BROADCAST)
-		IP_UPD_PO_STATS_BH(dev_net(rt->dst.dev), IPSTATS_MIB_INBCAST,
-				skb->len);
+		IP_UPD_PO_STATS_BH(net, IPSTATS_MIB_INBCAST, skb->len);
 
 	return dst_input(skb);
 
-- 
2.2.1
