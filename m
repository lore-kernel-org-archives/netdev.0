From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: Re: No idea about shaping trough many pc
Date: Thu, 10 Jan 2008 10:38:54 -0500
Message-ID: <20080110153854.GA2311@csclub.uwaterloo.ca>
References: <4785E01B.3080900@bigtelecom.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Badalian Vyacheslav <slavon@bigtelecom.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caffeine.csclub.uwaterloo.ca ([129.97.134.17]:48890 "EHLO
	caffeine.csclub.uwaterloo.ca" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755627AbYAJPi4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2008 10:38:56 -0500
Content-Disposition: inline
In-Reply-To: <4785E01B.3080900@bigtelecom.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 10, 2008 at 12:06:35PM +0300, Badalian Vyacheslav wrote:
> Hello all.
> I try more then 2 month resolve problem witch my shaping.  Maybe you can 
> help for me?
> 
> Sheme:
>                                +-------------------+
>                     + ----- | Shaping PC 1 | ---------+
>                     /          +-------------------+              \
> +--------+   /           +--------------------+              \          
> + --------+
> | Cisco |  +-------- | Shaping PC N  | -----------+ -----| CISCO |
> +--------+   \           +--------------------+              /          
> +---------+
>                     \          +---------------------+           /
>                     + ----- | Shaping PC 20 | --------+
>                                +---------------------+
> 
> Network - Over 10k users. Common bandwidth to INTERNET more then 1 GBs
> All computers have BGP and turn on multipath.
> Cisco can't do load sharing by Packet (its can resolve all my problems 
> =((( ). Only by DST IP, SRC IP, or +Level4.
> Ok. User must have speed 1mbs.
> Lets look variants:
> 1. Create rules to user = (1mbs/N computers). If user use N connection 
> all great, but if it use 1 connection his speed = 1mbs/N - its not look 
> good. All be great if cisco can PER PACKET load sharing =(
> 2. Create rules to user = 1mbs. If user use 1 connection all great, but 
> if it use N connection his speed much more then needed limit =(
> 
> Why i use 20 PC? Becouse 1 pc normal forward 100-150mbs... when it have 
> 100% cpu usage on Sofware Interrupts...

I have managed forwarding of 600Mbps using about 15% CPU load on a
500MHz Geode LX, using 4 100Mbit pcnet32 interfaces and a small tweak to
how the NAPI is implemented on it.  Adding traffic shapping and such to
the processing would certainly increase the CPU load, but hopefully not
by much.  The reason I didn't get more than 600Mbps was that the PCI bus
is now full.

> Any idea how to resolve this problem?
> 
> In my dreams (feature request to netdev ;) ):
> Get PC - title: MASTER TC.  All 20 PC syncronize statistic with MASTER 
> and have common rules and statistic. Then i use variant 2 and will be 
> happy... but its not real? =(
> Maybe have other variants?

Well now sure about synchornizing and all that.  I still think if I can
manage 600Mbps forwarding rate using a slow poke Geode then a modern CPU
like a Q6600 with a number of PCIe gig ports should be able to do quite
a lot.

The tweak I did was to add a timer to the driver that I can activate
whenever I finish emptying the receive queue.  When the timer expires it
adds the port back to the NAPI queue, and when it is called again the
poll will either process whatever packets arrived during the delay, or
it will actually unmask the IRQ and go back to IRQ mode.  The delay I
use is 1 jiffy, and I run with 1000HZ and set the queues to 256 packets,
since 1ms at 100MBps can provide at most about 200 packets (64byte worst
case).  I simply check whenever I empty the queue how many packets I
just processed.  If greater than 0, I enable the timer to expire on the
next jiffy and leave the port masked after removing port from napi
polling, and if it was 0 then I must have been called again after the
timer expired and still had no packets to process in which case I unmask
the IRQ and don't enable the timer.  I had to change the HZ to 1000
since at 250 or 100 I wouldn't be able to handle the worst case number
of packets (the pcnet32 has a maximum of 512 packets in a queue).

With NAPI the normal behaviour is that whenever you empty the receive
queue, you reenable IRQs, but it doesn't take that fast a CPU to
actually empty the queue all the time and then you end up with the
overhead for masking IRQs everytime you receive packets, process them,
and then the overhead of unmasking the IRQ just to within a fraction of
a milisecond getting an IRQ for the next packet.  With the delay until
the next jiffy for unmasking the IRQ you end up causing a potential lag
on processing packets of up to 1ms, although on average less than that,
but the IRQ load drops dramatically and the overhead of managing the IRQ
masking and the IRQ handler goes away.  In the case of this system the
CPU load dropped from 90% at 500Mbps to 15% at 600Mbps, and the
interrupt rate dropped from one IRQ every couple of packets, to one IRQ
at the start of each burst of packets.

I believe some GB ethernet ports and most 10Gig ports have the ability
to do delayed IRQ where they wait for a certain number of packets before
generating an IRQ, which is pretty much what I tried to emulate with my
tweak and it sure works amazingly well.

--
Len Sorensen
