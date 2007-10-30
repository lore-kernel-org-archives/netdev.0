From: Greg KH <greg@kroah.com>
Subject: Re: recent sysfs changes cause lots of network device errors
Date: Tue, 30 Oct 2007 15:40:43 -0700
Message-ID: <20071030224043.GA6612@kroah.com>
References: <20071030150010.79253f01@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tejun Heo <htejun@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Kay Sievers <kay.sievers@vrfy.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:56271 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753198AbXJ3Wmj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Oct 2007 18:42:39 -0400
Content-Disposition: inline
In-Reply-To: <20071030150010.79253f01@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 30, 2007 at 03:00:10PM -0700, Stephen Hemminger wrote:
> It seems that the network device rename done by distro's
> interacts badly with the code in device_rename() in 2.6.24
> (post -rc1).  Network devices create sysfs entries where the sd->s_name is 
> just a pointer over to the actual buffer in the netdevice. 
> 
> Prior to calling device_rename, the code in dev_change_name() updates
> the network device name field to the new name.  Then when device_rename
> is called it sees that the new name already exists, and dumps out a bunch
> of sysfs warnings. 
> 
> I already fixed the obvious case of rename to same name, so that isn't the
> problem.
> 
> dev_change_name eth0 -> eth4
> [   46.029555] sysfs: duplicate filename 'eth4' can not be created
> [   46.029557] WARNING: at fs/sysfs/dir.c:424 sysfs_add_one()
> [   46.029559] 
> [   46.029560] Call Trace:
> [   46.029586]  [<ffffffff802e60ff>] sysfs_add_one+0xaf/0xf0
> [   46.029590]  [<ffffffff802e7113>] sysfs_create_link+0xa3/0x140
> [   46.029597]  [<ffffffff803b1bb8>] device_rename+0x1d8/0x230
> [   46.029603]  [<ffffffff8040af45>] dev_change_name+0xe5/0x280
> [   46.029606]  [<ffffffff8040b697>] dev_ioctl+0x2b7/0x540
> [   46.029612]  [<ffffffff803fc32d>] sock_ioctl+0x7d/0x250
> [   46.029618]  [<ffffffff802ab33f>] do_ioctl+0x2f/0xa0
> [   46.029620]  [<ffffffff802ab424>] vfs_ioctl+0x74/0x2d0
> [   46.029624]  [<ffffffff8029bde5>] fd_install+0x25/0x60
> [   46.029626]  [<ffffffff802ab711>] sys_ioctl+0x91/0xb0
> [   46.029631]  [<ffffffff8020bbce>] system_call+0x7e/0x83
> 
> 
> What is the proper usage mode for the rename code? 
> Should the underlying structure get changed first or later?
> Or maybe dev_change_name should just not use device_rename
> at all, and just fix the kobject itself?
> 
> device_rename() should be smart enough to:
>     1. not get confused if sysfs entry is already changed
>     2. handle the case of rename to same name correctly.
> 
> The device control code needs more regression testing before new patches
> are accepted. I understand there is a strong desire to cleanup and eliminate
> the class device stuff, but before going there you need to create
> regression tests for all usages, and not depend on every subsystem
> maintainer to make changes to keep up with your whims.

Well, this was a bug that no one caught in -mm as we all seem to be
running with CONFIG_SYSFS_DEPRECATED disabled.  There was a long
discussion on lkml last week, and here's the patch that should fix it
that is going to Linus in a day or so (it's in my tree, but I'm supposed
to be on vacation right now...)

Let me know if this works for you or not.

thanks,

greg k-h

From: Kay Sievers <kay.sievers@vrfy.org>
Subject: Driver Core: fix bug in device_rename() for SYSFS_DEPRECATED=y

From: Kay Sievers <kay.sievers@vrfy.org>

This should fix the sysfs warnings that renaming network devices is
causing to show up with CONFIG_SYSFS_DEPRECATED=y

The code just shouldn't run if class devices are real directories, it's
an update for the symlink in the class directory. Nobody noticed that as
long as the creation of sysfs files silently failed, and we both missed
it before the merge, because we don't run SYSFS_DEPRECATED=y.        

Signed-off-by: Kay Sievers <kay.sievers@vrfy.org>
Cc: Larry Finger <Larry.Finger@lwfinger.net>
Cc: David Miller <davem@davemloft.net>
Cc: Rafael J. Wysocki <rjw@sisk.pl>
Cc: Tejun Heo <htejun@gmail.com>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

---
 drivers/base/core.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

--- a/drivers/base/core.c
+++ b/drivers/base/core.c
@@ -1228,18 +1228,18 @@ int device_rename(struct device *dev, ch
 			sysfs_remove_link(&dev->parent->kobj, old_class_name);
 		}
 	}
-#endif
-
+#else
 	if (dev->class) {
 		sysfs_remove_link(&dev->class->subsys.kobj, old_device_name);
 		error = sysfs_create_link(&dev->class->subsys.kobj, &dev->kobj,
 					  dev->bus_id);
 		if (error) {
-			/* Uh... how to unravel this if restoring can fail? */
 			dev_err(dev, "%s: sysfs_create_symlink failed (%d)\n",
 				__FUNCTION__, error);
 		}
 	}
+#endif
+
 out:
 	put_device(dev);
 
