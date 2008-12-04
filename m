From: "Will Newton" <will.newton@gmail.com>
Subject: Re: [PATCH] tty: Flags should be accessed via the foo_bit interfaces
Date: Thu, 4 Dec 2008 15:50:29 +0000
Message-ID: <87a5b0800812040750p6231b0c9s2f664345b23596f0@mail.gmail.com>
References: <20081204154030.27980.82380.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Alan Cox" <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.31]:64983 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754527AbYLDPuc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2008 10:50:32 -0500
Received: by yw-out-2324.google.com with SMTP id 9so1734997ywe.1
        for <netdev@vger.kernel.org>; Thu, 04 Dec 2008 07:50:30 -0800 (PST)
In-Reply-To: <20081204154030.27980.82380.stgit@localhost.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 4, 2008 at 3:41 PM, Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:
> From: Alan Cox <alan@redhat.com>
>
> We have various drivers that poke around directly and we need to clean this
> up before it causes problems. Fix up the networking ones - (Dave can you send
> this via the net tree as that seems simplest)
>
> Signed-off-by: Alan Cox <alan@redhat.com>

> diff --git a/drivers/net/slip.c b/drivers/net/slip.c
> index 1d58991..951c7df 100644
> --- a/drivers/net/slip.c
> +++ b/drivers/net/slip.c
> @@ -402,7 +402,7 @@ static void sl_encaps(struct slip *sl, unsigned char *icp, int len)
>         * if we did not request it before write operation.
>         *       14 Oct 1994  Dmitry Gorodchanin.
>         */
> -       sl->tty->flags |= (1 << TTY_DO_WRITE_WAKEUP);
> +       set_bit(TTY_DO_WRITE_WAKEUP, &sl->tty->flags);
>        actual = sl->tty->ops->write(sl->tty, sl->xbuff, count);
>  #ifdef SL_CHECK_TRANSMIT
>        sl->dev->trans_start = jiffies;
> @@ -432,7 +432,7 @@ static void slip_write_wakeup(struct tty_struct *tty)
>                /* Now serial buffer is almost free & we can start
>                 * transmission of another packet */
>                sl->tx_packets++;
> -               tty->flags &= ~(1 << TTY_DO_WRITE_WAKEUP);
> +               clear_bit(TTY_DO_WRITE_WAKEUP, &sl->tty->flags);
>                sl_unlock(sl);
>                return;
>        }
> @@ -465,7 +465,7 @@ static void sl_tx_timeout(struct net_device *dev)
>                        (tty_chars_in_buffer(sl->tty) || sl->xleft) ?
>                                "bad line quality" : "driver error");
>                sl->xleft = 0;
> -               sl->tty->flags &= ~(1 << TTY_DO_WRITE_WAKEUP);
> +               clear_bit(TTY_DO_WRITE_WAKEUP, &sl->tty->flags);
>                sl_unlock(sl);
>  #endif
>        }
> @@ -515,10 +515,9 @@ sl_close(struct net_device *dev)
>        struct slip *sl = netdev_priv(dev);
>
>        spin_lock_bh(&sl->lock);
> -       if (sl->tty) {
> +       if (sl->tty)
> +               clear_bit(TTY_DO_WRITE_WAKEUP, &sl->tty->flags);
>                /* TTY discipline is running. */
> -               sl->tty->flags &= ~(1 << TTY_DO_WRITE_WAKEUP);
> -       }

The indentation of the comment looks like it might be wrong here.

>        netif_stop_queue(dev);
>        sl->rcount   = 0;
>        sl->xleft    = 0;
