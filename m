From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 1/2] ravb: Add tx and rx clock internal delays
 mode of APSR
Date: Fri, 27 Jan 2017 15:42:05 +0300
Message-ID: <813af981-9a1b-8e45-1fed-788047ab26b5@cogentembedded.com>
References: <1485515090-7570-1-git-send-email-horms+renesas@verge.net.au>
 <1485515090-7570-2-git-send-email-horms+renesas@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Magnus Damm <magnus.damm@gmail.com>, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org,
        Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
To: Simon Horman <horms+renesas@verge.net.au>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f52.google.com ([209.85.215.52]:34317 "EHLO
        mail-lf0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754799AbdA0MnV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 07:43:21 -0500
Received: by mail-lf0-f52.google.com with SMTP id v186so161309308lfa.1
        for <netdev@vger.kernel.org>; Fri, 27 Jan 2017 04:42:13 -0800 (PST)
In-Reply-To: <1485515090-7570-2-git-send-email-horms+renesas@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On 01/27/2017 02:04 PM, Simon Horman wrote:

> From: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
>
> This patch enables tx and rx clock internal delay modes (TDM and RDM).
>
> This is to address a failure in the case of 1Gbps communication using the
> by salvator-x board with the KSZ9031RNX phy. This has been reported to
> occur with both the r8a7795 (H3) and r8a7796 (M3-W) SoCs.
>
> With this change APSR internal delay modes are enabled for
> "rgmii-id", "rgmii-rxid" and "rgmii-txid" phy modes as follows:
>
> phy mode   | ASPR delay mode
> -----------+----------------
> rgmii-id   | TDM and RDM
> rgmii-rxid | RDM
> rgmii-txid | TDM
>
> Signed-off-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
> Signed-off-by: Simon Horman <horms+renesas@verge.net.au>
>
> ---
> v1 [Simon Horman]
> - Combined patches
> - Reworded changelog
>
> v0 [Kazuya Mizuguchi]
> ---
>  drivers/net/ethernet/renesas/ravb.h      | 10 ++++++++++
>  drivers/net/ethernet/renesas/ravb_main.c | 29 +++++++++++++++++++++++++++++
>  2 files changed, 39 insertions(+)
>
> diff --git a/drivers/net/ethernet/renesas/ravb.h b/drivers/net/ethernet/renesas/ravb.h
> index f1109661a533..d7c91d48cc48 100644
> --- a/drivers/net/ethernet/renesas/ravb.h
> +++ b/drivers/net/ethernet/renesas/ravb.h
[...]
> @@ -248,6 +249,15 @@ enum ESR_BIT {
>  	ESR_EIL		= 0x00001000,
>  };
>
> +/* APSR */
> +enum APSR_BIT {
> +	APSR_MEMS		= 0x00000002,

    Not documented in the revision 0.5 of the gen3 manual...

> +	APSR_CMSW		= 0x00000010,
> +	APSR_DM			= 0x00006000,

    ... and neither this field. Are these documented in the latter revs?

> +	APSR_DM_RDM		= 0x00002000,
> +	APSR_DM_TDM		= 0x00004000,
> +};
> +
>  /* RCR */
>  enum RCR_BIT {
>  	RCR_EFFS	= 0x00000001,
> diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
> index 89ac1e3f6175..9fb4c04c5885 100644
> --- a/drivers/net/ethernet/renesas/ravb_main.c
> +++ b/drivers/net/ethernet/renesas/ravb_main.c
> @@ -1904,6 +1904,29 @@ static void ravb_set_config_mode(struct net_device *ndev)
>  	}
>  }
>
> +static void ravb_set_delay_mode(struct net_device *ndev)
> +{
> +	struct ravb_private *priv = netdev_priv(ndev);
> +
> +	if (priv->chip_id != RCAR_GEN2) {
> +		switch (priv->phy_interface) {
> +		case PHY_INTERFACE_MODE_RGMII_ID:
> +			ravb_modify(ndev, APSR, APSR_DM, APSR_DM_RDM |
> +				   APSR_DM_TDM);
> +			break;
> +		case PHY_INTERFACE_MODE_RGMII_RXID:
> +			ravb_modify(ndev, APSR, APSR_DM, APSR_DM_RDM);
> +			break;
> +		case PHY_INTERFACE_MODE_RGMII_TXID:
> +			ravb_modify(ndev, APSR, APSR_DM, APSR_DM_TDM);
> +			break;
> +		default:
> +			ravb_modify(ndev, APSR, APSR_DM, 0);
> +			break;
> +		}

    How about doing ravb_modify() only once?

[...]

MNR, Sergei
