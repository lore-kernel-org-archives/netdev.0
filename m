From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: Using ethernet device as efficient small packet generator
Date: Fri, 21 Jan 2011 14:09:17 -0800 (Pacific Standard Time)
Message-ID: <alpine.WNT.2.00.1101211400000.5816@JBRANDEB-DESK2.amr.corp.intel.com>
References: <D3F292ADF945FB49B35E96C94C2061B90ECC4FAC@nsmail.netscout.com> <13dbf221c875a931d408784495884998.squirrel@www.liukuma.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Loke, Chetan" <Chetan.Loke@netscout.com>,
	Jon Zhou <jon.zhou@jdsu.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: juice <juice@swagman.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:35937 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752946Ab1AUWJS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Jan 2011 17:09:18 -0500
In-Reply-To: <13dbf221c875a931d408784495884998.squirrel@www.liukuma.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Fri, 21 Jan 2011, juice wrote:
> I am using now a PCIe Intel e1000e card, that should be able to handle
> the needed traffic amount.
> 
> The statistics that I get are as follows:
> 
> kernel 2.6.32-27 (ubuntu 10.10 default)
>     pktgen:           750064pps 360Mb/sec (360030720bps)
>     AX4000 analyser:  Total bitrate:             383.879 MBits/s
>                       Bandwidth:                 38.39% GE
>                       Average packet intereval:  1.33 us
> 
> kernel 2.6.37 (latest stable from kernel.org)
>     pktgen:           786848pps 377Mb/sec (377687040bps)
>     AX4000 analyser:  Total bitrate:             402.904 MBits/s
>                       Bandwidth:                 40.29% GE
>                       Average packet intereval:  1.27 us
> 
> kernel 2.6.38-rc1 (latest from kernel.org)
>     pktgen:           795297pps 381Mb/sec (381742560bps)
>     AX4000 analyser:  Total bitrate:             407.117 MBits/s
>                       Bandwidth:                 40.72% GE
>                       Average packet intereval:  1.26 us
> 

your computation of Bandwidth (as Ben Greear said) is not accounting for 
the interframe gaps.  Maybe more useful is to note that wire speed 64 byte 
packets is 1.44 Million packets per second.

> In every case I have set the IRQ affinity of eth1 to CPU0 and started
> the test running in kpktgend_0.
> 
> The complete data of my measurements follows in the end of this post.
> 
> It looks like the small packet sending effiency of the ethernet driver
> is improving all the time, albeit quite slowly.
> 
> Now, I would be intrested in knowing whether it is indeed possible to
> increase the sending rate near full 1GE capacity with the current
> ethernet card I am using or do I have here a hardware limitation here?
> 
> I recall hearing that there are some enhanced versions of the e1000
> network card, such that have been geared towards higher performance
> at the expense of some functionality or general system effiency.
> Can anybody point me how to do that?

I think you need different hardware (again) as you have saddled yourself 
with a x1 PCIe connected adapter.  This adapter is not well suited to 
small packet traffic because the sheer amount of transactions is effected 
by the added latency due to the x1 connector (vs our dual port 1GbE 
adapters with a x4 connector)


> As I stated before, quoting myself:
> 
> > Which do you suppose is the reason for poor performance on my setup,
> > is it lack of multiqueue HW in the GE NIC's I am using or is it lack
> > of multiqueue support in the kernel (2.6.32) that I am using?
> >
> > Is multiqueue really necessary to achieve the full 1GE saturation, or
> > is it only needed on 10GE NIC's?

with Core i3/5/7 or newer cpus you should be able to saturate a 1Gb link 
with a single core/queue.  With Core2 era processors you may have some 
difficulty, with anything older than that you won't make it. :-)

> > As I understand multiqueue is useful only if there are lots of CPU cores
> > to run, each handling one queue.
> >
> > The application I am thinking of, preloading a packet sequence into
> > kernel from userland application and then starting to send from buffer
> > propably does not benefit so much from many cores, it would be enough
> > that one CPU would handle the sending and other core(s) would handle
> > other tasks.
> 
> Yours, Jussi Ohenoja
> 
> 
> *** Measurement details follows ***
> 
> 
> root@d8labralinux:/var/home/juice# lspci -vvv -s 04:00.0
> 04:00.0 Ethernet controller: Intel Corporation 82572EI Gigabit Ethernet
> Controller (Copper) (rev 06)

My suggestion is to get one of the igb based adapters, 82576, or 82580 
based that run the igb driver.

If you can't get a hold of those you should be able to easily get 1.1M pps 
from an 82571 adapter.

you may also want to try reducing the tx descriptor ring count to 128 
using ethtool, and change the ethtool -C rx-usecs 20 setting, try 
20,30,40,50,60

Jesse
