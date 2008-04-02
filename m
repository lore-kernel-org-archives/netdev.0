From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: GFP_ATOMIC page allocation failures.
Date: Wed, 02 Apr 2008 11:37:57 -0700
Message-ID: <47F3D285.7030404@intel.com>
References: <20080401235609.GA6947@codemonkey.org.uk>	<200804021228.16875.nickpiggin@yahoo.com.au>	<20080402013551.GA8361@codemonkey.org.uk>	<47F32789.2070703@redhat.com>	<20080402005646.f8df1c1b.akpm@linux-foundation.org>	<47F3C0A8.9090300@garzik.org> <20080402103355.77ef22ff.akpm@linux-foundation.org> <47F3CE10.1060903@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Chris Snook <csnook@redhat.com>,
	Dave Jones <davej@codemonkey.org.uk>,
	Nick Piggin <nickpiggin@yahoo.com.au>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Linus Torvalds <torvalds@linux-foundation.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:10712 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754463AbYDBSu6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Apr 2008 14:50:58 -0400
In-Reply-To: <47F3CE10.1060903@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Garzik wrote:
> Andrew Morton wrote:
>> After you've read Nick's comments (which I pray you have not), and after
>> you've convinced us and yourself of their wrongness, you might like to
>> consider adding a __GFP_NOWARN to netdev_alloc_skb().
> 
> Already done so.   Adding __GFP_NOWARN to netdev_alloc_skb() is wrong
> for several reasons.
> 
> It doesn't change the underlying conditions.
> It doesn't fix the desire to stamp other drivers in this manner.
> 
> And most importantly, it is not even correct:  the handling of the
> allocation failure remains delegated to the netdev_alloc_skb() users,
> which may or may not be properly handling allocation failures.
> 
> Put simply, you don't know if the caller is stupid or smart.  And there
> are a _lot_ of callers, do you really want to flag all of them?
> 
> Many modern net drivers are smart, and quite gracefully handle
> allocation failure without skipping a beat.
> 
> But some are really dumb, and leave big holes in their DMA rings when
> allocations fail.
> 
> The warnings are valid _sometimes_, but not for others.  So adding
> __GFP_NOWARN to netdev_alloc_skb() unconditionally makes no sense,
> except as an admission that the "spew when there is memory pressure"
> idea was silly.
> 
> 
> 
> Turning to Nick's comment,
> 
>> It's still actually nice to know how often it is happening even for
>> these known good sites because too much can indicate a problem and
>> that you could actually bring performance up by tuning some things.
> 
> then create a counter or acculuation buffer somewhere.
> 
> We don't need spew every time there is memory pressure of this magnitude.
> 
> IMO there are much better ways than printk(), to inform tasks, and
> humans, of allocation failures.


FYI e1000 and family already count various levels of alloc failures resulting from
this:

  alloc_rx_buff_failed - page alloc failure (might be harmless)
  rx_no_buffer_count - no buffer available for HW to use (harmless, hw will retry)
  rx_missed_errors - hw dropped a packet because of above failures

still I personally think the page alloc warnings are a good thing and we've had
several issues resolve quickly because of them.

shutting them up completely moves the focus to our driver which ends up being a
victim of suspicion, and we have to circle around hard to convince the user otherwise.

Auke
