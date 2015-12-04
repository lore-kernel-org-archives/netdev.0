From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net v2 2/2] vxlan: support ndo_fill_metadata_dst also for IPv6
Date: Fri, 4 Dec 2015 10:49:37 -0800
Message-ID: <CALnjE+qX=sv2wgT=HQ1kfmxVj1KAWe5rWuEEMeNbDr_seBxLqw@mail.gmail.com>
References: <cover.1449139112.git.jbenc@redhat.com>
	<66ad22ee59eb0a21090ff9e3fcad7faf77b63148.1449139112.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, Jesse Gross <jesse@nicira.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f177.google.com ([209.85.223.177]:33244 "EHLO
	mail-io0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751005AbbLDSti (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Dec 2015 13:49:38 -0500
Received: by iouu10 with SMTP id u10so127912686iou.0
        for <netdev@vger.kernel.org>; Fri, 04 Dec 2015 10:49:37 -0800 (PST)
In-Reply-To: <66ad22ee59eb0a21090ff9e3fcad7faf77b63148.1449139112.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 3, 2015 at 2:41 AM, Jiri Benc <jbenc@redhat.com> wrote:
> Fill the metadata correctly even when tunneling over IPv6. Also, check that
> the provided metadata is of an address family that is supported by the
> tunnel.
>
> Signed-off-by: Jiri Benc <jbenc@redhat.com>
> ---
> v2: fixed unused variable warning when building without IPv6
> ---
>  drivers/net/vxlan.c | 26 ++++++++++++++++++++++++--
>  1 file changed, 24 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index 5a38558da157..d3594de3ad07 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -2413,15 +2413,37 @@ static int vxlan_fill_metadata_dst(struct net_device *dev, struct sk_buff *skb)
>  {
>         struct vxlan_dev *vxlan = netdev_priv(dev);
>         struct ip_tunnel_info *info = skb_tunnel_info(skb);
> +#if IS_ENABLED(CONFIG_IPV6)
> +       struct dst_entry *ndst;
> +#endif
>         __be16 sport, dport;
>
>         sport = udp_flow_src_port(dev_net(dev), skb, vxlan->cfg.port_min,
>                                   vxlan->cfg.port_max, true);
>         dport = info->key.tp_dst ? : vxlan->cfg.dst_port;
>
> -       if (ip_tunnel_info_af(info) == AF_INET)
> +       if (ip_tunnel_info_af(info) == AF_INET) {
> +               if (!vxlan->vn4_sock)
> +                       return -EINVAL;
>                 return egress_ipv4_tun_info(dev, skb, info, sport, dport);
> -       return -EINVAL;
> +       } else {
> +               if (!IS_ENABLED(CONFIG_IPV6))
> +                       return -EPFNOSUPPORT;
> +
> +#if IS_ENABLED(CONFIG_IPV6)
> +               if (!vxlan->vn6_sock)
> +                       return -EINVAL;
> +               ndst = vxlan6_get_route(vxlan, skb, 0,
> +                                       &info->key.u.ipv6.dst,
> +                                       &info->key.u.ipv6.src);
> +               if (IS_ERR(ndst))
> +                       return PTR_ERR(ndst);
> +               dst_release(ndst);
> +#endif

Rather than checking IS_ENABLED(CONFIG_IPV6) three separate times, all
code can is restructured in one #if #else block by moving the ndst
definition to IPv6 local block.

> +               info->key.tp_src = sport;
> +               info->key.tp_dst = dport;
> +       }
> +       return 0;
>  }
>
>  static const struct net_device_ops vxlan_netdev_ops = {
> --
> 1.8.3.1
>
