From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] Don't allow sharing of tx skbs on xen-netfront
Date: Fri, 18 Nov 2011 07:09:58 -0500
Message-ID: <20111118120958.GD7907@hmsreliant.think-freely.org>
References: <1321298544-16434-1-git-send-email-nhorman@tuxdriver.com>
 <1321543238.3664.278.camel@zakaz.uk.xensource.com>
 <20111117192535.GB26847@hmsreliant.think-freely.org>
 <1321561021.8866.12.camel@dagon.hellion.org.uk>
 <20111117204553.GD26847@hmsreliant.think-freely.org>
 <1321612213.3664.293.camel@zakaz.uk.xensource.com>
 <20111118114839.GA7907@hmsreliant.think-freely.org>
 <1321617190.3664.338.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jeremy Fitzhardinge <Jeremy.Fitzhardinge@citrix.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:36358 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750844Ab1KRMKE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2011 07:10:04 -0500
Content-Disposition: inline
In-Reply-To: <1321617190.3664.338.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 18, 2011 at 11:53:09AM +0000, Ian Campbell wrote:
> On Fri, 2011-11-18 at 11:48 +0000, Neil Horman wrote:
> > On Fri, Nov 18, 2011 at 10:30:13AM +0000, Ian Campbell wrote:
> > > On Thu, 2011-11-17 at 20:45 +0000, Neil Horman wrote:
> > > > On Thu, Nov 17, 2011 at 08:17:01PM +0000, Ian Campbell wrote:
> > > > > On Thu, 2011-11-17 at 19:25 +0000, Neil Horman wrote:
> > > > > > On Thu, Nov 17, 2011 at 03:20:38PM +0000, Ian Campbell wrote:
> > > > > > > On Mon, 2011-11-14 at 14:22 -0500, Neil Horman wrote:
> > > > > > > > It was pointed out to me recently that the xen-netfront driver can't safely
> > > > > > > > support shared skbs on transmit, since, while it doesn't maintain skb state
> > > > > > > > directly, it does pass a pointer to the skb to the hypervisor via a list, and
> > > > > > > > the hypervisor may expect the contents of the skb to remain stable.  Clearing
> > > > > > > > the IFF_TX_SKB_SHARING flag after the call to alloc_etherdev to make it safe.
> > > > > > > 
> > > > > > > What are the actual constraints here? The skb is used as a handle to the
> > > > > > > skb->data and shinfo (frags) and to complete at the end. It's actually
> > > > > > > those which are passed to the hypervisor (effectively the same as
> > > > > > > passing those addresses to the h/w for DMA).
> > > > > > > 
> > > > > > > Which parts of the skb are expected/allowed to not remain stable?
> > > > > > > 
> > > > > > > (Appologies if the above seems naive, I seem to have missed the
> > > > > > > introduction of shared tx skbs and IFF_TX_SKB_SHARING)
> > > > > > > 
> > > > > > Its ok, this is the most accurate description from the previous threads on the
> > > > > > subject:
> > > > > > 2
> > > > > > 
> > > > > > The basic problem boils down the notion that some drivers, when they receive an
> > > > > > skb in their xmit paths, presume to have sole ownership of the skb, and as a
> > > > > > result may do things like add the skb to a list, or otherwise store stateful
> > > > > > data in the skb.  If the skb is shared, thats unsafe to do, as the stack still
> > > > > > holds a reference to the skb, and make make changes without serializing them
> > > > > > against the driver.  So we have to flag those drivers which preform these kinds
> > > > > > of actions.  xen-netfront doesn't strictly speaking modify any state directly ni
> > > > > > an skb, but it does place a pointer to the skb in a data structure here:
> > > > > > 
> > > > > > np->tx_skbs[id].skb = skb;
> > > > > > 
> > > > > > Which then gets handed off to the hypervisior.  Since the hypervisor now has
> > > > > > access to that skb pointer, and we can't be sure (from the guest perspective),
> > > > > > what it does with that information, it would be better to be safe by disallowing
> > > > > > shared skbs in this path.
> > > > > 
> > > > > The skb pointer itself doesn't get given to the backend/hypervisor. The
> > > > > page which skb->data refers to is granted to the backend domain, as are
> > > > > the pages in the frags.
> > > > > 
> > > > > I think we only need to be sure that the frontend doesn't rely on
> > > > > anything in the skb itself, right? Does skb->data or shinfo count from
> > > > > that perspective?
> > > > shinfo is definately a problem, as other devices may make modifications to it.
> > > > skb->data is probably safer, but is also potentially suspect (for instance if
> > > > another device appends an additional header to the data for instance)
> > > 
> > > A device is allowed to rely on these things being stable while in its
> > > start_xmit, right? (otherwise I don't see how any device can ever
> > > cope...).
> > > 
> > While the start_xmit routine is executing, yes.  Its only after the driver
> > returns, that it can have no expectation of an skb's data to remain stable.
> > 
> > > netfront only uses shinfo and ->data during start_xmit in order to
> > > create the necessary grant reference (which can be thought of as a DMA
> > > address passed to the virtual hardware). The only use of the stashed skb
> > > pointer outside of this are to dev_kfree_skb on tx completion (from
> > > either tx_buf_gc (normal completion) or release_tx_buf ("hardware"
> > > reset).
> > > 
> > Ok, if you're certain you can guarantee that the hypervisior makes no inspection
> > of the skb after the return from the driver, then you're safe
> 
> I believe this is the case, all that is exposed to the backend is the
> pfn, offset and length of the skb->data and frags at the time start_xmit
> was called.
> 
Ok, if you're sure, than this can be dropped.
Neil
