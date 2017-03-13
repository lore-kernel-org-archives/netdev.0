From: Petr Vorel <petr.vorel@gmail.com>
Subject: Re: [PATCH 1/1] r8152: fix NULL pointer dereference in r8152_poll
Date: Mon, 13 Mar 2017 16:37:46 +0100
Message-ID: <20170313153745.wu7cf254obh2x2gn@dell5510>
References: <20170313124727.4681-1-petr.vorel@gmail.com>
 <1489411084.28631.78.camel@edumazet-glaptop3.roam.corp.google.com>
 <1489411184.28631.80.camel@edumazet-glaptop3.roam.corp.google.com>
Reply-To: Petr Vorel <petr.vorel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, hayeswang@realtek.com, davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:36420 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751188AbdCMPht (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 11:37:49 -0400
Received: by mail-wm0-f67.google.com with SMTP id v190so10498164wme.3
        for <netdev@vger.kernel.org>; Mon, 13 Mar 2017 08:37:48 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1489411184.28631.80.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

> > The proper work around is to enclose the napi_schedule() in a
> > local_bh_enable()/local_bh_disable()  pair.

> Something like :
> --- a/drivers/net/usb/r8152.c
> +++ b/drivers/net/usb/r8152.c
> @@ -3703,8 +3703,10 @@ static int rtl8152_resume(struct usb_interface *intf)
>  			napi_enable(&tp->napi);
>  			clear_bit(SELECTIVE_SUSPEND, &tp->flags);
>  			smp_mb__after_atomic();
> +			local_bh_disable();
>  			if (!list_empty(&tp->rx_done))
>  				napi_schedule(&tp->napi);
> +			local_bh_enable();

Unfortunately this doesn't work. Code in r8152.c doesn't use local_bh_enable()/local_bh_disable(). I tried to lock it with spin_lock_bh()/spin_unlock_bh() and with mutex_lock()/mutex_unlock() but neither work.


Kind regards,
Petr
