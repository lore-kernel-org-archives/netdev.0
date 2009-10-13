From: Oren Laadan <orenl@librato.com>
Subject: Re: [PATCH 2/2] [RFC] Add c/r support for connected INET sockets
Date: Tue, 13 Oct 2009 15:35:07 -0400
Message-ID: <4AD4D66B.6090903@librato.com>
References: <1254932945-12578-1-git-send-email-danms@us.ibm.com>	<1254932945-12578-3-git-send-email-danms@us.ibm.com>	<4AD3A52B.6050101@librato.com> <87ws2zcjhe.fsf@caffeine.danplanet.com>	<4AD4CE61.30503@librato.com> <87pr8rcdl0.fsf@caffeine.danplanet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: containers@lists.osdl.org, netdev@vger.kernel.org,
	John Dykstra <jdykstra72@gmail.com>
To: Dan Smith <danms@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp111.iad.emailsrvr.com ([207.97.245.111]:41448 "EHLO
	smtp111.iad.emailsrvr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753318AbZJMThy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2009 15:37:54 -0400
In-Reply-To: <87pr8rcdl0.fsf@caffeine.danplanet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Dan Smith wrote:
> OL> IIRC, the TCP stack takes the timestamp for each packet directly
> OL> from jiffies. So you need to teach TCP to add a per-container (or
> OL> you can make it per-socket) delta to that timestamp.
> 
> After wondering what the heck you were talking about, I realized I
> assumed you were talking about TCP timeouts and not timestamps :)
> 
> I assume you mean the following:
> 
>   1. Put a absolute time stamp in the checkpoint stream
>   2. Calculate the delta between that and the current time on the
>      restoring host
>   3. Use that value to offset timestamps from that point on.
> 
> Correct?

Sort of. Right now we already record the absolute time-of-checkpoint:
ctx->ktime_begin.  The restart-blocks are saved relative to it. I'd
suggest the same for all time related data from the network - save it
in the checkpoint image as delta's compared to checkpoint time.

At restart, the restart-blocks are restored relative to restart-time,
using the saved delta. That would work for the TCP timestamps too.

> 
> Since I brought it up, do you agree that the retransmit timers should
> be canonicalized to time-after checkpoint values?  It occurs to me
> that right now I restore a jiffies value on the receiving host which
> is guaranteed to be incorrect :)

As for TCP timeouts - I don't think they matter that much in the case
of live migration, whether the timeout after restart happens in the
saved delta relative to original checkpoint-time, or new restart-time.
The difference is likely to be subsecond to a few seconds at most,
not important for most use-cases, I'd think.

(If we are concerned about a TCP hickup due to a migration, there are
tricks to work around it that; timeouts and retransmits are not the
best way to go, because once you get there you already slowed down
TCP significantly).

Here, too, once we have time virtualization this can be revisited, to
allow the user to choose a policy how to use the deltas.

> 
> OL> So I'm thinking, for both, do (1) put a big fat comment in the
> OL> code saying that sanity-tests are needed, and what for, and (2)
> OL> send a separate mail to the networking people with these two
> OL> scenarios and request comments ?
> 
> Yeah, although I would hope that they're seeing this conversation and
> would chime in (hence the cc:netdev).  Hopefully I don't have to
> disguise a separate email as non-C/R related to get past their
> filters! :)
> 
> OL> For example, now, if a user wants to send a TCP packet with
> OL> arbitrary protocol parameters, he needs to use raw IP sockets,
> OL> which require privilege. Would restarting a connection with the
> OL> desired parameters become a way to bypass that restriction ?
> OL> (e.g. assume the user restarts while using the host's network
> OL> namespace).
> 
> Um, yeah?  I don't see much way around that if we're going to trust
> any of what is in the checkpoint stream.  Perhaps we say CAP_NET_ADMIN
> is required to restart a live TCP connection?
> 

I don't see much way around that either. My point is to bring the issue
to everyone's attention, and see what others say about it.

CAP_NET_ADMIN is one option. CAP_NET_RAW is another option ?

Oren.

