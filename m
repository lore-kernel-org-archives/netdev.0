From: Matt Domsch <Matt_Domsch@dell.com>
Subject: Re: Network Device Naming mechanism and policy
Date: Thu, 26 Mar 2009 11:39:55 -0500
Message-ID: <20090326163955.GA22398@auslistsprd01.us.dell.com>
References: <20090324154617.GA16332@auslistsprd01.us.dell.com> <20090324.155756.214460004.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-hotplug@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-hotplug-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090324.155756.214460004.davem@davemloft.net>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 24, 2009 at 03:57:56PM -0700, David Miller wrote:
> From: Matt Domsch <Matt_Domsch@dell.com>
> Date: Tue, 24 Mar 2009 10:46:17 -0500
> 
> > Problem: Users expect on-motherboard NICs to be named eth0..ethN.
> > This can be difficult to achieve.
> 
> I learned a long time ago that eth0 et al. have zero meaning.
> 
> If the system firmware folks gave us topology information with respect
> to these things, we could export something that tools such as
> NetworkManager, iproute2, etc. could use.
> 
> For example, if we were told that PCI device "domain:bus:dev:fn" has
> string label "Onboard Ethernet 0" then we could present that to the
> user.
> 
> Changing how the actual network device name is determined is going to
> have zero traction.
> 
> So, please, put mapping tables into the ACPI or similar and then
> programs can go:
> 
> 	for_each_network_device(name) {
> 		fd = open(name);
> 		label = get_system_label(fd, name);
> 		present_to_user(label, name);
> 	}


Your wish is my command.  DMTF SMBIOS 2.6 specification
http://www.dmtf.org/standards/smbios/ contains changes which provide
this for PCI devices.

Specifically, Type 9 ("System Slots") was extended to include the PCI
domain/bus/device/function for each slot.  Type 10 ("On Board Devices
Information") could not be extended, thus it was deprecated, and new
Type 41 ("Onboard Devices Extended Information") was created to be
extensible and now includes PCI domain/bus/device/function
information.  Both Type 9 and Type 41 include a String field which
hopefully has a more descriptive value, such as "Onboard Ethernet
Broadcom 5808 NIC 1" in the case of some Dell servers.

Shipping Dell 10G (and very soon 11G) server BIOS includes this
information.  biosdevname can use this to report device names.  Some
HP systems have a vendor-specific SMBIOS extension to provide a
similar mapping; biosdevname can report this as well.

> This "get_system_label()" thing can be an ethtool ioctl, some
> rtnetlink call, or similar.  In the kernel, a generic routine would
> exist for major bus types to make the mapping translation, and drivers
> would call these.
>
> For PCI it might take the PCI device pointer and try to fish
> out a string from the ACPI layer.
> 
> For OpenFirmware we might just simply give the full device path,
> or a matching device alias name.
> 
> That's the only model which allows a smooth transition and
> no major infrastructure changes.

While I'd be happy for NetworkManager to present these SMBIOS-provided
human-parsable names when available, the names aren't terribly
meaningful in a programatic fashion.  The users I've encountered are
looking for a programatic way to say:

  The first LOM is my management/admin NIC.  The second LOM is my bulk
  traffic NIC.  The first add-in card is my backup NIC.

meaning we still need a translation from "how I want to use a NIC" to
"which NIC should I plug the cable into".  The SMBIOS names don't
completely solve this.

Hence my desire of having a way to have multiple alternate names for
the same interface.  One such name would be the full SMBIOS string.
Another would be a bus topology name. A third could be a "how do I use
it" name.  Analogous to devices represented in /dev using symlinks for
these other names.  I don't care if it's symlinks in /dev or some
other mechanism.

Thanks,
Matt

-- 
Matt Domsch
Linux Technology Strategist, Dell Office of the CTO
linux.dell.com & www.dell.com/linux
