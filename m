From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [Patch net] ipv4: restore rt->fi for reference counting
Date: Mon, 15 May 2017 23:37:30 +0300 (EEST)
Message-ID: <alpine.LFD.2.20.1705152317090.4002@ja.home.ssi.bg>
References: <1493934857-6693-1-git-send-email-xiyou.wangcong@gmail.com> <CAM_iQpVhdzeen+ZJ3jyK7Qb=yVuoRSZ7BFB3RoVMShY8KPBTZA@mail.gmail.com> <1494370367.7796.92.camel@edumazet-glaptop3.roam.corp.google.com> <1494370451.7796.93.camel@edumazet-glaptop3.roam.corp.google.com>
 <1494371348.7796.95.camel@edumazet-glaptop3.roam.corp.google.com> <CAM_iQpU+fXO7eFroAYMv6vqDzCK_ZYXjrTPAMfoDR2BDqaK9rQ@mail.gmail.com> <alpine.LFD.2.20.1705100937330.1938@ja.home.ssi.bg> <CAM_iQpX22qTqo4yfM_Je1bvJHxjAGK_tvm5KgQSnJzsYq7K55Q@mail.gmail.com>
 <alpine.LFD.2.20.1705102141320.1928@ja.home.ssi.bg> <CAM_iQpW0fJJXPS=FoTf-o4f5-mOC=mZYNP8=uqiUOmvX+CDwWw@mail.gmail.com> <CAM_iQpWxDKHF4N1xor7qj+5s91GrctgcGnzN0buw18qs7__-gQ@mail.gmail.com> <alpine.LFD.2.20.1705120659370.1811@ja.home.ssi.bg>
 <CAM_iQpVQSMd_LYMqm3EauRRgJhfkW=zsdvKRf4-YcGWwSufuvQ@mail.gmail.com> <alpine.LFD.2.20.1705122151001.2835@ja.home.ssi.bg> <CAM_iQpXtWUZoGS_KEqfZc+ZbzYxaF1hbAV7H9Qd82=r4auJojw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Andrey Konovalov <andreyknvl@google.com>,
        Eric Dumazet <edumazet@google.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:55958 "EHLO ja.ssi.bg"
        rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
        id S934269AbdEOUhp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 15 May 2017 16:37:45 -0400
In-Reply-To: <CAM_iQpXtWUZoGS_KEqfZc+ZbzYxaF1hbAV7H9Qd82=r4auJojw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Mon, 15 May 2017, Cong Wang wrote:

> On Fri, May 12, 2017 at 2:27 PM, Julian Anastasov <ja@ssi.bg> wrote:
> >         Now the main question: is FIB_LOOKUP_NOREF used
> > everywhere in IPv4? I guess so. If not, it means
> > someone can walk its res->fi NHs which is bad. I think,
> > this will delay the unregistration for long time and we
> > can not solve the problem.
> >
> >         If yes, free_fib_info() should not use call_rcu.
> > Instead, fib_release_info() will start RCU callback to
> > drop everything via a common function for fib_release_info
> > and free_fib_info. As result, the last fib_info_put will
> > just need to free fi->fib_metrics and fi.
> 
> 
> Yes it is used. But this is a different problem from the
> dev refcnt issue, right? I can send a separate patch to
> address it.

	Any user that does not set FIB_LOOKUP_NOREF
will need nh_dev refcounts. The assumption is that the
NHs are accessed, who knows, may be even after RCU grace
period. As result, we can not use dev_put on NETDEV_UNREGISTER.
So, we should check if there are users that do not
set FIB_LOOKUP_NOREF, at first look, I don't see such ones
for IPv4.

> >> Are you sure we are safe to call dev_put() in fib_release_info()
> >> for _all_ paths, especially non-unregister paths? See:
> >
> >         Yep, dev_put is safe there...
> >
> >> commit e49cc0da7283088c5e03d475ffe2fdcb24a6d5b1
> >> Author: Yanmin Zhang <yanmin_zhang@linux.intel.com>
> >> Date:   Wed May 23 15:39:45 2012 +0000
> >>
> >>     ipv4: fix the rcu race between free_fib_info and ip_route_output_slow
> >
> >         ...as long as we do not set nh_dev to NULL
> >
> 
> OK, fair enough, then I think the best solution here is to move
> the dev_put() from free_fib_info_rcu() to fib_release_info(),
> fib_nh is already removed from hash there anyway.

	free_fib_info still needs to put the references,
that is the reason for the common fib_info_release() in
my example. It happens in fib_create_info() where free_fib_info()
is called. The func names in my example can be corrected,
if needed.

> diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
> index da449dd..cb712d1 100644
> --- a/net/ipv4/fib_semantics.c
> +++ b/net/ipv4/fib_semantics.c
> @@ -205,8 +205,6 @@ static void free_fib_info_rcu(struct rcu_head *head)
>         struct fib_info *fi = container_of(head, struct fib_info, rcu);
> 
>         change_nexthops(fi) {
> -               if (nexthop_nh->nh_dev)
> -                       dev_put(nexthop_nh->nh_dev);
>                 lwtstate_put(nexthop_nh->nh_lwtstate);
>                 free_nh_exceptions(nexthop_nh);
>                 rt_fibinfo_free_cpus(nexthop_nh->nh_pcpu_rth_output);
> @@ -246,6 +244,14 @@ void fib_release_info(struct fib_info *fi)
>                         if (!nexthop_nh->nh_dev)
>                                 continue;
>                         hlist_del(&nexthop_nh->nh_hash);
> +                       /* We have to release these nh_dev here because a dst
> +                        * could still hold a fib_info via rt->fi, we can't wait
> +                        * for GC, a socket could hold the dst for a long time.
> +                        *
> +                        * This is safe, dev_put() alone does not really free
> +                        * the netdevice, we just have to put the refcnt back.
> +                        */
> +                       dev_put(nexthop_nh->nh_dev);
>                 } endfor_nexthops(fi)
>                 fi->fib_dead = 1;

	Such solution needs the fib_dead = 1|2 game to
know who dropped the nh_dev reference, fib_release_info (2) or
fib_create_info (1). You can not remove the dev_put calls
from free_fib_info_rcu.

>                 fib_info_put(fi);

Regards
