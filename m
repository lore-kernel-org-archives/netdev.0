From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: PATCH: Network Device Naming mechanism and policy
Date: Wed, 19 Aug 2009 20:26:25 +0100
Message-ID: <1250709985.2874.41.camel@achroite>
References: <5DDAB7BA7BDB58439DD0EED0B8E9A3AE011CD92D@ausx3mpc102.aus.amer.dell.com>
	 <5DDAB7BA7BDB58439DD0EED0B8E9A3AE011CD964@ausx3mpc102.aus.amer.dell.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-hotplug@vger.kernel.org
To: Jordan_Hargrave@Dell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:48584 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751874AbZHST0e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2009 15:26:34 -0400
In-Reply-To: <5DDAB7BA7BDB58439DD0EED0B8E9A3AE011CD964@ausx3mpc102.aus.amer.dell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-08-19 at 13:56 -0500, Jordan_Hargrave@Dell.com wrote:
> This is from an old discussion several months ago:
> http://lkml.org/lkml/2009/3/24/357
> http://lkml.org/lkml/2009/3/24/380
> 
> Basically the issue is that between a race in udev and PCI scan order the ethX IDs may not
> be consistent between reboots.  The idea is to use a mechanism similar to how disks now can
> be accessed by their LABEL/PATH/UUID instead of raw /dev/sdX ids.
> 
> example udev config:
> SUBSYSTEM=="net", SYMLINK+="net/by-mac/$sysfs{ifindex}.$sysfs{address}"
> SUBSYSTEM=="net", PROGRAM="/sbin/biosdevname -i %k --policy=all_names", SYMLINK+="net/by-chassis-id/%c"
> 
> The following patch will create a device node for network devices based off their ifindex;
> udev can then use this device node for creating symlinks in /dev/net/xxxx similar to the
> way that disks now use by-label and by-path symlinks.
> 
> Combining this with the biosdevname utility and patches to common network utilities,
> it could be possible to access ethernet devices by their PCI path or BIOS Label.
> 
> eg. ifconfig Embedded_NIC_1

Nice idea, but wouldn't it be "ifconfig LABEL=Embedded_NIC_1"?

> --- include/linux/major.h~	2009-07-30 18:34:47.000000000 -0400
> +++ include/linux/major.h	2009-08-05 14:52:10.000000000 -0400
> @@ -169,6 +169,7 @@
>  #define IBM_FS3270_MAJOR	228
>  
>  #define VIOTAPE_MAJOR		230
> +#define NETDEV_MAJOR		234
>  
>  #define BLOCK_EXT_MAJOR		259
>  #define SCSI_OSD_MAJOR		260	/* open-osd's OSD scsi device */
> --- net/core/net-sysfs.cx	2009-08-05 15:00:13.000000000 -0400
> +++ net/core/net-sysfs.c	2009-08-05 15:01:20.000000000 -0400
> @@ -11,6 +11,7 @@
>  
>  #include <linux/capability.h>
>  #include <linux/kernel.h>
> +#include <linux/major.h>
>  #include <linux/netdevice.h>
>  #include <linux/if_arp.h>
>  #include <net/sock.h>
> @@ -496,6 +497,7 @@ int netdev_register_kobject(struct net_d
>  	dev->class = &net_class;
>  	dev->platform_data = net;
>  	dev->groups = groups;
> +	dev->devt = MKDEV(NETDEV_MAJOR, net->ifindex);
[...]

Since this major number is unregistered, the device inode can only be
stat'd and not open'd, which seems like a bit of a hack.  Is there
anything that would stop register_chrdev(0, ...) from allocating this
major number, causing network devices to be confused with some other
device type?

Maybe there *should* be character devices for network device
manipulation.  It seems like that would avoid the race conditions that
device renaming and removal causes for name-based socket ioctls.  But
maybe everyone should be using netlink for that instead.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

