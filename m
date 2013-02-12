From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH net-next 2/5] gianfar: Cleanup and optimize struct gfar_private
Date: Tue, 12 Feb 2013 10:11:31 -0500
Message-ID: <511A5BA3.4020306@windriver.com>
References: <1360673237-349-1-git-send-email-claudiu.manoil@freescale.com> <1360673237-349-2-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>
To: Claudiu Manoil <claudiu.manoil@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:56310 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760612Ab3BLPLD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2013 10:11:03 -0500
In-Reply-To: <1360673237-349-2-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13-02-12 07:47 AM, Claudiu Manoil wrote:
> * group run-time critical fields within the 1st cacheline
>   followed by the tx|rx_queue reference arrays and the interrupt
>   group instances (gfargrp) (all cacheline aligned)
> * change 'padding' from unsigned short to u16
> * clear 20+ byte memory hole

Per prev. mail, it gets harder to see which change is where,
when they are all lumped together like this.  For example, it
wasn't obvious to me where the 20 byte hole was.  Also, it
doesn't look like you changed the padding, but rather instead
totally re-purposed it, leaving no alignment padding after the
uchar bitfields (where it was originally).

P.
--

> * group releated members
> * push non-critical fields at the end of the struct
> 
> Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
> ---
>  drivers/net/ethernet/freescale/gianfar.h |   93 +++++++++++++++--------------
>  1 files changed, 48 insertions(+), 45 deletions(-)
> 
> diff --git a/drivers/net/ethernet/freescale/gianfar.h b/drivers/net/ethernet/freescale/gianfar.h
> index 22c2f7a..5304a58 100644
> --- a/drivers/net/ethernet/freescale/gianfar.h
> +++ b/drivers/net/ethernet/freescale/gianfar.h
> @@ -1054,28 +1054,64 @@ enum gfar_errata {
>   * the buffer descriptor determines the actual condition.
>   */
>  struct gfar_private {
> -
> -	/* Indicates how many tx, rx queues are enabled */
> -	unsigned int num_tx_queues;
>  	unsigned int num_rx_queues;
> -	unsigned int num_grps;
> -	unsigned int mode;
> -
> -	/* The total tx and rx ring size for the enabled queues */
> -	unsigned int total_tx_ring_size;
> -	unsigned int total_rx_ring_size;
>  
>  	struct device *dev;
>  	struct net_device *ndev;
> -	struct platform_device *ofdev;
>  	enum gfar_errata errata;
> +	unsigned int rx_buffer_size;
> +
> +	u16 padding;
> +
> +	/* HW time stamping enabled flag */
> +	int hwts_rx_en;
> +	int hwts_tx_en;
>  
> -	struct gfar_priv_grp gfargrp[MAXGROUPS];
>  	struct gfar_priv_tx_q *tx_queue[MAX_TX_QS];
>  	struct gfar_priv_rx_q *rx_queue[MAX_RX_QS];
> +	struct gfar_priv_grp gfargrp[MAXGROUPS];
> +
> +	u32 device_flags;
> +
> +	unsigned int mode;
> +	unsigned int num_tx_queues;
> +	unsigned int num_grps;
> +
> +	/* Network Statistics */
> +	struct gfar_extra_stats extra_stats;
> +
> +	/* PHY stuff */
> +	phy_interface_t interface;
> +	struct device_node *phy_node;
> +	struct device_node *tbi_node;
> +	struct phy_device *phydev;
> +	struct mii_bus *mii_bus;
> +	int oldspeed;
> +	int oldduplex;
> +	int oldlink;
> +
> +	/* Bitfield update lock */
> +	spinlock_t bflock;
> +
> +	uint32_t msg_enable;
> +
> +	struct work_struct reset_task;
> +
> +	struct platform_device *ofdev;
> +	unsigned char
> +		extended_hash:1,
> +		bd_stash_en:1,
> +		rx_filer_enable:1,
> +		/* Wake-on-LAN enabled */
> +		wol_en:1,
> +		/* Enable priorty based Tx scheduling in Hw */
> +		prio_sched_en:1;
> +
> +	/* The total tx and rx ring size for the enabled queues */
> +	unsigned int total_tx_ring_size;
> +	unsigned int total_rx_ring_size;
>  
>  	/* RX per device parameters */
> -	unsigned int rx_buffer_size;
>  	unsigned int rx_stash_size;
>  	unsigned int rx_stash_index;
>  
> @@ -1094,39 +1130,6 @@ struct gfar_private {
>  	unsigned int fifo_starve;
>  	unsigned int fifo_starve_off;
>  
> -	/* Bitfield update lock */
> -	spinlock_t bflock;
> -
> -	phy_interface_t interface;
> -	struct device_node *phy_node;
> -	struct device_node *tbi_node;
> -	u32 device_flags;
> -	unsigned char
> -		extended_hash:1,
> -		bd_stash_en:1,
> -		rx_filer_enable:1,
> -		wol_en:1, /* Wake-on-LAN enabled */
> -		prio_sched_en:1; /* Enable priorty based Tx scheduling in Hw */
> -	unsigned short padding;
> -
> -	/* PHY stuff */
> -	struct phy_device *phydev;
> -	struct mii_bus *mii_bus;
> -	int oldspeed;
> -	int oldduplex;
> -	int oldlink;
> -
> -	uint32_t msg_enable;
> -
> -	struct work_struct reset_task;
> -
> -	/* Network Statistics */
> -	struct gfar_extra_stats extra_stats;
> -
> -	/* HW time stamping enabled flag */
> -	int hwts_rx_en;
> -	int hwts_tx_en;
> -
>  	/*Filer table*/
>  	unsigned int ftp_rqfpr[MAX_FILER_IDX + 1];
>  	unsigned int ftp_rqfcr[MAX_FILER_IDX + 1];
> 
