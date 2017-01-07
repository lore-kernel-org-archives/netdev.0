From: Russell King - ARM Linux <linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>
Subject: Re: [PATCHv2 net-next 11/16] net: mvpp2: handle misc PPv2.1/PPv2.2
 differences
Date: Sat, 7 Jan 2017 13:50:20 +0000
Message-ID: <20170107135019.GM14217@n2100.armlinux.org.uk>
References: <1482943592-12556-1-git-send-email-thomas.petazzoni@free-electrons.com>
 <1482943592-12556-12-git-send-email-thomas.petazzoni@free-electrons.com>
 <20170107110351.GK14217@n2100.armlinux.org.uk>
 <CAPv3WKeQ=fj2cKPyJ2NqCaAv55cOyWodujKwj3-v5iCrDYNcmA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Petazzoni <thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        "devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Ian Campbell <ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>,
        Pawel Moll <pawel.moll-5wv7dgnIgG8@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Kumar Gala <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
        Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
        Yehuda Yitschak <yehuday-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
        Jason Cooper <jason-NLaQJdtUoK4Be96aLqz0jA@public.gmane.org>,
        Hanna Hawa <hannah-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
        Nadav Haklai <nadavh-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
        Gregory Clement <gregory.clement-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
        Stefan Chulski <stefanc-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
        "linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
        <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmai
To: Marcin Wojtas <mw-nYOzD4b6Jr9Wk0Htik3J/w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAPv3WKeQ=fj2cKPyJ2NqCaAv55cOyWodujKwj3-v5iCrDYNcmA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Jan 07, 2017 at 01:12:35PM +0100, Marcin Wojtas wrote:
> In fact there is common SMI bus, but each port has its own register
> set to control it (it's true at least for Neta and PP2). There is also
> an option to use HW polling - every 1s hardware checks PHY over SMI
> and updates MAC registers of each port independently. I was able to
> use those successfully in other implementations.
> 
> However we are supposed to use libphy in Linux and I'm afraid we have
> to use single instance that controls single SMI bus - I think current
> implementation is a compromise between HW and libphy demands.

One of the "DT rules" is that DT only describes the hardware in an
implementation independent way.  It should not describe a particular
implementation's view of the hardware.

"libphy demands" sounds very much like an implementation dictating
the DT description, which sounds to me very wrong and against the
goals and purposes of DT.

Anyway, I don't think it's too bad - a possible solution here would
be to have the existing MDIO driver as a library, which can be
instantiated by the Neta and PP2 drivers.  This could be done in
DT (taking dove as an example) as:

                        eth: ethernet-ctrl@72000 {
                                compatible = "marvell,orion-eth";
				reg = <0x72000 0x4000>;
				ranges = <0 0x72000 0 0x4000>;
				...
				mdio: mdio@4 {
					compatible = "marvell,orion-mdio";
					reg = <4>;
					...
					... phys ...
				};
			};

I don't think that would require that big a change - and it could be
done in a way that compatibility with the existing DT descriptions is
maintained very cheaply.

Now, I'm not suggesting that mdio@4 should be created by a platform
device via marking ethernet-ctrl@72000 with "simple-bus", but it's
something that should be created by the ethernet driver if present.
The compatible string is there so we can identify that this is a
mdio node, and which type of mdio it is (the Armada 8k has this type
and a separate clause-45 xmdio implementation, and we need to
distinguish those.)

What that means is that we no longer have to worry about clocks and
overlapping register regions and the like, and can deal with the
ethernet driver wanting to access the SMI registers as well.

We would need the ethernet driver to be capable of instantiation even
with no ports enabled, so cases where the MDIO interface is used with
other ethernet controllers continues to be supportable (eg, the
Armada 8040 case where the slave CP110 ethernet controller is used
with PHYs connected to the master CP110 ethernet controller's MDIO
buses - which afaik aren't shared between the two CP110 dies.)

However, I'd like to see libphy become more flexible and support
hardware polled mode of operation, since libphy provides a nice
library of functions for accessing various phy features (like setting
the advertisment, EEE modes, flow control, etc.)  Even with hardware
polling, we should still describe the PHY in DT, because PHY is part
of the hardware description, and we need to know where it is in order
to program these phy features.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
