From: Jack Morgenstein <jackm@dev.mellanox.co.il>
Subject: Re: [PATCH V2 7/9] IB/mlx5: Mellanox Connect-IB, IB driver part 3/5
Date: Thu, 4 Jul 2013 16:33:23 +0300
Message-ID: <201307041633.24505.jackm@dev.mellanox.co.il>
References: <1372871592-32033-1-git-send-email-ogerlitz@mellanox.com> <1372871592-32033-8-git-send-email-ogerlitz@mellanox.com> <1372885804.1886.22.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <ogerlitz@mellanox.com>, roland@kernel.org,
	linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, eli@dev.mellanox.co.il, moshel@mellanox.com,
	Eli Cohen <eli@mellanox.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f182.google.com ([209.85.215.182]:34622 "EHLO
	mail-ea0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752082Ab3GDNbl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jul 2013 09:31:41 -0400
Received: by mail-ea0-f182.google.com with SMTP id d10so795316eaj.41
        for <netdev@vger.kernel.org>; Thu, 04 Jul 2013 06:31:39 -0700 (PDT)
In-Reply-To: <1372885804.1886.22.camel@joe-AO722>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 04 July 2013 00:10, Joe Perches wrote:
> On Wed, 2013-07-03 at 20:13 +0300, Or Gerlitz wrote:
> > From: Eli Cohen <eli@mellanox.com>
> 
> More trivia:
> 
> > diff --git a/drivers/infiniband/hw/mlx5/mlx5_ib.h b/drivers/infiniband/hw/mlx5/mlx5_ib.h
> []
> > +#define mlx5_ib_dbg(dev, format, arg...)				\
> > +do {									\
> > +	pr_debug("%s:%s:%d:(pid %d): " format, (dev)->ib_dev.name,	\
> > +		 __func__, __LINE__, current->pid, ##arg);		\
> > +} while (0)
> 
> unnecessary do {} while (0)

In this case, you are correct. The pr_debug macro itself does this internally
where needed -- not surprising, since pr_debug must also be usable for code like:
if (foo)
	pr_debug(...).
I'll remove the do-while in V3.

> > +static void clean_keys(struct mlx5_ib_dev *dev, int c)
> > +{
> > +	struct device *ddev = dev->ib_dev.dma_device;
> > +	struct mlx5_mr_cache *cache = &dev->cache;
> > +	struct mlx5_cache_ent *ent = &cache->ent[c];
> > +	struct mlx5_ib_mr *mr;
> > +	int size;
> > +	int err;
> > +
> > +	while (1) {
> > +		spin_lock(&ent->lock);
> > +		if (list_empty(&ent->head)) {
> > +			spin_unlock(&ent->lock);
> > +			return;
> > +		}
> > +		mr = list_first_entry(&ent->head, struct mlx5_ib_mr, list);
> > +		list_del(&mr->list);
> > +		ent->cur--;
> > +		ent->size--;
> > +		spin_unlock(&ent->lock);
> > +		err = mlx5_core_destroy_mkey(&dev->mdev, &mr->mmr);
> > +		if (err) {
> > +			mlx5_ib_warn(dev, "failed destroy mkey\n");
> 
> Are you leaking anything here by not freeing?
Actually, if the mkey-destroy fails, it is extremely risky to free
the memory resources it uses.  A tiny memory leak (in such a rare case)
is far preferable to a kernel crash.

> 
> > +		} else {
> > +			size = ALIGN(sizeof(u64) * (1 << mr->order), 0x40);
> > +			dma_unmap_single(ddev, mr->dma, size, DMA_TO_DEVICE);
> > +			kfree(mr->pas);
> > +			kfree(mr);
> > +		}
> > +	};
> > +}
> 
> > +static struct mlx5_ib_mr *reg_create(struct ib_pd *pd, u64 virt_addr,
> > +				     u64 length, struct ib_umem *umem,
> > +				     int npages, int page_shift,
> > +				     int access_flags)
> > +{
> []
> > +	mr = kzalloc(sizeof(*mr), GFP_KERNEL);
> > +	if (!mr) {
> > +		mlx5_ib_warn(dev, "allocation failed\n");
> 
> Another unnecessary OOM

Will remove for V3 

> > +		mr = ERR_PTR(-ENOMEM);
> > +	}
> > +
> > +	inlen = sizeof(*in) + sizeof(*in->pas) * ((npages + 1) / 2) * 2;
> > +	in = vzalloc(inlen);
> > +	if (!in) {
> > +		mlx5_ib_warn(dev, "alloc failed\n");
> 
> here too.

Will remove for V3 

> > +		err = -ENOMEM;
> > +		goto err_1;
> > +	}
> 
Thanks again for the review!

-Jack 
