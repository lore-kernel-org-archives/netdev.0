From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] eth: Declare an optimized compare_ether_addr_64bits()
 function
Date: Fri, 21 Nov 2008 23:22:32 -0800
Message-ID: <20081121232232.0c2454f2@extreme>
References: <4927B275.1030407@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:33395 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753102AbYKVHWg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Nov 2008 02:22:36 -0500
In-Reply-To: <4927B275.1030407@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 22 Nov 2008 08:19:17 +0100
Eric Dumazet <dada1@cosmosbay.com> wrote:

> Hello David, this is a resend of a patch previously sent in a 
> "tbench regression ..." thread on lkml
> 
> We should also address the problem of skb_pull(skb, ETH_HLEN);
> in eth_type_trans() :
> 
> Being not inlined, this force eth_type_trans() to be a non
> leaf function, that cost precious cpu cycles on many arches.
> 
> Thank you
> 
> [PATCH] eth: Declare an optimized compare_ether_addr_64bits() function
> 
> Linus mentioned we could try to perform long word operations, even
> on potentially unaligned addresses, on x86 at least.
> 
> I tried this idea and got nice assembly on 32 bits:
> 
> 158:   33 82 38 01 00 00       xor    0x138(%edx),%eax
> 15e:   33 8a 34 01 00 00       xor    0x134(%edx),%ecx
> 164:   c1 e0 10                shl    $0x10,%eax
> 167:   09 c1                   or     %eax,%ecx
> 169:   74 0b                   je     176 <eth_type_trans+0x87>
> 
> And very nice assembly on 64 bits of course (one xor, one shl)
> 
> Nice oprofile improvement in eth_type_trans(), 0.17 % instead of 0.41 %,
> expected since we remove 8 instructions on a fast path.
> 
> This patch implements a compare_ether_addr_64bits() function,
> that handles the case of x86 cpus, but might be used on other arches as well,
> if their potential misaligned long word reads are not expensive.
> 

Why invent another function? Why not just have compare_ether_addr() be
as optimized as possible, could even set it up to be overloadable by
asm code.
