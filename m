From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [PATCH net-next v2 1/1] geneve: add rtnl changelink support
Date: Wed, 19 Jul 2017 20:18:27 -0700
Message-ID: <CAOrHB_CNNzUgNN3GPmAtnceUW-orGGMPnUSS86nRSMtVPN4HHw@mail.gmail.com>
References: <1500420786-11993-1-git-send-email-girish.moodalbail@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Girish Moodalbail <girish.moodalbail@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2-d.mail.gandi.net ([217.70.183.194]:54072 "EHLO
        relay2-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932823AbdGTDS3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Jul 2017 23:18:29 -0400
Received: from mail-wr0-f177.google.com (mail-wr0-f177.google.com [209.85.128.177])
        (Authenticated sender: pshelar@ovn.org)
        by relay2-d.mail.gandi.net (Postfix) with ESMTPSA id A0750C5A46
        for <netdev@vger.kernel.org>; Thu, 20 Jul 2017 05:18:28 +0200 (CEST)
Received: by mail-wr0-f177.google.com with SMTP id 33so8792091wrz.4
        for <netdev@vger.kernel.org>; Wed, 19 Jul 2017 20:18:28 -0700 (PDT)
In-Reply-To: <1500420786-11993-1-git-send-email-girish.moodalbail@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 18, 2017 at 4:33 PM, Girish Moodalbail
<girish.moodalbail@oracle.com> wrote:
> This patch adds changelink rtnl operation support for geneve devices
> and the code changes involve:
>
>   - add geneve_quiesce() which quiesces the geneve device data path
>     for both TX and RX. This lets us perform the changelink operation
>     atomically w.r.t data path. Also add geneve_unquiesce() to
>     reverse the operation of geneve_quiesce().
>
>   - refactor geneve_newlink into geneve_nl2info to be used by both
>     geneve_newlink and geneve_changelink
>
>   - geneve_nl2info takes a changelink boolean argument to isolate
>     changelink checks.
>
>   - Allow changing only a few attributes (ttl, tos, and remote tunnel
>     endpoint IP address (within the same address family)):
>     - return -EOPNOTSUPP for attributes that cannot be changed for
>       now. Incremental patches can make the non-supported one
>       available in the future if needed.
>

> Signed-off-by: Girish Moodalbail <girish.moodalbail@oracle.com>
> ---
> v0 -> v1:
>    - added geneve_quiesce() and geneve_unquiesce() functions to
>      perform the changelink operation atomically w.r.t data path
> ---

>  drivers/net/geneve.c | 192 +++++++++++++++++++++++++++++++++++++++++----------
>  1 file changed, 157 insertions(+), 35 deletions(-)
>
> diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
> index de8156c..829f541 100644
> --- a/drivers/net/geneve.c
> +++ b/drivers/net/geneve.c
...
...

> +/* Quiesces the geneve device data path for both TX and RX. */
> +static inline void geneve_quiesce(struct geneve_dev *geneve,
> +                                 struct geneve_sock **gs4,
> +                                 struct geneve_sock **gs6)
> +{
> +       *gs4 = rtnl_dereference(geneve->sock4);
> +       rcu_assign_pointer(geneve->sock4, NULL);
> +
> +#if IS_ENABLED(CONFIG_IPV6)
> +       *gs6 = rtnl_dereference(geneve->sock6);
> +       rcu_assign_pointer(geneve->sock6, NULL);
> +#else
> +       *gs6 = NULL;
> +#endif
> +       synchronize_net();
> +}
> +
> +/* Resumes the geneve device data path for both TX and RX. */
> +static inline void geneve_unquiesce(struct geneve_dev *geneve,
> +                                   struct geneve_sock *gs4,
> +                                   struct geneve_sock __maybe_unused *gs6)
> +{
> +       rcu_assign_pointer(geneve->sock4, gs4);
> +#if IS_ENABLED(CONFIG_IPV6)
> +       rcu_assign_pointer(geneve->sock6, gs6);
> +#endif
> +       synchronize_net();
> +}
> +
> +static int geneve_changelink(struct net_device *dev, struct nlattr *tb[],
> +                            struct nlattr *data[],
> +                            struct netlink_ext_ack *extack)
> +{
> +       struct geneve_dev *geneve = netdev_priv(dev);
> +       struct geneve_sock *gs4, *gs6;
> +       struct ip_tunnel_info info;
> +       bool metadata;
> +       bool use_udp6_rx_checksums;
> +       int err;
> +
> +       /* If the geneve device is configured for metadata (or externally
> +        * controlled, for example, OVS), then nothing can be changed.
> +        */
> +       if (geneve->collect_md)
> +               return -EOPNOTSUPP;
> +
> +       /* Start with the existing info. */
> +       memcpy(&info, &geneve->info, sizeof(info));
> +       metadata = geneve->collect_md;
> +       use_udp6_rx_checksums = geneve->use_udp6_rx_checksums;
> +       err = geneve_nl2info(dev, tb, data, &info, &metadata,
> +                            &use_udp6_rx_checksums, true);
> +       if (err)
> +               return err;
> +
> +       if (!geneve_dst_addr_equal(&geneve->info, &info))
> +               dst_cache_reset(&info.dst_cache);
> +
> +       geneve_quiesce(geneve, &gs4, &gs6);
> +       geneve->info = info;
> +       geneve->collect_md = metadata;
> +       geneve->use_udp6_rx_checksums = use_udp6_rx_checksums;
> +       geneve_unquiesce(geneve, gs4, gs6);
> +
This is nice trick. But it adds check for the socket in datapath. did
you explore updating entire device state in single atomic transaction?


> +       return 0;
> +}
> +
>  static void geneve_dellink(struct net_device *dev, struct list_head *head)
>  {
>         struct geneve_dev *geneve = netdev_priv(dev);
> @@ -1375,6 +1496,7 @@ static int geneve_fill_info(struct sk_buff *skb, const struct net_device *dev)
>         .setup          = geneve_setup,
>         .validate       = geneve_validate,
>         .newlink        = geneve_newlink,
> +       .changelink     = geneve_changelink,
>         .dellink        = geneve_dellink,
>         .get_size       = geneve_get_size,
>         .fill_info      = geneve_fill_info,
> --
> 1.8.3.1
>
