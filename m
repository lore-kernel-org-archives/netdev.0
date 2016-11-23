From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ipv6:ipv6_pinfo dereferenced after NULL check
Date: Wed, 23 Nov 2016 12:32:52 +0100
Message-ID: <b142a6be-ee2c-2564-6c38-6dfc5e8efce2@stressinduktion.org>
References: <1479796024-39418-1-git-send-email-manjeet.p@samsung.com>
 <CGME20161122122650epcas3p200ae9d4f95577997c98c37eb3e375ae8@epcas3p2.samsung.com>
 <20161123044535epcms5p37a2a3f2c2c071fdac1ddb6b1a6c02cf6@epcms5p3>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: PANKAJ MISHRA <pankaj.m@samsung.com>,
        Ajeet Kumar Yadav <ajeet.y@samsung.com>
To: r.thapliyal@samsung.com, Manjeet Pawar <manjeet.p@samsung.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "kuznet@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>,
        "jmorris@namei.org" <jmorris@namei.org>,
        "yoshfuji@linux-ipv6.org" <yoshfuji@linux-ipv6.org>,
        "kaber@trash.net" <kaber@trash.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:54097 "EHLO
        out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1756180AbcKWLc4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 06:32:56 -0500
In-Reply-To: <20161123044535epcms5p37a2a3f2c2c071fdac1ddb6b1a6c02cf6@epcms5p3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 23.11.2016 05:45, Rohit Thapliyal wrote:
> |>On 22.11.2016 07:27, Manjeet Pawar wrote:
>  >> From: Rohit Thapliyal <r.thapliyal@samsung.com <mailto:r.thapliyal@samsung.com>>
>  >>
>  >> np checked for NULL and then dereferenced. It should be modified
>  >> for NULL case.
>  >>
>  >> Signed-off-by: Rohit Thapliyal <r.thapliyal@samsung.com 
> <mailto:r.thapliyal@samsung.com>>>
>  >> Signed-off-by: Manjeet Pawar <manjeet.p@samsung.com 
> <mailto:manjeet.p@samsung.com>>>
>  >> ---
>  >>  net/ipv6/ip6_output.c | 9 +++++----
>  >>  1 file changed, 5 insertions(+), 4 deletions(-)
>  >>
>  >> diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
>  >> index 1dfc402..c2afa14 100644
>  >> --- a/net/ipv6/ip6_output.c
>  >> +++ b/net/ipv6/ip6_output.c
>  >> @@ -205,14 +205,15 @@ int ip6_xmit(const struct sock *sk, struct sk_buff 
> *skb, struct flowi6 *fl6,
>  >>   /*
>  >>    * Fill in the IPv6 header
>  >>    */
>  >> - if (np)
>  >> + if (np) {
>  >>    hlimit = np->hop_limit;
>  >> +  ip6_flow_hdr(
>  >> +     hdr, tclass, ip6_make_flowlabel(
>  >> +     net, skb, fl6->flowlabel,
>  >> +     np->autoflowlabel, fl6));
>  >> + }
>  >>   if (hlimit < 0)
>  >>    hlimit = ip6_dst_hoplimit(dst);
>  >>
>  >> - ip6_flow_hdr(hdr, tclass, ip6_make_flowlabel(net, skb, fl6->flowlabel,
>  >> -    np->autoflowlabel, fl6));
>  >> -
>  >>   hdr->payload_len = htons(seg_len);
>  >>   hdr->nexthdr = proto;
>  >>   hdr->hop_limit = hlimit;
>  >>
>  >
>  >
>  >We always should initialize hdr and not skip the ip6_flow_hdr call.|
> 
> |if np becomes NULL, then anyways hdr won't be initialized due to NULL pointer 
> dereference ip6_make_flowlabel.|

Which we would see as a crash. So far no crash has been reported in this
code. Doing a quick code review on the paths leading to ip6_xmit,
inet6_sk must always be set to actually reach up to this point.
Otherwise we would have crashes on all code paths much earler.

Anyway, I would be fine to keep the NULL check in this path, it looks
better because of the inet6_sk you pointed out above but I would
recommend to just use a "np ? np->autoflowlabel :
ip6_default_np_autolabel(net) in the ip6_flow_hdr function.

> |>Do you saw a bug or did you find this by code review? I wonder if np can
>  >actually be NULL at this point. Maybe we can just eliminate the NULL check.|
> 
> |
> 
> 
> I must admit that I found it just by code review, and so far didn't face any 
> crash whatsoever.
> As we can see in inet6_sk, np could be NULL. Thus, the NULL check seems justified.

Thanks for looking at this!

Bye,
Hannes
