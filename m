From: Vicente Jimenez Aguilar <googuy@gmail.com>
Subject: [PATCH] icmp: Restore resistence to abnormal messages
Date: Fri, 11 Nov 2016 21:20:18 +0100
Message-ID: <20161111202018.13795-1-googuy@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Vicente Jimenez Aguilar <googuy@gmail.com>
To: "David S . Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36549 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934931AbcKKUUs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Nov 2016 15:20:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Restore network resistance to abnormal ICMP fragmentation needed messages
with next hop MTU equal to (or exceeding) dropped packet size

Fixes: 46517008e116 ("ipv4: Kill ip_rt_frag_needed().")
Signed-off-by: Vicente Jimenez Aguilar <googuy@gmail.com>
---
 net/ipv4/icmp.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 38abe70..4c90d76 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -773,6 +773,7 @@ static bool icmp_tag_validation(int proto)
 static bool icmp_unreach(struct sk_buff *skb)
 {
 	const struct iphdr *iph;
+	unsigned short old_mtu;
 	struct icmphdr *icmph;
 	struct net *net;
 	u32 info = 0;
@@ -819,6 +820,12 @@ static bool icmp_unreach(struct sk_buff *skb)
 				/* fall through */
 			case 0:
 				info = ntohs(icmph->un.frag.mtu);
+				/* Handle weird case where next hop MTU is
+				 * equal to or exceeding dropped packet size
+				 */
+				old_mtu = ntohs(iph->tot_len);
+				if (info >= old_mtu)
+					info = old_mtu - 2;
 			}
 			break;
 		case ICMP_SR_FAILED:
-- 
2.9.3
