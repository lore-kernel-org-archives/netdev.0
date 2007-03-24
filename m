From: John Heffner <jheffner@psc.edu>
Subject: [PATCH 2/3] [NET] Move DF check to ip_forward
Date: Fri, 23 Mar 2007 20:06:45 -0400
Message-ID: <11746948061847-git-send-email-jheffner@psc.edu>
References: <11746948063923-git-send-email-jheffner@psc.edu>
Cc: netdev@vger.kernel.org, John Heffner <jheffner@psc.edu>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.psc.edu ([128.182.58.100]:59455 "EHLO mailer1.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752354AbXCXAp1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Mar 2007 20:45:27 -0400
In-Reply-To: <11746948063923-git-send-email-jheffner@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Do fragmentation check in ip_forward, similar to ipv6 forwarding.  Also add
a debug printk in the DF check in ip_fragment since we should now never
reach it.

Signed-off-by: John Heffner <jheffner@psc.edu>
---
 net/ipv4/ip_forward.c |    8 ++++++++
 net/ipv4/ip_output.c  |    2 ++
 2 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/ip_forward.c b/net/ipv4/ip_forward.c
index 369e721..0efb1f5 100644
--- a/net/ipv4/ip_forward.c
+++ b/net/ipv4/ip_forward.c
@@ -85,6 +85,14 @@ int ip_forward(struct sk_buff *skb)
 	if (opt->is_strictroute && rt->rt_dst != rt->rt_gateway)
 		goto sr_failed;
 
+	if (unlikely(skb->len > dst_mtu(&rt->u.dst) &&
+	             (skb->nh.iph->frag_off & htons(IP_DF))) && !skb->local_df) {
+		IP_INC_STATS(IPSTATS_MIB_FRAGFAILS);
+		icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED,
+			  htonl(dst_mtu(&rt->u.dst)));
+		goto drop;
+	}
+
 	/* We are about to mangle packet. Copy it! */
 	if (skb_cow(skb, LL_RESERVED_SPACE(rt->u.dst.dev)+rt->u.dst.header_len))
 		goto drop;
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 593acf7..90bdd53 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -433,6 +433,8 @@ int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff*))
 	iph = skb->nh.iph;
 
 	if (unlikely((iph->frag_off & htons(IP_DF)) && !skb->local_df)) {
+		if (net_ratelimit())
+			printk(KERN_DEBUG "ip_fragment: requested fragment of packet with DF set\n");
 		IP_INC_STATS(IPSTATS_MIB_FRAGFAILS);
 		icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED,
 			  htonl(dst_mtu(&rt->u.dst)));
-- 
1.5.0.2.gc260-dirty

