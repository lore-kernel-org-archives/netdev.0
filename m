From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCHv3 2/6] sh_eth: add generic wake-on-lan support via magic
 packet
Date: Thu, 12 Jan 2017 15:55:54 +0300
Message-ID: <4842b7e9-70a6-03ff-3ca0-36fbd1dcf4a3@cogentembedded.com>
References: <20170109153409.13956-1-niklas.soderlund+renesas@ragnatech.se>
 <20170109153409.13956-3-niklas.soderlund+renesas@ragnatech.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Geert Uytterhoeven <geert@linux-m68k.org>, linux-pm@vger.kernel.org
To: =?UTF-8?Q?Niklas_S=c3=b6derlund?=
        <niklas.soderlund+renesas@ragnatech.se>,
        Simon Horman <horms+renesas@verge.net.au>,
        netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org
Return-path: <linux-pm-owner@vger.kernel.org>
In-Reply-To: <20170109153409.13956-3-niklas.soderlund+renesas@ragnatech.se>
Sender: linux-pm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

On 01/09/2017 06:34 PM, Niklas Söderlund wrote:

> Add generic functionality to support Wake-on-LAN using MagicPacket which
> are supported by at least a few versions of sh_eth. Only add
> functionality for WoL, no specific sh_eth versions are marked to support
> WoL yet.
>
> WoL is enabled in the suspend callback by setting MagicPacket detection
> and disabling all interrupts expect MagicPacket. In the resume path the
> driver needs to reset the hardware to rearm the WoL logic, this prevents
> the driver from simply restoring the registers and to take advantage of
> that sh_eth was not suspended to reduce resume time. To reset the
> hardware the driver closes and reopens the device just like it would do
> in a normal suspend/resume scenario without WoL enabled, but it both
> closes and opens the device in the resume callback since the device
> needs to be open for WoL to work.
>
> One quirk needed for WoL is that the module clock needs to be prevented
> from being switched off by Runtime PM. To keep the clock alive the
> suspend callback need to call clk_enable() directly to increase the
> usage count of the clock. Then when Runtime PM decreases the clock usage
> count it won't reach 0 and be switched off.
>
> Signed-off-by: Niklas Söderlund <niklas.soderlund+renesas@ragnatech.se>
> ---
>  drivers/net/ethernet/renesas/sh_eth.c | 114 +++++++++++++++++++++++++++++++---
>  drivers/net/ethernet/renesas/sh_eth.h |   3 +
>  2 files changed, 109 insertions(+), 8 deletions(-)
>
> diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
> index 8a784dce45fa..542c92b57b35 100644
> --- a/drivers/net/ethernet/renesas/sh_eth.c
> +++ b/drivers/net/ethernet/renesas/sh_eth.c
> @@ -1552,6 +1552,8 @@ static void sh_eth_emac_interrupt(struct net_device *ndev)
>  			sh_eth_rcv_snd_enable(ndev);
>  		}
>  	}
> +	if (felic_stat & ECSR_MPD)
> +		pm_wakeup_event(&mdp->pdev->dev, 0);

    Hum, seeing a corner case: if we're ignoring the link interrupt (and it 
does occur along with ECSR.MPD, we'll return and miss this check. It would 
have been preferable to add this code above the ECSR.LCHNG handler...

[...]
> @@ -3150,15 +3189,67 @@ static int sh_eth_drv_remove(struct platform_device *pdev)
>
>  #ifdef CONFIG_PM
>  #ifdef CONFIG_PM_SLEEP
> +static int sh_eth_wol_setup(struct net_device *ndev)
> +{
> +	struct sh_eth_private *mdp = netdev_priv(ndev);
> +
> +	/* Only allow ECI interrupts */
> +	synchronize_irq(ndev->irq);
> +	napi_disable(&mdp->napi);
> +	sh_eth_write(ndev, DMAC_M_ECI, EESIPR);
> +
> +	/* Enable MagicPacket */
> +	sh_eth_modify(ndev, ECMR, 0, ECMR_MPDE);

    I'd prefer sh_eth_modify(ndev, ECMR, ECMR_MPDE, ECMR_MPDE) to be 
consistent with my other code...

[...]

MBR, Sergei

