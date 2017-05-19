From: Ivan Vecera <cera@cera.cz>
Subject: Re: [PATCH net] bridge: start hello_timer when enabling KERNEL_STP in br_stp_start
Date: Fri, 19 May 2017 18:29:21 +0200
Message-ID: <CA+Nub0Z04YiWgsf1ao=iGbTvvgLpfo-NHskggCNCk3KW9YYPBQ@mail.gmail.com>
References: <6e78bfea3969ca1a937b37e28e796a3047b82615.1495203629.git.lucien.xin@gmail.com>
Reply-To: ivan.vecera@cera.cz
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: network dev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:34514 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751003AbdESQ3W (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 May 2017 12:29:22 -0400
Received: by mail-oi0-f67.google.com with SMTP id w10so13188593oif.1
        for <netdev@vger.kernel.org>; Fri, 19 May 2017 09:29:22 -0700 (PDT)
In-Reply-To: <6e78bfea3969ca1a937b37e28e796a3047b82615.1495203629.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2017-05-19 16:20 GMT+02:00 Xin Long <lucien.xin@gmail.com>:
> Since commit 76b91c32dd86 ("bridge: stp: when using userspace stp stop
> kernel hello and hold timers"), bridge would not start hello_timer if
> stp_enabled is not KERNEL_STP when br_dev_open.
>
> The problem is even if users set stp_enabled with KERNEL_STP later,
> the timer will still not be started. It causes that KERNEL_STP can
> not really work. Users have to re-ifup the bridge to avoid this.
>
> This patch is to fix it by starting br->hello_timer when enabling
> KERNEL_STP in br_stp_start.
>
> As an improvement, it's also to start hello_timer again only when
> br->stp_enabled is KERNEL_STP in br_hello_timer_expired, there is
> no reason to start the timer again when it's NO_STP.
>
> Fixes: 76b91c32dd86 ("bridge: stp: when using userspace stp stop kernel hello and hold timers")
> Reported-by: Haidong Li <haili@redhat.com>
> Signed-off-by: Xin Long <lucien.xin@gmail.com>
> ---
>  net/bridge/br_stp_if.c    | 1 +
>  net/bridge/br_stp_timer.c | 2 +-
>  2 files changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/net/bridge/br_stp_if.c b/net/bridge/br_stp_if.c
> index 08341d2..0db8102 100644
> --- a/net/bridge/br_stp_if.c
> +++ b/net/bridge/br_stp_if.c
> @@ -179,6 +179,7 @@ static void br_stp_start(struct net_bridge *br)
>                 br_debug(br, "using kernel STP\n");
>
>                 /* To start timers on any ports left in blocking */
> +               mod_timer(&br->hello_timer, jiffies + br->hello_time);
>                 br_port_state_selection(br);
>         }
>
> diff --git a/net/bridge/br_stp_timer.c b/net/bridge/br_stp_timer.c
> index c98b3e5..60b6fe2 100644
> --- a/net/bridge/br_stp_timer.c
> +++ b/net/bridge/br_stp_timer.c
> @@ -40,7 +40,7 @@ static void br_hello_timer_expired(unsigned long arg)
>         if (br->dev->flags & IFF_UP) {
>                 br_config_bpdu_generation(br);
>
> -               if (br->stp_enabled != BR_USER_STP)
> +               if (br->stp_enabled == BR_KERNEL_STP)
>                         mod_timer(&br->hello_timer,
>                                   round_jiffies(jiffies + br->hello_time));
>         }
> --
> 2.1.0
>
Reviewed-by: Ivan Vecera <cera@cera.cz>
