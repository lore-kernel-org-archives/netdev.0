From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net PATCH] ipv6: Do not treat a GSO_TCPV4 request from UDP tunnel
 over IPv6 as invalid
Date: Fri, 21 Nov 2014 19:37:09 -0800
Message-ID: <20141122033603.22361.28896.stgit@ahduyck-server>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44278 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751760AbaKVDhM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Nov 2014 22:37:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds SKB_GSO_TCPV4 to the list of supported GSO types handled by
the IPv6 GSO offloads.  Without this change VXLAN tunnels running over IPv6
do not currently handle IPv4 TCP TSO requests correctly and end up handing
the non-segmented frame off to the device.

Below is the before and after for a simple netperf TCP_STREAM test between
two endpoints tunneling IPv4 over a VXLAN tunnel running on IPv6 on top of
a 1Gb/s network adapter.

Recv   Send    Send
Socket Socket  Message  Elapsed
Size   Size    Size     Time     Throughput
bytes  bytes   bytes    secs.    10^6bits/sec

 87380  16384  16384    10.29       0.88      Before
 87380  16384  16384    10.03     895.69      After

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 net/ipv6/ip6_offload.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
index a071563..01e12d0 100644
--- a/net/ipv6/ip6_offload.c
+++ b/net/ipv6/ip6_offload.c
@@ -69,7 +69,8 @@ static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb,
 	int nhoff;
 
 	if (unlikely(skb_shinfo(skb)->gso_type &
-		     ~(SKB_GSO_UDP |
+		     ~(SKB_GSO_TCPV4 |
+		       SKB_GSO_UDP |
 		       SKB_GSO_DODGY |
 		       SKB_GSO_TCP_ECN |
 		       SKB_GSO_GRE |
