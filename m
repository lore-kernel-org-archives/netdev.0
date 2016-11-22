From: Jerome Brunet <jbrunet-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>
Subject: Re: [RFC PATCH net v2 2/3] dt: bindings: add ethernet phy
 eee-disable-advert option documentation
Date: Tue, 22 Nov 2016 11:13:57 +0100
Message-ID: <1479809637.17538.113.camel@baylibre.com>
References: <1479742524-30222-1-git-send-email-jbrunet@baylibre.com>
         <1479742524-30222-3-git-send-email-jbrunet@baylibre.com>
         <20161121160149.GF1922@lunn.ch> <1479744993.17538.85.camel@baylibre.com>
         <20161121164733.GG1922@lunn.ch>
         <e792c889-8725-3952-ca28-a08537d9f87a@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Alexandre TORGUE <alexandre.torgue-qxv4g6HH51o@public.gmane.org>,
        Neil Armstrong <narmstrong-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>,
        Martin Blumenstingl <martin.blumenstingl-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>,
        Kevin Hilman <khilman-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andre Roth <neolynx-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        linux-amlogic-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, Carlo Caione <carlo-KA+7E9HrN00dnm+yROfE0A@public.gmane.org>,
        Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
        linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <e792c889-8725-3952-ca28-a08537d9f87a-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2016-11-21 at 21:35 -0800, Florian Fainelli wrote:
> Le 21/11/2016 à 08:47, Andrew Lunn a écrit :
> > 
> > > 
> > > What I did not realize when doing this patch for the realtek
> > > driver is
> > > that there is already 6 valid modes defined in the kernel
> > > 
> > > #define MDIO_EEE_100TX		MDIO_AN_EEE_ADV_100TX	
> > > /*
> > > 100TX EEE cap */
> > > #define MDIO_EEE_1000T		MDIO_AN_EEE_ADV_1000T	
> > > /*
> > > 1000T EEE cap */
> > > #define MDIO_EEE_10GT		0x0008	/* 10GT EEE
> > > cap */
> > > #define MDIO_EEE_1000KX		0x0010	/* 1000KX
> > > EEE cap
> > > */
> > > #define MDIO_EEE_10GKX4		0x0020	/* 10G KX4
> > > EEE cap
> > > */
> > > #define MDIO_EEE_10GKR		0x0040	/* 10G KR EEE
> > > cap
> > > */
> > > 
> > > I took care of only 2 in the case of realtek.c since it only
> > > support
> > > MDIO_EEE_100TX and MDIO_EEE_1000T.
> > > 
> > > Defining a property for each is certainly doable but it does not
> > > look
> > > very nice either. If it extends in the future, it will get even
> > > more
> > > messier, especially if you want to disable everything.
> > 
> > Yes, agreed.
> 
> One risk with the definition a group of advertisement capabilities
> (under the form of a bitmask for instance) to enable/disable is that
> we
> end up with Device Tree contain some kind of configuration policy as
> opposed to just flagging particular hardware features as broken.

The code proposed only allows to disable EEE advertisement (not
enable), so we should not see it used as a configuration policy in DT.
To make this more explicit, I could replace the property "eee-advert-
disable" by "eee-broken" ?

> 
> Fortunately, there does not seem to be a ton of PHYs out there which
> require EEE

It is quite difficult to have the real picture here because some PHYs
have EEE disabled by default and you have to explicitly enable it.
I have no idea of the ratio between the 2 phy policies.

> to be disabled to function properly so having individual
> properties vs. bitmasks/groups is kind of speculative here.

In the particular instance of the OdroidC2, disabling EEE for GbE only
enough. However, If you have a PHY broken with, I think it is likely
that you might want to disable all (supported) EEE modes. That's reason
why I prefer bitmask. I agree both are functionally similar, this is
kind of a cosmetic debate.

> 
> Another approach to solving this problem could be to register a PHY
> fixup which disables EEE at the PHY level, and which is only called
> for
> specific boards affected by this problem
> (of_machine_is_compatible()).
> This code can leave in arch/*/* when that is possible, 

That something I was looking at, but we don't have these files anymore
on ARM64 (looking at your comment, you already know this)

> or it can just be
> somewhere where it is relevant, e.g; in the PHY driver for instance
> (similarly to how PCI fixups are done).

Do you prefer having board specific code inside generic driver than
having the setting living in DT? Peppe told me they also had a few
platform with similar issues. The point is that this could be useful to
other people, so it could spread a grow a bit.

I would prefer having this in the DT, but I can definitely do it the
PHY with of_machine_is_compatible() and register_fixup is this what you
prefer/want. 

Cheers
Jerome


--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
