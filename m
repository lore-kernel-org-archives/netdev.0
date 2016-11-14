From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH net] net: stmmac: Fix lack of link transition for fixed
 PHYs
Date: Mon, 14 Nov 2016 08:42:45 +0100
Message-ID: <e62d0f81-88c3-610d-7501-5c2b8821b447@st.com>
References: <20161114015036.6926-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, Alexandre Torgue <alexandre.torgue@st.com>,
        open list <linux-kernel@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:36209 "EHLO
        mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752739AbcKNHmy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2016 02:42:54 -0500
In-Reply-To: <20161114015036.6926-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/14/2016 2:50 AM, Florian Fainelli wrote:
> Commit 52f95bbfcf72 ("stmmac: fix adjust link call in case of a switch
> is attached") added some logic to avoid polling the fixed PHY and
> therefore invoking the adjust_link callback more than once, since this
> is a fixed PHY and link events won't be generated.
>
> This works fine the first time, because we start with phydev->irq =
> PHY_POLL, so we call adjust_link, then we set phydev->irq =
> PHY_IGNORE_INTERRUPT and we stop polling the PHY.
>
> Now, if we called ndo_close(), which calls both phy_stop() and does an
> explicit netif_carrier_off(), we end up with a link down. Upon calling
> ndo_open() again, despite starting the PHY state machine, we have
> PHY_IGNORE_INTERRUPT set, and we generate no link event at all, so the
> link is permanently down.
>
> 52f95bbfcf72 ("stmmac: fix adjust link call in case of a switch is attached")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
> Alexandre, Peppe,
>
> The original patch is already a hack, but since this is a bugfix, I took the
> same approach that you did here to backport this to -stable kernels.


Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

>
>  drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 7 +++++++
>  1 file changed, 7 insertions(+)
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> index 10909c9c0033..03dbf8e89c4c 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
> @@ -882,6 +882,13 @@ static int stmmac_init_phy(struct net_device *dev)
>  		return -ENODEV;
>  	}
>
> +	/* stmmac_adjust_link will change this to PHY_IGNORE_INTERRUPT to avoid
> +	 * subsequent PHY polling, make sure we force a link transition if
> +	 * we have a UP/DOWN/UP transition
> +	 */
> +	if (phydev->is_pseudo_fixed_link)
> +		phydev->irq = PHY_POLL;
> +
>  	pr_debug("stmmac_init_phy:  %s: attached to PHY (UID 0x%x)"
>  		 " Link = %d\n", dev->name, phydev->phy_id, phydev->link);
>
>
