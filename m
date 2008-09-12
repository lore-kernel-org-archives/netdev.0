From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [NET-NEXT PATCH 2/3][UPDATED] pkt_sched: Add multiqueue
	scheduler support
Date: Sat, 13 Sep 2008 00:42:12 +0200
Message-ID: <20080912224212.GA16662@ami.dom.local>
References: <20080912030750.6982.26892.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, jeff@garzik.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.30]:39171 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758051AbYILWkk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2008 18:40:40 -0400
Received: by yx-out-2324.google.com with SMTP id 8so407181yxm.1
        for <netdev@vger.kernel.org>; Fri, 12 Sep 2008 15:40:39 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080912030750.6982.26892.stgit@jtkirshe-mobile.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Kirsher wrote, On 09/12/2008 05:08 AM:

> From: Alexander Duyck <alexander.h.duyck@intel.com>
...
> diff --git a/Documentation/networking/multiqueue.txt b/Documentation/networking/multiqueue.txt
> index d391ea6..5787ee6 100644
> --- a/Documentation/networking/multiqueue.txt
> +++ b/Documentation/networking/multiqueue.txt
> @@ -24,4 +24,49 @@ netif_{start|stop|wake}_subqueue() functions to manage each queue while the
>  device is still operational.  netdev->queue_lock is still used when the device
>  comes online or when it's completely shut down (unregister_netdev(), etc.).
>  
> -Author: Peter P. Waskiewicz Jr. <peter.p.waskiewicz.jr@intel.com>
> +
> +Section 2: Qdisc support for multiqueue devices
> +
> +-----------------------------------------------
> +
> +Currently two qdiscs support multiqueue devices.

This looks like a bit misleading: one could think it's necessary to use
one of these two with mq devices.

>  The first is the default
> +pfifo_fast qdisc.  This qdisc supports one qdisc per hardware queue.  A new
> +round-robin qdisc, sch_multiq also supports multiple hardware queues. The
> +qdisc is responsible for classifying the skb's and then directing the skb's to
> +bands and queues based on the value in skb->queue_mapping.  Use this field in
> +the base driver to determine which queue to send the skb to.
> +
> +sch_multiq has been added for hardware that wishes to avoid unnecessary
> +requeuing.

This could suggest that other qdiscs don't wish the same or even
generate excessive requeuing, which IMHO could be true, but it's not
proven, and might be only temporary situation anyway...

Anyway, I wonder why you don't mention here anything from your first
nice explantion to my doubts around the first attempt to restore
multiqueue to prio, like EEDC/DCB/etc?

>   It will cycle though the bands and verify that the hardware queue
> +associated with the band is not stopped prior to dequeuing a packet.
> +
> +On qdisc load, the number of bands is based on the number of queues on the
> +hardware.  Once the association is made, any skb with skb->queue_mapping set,
> +will be queued to the band associated with the hardware queue.
> +
> +
> +Section 3: Brief howto using MULTIQ for multiqueue devices
> +---------------------------------------------------------------
> +
> +The userspace command 'tc,' part of the iproute2 package, is used to configure
> +qdiscs.  To add the MULTIQ qdisc to your network device, assuming the device
> +is called eth0, run the following command:
> +
> +# tc qdisc add dev eth0 root handle 1: multiq
> +
> +The qdisc will allocate the number of bands to equal the number of queues that
> +the device reports, and bring the qdisc online.  Assuming eth0 has 4 Tx
> +queues, the band mapping would look like:
> +
> +band 0 => queue 0
> +band 1 => queue 1
> +band 2 => queue 2
> +band 3 => queue 3
> +
> +Traffic will begin flowing through each queue if your base device has either
> +the default simple_tx_hash or a custom netdev->select_queue() defined.

I think a device doesn't need to have simple_tx_hash defined?

...
> +static int multiq_tune(struct Qdisc *sch, struct nlattr *opt)
> +{
> +	struct multiq_sched_data *q = qdisc_priv(sch);
> +	struct tc_multiq_qopt *qopt;
> +	int i;
> +
> +	if (sch->parent != TC_H_ROOT)
> +		return -EINVAL;
> +	if (!netif_is_multiqueue(qdisc_dev(sch)))
> +		return -EINVAL;
> +	if (nla_len(opt) < sizeof(*qopt))
> +		return -EINVAL;
> +
> +	qopt = nla_data(opt);
> +
> +	qopt->bands = qdisc_dev(sch)->real_num_tx_queues;
> +
> +	sch_tree_lock(sch);
> +	q->bands = qopt->bands;
> +	for (i = q->bands; i < q->max_bands; i++) {
> +		struct Qdisc *child = xchg(&q->queues[i], &noop_qdisc);
> +		if (child != &noop_qdisc) {

Or maybe?:
		if (q->queues[i] != &noop_qdisc) {
			struct Qdisc *child = xchg(&q->queues[i], &noop_qdisc);

> +			qdisc_tree_decrease_qlen(child, child->q.qlen);
> +			qdisc_destroy(child);
> +		}
> +	}
...
> +static int multiq_init(struct Qdisc *sch, struct nlattr *opt)
> +{
> +	struct multiq_sched_data *q = qdisc_priv(sch);
> +	int i;
> +
> +	q->queues = NULL;
> +
> +	if (opt == NULL)
> +		return -EINVAL;
> +
> +	q->max_bands = qdisc_dev(sch)->num_tx_queues;
> +
> +	q->queues = kcalloc(q->max_bands, sizeof(struct Qdisc *), GFP_KERNEL);
> +	if (!q->queues)
> +		return -ENOBUFS;
> +	for (i = 0; i < q->max_bands; i++)
> +		q->queues[i] = &noop_qdisc;
> +
> +	return multiq_tune(sch, opt);

But multiq_tune() can EINVAL, so kfree is needed here.

Jarek P.

PS: to save some "paper" a typo, I guess, from PATCH 3/3:

> +The behavior of tc filters remains the same.  However a new tc action,
> +skbedit, has been added.  Assuming you wanted to route all traffic to a
> +specific host, for example 192.168.0.3, though a specific queue you could use

 +specific host, for example 192.168.0.3, through a specific queue you could use
