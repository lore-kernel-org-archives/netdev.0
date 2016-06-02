From: <Mario_Limonciello@Dell.com>
Subject: RE: [PATCH] r8152: Add support for setting MAC to system's Auxiliary
 MAC address
Date: Thu, 2 Jun 2016 16:58:20 +0000
Message-ID: <5a22a497af9e467582221cd3a10c90ff@ausx13mpc124.AMER.DELL.COM>
References: <1464817844-27206-1-git-send-email-mario_limonciello@dell.com>
 <20160601230535.GA29279@kroah.com>
 <0bdb98b72b884682b936c0587f965629@ausx13mpc124.AMER.DELL.COM>
 <20160602152244.GA26494@kroah.com>
 <6d9575fd791c4e25b464b9a1b11daa83@ausx13mpc124.AMER.DELL.COM>
 <20160602160902.GA27948@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <hayeswang@realtek.com>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>, <linux-usb@vger.kernel.org>,
	<pali.rohar@gmail.com>, <anthony.wong@canonical.com>
To: <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160602160902.GA27948@kroah.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some of my comments are getting stale with what I've done in response to all these emails.
Let me send a v2 that we can better iterate on, a few comments below though.

> -----Original Message-----
> From: Greg KH [mailto:gregkh@linuxfoundation.org]
> Sent: Thursday, June 2, 2016 11:09 AM
> To: Limonciello, Mario <Mario_Limonciello@Dell.com>
> Cc: hayeswang@realtek.com; linux-kernel@vger.kernel.org;
> netdev@vger.kernel.org; linux-usb@vger.kernel.org; pali.rohar@gmail.com;
> anthony.wong@canonical.com
> Subject: Re: [PATCH] r8152: Add support for setting MAC to system's
> Auxiliary MAC address
> 
> On Thu, Jun 02, 2016 at 03:46:41PM +0000, Mario_Limonciello@Dell.com
> wrote:
> > > >
> > > > This isn't something part of ACPI - it's been added specifically for a
> > > > selection of Dell machines.
> > >
> > > Ah, but isn't ACPI supposed to be a "standard"?  :)
> > >
> >
> > Heh.
> > It's also possible to get this from an SMM routine.  Lesser of two evils to
> fetch the information this way, right? :)
> 
> Yes, but again, please only do this for machines you _know_ this value
> will be present on.  Otherwise you will end up with problems.

I'm going to send a V2, I'd like to know where and how this could still break. 
I am having a hard time grasping this.  

> 
> > > And please wrap your email lines, there is a "standard" for that...
> >
> > I'm unfortunately not limited to an evil mail client at my workplace since our
> mail server migration.   My apologies, I've got it set to wrap at 76 characters
> and I'm trying to make it as LKML friendly as possible.
> 
> It's not working as you can see here :(

Ugh, sorry.  Stupid outlook.  It seems to only be doing it on replies.
I'll manually just chop the lines when they're around that size until I've got a
better solution.

> 
> > > > I would rather not hardcode to the specific DMI model strings of those
> > > > Dell machines as it's certainly going to be a feature that expands to
> > > > more machines.  Since it is Dell specific though, if you would rather
> > > > me just match to the sys vendor Dell Inc., that seems like a pretty
> > > > good compromise to me.
> > >
> > > You need to only do this on machines you "know" have this set to a
> correct
> > > value, otherwise if some other random BIOS happens to set that field to
> > > some random value, you will have problems.
> >
> > Pali had recommended in another message to check the buffer header.  I
> was intending to do this along with check ACPI buffer output type, and
> output size in the next revision I submitted.  By switching to hex2bin, I'll also
> validate that the string has correct values (0-F or 0-f).  If somehow all of that
> fails, the set_ethernet_addr  checks if the address is valid.  If it's invalid it will
> generate a random one.
> 
> Why generate a random one and not just use the one that the network
> controler already provides?

That's how the flow works in r8152 already and I'm not overriding it.
Again, I'll send V2 and you'll see what I did.

> >
> > It's really not that hard, track a module wide static variable whether the
> feature is in use.  Track in each device whether the feature was in use.  If it in
> use, don't assign the next device plugged in via the ACPI string.  If a device is
> removed that has the feature activated, change the module wide static
> variable.
> 
> Ok, let's see the code before I say anymore about this.
> 
> > > What's wrong with a "simple" script to set the mac address from
> userspace if
> > > the user wants something like this?  Provide it as a system package and
> then
> > > no kernel changes are needed at all.  Much easier to support on your end
> > > (you don't have to maintain this odd kernel code for
> > > 10+ years), the default behavior is as Linux users expect, and your
> > > limited number of people who want this crazy behaviour can install your
> > > script if they want it.
> > >
> >
> > This was my original approach.  It involved a network manager script,
> network manager code changes to support this, and exposing this
> somewhere in a platform module (like dell-laptop).  I was told I'm better off
> doing it directly in the network module, so here I am.
> 
> Why not a small systemd unit file for this that sets things up when the
> device is found in the system?  Why mess with network manager and a
> platform kernel driver at all?  That seems very complex for such a
> simple operation where the kernel doesn't need to be involved at all,
> especially for such a "niche" product.
> 
> See this link:
> 	https://wiki.archlinux.org/index.php/MAC_address_spoofing#Auto
> matically
> 

The ACPI subsystem doesn't create a sysfs node for a random buffer under _SB.
I don't think the ACPI guys would be crazy about this either.

So you need a platform kernel driver to pull this out of ACPI (or SMM) and expose
into userspace somewhere in the first place.  I was putting it into a random sysfs
attribute when I did my first attempts at a userspace approach.

So I saw that wiki too, and tried that approach.  Network manager stomps all over
anything that systemd does in unit files and resets to the MAC address it declares 
was the HW MAC address from sysfs.

The other problem I encountered doing this in userspace was that because of the
renaming magic that exists now, you can't have a userspace script key off the device
as you move to to different places.  Dock in location A will rename eth0 to 
ethaabbccddeeff and dock in location B will rename to ethffeeddccbbaa.  

So my next approach was use a system unit file to rename the device to 
"delldock%x" and then use network manager to key off that.
