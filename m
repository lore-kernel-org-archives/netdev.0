From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] netlink: rx mmap: fix POLLIN condition
Date: Tue, 25 Aug 2015 20:17:12 -0700 (PDT)
Message-ID: <20150825.201712.2151042716686513603.davem@davemloft.net>
References: <55CDBC84.8020605@iogearbox.net>
	<55CDC51D.1060204@iogearbox.net>
	<20150820055447.GA2656@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net, fw@strlen.de
To: chamaken@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32936 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750920AbbHZDRQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 23:17:16 -0400
In-Reply-To: <20150820055447.GA2656@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ken-ichirou MATSUZAWA <chamaken@gmail.com>
Date: Thu, 20 Aug 2015 14:54:47 +0900

> Now poll() returns immediately after setting kernel current frame
> (ring->head) to SKIP from user space even if there are no new
> frames. And in a case of all frames is VALID, user space program
> unintensionally sets (only) kernel current frame to UNUSED, then
> calls poll(), it will not return immediately even though there are
> VALID frames.
> 
> To avoid situations like above, I think we need to scan all frames
> to find a VALID frame at poll() like netlink_alloc_skb(),
> netlink_forward_ring() finding an UNUSED frame at skb allocation.
> 
> Signed-off-by: Ken-ichirou MATSUZAWA <chamas@h4.dion.ne.jp>

There seems to be a few issues here.

Taking a look at netlink_forward_ring(), it appears buggy.

	static void netlink_forward_ring(struct netlink_ring *ring)
	{
		unsigned int head = ring->head, pos = head;
		const struct nl_mmap_hdr *hdr;

		do {
			hdr = __netlink_lookup_frame(ring, pos);
			if (hdr->nm_status == NL_MMAP_STATUS_UNUSED)
				break;
			if (hdr->nm_status != NL_MMAP_STATUS_SKIP)
				break;
			netlink_increment_head(ring);
		} while (ring->head != head);
	}

No matter what any of this code does, __netlink_lookup_frame() is always
called with the same "pos" value.

So, as far as I can tell, it will look at the same ring entry header over
and over again, every time through this loop.

netlink_increment_head() changes ring->head, but this has no influence
upon the calculations made inside of __netlink_lookup_frame().

So if netlink_forward_ring() _actually_ sees an entry that we should
advance past, it will cycle through the whole ring, advancing ring->head
until it equals the "ring->head != head" loop test fails.

We should definitely fix this bug first.

As per your patch, I wonder if a backwards scan would be faster.
