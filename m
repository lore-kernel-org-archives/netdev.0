From: Anton Blanchard <anton@samba.org>
Subject: Re: [PATCH 3/4] myri10ge - Driver core
Date: Wed, 24 May 2006 01:39:28 +1000
Message-ID: <20060523153928.GB5938@krispykreme>
References: <20060517220218.GA13411@myri.com> <20060517220608.GD13411@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, gallatin@myri.com,
	linux-kernel@vger.kernel.org, benh@kernel.crashing.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750825AbWEWQOV@vger.kernel.org>
To: Brice Goglin <brice@myri.com>
Content-Disposition: inline
In-Reply-To: <20060517220608.GD13411@myri.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi Brice,

Sorry this review is based on your previous submission, I just noticed
it was still sitting in my mailbox. Please ignore anything that has been
fixed in the meantime :)

> +/*
> + * Set of routunes to get a new receive buffer.  Any buffer which
> + * crosses a 4KB boundary must start on a 4KB boundary due to PCIe
> + * wdma restrictions. We also try to align any smaller allocation to
> + * at least a 16 byte boundary for efficiency.  We assume the linux
> + * memory allocator works by powers of 2, and will not return memory
> + * smaller than 2KB which crosses a 4KB boundary.  If it does, we fall
> + * back to allocating 2x as much space as required.
> + *
> + * We intend to replace large (>4KB) skb allocations by using
> + * pages directly and building a fraglist in the near future.
> + */

You go to a lot of trouble to align things. One thing on ppc64 is that
we really want to start all DMA writes on a cacheline boundary. We
enforce that in network drivers by making NET_IP_ALIGN = 0 and having
the drivers do:

skb_reserve(skb, NET_IP_ALIGN);

It sounds like your small allocations will be only aligned to 16 bytes.

> +	mgp->cmd = pci_alloc_consistent(pdev, sizeof(*mgp->cmd), &mgp->cmd_bus);

Id suggest using the dma API instead of the pci API. We have seen
machines in the field that have failed large pci_alloc_consistent calls
because it always asks for GFP_ATOMIC memory (it presumes the worst).
The dma API allows you to pass a GFP_ flag in which will have a much
better chance of succeeding when you dont need GFP_ATOMIC memory.

> +#ifdef CONFIG_MTRR
> +	mgp->mtrr = mtrr_add(mgp->iomem_base, mgp->board_span,
> +			     MTRR_TYPE_WRCOMB, 1);
> +#endif
...
> +	mgp->sram = ioremap(mgp->iomem_base, mgp->board_span);

Not sure how we are meant to specify write through in drivers. Any ideas Ben?

Anton
