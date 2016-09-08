From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net_namespace: fixed net_device reference leak
Date: Thu, 08 Sep 2016 14:00:13 -0700
Message-ID: <1473368413.18970.10.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CAJD3hpUgNJPOqGmAp7tEaY2+EnOasG=W6VLOMbEhDRgr8M5v8A@mail.gmail.com>
         <CAJD3hpUSqSxtgJMK__V-j8VKRwf-ftZFHw0J38VTxP9tDDZyhA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Jojy Varghese <jojy.varghese@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:34781 "EHLO
        mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750750AbcIHVAP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 17:00:15 -0400
Received: by mail-pa0-f68.google.com with SMTP id gi6so2837333pac.1
        for <netdev@vger.kernel.org>; Thu, 08 Sep 2016 14:00:15 -0700 (PDT)
In-Reply-To: <CAJD3hpUSqSxtgJMK__V-j8VKRwf-ftZFHw0J38VTxP9tDDZyhA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-09-08 at 12:08 -0700, Jojy Varghese wrote:
> (Updating the patch for the case when a non-loopback dev could be unregistered)
> 
> Currently during namespace cleanup, if ‘dst’ subsystem is holding
> a reference to the interface in the namespace, it does not get released.
> Current code first does a ’dev_hold’ on the same device followed by a
> ‘dev_put’ on the same device resulting in a no-op.
> 
> This change fixes this leak by assigning the initial namespace’s loopback
> device to the ‘dst’ before releasing the reference to the network
> device being released.
> 
> Additional reference: https://github.com/docker/docker/issues/5618
> 
> Signed-off-by: Jojy G Varghese <jojy.varghese@gmail.com>
> ---
>  net/core/dst.c | 6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
> 
> diff --git a/net/core/dst.c b/net/core/dst.c
> index a1656e3..7e45593 100644
> --- a/net/core/dst.c
> +++ b/net/core/dst.c
> @@ -433,7 +433,11 @@ static void dst_ifdown(struct dst_entry *dst,
> struct net_device *dev,
>                 dst->input = dst_discard;
>                 dst->output = dst_discard_out;
>         } else {
> -               dst->dev = dev_net(dst->dev)->loopback_dev;
> +               if (dst->dev == dev_net(dst->dev)->loopback_dev)
> +                       dst->dev = init_net.loopback_dev;
> +               else
> +                       dst->dev = dev_net(dst->dev)->loopback_dev;
> +
>                 dev_hold(dst->dev);
>                 dev_put(dev);
>         }

I understand these recurring problems are really a hassle
(unregister_netdevice: waiting for xxx to become free. Usage count = 1),
but this change simply hides the real bug ?

Pretending this dst now belongs to init_net is a bit like avoiding a
kfree(mem) : Better not free memory than risk use-after-free.

Now, try this one billion time, and I am sure host will have no memory
left.

At net namespace dismantle, all dst should be freed.
We have numerous callbacks to ensure this.
But maybe we have _one_ dst that is not properly purged.

Latest real fix was :
https://git.kernel.org/cgit/linux/kernel/git/davem/net.git/commit/?id=751eb6b6042a596b0080967c1a529a9fe98dac1d
