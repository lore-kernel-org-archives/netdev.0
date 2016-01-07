From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] bpf: add skb_postpush_rcsum and fix dev_forward_skb
 occasions
Date: Thu, 07 Jan 2016 11:02:11 +0100
Message-ID: <568E37A3.5070104@iogearbox.net>
References: <02f04a0cd04748df932912bac36afeccc4ee7755.1452125392.git.daniel@iogearbox.net> <568DC506.6020200@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:45975 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752935AbcAGKCP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 05:02:15 -0500
In-Reply-To: <568DC506.6020200@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/07/2016 02:53 AM, Hannes Frederic Sowa wrote:
> On 07.01.2016 02:01, Daniel Borkmann wrote:
>> +static inline void skb_postpush_rcsum(struct sk_buff *skb,
>> +                      const void *start, unsigned int len)
>> +{
>> +    if (skb->ip_summed == CHECKSUM_COMPLETE)
>> +        skb->csum = csum_add(skb->csum, csum_partial(start, len, 0));
>
> skb->csum = csum_partial(start, len, skb->csum);
>
> should work without calling carry-add twice, no?

Hmm, indeed, seems you're right. Since the csum_partial() only covers
this particular fragment with feeding initial csum as 0, the result
from the do_csum() stays as is for the first part, and the csum_add()
does effectively the same as if we've fed skb->csum already into
csum_partial().

There are btw couple of other places where this generic helper could be
used as well.
