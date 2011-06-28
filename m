From: Ian Campbell <Ian.Campbell@eu.citrix.com>
Subject: Re: SKB paged fragment lifecycle on receive
Date: Tue, 28 Jun 2011 11:25:15 +0100
Message-ID: <1309256715.32717.312.camel@zakaz.uk.xensource.com>
References: <4E04C961.9010302@goop.org>
	<1308938183.2532.8.camel@edumazet-laptop>	<4E04D59B.8060301@goop.org>
	<20110624.124624.1329947216240823992.davem@davemloft.net>
	<4E04EF8F.6070900@goop.org>
	<1309003121.5807.20.camel@dagon.hellion.org.uk>
	<4E08ED69.3010709@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"rusty@rustcorp.com.au" <rusty@rustcorp.com.au>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	David Miller <davem@davemloft.net>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>
To: Jeremy Fitzhardinge <jeremy@goop.org>
Return-path: <xen-devel-bounces@lists.xensource.com>
In-Reply-To: <4E08ED69.3010709@goop.org>
List-Unsubscribe: <http://lists.xensource.com/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xensource.com>
List-Help: <mailto:xen-devel-request@lists.xensource.com?subject=help>
List-Subscribe: <http://lists.xensource.com/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=subscribe>
Sender: xen-devel-bounces@lists.xensource.com
Errors-To: xen-devel-bounces@lists.xensource.com
List-Id: netdev.vger.kernel.org

On Mon, 2011-06-27 at 21:51 +0100, Jeremy Fitzhardinge wrote:
> On 06/25/2011 12:58 PM, Ian Campbell wrote:
> > On Fri, 2011-06-24 at 13:11 -0700, Jeremy Fitzhardinge wrote:
> >> On 06/24/2011 12:46 PM, David Miller wrote:
> >>> Pages get transferred between different SKBs all the time.
> >>>
> >>> For example, GRO makes extensive use of this technique.
> >>> See net/core/skbuff.c:skb_gro_receive().
> >>>
> >>> It is just one example.
> >> I see, and the new skb doesn't get a destructor copied from the
> >> original, so there'd be no second callback.
> > What about if we were to have a per-shinfo destructor (called once for
> > each page as its refcount goes 1->0, from whichever skb ends up with the
> > last ref) as well as the skb-destructors.
> 
> We never want the refcount for granted pages to go from 1 -> 0.  The
> safest thing is to make sure we always elevate the refcount to make sure
> that nothing else can ever drop the last ref.

I guess I meant called just after the refcount goes 2->1 or something.
_But_... thinking about it some more I don't think this scheme works in
the general case because the entity injecting into the network stack may
not be the only reference count holder.

Consider the NFS case -- in that case there is already a reference
because the page belongs to userspace. You certainly don't want to wait
for the process to exit before considering the page done with.

You may also have multiple reference counts due to multiple threads
doing I/O on (overlapping or not) portions of the same page etc.

So now we're into the realms of a shinfo per frag reference count and
destructor, which reintroduces the whole question of what happens if a
page is copied/moved to another shinfo.

Could we add a per-frag pointer to the shinfo pointing to:
	struct {
		atomic_t ref;
		void (destructor*)(struct skb, int fragnr, /*TBD*/);
		void *data; /* user data, maybe */
	};
This data structure is owned by whoever injected the page into the stack
and the pointer to it is propagated everywhere that page goes, including
across skb splits and pages moving or copied between skbs etc etc.

The split between ref counting on this and struct page needs a bit of
careful thought but perhaps it's IFF this struct exists the stack will
hold a single struct page refcount and use this new refcount for
everything else, dropping the struct page refcount when the frag
refcount hits 0. Otherwise it simply uses struct page refcount as
normal.

> If we can trust the network stack to always do the last release (and not
> hand it off to something else to do it), then we could have a destructor
> which gets called before the last ref drop (or leaves the ref drop to
> the destructor to do), and do everything required that way.  But it
> seems pretty fragile.  At the very least it would need a thorough code
> audit to make sure that everything handles page lifetimes in the
> expected way - but then I'd still worry about out-of-tree patches
> breaking something in subtle ways.
> 
> >  This already handles the
> > cloning case but when pages are moved between shinfo then would it make
> > sense for that to be propagated between skb's under these circumstances
> > and/or require them to be the same? Since in the case of something like
> > skb_gro_receive the skbs (and hence the frag array pages) are all from
> > the same 'owner' (even if the skb is actually created by the stack on
> > their behalf) I suspect this could work?
> >
> > But I bet this assumption isn't valid in all cases.
> 
> Hm.

e.g. if you have some sort of tunnel protocol which is encapsulating
multiple skb streams into a single one might you get an skb with pages
from multiple sources?

> > In which case I end up wondering about a destructor per page in the frag
> > array. At which point we might as well consider it as a part of the core
> > mm stuff rather than something net specific?
> 
> Doing it generically still needs some kind of marker that the page has a
> special-case destructor (and the destructor pointer itself).

True. you only really need the destructor pointer (which can be NULL)
but yes, it would add stuff to struct page which may not be useful
elsewhere.

Ian.
