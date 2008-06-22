From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RESEND] [PATCH] tcp: fix for splice receive when used with
	software LRO
Date: Sun, 22 Jun 2008 23:07:47 +0200
Message-ID: <20080622210747.GA17472@ami.dom.local>
References: <485B4ADE.8070102@domat.com.pl> <200806201539.24421.opurdila@ixiacom.com> <20080620130129.GA4417@ff.dom.local> <200806202344.12771.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.233]:62088 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755668AbYFVVHr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jun 2008 17:07:47 -0400
Received: by wr-out-0506.google.com with SMTP id 69so1592944wri.5
        for <netdev@vger.kernel.org>; Sun, 22 Jun 2008 14:07:44 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <200806202344.12771.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 20, 2008 at 11:44:12PM +0300, Octavian Purdila wrote:
...
> OK, here is my attempt at making it a bit more readable:
> 
> - move all of the details on offsets, lengths and buffers into a 
> single function instead of doing these operation from multiple places
> 
> - use a bottom up approach - try to avoid details in the high level functions, 
> introduce them gradually as you go deeper in the function call stack
> 
> I've attached both the patch and a full excerpt - it might be easier to 
> comment on it  this way.
> 
> I've minimally tested the patch, no obvious functional or performance problems 
> were found.

IMHO it's really more readable, and probably should be sometimes faster
if these divisions are optimized by a compiler. So, since the work is
done anyway, you could try to submit this - you got nothing to lose.
But, I think it's better to separate the change of functionality (a
recursive processing of frag_list) to another patch (if there is a
practical reason for this).

A few of my doubts below as //?? comments.

Regards,
Jarek P.


static inline void __segment_seek(struct page **page, int *poff, int *plen,
				  int off)

//?? unsigned ints (especially *poff for "/,%" optimization)?

{
	*poff += off;
	*page += *poff / PAGE_SIZE;
	*poff = *poff % PAGE_SIZE;
	*plen -= off;
}

static inline int __splice_segment(struct page *page, unsigned int poff,
				   unsigned int plen, unsigned int *off,
				   unsigned int *len, struct sk_buff *skb,
				   struct splice_pipe_desc *spd)
{
//??	if (!*len)
//??		return 1;

	/* skip this segment if already processed */
	if (*off >= plen) {
		*off -= plen;
		return 0;
	}

	/* ignore any bits we already processed */
	if (*off) {
		__segment_seek(&page, &poff, &plen, *off);
		*off = 0;
	}

	do {
		unsigned int flen = min(*len, plen);

//?? needed for a linear region?:
//??		flen = min_t(unsigned int, flen, PAGE_SIZE - poff);

		if (spd_fill_page(spd, page, flen, poff, skb))
			return 1;

		__segment_seek(&page, &poff, &plen, flen);
		*len -= flen;

	} while (*len && plen);

	return 0;
}

//?? The original comment with fixed "Returns..." (unless changed to void)?

int __skb_splice_bits(struct sk_buff *skb, unsigned int *offset,
			     unsigned int *len,
			     struct splice_pipe_desc *spd)
{
	int seg;


	/*
	 * map the linear part
	 */
	if (__splice_segment(virt_to_page(skb->data),
			     (unsigned long) skb->data & (PAGE_SIZE - 1),
			     skb_headlen(skb),
			     offset, len, skb, spd))
		return 1;

	/*
	 * then map the fragments
	 */
	for (seg = 0; seg < skb_shinfo(skb)->nr_frags; seg++) {
		const skb_frag_t *f = &skb_shinfo(skb)->frags[seg];

		if (__splice_segment(f->page, f->page_offset, f->size,
				     offset, len, skb, spd))
			return 1;
	}

//?? I'm not sure this recursion is really needed here, so I'd prefer
//?? to move this back to skb_splice_bits() for now, and maybe to
//?? propose this change as a separate patch giving the reasons for this.
	/*
	 * now see if we have a frag_list to map
	 */
	if (skb_shinfo(skb)->frag_list) {
		struct sk_buff *list = skb_shinfo(skb)->frag_list;

		for (; list && *len; list = list->next)
			if (__skb_splice_bits(list, offset, len, spd))
				return 1;
	}

	return 0;
}
...
