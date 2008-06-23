From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [RESEND] [PATCH] tcp: fix for splice receive when used with software LRO
Date: Mon, 23 Jun 2008 12:50:30 +0300
Message-ID: <200806231250.31087.opurdila@ixiacom.com>
References: <485B4ADE.8070102@domat.com.pl> <200806202344.12771.opurdila@ixiacom.com> <20080622210747.GA17472@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:1851 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751274AbYFWJwL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2008 05:52:11 -0400
In-Reply-To: <20080622210747.GA17472@ami.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 23 June 2008, Jarek Poplawski wrote:
>
> IMHO it's really more readable, and probably should be sometimes faster
> if these divisions are optimized by a compiler. So, since the work is
> done anyway, you could try to submit this - you got nothing to lose.

Cool, thanks for reviewing it.

> But, I think it's better to separate the change of functionality (a
> recursive processing of frag_list) to another patch (if there is a
> practical reason for this).
>

Yes, it makes sense, I'll remove the recursion from this patch. 

About the recursion: don't know if it makes a difference from a functional 
perspective (I don't think that we can have frag_lists in frag_lists), but 
I've noticed that skb_copy_bits does recurse. Any idea why?


> static inline void __segment_seek(struct page **page, int *poff, int *plen,
> 				  int off)
>
> //?? unsigned ints (especially *poff for "/,%" optimization)?

Ack, will fix.


> static inline int __splice_segment(struct page *page, unsigned int poff,
> 				   unsigned int plen, unsigned int *off,
> 				   unsigned int *len, struct sk_buff *skb,
> 				   struct splice_pipe_desc *spd)
> {
> //??	if (!*len)
> //??		return 1;

Ack, will fix.

> 	/* skip this segment if already processed */
> 	if (*off >= plen) {
> 		*off -= plen;
> 		return 0;
> 	}
>
> 	/* ignore any bits we already processed */
> 	if (*off) {
> 		__segment_seek(&page, &poff, &plen, *off);
> 		*off = 0;
> 	}
>
> 	do {
> 		unsigned int flen = min(*len, plen);
>
> //?? needed for a linear region?:
> //??		flen = min_t(unsigned int, flen, PAGE_SIZE - poff);
>

Oops, missed that, thanks for catching it.

>
> //?? The original comment with fixed "Returns..." (unless changed to void)?
>

Will add the comment back, since removing the recursions will make it correct 
again and will need the return type to decide if we go into the frag list or 
not, up in skb_splice_bits.

>
> //?? I'm not sure this recursion is really needed here, so I'd prefer
> //?? to move this back to skb_splice_bits() for now, and maybe to
> //?? propose this change as a separate patch giving the reasons for this.

Ack.

Thanks,
tavi


