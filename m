From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: Moving frags and SKBTX_DEV_ZEROCOPY skbs
Date: Wed, 14 May 2014 20:41:53 +0100
Message-ID: <5373C701.1080301@citrix.com>
References: <53737266.5040601@citrix.com> <1400077432.7973.85.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	"xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>,
	<kvm@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:25381 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750750AbaENTl5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 May 2014 15:41:57 -0400
In-Reply-To: <1400077432.7973.85.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14/05/14 15:23, Eric Dumazet wrote:
> On Wed, 2014-05-14 at 14:40 +0100, Zoltan Kiss wrote:
>> Hi,
>>
>> Recently I've investigated issues around SKBTX_DEV_ZEROCOPY skbs where
>> the frags list were modified. I came across this function skb_shift(),
>> which moves frags between skbs. And there are a lot more of such kind,
>> skb_split or skb_try_coalesce, for example.
>> It could be a dangerous thing if a frag is referenced from an skb which
>> doesn't have the original destructor_arg, and to avoid that
>> skb_orphan_frags should be called. Although probably these functions are
>> not normally touched in usual usecases, I think it would be useful to
>> review core skb functions proactively and add an skb_orphan_frags
>> everywhere where the frags could be referenced from other places.
>> Any opinion about this?
>
>
> For skb_shift(), it is currently used from tcp stack only, where
> this SKBTX_DEV_ZEROCOPY thing is not used, so I do not think there is a
> bug for the moment.
It is called from tcp_input.c, which suggests it can be called on 
incoming TCP packets. If the backend domain communicates with the 
frontend through sockets, zerocopy packets can turn up here.
But here is the thing: deliver_skb calls orphan_frags for every packet 
delivered to the local stack, so we are safe IF these functions are 
called before the IP stack. So we are safe now, but things can go wrong, if:
- such a frag-mangling function is called before deliver_skb, now or in 
the future
- if someone wants to take advantage of zerocopy in the guest<->backend path

>
> I already gave a patch for skb_try_coalesce() : For this one we do not
> wan skb_orphan_frags() overhead. Its simply better in this case to
> abort.
>
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 1b62343f5837..85995a14aafc 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -3838,7 +3839,10 @@ bool skb_try_coalesce(struct sk_buff *to, struct sk_buff *from,
>   		return true;
>   	}
>
> -	if (skb_has_frag_list(to) || skb_has_frag_list(from))
> +	if (skb_has_frag_list(to) ||
> +	    skb_has_frag_list(from) ||
> +	    (skb_shinfo(to)->tx_flags & SKBTX_DEV_ZEROCOPY) ||
> +	    (skb_shinfo(from)->tx_flags & SKBTX_DEV_ZEROCOPY))
>   		return false;
>
>   	if (skb_headlen(from) != 0) {
>
>
>
