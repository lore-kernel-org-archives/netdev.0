From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: tx queue hashing hot-spots and poor performance (multiq,
 ixgbe)
Date: Fri, 1 May 2009 14:37:56 -0700 (Pacific Daylight Time)
Message-ID: <alpine.WNT.2.00.0905011122450.5352@jbrandeb-desk1.amr.corp.intel.com>
References: <96ff3930904300207l4ecfe90byd6cce3f56ce4e113@mail.gmail.com>  <20090430.022417.07019547.davem@davemloft.net>  <606676310904300704p5308e3b6le2c469d320cc669@mail.gmail.com>  <20090430.070811.260649067.davem@davemloft.net>
 <606676310904301653w28f3226fsc477dc92b6a7cdbc@mail.gmail.com>  <49FA932B.4030405@cosmosbay.com>  <606676310904302319u1eacc634qde4b1f70e9936779@mail.gmail.com>  <49FA9940.1010203@cosmosbay.com> <606676310905010023l7bd0f153m35e65fb92e5b8c1e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	David Miller <davem@davemloft.net>,
	"jelaas@gmail.com" <jelaas@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Andrew Dickinson <andrew@whydna.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:52982 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753533AbZEAViA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 May 2009 17:38:00 -0400
In-Reply-To: <606676310905010023l7bd0f153m35e65fb92e5b8c1e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm going to try to clarify just a few minor things in the hope of helping 
explain why things look the way they do from the ixgbe perspective.

On Fri, 1 May 2009, Andrew Dickinson wrote:
> >> That's exactly what I did!  It solved the problem of hot-spots on some
> >> interrupts.  However, I now have a new problem (which is documented in
> >> my previous posts).  The short of it is that I'm only seeing 4 (out of
> >> 8) ksoftirqd's busy under heavy load... the other 4 seem idle.  The
> >> busy 4 are always on one physical package (but not always the same
> >> package (it'll change on reboot or when I change some parameters via
> >> ethtool), but never both.  This, despite /proc/interrupts showing me
> >> that all 8 interrupts are being hit evenly.  There's more details in
> >> my last mail. ;-D
> >>
> >
> > Well, I was reacting to your 'voodo' comment about
> >
> > return (u16) (((u64) hash * dev->real_num_tx_queues) >> 32);
> >
> > Since this is not the problem. Problem is coming from jhash() which shuffles
> > the input, while in your case we want to select same output queue
> > because of cpu affinities. No shuffle required.
> 
> Agreed.  I don't want to jhash(), and I'm not.
> 
> > (assuming cpu0 is handling tx-queue-0 and rx-queue-0,
> >          cpu1 is handling tx-queue-1 and rx-queue-1, and so on...)
> 
> That's a correct assumption. :D
> 
> > Then /proc/interrupts show your rx interrupts are not evenly distributed.
> >
> > Or that ksoftirqd is triggered only on one physical cpu, while on other
> > cpu, softirqds are not run from ksoftirqd. Its only a matter of load.
> 
> Hrmm... more fuel for the fire...
> 
> The NIC seems to be doing a good job of hashing the incoming data and
> the kernel is now finding the right TX queue:
> -bash-3.2# ethtool -S eth2 | grep -vw 0 | grep packets
>      rx_packets: 1286009099
>      tx_packets: 1287853570
>      tx_queue_0_packets: 162469405
>      tx_queue_1_packets: 162452446
>      tx_queue_2_packets: 162481160
>      tx_queue_3_packets: 162441839
>      tx_queue_4_packets: 162484930
>      tx_queue_5_packets: 162478402
>      tx_queue_6_packets: 162492530
>      tx_queue_7_packets: 162477162
>      rx_queue_0_packets: 162469449
>      rx_queue_1_packets: 162452440
>      rx_queue_2_packets: 162481186
>      rx_queue_3_packets: 162441885
>      rx_queue_4_packets: 162484949
>      rx_queue_5_packets: 162478427
> 
> Here's where it gets juicy.  If I reduce the rate at which I'm pushing
> traffic to a 0-loss level (in this case about 2.2Mpps), then top looks
> as follow:
> Cpu0  :  0.0%us,  0.0%sy,  0.0%ni,100.0%id,  0.0%wa,  0.0%hi,  0.0%si,  0.0%st
> Cpu1  :  0.0%us,  0.0%sy,  0.0%ni,100.0%id,  0.0%wa,  0.0%hi,  0.0%si,  0.0%st
> Cpu2  :  0.0%us,  0.0%sy,  0.0%ni,100.0%id,  0.0%wa,  0.0%hi,  0.0%si,  0.0%st
> Cpu3  :  0.0%us,  0.0%sy,  0.0%ni,100.0%id,  0.0%wa,  0.0%hi,  0.0%si,  0.0%st
> Cpu4  :  0.0%us,  0.0%sy,  0.0%ni,100.0%id,  0.0%wa,  0.0%hi,  0.0%si,  0.0%st
> Cpu5  :  0.0%us,  0.0%sy,  0.0%ni,100.0%id,  0.0%wa,  0.0%hi,  0.0%si,  0.0%st
> Cpu6  :  0.0%us,  0.0%sy,  0.0%ni,100.0%id,  0.0%wa,  0.0%hi,  0.0%si,  0.0%st
> Cpu7  :  0.0%us,  0.3%sy,  0.0%ni, 99.3%id,  0.0%wa,  0.0%hi,  0.3%si,  0.0%st
> 
> And if I watch /proc/interrupts, I see that all of the tx and rx
> queues are handling a fairly similar number of interrupts (ballpark,
> 7-8k/sec on rx, 10k on tx).
> 
> OK... now let me double the packet rate (to about 4.4Mpps), top looks like this:
> 
> Cpu0  :  0.0%us,  0.0%sy,  0.0%ni,  1.9%id,  0.0%wa,  5.5%hi, 92.5%si,  0.0%st
> Cpu1  :  0.0%us,  0.0%sy,  0.0%ni, 98.7%id,  0.0%wa,  0.0%hi,  1.3%si,  0.0%st
> Cpu2  :  0.0%us,  0.0%sy,  0.0%ni,  2.3%id,  0.0%wa,  4.9%hi, 92.9%si,  0.0%st
> Cpu3  :  0.0%us,  0.3%sy,  0.0%ni, 97.7%id,  0.0%wa,  0.0%hi,  1.9%si,  0.0%st
> Cpu4  :  0.0%us,  0.0%sy,  0.0%ni,  5.2%id,  0.0%wa,  5.2%hi, 89.6%si,  0.0%st
> Cpu5  :  0.0%us,  0.0%sy,  0.0%ni, 97.7%id,  0.0%wa,  0.3%hi,  1.9%si,  0.0%st
> Cpu6  :  0.0%us,  0.0%sy,  0.0%ni,  0.3%id,  0.0%wa,  4.9%hi, 94.8%si,  0.0%st
> Cpu7  :  0.0%us,  0.0%sy,  0.0%ni, 99.7%id,  0.0%wa,  0.0%hi,  0.3%si,  0.0%st
> 
> And if I watch /proc/interrupts again, I see that the even-CPUs (i.e.
> 0,2,4, and 6) RX queues are receiving relatively few interrupts
> (5-ish/sec (not 5k... just 5)) and the odd-CPUS RX queues are
> receiving about 2-3k/sec.  What's extra strange is that the TX queues
> are still handling about 10k/sec each.

rx interrupts start polling (100% time)
tx queues keep doing 10K per second because tx queues don't run in NAPI 
mode for MSI-X vectors.  They do try to limit the amount of work done at 
once as to not hog a cpu.

> So, below some magic threshold (approx 2.3Mpps), the box is basically
> idle and happily routing all the packets (I can confirm that my
> network test device ixia is showing 0-loss).  Above the magic
> threshold, the box starts acting as described above and I'm unable to
> push it beyond that threshold.  While I understand that there are
> limits to how fast I can route packets (obviously), it seems very
> strange that I'm seeing this physical-CPU affinity on the ksoftirqd
> "processes".
> 
> Here's how fragile this "magic threshold" is...  2.292 Mpps, box looks
> idle, 0 loss.   2.300 Mpps, even-CPU ksoftirqd processes at 50%-ish.
> 2.307 Mpps, even-CPU ksoftirqd processes at 75%.  2.323 Mpps, even-CPU
> ksoftirqd proccesses at 100%.  Never during this did the odd-CPU
> ksoftirqd processes show any utilization at all.
> 
> These are 64-byte frames, so I shouldn't be hitting any bandwidth
> issues that I'm aware of, 1.3Gbps in, and 1.3Gbps out (same NIC, I'm
> just routing packets back out the one NIC).

do you have all six channels populated with memory?

you're probably just hitting the limits of the OS combined with the 
hardware.  You could try reducing your rx/tx queue count (have to change 
code, 'num_rx_queues =') - hope we get ethtool to do that someday.

and then assigning each rx queue to one core and a tx queue to another on 
a shared cache.

on a Nehalem the kernel in numa mode (is your BIOS in numa mode?) may not 
be balancing the memory utilization evenly between channels.  are you 
using slub or slqb?

changing netdev_alloc_skb to __alloc_skb(be sure to specify node=-1 and 
getting rid of the skb_reserve(NET_IP_ALIGN) and skb_reserve(16)
might help align rx packets for dma.

hope this helps,
  Jesse
