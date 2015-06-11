From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next 1/3 v3] net: track link-status of ipv4 nexthops
Date: Wed, 10 Jun 2015 19:53:59 -0700
Message-ID: <CAE4R7bC=bKhMDVc9JT7YeFFDAi8Hn8GySd_b5Oa2uQ=bnbi8_A@mail.gmail.com>
References: <1433990233-958-1-git-send-email-gospo@cumulusnetworks.com> <1433990233-958-2-git-send-email-gospo@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, ddutt@cumulusnetworks.com,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
To: Andy Gospodarek <gospo@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f180.google.com ([209.85.216.180]:36155 "EHLO
	mail-qc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751684AbbFKCyU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2015 22:54:20 -0400
Received: by qcjl8 with SMTP id l8so4627336qcj.3
        for <netdev@vger.kernel.org>; Wed, 10 Jun 2015 19:54:19 -0700 (PDT)
In-Reply-To: <1433990233-958-2-git-send-email-gospo@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 10, 2015 at 7:37 PM, Andy Gospodarek
<gospo@cumulusnetworks.com> wrote:

> @@ -1129,7 +1142,15 @@ int fib_sync_down_dev(struct net_device *dev, int force)
>                                 dead++;
>                         else if (nexthop_nh->nh_dev == dev &&
>                                  nexthop_nh->nh_scope != scope) {
> -                               nexthop_nh->nh_flags |= RTNH_F_DEAD;
> +                               switch (event) {
> +                               case NETDEV_DOWN:
> +                               case NETDEV_UNREGISTER:
> +                                       nexthop_nh->nh_flags |= RTNH_F_DEAD;
> +                                       /* fall through */
> +                               case NETDEV_CHANGE:
> +                                       nexthop_nh->nh_flags |= RTNH_F_LINKDOWN;
> +                                       break;
> +                               }
>  #ifdef CONFIG_IP_ROUTE_MULTIPATH
>                                 spin_lock_bh(&fib_multipath_lock);
>                                 fi->fib_power -= nexthop_nh->nh_power;
> @@ -1139,14 +1160,22 @@ int fib_sync_down_dev(struct net_device *dev, int force)
>                                 dead++;
>                         }
>  #ifdef CONFIG_IP_ROUTE_MULTIPATH
> -                       if (force > 1 && nexthop_nh->nh_dev == dev) {
> +                       if (event == NETDEV_UNREGISTER && nexthop_nh->nh_dev == dev) {
>                                 dead = fi->fib_nhs;
>                                 break;
>                         }
>  #endif
>                 } endfor_nexthops(fi)
>                 if (dead == fi->fib_nhs) {
> -                       fi->fib_flags |= RTNH_F_DEAD;
> +                       switch (event) {
> +                       case NETDEV_DOWN:
> +                       case NETDEV_UNREGISTER:
> +                               fi->fib_flags |= RTNH_F_DEAD;
> +                               /* fall through */
> +                       case NETDEV_CHANGE:
> +                               fi->fib_flags |= RTNH_F_LINKDOWN;

RTNH_F_LINKDOWN is to mark linkdown nexthop devs....why is the route
fi being marked RTNH_F_LINKDOWN?

The RTNH_F_LINKDOWN comment says:

#define RTNH_F_LINKDOWN                16      /* carrier-down on nexthop */

It's a per-nh flag, not per-route flag, correct?

Can you show an ECMP example with only a subset of the nexthops dev
linkdowned?  Show the ip route output after going thru some link
down/up events on some of the nexthops devs.
