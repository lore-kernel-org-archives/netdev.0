From: Johan Hovold <johan@kernel.org>
Subject: Re: phy/micrel: KSZ8031RNL RMII clock reconfiguration bug
Date: Tue, 11 Nov 2014 20:41:01 +0100
Message-ID: <20141111194101.GI29789@localhost>
References: <1412866094-4972-1-git-send-email-bth@kamstrup.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com,
	s.hauer@pengutronix.de, bruno.thomsen@gmail.com,
	linux-kernel@vger.kernel.org
To: Bruno Thomsen <bth@kamstrup.dk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1412866094-4972-1-git-send-email-bth@kamstrup.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Bruno,

On Thu, Oct 09, 2014 at 04:48:14PM +0200, Bruno Thomsen wrote:
> Bug: Unable to send and receive Ethernet packets with Micrel PHY.
> 
> Affected devices:
> KSZ8031RNL (commercial temp)
> KSZ8031RNLI (industrial temp)
> 
> Description:
> PHY device is correctly detected during probe.
> PHY power-up default is 25MHz crystal clock input
> and output 50MHz RMII clock to MAC.
> Reconfiguration of PHY to input 50MHz RMII clock from MAC
> causes PHY to become unresponsive if clock source is changed
> after Operation Mode Strap Override (OMSO) register setup.
> 
> Cause:
> Long lead times on parts where clock setup match circuit design
> forces the usage of similar parts with wrong default setup.
> 
> Solution:
> Swapped KSZ8031 register setup and added phy_write return code validation.
> 
> Tested with Freescale i.MX28 Fast Ethernet Controler (fec).
> 
> Signed-off-by: Bruno Thomsen <bth@kamstrup.dk>
> ---
>  drivers/net/phy/micrel.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
> index 011dbda..ec3f646 100644
> --- a/drivers/net/phy/micrel.c
> +++ b/drivers/net/phy/micrel.c
> @@ -194,8 +194,10 @@ static int ksz8021_config_init(struct phy_device *phydev)
>  	if (rc)
>  		dev_err(&phydev->dev, "failed to set led mode\n");
>  
> -	phy_write(phydev, MII_KSZPHY_OMSO, val);
>  	rc = ksz_config_flags(phydev);
> +	if (rc < 0)
> +		return rc;
> +	rc = phy_write(phydev, MII_KSZPHY_OMSO, val);
>  	return rc < 0 ? rc : 0;
>  }

As you may have seen by now, I've been working on refactoring the
micrel phy driver to be able to use common initialisation code.

Specifically, I've added generic support for disabling the broadcast
address, which is what the MII_KSZPHY_OMSO write above does.

Generally you want this to be the first thing you do in order to avoid
unnecessary reconfigurations. If we ever were to allow concurrent
probing this would also be a requirement.

Could you provide some detail about the setup were you find that the PHY
becomes unresponsive without your patch? Do you have more than one PHY
on the bus? Using what addresses? And using what clock modes (i.e. 25
MHz or 50 MHz)?

Also, what exactly do you mean by "unresponsive"? Are you still able to
read the PHY registers for example?

Thanks,
Johan
