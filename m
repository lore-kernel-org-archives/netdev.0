From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: packetloss, on e1000e worse than r8169?
Date: Wed, 18 Jun 2008 00:04:49 +0300
Message-ID: <200806180004.49272.denys@visp.net.lb>
References: <20080616193501.M64730@visp.net.lb> <20080616220841.M50112@visp.net.lb> <36D9DB17C6DE9E40B059440DB8D95F52056AC4C2@orsmsx418.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Eric Dumazet" <dada1@cosmosbay.com>, netdev@vger.kernel.org
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:40529 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755511AbYFQVEk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2008 17:04:40 -0400
In-Reply-To: <36D9DB17C6DE9E40B059440DB8D95F52056AC4C2@orsmsx418.amr.corp.intel.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After trying everything, it looks like that problem in PBS size, and as result PBA (rx fifo) size.

On ICH8 it is small, only 16K PBS (0x10), and RX/TX set each 8k, even i can set 0xd/0x3 it doesn't help (i didn't measure if it make less packetloss).
As i understand, i need to set only RX, TX calculated automatically.
Both motherboards i tried had ICH8.

All other servers which i mention, and which have enough big load have:
1)Sun - PBA 48K (82546EB)
2)DP35DP - PBA 16K (ICH9)

Also ICH8 missing some features, that ICH9 supports, such as FLAG_HAS_ERT, but it looks ERT useful only for Jumbo frames. 
And sure ICH8 doesn't support Jumbo frames, maybe because of limited PBS.

Is PBS size hardware limitation of ICH8?
Is it possible i am right in my conclusions?
Probably such details in network adapters will be useful for Vyatta guys, to choose proper network adapter for their systems :-)

On Tuesday 17 June 2008 02:24, Brandeburg, Jesse wrote:
> Denys Fedoryshchenko wrote:
> > On Mon, 16 Jun 2008 23:44:07 +0200, Eric Dumazet wrote
> >> 
> >> ALso please try to lower the copybreak value of e1000e driver
> >> (module parameter copybreak=20 for example) Already tried, but over
> >> sysfs 
> > 
> > MegaRouter-KARAM ~ # echo 20 > /sys/module/e1000e/parameters/copybreak
> > 
> > Doesn't change anything. I am preparing profiling now.
> > 
> > I dont think it is CPU load issue. I have motherboard DP35DP working
> > on similar workload(less routes, but conntrack + ifb + htb without
> > hysteresis) perfectly, but it doesn't have Intel AMT, maybe that's
> > the key. 
> > 
> > Why CPU load not the issue? I don't think mpstat is lying. 98-99% CPU
> > is idle. But i will try oprofile, maybe it can help and will show
> > something. 
> > I will try also PREEMPT kernel now, maybe it is some locking issue,
> > and preemption can help with that. Because "bursty" and clearly
> > periodic character of errors means or counters updated each 1-2
> > seconds or it is something happening each 1-2 seconds. I am not sure
> > oprofile can catch that. 
> 
> error stats update only every two seconds from e1000e watchdog timer.
> 
> Please try using ethtool -C ethX rx-usecs 10 (100,000 interrupts per
> second possible)
> 
> The realtek may not have the same kind of interrupt moderation as the
> e1000e part.  Also, you mentioned elsewhere in this thread that PCIe
> should have plenty of bandwith but the reality is that x1 PCIe has a lot
> of latency so as you try to push a lot of small packets they may not be
> processed fast enough.
> 
> Try turning off Flow Control using ethtool -A ethX rx off tx off autoneg
> off
> 
> rx_missed_errors is because you're running out of RX FIFO in the
> adapter, and we can try to change some code to increase the RX fifo to a
> larger value, if you're using default 1500 MTU, you only need 4K TX
> fifo, so can have a little more RX fifo than what you have by default
> (it's the PBA register we need to change the lower 16 bits to 0x1c)
> 
> Jesse
> 

-- 
------
Technical Manager
Virtual ISP S.A.L.
Lebanon
