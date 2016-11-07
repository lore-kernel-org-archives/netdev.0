From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH net-next] sock: do not set sk_err in sock_dequeue_err_skb
Date: Sun, 6 Nov 2016 21:18:22 -0800
Message-ID: <CALCETrWLg+FKPD6DWBD8GGRA1RUVv6AHcH2kyi2tvyZ9kXhrcA@mail.gmail.com>
References: <1478211867-24569-1-git-send-email-soheil.kdev@gmail.com>
 <a3f7ea70-658e-9836-1a09-d1b9586582eb@stressinduktion.org> <CAF=yD-Ln_h5LHA=bfKYP7UPvANLXVBP4w6a5FE90AfByEyKNUw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Neal Cardwell <ncardwell@google.com>,
        Willem de Bruijn <willemb@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Network Development <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        Soheil Hassas Yeganeh <soheil.kdev@gmail.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f175.google.com ([209.85.217.175]:36632 "EHLO
        mail-ua0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750717AbcKGFT3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2016 00:19:29 -0500
Received: by mail-ua0-f175.google.com with SMTP id b35so110959990uaa.3
        for <netdev@vger.kernel.org>; Sun, 06 Nov 2016 21:18:43 -0800 (PST)
In-Reply-To: <CAF=yD-Ln_h5LHA=bfKYP7UPvANLXVBP4w6a5FE90AfByEyKNUw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Nov 4, 2016 1:26 PM, "Willem de Bruijn"
<willemdebruijn.kernel@gmail.com> wrote:
>
> On Thu, Nov 3, 2016 at 7:10 PM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
> > [also cc'ed Andy, albeit this doesn't seem to solve his initial problem,
> > right? <http://www.spinics.net/lists/netdev/msg331753.html>]
>
> Indeed, this does not help disambiguate the source of an error
> returned by a socketcall. It only reduces how often sk_err is leaked
> into the socket call datapath. Local errors and timestamps never set
> sk_err in the first place, so there can be no expectation that they
> set it on dequeue.
>
> I suspect that that line in sock_dequeue_err_skb originates from icmp
> errors, as those do set sk_err whenever queueing an error. So
> reenabling it when there are multiple errors on the queue makes sense,
> if all queued errors would be icmp errors. But they are not. And that
> path is racy, so there is no guarantee, either way. Processes that
> rely on syscall blocking to read the errqueue still block for icmp
> errors after this patch, due to the initial sk_err assignment on
> enqueue.
>
> Note that the comment in the patch that only TCP socket calls are
> blocked is probably incorrect. TCP has its own check in tcp_sendmsg
> and returns EPIPE when an sk_err is set, without clearing it. But
> other send, recv, connect, .. implementations include a path to
> sock_error that aborts the call (e.g., in __skb_try_recv_datagram),
> returns the value of sk_err, and clears it. This is an inconsistency
> between the protocols.
>
> Andy's original problem mentions recvmsg. We could probably make that
> unambiguous by returning a cmsg with the value of sk_err if RECVERR is
> set and sk_err is the source of the error. But this still does not
> solve the general issue, as other socketcalls, like send and connect,
> can also return sk_err. We can modify the number of places that check
> for it and currently abort system calls. Mainly sock_error(). One
> option is to add a socket option (SOL_SOCKET, as sk_err is not limited
> to when INET_RECVERR is set) to make that a noop. If the caller sets
> this option it instead has to wait with poll to receive POLLERR and
> call getsockopt SO_ERROR and recv MSG_ERRQUEUE to get the asynchronous
> error.

That would work for me, I think.  If this socket option were set, I
would hope that SO_ERROR wouldn't report anything if the only error
were a queued message on the error queue.
