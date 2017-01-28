From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v2 1/4] net: dsa: Add plumbing for port mirroring
Date: Sat, 28 Jan 2017 09:20:29 -0800
Message-ID: <629f29d8-7766-5054-6878-6db9f1ae7a6f@gmail.com>
References: <20170128012528.30524-1-f.fainelli@gmail.com>
 <20170128012528.30524-2-f.fainelli@gmail.com>
 <20170128091449.GA2033@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, cphealy@gmail.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ot0-f196.google.com ([74.125.82.196]:34833 "EHLO
        mail-ot0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751057AbdA1RUk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 28 Jan 2017 12:20:40 -0500
Received: by mail-ot0-f196.google.com with SMTP id 65so33970668otq.2
        for <netdev@vger.kernel.org>; Sat, 28 Jan 2017 09:20:31 -0800 (PST)
In-Reply-To: <20170128091449.GA2033@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 01/28/17 à 01:14, Jiri Pirko a écrit :
> Sat, Jan 28, 2017 at 02:25:25AM CET, f.fainelli@gmail.com wrote:
>> Add necessary plumbing at the slave network device level to have switch
>> drivers implement ndo_setup_tc() and most particularly the cls_matchall
>> classifier. We add support for two switch operations:
>>
>> port_add_mirror and port_del_mirror() which configure, on a per-port
>> basis the mirror parameters requested from the cls_matchall classifier.
>>
>> Code is largely borrowed from the Mellanox Spectrum switch driver.
>>
>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
>> ---
> 
> [...]
> 
> 
>> +/*
>> + * Mirroring TC entry
>> + */
>> +struct dsa_mall_mirror_tc_entry {
>> +	u8 to_local_port;
>> +	bool ingress;
>> +};
>> +
>> +/*
>> + * TC matchall entry
>> + */
> 
> Why are you using multiline comment format for single line comments?

There are precedents in that file, but I will remove it.

> 
> 
>> +struct dsa_mall_tc_entry {
>> +	struct list_head list;
>> +	unsigned long cookie;
>> +	enum dsa_port_mall_action_type type;
>> +	union {
>> +		struct dsa_mall_mirror_tc_entry mirror;
>> +	};
>> +};
>> +
>> +
>> struct dsa_port {
>> 	struct net_device	*netdev;
>> 	struct device_node	*dn;
>> @@ -370,6 +397,15 @@ struct dsa_switch_ops {
>> 	int	(*port_mdb_dump)(struct dsa_switch *ds, int port,
>> 				 struct switchdev_obj_port_mdb *mdb,
>> 				 int (*cb)(struct switchdev_obj *obj));
>> +
>> +	/*
>> +	 * TC integration
>> +	 */
>> +	int	(*port_mirror_add)(struct dsa_switch *ds, int port,
>> +				   struct dsa_mall_mirror_tc_entry *mirror,
>> +				   bool ingress);
>> +	void	(*port_mirror_del)(struct dsa_switch *ds, int port,
>> +				   struct dsa_mall_mirror_tc_entry *mirror);
>> };
> 
> [...]
> 
> 
>> +static int dsa_slave_add_cls_matchall(struct net_device *dev,
>> +				      __be16 protocol,
>> +				      struct tc_cls_matchall_offload *cls,
>> +				      bool ingress)
>> +{
>> +	struct dsa_slave_priv *p = netdev_priv(dev);
>> +	struct dsa_mall_tc_entry *mall_tc_entry;
>> +	struct dsa_switch *ds = p->parent;
>> +	struct net *net = dev_net(dev);
>> +	struct dsa_slave_priv *to_p;
>> +	struct net_device *to_dev;
>> +	const struct tc_action *a;
>> +	int err = -EOPNOTSUPP;
>> +	LIST_HEAD(actions);
>> +	int ifindex;
>> +
>> +	if (!ds->ops->port_mirror_add)
>> +		return err;
>> +
>> +	if (!tc_single_action(cls->exts)) {
>> +		netdev_err(dev, "only singular actions are supported\n");
> 
> Why you note the user in this case, but in case he tries to add
> non-supported action you don't note him?

Will remove that message.

> 
> 
>> +		return err;
>> +	}
>> +
>> +	mall_tc_entry = kzalloc(sizeof(*mall_tc_entry), GFP_KERNEL);
>> +	if (!mall_tc_entry)
>> +		return -ENOMEM;
>> +	mall_tc_entry->cookie = cls->cookie;
> 
> Hmm, I believe that this allocation and initialization should go into
> the "is_mirred if". You can do the checks in advance. That would also
> make the error path simplier.

Yes good point, seems like you may want to do the same in mlxsw since
that part of the code was loosely based on that too.

Thanks Jiri!
-- 
Florian
