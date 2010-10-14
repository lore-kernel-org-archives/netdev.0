From: David Miller <davem@davemloft.net>
Subject: Re: ixgbe: normalize frag_list usage
Date: Wed, 13 Oct 2010 19:17:02 -0700 (PDT)
Message-ID: <20101013.191702.71129064.davem@davemloft.net>
References: <80769D7B14936844A23C0C43D9FBCF0F25B97A24B5@orsmsx501.amr.corp.intel.com>
	<20101006.235837.241424681.davem@davemloft.net>
	<4CAE2692.8020401@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, netdev@vger.kernel.org
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34821
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754157Ab0JNCQk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Oct 2010 22:16:40 -0400
In-Reply-To: <4CAE2692.8020401@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Thu, 07 Oct 2010 12:59:14 -0700

> I can track it in the RSC_CB if that works for you.  Right now though
> I guess I am not seeing the difference between tracking this in
> skb->frag_next vs IXGBE_RSC_CB(skb)->frag_head.  I think it might help
> if you were to provide some functions that demonstrate exactly what
> you had in mind for frag list handling.  Specifically if you were to
> add a function for merging a frag into the frag list, and for how you
> want to approach cleaning up the skb->prev/frag_tail_tracker pointer
> when you are cleaning up an active frag_list.

Basically the one helper function will look like this.

static inline void skb_frag_list_add(struct sk_buff *head,
				     struct sk_buff *new)
{
	if (!skb_shinfo(skb)->frag_list) {
		skb_shinfo(skb)->frag_list = new;
		skb->frag_list_tail = new;
	} else {
		skb->frag_list_tail->frag_list_next = new;
		skb->frag_list_tail = new;
	}
}

If you have to track the head from the tail packets, please do
so in a private control block.
