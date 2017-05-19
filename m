From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net] bridge: fix hello and hold timers starting/stopping
Date: Fri, 19 May 2017 19:55:36 +0300
Message-ID: <4fb3ce7a-b3d8-b62e-2263-eb3fab2ff2fe@cumulusnetworks.com>
References: <20170519162543.31670-1-cera@cera.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, sashok@cumulusnetworks.com,
        stephen@networkplumber.org, bridge@lists.linux-foundation.org,
        lucien.xin@gmail.com
To: Ivan Vecera <cera@cera.cz>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f171.google.com ([209.85.128.171]:35848 "EHLO
        mail-wr0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750943AbdESQzk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 May 2017 12:55:40 -0400
Received: by mail-wr0-f171.google.com with SMTP id l50so20436894wrc.3
        for <netdev@vger.kernel.org>; Fri, 19 May 2017 09:55:39 -0700 (PDT)
In-Reply-To: <20170519162543.31670-1-cera@cera.cz>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/19/17 7:25 PM, Ivan Vecera wrote:
> Current bridge code incorrectly handles starting/stopping of hello and
> hold timers during STP enable/disable.
> 
> 1. Timers are stopped in br_stp_start() during NO_STP->USER_STP
>     transition. This is not correct as the timers are stopped in NO_STP
>     case.

This really is a noop, but ok.

> 
> 2. Timers are started in br_stp_stop() during USER_STP->NO_STP transition.
>     This is not also correct as the timers should be stopped in NO_STP
>     state.

Indeed, but the actual end result is almost as them being stopped because
in the timers there are specific checks if the STP == KERNEL_STP (see
br_transmit_config()) and the hold_timers will simply expire and not rearm
in any other mode. The only real problem is the hello_timer which continues
to rearm itself, but with Xin's earlier patch that is taken care of too.

> 
> 3. Timers are NOT stopped in br_stp_stop() during KERNEL_STP->NO_STP
>     transition. They should be stopped as they are running in KERNEL_STP
>     state and should not run in NO_STP case.

Same comment as for point 2.

> 
> The patch is a follow-up for "bridge: start hello_timer when enabling
> KERNEL_STP in br_stp_start" patch from Xin Long.
> 

I'd say this is more of a cleanup/improvement after Xin's patch and thus would
suggest targeting net-next. The only real issue is fixed by his patch.

> Cc: davem@davemloft.net
> Cc: sashok@cumulusnetworks.com
> Cc: stephen@networkplumber.org
> Cc: bridge@lists.linux-foundation.org
> Cc: lucien.xin@gmail.com
> Cc: nikolay@cumulusnetworks.com
> Signed-off-by: Ivan Vecera <cera@cera.cz>
> ---
>   net/bridge/br_stp_if.c | 15 +++++----------
>   1 file changed, 5 insertions(+), 10 deletions(-)
> 
> diff --git a/net/bridge/br_stp_if.c b/net/bridge/br_stp_if.c
> index 0db8102995a5..f137ebf27755 100644
> --- a/net/bridge/br_stp_if.c
> +++ b/net/bridge/br_stp_if.c
> @@ -150,7 +150,6 @@ static int br_stp_call_user(struct net_bridge *br, char *arg)
>   
>   static void br_stp_start(struct net_bridge *br)
>   {
> -	struct net_bridge_port *p;
>   	int err = -ENOENT;
>   
>   	if (net_eq(dev_net(br->dev), &init_net))
> @@ -169,11 +168,6 @@ static void br_stp_start(struct net_bridge *br)
>   	if (!err) {
>   		br->stp_enabled = BR_USER_STP;
>   		br_debug(br, "userspace STP started\n");
> -
> -		/* Stop hello and hold timers */
> -		del_timer(&br->hello_timer);
> -		list_for_each_entry(p, &br->port_list, list)
> -			del_timer(&p->hold_timer);
>   	} else {
>   		br->stp_enabled = BR_KERNEL_STP;
>   		br_debug(br, "using kernel STP\n");
> @@ -197,13 +191,14 @@ static void br_stp_stop(struct net_bridge *br)
>   			br_err(br, "failed to stop userspace STP (%d)\n", err);
>   
>   		/* To start timers on any ports left in blocking */
> -		mod_timer(&br->hello_timer, jiffies + br->hello_time);
> -		list_for_each_entry(p, &br->port_list, list)
> -			mod_timer(&p->hold_timer,
> -				  round_jiffies(jiffies + BR_HOLD_TIME));
>   		spin_lock_bh(&br->lock);
>   		br_port_state_selection(br);
>   		spin_unlock_bh(&br->lock);
> +	} else {
> +		/* BR_KERNEL_STP - stop hello and hold timers */
> +		del_timer(&br->hello_timer);
> +		list_for_each_entry(p, &br->port_list, list)
> +			del_timer(&p->hold_timer);
>   	}
>   
>   	br->stp_enabled = BR_NO_STP;
> 
