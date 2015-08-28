From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: Check frag_lists first to prevent data
 out of order
Date: Thu, 27 Aug 2015 21:37:11 -0700
Message-ID: <1440736631.8932.43.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1440636965-11552-1-git-send-email-chenweilong@huawei.com>
	 <1440641561.8932.36.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1440642184.8932.37.camel@edumazet-glaptop2.roam.corp.google.com>
	 <55DFD70C.2030001@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, edumazet@google.com,
	alexander.h.duyck@redhat.com, willemb@google.com,
	hannes@stressinduktion.org, netdev@vger.kernel.org
To: Weilong Chen <chenweilong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:35210 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750896AbbH1EhO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2015 00:37:14 -0400
Received: by pacdd16 with SMTP id dd16so48893542pac.2
        for <netdev@vger.kernel.org>; Thu, 27 Aug 2015 21:37:13 -0700 (PDT)
In-Reply-To: <55DFD70C.2030001@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-08-28 at 11:35 +0800, Weilong Chen wrote:
> Thanks for reply.
> 
> > On Wed, 2015-08-26 at 19:12 -0700, Eric Dumazet wrote:
> >> On Thu, 2015-08-27 at 08:56 +0800, chenweilong@huawei.com wrote:
> >>> From: Weilong Chen <chenweilong@huawei.com>
> >>>
> >>> When try to merge several skbs to prior one, if the frag_list is
> >>> used and the the last one is a small packet, once the condition
> >>> "len <= skb_tailroom(to)" is satisfied, we will get a wrong
> >>> packet!
> >>> This patch just check frag_lists before the condtion to prevent
> >>> this from happening.
> >>>
> >>> Signed-off-by: Weilong Chen <chenweilong@huawei.com>
> >>> ---
> >>>   net/core/skbuff.c | 6 +++---
> >>>   1 file changed, 3 insertions(+), 3 deletions(-)
> >>>
> >>> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> >>> index 8a725cc..d08edcb 100644
> >>> --- a/net/core/skbuff.c
> >>> +++ b/net/core/skbuff.c
> >>> @@ -4133,6 +4133,9 @@ bool skb_try_coalesce(struct sk_buff *to, struct sk_buff *from,
> >>>   	if (skb_cloned(to))
> >>>   		return false;
> >>>
> >>> +	if (skb_has_frag_list(to) || skb_has_frag_list(from))
> >>> +		return false;
> >>> +
> >>>   	if (len <= skb_tailroom(to)) {
> >>>   		if (len)
> >>>   			BUG_ON(skb_copy_bits(from, 0, skb_put(to, len), len));
> >>> @@ -4140,9 +4143,6 @@ bool skb_try_coalesce(struct sk_buff *to, struct sk_buff *from,
> >>>   		return true;
> >>>   	}
> >>>
> >>> -	if (skb_has_frag_list(to) || skb_has_frag_list(from))
> >>> -		return false;
> >>> -
> >>>   	if (skb_headlen(from) != 0) {
> >>>   		struct page *page;
> >>>   		unsigned int offset;
> >>
> >> Sigh.
> >>
> >> No idea what problem you tried to solve.
> >>
> >> This patch is not needed.
> >>
> >> If (len <= skb_tailroom()), then it is obviously correct to copy_bits()
> >> the bytes.
> >>
> >> Hints :
> >>
> >> - If @to has a fraglist, then skb_tailroom(to) is 0 so the copy can not
> >> be done.
> 
> How to make sure it?
> In my test, @to has a fraglist, but skb_tailroom(to) is not 0!
> The test is about tipc, the function tipc_buf_append will merge 3 skbs 
> to one:
> packet 1: len = 1420 skb_tailroom = 190
> packet 2: len = 1420
> 	packet 2 will be add to 1' fraglist, but not update skb_tailroom
> packet 3: len = 60
> 	Here's the error!

Then fix tipc, or make sure you read and understood the code.

By definition, if one skb has something in fraglist, it is non linear.

If you read skb_tailroom(), you'll see this function returns 0 if skb is
non linear.

include/linux/skbuff.h-/**
include/linux/skbuff.h: *       skb_tailroom - bytes at buffer end
include/linux/skbuff.h- *       @skb: buffer to check
include/linux/skbuff.h- *
include/linux/skbuff.h- *       Return the number of bytes of free space at the tail of an sk_buff
include/linux/skbuff.h- */
include/linux/skbuff.h:static inline int skb_tailroom(const struct sk_buff *skb)
include/linux/skbuff.h-{
include/linux/skbuff.h- return skb_is_nonlinear(skb) ? 0 : skb->end - skb->tail;
include/linux/skbuff.h-}
