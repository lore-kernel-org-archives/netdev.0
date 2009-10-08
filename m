From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RFC] multiqueue changes
Date: Thu, 8 Oct 2009 09:03:44 +0000
Message-ID: <20091008090344.GA7409@ff.dom.local>
References: <4ACD9255.4020008@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f210.google.com ([209.85.218.210]:60394 "EHLO
	mail-bw0-f210.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755875AbZJHJE0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2009 05:04:26 -0400
Received: by bwz6 with SMTP id 6so599103bwz.37
        for <netdev@vger.kernel.org>; Thu, 08 Oct 2009 02:03:49 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4ACD9255.4020008@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 08, 2009 at 09:18:45AM +0200, Eric Dumazet wrote:
> Say I have such non multiqueue device :
> 
> 03:00.0 Ethernet controller: Broadcom Corporation NetXtreme II BCM5708S Gigabit Ethernet (rev 12)
> 
> Driver bnx2
> 
> This drivers does an alloc_etherdev_mq(sizeof(*bp), TX_MAX_RINGS),
> regardless of real capabilities of the NIC.
> 
> Then, a bit later it does :
> 
> bp->dev->real_num_tx_queues = bp->num_tx_rings;  
> 
> (one in my non multiqueue case)
> 
> Now I have :
> 
> # tc -s -d qdisc show dev eth0
> qdisc mq 0: root
>  Sent 117693091 bytes 1542188 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> # tc -s -d class show dev eth0
> class mq :1 root
>  Sent 113935509 bytes 1492598 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :2 root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :3 root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :4 root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :5 root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :6 root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :7 root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> class mq :8 root
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> 
> While in previous kernels I had :
> 
> # tc -s -d qdisc show dev eth0
> qdisc pfifo_fast 0: root bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
>  Sent 26292963818 bytes 347139141 pkts (dropped 0, overlimits 0 requeues 0)
> # tc -s -d class show dev eth0
> 
> 
> So I lost the default pfifo_fast classification.

IMHO it (pfifo_fast qdiscs under mq root) could/should get back.

> 
> Just wondering if it could hurt some people.
> 
> Anyway, should we change bnx2/tg3 drivers so that single queue devices
> have same default qdisc/class than before ?
> 
> eg :
> 
> diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
> index 08cddb6..7cac205 100644
> --- a/drivers/net/bnx2.c
> +++ b/drivers/net/bnx2.c
> @@ -6152,6 +6152,7 @@ bnx2_setup_int_mode(struct bnx2 *bp, int dis_msi)
>  
>  	bp->num_tx_rings = rounddown_pow_of_two(bp->irq_nvecs);
>  	bp->dev->real_num_tx_queues = bp->num_tx_rings;
> +	bp->dev->num_tx_queues = bp->dev->real_num_tx_queues;
>  
>  	bp->num_rx_rings = bp->irq_nvecs;
>  }

It doesn't look consistent to me wrt. the comment in netdevice.h on
num_tx_queues. But it seems we should rather use more often
real_num_tx_queue in schedulers code like dumps and maybe more
(like e.g. sch_multiq does).

Jarek P.
