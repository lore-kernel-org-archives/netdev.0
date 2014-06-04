From: annie li <annie.li@oracle.com>
Subject: Re: [PATCH net] xen-netback: Fix handling of skbs
 requiring too many slots
Date: Wed, 04 Jun 2014 11:09:15 -0400
Message-ID: <538F369B.7010100@oracle.com>
References: <1401827406-9341-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: wei.liu2@citrix.com, ian.campbell@citrix.com, netdev@vger.kernel.org,
	linux@eikelenboom.it, paul.durrant@citrix.com,
	david.vrabel@citrix.com, xen-devel@lists.xenproject.org,
	davem@davemloft.net
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <1401827406-9341-1-git-send-email-zoltan.kiss@citrix.com>
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
List-Id: netdev.vger.kernel.org


On 2014/6/3 16:30, Zoltan Kiss wrote:
> A recent commit (a02eb4 "xen-netback: worse-case estimate in xenvif_rx_action is
> underestimating") capped the slot estimation to MAX_SKB_FRAGS, but that triggers
> the next BUG_ON a few lines down, as the packet consumes more slots than
> estimated.
> This patch introduces full_coalesce on the skb callback buffer, which is used in
> start_new_rx_buffer() to decide whether netback needs coalescing more
> aggresively. By doing that, no packet should need more than
> XEN_NETIF_MAX_TX_SIZE / PAGE_SIZE data slots,

(XEN_NETIF_MAX_TX_SIZE+1) / PAGE_SIZE here?

Thanks
Annie
> as the provided buffers are fully
> utilized.
>
> Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
> Cc: Paul Durrant <paul.durrant@citrix.com>
> Cc: Wei Liu <wei.liu2@citrix.com>
> Cc: Ian Campbell <ian.campbell@citrix.com>
> Cc: David Vrabel <david.vrabel@citrix.com>
> ---
> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> index 64ab1d1..65fbcd1 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -163,7 +163,10 @@ bool xenvif_rx_ring_slots_available(struct xenvif *vif, int needed)
>    * adding 'size' bytes to a buffer which currently contains 'offset'
>    * bytes.
>    */
> -static bool start_new_rx_buffer(int offset, unsigned long size, int head)
> +static bool start_new_rx_buffer(int offset,
> +				unsigned long size,
> +				int head,
> +				bool full_coalesce)
>   {
>   	/* simple case: we have completely filled the current buffer. */
>   	if (offset == MAX_BUFFER_OFFSET)
> @@ -175,6 +178,7 @@ static bool start_new_rx_buffer(int offset, unsigned long size, int head)
>   	 *     (i)   this frag would fit completely in the next buffer
>   	 * and (ii)  there is already some data in the current buffer
>   	 * and (iii) this is not the head buffer.
> +	 * and (iv)  there is no need to fully utilize the buffers
>   	 *
>   	 * Where:
>   	 * - (i) stops us splitting a frag into two copies
> @@ -185,6 +189,8 @@ static bool start_new_rx_buffer(int offset, unsigned long size, int head)
>   	 *   by (ii) but is explicitly checked because
>   	 *   netfront relies on the first buffer being
>   	 *   non-empty and can crash otherwise.
> +	 * - (iv) is needed for skbs which can use up more than MAX_SKB_FRAGS
> +	 *   slot
>   	 *
>   	 * This means we will effectively linearise small
>   	 * frags but do not needlessly split large buffers
> @@ -192,7 +198,10 @@ static bool start_new_rx_buffer(int offset, unsigned long size, int head)
>   	 * own buffers as before.
>   	 */
>   	BUG_ON(size > MAX_BUFFER_OFFSET);
> -	if ((offset + size > MAX_BUFFER_OFFSET) && offset && !head)
> +	if ((offset + size > MAX_BUFFER_OFFSET) &&
> +	    offset &&
> +	    !head &&
> +	    !full_coalesce)
>   		return true;
>   
>   	return false;
> @@ -227,6 +236,13 @@ static struct xenvif_rx_meta *get_next_rx_buffer(struct xenvif *vif,
>   	return meta;
>   }
>   
> +struct xenvif_rx_cb {
> +	int meta_slots_used;
> +	bool full_coalesce;
> +};
> +
> +#define XENVIF_RX_CB(skb) ((struct xenvif_rx_cb *)(skb)->cb)
> +
>   /*
>    * Set up the grant operations for this fragment. If it's a flipping
>    * interface, we also set up the unmap request from here.
> @@ -261,7 +277,10 @@ static void xenvif_gop_frag_copy(struct xenvif *vif, struct sk_buff *skb,
>   		if (bytes > size)
>   			bytes = size;
>   
> -		if (start_new_rx_buffer(npo->copy_off, bytes, *head)) {
> +		if (start_new_rx_buffer(npo->copy_off,
> +					bytes,
> +					*head,
> +					XENVIF_RX_CB(skb)->full_coalesce)) {
>   			/*
>   			 * Netfront requires there to be some data in the head
>   			 * buffer.
> @@ -541,12 +560,6 @@ static void xenvif_add_frag_responses(struct xenvif *vif, int status,
>   	}
>   }
>   
> -struct xenvif_rx_cb {
> -	int meta_slots_used;
> -};
> -
> -#define XENVIF_RX_CB(skb) ((struct xenvif_rx_cb *)(skb)->cb)
> -
>   void xenvif_kick_thread(struct xenvif *vif)
>   {
>   	wake_up(&vif->wq);
> @@ -602,10 +615,14 @@ static void xenvif_rx_action(struct xenvif *vif)
>   
>   		/* To avoid the estimate becoming too pessimal for some
>   		 * frontends that limit posted rx requests, cap the estimate
> -		 * at MAX_SKB_FRAGS.
> +		 * at MAX_SKB_FRAGS. In this case netback will fully coalesce
> +		 * the skb into the provided slots.
>   		 */
> -		if (max_slots_needed > MAX_SKB_FRAGS)
> +		if (max_slots_needed > MAX_SKB_FRAGS) {
>   			max_slots_needed = MAX_SKB_FRAGS;
> +			XENVIF_RX_CB(skb)->full_coalesce = true;
> +		} else
> +			XENVIF_RX_CB(skb)->full_coalesce = false;

I am not so clear hear, when max_slots_needed > MAX_SKB_FRAGS, then 
full_coalesce is always true.
>   
>   		/* We may need one more slot for GSO metadata */
>   		if (skb_is_gso(skb) &&
>
> _______________________________________________
> Xen-devel mailing list
> Xen-devel@lists.xen.org
> http://lists.xen.org/xen-devel
