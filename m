From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] flow-dissector: Fix alignment issue in
 __skb_flow_get_ports
Date: Fri, 10 Oct 2014 00:47:08 -0400 (EDT)
Message-ID: <20141010.004708.1975127853551765914.davem@davemloft.net>
References: <20141009.201248.1210454965155680255.davem@davemloft.net>
	<20141010035840.21428.359.stgit@ahduyck-workstation.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45595 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750758AbaJJErJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2014 00:47:09 -0400
In-Reply-To: <20141010035840.21428.359.stgit@ahduyck-workstation.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: alexander.duyck@gmail.com
Date: Thu, 09 Oct 2014 21:03:28 -0700

> From: Alexander Duyck <alexander.h.duyck@redhat.com>
> 
> This patch addresses a kernel unaligned access bug seen on a sparc64 system
> with an igb adapter.  Specifically the __skb_flow_get_ports was returning a
> be32 pointer which was then having the value directly returned.
> 
> In order to keep the handling of the ports consistent with how we were
> handling the IPv4 and IPv6 addresses I have instead replaced the assignment
> with a memcpy to the flow key ports value.  This way it should stay a
> memcpy on systems that cannot handle unaligned access, and will likely be
> converted to a 32b assignment on the systems that can support it.
> 
> Reported-by: David S. Miller <davem@davemloft.net>
> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>

Guess what the compiler will output for the memcpy()....

	*(u32 *)dest = *(u32 *)src;

Using memcpy() is never a valid way to avoid misaligned loads and
stores.

If the types have a given alignment, the compiler can legitimately
expand the memcpy() inline with suitably sized loads and stores.

Please see my other reply in the original thread, we have to use
the hardware when we can to manage this situation, by configuring
it to output two garbage bytes before the packet contents when
DMA'ing into power-of-2 aligned blocks of memory.

Thanks.
