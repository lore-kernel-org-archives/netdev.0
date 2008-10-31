From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: Validation of DMA params breaks e100 driver (2.6.28-rc2)
Date: Fri, 31 Oct 2008 21:01:32 +0000
Message-ID: <20081031210131.GA18015@flint.arm.linux.org.uk>
References: <4909E08F.9040306@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org
To: Anders =?iso-8859-1?Q?Grafstr=F6m?=
	<grfstrm@users.sourceforge.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:49105 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751133AbYJaVBy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Oct 2008 17:01:54 -0400
Content-Disposition: inline
In-Reply-To: <4909E08F.9040306@users.sourceforge.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 30, 2008 at 05:27:59PM +0100, Anders Grafstr=F6m wrote:
> The e100 driver triggers BUG_ON(buf->direction !=3D dir)
> by doing pci_map_single(..., PCI_DMA_BIDIRECTIONAL)
> and pci_dma_sync_single_for_device(..., PCI_DMA_TODEVICE).
>=20
> I'm guessing it's allowed to do that and that something like
> the patch below is called for?

No, it is not allowed to do that - that's why it's called "BUG_ON".
Changing the DMA direction, especially with dmabounce will result
in unexpected behaviour.

> -----------------
>=20
> [PATCH] [ARM] dma: Fix DMA params validation
>=20
> This patch makes the DMA params validation less strict
> and more like the generic implementation.
>=20
> Signed-off-by: Anders Grafstr=F6m <grfstrm@users.sourceforge.net>
> ---
>  arch/arm/common/dmabounce.c |   13 ++++++-------
>  1 files changed, 6 insertions(+), 7 deletions(-)
>=20
> diff --git a/arch/arm/common/dmabounce.c b/arch/arm/common/dmabounce.=
c
> index f030f07..a0c9c7b 100644
> --- a/arch/arm/common/dmabounce.c
> +++ b/arch/arm/common/dmabounce.c
> @@ -289,7 +289,6 @@ static inline void unmap_single(struct device *de=
v, dma_addr_t dma_addr,
>=20
>  	if (buf) {
>  		BUG_ON(buf->size !=3D size);
> -		BUG_ON(buf->direction !=3D dir);
>=20
>  		dev_dbg(dev,
>  			"%s: unsafe buffer %p (dma=3D%#x) mapped to %p (dma=3D%#x)\n",
> @@ -382,8 +381,6 @@ int dmabounce_sync_for_cpu(struct device *dev, dm=
a_addr_t addr,
>  	if (!buf)
>  		return 1;
>=20
> -	BUG_ON(buf->direction !=3D dir);
> -
>  	dev_dbg(dev, "%s: unsafe buffer %p (dma=3D%#x) mapped to %p (dma=3D=
%#x)\n",
>  		__func__, buf->ptr, virt_to_dma(dev, buf->ptr),
>  		buf->safe, buf->safe_dma_addr);
> @@ -394,7 +391,9 @@ int dmabounce_sync_for_cpu(struct device *dev, dm=
a_addr_t addr,
>  		dev_dbg(dev, "%s: copy back safe %p to unsafe %p size %d\n",
>  			__func__, buf->safe + off, buf->ptr + off, sz);
>  		memcpy(buf->ptr + off, buf->safe + off, sz);
> -	}
> +	} else
> +		BUG_ON(dir !=3D DMA_TO_DEVICE);
> +
>  	return 0;
>  }
>  EXPORT_SYMBOL(dmabounce_sync_for_cpu);
> @@ -411,8 +410,6 @@ int dmabounce_sync_for_device(struct device *dev,=
 dma_addr_t addr,
>  	if (!buf)
>  		return 1;
>=20
> -	BUG_ON(buf->direction !=3D dir);
> -
>  	dev_dbg(dev, "%s: unsafe buffer %p (dma=3D%#x) mapped to %p (dma=3D=
%#x)\n",
>  		__func__, buf->ptr, virt_to_dma(dev, buf->ptr),
>  		buf->safe, buf->safe_dma_addr);
> @@ -423,7 +420,9 @@ int dmabounce_sync_for_device(struct device *dev,=
 dma_addr_t addr,
>  		dev_dbg(dev, "%s: copy out unsafe %p to safe %p, size %d\n",
>  			__func__,buf->ptr + off, buf->safe + off, sz);
>  		memcpy(buf->safe + off, buf->ptr + off, sz);
> -	}
> +	} else
> +		BUG_ON(dir !=3D DMA_FROM_DEVICE);
> +
>  	return 0;
>  }
>  EXPORT_SYMBOL(dmabounce_sync_for_device);
> --=20
> 1.5.6.5
>=20
>=20
