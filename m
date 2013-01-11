From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 0/3] ixgbe: request_firmware for configuration parameters
Date: Fri, 11 Jan 2013 11:41:34 -0800
Message-ID: <20130111194134.GA4817@kroah.com>
References: <20130111020046.15463.72333.stgit@starfish.jf.intel.com>
 <20130111182547.GA22231@kroah.com>
 <CAP-MU4MzG_P9fz3_eix=zgzyjijZ5qo1mpKE=r_K7y3xcJqc5Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, dwmw2@infradead.org,
	jeffrey.t.kirsher@intel.com, linux-kernel@vger.kernel.org
To: Shannon Nelson <shannon.nelson@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAP-MU4MzG_P9fz3_eix=zgzyjijZ5qo1mpKE=r_K7y3xcJqc5Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 11, 2013 at 11:30:54AM -0800, Shannon Nelson wrote:
> On Fri, Jan 11, 2013 at 10:25 AM, Greg KH <gregkh@linuxfoundation.org> wrote:
> > On Thu, Jan 10, 2013 at 06:02:20PM -0800, Shannon Nelson wrote:
> >> Most networking dials and knobs can be set using ethtool, ifconfig, ip link
> >> commands, or sysfs entries, all of which can be driven by startup scripts
> >> and other configuration tools.  However, they all depend on having a netdev
> >> already set up, and we have some low-level device functionality that needs
> >> to be sorted out before we start setting up MSI-x and memory allocations.
> 
> > Ick, please don't abuse request_firmware() for this type of thing.
> 
> Yeah, it seemed ugly to me at first as well, but it grew on me as I
> realized that it does solve a problem in a rather elegant way.  While
> working this up I discussed this with Mr. Woodhouse thinking that as a
> firmware tree maintainer he'd have a similar reaction, but he actually
> wasn't opposed to it (David, please speak up if I'm misrepresenting
> your comments).

David maintains the external firmware tree repo, not the in-kernel
firmware core code (which I used to maintain.)

> > What's wrong with configfs?  It sounds like it will fit your need, and
> > that is what is created for.
> 
> configfs has similar problems as sysfs - the driver needs to create
> the hooks before it has all the info it might need for some hooks,
> there is no persistence across reboots, and I don't think it will help
> for initrd images.  Additionally, there would need to be some userland
> mechanism to notice that the hooks were there and to feed it the
> startup info.  Using a file in the firmware path gives us persistence
> and a way for the driver to get info before having to set up
> filesystem hooks.  It also gives us a way to get special config info
> into the boot image.  And the whole mechanism already exists,
> including UDEV hooks that can do more fancy stuff if needed.

Yes, but you are now starting to use "configuration files" for kernel
drivers, which we have resisted for 20+ years for a variety of good
reasons.  You can't just ignore all of the arguments to not do this all
of a sudden because you feel your driver is somehow "special" here.

All of the above issues you seem to have with sysfs and configfs can be
resolved with userspace code, and having your driver not do anything to
the hardware until it is told to by userspace.

The boot image problem is harder, but I would argue that your driver
better fall-back to some "known good" configuration for that type of
instance, as you will need to do that anyway if your "firmware" file
isn't present in the first place.

So please try configfs again, the idea of loading configuration files
from the filesystem, no matter what the mechanism, into your driver,
isn't ok to do, sorry.

greg k-h
