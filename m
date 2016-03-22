From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv6: Fix the pmtu path for connected UDP socket
Date: Tue, 22 Mar 2016 16:36:54 -0700
Message-ID: <1458689814.10868.29.camel@edumazet-glaptop3.roam.corp.google.com>
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
	 <CAC15z3jDRvJR4uZ97mC+beaMaPQvAvTHB9OLKCdQ4hcwRu07vw@mail.gmail.com>
	 <CAM_iQpU7JeLuAVPqtzjvJ7qvMYTDZSR8xc7Vfw--uQDxW-WaHQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Wei Wang <tracywwnj@gmail.com>, Martin KaFai Lau <kafai@fb.com>,
	Wei Wang <weiwan@google.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:35097 "EHLO
	mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750826AbcCVXg5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Mar 2016 19:36:57 -0400
Received: by mail-pf0-f170.google.com with SMTP id n5so330476852pfn.2
        for <netdev@vger.kernel.org>; Tue, 22 Mar 2016 16:36:57 -0700 (PDT)
In-Reply-To: <CAM_iQpU7JeLuAVPqtzjvJ7qvMYTDZSR8xc7Vfw--uQDxW-WaHQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-03-22 at 13:13 -0700, Cong Wang wrote:
> On Tue, Mar 22, 2016 at 11:03 AM, Wei Wang <tracywwnj@gmail.com> wrote:
> > Thanks Martin and Cong.
> >
> > I guess then we are going with the following fix in ip6_sk_update_pmtu():
> > 1. call ip6_upate_pmtu() as it is
> > 2. do a dst_check()
> > 3. re-lookup() if it is invalid
> > 4. and then do a ip6_dst_store()/dst_set
> 
> Exactly, please try the attached patch. Note I did nothing more than a
> compile test.
> 
> Does it make sense to you now?


Hard to reply on your patch as it was not inlined.

1) Lot of code duplication, for some reason I do not yet understand.

ip6_sk_update_pmtu() and ip6_update_pmtu() will basically do the same
thing...

2)

+       if (sk->sk_state == TCP_ESTABLISHED)
+               ip6_dst_store(sk, dst, &iph->daddr, &iph->saddr);
+out:


ip6_dst_store() will do :

np->daddr_cache = daddr;  (&iph->daddr)
np->saddr_cache = saddr;  (&iph->saddr)

So when skb is freed, daddr_cache & saddr_cache point to freed data.
