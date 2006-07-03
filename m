From: Greg KH <greg@kroah.com>
Subject: [RFC] change netdevice to use struct device instead of struct class_device
Date: Mon, 3 Jul 2006 15:47:19 -0700
Message-ID: <20060703224719.GA14176@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932171AbWGCWuu@vger.kernel.org>
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I have a patch here that converts the network device structure to use
the struct device instead of struct class_device structure.  It's a bit
too big to post here, so it's at:
	http://www.kernel.org/pub/linux/kernel/people/gregkh/gregkh-2.6/patches/network-class_device-to-device.patch

I can split it out, but then it will not build for the intermediate
steps, which 'git bisect' users might not appreciate.  If you all want
me to break it up to make it easier to review, please let me know and
I'll be glad to do it.

With this patch applied, sysfs now looks like:
 $ tree /sys/class/net/
 /sys/class/net/
 |-- eth0 -> ../../devices/pci0000:00/0000:00:02.0/0000:01:00.2/0000:03:0e.0/eth0
 |-- gerg -> ../../devices/pci0000:00/0000:00:02.0/0000:01:00.2/0000:03:0c.0/gerg
 `-- lo -> ../../devices/lo

Instead of the different directories being in /sys/class/net.

What this buys us is now the different network devices can be called by
the core when the system is shutting down or restoring, with the
suspend/resume changes that Linus has written (and are now in -mm).
This can be used by the network core to stop the queue, or whatever else
it desires.

Other good things happen with this, as the network devices are now real
devices, instead of the second-class citizens that "class_device" was.
(which is one reason why I'm getting rid of class_device entirely).

The patch needs some other changes to the driver core that are also in
my git tree, and included in the -mm release.  Specifically these
patches are needed:
	http://www.kernel.org/pub/linux/kernel/people/gregkh/gregkh-2.6/patches/driver/device-groups.patch
	http://www.kernel.org/pub/linux/kernel/people/gregkh/gregkh-2.6/patches/driver/device-class-parent.patch
	http://www.kernel.org/pub/linux/kernel/people/gregkh/gregkh-2.6/patches/driver/device-class-attr.patch
	http://www.kernel.org/pub/linux/kernel/people/gregkh/gregkh-2.6/patches/driver/device_rename.patch

And if you are curious, the suspend stuff from Linus is at:
	http://www.kernel.org/pub/linux/kernel/people/gregkh/gregkh-2.6/patches/driver/suspend-infrastructure-cleanup-and-extension.patch

I can gladly keep this in my tree (due to the previously mentioned
requirements) and eventually merge it with Linus after 2.6.18 is out, if
no one objects to it.

thanks,

greg k-h

p.s. That bonding code!  WTF is going on with poking around in the
     internals of krefs?  And why are you returning more than one value
     from a sysfs file?  I thought I asked that this stuff be fixed up a
     long time ago?
