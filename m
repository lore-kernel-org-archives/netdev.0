From: "Kweh, Hock Leong" <hock.leong.kweh@intel.com>
Subject: RE: [PATCH net] net: stmmac: Fix error path after register_netdev
 move
Date: Thu, 29 Dec 2016 09:36:57 +0000
Message-ID: <F54AEECA5E2B9541821D670476DAE19C5A917127@PGSMSX102.gar.corp.intel.com>
References: <20161228234441.5026-1-f.fainelli@gmail.com>
 <D6759987A7968C4889FDA6FA91D5CBC801CA3364@PGSMSX103.gar.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Joao.Pinto@synopsys.com" <Joao.Pinto@synopsys.com>,
        "peppe.cavallaro@st.com" <peppe.cavallaro@st.com>,
        "seraphin.bonnaffe@st.com" <seraphin.bonnaffe@st.com>,
        "alexandre.torgue@gmail.com" <alexandre.torgue@gmail.com>,
        "manabian@gmail.com" <manabian@gmail.com>,
        "niklas.cassel@axis.com" <niklas.cassel@axis.com>,
        "johan@kernel.org" <johan@kernel.org>,
        "pavel@ucw.cz" <pavel@ucw.cz>,
        "Ong, Boon Leong" <boon.leong.ong@intel.com>,
        "Voon, Weifeng" <weifeng.voon@intel.com>,
        "lars.persson@axis.com" <lars.persson@axis.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>
To: Florian Fainelli <f.fainelli@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:29182 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752723AbcL2Jin (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 29 Dec 2016 04:38:43 -0500
In-Reply-To: <D6759987A7968C4889FDA6FA91D5CBC801CA3364@PGSMSX103.gar.corp.intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Florian Fainelli [mailto:f.fainelli@gmail.com]
> Sent: Thursday, December 29, 2016 7:45 AM
> To: netdev@vger.kernel.org
> Cc: Florian Fainelli <f.fainelli@gmail.com>; pavel@ucw.cz;
> Joao.Pinto@synopsys.com; seraphin.bonnaffe@st.com;
> alexandre.torgue@gmail.com; manabian@gmail.com; niklas.cassel@axis.com;
> johan@kernel.org; Ong, Boon Leong <boon.leong.ong@intel.com>; Voon,
> Weifeng <weifeng.voon@intel.com>; lars.persson@axis.com; linux-
> kernel@vger.kernel.org; Giuseppe Cavallaro <peppe.cavallaro@st.com>;
> Alexandre Torgue <alexandre.torgue@st.com>
> Subject: [PATCH net] net: stmmac: Fix error path after register_netdev move
> 
> Commit 5701659004d6 ("net: stmmac: Fix race between stmmac_drv_probe and
> stmmac_open") re-ordered how the MDIO bus registration and the network
> device are registered, but missed to unwind the MDIO bus registration in case
> we fail to register the network device.
> 
> Fixes: 5701659004d6 ("net: stmmac: Fix race between stmmac_drv_probe and
> stmmac_open")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---

Acked-by: Kweh, Hock Leong <hock.leong.kweh@intel.com>



>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 9 ++++++++-
>  1 file changed, 8 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index 5910ea51f8f6..39eb7a65bb9f 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -3366,12 +3366,19 @@ int stmmac_dvr_probe(struct device *device,
>  	}
> 
>  	ret = register_netdev(ndev);
> -	if (ret)
> +	if (ret) {
>  		netdev_err(priv->dev, "%s: ERROR %i registering the device\n",
>  			   __func__, ret);
> +		goto error_netdev_register;
> +	}
> 
>  	return ret;
> 
> +error_netdev_register:
> +	if (priv->hw->pcs != STMMAC_PCS_RGMII &&
> +	    priv->hw->pcs != STMMAC_PCS_TBI &&
> +	    priv->hw->pcs != STMMAC_PCS_RTBI)
> +		stmmac_mdio_unregister(ndev);
>  error_mdio_register:
>  	netif_napi_del(&priv->napi);
>  error_hw_init:
> --
> 2.9.3
