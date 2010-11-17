From: Matt Domsch <Matt_Domsch@dell.com>
Subject: extended netdevice naming proposal
Date: Wed, 17 Nov 2010 16:06:59 -0600
Message-ID: <20101117220659.GA12177@auslistsprd01.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jcm@redhat.com, notting@redhat.com
To: linux-hotplug@vger.kernel.org, netdev@vger.kernel.org,
	narendra_k@dell.com
Return-path: <linux-hotplug-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

While this _is_ the original bikeshedding problem, as long as I'm
going to use biosdevname to change names for embedded NICs, perhaps I
can be so bold as to change them for USB add-in cards too?

There are quite a few dimensions to the problem:
* device location (onboard, PCI, other bus)
* multiple ports on a single add-in card
* with Network Partitioning (NPAR) and SR-IOV, the OS sees multiple
  network interfaces (physical or virtual interfaces) but a single external port
* the suffix .1234 currently used for vlans (ala vconfig)
* A single PCI device may drive multiple external ports

As such, here is a naming proposal, aimed to keep within 15
characters for most configurations.

(location)(slot)#(port)/(instance).(vlan)

location := NIC on Motherboard = net1, net2, net3, net4
   (note: people hated the TLA collision with 'lom', so avoiding that here).
         := PCI slot = pci1, pci2, pci3, pci4
 these correspond to chassis labels, information is available in
 $PIRQ, SMBIOS or ACPI, which biosdevname retrieves and uses.

For single- or multi-port cards in PCI slots, append #(port):
   pci1#1, pci1#2, pci1#3, pci1#4  for 4 ports on a card in PCI slot 1

There is currently no way to get this port info from BIOS.  Several people
have suggested using adding a PCI capabilities field to expose this
info in a standard way, but that's a ways off. Until then, biosdevname
can guess (assume ascending MAC order on the single card).

For NPAR/SR-IOV where the physical port is shared by several
instances, append /(instance):
   net1/1, net1/2 pci1#1/1, pci1#1/2,
   pci1#1/2, pci1#1/3, ...

For each of the above where vconfig sets up a vlan:
   pci1#/1.1000, pci1#1/2.1001, pci1#1/2.1003, pci1#1/3.1004, ...
vconfig simply appends .{vlan#} to the already  named device when creating a new vlan netdevice.

BIOS definitely doesn't know about these, as they aren't exposed until
after the OS is running, so the mechanism that creates them (such as
following modprobe ixgbevf) would have to, and I think that can be
done with a udev rule, if we can somehow expose the port number of the
underlying PF when we throw the message to udev on creation of the VF.

And of course, BIOS knows nothing about vlans, so vconfig would add that.


If we have no more than 99 PCI slots, no more than 99 ports on a
single card, no more than 999 instances/virtual functions (we need at
least 128, perhaps more than 256 at some point, so hex vs decimal
doesn't buy us much here), no more than 4k VLANs, we get:

len("pci99#99/999.4095") = 17

If we really have that many, we're in trouble in other ways, so let's
hope that's good enough.

Thoughts?  Overkill?

Thanks,
Matt

-- 
Matt Domsch
Technology Strategist
Dell | Office of the CTO
