From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: Re: [PATCH v3] net: stmmac: fix maxmtu assignment to be within valid
 range
Date: Fri, 6 Jan 2017 16:57:55 +0000
Message-ID: <a7c3212f-1772-8e07-b9a3-3ebbb4150fc7@synopsys.com>
References: <1483750143-11966-1-git-send-email-hock.leong.kweh@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: Alexandre TORGUE <alexandre.torgue@gmail.com>,
        Joachim Eastwood <manabian@gmail.com>,
        Niklas Cassel <niklas.cassel@axis.com>,
        Johan Hovold <johan@kernel.org>, <pavel@ucw.cz>,
        <lars.persson@axis.com>, netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
To: "Kweh, Hock Leong" <hock.leong.kweh@intel.com>,
        "David S. Miller" <davem@davemloft.net>,
        Joao Pinto <Joao.Pinto@synopsys.com>,
        "Giuseppe CAVALLARO" <peppe.cavallaro@st.com>,
        <seraphin.bonnaffe@st.com>, Jarod Wilson <jarod@redhat.com>,
        Andy Shevchenko <andy.shevchenko@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1483750143-11966-1-git-send-email-hock.leong.kweh@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi Wilson,

Às 12:49 AM de 1/7/2017, Kweh, Hock Leong escreveu:
> From: "Kweh, Hock Leong" <hock.leong.kweh@intel.com>
> 
> There is no checking valid value of maxmtu when getting it from device tree.
> This resolution added the checking condition to ensure the assignment is
> made within a valid range.
> 
> Signed-off-by: Kweh, Hock Leong <hock.leong.kweh@intel.com>
> ---
> changelog v3:
> * print the warning message only if maxmtu < min_mtu
> * add maxmtu = JUMBO_LEN at stmmac_pci.c to follow stmmac_platform.c
> 
> changelog v2:
> * correction of "devicetree" to "device tree" reported by Andy
> * print warning message while maxmtu is not in valid range
> 
>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    8 +++++++-
>  drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c  |    4 ++++
>  2 files changed, 11 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index 92ac006..ce74ae6 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -3345,8 +3345,14 @@ int stmmac_dvr_probe(struct device *device,
>  		ndev->max_mtu = JUMBO_LEN;
>  	else
>  		ndev->max_mtu = SKB_MAX_HEAD(NET_SKB_PAD + NET_IP_ALIGN);
> -	if (priv->plat->maxmtu < ndev->max_mtu)
> +
> +	if ((priv->plat->maxmtu < ndev->max_mtu) &&
> +	    (priv->plat->maxmtu >= ndev->min_mtu))
>  		ndev->max_mtu = priv->plat->maxmtu;
> +	else if (priv->plat->maxmtu < ndev->min_mtu)
> +		netdev_warn(priv->dev,
> +			    "%s: warning: maxmtu having invalid value (%d)\n",
> +			    __func__, priv->plat->maxmtu);
>  
>  	if (flow_ctrl)
>  		priv->flow_ctrl = FLOW_AUTO;	/* RX/TX pause on */
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
> index a283177..e539afe 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
> @@ -204,6 +204,10 @@ static int stmmac_pci_probe(struct pci_dev *pdev,
>  
>  	pci_set_master(pdev);
>  
> +	/* Set the maxmtu to a default of JUMBO_LEN in case the
> +	 * parameter is not defined for the device.
> +	 */
> +	plat->maxmtu = JUMBO_LEN;

I suggest to put this configuration in one of the default config functions.

Tahnks.

>  	if (info) {
>  		info->pdev = pdev;
>  		if (info->setup) {
> 
