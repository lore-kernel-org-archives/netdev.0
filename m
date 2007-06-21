From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 3/3] NET: [SCHED] Qdisc changes and sch_rr added for multiqueue
Date: Fri, 22 Jun 2007 01:47:30 +0200
Message-ID: <467B0E12.6030200@trash.net>
References: <20070621212629.31066.92148.stgit@localhost.localdomain> <20070621212647.31066.61074.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, jeff@garzik.org,
	auke-jan.h.kok@intel.com, hadi@cyberus.ca
To: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49662 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750936AbXFUXr5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jun 2007 19:47:57 -0400
In-Reply-To: <20070621212647.31066.61074.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

PJ Waskiewicz wrote:
> diff --git a/net/sched/Kconfig b/net/sched/Kconfig
> index 475df84..ca0b352 100644
> --- a/net/sched/Kconfig
> +++ b/net/sched/Kconfig
> @@ -102,8 +102,16 @@ config NET_SCH_ATM
>  	  To compile this code as a module, choose M here: the
>  	  module will be called sch_atm.
>  
> +config NET_SCH_BANDS
> +        bool "Multi Band Queueing (PRIO and RR)"
> +        ---help---
> +          Say Y here if you want to use n-band multiqueue packet
> +          schedulers.  These include a priority-based scheduler and
> +	   a round-robin scheduler.
> +
>  config NET_SCH_PRIO
>  	tristate "Multi Band Priority Queueing (PRIO)"
> +	depends on NET_SCH_BANDS
>  	---help---
>  	  Say Y here if you want to use an n-band priority queue packet
>  	  scheduler.
> @@ -111,6 +119,30 @@ config NET_SCH_PRIO
>  	  To compile this code as a module, choose M here: the
>  	  module will be called sch_prio.
>  
> +config NET_SCH_PRIO_MQ
> +	bool "Multiple hardware queue support for PRIO"
> +	depends on NET_SCH_PRIO
> +	---help---
> +	  Say Y here if you want to allow the PRIO qdisc to assign
> +	  flows to multiple hardware queues on an ethernet device.  This
> +	  will still work on devices with 1 queue.
> +
> +	  Consider this scheduler for devices that do not use
> +	  hardware-based scheduling policies.  Otherwise, use NET_SCH_RR.
> +
> +	  Most people will say N here.
> +
> +config NET_SCH_RR
> +	bool "Multi Band Round Robin Queuing (RR)"
> +	depends on NET_SCH_BANDS && NET_SCH_PRIO
> +	---help---
> +	  Say Y here if you want to use an n-band round robin packet
> +	  scheduler.
> +
> +	  The module uses sch_prio for its framework and is aliased as
> +	  sch_rr, so it will load sch_prio, although it is referred
> +	  to using sch_rr.
>   

The dependencies seem to be very confused. SCHED_PRIO does not depend
on anything new, SCH_RR also doesn't depend on anything. SCH_PRIO_MQ
and SCH_RR_MQ (which is missing) depend on SCH_PRIO/SCH_RR. A single
NET_SCH_MULTIQUEUE option seems better than adding one per scheduler
though.

> --- a/net/sched/sch_prio.c
> +++ b/net/sched/sch_prio.c
> @@ -9,6 +9,8 @@
>   * Authors:	Alexey Kuznetsov, <kuznet@ms2.inr.ac.ru>
>   * Fixes:       19990609: J Hadi Salim <hadi@nortelnetworks.com>:
>   *              Init --  EINVAL when opt undefined
> + * Additions:	Peter P. Waskiewicz Jr. <peter.p.waskiewicz.jr@intel.com>
> + *		Added round-robin scheduling for selection at load-time
>   

git keeps changelogs, please don't add it here.

>   */
>  
>  #include <linux/module.h>
> @@ -40,9 +42,13 @@
>  struct prio_sched_data
>  {
>  	int bands;
> +#ifdef CONFIG_NET_SCH_RR
> +	int curband; /* for round-robin */
> +#endif
>  	struct tcf_proto *filter_list;
>  	u8  prio2band[TC_PRIO_MAX+1];
>  	struct Qdisc *queues[TCQ_PRIO_BANDS];
> +	u16 band2queue[TC_PRIO_MAX + 1];
>   

Why is this still here? Its a 1:1 mapping.
> @@ -211,6 +265,22 @@ static int prio_tune(struct Qdisc *sch, struct rtattr *opt)
>  			return -EINVAL;
>  	}
>  
> +	/* If we're prio multiqueue or are using round-robin, make
> +	 * sure the number of incoming bands matches the number of
> +	 * queues on the device we're associating with.
> +	 */
> +#ifdef CONFIG_NET_SCH_RR
> +	if (strcmp("rr", sch->ops->id) == 0)
> +		if (qopt->bands != sch->dev->egress_subqueue_count)
> +			return -EINVAL;
> +#endif
> +
> +#ifdef CONFIG_NET_SCH_PRIO_MQ
> +	if (strcmp("prio", sch->ops->id) == 0)
> +		if (qopt->bands != sch->dev->egress_subqueue_count)
> +			return -EINVAL;
> +#endif
>   

For the tenth time now, the user should enable this at
runtime. You can't just break things dependant on config
options.


