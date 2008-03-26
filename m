From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] Improvev netconsole support for RTL8139 NIC driver
Date: Tue, 25 Mar 2008 22:23:24 -0400
Message-ID: <47E9B39C.5010502@pobox.com>
References: <47E9B115.9060109@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>
To: yshi <yang.shi@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:53448 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753317AbYCZCX2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Mar 2008 22:23:28 -0400
In-Reply-To: <47E9B115.9060109@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

yshi wrote:
> In current RTL8139 NIC driver, spin_lock()/spin_unlock() is used
> for irq handler. But for netconsole/netpoll, it prefers
> spin_lock_irqsave()/spin_unlcok_irqrestore(). So this patch fixed
> this problem to improve netconsole/netpoll support.
> 
> Signed-off-by: Yang Shi <yang.shi@windriver.com>
> ---
> b/drivers/net/8139too.c |    9 +++++++++
> 1 file changed, 9 insertions(+)
> ---
> 
> --- a/drivers/net/8139too.c
> +++ b/drivers/net/8139too.c
> @@ -2136,8 +2136,13 @@ static irqreturn_t rtl8139_interrupt (in
>        u16 status, ackstat;
>        int link_changed = 0; /* avoid bogus "uninit" warning */
>        int handled = 0;
> +#ifdef CONFIG_NET_POLL_CONTROLLER
> +       unsigned long flags;
> 
> +       spin_lock_irqsave (&tp->lock, flags);
> +#else
>        spin_lock (&tp->lock);
> +#endif
>        status = RTL_R16 (IntrStatus);
> 
>        /* shared irq? */
> @@ -2185,7 +2190,11 @@ static irqreturn_t rtl8139_interrupt (in
>                        RTL_W16 (IntrStatus, TxErr);
>        }
>  out:
> +#ifdef CONFIG_NET_POLL_CONTROLLER
> +       spin_unlock_irqrestore (&tp->lock, flags);
> +#else
>        spin_unlock (&tp->lock);
> +#endif

This is bogus -- you should never need to slow down the hot path in such 
a way.

Add a local_irq_save()/restore() to rtl8139_poll_controller() or a 
similar solution, putting the burden on the netpoll/netconsole layer.

	Jeff



