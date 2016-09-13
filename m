From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH V3] net-next: dsa: add FIB support
Date: Tue, 13 Sep 2016 12:21:37 -0400
Message-ID: <87intz22jy.fsf@ketchup.mtl.sfl>
References: <1473746541-52314-1-git-send-email-john@phrozen.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        John Crispin <john@phrozen.org>, Jiri Pirko <jiri@mellanox.com>
To: John Crispin <john@phrozen.org>,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1473746541-52314-1-git-send-email-john@phrozen.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi John,

John Crispin <john@phrozen.org> writes:

> @@ -237,6 +237,7 @@ struct switchdev_obj;
>  struct switchdev_obj_port_fdb;
>  struct switchdev_obj_port_mdb;
>  struct switchdev_obj_port_vlan;
> +struct switchdev_obj_ipv4_fib;

Can you keep it ordered please (put obj_ipv4 above port_fdb).

>  
>  struct dsa_switch_ops {
>  	struct list_head	list;
> @@ -386,6 +387,18 @@ struct dsa_switch_ops {
>  	int	(*port_mdb_dump)(struct dsa_switch *ds, int port,
>  				 struct switchdev_obj_port_mdb *mdb,
>  				 int (*cb)(struct switchdev_obj *obj));
> +
> +	/*
> +	 * IPV4 routing
> +	 */
> +	int	(*ipv4_fib_prepare)(struct dsa_switch *ds, int port,
> +				    const struct switchdev_obj_ipv4_fib *fib4,
> +				    struct switchdev_trans *trans);
> +	int	(*ipv4_fib_add)(struct dsa_switch *ds, int port,
> +				const struct switchdev_obj_ipv4_fib *fib4,
> +				struct switchdev_trans *trans);

DSA *_add ops should return void, since no error is supposed to occure in
the commit phase.

If they are port-based operations, please prefix them with "port_",
otherwise, the int port parameter is not necessary.

> +	int	(*ipv4_fib_del)(struct dsa_switch *ds, int port,
> +				const struct switchdev_obj_ipv4_fib *fib4);
>  };
>  
>  void register_switch_driver(struct dsa_switch_ops *type);
> diff --git a/net/dsa/slave.c b/net/dsa/slave.c
> index 9ecbe78..c974ac0 100644
> --- a/net/dsa/slave.c
> +++ b/net/dsa/slave.c
> @@ -334,6 +334,38 @@ static int dsa_slave_port_mdb_dump(struct net_device *dev,
>  	return -EOPNOTSUPP;
>  }
>  
> +static int dsa_slave_ipv4_fib_add(struct net_device *dev,
> +				  const struct switchdev_obj_ipv4_fib *fib4,
> +				  struct switchdev_trans *trans)
> +{
> +	struct dsa_slave_priv *p = netdev_priv(dev);
> +	struct dsa_switch *ds = p->parent;
> +	int ret;
> +
> +	if (!ds->ops->ipv4_fib_prepare || !ds->ops->ipv4_fib_add)
> +		return -EOPNOTSUPP;
> +
> +	if (switchdev_trans_ph_prepare(trans))
> +		ret = ds->ops->ipv4_fib_prepare(ds, p->port, fib4, trans);
> +	else
> +		ret = ds->ops->ipv4_fib_add(ds, p->port, fib4, trans);
> +
> +	return ret;
> +}

Please see dsa_slave_port_vlan_add for a better logic with the prepare
phase and void add routine.

> +
> +static int dsa_slave_ipv4_fib_del(struct net_device *dev,
> +				  const struct switchdev_obj_ipv4_fib *fib4)
> +{
> +	struct dsa_slave_priv *p = netdev_priv(dev);
> +	struct dsa_switch *ds = p->parent;
> +	int ret = -EOPNOTSUPP;
> +
> +	if (ds->ops->ipv4_fib_del)
> +		ret = ds->ops->ipv4_fib_del(ds, p->port, fib4);
> +
> +	return ret;
> +}

Just curious, isn't there a dump operation for SWITCHDEV_OBJ_ID_IPV4_FIB?

> +
>  static int dsa_slave_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
>  {
>  	struct dsa_slave_priv *p = netdev_priv(dev);
> @@ -465,6 +497,11 @@ static int dsa_slave_port_obj_add(struct net_device *dev,
>  					      SWITCHDEV_OBJ_PORT_VLAN(obj),
>  					      trans);
>  		break;
> +	case SWITCHDEV_OBJ_ID_IPV4_FIB:
> +		err = dsa_slave_ipv4_fib_add(dev,
> +					     SWITCHDEV_OBJ_IPV4_FIB(obj),
> +					     trans);
> +		break;
>  	default:
>  		err = -EOPNOTSUPP;
>  		break;
> @@ -490,6 +527,10 @@ static int dsa_slave_port_obj_del(struct net_device *dev,
>  		err = dsa_slave_port_vlan_del(dev,
>  					      SWITCHDEV_OBJ_PORT_VLAN(obj));
>  		break;
> +	case SWITCHDEV_OBJ_ID_IPV4_FIB:
> +		err = dsa_slave_ipv4_fib_del(dev,
> +					     SWITCHDEV_OBJ_IPV4_FIB(obj));
> +		break;
>  	default:
>  		err = -EOPNOTSUPP;
>  		break;

Please keep the SWITCHDEV_OBJ_ID_IPV4_FIB case ordered with other cases
as well.

I'm adding Jiri's in the loop, since he has started a thread on FIB
notifications a few days ago, his feedback might be interesting. If I'm
not mistaken, there is a plan to factorize FID routines (not sure).

Thanks,

        Vivien
