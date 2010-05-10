From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH V4 3/4] net: Use ip_route_input_noref() in input path
Date: Mon, 10 May 2010 23:33:06 +0200
Message-ID: <1273527186.10889.12.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:35213 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756016Ab0EJVdJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 17:33:09 -0400
Received: by wwa36 with SMTP id 36so1964635wwa.19
        for <netdev@vger.kernel.org>; Mon, 10 May 2010 14:33:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use ip_route_input_noref() in ip fast path, to avoid two atomic ops per
incoming packet.

Note: loopback is excluded from this optimization in ip_rcv_finish()

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
net/ipv4/arp.c         |    2 +-
net/ipv4/ip_input.c    |    4 ++--
net/ipv4/xfrm4_input.c |    4 ++--
3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 6e74706..f4ae3d4 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -854,7 +854,7 @@ static int arp_process(struct sk_buff *skb)
 	}
 
 	if (arp->ar_op == htons(ARPOP_REQUEST) &&
-	    ip_route_input(skb, tip, sip, 0, dev) == 0) {
+	    ip_route_input_noref(skb, tip, sip, 0, dev) == 0) {
 
 		rt = skb_rtable(skb);
 		addr_type = rt->rt_type;
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index f8ab7a3..6d5b65a 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -331,8 +331,8 @@ static int ip_rcv_finish(struct sk_buff *skb)
 	 *	how the packet travels inside Linux networking.
 	 */
 	if (skb_dst(skb) == NULL) {
-		int err = ip_route_input(skb, iph->daddr, iph->saddr, iph->tos,
-					 skb->dev);
+		int err = ip_route_input_noref(skb, iph->daddr, iph->saddr,
+					       iph->tos, skb->dev);
 		if (unlikely(err)) {
 			if (err == -EHOSTUNREACH)
 				IP_INC_STATS_BH(dev_net(skb->dev),
diff --git a/net/ipv4/xfrm4_input.c b/net/ipv4/xfrm4_input.c
index c791bb6..e7972d8 100644
--- a/net/ipv4/xfrm4_input.c
+++ b/net/ipv4/xfrm4_input.c
@@ -27,8 +27,8 @@ static inline int xfrm4_rcv_encap_finish(struct sk_buff *skb)
 	if (skb_dst(skb) == NULL) {
 		const struct iphdr *iph = ip_hdr(skb);
 
-		if (ip_route_input(skb, iph->daddr, iph->saddr, iph->tos,
-				   skb->dev))
+		if (ip_route_input_noref(skb, iph->daddr, iph->saddr,
+					 iph->tos, skb->dev))
 			goto drop;
 	}
 	return dst_input(skb);




