From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: using software TSO on non-TSO capable netdevices
Date: Thu, 31 Jul 2008 13:27:14 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0807311318120.4551@wrl-59.cs.helsinki.fi>
References: <20080730235004.GC21999@xi.wantstofly.org>
 <20080730.165621.211366535.davem@davemloft.net> <20080731004123.GB22826@xi.wantstofly.org>
 <20080730.181047.39922732.davem@davemloft.net>
 <Pine.LNX.4.64.0807311010250.4551@wrl-59.cs.helsinki.fi>
 <20080731095050.GD23814@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696208474-830321461-1217499777=:4551"
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, akarkare@marvell.com,
	nico@cam.org, Herbert Xu <herbert@gondor.apana.org.au>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:47903 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751934AbYGaK1Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2008 06:27:16 -0400
In-Reply-To: <20080731095050.GD23814@xi.wantstofly.org>
Content-ID: <Pine.LNX.4.64.0807311323270.4551@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-830321461-1217499777=:4551
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0807311323271.4551@wrl-59.cs.helsinki.fi>

On Thu, 31 Jul 2008, Lennert Buytenhek wrote:

> On Thu, Jul 31, 2008 at 10:34:13AM +0300, Ilpo Järvinen wrote:
> 
> > > > The hacky patch below (on top of 2.6.27-rc1 + stubbing out the
> > > > sk_can_gso() check) reduces the 1 GiB 1000 Mb/s sendfile test from:
> > >  ...
> > > > I.e. dramatic CPU time improvements, and some overall speedup as well.
> > > > 
> > > > I wonder if something like this can be done in a less hacky fashion --
> > > > the hard part I guess is deciding when to keep coalescing (to reduce
> > > > CPU overhead) vs. when to push out what has been coalesced so far (in
> > > > order to keep the pipe filled), and I'm not sure I have good ideas
> > > > about how to make that decision.
> > > 
> > > Interesting, I'll take a closer look at this.
> > > 
> > > Actually your patch is less of a surprise, because one of the issues I
> > > had to surmount constantly when rewriting the TSO output path was the
> > > implicit conflict between TSO deferral (to accumulate segments) and
> > > the nagle logic.
> > 
> > I think your statement makes very little sense to me (though I had to 
> > lookup the meaning of surmount but that seems not so significant 
> > anyway)... They both work into the same direction, ie., to delay sending 
> > to prevent excessive processing of small bits, but the region of operation 
> > shouldn't overlap (nagle works with <mss, and tso deferring logic 
> > basically begins from where the nagle ends)?
> > 
> > It seems to me that this not about conflict between TSO deferring and 
> > nagle sub-mss logic at all (perhaps there wasn't as direct relation to 
> > this issue as I read...?) AFAICT, the change only makes (!nonagle && 
> > tp->packets_out && tcp_minshall_check(tp)) test in tcp_nagle_check more 
> > likely to occur (and result in false), ie., basically we end up using 
> > nagle test also to prevent sending of >= mss skbs, besides the usual 
> > functionality which is to prevent sending in case of < mss sized ones. 
> > ...Which seems just an extension to what we checked for in 
> > tcp_tso_should_defer().
> 
> I wanted a way to get larger GSO segments, and the idea was to rig
> the nagle check to consider sub-N*mss frames as small frames and not
> let more than one of them into the pipe at any given time.  I don't
> know whether the change I made accomplishes exactly that, but it did
> end up giving me larger GSO segments, which was the goal.
>
> It makes the GSO segment size distribution pretty chaotic, though:

Your test accomplishes that only if there's a small segment in the 
outstanding window, ie., snd_sml points to outs. win (or packets_out is 
zero but that's probably not relevant).

Why not experimenting with modifying tcp_tso_should_defer instead to make 
it fully independent of snd_sml (existance of a sub mss skb in-flight), 
just make sure you don't try to defer past what min(tp->snd_cwnd, 
tcp_wnd_end(tp)) can give you at most (in theory you could apply some 
optimism and go even above in a slow start but that's not going to be very 
robust approach :-)).


-- 
 i.
---696208474-830321461-1217499777=:4551--
