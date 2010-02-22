From: David Miller <davem@davemloft.net>
Subject: Re: NETIF_F_HIGHDMA misuse in networking drivers?
Date: Mon, 22 Feb 2010 15:53:57 -0800 (PST)
Message-ID: <20100222.155357.235673585.davem@davemloft.net>
References: <4B8029FA.2000404@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: hancockrwd@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4B8029FA.2000404@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Robert Hancock <hancockrwd@gmail.com>
Date: Sat, 20 Feb 2010 12:29:14 -0600

> Was just part of a discussion in another thread talking about 64-bit
> DMA support issues where NETIF_F_HIGHDMA came up. I was originally
> under the impression that this flag indicated the device supported
> 64-bit DMA addressing. However, from looking at the code that checks
> for it (and, well, the actual comment for the flag) it really means
> "can access highmem" which has nothing to do with 64-bit at all. And
> if there's no highmem (like on x86_64) it has no effect at all.

I think it's trying to do two things, and doing only one of them
well :-)

It's trying to keep drivers from receiving highmem pages if they are
not able to access them properly.  F.e. imagine a driver that copies
data out of the packet assuming that page_address() is always valid on
the SKB pages.

It's also trying to use this to prevent physical addresses beyond 4GB
from reaching the driver, which as you note is not implemented
precisely here.

Without knowing something about how the driver "DMAs" packet data we
can't really do an accurate test here.  Maybe the driver directly DMAs
using physical addressing (an ASIC inside of a CPU, for example,
drivers/net/niu.c has a case of this).

Maybe the platform uses an IOMMU with 32-bit virtual addressing, so
any physical address is fine even if the card only supports 32-bit
addressing (basically any PCI coard on sparc64 is an example of this).

And finally maybe the card supports 64-bit DMA addressing so anything
works on any platform.

How to test all of these possible cases precisely that at this spot in
the transmit path is the question at hand.  To be honest I consider
the current hack "good enough" :-)
