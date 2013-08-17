From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 0/3] ixgbe: request_firmware for configuration parameters
Date: Fri, 16 Aug 2013 21:31:26 -0700
Message-ID: <20130817043126.GA9598@kroah.com>
References: <20130111020046.15463.72333.stgit@starfish.jf.intel.com>
 <20130111182547.GA22231@kroah.com>
 <CAP-MU4MzG_P9fz3_eix=zgzyjijZ5qo1mpKE=r_K7y3xcJqc5Q@mail.gmail.com>
 <20130111194134.GA4817@kroah.com>
 <520EA447.6090309@dev.mellanox.co.il>
 <20130816223932.GB31247@kroah.com>
 <520EC144.5090505@dev.mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	davem@davemloft.net, dwmw2@infradead.org,
	jeffrey.t.kirsher@intel.com, linux-kernel@vger.kernel.org
To: Ali Ayoub <ali@dev.mellanox.co.il>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <520EC144.5090505@dev.mellanox.co.il>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 16, 2013 at 05:18:12PM -0700, Ali Ayoub wrote:
> On 8/16/2013 3:39 PM, Greg KH wrote:
> > On Fri, Aug 16, 2013 at 03:14:31PM -0700, Ali Ayoub wrote:
> >> On 1/11/2013 11:41 AM, Greg KH wrote:
> > 
> > Seriously?  Restarting a thread from over 6 months ago?
> 
> Yes, it's an old thread, but still relevant for current code.

Which specific code are you referring to?

> > Why?
> 
> Because currently there is no good alternative for module params for
> device drivers that need to have low level configs in init time.

I disagree, see below for why module params are broken for this.

> >> Other device drivers of other vendors (not only netdevs) need such a
> >> mechanism as well,
> > 
> > Specifics please.
> >
> >> I think it's a general requirement for many drivers that normally need
> >> low level configurations for device initialization in the very first
> >> stage of the driver load.
> > 
> > I do not, but feel free to prove me otherwise.
> 
> A driver that claims the PCI device needs some configuration in init
> time such as: amount of resources to be allocated in the cache,
> interrupt mode, maximum allowed resources to be created for a specific
> type, number of event queues, etc. See for example:
> /drivers/net/ethernet/mellanox/mlx4/main.c
> 
> This driver doesn't necessary register a logical device, it may claim
> the PCI device only (e.g. for an HCA), and provide an infrastructure for
> upper layer protocols to register a logical device (nic, hba, etc.) on
> top of it.

And how do you handle hundreds of the same card in the same machine?
You can't do that with module paramaters at all, it doesn't scale, or
make any sense.

What about hotplug of new devices after the module is loaded?  That will
not work at all for module parameters either.

That is why we created sysfs, and configfs.

> The type of configuration needed varies between vendors, and they are
> normally passed in HW initialization stage. So even if we have a tool to
> configure the device (such as ethtool for netdevs) it wouldn't be a
> replacement for the module param, because some systems requires
> non-default (init) configurations, and if we load the driver with the
> default, and then use a user-space tool to "adjust" the configuration
> we'll have a "glitch" where the driver was loaded with unsuitable
> configs for the system.

No, just remain in a "unusable" state until you are initialized from
userspace.  No "glitch" at all.

> >>> All of the above issues you seem to have with sysfs and configfs can be
> >>> resolved with userspace code, and having your driver not do anything to
> >>> the hardware until it is told to by userspace.
> >>
> >> To tell the driver not to do anything until it's configured by a
> >> userspace code will require a module param for non-default-configs
> >> (which brings us back to the original argument of avoiding module params).
> > 
> > No, never use a module paramater for configuring a driver or a device.
> > That's not what they are there for.
> >
> >> By having userspace code to feed configfs/sysfs nodes, and making it
> >> available in initrd; we will end up having similar mechanism to
> >> request_firmware().
> > 
> > Close, but not the same.  That's why we created configfs, please use it.
> 
> configfs requires from the driver to provide the hooks before the HW is
> initialized, while module params allow passing information to the driver
> in init time before any driver hooks are ready.

And module params don't work at all for the common usage of hotplug
devices, and multiple numbers of devices that show up _after_ the module
is loaded.

> The proposal of changing the driver not to configure the HW until it's
> triggered by userspace service through configfs, means that we need:
> 
> a. To have driver config to toggle between the mode where the driver
> "waits" for configfs, and the "auto" mode where the driver loads with
> the default-configs (when using mod params for example, the driver
> simply loads with the defaults when there is modprobe config files).
> 
> b. To have the userspace mechanism to feed the configs nodes, to store
> the configs in a file to keep them persistent between reboots, and make
> these userspace services available in initrd.

Does this really need to be in the initrd?  That's only needed for your
boot device, and if you need it there, great, put it there, that's what
dracut is there for, it's a full Linux system in the initrd.

configfs, for complex initializations like you are proposing, works,
that is why it was created, and what it is used for.  Yes, it's "rough"
in places, and a bit complex.  Patches to fix that are always gladly
appreciated.

> I don't see how this is better than module params, or
> request_firmware_config().

request_firmware is for just that, firmware, not configuration values,
sorry.  Use configfs for configuration, that's what it is there for.

thanks,

greg k-h
