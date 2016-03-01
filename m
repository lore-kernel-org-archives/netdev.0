From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net v2] mld, igmp: Fix reserved tailroom calculation
Date: Tue, 01 Mar 2016 11:18:12 +0100
Message-ID: <56D56C64.1030504@iogearbox.net>
References: <56D48DCE.3090705@stressinduktion.org> <1456787013-3277-1-git-send-email-bpoirier@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: Benjamin Poirier <bpoirier@suse.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:43467 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751881AbcCAKSR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 05:18:17 -0500
In-Reply-To: <1456787013-3277-1-git-send-email-bpoirier@suse.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/01/2016 12:03 AM, Benjamin Poirier wrote:
[...]
> Notes:
>      Changes v1->v2
>      As suggested by Hannes, move the code to an inline helper and express it
>      using "if" rather than "min".

The code is correct, thanks!

Therefore:

Acked-by: Daniel Borkmann <daniel@iogearbox.net>

However, I actually think that v1 was much better/easier as a fix though. :/

Meaning 1) it's likely easier to backport, and 2) that we now need a comment
above each skb->reserved_tailroom assignment probably says that min() might
perhaps have been more self-documenting ...

skb_tailroom_reserve() looks quite generic, but it only makes sense to use in
combination with skb_availroom(), which would have been good to put a note to
the header comment. Also "the required headroom should already have been
reserved before using this function", places one more requirement for usage.

If we really want to go that path, maybe rather a skb_setroom() that is coupled
with skb_availroom() like:

static inline int __skb_tailroom(const struct sk_buff *skb)
{
	return skb->end - skb->tail;
}

static inline void skb_setroom(struct sk_buff *skb,
                                unsigned int needed_headroom,
                                unsigned int size,
                                unsigned int needed_tailroom)
{
         SKB_LINEAR_ASSERT(skb);

         skb_reserve(skb, needed_headroom);
         skb->reserved_tailroom = needed_tailroom;

         if (size < __skb_tailroom(skb) - needed_tailroom)
                 skb->reserved_tailroom = __skb_tailroom(skb) - size;
}

Then, skb_tailroom() would internally use __skb_tailroom(), too. And we can also
spare us the two unneeded skb_is_nonlinear() checks in our helper which will
currently always evaluate to false anyway.

... just a thought.

Thanks again,
Daniel
