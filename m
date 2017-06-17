From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net/phy: micrel: configure intterupts after autoneg
 workaround
Date: Sun, 18 Jun 2017 00:39:18 +0200
Message-ID: <20170617223918.GC14173@lunn.ch>
References: <1497633607-27180-1-git-send-email-zach.brown@ni.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Zach Brown <zach.brown@ni.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1497633607-27180-1-git-send-email-zach.brown@ni.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 16, 2017 at 12:20:07PM -0500, Zach Brown wrote:
> The commit ("net/phy: micrel: Add workaround for bad autoneg") fixes
> an autoneg failure case by resetting the hardware. This turns off
> intterupts. Things will work themselves out if the phy
> polls, as it will figure out it's state during a poll. However if the
> phy uses only intterupts, the phy will stall, since interrupts
> are off.
> 
> This patch fixes the issue by calling config_intr after resetting the
> phy.
> 
> Fixes: d2fd719bcb0e ("net/phy: micrel: Add workaround for bad autoneg ")
> Signed-off-by: Zach Brown <zach.brown@ni.com>
> ---
>  drivers/net/phy/micrel.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
> index 9365b07..bc2a0a4 100644
> --- a/drivers/net/phy/micrel.c
> +++ b/drivers/net/phy/micrel.c
> @@ -620,6 +620,8 @@ static int ksz9031_read_status(struct phy_device *phydev)
>  	if ((regval & 0xFF) == 0xFF) {
>  		phy_init_hw(phydev);
>  		phydev->link = 0;
> +		if (phydev->drv->config_intr)
> +			phydev->drv->config_intr(phydev);

The core will only call the config_intr() method if
phy_interrupt_is_valid() is true.

I would suggest you do the same here. Otherwise there is a danger of
enabling interrupts without having an interrupt handler registered.

  Andrew
