From: "Alexander Duyck" <alexander.duyck@gmail.com>
Subject: Re: [PATCH 3/3] pkt_sched: restore multiqueue prio scheduler
Date: Sat, 23 Aug 2008 12:09:42 -0700
Message-ID: <5f2db9d90808231209i134a7afbu233269c8ea592422@mail.gmail.com>
References: <1219415417.4672.79.camel@localhost>
	 <20080822221913.GA2981@ami.dom.local>
	 <20080822.173348.232018958.davem@davemloft.net>
	 <20080823084715.GA2515@ami.dom.local>
	 <5f2db9d90808230931n453a3b75q84153dd8c18bcfc2@mail.gmail.com>
	 <1219510193.4732.26.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Jarek Poplawski" <jarkao2@gmail.com>,
	"David Miller" <davem@davemloft.net>, jeffrey.t.kirsher@intel.com,
	jeff@garzik.org, netdev@vger.kernel.org,
	alexander.h.duyck@intel.com
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.28]:24619 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750828AbYHWTJn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Aug 2008 15:09:43 -0400
Received: by yx-out-2324.google.com with SMTP id 8so559508yxm.1
        for <netdev@vger.kernel.org>; Sat, 23 Aug 2008 12:09:42 -0700 (PDT)
In-Reply-To: <1219510193.4732.26.camel@localhost>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 23, 2008 at 9:49 AM, jamal <hadi@cyberus.ca> wrote:
> On Sat, 2008-23-08 at 09:31 -0700, Alexander Duyck wrote:
>
>> Actually in this new multiple tx queue kernel this qdisc could serve a
>> very specific but needed purpose which just became apparent to me.
>> This qdisc resolves one very specific issue, head-of-line blocking if
>> one of the hardware queues is full.  What if I reversed things a bit
>> in prio_classify so that skb->queue_mapping determined the band
>> instead of the other way around in the case of the multiqueue option
>> being enabled?  I would think that in this configuration the qdisc
>> would prove to be pretty useful for purposes other than QOS since it
>> would allow a classful qdisc per transmit queue instead of per device.
>>
>
> i think thats whats Dave is saying not in so many words.
>
> prio_classify calls classifiers.
> dont modify the qdisc; rather do a classification which when matched
> sets skb->queue_mapping to a value your policy likes it to be.
> you dont need a new classifier, u32 would do for example. or ematch if
> you want to do some funky things. you will need a new action which sets
> the skb->queue_mapping.

We have to modify the existing prio qdisc or create a new qdisc in
order to resolve the head-of-line blocking once any of the queues have
stopped.  The new one wouldn't make any changes to the priority of the
packet but instead would only switch it to a separate qdisc based on
the queue_mapping of the skb.

I get the fact that all we would need is a new action to handle the
queue mapping, but in order for that to be an acceptable solution I
still need the qdisc changes.

>> I could then create a select_queue for the device that returns 0 when
>> in DCB/EEDC mode for our drivers, implement the tc action to set the
>> queue mapping, and have essentially the same result as I had before.
>>
> put overflow queues in your driver. With the new multiq approach the
> controls are per-queue not per driver.
>

I think you missed the email from Dave earlier, either that or I am
not understanding something and if I am feel free to explain.  My
understanding is that when we assign a new qdisc via tc the
qdisc/transmit queues end up with a configuration kind of like what
Dave has on slide 7 at
(http://vger.kernel.org/~davem/davem_seattle08.pdf).  Adding more
queues doesn't resolve anything since I am still going through the
same qdisc regardless of how many queues I have.  The changes to the
dequeue portion of this qdisc are the most important part for this
change since I need them to keep the qdisc from jamming up in a
dequeue/requeue loop if the packet at the head of the qdisc needs to
go to a stopped hardware transmit queue.

> cheers,
> jamal
>

Thanks,

Alex
