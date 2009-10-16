From: Willy Tarreau <w@1wt.eu>
Subject: Re: TCP_DEFER_ACCEPT is missing counter update
Date: Fri, 16 Oct 2009 09:19:02 +0200
Message-ID: <20091016071902.GA11244@1wt.eu>
References: <20091015060834.GB29564@1wt.eu> <Pine.LNX.4.58.0910151120340.2879@u.domain.uli> <20091015124134.GB1073@1wt.eu> <Pine.LNX.4.58.0910152257410.3047@u.domain.uli> <4AD7EDB4.7060907@gmail.com> <4AD7FE01.1010805@gmail.com> <20091016052913.GB5574@1wt.eu> <4AD80D1F.3090601@gmail.com> <20091016061806.GD5574@1wt.eu> <4AD81C0B.90804@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Julian Anastasov <ja@ssi.bg>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:50280 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756034AbZJPHTs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Oct 2009 03:19:48 -0400
Content-Disposition: inline
In-Reply-To: <4AD81C0B.90804@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 16, 2009 at 09:08:59AM +0200, Eric Dumazet wrote:
(...)
> > Yes it could differ if a pure ACK is lost between the client and the server,
> > but in my opinion what is important is not to precisely account the number
> > of ACKs to ensure we wake up exactly after XXX ACKs received, but that in
> > most common situations we avoid to wake up too early.
> > 
> 
> We basically same thing, but you misundertood me. I was concerning about
> one lost (server -> client SYN-ACK), not a lost (client -> server ACK) which is fine
> (even without playing with TCP_DEFER_ACCEPT at all)
> 
> In this case, if we do the retrans test, we'll accept the first (client -> server ACK)
> and wakeup the application, while most probably we'll receive the client request
>  few milli second later.

OK I get your point. We can detect that though, as Julian explained it, with
the ->acked field. It indicates we got an ACK, which proves the SYN-ACK was
received. At first glance, I think that Julian's algorithm explained at the
end of his mail exactly covers all cases without using any additional field,
though this is not an issue anyway.

> > Also, keep in mind that the TCP_DEFER_ACCEPT parameter is passed in number
> > of seconds by the application, which are in turn converted to a number of
> > retransmits based on our own timer, which means that our SYN-ACK counter
> > is what most closely matches the application's expected delay, even if an
> > ACK from the client gets lost in between or if a client's stack retransmits
> > pure ACKs very fast for any implementation-specific reason.
> > 
> 
> Well, this is why converting application delay (sockopt() argument) in second units
> to a number of SYN-ACK counter is subobptimal and error prone.

I agree, but it allows the application to be unware of retransmit timers.

> This might be changed to be mapped to what documentation states : a number of seconds,
> or even better a number of milli seconds (new TCP_DEFER_ACCEPT_MS setsockopt cmd),
> because a high performance server wont play with > 1 sec values anyway.

It would be nice but it would require a new timer. Current implementation
does not need any and is efficient enough for most common cases. In fact it
would have been better to simply be able to specify that we want to skip one
empty ACK (or X empty ACKs). But let's make use of what we currently have,
with your (or Julian's) changes, it should cover almost all usages without
changing semantics for applications.

Regards,
Willy

