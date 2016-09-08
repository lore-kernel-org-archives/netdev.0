From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net_namespace: fixed net_device reference leak
Date: Thu, 08 Sep 2016 16:37:41 -0700
Message-ID: <1473377861.18970.20.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CAJD3hpUgNJPOqGmAp7tEaY2+EnOasG=W6VLOMbEhDRgr8M5v8A@mail.gmail.com>
         <CAJD3hpUSqSxtgJMK__V-j8VKRwf-ftZFHw0J38VTxP9tDDZyhA@mail.gmail.com>
         <1473368413.18970.10.camel@edumazet-glaptop3.roam.corp.google.com>
         <1473368750.18970.11.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAJD3hpWs7ur8qc+E3yq_oJWs7NdbJEmRrxKFesYbap9ihSzUiw@mail.gmail.com>
         <1473373012.18970.13.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAJD3hpUMdSt6UXEFjU9OnU4K7qiET50xo8AQ194+4vpX2CfOUA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Jojy Varghese <jojy.varghese@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:33647 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755063AbcIHXhn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 19:37:43 -0400
Received: by mail-pf0-f196.google.com with SMTP id 128so3108790pfb.0
        for <netdev@vger.kernel.org>; Thu, 08 Sep 2016 16:37:43 -0700 (PDT)
In-Reply-To: <CAJD3hpUMdSt6UXEFjU9OnU4K7qiET50xo8AQ194+4vpX2CfOUA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-09-08 at 16:16 -0700, Jojy Varghese wrote:
> The dst's do disappear but the net device does not. A better solution
> is to only hold reference to dst's net device ONLY if it is not a
> loopback device. In the case of the loopback device, we want to do
> only a "put" on it and skip the "hold".
> 
> Updating the patch below:
> 
> ---
>  net/core/dst.c | 7 +++----
>  1 file changed, 3 insertions(+), 4 deletions(-)
> 
> diff --git a/net/core/dst.c b/net/core/dst.c
> index 7e45593..f63027e 100644
> --- a/net/core/dst.c
> +++ b/net/core/dst.c
> @@ -433,12 +433,11 @@ static void dst_ifdown(struct dst_entry *dst,
> struct net_device *dev,
>                 dst->input = dst_discard;
>                 dst->output = dst_discard_out;
>         } else {
> -               if (dst->dev == dev_net(dst->dev)->loopback_dev)

On which tree are you working exactly ?
Current code is not looking like that.

> -                       dst->dev = init_net.loopback_dev;
> -               else
> +               if (dst->dev != dev_net(dst->dev)->loopback_dev) {
>                         dst->dev = dev_net(dst->dev)->loopback_dev;
> +                       dev_hold(dst->dev);
> +               }
> 
> -               dev_hold(dst->dev);
>                 dev_put(dev);
>         }
>  }


I appreciate your desperate efforts, but I am telling you the bug is
elsewhere.

Do you have a reproducer of the bug, on latest David Miller tree
( https://git.kernel.org/cgit/linux/kernel/git/davem/net.git )

Thanks.
