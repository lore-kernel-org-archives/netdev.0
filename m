From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] ravb: Add missing free_irq() calls to ravb_close()
Date: Wed, 4 May 2016 16:30:09 +0300
Message-ID: <5729F961.2050603@cogentembedded.com>
References: <1462366987-18418-1-git-send-email-geert+renesas@glider.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Yoshihiro Kaneko <ykaneko0929@gmail.com>,
	Simon Horman <horms+renesas@verge.net.au>,
	netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org
To: Geert Uytterhoeven <geert+renesas@glider.be>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f46.google.com ([209.85.215.46]:34666 "EHLO
	mail-lf0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750857AbcEDNaO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 09:30:14 -0400
Received: by mail-lf0-f46.google.com with SMTP id m64so59791790lfd.1
        for <netdev@vger.kernel.org>; Wed, 04 May 2016 06:30:13 -0700 (PDT)
In-Reply-To: <1462366987-18418-1-git-send-email-geert+renesas@glider.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 05/04/2016 04:03 PM, Geert Uytterhoeven wrote:

> When reopening the network device on ra7795/salvator-x, e.g. after a
> DHCP timeout:
>
>      IP-Config: Reopening network devices...
>      genirq: Flags mismatch irq 139. 00000000 (eth0:ch24:emac) vs. 00000000 (eth0:ch24:emac)
>      ravb e6800000.ethernet eth0: cannot request IRQ eth0:ch24:emac
>      IP-Config: Failed to open eth0
>      IP-Config: No network devices available
>
> The "mismatch" is due to requesting an IRQ that is already in use,
> while IRQF_PROBE_SHARED wasn't set.
>
> However, the real cause is that ravb_close() doesn't release any of the
> R-Car Gen3-specific secondary IRQs.
>
> Add the missing free_irq() calls to fix this.
>
> Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>

    This patch must be against net-next.git but you because the patch that 
this one fixes is only there. You never indicated that. I'd also appreciate if 
you specify the Fixed: tag.

> ---
>   drivers/net/ethernet/renesas/ravb_main.c | 7 +++++++
>   1 file changed, 7 insertions(+)
>
> diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
> index 34066e0649f5c673..867caf6e7a5a65ad 100644
> --- a/drivers/net/ethernet/renesas/ravb_main.c
> +++ b/drivers/net/ethernet/renesas/ravb_main.c
> @@ -1667,6 +1667,13 @@ static int ravb_close(struct net_device *ndev)
>   		priv->phydev = NULL;
>   	}
>
> +	if (priv->chip_id != RCAR_GEN2) {
> +		free_irq(priv->tx_irqs[RAVB_NC], ndev);
> +		free_irq(priv->rx_irqs[RAVB_NC], ndev);
> +		free_irq(priv->tx_irqs[RAVB_BE], ndev);
> +		free_irq(priv->rx_irqs[RAVB_BE], ndev);

    Shame on me for not noticing this. :-(

> +		free_irq(priv->emac_irq, ndev);

    However, net.git is also affected, it only calls free_irq() on 'ndev->irq'.
Please submit 2 separate fixes against net.git and net-next.git.

> +	}
>   	free_irq(ndev->irq, ndev);
>
>   	napi_disable(&priv->napi[RAVB_NC]);
>

MBR, Sergei
