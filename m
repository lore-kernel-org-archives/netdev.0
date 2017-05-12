From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [Patch net] ipv4: restore rt->fi for reference counting
Date: Sat, 13 May 2017 00:27:52 +0300 (EEST)
Message-ID: <alpine.LFD.2.20.1705122151001.2835@ja.home.ssi.bg>
References: <1493934857-6693-1-git-send-email-xiyou.wangcong@gmail.com> <1494348962.7796.88.camel@edumazet-glaptop3.roam.corp.google.com> <CAM_iQpXADa6AyQ3X-EbmRPGCQArgPWygvHMYgWtfUYV082oF3Q@mail.gmail.com> <CAM_iQpVhdzeen+ZJ3jyK7Qb=yVuoRSZ7BFB3RoVMShY8KPBTZA@mail.gmail.com>
 <1494370367.7796.92.camel@edumazet-glaptop3.roam.corp.google.com> <1494370451.7796.93.camel@edumazet-glaptop3.roam.corp.google.com> <1494371348.7796.95.camel@edumazet-glaptop3.roam.corp.google.com> <CAM_iQpU+fXO7eFroAYMv6vqDzCK_ZYXjrTPAMfoDR2BDqaK9rQ@mail.gmail.com>
 <alpine.LFD.2.20.1705100937330.1938@ja.home.ssi.bg> <CAM_iQpX22qTqo4yfM_Je1bvJHxjAGK_tvm5KgQSnJzsYq7K55Q@mail.gmail.com> <alpine.LFD.2.20.1705102141320.1928@ja.home.ssi.bg> <CAM_iQpW0fJJXPS=FoTf-o4f5-mOC=mZYNP8=uqiUOmvX+CDwWw@mail.gmail.com>
 <CAM_iQpWxDKHF4N1xor7qj+5s91GrctgcGnzN0buw18qs7__-gQ@mail.gmail.com> <alpine.LFD.2.20.1705120659370.1811@ja.home.ssi.bg> <CAM_iQpVQSMd_LYMqm3EauRRgJhfkW=zsdvKRf4-YcGWwSufuvQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Andrey Konovalov <andreyknvl@google.com>,
        Eric Dumazet <edumazet@google.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:45296 "EHLO ja.ssi.bg"
        rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
        id S1758370AbdELV2C (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 12 May 2017 17:28:02 -0400
In-Reply-To: <CAM_iQpVQSMd_LYMqm3EauRRgJhfkW=zsdvKRf4-YcGWwSufuvQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Fri, 12 May 2017, Cong Wang wrote:

> On Thu, May 11, 2017 at 11:39 PM, Julian Anastasov <ja@ssi.bg> wrote:
> >
> >         fib_flush will unlink the FIB infos at NETDEV_UNREGISTER
> > time, so we can not see them in any hash tables later on
> > NETDEV_UNREGISTER_FINAL. fib_put_nh_devs() can not work
> > except if moving NHs in another hash table but that should
> > not be needed.
> 
> Ah, I did miss the hlist_del() in fib_table_flush(), so we just need some
> way to link those fib_nh together for NETDEV_UNREGISTER_FINAL,
> a linked list should be sufficient, but requires adding list_head to fib_nh.

	It could be a fib_info_devhash_dead hash table, similar
to fib_info_devhash where we can hash NHs for dead fib infos
but then we will need a fib_clntref reference or otherwise last
user can drop the fib info before NETDEV_UNREGISTER_FINAL is called.
It will add more code in fib_sync_down_dev to know when
to call fib_info_hold. But OTOH, it will reduce the work
needed for careful release of the references in fib_release_info.

	So, we have 2 possible cases to consider:

1. route deleted, fib_release_info called, fi held by socket,
NETDEV_UNREGISTER can not see the NHs because they are
unlinked in fib_release_info. dev unreg delayed for long time...

2. NETDEV_UNREGISTER called first, before the NHs are
unlinked.

	Now the main question: is FIB_LOOKUP_NOREF used
everywhere in IPv4? I guess so. If not, it means
someone can walk its res->fi NHs which is bad. I think,
this will delay the unregistration for long time and we
can not solve the problem.

	If yes, free_fib_info() should not use call_rcu.
Instead, fib_release_info() will start RCU callback to
drop everything via a common function for fib_release_info
and free_fib_info. As result, the last fib_info_put will
just need to free fi->fib_metrics and fi.

	Something like:

/* Long living data */
fib_info_destroy:
{
	if (fi->fib_dead == 0) {
		pr_warn("Freeing alive fib_info %p\n", fi);
		return;
	}

	if (fi->fib_metrics != (u32 *) dst_default_metrics)
		kfree(fi->fib_metrics);
	kfree(fi);
}

/* Do not imply RCU grace period anymore, last user is last */
fib_info_put():
{
	if (atomic_dec_and_test(&fi->fib_clntref))
		fib_info_destroy(fi);
}

/* Release everything except long living fields (fib_metrics) */
fib_info_release():
{
        change_nexthops(fi) {
                if (nexthop_nh->nh_dev)
                        dev_put(nexthop_nh->nh_dev);
                lwtstate_put(nexthop_nh->nh_lwtstate);
                free_nh_exceptions(nexthop_nh);
                rt_fibinfo_free_cpus(nexthop_nh->nh_pcpu_rth_output);
                rt_fibinfo_free(&nexthop_nh->nh_rth_input);
        } endfor_nexthops(fi);
}

/* RCU grace period after unlink */
fib_release_info_rcu():
{
	struct fib_info *fi = container_of(head, struct fib_info, rcu);

	fib_info_release(fi);
	fib_info_put(fi);
}

/* Called just on error */
free_fib_info():
{
	fib_info_release(fi);
	fib_info_put(fi);
}

fib_release_info():
{
	...
	fi->fib_dead = 1;
-	fib_info_put(fi);
+	call_rcu(&fi->rcu, fib_release_info_rcu);
}

> >         I'm thinking for the following solution which
> > is a bit hackish:
> >
> > - on NETDEV_UNREGISTER we want to put the nh_dev references,
> > so fib_release_info is a good place. But as fib_release_info
> > is not always called, we will have two places that put
> > references. We can use such hack:
> >
> >         - for example, use nh_oif to know if dev_put is
> >         already called
> >
> >         - fib_release_info() should set nh_oif to 0 because
> >         it will now call dev_put without clearing nh_dev
> 
> Are you sure we are safe to call dev_put() in fib_release_info()
> for _all_ paths, especially non-unregister paths? See:

	Yep, dev_put is safe there...

> commit e49cc0da7283088c5e03d475ffe2fdcb24a6d5b1
> Author: Yanmin Zhang <yanmin_zhang@linux.intel.com>
> Date:   Wed May 23 15:39:45 2012 +0000
> 
>     ipv4: fix the rcu race between free_fib_info and ip_route_output_slow

	...as long as we do not set nh_dev to NULL

> But, hmm, very interesting, I always thought dev_put() triggers a
> kfree() potentially, but here your suggestion actually leverages the fact
> that it is merely a pcpu counter decrease, so for unregister path,
> this is just giving refcnt back, which means it is safe as long as
> we don't have any parallel unregister?  We should because of RTNL.

	Yes, we are in the context of unregistration and
there is a rcu_barrier() that prevents device to be
destroyed while there are RCU users. Refcnt reaching 0 is
not enough to free dev, RCU users must be considered,
they do not get reference.

> I see why you say this is hackish, really it is. ;) We have to ensure
> the evil dev_put() is only called on unregister path.

	Or after a RCU grace period but not later...

> > - fib_dev/nh_dev != NULL checks are not needed, so this addresses
> > Eric's concerns. BTW, fib_route_seq_show actually checks
> > for fi->fib_dev, may be not in a safe way (lockless_dereference
> > needed?) but as we don't set nh_dev to NULL this is not
> > needed.
> >
> 
> I think Eric was complaining about the lack of rcu_dereference()
> there.

	Not needed if we don't set nh_dev to NULL.

> >         What more? What about nh_pcpu_rth_output and
> > nh_rth_input holding routes? We should think about
> > them too. I should think more if nh_oif trick can work
> > for them, may be not because nh_oif is optional...
> > May be we should purge them somehow?
> >
> 
> Or maybe don't touch nh_oif but using a new flag in
> nh_flags?? We only need to know if we should call
> dev_put() in free_fib_info_rcu().

	fib_dead is a better option if we decide to use
such solution: 1=not called by fib_release_info,
2=called by fib_release_info.

Regards
