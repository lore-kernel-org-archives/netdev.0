From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: tbench wrt. loopback TSO
Date: Wed, 5 Nov 2008 14:25:57 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0811051414250.23792@wrl-59.cs.helsinki.fi>
References: <20081105114900.GA18691@ioremap.net> <20081105.035454.87914782.davem@davemloft.net>
 <Pine.LNX.4.64.0811051355550.23792@wrl-59.cs.helsinki.fi>
 <20081105.040943.03609283.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-970381972-1225887957=:23792"
Cc: zbr@ioremap.net, Netdev <netdev@vger.kernel.org>, efault@gmx.de,
	mingo@elte.hu, a.p.zijlstra@chello.nl,
	Herbert Xu <herbert@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:35732 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753867AbYKEMZ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2008 07:25:58 -0500
In-Reply-To: <20081105.040943.03609283.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-970381972-1225887957=:23792
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Wed, 5 Nov 2008, David Miller wrote:

> From: "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Wed, 5 Nov 2008 14:04:14 +0200 (EET)
> 
> > On Wed, 5 Nov 2008, David Miller wrote:
> > 
> > > From: Evgeniy Polyakov <zbr@ioremap.net>
> > > Date: Wed, 5 Nov 2008 14:49:00 +0300
> > > 
> > > > But what if we just remove that trimming at all? This may result in
> > > > a not fully filled tso frame, but who cares if we copy data from
> > > > userspace anyway, will add another potentially small copy at sending
> > > > time?
> > > 
> > > Ok, the only part I care about is whether taking away this modulus
> > > will result in a sub-MSS sized packet on the wire, which is
> > > undesirable.
> > >
> > > The send logic will prevent this, right?
> > 
> > I don't see what currently would do that. We'd need to resegment skbs 
> > there then...
> 
> Look at tcp_mss_split_point() in tcp_output.c
> 
> I think it ends up doing exactly this.
> 
> 'needed' is set to min(skb->len, window)
> 
> and the return value is "needed - (needed % mss_now)"
> 
> The caller splits up the TSO segment as needed to satisfy this
> returned limit.
> 
> That should effectively chop off the sub-mss part.

Yes yes, I know as I wrote that part :-). But how does it prevent sub-MSS 
on wire?

Answer: It is intented for different case and doesn't prevent sub-MSS 
segments but solves some window limitation issues! It just makes sure
we won't add yet another sub-mss segment because of splitting we anyway 
are forced to.

In case of curr_mss != write_time_mss, we'll be sending those < mss 
segments per each skb, normally this happens over a single rtt so it's not 
that bad problem (and btw, that modulo won't even be executed if you have 
enough window but the splitting happens on a layer below, except for the 
last segment of course where we'd do nagle).

The problem is that we'd need to _resegment with the next skb_ since the 
mss boundary and skb boundary would basically constantly be running 
out-of-sync. That won't get done currently by anything.


-- 
 i.
---696208474-970381972-1225887957=:23792--
