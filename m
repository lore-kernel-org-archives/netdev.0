From: Milton Miller <miltonm@bga.com>
Subject: Re: [PATCH] fix e100 rx path on ARM (was [PATCH] e100 rx: or s and el bits)
Date: Wed, 30 May 2007 03:26:38 -0500
Message-ID: <94c8ff9069a77568513a9a1d1e60012d@bga.com>
References: <200705011124.l41BOEG4007662@sullivan.realtime.net> <46375664.8030701@roinet.com> <4638F2B2.2000103@roinet.com> <463BA906.30205@roinet.com> <85f07fc58d5ed2147d5214d0f0b4fe32@bga.com> <4648A9DF.6030001@roinet.com> <464D074F.20400@pobox.com> <464D21B6.2000208@intel.com> <464DB336.2030003@roinet.com> <464DB619.3070900@roinet.com> <464DC676.90504@intel.com> <464DCA97.3070405@roinet.com> <464DCD5E.50003@intel.com> <464DDE3E.9010400@roinet.com> <e3819b7a866b1117fd5a69e6a85e0784@bga.com> <4651DAC1.7050604@intel.com> <53c44b6f03973eb1b28f221859d3002c@bga.com> <465369AF.8080508@roinet.com> <f83441453b1233771c5bda869912aeca@bga.com> <4654B2E4.9010308@roinet.com> <039d8ee49a8dfcbff8695b19d0a1a5c4@bga.com> <a4fae96e1c8c7b594207bf77fcb6b38f@bga.com> <465C4DBE.6000205@roinet.com>
Mime-Version: 1.0 (Apple Message framework v624)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	e1000-devel@lists.sourceforge.net,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Scott Feldman <sfeldma@pobox.com>, netdev@vger.kernel.org
To: David Acker <dacker@roinet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mercury.realtime.net ([205.238.132.86]:45746 "EHLO
	ruth.realtime.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751399AbXE3I1r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2007 04:27:47 -0400
In-Reply-To: <465C4DBE.6000205@roinet.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On May 29, 2007, at 10:58 AM, David Acker wrote:

> Ok, I finally got some time to code this out and study it and Ihave 
> some
> questions.
>
> Milton Miller wrote:
>>> We add two flags to struct rx:  one says this packet is EL, and one 
>>> says
>>> it is or was size 0.   We create a function, find_mark_el(struct nic,
>>> is_running) that is called after initial alloc and/or after refilling
>>> skb list.   In find_mark_el, we start with rx_to_use (lets rename 
>>> this
>>> rx_to_fill), and go back two entries, call this rx_to_mark.   If
>>> is_running and rx_to_mark->prev->el then just return, leave EL alone.
> So if we start clean and then one packet completes, we can not clear 
> the
> old marked entry?  We must then add a per nic pointer to the current
> marked entry so that when the next packet completes, we can avoid
> scanning for it.  Why do we need to check this again?

I don't think we need a per-nic pointer, we just need to check if our
to_mark->prev has the "This is EL" flag set.  the to_mark is the
to_fill->prev->prev  (I think -- to_use in the code, which is the
next to be allocated, not last allocated?  I haven't studied that 
detail).

We need this to avoid our refill code running in lock step with the
hardware and exposing two packets in a row with a size that it reads
as 0.

This means we never need to scan ahead more than one packet.


>
>>> Otherwise, set EL and size to 0, set the two flags in the rx struct,
>>> sync the RFD, then search for the current EL (we could save the 
>>> pointer,
>>> but its always the odl rx_to_use (fill) or its ->prev).  Clear 
>>> RFD->EL,
>>> sync,  clear rx->el.  Set size non-zero, sync,  Leave the was_0 flag 
>>> set
>>> if is_running (clear it only if we know reciever is stopped).
>>>
>>> At this point, if the receiver was stopped we can restart it,.  We
>>> should do so in the caller.  (We always restart at rx_to_clean).
>>> Restart should ack the RNR status before issuing the ru_start 
>>> command to
>>> avoid a spurious RNR interrupt.
>>>
>>> In the receive loop, if RFD->C is not set, rx->was_0 is set and el
>>> is not set, then we need to check rx->next->RFD->C bit (after
>>> pci_sync_for_cpu).   If the next packet C bit is set then we consider
>>> this skb as used, and just complete it with no data to the stack.
> If the C-bit is not set, we can read the status to see if the RU is
> running (we cleared the EL bit before it read it but it has not found
> another packet yet) or not (it read the el-bit before we cleared it).
> This read lets us avoid going through an enable interrupts, wait for 
> the
> RNR interrupt cycle.

Yes agreed.  But I was pointing out if we never had set size to 0
on this packet (ie rx->was_0 is clear) we dont' even need to poll
the device (saves a slow mmio load) or check the next packet (saves
a pci_sync_for_cpu ie a cache line invalidate, and check for c bit).

>>> Because find_mark_el will only advance EL if the receiver was stopped
>>> or we had more than 1 packet added, we can guarantee that if packet
>>> N has was_0 set, then packet N+1 will not have it set, so we have
>>> bounded lookahead.
> Is this meant to be 1 packet added at any given call or 1 packet added
> since the last time we cleared?

This would be we allocated one packet since the last time we moved EL.

>>> This adds two flags to struct rx, but that is allocated as a single
>>> array and the array size is filled out as forward and back pointers.
>>> Rx clean only has to look at was_0 on the last packet when it
>>> decides C is not set, and only if both are set does it peek at the
>>> next packet.  In other words, we shouldn't worry about the added
>>> flags making it a non-power-of-2 size.
>>>
>>> By setting size != 0 after we have modified all other fields, the
>>> device will only write to this packet if we are done writing.  If
>>> we loose the race and only partially complete, it will just go on
>>> to the next packet and we find it.  If we totally loose, then the
>>> receiver will go RNR and we can reclaim all the buffer space we
>>> have allocated.
>>>
>>> Comments?  Questions?
>>>
>
>
> Say we have an 8 buffer receive pool (0-7) at start.  rx[6] is marked.
>
> hardware consumes rx[0]
> software sees one rx complete without an s-bit set.

wihtout el bit set?

software sees one packet complete, checks next and find was_el is not 
set so it assumes it is still pending and the device is running.


> software notes that rx[6] is marked
> software allocates new buffer for rx[0]
> software runs find_mark_el with rx_to_use == rx[1], rx_to_mark == 
> rx[7], is_running == true, marked_rx == rx[6]
> find_mark_el finds rx_to_mark->prev->el set and is_running true, and 
> returns.
>
> hardware consumes rx[1]
> software sees one rx complete without an s-bit set.

software sees one packet complete, checks next and find was_0 is not 
set so it assumes it is still pending and the device is running.

> software notes that rx[6] is still marked
> software allocates new buffer for rx[1]
> software runs find_mark_el with rx_to_use == rx[2], rx_to_mark == 
> rx[0], is_running == true, marked_rx == rx[6]
> find_mark_el does not find rx_to_mark->prev->el set so continues
> find_mark_el sets rx[0]->rfd->el rx[0]->rfd->size = 0, rx[0]->el, 
> rx[0]->size0;
> find_mark_el clears rx[6]->rfd->el, syncs, sets rx[6]->rfd->size, 
> syncs, clears rx[6]->rfd->el but leaves rx[6]->rfd->size0 set.
>
> Is this the correct flow?
>

Without thinking about the ordering of these updates, yes I think that 
is the right flow.

although the "rx[6] is still marked" is not really a step, but notices
that [0]->prev === [7]->el is not set.


actually, lets do second part again with what I was thinking:
>
> hardware consumes rx[1]
> software sees one rx complete without an s-bit set.

software notes that rx_to_use (fill) is rx[1]

> software allocates new buffer for rx[1], and moves rx_to_use to rx[2]

software runs with find_mark_el with rx_to_use = rx[2], rx_was_to_use = 
rx[1], is_running = true

find_mark_el walks backward and calculates rx_to_mark as rx[0].   it 
calculates rx_to_unmark as rx_was_to_use->prev == rx[7] initially, but 
since ->el is not set it backs up once more to rx[6].  It then compares 
rx_to_unmark is != rx_to_mark->prev and continues as above.   Note that 
if is_running == true we would also continue; this should be the second 
clause in the || obviously.

Your logic works, this adds some conditional branching but saves a 
pointer, not sure which is better.  Mine can be used for initializing 
without special casing since it will just calculate rx_to_unmark as 
rx[n-2] and rx_to_mark as rx[n-2] != rx[n-2]->prev; unmarking a never 
marked still works, where as for yours the "was marked" must be 
explicitly set to something (hmm, rxs = rx[0] might work for that 
initial value until we mark -2??)

again, the compare of rx->el instead of rx->rfd->el is to save cache 
traffic to the rfd under io.  The rx->was_0 is required, so the el flag 
is free.

milton

