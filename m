From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next v4] switchdev: fix stp update API to work with
 layered netdevices
Date: Mon, 16 Mar 2015 23:10:28 -0700
Message-ID: <CAE4R7bDSUaUvhQQ5jHFSU9bJ8fQt1O=2jzi_NjipiqQ-hRUbzQ@mail.gmail.com>
References: <1426527159-8039-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Netdev <netdev@vger.kernel.org>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f42.google.com ([209.85.192.42]:36098 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750799AbbCQGK2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 02:10:28 -0400
Received: by qgf3 with SMTP id 3so970897qgf.3
        for <netdev@vger.kernel.org>; Mon, 16 Mar 2015 23:10:28 -0700 (PDT)
In-Reply-To: <1426527159-8039-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 16, 2015 at 10:32 AM,  <roopa@cumulusnetworks.com> wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
> make it same as the netdev_switch_port_bridge_setlink/dellink
> api (ie traverse lowerdevs to get to the switch port).
>
> removes "WARN_ON(!ops->ndo_switch_parent_id_get)" because
> direct bridge ports can be stacked netdevices (like bonds
> and team of switch ports) which may not imeplement this ndo.
>
> v2 to v3:
>         - remove changes to bond and team. Bring back the
>         transparently following lowerdevs like i initially
>         had for setlink/getlink
>         (http://www.spinics.net/lists/netdev/msg313436.html)
>         dave and scott feldman also seem to prefer it be that
>         way and move to non-transparent way of doing things
>         if we see a problem down the lane.
>
> v3 to v4:
>         - fix ret initialization
>
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> ---
>  net/switchdev/switchdev.c |   20 ++++++++++++++++----
>  1 file changed, 16 insertions(+), 4 deletions(-)
>
> diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
> index c9bfa00..e593b59 100644
> --- a/net/switchdev/switchdev.c
> +++ b/net/switchdev/switchdev.c
> @@ -47,11 +47,23 @@ EXPORT_SYMBOL_GPL(netdev_switch_parent_id_get);
>  int netdev_switch_port_stp_update(struct net_device *dev, u8 state)
>  {
>         const struct swdev_ops *ops = dev->swdev_ops;
> +       struct net_device *lower_dev;
> +       struct list_head *iter;
> +       int ret = -EOPNOTSUPP, err;
>
> -       if (!ops || !ops->swdev_port_stp_update)
> -               return -EOPNOTSUPP;
> -       WARN_ON(!ops->swdev_parent_id_get);
> -       return ops->swdev_port_stp_update(dev, state);
> +       if (!(dev->features & NETIF_F_HW_SWITCH_OFFLOAD))
> +               return ret;

I would drop the NETIF_F_HW_SWITCH_OFFLOAD check.  It's not telling
you anything more than the next test for ops->swdev_port_stp_update.

> +
> +       if (ops && ops->swdev_port_stp_update)
> +               return ops->swdev_port_stp_update(dev, state);
> +
> +       netdev_for_each_lower_dev(dev, lower_dev, iter) {
> +               err = netdev_switch_port_stp_update(lower_dev, state);
> +               if (err && err != -EOPNOTSUPP)
> +                       ret = err;

Just return err here, on first failure.  Otherwise you're overwriting
previous err value; doesn't make sense.

> +       }
> +
> +       return ret;
>  }
>  EXPORT_SYMBOL_GPL(netdev_switch_port_stp_update);
>
> --
> 1.7.10.4
>
