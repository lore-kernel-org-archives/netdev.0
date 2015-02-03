From: Willy Tarreau <w@1wt.eu>
Subject: Re: Per-connection tcp_retries2 and RFC 1122 compliance
Date: Wed, 4 Feb 2015 00:15:27 +0100
Message-ID: <20150203231527.GA30766@1wt.eu>
References: <87a90w10tq.fsf@redhat.com> <CADVnQymEvyJaM8ogia5kmARrrFF0dSk83iSUyPPTHOaCO+GrfQ@mail.gmail.com> <874mr227bx.fsf@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Eckersberg <jeckersb@redhat.com>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:21830 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755168AbbBCXPi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Feb 2015 18:15:38 -0500
Content-Disposition: inline
In-Reply-To: <874mr227bx.fsf@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

do you think we could have the fix below queued for -stable ? It
appears to fix some quite annoying issues that are not easy to
debug.

Thanks,
Willy

On Tue, Feb 03, 2015 at 01:11:46PM -0500, John Eckersberg wrote:
> Neal Cardwell <ncardwell@google.com> writes:
> > I believe the functionality you are looking  for is the
> > TCP_USER_TIMEOUT socket option:
> 
> I had tried that previously, and it did not help my case.  The reason
> why is that I was using a downstream kernel (Fedora 21, 3.17.8 in this
> case) and it was missing this commit that went into 3.18:
> 
> commit b248230c34970a6c1c17c591d63b464e8d2cfc33
> Author: Yuchung Cheng <ycheng@google.com>
> Date:   Mon Sep 29 13:20:38 2014 -0700
> 
>     tcp: abort orphan sockets stalling on zero window probes
>     
>     Currently we have two different policies for orphan sockets
>     that repeatedly stall on zero window ACKs. If a socket gets
>     a zero window ACK when it is transmitting data, the RTO is
>     used to probe the window. The socket is aborted after roughly
>     tcp_orphan_retries() retries (as in tcp_write_timeout()).
>     
>     But if the socket was idle when it received the zero window ACK,
>     and later wants to send more data, we use the probe timer to
>     probe the window. If the receiver always returns zero window ACKs,
>     icsk_probes keeps getting reset in tcp_ack() and the orphan socket
>     can stall forever until the system reaches the orphan limit (as
>     commented in tcp_probe_timer()). This opens up a simple attack
>     to create lots of hanging orphan sockets to burn the memory
>     and the CPU, as demonstrated in the recent netdev post "TCP
>     connection will hang in FIN_WAIT1 after closing if zero window is
>     advertised." http://www.spinics.net/lists/netdev/msg296539.html
>     
>     This patch follows the design in RTO-based probe: we abort an orphan
>     socket stalling on zero window when the probe timer reaches both
>     the maximum backoff and the maximum RTO. For example, an 100ms RTT
>     connection will timeout after roughly 153 seconds (0.3 + 0.6 +
>     .... + 76.8) if the receiver keeps the window shut. If the orphan
>     socket passes this check, but the system already has too many orphans
>     (as in tcp_out_of_resources()), we still abort it but we'll also
>     send an RST packet as the connection may still be active.
>     
>     In addition, we change TCP_USER_TIMEOUT to cover (life or dead)
>     sockets stalled on zero-window probes. This changes the semantics
>     of TCP_USER_TIMEOUT slightly because it previously only applies
>     when the socket has pending transmission.
> 
> The key part being that last paragraph about stalled zero-window
> probes.  Here's the specific use case where I'm hitting this:
> 
> (1) Establish a TCP connection bound to a given IP address
> (2) Remove IP address from host
> (3) Write to socket
> 
> This gets kicked back by the IP layer as non-routable, which triggers
> the same behavior as the zero-window probes.
> 
> The good news is, I confirmed this is working as expected when I tested
> on 3.19.0-rc7.
> 
> Thanks for the pointer, I'll go take my harassment to the relevant
> downstream folks.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
