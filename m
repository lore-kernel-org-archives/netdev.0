From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v4] cadence: Add LSO support.
Date: Tue, 8 Nov 2016 11:09:09 -0800
Message-ID: <911391d0-a7ec-1d4f-e419-b1a09c4d13d3@gmail.com>
References: <20161107.203846.734910693756417486.davem@davemloft.net>
 <1478612463-15076-1-git-send-email-rafalo@cadence.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
To: Rafal Ozieblo <rafalo@cadence.com>, nicolas.ferre@atmel.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1478612463-15076-1-git-send-email-rafalo@cadence.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/08/2016 05:41 AM, Rafal Ozieblo wrote:
> New Cadence GEM hardware support Large Segment Offload (LSO):
> TCP segmentation offload (TSO) as well as UDP fragmentation
> offload (UFO). Support for those features was added to the driver.
> 
> Signed-off-by: Rafal Ozieblo <rafalo@cadence.com>
> ---

> -#define MACB_MAX_TX_LEN		((unsigned int)((1 << MACB_TX_FRMLEN_SIZE) - 1))
> -#define GEM_MAX_TX_LEN		((unsigned int)((1 << GEM_TX_FRMLEN_SIZE) - 1))
> +/* Max length of transmit frame must be a multiple of 8 bytes */
> +#define MACB_TX_LEN_ALIGN	8
> +#define MACB_MAX_TX_LEN		((unsigned int)((1 << MACB_TX_FRMLEN_SIZE) - 1) & ~((unsigned int)(MACB_TX_LEN_ALIGN - 1)))
> +#define GEM_MAX_TX_LEN		((unsigned int)((1 << GEM_TX_FRMLEN_SIZE) - 1) & ~((unsigned int)(MACB_TX_LEN_ALIGN - 1)))
>  
>  #define GEM_MTU_MIN_SIZE	ETH_MIN_MTU
> +#define MACB_NETIF_LSO		(NETIF_F_TSO | NETIF_F_UFO)

Not a huge fan of this definition, since it is always used in conjuction
with netdev_features_t, having it expanded all the time is kind of nicer
for the reader, but this is just personal preference here.

>  
>  #define MACB_WOL_HAS_MAGIC_PACKET	(0x1 << 0)
>  #define MACB_WOL_ENABLED		(0x1 << 1)
> @@ -1223,7 +1228,8 @@ static void macb_poll_controller(struct net_device *dev)
>  
>  static unsigned int macb_tx_map(struct macb *bp,
>  				struct macb_queue *queue,
> -				struct sk_buff *skb)
> +				struct sk_buff *skb,
> +				unsigned int hdrlen)
>  {
>  	dma_addr_t mapping;
>  	unsigned int len, entry, i, tx_head = queue->tx_head;
> @@ -1231,14 +1237,27 @@ static unsigned int macb_tx_map(struct macb *bp,
>  	struct macb_dma_desc *desc;
>  	unsigned int offset, size, count = 0;
>  	unsigned int f, nr_frags = skb_shinfo(skb)->nr_frags;
> -	unsigned int eof = 1;
> -	u32 ctrl;
> +	unsigned int eof = 1, mss_mfs = 0;
> +	u32 ctrl, lso_ctrl = 0, seq_ctrl = 0;
> +
> +	/* LSO */
> +	if (skb_shinfo(skb)->gso_size != 0) {
> +		if (IPPROTO_UDP == (ip_hdr(skb)->protocol))

Most checks are usually done the other way with the left and right
member swapped.

> +			/* UDP - UFO */
> +			lso_ctrl = MACB_LSO_UFO_ENABLE;
> +		else
> +			/* TCP - TSO */
> +			lso_ctrl = MACB_LSO_TSO_ENABLE;
> +	}

>  
>  	/* Then, map paged data from fragments */
> @@ -1311,6 +1332,20 @@ static unsigned int macb_tx_map(struct macb *bp,
>  	desc = &queue->tx_ring[entry];
>  	desc->ctrl = ctrl;
>  
> +	if (lso_ctrl) {
> +		if (lso_ctrl == MACB_LSO_UFO_ENABLE)
> +			/* include header and FCS in value given to h/w */
> +			mss_mfs = skb_shinfo(skb)->gso_size +
> +					skb_transport_offset(skb) + 4;

ETH_FCS_LEN instead of 4?


> +static netdev_features_t macb_features_check(struct sk_buff *skb,
> +					     struct net_device *dev,
> +					     netdev_features_t features)
> +{
> +	unsigned int nr_frags, f;
> +	unsigned int hdrlen;
> +
> +	/* Validate LSO compatibility */
> +
> +	/* there is only one buffer */
> +	if (!skb_is_nonlinear(skb))
> +		return features;
> +
> +	/* length of header */
> +	hdrlen = skb_transport_offset(skb);
> +	if (IPPROTO_TCP == (ip_hdr(skb)->protocol))
> +		hdrlen += tcp_hdrlen(skb);

Same here, please reverse the left and right members, no need for
parenthesis aground ip_hdr(skb)->protocol.

> +
> +	/* For LSO:
> +	 * When software supplies two or more payload buffers all payload buffers
> +	 * apart from the last must be a multiple of 8 bytes in size.
> +	 */
> +	if (!IS_ALIGNED(skb_headlen(skb) - hdrlen, MACB_TX_LEN_ALIGN))
> +		return features & ~MACB_NETIF_LSO;
> +
> +	nr_frags = skb_shinfo(skb)->nr_frags;
> +	/* No need to check last fragment */
> +	nr_frags--;
> +	for (f = 0; f < nr_frags; f++) {
> +		const skb_frag_t *frag = &skb_shinfo(skb)->frags[f];
> +
> +		if (!IS_ALIGNED(skb_frag_size(frag), MACB_TX_LEN_ALIGN))
> +			return features & ~MACB_NETIF_LSO;
> +	}
> +	return features;
> +}
> +
>  static inline int macb_clear_csum(struct sk_buff *skb)
>  {
>  	/* no change for packets without checksum offloading */
> @@ -1374,7 +1456,27 @@ static int macb_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  	struct macb *bp = netdev_priv(dev);
>  	struct macb_queue *queue = &bp->queues[queue_index];
>  	unsigned long flags;
> -	unsigned int count, nr_frags, frag_size, f;
> +	unsigned int desc_cnt, nr_frags, frag_size, f;
> +	unsigned int is_lso = 0, is_udp, hdrlen;
> +
> +	is_lso = (skb_shinfo(skb)->gso_size != 0);
> +
> +	if (is_lso) {
> +		is_udp = (IPPROTO_UDP == (ip_hdr(skb)->protocol));

Same here, and you may want to declare is_udp as boolean and do this:

		is_udp = !!(ip_hdr(skb)->protocl == IPPROTO_UDP);

> +
> +		/* length of headers */
> +		if (is_udp)
> +			/* only queue eth + ip headers separately for UDP */
> +			hdrlen = skb_transport_offset(skb);
> +		else
> +			hdrlen = skb_transport_offset(skb) + tcp_hdrlen(skb);
> +		if (skb_headlen(skb) < hdrlen) {
> +			netdev_err(bp->dev, "Error - LSO headers fragmented!!!\n");
> +			/* if this is required, would need to copy to single buffer */
> +			return NETDEV_TX_BUSY;
> +		}

>  
> +	if (is_lso) {
> +		if (is_udp)
> +			/* zero UDP checksum, not calculated by h/w for UFO */
> +			udp_hdr(skb)->check = 0;

is_udp is only set when (is_lso) is checked, so the two conditions are
redundant, just checking is_udp should be enough?
-- 
Florian
