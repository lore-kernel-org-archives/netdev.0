From: lucien xin <lucien.xin@gmail.com>
Subject: Re: [PATCH] ipv6: ip6_append_data_mtu do not handle the mtu of the
 second fragment properly
Date: Wed, 12 Mar 2014 10:40:50 +0800
Message-ID: <CADvbK_fS0rhPodczcZ52YN9D7NBY_TG+6xXvt-shvvz+e3qLnw@mail.gmail.com>
References: <1394512309-8823-1-git-send-email-lucien.xin@gmail.com>
	<20140311144906.GA29404@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Xin Long <lucien.xin@gmail.com>,
	network dev <netdev@vger.kernel.org>,
	Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f173.google.com ([74.125.82.173]:49285 "EHLO
	mail-we0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751015AbaCLCkx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2014 22:40:53 -0400
Received: by mail-we0-f173.google.com with SMTP id w61so10825896wes.32
        for <netdev@vger.kernel.org>; Tue, 11 Mar 2014 19:40:52 -0700 (PDT)
In-Reply-To: <20140311144906.GA29404@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 11, 2014 at 10:49 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
>
> Sorry, that is not correct:
>
> The min() protects the mtu going over np->frag_size (if set). In case we
> remove the min we would fallback to dev->mtu or dst_mtu and thus this could
> lead to a situation where the first fragment respects frag_size but second
> not. This confuses ip6_append_data and would lead to a crash.
>
yes, your analysis is quite right,  I ignore the code:
                if (np->frag_size < mtu) {
                        if (np->frag_size)
                                mtu = np->frag_size;
                }
> I am thinking about changing this to
>
> min(*mtu + rt->dst.header_len, pmtuprobe ? rt->dst.dev->mtu : dst_mtu(rt->dst.path))
>
> or we pass the np directly and test for frag_size again.

but I cannot understand the top half of ip6_append_data() has the code
to get mtu,
                if (rt->dst.flags & DST_XFRM_TUNNEL)
                        mtu = np->pmtudisc >= IPV6_PMTUDISC_PROBE ?
                              rt->dst.dev->mtu : dst_mtu(&rt->dst);
                else
                        mtu = np->pmtudisc >= IPV6_PMTUDISC_PROBE ?
                              rt->dst.dev->mtu : dst_mtu(rt->dst.path);

 why it need to calculate mtu again?  just "mtu=*mtu +
rt->dst.header_len", isn't it sufficient?
