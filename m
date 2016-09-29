From: Paolo Abeni <pabeni-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next v3 2/3] udp: implement memory accounting helpers
Date: Thu, 29 Sep 2016 09:34:42 +0200
Message-ID: <1475134482.4676.11.camel@redhat.com>
References: <cover.1475048434.git.pabeni@redhat.com>
         <6f445861ef2ce2e626a1df4946bc3f43f3d43e3f.1475048434.git.pabeni@redhat.com>
         <1475113378.28155.124.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>,
        Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>,
        Alexander Duyck <aduyck-nYU0QVwCCFFWk0Htik3J/w@public.gmane.org>,
        Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
        Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        Tom Herbert <tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org>,
        Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>,
        Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1475113378.28155.124.camel-XN9IlZ5yJG9HTL0Zs8A6p+yfmBU6pStAUsxypvmhUTTZJqsBc5GL+g@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Eric,

On Wed, 2016-09-28 at 18:42 -0700, Eric Dumazet wrote:
> On Wed, 2016-09-28 at 12:52 +0200, Paolo Abeni wrote:
> 
> > +static void udp_rmem_release(struct sock *sk, int partial)
> > +{
> > +	struct udp_sock *up = udp_sk(sk);
> > +	int fwd, amt;
> > +
> > +	if (partial && !udp_under_memory_pressure(sk))
> > +		return;
> > +
> > +	/* we can have concurrent release; if we catch any conflict
> > +	 * we let only one of them do the work
> > +	 */
> > +	if (atomic_dec_if_positive(&up->can_reclaim) < 0)
> > +		return;
> > +
> > +	fwd = __udp_forward(up, atomic_read(&sk->sk_rmem_alloc));
> > +	if (fwd < SK_MEM_QUANTUM + partial) {
> > +		atomic_inc(&up->can_reclaim);
> > +		return;
> > +	}
> > +
> > +	amt = (fwd - partial) & ~(SK_MEM_QUANTUM - 1);
> > +	atomic_sub(amt, &up->mem_allocated);
> > +	atomic_inc(&up->can_reclaim);
> > +
> > +	__sk_mem_reduce_allocated(sk, amt >> SK_MEM_QUANTUM_SHIFT);
> > +	sk->sk_forward_alloc = fwd - amt;
> > +}

Thank you for reviewing this!

> This is racy... 

Could you please elaborate? 

> all these atomics make me nervous...

I'd like to drop some of them if possible.

atomic_inc(&up->can_reclaim);

could probably be replaced with atomic_set(&up->can_reclaim, 1) since we
don't have concurrent processes doing that and can_reclaim.counter is
known to be 0 at that point.
Performance wise the impact is minimal, since in normal condition we do
the reclaim only on socket shutdown.

Paolo

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
