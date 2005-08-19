From: Ming Zhang <mingz@ele.uri.edu>
Subject: Re: [E1000-devel] Page Allocation Failure with e1000 using
 jumboframe
Date: Fri, 19 Aug 2005 15:07:09 -0400
Message-ID: <1124478429.5552.39.camel@localhost.localdomain>
References: <1124326404.5546.215.camel@localhost.localdomain>
	 <Pine.WNT.4.63.0508190940210.3796@jbrandeb-desk.amr.corp.intel.com>
	 <1124470909.5552.11.camel@localhost.localdomain>
	 <Pine.WNT.4.63.0508191023130.3796@jbrandeb-desk.amr.corp.intel.com>
	 <20050819174201.GJ3953@verdi.suse.de>
	 <Pine.WNT.4.63.0508191043440.3796@jbrandeb-desk.amr.corp.intel.com>
	 <20050819180132.GO22993@wotan.suse.de>
Reply-To: mingz@ele.uri.edu
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
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

I am sorry that the guy who found this problem is running suse linux,
but with vanilla kernel. so this is a generic problem, not suse
specific.

I am sorry for my insaneness at that time. :P

Ming


On Fri, 2005-08-19 at 20:01 +0200, Andi Kleen wrote:
> > I could certainly be mistaken.  The difference I saw was that suse kernels 
> > recycle the same skb pointers back to our driver, and the redhat kernels 
> > seem to march through a much larger range before the values repeat.  This 
> > is all observation based, so I may be completely wrong on this issue.
> 
> Maybe you're comparing 2.4 to 2.6 or different 2.6s. But I don't 
> think there are any SUSE specific patches affecting this.
> 
> > 
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
> 
> But surely it doesn't use all of the 2k for the 1.5k MTU, so it
> would be good if you could fit the header alignment in there
> and only get the exact needed amount from the underlying allocator.
> 
> 
> > 
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
> 
> -Andi



-------------------------------------------------------
SF.Net email is Sponsored by the Better Software Conference & EXPO
September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
Agile & Plan-Driven Development * Managing Projects & Teams * Testing & QA
Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf
