From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] sit: enable lockless xmits
Date: Tue, 28 Sep 2010 14:53:41 +0200
Message-ID: <1285678421.3154.56.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:61261 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753691Ab0I1Mxq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Sep 2010 08:53:46 -0400
Received: by fxm3 with SMTP id 3so2527799fxm.19
        for <netdev@vger.kernel.org>; Tue, 28 Sep 2010 05:53:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SIT tunnels can benefit from lockless xmits, using NETIF_F_LLTX

Bench on a 16 cpus machine (dual E5540 cpus), 16 threads sending
10000000 UDP frames via one sit tunnel (size:220 bytes per frame)

Before patch : 

real	3m15.399s
user	0m9.185s
sys	51m55.403s

75029.00 87.5% _raw_spin_lock            vmlinux                                                             
 1090.00  1.3% dst_release               vmlinux                                                             
  902.00  1.1% dev_queue_xmit            vmlinux                                                             
  627.00  0.7% sock_wfree                vmlinux                                                             
  613.00  0.7% ip6_push_pending_frames   ipv6.ko
  505.00  0.6% __ip_route_output_key     vmlinux                                            

After patch:

real	1m1.387s
user	0m12.489s
sys	15m58.868s

28239.00 23.3% dst_release               vmlinux                                                             
13570.00 11.2% ip6_push_pending_frames   ipv6.ko
13118.00 10.8% ip6_append_data           ipv6.ko
 7995.00  6.6% __ip_route_output_key     vmlinux                                                             
 7924.00  6.5% sk_dst_check              vmlinux                                                             
 5015.00  4.1% udpv6_sendmsg             ipv6.ko
 3594.00  3.0% sock_alloc_send_pskb      vmlinux                                                             
 3135.00  2.6% sock_wfree                vmlinux                                                             
 3055.00  2.5% ip6_sk_dst_lookup         ipv6.ko
 2473.00  2.0% ip_finish_output          vmlinux               

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv6/sit.c |    1 +
 1 files changed, 1 insertion(+)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 011ecf5..d770178 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -1140,6 +1140,7 @@ static void ipip6_tunnel_setup(struct net_device *dev)
 	dev->iflink		= 0;
 	dev->addr_len		= 4;
 	dev->features		|= NETIF_F_NETNS_LOCAL;
+	dev->features		|= NETIF_F_LLTX;
 }
 
 static int ipip6_tunnel_init(struct net_device *dev)


