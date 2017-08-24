From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: UDP sockets oddities
Date: Wed, 23 Aug 2017 17:43:46 -0700
Message-ID: <1503535426.2499.66.camel@edumazet-glaptop3.roam.corp.google.com>
References: <3fed7679-0e19-8a0a-eee6-11baa5654fac@gmail.com>
         <1503527210.2499.63.camel@edumazet-glaptop3.roam.corp.google.com>
         <9a9c1c94-4902-2ec9-d216-3f5cfb3044af@gmail.com>
         <1503529476.2499.65.camel@edumazet-glaptop3.roam.corp.google.com>
         <6c88e440-3f36-858d-1a08-bd32a2c66f4e@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@gmail.com, pabeni@redhat.com,
        willemb@google.com, davem@davemloft.net
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:36500 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751003AbdHXAnt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 20:43:49 -0400
Received: by mail-pg0-f68.google.com with SMTP id m7so1406043pga.3
        for <netdev@vger.kernel.org>; Wed, 23 Aug 2017 17:43:49 -0700 (PDT)
In-Reply-To: <6c88e440-3f36-858d-1a08-bd32a2c66f4e@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-08-23 at 17:03 -0700, Florian Fainelli wrote:

> Attached is the perf report --stdio of:
> 
> # perf record -a -g -e skb:kfree_skb iperf -c 192.168.1.23 -b 800M -t 60
> WARNING: option -b implies udp testing
> ------------------------------------------------------------
> Client connecting to 192.168.1.23, UDP port 5001
> Sending 1470 byte datagrams
> UDP buffer size:  160 KByte (default)
> ------------------------------------------------------------
> [  4] local 192.168.1.66 port 36169 connected with 192.168.1.23 port 5001
> [ ID] Interval       Transfer     Bandwidth
> [  4]  0.0-60.0 sec   685 MBytes  95.8 Mbits/sec
> [  4] Sent 488633 datagrams
> [  4] Server Report:
> [  4]  0.0-74.4 sec   685 MBytes  77.2 Mbits/sec   0.187 ms  300/488632
> (0.061%)
> [  4]  0.0-74.4 sec  58 datagrams received out-of-order
> 
> It measured 488644 events which is greater than the number of packets
> transmitted by iperf but I only count 8 non-IP packets being sent
> (protocl=2054 -> ETH_P_ARP) so I am not sure what the other 4 were and
> why there are not accounted for.
> 
> Almost all events came from net_tx_action() except 2 that came from
> net/core/neighbour.c::neigh_probe() and 65 that came from
> arch/arm/include/asm/irqflags.h::arch_local_irq_save() ?!?

Oh you have too much noise and need this fix :

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index dc3052751bc1..fcfa8d991850 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -597,7 +597,7 @@ static int bcm_sysport_set_coalesce(struct net_device *dev,
 
 static void bcm_sysport_free_cb(struct bcm_sysport_cb *cb)
 {
-	dev_kfree_skb_any(cb->skb);
+	dev_consume_skb_any(cb->skb);
 	cb->skb = NULL;
 	dma_unmap_addr_set(cb, dma_addr, 0);
 }
