From: Joe Stringer <joe@ovn.org>
Subject: Re: [PATCH net-next v1 2/3] gtp: Support creating flow-based gtp net_device
Date: Thu, 13 Jul 2017 11:01:01 -0700
Message-ID: <CAPWQB7E-cbYXc9PCZhfi0TuFwi1-1tkKKJcZwEeGGeb6Kc-qVQ@mail.gmail.com>
References: <20170713004455.3946570-1-ouyangj@fb.com> <20170713004455.3946570-3-ouyangj@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: osmocom-net-gprs@lists.osmocom.org,
        netdev <netdev@vger.kernel.org>, ovs dev <dev@openvswitch.org>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Harald Welte <laforge@gnumonks.org>,
        Pravin B Shelar <pshelar@nicira.com>,
        Wieger IJntema <wieger.ijntema.tno@gmail.com>,
        "Yang, Yi Y" <yi.y.yang@intel.com>,
        Amar Padmanabhan <amarpadmanabhan@fb.com>
To: Jiannan Ouyang <ouyangj@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay5-d.mail.gandi.net ([217.70.183.197]:60880 "EHLO
        relay5-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751267AbdGMSB0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Jul 2017 14:01:26 -0400
Received: from mfilter27-d.gandi.net (mfilter27-d.gandi.net [217.70.178.155])
        by relay5-d.mail.gandi.net (Postfix) with ESMTP id 7E5AD41C086
        for <netdev@vger.kernel.org>; Thu, 13 Jul 2017 20:01:25 +0200 (CEST)
Received: from relay5-d.mail.gandi.net ([IPv6:::ffff:217.70.183.197])
        by mfilter27-d.gandi.net (mfilter27-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id poxyUBuyLKIT for <netdev@vger.kernel.org>;
        Thu, 13 Jul 2017 20:01:24 +0200 (CEST)
Received: from mail-oi0-f54.google.com (mail-oi0-f54.google.com [209.85.218.54])
        (Authenticated sender: joe@ovn.org)
        by relay5-d.mail.gandi.net (Postfix) with ESMTPSA id 120DA41C088
        for <netdev@vger.kernel.org>; Thu, 13 Jul 2017 20:01:23 +0200 (CEST)
Received: by mail-oi0-f54.google.com with SMTP id 191so52686289oii.2
        for <netdev@vger.kernel.org>; Thu, 13 Jul 2017 11:01:23 -0700 (PDT)
In-Reply-To: <20170713004455.3946570-3-ouyangj@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12 July 2017 at 17:44, Jiannan Ouyang <ouyangj@fb.com> wrote:
> Add the gtp_create_flow_based_dev() interface to create flow-based gtp
> net_device, which sets gtp->collect_md. Under flow-based mode, UDP sockets are
> created and maintained in kernel.
>
> Signed-off-by: Jiannan Ouyang <ouyangj@fb.com>
> ---

<snip>

> +static int gtp_configure(struct net *net, struct net_device *dev,
> +                        const struct ip_tunnel_info *info)
> +{
> +       struct gtp_net *gn = net_generic(net, gtp_net_id);
> +       struct gtp_dev *gtp = netdev_priv(dev);
> +       int err;
> +
> +       gtp->net = net;
> +       gtp->dev = dev;
> +
> +       if (gtp_find_flow_based_dev(net))
> +               return -EBUSY;
> +
> +       dev->netdev_ops         = &gtp_netdev_ops;
> +       dev->priv_destructor    = free_netdev;
> +
> +       dev->hard_header_len = 0;
> +       dev->addr_len = 0;
> +
> +       /* Zero header length. */
> +       dev->type = ARPHRD_NONE;
> +       dev->flags = IFF_POINTOPOINT | IFF_NOARP | IFF_MULTICAST;
> +
> +       dev->priv_flags |= IFF_NO_QUEUE;
> +       dev->features   |= NETIF_F_LLTX;
> +       netif_keep_dst(dev);
> +
> +       /* Assume largest header, ie. GTPv0. */
> +       dev->needed_headroom    = LL_MAX_HEADER +
> +               sizeof(struct iphdr) +
> +               sizeof(struct udphdr) +
> +               sizeof(struct gtp0_header);
> +
> +       dst_cache_reset(&gtp->info.dst_cache);
> +       gtp->info = *info;
> +       gtp->collect_md = true;
> +
> +       err = gtp_hashtable_new(gtp, GTP_PDP_HASHSIZE); // JO: when to free??
> +       if (err < 0) {
> +               pr_err("Error gtp_hashtable_new");
> +               return err;
> +       }

Firstly, if this succeeds then the subsequent register_netdevice()
call below could still fail, in which case the error handling there
free this hashtable. Don't forget that even if this whole function
succeeds, the caller may still fail to set up the device and in those
error cases everything needs to be freed/cleaned up as well.

Then in terms of the overall lifecycle, I guess it's a matter of 1) If
there is a hashtable allocated then it must be freed on device close;
2) If the device can be reconfigured, and there is already one of
these allocated then it would need to be freed upon reconfiguration.

Cheers,
Joe
