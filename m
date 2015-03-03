From: "claudiu.manoil@freescale.com" <claudiu.manoil@freescale.com>
Subject: RE: [PATCH] gianfar: Reduce logging noise seen due to phy polling if
 link is down
Date: Tue, 3 Mar 2015 14:42:10 +0000
Message-ID: <DM2PR03MB414A9B4827E955E774C85029C110@DM2PR03MB414.namprd03.prod.outlook.com>
References: <1425326607-21464-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Guenter Roeck <linux@roeck-us.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1425326607-21464-1-git-send-email-linux@roeck-us.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Guenter Roeck [mailto:linux@roeck-us.net]
> Sent: Monday, March 02, 2015 10:03 PM
> 
[...]
> 
> Cc: Claudiu Manoil <claudiu.manoil@freescale.com>
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>
> ---
[...]
>  	if (unlikely(phydev->link != priv->oldlink ||
> -		     phydev->duplex != priv->oldduplex ||
> -		     phydev->speed != priv->oldspeed))
> +		     (phydev->link && (phydev->duplex != priv->oldduplex ||
> +				       phydev->speed != priv->oldspeed))))
>  		gfar_update_link_state(priv);
>  }

I did a quick check and, indeed, phydev->duplex or phydev->speed
may change even if phydev->link is 0.  I could reproduce the issue
with the following test for an eth with a polling mode phy:
1) initially link is up - autoneg on, speed 1000;
2) taking the link down - link down message printed only once;
3) turning autoneg to off for the same eth  - link down message
is printed continuously;

So, given this, I agree that the driver needs this protection before
accessing the phydev->duplex/speed fields, namely to check first whether
phydev->link is 1.  If link is 0, phydev->speed/duplex may be bogus.

Thanks for spotting this.

Reviewed-by: Claudiu Manoil <claudiu.manoil@freescale.com>
