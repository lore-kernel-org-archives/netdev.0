From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 6/7] [NETDEV]: tehuti Fix possible causing oops of
 net_rx_action
Date: Wed, 12 Dec 2007 08:36:48 -0800
Message-ID: <20071212083648.13ab0aea@freepuppy.rosehill>
References: <002901c83c73$b089b6e0$9c94fea9@jason>
	<20071211213939.122de1db@freepuppy.rosehill>
	<20071212.072034.148833113.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jgarzik@pobox.com, baum@tehutinetworks.net, andy@greyhouse.net
To: David Miller <davem@davemloft.net>, joonwpark81@gmail.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759496AbXLLQj0@vger.kernel.org>
In-Reply-To: <20071212.072034.148833113.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 12 Dec 2007 07:20:34 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@linux-foundation.org>
> Date: Tue, 11 Dec 2007 21:39:39 -0800
> 
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
> > >  		netif_rx_complete(dev, napi);
> > >  		bdx_enable_interrupts(priv);
> > > +		if (unlikely(work_done == napi->weight))
> > > +			return work_done - 1;
> > >  	}
> > >  	return work_done;
> > >  }
> > 
> > A better fix would be not going over budget in the first place.
> 
> That's not the problem.
> 
> They are not going over the budget, rather, they are hitting
> the budget yet doing netif_rx_complete() as well which is
> illegal.
> 
> Unless you strictly process less than "weight" packets, you must
> not netif_rx_complete() and re-enable chip interrupts.
> 
> I can't believe people are trying to fix this bug like this.

Sorry, I was looking at a different possible problem. The issue
is that if netdev_budget was set smaller (say 128) but device
weight was set larger (say 256). The new code would still allow
the device to do a full swipe (256) packets rather than only
128 as in earlier NAPI. I guess it is an okay behaviour change, because
we don't really guarantee that case.

The problem with the tehuti driver is the logic around priv->napi_stop.
That whole early stop concept should be removed since it just
duplicates the logic of netdev->weight but breaks the assumptions
in the calling netif_rx_action.



-- 
Stephen Hemminger <shemminger@linux-foundation.org>
