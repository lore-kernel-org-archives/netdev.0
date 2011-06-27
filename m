From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: Re: SKB paged fragment lifecycle on receive
Date: Mon, 27 Jun 2011 21:51:53 +0100
Message-ID: <4E08ED69.3010709@goop.org>
References: <4E04C961.9010302@goop.org>	
	<1308938183.2532.8.camel@edumazet-laptop>	<4E04D59B.8060301@goop.org>	
	<20110624.124624.1329947216240823992.davem@davemloft.net>	
	<4E04EF8F.6070900@goop.org>
	<1309003121.5807.20.camel@dagon.hellion.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rusty@rustcorp.com.au,
	xen-devel@lists.xensource.com,
	David Miller <davem@davemloft.net>, eric.dumazet@gmail.com
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <xen-devel-bounces@lists.xensource.com>
In-Reply-To: <1309003121.5807.20.camel@dagon.hellion.org.uk>
List-Unsubscribe: <http://lists.xensource.com/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xensource.com>
List-Help: <mailto:xen-devel-request@lists.xensource.com?subject=help>
List-Subscribe: <http://lists.xensource.com/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=subscribe>
Sender: xen-devel-bounces@lists.xensource.com
Errors-To: xen-devel-bounces@lists.xensource.com
List-Id: netdev.vger.kernel.org

On 06/25/2011 12:58 PM, Ian Campbell wrote:
> On Fri, 2011-06-24 at 13:11 -0700, Jeremy Fitzhardinge wrote:
>> On 06/24/2011 12:46 PM, David Miller wrote:
>>> Pages get transferred between different SKBs all the time.
>>>
>>> For example, GRO makes extensive use of this technique.
>>> See net/core/skbuff.c:skb_gro_receive().
>>>
>>> It is just one example.
>> I see, and the new skb doesn't get a destructor copied from the
>> original, so there'd be no second callback.
> What about if we were to have a per-shinfo destructor (called once for
> each page as its refcount goes 1->0, from whichever skb ends up with the
> last ref) as well as the skb-destructors.

We never want the refcount for granted pages to go from 1 -> 0.  The
safest thing is to make sure we always elevate the refcount to make sure
that nothing else can ever drop the last ref.

If we can trust the network stack to always do the last release (and not
hand it off to something else to do it), then we could have a destructor
which gets called before the last ref drop (or leaves the ref drop to
the destructor to do), and do everything required that way.  But it
seems pretty fragile.  At the very least it would need a thorough code
audit to make sure that everything handles page lifetimes in the
expected way - but then I'd still worry about out-of-tree patches
breaking something in subtle ways.

>  This already handles the
> cloning case but when pages are moved between shinfo then would it make
> sense for that to be propagated between skb's under these circumstances
> and/or require them to be the same? Since in the case of something like
> skb_gro_receive the skbs (and hence the frag array pages) are all from
> the same 'owner' (even if the skb is actually created by the stack on
> their behalf) I suspect this could work?
>
> But I bet this assumption isn't valid in all cases.

Hm.

> In which case I end up wondering about a destructor per page in the frag
> array. At which point we might as well consider it as a part of the core
> mm stuff rather than something net specific?

Doing it generically still needs some kind of marker that the page has a
special-case destructor (and the destructor pointer itself).

    J
