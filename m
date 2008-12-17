From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH] tcp: make urg+gso work for real this time
Date: Wed, 17 Dec 2008 10:42:05 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0812171033250.9494@wrl-59.cs.helsinki.fi>
References: <E1LCl3n-00052k-6h@gondolin.me.apana.org.au>
 <1229501899.13305.12.camel@nathan.suse.cz>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-751646983-1229503325=:9494"
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Petr Tesarik <ptesarik@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:49110 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751249AbYLQImJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 03:42:09 -0500
In-Reply-To: <1229501899.13305.12.camel@nathan.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-751646983-1229503325=:9494
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Wed, 17 Dec 2008, Petr Tesarik wrote:

> Herbert Xu píse v St 17. 12. 2008 v 12:18 +1100:
> > Ilpo J??rvinen <ilpo.jarvinen@helsinki.fi> wrote:
> > > 
> > > I should have noticed this earlier... :-) The previous solution
> > > to URG+GSO/TSO will cause SACK block tcp_fragment to do zig-zig
> > > patterns, or even worse, a steep downward slope into packet
> > > counting because each skb pcount would be truncated to pcount
> > > of 2 and then the following fragments of the later portion would
> > > restore the window again.
> > 
> > How about just handling it, URG isn't that hard.  If anyone is
> > bored you can do this for GRO as well.
> > 
> > tcp: Add GSO support for urgent data
> > 
> > When segmenting packets with urgent data we need to clear the
> > urgent flag/pointer once we move past the end of the urgent data.
> > This was not handled correctly in GSO or (presumably) in existing
> > hardware.
> > 
> > This patch adds a new GSO flag for TCP urgent data and also fixes
> > its handling in GSO.
> 
> This would work, but:
> 
>   1. Currently this code path will never get run, because large
>      offloads are avoided both for hardware TSO and software GSO.
>      You'd also have to modify the conditionals that guard calls
>      to tcp_mss_split_point().
> 
>   2. Is it worth the trouble?
>      This slows down the software GSO slightly. I mean, urgent
>      data should be quite rare, so it makes sense to treat
>      non-urgent data as "fast path" and urgent data as "slow
>      path". While Ilpo's approach only slows down the slow path,
>      your patch slows down both.

My intention is to make it slightly more fine-grained on tcp side still, 
so that affected portion only includes those segments that really reside 
within 64k from the urg seq and rest will be unaffected.

>      No, I don't have any numbers, no. ;)

To put this in contrast (an example for elsewhere)... Once we got any
SACK blocks, we were doing tcp_fragment for almost every incoming segment, 
in practice for the whole window (I made it a lot better in net-next
though still some tcp_fragment()s will be needed), and that send-used 
fragment calls for tso_fragment which is less heavy-weight than sack-used 
tcp_fragment.

> Anyway, we have to keep the code that avoids large offloads with URG,
> because many NICs are broken in this regard (at least all Intel NICs
> I've seen so far), so why treat software GSO specially?

All TSO implementation will be subject to the other problem I mentioned in 
my response to Herbert. There just isn't enough bits for them to do 
things right w.r.t. 64k-before point.

-- 
 i.
---696208474-751646983-1229503325=:9494--
