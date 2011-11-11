From: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH 4/4] sunrpc: use SKB fragment destructors to delay
 completion until page is released by network stack.
Date: Fri, 11 Nov 2011 15:00:32 -0500
Message-ID: <20111111200032.GA20853@fieldses.org>
References: <1320850895.955.172.camel@zakaz.uk.xensource.com>
 <1320850927-30240-4-git-send-email-ian.campbell@citrix.com>
 <20111111123824.GA23902@redhat.com>
 <1321017627.955.254.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Neil Brown <neilb-l3A5Bk7waGM@public.gmane.org>,
	"linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Ian Campbell <Ian.Campbell-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1321017627.955.254.camel-o4Be2W7LfRlXesXXhkcM7miJhflN2719@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 11, 2011 at 01:20:27PM +0000, Ian Campbell wrote:
> On Fri, 2011-11-11 at 12:38 +0000, Michael S. Tsirkin wrote:
> > On Wed, Nov 09, 2011 at 03:02:07PM +0000, Ian Campbell wrote:
> > > This prevents an issue where an ACK is delayed, a retransmit is queued (either
> > > at the RPC or TCP level) and the ACK arrives before the retransmission hits the
> > > wire. If this happens to an NFS WRITE RPC then the write() system call
> > > completes and the userspace process can continue, potentially modifying data
> > > referenced by the retransmission before the retransmission occurs.
> > > 
> > > Signed-off-by: Ian Campbell <ian.campbell-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
> > > Acked-by: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
> > > Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> > > Cc: Neil Brown <neilb-l3A5Bk7waGM@public.gmane.org>
> > > Cc: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
> > > Cc: linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> > > Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> > 
> > So this blocks the system call until all page references
> > are gone, right?
> 
> Right. The alternative is to return to userspace while the network stack
> still has a reference to the buffer which was passed in -- that's the
> exact class of problem this patch is supposed to fix.
> 
> > But, there's no upper limit on how long the
> > page is referenced, correct?
> 
> Correct.
> 
> >  consider a bridged setup
> > with an skb queued at a tap device - this cause one process
> > to block another one by virtue of not consuming a cloned skb?
> 
> Hmm, yes.
> 
> One approach might be to introduce the concept of an skb timeout to the
> stack as a whole and cancel (or deep copy) after that timeout occurs.
> That's going to be tricky though I suspect...
> 
> A simpler option would be to have an end points such as a tap device
> which can swallow skbs for arbitrary times implement a policy in this
> regard, either to deep copy or drop after a timeout?

Stupid question: Is it a requirement that you be safe against DOS by a
rogue process with a tap device?  (And if so, does current code satisfy
that requirement?)

--b.
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
