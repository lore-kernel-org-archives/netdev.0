From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net] rocker: handle non-bridge master change
Date: Mon, 23 Mar 2015 11:43:51 -0700
Message-ID: <CAE4R7bALENahPfnbB0nm-gU-syXYHLx92iqrR09seP1kYbR+sg@mail.gmail.com>
References: <1427091201-7872-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Pirko <jiri@resnulli.us>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f44.google.com ([209.85.192.44]:35010 "EHLO
	mail-qg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752214AbbCWSoN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 14:44:13 -0400
Received: by qgf74 with SMTP id 74so33114007qgf.2
        for <netdev@vger.kernel.org>; Mon, 23 Mar 2015 11:44:12 -0700 (PDT)
In-Reply-To: <1427091201-7872-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 22, 2015 at 11:13 PM, Simon Horman
<simon.horman@netronome.com> wrote:
> Master change notifications may occur other than when joining or
> leaving a bridge, for example when being added to or removed from
> a bond or Open vSwitch.
>
> Previously in those cases rocker_port_bridge_leave() was called
> which results in a null-pointer dereference as rocker_port->bridge_dev
> is NULL because there is no bridge device.
>
> This patch makes provision for doing nothing in such cases.
>
> Fixes: 6c7079450071f ("rocker: implement L2 bridge offloading")
> Signed-off-by: Simon Horman <simon.horman@netronome.com>
> ---
>  drivers/net/ethernet/rocker/rocker.c | 8 +++++++-
>  1 file changed, 7 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
> index 9fb6948..0390714 100644
> --- a/drivers/net/ethernet/rocker/rocker.c
> +++ b/drivers/net/ethernet/rocker/rocker.c
> @@ -4468,10 +4468,16 @@ static int rocker_port_master_changed(struct net_device *dev)
>         struct net_device *master = netdev_master_upper_dev_get(dev);
>         int err = 0;
>
> +       /* There are currently three cases handled here:
> +        * 1. Joining a bridge
> +        * 2. Leaving a previously joined bridge
> +        * 3. Other, e.g. being added to or removed from a bond or openvswitch,
> +        *    in which case nothing is done
> +        */
>         if (master && master->rtnl_link_ops &&
>             !strcmp(master->rtnl_link_ops->kind, "bridge"))
>                 err = rocker_port_bridge_join(rocker_port, master);
> -       else
> +       else if (rocker_port->bridge_dev)
>                 err = rocker_port_bridge_leave(rocker_port);

Please send v2 that uses rocker_port_is_bridged(), otherwise looks
good, thanks Simon.
