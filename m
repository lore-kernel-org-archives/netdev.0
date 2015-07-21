From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next 14/22] vxlan: Flow based tunneling
Date: Tue, 21 Jul 2015 19:53:11 +0200
Message-ID: <20150721175311.GE23672@pox.localdomain>
References: <cover.1437468140.git.tgraf@suug.ch>
 <67f2a7c6de2b8829cc41b73a037cf7631c21e483.1437468140.git.tgraf@suug.ch>
 <55AE81C1.2070909@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: roopa@cumulusnetworks.com, rshearma@brocade.com,
	ebiederm@xmission.com, hannes@stressinduktion.org,
	pshelar@nicira.com, jesse@nicira.com, davem@davemloft.net,
	daniel@iogearbox.net, tom@herbertland.com, edumazet@google.com,
	jiri@resnulli.us, marcelo.leitner@gmail.com,
	stephen@networkplumber.org, jpettit@nicira.com, kaber@trash.net,
	simon.horman@netronome.com, joestringer@nicira.com, ja@ssi.bg,
	weichunc@plumgrid.com, netdev@vger.kernel.org, dev@openvswitch.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:34902 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755728AbbGURxP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2015 13:53:15 -0400
Received: by wibxm9 with SMTP id xm9so129361809wib.0
        for <netdev@vger.kernel.org>; Tue, 21 Jul 2015 10:53:13 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <55AE81C1.2070909@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/21/15 at 10:30am, Alexei Starovoitov wrote:
> RX:
> >+		info->mode = IP_TUNNEL_INFO_RX;
> >+		info->key.tun_flags = TUNNEL_KEY;
> >+		info->key.tun_id = cpu_to_be64(vni >> 8);
> ...
> TX:
> >+		dst_port = info->key.tp_dst ? : vxlan->dst_port;
> >+		vni = be64_to_cpu(info->key.tun_id);
> 
> I think the copy paste of ovs_tunnel_info into ip_tunnel_info
> can be improved. In particular instead of '__be64 tun_id'
> we can use '__u64 tun_id' which will avoid extra byteswaps for rx/tx
> paths.
> 
> netlink for this part also seems inconsistent.
> In the patch 16:
> +static const struct nla_policy ip_tun_policy[IP_TUN_MAX + 1] = {
> +	[IP_TUN_ID]		= { .type = NLA_U64 },
> ...
> +	if (tb[IP_TUN_ID])
> +		tun_info->key.tun_id = nla_get_u64(tb[IP_TUN_ID]);
> 
> I think nla_get_be64 should be there?
> and with my suggestion we can add be64_to_cpu() here instead
> of doing it per packet.
> Thoughts?

I like this. The be64 originates from how OVS stores the tun_id in the
flow key. I agree that it makes sense to limit and delay the byteswaps
to when OVS inherits the flow key from the ip_tunnel_info. I will send
a follow-up.
