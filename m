From: Chris Snook <csnook@redhat.com>
Subject: Re: Bonding gigabit and fast?
Date: Tue, 16 Dec 2008 15:37:47 -0500
Message-ID: <4948119B.5050000@redhat.com>
References: <200812161939.30033.tvrtko@ursulin.net> <49480775.4060408@redhat.com> <200812162012.29811.tvrtko@ursulin.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Tvrtko A. Ursulin" <tvrtko@ursulin.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:57691 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752113AbYLPUht (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Dec 2008 15:37:49 -0500
In-Reply-To: <200812162012.29811.tvrtko@ursulin.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tvrtko A. Ursulin wrote:
> On Tuesday 16 December 2008 19:54:29 Chris Snook wrote:
>>> When serving data from the machine I get 13.7 MB/s aggregated while with
>>> a single slave (so bond still active) I get 5.6 MB/s for gigabit and 9.1
>>> MB/s for fast. Yes, that's not a typo - fast ethernet is faster than
>>> gigabit.
>> That would qualify as something very wrong with your gigabit card.  What do
>> you get when bonding is completely disabled?
> 
> With same testing methology (ie. serving from Samba to CIFS) it averages to 
> around 10 Mb/s, so somewhat faster than when bonded but still terribly 
> unstable. Problem is I think it was much better under older kernels. I wrote 
> about it before:
> 
> http://lkml.org/lkml/2008/11/20/418
> http://bugzilla.kernel.org/show_bug.cgi?id=6796
> 
> Stephen thinks it may be limited PCI bandwith, but the fact that I get double 
> speed in the opposite direction and that slow direction was previously 
> roughly double of what it is now, makes me suspicious that there is a 
> regression here somewhere.
> 
>>> That is actually another problem I was trying to get to the bottom of for
>>> some time. Gigabit adapter is skge in a PCI slot and outgoing bandwith
>>> oscillates a lot during transfer, much more than on 8139too which is both
>>> stable and faster.
>> The gigabit card might be sharing a PCI bus with your disk controller, so
>> swapping which slots the cards are in might make gigabit work faster, but
>> it sounds more like the driver is doing something stupid with interrupt
>> servicing.
> 
> Dang you are right, they really do share the same interrupt. And I have 
> nowhere else to move that card since it is a single PCI slot. Interestingly, 
> fast ethernet (eth0) generates double number of interrupts than gigabit 
> (eth1) and SATA combined.
> 
> From powertop:
> 
> Top causes for wakeups:
>   65.5% (11091.1)       <interrupt> : eth0
>   32.9% (5570.5)       <interrupt> : sata_sil, eth1
> 
> Tvrtko

Sharing an interrupt shouldn't be a problem, unless the other driver is doing 
bad things.  Sharing the bus limits PCI bandwidth though, and that can hurt.

The fact that you're getting more interrupts on the card moving more packets 
isn't surprising.

It occurred to me that the alb algorithm is not designed for asymmetric bonds, 
so part of the problem is likely the distribution of traffic.  You always end up 
with somewhat unbalanced distribution, and it happens to be favoring the slower 
card.

The real problem is that you get such lousy performance in unbonded gigabit 
mode.  Try oprofiling it to see where it's spending all that time.

-- Chris
