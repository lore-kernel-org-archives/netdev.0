From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC PATCH] net: add dataref destructor to sk_buff
Date: Mon, 16 Nov 2009 11:59:31 -0800
Message-ID: <20091116115931.6266f9c9@nehalam>
References: <20091002141407.30224.54207.stgit@dev.haskins.net>
	<20091110115335.GC6989@redhat.com>
	<4AF919020200005A000586A9@sinclair.provo.novell.com>
	<20091110131722.GA19645@redhat.com>
	<4AF9747E.8020408@novell.com>
	<20091110143652.GB19645@redhat.com>
	<4AF98A8C.9040201@novell.com>
	<20091114011229.GA18580@gondor.apana.org.au>
	<4AFE08EF.2030308@gmail.com>
	<20091114022103.GA19020@gondor.apana.org.au>
	<4AFE15AD.6000208@gmail.com>
	<20091113184503.13f6d447@s6510>
	<4AFE3FD2.6030403@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Gregory Haskins <ghaskins@novell.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Gregory Haskins <gregory.haskins@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753894AbZKPT7n@vger.kernel.org>
In-Reply-To: <4AFE3FD2.6030403@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 14 Nov 2009 00:27:46 -0500
Gregory Haskins <gregory.haskins@gmail.com> wrote:

> Stephen Hemminger wrote:
> > On Fri, 13 Nov 2009 21:27:57 -0500
> > Gregory Haskins <gregory.haskins@gmail.com> wrote:
> > 
> >> Herbert Xu wrote:
> >>> On Fri, Nov 13, 2009 at 08:33:35PM -0500, Gregory Haskins wrote:
> >>>> Well, not with respect to the overall protocol, of course not.  But with
> >>>> respect to the buffer in question, it _has_ to be.  Or am I missing
> >>>> something?
> >>> sendfile() has never guaranteed that the kernel is finished with
> >>> the underlying pages when it returns.
> >>>
> >>> Cheers,
> >> Clearly there must be _some_ mechanism to synchronize (e.g.
> >> flush/barrier) though, right?  Otherwise, that interface would seem to
> >> be quite prone to races and would likely be unusable.   So what does
> >> said flush use to know when the buffer is free?
> > 
> > No all the interfaces require a copy.
> 
> I'm sorry, but I do not think that is correct.  As others have pointed
> out, that would not appear to be true for at least sendfile.

Correct.

> 
> > Actually, sendfile makes no guarantee about synchronization
> > because the receiver of said file could be arbitrarily slow, and any attempt at locking down
> > current contents of file is a denial of service exposure.
> 
> I think you are inverting the problem space.  It is fully expected that
> changing the "file", or the pages that represent the file before the
> packet is queued would constitute the modification of the stream on the
> wire.
> 
> I am more thinking about the applications of mmap+sendfile to implement
> a zero-copy interface.  As David mentions in another mail, it seems that
> there is no sync mechanism available, so this would not appear to be a
> viable use case today, unfortunately.

yes, if you do mmap/sendfile then there is no synchronization, and the stack
can hold onto your data for an arbitrary time.  The file and mapping's can
be closed but that risks tying up all of memory.


> > 
> > People have tried doing copy-less send by page flipping, but the overhead of the IPI to
> > invalidate the TLB exceeded the overhead of the copy. There was an Intel paper on this in
> > at Linux Symposium (Ottawa) several years ago.
> 
> I think you are confusing copy-less tx with copy-less rx.  You can try
> to do copy-less rx with page flipping, which has the IPI/TLB thrashing
> properties you mention, and I agree is problematic.  We are talking
> about copy-less tx here, however, and therefore no page-flipping is
> involved.  Rather, we are just posting SG lists of pages directly to the
> NIC (assuming the nic supports HIGH_DMA, etc).  You do not need to flip
> the page, or invalidate the TLB (and thus IPI the other cores) to do
> this to my knowledge.
> 

If you want to do copy-less tx for all applications, you have to
do COW to handle the trivial case of :

while (cc = read(infd, buffer, sizeof buffer)) {
   send(outsock, buffer, cc);
}




-- 
