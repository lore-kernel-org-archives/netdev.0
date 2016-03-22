From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] ipv6: Fix the pmtu path for connected UDP socket
Date: Tue, 22 Mar 2016 09:53:35 -0700
Message-ID: <CAM_iQpVfofoThoUS8UYkh-2KR_Co42tfxz00mCXx+JMWpwgg8A@mail.gmail.com>
References: <20160316.195341.68257764618999441.davem@davemloft.net>
	<1458174127.7353.11.camel@edumazet-glaptop3.roam.corp.google.com>
	<20160316.223803.240230703927987310.davem@davemloft.net>
	<1458185652.7353.28.camel@edumazet-glaptop3.roam.corp.google.com>
	<CAM_iQpWG-Pd-qE05B8ETwBMnVGuxVCES-zrL=wyxKAfZwnbwyQ@mail.gmail.com>
	<CAEA6p_CfDYYLf-s0pUy7VNFH+46PDZSXNzUExXRAM_xv2w8tcw@mail.gmail.com>
	<CAM_iQpXgHHr=h=3VeMdYfOnzTdeBeODGVKmwBi7AFW485_WRAg@mail.gmail.com>
	<CAC15z3hhXxTQ+_Y6DaZcd-XVfCdDO9ZcQD6doNNKt-wHjTXAQw@mail.gmail.com>
	<CAM_iQpWvKUyTmvH=08FbeyGWKfV_WaM_L1MgOQ-9r9hjfvzPyA@mail.gmail.com>
	<CAC15z3ikqBc3CcgNaUJkaD1ZiBbwqZFkjEsgR7_F9Q1dvZ2Zvw@mail.gmail.com>
	<20160322060220.GA50824@kafai-mba.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Wei Wang <tracywwnj@gmail.com>, Wei Wang <weiwan@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f181.google.com ([209.85.161.181]:32769 "EHLO
	mail-yw0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751600AbcCVQxg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Mar 2016 12:53:36 -0400
Received: by mail-yw0-f181.google.com with SMTP id h65so119245594ywe.0
        for <netdev@vger.kernel.org>; Tue, 22 Mar 2016 09:53:36 -0700 (PDT)
In-Reply-To: <20160322060220.GA50824@kafai-mba.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 21, 2016 at 11:02 PM, Martin KaFai Lau <kafai@fb.com> wrote:
> I think Cong Wang is suggesting, in ip6_sk_update_pmtu():
> 1. call ip6_upate_pmtu() as it is
> 2. do a dst_check()
> 3. re-lookup() if it is invalid
> 4. and then do a ip6_dst_store()/dst_set
>
> The above is exactly what inet6_csk_update_pmtu(), which was also used in the
> first patch, is doing.

Well, the reasons why I suggest to fix ip6_sk_update_pmtu() instead of anything
else (no matter __udp6_lib_err() in v1 or ip6_update_pmtu() in v2) are that:

1) Catch up with ipv4 part, which is ipv4_sk_update_pmtu()
2) Straight-forward, (ideally) no need to bother other irrelevant
callers like xfrm.

Functionally all the solutions should work to fix Wei's problem, we just need to
find which one is more elegant.


>
> In term of difference, AFAICT, the current patch is an optimization in the
> sense that the update_pmtu() code path does not have to do a dst_check to
> discover its sk->sk_dst_cache is invalid, and then do a relookup to find out
> that the just created RTF_CACHE clone should be used.  To get this, it may
> make more sense to remove all the relookup code together during update_pmtu().
> Even if this slow path was to be optimized, should it be put in a
> separate patch where net-next is a better candidate?
>

Speaking of RTF_CACHE, I am curious why you didn't use FIB next hop exception
as what ipv4 does to cache exceptions? This makes IPv6 has more gap with IPv4.
This is (almost) irrelevant to this patch.


> I think fixing it in __udp6_lib_err() or what Cong Wang is suggesting makes
> more sense for a net branch fix.  If there is logic specific to connected-udp,
> I would do it in the __udp6_lib_err() instead.  After looking at
> udpv6_sendmsg() and how it calls ip6_dst_store(), may also need to be careful
> what daddr and saddr should be passed to ip6_dst_store(), or at least a commit
> message.  The first patch is essentially passing NULL to daddr and saddr
> while the second patch seems passing something else.

Raw socket needs to fix too, we can't just fix __udp6_lib_err(), this is also
why fixing ip6_sk_update_pmtu() is better, its call path is better.
