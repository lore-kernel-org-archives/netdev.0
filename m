From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 4/4] net: dsa: Do not clobber PHY link outside
 of state machine
Date: Tue, 7 Feb 2017 01:11:32 +0100
Message-ID: <20170207001132.GB30169@lunn.ch>
References: <20170206235523.23216-1-f.fainelli@gmail.com>
 <20170206235523.23216-5-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, zefir.kurtisi@neratec.com,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Wingman Kwok <w-kwok2@ti.com>,
        Murali Karicheri <m-karicheri2@ti.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        "David S. Miller" <davem@davemloft.net>,
        Philippe Reynes <tremyfr@gmail.com>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Jisheng Zhang <jszhang@marvell.com>,
        Jarod Wilson <jarod@redhat.com>,
        open list <linux-kernel@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170206235523.23216-5-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 06, 2017 at 03:55:23PM -0800, Florian Fainelli wrote:
> Calling phy_read_status() means that we may call into
> genphy_read_status() which in turn will use genphy_update_link() which
> can make changes to phydev->link outside of the state machine's state
> transitions. This is an invalid behavior that is now caught as of
> 811a919135b9 ("phy state machine: failsafe leave invalid RUNNING state")
> 
> Reported-by: Zefir Kurtisi <zefir.kurtisi@neratec.com>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
>  net/dsa/slave.c | 10 +++-------
>  1 file changed, 3 insertions(+), 7 deletions(-)
> 
> diff --git a/net/dsa/slave.c b/net/dsa/slave.c
> index 09fc3e9462c1..4b6fb6b14de4 100644
> --- a/net/dsa/slave.c
> +++ b/net/dsa/slave.c
> @@ -651,14 +651,10 @@ dsa_slave_get_link_ksettings(struct net_device *dev,
>  			     struct ethtool_link_ksettings *cmd)
>  {
>  	struct dsa_slave_priv *p = netdev_priv(dev);
> -	int err;
> +	int err = -EOPNOTSUPP;
>  
> -	err = -EOPNOTSUPP;
> -	if (p->phy != NULL) {
> -		err = phy_read_status(p->phy);
> -		if (err == 0)
> -			err = phy_ethtool_ksettings_get(p->phy, cmd);
> -	}
> +	if (p->phy != NULL)
> +		err = phy_ethtool_ksettings_get(p->phy, cmd);

Hi Florian

So what we are effectively doing is returning the state from the last
poll/interrupt. The poll information could be up to 1 second out of
date, but those PHYs using interrupts should give more fresh
information.

Seems reasonable.

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
