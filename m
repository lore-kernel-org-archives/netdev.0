From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] netpoll: protect napi_poll and poll_controller during
 dev_[open|close]
Date: Wed, 30 Jan 2013 16:25:53 -0500
Message-ID: <20130130212553.GA3937@hmsreliant.think-freely.org>
References: <1359578665-29248-1-git-send-email-nhorman@tuxdriver.com>
 <1359580042.2789.53.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Ivan Vecera <ivecera@redhat.com>,
	"David S. Miller" <davem@davemloft.net>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:51838 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754355Ab3A3VZ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2013 16:25:58 -0500
Content-Disposition: inline
In-Reply-To: <1359580042.2789.53.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 30, 2013 at 09:07:22PM +0000, Ben Hutchings wrote:
> On Wed, 2013-01-30 at 15:44 -0500, Neil Horman wrote:
> > Ivan Vercera was recently backporting commit
> > 9c13cb8bb477a83b9a3c9e5a5478a4e21294a760 to a RHEL kernel, and I noticed that,
> > while this patch protects the tg3 driver from having its ndo_poll_controller
> > routine called during device initalization, it does nothing for the driver
> > during shutdown. I.e. it would be entirely possible to have the
> > ndo_poll_controller method (or subsequently the ndo_poll) routine called for a
> > driver in the netpoll path on CPU A while in parallel on CPU B, the ndo_close or
> > ndo_open routine could be called.  Given that the two latter routines tend to
> > initizlize and free many data structures that the former two rely on, the result
> > can easily be data corruption or various other crashes.  Furthermore, it seems
> > that this is potentially a problem with all net drivers that support netpoll,
> > and so this should ideally be fixed in a common path.
> > 
> > Fix it by creating a spinlock in the netpoll_info structure, and holding it on
> > netpoll_poll_dev, and in dev_close and dev_open.  That will prevent the driver
> > from getting torn down while we're using it in the netpoll path
> > 
> > I've done some testing on this, flooding a netconsole enabled system with
> > messages and ifup/downing the interface. No problems observed
> > 
> > Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> > CC: Ivan Vecera <ivecera@redhat.com>
> > CC: "David S. Miller" <davem@davemloft.net>
> > ---
> >  include/linux/netpoll.h |  1 +
> >  net/core/dev.c          | 16 ++++++++++++++++
> >  net/core/netpoll.c      |  3 +++
> >  3 files changed, 20 insertions(+)
> > 
> > diff --git a/include/linux/netpoll.h b/include/linux/netpoll.h
> > index f54c3bb..bb1d364 100644
> > --- a/include/linux/netpoll.h
> > +++ b/include/linux/netpoll.h
> > @@ -40,6 +40,7 @@ struct netpoll_info {
> >  
> >  	int rx_flags;
> >  	spinlock_t rx_lock;
> > +	spinlock_t napi_lock;
> >  	struct list_head rx_np; /* netpolls that registered an rx_hook */
> >  
> >  	struct sk_buff_head neigh_tx; /* list of neigh requests to reply to */
> > diff --git a/net/core/dev.c b/net/core/dev.c
> > index a87bc74..18f85e1 100644
> > --- a/net/core/dev.c
> > +++ b/net/core/dev.c
> > @@ -1307,11 +1307,19 @@ static int __dev_open(struct net_device *dev)
> >  int dev_open(struct net_device *dev)
> >  {
> >  	int ret;
> > +	struct netpoll_info *ni;
> >  
> >  	if (dev->flags & IFF_UP)
> >  		return 0;
> >  
> > +	rcu_read_lock();
> > +	ni = rcu_dereference(dev->npinfo);
> > +	if (ni)
> > +		spin_lock(&ni->napi_lock);
> >  	ret = __dev_open(dev);
> > +	if (ni)
> > +		spin_unlock(&ni->napi_lock);
> [...]
> 
> No, you can't call ndo_open and ndo_stop in atomic context.
> 
Crap, you're right.  I might deadlock too if we print something while going down
via netconsole.  I'll change this to a flag to skip the poll_controller routine
if we're going down.  New patch in the AM.

Thanks
Neil

> Ben.
> 
> -- 
> Ben Hutchings, Staff Engineer, Solarflare
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
> 
> 
