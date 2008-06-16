From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: packetloss, on e1000e worse than r8169?
Date: Mon, 16 Jun 2008 16:24:22 -0700
Message-ID: <36D9DB17C6DE9E40B059440DB8D95F52056AC4C2@orsmsx418.amr.corp.intel.com>
References: <20080616193501.M64730@visp.net.lb> <4856C3A7.9070703@cosmosbay.com> <20080616202210.M84100@visp.net.lb> <4856CEDC.6010706@intel.com> <20080616204411.M52834@visp.net.lb> <4856D1D6.7040207@intel.com> <20080616211213.M76390@visp.net.lb> <4856DB1D.80503@cosmosbay.com> <20080616213419.M212@visp.net.lb> <4856DE1F.4090001@cosmosbay.com> <4856DEA7.9060506@cosmosbay.com> <20080616220841.M50112@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "Denys Fedoryshchenko" <denys@visp.net.lb>,
	"Eric Dumazet" <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:36426 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757131AbYFPXYb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2008 19:24:31 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20080616220841.M50112@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denys Fedoryshchenko wrote:
> On Mon, 16 Jun 2008 23:44:07 +0200, Eric Dumazet wrote
>> 
>> ALso please try to lower the copybreak value of e1000e driver
>> (module parameter copybreak=20 for example) Already tried, but over
>> sysfs 
> 
> MegaRouter-KARAM ~ # echo 20 > /sys/module/e1000e/parameters/copybreak
> 
> Doesn't change anything. I am preparing profiling now.
> 
> I dont think it is CPU load issue. I have motherboard DP35DP working
> on similar workload(less routes, but conntrack + ifb + htb without
> hysteresis) perfectly, but it doesn't have Intel AMT, maybe that's
> the key. 
> 
> Why CPU load not the issue? I don't think mpstat is lying. 98-99% CPU
> is idle. But i will try oprofile, maybe it can help and will show
> something. 
> I will try also PREEMPT kernel now, maybe it is some locking issue,
> and preemption can help with that. Because "bursty" and clearly
> periodic character of errors means or counters updated each 1-2
> seconds or it is something happening each 1-2 seconds. I am not sure
> oprofile can catch that. 

error stats update only every two seconds from e1000e watchdog timer.

Please try using ethtool -C ethX rx-usecs 10 (100,000 interrupts per
second possible)

The realtek may not have the same kind of interrupt moderation as the
e1000e part.  Also, you mentioned elsewhere in this thread that PCIe
should have plenty of bandwith but the reality is that x1 PCIe has a lot
of latency so as you try to push a lot of small packets they may not be
processed fast enough.

Try turning off Flow Control using ethtool -A ethX rx off tx off autoneg
off

rx_missed_errors is because you're running out of RX FIFO in the
adapter, and we can try to change some code to increase the RX fifo to a
larger value, if you're using default 1500 MTU, you only need 4K TX
fifo, so can have a little more RX fifo than what you have by default
(it's the PBA register we need to change the lower 16 bits to 0x1c)

Jesse
