From: Bill Fink <billfink@mindspring.com>
Subject: Re: [PATCH v2] net-tcp: TCP/IP stack bypass for loopback
 connections
Date: Tue, 14 Aug 2012 02:31:55 -0400
Message-ID: <20120814023155.ffe9c01d.billfink@mindspring.com>
References: <1344559958-29162-1-git-send-email-brutus@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org
To: "Bruce \"Brutus\" Curtis" <brutus@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-masked.atl.sa.earthlink.net ([209.86.89.68]:38987 "EHLO
	elasmtp-masked.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751734Ab2HNGpD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Aug 2012 02:45:03 -0400
In-Reply-To: <1344559958-29162-1-git-send-email-brutus@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  9 Aug 2012, Bruce "Brutus" Curtis wrote:

> From: "Bruce \"Brutus\" Curtis" <brutus@google.com>
> 
> TCP/IP loopback socket pair stack bypass, based on an idea by, and
> rough upstream patch from, David Miller <davem@davemloft.net> called
> "friends", the data structure modifcations and connection scheme are
> reused with extensive data-path changes.
> 
> A new sysctl, net.ipv4.tcp_friends, is added:
>   0: disable friends and use the stock data path.
>   1: enable friends and bypass the stack data path, the default.

The following is from a user perspective, since I am not
intimately familiar with the internals of the TCP stack.

I think tcp_friends is a poor name from a user POV.
Something like tcp_bypass would be much better.

I also believe it should be disabled by default, as that is
the current behavior, and those who would gain an advantage
from using it can easily enable it.

Changing the behavior would violate the principle of least
surprise.  Loopback TCP testing of an application or system
is often a useful first step in evaluating its behavior and
performance.  If the TCP stack is bypassed, it will give a
very false impression when such tests are performed.

Does it preserve all TCP semantics for applications, including
things like urgent data, ancillary data, and TCP socket options
and ioctls.  If it doesn't, it shouldn't be the default, and it
should be documented what features do and don't work when
tcp_bypass is enabled.  If all TCP semantics are unchanged,
that would also be good to know and document.

And there's the already mentioned issue of breaking tcpdump
and related tools.

While this could be a very useful feature in some environments,
it seems to me it would be safest to have it disabled by default.

					-Bill



> Note, when friends is enabled any loopback interpose, e.g. tcpdump,
> will only see the TCP/IP packets during connection establishment and
> finish, all data bypasses the stack and instead is delivered to the
> destination socket directly.
> 
> Testing done on a 4 socket 2.2GHz "Quad-Core AMD Opteron(tm) Processor
> 8354 CPU" based system, netperf results for a single connection show
> increased TCP_STREAM throughput, increased TCP_RR and TCP_CRR transaction
> rate for most message sizes vs baseline and comparable to AF_UNIX.
> 
> Significant increase (up to 4.88x) in aggregate throughput for multiple
> netperf runs (STREAM 32KB I/O x N) is seen.
