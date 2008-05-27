From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: network interface *name* alias support?
Date: Tue, 27 May 2008 23:49:03 +0200 (CEST)
Message-ID: <alpine.LNX.1.10.0805272330170.12937@fbirervta.pbzchgretzou.qr>
References: <48387B18.2090300@trash.net> <alpine.LNX.1.10.0805242254020.19084@fbirervta.pbzchgretzou.qr> <4838D7E4.7050401@trash.net> <20080525.051713.124717485.davem@davemloft.net> <20080527190352.GE25696@auslistsprd01.us.dell.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	dwmw2@infradead.org, jchapman@katalix.com, jonathan@jonmasters.org,
	tgraf@suug.ch, rick.jones2@hp.com, auke-jan.h.kok@intel.com,
	johnathan@jonmasters.org, netdev@vger.kernel.org
To: Matt Domsch <Matt_Domsch@dell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:46896 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756125AbYE0VtG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2008 17:49:06 -0400
In-Reply-To: <20080527190352.GE25696@auslistsprd01.us.dell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tuesday 2008-05-27 21:03, Matt Domsch wrote:
>
>OK, I'm just trying to understand how you would see this "feature"
>being implemented in userspace.  Advice welcome.
>
>I keep looking at my analogue: disk devices.
>Disks have a hard-coded association: Some device node with number
>(8,0) means "the first SCSI disk device" to the kernel.  Regardless of
>what the name of the file that implements the device node is (probably
>/dev/sda, but not necessarily), or if there are symlinks pointing at
>that file.  The kernel only cares about the linkage between the device
>node and the driver that accepts read/write/ioctl/etc. to it.
>
>Network devices have no such thing that I can tell.  I get at the
>device names (as presently assigned) by reading /proc/net/dev (I'd be
>happy to be told of a more correct way - this is what net-tools uses.)
>[...]
>Something like that?

The "correct" way seems to be sending off netlink messages (look at
the iproute2 code -- if you dare), or for shell scripts perhaps just
globbing up /sys/class/net/*.

And that's probably where it already ends. I like your analogy to
disk devices: the kernel keeps exactly one association (namely,
kdev_t to the device driver), so it seems sane to do the same for
network devices.

Make a /dev/net directory, and let udev populate it with symlinks in
the fashion of "bus-pci-0000:02.9 -> eth0". Note the potential
symlink loop, which should be of no concern since readlink(2)
dereferences it exactly once.

The catch: you cannot use "bus-pci-0000:02.9" as a device name
when directly talking to the kernel, it needs to be resolved to eth0
first. But then again, opening /dev/sda1 is also a resolution
procedure (finding the kdev_t for sda1), though it is in the kernel.

I am reminded of Solaris, which has device nodes for network
interfaces in /dev, though I am not aware how they are actually used.
(And granted, having to plumb it first is not as straightforward
compared to just-using-them in Linux). Though, when it is a device
node, userspace does not need to have knowledge of /dev/net and
readlink(2) it itself, as the kernel will auto-follow symlinks when
open(2)ed.
