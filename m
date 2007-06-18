From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/3] NET: [SCHED] Qdisc changes and sch_rr added for multiqueue
Date: Mon, 18 Jun 2007 21:05:31 +0200
Message-ID: <4676D77B.7020105@trash.net>
References: <20070618184208.12274.13017.stgit@localhost.localdomain> <20070618184224.12274.36798.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, jeff@garzik.org,
	auke-jan.h.kok@intel.com, hadi@cyberus.ca
To: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:40278 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762126AbXFRTFh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2007 15:05:37 -0400
In-Reply-To: <20070618184224.12274.36798.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

PJ Waskiewicz wrote:
>
> diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
> index 6d7542c..44ecdc6 100644
> --- a/net/sched/sch_prio.c
> +++ b/net/sched/sch_prio.c
>  	}
> +#ifdef CONFIG_NET_SCH_PRIO_MQ
> +	/* setup queue to band mapping */
> +	if (q->bands < sch->dev->egress_subqueue_count) {
> +		qmapoffset = 1;
> +		mod = sch->dev->egress_subqueue_count;
> +	} else {
> +		mod = q->bands % sch->dev->egress_subqueue_count;
> +		qmapoffset = q->bands / sch->dev->egress_subqueue_count
> +				+ ((mod) ? 1 : 0);
> +	}
> +
> +	queue = 0;
> +	offset = 0;
> +	for (i = 0; i < q->bands; i++) {
> +		q->band2queue[i] = queue;
> +		if ( ((i + 1) - offset) == qmapoffset) {
> +			queue++;
> +			offset += qmapoffset;
> +			if (mod)
> +				mod--;
> +			qmapoffset = q->bands /
> +				sch->dev->egress_subqueue_count +
> +				((mod) ? 1 : 0);
> +		}
> +	}
> +#endif

This should really go, its not only ugly, it also makes no sense to use
more bands than queues since that means multiple bands of different
priorities are controlled through a single queue state, so lower priority
bands can stop the queue for higher priority ones.

The user should enable multiqueue behaviour and using it with a non-matching
parameters should simply return an error.

>  	return 0;
>  }
>  
> diff --git a/net/sched/sch_rr.c b/net/sched/sch_rr.c
> new file mode 100644
> index 0000000..ce9f237
> --- /dev/null
> +++ b/net/sched/sch_rr.c

For which multiqueue capable device is this? Jamal mentioned that e1000 
uses drr.

> @@ -0,0 +1,516 @@
> +/*
> + * net/sched/sch_rr.c	Simple n-band round-robin scheduler.
> + *
> + *		This program is free software; you can redistribute it and/or
> + *		modify it under the terms of the GNU General Public License
> + *		as published by the Free Software Foundation; either version
> + *		2 of the License, or (at your option) any later version.
> + *
> + * The core part of this qdisc is based on sch_prio.  ->dequeue() is where
> + * this scheduler functionally differs.
> + *
> + * Author:	PJ Waskiewicz, <peter.p.waskiewicz.jr@intel.com>
> + *
> + * Original Authors (from PRIO): Alexey Kuznetsov, <kuznet@ms2.inr.ac.ru>
> + * Fixes:       19990609: J Hadi Salim <hadi@nortelnetworks.com>:
> + *              Init --  EINVAL when opt undefined
> + */
> +
> +#include <linux/module.h>
> +#include <asm/uaccess.h>
> +#include <asm/system.h>
> +#include <linux/bitops.h>
> +#include <linux/types.h>
> +#include <linux/kernel.h>
> +#include <linux/string.h>
> +#include <linux/mm.h>
> +#include <linux/socket.h>
> +#include <linux/sockios.h>
> +#include <linux/in.h>
> +#include <linux/errno.h>
> +#include <linux/interrupt.h>
> +#include <linux/if_ether.h>
> +#include <linux/inet.h>
> +#include <linux/netdevice.h>
> +#include <linux/etherdevice.h>
> +#include <linux/notifier.h>
> +#include <net/ip.h>
> +#include <net/route.h>
> +#include <linux/skbuff.h>
> +#include <net/netlink.h>
> +#include <net/sock.h>
> +#include <net/pkt_sched.h>

Lots os unnecessary includes. I have a patch that cleans this up for 
net/sched,
this is the relevant sch_prio part where you copied this from:

--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -12,28 +12,12 @@
  */
 
 #include <linux/module.h>
-#include <asm/uaccess.h>
-#include <asm/system.h>
-#include <linux/bitops.h>
 #include <linux/types.h>
 #include <linux/kernel.h>
 #include <linux/string.h>
-#include <linux/mm.h>
-#include <linux/socket.h>
-#include <linux/sockios.h>
-#include <linux/in.h>
 #include <linux/errno.h>
-#include <linux/interrupt.h>
-#include <linux/if_ether.h>
-#include <linux/inet.h>
-#include <linux/netdevice.h>
-#include <linux/etherdevice.h>
-#include <linux/notifier.h>
-#include <net/ip.h>
-#include <net/route.h>
 #include <linux/skbuff.h>
 #include <net/netlink.h>
-#include <net/sock.h>
 #include <net/pkt_sched.h>

> +
> +
> +struct rr_sched_data
> +{
> +	int bands;
> +	int curband;
> +	struct tcf_proto *filter_list;
> +	u8  prio2band[TC_RR_MAX + 1];
> +	struct Qdisc *queues[TCQ_RR_BANDS];
> +	u16 band2queue[TC_RR_MAX + 1];
> +};
> +
> +
> +static struct Qdisc *rr_classify(struct sk_buff *skb, struct Qdisc *sch,
> +				 int *qerr)
> +{
> +	struct rr_sched_data *q = qdisc_priv(sch);
> +	u32 band = skb->priority;
> +	struct tcf_result res;
> +
> +	*qerr = NET_XMIT_BYPASS;
> +	if (TC_H_MAJ(skb->priority) != sch->handle) {
> +#ifdef CONFIG_NET_CLS_ACT
> +		switch (tc_classify(skb, q->filter_list, &res)) {
> +		case TC_ACT_STOLEN:
> +		case TC_ACT_QUEUED:
> +			*qerr = NET_XMIT_SUCCESS;
> +		case TC_ACT_SHOT:
> +			return NULL;
> +		}
> +
> +		if (!q->filter_list ) {
> +#else
> +		if (!q->filter_list || tc_classify(skb, q->filter_list, &res)) {
> +#endif
> +			if (TC_H_MAJ(band))
> +				band = 0;
> + 			skb->queue_mapping =
> + 				  q->band2queue[q->prio2band[band&TC_RR_MAX]];
> +
> +			return q->queues[q->prio2band[band&TC_RR_MAX]];
> +		}
> +		band = res.classid;
> +	}
> +	band = TC_H_MIN(band) - 1;
> +	if (band > q->bands) {

You copied an off-by-one from an old sch_prio version here.

>
> +static int rr_tune(struct Qdisc *sch, struct rtattr *opt)
> +{
> +	struct rr_sched_data *q = qdisc_priv(sch);
> +	struct tc_rr_qopt *qopt = RTA_DATA(opt);


Nested attributes please, don't repeat sch_prio's mistake.


> ...
> +	/* setup queue to band mapping - best effort to map into available
> +	 * hardware queues
> +	 */
> +	if (q->bands < sch->dev->egress_subqueue_count) {
> +		qmapoffset = 1;
> +		mod = sch->dev->egress_subqueue_count;
> +	} else {
> +		mod = q->bands % sch->dev->egress_subqueue_count;
> +		qmapoffset = q->bands / sch->dev->egress_subqueue_count
> +				+ ((mod) ? 1 : 0);
> +	}
> +
> +	queue = 0;
> +	offset = 0;
> +	for (i = 0; i < q->bands; i++) {
> +		q->band2queue[i] = queue;
> +		if ( ((i + 1) - offset) == qmapoffset) {
> +			queue++;
> +			offset += qmapoffset;
> +			if (mod)
> +				mod--;
> +			qmapoffset = q->bands /
> +				sch->dev->egress_subqueue_count +
> +				((mod) ? 1 : 0);
> +		}
> +	}

Should go as well.


