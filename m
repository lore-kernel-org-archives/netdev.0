From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: using software TSO on non-TSO capable netdevices
Date: Thu, 31 Jul 2008 10:34:13 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0807311010250.4551@wrl-59.cs.helsinki.fi>
References: <20080730235004.GC21999@xi.wantstofly.org>
 <20080730.165621.211366535.davem@davemloft.net> <20080731004123.GB22826@xi.wantstofly.org>
 <20080730.181047.39922732.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: buytenh@wantstofly.org, Netdev <netdev@vger.kernel.org>,
	akarkare@marvell.com, nico@cam.org,
	Herbert Xu <herbert@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:45795 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753292AbYGaHeQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2008 03:34:16 -0400
In-Reply-To: <20080730.181047.39922732.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 30 Jul 2008, David Miller wrote:

> From: Lennert Buytenhek <buytenh@wantstofly.org>
> Date: Thu, 31 Jul 2008 02:41:23 +0200
> 
> > The hacky patch below (on top of 2.6.27-rc1 + stubbing out the
> > sk_can_gso() check) reduces the 1 GiB 1000 Mb/s sendfile test from:
>  ...
> > I.e. dramatic CPU time improvements, and some overall speedup as well.
> > 
> > I wonder if something like this can be done in a less hacky fashion --
> > the hard part I guess is deciding when to keep coalescing (to reduce
> > CPU overhead) vs. when to push out what has been coalesced so far (in
> > order to keep the pipe filled), and I'm not sure I have good ideas
> > about how to make that decision.
> 
> Interesting, I'll take a closer look at this.
> 
> Actually your patch is less of a surprise, because one of the issues I
> had to surmount constantly when rewriting the TSO output path was the
> implicit conflict between TSO deferral (to accumulate segments) and
> the nagle logic.

I think your statement makes very little sense to me (though I had to 
lookup the meaning of surmount but that seems not so significant 
anyway)... They both work into the same direction, ie., to delay sending 
to prevent excessive processing of small bits, but the region of operation 
shouldn't overlap (nagle works with <mss, and tso deferring logic 
basically begins from where the nagle ends)?

It seems to me that this not about conflict between TSO deferring and 
nagle sub-mss logic at all (perhaps there wasn't as direct relation to 
this issue as I read...?) AFAICT, the change only makes (!nonagle && 
tp->packets_out && tcp_minshall_check(tp)) test in tcp_nagle_check more 
likely to occur (and result in false), ie., basically we end up using 
nagle test also to prevent sending of >= mss skbs, besides the usual 
functionality which is to prevent sending in case of < mss sized ones. 
...Which seems just an extension to what we checked for in 
tcp_tso_should_defer().

So it guess that the results just show that there's benefit in deferring 
even more than we do currently.


-- 
 i.
