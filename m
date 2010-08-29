From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: Re: [PATCH] starfire: use BUILD_BUG_ON for netdrv_addr_t
Date: Mon, 30 Aug 2010 07:59:38 +0900
Message-ID: <20100830075830R.fujita.tomonori@lab.ntt.co.jp>
References: <1282972125-9968-1-git-send-email-akinobu.mita@gmail.com>
	<20100828.154125.246523501.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akinobu.mita@gmail.com, netdev@vger.kernel.org, ionut@badula.org,
	fujita.tomonori@lab.ntt.co.jp, linux-arch@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sh.osrg.net ([192.16.179.4]:36953 "EHLO sh.osrg.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753357Ab0H2W74 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 29 Aug 2010 18:59:56 -0400
In-Reply-To: <20100828.154125.246523501.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CC'ed to linux-arch,

On Sat, 28 Aug 2010 15:41:25 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Akinobu Mita <akinobu.mita@gmail.com>
> Date: Sat, 28 Aug 2010 14:08:45 +0900
> 
> > Detect size mismatch for netdrv_addr_t at build time rather than
> > checking at module load time.
> > 
> > Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
> > Cc: Ion Badulescu <ionut@badula.org>
> > Cc: "David S. Miller" <davem@davemloft.net>
> > Cc: netdev@vger.kernel.org
> 
> Applied, but I suspect we will see some interesting build failures now
> if that ugly and brittle ifdef test which constrols the netdrv_addr_t
> define isn't %100 accurate.

Yeah, looks like you need to add another hack for powerpc?


> Fujita-san, what this driver does is actually pretty reasonable.  It
> has two kinds of descriptors, one supports 32-bit addresses and the
> other supports 64-bit addresses.  It wants to CPP test which one to
> use so that the driver is not burdoned with two duplicated sets of
> routines.
> 
> Maybe we should provide a DMA_ADDR_T_SIZE or similar macro?  What do
> you think?  Anything is better than what it uses now:

Introducing something like CONFIG_DMA_ADDR_T_64BIT works?

include/asm-generic/types.h has:

#ifndef dma_addr_t
#ifdef CONFIG_PHYS_ADDR_T_64BIT
typedef u64 dma_addr_t;
#else
typedef u32 dma_addr_t;
#endif /* CONFIG_PHYS_ADDR_T_64BIT */
#endif /* dma_addr_t */

But the above can't be perfect so about twenty architectures define
dma_addr_t. With CONFIG_DMA_ADDR_T_64BIT, we can clean up all the
mess nicely, I guess.


> /*
>  * This SUCKS.
>  * We need a much better method to determine if dma_addr_t is 64-bit.
>  */
> #if (defined(__i386__) && defined(CONFIG_HIGHMEM64G)) || defined(__x86_64__) || defined (__ia64__) || defined(__alpha__) || defined(__mips64__) || (defined(__mips__) && defined(CONFIG_HIGHMEM) && defined(CONFIG_64BIT_PHYS_ADDR))
