From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC net-next 2/2] udp: No longer use SLAB_DESTROY_BY_RCU
Date: Mon, 28 Mar 2016 14:02:30 -0700
Message-ID: <1459198950.6473.129.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1458944964-12890-1-git-send-email-edumazet@google.com>
	 <1458944964-12890-3-git-send-email-edumazet@google.com>
	 <CALx6S35n=R4B0Mm0YpgobPfU9rC=wf+t2b2z=xne3MhCMLbW2g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	"David S . Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:35392 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751785AbcC1VCe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Mar 2016 17:02:34 -0400
Received: by mail-pa0-f46.google.com with SMTP id td3so106027283pab.2
        for <netdev@vger.kernel.org>; Mon, 28 Mar 2016 14:02:34 -0700 (PDT)
In-Reply-To: <CALx6S35n=R4B0Mm0YpgobPfU9rC=wf+t2b2z=xne3MhCMLbW2g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-03-25 at 17:08 -0700, Tom Herbert wrote:
> On Fri, Mar 25, 2016 at 3:29 PM, Eric Dumazet <edumazet@google.com> wrote:

> > +/* Must be called under rcu_read_lock().
> 
> 
> It might be just as easy to do the rcu_read_lock() within the
> function. That way we don't need to require callers to do it now.
> 
> > + * Does increment socket refcount.
> > + */
> > +#if IS_ENABLED(CONFIG_NETFILTER_XT_MATCH_SOCKET) || \
> > +    IS_ENABLED(CONFIG_NETFILTER_XT_TARGET_TPROXY)
> >  struct sock *udp4_lib_lookup(struct net *net, __be32 saddr, __be16 sport,
> >                              __be32 daddr, __be16 dport, int dif)
> >  {
> > -       return __udp4_lib_lookup(net, saddr, sport, daddr, dport, dif,
> > -                                &udp_table, NULL);
> > +       struct sock *sk;
> > +
> > +       sk = __udp4_lib_lookup(net, saddr, sport, daddr, dport,
> > +                              dif, &udp_table, NULL);
> > +       if (sk && !atomic_inc_not_zero(&sk->sk_refcnt))
> > +               sk = NULL;
> > +       return sk;
> >  }
> >  EXPORT_SYMBOL_GPL(udp4_lib_lookup);
> > +#endif


Well, these callers already run with rcu_read_lock(), I simply added a
comment to remind this assumption.

As I said, we might later avoid the refcounting if callers are modified
to not call sock_put(). This is why I prefer to maintain the reuirement
of rcu_read_lock() being held by callers anyway.
