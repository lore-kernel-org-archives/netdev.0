From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [RFC net-next 0/3] IP imposition of per-nh MPLS encap
Date: Tue, 2 Jun 2015 14:28:58 +0100
Message-ID: <556DAF9A.9050505@brocade.com>
References: <1433177175-16775-1-git-send-email-rshearma@brocade.com> <20150602000603.GB18435@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	roopa <roopa@cumulusnetworks.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:53259 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753009AbbFBNac (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 09:30:32 -0400
In-Reply-To: <20150602000603.GB18435@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/06/15 01:06, Thomas Graf wrote:
> On 06/01/15 at 05:46pm, Robert Shearman wrote:
>> In order to be able to function as a Label Edge Router in an MPLS
>> network, it is necessary to be able to take IP packets and impose an
>> MPLS encap and forward them out. The traditional approach of setting
>> up an interface for each "tunnel" endpoint doesn't scale for the
>> common MPLS use-cases where each IP route tends to be assigned a
>> different label as encap.
>>
>> The solution suggested here for further discussion is to provide the
>> facility to define encap data on a per-nexthop basis using a new
>> netlink attribue, RTA_ENCAP, which would be opaque to the IPv4/IPv6
>> forwarding code, but interpreted by the virtual interface assigned to
>> the nexthop.
>
> RTA_ENCAP is currently a binary blob specific to each encapsulation
> type interface. I guess this should be converted to a set of nested
> Netlink attributes for each type of encap to make it extendible in
> the future.

Nesting attributes inside the RTA_ENCAP blob should be supported by the 
patch series today. Something like this:

+enum rta_tunnel_t {
+	RTA_TUN_UNSPEC,
+	RTA_TUN_ID,
+	RTA_TUN_DST,
+	RTA_TUN_SRC,
+	RTA_TUN_TTL,
+	RTA_TUN_TOS,
+	RTA_TUN_SPORT,
+	RTA_TUN_DPORT,
+	RTA_TUN_FLAGS,
+	RTA_TUN_MAX,
+};
+
+static const struct nla_policy tunnel_policy[RTA_TUN_MAX + 1] = {
+	[RTA_TUN_ID]		= { .type = NLA_U64 },
+	[RTA_TUN_DST]		= { .type = NLA_U32 },
+	[RTA_TUN_SRC]		= { .type = NLA_U32 },
+	[RTA_TUN_TTL]		= { .type = NLA_U8 },
+	[RTA_TUN_TOS]		= { .type = NLA_U8 },
+	[RTA_TUN_SPORT]		= { .type = NLA_U16 },
+	[RTA_TUN_DPORT]		= { .type = NLA_U16 },
+	[RTA_TUN_FLAGS]		= { .type = NLA_U16 },
+};
+
+static int vxlan_parse_encap(const struct net_device *dev,
+			     const struct nlattr *nla,
+			     void *encap)
+{
+	if (encap) {
+		struct ip_tunnel_info *tun_info = encap;
+		struct nlattr *tb[RTA_TUN_MAX+1];
+		int err;
+
+		err = nla_parse_nested(tb, RTA_TUN_MAX, nla, tunnel_policy);
+		if (err < 0)
+			return err;
+
+		if (tb[RTA_TUN_ID])
+			tun_info->key.tun_id = nla_get_u64(tb[RTA_TUN_ID]);
+
+		if (tb[RTA_TUN_DST])
+			tun_info->key.ipv4_dst = nla_get_be32(tb[RTA_TUN_DST]);
+
+		if (tb[RTA_TUN_SRC])
+			tun_info->key.ipv4_src = nla_get_be32(tb[RTA_TUN_SRC]);
+
+		if (tb[RTA_TUN_TTL])
+			tun_info->key.ipv4_ttl = nla_get_u8(tb[RTA_TUN_TTL]);
+
+		if (tb[RTA_TUN_TOS])
+			tun_info->key.ipv4_tos = nla_get_u8(tb[RTA_TUN_TOS]);
+
+		if (tb[RTA_TUN_SPORT])
+			tun_info->key.tp_src = nla_get_be16(tb[RTA_TUN_SPORT]);
+
+		if (tb[RTA_TUN_DPORT])
+			tun_info->key.tp_dst = nla_get_be16(tb[RTA_TUN_DPORT]);
+
+		if (tb[RTA_TUN_FLAGS])
+			tun_info->key.tun_flags = nla_get_u16(tb[RTA_TUN_FLAGS]);
+
+		tun_info->options = NULL;
+		tun_info->options_len = 0;
+	}
+
+	return sizeof(struct ip_tunnel_info);
+}
+
+static int vxlan_fill_encap(const struct net_device *dev,
+			    struct sk_buff *skb, int encap_len,
+			    const void *encap)
+{
+	const struct ip_tunnel_info *tun_info = encap;
+	struct nlattr *encap_attr;
+
+	encap_attr = nla_nest_start(skb, RTA_ENCAP);
+	if (!encap_attr)
+		return -ENOMEM;
+
+	if (nla_put_u64(skb, RTA_TUN_ID, tun_info->key.tun_id) ||
+	    nla_put_be32(skb, RTA_TUN_DST, tun_info->key.ipv4_dst) ||
+	    nla_put_be32(skb, RTA_TUN_SRC, tun_info->key.ipv4_src) ||
+	    nla_put_u8(skb, RTA_TUN_TOS, tun_info->key.ipv4_tos) ||
+	    nla_put_u8(skb, RTA_TUN_TTL, tun_info->key.ipv4_ttl) ||
+	    nla_put_u16(skb, RTA_TUN_SPORT, tun_info->key.tp_src) ||
+	    nla_put_u16(skb, RTA_TUN_DPORT, tun_info->key.tp_dst) ||
+	    nla_put_u16(skb, RTA_TUN_FLAGS, tun_info->key.tun_flags))
+		return -ENOMEM;
+
+	nla_nest_end(skb, encap_attr);
+
+	return 0;
+}
+
+static int vxlan_match_encap(const struct net_device *dev,
+			     const struct nlattr *nla, int encap_len,
+			     const void *encap)
+{
+	const struct ip_tunnel_info *tun_info = encap;
+	struct nlattr *tb[RTA_TUN_MAX+1];
+	int err;
+
+	err = nla_parse_nested(tb, RTA_TUN_MAX, nla, tunnel_policy);
+	if (err < 0)
+		return err;
+
+	if (tb[RTA_TUN_ID] &&
+	    tun_info->key.tun_id != nla_get_u64(tb[RTA_TUN_ID]))
+		return 1;
+
+	if (tb[RTA_TUN_DST] &&
+	    tun_info->key.ipv4_dst != nla_get_be32(tb[RTA_TUN_DST]))
+		return 1;
+
+	if (tb[RTA_TUN_SRC] &&
+	    tun_info->key.ipv4_src != nla_get_be32(tb[RTA_TUN_SRC]))
+		return 1;
+
+	if (tb[RTA_TUN_TTL] &&
+	    tun_info->key.ipv4_ttl != nla_get_u8(tb[RTA_TUN_TTL]))
+		return 1;
+
+	if (tb[RTA_TUN_TOS] &&
+	    tun_info->key.ipv4_tos != nla_get_u8(tb[RTA_TUN_TOS]))
+		return 1;
+
+	if (tb[RTA_TUN_SPORT] &&
+	    tun_info->key.tp_src != nla_get_be16(tb[RTA_TUN_SPORT]))
+		return 1;
+
+	if (tb[RTA_TUN_DPORT] &&
+	    tun_info->key.tp_dst != nla_get_be16(tb[RTA_TUN_DPORT]))
+		return 1;
+
+	if (tb[RTA_TUN_FLAGS] &&
+	    tun_info->key.tun_flags != nla_get_u16(tb[RTA_TUN_FLAGS]))
+		return 1;
+
+	return 0;
+}
+
  static struct rtnl_link_ops vxlan_link_ops __read_mostly = {
  	.kind		= "vxlan",
  	.maxtype	= IFLA_VXLAN_MAX,
@@ -2893,6 +3093,9 @@ static struct rtnl_link_ops vxlan_link_ops 
__read_mostly = {
  	.get_size	= vxlan_get_size,
  	.fill_info	= vxlan_fill_info,
  	.get_link_net	= vxlan_get_link_net,
+	.parse_encap	= vxlan_parse_encap,
+	.fill_encap	= vxlan_fill_encap,
+	.match_encap	= vxlan_match_encap,
  };


> What is your plan regarding the receive side and on the matching of
> encap fields? Storing the receive parameters is what lead me to
> storing it in skb_shared_info.

No plan for the receive side and it wouldn't easily fit in with my 
approach, so you'll need to implement that separately.

Thanks,
Rob
