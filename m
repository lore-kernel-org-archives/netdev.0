From: Matt Domsch <Matt_Domsch@dell.com>
Subject: Re: PATCH: Network Device Naming mechanism and policy
Date: Sat, 10 Oct 2009 07:47:32 -0500
Message-ID: <20091010124731.GA17218@mock.linuxdev.us.dell.com>
References: <EDA0A4495861324DA2618B4C45DCB3EE5894ED@blrx3m08.blr.amer.dell.com> <20091009140000.GA18765@mock.linuxdev.us.dell.com> <20091009210909.GA9836@auslistsprd01.us.dell.com> <20091009194401.036da080@nehalam> <20091010044056.GA5350@mock.linuxdev.us.dell.com> <20091010052308.GA12458@kroah.com>
Reply-To: Matt Domsch <Matt_Domsch@dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	linux-hotplug@vger.kernel.org, Narendra_K@dell.com,
	jordan_hargrave@dell.com
To: Greg KH <greg@kroah.com>
Return-path: <linux-hotplug-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20091010052308.GA12458@kroah.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 09, 2009 at 10:23:08PM -0700, Greg KH wrote:
> On Fri, Oct 09, 2009 at 11:40:57PM -0500, Matt Domsch wrote:
> > The fundamental roadblock to this is that enumeration != naming,
> > except that it is for network devices, and we keep changing the
> > enumeration order.
> 
> No, the hardware changes the enumeration order, it places _no_
> guarantees on what order stuff will be found in.  So this is not the
> kernel changing, just to be clear.

Over time the kernel has changed its enumeration mechanisms, and
introduced parallelism into the process (which is a good thing),
which, from a user perspective, makes names nondeterministic.  Yes,
fixing this up by hard-coding MAC addresses after install has been
the traditional mechanism to address this.  I think there's a better
way.

> Again, I have a machine here that likes to reorder PCI devices every 4th
> or so boot times, and that's fine according to the PCI spec.  Yeah, it's
> a crappy BIOS, but the manufacturer rightly pointed out that it is not
> in violation of anything.

I haven't encounted this myself, but yes, it's valid but annoying.
 
> > Today, port naming is completely nondeterministic.  If you have but
> > one NIC, there are few chances to get the name wrong (it'll be eth0).
> > If you have >1 NIC, chances increase to get it wrong.
> 
> That is why all distros name network devices based on the only
> deterministic thing they have today, the MAC address.  I still fail to
> see why you do not like this solution, it is honestly the only way to
> properly name network devices in a sane manner.
>
> All distros also provide a way to easily rename the network devices, to
> place a specific name on a specific MAC address, so again, this should
> all be solved already.

It's not the only way, it introduces state where there's a desire for
a stateless solution, it's useless for getting all the names right at
initial OS install time, and it restricts us to a single "name" for a
given device.

We can get additional information from BIOS.  SMBIOS 2.6 (types 9 and
41) has the fields to let us get a "label" for an device at a given
b/d/f.  On my PowerEdge R610, I see "Embedded NIC 1" .. "Embedded NIC
4" for the 4 LOMs.  These labels have a clear correlation to the
labels on the back of the chassis at these ports.  biosdevname can
parse and report this.  HP made a similar vendor-specific extension to
SMBIOS for their platforms, which biosdevname also parses.  Even if
BIOS decides they need to renumber the busses on every boot, it can
keep this table correct.  (insert general mistrust of BIOS authors
rant; that's not the point here.)

biosdevname can be used in udev rules to create multiple names for a
given device.  Rules such as:

 PROGRAM="/sbin/biosdevname --policy=all_names -i %k", SYMLINK+="net/by-slot-name/%c", OPTIONS+="string_escape=replace"
 PROGRAM="/sbin/biosdevname --policy=smbios_names -i %k", SYMLINK+="net/by-chassis-label/%c", OPTIONS+="string_escape=replace"

SMBIOS has its own problems, specifically that it's not hot-plug
aware (it's a static table created during POST).  And if a better way
is found (perhaps through the PCI SIG or ACPI), great, biosdevname can
be extended to use it.  But, without at least a change in udev or the
kernel, it doesn't do any good.
 
> No matter how badly your BIOS teams mess up the PCI enumeration
> order :)

In my case, the BIOS for a given system always configures the ports
the same way, and assigns b/d/f the same way.  With no change in the
BIOS or hardware, I still see the ports enumerated differently on each
boot. :-(



-- 
Matt Domsch
Technology Strategist, Dell Office of the CTO
linux.dell.com & www.dell.com/linux
