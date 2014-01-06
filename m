From: Stefano Stabellini <stefano.stabellini@eu.citrix.com>
Subject: Re: [Xen-devel] [PATCH net] xen-netback: fix guest-receive-side
 array sizes
Date: Mon, 6 Jan 2014 12:59:14 +0000
Message-ID: <alpine.DEB.2.02.1401061257360.8667@kaball.uk.xensource.com>
References: <1387790838-8852-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: <netdev@vger.kernel.org>, <xen-devel@lists.xen.org>,
	Ian Campbell <ian.campbell@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>,
	"Konrad Rzeszutek Wilk" <konrad.wilk@oracle.com>,
	Wei Liu <wei.liu2@citrix.com>, <davem@davemloft.net>
To: Paul Durrant <paul.durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:6648 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750950AbaAFNCm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jan 2014 08:02:42 -0500
In-Reply-To: <1387790838-8852-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 23 Dec 2013, Paul Durrant wrote:
> The sizes chosen for the metadata and grant_copy_op arrays on the guest
> receive size are wrong;
> 
> - The meta array is needlessly twice the ring size, when we only ever
>   consume a single array element per RX ring slot
> - The grant_copy_op array is way too small. It's sized based on a bogus
>   assumption: that at most two copy ops will be used per ring slot. This
>   may have been true at some point in the past but it's clear from looking
>   at start_new_rx_buffer() that a new ring slot is only consumed if a frag
>   would overflow the current slot (plus some other conditions) so the actual
>   limit is MAX_SKB_FRAGS grant_copy_ops per ring slot.
> 
> This patch fixes those two sizing issues and, because grant_copy_ops grows
> so much, it pulls it out into a separate chunk of vmalloc()ed memory.
> 
> Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
> Acked-by: Wei Liu <wei.liu2@citrix.com>
> Cc: Ian Campbell <ian.campbell@citrix.com>
> Cc: David Vrabel <david.vrabel@citrix.com>

Unfortunately this patch (now in 3.13-rc7) breaks the ARM build:

  CC      drivers/net/xen-netback/interface.o
drivers/net/xen-netback/interface.c: In function 'xenvif_alloc':
drivers/net/xen-netback/interface.c:311:2: error: implicit declaration of function 'vmalloc' [-Werror=implicit-function-declaration]
  vif->grant_copy_op = vmalloc(sizeof(struct gnttab_copy) *
  ^
drivers/net/xen-netback/interface.c:311:21: warning: assignment makes pointer from integer without a cast [enabled by default]
  vif->grant_copy_op = vmalloc(sizeof(struct gnttab_copy) *
                     ^
drivers/net/xen-netback/interface.c: In function 'xenvif_free':
drivers/net/xen-netback/interface.c:499:2: error: implicit declaration of function 'vfree' [-Werror=implicit-function-declaration]
  vfree(vif->grant_copy_op);
  ^
cc1: some warnings being treated as errors
make[3]: *** [drivers/net/xen-netback/interface.o] Error 1
make[2]: *** [drivers/net/xen-netback] Error 2
make[1]: *** [drivers/net] Error 2
make: *** [drivers] Error 2

I suggest we fix it (probably by reverting it) ASAP otherwise we risk
break the release.


> This was originally submitted for discussion on xen-devel. Wei acked it
> there, which is why this carbon-copy submission to netdev already carries
> his ack.
> 
>  drivers/net/xen-netback/common.h    |   19 +++++++++++++------
>  drivers/net/xen-netback/interface.c |   10 ++++++++++
>  drivers/net/xen-netback/netback.c   |    2 +-
>  3 files changed, 24 insertions(+), 7 deletions(-)
> 
> diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
> index 08ae01b..c47794b 100644
> --- a/drivers/net/xen-netback/common.h
> +++ b/drivers/net/xen-netback/common.h
> @@ -101,6 +101,13 @@ struct xenvif_rx_meta {
>  
>  #define MAX_PENDING_REQS 256
>  
> +/* It's possible for an skb to have a maximal number of frags
> + * but still be less than MAX_BUFFER_OFFSET in size. Thus the
> + * worst-case number of copy operations is MAX_SKB_FRAGS per
> + * ring slot.
> + */
> +#define MAX_GRANT_COPY_OPS (MAX_SKB_FRAGS * XEN_NETIF_RX_RING_SIZE)
> +
>  struct xenvif {
>  	/* Unique identifier for this interface. */
>  	domid_t          domid;
> @@ -143,13 +150,13 @@ struct xenvif {
>  	 */
>  	RING_IDX rx_req_cons_peek;
>  
> -	/* Given MAX_BUFFER_OFFSET of 4096 the worst case is that each
> -	 * head/fragment page uses 2 copy operations because it
> -	 * straddles two buffers in the frontend.
> -	 */
> -	struct gnttab_copy grant_copy_op[2*XEN_NETIF_RX_RING_SIZE];
> -	struct xenvif_rx_meta meta[2*XEN_NETIF_RX_RING_SIZE];
> +	/* This array is allocated seperately as it is large */
> +	struct gnttab_copy *grant_copy_op;
>  
> +	/* We create one meta structure per ring request we consume, so
> +	 * the maximum number is the same as the ring size.
> +	 */
> +	struct xenvif_rx_meta meta[XEN_NETIF_RX_RING_SIZE];
>  
>  	u8               fe_dev_addr[6];
>  
> diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
> index 870f1fa..34ca4e5 100644
> --- a/drivers/net/xen-netback/interface.c
> +++ b/drivers/net/xen-netback/interface.c
> @@ -307,6 +307,15 @@ struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
>  	SET_NETDEV_DEV(dev, parent);
>  
>  	vif = netdev_priv(dev);
> +
> +	vif->grant_copy_op = vmalloc(sizeof(struct gnttab_copy) *
> +				     MAX_GRANT_COPY_OPS);
> +	if (vif->grant_copy_op == NULL) {
> +		pr_warn("Could not allocate grant copy space for %s\n", name);
> +		free_netdev(dev);
> +		return ERR_PTR(-ENOMEM);
> +	}
> +
>  	vif->domid  = domid;
>  	vif->handle = handle;
>  	vif->can_sg = 1;
> @@ -487,6 +496,7 @@ void xenvif_free(struct xenvif *vif)
>  
>  	unregister_netdev(vif->dev);
>  
> +	vfree(vif->grant_copy_op);
>  	free_netdev(vif->dev);
>  
>  	module_put(THIS_MODULE);
> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> index 7b4fd93..7842555 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -608,7 +608,7 @@ void xenvif_rx_action(struct xenvif *vif)
>  	if (!npo.copy_prod)
>  		return;
>  
> -	BUG_ON(npo.copy_prod > ARRAY_SIZE(vif->grant_copy_op));
> +	BUG_ON(npo.copy_prod > MAX_GRANT_COPY_OPS);
>  	gnttab_batch_copy(vif->grant_copy_op, npo.copy_prod);
>  
>  	while ((skb = __skb_dequeue(&rxq)) != NULL) {
> -- 
> 1.7.10.4
> 
> 
> _______________________________________________
> Xen-devel mailing list
> Xen-devel@lists.xen.org
> http://lists.xen.org/xen-devel
> 
