From: John Crispin <john@phrozen.org>
Subject: Re: [PATCH V3] net-next: dsa: add FIB support
Date: Tue, 13 Sep 2016 18:27:46 +0200
Message-ID: <4f5e1704-daab-b9d3-c865-fad834d9f80b@phrozen.org>
References: <1473746541-52314-1-git-send-email-john@phrozen.org>
 <87intz22jy.fsf@ketchup.mtl.sfl>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Jiri Pirko <jiri@mellanox.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:39056 "EHLO nbd.name"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754811AbcIMQ1w (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 13 Sep 2016 12:27:52 -0400
In-Reply-To: <87intz22jy.fsf@ketchup.mtl.sfl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 13/09/2016 18:21, Vivien Didelot wrote:
> Hi John,
> 
> John Crispin <john@phrozen.org> writes:
> 
>> @@ -237,6 +237,7 @@ struct switchdev_obj;
>>  struct switchdev_obj_port_fdb;
>>  struct switchdev_obj_port_mdb;
>>  struct switchdev_obj_port_vlan;
>> +struct switchdev_obj_ipv4_fib;
> 
> Can you keep it ordered please (put obj_ipv4 above port_fdb).
> 
>>  
>>  struct dsa_switch_ops {
>>  	struct list_head	list;
>> @@ -386,6 +387,18 @@ struct dsa_switch_ops {
>>  	int	(*port_mdb_dump)(struct dsa_switch *ds, int port,
>>  				 struct switchdev_obj_port_mdb *mdb,
>>  				 int (*cb)(struct switchdev_obj *obj));
>> +
>> +	/*
>> +	 * IPV4 routing
>> +	 */
>> +	int	(*ipv4_fib_prepare)(struct dsa_switch *ds, int port,
>> +				    const struct switchdev_obj_ipv4_fib *fib4,
>> +				    struct switchdev_trans *trans);
>> +	int	(*ipv4_fib_add)(struct dsa_switch *ds, int port,
>> +				const struct switchdev_obj_ipv4_fib *fib4,
>> +				struct switchdev_trans *trans);
> 
> DSA *_add ops should return void, since no error is supposed to occure in
> the commit phase.
> 
> If they are port-based operations, please prefix them with "port_",
> otherwise, the int port parameter is not necessary.
> 
>> +	int	(*ipv4_fib_del)(struct dsa_switch *ds, int port,
>> +				const struct switchdev_obj_ipv4_fib *fib4);
>>  };
>>  
>>  void register_switch_driver(struct dsa_switch_ops *type);
>> diff --git a/net/dsa/slave.c b/net/dsa/slave.c
>> index 9ecbe78..c974ac0 100644
>> --- a/net/dsa/slave.c
>> +++ b/net/dsa/slave.c
>> @@ -334,6 +334,38 @@ static int dsa_slave_port_mdb_dump(struct net_device *dev,
>>  	return -EOPNOTSUPP;
>>  }
>>  
>> +static int dsa_slave_ipv4_fib_add(struct net_device *dev,
>> +				  const struct switchdev_obj_ipv4_fib *fib4,
>> +				  struct switchdev_trans *trans)
>> +{
>> +	struct dsa_slave_priv *p = netdev_priv(dev);
>> +	struct dsa_switch *ds = p->parent;
>> +	int ret;
>> +
>> +	if (!ds->ops->ipv4_fib_prepare || !ds->ops->ipv4_fib_add)
>> +		return -EOPNOTSUPP;
>> +
>> +	if (switchdev_trans_ph_prepare(trans))
>> +		ret = ds->ops->ipv4_fib_prepare(ds, p->port, fib4, trans);
>> +	else
>> +		ret = ds->ops->ipv4_fib_add(ds, p->port, fib4, trans);
>> +
>> +	return ret;
>> +}
> 
> Please see dsa_slave_port_vlan_add for a better logic with the prepare
> phase and void add routine.
> 
>> +
>> +static int dsa_slave_ipv4_fib_del(struct net_device *dev,
>> +				  const struct switchdev_obj_ipv4_fib *fib4)
>> +{
>> +	struct dsa_slave_priv *p = netdev_priv(dev);
>> +	struct dsa_switch *ds = p->parent;
>> +	int ret = -EOPNOTSUPP;
>> +
>> +	if (ds->ops->ipv4_fib_del)
>> +		ret = ds->ops->ipv4_fib_del(ds, p->port, fib4);
>> +
>> +	return ret;
>> +}
> 
> Just curious, isn't there a dump operation for SWITCHDEV_OBJ_ID_IPV4_FIB?
> 
>> +
>>  static int dsa_slave_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
>>  {
>>  	struct dsa_slave_priv *p = netdev_priv(dev);
>> @@ -465,6 +497,11 @@ static int dsa_slave_port_obj_add(struct net_device *dev,
>>  					      SWITCHDEV_OBJ_PORT_VLAN(obj),
>>  					      trans);
>>  		break;
>> +	case SWITCHDEV_OBJ_ID_IPV4_FIB:
>> +		err = dsa_slave_ipv4_fib_add(dev,
>> +					     SWITCHDEV_OBJ_IPV4_FIB(obj),
>> +					     trans);
>> +		break;
>>  	default:
>>  		err = -EOPNOTSUPP;
>>  		break;
>> @@ -490,6 +527,10 @@ static int dsa_slave_port_obj_del(struct net_device *dev,
>>  		err = dsa_slave_port_vlan_del(dev,
>>  					      SWITCHDEV_OBJ_PORT_VLAN(obj));
>>  		break;
>> +	case SWITCHDEV_OBJ_ID_IPV4_FIB:
>> +		err = dsa_slave_ipv4_fib_del(dev,
>> +					     SWITCHDEV_OBJ_IPV4_FIB(obj));
>> +		break;
>>  	default:
>>  		err = -EOPNOTSUPP;
>>  		break;
> 
> Please keep the SWITCHDEV_OBJ_ID_IPV4_FIB case ordered with other cases
> as well.
> 
> I'm adding Jiri's in the loop, since he has started a thread on FIB
> notifications a few days ago, his feedback might be interesting. If I'm
> not mistaken, there is a plan to factorize FID routines (not sure).
> 
> Thanks,
> 
>         Vivien

Hi Vivien,

i sent an email to Jiri earlier today and he asked me to drop this until
his notification series got merged.

	John

> 
