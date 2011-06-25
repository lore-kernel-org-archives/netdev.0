From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: SKB paged fragment lifecycle on receive
Date: Sat, 25 Jun 2011 12:58:41 +0100
Message-ID: <1309003121.5807.20.camel@dagon.hellion.org.uk>
References: <4E04C961.9010302@goop.org>
	 <1308938183.2532.8.camel@edumazet-laptop>	<4E04D59B.8060301@goop.org>
	 <20110624.124624.1329947216240823992.davem@davemloft.net>
	 <4E04EF8F.6070900@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, xen-devel@lists.xensource.com,
	rusty@rustcorp.com.au
To: Jeremy Fitzhardinge <jeremy@goop.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([62.200.22.115]:48728 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751100Ab1FYL6o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jun 2011 07:58:44 -0400
In-Reply-To: <4E04EF8F.6070900@goop.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-06-24 at 13:11 -0700, Jeremy Fitzhardinge wrote:
> On 06/24/2011 12:46 PM, David Miller wrote:
> > Pages get transferred between different SKBs all the time.
> >
> > For example, GRO makes extensive use of this technique.
> > See net/core/skbuff.c:skb_gro_receive().
> >
> > It is just one example.
> 
> I see, and the new skb doesn't get a destructor copied from the
> original, so there'd be no second callback.

What about if we were to have a per-shinfo destructor (called once for
each page as its refcount goes 1->0, from whichever skb ends up with the
last ref) as well as the skb-destructors. This already handles the
cloning case but when pages are moved between shinfo then would it make
sense for that to be propagated between skb's under these circumstances
and/or require them to be the same? Since in the case of something like
skb_gro_receive the skbs (and hence the frag array pages) are all from
the same 'owner' (even if the skb is actually created by the stack on
their behalf) I suspect this could work?

But I bet this assumption isn't valid in all cases.

In which case I end up wondering about a destructor per page in the frag
array. At which point we might as well consider it as a part of the core
mm stuff rather than something net specific?

Ian.

