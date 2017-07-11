From: Arkadi Sharshevsky <arkadis@mellanox.com>
Subject: Re: [PATCH net-next RFC 10/12] net: dsa: Move FDB dump implementation
 inside DSA
Date: Tue, 11 Jul 2017 11:32:09 +0300
Message-ID: <acadbdf6-0387-627b-990b-998edd6a1c4e@mellanox.com>
References: <1499268990-19251-1-git-send-email-arkadis@mellanox.com>
 <1499268990-19251-11-git-send-email-arkadis@mellanox.com>
 <87wp7g5bkv.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jiri@resnulli.us, ivecera@redhat.com,
        f.fainelli@gmail.com, andrew@lunn.ch, Woojung.Huh@microchip.com,
        stephen@networkplumber.org, mlxsw@mellanox.com
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr30040.outbound.protection.outlook.com ([40.107.3.40]:28513
        "EHLO EUR03-AM5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1755378AbdGKIcU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 11 Jul 2017 04:32:20 -0400
In-Reply-To: <87wp7g5bkv.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 07/10/2017 10:36 PM, Vivien Didelot wrote:
> Hi Arkadi,
> 
> Arkadi Sharshevsky <arkadis@mellanox.com> writes:
> 
>> +struct dsa_slave_dump_ctx {
>> +	struct net_device *dev;
>> +	struct sk_buff *skb;
>> +	struct netlink_callback *cb;
>> +	int idx;
>> +};
>> +
>>  struct dsa_switch_ops {
>>  	/*
>>  	 * Legacy probing.
>> @@ -392,9 +399,7 @@ struct dsa_switch_ops {
>>  	int	(*port_fdb_del)(struct dsa_switch *ds, int port,
>>  				const unsigned char *addr, u16 vid);
>>  	int	(*port_fdb_dump)(struct dsa_switch *ds, int port,
>> -				 struct switchdev_obj_port_fdb *fdb,
>> -				  switchdev_obj_dump_cb_t *cb);
>> -
>> +				 struct dsa_slave_dump_ctx *dump);
> 
> I would prefer to pass a callback to the driver, so that we can call
> port_fdb_dump for other interfaces like debugfs, and for non exposed
> switch ports (CPU and DSA links) as well. Something like:
> 
>     typedef int dsa_fdb_dump_cb_t(const unsigned char *addr, u16 vid,
>                                   bool is_static, void *data);
> 
>     int (*port_fdb_dump)(struct dsa_switch *ds, int port,
>                          dsa_fdb_dump_cb_t *cb, void *data);
> 
> Then dsa_slave_dump_ctx and dsa_slave_port_fdb_do_dump can be static to
> net/dsa/slave.c.
> 

Originally thought about it. But it makes sense to pass a callback
when different functions can be supplied.

Here is only one option which is the fdb_do_dump(). So I thought
exporting it makes more sense..

>> +int dsa_slave_port_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb,
>> +			    struct net_device *dev,
>> +			    struct net_device *filter_dev, int *idx)
>> +{
>> +	struct dsa_slave_dump_ctx dump = {
>> +		.dev = dev,
>> +		.skb = skb,
>> +		.cb = cb,
>> +		.idx = *idx,
>> +	};
>> +	struct dsa_slave_priv *p = netdev_priv(dev);
>> +	struct dsa_port *dp = p->dp;
>> +	struct dsa_switch *ds = dp->ds;
>> +	int err;
>> +
>> +	if (!ds->ops->port_fdb_dump) {
>> +		err = -EOPNOTSUPP;
>> +		goto out;
>> +	}
>> +
>> +	err = ds->ops->port_fdb_dump(ds, dp->index, &dump);
>> +out:
>> +	*idx = dump.idx;
>> +	return err;
> 
> There is no need to reassign *idx in case of error:
> 
>     if (!ds->ops->port_fdb_dump)
>         return -EOPNOTSUPP;
> 
>     err = ds->ops->port_fdb_dump(ds, dp->index, &dump);
>     *idx = dump.idx;
> 
>     return err;
>
Will fix, thanks.

>> +	.ndo_fdb_dump		= dsa_slave_port_fdb_dump,
> 
> And s/dsa_slave_port_fdb_dump/dsa_slave_fdb_dump/ here will be even
> better ;-)
> 
> 
> Thanks,
> 
>         Vivien
> 
Will fix, thanks.
