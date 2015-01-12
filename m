From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next] openvswitch: Introduce vport_route_lookup
Date: Mon, 12 Jan 2015 14:31:00 -0800
Message-ID: <CALnjE+pXY_pPKiHgiO9hVCo_2rNbZ_pPgx-i1KesjEt8E6Nhug@mail.gmail.com>
References: <1421054087-25632-1-git-send-email-fan.du@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>, fengyuleidian0615@gmail.com
To: Fan Du <fan.du@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog126.obsmtp.com ([74.125.149.155]:45473 "HELO
	na3sys009aog126.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751318AbbALWbB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2015 17:31:01 -0500
Received: by mail-ig0-f174.google.com with SMTP id hn15so14005044igb.1
        for <netdev@vger.kernel.org>; Mon, 12 Jan 2015 14:31:00 -0800 (PST)
In-Reply-To: <1421054087-25632-1-git-send-email-fan.du@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 12, 2015 at 1:14 AM, Fan Du <fan.du@intel.com> wrote:
> Introduce vport_route_lookup to consolidate route lookup
> shared by vxlan, gre, and geneve ports.
>
> Signed-off-by: Fan Du <fan.du@intel.com>
> ---
...

>  }
> +
> +struct rtable *vport_route_lookup(struct ovs_key_ipv4_tunnel *tun_key,
> +                                 struct sk_buff *skb,
> +                                 struct flowi4 *fl,
> +                                 struct net *net,
> +                                 u8 protocol)
> +{
> +       struct rtable *rt;
> +
> +       memset(fl, 0, sizeof(*fl));
> +       fl->daddr = tun_key->ipv4_dst;
> +       fl->saddr = tun_key->ipv4_src;
> +       fl->flowi4_tos = RT_TOS(tun_key->ipv4_tos);
> +       fl->flowi4_mark = skb->mark;
> +       fl->flowi4_proto = protocol;
> +
> +       rt = ip_route_output_key(net, fl);
> +       return rt;
> +}
> +EXPORT_SYMBOL_GPL(vport_route_lookup);
This is small function and it is in fast path, So can you inline it?


> diff --git a/net/openvswitch/vport.h b/net/openvswitch/vport.h
> index 99c8e71..4487a97 100644
> --- a/net/openvswitch/vport.h
> +++ b/net/openvswitch/vport.h
> @@ -68,6 +68,12 @@ int ovs_tunnel_get_egress_info(struct ovs_tunnel_info *egress_tun_info,
>  int ovs_vport_get_egress_tun_info(struct vport *vport, struct sk_buff *skb,
>                                   struct ovs_tunnel_info *info);
>
> +struct rtable *vport_route_lookup(struct ovs_key_ipv4_tunnel *tun_key,
> +                                 struct sk_buff *skb,
> +                                 struct flowi4 *fl,
> +                                 struct net *net,
> +                                 u8 protocol);
> +
>  /* The following definitions are for implementers of vport devices: */
>
Generally net is first parameter for networking functions.
Tunnel is better prefix rather than vport for the function name.
You can use new function in ovs_tunnel_get_egress_info().

>  struct vport_err_stats {
> --
> 1.7.1
>
