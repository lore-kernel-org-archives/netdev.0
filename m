From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [RFC net-next 0/3] devconf: New infrastructure for setting
 pre-load parameters for a module
Date: Thu, 8 Jan 2015 09:47:07 -0800
Message-ID: <20150108174707.GA13218@kroah.com>
References: <1420730220-20224-1-git-send-email-hadarh@mellanox.com>
 <20150108164618.GA11696@kroah.com>
 <54AEBA28.1030301@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hadar Hen Zion <hadarh@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	"shannon.nelson@intel.com" <shannon.nelson@intel.com>,
	Doug Ledford <dledford@redhat.com>,
	"greearb@candelatech.com" <greearb@candelatech.com>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:42438 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932271AbbAHRrJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2015 12:47:09 -0500
Content-Disposition: inline
In-Reply-To: <54AEBA28.1030301@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 08, 2015 at 07:11:04PM +0200, Amir Vadai wrote:
> On 1/8/2015 6:46 PM, Greg KH wrote:
> > On Thu, Jan 08, 2015 at 05:16:57PM +0200, Hadar Hen Zion wrote:
> >> Hi,
> >>     
> >> When configuring a device at an early boot stage, most kernel drivers
> >> use module parameters (the parameters' settings can be determined in
> >> modprobe.d config files).
> > 
> > Which is a bad idea, as you have learned :)
> > 
> >> These parameters are difficult to manage, and one of the reasons is that
> >> module parameters are set per driver and not per device (NICs using the
> >> same driver cannot be set with different configurations).
> >> Furthermore, using other existing configuration tools like ethtool,
> >> ifconfig, ip link commands or sysfs entries is not applicable, since
> >> they all rely on having a netdev already set up.
> >>
> >> In the past, 'request_firmware' solution for configuration parameters
> >> was suggested by Shannon Nelson from Intel[1]. The idea was rejected by
> >> Greg KH, who claimed it was abusive of the request_firmware mechanism.
> >> Greg suggested using configfs for device configuration instead (as done
> >> by the USB gadget driver).
> >>
> >> As a solution, we introduce a new kernel infrastructure using configfs
> >> to allow the configuration of the device. The goal is to set low-level
> >> device functionality that needs to be sorted out before a module is
> >> loaded.
> > 
> > Ick, really?  drivers should never need to be configured like this, if
> > so, then something is wrong, they should "just work" by default.  What
> > are you needing to "configure" that can't be determined by something
> > like a device tree?
> Ick indeed - but we can't find anything better.
> 
> For example, we have devices that can act as either netdev or as an
> Infiniband device.
> The driver consists of a core to handle the hardware, and higher layer
> drivers - one for Ethernet and one for Infiniband.
> Today the selection is done through a module parameter. according to it
> the relevant higher level driver is loaded, and the device is
> initialized. You don't want to have a default of netdev, and in every
> installation that needs Infiniband, a netdev will be created, removed
> and only then the Infiniband device will appear.

But that really isn't an issue, right?  Who cares if it happens that
way?

Or just don't do anything until that "higher level" driver is loaded,
either ib or network.

> This is only one example to configuration that needs to be known before
> the hardware is initialized, and be persistent across boots.
> 
> We can have a 2 stages loading. First load the core, wait for user
> input, and only then configure the device and load the right upper layer
> driver according to the user input (configfs/sysfs).

Why not just wait for an "upper layer" driver to be loaded?  It doesn't
make it dynamic, and forces you to have a module manually be loaded, but
would solve this problem.

Or just don't do anything until configfs is set up for your devices,
after the module is loaded.  This allows drivers to be built into the
kernel if people really want that type of configuration to work
properly.

> Since other vendors seems to need this capability too, we thought it
> would be better to make it generic - and this is this what this RFC is
> about.

What other vendors have such horribly designed hardware / kernel modules
that need this type of thing?  :)

thanks,

greg k-h
