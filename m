From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH RFCv2 5/6] net: phy: suspend unused PHYs on mdio_bus in
 late_initcall
Date: Thu, 05 Dec 2013 00:05:44 +0300
Message-ID: <529F9928.9090407@cogentembedded.com>
References: <1384978913-8052-1-git-send-email-sebastian.hesselbarth@gmail.com> <1386171888-28190-6-git-send-email-sebastian.hesselbarth@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Mugunthan V N <mugunthanvnm@ti.com>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1386171888-28190-6-git-send-email-sebastian.hesselbarth@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 12/04/2013 06:44 PM, Sebastian Hesselbarth wrote:

> Since phy_attach ensures PHYs are resumed, we can now suspend all
> PHYs that have no attached netdev after initcalls.

> Signed-off-by: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
> ---
> Changelog:
> RFCv1->RFCv2:
> - only check for phydev->attached_dev and let phy_suspend decide on
>    performing suspend or not (Suggested by Florian)

> @Florian: You suggested to 'make sure that the MDIO bus suspend policy
> was set to "auto"'. I wasn't able to find any clue how to check that,
> so I ignored that for now.

> Cc: David Miller <davem@davemloft.net>
> Cc: Florian Fainelli <f.fainelli@gmail.com>
> Cc: Mugunthan V N <mugunthanvnm@ti.com>
> Cc: netdev@vger.kernel.org
> Cc: linux-arm-kernel@lists.infradead.org
> Cc: linux-kernel@vger.kernel.org
> ---
>   drivers/net/phy/mdio_bus.c |   25 +++++++++++++++++++++++++
>   1 files changed, 25 insertions(+), 0 deletions(-)

> diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
> index 5617876..f533d17 100644
> --- a/drivers/net/phy/mdio_bus.c
> +++ b/drivers/net/phy/mdio_bus.c
> @@ -320,6 +320,31 @@ static int mdio_bus_match(struct device *dev, struct device_driver *drv)
>   		(phydev->phy_id & phydrv->phy_id_mask));
>   }
>
> +static int mdio_bus_suspend_unused(struct device *busdev, void *data)
> +{
> +	struct mii_bus *bus = to_mii_bus(busdev);
> +	struct phy_device *phydev;
> +	int i;
> +
> +	for (i = 0; i < PHY_MAX_ADDR; i++) {
> +		if (!bus->phy_map[i])
> +			continue;
> +
> +		phydev = to_phy_device(&bus->phy_map[i]->dev);

    Why so complex? 'bus->phy_map[i]' already gives you 'phydev'.

> +		if (!phydev->attached_dev)
> +			phy_suspend(phydev);
> +	}
> +
> +	return 0;
> +}

WBR, Sergei
