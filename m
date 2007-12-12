From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 6/7] : tehuti Fix possible causing oops of
 net_rx_action
Date: Tue, 11 Dec 2007 21:53:50 -0800
Message-ID: <20071211215350.1bf86d02@freepuppy.rosehill>
References: <002901c83c73$b089b6e0$9c94fea9@jason>
	<20071211213939.122de1db@freepuppy.rosehill>
	<b25c3fa70712112148u59baea4dl67a6939df4292917@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jgarzik@pobox.com, baum@tehutinetworks.net, andy@greyhouse.net
To: "Joonwoo Park" <joonwpark81@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:40313 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752233AbXLLFzz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2007 00:55:55 -0500
In-Reply-To: <b25c3fa70712112148u59baea4dl67a6939df4292917@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 12 Dec 2007 14:48:27 +0900
"Joonwoo Park" <joonwpark81@gmail.com> wrote:

> 2007/12/12, Stephen Hemminger <shemminger@linux-foundation.org>:
> > On Wed, 12 Dec 2007 13:01:27 +0900
> > "Joonwoo Park" <joonwpark81@gmail.com> wrote:
> >
> > > [NETDEV]: tehuti Fix possible causing oops of net_rx_action
> > >
> > > Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>
> > > ---
> > >  drivers/net/tehuti.c |    2 ++
> > >  1 files changed, 2 insertions(+), 0 deletions(-)
> > >
> > > diff --git a/drivers/net/tehuti.c b/drivers/net/tehuti.c
> > > index 21230c9..955e749 100644
> > > --- a/drivers/net/tehuti.c
> > > +++ b/drivers/net/tehuti.c
> > > @@ -305,6 +305,8 @@ static int bdx_poll(struct napi_struct *napi, int budget)
> > >
> > >               netif_rx_complete(dev, napi);
> > >               bdx_enable_interrupts(priv);
> > > +             if (unlikely(work_done == napi->weight))
> > > +                     return work_done - 1;
> > >       }
> > >       return work_done;
> > >  }
> >
> > A better fix would be not going over budget in the first place.
> >
> > --
> > Stephen Hemminger <shemminger@linux-foundation.org>
> >
> 
> Stephen,
> This is code of bd_poll().
> Do you mean remove napi_stop stuff?
> 
> static int bdx_poll(struct napi_struct *napi, int budget)
> {
> ...
>         work_done = bdx_rx_receive(priv, &priv->rxd_fifo0, budget);
>         if ((work_done < budget) ||
>             (priv->napi_stop++ >= 30)) {

Yes remove the napi_stop stuff, because current NAPI expects device
to be constrained only by budget. If you need to stop sooner, just
set napi weight to be smaller.

>                 DBG("rx poll is done. backing to isr-driven\n");
> 
>                 /* from time to time we exit to let NAPI layer release
>                  * device lock and allow waiting tasks (eg rmmod) to advance) */
>                 priv->napi_stop = 0;
> 
>                 netif_rx_complete(dev, napi);
>                 bdx_enable_interrupts(priv);

With my posted fix to rx_action the following two lines would not be needed.
>                 if (unlikely(work_done == napi->weight))
>                         return work_done - 1;
>         }
>         return work_done;
> }
> 
> Thanks,
> Joonwoo


-- 
Stephen Hemminger <shemminger@linux-foundation.org>
