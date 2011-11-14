From: Ian Campbell <Ian.Campbell-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 4/4] sunrpc: use SKB fragment destructors to delay
 completion until page is released by network stack.
Date: Mon, 14 Nov 2011 13:07:35 +0000
Message-ID: <1321276055.3664.67.camel@zakaz.uk.xensource.com>
References: <1320850895.955.172.camel@zakaz.uk.xensource.com>
	 <1320850927-30240-4-git-send-email-ian.campbell@citrix.com>
	 <20111111123824.GA23902@redhat.com>
	 <1321017627.955.254.camel@zakaz.uk.xensource.com>
	 <20111113101713.GB15322@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Neil Brown <neilb-l3A5Bk7waGM@public.gmane.org>,
	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	"linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20111113101713.GB15322-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, 2011-11-13 at 10:17 +0000, Michael S. Tsirkin wrote:
> On Fri, Nov 11, 2011 at 01:20:27PM +0000, Ian Campbell wrote:
> > On Fri, 2011-11-11 at 12:38 +0000, Michael S. Tsirkin wrote:
> > > On Wed, Nov 09, 2011 at 03:02:07PM +0000, Ian Campbell wrote:
> > > > This prevents an issue where an ACK is delayed, a retransmit is queued (either
> > > > at the RPC or TCP level) and the ACK arrives before the retransmission hits the
> > > > wire. If this happens to an NFS WRITE RPC then the write() system call
> > > > completes and the userspace process can continue, potentially modifying data
> > > > referenced by the retransmission before the retransmission occurs.
> > > > 
> > > > Signed-off-by: Ian Campbell <ian.campbell-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
> > > > Acked-by: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
> > > > Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> > > > Cc: Neil Brown <neilb-l3A5Bk7waGM@public.gmane.org>
> > > > Cc: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
> > > > Cc: linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> > > > Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> > > 
> > > So this blocks the system call until all page references
> > > are gone, right?
> > 
> > Right. The alternative is to return to userspace while the network stack
> > still has a reference to the buffer which was passed in -- that's the
> > exact class of problem this patch is supposed to fix.
> 
> BTW, the increased latency and the overhead extra wakeups might for some
> workloads be greater than the cost of the data copy.

Under normal circumstances these paths should not be activated at all.
These only come into play if there are delays in the network coming from
somewhere and I would expect any negative effect from that to outweigh
either a copy or an additional wakeup.

> > 
> > >  consider a bridged setup
> > > with an skb queued at a tap device - this cause one process
> > > to block another one by virtue of not consuming a cloned skb?
> > 
> > Hmm, yes.
> > 
> > One approach might be to introduce the concept of an skb timeout to the
> > stack as a whole and cancel (or deep copy) after that timeout occurs.
> > That's going to be tricky though I suspect...
> 
> Further, an application might use signals such as SIGALARM,
> delaying them significantly will cause trouble.

AIUI there is nothing to stop the SIGALARM being delivered in a timely
manner, all which may need to be delayed is the write() returning
-EINTR. 

When -EINTR is returned the buffer must no longer be referenced either
implicitly or explicitly by the kernel and the write must not have
completed and nor should it complete in the future (that way lies
corruption of varying sorts) so copying the data pages is not helpful in
this case.

This patch ensures that the buffer is no longer referenced when the
write returns. It's possible that NFS might need to cancel a write
operation in order to not complete it after returning -EINTR (I don't
know if it does this or not) but I don't think this series impacts that
one way or the other.

> 
> > A simpler option would be to have an end points such as a tap device
> 
> Which end points would that be? Doesn't this affect a packet socket
> with matching filters? A userspace TCP socket that happens to
> reside on the same box?  It also seems that at least with a tap device
> an skb can get queued in a qdisk, also indefinitely, right?

Those are all possibilities.

In order for this patch to have any impact on any of these scenarios
those end points would have to currently be referencing and using pages
of data which have been "returned" to the originating user process and
may be changing under their feet. This is without a doubt a Bad Thing.

In the normal case it is likely that the same end point which is
injecting delay is also the one the originating process is actually
trying to talk to and so the delay would already have been present and
this patch doesn't delay things any further.

If there are parts of the stack which can end up holding onto an skb for
an arbitrary amount of time then I think that is something which needs
to be fixed up in those end points rather than in everyone who injects
an skb into the stack. Whether an immediate deep copy or a more lazy
approach is appropriate I suspect depends upon the exact use case of
each end point.

Having said that one idea which springs to mind would be to allow
someone who has injected a page into the stack to "cancel" it. Since I
am working on pushing the struct page * down into the struct
skb_destructor this could be as simple as setting the page to NULL.
However every end point would need to be taught to expect this. I'm sure
there are also all sorts of locking nightmares underlying this idea.
Perhaps you'd need separate reference counts for queued vs in active
use.

Ian.

> 
> > which can swallow skbs for arbitrary times implement a policy in this
> > regard, either to deep copy or drop after a timeout?
> > 
> > Ian.
> 
> Or deep copy immediately?
> 


--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
