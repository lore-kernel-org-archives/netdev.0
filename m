From: Pavel Roskin <proski@gnu.org>
Subject: Re: Can we have GET_NETDEV_DEV?
Date: Tue, 25 Jul 2006 18:02:55 -0400
Message-ID: <1153864975.2288.49.camel@dv>
References: <1153803145.23803.19.camel@dv>
	 <20060725102005.7edb5509@localhost.localdomain>
	 <1153861691.2288.14.camel@dv>
	 <20060725142606.0a44d258@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Greg Kroah-Hartman <gregkh@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fencepost.gnu.org ([199.232.76.164]:37847 "EHLO
	fencepost.gnu.org") by vger.kernel.org with ESMTP id S932251AbWGYWC7
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jul 2006 18:02:59 -0400
Received: from proski by fencepost.gnu.org with local (Exim 4.34)
	id 1G5UzS-0001QQ-BT
	for netdev@vger.kernel.org; Tue, 25 Jul 2006 18:02:58 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060725142606.0a44d258@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-07-25 at 14:26 -0700, Stephen Hemminger wrote:
> On Tue, 25 Jul 2006 17:08:11 -0400
> Pavel Roskin <proski@gnu.org> wrote:
> > Considering the drivers that are already in the kernel, you may prefer
> > to have a more high-level function that would clone the network device
> > by copying most of the net_device structure.  I think netdev_get_pdev()
> > would be mostly used for such cloning if implemented.
> > 
> 
> What is the wireless tree using for this?

Suppose there is a wireless device that can be used on different buses,
e.g. PCI and PCMCIA.  The driver consists of the common part that works
with the chip and the bus specific parts that allocate the resources.

The bus specific parts call SET_NETDEV_DEV to associate the network
device with the hardware device.

Now, suppose the user requests creating a WDS interface.  WDS interfaces
use 4-address headers, which allows bridging.  As it stands now, the way
to support a WDS interface is to make is a separate network device.  I
wish it wouldn't be necessary, but we would need to change quite a few
code inside and outside the kernel to understand WDS addressing (I hope
to be wrong about that).

There is nothing hardware specific about WDS interfaces.  They are just
extensions of the main interface with a fixed "receive address" and
4-address headers enabled.  So it makes sense to create WDS interface in
the common (i.e. bus-agnostic) part of the driver.

In the (possibly misguided) attempt to make WDS network devices look
like real network interfaces, the "class_dev" field is copied from the
master network device, because it's something that can be done in the
bus-agnostic way:

SET_NETDEV_DEV(dev, mdev->class_dev.dev);

This is how it's done in HostAP (in the kernel) and MadWifi (outside the
kernel).

Sure, this value can be stored in the private part of the driver, so
it's a minor issue.

(Actually, the main (AP or STA) interface is also made a virtual network
device, so that the the master interface appears as the parent of the
main and the WDS devices and as the single point for monitoring of all
wireless traffic.)

-- 
Regards,
Pavel Roskin


