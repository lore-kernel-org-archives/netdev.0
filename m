From: Julian Anastasov <ja@ssi.bg>
Subject: Re: Use after free in __dst_destroy_metrics_generic
Date: Sat, 16 Sep 2017 01:38:18 +0300 (EEST)
Message-ID: <alpine.LFD.2.20.1709160103190.1770@ja.home.ssi.bg>
References: <1234e09b75197d43ed84bdb1b154b4b6@codeaurora.org>         <CAM_iQpXKfUkbyuuZEZXyPrVVCoPaxnCmCARz=Jf0VtU1m9NsZg@mail.gmail.com> <1505509219.16139.6.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Lorenzo Colitti <lorenzo@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:35444 "EHLO ja.ssi.bg"
        rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751211AbdIOWi2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 15 Sep 2017 18:38:28 -0400
In-Reply-To: <1505509219.16139.6.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Fri, 15 Sep 2017, Eric Dumazet wrote:

> On Fri, 2017-09-08 at 09:10 -0700, Cong Wang wrote:
> > On Thu, Sep 7, 2017 at 5:52 PM, Subash Abhinov Kasiviswanathan
> > <subashab@codeaurora.org> wrote:
> > > We are seeing a possible use after free in ip6_dst_destroy.
> > >
> > > It appears as if memory of the __DST_METRICS_PTR(old) was freed in some path
> > > and allocated
> > > to ion driver. ion driver has also freed it. Finally the memory is freed by
> > > the
> > > fib gc and crashes since it is already deallocated.
> > 
> > Does the attach (compile-only) patch help anything?
> > 
> > From my _quick_ glance, it seems we miss the refcnt'ing
> > right in __dst_destroy_metrics_generic().
> > 
> > Thanks!
> 
> 
> Hi Cong
> 
> I believe your patch makes a lot of sense, please submit it formally ?

	Cong's patch is wrong for few reasons:

- it will stop to kfree non-refcounted metrics

- report was for IPV6 and we set DST_METRICS_REFCOUNTED only
for IPv4, for DST_METRICS_READ_ONLY metrics

- __dst_destroy_metrics_generic is called for val without
DST_METRICS_READ_ONLY flag and such metrics are not with
DST_METRICS_REFCOUNTED flag

- ->cow_metrics and dst_cow_metrics_generic are called with 
DST_METRICS_READ_ONLY flag set, there is no chance to write
new value twice, especially to write DST_METRICS_REFCOUNTED flag
and later to see this flag in __dst_destroy_metrics_generic

	So, I'm not sure where exactly is the bug with the
metrics.

	May be I'm missing some posting but I don't see if
the patch was tested successfully.

Regards
