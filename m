From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v3 4/5] bgmac: reset all cores on Northstar SoC
Date: Sun, 05 Jan 2014 17:10:04 +0400
Message-ID: <52C959AC.9000005@cogentembedded.com>
References: <1388880647-7611-1-git-send-email-hauke@hauke-m.de> <1388880647-7611-5-git-send-email-hauke@hauke-m.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: zajec5@gmail.com, netdev@vger.kernel.org
To: Hauke Mehrtens <hauke@hauke-m.de>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f169.google.com ([209.85.217.169]:47096 "EHLO
	mail-lb0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751050AbaAENKH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jan 2014 08:10:07 -0500
Received: by mail-lb0-f169.google.com with SMTP id u14so9342249lbd.0
        for <netdev@vger.kernel.org>; Sun, 05 Jan 2014 05:10:06 -0800 (PST)
In-Reply-To: <1388880647-7611-5-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 05-01-2014 4:10, Hauke Mehrtens wrote:

> On the Northstar SoC (BCM4707 and BCM53018) we have to enable all GMA=
C
> cores when we just want to use on. We iterate over all the cores and
> activate them.

> Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
> Acked-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
> ---
>   drivers/net/ethernet/broadcom/bgmac.c |   21 +++++++++++++++++++++
>   1 file changed, 21 insertions(+)

> diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethe=
rnet/broadcom/bgmac.c
> index 88ec69e..2cdacb8 100644
> --- a/drivers/net/ethernet/broadcom/bgmac.c
> +++ b/drivers/net/ethernet/broadcom/bgmac.c
> @@ -1446,6 +1446,27 @@ static int bgmac_probe(struct bcma_device *cor=
e)
>
>   	bgmac_chip_reset(bgmac);
>
> +	/* For Northstar, we have to take all GMAC core out of reset */
> +	if (core->id.id =3D=3D BCMA_CHIP_ID_BCM4707 ||
> +	    core->id.id =3D=3D BCMA_CHIP_ID_BCM53018) {
> +		struct bcma_device *ns_core;
> +		int ns_gmac;
> +
> +		/* Northstar has 4 GMAC cores */
> +		for (ns_gmac =3D 0; ns_gmac < 4; ns_gmac++) {
> +			/* As northstar requirement, we have to reset all GAMCs

    Sorry for grammar nitpicking but s/GAMCs/GMACs/? And "northstar" pr=
obaby=20
should be capitalized.

> +			 * before accessing one. bgmac_chip_reset() call
> +			 * bcma_core_enable() for this core. Then the other
> +			 * three GAMCs didn't reset.  We do it here.

    GMACs again?

> +			 */
> +			ns_core =3D bcma_find_core_unit(core->bus,
> +						      BCMA_CORE_MAC_GBIT,
> +						      ns_gmac);
> +			if (ns_core && !bcma_core_is_enabled(ns_core))
> +				bcma_core_enable(ns_core, 0);
> +		}
> +	}
> +

WBR, Sergei
