From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net-next 09/10] net/mlx4_en: Manage flow steering rules
 with ethtool
Date: Mon, 2 Jul 2012 15:57:49 +0300
Message-ID: <4FF19ACD.6040602@mellanox.com>
References: <1341135823-29039-1-git-send-email-ogerlitz@mellanox.com>  <1341135823-29039-10-git-send-email-ogerlitz@mellanox.com> <1341158452.4852.107.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <roland@kernel.org>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Oren Duer <oren@mellanox.com>, <netdev@vger.kernel.org>,
	Hadar Hen Zion <hadarh@mellanox.co.il>,
	Amir Vadai <amirv@mellanox.co.il>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog118.obsmtp.com ([207.126.144.145]:43223 "HELO
	eu1sys200aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751173Ab2GBM6I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jul 2012 08:58:08 -0400
In-Reply-To: <1341158452.4852.107.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/1/2012 7:00 PM, Ben Hutchings wrote:
[...]

Hi Ben,

Thanks for the detailed feedback, see below some responses


> +		l4_mask = &cmd->fs.m_u.tcp_ip4_spec;
> +		/* don't allow mask which isn't all 0 or 1 */
> +		if (not_all_zeros_or_all_ones(l4_mask->ip4src, __be32) ||
> +		    not_all_zeros_or_all_ones(l4_mask->ip4dst, __be32) ||
> +		    not_all_zeros_or_all_ones(l4_mask->psrc, __be16) ||
> +		    not_all_zeros_or_all_ones(l4_mask->pdst, __be16))
> +			return -EOPNOTSUPP;
>
> Again, here and in many further instances, the error code should be EINVAL.


OK, will fix to use EINVAL instead of EOPNOTSUPP here and else-where needed.


> +
> +static void add_ip_rule(struct mlx4_en_priv *priv,
> +			struct ethtool_rxnfc *cmd,
> +			struct list_head *list_h)
> +{
> +	struct mlx4_spec_list *spec_l3;
> +
> +	spec_l3 = kzalloc(sizeof *spec_l3, GFP_KERNEL);
> +	if (!spec_l3) {
> +		en_err(priv, "Fail to alloc ethtool rule.\n");
> +		return;
> +	}
>
> This should return an error code as well - logging is not a substitue.

OK, will do.

>
>
>> +	spec_l3->id = MLX4_NET_TRANS_RULE_ID_IPV4;
>> +	spec_l3->ipv4.src_ip = cmd->fs.h_u.usr_ip4_spec.ip4src;
>> +	if (spec_l3->ipv4.src_ip)
>> +		spec_l3->ipv4.src_ip_msk = EN_ETHTOOL_WORD_MASK;
>> +	spec_l3->ipv4.dst_ip = cmd->fs.h_u.usr_ip4_spec.ip4dst;
>> +	if (spec_l3->ipv4.dst_ip)
>> +		spec_l3->ipv4.dst_ip_msk = EN_ETHTOOL_WORD_MASK;
>
> The conditions should be using the mask (cmd->fs.m_u) not the value.

I'd like to clarify things here a bit - the way the code is written, is to

1st make sure that we can deal with the mask provided by the user in the 
ethtool
command, e.g its all zeroes or all ones (leaving a side for a minute the 
other
discussion on how would be best to impl. that check...) - this check is 
done
in mlx4_en_validate_flow

2nd initialize mlx4 flow spec which is all empty - see calls to kzalloc 
spec_l2/l3/l4

3rd import the non-zero values (not masks) from the ethtool command into 
the mlx4
flow specs, with FULL mask


Under this logic, we can use the values and not the masks, isn't that?



>
>
>> +static void add_tcp_udp_rule(struct mlx4_en_priv *priv,
>> +			     struct ethtool_rxnfc *cmd,
>> +			     struct list_head *list_h, int proto)
>> +{
>> +	struct mlx4_spec_list *spec_l3;
>> +	struct mlx4_spec_list *spec_l4;
>> +
>> +	spec_l3 = kzalloc(sizeof *spec_l3, GFP_KERNEL);
>> +	spec_l4 = kzalloc(sizeof *spec_l4, GFP_KERNEL);
>> +	if (!spec_l4 || !spec_l3) {
>> +		en_err(priv, "Fail to alloc ethtool rule.\n");
>
> If one of them was successfully allocated, it will now be leaked.

THANKS, will fix.

>> +static int mlx4_en_ethtool_to_net_trans_rule(struct net_device *dev,
>> +					     struct ethtool_rxnfc *cmd,
>> +					     struct list_head *rule_list_h)
>> +{
>> +	int err;
>> +	u64 mac;
>> +	__be64 be_mac;
>> +	struct ethhdr *eth_spec;
>> +	struct mlx4_en_priv *priv = netdev_priv(dev);
>> +	struct mlx4_spec_list *spec_l2;
>> +	__be64 mac_msk = cpu_to_be64(EN_ETHTOOL_MAC_MASK << 16);
>> +
>> +	err = mlx4_en_validate_flow(dev, cmd);
>> +	if (err)
>> +		return err;
>> +
>> +	spec_l2 = kzalloc(sizeof *spec_l2, GFP_KERNEL);
>> +	if (!spec_l2)
>> +		return -ENOMEM;
>> +
>> +	mac = priv->mac & EN_ETHTOOL_MAC_MASK;
>> +	be_mac = cpu_to_be64(mac << 16);
>> +
>> +	spec_l2->id = MLX4_NET_TRANS_RULE_ID_ETH;
>> +	memcpy(spec_l2->eth.dst_mac_msk, &mac_msk, ETH_ALEN);
>> +	if ((cmd->fs.flow_type & ~FLOW_EXT) != ETHER_FLOW)
>> +		memcpy(spec_l2->eth.dst_mac, &be_mac, ETH_ALEN);
>
> Does the hardware require filtering by MAC address and not only by layer 3/4 addresses?

YES

>
>
>> +	if ((cmd->fs.flow_type & FLOW_EXT) && cmd->fs.m_ext.vlan_tci) {
>> +		spec_l2->eth.vlan_id = cmd->fs.h_ext.vlan_tci;
>> +		spec_l2->eth.vlan_id_msk = cpu_to_be16(0xfff);
>
> This doesn't match mlx4_en_validate_flow(); you are replacing a mask of
> 0xffff with 0xfff.

I need to check how exactly this should be done here, vlan ID is only 12 
bits in size, so this is
probably the source for the 0xfff vs 0xffff


>
>
>> +	switch (cmd->fs.flow_type & ~FLOW_EXT) {
>> +	case ETHER_FLOW:
>> +		eth_spec = &cmd->fs.h_u.ether_spec;
>> +		memcpy(&spec_l2->eth.dst_mac, eth_spec->h_dest, ETH_ALEN);
>> +		spec_l2->eth.ether_type = eth_spec->h_proto;
>> +		if (eth_spec->h_proto)
>> +			spec_l2->eth.ether_type_enable = 1;
>> +		break;
>> +	case IP_USER_FLOW:
>> +		add_ip_rule(priv, cmd, rule_list_h);
>> +		break;
>> +	case TCP_V4_FLOW:
>> +		add_tcp_udp_rule(priv, cmd, rule_list_h, TCP_V4_FLOW);
>> +		break;
>> +	case UDP_V4_FLOW:
>> +		add_tcp_udp_rule(priv, cmd, rule_list_h, UDP_V4_FLOW);
>> +		break;
>
> All those functions need to be able to return errors.


OK
