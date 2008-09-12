From: "Duyck, Alexander H" <alexander.h.duyck@intel.com>
Subject: RE: [NET-NEXT PATCH 2/3][UPDATED] pkt_sched: Add multiqueue
	scheduler support
Date: Fri, 12 Sep 2008 16:33:45 -0700
Message-ID: <80769D7B14936844A23C0C43D9FBCF0F156E4802@orsmsx501.amr.corp.intel.com>
References: <20080912030750.6982.26892.stgit@jtkirshe-mobile.jf.intel.com>
 <20080912224212.GA16662@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"jeff@garzik.org" <jeff@garzik.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>
To: Jarek Poplawski <jarkao2@gmail.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:1928 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756775AbYILXdr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2008 19:33:47 -0400
In-Reply-To: <20080912224212.GA16662@ami.dom.local>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
----------------------------------------------
>> +
>> +Currently two qdiscs support multiqueue devices.
>
> This looks like a bit misleading: one could think it's necessary to
> use one of these two with mq devices.
>
How about I change this from "support" to "are optimized for".  Would
that work better for you?

>> +
>> +sch_multiq has been added for hardware that wishes to avoid
>> +unnecessary requeuing.
>
> This could suggest that other qdiscs don't wish the same or even
> generate excessive requeuing, which IMHO could be true, but it's not
> proven, and might be only temporary situation anyway...
>
> Anyway, I wonder why you don't mention here anything from your first
> nice explantion to my doubts around the first attempt to restore
> multiqueue to prio, like EEDC/DCB/etc?

Actually this was just a poor choice of words on my part.  I should
probably replace "unnecessary requeueing" with "head-of-line blocking".


>> +Traffic will begin flowing through each queue if your base device
>> +has either the default simple_tx_hash or a custom
>> +netdev->select_queue() defined.
>
> I think a device doesn't need to have simple_tx_hash defined?

Actually simple_tx_hash is the default hash function that netdev uses
if select_queue is not defined.  Another poor choice of wording.  It
Should have been "..each queue via either the default simple_tx_hash
or the netdev->select_queue function if you have it defined".

>> +     for (i = q->bands; i < q->max_bands; i++) {
>> +             struct Qdisc *child = xchg(&q->queues[i], &noop_qdisc);
>> +             if (child != &noop_qdisc) {
>
> Or maybe?:
>                 if (q->queues[i] != &noop_qdisc) {
>                         struct Qdisc *child = xchg(&q->queues[i],
>                                                    &noop_qdisc);
>
>> +                     qdisc_tree_decrease_qlen(child, child->q.qlen);
>> +                     qdisc_destroy(child);
>> +             }
>> +     }
I suppose I can make this change since we are already protected by the
tree lock already.

>> +static int multiq_init(struct Qdisc *sch, struct nlattr *opt) +{
>> +     struct multiq_sched_data *q = qdisc_priv(sch); +     int i;
>> +
>> +     q->queues = NULL;
>> +
>> +     if (opt == NULL)
>> +             return -EINVAL;
>> +
>> +     q->max_bands = qdisc_dev(sch)->num_tx_queues; +
>> +     q->queues = kcalloc(q->max_bands, sizeof(struct Qdisc *),
...
>> +
>> +     return multiq_tune(sch, opt);
>
> But multiq_tune() can EINVAL, so kfree is needed here.

Noted and corrected.

> Jarek P.
>
> PS: to save some "paper" a typo, I guess, from PATCH 3/3:
>
>> +specific host, for example 192.168.0.3, though a specific queue
>> +you could use
>
>  +specific host, for example 192.168.0.3, through a specific queue
> you could use

Typo noted and will be corrected shortly.

Thanks,

Alex
