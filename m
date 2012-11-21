From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH V2] xen/netfront: handle compound page fragments on
 transmit
Date: Wed, 21 Nov 2012 12:08:47 +0000
Message-ID: <1353499727.13542.137.camel@zakaz.uk.xensource.com>
References: <1353427257-16789-1-git-send-email-ian.campbell@citrix.com>
	 <1353428844.2590.17.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	Eric Dumazet <edumazet@google.com>,
	Konrad Rzeszutek Wilk <konrad@kernel.org>,
	ANNIE LI <annie.li@oracle.com>,
	Sander Eikelenboom <linux@eikelenboom.it>,
	"Stefan Bader" <stefan.bader@canonical.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([46.33.159.39]:45121 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754587Ab2KUMIu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2012 07:08:50 -0500
In-Reply-To: <1353428844.2590.17.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-11-20 at 16:27 +0000, Eric Dumazet wrote:
> On Tue, 2012-11-20 at 16:00 +0000, Ian Campbell wrote:
> > An SKB paged fragment can consist of a compound page with order > 0.
> > However the netchannel protocol deals only in PAGE_SIZE frames.
> > 
> > Handle this in xennet_make_frags by iterating over the frames which
> > make up the page.
> > 
> > This is the netfront equivalent to 6a8ed462f16b for netback.
> ...
> 
> > -	frags += DIV_ROUND_UP(offset + len, PAGE_SIZE);
> > -	if (unlikely(frags > MAX_SKB_FRAGS + 1)) {
> > -		printk(KERN_ALERT "xennet: skb rides the rocket: %d frags\n",
> > -		       frags);
> > -		dump_stack();
> > +	slots = DIV_ROUND_UP(offset + len, PAGE_SIZE) +
> > +		xennet_count_skb_frag_slots(skb);
> > +	if (unlikely(slots > MAX_SKB_FRAGS + 1)) {
> > +		printk(KERN_ALERT "xennet: skb rides the rocket: %d slots\n",
> > +		       slots);
> 
> I think this is wrong.
> 
> You should change netfront_tx_slot_available() to stop the queue before
> this can happen.
>
> Yes, you dont hit this on your tests, but a driver should not drop a
> good packet.

The max-frag related limitation comes from the "wire" protocol used
between front and back. As it stands either the frontend or the backend
is more than likely going to drop the sort of pathalogical skbs you are
worried.

I agree that this absolutely needs to be fixed in the protocol (and I've
posted a call to arms on this topic on xen-devel) but I'd like to do it
in a coordinated manner as part of a protocol extension (where the front
and backend negotiate the maximum number of order-0 pages per Ethernet
frame they are willing to handle) rather than as a side effect of this
patch.

So right now I don't want to introduce frontends which default to
sending increased numbers of pages in to the wild, since that makes
things more complex when we come to extend the protocol.

Perhaps in the short term doing an skb_linearize when we hit this case
would help, that will turn the pathalogical skb into a much more normal
one. It'll be expensive but it should be rare. That assumes you can
linearize such a large skb, which depends on the ability to allocate
large order pages which isn't a given. Herm, maybe that doesn't work
then.

AFAIK we don't have an existing skb_foo operation which copies an skb,
including (or only) the frags, with the side effect of aligning and
coalescing them. Do we?

Ian.
