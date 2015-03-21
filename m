From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next v5] switchdev: fix stp update API to work with
 layered netdevices
Date: Fri, 20 Mar 2015 22:35:09 -0700
Message-ID: <CAE4R7bBWvMY9=bZj4tV35NDJxh8bR3Vafknm5c7S0KvcDUV4NA@mail.gmail.com>
References: <1426915232-17544-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Netdev <netdev@vger.kernel.org>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f44.google.com ([209.85.192.44]:34356 "EHLO
	mail-qg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751809AbbCUFfJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2015 01:35:09 -0400
Received: by qgh62 with SMTP id 62so110240917qgh.1
        for <netdev@vger.kernel.org>; Fri, 20 Mar 2015 22:35:09 -0700 (PDT)
In-Reply-To: <1426915232-17544-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 20, 2015 at 10:20 PM,  <roopa@cumulusnetworks.com> wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
> make it same as the netdev_switch_port_bridge_setlink/dellink
> api (ie traverse lowerdevs to get to the switch port).
>
> removes "WARN_ON(!ops->ndo_switch_parent_id_get)" because
> direct bridge ports can be stacked netdevices (like bonds
> and team of switch ports) which may not implement this ndo.
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
> v4 to v5:
>         - return err on first failure (scott feldman)
>
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> ---
>  net/switchdev/switchdev.c |   17 +++++++++++++----
>  1 file changed, 13 insertions(+), 4 deletions(-)
>
> diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
> index c9bfa00..7d7b487 100644
> --- a/net/switchdev/switchdev.c
> +++ b/net/switchdev/switchdev.c
> @@ -47,11 +47,20 @@ EXPORT_SYMBOL_GPL(netdev_switch_parent_id_get);
>  int netdev_switch_port_stp_update(struct net_device *dev, u8 state)
>  {
>         const struct swdev_ops *ops = dev->swdev_ops;
> +       struct net_device *lower_dev;
> +       struct list_head *iter;
> +       int ret;

Use "err" rather than "ret"....to be consistent with rest of switchdev code.

>
> -       if (!ops || !ops->swdev_port_stp_update)
> -               return -EOPNOTSUPP;
> -       WARN_ON(!ops->swdev_parent_id_get);
> -       return ops->swdev_port_stp_update(dev, state);
> +       if (ops && ops->swdev_port_stp_update)
> +               return ops->swdev_port_stp_update(dev, state);
> +
> +       netdev_for_each_lower_dev(dev, lower_dev, iter) {
> +               ret = netdev_switch_port_stp_update(lower_dev, state);
> +               if (ret && ret != -EOPNOTSUPP)
> +                       return ret;
> +       }
> +
> +       return 0;

Return err and initialize err to -EOPNOTSUPP.

The way you have it, you're claiming success for the case where there
is no op and no lower devs...be consistent with same func when
CONFIG_NET_SWITCHDEV is not defined.

Sorry for being pedantic, but why not be consistent with the surrounding code?

-scott
