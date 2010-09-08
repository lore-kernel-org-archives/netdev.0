From: Avi Kivity <avi@redhat.com>
Subject: Re: [RFC PATCH 0/4] Implement multiqueue virtio-net
Date: Wed, 08 Sep 2010 12:28:21 +0300
Message-ID: <4C875735.9050808@redhat.com>
References: <20100908072859.23769.97363.sendpatchset@krkumar2.in.ibm.com> <4C873F96.5020203@redhat.com> <OF2EF80349.03D44EF4-ON65257798.002D0021-65257798.003352A5@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: anthony@codemonkey.ws, davem@davemloft.net, kvm@vger.kernel.org,
	mst@redhat.com, netdev@vger.kernel.org, rusty@rustcorp.com.au
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12856 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756714Ab0IHJ2d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Sep 2010 05:28:33 -0400
In-Reply-To: <OF2EF80349.03D44EF4-ON65257798.002D0021-65257798.003352A5@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  On 09/08/2010 12:22 PM, Krishna Kumar2 wrote:
> Avi Kivity<avi@redhat.com>  wrote on 09/08/2010 01:17:34 PM:
>
>>    On 09/08/2010 10:28 AM, Krishna Kumar wrote:
>>> Following patches implement Transmit mq in virtio-net.  Also
>>> included is the user qemu changes.
>>>
>>> 1. This feature was first implemented with a single vhost.
>>>      Testing showed 3-8% performance gain for upto 8 netperf
>>>      sessions (and sometimes 16), but BW dropped with more
>>>      sessions.  However, implementing per-txq vhost improved
>>>      BW significantly all the way to 128 sessions.
>> Why were vhost kernel changes required?  Can't you just instantiate more
>> vhost queues?
> I did try using a single thread processing packets from multiple
> vq's on host, but the BW dropped beyond a certain number of
> sessions.

Oh - so the interface has not changed (which can be seen from the 
patch).  That was my concern, I remembered that we planned for vhost-net 
to be multiqueue-ready.

The new guest and qemu code work with old vhost-net, just with reduced 
performance, yes?

> I don't have the code and performance numbers for that
> right now since it is a bit ancient, I can try to resuscitate
> that if you want.

No need.

>>> Guest interrupts for a 4 TXQ device after a 5 min test:
>>> # egrep "virtio0|CPU" /proc/interrupts
>>>         CPU0     CPU1     CPU2    CPU3
>>> 40:   0        0        0       0        PCI-MSI-edge  virtio0-config
>>> 41:   126955   126912   126505  126940   PCI-MSI-edge  virtio0-input
>>> 42:   108583   107787   107853  107716   PCI-MSI-edge  virtio0-output.0
>>> 43:   300278   297653   299378  300554   PCI-MSI-edge  virtio0-output.1
>>> 44:   372607   374884   371092  372011   PCI-MSI-edge  virtio0-output.2
>>> 45:   162042   162261   163623  162923   PCI-MSI-edge  virtio0-output.3
>> How are vhost threads and host interrupts distributed?  We need to move
>> vhost queue threads to be colocated with the related vcpu threads (if no
>> extra cores are available) or on the same socket (if extra cores are
>> available).  Similarly, move device interrupts to the same core as the
>> vhost thread.
> All my testing was without any tuning, including binding netperf&
> netserver (irqbalance is also off). I assume (maybe wrongly) that
> the above might give better results?

I hope so!

> Are you suggesting this
> combination:
> 	IRQ on guest:
> 		40: CPU0
> 		41: CPU1
> 		42: CPU2
> 		43: CPU3 (all CPUs are on socket #0)
> 	vhost:
> 		thread #0:  CPU0
> 		thread #1:  CPU1
> 		thread #2:  CPU2
> 		thread #3:  CPU3
> 	qemu:
> 		thread #0:  CPU4
> 		thread #1:  CPU5
> 		thread #2:  CPU6
> 		thread #3:  CPU7 (all CPUs are on socket#1)

May be better to put vcpu threads and vhost threads on the same socket.

Also need to affine host interrupts.

> 	netperf/netserver:
> 		Run on CPUs 0-4 on both sides
>
> The reason I did not optimize anything from user space is because
> I felt showing the default works reasonably well is important.

Definitely.  Heavy tuning is not a useful path for general end users.  
We need to make sure the the scheduler is able to arrive at the optimal 
layout without pinning (but perhaps with hints).

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

