From: Jesper Krogh <jesper@krogh.cc>
Subject: Re: NIU driver: Sun x8 Express Quad Gigabit Ethernet Adapter
Date: Wed, 12 Nov 2008 18:56:48 +0100
Message-ID: <491B18E0.7040502@krogh.cc>
References: <20081112.014923.68124784.davem@davemloft.net>	<1226487710.6834.53.camel@localhost.localdomain>	<20081112.035240.226243372.davem@davemloft.net> <20081112.041143.11487260.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jdb@comx.dk, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 2605ds1-ynoe.1.fullrate.dk ([90.184.12.24]:40279 "EHLO
	shrek.krogh.cc" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751763AbYKLR45 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Nov 2008 12:56:57 -0500
In-Reply-To: <20081112.041143.11487260.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> I am guessing you're running a 32-bit x86 kernel.
> 
> In such a case the driver has to define a local readq()
> and writeq() implementation.
> 
> What I provide for NIU right now reads the upper 32-bits
> then the lower 32-bits of the register.
> 
> Guess what that does?  The packet counters live in the upper
> 32-bits and the MARK bits live in the lower 32-bits of the
> TX_CS register.
> 
> So it first reads the packet counters, and as a side effect that
> clears the MARK bits in the TX_CS register.  So when we read the lower
> 32-bits the MARK bits are always seen as zero.
> 
> BzzaaarT!
> 
> So the following patch should fix this bug.  writeq() should
> be OK as-is, so doesn't need a similar change.
> 
> diff --git a/drivers/net/niu.c b/drivers/net/niu.c
> index 9acb5d7..d8463b1 100644
> --- a/drivers/net/niu.c
> +++ b/drivers/net/niu.c
> @@ -51,8 +51,7 @@ MODULE_VERSION(DRV_MODULE_VERSION);
>  #ifndef readq
>  static u64 readq(void __iomem *reg)
>  {
> -	return (((u64)readl(reg + 0x4UL) << 32) |
> -		(u64)readl(reg));
> +	return ((u64) readl(reg)) | (((u64) readl(reg + 4UL)) << 32);
>  }
>  
>  static void writeq(u64 val, void __iomem *reg)

On my system, I'm not in a position where I can just pull down the 
server and test, but if the above seems plausible that it is the same 
bug I hit using the 10GBitE card, then I'll definately try to test it out.

I sort-of reliably hit the problem after a few day of production on a 16 
core, amd64 system running NFS-server.

Does it seem likely to be the same problem?

Thanks
-- 
Jesper Krogh
