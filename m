From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 1/4] net: dsa: move up phy enabling in core
Date: Fri, 22 Sep 2017 09:52:34 -0700
Message-ID: <06cb966d-9066-bc3d-13f0-c7a34ebf9878@gmail.com>
References: <20170922161753.19563-1-vivien.didelot@savoirfairelinux.com>
 <20170922161753.19563-2-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170922161753.19563-2-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/22/2017 09:17 AM, Vivien Didelot wrote:
> bcm_sf2 is currently the only driver using the phy argument passed to
> .port_enable. It resets the state machine if the phy has been hard
> reset. This check is generic and can be moved to DSA core.

This is completely specific to bcm_sf2 because it does call
bcm_sf2_gphy_enable_set() which performs a HW reset of the PHY, you
can't move this to the generic portion of net/dsa/slave.c. NACK.

> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> ---
>  drivers/net/dsa/bcm_sf2.c | 16 +---------------
>  net/dsa/slave.c           | 15 +++++++++++++--
>  2 files changed, 14 insertions(+), 17 deletions(-)
> 
> diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
> index 898d5642b516..ad96b9725a2c 100644
> --- a/drivers/net/dsa/bcm_sf2.c
> +++ b/drivers/net/dsa/bcm_sf2.c
> @@ -184,22 +184,8 @@ static int bcm_sf2_port_setup(struct dsa_switch *ds, int port,
>  	core_writel(priv, reg, CORE_PORT_TC2_QOS_MAP_PORT(port));
>  
>  	/* Re-enable the GPHY and re-apply workarounds */
> -	if (priv->int_phy_mask & 1 << port && priv->hw_params.num_gphy == 1) {
> +	if (priv->int_phy_mask & 1 << port && priv->hw_params.num_gphy == 1)
>  		bcm_sf2_gphy_enable_set(ds, true);
> -		if (phy) {
> -			/* if phy_stop() has been called before, phy
> -			 * will be in halted state, and phy_start()
> -			 * will call resume.
> -			 *
> -			 * the resume path does not configure back
> -			 * autoneg settings, and since we hard reset
> -			 * the phy manually here, we need to reset the
> -			 * state machine also.
> -			 */
> -			phy->state = PHY_READY;
> -			phy_init_hw(phy);
> -		}
> -	}
>  
>  	/* Enable MoCA port interrupts to get notified */
>  	if (port == priv->moca_port)
> diff --git a/net/dsa/slave.c b/net/dsa/slave.c
> index 02ace7d462c4..606812160fd5 100644
> --- a/net/dsa/slave.c
> +++ b/net/dsa/slave.c
> @@ -72,6 +72,7 @@ static int dsa_slave_get_iflink(const struct net_device *dev)
>  static int dsa_slave_open(struct net_device *dev)
>  {
>  	struct dsa_slave_priv *p = netdev_priv(dev);
> +	struct phy_device *phy = p->phy;
>  	struct dsa_port *dp = p->dp;
>  	struct dsa_switch *ds = dp->ds;
>  	struct net_device *master = dsa_master_netdev(p);
> @@ -106,8 +107,18 @@ static int dsa_slave_open(struct net_device *dev)
>  
>  	dsa_port_set_state_now(p->dp, stp_state);
>  
> -	if (p->phy)
> -		phy_start(p->phy);
> +	if (phy) {
> +		/* If phy_stop() has been called before, phy will be in
> +		 * halted state, and phy_start() will call resume.
> +		 *
> +		 * The resume path does not configure back autoneg
> +		 * settings, and since the internal phy may have been
> +		 * hard reset, we need to reset the state machine also.
> +		 */
> +		phy->state = PHY_READY;
> +		phy_init_hw(phy);
> +		phy_start(phy);
> +	}
>  
>  	return 0;
>  
> 


-- 
Florian
