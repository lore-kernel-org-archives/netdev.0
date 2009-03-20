From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: performance issue of netdev_budget and dev_weight with ixgbe
Date: Fri, 20 Mar 2009 10:27:17 -0700 (Pacific Daylight Time)
Message-ID: <alpine.WNT.2.00.0903200835490.7220@jbrandeb-desk1.amr.corp.intel.com>
References: <a06240409c5d5e74a49d0@[129.98.90.227]> <F169D4F5E1F1974DBFAFABF47F60C10A1E6EABF2@orsmsx507.amr.corp.intel.com> <49C35859.7050803@baidu.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	jesse.brandeburg@intel.com
To: Terry <hanfang@baidu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:25012 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754903AbZCTR1V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Mar 2009 13:27:21 -0400
In-Reply-To: <49C35859.7050803@baidu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 20 Mar 2009, Terry wrote:
> I was doing some tuning work for ip-forwarding with oplin cards .
> i found that when i set netdev_budget to 64(default is 300),just the 

netdev_budget controls how many times poll can be called for multiple 
devices on a single cpu.

> same as  dev_weight in ixgbe, i got the highest forwarding rate.
> not only in forwarding scenario, but also the  "receive and send back" 
> scenario.

you're changing the scheduling (scheduler interaction) behavior by 
decreasing netdev_budget.  You're also affecting the fairness between two 
interfaces that might be running NAPI on the same CPU.

> If I change  netdev_budget or weight in driver to any other value, the 
> performace get worse.
> how did the ixgbe driver folks pick  the  value of 64 and how does it 
> affect the perf?

64 is pretty much the global default for all drivers, not just ixgbe, we 
didn't "pick" it at all.  at 10 Gb Ethernet speeds, we get a LOT of 
packets.  When you play with budget you're decreasing the amount of cache 
coherency you get by handing lots of packets at once.

I think if you look at the time_squeeze counter in /proc/net/softnet_stat 
you'll see that when routing we often take more than a jiffie, which means 
that next time through the poll loop our budget is smaller.  You might 
want to add code to check what the minimum value that the budget passed to 
ixgbe is.  If it gets too small all your cpu time is spent thrashing 
between scheduling NAPI and never getting much work done.

The per-packet cost for routing is so high when merging all the transmit 
work into the netif_receive_skb code, that I bet 64 packets often exceeds 
a jiffie.

This is probably an area that the kernel stack could improve by batching 
packets on receive (possibly similar to what yanmin zhang has been posting 
recently) especially when routing.
