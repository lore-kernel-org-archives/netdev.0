From: David Acker <dacker@roinet.com>
Subject: Re: [PATCH] fix e100 rx path on ARM (was [PATCH] e100 rx: or s and
 el bits)
Date: Thu, 24 May 2007 08:51:20 -0400
Message-ID: <46558A48.9060403@roinet.com>
References: <200705011124.l41BOEG4007662@sullivan.realtime.net> <46375664.8030701@roinet.com> <4638F2B2.2000103@roinet.com> <463BA906.30205@roinet.com> <85f07fc58d5ed2147d5214d0f0b4fe32@bga.com> <4648A9DF.6030001@roinet.com> <464D074F.20400@pobox.com> <464D21B6.2000208@intel.com> <464DB336.2030003@roinet.com> <464DB619.3070900@roinet.com> <464DC676.90504@intel.com> <464DCA97.3070405@roinet.com> <464DCD5E.50003@intel.com> <464DDE3E.9010400@roinet.com> <e3819b7a866b1117fd5a69e6a85e0784@bga.com> <4651DAC1.7050604@intel.com> <53c44b6f03973eb1b28f221859d3002c@bga.com> <465369AF.8080508@roinet.com> <f83441453b1233771c5bda869912aeca@bga.com> <4654B2E4.9010308@roinet.com> <039d8ee49a8dfcbff8695b19d0a1a5c4@bga.com> <a4fae96e1c8c7b594207bf77fcb6b38f@bga.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Scott Feldman <sfeldma@pobox.com>,
	John Ronciak <john.ronciak@intel.com>
To: Milton Miller <miltonm@bga.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-72-92-88-10.phlapa.fios.verizon.net ([72.92.88.10]:33118
	"EHLO smtp.roinet.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755904AbXEXMuN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 May 2007 08:50:13 -0400
In-Reply-To: <a4fae96e1c8c7b594207bf77fcb6b38f@bga.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Milton Miller wrote:
>> Ok here's my just-before-dinner brainstorming, as relayed after dinner:
>>
>> We add two flags to struct rx:  one says this packet is EL, and one says
>> it is or was size 0.   We create a function, find_mark_el(struct nic,
>> is_running) that is called after initial alloc and/or after refilling
>> skb list.   In find_mark_el, we start with rx_to_use (lets rename this
>> rx_to_fill), and go back two entries, call this rx_to_mark.   If
>> is_running and rx_to_mark->prev->el then just return, leave EL alone.
>> Otherwise, set EL and size to 0, set the two flags in the rx struct,
>> sync the RFD, then search for the current EL (we could save the pointer,
>> but its always the odl rx_to_use (fill) or its ->prev).  Clear RFD->EL,
>> sync,  clear rx->el.  Set size non-zero, sync,  Leave the was_0 flag set
>> if is_running (clear it only if we know reciever is stopped).
>>
>> At this point, if the receiver was stopped we can restart it,.  We
>> should do so in the caller.  (We always restart at rx_to_clean).
>> Restart should ack the RNR status before issuing the ru_start command to
>> avoid a spurious RNR interrupt.
>>
>> In the receive loop, if RFD->C is not set, rx->was_0 is set and el
>> is not set, then we need to check rx->next->RFD->C bit (after
>> pci_sync_for_cpu).   If the next packet C bit is set then we consider
>> this skb as used, and just complete it with no data to the stack.
>>
>> Because find_mark_el will only advance EL if the receiver was stopped
>> or we had more than 1 packet added, we can guarantee that if packet
>> N has was_0 set, then packet N+1 will not have it set, so we have
>> bounded lookahead.
>>
>> This adds two flags to struct rx, but that is allocated as a single
>> array and the array size is filled out as forward and back pointers.
>> Rx clean only has to look at was_0 on the last packet when it
>> decides C is not set, and only if both are set does it peek at the
>> next packet.  In other words, we shouldn't worry about the added
>> flags making it a non-power-of-2 size.
>>
>> By setting size != 0 after we have modified all other fields, the
>> device will only write to this packet if we are done writing.  If
>> we loose the race and only partially complete, it will just go on
>> to the next packet and we find it.  If we totally loose, then the
>> receiver will go RNR and we can reclaim all the buffer space we
>> have allocated.
>>
>> Comments?  Questions?
This sounds pretty reasonable.  I will take a stab at coding this up 
today; I always think better looking at code.


>> We need to enforce a minimum rx ring size (3? 4?).
The code currently limits ethtool -G ethX rx calls to 16.

>> We rely on other mechanisms to guarantee the RFD in this skb
>> will not cache line conflict with the data in antoher scb
>> (slab allocs of the skb should give us this).
Yep.


> Copying EL to a flag in rx is only to avoid additional
> reading of the rfd while it might be under dma.  We do
> need the was_0 flag.
> 
> Do we need to continue with the stop-before-last plan?  As
> long as we set size to 0 with EL, we shoud be able to change
> the link, sync, set size 0, sync, and then set size.
Perhaps not.  I can take a try at coding it without it.  It would 
certainly make the driver easier to follow.

> We still need the "advance at least 2 if not stopped" check when
> deciding to move the EL.  This would break if the hardware
> in the dma path can read the multiple cache lines of the
> RFD out of order, so it may not be safe (if some pci host
> decided to prefetch data, and got the second line ahead of
> the first and didn't discard prefetch until pci bus
> disconnect).  Actually, I am afraid I know hardware that
> might do that.
Hmm, me too.

> 
> [defer]
> Currently we handle failed allocs by doing a sw interrupt
> in the watchdog.  Since we fail ifup if we can't alloc
> rxs, we can always start the reciever, even if we didn't
> alloc a new packet -- it will just read the RFD and go RNR
> again.   We could make this sw interrupt conditional on
> rx_to_clean->el being set.   However, looking further, it
> appears this 2s watchdog induced watchdog also covers
> makeing sure that we reattempt netif_schedule_prep_rx when
> it fails in e100_intr.   Any change in this area should be
> in a seperate patch, and probably delayed at least one
> release.    I also note that netpoll_controller calls
> e100_intr, which will call into the netif_rx_schedule
> only when a device interrupt is active.
Agreed.

I will get back when I have done some experiments with these ideas. 
Thanks for the replies!
-Ack
