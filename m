From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [Patch net] ipv4: restore rt->fi for reference counting
Date: Fri, 12 May 2017 09:39:25 +0300 (EEST)
Message-ID: <alpine.LFD.2.20.1705120659370.1811@ja.home.ssi.bg>
References: <1493934857-6693-1-git-send-email-xiyou.wangcong@gmail.com> <CAM_iQpWQoLppsMfDOQWsdifGd56CAY24tCNm0Jm02QCe7ZThOw@mail.gmail.com> <1494348962.7796.88.camel@edumazet-glaptop3.roam.corp.google.com> <CAM_iQpXADa6AyQ3X-EbmRPGCQArgPWygvHMYgWtfUYV082oF3Q@mail.gmail.com>
 <CAM_iQpVhdzeen+ZJ3jyK7Qb=yVuoRSZ7BFB3RoVMShY8KPBTZA@mail.gmail.com> <1494370367.7796.92.camel@edumazet-glaptop3.roam.corp.google.com> <1494370451.7796.93.camel@edumazet-glaptop3.roam.corp.google.com> <1494371348.7796.95.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpU+fXO7eFroAYMv6vqDzCK_ZYXjrTPAMfoDR2BDqaK9rQ@mail.gmail.com> <alpine.LFD.2.20.1705100937330.1938@ja.home.ssi.bg> <CAM_iQpX22qTqo4yfM_Je1bvJHxjAGK_tvm5KgQSnJzsYq7K55Q@mail.gmail.com> <alpine.LFD.2.20.1705102141320.1928@ja.home.ssi.bg>
 <CAM_iQpW0fJJXPS=FoTf-o4f5-mOC=mZYNP8=uqiUOmvX+CDwWw@mail.gmail.com> <CAM_iQpWxDKHF4N1xor7qj+5s91GrctgcGnzN0buw18qs7__-gQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Andrey Konovalov <andreyknvl@google.com>,
        Eric Dumazet <edumazet@google.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:60012 "EHLO ja.ssi.bg"
        rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
        id S1755015AbdELGji (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 12 May 2017 02:39:38 -0400
In-Reply-To: <CAM_iQpWxDKHF4N1xor7qj+5s91GrctgcGnzN0buw18qs7__-gQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Thu, 11 May 2017, Cong Wang wrote:

> On Thu, May 11, 2017 at 5:07 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> > So, if I understand you correctly it is safe to NULL'ing
> > nh_dev in NETDEV_UNREGISTER_FINAL, right?
> >
> > If still not, how about transfer nh_dev's to loopback_dev
> > too in NETDEV_UNREGISTER? Like we transfer dst->dev.
> >
> > I don't want to touch the fast path to check for NULL, as
> > it will change more code and slow down performance.
> 
> Finally I come up with the attached patch. Please let me know if
> I still miss anything.

	fib_flush will unlink the FIB infos at NETDEV_UNREGISTER
time, so we can not see them in any hash tables later on
NETDEV_UNREGISTER_FINAL. fib_put_nh_devs() can not work
except if moving NHs in another hash table but that should
not be needed.

	I'm thinking for the following solution which
is a bit hackish:

- on NETDEV_UNREGISTER we want to put the nh_dev references,
so fib_release_info is a good place. But as fib_release_info
is not always called, we will have two places that put
references. We can use such hack:

	- for example, use nh_oif to know if dev_put is
	already called

	- fib_release_info() should set nh_oif to 0 because
	it will now call dev_put without clearing nh_dev

	- free_fib_info_rcu() will not call dev_put if nh_oif is 0:
	if (nexthop_nh->nh_dev && nexthop_nh->nh_oif)
		dev_put(nexthop_nh->nh_dev);

	- as fi is unlinked, there is no chance fib_info_hashfn()
	to use the cleared nh_oif for hashing

	- we expect noone to touch nh_dev fields after fi is
	unlinked, this includes free_fib_info and free_fib_info_rcu

	What we achieve:

- between NETDEV_UNREGISTER and NETDEV_UNREGISTER_FINAL nh_dev
still points to our dev (and not to loopback, I think, this
answers your question in previous email), so route lookups
will not find loopback in the FIB tree. We do not want
some packets to be wrongly rerouted. Even if we don't
hold dev reference, the RCU grace period helps here.

- fib_dev/nh_dev != NULL checks are not needed, so this addresses
Eric's concerns. BTW, fib_route_seq_show actually checks
for fi->fib_dev, may be not in a safe way (lockless_dereference
needed?) but as we don't set nh_dev to NULL this is not
needed.

	What more? What about nh_pcpu_rth_output and
nh_rth_input holding routes? We should think about
them too. I should think more if nh_oif trick can work
for them, may be not because nh_oif is optional...
May be we should purge them somehow?

Regards
