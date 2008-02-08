From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] Add IPv6 support to TCP SYN cookies
Date: Fri, 8 Feb 2008 13:07:46 +0100
Message-ID: <20080208120746.GE4745@one.firstfloor.org>
References: <47a79d64.16538c0a.5b6a.ffffb0fe@mx.google.com> <20080205155558.GA23145@one.firstfloor.org> <c9e534200802051029u5d08cf6dm54866f769e362262@mail.gmail.com> <20080205192559.GA10573@kallisti.us> <20080205201106.GB26150@one.firstfloor.org> <20080205212335.GA11287@kallisti.us> <20080206085357.GA1402@one.firstfloor.org> <20080207194446.GA25463@kallisti.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>,
	Glenn Griffin <ggriffin.kernel@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Ross Vandegrift <ross@kallisti.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:49557 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754259AbYBHLcj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2008 06:32:39 -0500
Content-Disposition: inline
In-Reply-To: <20080207194446.GA25463@kallisti.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 07, 2008 at 02:44:46PM -0500, Ross Vandegrift wrote:
> On Wed, Feb 06, 2008 at 09:53:57AM +0100, Andi Kleen wrote:
> > That would be useful yes -- for different bandwidths.
> 
> My initial test is end-to-end 1000Mbps, but I've got a few different
> packet rates.
> 
> > If the young/old heuristics do not work well enough anymore most
> > likely we should try readding RED to the syn queue again. That used
> > to be pretty effective in the early days. I don't quite remember why
> > Linux didn't end up using it in fact.
> 
> I'm running juno-z with 2, 4, & 8 threads of syn flood to port 80.
> wireshark measures 2 threads at 350pps, 4 threads at 750pps, and 8

What's the total bandwidth of the attack?

> threads at 1200pps.  Under no SYN flood, the server handles 750 HTTP
> requests per second, measured via httping in flood mode.

Thanks for the tests. Could you please do an additional experiment? 
Use sch_em or similar to add a jittering longer latency in the connection
(as would be realistic in a real distributed DOS). Does it make a
difference? 

> With a default tcp_max_syn_backlog of 1024, I can trivially prevent
> any inbound client connections with 2 threads of syn flood.
> Enabling tcp_syncookies brings the connection handling back up to 725
> fetches per second.

Yes the defaults are probably too low. That's something that should
be fixed.

> 
> At these levels the CPU impact of tcp_syncookies is nothing.  I can't

CPU impact of syncookies was never a concern. The problems are rather
missing flow control and disabling of valuable TCP features.

> BUG: soft lockup detected on CPU#1!
>  [<c044d1ec>] softlockup_tick+0x96/0xa4
>  [<c042ddb0>] update_process_times+0x39/0x5c
>  [<c04196f7>] smp_apic_timer_interrupt+0x5b/0x6c
>  [<c04059bf>] apic_timer_interrupt+0x1f/0x24
>  [<c045007b>] taskstats_exit_send+0x152/0x371
>  [<c05c007b>] netlink_kernel_create+0x5/0x11c
>  [<c05a7415>] reqsk_queue_alloc+0x32/0x81
>  [<c05a5aca>] lock_sock+0x8e/0x96

I think the softirqs are starving user context through the socket
lock.  Probably should be fixed too. Something like softirq should
detect when there is a user and it is looping too long and should
give up the lock for some time.


-Andi
