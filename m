From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [RFC net-next 2/3] net: dsa: Propagate VLAN add/del to
	CPU port(s)
Date: Tue, 22 Nov 2016 11:50:38 -0500
Message-ID: <87eg23zcf5.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
References: <20161121190925.14530-1-f.fainelli@gmail.com>
	<20161121190925.14530-3-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: idosch@mellanox.com, andrew@lunn.ch,
	Florian Fainelli <f.fainelli@gmail.com>,
	bridge@lists.linux-foundation.org, jiri@mellanox.com, davem@davemloft.net
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20161121190925.14530-3-f.fainelli@gmail.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Hi Florian,

Open question: will we need to do the same for FDB and MDB objects?

Florian Fainelli <f.fainelli@gmail.com> writes:

> Now that the bridge layer can call into switchdev to signal programming
> requests targeting the bridge master device itself, allow the switch
> drivers to implement separate programming of downstream and
> upstream/management ports.
>
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
>  net/dsa/slave.c | 45 +++++++++++++++++++++++++++++++++------------
>  1 file changed, 33 insertions(+), 12 deletions(-)
>
> diff --git a/net/dsa/slave.c b/net/dsa/slave.c
> index d0c7bce88743..18288261b964 100644
> --- a/net/dsa/slave.c
> +++ b/net/dsa/slave.c
> @@ -223,35 +223,30 @@ static int dsa_slave_set_mac_address(struct net_device *dev, void *a)
>  	return 0;
>  }
>  
> -static int dsa_slave_port_vlan_add(struct net_device *dev,
> +static int dsa_slave_port_vlan_add(struct dsa_switch *ds, int port,
>  				   const struct switchdev_obj_port_vlan *vlan,
>  				   struct switchdev_trans *trans)
>  {
> -	struct dsa_slave_priv *p = netdev_priv(dev);
> -	struct dsa_switch *ds = p->parent;
>  

Extra newline ^.

>  	if (switchdev_trans_ph_prepare(trans)) {
>  		if (!ds->ops->port_vlan_prepare || !ds->ops->port_vlan_add)
>  			return -EOPNOTSUPP;
>  
> -		return ds->ops->port_vlan_prepare(ds, p->port, vlan, trans);
> +		return ds->ops->port_vlan_prepare(ds, port, vlan, trans);
>  	}
>  
> -	ds->ops->port_vlan_add(ds, p->port, vlan, trans);
> +	ds->ops->port_vlan_add(ds, port, vlan, trans);
>  
>  	return 0;
>  }
>  
> -static int dsa_slave_port_vlan_del(struct net_device *dev,
> +static int dsa_slave_port_vlan_del(struct dsa_switch *ds, int port,
>  				   const struct switchdev_obj_port_vlan *vlan)
>  {
> -	struct dsa_slave_priv *p = netdev_priv(dev);
> -	struct dsa_switch *ds = p->parent;
> -
>  	if (!ds->ops->port_vlan_del)
>  		return -EOPNOTSUPP;
>  
> -	return ds->ops->port_vlan_del(ds, p->port, vlan);
> +	return ds->ops->port_vlan_del(ds, port, vlan);
>  }
>  
>  static int dsa_slave_port_vlan_dump(struct net_device *dev,
> @@ -465,8 +460,21 @@ static int dsa_slave_port_obj_add(struct net_device *dev,
>  				  const struct switchdev_obj *obj,
>  				  struct switchdev_trans *trans)
>  {
> +	struct dsa_slave_priv *p = netdev_priv(dev);
> +	struct dsa_switch *ds = p->parent;
> +	int port = p->port;
>  	int err;
>  
> +	/* Here we may be called with an orig_dev which is different from dev,
> +	 * on purpose, to receive request coming from e.g the bridge master
> +	 * device. Although there are no network device associated with CPU/DSA
> +	 * ports, we may still have programming operation for these ports.
> +	 */
> +	if (obj->orig_dev == p->bridge_dev) {
> +		ds = ds->dst->ds[0];
> +		port = ds->dst->cpu_port;
> +	}
> +
>  	/* For the prepare phase, ensure the full set of changes is feasable in
>  	 * one go in order to signal a failure properly. If an operation is not
>  	 * supported, return -EOPNOTSUPP.
> @@ -483,7 +491,7 @@ static int dsa_slave_port_obj_add(struct net_device *dev,
>  					     trans);
>  		break;
>  	case SWITCHDEV_OBJ_ID_PORT_VLAN:
> -		err = dsa_slave_port_vlan_add(dev,
> +		err = dsa_slave_port_vlan_add(ds, port,
>  					      SWITCHDEV_OBJ_PORT_VLAN(obj),
>  					      trans);

Note that dsa_slave_port_vlan_add() will be called N times, N being the
number of bridge ports. This is not an issue for the moment though.
Programming it only once requires caching, so leave it for an eventual
future patch.

When issuing the following command (lan0 being a member of br0):

    # bridge vlan add vid 42 dev lan0

the CPU port is also programmed as tagged in VLAN 42. Is that expected?

Thanks,

        Vivien
