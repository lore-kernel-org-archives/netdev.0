From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net-next 09/10] net/mlx4_en: Manage flow steering rules
 with ethtool
Date: Mon, 2 Jul 2012 16:32:15 +0300
Message-ID: <4FF1A2DF.5090403@mellanox.com>
References: <1341135823-29039-1-git-send-email-ogerlitz@mellanox.com>  <1341135823-29039-10-git-send-email-ogerlitz@mellanox.com> <1341158452.4852.107.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <roland@kernel.org>,
	<yevgenyp@mellanox.com>, <oren@mellanox.com>,
	<netdev@vger.kernel.org>, Hadar Hen Zion <hadarh@mellanox.co.il>,
	Amir Vadai <amirv@mellanox.co.il>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog102.obsmtp.com ([207.126.144.113]:53561 "HELO
	eu1sys200aog102.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750838Ab2GBNcb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jul 2012 09:32:31 -0400
In-Reply-To: <1341158452.4852.107.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/1/2012 7:00 PM, Ben Hutchings wrote:
>> static int mlx4_en_get_rxnfc(struct net_device *dev, struct ethtool_rxnfc *cmd,
>> >  			     u32 *rule_locs)
>> >  {
>> >  	struct mlx4_en_priv *priv = netdev_priv(dev);
>> >+	struct mlx4_en_dev *mdev = priv->mdev;
>> >  	int err = 0;
>> >+	int i = 0, priority = 0;
>> >+
>> >+	if (mdev->dev->caps.steering_mode != MLX4_STEERING_MODE_DEVICE_MANAGED)
>> >+		return -EOPNOTSUPP;
>> >  
>> >  	switch (cmd->cmd) {
>> >  	case ETHTOOL_GRXRINGS:
>> >  		cmd->data = priv->rx_ring_num;
>> >  		break;
>> >+	case ETHTOOL_GRXCLSRLCNT:
>> >+		cmd->rule_cnt = mlx4_en_get_num_flows(priv);
>> >+		break;
>> >+	case ETHTOOL_GRXCLSRULE:
>> >+		err = mlx4_en_get_flow(dev, cmd, cmd->fs.location);
>> >+		break;
>> >+	case ETHTOOL_GRXCLSRLALL:
>> >+		while (!err || err == -ENOENT) {
>> >+			err = mlx4_en_get_flow(dev, cmd, i);
>> >+			if (!err)
>> >+				((u32 *)(rule_locs))[priority++] = i;
> I don't see any range check against cmd->rule_cnt.

OK, will fix to make sure we don't cross cmd->rule_cnt

>
>
> Why are you casting rule_locs?

doesn't seem to be needed, will remove that casting

>
>
> Also, are the rules really prioritised by location, so that if rule 0
> and 1 match a packet then only rule 0 is applied?  If they are actually
> prioritised by the match type then you need to assign locations on the
> driver side that reflect the actual priorities.


Rules are prioritized by a scheme made of "domain" X location, see below 
and in patch #6
the MLX4_DOMAIN_yyy entries, higher domain value means lower priority, 
so for instance rules
placed by ethtool would have higher priority over rules added by the L2 
NIC  or by future RFS
patch. Within a domain, the location matters.

You can see that simple L2 rules (e.g contain dest-mac, possibly vlan) 
added by the driver
use the NIC domain, wheres those added to serve ethtool commands use the 
ETHTOOL one.

Within the ethtool domain, we maintain the priority as the location 
specified by the user, hope this explains
things.

> +enum {
> +	MLX4_DOMAIN_UVERBS	= 0x1000,
> +	MLX4_DOMAIN_ETHTOOL     = 0x2000,
> +	MLX4_DOMAIN_RFS         = 0x3000,
> +	MLX4_DOMAIN_NIC    = 0x5000,
> +};

>> >+			i++;
>> >+		}
>> >+		if (priority)
>> >+			err = 0;
> [...]
>
> But if there are no rules defined, this is an error?  That's not right.
> I think you should unconditionally set err = 0 here.

OK, will do.

Or.
