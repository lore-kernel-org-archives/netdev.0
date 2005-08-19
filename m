From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: Re: [E1000-devel] Page Allocation Failure with e1000 using jumboframe
Date: Fri, 19 Aug 2005 14:10:40 -0700 (Pacific Daylight Time)
Message-ID: <Pine.WNT.4.63.0508191103220.3796@jbrandeb-desk.amr.corp.intel.com>
References: <1124326404.5546.215.camel@localhost.localdomain>
 <Pine.WNT.4.63.0508190940210.3796@jbrandeb-desk.amr.corp.intel.com>
 <1124470909.5552.11.camel@localhost.localdomain>
 <Pine.WNT.4.63.0508191023130.3796@jbrandeb-desk.amr.corp.intel.com>
 <20050819174201.GJ3953@verdi.suse.de> <Pine.WNT.4.63.0508191043440.3796@jbrandeb-desk.amr.corp.intel.com>
 <20050819180132.GO22993@wotan.suse.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	Ming Zhang <mingz@ele.uri.edu>,
	E1000 <e1000-devel@lists.sourceforge.net>,
	iet-dev <iscsitarget-devel@lists.sourceforge.net>,
	netdev@vger.kernel.org
Return-path: <iscsitarget-devel-admin@lists.sourceforge.net>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20050819180132.GO22993@wotan.suse.de>
Sender: iscsitarget-devel-admin@lists.sourceforge.net
Errors-To: iscsitarget-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/iscsitarget-devel>,
	<mailto:iscsitarget-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:iscsitarget-devel@lists.sourceforge.net>
List-Help: <mailto:iscsitarget-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/iscsitarget-devel>,
	<mailto:iscsitarget-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=iscsitarget-devel>
List-Id: netdev.vger.kernel.org

On Fri, 19 Aug 2005, Andi Kleen wrote:
> > >> the formula for the size that the current e1000 looks for is something
> > >> like
> > >>
> > >> a = MTU roundup to next power of 2
> > >> a += 2 (skb_reserve(NET_IP_ALIGN))
> > >> a += 16 (skb_reserve 16 by __dev_alloc_skb)
> > >>
> > >> so, a = 2048 + 2 + 16, or 2066
> > >> request (a) from slab, which does a power of 2 roundup
> > >> so the skb comes from the 4k (single page) slab for standard mtu.
> > >
> > >That's very suboptimal because you're wasting nearly 2k. It would
> > >be better if you allocated 4k or exactly 2k
> >
> > we have to give the full 2k to hardware, unfortunately.  which means
> > mapping the full 2k.  we do the skb reserve because of cache/alighment
> > effects which show a (big) hit in performance if we don't align the IP
> > header.  Yes I know that dword unaligned DMA really hurts on some arches,
> > but thats why the arch can #def NET_IP_ALIGN 0.
> 
> What is the requirement of your hardware? power of two alignment or
> power of two size?  If the later does it really trash the data behind it?

our pci/pci-x hardware requires the full 2k, (power of 2 size) and it can 
trash the data behind it even in the 1500 MTU case because a frame larger 
than 1518 bytes can be received, and we could fill a whole descriptor and 
overflow into the next. see next paragraph.

> But surely it doesn't use all of the 2k for the 1.5k MTU, so it
> would be good if you could fit the header alignment in there
> and only get the exact needed amount from the underlying allocator.

that would be ideal.  Depending on the memory constraints of the system, 
we could set the RCTL.LPE=0 (long packet enable that forces the hardware 
to drop packets more than 1522 bytes) that would then enable us to 
cheat/optimize for the 1500 MTU case.  I guess then we just call alloc_skb 
directly instead of the dev version.

> > if thats the case, then we're left asking the question, who uses that 16
> > bytes that are skb_reserved by __dev_alloc_skb???
> 
> Nothing, except maybe routing to a different class of link layer that
> needs bigger headers (e.g. PPP).  Even then it's just a performance
> optimization to avoid a skb copy.
> 
> I suppose it would be possible to keep track of the largest supported
> hard_header_len of all devices and if it's all identical don't add the
> 16 bytes.

hmm, all this is pie in the sky until we can get some of this tested. 
Unfortunately those resources are busy here :-(

Jesse




-------------------------------------------------------
SF.Net email is Sponsored by the Better Software Conference & EXPO
September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
Agile & Plan-Driven Development * Managing Projects & Teams * Testing & QA
Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf
