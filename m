From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] r8152: Add support for setting MAC to system's Auxiliary
 MAC address
Date: Thu, 2 Jun 2016 09:09:02 -0700
Message-ID: <20160602160902.GA27948@kroah.com>
References: <1464817844-27206-1-git-send-email-mario_limonciello@dell.com>
 <20160601230535.GA29279@kroah.com>
 <0bdb98b72b884682b936c0587f965629@ausx13mpc124.AMER.DELL.COM>
 <20160602152244.GA26494@kroah.com>
 <6d9575fd791c4e25b464b9a1b11daa83@ausx13mpc124.AMER.DELL.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hayeswang@realtek.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	pali.rohar@gmail.com, anthony.wong@canonical.com
To: Mario_Limonciello@Dell.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <6d9575fd791c4e25b464b9a1b11daa83@ausx13mpc124.AMER.DELL.COM>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 02, 2016 at 03:46:41PM +0000, Mario_Limonciello@Dell.com wrote:
> > >
> > > This isn't something part of ACPI - it's been added specifically for a
> > > selection of Dell machines.
> > 
> > Ah, but isn't ACPI supposed to be a "standard"?  :)
> > 
> 
> Heh.
> It's also possible to get this from an SMM routine.  Lesser of two evils to fetch the information this way, right? :)

Yes, but again, please only do this for machines you _know_ this value
will be present on.  Otherwise you will end up with problems.

> > And please wrap your email lines, there is a "standard" for that...
> 
> I'm unfortunately not limited to an evil mail client at my workplace since our mail server migration.   My apologies, I've got it set to wrap at 76 characters and I'm trying to make it as LKML friendly as possible.

It's not working as you can see here :(

> > > I would rather not hardcode to the specific DMI model strings of those
> > > Dell machines as it's certainly going to be a feature that expands to
> > > more machines.  Since it is Dell specific though, if you would rather
> > > me just match to the sys vendor Dell Inc., that seems like a pretty
> > > good compromise to me.
> > 
> > You need to only do this on machines you "know" have this set to a correct
> > value, otherwise if some other random BIOS happens to set that field to
> > some random value, you will have problems.
> 
> Pali had recommended in another message to check the buffer header.  I was intending to do this along with check ACPI buffer output type, and output size in the next revision I submitted.  By switching to hex2bin, I'll also validate that the string has correct values (0-F or 0-f).  If somehow all of that fails, the set_ethernet_addr  checks if the address is valid.  If it's invalid it will generate a random one.

Why generate a random one and not just use the one that the network
controler already provides?

And yes, you better error check the heck out of this before you set it.

> > > With E-docks they were really just extensions of the pins for the
> > > already onboard NIC of the system.  When you docked in an E-dock you
> > > inherently would use the same MAC everywhere you went.  If you had two
> > > cubes your network admin would see your same MAC in both.
> > >
> > > With TBT docks and this patch not present docking in different places
> > > will give you the MAC of the dock rather than something persistent
> > > that your network admin could identify.  Solving this was something
> > > that was explicitly asked for in case studies during conceptualization
> > > of these docks and is a feature present in the Realtek Windows driver.
> > 
> > But you are dealing with different "devices" here, thunderbolt is a PCI
> > device, not a "pin pass-through", and to treat it differently like you want to is
> > going to cause confusion as well.
> 
> Is it not also going to be confusing if someone boots Windows and Linux on the same laptop and has a different behavior with their dock's MAC address?  I'm trying to get parity here for organizations that are supporting both Windows and Linux for their employees.

Those few orginizations can use a userspace script for this :)

> > > In addition to limiting to Dell DMI system vendor string how about I do two
> > more things about this:
> > >
> > > 1) Add a module parameter to disable this behavior altogether in r8152 if
> > it's not desired by the user or admin (but leave it on by default).
> > 
> > No module parameters, this isn't the 1990's anymore, and you aren't going to
> > be modifying module config files for everyone, are you?
> > 
> > And this seems like a "default" that should be turned off anyway, as it goes
> > against the model of all of our other network devices in Linux.
> > 
> > > 2) Track whether this is the first or second USB NIC plugged in.  Only offer it
> > on the first NIC detected by r8152.  When the second NIC is plugged in don't
> > match from ACPI.
> > > There would be a question of what to do if the first NIC is removed and
> > added back if it should get the persistent system MAC or not.
> > > I'd say yes, just make sure that only one NIC can have it at a time.
> > 
> > You are going to get things very complex very quickly if you try to do this.
> 
> It's really not that hard, track a module wide static variable whether the feature is in use.  Track in each device whether the feature was in use.  If it in use, don't assign the next device plugged in via the ACPI string.  If a device is removed that has the feature activated, change the module wide static variable.

Ok, let's see the code before I say anymore about this.

> > What's wrong with a "simple" script to set the mac address from userspace if
> > the user wants something like this?  Provide it as a system package and then
> > no kernel changes are needed at all.  Much easier to support on your end
> > (you don't have to maintain this odd kernel code for
> > 10+ years), the default behavior is as Linux users expect, and your
> > limited number of people who want this crazy behaviour can install your
> > script if they want it.
> > 
> 
> This was my original approach.  It involved a network manager script, network manager code changes to support this, and exposing this somewhere in a platform module (like dell-laptop).  I was told I'm better off doing it directly in the network module, so here I am.

Why not a small systemd unit file for this that sets things up when the
device is found in the system?  Why mess with network manager and a
platform kernel driver at all?  That seems very complex for such a
simple operation where the kernel doesn't need to be involved at all,
especially for such a "niche" product.

See this link:
	https://wiki.archlinux.org/index.php/MAC_address_spoofing#Automatically

for an example of how to do this in a simple manner.

thanks,

greg k-h
