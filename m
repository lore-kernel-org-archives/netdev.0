From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [Xen-devel] [RFC PATCH V3 13/16] netback: stub for multi
 receive protocol support.
Date: Tue, 31 Jan 2012 11:03:44 +0000
Message-ID: <1328007824.5553.70.camel@leeds.uk.xensource.com>
References: <1327934734-8908-1-git-send-email-wei.liu2@citrix.com>
	 <1327934734-8908-14-git-send-email-wei.liu2@citrix.com>
	 <20120130214710.GC16261@phenom.dumpdata.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <wei.liu2@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"Ian Campbell" <Ian.Campbell@citrix.com>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([62.200.22.115]:65069 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752292Ab2AaLDg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2012 06:03:36 -0500
In-Reply-To: <20120130214710.GC16261@phenom.dumpdata.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-01-30 at 21:47 +0000, Konrad Rzeszutek Wilk wrote:
> On Mon, Jan 30, 2012 at 02:45:31PM +0000, Wei Liu wrote:
> > Refactor netback, make stub for mutli receive protocols. Also stub
> 
> multi.
> 

Good catch, thanks.

> > existing code as protocol 0.
> 
> Why not 1?
> 

We have some existing xenolinux code which has not been upstreamed calls
this protocol 0, just try to be compatible.

> Why do we need a new rework without anything using it besides
> the existing framework? OR if you are, you should say which
> patch is doing it...
> 

It is not in use at the moment, and will be in use in the future.

> > 
> > Now the file layout becomes:
> > 
> >  - interface.c: xenvif interfaces
> >  - xenbus.c: xenbus related functions
> >  - netback.c: common functions for various protocols
> > 
> > For different protocols:
> > 
> >  - xenvif_rx_protocolX.h: header file for the protocol, including
> >                           protocol structures and functions
> >  - xenvif_rx_protocolX.c: implementations
> > 
> > To add a new protocol:
> > 
> >  - include protocol header in common.h
> >  - modify XENVIF_MAX_RX_PROTOCOL in common.h
> >  - add protocol structure in xenvif.rx union
> >  - stub in xenbus.c
> >  - modify Makefile
> > 
> > A protocol should define five functions:
> > 
> >  - setup: setup frontend / backend ring connections
> >  - teardown: teardown frontend / backend ring connections
> >  - start_xmit: host start xmit (i.e. guest need to do rx)
> >  - event: rx completion event
> >  - action: prepare host side data for guest rx
> > 
> .. snip..
> 
> > -
> > -	return resp;
> > -}
> > -
> >  static inline int rx_work_todo(struct xenvif *vif)
> >  {
> >  	return !skb_queue_empty(&vif->rx_queue);
> > @@ -1507,8 +999,8 @@ int xenvif_kthread(void *data)
> >  		if (kthread_should_stop())
> >  			break;
> >  
> > -		if (rx_work_todo(vif))
> > -			xenvif_rx_action(vif);
> > +		if (rx_work_todo(vif) && vif->action)
> > +			vif->action(vif);
> >  	}
> >  
> >  	return 0;
> > diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xenbus.c
> > index 79499fc..4067286 100644
> > --- a/drivers/net/xen-netback/xenbus.c
> > +++ b/drivers/net/xen-netback/xenbus.c
> > @@ -415,6 +415,7 @@ static int connect_rings(struct backend_info *be)
> >  	unsigned long rx_ring_ref[NETBK_MAX_RING_PAGES];
> >  	unsigned int  tx_ring_order;
> >  	unsigned int  rx_ring_order;
> > +	unsigned int  rx_protocol;
> >  
> >  	err = xenbus_gather(XBT_NIL, dev->otherend,
> >  			    "event-channel", "%u", &evtchn, NULL);
> > @@ -510,6 +511,11 @@ static int connect_rings(struct backend_info *be)
> >  		}
> >  	}
> >  
> > +	err = xenbus_scanf(XBT_NIL, dev->otherend, "rx-protocol",
> 
> feature-rx-protocol?
> 

This is not a feature switch. Does it make sense to add "feature-"
prefix?

> > +			   "%u", &rx_protocol);
> > +	if (err < 0)
> > +		rx_protocol = XENVIF_MIN_RX_PROTOCOL;
> > +
> 
> You should check to see if the protocol is higher than what we can support.
> The guest could be playing funny games and putting in 39432...
> 
> 

Good point.


Wei.
