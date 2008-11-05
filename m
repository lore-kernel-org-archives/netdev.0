From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: tbench wrt. loopback TSO
Date: Wed, 5 Nov 2008 21:46:03 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0811052108250.9159@wrl-59.cs.helsinki.fi>
References: <20081105114900.GA18691@ioremap.net> <20081105.035454.87914782.davem@davemloft.net>
 <Pine.LNX.4.64.0811051355550.23792@wrl-59.cs.helsinki.fi>
 <20081105.040943.03609283.davem@davemloft.net>
 <Pine.LNX.4.64.0811051414250.23792@wrl-59.cs.helsinki.fi>
 <20081105130405.GA26435@ioremap.net> <Pine.LNX.4.64.0811051527210.23792@wrl-59.cs.helsinki.fi>
 <4911EA97.8080101@hp.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-427629296-1225914363=:9159"
Cc: Evgeniy Polyakov <zbr@ioremap.net>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, efault@gmx.de, mingo@elte.hu,
	a.p.zijlstra@chello.nl, Herbert Xu <herbert@gondor.apana.org.au>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:42407 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753546AbYKETqH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2008 14:46:07 -0500
In-Reply-To: <4911EA97.8080101@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-427629296-1225914363=:9159
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Wed, 5 Nov 2008, Rick Jones wrote:

> Ilpo Järvinen wrote:
> > On Wed, 5 Nov 2008, Evgeniy Polyakov wrote:
> > 
> > 
> > >On Wed, Nov 05, 2008 at 02:25:57PM +0200, Ilpo Järvinen
> > >(ilpo.jarvinen@helsinki.fi) wrote:
> > >
> > > >The problem is that we'd need to _resegment with the next skb_ since the
> > > >mss boundary and skb boundary would basically constantly be running
> > > >out-of-sync. That won't get done currently by anything.
> > >
> > >Btw, what's that wrong if there will be sub-mss frame per tso frame?
> > 
> > 
> > I personally don't consider that to be a big deal... I suppose some see
> > it as bad thing because of the slightly larger header vs data ratio...
> > Which is significant only if you can saturate the link (or have unbounded
> > bandwidth such as with lo), so slower links are more affected than high
> > speed ones...
> 
> Can't say that I tend to "like" subMSS segments out there in a bulk 
> transfer but some pseudorandom thoughts:
> 
> And the worst that would be would be one full MSS and a single byte, getting
> us an average of (MSS+1)/2 (roughly).  It only gets better from there
> (2MSS+1)/3, (3MSS+1)/4 etc etc.

...Note that likelyhood of such 1 byte pathological case are not that high 
if one is sending pages... For malicious purposes one could always use 
TCP_NODELAY anyway to force similar small segments so it's hardly worth 
considering here.

For the most sensible cases with full pages, resulting segs are (1460,1448 
mss):

1 2.80548 2.82873
2 5.61096 5.65746
3 8.41644 8.48619
4 11.2219 11.3149
5 14.0274 14.1436
6 16.8329 16.9724
7 19.6384 19.8011
8 22.4438 22.6298
9 25.2493 25.4586
10 28.0548 28.2873
11 30.8603 31.116
12 33.6658 33.9448
13 36.4712 36.7735
14 39.2767 39.6022
15 42.0822 42.4309
16 44.8877 45.2597

The worst case seems to be 5 pages with 1460 which yields to 40 bytes 
payload.

> Ignoring the TSO case for a moment, if there is congestion and receiver 
> window available and a user makes a > MSS send that isn't an integral 
> multiple of the MSS, we don't delay the last subMSS segment do we?

Without TSO, only Nagle could prevent sending that submss portion, so the 
answer depends on what the window in-flight consists of.

With TSO, I guess this falls under tcp_tso_should_defer first...

And then, as far as the mss-splitter (that was quoted in this thread by 
DaveM) we send just the full segment if there's enough room in the 
receiver window and let the tso/gso handle splitting of that submss 
segment if necessary... ...Except for that last segment which is important 
for keeping track of nagle and we currently don't handle nagle correctly 
if the segment in question would have len > mss (as noted earlier this 
could be changed though after auditting those len < mss checks). So it 
will basically be the same as without tso (depends on in-flight win).

We _won't do_ nagle for the intermediate submss segments (it is a design 
decision which predates times I've been tracking kernel development), for 
obvious reasons it could just be enabled for them currently because then 
nagle would basically stall the transfer eg. when opposite dir needs to 
change mss due to reporting sack blocks. In general those middle submss 
skbs only occur if mss changes as they're split currently based on mss 
already at write time.


-- 
 i.
---696208474-427629296-1225914363=:9159--
