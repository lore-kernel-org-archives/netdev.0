From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH] Intel IXP4xx network drivers v.2 - Ethernet and HSS
Date: Tue, 8 May 2007 16:53:40 +0200
Message-ID: <20070508145340.GD387@xi.wantstofly.org>
References: <m3abwhcy74.fsf@maximus.localdomain> <m3vef5biob.fsf@maximus.localdomain> <5BB7E1AB-5CE1-43C8-8CE3-E0DE0236BD09@cam.ac.uk> <m3hcqoa772.fsf@maximus.localdomain> <86D26EBE-5899-468F-9C79-23E83E0DE04B@cam.ac.uk> <m33b289zku.fsf@maximus.localdomain> <m3zm4g3yed.fsf_-_@maximus.localdomain> <20070508113735.GB32055@xi.wantstofly.org> <m3fy6775fz.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael-Luke Jones <mlj28@cam.ac.uk>,
	Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	lkml <linux-kernel@vger.kernel.org>,
	Russell King <rmk@arm.linux.org.uk>,
	ARM Linux Mailing List
	<linux-arm-kernel@lists.arm.linux.org.uk>
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S968330AbXEHOxp@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m3fy6775fz.fsf@maximus.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 08, 2007 at 04:31:12PM +0200, Krzysztof Halasa wrote:

> >> +/* Built-in 10/100 Ethernet MAC interfaces */
> >> +static struct mac_plat_info ixdp425_plat_mac[] = {
> >> +	{
> >> +		.phy		= 0,
> >> +		.rxq		= 3,
> >> +	}, {
> >> +		.phy		= 1,
> >> +		.rxq		= 4,
> >> +	}
> >> +};
> >
> > As with Christian's driver (I'm feeling like a bit of a broken record
> > here :-), putting knowledge of which queue to use (which is firmware-
> > specific) in the _board_ support file is almost certainly wrong.
> >
> > I would just put the port number in there, and let the ethernet
> > driver map the port number to the hardware queue number.  After all,
> > the ethernet driver knows which queues the firmware uses, while the
> > board support code doesn't.
> 
> No, quite the opposite. The board code knows its set of hardware
> interfaces etc. and can let Ethernet driver use, say, HSS queues.
> The driver can't know that.

You are attacking a point that I did not make.

The board support code knows such things as that the "front ethernet
port" on the board is connected to the CPU's MII port number #2, but
the board support code does _not_ know that MII port number #2
corresponds to "ixp4xx hardware queue #5."

If Intel puts out a firmware update next month, and your ethernet
driver is modified to take advantage of the new features in that
firmware and starts depending on the newer version of that firmware,
we will have to modify every ixp4xx board support file in case the
firmware update modifies the ixp4xx queue numbers in use.  The
mapping from hardware ports (MII port #0, MII port #6, HSS port
#42, whatever) to ixp4xx hardware queue numbers (0-63) should _not_
be put in every single ixp4xx board support file.

Even if you only change the

	(in board support file)
	.rxq		= 4,

line to something like this instead:

	(in some ixp4xx-specific or driver-specific header file)
	#define IXP4XX_MII_PORT_1_RX_QUEUE		4

	(in board support file)
	.rxq		= IXP4XX_MII_PORT_1_RX_QUEUE,

then you have remved this dependency, and then you only have to update
one place if you move to a newer firmware version.


> > I generally discourage the use of such wrappers, as it often makes
> > people forget that the set and clear operations are not atomic, and
> > it ignores the fact that some of the other bits in the register you
> > are modifying might have side-effects.
> 
> Without them the code in question is hardly readable,

You can read Polish, how can you complain about code readability. :-))

*runs*


> I pick the need to remember about non-atomicity and possible side
> effects instead :-)

Sure, point taken, it's just that the person after you might not
remember..
