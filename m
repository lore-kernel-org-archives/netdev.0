From: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Subject: Re: [PATCH] netpoll: fix TX queue overflow in trapped mode
Date: Sun, 29 Apr 2007 00:25:41 +0400
Message-ID: <200704290025.41760.sshtylyov@ru.mvista.com>
References: <200704282212.32443.sshtylyov@ru.mvista.com> <200704282252.01296.sshtylyov@ru.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from h155.mvista.com ([63.81.120.155]:42082 "EHLO imap.sh.mvista.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1749667AbXD1UYG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Apr 2007 16:24:06 -0400
In-Reply-To: <200704282252.01296.sshtylyov@ru.mvista.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 28 April 2007 22:52, I wrote:

> > CONFIG_NETPOLL_TRAP causes the TX queue controls to be completely
> > bypassed in the netpoll's "trapped" mode which easily causes overflows in
> > the drivers with short TX queues (most notably, in 8139too with its
> > 4-deep queue).  So, make this option more sensible by making it only
> > bypass the TX softirq wakeup.
>    Dammit!  Finally forgot to add acks earned so far:

   Oh, and there was even another one:

> > Signed-off-by: Sergei Shtylyov <sshtylyov@ru.mvista.com>

> Acked-by: Jeff Garzik <jgarzik@pobox.com>
Acked-by: Tom Rini <trini@kernel.crashing.org>
> Acked-by: Matt Mackall <mpm@selenic.com>

> > ---
> > Split this part form the initial patch as request by Matt Mackall.
> >
> >  include/linux/netdevice.h |    8 +++-----
> >  2 files changed, 3 insertions(+), 10 deletions(-)
> >
> > Index: linux-2.6/include/linux/netdevice.h
> > ===================================================================
> > --- linux-2.6.orig/include/linux/netdevice.h
> > +++ linux-2.6/include/linux/netdevice.h
> > @@ -647,8 +647,10 @@ static inline void netif_start_queue(str
> >  static inline void netif_wake_queue(struct net_device *dev)
> >  {
> >  #ifdef CONFIG_NETPOLL_TRAP
> > -	if (netpoll_trap())
> > +	if (netpoll_trap()) {
> > +		clear_bit(__LINK_STATE_XOFF, &dev->state);
> >  		return;
> > +	}
> >  #endif
> >  	if (test_and_clear_bit(__LINK_STATE_XOFF, &dev->state))
> >  		__netif_schedule(dev);
> > @@ -656,10 +658,6 @@ static inline void netif_wake_queue(stru
> >
> >  static inline void netif_stop_queue(struct net_device *dev)
> >  {
> > -#ifdef CONFIG_NETPOLL_TRAP
> > -	if (netpoll_trap())
> > -		return;
> > -#endif
> >  	set_bit(__LINK_STATE_XOFF, &dev->state);
> >  }

