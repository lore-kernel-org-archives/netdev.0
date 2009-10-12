From: Matt Domsch <matt_domsch@dell.com>
Subject: Re: PATCH: Network Device Naming mechanism and policy
Date: Mon, 12 Oct 2009 14:48:36 -0500
Message-ID: <20091012194835.GA8474@mock.linuxdev.us.dell.com>
References: <EDA0A4495861324DA2618B4C45DCB3EE589541@blrx3m08.blr.amer.dell.com> <20091012184711.GA4836@mock.linuxdev.us.dell.com> <20091012190900.GA514@kroah.com>
Reply-To: Matt Domsch <Matt_Domsch@dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Narendra K <Narendra_K@dell.com>, notting@redhat.com,
	netdev@vger.kernel.org, shemminger@vyatta.com,
	linux-hotplug@vger.kernel.org, jordan_hargrave@dell.com,
	charles_rose@dell.com
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausxipps301.us.dell.com ([143.166.148.223]:18161 "EHLO
	ausxipps301.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758025AbZJLTtO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2009 15:49:14 -0400
Content-Disposition: inline
In-Reply-To: <20091012190900.GA514@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 12, 2009 at 12:09:00PM -0700, Greg KH wrote:
> "LOM"?

LAN on Motherboard (e.g. an embedded NIC, as opposed to being in some
slot).

> Isn't what you want is a PCI slot detection, combined with the order on
> board in which the port is enumerated?

Most folks do, yes.


> I still fail to see how this dummy char device would solve this problem,
> as everything you can do today in userspace would be the same with this
> device node as you can't do anything with the symlink name on its own,
> right?

You are correct, the char device by itself doesn't help with this.
You noted earlier, the char device is really only needed if we want to
be able have multiple names for the same device, only exposed in
userspace.

If all we want to do is change the namespace for devices the kernel
uses, from "ethN" to something else, we can do that with a single
simple rename.  And biosdevname has several --policy=[] options to
provide that.

--policy=smbios_names => "Embedded NIC 1", "PCI2"
--policy=kernelnames  => "eth0"  (kind of pointless, but included for completeness)
--policy=all_ethN     => "eth0..ethN" in ascending slot order, embedded
                         before slots, within a single slot in PCI
                         breadth-first order, and thereafter in MAC
                         address order if really needed.
--policy=all_names    => "eth_s0_0" for the first embedded NIC in PCI
                         breadth-first order, "eth_s1_1" for the
                         second NIC port in PCI slot 1, again in
                         breadth-first order.
--policy=embedded_ethN_slots_names   a combo of the above, but making
                        the embeddeds still retain the "eth0" format
                        and the slots get "eth_s1_1" format.

We could add a dozen more.  all_ethN, and to a lesser extent,
embedded_ethN, are bad choices if biosdevname is invoked by udev on
every run (e.g. not using persistent rules), because when it's run,
userspace doesn't know if there are more drivers to be loaded yet, and
so biosdevname can't know if there are more NICs to
include in the enumeration, to get the naming right.  (yet another
example of enumeration != naming).

Now, for --policy=smbios_names, we get lucky in that the string length
returned from SMBIOS is 14 characters, it fits in IFNAMSZ.  We may not
always get so lucky, SMBIOS strings are arbitrary lengths.  This works
somewhat better as a symlink source, as that can be longer than
IFNAMSZ long.

--policy=all_names is pretty good.  It fits, it lines up to a fairly
obvious hardware mapping.  It breaks any code that assumes a regular
expression eth[[:digit:]]+ for the name.

By having a single name in the kernel for a particular device, it
forces a sysadmin to choose one naming policy.  We can't have multiple
names for the same device (like we do for disks).  And conceptually,
I'd like to be able to have a physical-based naming scheme (all_names)
for use at installtime and mechanical configuration, and a
logical-based naming scheme for firewall rules and other policy-based
configuration.  I can't do that with a single name.

I can't please everyone.  I can't keep the kernel's eth* namespace
intact, as it is meaningless and non-deterministic.  I can switch
names to another namespace, at the risk of breaking all the
applications that have bad assumptions.  And I can't have multiple
names for the same device.  But if I have multiple names for the same
device, then I can keep the eth* namespace intact (meaningless as it
is), and provide more meaningful names that work too.

I'm not hung up on the char device.  If I could have multiple names
for the same device, done entirely inside the kernel, I'd go for that
too.  That suggestion has met similar resistance.  Or any other
mechanism, I'm open to also.  But _not_ solving it is no longer an
option for me and my customers.


-- 
Matt Domsch
Technology Strategist, Dell Office of the CTO
linux.dell.com & www.dell.com/linux
