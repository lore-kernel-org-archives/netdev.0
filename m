From: Jeremy Linton <jeremy.linton@arm.com>
Subject: Re: [RFC] net: phy: smsc: Disable auto-negotiation on startup
Date: Tue, 11 Oct 2016 09:32:30 -0500
Message-ID: <4ced57d0-febe-181c-5f41-41ff3e018857@arm.com>
References: <20161010174123.21436-1-kyle.roeschley@ni.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Kyle Roeschley <kyle.roeschley@ni.com>, f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161010174123.21436-1-kyle.roeschley@ni.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/10/2016 12:41 PM, Kyle Roeschley wrote:
> Because the SMSC PHY completes auto-negotiation before the driver is
> ready to handle interrupts, the PHY state machine never realizes that we
> have a link. Clear the ANENABLE bit on initialization, which lets
> genphy_config_aneg do its thing when that code is hit later.
>
> While this patch does fix the problem we see (no link on boot without
> re-plugging the cable), it seems like the generic PHY code should be
> able to handle auto-negotiation completing before interrupts are
> enabled. Submitted as an RFC in the hopes that someone has an idea as to
> how that could be done.

Hi,

	Which smsc chip/driver? Maybe assuring the device interrupts are 
enabled before the phy is started is a solution?

	The whole problem sounds similar to what was recently happening in the 
smsc911x driver, but AFAIK that driver is basically only polling at this 
point so connecting the phy before the interrupts are enabled shouldn't 
be a problem.




>
> This fix is copied from commit 99f81afc139c ("phy: micrel: Disable auto
> negotiation on startup").
>
> Signed-off-by: Kyle Roeschley <kyle.roeschley@ni.com>
> ---
>  drivers/net/phy/smsc.c | 10 ++++++++++
>  1 file changed, 10 insertions(+)
>
> diff --git a/drivers/net/phy/smsc.c b/drivers/net/phy/smsc.c
> index b62c4aa..8de8011 100644
> --- a/drivers/net/phy/smsc.c
> +++ b/drivers/net/phy/smsc.c
> @@ -62,6 +62,16 @@ static int smsc_phy_config_init(struct phy_device *phydev)
>  			return rc;
>  	}
>
> +	if (phy_interrupt_is_valid(phydev)) {
> +		rc = phy_read(phydev, MII_BMCR);
> +		if (rc < 0)
> +			return rc;
> +
> +		rc = phy_write(phydev, MII_BMCR, rc & ~BMCR_ANENABLE);
> +		if (rc < 0)
> +			return rc;
> +	}
> +
>  	return smsc_phy_ack_interrupt(phydev);
>  }
>
>
