From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net] net: dsa: mv88e6xxx: do not leave reserved VLANs
Date: Sat, 6 Feb 2016 19:27:57 +0100
Message-ID: <20160206182757.GB17218@lunn.ch>
References: <1454699234-6157-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Kevin Smith <kevin.smith@elecsyscorp.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1454699234-6157-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 05, 2016 at 02:07:14PM -0500, Vivien Didelot wrote:
> BRIDGE_VLAN_FILTERING automatically adds a newly bridged port to the
> VLAN with the bridge's default_pvid.
> 
> The mv88e6xxx driver currently reserves VLANs 4000+ for unbridged ports
> isolation. When a port joins a bridge, it leaves its reserved VLAN. When
> a port leaves a bridge, it joins again its reserved VLAN.
> 
> But if the VLAN filtering is disabled, or if this hardware VLAN is
> already in use, the bridged port ends up with no default VLAN, and the
> communication with the CPU is thus broken.
> 
> To fix this, make a port join its reserved VLAN once on setup, never
> leave it, and restore its PVID after another one was eventually used.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Tested-by: Andrew Lunn <andrew@lunn.ch>

Thanks

	Andrew


> ---
>  drivers/net/dsa/mv88e6xxx.c | 25 ++++++++++---------------
>  1 file changed, 10 insertions(+), 15 deletions(-)
> 
> diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
> index 1cb3d15..4196dd8 100644
> --- a/drivers/net/dsa/mv88e6xxx.c
> +++ b/drivers/net/dsa/mv88e6xxx.c
> @@ -1572,6 +1572,7 @@ int mv88e6xxx_port_vlan_del(struct dsa_switch *ds, int port,
>  			    const struct switchdev_obj_port_vlan *vlan)
>  {
>  	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
> +	const u16 defpvid = 4000 + ds->index * DSA_MAX_PORTS + port;
>  	u16 pvid, vid;
>  	int err = 0;
>  
> @@ -1587,7 +1588,8 @@ int mv88e6xxx_port_vlan_del(struct dsa_switch *ds, int port,
>  			goto unlock;
>  
>  		if (vid == pvid) {
> -			err = _mv88e6xxx_port_pvid_set(ds, port, 0);
> +			/* restore reserved VLAN ID */
> +			err = _mv88e6xxx_port_pvid_set(ds, port, defpvid);
>  			if (err)
>  				goto unlock;
>  		}
> @@ -1879,26 +1881,20 @@ unlock:
>  
>  int mv88e6xxx_port_bridge_join(struct dsa_switch *ds, int port, u32 members)
>  {
> -	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
> -	const u16 pvid = 4000 + ds->index * DSA_MAX_PORTS + port;
> -	int err;
> -
> -	/* The port joined a bridge, so leave its reserved VLAN */
> -	mutex_lock(&ps->smi_mutex);
> -	err = _mv88e6xxx_port_vlan_del(ds, port, pvid);
> -	if (!err)
> -		err = _mv88e6xxx_port_pvid_set(ds, port, 0);
> -	mutex_unlock(&ps->smi_mutex);
> -	return err;
> +	return 0;
>  }
>  
>  int mv88e6xxx_port_bridge_leave(struct dsa_switch *ds, int port, u32 members)
>  {
> +	return 0;
> +}
> +
> +static int mv88e6xxx_setup_port_default_vlan(struct dsa_switch *ds, int port)
> +{
>  	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
>  	const u16 pvid = 4000 + ds->index * DSA_MAX_PORTS + port;
>  	int err;
>  
> -	/* The port left the bridge, so join its reserved VLAN */
>  	mutex_lock(&ps->smi_mutex);
>  	err = _mv88e6xxx_port_vlan_add(ds, port, pvid, true);
>  	if (!err)
> @@ -2182,8 +2178,7 @@ int mv88e6xxx_setup_ports(struct dsa_switch *ds)
>  		if (dsa_is_cpu_port(ds, i) || dsa_is_dsa_port(ds, i))
>  			continue;
>  
> -		/* setup the unbridged state */
> -		ret = mv88e6xxx_port_bridge_leave(ds, i, 0);
> +		ret = mv88e6xxx_setup_port_default_vlan(ds, i);
>  		if (ret < 0)
>  			return ret;
>  	}
> -- 
> 2.7.0
> 
