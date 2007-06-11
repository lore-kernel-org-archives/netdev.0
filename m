From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Mon, 11 Jun 2007 19:36:59 +0200
Message-ID: <466D883B.5050409@trash.net>
References: <20070604214037.1524.58506.stgit@localhost.localdomain> <20070604214045.1524.18254.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, jeff@garzik.org,
	auke-jan.h.kok@intel.com
To: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:47884 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752297AbXFKRjc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2007 13:39:32 -0400
In-Reply-To: <20070604214045.1524.18254.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

PJ Waskiewicz wrote:
> diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
> index f28bb2d..b9dc2a6 100644
> --- a/net/sched/sch_generic.c
> +++ b/net/sched/sch_generic.c
> @@ -123,7 +123,8 @@ static inline int qdisc_restart(struct net_device *dev)
>  			/* And release queue */
>  			spin_unlock(&dev->queue_lock);
>  
> -			if (!netif_queue_stopped(dev)) {
> +			if (!netif_queue_stopped(dev) &&
> +			    !netif_subqueue_stopped(dev, skb->queue_mapping)) {
>  				int ret;
>  
>  				ret = dev_hard_start_xmit(skb, dev);


Your patch doesn't update any other users of netif_queue_stopped().
The assumption that they can pass packets to the driver when the
queue is running is no longer valid since they don't know whether
the subqueue the packet will end up in is active (it might be
different from queue 0 if packets were redirected from a multiqueue
aware qdisc through TC actions). So they need to be changed to
check the subqueue state as well.

BTW, I couldn't find anything but a single netif_wake_subqueue
in your (old) e1000 patch. Why doesn't it stop subqueues?
