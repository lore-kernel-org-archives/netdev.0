From: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH v2 3/3] pppoatm: protect against freeing of vcc
Date: Thu, 29 Nov 2012 12:17:01 -0500
Message-ID: <20121129121701.21ab7c0b@thirdoffive.cmf.nrl.navy.mil>
References: <1350926091-12642-1-git-send-email-krzysiek@podlesie.net>
	<1350926091-12642-3-git-send-email-krzysiek@podlesie.net>
	<1354036592.2534.6.camel@shinybook.infradead.org>
	<20121127173906.GA11390@shrek.podlesie.net>
	<1354039349.2534.11.camel@shinybook.infradead.org>
	<20121127135434.0728cd4f@thirdoffive.cmf.nrl.navy.mil>
	<AE90C24D6B3A694183C094C60CF0A2F6026B70C9@saturn3.aculab.com>
	<1354141115.21562.101.camel@shinybook.infradead.org>
	<20121129150945.GB16478@shrek.podlesie.net>
	<1354204077.21562.172.camel@shinybook.infradead.org>
	<20121129105934.3e0c3a04@thirdoffive.cmf.nrl.navy.mil>
	<1354206269.21562.189.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Krzysztof Mazur <krzysiek@podlesie.net>,
	David Laight <David.Laight@ACULAB.COM>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	nathan@traverse.com.au
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1354206269.21562.189.camel@shinybook.infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 29 Nov 2012 16:24:29 +0000
David Woodhouse <dwmw2@infradead.org> wrote:

> On Thu, 2012-11-29 at 10:59 -0500, chas williams - CONTRACTOR wrote:
> > the part that bothers me (and i dont have the programmer's guide for
> > the solos hardware) is that you are watching for the PKT_PCLOSE to be
> > sent to the card.  shouldnt you be watching for the PKT_PCLOSE to be
> > returned from the card (assuming it does such a thing) so that you can
> > be assured that the tx/rx for this vpi/vci pair has been "stopped"?
> 
> Define "stopped".
> 
> For the RX case... the other end may *always* take it upon itself to
> send us a packet marked with arbitrary VCI/VPI, right? There's no
> connection setup for it "on the wire", in the case of PVC?

most atm hardware that i am familiar with, wont deliver vpi/vci data
unless you are actually trying to receive it.  however, this hardware
is generally doing its reassembly in hardware and delivering aal5
pdu's and needs to manage its memory resources carefully.  you might be
trying to reassemble 1000 pdu's from different vpi/vci's.

> So bearing that in mind: from the moment ATM_VF_READY gets cleared, as
> far as the ATM core is concerned, we will no longer receive packets on
> the given VCC. If we receive any, we'll just complain about receiving
> packets for an unknown VCI/VPI.
> 
> For the TX case ... yes, we need to be sure we aren't continuing to send
> packets after our close() routine completes. We *used* to, but the
> resulting ->pop() calls were causing problems, and that's why we're
> looking at this code path closer. The currently proposed patches (except
> one suggestion from Krzyztof that we both shouted down) would fix that.

again part of this is poor synchronization.  the detach protocol (i.e.
push of a NULL skb) should be flushing any pending transmits and
shutting down whatever in the protocol is doing any sending and
receiving.  however, i release this might be difficult to do since the
detach protocol is invoked in such a strange way.
