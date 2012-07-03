From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net-next 09/10] net/mlx4_en: Manage flow steering rules
 with ethtool
Date: Tue, 3 Jul 2012 12:00:00 +0300
Message-ID: <4FF2B490.4070703@mellanox.com>
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
Received: from eu1sys200aog116.obsmtp.com ([207.126.144.141]:45476 "HELO
	eu1sys200aog116.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751969Ab2GCJAP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jul 2012 05:00:15 -0400
In-Reply-To: <1341158452.4852.107.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/1/2012 7:00 PM, Ben Hutchings wrote:
>> +#define not_all_zeros_or_all_ones(field, type) \
>> >+	(field && (type)~field)
>> >+
>> >+static int mlx4_en_validate_flow(struct net_device *dev,
>> >+				 struct ethtool_rxnfc *cmd)
>> >+{
>> >+	struct ethtool_usrip4_spec *l3_mask;
>> >+	struct ethtool_tcpip4_spec *l4_mask;
>> >+	struct ethhdr *eth_mask;
>> >+	u64 full_mac = ~0ull;
>> >+	u64 zero_mac = 0;
>> >+
>> >+	if (cmd->fs.location >= MAX_NUM_OF_FS_RULES)
>> >+		return -EINVAL;
>> >+
>> >+	switch (cmd->fs.flow_type & ~FLOW_EXT) {
>> >+	case TCP_V4_FLOW:
>> >+	case UDP_V4_FLOW:
>> >+		if (cmd->fs.h_u.tcp_ip4_spec.tos)
>> >+			return -EOPNOTSUPP;
> I suspect that your filter ignores TOS, rather than only matching TOS ==
> 0, so you should actually be checking the corresponding field in the
> mask (fs.m_u). [...]

OK, thanks for pointing this over, will fix.

> >+		break;
> >+	case IP_USER_FLOW:
> >+		l3_mask = &cmd->fs.m_u.usr_ip4_spec;
> >+		if (cmd->fs.h_u.usr_ip4_spec.l4_4_bytes ||
> >+		    cmd->fs.h_u.usr_ip4_spec.tos ||
> I think this should be checking l4_4_bytes and tos in the mask.

OK

>
>> >+		    cmd->fs.h_u.usr_ip4_spec.proto ||
>> >+		    cmd->fs.h_u.usr_ip4_spec.ip_ver != ETH_RX_NFC_IP4 ||
>> >+		    (!cmd->fs.h_u.usr_ip4_spec.ip4src &&
>> >+		     !cmd->fs.h_u.usr_ip4_spec.ip4dst) ||
>> >+		    not_all_zeros_or_all_ones(l3_mask->ip4src, __be32) ||
>> >+		    not_all_zeros_or_all_ones(l3_mask->ip4dst, __be32))
>> >+			return -EOPNOTSUPP;
>> >+		break;
>> >+	case ETHER_FLOW:
>> >+		eth_mask = &cmd->fs.m_u.ether_spec;
>> >+		if (memcmp(eth_mask->h_source, &zero_mac, ETH_ALEN))
>> >+			return -EOPNOTSUPP;
>> >+		if (!memcmp(eth_mask->h_dest, &zero_mac, ETH_ALEN))
>> >+			return -EOPNOTSUPP;
> But in the next statement you test whether eth_mask->h_dest is either
> all-zeroes or all-ones.  Is all-zeroes valid or not?  I suspect you
> actually intend to reject the case where both h_dest and h_proto are masked out.

indeed, this code section can be better written, will fix for V1


>
>> >+		if (not_all_zeros_or_all_ones(eth_mask->h_proto, __be16) ||
>> >+		    (memcmp(eth_mask->h_dest, &zero_mac, ETH_ALEN) &&
>> >+		     memcmp(eth_mask->h_dest, &full_mac, ETH_ALEN)))
>> >+			return -EOPNOTSUPP;
>> >+		break;
>> >+	default:
>> >+		return -EOPNOTSUPP;
>> >+	}
>> >+
>> >+	if ((cmd->fs.flow_type & FLOW_EXT)) {
>> >+		if (cmd->fs.m_ext.vlan_etype ||
>> >+		    not_all_zeros_or_all_ones(cmd->fs.m_ext.vlan_tci,
>> >+					       __be16)) {
>> >+			return -EOPNOTSUPP;
>> >+		}
>> >+	}
>> >+
>> >+	return 0;
>> >+}
