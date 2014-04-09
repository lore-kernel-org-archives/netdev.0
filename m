From: Shawn Bohrer <shawn.bohrer@gmail.com>
Subject: Re: udp: Question about busy_poll change
Date: Wed, 9 Apr 2014 09:51:29 -0500
Message-ID: <20140409145129.GA4002@sbohrermbp13-local.rgmadvisors.com>
References: <53455581.7060209@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Shawn Bohrer <sbohrer@rgmadvisors.com>,
	Jonathan Cooper <jcooper@solarflare.com>,
	eric.dumazet@gmail.com
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f45.google.com ([209.85.219.45]:46112 "EHLO
	mail-oa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933057AbaDIOvk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Apr 2014 10:51:40 -0400
Received: by mail-oa0-f45.google.com with SMTP id eb12so2821008oac.4
        for <netdev@vger.kernel.org>; Wed, 09 Apr 2014 07:51:40 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <53455581.7060209@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 09, 2014 at 03:13:21PM +0100, Edward Cree wrote:
> Commit 005ec9743394010cd37d86c3fd2e81978231cdbf, "udp: Only allow busy
> read/poll on connected sockets",
> causes a performance regression (increased latency) on some
> micro-benchmarks which don't connect() their UDP socket, and might well
> have a similar effect on real applications that do the same thing.
> As far as I can tell, the change is only needed in the case where the
> UDP socket is bound to INADDR_ANY, _and_ traffic on the chosen UDP port
> is received through more than one NIC (or perhaps through a NIC with
> separate NAPI contexts per receive queue?)

Yep.  The separate NAPI contexts per receive queue part was one of the
main reasons, though I suppose the INADDR_ANY case is relevant as
well.

> In particular, busy polling makes sense for a client (which will only be
> receiving packets from one remote address even though the socket is
> unconnected), or for a socket which has been bound to an interface's
> address (at least in the case of sfc, where we have one NAPI context for
> all the receive queues on an interface).

I agree that it makes sense in this case but if you meet these
requirements then you can also connect your UDP socket.  The real
problem is that there is no way for the kernel to know that you will
only receive packets from a single remote address, so you have to
connect.

I believe the sfc case where you only have a single NAPI context is
also valid and it seems reasonable to me that if you can detect that
specific case that busy polling could be allowed.  I'm not sure how to
detect this.  I'm sure patches are welcome.

> So, what was the deeper rationale for this change?  Is there a
> correctness issue or does the old behaviour just affect performance
> through unnecessary busy_polling?  Or have I just misunderstood things
> completely?

If we are spinning on a NAPI context and a packet arrives in a
different rx queue then you'll get unpredictable latencies and
out of order packets.  For the people using this feature that is
probably not desirable.

--
Shawn
