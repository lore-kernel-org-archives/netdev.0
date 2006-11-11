From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Questions regarding network drivers
Date: Sat, 11 Nov 2006 14:54:49 +0300
Message-ID: <20061111115449.GA22586@2ka.mipt.ru>
References: <20061110100004.GA18739@2ka.mipt.ru> <661353.35559.qm@web31513.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:20156 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1424557AbWKKLyj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Nov 2006 06:54:39 -0500
To: Jonathan Day <imipak@yahoo.com>
Content-Disposition: inline
In-Reply-To: <661353.35559.qm@web31513.mail.mud.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 10, 2006 at 09:34:33AM -0800, Jonathan Day (imipak@yahoo.com) wrote:
> > > First of all, is it possible (and/or "reasonable
> > > practice") when developing a network driver to do
> > > zero-copy transfers between main memory and the
> > > network device?
> > 
> > What do you mean?
> > DMA from NIC memory into CPU memory?
> 
> Yes. I want to bypass the kernel altogether and think
> there may be a way to do this, but want to make very
> certain that I'm not going down the wrong track.
> 
> The underlying problem is this. The group I'm working
> with is messing about with building their own
> networking device that will run at an equal speed to
> the bus leading to the host (2.5 gigabits/second). The
> device has its own DMA controller and can operate as
> bus master.
> 
> It's my task to figure out how to get the data into
> the host at near-100% bandwidth without dropping
> anything, with minimal latency and real-time
> characteristics.

<advertisement>
You can use netchannels, which were designed for exactly that kind of
load.
</advertisement>

You need to process some headers anyway - to select appropriate socket
or netchannel or whatever.

...  driver's internals were skipped ...

> The idea is that we're DMAing to a page that we know
> is safe, because the driver has ensured that before
> telling the network device where it is. (ie: the
> driver ensures that the page actually does exist, has
> been fuly set up in the VMM, and isn't going to move
> in physical memory or into swap.)

It does not differ from usual behaviour actaully except that you need to
setup different skb for each packet.
So you can preallocate required number of skbs, allocate special page
and setup it's pointers appropriately - this will require you to change
some logic behind frag_list, for example you can increase page's
reference counter to number of packets in that page and setup frag_list
for each skb to point to different packets inside that page.
Each skb->data must have some headers though, so you will need to copy
parts of the packets.

> The above description could be "enhanced" by having
> two or more available pages, so that it could rapidly
> switch. The only requirement for a sustainable system
> would be that I could allocate and make safe pages at
> an average rate equal to or faster than they would be
> consumed. The xon/xoff-type control would then be
> simply a way of guaranteeing that the network device
> didn't run out of places to put things.
> 
> The people working on the hardware have said that they
> can handle the hardware side of my description, but I
> want to make sure that (a) this will actually work the
> way I expect, and (b) there isn't something staring me
> in the face that's a billion times easier and a
> trillion times more efficient.
> 
> What I'm looking for is every argument that can
> possibly be thrown against this method - latency,
> throughput, accepted standards for Linux drivers,
> excessive weirdness, whatever.

Excessive weirdness is indeed the case.
If I understood you correctly, hardware is capable to DMA several
packets one-by-one into given buffer and you want to take advantage of
that?

> > > Lastly, assuming my sanity lasts that long, would
> > I be
> > > correct in assuming that the first step in the
> > process
> > > of getting the driver peer-reviewed and accepted
> > would
> > > be to post the patches here?
> > 
> > Actually not, the first step in that process is
> > learning jig dance and
> > of course providing enough beer and other goodies to
> > network maintainers.
> 
> I tried doing a jig dance once, but the saw cut my
> shoes in half.
> 
> I can try getting beer. Oregon has some acceptable
> microbreweries, but I miss having a pint of Hatters in
> England. Mead is easier. I brew mead. Strong, dry,
> rocket-fuel mead.

Then you definitely just need to send your driver to netdev@.

-- 
	Evgeniy Polyakov
