From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: RE: [PATCH net] xen-netback: bookkeep number of queues in our own
 module
Date: Mon, 23 Jun 2014 09:18:23 +0000
Message-ID: <9AAE0902D5BC7E449B7C8E4E778ABCD03BC2F7@AMSPEX01CL01.citrite.net>
References: <1403100558-12866-1-git-send-email-wei.liu2@citrix.com>
 <20140622.001355.624567316306796984.davem@davemloft.net>
 <20140622111657.GA7528@zion.uk.xensource.com>
 <9AAE0902D5BC7E449B7C8E4E778ABCD03BBD51@AMSPEX01CL01.citrite.net>
 <20140623084831.GV20819@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Wei Liu <wei.liu2@citrix.com>, David Miller <davem@davemloft.net>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"boris.ostrovsky@oracle.com" <boris.ostrovsky@oracle.com>,
	Ian Campbell <Ian.Campbell@citrix.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([185.25.65.24]:45760 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750723AbaFWJSZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2014 05:18:25 -0400
In-Reply-To: <20140623084831.GV20819@zion.uk.xensource.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Wei Liu [mailto:wei.liu2@citrix.com]
> Sent: 23 June 2014 09:49
> To: Paul Durrant
> Cc: Wei Liu; David Miller; xen-devel@lists.xen.org; netdev@vger.kernel.org;
> boris.ostrovsky@oracle.com; Ian Campbell
> Subject: Re: [PATCH net] xen-netback: bookkeep number of queues in our
> own module
> 
> On Mon, Jun 23, 2014 at 08:59:16AM +0100, Paul Durrant wrote:
> [...]
> > > > > So we bookkeep the number of queues in xen-netback to solve this
> > > > > problem. The usage of real_num_tx_queues in core driver is to cap
> > > queue
> > > > > index to a valid value. In start_xmit we've already guarded against out
> > > > > of range queue index so we should be fine.
> > > > >
> > > > > This fixes a regression introduced by multiqueue patchset in 3.16-rc1.
> > > > >
> > > > > Reported-by: Boris Ostrovsky <boris.ostrovsky@oracle.com>
> > > > > Signed-off-by: Wei Liu <wei.liu2@citrix.com>
> > > >
> > > > I say you should have a select queue method at all.
> > > >
> > > > You're essentially providing a half-assed version of __netdev_pick_tx()
> > > > except that:
> > > >
> > > > 1) You're _completely_ ignoring the socket hash, if any.
> > > >
> > > > 2) You're not allowing XPS to work, _at all_.
> > > >
> > > > I think you need to serious reevaluate providing any select queue
> > > > method at all, just let netdev_pick_tx() do all the work.
> > > >
> > >
> > > Looking at the core driver code in more details I think you're right. I
> > > will remove the select queue method.
> > >
> >
> > Bear in mind that the original intention of the multi-queue patches
> > was to allow the queue selection algorithm to be negotiated with the
> > frontend (see
> > http://lists.xen.org/archives/html/xen-devel/2013-06/msg02654.html).
> > Particularly, if the frontend is Windows then netback will need to use
> > a Toeplitz hash to steer traffic since this is stipulated by
> > Microsoft's RSS (Receive Side Scaling) interfaces. So, IMO netback
> > should always implement a select queue method, otherwise any
> > (theoretical) algorithm change in __netdev_pick_tx() would be
> > immediately imposed on frontends, possibly causing them to misbehave.
> >
> 
> In that case we can easily add back this select queue routine when the
> implementation comes, right?
> 

Ok, for the addition of a new algorithm that may be the case but what about the existent algorithm stability issue? Who's going to watch the implementation of __netdev_pick_tx() and make sure there is no semantic change? I'm still of the opinion that the implementation should be kept within netback so that we can guarantee stability, even if it means duplication. Either that or we need some guarantee that the semantic of __netdev_pick_tx() will never change.

  Paul

> On the other hand, we can exploit the fact that current select queue
> method takes a "fallback" parameter and it points to __netdev_pick_tx,
> we can have something like:
> 
> static u16 xenvif_select_queue(struct net_device *dev, struct sk_buff *skb,
>                                void *accel_priv, select_queue_fallback_t fallback)
> {
>         return fallback(dev, skb);
> }
> 
> But that doesn't make much difference and is a bit redundant IMHO.
> 
> 
> Wei.
> 
> >   Paul
> >
> > > > If you have some issue maintaining the release of queue resources,
> > > > maintain that privately and keep those details in the queue resource
> > > > allocation and freeing code _only_.  Don't make it an issue that
> > > > interferes at all with the normal mechanisms for SKB tx queue
> > > > selection.
> > > >
> > >
> > > Sure. This is exactly the main idea of this patch, just that it
> > > interfered the queue selection logic. :-(
> > >
> > > Will send an updated version soon.
> > >
> > > Wei.
> > >
> > > > Thanks.
> > > --
> > > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > > the body of a message to majordomo@vger.kernel.org
> > > More majordomo info at  http://vger.kernel.org/majordomo-info.html
