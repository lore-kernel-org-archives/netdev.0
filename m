From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH RFC 5/6] net: orphan frags on receive
Date: Wed, 9 May 2012 18:12:02 +0300
Message-ID: <20120509151202.GB20474@redhat.com>
References: <cover.1336397823.git.mst@redhat.com>
 <a3353f6235d877c6b2d300eb5a914dbc9b78824d.1336397823.git.mst@redhat.com>
 <1336571692.25514.122.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32653 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759850Ab2EIPMB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 May 2012 11:12:01 -0400
Content-Disposition: inline
In-Reply-To: <1336571692.25514.122.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 09, 2012 at 02:54:52PM +0100, Ian Campbell wrote:
> On Mon, 2012-05-07 at 14:54 +0100, Michael S. Tsirkin wrote:
> > zero copy packets are normally sent to the outside
> > network, but bridging, tun etc might loop them
> > back to host networking stack. If this happens
> > destructors will never be called, so orphan
> > the frags immediately on receive.
> 
> I think this deceptively simply patch is actually the meat of the
> series.
> It's been a long time since I dug into the bridging code. Am I right
> that this function is only reached when an SKB is going to be delivered
> locally and not when forwarding to another port on the bridge?
> 
> Ian.

I think so - bridge uses netdev_rx_handler_unregister
so it does not go through packet handlers.

> > 
> > Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> > ---
> >  net/core/dev.c |    2 ++
> >  1 files changed, 2 insertions(+), 0 deletions(-)
> > 
> > diff --git a/net/core/dev.c b/net/core/dev.c
> > index a2be59f..c0cdc00 100644
> > --- a/net/core/dev.c
> > +++ b/net/core/dev.c
> > @@ -1630,6 +1630,8 @@ static inline int deliver_skb(struct sk_buff *skb,
> >  			      struct packet_type *pt_prev,
> >  			      struct net_device *orig_dev)
> >  {
> > +	if (unlikely(skb_orphan_frags(skb, GFP_ATOMIC)))
> > +		return -ENOMEM;
> >  	atomic_inc(&skb->users);
> >  	return pt_prev->func(skb, skb->dev, pt_prev, orig_dev);
> >  }
> 
