From: David Miller <davem@davemloft.net>
Subject: Re: Buglet in net/pkt_cls.h pointer handling.
Date: Tue, 21 Dec 2010 12:57:43 -0800 (PST)
Message-ID: <20101221.125743.115954170.davem@davemloft.net>
References: <20101216215627.43f34977.suckfish@ihug.co.nz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: suckfish@ihug.co.nz
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54293
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751280Ab0LUU5O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Dec 2010 15:57:14 -0500
In-Reply-To: <20101216215627.43f34977.suckfish@ihug.co.nz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ralph Loader <suckfish@ihug.co.nz>
Date: Thu, 16 Dec 2010 21:56:27 +1300

> tcf_valid_offset() in net/pkt_cls.h appears to have a couple of 
> problems (obvious patch below):
> 
> (a) there is no check for overflow in the pointer arithmetic.
> (b) the pointers are presumably likely to be normally valid, so the
>     hint should be 'likely()' not 'unlikely()'.
> 
> The offsets used to construct the arguments to that function, e.g., as
> called in net/sched/em_u32.c, I think come from user-space & in theory
> could be crafted to cause an invalid pointer deref if ptr+len overflows?
> 
> Possibly the '<' and '>' in that function should be '<=' and '>='
> also.  I'm not familiar enough with the data-structures to be sure.
> 
> Also a question:  in em_u32.c em_u32_match(), and in cls_u32.c
> u32_classify(), we dereference pointers that have had an offset
> (originally from user space) added to them.  I can't see anything that
> keeps those pointers aligned.  Is that a problem on architectures that
> don't support unaligned pointers, or am I missing something?

Your analysis is accurate, so I added the <= and >= test changes
and applied the following to the tree.

Please read Documentation/SubmittingPatches and
Documentation/email-clients.txt before submitting your
own patches in the future.

What you sent here was whitespace damaged by your email client
and you didn't provide a proper "Signed-off-by: " tag in your
commit message.

Thanks.

--------------------
net: Fix range checks in tcf_valid_offset().

This function has three bugs:

1) The offset should be valid most of the time, this is just
   a sanity check, therefore we should use "likely" not "unlikely"

2) This is the only place where we can check for arithmetic overflow
   of the pointer plus the length.

3) The existing range checks are off by one, the valid range is
   skb->head to skb_tail_pointer(), inclusive.

Based almost entirely upon a patch by Ralph Loader.

Reported-by: Ralph Loader <suckfish@ihug.co.nz>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/pkt_cls.h |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index dd3031a..9fcc680 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -323,7 +323,9 @@ static inline unsigned char * tcf_get_base_ptr(struct sk_buff *skb, int layer)
 static inline int tcf_valid_offset(const struct sk_buff *skb,
 				   const unsigned char *ptr, const int len)
 {
-	return unlikely((ptr + len) < skb_tail_pointer(skb) && ptr > skb->head);
+	return likely((ptr + len) <= skb_tail_pointer(skb) &&
+		      ptr >= skb->head &&
+		      (ptr <= (ptr + len)));
 }
 
 #ifdef CONFIG_NET_CLS_IND
-- 
1.7.3.4

