From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: af_packet.c flush_dcache_page
Date: Thu, 1 Nov 2007 19:27:57 +0300
Message-ID: <20071101162757.GA18124@2ka.mipt.ru>
References: <47288C42.5010603@trash.net> <20071031.155749.26538335.davem@davemloft.net> <4729FA78.5040702@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:57284 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751540AbXKAQ1o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Nov 2007 12:27:44 -0400
Content-Disposition: inline
In-Reply-To: <4729FA78.5040702@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 01, 2007 at 05:10:32PM +0100, Patrick McHardy (kaber@trash.net) wrote:
> David Miller wrote:
> >Instead of answering your questions, I'm going to show you
> >how to avoid having to do any of this cache flushing crap :-)
> >
> >You can avoid having to flush anything as long as the virtual
> >addresses on the kernel side are modulo SHMLBA the virtual addresses
> >on the userland side.
> >
> >We have some (decidedly awkward) mechanisms to try and achieve
> >this in the kernel, but they are cumbersome and not air tight.
> >
> >Instead, I would recommend simply that you access the ring
> >buffer directly in userspace.  This avoids all of the cache
> >aliasing issues.
> >
> >Yes, this means you have to do the ring buffer accesses in
> >the context of the user, but it simplifies so much that I think
> >it'd be worth it.
> 
> 
> I'm probably misunderstanding your suggestion because of my
> limited mm knowledge, are you suggesting to do something like
> this:
> 
> setsockopt(RX_RING, ...):
> 
> Allocate ring using get_user_pages, return address to user
> 
> tpacket_rcv/netlink_unicast/netlink_broadcast:
> 
> for each receiver:
> 	switch_mm(...)
> 	copy data to ring
> 
> switch_mm(original mm)
> 
> Would this work in softirq context?

IIRC it requires disabled interrupts.

Probably David suggests to provide a pointer to allocated
in userspace buffer and use copy_to_user() and friends.

> >Another option is to use the "copy_to_user_page()" and
> >"copy_from_user_page()" interfaces which will do all of
> >the necessary cache flushing for you.
> >
> >Actually it might be nice to convert AF_PACKET's mmap() code
> >over to using those things.
> 
> 
> That would also require to do the copy in the context of
> the user, right?

Most of the time it is possible to call copy_to_user() in atomic
context, but it can fail, in which case some additional mechanism to
make a copy should be invented (workqueue, kthread, whatever you like :)

-- 
	Evgeniy Polyakov
