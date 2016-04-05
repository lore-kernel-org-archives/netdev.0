From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 2/3] net: dsa: make the FDB add function return
 void
Date: Wed, 6 Apr 2016 01:51:19 +0200
Message-ID: <20160405235119.GC19409@lunn.ch>
References: <1459869875-23815-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1459869875-23815-2-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Scott Feldman <sfeldma@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1459869875-23815-2-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 05, 2016 at 11:24:34AM -0400, Vivien Didelot wrote:
> The switchdev design implies that a software error should not happen in
> the commit phase since it must have been previously reported in the
> prepare phase. If an hardware error occurs during the commit phase,
> there is nothing switchdev can do about it.
> 
> The DSA layer separates port_fdb_prepare and port_fdb_add for simplicity
> and convenience. If an hardware error occurs during the commit phase,
> there is no need to report it outside the DSA driver itself.
> 
> Make the DSA port_fdb_add routine return void for explicitness.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> ---
>  drivers/net/dsa/bcm_sf2.c   |  9 +++++----
>  drivers/net/dsa/mv88e6xxx.c | 12 +++++-------
>  drivers/net/dsa/mv88e6xxx.h |  6 +++---
>  include/net/dsa.h           |  2 +-
>  net/dsa/slave.c             | 16 ++++++++--------
>  5 files changed, 22 insertions(+), 23 deletions(-)
> 
> diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
> index b847624..feebeaa 100644
> --- a/drivers/net/dsa/bcm_sf2.c
> +++ b/drivers/net/dsa/bcm_sf2.c
> @@ -722,13 +722,14 @@ static int bcm_sf2_sw_fdb_prepare(struct dsa_switch *ds, int port,
>  	return 0;
>  }
>  
> -static int bcm_sf2_sw_fdb_add(struct dsa_switch *ds, int port,
> -			      const struct switchdev_obj_port_fdb *fdb,
> -			      struct switchdev_trans *trans)
> +static void bcm_sf2_sw_fdb_add(struct dsa_switch *ds, int port,
> +			       const struct switchdev_obj_port_fdb *fdb,
> +			       struct switchdev_trans *trans)
>  {
>  	struct bcm_sf2_priv *priv = ds_to_priv(ds);
>  
> -	return bcm_sf2_arl_op(priv, 0, port, fdb->addr, fdb->vid, true);
> +	if (bcm_sf2_arl_op(priv, 0, port, fdb->addr, fdb->vid, true))
> +		pr_err("%s: failed to add address\n", __func__);
>  }
>  
>  static int bcm_sf2_sw_fdb_del(struct dsa_switch *ds, int port,
> diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
> index 5a2e46d..bca9a2c 100644
> --- a/drivers/net/dsa/mv88e6xxx.c
> +++ b/drivers/net/dsa/mv88e6xxx.c
> @@ -2090,21 +2090,19 @@ int mv88e6xxx_port_fdb_prepare(struct dsa_switch *ds, int port,
>  	return 0;
>  }
>  
> -int mv88e6xxx_port_fdb_add(struct dsa_switch *ds, int port,
> -			   const struct switchdev_obj_port_fdb *fdb,
> -			   struct switchdev_trans *trans)
> +void mv88e6xxx_port_fdb_add(struct dsa_switch *ds, int port,
> +			    const struct switchdev_obj_port_fdb *fdb,
> +			    struct switchdev_trans *trans)
>  {
>  	int state = is_multicast_ether_addr(fdb->addr) ?
>  		GLOBAL_ATU_DATA_STATE_MC_STATIC :
>  		GLOBAL_ATU_DATA_STATE_UC_STATIC;
>  	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
> -	int ret;
>  
>  	mutex_lock(&ps->smi_mutex);
> -	ret = _mv88e6xxx_port_fdb_load(ds, port, fdb->addr, fdb->vid, state);
> +	if (_mv88e6xxx_port_fdb_load(ds, port, fdb->addr, fdb->vid, state))
> +		netdev_warn(ds->ports[port], "cannot load address\n");

In the SF2 driver you use pr_err, but here netdev_warn. We probably
should be consistent if we error or warn. I would use netdev_error,
since if this fails we probably have a real hardware problem.

      Andrew
