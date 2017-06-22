From: Andrey Konovalov <andreyknvl@google.com>
Subject: Re: [Patch net] ipv6: avoid unregistering inet6_dev for loopback
Date: Thu, 22 Jun 2017 12:10:03 +0200
Message-ID: <CAAeHK+xURU9Dkt0bSkrLwJ8-W3P5s+7pKYB-qSAh7m70sdRBvQ@mail.gmail.com>
References: <1498080898-17338-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev <netdev@vger.kernel.org>,
        Daniel Lezcano <dlezcano@fr.ibm.com>,
        David Ahern <dsahern@gmail.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yb0-f179.google.com ([209.85.213.179]:34006 "EHLO
        mail-yb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752563AbdFVKKF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2017 06:10:05 -0400
Received: by mail-yb0-f179.google.com with SMTP id e201so3206733ybb.1
        for <netdev@vger.kernel.org>; Thu, 22 Jun 2017 03:10:05 -0700 (PDT)
In-Reply-To: <1498080898-17338-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 21, 2017 at 11:34 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> The per netns loopback_dev->ip6_ptr is unregistered and set to
> NULL when its mtu is set to smaller than IPV6_MIN_MTU, this
> leads to that we could set rt->rt6i_idev NULL after a
> rt6_uncached_list_flush_dev() and then crash after another
> call.
>
> In this case we should just bring its inet6_dev down, rather
> than unregistering it, at least prior to commit 176c39af29bc
> ("netns: fix addrconf_ifdown kernel panic") we always
> override the case for loopback.
>
> Thanks a lot to Andrey for finding a reliable reproducer.

Thanks! This fixes the bug for me.

Tested-by: Andrey Konovalov <andreyknvl@google.com>

>
> Fixes: 176c39af29bc ("netns: fix addrconf_ifdown kernel panic")
> Reported-by: Andrey Konovalov <andreyknvl@google.com>
> Cc: Andrey Konovalov <andreyknvl@google.com>
> Cc: Daniel Lezcano <dlezcano@fr.ibm.com>
> Cc: David Ahern <dsahern@gmail.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---
>  net/ipv6/addrconf.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
>
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 686c923..1d2dbac 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -3369,6 +3369,7 @@ static int addrconf_notify(struct notifier_block *this, unsigned long event,
>         struct net_device *dev = netdev_notifier_info_to_dev(ptr);
>         struct netdev_notifier_changeupper_info *info;
>         struct inet6_dev *idev = __in6_dev_get(dev);
> +       struct net *net = dev_net(dev);
>         int run_pending = 0;
>         int err;
>
> @@ -3384,7 +3385,7 @@ static int addrconf_notify(struct notifier_block *this, unsigned long event,
>         case NETDEV_CHANGEMTU:
>                 /* if MTU under IPV6_MIN_MTU stop IPv6 on this interface. */
>                 if (dev->mtu < IPV6_MIN_MTU) {
> -                       addrconf_ifdown(dev, 1);
> +                       addrconf_ifdown(dev, dev != net->loopback_dev);
>                         break;
>                 }
>
> @@ -3500,7 +3501,7 @@ static int addrconf_notify(struct notifier_block *this, unsigned long event,
>                          * IPV6_MIN_MTU stop IPv6 on this interface.
>                          */
>                         if (dev->mtu < IPV6_MIN_MTU)
> -                               addrconf_ifdown(dev, 1);
> +                               addrconf_ifdown(dev, dev != net->loopback_dev);
>                 }
>                 break;
>
> --
> 2.5.5
>
