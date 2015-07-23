From: Wei-Chun Chao <weichunc@plumgrid.com>
Subject: [PATCH net-next] ipv6: fix crash over flow-based vxlan device
Date: Wed, 22 Jul 2015 18:13:12 -0700
Message-ID: <1437613992-25953-1-git-send-email-weichunc@plumgrid.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net, ast@plumgrid.com,
	tgraf@suug.ch
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:34906 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752203AbbGWBNQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2015 21:13:16 -0400
Received: by pdrg1 with SMTP id g1so147295616pdr.2
        for <netdev@vger.kernel.org>; Wed, 22 Jul 2015 18:13:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Similar check was added in ip_rcv but not in ipv6_rcv.

BUG: unable to handle kernel NULL pointer dereference at (null)
IP: [<ffffffff81734e0a>] ipv6_rcv+0xfa/0x500
Call Trace:
[<ffffffff816c9786>] ? ip_rcv+0x296/0x400
[<ffffffff817732d2>] ? packet_rcv+0x52/0x410
[<ffffffff8168e99f>] __netif_receive_skb_core+0x63f/0x9a0
[<ffffffffc02b34a0>] ? br_handle_frame_finish+0x580/0x580 [bridge]
[<ffffffff8109912c>] ? update_rq_clock.part.81+0x1c/0x40
[<ffffffff8168ed18>] __netif_receive_skb+0x18/0x60
[<ffffffff8168fa1f>] process_backlog+0x9f/0x150

Fixes: ee122c79d422 (vxlan: Flow based tunneling)
Signed-off-by: Wei-Chun Chao <weichunc@plumgrid.com>
---
 net/ipv6/ip6_input.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index 57990c9..adba03a 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -45,6 +45,7 @@
 #include <net/addrconf.h>
 #include <net/xfrm.h>
 #include <net/inet_ecn.h>
+#include <net/dst_metadata.h>
 
 int ip6_rcv_finish(struct sock *sk, struct sk_buff *skb)
 {
@@ -55,7 +56,7 @@ int ip6_rcv_finish(struct sock *sk, struct sk_buff *skb)
 		if (ipprot && ipprot->early_demux)
 			ipprot->early_demux(skb);
 	}
-	if (!skb_dst(skb))
+	if (!skb_valid_dst(skb))
 		ip6_route_input(skb);
 
 	return dst_input(skb);
@@ -98,7 +99,7 @@ int ipv6_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt
 	 * arrived via the sending interface (ethX), because of the
 	 * nature of scoping architecture. --yoshfuji
 	 */
-	IP6CB(skb)->iif = skb_dst(skb) ? ip6_dst_idev(skb_dst(skb))->dev->ifindex : dev->ifindex;
+	IP6CB(skb)->iif = skb_valid_dst(skb) ? ip6_dst_idev(skb_dst(skb))->dev->ifindex : dev->ifindex;
 
 	if (unlikely(!pskb_may_pull(skb, sizeof(*hdr))))
 		goto err;
-- 
1.9.1
