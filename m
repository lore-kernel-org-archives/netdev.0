From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: hard_header_len vs needed_headroom
Date: Mon, 9 Jun 2014 11:16:55 -0700
Message-ID: <CALnjE+pNfhB_-o1POjDpJj2F3opUv7ei1U8uO+bacCoP5vwxHg@mail.gmail.com>
References: <CAHA+R7Nyi9TvpN+fJrFt7krhLLXyJ5ify1ONvAse+rJFU0kbKg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	=?UTF-8?Q?Timo_Ter=C3=A4s?= <timo.teras@iki.fi>,
	netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog121.obsmtp.com ([74.125.149.145]:53242 "HELO
	na3sys009aog121.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753748AbaFISQ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jun 2014 14:16:56 -0400
Received: by mail-ve0-f170.google.com with SMTP id oz11so2265555veb.15
        for <netdev@vger.kernel.org>; Mon, 09 Jun 2014 11:16:55 -0700 (PDT)
In-Reply-To: <CAHA+R7Nyi9TvpN+fJrFt7krhLLXyJ5ify1ONvAse+rJFU0kbKg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 5, 2014 at 4:39 PM, Cong Wang <cwang@twopensource.com> wrote:
> Hello,
>
>
> While debugging a skb header push crash, I noticed that
> new ip tunnel code uses dev->needed_headroom as the
> length of hardware header:
>
> dev->needed_headroom = t_hlen + hlen;
>
> in IPIP tunnel case it's the ethernet header length plus IPv4
> header length. And it leaves dev->hard_header_len as 0.
>
> But there are some places assuming
> dev->hard_header_len is the length of L2 header, at least
> tcf_mirred() calls skb_push(skb, skb->dev->hard_header_len)
> to reset skb->data back to L2 header. Current code is broken.
>
> I think ip tunnel code is wrong, according to LL_RESERVED_SPACE(),
> it seems dev->hard_header_len should be the L2 header while
> dev->needed_headroom should be the *additional* headroom needed
> by hardware. That also means skb_push(dev->hard_header_len) is
> correct.
>
> Therefore, I think IP tunnel should set its dev->hard_header_len to
> lower_dev->hard_header_len + tunnel->hlen + sizeof(struct iphdr),
> and set its dev->needed_headroom to lower_dev->needed_headroom.
> See the attached patch for details.
>
> But gretap seems to be an exception, it calls ether_setup() to init its
> dev->hard_header_len to ETH_HLEN. My patch probably breaks it,
> I think it should set its tunnel->hlen = gre_hdr_len + ETH_HLEN.
>

When ip-tunnel was written I thought LL_RESERVED_SPACE() is used to
reserve header space. Obviously I missed tcf_mirred()
At this point I think easiest fix would be using LL_RESERVED_SPACE()
in tcf_mirred().
Later we can change ip-tunnel code to use hard_header and
needed_headroom as you have menioned.

Thanks,
Pravin.


> What do you think?
>
>
> Thanks.
