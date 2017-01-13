From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: RE: [PATCH] xen-netback: fix memory leaks on XenBus disconnect
Date: Fri, 13 Jan 2017 10:49:36 +0000
Message-ID: <75863da2db4f48929c9eea56f76dbd9e@AMSPEX02CL03.citrite.net>
References: <1484243516-141100-1-git-send-email-igor.druzhinin@citrix.com>
 <20170113103800.GA5089@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Wei Liu <wei.liu2@citrix.com>,
        "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Wei Liu <wei.liu2@citrix.com>,
        Igor Druzhinin <igor.druzhinin@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170113103800.GA5089@citrix.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Wei Liu [mailto:wei.liu2@citrix.com]
> Sent: 13 January 2017 10:38
> To: Igor Druzhinin <igor.druzhinin@citrix.com>
> Cc: Wei Liu <wei.liu2@citrix.com>; xen-devel@lists.xenproject.org; Paul
> Durrant <Paul.Durrant@citrix.com>; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org
> Subject: Re: [PATCH] xen-netback: fix memory leaks on XenBus disconnect
> 
> On Thu, Jan 12, 2017 at 05:51:56PM +0000, Igor Druzhinin wrote:
> > Eliminate memory leaks introduced several years ago by cleaning the
> queue
> > resources which are allocated on XenBus connection event. Namely, queue
> > structure array and pages used for IO rings.
> > vif->lock is used to protect statistics gathering agents from using the
> > queue structure during cleaning.
> >
> 
> There is code in netback_remove which eventually calls xenvif_free to
> free up the resources, maybe you should modify xenvif_free instead? That
> seems more symmetric to me. What do you think?

The connect code vallocs the queue array because the size is not known until then so it makes sense that disconnect vfrees it.

  Paul

> 
> > Signed-off-by: Igor Druzhinin <igor.druzhinin@citrix.com>
> > ---
> >  drivers/net/xen-netback/interface.c |  6 ++++--
> >  drivers/net/xen-netback/xenbus.c    | 13 +++++++++++++
> >  2 files changed, 17 insertions(+), 2 deletions(-)
> >
> > diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-
> netback/interface.c
> > index e30ffd2..5795213 100644
> > --- a/drivers/net/xen-netback/interface.c
> > +++ b/drivers/net/xen-netback/interface.c
> > @@ -221,18 +221,18 @@ static struct net_device_stats
> *xenvif_get_stats(struct net_device *dev)
> >  {
> >  	struct xenvif *vif = netdev_priv(dev);
> >  	struct xenvif_queue *queue = NULL;
> > -	unsigned int num_queues = vif->num_queues;
> >  	unsigned long rx_bytes = 0;
> >  	unsigned long rx_packets = 0;
> >  	unsigned long tx_bytes = 0;
> >  	unsigned long tx_packets = 0;
> >  	unsigned int index;
> >
> > +	spin_lock(&vif->lock);
> >  	if (vif->queues == NULL)
> >  		goto out;
> >
> >  	/* Aggregate tx and rx stats from each queue */
> > -	for (index = 0; index < num_queues; ++index) {
> > +	for (index = 0; index < vif->num_queues; ++index) {
> >  		queue = &vif->queues[index];
> >  		rx_bytes += queue->stats.rx_bytes;
> >  		rx_packets += queue->stats.rx_packets;
> > @@ -241,6 +241,8 @@ static struct net_device_stats
> *xenvif_get_stats(struct net_device *dev)
> >  	}
> >
> >  out:
> > +	spin_unlock(&vif->lock);
> > +
> 
> Good catch, this is definitely needed. And it would probably be in a
> separate patch.
> 
> Wei.
