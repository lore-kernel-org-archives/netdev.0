From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] ip_tunnel: fix kernel panic with icmp_dest_unreach
Date: Fri, 24 May 2013 08:49:58 -0700
Message-ID: <1369410598.3301.415.camel@edumazet-glaptop>
References: <D2CA09D3-A93C-48CF-A23B-DC1B76D66818@rcs-rds.ro>
	 <1369170063.3301.251.camel@edumazet-glaptop> <519C839E.1000309@rcs-rds.ro>
	 <1369222666.3301.304.camel@edumazet-glaptop> <519CB0D3.8000406@rcs-rds.ro>
	 <1369230739.3301.334.camel@edumazet-glaptop> <519CE6F0.3040703@rcs-rds.ro>
	 <519DD7A4.9090801@rcs-rds.ro> <1369324409.3301.382.camel@edumazet-glaptop>
	 <1369329033.3301.389.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Daniel Petre <daniel.petre@rcs-rds.ro>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:39262 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754601Ab3EXPuB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 May 2013 11:50:01 -0400
Received: by mail-pa0-f50.google.com with SMTP id fb11so3080504pad.37
        for <netdev@vger.kernel.org>; Fri, 24 May 2013 08:50:00 -0700 (PDT)
In-Reply-To: <1369329033.3301.389.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Daniel Petre reported crashes in icmp_dst_unreach() with following call
graph:

#3 [ffff88003fc03938] __stack_chk_fail at ffffffff81037f77
#4 [ffff88003fc03948] icmp_send at ffffffff814d5fec
#5 [ffff88003fc03ae8] ipv4_link_failure at ffffffff814a1795
#6 [ffff88003fc03af8] ipgre_tunnel_xmit at ffffffff814e7965
#7 [ffff88003fc03b78] dev_hard_start_xmit at ffffffff8146e032
#8 [ffff88003fc03bc8] sch_direct_xmit at ffffffff81487d66
#9 [ffff88003fc03c08] __qdisc_run at ffffffff81487efd
#10 [ffff88003fc03c48] dev_queue_xmit at ffffffff8146e5a7
#11 [ffff88003fc03c88] ip_finish_output at ffffffff814ab596

Daniel found a similar problem mentioned in 
 http://lkml.indiana.edu/hypermail/linux/kernel/1007.0/00961.html

And indeed this is the root cause : skb->cb[] contains data fooling IP
stack.

We must clear IPCB in ip_tunnel_xmit() sooner in case dst_link_failure()
is called. Or else skb->cb[] might contain garbage from GSO segmentation
layer.

A similar fix was tested on linux-3.9, but gre code was refactored in
linux-3.10. I'll send patches for stable kernels as well.

Many thanks to Daniel for providing reports, patches and testing !

Reported-by: Daniel Petre <daniel.petre@rcs-rds.ro>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/ip_tunnel.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index e4147ec..be2f8da 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -503,6 +503,7 @@ void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
 
 	inner_iph = (const struct iphdr *)skb_inner_network_header(skb);
 
+	memset(IPCB(skb), 0, sizeof(*IPCB(skb)));
 	dst = tnl_params->daddr;
 	if (dst == 0) {
 		/* NBMA tunnel */
@@ -658,7 +659,6 @@ void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
 
 	skb_dst_drop(skb);
 	skb_dst_set(skb, &rt->dst);
-	memset(IPCB(skb), 0, sizeof(*IPCB(skb)));
 
 	/* Push down and install the IP header. */
 	skb_push(skb, sizeof(struct iphdr));
