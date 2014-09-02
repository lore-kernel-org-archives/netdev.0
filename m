From: Hannes Frederic Sowa <hannes@redhat.com>
Subject: Re: [PATCH net-next] sock: consistent errqueue errors and signals
Date: Tue, 02 Sep 2014 23:18:11 +0200
Message-ID: <1409692691.15984.16.camel@localhost>
References: <1409534896-372-1-git-send-email-willemb@google.com>
	 <1409606744.21965.37.camel@localhost>
	 <CA+FuTScAYY1ZhQPwY=pqW9hXf3UYB70Dxq5+aPH4D4pB7QRPbg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Network Development <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:14321 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754183AbaIBVSR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Sep 2014 17:18:17 -0400
In-Reply-To: <CA+FuTScAYY1ZhQPwY=pqW9hXf3UYB70Dxq5+aPH4D4pB7QRPbg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Di, 2014-09-02 at 11:20 -0400, Willem de Bruijn wrote:
> > From my experience in IPv6 code, we only do sk->sk_err updates directly
> > in protocol error handling code. In case of UDP IPv6 errors for example
> > we now notify sk_error_report two times with this patch (before the
> > patch we did sk_data_ready (this is what you changed) and
> > sk_error_report).
> 
> If the event is that an error is ready, is this not correct? The
> wake up key should be POLLERR in both cases. In implementation
> of sock_def_error_report and sock_def_readable, the difference
> otherwise seems slim. I haven't checked all sk_data_ready and
> sk_error_report implementations, though, so may have missed
> differences for specific protocols. If this is not as obviously a strict
> improvement as I thought, I'll just drop it.

I am not sure if waking up the socket two times has unforeseen
consequences, we do so e.g. in __udp6_lib_err if recverr is set.

> > I really wonder if setting sk->sk_err in this function is the right
> > thing to do.
> 
> I agree, in that it is hard to verify that this does not overwrite
> an existing error. This patch only makes the behavior
> consistent between enqueue and dequeue, but perhaps a
> better way to achieve that is to change the dequeue side:
> remove the assignment to sk->sk_err there. If so, then all
> locations that currently check the state of sk->sk_err should
> be changed to also check the qlen of the error queue and
> if non-zero return the embedded error of the first skb. I'll
> take a look whether that is feasible without adding locks
> or atomics in the common path.

That would be great.

> 
> > It also depends on socket state bits (e.g. np->recverr) if
> > the update happens. So we still cannot get rid of the protocol dependent
> > sk->sk_err updates.
> >
> > It looks like we have to check all error handling functions in the
> > protocols. Maybe timestamp code needs to adapt?
> 
> Does the above sound okay, or did you mean something else?

Best thing would be to not keep the error status two times per socket.
Maybe it would make sense to always synchronize on the error queue and
don't check for sk->sk_err at all? It seems to get very hairy without
taking any locks though.

I even don't know what the semantics for sk_err should be. Should we
leave the oldest error in place until it got fetched? Then we could use
cmpxchg in slow path with 0 as the old value. They could easily become
unsynchronized if the user switches off recverr setsockopt. But I don't
think we need to handle that.

I think best effort should would be ok, too. Not having locked
instructions in fast path is much more important.

Thanks,
Hannes
