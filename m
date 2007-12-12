From: "Joonwoo Park" <joonwpark81@gmail.com>
Subject: Re: [PATCH 6/7] : tehuti Fix possible causing oops of net_rx_action
Date: Wed, 12 Dec 2007 14:48:27 +0900
Message-ID: <b25c3fa70712112148u59baea4dl67a6939df4292917@mail.gmail.com>
References: <002901c83c73$b089b6e0$9c94fea9@jason>
	 <20071211213939.122de1db@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jgarzik@pobox.com, baum@tehutinetworks.net, andy@greyhouse.net
To: "Stephen Hemminger" <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ro-out-1112.google.com ([72.14.202.176]:64154 "EHLO
	ro-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757199AbXLLFsa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2007 00:48:30 -0500
Received: by ro-out-1112.google.com with SMTP id p4so142281roc.5
        for <netdev@vger.kernel.org>; Tue, 11 Dec 2007 21:48:29 -0800 (PST)
In-Reply-To: <20071211213939.122de1db@freepuppy.rosehill>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2007/12/12, Stephen Hemminger <shemminger@linux-foundation.org>:
> On Wed, 12 Dec 2007 13:01:27 +0900
> "Joonwoo Park" <joonwpark81@gmail.com> wrote:
>
> > [NETDEV]: tehuti Fix possible causing oops of net_rx_action
> >
> > Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>
> > ---
> >  drivers/net/tehuti.c |    2 ++
> >  1 files changed, 2 insertions(+), 0 deletions(-)
> >
> > diff --git a/drivers/net/tehuti.c b/drivers/net/tehuti.c
> > index 21230c9..955e749 100644
> > --- a/drivers/net/tehuti.c
> > +++ b/drivers/net/tehuti.c
> > @@ -305,6 +305,8 @@ static int bdx_poll(struct napi_struct *napi, int budget)
> >
> >               netif_rx_complete(dev, napi);
> >               bdx_enable_interrupts(priv);
> > +             if (unlikely(work_done == napi->weight))
> > +                     return work_done - 1;
> >       }
> >       return work_done;
> >  }
>
> A better fix would be not going over budget in the first place.
>
> --
> Stephen Hemminger <shemminger@linux-foundation.org>
>

Stephen,
This is code of bd_poll().
Do you mean remove napi_stop stuff?

static int bdx_poll(struct napi_struct *napi, int budget)
{
...
        work_done = bdx_rx_receive(priv, &priv->rxd_fifo0, budget);
        if ((work_done < budget) ||
            (priv->napi_stop++ >= 30)) {
                DBG("rx poll is done. backing to isr-driven\n");

                /* from time to time we exit to let NAPI layer release
                 * device lock and allow waiting tasks (eg rmmod) to advance) */
                priv->napi_stop = 0;

                netif_rx_complete(dev, napi);
                bdx_enable_interrupts(priv);
                if (unlikely(work_done == napi->weight))
                        return work_done - 1;
        }
        return work_done;
}

Thanks,
Joonwoo
