From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] sctp: Clean up type-punning in sctp_cmd_t union
Date: Mon, 29 Oct 2012 14:59:32 -0400
Message-ID: <20121029185932.GC10177@hmsreliant.think-freely.org>
References: <20121026132422.GA25087@hmsreliant.think-freely.org>
 <508AE08B.8070303@gmail.com>
 <20121026203504.GD25087@hmsreliant.think-freely.org>
 <20121026.171019.702275326710216395.davem@davemloft.net>
 <AE90C24D6B3A694183C094C60CF0A2F6026B7076@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, vyasevich@gmail.com,
	netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:59789 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932405Ab2J2S7p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Oct 2012 14:59:45 -0400
Content-Disposition: inline
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7076@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 29, 2012 at 03:07:07PM -0000, David Laight wrote:
> > > On Fri, Oct 26, 2012 at 03:12:11PM -0400, Vlad Yasevich wrote:
> > >> Look at commit 19c7e9ee that introduced this.  I don't remember all
> > >> the details any more, but the problem only occurred on ia64
> > >> (probably due its speculative load handling).
> > >>
> > >> -vlad
> > >>
> > > Thanks Vlad, I'll have a look see.
> > 
> > Ok, so this IA64 issue is all about accesses to uninitialized memory.
> > 
> > I think Neil's change is thus the most desirable thing to do.  Simple
> > memset the object to zero.
> 
> I'd guess it an artifact of the C memory aliasing rules and unions.
> If you write to a location as a one type but read it as another type
> (and neither type is char) then the compiler is generally allowed to
> schedule the read before the write (and may even optimise the write away).
> This shouldn't happen if the fields are both members of the same union,
> but casting some other address to a 'union *' separately for the
> write and read isn't enough.
> 
I don't think thats whats going on at all.  The problem, as commit
19c7e9eef503dc1ae926f3d26c56f88bee568d7b describes it, is that ia64 was
speculatively loading a value from memory of type sctp_arg_t.  If the
initialization step set the value of one of the smaller members of the union
(say a short), then the load stage may still load a larger amount of data (given
that the union is larger than its smallest members).  That results in part of
the load being uninitalized, and ia64 declaring it Not A Thing, and consequently
trapping out.

The fix previously was to just initazlie the unsigned long member zero in that
union before setting the actuall type member that was requried so as to ensure
all the data was initalized.  That works well enough, but it presumes that
unsigned long is the largest member of the union, which is risky.  Its better to
memset the union to 0 for sizeof bytes to ensure future proofing.

I've sent an updated version of the patch to do the memset. Its marked as V3,
but I fat fingered the in-reply-to so it didn't show up in this thread.
Apologies.

> This probably means that this entire type-punning argument passing
> scheme is actually broken.
> 
No, It works, as long as you read the same member as you write, and initalize
the entire union, which is what this patch does.
Neil

> 	David
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
