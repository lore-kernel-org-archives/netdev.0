From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] liquidio: replace skb_tx_hash with fallback
Date: Thu, 12 Jan 2017 11:10:18 -0800
Message-ID: <1484248218.3321.1.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170112184606.GA5503@felix.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        raghu.vatsavayi@cavium.com, derek.chickles@cavium.com,
        satananda.burla@cavium.com
To: Felix Manlunas <felix.manlunas@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34419 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750823AbdALUL5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 15:11:57 -0500
Received: by mail-pf0-f194.google.com with SMTP id y143so4848954pfb.1
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 12:11:57 -0800 (PST)
In-Reply-To: <20170112184606.GA5503@felix.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-01-12 at 10:46 -0800, Felix Manlunas wrote:
> From: Satanand Burla <satananda.burla@cavium.com>
> 
> Use fallback instead of skb_tx_hash for selecting txq
> 
> Signed-off-by: Satanand Burla <satananda.burla@cavium.com>
> Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
> Signed-off-by: Derek Chickles <derek.chickles@cavium.com>
> ---
>  drivers/net/ethernet/cavium/liquidio/lio_main.c    | 10 ++--------
>  drivers/net/ethernet/cavium/liquidio/lio_vf_main.c | 11 ++---------
>  2 files changed, 4 insertions(+), 17 deletions(-)
> 
> diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
> index b8b579d..90f000f 100644
> --- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
> +++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
> @@ -2231,15 +2231,9 @@ static void if_cfg_callback(struct octeon_device *oct,
>   */
>  static u16 select_q(struct net_device *dev, struct sk_buff *skb,
>  		    void *accel_priv __attribute__((unused)),
> -		    select_queue_fallback_t fallback __attribute__((unused)))
> +		    select_queue_fallback_t fallback)
>  {
> -	u32 qindex = 0;
> -	struct lio *lio;
> -
> -	lio = GET_LIO(dev);
> -	qindex = skb_tx_hash(dev, skb);
> -
> -	return (u16)(qindex % (lio->linfo.num_txpciq));
> +	return fallback(dev, skb);
>  }
>  
>  /** Routine to push packets arriving on Octeon interface upto network layer.
> diff --git a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
> index ad2e72d..a7478eb 100644
> --- a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
> +++ b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
> @@ -1463,16 +1463,9 @@ static void if_cfg_callback(struct octeon_device *oct,
>   */
>  static u16 select_q(struct net_device *dev, struct sk_buff *skb,
>  		    void *accel_priv __attribute__((unused)),
> -		    select_queue_fallback_t fallback __attribute__((unused)))
> +		    select_queue_fallback_t fallback)
>  {
> -	struct lio *lio;
> -	u32 qindex;
> -
> -	lio = GET_LIO(dev);
> -
> -	qindex = skb_tx_hash(dev, skb);
> -
> -	return (u16)(qindex % (lio->linfo.num_txpciq));
> +	return fallback(dev, skb);
>  }
>  
>  /** Routine to push packets arriving on Octeon interface upto network layer.


Why are you keeping these functions then ?

Remove them completely, and remove .ndo_select_queue from your ops.

Core networking stack will fallback automatically.
