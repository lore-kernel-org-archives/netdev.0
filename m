From: Jonathan Day <imipak@yahoo.com>
Subject: Re: Questions regarding network drivers
Date: Fri, 10 Nov 2006 09:34:33 -0800 (PST)
Message-ID: <661353.35559.qm@web31513.mail.mud.yahoo.com>
References: <20061110100004.GA18739@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from web31513.mail.mud.yahoo.com ([68.142.198.142]:19630 "HELO
	web31513.mail.mud.yahoo.com") by vger.kernel.org with SMTP
	id S1161888AbWKJRee (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Nov 2006 12:34:34 -0500
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20061110100004.GA18739@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--- Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:

> On Thu, Nov 09, 2006 at 07:06:00PM -0800, Jonathan
> Day (imipak@yahoo.com) wrote:
> > Hi,
> > 
> > I've got an interesting problem to contend with
> and
> > need some advice from the great wise ones here.
> > 
> > First of all, is it possible (and/or "reasonable
> > practice") when developing a network driver to do
> > zero-copy transfers between main memory and the
> > network device?
> 
> What do you mean?
> DMA from NIC memory into CPU memory?

Yes. I want to bypass the kernel altogether and think
there may be a way to do this, but want to make very
certain that I'm not going down the wrong track.

The underlying problem is this. The group I'm working
with is messing about with building their own
networking device that will run at an equal speed to
the bus leading to the host (2.5 gigabits/second). The
device has its own DMA controller and can operate as
bus master.

It's my task to figure out how to get the data into
the host at near-100% bandwidth without dropping
anything, with minimal latency and real-time
characteristics.

(I talked them out of making me do this blindfolded,
but on further consideration, I'm not sure if this was
a good idea.)

> > Secondly, the network device is only designed to
> work
> > with short packets and I really want to keep the
> > throughput up. My thought was that if I fired off
> an
> > interrupt then transfer a page of data into an
> area I
> > know is safe, the kernel will have enough time to
> find
> > a new safe area and post the address before the
> next
> > page is ready to send.
> > 
> > Can anyone suggest why this wouldn't work or,
> assuming
> > it can work, why this would be a Bad Idea?
> 
> There should not be any kind of 'kernel will have
> enough time to do
> something', instead you must guarantee that there
> will not be any kind
> of races. You can either prealocate several buffers
> or allocate them on
> demand in interrupts.

The exact process I was thinking of is as follows:

1. Driver sets up a full page and pins it.

2. Driver obtains the physical address and places that
address into a known, fixed location.

3. Driver sends interrupt to network device to say
that everything is ready.

4. On obtaining the interrupt, a bit is set to true on
the network device, to say that the host is ready to
receive.

5. The network device has a counter for the number of
packets that can be put in one page. If this number is
zero and the bit is set, then:

5.1 The counter is set to the maximum number of
packets storeable in the page.

5.2 The page address is DMAed out of the known
location in host memory and placed in network device
memory.

5.3 The bit is cleared.

5.4 The driver is given an interrupt to tell it to
prepare the next page.

5.5 If the sender had previously been told to stop
transmitting, it is now told to continue.

6. Every received packet is placed in a ring buffer on
the network device.

7. The counter is reduced by 1.

8. If the counter reaches zero, OR the packet is
followed by an end-of-transmission notification:

8.1. The ring buffer is DMAed en-masse into host
memory at the location given in the previously cached
page address.

8.2. If the new page bit has not been set to true, the
network device notifies the sender to pause.

The idea is that we're DMAing to a page that we know
is safe, because the driver has ensured that before
telling the network device where it is. (ie: the
driver ensures that the page actually does exist, has
been fuly set up in the VMM, and isn't going to move
in physical memory or into swap.)

The above description could be "enhanced" by having
two or more available pages, so that it could rapidly
switch. The only requirement for a sustainable system
would be that I could allocate and make safe pages at
an average rate equal to or faster than they would be
consumed. The xon/xoff-type control would then be
simply a way of guaranteeing that the network device
didn't run out of places to put things.

The people working on the hardware have said that they
can handle the hardware side of my description, but I
want to make sure that (a) this will actually work the
way I expect, and (b) there isn't something staring me
in the face that's a billion times easier and a
trillion times more efficient.

What I'm looking for is every argument that can
possibly be thrown against this method - latency,
throughput, accepted standards for Linux drivers,
excessive weirdness, whatever.

> > Lastly, assuming my sanity lasts that long, would
> I be
> > correct in assuming that the first step in the
> process
> > of getting the driver peer-reviewed and accepted
> would
> > be to post the patches here?
> 
> Actually not, the first step in that process is
> learning jig dance and
> of course providing enough beer and other goodies to
> network maintainers.

I tried doing a jig dance once, but the saw cut my
shoes in half.

I can try getting beer. Oregon has some acceptable
microbreweries, but I miss having a pint of Hatters in
England. Mead is easier. I brew mead. Strong, dry,
rocket-fuel mead.

> > Thanks for any help,
> 
> No problem, but to answer at least on of your
> question more
> information should be provided.

Hopefully what's there now is sufficient, though I'd
be happy to add more if need-be.



 
____________________________________________________________________________________
Do you Yahoo!?
Everyone is raving about the all-new Yahoo! Mail beta.
http://new.mail.yahoo.com
