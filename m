From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next 05/10] igb: Update igb to use a path similar to ixgbe
 to determine when to stop Tx
Date: Fri, 08 Feb 2013 04:26:09 -0800
Message-ID: <1360326369.28557.95.camel@edumazet-glaptop>
References: <1360319958-10497-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1360319958-10497-6-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f51.google.com ([209.85.210.51]:56507 "EHLO
	mail-da0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758100Ab3BHM0N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2013 07:26:13 -0500
Received: by mail-da0-f51.google.com with SMTP id n15so1743229dad.24
        for <netdev@vger.kernel.org>; Fri, 08 Feb 2013 04:26:12 -0800 (PST)
In-Reply-To: <1360319958-10497-6-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-02-08 at 02:39 -0800, Jeff Kirsher wrote:
> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> After reviewing the igb and ixgbe code I realized there are a few issues in
> how the code is structured.  Specifically we are not checking the size of the
> buffers being used in transmits and we are not using the same value to
> determine when to stop or start a Tx queue.  As such the code is prone to be
> buggy.
> 
> This patch makes it so that we have one value DESC_NEEDED that we will use for
> starting and stopping the queue.  In addition we will check the size of
> buffers being used when setting up a transmit so as to avoid a possible buffer
> overrun if we were to receive a frame with a block of data larger than 32K in
> skb->data.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Tested-by: Aaron Brown <aaron.f.brown@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/ethernet/intel/igb/igb.h      | 13 +++++++++++--
>  drivers/net/ethernet/intel/igb/igb_main.c | 32 ++++++++++++++++++-------------
>  2 files changed, 30 insertions(+), 15 deletions(-)
> 
> diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
> index afdb8bb..d27edbc 100644
> --- a/drivers/net/ethernet/intel/igb/igb.h
> +++ b/drivers/net/ethernet/intel/igb/igb.h
> @@ -139,8 +139,6 @@ struct vf_data_storage {
>  #define IGB_RX_HDR_LEN		IGB_RXBUFFER_256
>  #define IGB_RX_BUFSZ		IGB_RXBUFFER_2048
>  
> -/* How many Tx Descriptors do we need to call netif_wake_queue ? */
> -#define IGB_TX_QUEUE_WAKE	16
>  /* How many Rx Buffers do we bundle into one write to the hardware ? */
>  #define IGB_RX_BUFFER_WRITE	16	/* Must be power of 2 */
>  
> @@ -169,6 +167,17 @@ enum igb_tx_flags {
>  #define IGB_TX_FLAGS_VLAN_MASK		0xffff0000
>  #define IGB_TX_FLAGS_VLAN_SHIFT	16
>  
> +/*
> + * The largest size we can write to the descriptor is 65535.  In order to
> + * maintain a power of two alignment we have to limit ourselves to 32K.
> + */
> +#define IGB_MAX_TXD_PWR	15
> +#define IGB_MAX_DATA_PER_TXD	(1 << IGB_MAX_TXD_PWR)
> +
> +/* Tx Descriptors needed, worst case */
> +#define TXD_USE_COUNT(S) DIV_ROUND_UP((S), IGB_MAX_DATA_PER_TXD)
> +#define DESC_NEEDED (MAX_SKB_FRAGS + 4)
> +
>  /* wrapper around a pointer to a socket buffer,
>   * so a DMA handle can be stored along with the buffer */
>  struct igb_tx_buffer {
> diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
> index ebf8384..e69dd4f 100644
> --- a/drivers/net/ethernet/intel/igb/igb_main.c
> +++ b/drivers/net/ethernet/intel/igb/igb_main.c
> @@ -4434,13 +4434,6 @@ static void igb_tx_olinfo_status(struct igb_ring *tx_ring,
>  	tx_desc->read.olinfo_status = cpu_to_le32(olinfo_status);
>  }
>  
> -/*
> - * The largest size we can write to the descriptor is 65535.  In order to
> - * maintain a power of two alignment we have to limit ourselves to 32K.
> - */
> -#define IGB_MAX_TXD_PWR	15
> -#define IGB_MAX_DATA_PER_TXD	(1<<IGB_MAX_TXD_PWR)
> -
>  static void igb_tx_map(struct igb_ring *tx_ring,
>  		       struct igb_tx_buffer *first,
>  		       const u8 hdr_len)
> @@ -4609,15 +4602,27 @@ netdev_tx_t igb_xmit_frame_ring(struct sk_buff *skb,
>  	struct igb_tx_buffer *first;
>  	int tso;
>  	u32 tx_flags = 0;
> +#if PAGE_SIZE > IGB_MAX_DATA_PER_TXD
> +	unsigned short f;
> +#endif
> +	u16 count = TXD_USE_COUNT(skb_headlen(skb));
>  	__be16 protocol = vlan_get_protocol(skb);
>  	u8 hdr_len = 0;
>  
> -	/* need: 1 descriptor per page,
> +	/*
> +	 * need: 1 descriptor per page * PAGE_SIZE/IGB_MAX_DATA_PER_TXD,
> +	 *       + 1 desc for skb_headlen/IGB_MAX_DATA_PER_TXD,
>  	 *       + 2 desc gap to keep tail from touching head,
> -	 *       + 1 desc for skb->data,
>  	 *       + 1 desc for context descriptor,
> -	 * otherwise try next time */
> -	if (igb_maybe_stop_tx(tx_ring, skb_shinfo(skb)->nr_frags + 4)) {
> +	 * otherwise try next time
> +	 */
> +#if PAGE_SIZE > IGB_MAX_DATA_PER_TXD

This code assumes a frag is at most PAGE_SIZE, but its not true.

> +	for (f = 0; f < skb_shinfo(skb)->nr_frags; f++)
> +		count += TXD_USE_COUNT(skb_shinfo(skb)->frags[f].size);
> +#else
> +	count += skb_shinfo(skb)->nr_frags;
> +#endif

Current practical limit is 32768 bytes on x86
