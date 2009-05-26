From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/1] NIU: fix spurious interrupts
Date: Mon, 25 May 2009 23:16:22 -0700 (PDT)
Message-ID: <20090525.231622.222754412.davem@davemloft.net>
References: <4A15F466.70708@windriver.com>
	<20090522.010849.89655675.davem@davemloft.net>
	<4A16D5F6.8040000@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, matheos.worku@sun.com
To: hong.pham@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60593
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753330AbZEZGQX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2009 02:16:23 -0400
In-Reply-To: <4A16D5F6.8040000@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Hong H. Pham" <hong.pham@windriver.com>
Date: Fri, 22 May 2009 12:42:30 -0400

> The tpc at the time of the spurious interrupt is niu_poll+0x99c.
> Looking this address up, it's at this line in niu_ldg_rearm():
> 
>   nw64(LDG_IMGMT(lp->ldg_num), val);
> 
> Since the timer is also reprogrammed when the LDG is rearmed,
> interrupts should not have been generated immediately after
> writing to LDG_IMGMT.
> 
> The tpc also showed interrupts happening in net_rx_action.  In
> this case the LDG has been rearmed, but the timer prevented
> interrupt delivery until after niu_poll is done.

The mystery is even deeper now!

First of all, we've been tricking ourselves.  OF COURSE we will see
the ARM bit cleared in these logs.  Any time the interrupt is sent,
the chip will clear the ARM bit.  So let's stop considering that as
unexpected :-)

If we are at the LDG rarm, we should have called napi_complete()
first.  Which happens in niu_poll().  napi_complete() therefore
always runs first, and therefore via this code path the LDG
rearm triggered interrupt should not see the NAPI scheduled.

There are only two other (both unlikely) paths that calls this,
niu_enable_interrupts() and the niu_interrupt() path that handles MIF,
RX error, and TX error interrupts.

I wonder if it's the niu_interrupt path, and all the v0 bits are
clear.  Yeah, I bet that's it.  We're taking some slowpath interrupt
for RX or TX counter overflows or errors, and then we try to rearm the
LDG even though we're already handling normal RX/TX via NAPI.

But that shouldn't happen, the thing that went into RX/TX NAPI work
should have turned those interrupt off.  We handle RX normal work and
error interrupts in the same LDG, and similar for TX, and thus using
the same interrupt.

Can you check to see who calls niu_ldg_rearm() when we see it trigger
the interrupt with NAPI already scheduled?  That will help narrow this
down even further.  Probably the best thing to do is to get a full
stack trace using show_stack() or dump_stack().

This is looking more and more like a driver bug at this point.
