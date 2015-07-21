From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next 14/22] vxlan: Flow based tunneling
Date: Tue, 21 Jul 2015 10:30:41 -0700
Message-ID: <55AE81C1.2070909@plumgrid.com>
References: <cover.1437468140.git.tgraf@suug.ch>
 <67f2a7c6de2b8829cc41b73a037cf7631c21e483.1437468140.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: Thomas Graf <tgraf@suug.ch>, roopa@cumulusnetworks.com,
	rshearma@brocade.com, ebiederm@xmission.com,
	hannes@stressinduktion.org, pshelar@nicira.com, jesse@nicira.com,
	davem@davemloft.net, daniel@iogearbox.net, tom@herbertland.com,
	edumazet@google.com, jiri@resnulli.us, marcelo.leitner@gmail.com,
	stephen@networkplumber.org, jpettit@nicira.com, kaber@trash.net,
	simon.horman@netronome.com, joestringer@nicira.com, ja@ssi.bg,
	weichunc@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:36651 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755088AbbGURap (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2015 13:30:45 -0400
Received: by pachj5 with SMTP id hj5so123747171pac.3
        for <netdev@vger.kernel.org>; Tue, 21 Jul 2015 10:30:44 -0700 (PDT)
In-Reply-To: <67f2a7c6de2b8829cc41b73a037cf7631c21e483.1437468140.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/21/15 1:43 AM, Thomas Graf wrote:
> This prepares the VXLAN device to be steered by the routing and other
> subsystems which allows to support encapsulation for a large number
> of tunnel endpoints and tunnel ids through a single net_device which
> improves the scalability.

+1. looks very useful.

RX:
> +		info->mode = IP_TUNNEL_INFO_RX;
> +		info->key.tun_flags = TUNNEL_KEY;
> +		info->key.tun_id = cpu_to_be64(vni >> 8);
...
TX:
> +		dst_port = info->key.tp_dst ? : vxlan->dst_port;
> +		vni = be64_to_cpu(info->key.tun_id);

I think the copy paste of ovs_tunnel_info into ip_tunnel_info
can be improved. In particular instead of '__be64 tun_id'
we can use '__u64 tun_id' which will avoid extra byteswaps for rx/tx
paths.

netlink for this part also seems inconsistent.
In the patch 16:
+static const struct nla_policy ip_tun_policy[IP_TUN_MAX + 1] = {
+	[IP_TUN_ID]		= { .type = NLA_U64 },
...
+	if (tb[IP_TUN_ID])
+		tun_info->key.tun_id = nla_get_u64(tb[IP_TUN_ID]);

I think nla_get_be64 should be there?
and with my suggestion we can add be64_to_cpu() here instead
of doing it per packet.
Thoughts?
