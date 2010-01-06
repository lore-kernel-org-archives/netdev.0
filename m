From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: BSD 4.2 style TCP keepalives
Date: Tue, 5 Jan 2010 21:07:56 -0500
Message-ID: <20100106020756.GA4378@localhost.localdomain>
References: <20100105.163911.10233438.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, ilpo.jarvinen@helsinki.fi
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:54421 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755386Ab0AFCIA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2010 21:08:00 -0500
Content-Disposition: inline
In-Reply-To: <20100105.163911.10233438.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 05, 2010 at 04:39:11PM -0800, David Miller wrote:
> 
> To make a long story short, there are still some Windows 2000
> machines out there emitting BSD 4.2 style keepalives (one garbage
> byte instead of an empty out-of-window probe frame).
> 
> We don't ACK these because of how tcp_sequence() sees ->end_seq
> as being equal to ->rcv_wup
> 
> But we can't change tcp_sequence() to reject these frames, because if
> we do then we end up mishandling connection attempts (SYN, SYN+ACK)
> and retransmits of such.
> 
> Neil has shown me a patch that does a by-hand special case of this
> one-garbage-byte keepalive inside of tcp_rcv_established().
> 
> Anyone have suggestions for an alternative and perhaps cleaner
> implementation of a fix?
> 
Dave, If that patch fixes the problem (waiting on test results now, but I figure
it will), what if we add a parameter to tcp_sequence (and
tcp_validate_incomming), that represents an offset to trim from end_seq (so that
we can effectively ignore the garbage byte)?  Its not much cleaner, but it
consolidates the code a bit, and is probably a bit quicker.  Then we can just
pass a 0 value to tcp_validate_incomming from tcp_rcv_state_process and 1 in
tcp_rcv_established (or a boolean variable if we want to implement a sysctl to
tune weather or not we want to ack these old frames, if such a knob is
relevant).

I'll happily implement this if theres consensus on it

Thoughts?

Thanks!
Neil
