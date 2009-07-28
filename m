From: Oren Laadan <orenl@librato.com>
Subject: Re: [PATCH 2/2] c/r: Add AF_INET support (v3)
Date: Tue, 28 Jul 2009 13:22:37 -0400
Message-ID: <4A6F33DD.7040804@librato.com>
References: <1246994776-1882-1-git-send-email-danms@us.ibm.com>	<1246994776-1882-3-git-send-email-danms@us.ibm.com> <1248468247.16746.12.camel@merlyn>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Dan Smith <danms@us.ibm.com>, containers@lists.osdl.org,
	netdev@vger.kernel.org, Alexey Dobriyan <adobriyan@gmail.com>
To: John Dykstra <john.dykstra1@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp151.iad.emailsrvr.com ([207.97.245.151]:33377 "EHLO
	smtp151.iad.emailsrvr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752019AbZG1RWj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2009 13:22:39 -0400
In-Reply-To: <1248468247.16746.12.camel@merlyn>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



John Dykstra wrote:
> On Tue, 2009-07-07 at 12:26 -0700, Dan Smith wrote:
>>  2. I don't do anything to redirect or freeze traffic flowing to or from the
>>     remote system (to prevent a RST from breaking things).  I expect that
>>     userspace will bring down a veth device or freeze traffic to the remote
>>     system to handle this case.
> 
> Theoretically, you can drop any packet that's in flight (ingress or
> egress), because IP doesn't guarantee delivery.  TCP is able to recover,
> and a UDP or raw-socket application should already be designed to.  Of
> course, retransmissions will have an impact on application performance
> in the migration case, so that's got to be considered in the tradeoff.
> Main goal should probably be avoiding anything that shoves either end
> into slow-start.

Sure. Still, the network needs to be blocked for the duration of the
migration to ensure that the socket at the origin does not ACK any
new data after the receive buffers have been saved.

> 
> Thinking out loud, have you considered draining TCP buffers rather than
> including them in the checkpoint?  You'd stop ingress traffic, and let
> the app run until it had read everything in the socket buffer.  On the
> egress side, you'd cork the app by telling it that buffers were full,
> and then wait until the data already at the socket layer had been
> transmitted.  Both are somewhat unbounded re time, and probably not
> worth it, but maybe there's some variant of this idea that has value.
> TCP transmit buffers on 10GE links can be pretty big...

Hmmm... buffers can be big, but I would expect that in most case the
memory footprint of the application will be bigger (unless all it
does is some very simple receive-filter-send of data).

Oren.

> 
> BTW, if you see RSTs, that probably means you've created a protocol
> violation due to a buggy restore.  Just blocking or dropping packets
> shouldn't result in an RST unless it's very long.
> 
>   --  John
> 
> _______________________________________________
> Containers mailing list
> Containers@lists.linux-foundation.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
