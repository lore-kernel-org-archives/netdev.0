From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH 3/3] net: smsc911x: add u16 workaround for pxa platforms
Date: Mon, 3 Oct 2016 17:09:13 +0100
Message-ID: <20161003160913.GQ1041@n2100.armlinux.org.uk>
References: <1475485553-18747-1-git-send-email-robert.jarzmik@free.fr>
 <1475485553-18747-3-git-send-email-robert.jarzmik@free.fr>
 <20161003154624.GG7632@leverpostej>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Robert Jarzmik <robert.jarzmik@free.fr>,
        Rob Herring <robh+dt@kernel.org>,
        Nicolas Pitre <nico@fluxnic.net>,
        Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-kernel@vger.kernel.org
To: Mark Rutland <mark.rutland@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:38844 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753715AbcJCQJb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Oct 2016 12:09:31 -0400
Content-Disposition: inline
In-Reply-To: <20161003154624.GG7632@leverpostej>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 03, 2016 at 04:46:25PM +0100, Mark Rutland wrote:
> On Mon, Oct 03, 2016 at 11:05:53AM +0200, Robert Jarzmik wrote:
> > Add a workaround for mainstone, idp and stargate2 boards, for u16 writes
> > which must be aligned on 32 bits addresses.
> > 
> > Signed-off-by: Robert Jarzmik <robert.jarzmik@free.fr>
> > ---
> >  Documentation/devicetree/bindings/net/smsc911x.txt | 2 ++
> >  1 file changed, 2 insertions(+)
> > 
> > diff --git a/Documentation/devicetree/bindings/net/smsc911x.txt b/Documentation/devicetree/bindings/net/smsc911x.txt
> > index 3fed3c124411..224965b7453c 100644
> > --- a/Documentation/devicetree/bindings/net/smsc911x.txt
> > +++ b/Documentation/devicetree/bindings/net/smsc911x.txt
> > @@ -13,6 +13,8 @@ Optional properties:
> >  - reg-io-width : Specify the size (in bytes) of the IO accesses that
> >    should be performed on the device.  Valid value for SMSC LAN is
> >    2 or 4.  If it's omitted or invalid, the size would be 2.
> > +- reg-u16-align4 : Boolean, put in place the workaround the force all
> > +  		   u16 writes to be 32 bits aligned
> 
> This property name and description is confusing.
> 
> How exactly does this differ from having reg-io-width = <4>, which is
> documented immediately above?

Please note that the binding doc for smsc,lan91c111.txt is slightly wrong
on two counts:

1) compatible property:

compatible = "smsc,lan91c111";

vs the code:

static const struct of_device_id smc91x_match[] = {
        { .compatible = "smsc,lan91c94", },
        { .compatible = "smsc,lan91c111", },
        {},
};
MODULE_DEVICE_TABLE(of, smc91x_match);

So the binding document needs to mention that smsc,lan91c94 is a valid
compatible for this device.

2) reg-io-width property:

- reg-io-width : Mask of sizes (in bytes) of the IO accesses that
  are supported on the device.  Valid value for SMSC LAN91c111 are
  1, 2 or 4.  If it's omitted or invalid, the size would be 2 meaning
  16-bit access only.

The SMC requires at least one of byte or 16-bit access sizes, with
32-bit access sizes being optional on top.  So, the legal values here
are: 1, 2, 3, 5, 6, and 7.  4 is illegal, and has never been supported
by the driver.

Note that the driver will always use byte accesses if '1' is specified
and emulate 16-bit accesses.  If '2' is specified, the driver will
always use 16-bit accesses, and emulate byte accesses for the 8-bit
registers using a read-modify-write scheme.  If '3' is specified, the
driver will use both 16-bit and byte accesses as appropriate for the
register being accessed with no emulation.  Byte or 16-bit access are
required for non-data register access.

Including 32-bit accesses on top of this allows the packet transfer
(iow, data register accesses) to use 32-bit access instructions, which
is a performance boost.

Moreover, look at the property name vs the binding description.  It's
property name says it's a width, but the description says it's a mask
of sizes - these really aren't the same thing.  Once you start
specifying these other legal masks, it makes a nonsense of the "width"
part of the name.  It's too late to try and fix this now though.

The binding document really needs to get fixed - I'll try to cook up a
patch during this week to correct these points, but it probably needs
coordination if others are going to be changing this as well.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
