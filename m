From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH] Don't allow sharing of tx skbs on xen-netfront
Date: Thu, 17 Nov 2011 20:17:01 +0000
Message-ID: <1321561021.8866.12.camel@dagon.hellion.org.uk>
References: <1321298544-16434-1-git-send-email-nhorman@tuxdriver.com>
	 <1321543238.3664.278.camel@zakaz.uk.xensource.com>
	 <20111117192535.GB26847@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jeremy Fitzhardinge <Jeremy.Fitzhardinge@citrix.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([62.200.22.115]:47396 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755266Ab1KQURE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 15:17:04 -0500
In-Reply-To: <20111117192535.GB26847@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-11-17 at 19:25 +0000, Neil Horman wrote:
> On Thu, Nov 17, 2011 at 03:20:38PM +0000, Ian Campbell wrote:
> > On Mon, 2011-11-14 at 14:22 -0500, Neil Horman wrote:
> > > It was pointed out to me recently that the xen-netfront driver can't safely
> > > support shared skbs on transmit, since, while it doesn't maintain skb state
> > > directly, it does pass a pointer to the skb to the hypervisor via a list, and
> > > the hypervisor may expect the contents of the skb to remain stable.  Clearing
> > > the IFF_TX_SKB_SHARING flag after the call to alloc_etherdev to make it safe.
> > 
> > What are the actual constraints here? The skb is used as a handle to the
> > skb->data and shinfo (frags) and to complete at the end. It's actually
> > those which are passed to the hypervisor (effectively the same as
> > passing those addresses to the h/w for DMA).
> > 
> > Which parts of the skb are expected/allowed to not remain stable?
> > 
> > (Appologies if the above seems naive, I seem to have missed the
> > introduction of shared tx skbs and IFF_TX_SKB_SHARING)
> > 
> Its ok, this is the most accurate description from the previous threads on the
> subject:
> http://lists.openwall.net/netdev/2011/08/22/63
> 
> The basic problem boils down the notion that some drivers, when they receive an
> skb in their xmit paths, presume to have sole ownership of the skb, and as a
> result may do things like add the skb to a list, or otherwise store stateful
> data in the skb.  If the skb is shared, thats unsafe to do, as the stack still
> holds a reference to the skb, and make make changes without serializing them
> against the driver.  So we have to flag those drivers which preform these kinds
> of actions.  xen-netfront doesn't strictly speaking modify any state directly ni
> an skb, but it does place a pointer to the skb in a data structure here:
> 
> np->tx_skbs[id].skb = skb;
> 
> Which then gets handed off to the hypervisior.  Since the hypervisor now has
> access to that skb pointer, and we can't be sure (from the guest perspective),
> what it does with that information, it would be better to be safe by disallowing
> shared skbs in this path.

The skb pointer itself doesn't get given to the backend/hypervisor. The
page which skb->data refers to is granted to the backend domain, as are
the pages in the frags.

I think we only need to be sure that the frontend doesn't rely on
anything in the skb itself, right? Does skb->data or shinfo count from
that perspective?

Ian.

> 
> Neil
> 
> > Ian.
> > 
> > > 
> > > Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> > > CC: "David S. Miller" <davem@davemloft.net>
> > > CC: Jeremy Fitzhardinge <jeremy.fitzhardinge@citrix.com>
> > > CC: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> > > CC: xen-devel@lists.xensource.com
> > > ---
> > >  drivers/net/xen-netfront.c |    6 ++++++
> > >  1 files changed, 6 insertions(+), 0 deletions(-)
> > > 
> > > diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
> > > index 226faab..fb1077b 100644
> > > --- a/drivers/net/xen-netfront.c
> > > +++ b/drivers/net/xen-netfront.c
> > > @@ -1252,6 +1252,12 @@ static struct net_device * __devinit xennet_create_dev(struct xenbus_device *dev
> > >  		return ERR_PTR(-ENOMEM);
> > >  	}
> > >  
> > > +	/*
> > > +	 * Since frames remain on a queue after a return from xennet_start_xmit,
> > > +	 * we can't support tx shared skbs
> > > +	 */
> > > +	netdev->priv_flags &= ~IFF_TX_SKB_SHARING;
> > > +
> > >  	np                   = netdev_priv(netdev);
> > >  	np->xbdev            = dev;
> > >  
> > 
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > 
