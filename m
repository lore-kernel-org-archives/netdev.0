From: jamal <hadi@cyberus.ca>
Subject: RE: [PATCH 2/3][NET_BATCH] net core use batching
Date: Mon, 08 Oct 2007 19:40:45 -0400
Message-ID: <1191886845.4373.138.camel@localhost>
References: <1191868010.4335.33.camel@localhost>
	 <D5C1322C3E673F459512FB59E0DDC32903BC1234@orsmsx414.amr.corp.intel.com>
	 <1191876530.4373.58.camel@localhost>
	 <D5C1322C3E673F459512FB59E0DDC32903BC14AC@orsmsx414.amr.corp.intel.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, krkumar2@in.ibm.com,
	johnpol@2ka.mipt.ru, herbert@gondor.apana.org.au, kaber@trash.net,
	shemminger@linux-foundation.org, jagana@us.ibm.com,
	Robert.Olsson@data.slu.se, rick.jones2@hp.com, xma@us.ibm.com,
	gaagaan@gmail.com, netdev@vger.kernel.org, rdreier@cisco.com,
	mcarlson@broadcom.com, jeff@garzik.org, mchan@broadcom.com,
	general@lists.openfabrics.org, tgraf@suug.ch,
	randy.dunlap@oracle.com, sri@us.ibm.com
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.235]:37109 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751808AbXJHXku (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 19:40:50 -0400
Received: by wx-out-0506.google.com with SMTP id h31so1470913wxd
        for <netdev@vger.kernel.org>; Mon, 08 Oct 2007 16:40:49 -0700 (PDT)
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC32903BC14AC@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-08-10 at 15:33 -0700, Waskiewicz Jr, Peter P wrote:


> Addressing your note/issue with different rings being services
> concurrently: I'd like to remove the QDISC_RUNNING bit from the global

The challenge to deal with is that netdevices, filters, the queues and
scheduler are closely inter-twined. So it is not just the scheduling
region and QDISC_RUNNING. For example, lets pick just the filters
because they are simple to see: You need to attach them to something -
whatever that is, you then need to synchronize against config and
multiple cpus trying to use them. You could: 
a) replicate them across cpus and only lock on config, but you are
wasting RAM then
b) attach them to rings instead of netdevices - but that makes me wonder
if those subqueues are now going to become netdevices. This also means
you change all user space interfaces to know about subqueues. If you
recall this was a major contention in our earlier discussion.

> device; with Tx multiqueue, this bit should be set on each queue (if at
> all), allowing multiple Tx rings to be loaded simultaneously. 

This is the issue i raised - refer to Dave's wording of it. If you run
access to the rings simultenously you may not be able to guarantee any
ordering or proper qos in contention for wire-resources (think strict
prio in hardware) - as long as you have the qdisc area.  You may
actually get away with it with something like DRR.
You could totaly bypass the qdisc region and go to the driver directly
and let it worry about the scheduling but youd have to make the qdisc
area a "passthrough" while providing the illusion to user space that all
is as before.

>  The
> biggest issue today with the multiqueue implementation is the global
> queue_lock.  I see it being a hot source of contention in my testing; my
> setup is a 8-core machine (dual quad-core procs) with a 10GbE NIC, using
> 8 Tx and 8 Rx queues.  On transmit, when loading all 8 queues, the
> enqueue/dequeue are hitting that lock quite a bit for the whole device.

Yes, the queuelock is expensive; in your case if all 8 hardware threads
are contending for that one device, you will suffer. The txlock on the
other hand is not that expensive since the contention is for a max of 2
cpus (tx and rx softirq). 
I tried to use that fact in the batching to move things that i processed
under queue lock into the area for txlock. I'd be very interested in
some results on such a piece of hardware with the 10G nic to see if
these theories make any sense.

> I really think that the queue_lock should join the queue_state, so the
> device no longer manages the top-level state (since we're operating
> per-queue instead of per-device).

Refer to above.


> 
> The multiqueue implementation today enforces the number of qdisc bands
> (RR or PRIO) to be equal to the number of Tx rings your hardware/driver
> is supporting.  Therefore, the queue_lock and queue_state in the kernel
> directly relate to the qdisc band management.  If the queue stops from
> the driver, then the qdisc won't try to dequeue from the band. 

Good start.

>  What I'm
> working on is to move the lock there too, so I can lock the queue when I
> enqueue (protect the band from multiple sources modifying the skb
> chain), and lock it when I dequeue.  This is purely for concurrency of
> adding/popping skb's from the qdisc queues.  

Ok, so the "concurency" aspect is what worries me. What i am saying is
that sooner or later you have to serialize (which is anti-concurency)
For example, consider CPU0 running a high prio queue and CPU1 running
the low prio queue of the same netdevice.
Assume CPU0 is getting a lot of interupts or other work while CPU1
doesnt (so as to create a condition that CPU1 is slower). Then as long
as there packets and there is space on the drivers rings, CPU1 will send
more packets per unit time than CPU0.
This contradicts the strict prio scheduler which says higher priority
packets ALWAYS go out first regardless of the presence of low prio
packets.  I am not sure i made sense.

cheers,
jamal

