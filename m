From: "David S. Miller" <davem@redhat.com>
Subject: Re: Tigon3 5701 PCI-X recv performance problem
Date: Wed, 8 Oct 2003 13:50:30 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031008135030.3dad33f9.davem@redhat.com>
References: <3F844578.40306@sgi.com>
	<20031008101046.376abc3b.davem@redhat.com>
	<3F8455BE.8080300@sgi.com>
	<20031008183742.GA24822@wotan.suse.de>
	<20031008122223.1ba5ac79.davem@redhat.com>
	<20031008202248.GA15611@oldwotan.suse.de>
	<20031008132402.64984528.davem@redhat.com>
	<20031008203306.GB15611@oldwotan.suse.de>
	<20031008133248.1583ddcf.davem@redhat.com>
	<20031008204618.GC15611@oldwotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, modica@sgi.com, johnip@sgi.com, netdev@oss.sgi.com,
        jgarzik@pobox.com, jes@sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20031008204618.GC15611@oldwotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 8 Oct 2003 22:46:18 +0200
Andi Kleen <ak@suse.de> wrote:

> On Wed, Oct 08, 2003 at 01:32:48PM -0700, David S. Miller wrote:
> > The page chunk allocator is meant to make it easier to put the
> > non-header parts in the frag list of the SKB, see?  It means we
> > don't need to do anything special in the networking, all the
> > receive paths handle frag'd RX packets properly.
> 
> Sure, but to handle the sub allocation you need a destructor per fragment.
> (otherwise how do you want to share a page between different packets)

Aha, no you don't, this is the beauty of it.

Let's say we've packed 4 packets into a page (or 10 in 2 pages,
whatever the optimal packing is), as you attach each chunk to a SKB
you up the page count (if the buffer straddles 2 or more pages you use
one frag entry for each of those pages and bump the count as
approprise).  As far as the networking is concerned, it's some page
cache page or whatever, it doesn't care.

Then kfree_skb(skb) just does the right thing by putting all the
pages, when the page count goes to zero it's free'd up.

> BTW I think this all should be also ifdefed with CONFIG_SLOW_UNALIGNMENT.
> I certainly don't want any of this on x86-64 where unalignment cost
> one cycle only.

I agree, I don't even want this rediculious crap on sparc64 where
I can make the unaligned trap handler 30 or 40 cycles or even less.

BTW, your highmem example is interesting, but even more interesting are
the cards that do the magic multiple-TCP-packet coalescing so that the
data parts are all page aligned.  They want infrastructure like this.
