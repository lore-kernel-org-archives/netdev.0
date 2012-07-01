From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 09/10] net/mlx4_en: Manage flow steering rules
 with ethtool
Date: Sun, 1 Jul 2012 17:00:52 +0100
Message-ID: <1341158452.4852.107.camel@deadeye.wl.decadent.org.uk>
References: <1341135823-29039-1-git-send-email-ogerlitz@mellanox.com>
	 <1341135823-29039-10-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <roland@kernel.org>,
	<yevgenyp@mellanox.com>, <oren@mellanox.com>,
	<netdev@vger.kernel.org>, Hadar Hen Zion <hadarh@mellanox.co.il>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:13831 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752214Ab2GAQBA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jul 2012 12:01:00 -0400
In-Reply-To: <1341135823-29039-10-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-07-01 at 12:43 +0300, Or Gerlitz wrote:
> From: Hadar Hen Zion <hadarh@mellanox.co.il>
> 
> Implement the ethtool APIs for attaching L2/L3/L4 based flow steering
> rules to the netdevice RX rings. Added set_rxnfc callback and enhanced
> the existing get_rxnfc callback.
> 
> Signed-off-by: Hadar Hen Zion <hadarh@mellanox.co.il>
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
> ---
>  drivers/net/ethernet/mellanox/mlx4/en_ethtool.c |  373 +++++++++++++++++++++++
>  drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    |    7 +
>  2 files changed, 380 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
> index 72901ce..30de264 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
> @@ -38,6 +38,10 @@
>  #include "mlx4_en.h"
>  #include "en_port.h"
>  
> +#define EN_ETHTOOL_QP_ATTACH (1ull << 63)
> +#define EN_ETHTOOL_MAC_MASK 0xffffffffffffULL
> +#define EN_ETHTOOL_SHORT_MASK cpu_to_be16(0xffff)
> +#define EN_ETHTOOL_WORD_MASK  cpu_to_be32(0xffffffff)
>  
>  static void
>  mlx4_en_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *drvinfo)
> @@ -599,16 +603,360 @@ static int mlx4_en_set_rxfh_indir(struct net_device *dev,
>  	return err;
>  }
>  
> +#define not_all_zeros_or_all_ones(field, type) \
> +	(field && (type)~field)
> +
> +static int mlx4_en_validate_flow(struct net_device *dev,
> +				 struct ethtool_rxnfc *cmd)
> +{
> +	struct ethtool_usrip4_spec *l3_mask;
> +	struct ethtool_tcpip4_spec *l4_mask;
> +	struct ethhdr *eth_mask;
> +	u64 full_mac = ~0ull;
> +	u64 zero_mac = 0;
> +
> +	if (cmd->fs.location >= MAX_NUM_OF_FS_RULES)
> +		return -EINVAL;
> +
> +	switch (cmd->fs.flow_type & ~FLOW_EXT) {
> +	case TCP_V4_FLOW:
> +	case UDP_V4_FLOW:
> +		if (cmd->fs.h_u.tcp_ip4_spec.tos)
> +			return -EOPNOTSUPP;

I suspect that your filter ignores TOS, rather than only matching TOS ==
0, so you should actually be checking the corresponding field in the
mask (fs.m_u).  The error code should be EINVAL.

> +		l4_mask = &cmd->fs.m_u.tcp_ip4_spec;
> +		/* don't allow mask which isn't all 0 or 1 */
> +		if (not_all_zeros_or_all_ones(l4_mask->ip4src, __be32) ||
> +		    not_all_zeros_or_all_ones(l4_mask->ip4dst, __be32) ||
> +		    not_all_zeros_or_all_ones(l4_mask->psrc, __be16) ||
> +		    not_all_zeros_or_all_ones(l4_mask->pdst, __be16))
> +			return -EOPNOTSUPP;

Again, here and in many further instances, the error code should be
EINVAL.

> +		break;
> +	case IP_USER_FLOW:
> +		l3_mask = &cmd->fs.m_u.usr_ip4_spec;
> +		if (cmd->fs.h_u.usr_ip4_spec.l4_4_bytes ||
> +		    cmd->fs.h_u.usr_ip4_spec.tos ||

I think this should be checking l4_4_bytes and tos in the mask.

> +		    cmd->fs.h_u.usr_ip4_spec.proto ||
> +		    cmd->fs.h_u.usr_ip4_spec.ip_ver != ETH_RX_NFC_IP4 ||
> +		    (!cmd->fs.h_u.usr_ip4_spec.ip4src &&
> +		     !cmd->fs.h_u.usr_ip4_spec.ip4dst) ||
> +		    not_all_zeros_or_all_ones(l3_mask->ip4src, __be32) ||
> +		    not_all_zeros_or_all_ones(l3_mask->ip4dst, __be32))
> +			return -EOPNOTSUPP;
> +		break;
> +	case ETHER_FLOW:
> +		eth_mask = &cmd->fs.m_u.ether_spec;
> +		if (memcmp(eth_mask->h_source, &zero_mac, ETH_ALEN))
> +			return -EOPNOTSUPP;
> +		if (!memcmp(eth_mask->h_dest, &zero_mac, ETH_ALEN))
> +			return -EOPNOTSUPP;

But in the next statement you test whether eth_mask->h_dest is either
all-zeroes or all-ones.  Is all-zeroes valid or not?  I suspect you
actually intend to reject the case where both h_dest and h_proto are
masked out.

> +		if (not_all_zeros_or_all_ones(eth_mask->h_proto, __be16) ||
> +		    (memcmp(eth_mask->h_dest, &zero_mac, ETH_ALEN) &&
> +		     memcmp(eth_mask->h_dest, &full_mac, ETH_ALEN)))
> +			return -EOPNOTSUPP;
> +		break;
> +	default:
> +		return -EOPNOTSUPP;
> +	}
> +
> +	if ((cmd->fs.flow_type & FLOW_EXT)) {
> +		if (cmd->fs.m_ext.vlan_etype ||
> +		    not_all_zeros_or_all_ones(cmd->fs.m_ext.vlan_tci,
> +					       __be16)) {
> +			return -EOPNOTSUPP;
> +		}
> +	}
> +
> +	return 0;
> +}
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

This should return an error code as well - logging is not a substitue.

> +	spec_l3->id = MLX4_NET_TRANS_RULE_ID_IPV4;
> +	spec_l3->ipv4.src_ip = cmd->fs.h_u.usr_ip4_spec.ip4src;
> +	if (spec_l3->ipv4.src_ip)
> +		spec_l3->ipv4.src_ip_msk = EN_ETHTOOL_WORD_MASK;
> +	spec_l3->ipv4.dst_ip = cmd->fs.h_u.usr_ip4_spec.ip4dst;
> +	if (spec_l3->ipv4.dst_ip)
> +		spec_l3->ipv4.dst_ip_msk = EN_ETHTOOL_WORD_MASK;

The conditions should be using the mask (cmd->fs.m_u) not the value.

> +	list_add_tail(&spec_l3->list, list_h);
> +}
> +
> +static void add_tcp_udp_rule(struct mlx4_en_priv *priv,
> +			     struct ethtool_rxnfc *cmd,
> +			     struct list_head *list_h, int proto)
> +{
> +	struct mlx4_spec_list *spec_l3;
> +	struct mlx4_spec_list *spec_l4;
> +
> +	spec_l3 = kzalloc(sizeof *spec_l3, GFP_KERNEL);
> +	spec_l4 = kzalloc(sizeof *spec_l4, GFP_KERNEL);
> +	if (!spec_l4 || !spec_l3) {
> +		en_err(priv, "Fail to alloc ethtool rule.\n");

If one of them was successfully allocated, it will now be leaked.

> +		return;
> +	}
> +
> +	spec_l3->id = MLX4_NET_TRANS_RULE_ID_IPV4;
> +
> +	if (proto == TCP_V4_FLOW) {
> +		spec_l4->id = MLX4_NET_TRANS_RULE_ID_TCP;
> +		spec_l3->ipv4.src_ip = cmd->fs.h_u.tcp_ip4_spec.ip4src;
> +		spec_l3->ipv4.dst_ip = cmd->fs.h_u.tcp_ip4_spec.ip4dst;
> +		spec_l4->tcp_udp.src_port = cmd->fs.h_u.tcp_ip4_spec.psrc;
> +		spec_l4->tcp_udp.dst_port = cmd->fs.h_u.tcp_ip4_spec.pdst;
> +	} else {
> +		spec_l4->id = MLX4_NET_TRANS_RULE_ID_UDP;
> +		spec_l3->ipv4.src_ip = cmd->fs.h_u.udp_ip4_spec.ip4src;
> +		spec_l3->ipv4.dst_ip = cmd->fs.h_u.udp_ip4_spec.ip4dst;
> +		spec_l4->tcp_udp.src_port = cmd->fs.h_u.udp_ip4_spec.psrc;
> +		spec_l4->tcp_udp.dst_port = cmd->fs.h_u.udp_ip4_spec.pdst;
> +	}
> +
> +	if (spec_l3->ipv4.src_ip)
> +		spec_l3->ipv4.src_ip_msk = EN_ETHTOOL_WORD_MASK;
> +	if (spec_l3->ipv4.dst_ip)
> +		spec_l3->ipv4.dst_ip_msk = EN_ETHTOOL_WORD_MASK;
> +
> +	if (spec_l4->tcp_udp.src_port)
> +		spec_l4->tcp_udp.src_port_msk = EN_ETHTOOL_SHORT_MASK;
> +	if (spec_l4->tcp_udp.dst_port)
> +		spec_l4->tcp_udp.dst_port_msk = EN_ETHTOOL_SHORT_MASK;

All these conditions should be using the mask, not the value.

> +	list_add_tail(&spec_l3->list, list_h);
> +	list_add_tail(&spec_l4->list, list_h);
> +}
> +
> +static int mlx4_en_ethtool_to_net_trans_rule(struct net_device *dev,
> +					     struct ethtool_rxnfc *cmd,
> +					     struct list_head *rule_list_h)
> +{
> +	int err;
> +	u64 mac;
> +	__be64 be_mac;
> +	struct ethhdr *eth_spec;
> +	struct mlx4_en_priv *priv = netdev_priv(dev);
> +	struct mlx4_spec_list *spec_l2;
> +	__be64 mac_msk = cpu_to_be64(EN_ETHTOOL_MAC_MASK << 16);
> +
> +	err = mlx4_en_validate_flow(dev, cmd);
> +	if (err)
> +		return err;
> +
> +	spec_l2 = kzalloc(sizeof *spec_l2, GFP_KERNEL);
> +	if (!spec_l2)
> +		return -ENOMEM;
> +
> +	mac = priv->mac & EN_ETHTOOL_MAC_MASK;
> +	be_mac = cpu_to_be64(mac << 16);
> +
> +	spec_l2->id = MLX4_NET_TRANS_RULE_ID_ETH;
> +	memcpy(spec_l2->eth.dst_mac_msk, &mac_msk, ETH_ALEN);
> +	if ((cmd->fs.flow_type & ~FLOW_EXT) != ETHER_FLOW)
> +		memcpy(spec_l2->eth.dst_mac, &be_mac, ETH_ALEN);

Does the hardware require filtering by MAC address and not only by layer
3/4 addresses?

> +	if ((cmd->fs.flow_type & FLOW_EXT) && cmd->fs.m_ext.vlan_tci) {
> +		spec_l2->eth.vlan_id = cmd->fs.h_ext.vlan_tci;
> +		spec_l2->eth.vlan_id_msk = cpu_to_be16(0xfff);

This doesn't match mlx4_en_validate_flow(); you are replacing a mask of
0xffff with 0xfff.

> +	}
> +
> +	list_add_tail(&spec_l2->list, rule_list_h);
> +
> +	switch (cmd->fs.flow_type & ~FLOW_EXT) {
> +	case ETHER_FLOW:
> +		eth_spec = &cmd->fs.h_u.ether_spec;
> +		memcpy(&spec_l2->eth.dst_mac, eth_spec->h_dest, ETH_ALEN);
> +		spec_l2->eth.ether_type = eth_spec->h_proto;
> +		if (eth_spec->h_proto)
> +			spec_l2->eth.ether_type_enable = 1;
> +		break;
> +	case IP_USER_FLOW:
> +		add_ip_rule(priv, cmd, rule_list_h);
> +		break;
> +	case TCP_V4_FLOW:
> +		add_tcp_udp_rule(priv, cmd, rule_list_h, TCP_V4_FLOW);
> +		break;
> +	case UDP_V4_FLOW:
> +		add_tcp_udp_rule(priv, cmd, rule_list_h, UDP_V4_FLOW);
> +		break;

All those functions need to be able to return errors.

> +	}
> +	return 0;
> +}
> +
> +static int mlx4_en_flow_replace(struct net_device *dev,
> +				struct ethtool_rxnfc *cmd)
> +{
> +	int err;
> +	struct mlx4_en_priv *priv = netdev_priv(dev);
> +	struct ethtool_flow_id *loc_rule;
> +	struct mlx4_spec_list *spec, *tmp_spec;
> +	u32 qpn;
> +	u64 reg_id;
> +
> +	struct mlx4_net_trans_rule rule = {
> +		.queue_mode = MLX4_NET_TRANS_Q_FIFO,
> +		.exclusive = 0,
> +		.allow_loopback = 1,
> +		.promisc_mode = MLX4_FS_PROMISC_NONE,
> +	};
> +
> +	rule.port = priv->port;
> +	rule.priority = MLX4_DOMAIN_ETHTOOL | cmd->fs.location;
> +	INIT_LIST_HEAD(&rule.list);
> +
> +	/* Allow direct QP attaches if the EN_ETHTOOL_QP_ATTACH flag is set */
> +	if (cmd->fs.ring_cookie == RX_CLS_FLOW_DISC)
> +		return -EOPNOTSUPP;

EINVAL.

[...]
>  static int mlx4_en_get_rxnfc(struct net_device *dev, struct ethtool_rxnfc *cmd,
>  			     u32 *rule_locs)
>  {
>  	struct mlx4_en_priv *priv = netdev_priv(dev);
> +	struct mlx4_en_dev *mdev = priv->mdev;
>  	int err = 0;
> +	int i = 0, priority = 0;
> +
> +	if (mdev->dev->caps.steering_mode != MLX4_STEERING_MODE_DEVICE_MANAGED)
> +		return -EOPNOTSUPP;
>  
>  	switch (cmd->cmd) {
>  	case ETHTOOL_GRXRINGS:
>  		cmd->data = priv->rx_ring_num;
>  		break;
> +	case ETHTOOL_GRXCLSRLCNT:
> +		cmd->rule_cnt = mlx4_en_get_num_flows(priv);
> +		break;
> +	case ETHTOOL_GRXCLSRULE:
> +		err = mlx4_en_get_flow(dev, cmd, cmd->fs.location);
> +		break;
> +	case ETHTOOL_GRXCLSRLALL:
> +		while (!err || err == -ENOENT) {
> +			err = mlx4_en_get_flow(dev, cmd, i);
> +			if (!err)
> +				((u32 *)(rule_locs))[priority++] = i;

I don't see any range check against cmd->rule_cnt.

Why are you casting rule_locs?

Also, are the rules really prioritised by location, so that if rule 0
and 1 match a packet then only rule 0 is applied?  If they are actually
prioritised by the match type then you need to assign locations on the
driver side that reflect the actual priorities.

> +			i++;
> +		}
> +		if (priority)
> +			err = 0;
[...]

But if there are no rules defined, this is an error?  That's not right.
I think you should unconditionally set err = 0 here.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
