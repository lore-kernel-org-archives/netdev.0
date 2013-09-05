From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [PATCH] net: mvneta: properly disable HW PHY polling and ensure
 adjust_link() works
Date: Thu, 5 Sep 2013 10:26:59 +0200
Message-ID: <20130905102659.25a0f064@skate>
References: <1378304478-21237-1-git-send-email-thomas.petazzoni@free-electrons.com>
	<20130904163245.GI20552@1wt.eu>
	<CACzLR4uDQK2bkcEJQXLe805EfSA8=eF+YH-FTYovHA0q+8Y9NA@mail.gmail.com>
	<20130905051223.GB26000@1wt.eu>
	<20130905092808.617da416@skate>
	<20130905074426.GD26000@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ethan Tuttle <ethan@ethantuttle.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	Lior Amsalem <alior@marvell.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	Jochen De Smet <jochen.armkernel@leahnim.org>,
	Peter Sanford <psanford@nearbuy.io>,
	=?UTF-8?B?Q2jDqW55?= Yves-Gael <yves@cheny.fr>,
	Ryan Press <ryan@presslab.us>,
	Simon Guinot <simon.guinot@sequanux.org>, vdonnefort@lacie.com,
	stable@vger.kernel.org, Jason Cooper <jason@lakedaemon.net>
To: Willy Tarreau <w@1wt.eu>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20130905074426.GD26000@1wt.eu>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dear Willy Tarreau,

On Thu, 5 Sep 2013 09:44:26 +0200, Willy Tarreau wrote:

> On Thu, Sep 05, 2013 at 09:28:08AM +0200, Thomas Petazzoni wrote:
> > I indeed submitted a revised/improved version of your patches some time
> > ago, but they were rejected. See
> > http://lists.infradead.org/pipermail/linux-arm-kernel/2013-June/173201.html.
> 
> Thanks for the link, that's indeed what I was referring to. Well, at least
> the most boring part that constantly needed to be rebased was the DT patch.
> Now it's much easier to keep the small remaining patches in one's local tree.

Right.

> > Since this has been rejected, the available options are:
> > 
> >  (1) Use a DT-capable bootloader that will properly set the MAC
> >      addresses in the DT. Such DT capable bootloaders will soon be made
> >      available by Marvell, but I am really unsure Globalscale will
> >      provide an update for the Mirabox bootloader, rebased on the new
> >      Marvell bootloader that will be DT capable.
> 
> One simpler solution for them could be to slightly modify the boot loader
> so that it sets the MAC address on the two ethernet controllers prior to
> boot. Then your code which checks if a MAC is already set will simply
> work.

This works when the network driver is compiled 'statically' inside the
kernel. When compiled as a module, then the gatable clock of the
network interface will be gated at the end of the kernel boot, before
the mvneta module is probe. And gating the network interface clocks
means that it will loose its state, including its MAC address. So it's
not an entirely perfect solution either, but I admit that on such
platforms, the network driver is most likely compiled statically, so it
would probably suit the needs of most people.

Note that this can be done without doing any change in the bootloader.
For example, on a Mirabox, you can do:

   mw.l 0xD0072414 0x5C93; mw.l 0xD0072418 0xF0AD4E01; mw.l 0xD0076414 0x5C94; mw.l 0xD0076418 0xF0AD4E01; bootm

to boot your kernel. This will program the MAC addresses for both
network interfaces in the network controllers, so that when booting
Linux, you get:

[   42.122881] mvneta d0070000.ethernet eth0: Using hardware mac address f0:ad:4e:01:5c:93
[   42.385398] mvneta d0074000.ethernet eth1: Using hardware mac address f0:ad:4e:01:5c:94

You add that to your default U-Boot boot script, and that's it, you
have stable MAC addresses. Of course, as explained above, that doesn't
work if you build mvneta as a module.

> >      As an alternative, we (mainly Sebastian Hesselbarth and myself)
> >      have started adding Armada 370/XP support in the Barebox
> >      bootloader. We can already start Barebox on the Mirabox, but for
> >      now it's quite useless since only the serial port is supported,
> >      there is still no support for the network, SD card, USB or NAND.
> >      This will probably come over time, but it's not going to happen
> >      overnight.
> 
> And we must keep in mind that people are generally scared by boot loader
> upgrades, especially when it's for a different one. At least on this
> platform now we have a solution to reflash even after complete failures
> so this is less of a problem.

Right, with kwboot working very reliably on Mirabox, I believe this is
not really an issue.

> >  (2) Use the "impedance matcher" code written by Daniel Mack and
> >      extended by Jason Cooper, available at
> >      https://github.com/zonque/pxa-impedance-matcher. Essentially, it
> >      inserts a small binary between the installed bootloader and the
> >      kernel, that for example allows to choose a particular DTB amongst
> >      several, depending on the board that is detected. I believe it
> >      could probably be extended to cover other use cases such as
> >      modifying the DTB to add the MAC addresses where appropriate. I've
> >      added Jason Cooper in the Cc list if he wants to comment on that.
> 
> Could be a nice solution as well, indeed.
> 
> A last one would be to have the mvneta module accept an array of addresses
> as a module parameter. This way it would just require a minor change in the
> kernel's cmdline to pass the MAC addresses. I remember seeing this in the
> past, I don't remember the platform (maybe the NSLU2 but I could be wrong).

The situation of module parameters to pass MAC addresses was a bit
fuzzy. There was once a proposal to add a generic kernel parameter to
do this, but it was rejected by David Miller (I believe not on specific
implementation details, but on the general idea). However, there are
numerous drivers in the tree that do provide a custom module parameter
to set MAC addresses.

However, with the above suggestion of U-Boot scripting, I believe we
have a relatively easy solution for people to use.

Best regards,

Thomas
-- 
Thomas Petazzoni, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
