From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH 6/6] stmmac: Replace infinite loops by timeouts in mdio
 r/w
Date: Tue, 06 Mar 2012 08:55:18 +0100
Message-ID: <4F55C2E6.8040204@st.com>
References: <1330692928-30330-1-git-send-email-deepak.sikri@st.com> <1330692928-30330-2-git-send-email-deepak.sikri@st.com> <1330692928-30330-3-git-send-email-deepak.sikri@st.com> <1330692928-30330-4-git-send-email-deepak.sikri@st.com> <1330692928-30330-5-git-send-email-deepak.sikri@st.com> <1330692928-30330-6-git-send-email-deepak.sikri@st.com> <1330692928-30330-7-git-send-email-deepak.sikri@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: spear-devel@list.st.com, netdev@vger.kernel.org
To: Deepak Sikri <deepak.sikri@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog109.obsmtp.com ([207.126.144.127]:36599 "EHLO
	eu1sys200aog109.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757910Ab2CFH4o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2012 02:56:44 -0500
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 7888A242
	for <netdev@vger.kernel.org>; Tue,  6 Mar 2012 07:56:42 +0000 (GMT)
Received: from mail7.sgp.st.com (mail7.sgp.st.com [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 0AF3116DB
	for <netdev@vger.kernel.org>; Tue,  6 Mar 2012 07:56:42 +0000 (GMT)
In-Reply-To: <1330692928-30330-7-git-send-email-deepak.sikri@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/2/2012 1:55 PM, Deepak Sikri wrote:
> This patch removes the infinite waits from the mdio read and
> write interfaces. These infinite waits have been replaced by
> the timeout handling. In case if a time out occurs, an error is
> returned.
> 
> Signed-off-by: Deepak Sikri <deepak.sikri@st.com>

Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

> ---
>  drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c |   30 ++++++++++++++++-----
>  1 files changed, 23 insertions(+), 7 deletions(-)
> 
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
> index 7319532..b6a6fb2 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
> @@ -34,6 +34,20 @@
>  #define MII_BUSY 0x00000001
>  #define MII_WRITE 0x00000002
>  
> +static int stmmac_mdio_busy_wait(unsigned long ioaddr, unsigned int mii_addr)
> +{
> +	unsigned long finish = jiffies + 3 * HZ;
> +
> +	do {
> +		if (readl(ioaddr + mii_addr) & MII_BUSY)
> +			cpu_relax();
> +		else
> +			return 0;
> +	} while (!time_after_eq(jiffies, finish));
> +
> +	return -EBUSY;
> +}
> +
>  /**
>   * stmmac_mdio_read
>   * @bus: points to the mii_bus structure
> @@ -56,9 +70,13 @@ static int stmmac_mdio_read(struct mii_bus *bus, int phyaddr, int phyreg)
>  			((phyreg << 6) & (0x000007C0)));
>  	regValue |= MII_BUSY | ((priv->plat->clk_csr & 7) << 2);
>  
> -	do {} while (((readl(priv->ioaddr + mii_address)) & MII_BUSY) == 1);
> +	if (stmmac_mdio_busy_wait(priv->ioaddr, mii_address))
> +		return -EBUSY;
> +
>  	writel(regValue, priv->ioaddr + mii_address);
> -	do {} while (((readl(priv->ioaddr + mii_address)) & MII_BUSY) == 1);
> +
> +	if (stmmac_mdio_busy_wait(priv->ioaddr, mii_address))
> +		return -EBUSY;
>  
>  	/* Read the data from the MII data register */
>  	data = (int)readl(priv->ioaddr + mii_data);
> @@ -88,18 +106,16 @@ static int stmmac_mdio_write(struct mii_bus *bus, int phyaddr, int phyreg,
>  
>  	value |= MII_BUSY | ((priv->plat->clk_csr & 7) << 2);
>  
> -
>  	/* Wait until any existing MII operation is complete */
> -	do {} while (((readl(priv->ioaddr + mii_address)) & MII_BUSY) == 1);
> +	if (stmmac_mdio_busy_wait(priv->ioaddr, mii_address))
> +		return -EBUSY;
>  
>  	/* Set the MII address register to write */
>  	writel(phydata, priv->ioaddr + mii_data);
>  	writel(value, priv->ioaddr + mii_address);
>  
>  	/* Wait until any existing MII operation is complete */
> -	do {} while (((readl(priv->ioaddr + mii_address)) & MII_BUSY) == 1);
> -
> -	return 0;
> +	return stmmac_mdio_busy_wait(priv->ioaddr, mii_address);
>  }
>  
>  /**
