From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH] mld, igmp: Fix reserved tailroom calculation
Date: Mon, 29 Feb 2016 16:38:30 +0100
Message-ID: <56D465F6.3020802@iogearbox.net>
References: <1456603028-12589-2-git-send-email-bpoirier@suse.com> <56D45C6A.5040606@iogearbox.net> <20160229151920.GA5474@f1.synalogic.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: Benjamin Poirier <bpoirier@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:60084 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750843AbcB2Pie (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Feb 2016 10:38:34 -0500
In-Reply-To: <20160229151920.GA5474@f1.synalogic.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/29/2016 04:19 PM, Benjamin Poirier wrote:
> On 2016/02/29 15:57, Daniel Borkmann wrote:
> [...]
>>
>> [ cutting the IPv4 part off as diff is the same ]
>>
>>> diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
>>> index 5ee56d0..c157edc 100644
>>> --- a/net/ipv6/mcast.c
>>> +++ b/net/ipv6/mcast.c
>>> @@ -1574,9 +1574,9 @@ static struct sk_buff *mld_newpack(struct inet6_dev *idev, unsigned int mtu)
>>>   		return NULL;
>>>
>>>   	skb->priority = TC_PRIO_CONTROL;
>>> -	skb->reserved_tailroom = skb_end_offset(skb) -
>>> -				 min(mtu, skb_end_offset(skb));
>>>   	skb_reserve(skb, hlen);
>>> +	skb->reserved_tailroom = skb_tailroom(skb) -
>>> +		min_t(int, mtu, skb_tailroom(skb) - tlen);
>>
>> Are you sure this is correct? Wouldn't that mean (assuming we allocated
>> enough space), that I could now fill a larger than MTU frame?
>
> Quoting back a part of the log:
>
>>> The maximum space available for ip headers and payload without
>>> fragmentation is min(mtu, data + extra). Therefore,
>>> reserved_tailroom
>>> = data + extra + tlen - min(mtu, data + extra)
>>> = skb_end_offset - hlen - min(mtu, skb_end_offset - hlen - tlen)
>>> = skb_tailroom - min(mtu, skb_tailroom - tlen) ; after skb_reserve(hlen)
>
> The min() takes care of the situation you describe, ie. if the allocated
> space is large, reserved_tailroom will be large enough that we do not
> use more space than the mtu.

Hmm, sorry, you are right, I had a bug in my thought process wrt the
skb_reserve() that is now done first.

Code is fine, patch would be against -net tree:

Acked-by: Daniel Borkmann <daniel@iogearbox.net>

Thanks, Benjamin!
