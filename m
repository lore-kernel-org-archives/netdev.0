From: =?iso-8859-1?Q?Bj=F6rn?= Steinbrink <B.Steinbrink@gmx.de>
Subject: Re: forcedeth: MAC-address reversed on resume from suspend
Date: Fri, 4 Jan 2008 04:43:57 +0100
Message-ID: <20080104034357.GA2113@atjola.homenet>
References: <477BFC71.7090002@coderworld.net> <20080102214843.GA19224@rhlx01.hs-esslingen.de> <20080102234209.GA10831@does.not.exist>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andreas Mohr <andi@lisas.de>,
	Richard Jonsson <richie@coderworld.net>,
	linux-kernel@vger.kernel.org, Ayaz Abdulla <aabdulla@nvidia.com>,
	jgarzik@pobox.com, netdev@vger.kernel.org
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:58432 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753600AbYADDoC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Jan 2008 22:44:02 -0500
Content-Disposition: inline
In-Reply-To: <20080102234209.GA10831@does.not.exist>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2008.01.03 01:42:09 +0200, Adrian Bunk wrote:
> [ original bug report: http://lkml.org/lkml/2008/1/2/253 ]
>=20
> On Wed, Jan 02, 2008 at 10:48:43PM +0100, Andreas Mohr wrote:
> > Hi,
> >=20
> > On Wed, Jan 02, 2008 at 10:04:49PM +0100, Richard Jonsson wrote:
> > > Bugreport regarding forcedeth driver.
> > >
> > > When returning from suspend-to-RAM the MAC-address byteorder is
> > > reversed.  After another suspend-resume cycle the MAC-address is
> > > again correct. This brings a great deal of pain since the NIC is
> > > assigned a random MAC-address when it is detected as invalid.
> > >
> > > I cannot say if this issue appeared recently or if it's been in
> > > the kernel for a while, as I've been using wireless until
> > > recently.
> > >
> > > I read somewhere on lkml that the mac is read from the device,
> > > then reversed and finally written back to the device. Can it be
> > > that it is read again on resume and reversed, and then again
> > > written to the device? This would explain why it's ok every other
> > > resume cycle.
> >=20
> > Uh, Use The Source, Luke?
> >=20
> > But no, I think it's simply driver dainbreadness, not a matter of
> > complicated writing and reading back in reversed order.
> >=20
> > drivers/net/forcedeth.c has a nice DEV_HAS_CORRECT_MACADDR flag
> > which is being enabled for certain cards (those which need this) an=
d
> > disabled for others.
> >=20
> > The nv_probe() function then nicely obeys this flag by reversing th=
e
> > address if needed, _however_ there's another function,
> > nv_copy_mac_to_hw(), which does _NOT_ obey it and simply copies the
> > _raw_ netdev dev_addr to the card register (NvRegMacAddrA etc.).

nv_copy_mac_to_hw() is called from nv_probe() _after_ the MAC address
has been fixed, and from nv_set_mac_address() which is supposed to get =
a
correct MAC address anyway. So I don't see any problem there.


After some digging, I guess it's related to
5070d3408405ae1941f259acac7a9882045c3be4

That introduced a flag in a register to signal if the MAC address has
been corrected, so that for example kexec won't reverse the adddress
again, when calling nv_probe() again.

As I know neither the suspend nor the kexec code well enough, I'll have
to make a few smart guesses (let's hope that that works out *g*):

a) suspend manages to reverse the MAC address again, so it must call
nv_probe. And we have lost the flag that stops us from reversing the
address. We cannot have lost the fixed MAC address, because then we'd
always get the reversed address, and not go back and forth. I'll assume
that it will also call nv_remove during suspend, because it's nicely
symmetrical then :-)

b) kexec does not call nv_remove, because otherwise, it would see a
reversed address on its nv_probe call anyway, and the flag wouldn't be
necessary.

Now the commit that introduced the flag did also introduce an indirect
change to nv_remove. Although it still says that it writes back the
broken MAC address, that's no longer true, because orig_mac now also
gets the correct address in nv_probe.

Smart guessing time again: That was required because otherwise a "rmood
forcedeth && modprobe forcedeth" would have produced a reversed MAC
address.

But that also causes the problem that we get when we loose either the
flag, we start reversing the fixed address. If we instead return the
card to its initial state in nv_remove, ie. unset the flag and write
back the reversed address, then everyone going through nv_remove _and_
nv_probe should be happy. And kexec, which only goes through nv_probe
again and doesn't loose the flag should be happy, too.

Richard, could you give this a spin? And then we'd likely need someone
to test that with kexec...

thanks,
Bj=F6rn
---
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index a96583c..f84c752 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -5199,10 +5199,6 @@ static int __devinit nv_probe(struct pci_dev *pc=
i_dev, const struct pci_device_i
 		dev->dev_addr[3] =3D (np->orig_mac[0] >> 16) & 0xff;
 		dev->dev_addr[4] =3D (np->orig_mac[0] >>  8) & 0xff;
 		dev->dev_addr[5] =3D (np->orig_mac[0] >>  0) & 0xff;
-		/* set permanent address to be correct aswell */
-		np->orig_mac[0] =3D (dev->dev_addr[0] << 0) + (dev->dev_addr[1] << 8=
) +
-			(dev->dev_addr[2] << 16) + (dev->dev_addr[3] << 24);
-		np->orig_mac[1] =3D (dev->dev_addr[4] << 0) + (dev->dev_addr[5] << 8=
);
 		writel(txreg|NVREG_TRANSMITPOLL_MAC_ADDR_REV, base + NvRegTransmitPo=
ll);
 	}
 	memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
@@ -5414,6 +5410,8 @@ static void __devexit nv_remove(struct pci_dev *p=
ci_dev)
 	 */
 	writel(np->orig_mac[0], base + NvRegMacAddrA);
 	writel(np->orig_mac[1], base + NvRegMacAddrB);
+	writel(readl(base + NvRegTransmitPoll) & ~NVREG_TRANSMITPOLL_MAC_ADDR=
_REV,
+	       base + NvRegTransmitPoll);
=20
 	/* free all structures */
 	free_rings(dev);
