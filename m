From: "Kalluru, Sudarsana" <Sudarsana.Kalluru@cavium.com>
Subject: RE: [PATCH net 2/3] qed: Fix overriding of supported autoneg value.
Date: Thu, 4 May 2017 08:02:52 +0000
Message-ID: <CY4PR07MB3048164CC90E3486981CDA5F8AEA0@CY4PR07MB3048.namprd07.prod.outlook.com>
References: <20170504065209.26106-1-sudarsana.kalluru@cavium.com>
 <20170504065209.26106-3-sudarsana.kalluru@cavium.com>
 <20170504072051.GP22833@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Mintz, Yuval" <Yuval.Mintz@cavium.com>
To: Leon Romanovsky <leon@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0053.outbound.protection.outlook.com ([104.47.37.53]:49376
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750922AbdEDICz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 4 May 2017 04:02:55 -0400
In-Reply-To: <20170504072051.GP22833@mtr-leonro.local>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



-----Original Message-----
From: Leon Romanovsky [mailto:leon@kernel.org]=20
Sent: 04 May 2017 12:51
To: Kalluru, Sudarsana <Sudarsana.Kalluru@cavium.com>
Cc: davem@davemloft.net; netdev@vger.kernel.org; Mintz, Yuval <Yuval.Mintz@=
cavium.com>
Subject: Re: [PATCH net 2/3] qed: Fix overriding of supported autoneg value=
.

On Wed, May 03, 2017 at 11:52:08PM -0700, Sudarsana Reddy Kalluru wrote:
> Driver currently uses advertised-autoneg value to populate the=20
> supported-autoneg field. When advertised field is updated, user gets=20
> the same value for supported field. Supported-autoneg value need to be=20
> populated from the link capabilities value returned by the MFW.
>
> Signed-off-by: Sudarsana Reddy Kalluru <Sudarsana.Kalluru@cavium.com>
> ---
>  drivers/net/ethernet/qlogic/qed/qed_dev.c  | 3 +++ =20
> drivers/net/ethernet/qlogic/qed/qed_main.c | 6 +++++- =20
> drivers/net/ethernet/qlogic/qed/qed_mcp.h  | 1 +
>  3 files changed, 9 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c=20
> b/drivers/net/ethernet/qlogic/qed/qed_dev.c
> index 5c6874a..bb70522 100644
> --- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
> +++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
> @@ -2536,6 +2536,9 @@ static int qed_hw_get_nvm_info(struct qed_hwfn *p_h=
wfn, struct qed_ptt *p_ptt)
>  		DP_NOTICE(p_hwfn, "Unknown Speed in 0x%08x\n", link_temp);
>  	}
>
> +	p_hwfn->mcp_info->link_capabilities.default_speed_autoneg =3D
> +		link->speed.autoneg;
> +
>  	link_temp &=3D NVM_CFG1_PORT_DRV_FLOW_CONTROL_MASK;
>  	link_temp >>=3D NVM_CFG1_PORT_DRV_FLOW_CONTROL_OFFSET;
>  	link->pause.autoneg =3D !!(link_temp & diff --git=20
> a/drivers/net/ethernet/qlogic/qed/qed_main.c=20
> b/drivers/net/ethernet/qlogic/qed/qed_main.c
> index a5eef1a..b7ad36b 100644
> --- a/drivers/net/ethernet/qlogic/qed/qed_main.c
> +++ b/drivers/net/ethernet/qlogic/qed/qed_main.c
> @@ -1372,7 +1372,7 @@ static void qed_fill_link(struct qed_hwfn *hwfn,
>
>  	/* TODO - at the moment assume supported and advertised speed equal */
>  	if_link->supported_caps =3D QED_LM_FIBRE_BIT;
> -	if (params.speed.autoneg)
> +	if (link_caps.default_speed_autoneg)
>  		if_link->supported_caps |=3D QED_LM_Autoneg_BIT;
>  	if (params.pause.autoneg ||
>  	    (params.pause.forced_rx && params.pause.forced_tx)) @@ -1382,6=20
> +1382,10 @@ static void qed_fill_link(struct qed_hwfn *hwfn,
>  		if_link->supported_caps |=3D QED_LM_Pause_BIT;
>
>  	if_link->advertised_caps =3D if_link->supported_caps;
> +	if (params.speed.autoneg)
> +		if_link->advertised_caps |=3D QED_LM_Autoneg_BIT;
> +	else
> +		if_link->advertised_caps &=3D ~QED_LM_Autoneg_BIT;
>  	if (params.speed.advertised_speeds &
>  	    NVM_CFG1_PORT_DRV_SPEED_CAPABILITY_MASK_1G)
>  		if_link->advertised_caps |=3D QED_LM_1000baseT_Half_BIT | diff --git=20
> a/drivers/net/ethernet/qlogic/qed/qed_mcp.h=20
> b/drivers/net/ethernet/qlogic/qed/qed_mcp.h
> index 5ae35d6..937496d 100644
> --- a/drivers/net/ethernet/qlogic/qed/qed_mcp.h
> +++ b/drivers/net/ethernet/qlogic/qed/qed_mcp.h
> @@ -61,6 +61,7 @@ struct qed_mcp_link_params {
>
>  struct qed_mcp_link_capabilities {
>  	u32 speed_capabilities;
> +	bool default_speed_autoneg;	/* In Mb/s */

bool variable in Mb/s ?????

Thanks. It's an incorrect comment.

Dave, please let us know if re-spin is required for this. If not required, =
will plan to clean it up in the next series.

>  };
>
>  struct qed_mcp_link_state {
> --
> 1.8.3.1
>
