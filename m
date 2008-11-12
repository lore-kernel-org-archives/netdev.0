From: Jesper Dangaard Brouer <jdb@comx.dk>
Subject: Re: NIU driver: Sun x8 Express Quad Gigabit Ethernet Adapter
Date: Wed, 12 Nov 2008 13:49:39 +0100
Message-ID: <1226494179.6834.64.camel@localhost.localdomain>
References: <20081112.014923.68124784.davem@davemloft.net>
	 <1226487710.6834.53.camel@localhost.localdomain>
	 <20081112.035240.226243372.davem@davemloft.net>
	 <20081112.041143.11487260.davem@davemloft.net>
Reply-To: jdb@comx.dk
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:48811 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751899AbYKLMtu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2008 07:49:50 -0500
In-Reply-To: <20081112.041143.11487260.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-11-12 at 04:11 -0800, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Wed, 12 Nov 2008 03:52:40 -0800 (PST)
>
> These tests are still useful for me, so please perform them,

As a gratitude for your work and being allowed to operate your expresso
machine, I'll be happy to perform the tests even though the bug has been
found.

> but I think I've found the bug.

Yes! you have found the bug! :-)

(This is on the non SMP and non MSI kernel.  First test pktgen test says
I can route 319 kpps using a single CPU, promising as I got 160 kpps
using the Sun nxge driver)

Tested-by: Jesper Dangaard Brouer <jdb@comx.dk>

-- 
Med venlig hilsen / Best regards
  Jesper Brouer
  ComX Networks A/S
  Linux Network developer
  Cand. Scient Datalog / MSc.
  Author of http://adsl-optimizer.dk
  LinkedIn: http://www.linkedin.com/in/brouer

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
