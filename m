From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] r8152: Add support for setting MAC to system's Auxiliary
 MAC address
Date: Thu, 2 Jun 2016 08:22:44 -0700
Message-ID: <20160602152244.GA26494@kroah.com>
References: <1464817844-27206-1-git-send-email-mario_limonciello@dell.com>
 <20160601230535.GA29279@kroah.com>
 <0bdb98b72b884682b936c0587f965629@ausx13mpc124.AMER.DELL.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hayeswang@realtek.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	pali.rohar@gmail.com, anthony.wong@canonical.com
To: Mario_Limonciello@Dell.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <0bdb98b72b884682b936c0587f965629@ausx13mpc124.AMER.DELL.COM>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 02, 2016 at 02:10:37AM +0000, Mario_Limonciello@Dell.com wrote:
> > -----Original Message-----
> > From: Greg KH [mailto:gregkh@linuxfoundation.org]
> > Sent: Wednesday, June 1, 2016 6:06 PM
> > To: Limonciello, Mario <Mario_Limonciello@Dell.com>
> > Cc: hayeswang@realtek.com; LKML <linux-kernel@vger.kernel.org>; Netdev
> > <netdev@vger.kernel.org>; Linux USB <linux-usb@vger.kernel.org>;
> > pali.rohar@gmail.com; anthony.wong@canonical.com
> > Subject: Re: [PATCH] r8152: Add support for setting MAC to system's Auxiliary
> > MAC address
> > 
> > On Wed, Jun 01, 2016 at 04:50:44PM -0500, Mario Limonciello wrote:
> > > Dell systems with Type-C ports have support for a persistent system
> > > specific MAC address when used with Dell Type-C docks and dongles.
> > > This means a dock plugged into two different systems will show
> > > different (but persistent) MAC addresses.  Dell Type-C docks and
> > > dongles use the
> > > r8152 driver.
> > >
> > > This information for the system's persistent MAC address is burned in
> > > when the HW is built and avilable under _SB\AMAC in the DSDT at runtime.
> > >
> > > More information about the technology is available here:
> > > http://www.dell.com/support/article/us/en/04/SLN301147
> > >
> > > Signed-off-by: Mario Limonciello <mario_limonciello@dell.com>
> > > ---
> > >  drivers/net/usb/Kconfig |  1 +
> > >  drivers/net/usb/r8152.c | 37 +++++++++++++++++++++++++++++++++++++
> > >  2 files changed, 38 insertions(+)
> > >
> > > diff --git a/drivers/net/usb/Kconfig b/drivers/net/usb/Kconfig index
> > > cdde590..c320930 100644
> > > --- a/drivers/net/usb/Kconfig
> > > +++ b/drivers/net/usb/Kconfig
> > > @@ -98,6 +98,7 @@ config USB_RTL8150
> > >  config USB_RTL8152
> > >  	tristate "Realtek RTL8152/RTL8153 Based USB Ethernet Adapters"
> > >  	select MII
> > > +	depends on ACPI
> > >  	help
> > >  	  This option adds support for Realtek RTL8152 based USB 2.0
> > >  	  10/100 Ethernet adapters and RTL8153 based USB 3.0 10/100/1000
> > > diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c index
> > > 3f9f6ed..62af3b4 100644
> > > --- a/drivers/net/usb/r8152.c
> > > +++ b/drivers/net/usb/r8152.c
> > > @@ -26,6 +26,7 @@
> > >  #include <linux/mdio.h>
> > >  #include <linux/usb/cdc.h>
> > >  #include <linux/suspend.h>
> > > +#include <linux/acpi.h>
> > >
> > >  /* Information for net-next */
> > >  #define NETNEXT_VERSION		"08"
> > > @@ -1030,6 +1031,39 @@ out1:
> > >  	return ret;
> > >  }
> > >
> > > +static u8 amac_ascii_to_hex(int c)
> > > +{
> > > +	if (c <= 0x39)
> > > +		return (u8)(c - 0x30);
> > > +	else if (c <= 0x46)
> > > +		return (u8)(c - 0x37);
> > > +	return (u8)(c - 0x57);
> > > +}
> > 
> > We really don't have such a function somewhere in the kernel already?
> > 
> > And why 'int', isn't "c" really a u8?
> > 
> > > +static void set_auxiliary_addr(struct sockaddr *sa) {
> > > +	acpi_status status;
> > > +	acpi_handle handle;
> > > +	struct acpi_buffer buffer = { ACPI_ALLOCATE_BUFFER, NULL };
> > > +	union acpi_object *obj;
> > > +	int i;
> > > +	char *ptr;
> > > +
> > > +	acpi_get_handle(NULL, "\\_SB", &handle);
> > > +	status = acpi_evaluate_object(handle, "AMAC", NULL, &buffer);
> > 
> > Is this field in the ACPI standard, or should this only be "trusted" on a limited
> > number of machines (i.e. with Dell DMI strings?)
> > 
> 
> This isn't something part of ACPI - it's been added specifically for a
> selection of Dell machines.  

Ah, but isn't ACPI supposed to be a "standard"?  :)

And please wrap your email lines, there is a "standard" for that...

> I would rather not hardcode to the specific DMI model strings of those
> Dell machines as it's certainly going to be a feature that expands to
> more machines.  Since it is Dell specific though, if you would rather
> me just match to the sys vendor Dell Inc., that seems like a pretty
> good compromise to me.

You need to only do this on machines you "know" have this set to a
correct value, otherwise if some other random BIOS happens to set that
field to some random value, you will have problems.

> > And finally, this seems odd overall given that a MAC address should be
> > associated with the specific network device, not the overall system.
> 
> The whole reasoning behind this is to bring the behavior that E-Docks
> had to TBT docks.

What is "TBT"?

> With E-docks they were really just extensions of the pins for the
> already onboard NIC of the system.  When you docked in an E-dock you
> inherently would use the same MAC everywhere you went.  If you had two
> cubes your network admin would see your same MAC in both.
> 
> With TBT docks and this patch not present docking in different places
> will give you the MAC of the dock rather than something persistent
> that your network admin could identify.  Solving this was something
> that was explicitly asked for in case studies during conceptualization
> of these docks and is a feature present in the Realtek Windows driver.

But you are dealing with different "devices" here, thunderbolt is a PCI
device, not a "pin pass-through", and to treat it differently like you
want to is going to cause confusion as well.

> > What if you have 2 types of devices plugged into the same machine, with this
> > patch you suddenly have the same MAC address for both of them.
> > That doesn't seem correct...
> > 
> 
> I suppose it is technically possible to have two USB NIC's that use r8152 and that would be a bad behavior indeed to hand the same MAC to both of them.

Yes, and it will happen.

> In addition to limiting to Dell DMI system vendor string how about I do two more things about this:
> 
> 1) Add a module parameter to disable this behavior altogether in r8152 if it's not desired by the user or admin (but leave it on by default).

No module parameters, this isn't the 1990's anymore, and you aren't
going to be modifying module config files for everyone, are you?

And this seems like a "default" that should be turned off anyway, as it
goes against the model of all of our other network devices in Linux.

> 2) Track whether this is the first or second USB NIC plugged in.  Only offer it on the first NIC detected by r8152.  When the second NIC is plugged in don't match from ACPI.  
> There would be a question of what to do if the first NIC is removed and added back if it should get the persistent system MAC or not.  
> I'd say yes, just make sure that only one NIC can have it at a time.

You are going to get things very complex very quickly if you try to do
this.

What's wrong with a "simple" script to set the mac address from
userspace if the user wants something like this?  Provide it as a system
package and then no kernel changes are needed at all.  Much easier to
support on your end (you don't have to maintain this odd kernel code for
10+ years), the default behavior is as Linux users expect, and your
limited number of people who want this crazy behaviour can install your
script if they want it.

thanks,

greg k-h
