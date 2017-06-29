From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [PATCH net-next v2 7/9] nfp: add metadata to each flow offload
Date: Wed, 28 Jun 2017 19:33:02 -0700
Message-ID: <20170628193302.555537c1@cakuba.netronome.com>
References: <1498681802-2897-1-git-send-email-simon.horman@netronome.com>
        <1498681802-2897-8-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        oss-drivers@netronome.com,
        Pieter Jansen van Vuuren
        <pieter.jansenvanvuuren@netronome.com>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:33963 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751579AbdF2CdI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Jun 2017 22:33:08 -0400
Received: by mail-pg0-f44.google.com with SMTP id t186so40704778pgb.1
        for <netdev@vger.kernel.org>; Wed, 28 Jun 2017 19:33:07 -0700 (PDT)
In-Reply-To: <1498681802-2897-8-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 28 Jun 2017 22:30:00 +0200, Simon Horman wrote:
> From: Pieter Jansen van Vuuren <pieter.jansenvanvuuren@netronome.com>
> 
> Adds metadata describing the mask id of each flow and keeps track of
> flows installed in hardware. Previously a flow could not be removed
> from hardware as there was no way of knowing if that a specific flow
> was installed. This is solved by storing the offloaded flows in a
> hash table.
> 
> Signed-off-by: Pieter Jansen van Vuuren <pieter.jansenvanvuuren@netronome.com>
> Signed-off-by: Simon Horman <simon.horman@netronome.com>

> diff --git a/drivers/net/ethernet/netronome/nfp/flower/main.c b/drivers/net/ethernet/netronome/nfp/flower/main.c
> index 19f20f819e2f..1103d23a8ec7 100644
> --- a/drivers/net/ethernet/netronome/nfp/flower/main.c
> +++ b/drivers/net/ethernet/netronome/nfp/flower/main.c
> @@ -50,14 +50,6 @@
>  
>  #define NFP_FLOWER_ALLOWED_VER 0x0001000000010000UL
>  
> -/**
> - * struct nfp_flower_priv - Flower APP per-vNIC priv data
> - * @nn:		     Pointer to vNIC
> - */
> -struct nfp_flower_priv {
> -	struct nfp_net *nn;
> -};
> -
>  static const char *nfp_flower_extra_cap(struct nfp_app *app, struct nfp_net *nn)
>  {
>  	return "FLOWER";
> @@ -351,6 +343,12 @@ static int nfp_flower_init(struct nfp_app *app)
>  	if (!app->priv)
>  		return -ENOMEM;
>  
> +	err = nfp_flower_metadata_init(app);
> +	if (nfp_flower_metadata_init(app)) {

You're calling init twice here.  Also please do the error path with
goto, as explained in review of patch 8 having a proper unwind makes
later patches easier to review.

> +		kfree(app->priv);
> +		return err;
> +	}
> +
>  	return 0;
>  }
>  

> +static int nfp_mask_alloc(struct nfp_app *app, u8 *mask_id)
> +{
> +	struct nfp_flower_priv *priv = app->priv;
> +	struct timespec64 delta, now;
> +	struct circ_buf *ring;
> +	u8 temp_id, freed_id;
> +
> +	ring = &priv->mask_ids.mask_id_free_list;
> +	freed_id = NFP_FLOWER_MASK_ENTRY_RS - 1;
> +	/* Checking for unallocated entries first. */
> +	if (priv->mask_ids.init_unallocated > 0) {
> +		*mask_id = priv->mask_ids.init_unallocated;
> +		priv->mask_ids.init_unallocated--;
> +		return 0;
> +	}
> +
> +	/* Checking if buffer is empty. */
> +	if (ring->head == ring->tail) {
> +		*mask_id = freed_id;
> +		return -ENOENT;
> +	}
> +
> +	memcpy(&temp_id, &ring->buf[ring->tail], NFP_FLOWER_MASK_ELEMENT_RS);
> +	*mask_id = temp_id;
> +	memcpy(&ring->buf[ring->tail], &freed_id, NFP_FLOWER_MASK_ELEMENT_RS);
> +	ring->tail = (ring->tail + NFP_FLOWER_MASK_ELEMENT_RS) %
> +		     (NFP_FLOWER_MASK_ENTRY_RS * NFP_FLOWER_MASK_ELEMENT_RS);
> +
> +	getnstimeofday64(&now);
> +	delta = timespec64_sub(now, priv->mask_ids.last_used[*mask_id]);
> +
> +	if (timespec64_to_ns(&delta) < NFP_FL_MASK_REUSE_TIME_NS) {
> +		nfp_release_mask_id(app, *mask_id);

nfp_release_mask_id() will reset the time stamp and put the mask at the
end of the queue.  Is that OK?

> +		return -ENOENT;
> +	}
> +
> +	return 0;
> +}
> +

> +int nfp_flower_metadata_init(struct nfp_app *app)
> +{
> +	struct nfp_flower_priv *priv = app->priv;
> +
> +	hash_init(priv->mask_table);
> +	hash_init(priv->flow_table);
> +
> +	/* Init ring buffer and unallocated mask_ids. */
> +	priv->mask_ids.mask_id_free_list.buf =
> +		kmalloc(NFP_FLOWER_MASK_ENTRY_RS * NFP_FLOWER_MASK_ELEMENT_RS,
> +			GFP_KERNEL);

kmalloc_array, perhaps?  

> +	if (!priv->mask_ids.mask_id_free_list.buf)
> +		return -ENOMEM;
> +
> +	priv->mask_ids.init_unallocated = NFP_FLOWER_MASK_ENTRY_RS - 1;
> +
> +	/* Init timestamps for mask id*/
> +	priv->mask_ids.last_used =
> +		kmalloc_array(NFP_FLOWER_MASK_ENTRY_RS,
> +			      sizeof(*priv->mask_ids.last_used), GFP_KERNEL);
> +	if (!priv->mask_ids.last_used) {
> +		kfree(priv->mask_ids.mask_id_free_list.buf);
> +		return -ENOMEM;
> +	}
> +
> +	return 0;
> +}
