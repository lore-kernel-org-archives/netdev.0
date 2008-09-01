From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [UPDATED] [NET-NEXT PATCH 1/2] pkt_sched: Add multiqueue
	scheduler support
Date: Mon, 1 Sep 2008 23:05:16 +0200
Message-ID: <20080901210516.GA5931@ami.dom.local>
References: <20080830072304.7597.24577.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org, davem@davemloft.net,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.156]:3653 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751843AbYIAVDw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2008 17:03:52 -0400
Received: by fg-out-1718.google.com with SMTP id 19so1619792fgg.17
        for <netdev@vger.kernel.org>; Mon, 01 Sep 2008 14:03:50 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080830072304.7597.24577.stgit@jtkirshe-mobile.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Kirsher wrote, On 08/30/2008 09:23 AM:

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> This patch is intended to add a qdisc to support the new tx multiqueue
> architecture by providing a band for each hardware queue.  By doing
> this it is possible to support a different qdisc per physical hardware
> queue.
> 
> This qdisc uses the skb->queue_mapping to select which band to place
> the traffic onto.  It then uses a round robin w/ a check to see if the
> subqueue is stopped to determine which band to dequeue the packet from.

Mostly looks OK to me, but a few (late) doubts below:

> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
> 
>  include/linux/pkt_sched.h |    6 +
>  net/sched/Kconfig         |    9 +
>  net/sched/Makefile        |    1 
>  net/sched/sch_multiq.c    |  470 +++++++++++++++++++++++++++++++++++++++++++++
>  4 files changed, 486 insertions(+), 0 deletions(-)
>  create mode 100644 net/sched/sch_multiq.c
> 
> diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
> index e5de421..7fbc952 100644
> --- a/include/linux/pkt_sched.h
> +++ b/include/linux/pkt_sched.h
> @@ -123,6 +123,12 @@ struct tc_prio_qopt
>  	__u8	priomap[TC_PRIO_MAX+1];	/* Map: logical priority -> PRIO band */
>  };
>  
> +/* MULTIQ section */
> +
> +struct tc_multiq_qopt {
> +	int	bands;			/* Number of bands */

Probably __u16 or __u32 would look better here.

> +};
> +
>  /* TBF section */
>  
>  struct tc_tbf_qopt
> diff --git a/net/sched/Kconfig b/net/sched/Kconfig
> index 9437b27..efaa7a7 100644
> --- a/net/sched/Kconfig
> +++ b/net/sched/Kconfig
> @@ -106,6 +106,15 @@ config NET_SCH_PRIO
>  	  To compile this code as a module, choose M here: the
>  	  module will be called sch_prio.
>  
> +config NET_SCH_MULTIQ
> +	tristate "Hardware Multiqueue-aware Multi Band Queuing (MULTIQ)"
> +	---help---
> +	  Say Y here if you want to use an n-band queue packet scheduler
> +	  to support devices that have multiple hardware transmit queues.
> +
> +	  To compile this code as a module, choose M here: the
> +	  module will be called sch_multiq.
> +

It would be nice to bring back a few lines about MULTIQ(RR) to
Documentation/networking/multiqueue.txt and mention this here.

>  config NET_SCH_RED
>  	tristate "Random Early Detection (RED)"
>  	---help---
> diff --git a/net/sched/Makefile b/net/sched/Makefile
> index 1d2b0f7..3d9b953 100644
> --- a/net/sched/Makefile
> +++ b/net/sched/Makefile
> @@ -26,6 +26,7 @@ obj-$(CONFIG_NET_SCH_SFQ)	+= sch_sfq.o
>  obj-$(CONFIG_NET_SCH_TBF)	+= sch_tbf.o
>  obj-$(CONFIG_NET_SCH_TEQL)	+= sch_teql.o
>  obj-$(CONFIG_NET_SCH_PRIO)	+= sch_prio.o
> +obj-$(CONFIG_NET_SCH_MULTIQ)	+= sch_multiq.o
>  obj-$(CONFIG_NET_SCH_ATM)	+= sch_atm.o
>  obj-$(CONFIG_NET_SCH_NETEM)	+= sch_netem.o
>  obj-$(CONFIG_NET_CLS_U32)	+= cls_u32.o
> diff --git a/net/sched/sch_multiq.c b/net/sched/sch_multiq.c
> new file mode 100644
> index 0000000..708dd5c
> --- /dev/null
> +++ b/net/sched/sch_multiq.c
> @@ -0,0 +1,470 @@
> +/*
> + * net/sched/sch_multiq.c
> + * 		This qdisc is based off of the rr qdisc and is meant to
> + * 		prevent head-of-line blocking on devices that have multiple
> + * 		hardware queues.
> + *
> + *		This program is free software; you can redistribute it and/or
> + *		modify it under the terms of the GNU General Public License
> + *		as published by the Free Software Foundation; either version
> + *		2 of the License, or (at your option) any later version.
> + *
> + * Authors:	Alexander Duyck <alexander.h.duyck@intel.com>
> + */
> +
> +#include <linux/module.h>
> +#include <linux/types.h>
> +#include <linux/kernel.h>
> +#include <linux/string.h>
> +#include <linux/errno.h>
> +#include <linux/skbuff.h>
> +#include <net/netlink.h>
> +#include <net/pkt_sched.h>
> +
> +
> +struct multiq_sched_data {
> +	int bands;
> +	int curband;

unsigned etc?

> +	struct tcf_proto *filter_list;
> +	struct Qdisc **queues;
> +

A spurious line.

> +};

...
> +static void
> +multiq_reset(struct Qdisc *sch)
> +{
> +	int band;
> +	struct multiq_sched_data *q = qdisc_priv(sch);
> +
> +	for (band = 0; band < q->bands; band++)
> +		qdisc_reset(q->queues[band]);
> +	sch->q.qlen = 0;

  +	q->curband = 0; ?

...
> +static int multiq_tune(struct Qdisc *sch, struct nlattr *opt)
> +{
> +	struct multiq_sched_data *q = qdisc_priv(sch);
> +	struct tc_multiq_qopt *qopt;
> +	struct Qdisc **queues;
> +	int i;
> +
> +	if (sch->parent != TC_H_ROOT)
> +		return -EINVAL;

Is it necessary?

> +	if (!netif_is_multiqueue(qdisc_dev(sch)))
> +		return -EINVAL;
> +	if (nla_len(opt) < sizeof(*qopt))
> +		return -EINVAL;
> +
> +	qopt = nla_data(opt);
> +
> +	qopt->bands = qdisc_dev(sch)->real_num_tx_queues;
> +
> +	queues = kzalloc(sizeof(struct Qdisc *)*qopt->bands, GFP_KERNEL);

kcalloc()?

...
> +static int multiq_dump(struct Qdisc *sch, struct sk_buff *skb)
> +{
> +	struct multiq_sched_data *q = qdisc_priv(sch);
> +	unsigned char *b = skb_tail_pointer(skb);
> +	struct nlattr *nest;
> +	struct tc_multiq_qopt opt;
> +
> +	opt.bands = q->bands;
> +
> +	nest = nla_nest_compat_start(skb, TCA_OPTIONS, sizeof(opt), &opt);

http://marc.info/?l=linux-netdev&m=121993231608269&w=2

> +	if (nest == NULL)
> +		goto nla_put_failure;
> +	nla_nest_compat_end(skb, nest);
...

Jarek P.
