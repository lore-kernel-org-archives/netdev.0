From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] ipv6: Fix the pmtu path for connected UDP socket
Date: Tue, 22 Mar 2016 11:19:27 -0700
Message-ID: <CAM_iQpXT2Q1UKpyjmf3hu=EqL=HesE268tK5Y0xksPPMHgZv0g@mail.gmail.com>
References: <20160316.223803.240230703927987310.davem@davemloft.net>
	<1458185652.7353.28.camel@edumazet-glaptop3.roam.corp.google.com>
	<CAM_iQpWG-Pd-qE05B8ETwBMnVGuxVCES-zrL=wyxKAfZwnbwyQ@mail.gmail.com>
	<CAEA6p_CfDYYLf-s0pUy7VNFH+46PDZSXNzUExXRAM_xv2w8tcw@mail.gmail.com>
	<CAM_iQpXgHHr=h=3VeMdYfOnzTdeBeODGVKmwBi7AFW485_WRAg@mail.gmail.com>
	<CAC15z3hhXxTQ+_Y6DaZcd-XVfCdDO9ZcQD6doNNKt-wHjTXAQw@mail.gmail.com>
	<CAM_iQpWvKUyTmvH=08FbeyGWKfV_WaM_L1MgOQ-9r9hjfvzPyA@mail.gmail.com>
	<CAC15z3ikqBc3CcgNaUJkaD1ZiBbwqZFkjEsgR7_F9Q1dvZ2Zvw@mail.gmail.com>
	<20160322060220.GA50824@kafai-mba.local>
	<CAM_iQpVfofoThoUS8UYkh-2KR_Co42tfxz00mCXx+JMWpwgg8A@mail.gmail.com>
	<20160322173939.GA53936@kafai-mba.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Wei Wang <tracywwnj@gmail.com>, Wei Wang <weiwan@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f170.google.com ([209.85.161.170]:36605 "EHLO
	mail-yw0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750901AbcCVST2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Mar 2016 14:19:28 -0400
Received: by mail-yw0-f170.google.com with SMTP id g3so265357981ywa.3
        for <netdev@vger.kernel.org>; Tue, 22 Mar 2016 11:19:27 -0700 (PDT)
In-Reply-To: <20160322173939.GA53936@kafai-mba.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 22, 2016 at 10:39 AM, Martin KaFai Lau <kafai@fb.com> wrote:
> On Tue, Mar 22, 2016 at 09:53:35AM -0700, Cong Wang wrote:
>> On Mon, Mar 21, 2016 at 11:02 PM, Martin KaFai Lau <kafai@fb.com> wrote:
>> > In term of difference, AFAICT, the current patch is an optimization in the
>> > sense that the update_pmtu() code path does not have to do a dst_check to
>> > discover its sk->sk_dst_cache is invalid, and then do a relookup to find out
>> > that the just created RTF_CACHE clone should be used.  To get this, it may
>> > make more sense to remove all the relookup code together during update_pmtu().
>> > Even if this slow path was to be optimized, should it be put in a
>> > separate patch where net-next is a better candidate?
>> >
>>
>> Speaking of RTF_CACHE, I am curious why you didn't use FIB next hop exception
>> as what ipv4 does to cache exceptions? This makes IPv6 has more gap with IPv4.
>> This is (almost) irrelevant to this patch.
> There are a few differences between IPv6 and IPv4.  Both in terms of
> data structure and functionality.  The last 'RTF_CACHE on exception' patchset is one
> step toward this direction. More patches are needed and are welcomed ;)

Sure, I will take a look at this once net-next is re-open.


>
>>
>>
>> > I think fixing it in __udp6_lib_err() or what Cong Wang is suggesting makes
>> > more sense for a net branch fix.  If there is logic specific to connected-udp,
>> > I would do it in the __udp6_lib_err() instead.  After looking at
>> > udpv6_sendmsg() and how it calls ip6_dst_store(), may also need to be careful
>> > what daddr and saddr should be passed to ip6_dst_store(), or at least a commit
>> > message.  The first patch is essentially passing NULL to daddr and saddr
>> > while the second patch seems passing something else.
>>
>> Raw socket needs to fix too, we can't just fix __udp6_lib_err(), this is also
>> why fixing ip6_sk_update_pmtu() is better, its call path is better.
> I don't see rawv6 socket is storing the dst.  I probably have overlooked it.  Can
> you point it out?


I thought sk->sk_dst_cache is generic to all sockets, but it is up to
each kind of
socket to decide to use it or not, and you are right, raw socket doesn't seem to
care about it even though it calls *_sk_update_pmtu().
