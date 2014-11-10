From: Seth Forshee <seth.forshee@canonical.com>
Subject: Re: BUG in xennet_make_frags with paged skb data
Date: Mon, 10 Nov 2014 08:35:17 -0600
Message-ID: <20141110143517.GA74005@ubuntu-hedt>
References: <20141106214940.GD44162@ubuntu-hedt>
 <545CA27F.4070400@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	Stefan Bader <stefan.bader@canonical.com>,
	Jay Vosburgh <jay.vosburgh@canonical.com>,
	linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org,
	seth.forshee@canonical.com
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <545CA27F.4070400@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 07, 2014 at 10:44:15AM +0000, David Vrabel wrote:
> On 06/11/14 21:49, Seth Forshee wrote:
> > We've had several reports of hitting the following BUG_ON in
> > xennet_make_frags with 3.2 and 3.13 kernels (I'm currently awaiting
> > results of testing with 3.17):
> > 
> >         /* Grant backend access to each skb fragment page. */
> >         for (i = 0; i < frags; i++) {
> >                 skb_frag_t *frag = skb_shinfo(skb)->frags + i;
> >                 struct page *page = skb_frag_page(frag);
> > 
> >                 len = skb_frag_size(frag);
> >                 offset = frag->page_offset;
> > 
> >                 /* Data must not cross a page boundary. */
> >                 BUG_ON(len + offset > PAGE_SIZE<<compound_order(page));
> > 
> > When this happens the page in question is a "middle" page in a compound
> > page (i.e. it's a tail page but not the last tail page), and the data is
> > fully contained within the compound page. The data does however cross
> > the hardware page boundary, and since compound_order evaluates to 0 for
> > tail pages the check fails.
> > 
> > In going over this I've been unable to determine whether the BUG_ON in
> > xennet_make_frags is incorrect or the paged skb data is wrong. I can't
> > find that it's documented anywhere, and the networking code itself is a
> > bit ambiguous when it comes to compound pages. On the one hand
> > __skb_fill_page_desc specifically handles adding tail pages as paged
> > data, but on the other hand skb_copy_bits kmaps frag->page.p which could
> > fail with data that extends into another page.
> 
> netfront will safely handle this case so you can remove this BUG_ON()
> (and the one later on).  But it would be better to find out were these
> funny-looking skbs are coming from and (if necessary) fixing the bug there.

There still seems to be disagreement about whether the "funny" skb is
valid though - you imply it isn't, but Eric says it is. I've been trying
to track down where these skbs originate, and so far I've determined
that they come from a socket spliced to a pipe spliced to a socket. It
looks like the particular page/offset/len tuple originates at least as
far back as the first socket, as the tuple is simply copied from an skb
into the pipe and from the pipe into the final skb.

Anyway, it looks like at minimum it should be safe to change the first
BUG_ON to assert that the data is fully within the compound page as
Stefan suggested, then remove the second BUG_ON entirely. This is the
path I plan to pursue unless someone objects.

Thanks,
Seth
