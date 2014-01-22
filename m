From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] net: phy: use network device in
 phy_print_status
Date: Wed, 22 Jan 2014 10:49:44 -0800
Message-ID: <1390416584.31946.84.camel@joe-AO722>
References: <1390415553-4961-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0079.hostedemail.com ([216.40.44.79]:52948 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752767AbaAVStr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jan 2014 13:49:47 -0500
In-Reply-To: <1390415553-4961-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-01-22 at 10:32 -0800, Florian Fainelli wrote:
> phy_print_status() currently uses dev_name(&phydev->dev) which will
> usually result in printing something along those lines for Device Tree
> aware drivers:
> 
> libphy: f0b60000.etherne:0a - Link is Down
> libphy: f0ba0000.etherne:00 - Link is Up - 1000/Full
> 
> This is not terribly useful for network administrators or users since we
> expect a network interface name to be able to correlate link events with
> interfaces. Update phy_print_status() to use netdev_info() with
> phydev->attached_dev which is the backing network device for our PHY
> device.
[]
> diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
[]
> @@ -45,12 +45,11 @@
>  void phy_print_status(struct phy_device *phydev)
>  {
>  	if (phydev->link) {
> -		pr_info("%s - Link is Up - %d/%s\n",
> -			dev_name(&phydev->dev),
> +		netdev_info(phydev->attached_dev, "- Link is Up - %d/%s\n",
>  			phydev->speed,
>  			DUPLEX_FULL == phydev->duplex ? "Full" : "Half");
>  	} else	{
> -		pr_info("%s - Link is Down\n", dev_name(&phydev->dev));
> +		netdev_info(phydev->attached_dev, "- Link is Down\n");
>  	}

The leading "- "'s now aren't useful and these could be

	if (phydev->link)
		netdev_info(phydev->attached_dev, "Link is Up - %d/%s\n",
			    phydev->speed,
			    phydev->duplex == DUPLEX_FULL ? "Full" : "Half");
	else
		netdev_info(phydev->attached_dev, "Link is Down\n");

Is is possible that phydev->attached_dev is NULL?

It may also be possible to slightly improve the output by
reducing the number of 0's in the speed block and emitting
Kb/Mb/Gb (or Kbps/Mbps/Gbps) and maybe flow control if it's
available.
