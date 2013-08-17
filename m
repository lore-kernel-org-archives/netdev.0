From: Ali Ayoub <ali@dev.mellanox.co.il>
Subject: Re: [PATCH 0/3] ixgbe: request_firmware for configuration parameters
Date: Fri, 16 Aug 2013 17:18:12 -0700
Message-ID: <520EC144.5090505@dev.mellanox.co.il>
References: <20130111020046.15463.72333.stgit@starfish.jf.intel.com> <20130111182547.GA22231@kroah.com> <CAP-MU4MzG_P9fz3_eix=zgzyjijZ5qo1mpKE=r_K7y3xcJqc5Q@mail.gmail.com> <20130111194134.GA4817@kroah.com> <520EA447.6090309@dev.mellanox.co.il> <20130816223932.GB31247@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	davem@davemloft.net, dwmw2@infradead.org,
	jeffrey.t.kirsher@intel.com, linux-kernel@vger.kernel.org
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130816223932.GB31247@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/16/2013 3:39 PM, Greg KH wrote:
> On Fri, Aug 16, 2013 at 03:14:31PM -0700, Ali Ayoub wrote:
>> On 1/11/2013 11:41 AM, Greg KH wrote:
> 
> Seriously?  Restarting a thread from over 6 months ago?

Yes, it's an old thread, but still relevant for current code.

> Why?

Because currently there is no good alternative for module params for
device drivers that need to have low level configs in init time.
I found Shannon proposal in this thread the closest to what I am looking
for to configure the device driver and yet not to use module params.
Thus, pinged this thread.

>> Other device drivers of other vendors (not only netdevs) need such a
>> mechanism as well,
> 
> Specifics please.
>
>> I think it's a general requirement for many drivers that normally need
>> low level configurations for device initialization in the very first
>> stage of the driver load.
> 
> I do not, but feel free to prove me otherwise.

A driver that claims the PCI device needs some configuration in init
time such as: amount of resources to be allocated in the cache,
interrupt mode, maximum allowed resources to be created for a specific
type, number of event queues, etc. See for example:
/drivers/net/ethernet/mellanox/mlx4/main.c

This driver doesn't necessary register a logical device, it may claim
the PCI device only (e.g. for an HCA), and provide an infrastructure for
upper layer protocols to register a logical device (nic, hba, etc.) on
top of it.

The type of configuration needed varies between vendors, and they are
normally passed in HW initialization stage. So even if we have a tool to
configure the device (such as ethtool for netdevs) it wouldn't be a
replacement for the module param, because some systems requires
non-default (init) configurations, and if we load the driver with the
default, and then use a user-space tool to "adjust" the configuration
we'll have a "glitch" where the driver was loaded with unsuitable
configs for the system.

>>> All of the above issues you seem to have with sysfs and configfs can be
>>> resolved with userspace code, and having your driver not do anything to
>>> the hardware until it is told to by userspace.
>>
>> To tell the driver not to do anything until it's configured by a
>> userspace code will require a module param for non-default-configs
>> (which brings us back to the original argument of avoiding module params).
> 
> No, never use a module paramater for configuring a driver or a device.
> That's not what they are there for.
>
>> By having userspace code to feed configfs/sysfs nodes, and making it
>> available in initrd; we will end up having similar mechanism to
>> request_firmware().
> 
> Close, but not the same.  That's why we created configfs, please use it.

configfs requires from the driver to provide the hooks before the HW is
initialized, while module params allow passing information to the driver
in init time before any driver hooks are ready.

The proposal of changing the driver not to configure the HW until it's
triggered by userspace service through configfs, means that we need:

a. To have driver config to toggle between the mode where the driver
"waits" for configfs, and the "auto" mode where the driver loads with
the default-configs (when using mod params for example, the driver
simply loads with the defaults when there is modprobe config files).

b. To have the userspace mechanism to feed the configs nodes, to store
the configs in a file to keep them persistent between reboots, and make
these userspace services available in initrd.

I don't see how this is better than module params, or
request_firmware_config().
