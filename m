From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: [PATCH] e1000: fix race condition while driver unload/reset
 using kref count
Date: Wed, 2 Mar 2011 14:50:31 -0800 (Pacific Standard Time)
Message-ID: <alpine.WNT.2.00.1103021337560.8204@JBRANDEB-DESK2.amr.corp.intel.com>
References: <1299091597-28409-1-git-send-email-prasanna.panchamukhi@riverbed.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Pieper, Jeffrey E" <jeffrey.e.pieper@intel.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "prasanna.panchamukhi@riverbed.com"
	<prasanna.panchamukhi@riverbed.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:19710 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754924Ab1CBWuh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Mar 2011 17:50:37 -0500
In-Reply-To: <1299091597-28409-1-git-send-email-prasanna.panchamukhi@riverbed.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Wed, 2 Mar 2011, prasanna.panchamukhi@riverbed.com wrote:

> This race conditions occurs with reentrant e1000_down(), which gets
> called by multiple threads while driver unload or reset.
> This patch fixes the race condition when one thread tries to destroy
> the memory allocated for tx buffer_info, while another thread still
> happen to access tx buffer_info.
> This patch fixes the above race condition using kref count.

I'm very interested in any test cases that you might have come up with to 
reproduce this issue.

The patch itself looks interesting, and probably okay, but we really need 
a reproduction case.

Also, do we need to adjust the rtnl_lock stuff or do this for rx 
buffer_info structs?

I'm concerned that maybe we don't understand the full flow of events 
leading up to this failure.

Jesse
 
> Signed-off-by: Prasanna S. Panchamukhi <prasanna.panchamukhi@riverbed.com>
> ---
>  drivers/net/e1000/e1000.h      |    2 +
>  drivers/net/e1000/e1000_main.c |   41 +++++++++++++++++++++++++++++++++++++--
>  2 files changed, 40 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
> index a881dd0..36f55b3 100644
> --- a/drivers/net/e1000/e1000.h
> +++ b/drivers/net/e1000/e1000.h
> @@ -168,6 +168,8 @@ struct e1000_tx_ring {
>  	unsigned int next_to_clean;
>  	/* array of buffer information structs */
>  	struct e1000_buffer *buffer_info;
> +	spinlock_t bufinfo_lock; /* protect access to buffer_info */
> +	struct kref bufinfo_refcount; /* refcount access to buffer info */
>  
>  	u16 tdh;
>  	u16 tdt;
> diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
> index beec573..336d3e1 100644
> --- a/drivers/net/e1000/e1000_main.c
> +++ b/drivers/net/e1000/e1000_main.c
> @@ -1531,6 +1531,8 @@ setup_tx_desc_die:
>  
>  	txdr->next_to_use = 0;
>  	txdr->next_to_clean = 0;
> +	spin_lock_init(&txdr->bufinfo_lock);
> +	kref_init(&txdr->bufinfo_refcount);
>  
>  	return 0;
>  }
> @@ -1880,6 +1882,22 @@ static void e1000_configure_rx(struct e1000_adapter *adapter)
>  	ew32(RCTL, rctl);
>  }
>  
> +/*
> + * Free tx buffer info resources, only when no other thread is
> + * accessing it. Access to buffer_info is refcounted by bufinfo_refcount,
> + * hence memory allocated must be destroyed when bufinfo_refcount
> + * becomes zero. This routine gets executed when bufinfo_refcount
> + * becomes zero.
> + */
> +static void e1000_free_tx_buffer_info(struct kref *ref)
> +{
> +	struct e1000_tx_ring *tx_ring =
> +		container_of(ref, struct e1000_tx_ring, bufinfo_refcount);
> +
> +	vfree(tx_ring->buffer_info);
> +	tx_ring->buffer_info = NULL;
> +}
> +
>  /**
>   * e1000_free_tx_resources - Free Tx Resources per Queue
>   * @adapter: board private structure
> @@ -1895,8 +1913,9 @@ static void e1000_free_tx_resources(struct e1000_adapter *adapter,
>  
>  	e1000_clean_tx_ring(adapter, tx_ring);
>  
> -	vfree(tx_ring->buffer_info);
> -	tx_ring->buffer_info = NULL;
> +	spin_lock(&tx_ring->bufinfo_lock);
> +	kref_put(&tx_ring->bufinfo_refcount, e1000_free_tx_buffer_info);
> +	spin_unlock(&tx_ring->bufinfo_lock);
>  
>  	dma_free_coherent(&pdev->dev, tx_ring->size, tx_ring->desc,
>  			  tx_ring->dma);
> @@ -1954,8 +1973,20 @@ static void e1000_clean_tx_ring(struct e1000_adapter *adapter,
>  	unsigned long size;
>  	unsigned int i;
>  
> -	/* Free all the Tx ring sk_buffs */
> +	spin_lock(&tx_ring->bufinfo_lock);
> +	/*
> +	 * Check buffer_info is not NULL, and
> +	 * increment the refcount to prevent
> +	 * the buffer getting freed underneath.
> +	 */
> +	if (tx_ring->buffer_info == NULL) {
> +		spin_unlock(&tx_ring->bufinfo_lock);
> +		return;
> +	}
> +	kref_get(&tx_ring->bufinfo_refcount);
> +	spin_unlock(&tx_ring->bufinfo_lock);
>  
> +	/* Free all the Tx ring sk_buffs */
>  	for (i = 0; i < tx_ring->count; i++) {
>  		buffer_info = &tx_ring->buffer_info[i];
>  		e1000_unmap_and_free_tx_resource(adapter, buffer_info);
> @@ -1968,6 +1999,10 @@ static void e1000_clean_tx_ring(struct e1000_adapter *adapter,
>  
>  	memset(tx_ring->desc, 0, tx_ring->size);
>  
> +	spin_lock(&tx_ring->bufinfo_lock);
> +	kref_put(&tx_ring->bufinfo_refcount, e1000_free_tx_buffer_info);
> +	spin_unlock(&tx_ring->bufinfo_lock);
> +
>  	tx_ring->next_to_use = 0;
>  	tx_ring->next_to_clean = 0;
>  	tx_ring->last_tx_tso = 0;
> 
