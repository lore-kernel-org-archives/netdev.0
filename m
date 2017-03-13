From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/1] r8152: fix NULL pointer dereference in r8152_poll
Date: Mon, 13 Mar 2017 06:18:04 -0700
Message-ID: <1489411084.28631.78.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170313124727.4681-1-petr.vorel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hayeswang@realtek.com, davem@davemloft.net
To: Petr Vorel <petr.vorel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:33607 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750929AbdCMNSG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 09:18:06 -0400
Received: by mail-pg0-f67.google.com with SMTP id 77so17991032pgc.0
        for <netdev@vger.kernel.org>; Mon, 13 Mar 2017 06:18:05 -0700 (PDT)
In-Reply-To: <20170313124727.4681-1-petr.vorel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-03-13 at 13:47 +0100, Petr Vorel wrote:
> commit 7489bdadb7d1 (r8152: check rx after napi is enabled) causes null
> pointer dereference when using device as under root:
> 
>  # rmmod r8152 # or lsusb -v
> NOHZ: local_softirq_pending 08
> BUG: unable to handle kernel NULL pointer dereference at 0000000000000008
> IP: r8152_poll+0x125/0x570 [r8152]
> PGD 89b4cf067
> PUD 898ff2067
> PMD 0
> Oops: 0002 [#1] PREEMPT SMP
> 
> Signed-off-by: Petr Vorel <petr.vorel@gmail.com>
> ---
> NOTE: This is just a workaround, I suppose, there is better way how to fix that
> (which allows keeping scheduling the napi for rx after napi_enable()).
> ---
>  drivers/net/usb/r8152.c | 2 --
>  1 file changed, 2 deletions(-)
> 
> diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
> index 986243c932cc..79c665a89a47 100644
> --- a/drivers/net/usb/r8152.c
> +++ b/drivers/net/usb/r8152.c
> @@ -3703,8 +3703,6 @@ static int rtl8152_resume(struct usb_interface *intf)
>  			napi_enable(&tp->napi);
>  			clear_bit(SELECTIVE_SUSPEND, &tp->flags);
>  			smp_mb__after_atomic();
> -			if (!list_empty(&tp->rx_done))
> -				napi_schedule(&tp->napi);
>  		} else {
>  			tp->rtl_ops.up(tp);
>  			netif_carrier_off(tp->netdev);


The proper work around is to enclose the napi_schedule() in a
local_bh_enable()/local_bh_disable()  pair.
