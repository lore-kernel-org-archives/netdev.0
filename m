From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH][net-next] gianfar: Fix reported sent bytes to BQL for
 Tx timestamping
Date: Mon, 29 Apr 2013 06:53:13 -0700
Message-ID: <1367243593.8964.306.camel@edumazet-glaptop>
References: <1367240268-32609-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	"David S. Miller" <davem@davemloft.net>
To: Claudiu Manoil <claudiu.manoil@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:41603 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752038Ab3D2NxQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Apr 2013 09:53:16 -0400
Received: by mail-pa0-f42.google.com with SMTP id kl13so3685466pab.1
        for <netdev@vger.kernel.org>; Mon, 29 Apr 2013 06:53:16 -0700 (PDT)
In-Reply-To: <1367240268-32609-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-04-29 at 15:57 +0300, Claudiu Manoil wrote:
> When Tx timestamping is enabled the number of sent bytes reported
> to BQL via tx_completed_queue() falls short by GMAC_FCB_LEN +
> GMAC_TXPAL_LEN than the number of bytes reported via tx_sent_queue()
> on xmit. This leads to BQL stopping transmission errorneously followed
> by tx timeout firing.
> 
> This fixes the amount of sent bytes reported to BQL on clean_tx_ring
> to match the amount reported on xmit, when Tx timestamping enabled.
> 
> Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
> ---
>  drivers/net/ethernet/freescale/gianfar.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
> index 2375a01..0d26a8b 100644
> --- a/drivers/net/ethernet/freescale/gianfar.c
> +++ b/drivers/net/ethernet/freescale/gianfar.c
> @@ -2539,6 +2539,7 @@ static void gfar_clean_tx_ring(struct gfar_priv_tx_q *tx_queue)
>  			skb_tstamp_tx(skb, &shhwtstamps);
>  			bdp->lstatus &= BD_LFLAG(TXBD_WRAP);
>  			bdp = next;
> +			bytes_sent += GMAC_FCB_LEN + GMAC_TXPAL_LEN;
>  		}
>  
>  		bdp->lstatus &= BD_LFLAG(TXBD_WRAP);

Technically speaking these bytes are not sent to the wire.

I would rather fix gfar_start_xmit() to give to netdev_tx_sent_queue()
call the correct amount of bytes on wire, to be consistent with other
drivers.
