From: Phil Sutter <phil@nwl.cc>
Subject: Re: [net-next PATCH 2/3] net: sched: set tx_queue_len to default
 when changing noqueue device's qdisc
Date: Thu, 30 Jul 2015 00:08:12 +0200
Message-ID: <20150729220812.GD15554@orbit.nwl.cc>
References: <1438203103-27013-1-git-send-email-phil@nwl.cc>
 <1438203103-27013-2-git-send-email-phil@nwl.cc>
 <1438203103-27013-3-git-send-email-phil@nwl.cc>
 <1438204245.20182.106.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>,
	Cong Wang <cwang@twopensource.com>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:51094 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752711AbbG2WIO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jul 2015 18:08:14 -0400
Content-Disposition: inline
In-Reply-To: <1438204245.20182.106.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 29, 2015 at 11:10:45PM +0200, Eric Dumazet wrote:
> On Wed, 2015-07-29 at 22:51 +0200, Phil Sutter wrote:
[...]
> > diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
> > index f06aa01..79b8900 100644
> > --- a/net/sched/sch_api.c
> > +++ b/net/sched/sch_api.c
> > @@ -1315,6 +1315,10 @@ graft:
> >  			qdisc_destroy(q);
> >  		return err;
> >  	}
> > +	/* circumvent noqueue hack for virtual interfaces if
> > +	 * user desires to use a qdisc on it */
> > +	if (!dev->tx_queue_len)
> > +		dev->tx_queue_len = CONFIG_DEFAULT_TX_QUEUE_LEN;
> >  
> >  	return 0;
> >  }
> 
> This is still broken for htb : htb_init() would run before this,
> and htb_init() does :
> 
> 
> q->direct_qlen = qdisc_dev(sch)->tx_queue_len;

Oh, indeed. But the two lines following it read:

| if (q->direct_qlen < 2) /* some devices have zero tx_queue_len */
| 	q->direct_qlen = 2;

So there is a workaround already in place. Scrolling through the other
implementations it looks like they either ignore tx_queue_len altogether
or have fallbacks for when it's zero already in place. Looks like I was
fixing a pfifo-specific problem in a generic way.

> Really, I am not sure this can be changed. qdisc scripts are mostly
> written by skilled people knowing if txqueuelen needs to be changed or
> not...
> 
> Change the kernel behavior and scripts will break.

I understand that, although I personally wouldn't rely upon such
inconsistent defaults if I were aware of them. Anyway, this series tries
to leave the skilled people alone whilst focussing on the potentially
less skilled ones using veth with default settings. In that regard
Florian's (and now also David's) suggestions to have a separate flag for
drivers defaulting to noqueue and leaving tx_queue_len alone might be a
much better choice.

I'll try that path instead and see where it leads me. Thanks a lot for
the quick help!

Cheers, Phil
