From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net_namespace: fixed net_device reference leak
Date: Thu, 08 Sep 2016 16:51:25 -0700
Message-ID: <1473378685.18970.22.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CAJD3hpUgNJPOqGmAp7tEaY2+EnOasG=W6VLOMbEhDRgr8M5v8A@mail.gmail.com>
         <CAJD3hpUSqSxtgJMK__V-j8VKRwf-ftZFHw0J38VTxP9tDDZyhA@mail.gmail.com>
         <1473368413.18970.10.camel@edumazet-glaptop3.roam.corp.google.com>
         <1473368750.18970.11.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAJD3hpWs7ur8qc+E3yq_oJWs7NdbJEmRrxKFesYbap9ihSzUiw@mail.gmail.com>
         <1473373012.18970.13.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAJD3hpUMdSt6UXEFjU9OnU4K7qiET50xo8AQ194+4vpX2CfOUA@mail.gmail.com>
         <CAJD3hpUDTZiJQ4YMiCizcYBKw=GD6jZoww3GxYjmajSdn6CE=g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Jojy Varghese <jojy.varghese@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:36630 "EHLO
        mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750714AbcIHXv1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 19:51:27 -0400
Received: by mail-pa0-f66.google.com with SMTP id ez1so2976645pab.3
        for <netdev@vger.kernel.org>; Thu, 08 Sep 2016 16:51:27 -0700 (PDT)
In-Reply-To: <CAJD3hpUDTZiJQ4YMiCizcYBKw=GD6jZoww3GxYjmajSdn6CE=g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-09-08 at 16:33 -0700, Jojy Varghese wrote:
> Sorry last patch was just the delta over my original patch. Here is
> the complete patch:
> 
> ---
>  net/core/dst.c | 7 +++++--
>  1 file changed, 5 insertions(+), 2 deletions(-)
> 
> diff --git a/net/core/dst.c b/net/core/dst.c
> index a1656e3..f63027e 100644
> --- a/net/core/dst.c
> +++ b/net/core/dst.c
> @@ -433,8 +433,11 @@ static void dst_ifdown(struct dst_entry *dst,
> struct net_device *dev,
>                 dst->input = dst_discard;
>                 dst->output = dst_discard_out;
>         } else {
> -               dst->dev = dev_net(dst->dev)->loopback_dev;
> -               dev_hold(dst->dev);
> +               if (dst->dev != dev_net(dst->dev)->loopback_dev) {
> +                       dst->dev = dev_net(dst->dev)->loopback_dev;
> +                       dev_hold(dst->dev);
> +               }
> +
>                 dev_put(dev);
>         }
>  }

This is complete garbage, now we have a dst somewhere in the system,
pointing to a device that might have been freed.

Crash might happen when dst->dev is used later.
