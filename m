From: Michael =?UTF-8?B?QsO8c2No?= <m@bues.ch>
Subject: Re: [Bugme-new] [Bug 38102] New: BUG kmalloc-2048: Poison
 overwritten
Date: Wed, 6 Jul 2011 18:12:58 +0200
Message-ID: <20110706181258.57b3c112@maggie>
References: <1309882352.2271.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<20110705164202.GD2959@hmsreliant.think-freely.org>
	<1309884441.2271.34.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<20110705180650.GF2959@hmsreliant.think-freely.org>
	<1309889634.2545.2.camel@edumazet-laptop>
	<1309890775.2545.17.camel@edumazet-laptop>
	<1309891516.2545.23.camel@edumazet-laptop>
	<20110705195353.GG2959@hmsreliant.think-freely.org>
	<1309896147.2545.28.camel@edumazet-laptop>
	<1309896940.2545.34.camel@edumazet-laptop>
	<20110705220644.GB12118@hmsreliant.think-freely.org>
	<20110706173243.404d8599@maggie>
	<1309968019.2292.44.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Alexey Zaytsev <alexey.zaytsev@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, Gary Zambrano <zambrano@broadcom.com>,
	bugme-daemon@bugzilla.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Pekka Pietikainen <pp@ee.oulu.fi>,
	Florian Schirmer <jolt@tuxbox.org>,
	Felix Fietkau <nbd@openwrt.org>, Michael Buesch <mb@bu3sch.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bues.ch ([80.190.117.144]:57459 "EHLO bues.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751406Ab1GFQNQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jul 2011 12:13:16 -0400
In-Reply-To: <1309968019.2292.44.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 06 Jul 2011 18:00:19 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:
> Not exactly :
> 
> If we read one skb at descriptor 0, we prepare a new buffer on slot 200,
> and advance DMARX_PTR to 201*sizeof(descriptor).

I don't think so. Why do you think this is the case?
We allocate a new descriptor buffer for the consumed buffer at exactly
the same place (which is "cons").
(Alternatively, we leave the buffer in place, and just copy the data to a new buffer).
And DMARX_PTR is updated to the last "cons", which is one beyond
the last buffer that we consumed (and pushed up the net stack).

(Note that "beyond" always means "beyond" in the sense of a DMA _ring_,
which honors the EOT bit. This is done by masking cons with RX_RING_SIZE-1,
which is thus assumed to be a power of two).

> > I don't know why b44 sets the DMARX_PTR to 200 initially (which is 40
> > descriptors, as this is a byte pointer). This seems kind of arbitrary.
> > In b43 we set it to (NR_OF_DESCRIPTORS - 1) * sizeof(descriptor).
> > But I don't think it really matters. It only limits the usable DMA
> > area before the first interrupt (or poll) occurs. After the final
> > B44_DMARX_PTR write in b44_rx(), the full descriptor range (well, minus one)
> > will be usable.
> 
> Yes, this is probably a small bug, we should fix it for correctness.

I wouldn't call this a bug.

> > Summary: I don't see where the DMA engine code is broken (except for
> > the minor missing wmb(), which doesn't trigger this memory corruption, though)
> > 
> > I hope that helps to clear up stuff...
> 
> Well, you describe (nicely, thanks !) your understanding of how work the
> driver and chip.
> 
> Problem is we suspect a wrong statement or wrong hardware ;)
>
> Another problem is Alexey doesnt answer anymore, and I dont have this
> (old) hardware...

I do really think that either
1) His device is broken. Chips break. I already saw several devices
with HND DMA engine that broke down after some time of use.
or
2) The bug is at another place, but not in the lowlevel DMA handling.

Could this possibly be some kind of context issue? threaded IRQs?
The net subsys was rather picky about context, last time I looked
into it. see the .._ni() style functions.

> Other point : Do you know why b44_get_ringparam() doesnt  set
> ering->tx_max_pending and ering->tx_pending
> 
> The comment seems wrong :
> /* XXX ethtool lacks a tx_max_pending, oops... */

Well, I _guess_ that ering->tx_max_pending was added later? (I didn't
even check if it's there _now_, though.)
