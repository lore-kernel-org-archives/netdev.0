From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 09/10] net/mlx4_en: Manage flow steering rules
 with ethtool
Date: Tue, 3 Jul 2012 02:47:21 +0100
Message-ID: <1341280041.2590.39.camel@bwh-desktop.uk.solarflarecom.com>
References: <1341135823-29039-1-git-send-email-ogerlitz@mellanox.com>
	  <1341135823-29039-10-git-send-email-ogerlitz@mellanox.com>
	 <1341158452.4852.107.camel@deadeye.wl.decadent.org.uk>
	 <4FF19ACD.6040602@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <roland@kernel.org>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Oren Duer <oren@mellanox.com>, <netdev@vger.kernel.org>,
	Hadar Hen Zion <hadarh@mellanox.co.il>,
	Amir Vadai <amirv@mellanox.co.il>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:54851 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755898Ab2GCBrZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jul 2012 21:47:25 -0400
In-Reply-To: <4FF19ACD.6040602@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-07-02 at 15:57 +0300, Or Gerlitz wrote:
> On 7/1/2012 7:00 PM, Ben Hutchings wrote:
[...]
> >> +	spec_l3->id = MLX4_NET_TRANS_RULE_ID_IPV4;
> >> +	spec_l3->ipv4.src_ip = cmd->fs.h_u.usr_ip4_spec.ip4src;
> >> +	if (spec_l3->ipv4.src_ip)
> >> +		spec_l3->ipv4.src_ip_msk = EN_ETHTOOL_WORD_MASK;
> >> +	spec_l3->ipv4.dst_ip = cmd->fs.h_u.usr_ip4_spec.ip4dst;
> >> +	if (spec_l3->ipv4.dst_ip)
> >> +		spec_l3->ipv4.dst_ip_msk = EN_ETHTOOL_WORD_MASK;
> >
> > The conditions should be using the mask (cmd->fs.m_u) not the value.
> 
> I'd like to clarify things here a bit - the way the code is written, is to
> 
> 1st make sure that we can deal with the mask provided by the user in the 
> ethtool
> command, e.g its all zeroes or all ones (leaving a side for a minute the 
> other
> discussion on how would be best to impl. that check...) - this check is 
> done
> in mlx4_en_validate_flow
> 
> 2nd initialize mlx4 flow spec which is all empty - see calls to kzalloc 
> spec_l2/l3/l4
> 
> 3rd import the non-zero values (not masks) from the ethtool command into 
> the mlx4
> flow specs, with FULL mask
> 
> 
> Under this logic, we can use the values and not the masks, isn't that?

No, it's perfectly valid to specify a filter that matches, for example,
a destination IP address of 0.0.0.0 with mask of 255.255.255.255.  So
you really need to check the mask.  If your filter hardware doesn't
support zero values for some fields then you'll need to reject them in
mlx4_en_validate_flow.

[...]
> >> +static int mlx4_en_ethtool_to_net_trans_rule(struct net_device *dev,
> >> +					     struct ethtool_rxnfc *cmd,
> >> +					     struct list_head *rule_list_h)
> >> +{
> >> +	int err;
> >> +	u64 mac;
> >> +	__be64 be_mac;
> >> +	struct ethhdr *eth_spec;
> >> +	struct mlx4_en_priv *priv = netdev_priv(dev);
> >> +	struct mlx4_spec_list *spec_l2;
> >> +	__be64 mac_msk = cpu_to_be64(EN_ETHTOOL_MAC_MASK << 16);
> >> +
> >> +	err = mlx4_en_validate_flow(dev, cmd);
> >> +	if (err)
> >> +		return err;
> >> +
> >> +	spec_l2 = kzalloc(sizeof *spec_l2, GFP_KERNEL);
> >> +	if (!spec_l2)
> >> +		return -ENOMEM;
> >> +
> >> +	mac = priv->mac & EN_ETHTOOL_MAC_MASK;
> >> +	be_mac = cpu_to_be64(mac << 16);
> >> +
> >> +	spec_l2->id = MLX4_NET_TRANS_RULE_ID_ETH;
> >> +	memcpy(spec_l2->eth.dst_mac_msk, &mac_msk, ETH_ALEN);
> >> +	if ((cmd->fs.flow_type & ~FLOW_EXT) != ETHER_FLOW)
> >> +		memcpy(spec_l2->eth.dst_mac, &be_mac, ETH_ALEN);
> >
> > Does the hardware require filtering by MAC address and not only by layer 3/4 addresses?
> 
> YES

That's a pity.  Maybe the API should be extended so the driver can at
least report that the filter is narrower than requested.

> >> +	if ((cmd->fs.flow_type & FLOW_EXT) && cmd->fs.m_ext.vlan_tci) {
> >> +		spec_l2->eth.vlan_id = cmd->fs.h_ext.vlan_tci;
> >> +		spec_l2->eth.vlan_id_msk = cpu_to_be16(0xfff);
> >
> > This doesn't match mlx4_en_validate_flow(); you are replacing a mask of
> > 0xffff with 0xfff.
> 
> I need to check how exactly this should be done here, vlan ID is only 12 
> bits in size, so this is
> probably the source for the 0xfff vs 0xffff
[...]

If the hardware can only match the VID then you need to validate that
the mask is either 0 or 0xfff instead of 0 or 0xffff.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
