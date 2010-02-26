From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: Re: Gianfar driver failing on MPC8641D based board
Date: Fri, 26 Feb 2010 17:35:32 +0300
Message-ID: <20100226143532.GA31622@oksana.dev.rtsoft.ru>
References: <4B6C2488.3060403@ge.com>
 <4B865176.7080806@ge.com>
 <4B86A97E.6050509@ge.com>
 <20100225165141.GA9686@oksana.dev.rtsoft.ru>
 <20100225174935.GA32370@oksana.dev.rtsoft.ru>
 <7d1d9c251002251653n6473f01ex2d43933ec6aa010b@mail.gmail.com>
 <20100226031452.GA11319@oksana.dev.rtsoft.ru>
 <4B87B937.6010204@ge.com>
Reply-To: avorontsov@ru.mvista.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linuxppc-dev list <linuxppc-dev@ozlabs.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Sandeep Gopalpet <Sandeep.Kumar@freescale.com>,
	davem@davemloft.net
To: Martyn Welch <martyn.welch@ge.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4B87B937.6010204@ge.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 26, 2010 at 12:06:15PM +0000, Martyn Welch wrote:
> Anton Vorontsov wrote:
> > On Thu, Feb 25, 2010 at 07:53:30PM -0500, Paul Gortmaker wrote:
> > [...]
> >   
> >> I was able to reproduce it on an 8641D and bisected it down to this:
> >>
> >> -----------
> >> commit a3bc1f11e9b867a4f49505ecac486a33af248b2e
> >> Author: Anton Vorontsov <avorontsov@ru.mvista.com>
> >> Date:   Tue Nov 10 14:11:10 2009 +0000
> >>
> >>     gianfar: Revive SKB recycling
> >>     
> >
> > Thanks for the bisect. I have a guess why tx hangs in
> > SMP case. Could anyone try the patch down below?
> >   
> 
> Yup, no problem. I'm afraid it doesn't resolve the problem for me.

Hm.. I found a p2020 board and I was able to reproduce the issue.
The patch down below fixed it completely for me... hm.

I'll look further, thanks!

> > [...]
> >   
> >> ...which probably explains why you weren't seeing it on non-SMP.
> >> I'd imagine it would show up on any of the e500mc boards too.
> >>     
> >
> > Yeah.. Pity, I don't have SMP boards anymore. I'll try
> > to get one though.
> >
> >
> > diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
> > index 8bd3c9f..3ff3bd0 100644
> > --- a/drivers/net/gianfar.c
> > +++ b/drivers/net/gianfar.c
> > @@ -2614,6 +2614,8 @@ static int gfar_poll(struct napi_struct *napi, int budget)
> >  			tx_queue = priv->tx_queue[rx_queue->qindex];
> >  
> >  			tx_cleaned += gfar_clean_tx_ring(tx_queue);
> > +			if (!tx_cleaned && !tx_queue->num_txbdfree)
> > +				tx_cleaned += 1; /* don't complete napi */
> >  			rx_cleaned_per_queue = gfar_clean_rx_ring(rx_queue,
> >  							budget_per_queue);
> >  			rx_cleaned += rx_cleaned_per_queue;
> >   

-- 
Anton Vorontsov
email: cbouatmailru@gmail.com
irc://irc.freenode.net/bd2
