From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 1/4] drivers: net: xgene-v2: Add MDIO support
Date: Tue, 21 Mar 2017 21:35:50 +0100
Message-ID: <20170321203550.GD30655@lunn.ch>
References: <1490124283-10371-1-git-send-email-isubramanian@apm.com>
 <1490124283-10371-2-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, f.fainelli@gmail.com,
        David.Laight@aculab.com, linux-arm-kernel@lists.infradead.org,
        patches@apm.com, kchudgar@apm.com
To: Iyappan Subramanian <isubramanian@apm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:55861 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933546AbdCUUfz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 21 Mar 2017 16:35:55 -0400
Content-Disposition: inline
In-Reply-To: <1490124283-10371-2-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> @@ -511,9 +512,9 @@ static int xge_close(struct net_device *ndev)
>  {
>  	struct xge_pdata *pdata = netdev_priv(ndev);
>  
> -	netif_carrier_off(ndev);
>  	netif_stop_queue(ndev);
>  	xge_mac_disable(pdata);
> +	phy_stop(ndev->phydev);
>  
>  	xge_intr_disable(pdata);
>  	xge_free_irq(ndev);
> @@ -683,9 +684,14 @@ static int xge_probe(struct platform_device *pdev)
>  	if (ret)
>  		goto err;
>  
> +	spin_lock_init(&pdata->mdio_lock);
> +

...

> +static int xge_mdio_write(struct mii_bus *bus, int phy_id, int reg, u16 data)
> +{
> +	struct xge_pdata *pdata = bus->priv;
> +	u32 done, val = 0;
> +	u8 wait = 10;
> +	int ret = 0;
> +
> +	spin_lock(&pdata->mdio_lock);
> +
> +	SET_REG_BITS(&val, PHY_ADDR, phy_id);
> +	SET_REG_BITS(&val, REG_ADDR, reg);
> +	xge_wr_csr(pdata, MII_MGMT_ADDRESS, val);
> +
> +	xge_wr_csr(pdata, MII_MGMT_CONTROL, data);
> +	do {
> +		usleep_range(5, 10);
> +		done = xge_rd_csr(pdata, MII_MGMT_INDICATORS);
> +	} while ((done & MII_MGMT_BUSY) && wait--);
> +
> +	if (done & MII_MGMT_BUSY) {
> +		dev_err(&bus->dev, "MII_MGMT write failed\n");
> +		ret = -ETIMEDOUT;
> +	}
> +
> +	spin_unlock(&pdata->mdio_lock);
> +
> +	return ret;
> +}
> +
> +static int xge_mdio_read(struct mii_bus *bus, int phy_id, int reg)
> +{
> +	struct xge_pdata *pdata = bus->priv;
> +	u32 data, done, val = 0;
> +	u8 wait = 10;
> +
> +	spin_lock(&pdata->mdio_lock);
> +

Hi Iyappan

Please could you explain what this lock is protecting which the
mii_bus mdio_lock in mdio_bus.c is not protecting?

Thanks
	Andrew
