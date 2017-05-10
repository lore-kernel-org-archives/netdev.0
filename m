From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [Patch net] ipv4: restore rt->fi for reference counting
Date: Wed, 10 May 2017 22:51:27 +0300 (EEST)
Message-ID: <alpine.LFD.2.20.1705102141320.1928@ja.home.ssi.bg>
References: <1493934857-6693-1-git-send-email-xiyou.wangcong@gmail.com> <20170508.143557.105629611489969352.davem@davemloft.net> <1494288080.7796.59.camel@edumazet-glaptop3.roam.corp.google.com> <20170508.212211.1291611254198273979.davem@davemloft.net>
 <1494296302.7796.61.camel@edumazet-glaptop3.roam.corp.google.com> <CAM_iQpWQoLppsMfDOQWsdifGd56CAY24tCNm0Jm02QCe7ZThOw@mail.gmail.com> <1494348962.7796.88.camel@edumazet-glaptop3.roam.corp.google.com> <CAM_iQpXADa6AyQ3X-EbmRPGCQArgPWygvHMYgWtfUYV082oF3Q@mail.gmail.com>
 <CAM_iQpVhdzeen+ZJ3jyK7Qb=yVuoRSZ7BFB3RoVMShY8KPBTZA@mail.gmail.com> <1494370367.7796.92.camel@edumazet-glaptop3.roam.corp.google.com> <1494370451.7796.93.camel@edumazet-glaptop3.roam.corp.google.com> <1494371348.7796.95.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpU+fXO7eFroAYMv6vqDzCK_ZYXjrTPAMfoDR2BDqaK9rQ@mail.gmail.com> <alpine.LFD.2.20.1705100937330.1938@ja.home.ssi.bg> <CAM_iQpX22qTqo4yfM_Je1bvJHxjAGK_tvm5KgQSnJzsYq7K55Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Andrey Konovalov <andreyknvl@google.com>,
        Eric Dumazet <edumazet@google.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:42288 "EHLO ja.ssi.bg"
        rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753795AbdEJTvl (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 10 May 2017 15:51:41 -0400
In-Reply-To: <CAM_iQpX22qTqo4yfM_Je1bvJHxjAGK_tvm5KgQSnJzsYq7K55Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Wed, 10 May 2017, Cong Wang wrote:

> On Wed, May 10, 2017 at 12:38 AM, Julian Anastasov <ja@ssi.bg> wrote:
> >
> >         During NETDEV_UNREGISTER packets for dev should not
> > be flying but packets for other devs can walk the nexthops
> > for multipath routes. It is the rcu_barrier before
> > NETDEV_UNREGISTER_FINAL that allows nh_dev to be set to NULL
> > during this grace period but there are many places to fix that
> > assume nh_dev!=NULL.
> 
> Excellent point. Unfortunately NETDEV_UNREGISTER_FINAL is not
> yet captured by the fib event notifier.
> 
> I think readers are still safe to assume nh_dev!=NULL since we wait
> for existing readers, readers coming later can't see it any more. Or
> am I missing anything?

	It is not safe because other devs can deliver packets
that still can see the multipath fib info in the FIB nodes.

CPU 1 (unreg dev)               CPU 2 (packet to another dev2)
NETDEV_DOWN => set RTNH_F_DEAD

Now traffic sent via downed
dev should stop

flush_all_backlogs
synchronize_net

Now received traffic for dev
should stop on all CPUs

fib_sync_down_dev
nh_dev = NULL
                                fib_table_lookup: boom in
                                __in_dev_get_rcu(nh->nh_dev),
                                all nh_dev dereferences must be
                                checked. If checked, it should be
                                safe to use this nh_dev due to the
                                rcu_barrier in netdev_run_todo.
                                But only the structure can be accessed,
                                traffic should not go via unreged dev.

fib_flush: unlink fi
from fa_info in
fib_table_flush

                                Now other CPUs will not see this
                                fi on lookups (after fib_table_flush)

netdev_run_todo
 rcu_barrier
                                Now other CPUs should not send
                                packets via this fib info
 NETDEV_UNREGISTER_FINAL

Notes:

- when NETDEV_DOWN is delivered fib_sync_down_dev sets RTNH_F_DEAD
but only for link routes, not for host routes

- fib_table_lookup runs without any memory ordering barriers,
when CPU 2 delivers packet from different dev it can hit
a multipath route with nh_dev set to NULL. Not so often
if RTNH_F_DEAD was set early and properly checked before
dereferencing nh_dev.

> >         But why we leak routes? Is there some place that holds
> > routes without listening for NETDEV_UNREGISTER? On fib_flush
> > the infos are unlinked from trees, so after a grace period packets
> > should not see/hold such infos. If we hold routes somewhere for
> > long time, problem can happen also for routes with single nexthop.
> 
> My theory is that dst which holds a refcnt to fib_info (of course, after
> this patch) is moved in GC after NETDEV_UNREGISTER but still
> referenced somewhere, it therefore holds these nh_dev's, which
> in turn hold back to the netdevice which is being unregistered, thus
> Eric saw these refcnt leak warnings.

	Oh, well, the sockets can hold cached dst.
But if the promise is that rt->fi is used only as
reference to metrics we have to find a way to drop
the dev references at NETDEV_UNREGISTER time. If you
set nh_dev to NULL then all lookups should check it
for != NULL. The sockets will not walk NHs via rt->fi,
i.e. the route lookups will get valid res.fi from trees,
so it may work in this way.

Regards
