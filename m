From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] net: dsa: set random switch address
Date: Thu, 12 Oct 2017 15:21:05 -0700
Message-ID: <b9aecb73-b240-7b59-4315-ea87868396cd@gmail.com>
References: <20171012221009.14615-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171012221009.14615-1-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/12/2017 03:10 PM, Vivien Didelot wrote:
> An Ethernet switch may support having a MAC address, which can be used
> as the switch's source address in transmitted full-duplex Pause frames.
> 
> If a DSA switch supports the related .set_addr operation, the DSA core
> sets the master's MAC address on the switch.
> 
> This won't make sense anymore in a multi-CPU ports system, because there
> won't be a unique master device assigned to a switch tree.

Thus far, everything you have said is true, but why we should do it,
that is: what if we don't, needs to be explained. Does that create a
problem with the generation of pause frames throughout the switch fabric?

> 
> To fix this, assign a random MAC address to the switch chip instead.

Maybe this is something that should be removed entirely from the DSA
core and pushed into the individual switch drivers instead. dsa_loop
implements it for code coverage, but that does not do anything.

set_addr is confusing in that you may think it could be used to program
the switch with the MAC address of the CPU/management port such that you
can disable MAC address learning on said port, but in fact, that's not
how it is used.

> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> ---
>  net/dsa/dsa2.c     |  8 +++-----
>  net/dsa/dsa_priv.h |  1 +
>  net/dsa/legacy.c   |  8 +++-----
>  net/dsa/switch.c   | 17 +++++++++++++++++
>  4 files changed, 24 insertions(+), 10 deletions(-)
> 
> diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
> index 54ed054777bd..8e5780ddd7f9 100644
> --- a/net/dsa/dsa2.c
> +++ b/net/dsa/dsa2.c
> @@ -336,11 +336,9 @@ static int dsa_ds_apply(struct dsa_switch_tree *dst, struct dsa_switch *ds)
>  	if (err)
>  		return err;
>  
> -	if (ds->ops->set_addr) {
> -		err = ds->ops->set_addr(ds, dst->cpu_dp->netdev->dev_addr);
> -		if (err < 0)
> -			return err;
> -	}
> +	err = dsa_switch_set_addr(ds);
> +	if (err)
> +		return err;
>  
>  	if (!ds->slave_mii_bus && ds->ops->phy_read) {
>  		ds->slave_mii_bus = devm_mdiobus_alloc(ds->dev);
> diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
> index 2850077cc9cc..9c4c17a4bd6b 100644
> --- a/net/dsa/dsa_priv.h
> +++ b/net/dsa/dsa_priv.h
> @@ -172,6 +172,7 @@ void dsa_slave_unregister_notifier(void);
>  /* switch.c */
>  int dsa_switch_register_notifier(struct dsa_switch *ds);
>  void dsa_switch_unregister_notifier(struct dsa_switch *ds);
> +int dsa_switch_set_addr(struct dsa_switch *ds);
>  
>  /* tag_brcm.c */
>  extern const struct dsa_device_ops brcm_netdev_ops;
> diff --git a/net/dsa/legacy.c b/net/dsa/legacy.c
> index 19ff6e0a21dc..340ca7997271 100644
> --- a/net/dsa/legacy.c
> +++ b/net/dsa/legacy.c
> @@ -172,11 +172,9 @@ static int dsa_switch_setup_one(struct dsa_switch *ds,
>  	if (ret)
>  		return ret;
>  
> -	if (ops->set_addr) {
> -		ret = ops->set_addr(ds, master->dev_addr);
> -		if (ret < 0)
> -			return ret;
> -	}
> +	ret = dsa_switch_set_addr(ds);
> +	if (ret)
> +		return ret;
>  
>  	if (!ds->slave_mii_bus && ops->phy_read) {
>  		ds->slave_mii_bus = devm_mdiobus_alloc(ds->dev);
> diff --git a/net/dsa/switch.c b/net/dsa/switch.c
> index e6c06aa349a6..b45a26b006af 100644
> --- a/net/dsa/switch.c
> +++ b/net/dsa/switch.c
> @@ -10,6 +10,7 @@
>   * (at your option) any later version.
>   */
>  
> +#include <linux/etherdevice.h>
>  #include <linux/netdevice.h>
>  #include <linux/notifier.h>
>  #include <net/switchdev.h>
> @@ -267,3 +268,19 @@ void dsa_switch_unregister_notifier(struct dsa_switch *ds)
>  	if (err)
>  		dev_err(ds->dev, "failed to unregister notifier (%d)\n", err);
>  }
> +
> +int dsa_switch_set_addr(struct dsa_switch *ds)
> +{
> +	u8 addr[6];
> +	int err;
> +
> +	if (ds->ops->set_addr) {
> +		eth_random_addr(addr);
> +
> +		err = ds->ops->set_addr(ds, addr);
> +		if (err)
> +			return err;
> +	}
> +
> +	return 0;
> +}
> 


-- 
Florian
