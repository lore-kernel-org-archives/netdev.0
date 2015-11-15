From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] tcp: ensure proper barriers in lockless contexts
Date: Sat, 14 Nov 2015 19:21:41 -0800
Message-ID: <1447557701.22599.57.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20151115012032.GA21282@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:34210 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752061AbbKODVn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Nov 2015 22:21:43 -0500
Received: by padhx2 with SMTP id hx2so138856087pad.1
        for <netdev@vger.kernel.org>; Sat, 14 Nov 2015 19:21:43 -0800 (PST)
In-Reply-To: <20151115012032.GA21282@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2015-11-15 at 09:20 +0800, Herbert Xu wrote:
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > Some functions access TCP sockets without holding a lock and
> > might output non consistent data, depending on compiler and or
> > architecture.
> > 
> > tcp_diag_get_info(), tcp_get_info(), tcp_poll(), get_tcp4_sock() ...
> 
> For the information gathering ones such as tcp_diag_get_info I'm
> wondering whether we really need these memory barriers.  After all,
> if it's truly lockless then surely the TCP socket state can change
> again after you load the state the first time, in which case the
> barrier becomes completely meaningless.

Not a big deal, no crash or kernel instability, just making the
information a bit more consistent.

They are not truly needed, but the patch avoids some discrepancies when
an observer gets the data, for a minimum cost ( compiler barrier() in
most cases)

Like : 

       state = sk_state_load(sp);
       if (state == TCP_LISTEN)
               rx_queue = sp->sk_ack_backlog;
       else
               /* Because we don't lock the socket,
                * we might find a transient negative value.
                */
               rx_queue = max_t(int, tp->rcv_nxt - tp->copied_seq, 0);

or :

       if (sk_state_load(sk) == TCP_LISTEN) {
                r->idiag_rqueue = sk->sk_ack_backlog;
                r->idiag_wqueue = sk->sk_max_ack_backlog;


This patch makes sure sk_ack_backlog is written before sk_state is set
to TCP_LISTEN, otherwise one could see a '0' listener backlog.

We had a spurious kernel log for a similar issue that was solved in
commit f985c65c908f6b26c30019a83dc5ea295f5fcf62
("tcp: avoid spurious SYN flood detection at listen() time")

Sure, we can live with a spurious log, but experience showed that taking
care of this early could avoid lot of hassle, say in 12 months when
people start using linux-4.4 

Thanks.
