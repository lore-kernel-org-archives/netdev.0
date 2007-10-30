From: Matt Mackall <mpm@selenic.com>
Subject: Re: [patch] net: avoid race between netpoll and network fast path
Date: Tue, 30 Oct 2007 00:08:39 -0500
Message-ID: <20071030050838.GH19691@waste.org>
References: <47158540.7000709@oracle.com> <20071016.210613.71104656.davem@davemloft.net> <4715A1B6.5020300@oracle.com> <20071029.212611.152845077.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tina.yang@oracle.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from waste.org ([66.93.16.53]:53602 "EHLO waste.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752379AbXJ3FJD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Oct 2007 01:09:03 -0400
Content-Disposition: inline
In-Reply-To: <20071029.212611.152845077.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 29, 2007 at 09:26:11PM -0700, David Miller wrote:
> From: Tina Yang <tina.yang@oracle.com>
> Date: Tue, 16 Oct 2007 22:46:30 -0700
> 
> > 	The precise race is
> > 	1) net_rx_action get the dev from poll_list
> > 	2) at the same time, netpoll poll_napi() get a hold of the poll lock
> > 	   and calls ->poll(), remove dev from the poll list
> > 	3) after it finishes, net_rx_action get the poll lock, and calls
> > 	   ->poll() the second time, and panic when trying to remove (again)
> > 	   the dev from the poll list.
> 
> This is trivial to fix.
> 
> I'll check the following into 2.6.14 and backport it to
> the -stable trees.
> 
> [NET]: Fix race between poll_napi() and net_rx_action()
> 
> netpoll_poll_lock() synchronizes the ->poll() invocation
> code paths, but once we have the lock we have to make
> sure that NAPI_STATE_SCHED is still set.  Otherwise we
> get:
> 
> 	cpu 0			cpu 1
> 
> 	net_rx_action()		poll_napi()
> 	netpoll_poll_lock()	... spin on ->poll_lock
> 	->poll()
> 	  netif_rx_complete
> 	netpoll_poll_unlock()	acquire ->poll_lock()
> 				->poll()
> 				 netif_rx_complete()
> 				 CRASH
> 
> Based upon a bug report from Tina Yang.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>

Thanks, Dave.

-- 
Mathematics is the supreme nostalgia of our time.
