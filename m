From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH 2/2] platform: Facilitate the creation of pseudo-platform buses
Date: Thu, 19 Aug 2010 16:22:41 -0600
Message-ID: <AANLkTinaddiPAcokH3fRVYAFf3N-Gz--U5Jd1iyNsi+m@mail.gmail.com>
References: <1281484174-32174-1-git-send-email-ppannuto@codeaurora.org>
 <1281484174-32174-3-git-send-email-ppannuto@codeaurora.org>
 <3F978429-F916-42E5-8B36-6AC02DAC8CA2@boeing.com> <AANLkTi=Pm8BL+Ksq1o7MYpV7mMH10bEPu1=Am9EgT-Kk@mail.gmail.com>
 <87hbiql89d.fsf@deeprootsystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Moffett, Kyle D" <Kyle.D.Moffett@boeing.com>,
	Patrick Pannuto <ppannuto@codeaurora.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-arm-msm@vger.kernel.org" <linux-arm-msm@vger.kernel.org>,
	"magnus.damm@gmail.com" <magnus.damm@gmail.com>,
	"gregkh@suse.de" <gregkh@suse.de>,
	Paul Mundt <lethal@linux-sh.org>,
	Magnus Damm <damm@opensource.se>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Eric Miao <eric.y.miao@gmail.com>,
	Dmitry Torokhov <dtor@mail.ru>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Kyle D Moffett <kyle@moffetthome.net>
To: Kevin Hilman <khilman@deeprootsystems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:56565 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753502Ab0HSWXD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 18:23:03 -0400
In-Reply-To: <87hbiql89d.fsf@deeprootsystems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 19, 2010 at 1:20 PM, Kevin Hilman
<khilman@deeprootsystems.com> wrote:
>> There is no mechanism to allow drivers from one bus type to also be
>> made available to another bus type. Certainly it would be possible t=
o
>> invent a mechanism, but the more I think about it, them more I think
>> it will be a bad idea. =A0The runtime-PM use-case that kicked this
>> discussion off makes the assumption that a driver will behave
>> identically when attached to either the platform_bus_type or the
>> soc_bus_type. =A0However, I think that in the general case that
>> assumption will prove to be false. =A0I strongly suspect that the ne=
w
>> bus type will turn out to be not as similar to the platform_bus_type
>> as originally assumed and that there will still be bus-type-specific
>> impact on device drivers
>
> What makes you suspect that? =A0Maybe Patrick has other use-cases in =
mind,
> but from a PM perspective, I have not seen any impact.

Call it a gut reaction if you like, but here's my line of thinking.
In your use case, sure, there is zero impact on drivers, but will that
continue to be the case for other bus architectures as they use this
interface?  Or, in other words, will this solution end up being short
sighted and we'll be having this discussion all over again in a year?

The big concern for me is the idea of partial divergence from the
platform_bus_type (specifically having different bus_type, but same
pool of drivers).  For starts, how is it represented in the device
model?  Where do the device drivers live in /sys/bus/*/drivers?  What
happens when one bus type is unregistered but has drivers used by
another bus type?  Does it scale to the (granted, currently
speculative) use-case where the device driver does need knowledge
about which bus_type it is registered against?  I'm also concerned
about the complexity required to implement driver sharing and ensuring
that correct locking and consistency is maintained between bus_types.

Note: I consider partial divergence to be different from
platform_bus_type inheritance which Patrick has been implementing.  I
don't have a technical issue with inheritance (drivers aren't shared),
I'm just not convinced it is the best solution yet.  :-)

My other thought is this:  If from both the device perspective and the
driver perspective the interface is exactly the same as the
platform_bus_type, then platform_bus_type really is the correct
interface.  That says to me that putting the runtime PM behaviour into
a new bus_type is abstracting at the wrong level, and a different
method should be used to modify PM behaviour, either based on device
model topology (ie, the parent implement's the child's runtime PM
behaviour), or maybe a "struct dev_pm_ops *bus_pm" in the struct
device.

However, the number of device drivers affected is still very small,
and I don't have concerns if each driver registers itself on multiple
bus types explicitly.  For example:

static struct platform_driver omap2_mcspi_platform_driver =3D {
        .driver =3D {
                .name =3D         "omap2_mcspi",
                .owner =3D        THIS_MODULE,
        },
        .probe =3D omap2_mcspi_probe,
        .remove =3D       __exit_p(omap2_mcspi_remove),
};
static struct platform_driver omap2_mcspi_omap_driver =3D {
        .driver =3D {
                .name =3D         "omap2_mcspi",
                .owner =3D        THIS_MODULE,
        },
        .probe =3D omap2_mcspi_probe,
        .remove =3D       __exit_p(omap2_mcspi_remove),
};

static int __init omap2_mcspi_init(void)
{
        platform_driver_register(&omap2_mcspi_platform_driver);
        omap_driver_register(&omap2_mcspi_omap_driver);
}
module_init(omap2_mcspi_init);

I'd even be okay with a helper function that kmemdups() a
platform_driver and registers it onto multiple busses.  Then if the
driver ever really does need to be differentiated, then the driver can
stop using the helper function and provide a different probe hook for
each registration.

> One of the primary goals of this (at least for me and it seems Magnus=
 also)
> is to keep drivers ignorant of their bus type, and any bus-type-speci=
fic
> code should be done in the bus_type implementation.

Heh; which just screams to me that bus_type is the wrong level to be
abstracting the behaviour (but I also understand your need for the
"omap_device" wrapper around platform_device which also requires some
method to sort out when a platform_device really is an omap_device
without an unsafe dereference).

> Both for SH and OMAP, we've been using the (admiteddly broken)
> weak-symbol-override approach to getting a custom bus-type based on t=
he
> platform_bus. =A0We've been using that in OMAP for a while now and ha=
ve
> not seen any need to for the drivers to know if they are on the vanil=
la
> platform_bus or the customized one.
>
> I'm very curious to hear what type of impact you expect to the driver=
s.

My fears on this point may very well be unfounded.  This isn't the
hill I'm going to die on either.  Show me an implementation of driver
sharing that is clean and prove me wrong!  :-)

Cheers,
g.

--=20
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
