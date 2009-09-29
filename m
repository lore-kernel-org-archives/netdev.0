From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: restore tx timestamping for accelerated vlans
Date: Tue, 29 Sep 2009 14:57:37 +0200
Message-ID: <4AC20441.8040004@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:50005 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751609AbZI2M5h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2009 08:57:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit 9b22ea560957de1484e6b3e8538f7eef202e3596
( net: fix packet socket delivery in rx irq handler )

We lost rx timestamping of packets received on accelerated vlans.

Effect is that tcpdump on real dev can show strange timings, since it gets rx timestamps
too late (ie at skb dequeueing time, not at skb queueing time)

14:47:26.986871 IP 192.168.20.110 > 192.168.20.141: icmp 64: echo request seq 1
14:47:26.986786 IP 192.168.20.141 > 192.168.20.110: icmp 64: echo reply seq 1

14:47:27.986888 IP 192.168.20.110 > 192.168.20.141: icmp 64: echo request seq 2
14:47:27.986781 IP 192.168.20.141 > 192.168.20.110: icmp 64: echo reply seq 2

14:47:28.986896 IP 192.168.20.110 > 192.168.20.141: icmp 64: echo request seq 3
14:47:28.986780 IP 192.168.20.141 > 192.168.20.110: icmp 64: echo reply seq 3

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/dev.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 560c8c9..b8f74cf 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2288,6 +2288,9 @@ int netif_receive_skb(struct sk_buff *skb)
 	int ret = NET_RX_DROP;
 	__be16 type;
 
+	if (!skb->tstamp.tv64)
+		net_timestamp(skb);
+
 	if (skb->vlan_tci && vlan_hwaccel_do_receive(skb))
 		return NET_RX_SUCCESS;
 
@@ -2295,9 +2298,6 @@ int netif_receive_skb(struct sk_buff *skb)
 	if (netpoll_receive_skb(skb))
 		return NET_RX_DROP;
 
-	if (!skb->tstamp.tv64)
-		net_timestamp(skb);
-
 	if (!skb->iif)
 		skb->iif = skb->dev->ifindex;
 
