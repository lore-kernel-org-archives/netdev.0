From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH V2 7/9] IB/mlx5: Mellanox Connect-IB, IB driver part 3/5
Date: Wed, 03 Jul 2013 14:10:04 -0700
Message-ID: <1372885804.1886.22.camel@joe-AO722>
References: <1372871592-32033-1-git-send-email-ogerlitz@mellanox.com>
	 <1372871592-32033-8-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org, eli-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org,
	moshel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1372871592-32033-8-git-send-email-ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-07-03 at 20:13 +0300, Or Gerlitz wrote:
> From: Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

More trivia:

> diff --git a/drivers/infiniband/hw/mlx5/mlx5_ib.h b/drivers/infiniband/hw/mlx5/mlx5_ib.h
[]
> +#define mlx5_ib_dbg(dev, format, arg...)				\
> +do {									\
> +	pr_debug("%s:%s:%d:(pid %d): " format, (dev)->ib_dev.name,	\
> +		 __func__, __LINE__, current->pid, ##arg);		\
> +} while (0)

unnecessary do {} while (0)

> +static void clean_keys(struct mlx5_ib_dev *dev, int c)
> +{
> +	struct device *ddev = dev->ib_dev.dma_device;
> +	struct mlx5_mr_cache *cache = &dev->cache;
> +	struct mlx5_cache_ent *ent = &cache->ent[c];
> +	struct mlx5_ib_mr *mr;
> +	int size;
> +	int err;
> +
> +	while (1) {
> +		spin_lock(&ent->lock);
> +		if (list_empty(&ent->head)) {
> +			spin_unlock(&ent->lock);
> +			return;
> +		}
> +		mr = list_first_entry(&ent->head, struct mlx5_ib_mr, list);
> +		list_del(&mr->list);
> +		ent->cur--;
> +		ent->size--;
> +		spin_unlock(&ent->lock);
> +		err = mlx5_core_destroy_mkey(&dev->mdev, &mr->mmr);
> +		if (err) {
> +			mlx5_ib_warn(dev, "failed destroy mkey\n");

Are you leaking anything here by not freeing?

> +		} else {
> +			size = ALIGN(sizeof(u64) * (1 << mr->order), 0x40);
> +			dma_unmap_single(ddev, mr->dma, size, DMA_TO_DEVICE);
> +			kfree(mr->pas);
> +			kfree(mr);
> +		}
> +	};
> +}

> +static struct mlx5_ib_mr *reg_create(struct ib_pd *pd, u64 virt_addr,
> +				     u64 length, struct ib_umem *umem,
> +				     int npages, int page_shift,
> +				     int access_flags)
> +{
[]
> +	mr = kzalloc(sizeof(*mr), GFP_KERNEL);
> +	if (!mr) {
> +		mlx5_ib_warn(dev, "allocation failed\n");

Another unnecessary OOM

> +		mr = ERR_PTR(-ENOMEM);
> +	}
> +
> +	inlen = sizeof(*in) + sizeof(*in->pas) * ((npages + 1) / 2) * 2;
> +	in = vzalloc(inlen);
> +	if (!in) {
> +		mlx5_ib_warn(dev, "alloc failed\n");

here too.

> +		err = -ENOMEM;
> +		goto err_1;
> +	}


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
