From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [Patch net] ipv4: restore rt->fi for reference counting
Date: Wed, 10 May 2017 10:38:49 +0300 (EEST)
Message-ID: <alpine.LFD.2.20.1705100937330.1938@ja.home.ssi.bg>
References: <1493934857-6693-1-git-send-email-xiyou.wangcong@gmail.com> <20170508.143557.105629611489969352.davem@davemloft.net> <1494288080.7796.59.camel@edumazet-glaptop3.roam.corp.google.com> <20170508.212211.1291611254198273979.davem@davemloft.net>
 <1494296302.7796.61.camel@edumazet-glaptop3.roam.corp.google.com> <CAM_iQpWQoLppsMfDOQWsdifGd56CAY24tCNm0Jm02QCe7ZThOw@mail.gmail.com> <1494348962.7796.88.camel@edumazet-glaptop3.roam.corp.google.com> <CAM_iQpXADa6AyQ3X-EbmRPGCQArgPWygvHMYgWtfUYV082oF3Q@mail.gmail.com>
 <CAM_iQpVhdzeen+ZJ3jyK7Qb=yVuoRSZ7BFB3RoVMShY8KPBTZA@mail.gmail.com> <1494370367.7796.92.camel@edumazet-glaptop3.roam.corp.google.com> <1494370451.7796.93.camel@edumazet-glaptop3.roam.corp.google.com> <1494371348.7796.95.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpU+fXO7eFroAYMv6vqDzCK_ZYXjrTPAMfoDR2BDqaK9rQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Andrey Konovalov <andreyknvl@google.com>,
        Eric Dumazet <edumazet@google.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:36436 "EHLO ja.ssi.bg"
        rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751121AbdEJHjB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 10 May 2017 03:39:01 -0400
In-Reply-To: <CAM_iQpU+fXO7eFroAYMv6vqDzCK_ZYXjrTPAMfoDR2BDqaK9rQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Tue, 9 May 2017, Cong Wang wrote:

> > Also setting nexthop_nh->nh_dev to NULL looks quite dangerous
> >
> > We have plenty of sites doing :
> >
> > if (fi->fib_dev)
> >     x = fi->fib_dev->field
> >
> > fib_route_seq_show() is one example.
> >
> 
> All of them take RCU read lock, so, as I explained in the code comment,
> they all should be fine because of synchronize_net() on unregister path.
> Do you see anything otherwise?

	During NETDEV_UNREGISTER packets for dev should not
be flying but packets for other devs can walk the nexthops
for multipath routes. It is the rcu_barrier before
NETDEV_UNREGISTER_FINAL that allows nh_dev to be set to NULL
during this grace period but there are many places to fix that
assume nh_dev!=NULL.

	But why we leak routes? Is there some place that holds
routes without listening for NETDEV_UNREGISTER? On fib_flush
the infos are unlinked from trees, so after a grace period packets
should not see/hold such infos. If we hold routes somewhere for
long time, problem can happen also for routes with single nexthop.

Regards
