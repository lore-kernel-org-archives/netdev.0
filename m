From: Mathieu Desnoyers <mathieu.desnoyers-vg+e7yoeK/dWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v7 15/16] openvswitch: use new hashtable implementation
Date: Mon, 29 Oct 2012 11:59:57 -0400
Message-ID: <20121029155957.GB18834@Krystal>
References: <1351450948-15618-1-git-send-email-levinsasha928@gmail.com> <1351450948-15618-15-git-send-email-levinsasha928@gmail.com> <20121029132931.GC16391@Krystal> <CA+1xoqfRGhPaBEVh228O5_295bWh8FmcyLSOwq8VE5Dm7i3JHg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, paul.gortmaker-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org,
	ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, aarcange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ericvh-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org,
	eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, neilb-l3A5Bk7waGM@public.gmane.org, ccaulfie-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	teigland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org,
	bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org, fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org,
	venkat.x.venkatsubra-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, ejt-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org, lw-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org
To: Sasha Levin <levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CA+1xoqfRGhPaBEVh228O5_295bWh8FmcyLSOwq8VE5Dm7i3JHg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

* Sasha Levin (levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org) wrote:
> Hi Mathieu,
> 
> On Mon, Oct 29, 2012 at 9:29 AM, Mathieu Desnoyers
> <mathieu.desnoyers-vg+e7yoeK/dWk0Htik3J/w@public.gmane.org> wrote:
> > * Sasha Levin (levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org) wrote:
> > [...]
> >> -static struct hlist_head *hash_bucket(struct net *net, const char *name)
> >> -{
> >> -     unsigned int hash = jhash(name, strlen(name), (unsigned long) net);
> >> -     return &dev_table[hash & (VPORT_HASH_BUCKETS - 1)];
> >> -}
> >> -
> >>  /**
> >>   *   ovs_vport_locate - find a port that has already been created
> >>   *
> >> @@ -84,13 +76,12 @@ static struct hlist_head *hash_bucket(struct net *net, const char *name)
> >>   */
> >>  struct vport *ovs_vport_locate(struct net *net, const char *name)
> >>  {
> >> -     struct hlist_head *bucket = hash_bucket(net, name);
> >>       struct vport *vport;
> >>       struct hlist_node *node;
> >> +     int key = full_name_hash(name, strlen(name));
> >>
> >> -     hlist_for_each_entry_rcu(vport, node, bucket, hash_node)
> >> -             if (!strcmp(name, vport->ops->get_name(vport)) &&
> >> -                 net_eq(ovs_dp_get_net(vport->dp), net))
> >> +     hash_for_each_possible_rcu(dev_table, vport, node, hash_node, key)
> >
> > Is applying hash_32() on top of full_name_hash() needed and expected ?
> 
> Since this was pointed out in several of the patches, I'll answer it
> just once here.
> 
> I've intentionally "allowed" double hashing with hash_32 to keep the
> code simple.
> 
> hash_32() is pretty simple and gcc optimizes it to be almost nothing,
> so doing that costs us a multiplication and a shift. On the other
> hand, we benefit from keeping our code simple - how would we avoid
> doing this double hash? adding a different hashtable function for
> strings? or a new function for already hashed keys? I think we benefit
> a lot from having to mul/shr instead of adding extra lines of code
> here.

This could be done, as I pointed out in another email within this
thread, by changing the "key" argument from add/for_each_possible to an
expected "hash" value, and let the caller invoke hash_32() if they want.
I doubt this would add a significant amount of complexity for users of
this API, but would allow much more flexibility to choose hash
functions.

Thanks,

Mathieu

-- 
Mathieu Desnoyers
Operating System Efficiency R&D Consultant
EfficiOS Inc.
http://www.efficios.com
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
