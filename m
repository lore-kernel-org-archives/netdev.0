From: Patrick McHardy <kaber@trash.net>
Subject: Re: af_packet.c flush_dcache_page
Date: Thu, 01 Nov 2007 17:10:32 +0100
Message-ID: <4729FA78.5040702@trash.net>
References: <47288C42.5010603@trash.net> <20071031.155749.26538335.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56191 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751219AbXKAQNf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Nov 2007 12:13:35 -0400
In-Reply-To: <20071031.155749.26538335.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> Instead of answering your questions, I'm going to show you
> how to avoid having to do any of this cache flushing crap :-)
> 
> You can avoid having to flush anything as long as the virtual
> addresses on the kernel side are modulo SHMLBA the virtual addresses
> on the userland side.
> 
> We have some (decidedly awkward) mechanisms to try and achieve
> this in the kernel, but they are cumbersome and not air tight.
> 
> Instead, I would recommend simply that you access the ring
> buffer directly in userspace.  This avoids all of the cache
> aliasing issues.
> 
> Yes, this means you have to do the ring buffer accesses in
> the context of the user, but it simplifies so much that I think
> it'd be worth it.


I'm probably misunderstanding your suggestion because of my
limited mm knowledge, are you suggesting to do something like
this:

setsockopt(RX_RING, ...):

Allocate ring using get_user_pages, return address to user

tpacket_rcv/netlink_unicast/netlink_broadcast:

for each receiver:
	switch_mm(...)
	copy data to ring

switch_mm(original mm)

Would this work in softirq context?

> Another option is to use the "copy_to_user_page()" and
> "copy_from_user_page()" interfaces which will do all of
> the necessary cache flushing for you.
> 
> Actually it might be nice to convert AF_PACKET's mmap() code
> over to using those things.


That would also require to do the copy in the context of
the user, right?
