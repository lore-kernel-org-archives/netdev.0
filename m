From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: Re: [PATCH v3] ucc_geth: Lockless xmit
Date: Sun, 23 Sep 2012 11:39:20 +0200
Message-ID: <OF39977762.2BDD4BB8-ONC1257A82.0032A26B-C1257A82.00350A53@transmode.se>
References: <1348129021-28333-1-git-send-email-Joakim.Tjernlund@transmode.se> <1348218675-3804-1-git-send-email-Joakim.Tjernlund@transmode.se> <20120921125129.GA21792@electric-eye.fr.zoreil.com> <OF6B2AFF0B.1C979828-ONC1257A80.00502DCF-C1257A80.00509C7E@LocalDomain> <OF53C63B27.8D5BE7C3-ONC1257A80.00575156-C1257A80.005766FC@transmode.se> <20120921173535.GA27934@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([195.58.98.146]:54105 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753306Ab2IWJjY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Sep 2012 05:39:24 -0400
In-Reply-To: <20120921173535.GA27934@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois Romieu <romieu@fr.zoreil.com> wrote on 2012/09/21 19:35:35:
>
> Please keep netdev in the Cc:.

Sorry, wrong reply button. Now added.

>
> Joakim Tjernlund <joakim.tjernlund@transmode.se> :
> [...]
> > This is what I could come up with, what do you think?
>
> In its current state the driver implicitely relies on the Tx xmit vs Tx
> completion exclusion to work. As long as they exclude each other the
> ugeth->tx_skbuff[txQ][...] and the "bd_status & T_R" states are consistent.
>
> This scheme can not work without locking. The skb alone won't provide a
> synchronization point.

I don't get it. The skb test is there just for one special case, when
the BD ring is empty the (bd_status & T_R) == 0 will be true as well so
one need something more than the bd_status test.

>
> An usual solution would be some skb dirtytx vs curtx comparison + smp
> barriers (Documentation/memory-barriers.txt).

You mean adding an extra test in addition to !skb? Something like:
if (!skb && ugeth->skb_dirtytx[txQ] == ugeth->skb_curtx[txQ])
	break;

>
> Sidenote: is there some reason why modulo (%) operations should be
> avoided on this platform ?

Not that I know. The original driver author did it this way.

>
> [...]
> > @@ -3380,8 +3380,12 @@ static int ucc_geth_tx(struct net_device *dev, u8 txQ)
> >                      1) & TX_RING_MOD_MASK(ugeth->ug_info->bdRingLenTx[txQ]);
> >
> >                 /* We freed a buffer, so now we can restart transmission */
> > -               if (netif_queue_stopped(dev))
> > -                       netif_wake_queue(dev);
> > +               if (netif_queue_stopped(dev)) {
> > +                       netif_tx_lock(dev);
> > +                       if (netif_queue_stopped(dev))
> > +                               netif_wake_queue(dev);
> > +                       netif_tx_unlock(dev);
> > +               }
>
> Without exclusion we don't know if it was stopped before or after the packet
> was freed. There must be some "are there available Tx slots ?" test in the
> locked section.

This makes sense, but stopping relies on ugeth->confBd[txQ] which is updated
last in ucc_geth_tx(). Looks a bit suboptimal though so it should probably
be changed.

>
> Btw the second netif_queue_stopped test can be removed if tx queueing can
> only be stopped in a single place (I did not check).

There is a netif_stop_queue in xmit and one in ucc_geth_close() so I guess
one can say there is only one place.
