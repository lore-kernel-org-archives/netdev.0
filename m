From: Chris Wilson <chris@chris-wilson.co.uk>
Subject: Re: [PATCH v2 2/4] io-mapping: Specify mapping size for
 io_mapping_map_wc()
Date: Tue, 19 Apr 2016 13:02:25 +0100
Message-ID: <20160419120225.GF26039@nuc-i3427.alporthouse.com>
References: <1460978042-9953-1-git-send-email-chris@chris-wilson.co.uk>
 <1460978042-9953-2-git-send-email-chris@chris-wilson.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tvrtko Ursulin <tvrtko.ursulin@intel.com>,
	Daniel Vetter <daniel.vetter@intel.com>,
	Jani Nikula <jani.nikula@linux.intel.com>,
	David Airlie <airlied@linux.ie>,
	Yishai Hadas <yishaih@mellanox.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Ingo Molnar <mingo@kernel.org>,
	"Peter Zijlstra (Intel)" <peterz@infradead.org>,
	David Hildenbrand <dahi@linux.vnet.ibm.com>,
	"Luis R. Rodriguez" <mcgrof@kernel.org>,
	dri-devel@lists.freedesktop.org, netdev@vger.kernel.org,
	linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org
To: intel-gfx@lists.freedesktop.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1460978042-9953-2-git-send-email-chris@chris-wilson.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 18, 2016 at 12:14:00PM +0100, Chris Wilson wrote:
> The ioremap() hidden behind the io_mapping_map_wc() convenience helper
> can be used for remapping multiple pages. Extend the helper so that
> future callers can use it for larger ranges.

Adding Luis Rodriguez as he has been active in the area of ioremap_*().

> Signed-off-by: Chris Wilson <chris@chris-wilson.co.uk>
> Cc: Tvrtko Ursulin <tvrtko.ursulin@intel.com>
> Cc: Daniel Vetter <daniel.vetter@intel.com>
> Cc: Jani Nikula <jani.nikula@linux.intel.com>
> Cc: David Airlie <airlied@linux.ie>
> Cc: Yishai Hadas <yishaih@mellanox.com>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Ingo Molnar <mingo@kernel.org>
> Cc: "Peter Zijlstra (Intel)" <peterz@infradead.org>
> Cc: David Hildenbrand <dahi@linux.vnet.ibm.com>
Cc: Luis R. Rodriguez <mcgrof@kernel.org>
> Cc: intel-gfx@lists.freedesktop.org
> Cc: dri-devel@lists.freedesktop.org
> Cc: netdev@vger.kernel.org
> Cc: linux-rdma@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org
> ---
>  drivers/gpu/drm/i915/intel_overlay.c    |  3 ++-
>  drivers/net/ethernet/mellanox/mlx4/pd.c |  4 +++-
>  include/linux/io-mapping.h              | 10 +++++++---
>  3 files changed, 12 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/gpu/drm/i915/intel_overlay.c b/drivers/gpu/drm/i915/intel_overlay.c
> index 9746b9841c13..0d5a376878d3 100644
> --- a/drivers/gpu/drm/i915/intel_overlay.c
> +++ b/drivers/gpu/drm/i915/intel_overlay.c
> @@ -198,7 +198,8 @@ intel_overlay_map_regs(struct intel_overlay *overlay)
>  		regs = (struct overlay_registers __iomem *)overlay->reg_bo->phys_handle->vaddr;
>  	else
>  		regs = io_mapping_map_wc(ggtt->mappable,
> -					 overlay->flip_addr);
> +					 overlay->flip_addr,
> +					 PAGE_SIZE);
>  
>  	return regs;
>  }
> diff --git a/drivers/net/ethernet/mellanox/mlx4/pd.c b/drivers/net/ethernet/mellanox/mlx4/pd.c
> index b3cc3ab63799..6fc156a3918d 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/pd.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/pd.c
> @@ -205,7 +205,9 @@ int mlx4_bf_alloc(struct mlx4_dev *dev, struct mlx4_bf *bf, int node)
>  			goto free_uar;
>  		}
>  
> -		uar->bf_map = io_mapping_map_wc(priv->bf_mapping, uar->index << PAGE_SHIFT);
> +		uar->bf_map = io_mapping_map_wc(priv->bf_mapping,
> +						uar->index << PAGE_SHIFT,
> +						PAGE_SIZE);
>  		if (!uar->bf_map) {
>  			err = -ENOMEM;
>  			goto unamp_uar;
> diff --git a/include/linux/io-mapping.h b/include/linux/io-mapping.h
> index e399029b68c5..645ad06b5d52 100644
> --- a/include/linux/io-mapping.h
> +++ b/include/linux/io-mapping.h
> @@ -100,14 +100,16 @@ io_mapping_unmap_atomic(void __iomem *vaddr)
>  }
>  
>  static inline void __iomem *
> -io_mapping_map_wc(struct io_mapping *mapping, unsigned long offset)
> +io_mapping_map_wc(struct io_mapping *mapping,
> +		  unsigned long offset,
> +		  unsigned long size)
>  {
>  	resource_size_t phys_addr;
>  
>  	BUG_ON(offset >= mapping->size);
>  	phys_addr = mapping->base + offset;
>  
> -	return ioremap_wc(phys_addr, PAGE_SIZE);
> +	return ioremap_wc(phys_addr, size);
>  }
>  
>  static inline void
> @@ -155,7 +157,9 @@ io_mapping_unmap_atomic(void __iomem *vaddr)
>  
>  /* Non-atomic map/unmap */
>  static inline void __iomem *
> -io_mapping_map_wc(struct io_mapping *mapping, unsigned long offset)
> +io_mapping_map_wc(struct io_mapping *mapping,
> +		  unsigned long offset,
> +		  unsigned long size)
>  {
>  	return ((char __force __iomem *) mapping) + offset;
>  }

-- 
Chris Wilson, Intel Open Source Technology Centre
