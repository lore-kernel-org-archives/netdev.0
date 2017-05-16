From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [PATCH net-next] geneve: add rtnl changelink support
Date: Tue, 16 May 2017 13:00:55 -0700
Message-ID: <CAOrHB_CRBWb2odpyFBaZS0sJ=zK=ve4d8LRp0iVNJehghmsBGQ@mail.gmail.com>
References: <1494870424-22699-1-git-send-email-girish.moodalbail@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Joe Stringer <joe@ovn.org>, Jiri Benc <jbenc@redhat.com>
To: Girish Moodalbail <girish.moodalbail@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay4-d.mail.gandi.net ([217.70.183.196]:55668 "EHLO
        relay4-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751587AbdEPUA7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 16:00:59 -0400
Received: from mfilter19-d.gandi.net (mfilter19-d.gandi.net [217.70.178.147])
        by relay4-d.mail.gandi.net (Postfix) with ESMTP id B3E41172095
        for <netdev@vger.kernel.org>; Tue, 16 May 2017 22:00:57 +0200 (CEST)
Received: from relay4-d.mail.gandi.net ([IPv6:::ffff:217.70.183.196])
        by mfilter19-d.gandi.net (mfilter19-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id hKHFVjKcsDNg for <netdev@vger.kernel.org>;
        Tue, 16 May 2017 22:00:56 +0200 (CEST)
Received: from mail-wr0-f176.google.com (mail-wr0-f176.google.com [209.85.128.176])
        (Authenticated sender: pshelar@ovn.org)
        by relay4-d.mail.gandi.net (Postfix) with ESMTPSA id 2FBC61720B1
        for <netdev@vger.kernel.org>; Tue, 16 May 2017 22:00:56 +0200 (CEST)
Received: by mail-wr0-f176.google.com with SMTP id w50so83063436wrc.0
        for <netdev@vger.kernel.org>; Tue, 16 May 2017 13:00:56 -0700 (PDT)
In-Reply-To: <1494870424-22699-1-git-send-email-girish.moodalbail@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 15, 2017 at 10:47 AM, Girish Moodalbail
<girish.moodalbail@oracle.com> wrote:
> This patch adds changelink rtnl operation support for geneve devices.
> Code changes involve:
>   - refactor geneve_newlink into geneve_nl2info to be used by both
>     geneve_newlink and geneve_changelink
>   - geneve_nl2info takes a changelink boolean argument to isolate
>     changelink checks and updates.
>   - Allow changing only a few attributes:
>     - return -EOPNOTSUPP for attributes that cannot be changed for
>       now. Incremental patches can make the non-supported one
>       available in the future if needed.
>
Thanks for working on this.

> Signed-off-by: Girish Moodalbail <girish.moodalbail@oracle.com>
> ---
>  drivers/net/geneve.c | 149 ++++++++++++++++++++++++++++++++++++++++-----------
>  1 file changed, 117 insertions(+), 32 deletions(-)
>
...
> @@ -1169,45 +1181,58 @@ static void init_tnl_info(struct ip_tunnel_info *info, __u16 dst_port)
>         info->key.tp_dst = htons(dst_port);
>  }
>
> -static int geneve_newlink(struct net *net, struct net_device *dev,
> -                         struct nlattr *tb[], struct nlattr *data[])
> +static int geneve_nl2info(struct net_device *dev, struct nlattr *tb[],
> +                         struct nlattr *data[], struct ip_tunnel_info *info,
> +                         bool *metadata, bool *use_udp6_rx_checksums,
> +                         bool changelink)
>  {
> -       bool use_udp6_rx_checksums = false;
> -       struct ip_tunnel_info info;
> -       bool metadata = false;
> +       struct geneve_dev *geneve = netdev_priv(dev);
>
> -       init_tnl_info(&info, GENEVE_UDP_PORT);
> +       if (changelink) {
> +               /* if changelink operation, start with old existing info */
> +               memcpy(info, &geneve->info, sizeof(*info));
> +               *metadata = geneve->collect_md;
> +               *use_udp6_rx_checksums = geneve->use_udp6_rx_checksums;
> +       } else {
> +               init_tnl_info(info, GENEVE_UDP_PORT);
> +       }
>
>         if (data[IFLA_GENEVE_REMOTE] && data[IFLA_GENEVE_REMOTE6])
>                 return -EINVAL;
>
>         if (data[IFLA_GENEVE_REMOTE]) {
> -               info.key.u.ipv4.dst =
> +               info->key.u.ipv4.dst =
>                         nla_get_in_addr(data[IFLA_GENEVE_REMOTE]);
>
> -               if (IN_MULTICAST(ntohl(info.key.u.ipv4.dst))) {
> +               if (IN_MULTICAST(ntohl(info->key.u.ipv4.dst))) {
>                         netdev_dbg(dev, "multicast remote is unsupported\n");
>                         return -EINVAL;
>                 }
> +               if (changelink &&
> +                   ip_tunnel_info_af(&geneve->info) == AF_INET6) {
> +                       info->mode &= ~IP_TUNNEL_INFO_IPV6;
> +                       info->key.tun_flags &= ~TUNNEL_CSUM;
> +                       *use_udp6_rx_checksums = false;
> +               }
This allows changelink to change ipv4 address but there are no changes
made to the geneve tunnel port hash table after this update. We also
need to check to see if there is any conflicts with existing ports.

What is the barrier between the rx/tx threads and changelink process?

>         }
>
>         if (data[IFLA_GENEVE_REMOTE6]) {
>   #if IS_ENABLED(CONFIG_IPV6)
> -               info.mode = IP_TUNNEL_INFO_IPV6;
> -               info.key.u.ipv6.dst =
> +               info->mode = IP_TUNNEL_INFO_IPV6;
> +               info->key.u.ipv6.dst =
>                         nla_get_in6_addr(data[IFLA_GENEVE_REMOTE6]);
>
> -               if (ipv6_addr_type(&info.key.u.ipv6.dst) &
> +               if (ipv6_addr_type(&info->key.u.ipv6.dst) &
>                     IPV6_ADDR_LINKLOCAL) {
>                         netdev_dbg(dev, "link-local remote is unsupported\n");
>                         return -EINVAL;
>                 }
> -               if (ipv6_addr_is_multicast(&info.key.u.ipv6.dst)) {
> +               if (ipv6_addr_is_multicast(&info->key.u.ipv6.dst)) {
>                         netdev_dbg(dev, "multicast remote is unsupported\n");
>                         return -EINVAL;
>                 }
> -               info.key.tun_flags |= TUNNEL_CSUM;
> -               use_udp6_rx_checksums = true;
> +               info->key.tun_flags |= TUNNEL_CSUM;
> +               *use_udp6_rx_checksums = true;
Same here. We need to check/fix the geneve tunnel hash table according
to new IP address.

>  #else
>                 return -EPFNOSUPPORT;
>  #endif
> @@ -1216,48 +1241,107 @@ static int geneve_newlink(struct net *net, struct net_device *dev,
...
>
> -       if (data[IFLA_GENEVE_PORT])
> -               info.key.tp_dst = nla_get_be16(data[IFLA_GENEVE_PORT]);
> +       if (data[IFLA_GENEVE_PORT]) {
> +               if (changelink)
> +                       return -EOPNOTSUPP;
> +               info->key.tp_dst = nla_get_be16(data[IFLA_GENEVE_PORT]);
> +       }
> +
> +       if (data[IFLA_GENEVE_COLLECT_METADATA]) {
> +               if (changelink)
> +                       return -EOPNOTSUPP;
Rather than blindly returning error here it should check if the
changelink is changing existing configuration.

> +               *metadata = true;
> +       }
> +
> +       if (data[IFLA_GENEVE_UDP_CSUM]) {
> +               if (changelink)
> +                       return -EOPNOTSUPP;
> +               if (nla_get_u8(data[IFLA_GENEVE_UDP_CSUM]))
> +                       info->key.tun_flags |= TUNNEL_CSUM;
> +       }
> +
same here.

> +       if (data[IFLA_GENEVE_UDP_ZERO_CSUM6_TX]) {
> +               if (changelink)
> +                       return -EOPNOTSUPP;
> +               if (nla_get_u8(data[IFLA_GENEVE_UDP_ZERO_CSUM6_TX]))
> +                       info->key.tun_flags &= ~TUNNEL_CSUM;
same here.

> +       }
>
> -       if (data[IFLA_GENEVE_COLLECT_METADATA])
> -               metadata = true;
> +       if (data[IFLA_GENEVE_UDP_ZERO_CSUM6_RX]) {
> +               if (changelink)
> +                       return -EOPNOTSUPP;
> +               if (nla_get_u8(data[IFLA_GENEVE_UDP_ZERO_CSUM6_RX]))
> +                       *use_udp6_rx_checksums = false;
> +       }
>
> -       if (data[IFLA_GENEVE_UDP_CSUM] &&
> -           nla_get_u8(data[IFLA_GENEVE_UDP_CSUM]))
> -               info.key.tun_flags |= TUNNEL_CSUM;
> +       return 0;
> +}
>
> -       if (data[IFLA_GENEVE_UDP_ZERO_CSUM6_TX] &&
> -           nla_get_u8(data[IFLA_GENEVE_UDP_ZERO_CSUM6_TX]))
> -               info.key.tun_flags &= ~TUNNEL_CSUM;
> +static int geneve_newlink(struct net *net, struct net_device *dev,
> +                         struct nlattr *tb[], struct nlattr *data[])
> +{
> +       bool use_udp6_rx_checksums = false;
> +       struct ip_tunnel_info info;
> +       bool metadata = false;
> +       int err;
>
> -       if (data[IFLA_GENEVE_UDP_ZERO_CSUM6_RX] &&
> -           nla_get_u8(data[IFLA_GENEVE_UDP_ZERO_CSUM6_RX]))
> -               use_udp6_rx_checksums = false;
> +       err = geneve_nl2info(dev, tb, data, &info, &metadata,
> +                            &use_udp6_rx_checksums, false);
> +       if (err)
> +               return err;
>
>         return geneve_configure(net, dev, &info, metadata, use_udp6_rx_checksums);
>  }
>
> +static int geneve_changelink(struct net_device *dev, struct nlattr *tb[],
> +                            struct nlattr *data[])
> +{
> +       struct geneve_dev *geneve = netdev_priv(dev);
> +       struct ip_tunnel_info info;
> +       bool metadata = false;
> +       bool use_udp6_rx_checksums = false;
> +       int err;
> +
> +       err = geneve_nl2info(dev, tb, data, &info, &metadata,
> +                            &use_udp6_rx_checksums, true);
> +       if (err)
> +               return err;
> +
> +       if (!geneve_dst_addr_equal(&geneve->info, &info))
> +               dst_cache_reset(&info.dst_cache);
> +       geneve->info = info;
This would just overwrite dst-cache, which could leak the percpu
cached dst-entry objects.

> +       geneve->collect_md = metadata;
> +       geneve->use_udp6_rx_checksums = use_udp6_rx_checksums;
> +
> +       return 0;
> +}
> +
