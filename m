From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: PROBLEM: Linux kernel 2.6.31 IPv4 TCP fails to open huge amount of outgoing connections (unable to bind ... )
Date: Wed, 21 Apr 2010 04:30:22 +0400
Message-ID: <20100421003022.GA3107@ioremap.net>
References: <g2z46c8cb3e1004201517i5641a75cze2ec5bd33e81fb0f@mail.gmail.com> <4BCE33B9.8050101@candelatech.com> <u2t46c8cb3e1004201620tf9fce087ibae421759f9e1e84@mail.gmail.com> <4BCE392F.60104@candelatech.com> <y2p46c8cb3e1004201635s8f84672dq90d3115dca04a1ed@mail.gmail.com> <4BCE3D8D.3030500@candelatech.com> <1271808314.7895.614.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Greear <greearb@candelatech.com>,
	David Miller <davem@davemloft.net>,
	Gaspar Chilingarov <gasparch@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from corega.com.ru ([195.178.208.66]:37926 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753231Ab0DUAa1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Apr 2010 20:30:27 -0400
Content-Disposition: inline
In-Reply-To: <1271808314.7895.614.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 21, 2010 at 02:05:14AM +0200, Eric Dumazet (eric.dumazet@gmail.com) wrote:
> I believe the bsockets 'optimization' is a bug, we should remove it.
> 
> This is a stable candidate (2.6.30+)
> 
> [PATCH net-next-2.6] tcp: remove bsockets count
> 
> Counting number of bound sockets to avoid a loop is buggy, since we cant
> know how many IP addresses are in use. When threshold is reached, we try
> 5 random slots and can fail while there are plenty available ports.

To return back to exponential bind() times you need to revert the whole
original patch including magic 5 number, not only bsockets.

But actual problem is not in this digit, but in a deeper logic.
Previously we scanned the whole table, now we have 5 attempts to
find out at least one bucket (without conflict) we will insert
new socket into. Apparently for large number of addresses it is possible
that all 5 times we will randomly select those buckets which conflicts.
As dumb solution we can increase 'attempt' number to infinite one, or
fallback to whole-table-search after several random attempts, which is a
bit more clever I think.

-- 
	Evgeniy Polyakov
