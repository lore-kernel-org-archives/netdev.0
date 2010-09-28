From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] ipip: enable lockless xmits
Date: Tue, 28 Sep 2010 12:17:17 +0200
Message-ID: <1285669037.3154.14.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:41242 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754081Ab0I1KRW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Sep 2010 06:17:22 -0400
Received: by fxm3 with SMTP id 3so2466331fxm.19
        for <netdev@vger.kernel.org>; Tue, 28 Sep 2010 03:17:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IPIP tunnels can benefit from lockless xmits, using NETIF_F_LLTX


Bench on a 16 cpus machine (dual E5540 cpus), 16 threads sending
10000000 UDP frames via one ipip tunnel (size:200 bytes per frame)

Before patch : 
real	2m53.321s
user	0m10.277s
sys	46m0.597s


After patch:
real	0m32.063s
user	0m9.237s
sys	8m16.255s


Last problem to solve is the contention on dst :

16118.00 28.3% __ip_route_output_key         vmlinux
 6135.00 10.8% dst_release                   vmlinux
 3220.00  5.6% ip_finish_output              vmlinux
 2149.00  3.8% ip_route_output_flow          vmlinux
 1575.00  2.8% ip_append_data                vmlinux
 1481.00  2.6% ip_push_pending_frames        vmlinux
 1349.00  2.4% __xfrm_lookup                 vmlinux
 1216.00  2.1% csum_partial_copy_generic     vmlinux
 1208.00  2.1% udp_sendmsg                   vmlinux


Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/ipip.c |    1 +
 1 files changed, 1 insertion(+)

diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 12b6fde..6ad46c2 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -767,6 +767,7 @@ static void ipip_tunnel_setup(struct net_device *dev)
 	dev->iflink		= 0;
 	dev->addr_len		= 4;
 	dev->features		|= NETIF_F_NETNS_LOCAL;
+	dev->features		|= NETIF_F_LLTX;
 	dev->priv_flags		&= ~IFF_XMIT_DST_RELEASE;
 }
 


