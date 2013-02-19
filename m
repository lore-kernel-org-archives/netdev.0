From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [PATCH v2 0/5] Generic PHY Framework
Date: Tue, 19 Feb 2013 12:33:54 +0000
Message-ID: <201302191233.54677.arnd@arndb.de>
References: <1361253198-7401-1-git-send-email-kishon@ti.com> <201302191044.28653.arnd@arndb.de> <512361F0.1070500@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: rob-VoJi6FS/r0vR7s880joybQ@public.gmane.org, tony-4v6yS6AI5VpBDgjK7y7TUQ@public.gmane.org, linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org,
	eballetbo-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, javier-0uQlZySMnqxg9hUCZPvPmw@public.gmane.org, balbi-l0cyMroinI0@public.gmane.org,
	gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	mchehab-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, cesarb-PWySMVKUnqmsTnJN9+BGXg@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	santosh.shilimkar-l0cyMroinI0@public.gmane.org, broonie-yzvPICuk2AATkU/dhu1WVueM+bqZidxxQQ4Iyu8u01E@public.gmane.org,
	swarren-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org, linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: kishon <kishon-l0cyMroinI0@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <512361F0.1070500-l0cyMroinI0@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tuesday 19 February 2013, kishon wrote:
> On Tuesday 19 February 2013 04:14 PM, Arnd Bergmann wrote:
> > On Tuesday 19 February 2013, Kishon Vijay Abraham I wrote:
> >> Added a generic PHY framework that provides a set of APIs for the PHY drivers
> >> to create/destroy a PHY and APIs for the PHY users to obtain a reference to
> >> the PHY with or without using phandle. To obtain a reference to the PHY
> >> without using phandle, the platform specfic intialization code (say from board
> >> file) should have already called phy_bind with the binding information. The
> >> binding information consists of phy's device name, phy user device name and an
> >> index. The index is used when the same phy user binds to mulitple phys.
> >>
> >> This framework will be of use only to devices that uses external PHY (PHY
> >> functionality is not embedded within the controller).
> >>
> >> The intention of creating this framework is to bring the phy drivers spread
> >> all over the Linux kernel to drivers/phy to increase code re-use and to
> >> increase code maintainability.
> >>
> >> Comments to make PHY as bus wasn't done because PHY devices can be part of
> >> other bus and making a same device attached to multiple bus leads to bad
> >> design.
> >
> > How does this relate to the generic PHY interfaces in drivers/net/phy?
> 
> Currently drivers/phy and drivers/net/phy are independent and are not 
> related to each other. There are some fundamental differences on how 
> these frameworks work. IIUC, the *net* uses bus layer (MDIO bus) to 
> match a PHY device with a PHY driver and the Ethernet device uses the 
> bus layer to get the PHY.
> The Generic PHY Framework however doesn't have any bus layer. The PHY 
> should be like any other Platform Devices and Drivers and the framework 
> will provide some APIs to register with the framework. And there are 
> other APIs which any controller can use to get the PHY (for e.g., in the 
> case of dt boot, it can use phandle to get a reference to the PHY).

Hmm, I think the use of a bus_type for a PHY actually sounds quite
appropriate. The actual PHY device would then be a child of the
platform_device (or something else) that gets probed by its parent
bus or the DT. The operations that you define for the PHY
actually mirror some of the things that we have for a 'struct device',
so I think it would be quite logical to do it the same way.

Note that MDIO has both a 'bus' and a 'class', and what we want here is more
like what the 'class' was meant for, except that for new classes, we
should actually use a 'bus', since the long-term plan is to kill off
the concept of a 'class'. I hope that was not too confusing. :)

> > Do you expect that to get merged into drivers/phy in the long run, or
> > do you want to keep the generic phy only for everything but ethernet?
> 
> We'd like the PHY drivers spread all over the kernel to get merged to 
> drivers/phy including Ethernet. Having said that, Ethernet itself has a 
> huge PHY framework and it's going to be little challenging to adapt to 
> the new PHY framework (of course there'll be changes in this PHY 
> framework when we want to have network PHY added here). But adapting USB 
> PHYs to the new framework will be simpler and will be taken first. Also 
> when we add SATA PHY (OMAP5), it will make use of this framework as both 
> SATA and USB3 uses the same PHY IP.

I think you need to have at least a concept of where you want to end up.
It's totally fine to introduce a new subsystem that does only the
minimum of what you need here, and add things as you go, but if you
already plan to merge the existing mdio bus into this, you should really
have an idea of what that will mean in the long run.

> > I think it would be problematic to have two alternative interfaces for
> > ethernet PHYs because then an ethernet driver still needs to decide
> > which subsystem to interface with.
> 
> Right. For now Ethernet should continue to use their own PHY abstraction 
> layer till we are a bit more clear on how to move it to drivers/phy.

Ok.

	Arnd
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
