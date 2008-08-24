From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 3/3] pkt_sched: restore multiqueue prio scheduler
Date: Sun, 24 Aug 2008 09:53:31 +0200
Message-ID: <20080824075331.GA2721@ami.dom.local>
References: <1219415417.4672.79.camel@localhost> <20080822221913.GA2981@ami.dom.local> <20080822.173348.232018958.davem@davemloft.net> <20080823084715.GA2515@ami.dom.local> <5f2db9d90808230931n453a3b75q84153dd8c18bcfc2@mail.gmail.com> <1219510193.4732.26.camel@localhost> <5f2db9d90808231209i134a7afbu233269c8ea592422@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, David Miller <davem@davemloft.net>,
	jeffrey.t.kirsher@intel.com, jeff@garzik.org,
	netdev@vger.kernel.org, alexander.h.duyck@intel.com
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:32878 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752298AbYHXHw6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Aug 2008 03:52:58 -0400
Received: by nf-out-0910.google.com with SMTP id d3so526594nfc.21
        for <netdev@vger.kernel.org>; Sun, 24 Aug 2008 00:52:55 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <5f2db9d90808231209i134a7afbu233269c8ea592422@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 23, 2008 at 12:09:42PM -0700, Alexander Duyck wrote:
> On Sat, Aug 23, 2008 at 9:49 AM, jamal <hadi@cyberus.ca> wrote:
> > On Sat, 2008-23-08 at 09:31 -0700, Alexander Duyck wrote:
> >
> >> Actually in this new multiple tx queue kernel this qdisc could serve a
> >> very specific but needed purpose which just became apparent to me.
> >> This qdisc resolves one very specific issue, head-of-line blocking if
> >> one of the hardware queues is full.  What if I reversed things a bit
> >> in prio_classify so that skb->queue_mapping determined the band
> >> instead of the other way around in the case of the multiqueue option
> >> being enabled?  I would think that in this configuration the qdisc
> >> would prove to be pretty useful for purposes other than QOS since it
> >> would allow a classful qdisc per transmit queue instead of per device.

I'm not sure if I don't miss your point, but if you decided you can do
this with a new action there is probably no reason to change or revert
anything in prio_classify - you pass the band/class number as a result.

...
> >> I could then create a select_queue for the device that returns 0 when
> >> in DCB/EEDC mode for our drivers, implement the tc action to set the
> >> queue mapping, and have essentially the same result as I had before.
> >>
> > put overflow queues in your driver. With the new multiq approach the
> > controls are per-queue not per driver.
> >
> 
> I think you missed the email from Dave earlier, either that or I am
> not understanding something and if I am feel free to explain.  My
> understanding is that when we assign a new qdisc via tc the
> qdisc/transmit queues end up with a configuration kind of like what
> Dave has on slide 7 at
> (http://vger.kernel.org/~davem/davem_seattle08.pdf).  Adding more
> queues doesn't resolve anything since I am still going through the
> same qdisc regardless of how many queues I have.  The changes to the
> dequeue portion of this qdisc are the most important part for this
> change since I need them to keep the qdisc from jamming up in a
> dequeue/requeue loop if the packet at the head of the qdisc needs to
> go to a stopped hardware transmit queue.

I guess, Jamal meant additional, backup queues, and you're thinking
about remapping to the basic, working queues. There is a question
if it's not enough to check and do this during classification, then
changes to prio's ->dequeue() would be also unnecessary. On the other
hand, if you proved in some tests it's worth to do in dequeue, I think
David is a reasonable guy and should let for such improvements. BTW,
if this jamming with requeuing is really a problem, probably it should
be also considered in the generic code like simple_tx_hash() by using
some mask.

Thanks,
Jarek P.
