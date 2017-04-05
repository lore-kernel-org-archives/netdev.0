From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH v2 00/13] ftgmac100: Rework batch 1 - Link & Interrupts
Date: Wed, 05 Apr 2017 16:31:20 +1000
Message-ID: <1491373880.4166.79.camel@kernel.crashing.org>
References: <20170405022853.8238-1-benh@kernel.crashing.org>
         <2344b1ea-f8bc-7491-4662-b8a3e94fb94e@gmail.com>
         <1491371595.4166.77.camel@kernel.crashing.org>
         <b59025eb-e653-8481-2e58-a780777df4ee@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:55764 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752510AbdDEGbi (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 5 Apr 2017 02:31:38 -0400
In-Reply-To: <b59025eb-e653-8481-2e58-a780777df4ee@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-04-04 at 23:02 -0700, Florian Fainelli wrote:

> We don't necessarily have a phydev attached when using NC-SI, so it was
> > easier to have the core code path not have to go fishing for those
> > settings in different places based on whether we're using NC-SI or not.
> 
> Oh right, I missed that part. Is there a reason why NC-SI does not have
> a PHY device attached? If not, could you somehow model the link using a
> fixed PHY (which appears to Linux as a normal phy_device) just to keep
> things simple.

Hrm ... maybe another day if you don't mind ;-)

First NC-SI isn't really a PHY .... it's a cross-over RMII connection
to another NIC.

Now we could make it a phydev using a "fixed" PHY I suppose, that just
"represents" the other end. That would be a way to do it. It would need
to have the link permanently up however (see below).

That said I do want to tackle making it some kind of pseudo-PHY that
actually reflects the state of the remote end (especially the link
state, ie. up/down).

However there are a couple of issues to tackle if we do that. Well
mostly one annoying one:

NC-SI needs to talk to the remote NIC via specific ethernet frames.

With the current link watch code however, if we reflect the remote link
to the local NIC link via netif_carrier_on/off, we end up deactivating
the device on link off and thus preventing the NC-SI stack from talking
to the peer NIC at all.

I thought a while ago we could add some dev flag to prevent the link
watch from doing that, but never got to look into it myself and
apparently neither did Gavin.

So yes, those are worthwhile improvements and I can probably tackle
them once I've unpiled a dozen other train wrecks from my plate ;)
However I'd like to not block this series further since it's not
actually making things any worse than they are.

> > > - the need to reset the HW during link changes is just ... well too bad
> > 
> > Yup but there's little choice. The HW wants it. I don't see any real
> > point in optimizing that path mind you. Losing a few packets around
> > a link change isn't going to hurt and it keeps the code a lot simpler
> > by having a single "re-init" path.
> 
> I was just merely trying to say nicely: what a nicely broken piece of HW
> (there were other adjectives coming to mind), and I do understand the pain.

:-) At least I got a register spec (and little more) :-)

It looks like those Aspeed BMCs are the only game in town for BMC chips
these days and they use that "interesting" IP block from Faraday so
this is probably here to stay, at least for a while.

Another "interesting" attribute of that piece of c^Hhw is its handling
of receive descriptors.

It doesn't "count" how many are free. It has to constantly "read" the
head descriptor in the RX ring to check the own bit. So you have to
setup a HW timer for the chip to go "poll" on your memory. It's pretty
insane. At least for TX there's an MMIO you can poke to tell it to go
fetch more. There's sort-of one for RX but it doesn't seem to do what
you would expect, or I did something wrong when playing with it.

It's not like it would have been hard to have a counter, which is
incremented by writing a value to a register so Linux can "provide"
descriptors by writing the number freed in there.

So the chip never really knows how many free descriptors it has which
also means it cannot do flow control based on that, only on the FIFO
threshold. With a 2K only FIFO that's .... interesting.

Anyway, it sort-of works. Without my patches I maxed out at about
80Mbit/s iperf on a gigabit link with the AST2500 eval board (ARM11
800Mhz base). With my patches I get to about 400Mbit/s.

Cheers.
Ben.
