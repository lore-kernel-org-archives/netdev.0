From: Russell King - ARM Linux <linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>
Subject: Re: [PATCH net v4 2/3] dt-binding: net: sfp binding documentation
Date: Tue, 31 Oct 2017 09:29:12 +0000
Message-ID: <20171031092911.GA9463@n2100.armlinux.org.uk>
References: <b98ac3e8cde5c99489e8dcee9a1d5b8a19face8d.1504776350.git.baruch@tkos.co.il>
 <5b46343b543ad1d2ebbc5be9871def7f92c4dbd8.1504776350.git.baruch@tkos.co.il>
 <d707abea-a9eb-74d0-841f-1ff1fe4153a8@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Baruch Siach <baruch-NswTu9S1W3P6gbPvEgmw2w@public.gmane.org>, Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>,
        Antoine Tenart <antoine.tenart-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
To: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <d707abea-a9eb-74d0-841f-1ff1fe4153a8-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 30, 2017 at 08:13:42PM -0700, Florian Fainelli wrote:
> Hi Baruch,
> 
> On 09/07/2017 02:25 AM, Baruch Siach wrote:
> > diff --git a/Documentation/devicetree/bindings/net/sff,sfp.txt b/Documentation/devicetree/bindings/net/sff,sfp.txt
> > new file mode 100644
> > index 000000000000..60e970ce10ee
> > --- /dev/null
> > +++ b/Documentation/devicetree/bindings/net/sff,sfp.txt
> > @@ -0,0 +1,76 @@
> > +Small Form Factor (SFF) Committee Small Form-factor Pluggable (SFP)
> > +Transceiver
> > +
> > +Required properties:
> > +
> > +- compatible : must be "sff,sfp"
> > +
> > +Optional Properties:
> > +
> > +- i2c-bus : phandle of an I2C bus controller for the SFP two wire serial
> > +  interface
> 
> What was the reasoning behind using this property instead of making the
> SFP a child of the i2c bus directly? Were you thinking that there could
> be systems where the SFP is not i2c-addresable, but another 2-wire
> protocol is used instead? This is not particularly wrong per-se I guess,
> but usually, the parent/child relationship should make that more obvious.

Here's what I said about this exact subject in August:

  What reg= value would you use to identify it?  There's no particular
  I2C bus address.  There's an EEPROM on the actual module, and there
  may be a PHY on the I2C bus (some PHYs include I2C as an alternative
  way to speak to them other than MDIO.)

  I2C couldn't probe these as they are effectively hotplugged.

  However, there's also the question about why it should be a child of
  the I2C bus - the I2C bus is just a means of communicating with and
  identifying the module.  You could equally argue that it should be
  a child of the GPIO controller, because that's how it's controlled.
  You could also argue that it should be a child of the ethernet
  interface, since that's the main data path.

The SFP support is basically a driver for a socket which has a
hot-pluggable device, which may be empty at the time of probing.
If it's empty, it just has an I2C bus, a bunch of GPIOs and a
couple of serdes lanes routed to it, which appear on pins on the
socket.  There is no device that can be detected or probed.

There is no I2C bus address of an empty socket.

When a module is plugged in, then we get some I2C devices appearing.
These can take one or more I2C bus addresses.  The I2C device
binding requires that all I2C child nodes specify the bus address
of their device.  Which address do you choose?

Bear in mind that when the socket is empty, as there's no devices
present, there wouldn't be a device for a driver to bind to, so
this driver, which deals with the hot-plugging of the socket has
no device to bind with.

Think of the "sff,sfp" driver as a driver for the /socket/ rather
than the /module/ in the socket.  The SFF specifications give the
requirements for the signals at the /socket/ and the driver
implements those requirements.

If drivers are required for the modules (because they have a PHY
on them) the normal Linux PHY drivers get used for that.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line in suburbia: sync at 8.8Mbps down 630kbps up
According to speedtest.net: 8.21Mbps down 510kbps up
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
