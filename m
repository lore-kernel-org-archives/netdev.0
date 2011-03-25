From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC] Inconsistency in MDIO ioctl behaviour
Date: Fri, 25 Mar 2011 21:07:34 +0000
Message-ID: <1301087254.2694.27.camel@bwh-desktop>
References: <1252011886.2781.45.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:53059 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755155Ab1CYVHh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Mar 2011 17:07:37 -0400
In-Reply-To: <1252011886.2781.45.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-09-03 at 22:04 +0100, Ben Hutchings wrote:
> While comparing the various implementations of SIOC{G,S}MIIREG and
> SIOCGMIIPHY, I found some differences in behaviour that could make so=
me
> applications unreliable across different drivers.

=2E..and I just got round to looking at this again.

> 1. Implementations of SIOCGMIIPHY must set phy_id to the PHY's MDIO
> address (PRTAD) or to a dummy address if there is no real MDIO bus.
> Many implementations, including the generic ones (mii, phylib,
> pci-skeleton and now mdio) then proceed as for SIOCGMIIPHY.  Others
> return without accessing any registers.  Which behaviour is right?

With a Google Code Search for SIOCGMIIPHY I found only one program that
assumes SIOCGMIIPHY reads a register.  That is mii-diag, which in
verbose mode prints val_out as the BMCR value, and since reg_num is
statically zero-initialised this works for many implementations.  For
all subsequent register reads, it uses SIOCGMIIREG.

In these 8 drivers, SIOCGMIIPHY doesn't read a register:

atl1c, atl1e, atl2, e1000, e1000e, igb, r8169, via-velocity

and in about 90 other drivers (including users of mii, mdio and phylib)
it does.  But the chips covered by the first 7 of those 8 drivers are
extremely widely used, and I expect that if anyone cared about
'mii-diag -v' or another utility with the same assumption then this
would have been reported to netdev repeatedly.

I'm inclined to say we should drop the register read from SIOCGMIIPHY
from the common implementations and pci-skeleton.c.

> 2. Implementations of=EF=BB=BF SIOC{G,S}MIIREG that do not support ac=
cess to
> arbitary MDIO addresses handle non-matching values of phy_id in at le=
ast
> three different ways:
> (a) ignore it and always use the expected PHY address
> (b) ignore writes and return a dummy value for reads
> (c) fail
> I favour behaviour (c) but I'm not sure what the error code should be=
=2E
> ENODEV, EINVAL or EIO?

I think ENODEV should be reserved for 'network device does not exist',
and EIO for a failure in I/O to hardware that we actually expect to be
there.  So EINVAL it is.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

