From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [RFC PATCH 3/8] [NET]: uninline dev_alloc_skb, de-bloats a lot
Date: Thu, 21 Feb 2008 00:18:49 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0802202135080.32171@kivilampi-30.cs.helsinki.fi>
References: <1203515238-22848-1-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1203515238-22848-2-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1203515238-22848-3-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1203515238-22848-4-git-send-email-ilpo.jarvinen@helsinki.fi>
 <Pine.LNX.4.64.0802201651580.26109@fbirervta.pbzchgretzou.qr>
 <47BC54FB.2050508@trash.net> <Pine.LNX.4.64.0802201730240.26109@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Arnaldo Carvalho de Melo <acme@redhat.com>
To: Jan Engelhardt <jengelh@computergmbh.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:33257 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754951AbYBTWSw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2008 17:18:52 -0500
In-Reply-To: <Pine.LNX.4.64.0802201730240.26109@fbirervta.pbzchgretzou.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 20 Feb 2008, Jan Engelhardt wrote:

> 
> On Feb 20 2008 17:27, Patrick McHardy wrote:
> >> Striking. How can this even happen? A callsite which calls
> >> 
> >>  dev_alloc_skb(n)
> >> 
> >> is just equivalent to
> >> 
> >>  __dev_alloc_skb(n, GFP_ATOMIC);
> >> 
> >> which means there's like 4 (or 8 if it's long) bytes more on the
> >> stack. For a worst case, count in another 8 bytes for push and pop or mov on
> >> the stack. But that still does not add up to 23 kb.

I think you misunderstood the results, if I uninlined dev_alloc_skb(), it 
_alone_ was uninlined which basically means that __dev_alloc_skb() that is 
inline as well is included inside that uninlined function.

When both were inlined, they add up to everywhere, and uninlining 
dev_alloc_skb alone mitigates that for both(!) of them in every place 
where dev_alloc_skb is being called. Because __dev_alloc_skb call sites 
are few, most benefits show up already with dev_alloc_skb uninlining 
alone. On the other hand, if __dev_alloc_skb is uninlined, the size 
reasoning you used above applies to dev_alloc_skb callsites, and that
is definately less than 23kB.

> > __dev_alloc_skb() is also an inline function which performs
> > some extra work. Which raises the question - if dev_alloc_skb()
> > is uninlined, shouldn't __dev_alloc_skb() be uninline as well?

Of course that could be done as well, however, I wouldn't be too keen to 
deepen callchain by both of them, ie., uninlined dev_alloc_skb would just 
contain few bytes which perform the call to __dev_alloc_skb which has the 
bit larger content due to that "extra work". IMHO the best solution would 
duplicate the "extra work" to both of them on binary level (obviously 
not on the source level), e.g., by adding static inline ___dev_alloc_skb() 
to .h which is inlined to both of the variants. I'm not too sure if inline 
to __dev_alloc_skb() alone is enough in .c file to result in inlining of 
__dev_alloc_skb to dev_alloc_skb (with all gcc versions and relevant 
optimization settings).

> I'd like to see the results when {__dev_alloc_skb is externed
> and dev_alloc_skb remains inlined}.

The results are right under your nose already... ;-)
See from the list of the series introduction:

  http://marc.info/?l=linux-netdev&m=120351526210711&w=2

IMHO more interesting number (which I currently don't have) is the 
_remaining_ benefits of uninlining __dev_alloc_skb after
dev_alloc_skb was first uninlined.


-- 
 i.
