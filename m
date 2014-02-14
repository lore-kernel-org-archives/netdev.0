From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: [PATCH] ipv4: use daddr to get inet_peer
Date: Fri, 14 Feb 2014 17:25:35 +0800
Message-ID: <52FDE10F.5010903@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, hannes@stressinduktion.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:36700 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751740AbaBNJ0f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Feb 2014 04:26:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


since commit 1d861aa4("inet: Minimize use of cached route inetpeer"),
ip_error() uses saddr to get inet_peer, so ip_error() and icmpv4_xrlim_allow()
use the same inet_peer to limit icmp error message twice.

In ip_error(), peer->rate_tokens is set to ip_rt_error_burst, but in
inet_peer_xrlim_allow() peer->rate_tokens is set to XRLIM_BURST_FACTOR.
XRLIM_BURST_FACTOR is defined to 6, so user seting ip_rt_error_burst makes
no sense.

In my opinion, the ip_rt_error_burst is used to limit icmp error messages
for daddr instead of saddr.

Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
---
 net/ipv4/route.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 25071b4..4da5588 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -933,7 +933,7 @@ static int ip_error(struct sk_buff *skb)
 		break;
 	}
 
-	peer = inet_getpeer_v4(net->ipv4.peers, ip_hdr(skb)->saddr, 1);
+	peer = inet_getpeer_v4(net->ipv4.peers, ip_hdr(skb)->daddr, 1);
 
 	send = true;
 	if (peer) {
-- 
1.8.3.1
