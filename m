From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net v2] mld, igmp: Fix reserved tailroom calculation
Date: Tue, 1 Mar 2016 17:00:33 +0100
Message-ID: <56D5BCA1.4050206@stressinduktion.org>
References: <56D48DCE.3090705@stressinduktion.org>
 <1456787013-3277-1-git-send-email-bpoirier@suse.com>
 <56D56C64.1030504@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: Daniel Borkmann <daniel@iogearbox.net>,
	Benjamin Poirier <bpoirier@suse.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:46497 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754759AbcCAQAg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 11:00:36 -0500
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id E428820FC3
	for <netdev@vger.kernel.org>; Tue,  1 Mar 2016 11:00:34 -0500 (EST)
In-Reply-To: <56D56C64.1030504@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01.03.2016 11:18, Daniel Borkmann wrote:
> On 03/01/2016 12:03 AM, Benjamin Poirier wrote:
> [...]
>> Notes:
>>      Changes v1->v2
>>      As suggested by Hannes, move the code to an inline helper and
>> express it
>>      using "if" rather than "min".
>
> The code is correct, thanks!
>
> Therefore:
>
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>
>
> However, I actually think that v1 was much better/easier as a fix
> though. :/
>
> Meaning 1) it's likely easier to backport, and 2) that we now need a
> comment
> above each skb->reserved_tailroom assignment probably says that min() might
> perhaps have been more self-documenting ...
>
> skb_tailroom_reserve() looks quite generic, but it only makes sense to
> use in
> combination with skb_availroom(), which would have been good to put a
> note to
> the header comment. Also "the required headroom should already have been
> reserved before using this function", places one more requirement for
> usage.
>
> If we really want to go that path, maybe rather a skb_setroom() that is
> coupled
> with skb_availroom() like:
>
> static inline int __skb_tailroom(const struct sk_buff *skb)
> {
>      return skb->end - skb->tail;
> }
>
> static inline void skb_setroom(struct sk_buff *skb,
>                                 unsigned int needed_headroom,
>                                 unsigned int size,
>                                 unsigned int needed_tailroom)
> {
>          SKB_LINEAR_ASSERT(skb);
>
>          skb_reserve(skb, needed_headroom);
>          skb->reserved_tailroom = needed_tailroom;
>
>          if (size < __skb_tailroom(skb) - needed_tailroom)
>                  skb->reserved_tailroom = __skb_tailroom(skb) - size;
> }
>
> Then, skb_tailroom() would internally use __skb_tailroom(), too. And we
> can also
> spare us the two unneeded skb_is_nonlinear() checks in our helper which
> will
> currently always evaluate to false anyway.
>
> ... just a thought.

I think it is fine. The code will be inlined anyway and probably skb 
linear assertions will be optimized away.

I like the current code in its form:

skb_reserve(skb, header);
skb_tailroom_reserve(skb, mtu, tailroom);

Combined form has too many arguments, so one has to look up the header 
file again.

Bye,
Hannes
