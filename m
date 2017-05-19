From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH net] bridge: fix hello and hold timers starting/stopping
Date: Sat, 20 May 2017 00:51:42 +0800
Message-ID: <CADvbK_eRRy5bXb1RN6p-DTp9cKp6MvCZGH8oL=gfhTrJ0URFqQ@mail.gmail.com>
References: <20170519162543.31670-1-cera@cera.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: network dev <netdev@vger.kernel.org>, davem <davem@davemloft.net>,
        sashok@cumulusnetworks.com,
        Stephen Hemminger <stephen@networkplumber.org>,
        bridge@lists.linux-foundation.org,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: Ivan Vecera <cera@cera.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:35794 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751105AbdESQvo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 May 2017 12:51:44 -0400
Received: by mail-qk0-f194.google.com with SMTP id k74so10912751qke.2
        for <netdev@vger.kernel.org>; Fri, 19 May 2017 09:51:43 -0700 (PDT)
In-Reply-To: <20170519162543.31670-1-cera@cera.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 20, 2017 at 12:25 AM, Ivan Vecera <cera@cera.cz> wrote:
> Current bridge code incorrectly handles starting/stopping of hello and
> hold timers during STP enable/disable.
>
> 1. Timers are stopped in br_stp_start() during NO_STP->USER_STP
>    transition. This is not correct as the timers are stopped in NO_STP
>    case.
>
> 2. Timers are started in br_stp_stop() during USER_STP->NO_STP transition.
>    This is not also correct as the timers should be stopped in NO_STP
>    state.
>
> 3. Timers are NOT stopped in br_stp_stop() during KERNEL_STP->NO_STP
>    transition. They should be stopped as they are running in KERNEL_STP
>    state and should not run in NO_STP case.
>
> The patch is a follow-up for "bridge: start hello_timer when enabling
> KERNEL_STP in br_stp_start" patch from Xin Long.
>
> Cc: davem@davemloft.net
> Cc: sashok@cumulusnetworks.com
> Cc: stephen@networkplumber.org
> Cc: bridge@lists.linux-foundation.org
> Cc: lucien.xin@gmail.com
> Cc: nikolay@cumulusnetworks.com
> Signed-off-by: Ivan Vecera <cera@cera.cz>
> ---
>  net/bridge/br_stp_if.c | 15 +++++----------
>  1 file changed, 5 insertions(+), 10 deletions(-)
>
> diff --git a/net/bridge/br_stp_if.c b/net/bridge/br_stp_if.c
> index 0db8102995a5..f137ebf27755 100644
> --- a/net/bridge/br_stp_if.c
> +++ b/net/bridge/br_stp_if.c
> @@ -150,7 +150,6 @@ static int br_stp_call_user(struct net_bridge *br, char *arg)
>
>  static void br_stp_start(struct net_bridge *br)
>  {
> -       struct net_bridge_port *p;
>         int err = -ENOENT;
>
>         if (net_eq(dev_net(br->dev), &init_net))
> @@ -169,11 +168,6 @@ static void br_stp_start(struct net_bridge *br)
>         if (!err) {
>                 br->stp_enabled = BR_USER_STP;
>                 br_debug(br, "userspace STP started\n");
> -
> -               /* Stop hello and hold timers */
> -               del_timer(&br->hello_timer);
> -               list_for_each_entry(p, &br->port_list, list)
> -                       del_timer(&p->hold_timer);
>         } else {
>                 br->stp_enabled = BR_KERNEL_STP;
>                 br_debug(br, "using kernel STP\n");
> @@ -197,13 +191,14 @@ static void br_stp_stop(struct net_bridge *br)
>                         br_err(br, "failed to stop userspace STP (%d)\n", err);
>
>                 /* To start timers on any ports left in blocking */
> -               mod_timer(&br->hello_timer, jiffies + br->hello_time);
> -               list_for_each_entry(p, &br->port_list, list)
> -                       mod_timer(&p->hold_timer,
> -                                 round_jiffies(jiffies + BR_HOLD_TIME));
>                 spin_lock_bh(&br->lock);
>                 br_port_state_selection(br);
>                 spin_unlock_bh(&br->lock);
> +       } else {
> +               /* BR_KERNEL_STP - stop hello and hold timers */
> +               del_timer(&br->hello_timer);
> +               list_for_each_entry(p, &br->port_list, list)
> +                       del_timer(&p->hold_timer);
I'm thinking, what if the timers are running when deleting them ?
del_timer may not be going to delete it, and still have to stop itself
next time when br->stp_enabled = BR_NO_STP.

So do you think it's better to do nothing here and just leave it to be
stopped by itself when checking br->stp_enabled  in
br_hello_timer_expired ?

>         }
>
>         br->stp_enabled = BR_NO_STP;
> --
> 2.13.0
>
