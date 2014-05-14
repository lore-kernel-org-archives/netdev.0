From: dormando <dormando@rydia.net>
Subject: Re: Multitude of dst obsolescense race conditions
Date: Wed, 14 May 2014 10:59:41 -0700 (PDT)
Message-ID: <alpine.DEB.2.10.1405141058570.9591@dinf>
References: <alpine.DEB.2.02.1405140233210.16893@dtop> <1400067618.7973.72.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1400067618.7973.72.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> On Wed, 2014-05-14 at 02:57 -0700, dormando wrote:
> > Hi,
> >
> > Given a machine with frequently changing routes (ie; a router with an
> > active internet BGP table and multiple interfaces), there're at least
> > several places where obsolete dst's are handled improperly. If I pause the
> > route changes, the crashes appear to stop. This first one has a crash
> > utility we've made, so I was able to more quickly find a patch and test
> > it. The others take time to reproduce.
> >
> > I'm testing against 3.10.39, but I think if these were fixed they'd be
> > backported to stable? I've also had recent 3.12's running that have
> > crashed in the same spots. Anyway correct me if I'm wrong...
>
> Is this a vanilla kernel ? I never had any issues like that.
>
> I wonder if you have some RCU issues.
>
> static inline struct dst_entry *
> sk_dst_get(struct sock *sk)
> {
>         struct dst_entry *dst;
>
>         rcu_read_lock();
>         dst = rcu_dereference(sk->sk_dst_cache);
>         if (dst)
>                 dst_hold(dst);
>         rcu_read_unlock();
>         return dst;
> }
>
> static inline void
> __sk_dst_set(struct sock *sk, struct dst_entry *dst)
> {
>         struct dst_entry *old_dst;
>
>         sk_tx_queue_clear(sk);
>         /*
>          * This can be called while sk is owned by the caller only,
>          * with no state that can be checked in a rcu_dereference_check() cond
>          */
>         old_dst = rcu_dereference_raw(sk->sk_dst_cache);
>         rcu_assign_pointer(sk->sk_dst_cache, dst);
>         dst_release(old_dst);
> }
>
> static inline void
> sk_dst_set(struct sock *sk, struct dst_entry *dst)
> {
>         spin_lock(&sk->sk_dst_lock);
>         __sk_dst_set(sk, dst);
>         spin_unlock(&sk->sk_dst_lock);
> }
>
>
>
>

We have some minor patches, but I've removed them before and they still
happen. I'd crashed a vanilla 3.12 + just the stable patches recently I
think.
