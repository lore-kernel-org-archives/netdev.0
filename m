From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] tcp: correct memory barrier usage in
 tcp_check_space()
Date: Sat, 04 Feb 2017 07:19:37 -0800
Message-ID: <1486221577.21871.126.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170204095954.GA5916@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jason Baron <jbaron@akamai.com>, davem@davemloft.net,
        netdev@vger.kernel.org, oleg@redhat.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:36159 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750876AbdBDPUd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2017 10:20:33 -0500
Received: by mail-it0-f65.google.com with SMTP id f200so4226497itf.3
        for <netdev@vger.kernel.org>; Sat, 04 Feb 2017 07:19:40 -0800 (PST)
In-Reply-To: <20170204095954.GA5916@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2017-02-04 at 17:59 +0800, Herbert Xu wrote:
> Jason Baron <jbaron@akamai.com> wrote:
> > From: Jason Baron <jbaron@akamai.com>
> > 
> > sock_reset_flag() maps to __clear_bit() not the atomic version clear_bit().
> > Thus, we need smp_mb(), smp_mb__after_atomic() is not sufficient.
> > 
> > Fixes: 3c7151275c0c ("tcp: add memory barriers to write space paths")
> > Cc: Eric Dumazet <eric.dumazet@gmail.com>
> > Cc: Oleg Nesterov <oleg@redhat.com>
> > Signed-off-by: Jason Baron <jbaron@akamai.com>
> 
> This patch makes no sense.
> 
> > diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> > index bfa165cc455a..1e22ae4a5b38 100644
> > --- a/net/ipv4/tcp_input.c
> > +++ b/net/ipv4/tcp_input.c
> > @@ -5028,7 +5028,7 @@ static void tcp_check_space(struct sock *sk)
> >        if (sock_flag(sk, SOCK_QUEUE_SHRUNK)) {
> >                sock_reset_flag(sk, SOCK_QUEUE_SHRUNK);
> >                /* pairs with tcp_poll() */
> > -               smp_mb__after_atomic();
> > +               smp_mb();
> >                if (sk->sk_socket &&
> >                    test_bit(SOCK_NOSPACE, &sk->sk_socket->flags)) {
> >                        tcp_new_space(sk);
> 
> The comment says that it's pairing with an mb in tcp_poll, but
> tcp_poll doesn't touch QUEUE_SHRUNK at all.  So what exactly is
> this barrier for?

Do not focus on QUEUE_SHRUNK flag, which is locally used by this thread
only.

The confusion comes because 3c7151275c0c9a80c3375f9874b1c7129a105eea
thought it could avoid the cost of smp_mb() by abusing the fact that
sock_reset_flag(sk, SOCK_QUEUE_SHRUNK) was doing an atomic,
but it was not.
