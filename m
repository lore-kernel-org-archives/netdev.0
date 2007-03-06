From: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Subject: Re: [2.6.21 patch] unconditionally enable SYSFS_DEPRECATED
Date: Tue, 6 Mar 2007 12:05:37 -0800
Message-ID: <20070306200536.GA5459@kroah.com>
References: <20070305011729.GB7681@kroah.com> <20070305125950.GC26781@thunk.org> <20070305185813.GA31465@kroah.com> <20070305234052.GR3441@stusta.de> <20070306000722.GA11436@kroah.com> <20070306013020.GN23311@waste.org> <20070306024850.GA24477@kroah.com> <20070306033947.GQ23311@waste.org> <20070306040350.GA25783@kroah.com> <20070306061009.GR23311@waste.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Adrian Bunk <bunk-HeJ8Db2Gnd6zQB+pC5nmwQ@public.gmane.org>, Theodore Tso <tytso-3s7WtUTddSA@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, jketreno-VuQAYsv1563Yd54FQh9/CA@public.gmane.org,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, akpm-3NddpPZAyC0@public.gmane.org
To: Matt Mackall <mpm-VDJrAJ4Gl5ZBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20070306061009.GR23311-1tnLUEbcrg3YtjvyW6yDsg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 06, 2007 at 12:10:09AM -0600, Matt Mackall wrote:
> On Mon, Mar 05, 2007 at 08:03:50PM -0800, Greg KH wrote:
> > On Mon, Mar 05, 2007 at 09:39:47PM -0600, Matt Mackall wrote:
> > > On Mon, Mar 05, 2007 at 06:48:50PM -0800, Greg KH wrote:
> > > > If so, can you disable the option and strace it to see what program is
> > > > trying to access what?  That will put the
> > > > HAL/NetworkManager/libsysfs/distro script finger pointing to rest pretty
> > > > quickly :)
> > > 
> > > Ok, I've got straces of both good and bad (>5M each). Filtered out
> > > random pointer values and the like, diffed, and filtered for /sys/,
> > > and the result's still 1.5M. What should I be looking for?
> > 
> > Failures when trying to read from /sys/class/net/
> > 
> > Or opening the directory and iterating over the subdirs in there.  Or
> > something like that.
> > 
> > But the /sys/class/net/ stuff should hopefully help narrow it down.
> 
> Works:
> 
> 6857  open("/sys/class/net",
> O_RDONLY|O_NONBLOCK|O_LARGEFILE|O_DIRECTORY) = 13
> 6857  fstat64(13, {st_mode=S_IFDIR|0755, st_size=0, ...}) = 0
> 6857  fcntl64(13, F_SETFD, FD_CLOEXEC)  = 0
> 6857  getdents64(13, /* 5 entries */, 4096) = 120
> 6857  readlink("/sys/class/net/eth1", 0x80a2450, 256) = -1 EINVAL
> (Invalid argument)
> 6857  readlink("/sys/class/net/eth1/device",
> "../../../devices/pci0000:00/0000:00:1e.0/0000:02:02.0", 256) = 53
> 6857  readlink("/sys/class/net/lo", 0x80a2450, 256) = -1 EINVAL
> (Invalid argument)
> 6857  readlink("/sys/class/net/lo/device", 0x80a2450, 256) = -1 ENOENT
> (No such
> file or directory)
> 6857  readlink("/sys/class/net/eth0", 0x80a2450, 256) = -1 EINVAL
> (Invalid argument)
> 6857  readlink("/sys/class/net/eth0/device",
> "../../../devices/pci0000:00/0000:00:1e.0/0000:02:01.0", 256) = 53
> 6857  getdents64(13, /* 0 entries */, 4096) = 0
> 6857  close(13)                         = 0
> 
> Breaks:
> 
> 3620  open("/sys/class/net",
> O_RDONLY|O_NONBLOCK|O_LARGEFILE|O_DIRECTORY) = 13
> 3620  fstat64(13, {st_mode=S_IFDIR|0755, st_size=0, ...}) = 0
> 3620  fcntl64(13, F_SETFD, FD_CLOEXEC)  = 0
> 3620  getdents64(13, /* 5 entries */, 4096) = 120
> 3620  readlink("/sys/class/net/eth1",
> "../../devices/pci0000:00/0000:00:1e.0/00\00:02:02.0/eth1", 256) = 55
> 3620
> readlink("/sys/devices/pci0000:00/0000:00:1e.0/0000:02:02.0/eth1/device",
> 0x809e910, 256) = -1 ENOENT (No such file or directory)
> 3620  readlink("/sys/class/net/lo", "../../devices/virtual/net/lo",
> 256) = 28
> 3620  readlink("/sys/devices/virtual/net/lo/device", 0x809e960, 256) =
> -1 ENOEN\T (No such file or directory)
> 3620  readlink("/sys/class/net/eth0",
> "../../devices/pci0000:00/0000:00:1e.0/00\00:02:01.0/eth0", 256) = 55
> 3620
> readlink("/sys/devices/pci0000:00/0000:00:1e.0/0000:02:01.0/eth0/device",
> 0x809e960, 256) = -1 ENOENT (No such file or directory)
> 3620  getdents64(13, /* 0 entries */, 4096) = 0
> 3620  close(13)                         = 0

Can you try the patch below?  And enable CONFIG_SYSFS_DEPRECATED.  It
should cause HAL to see the network devices again, as the symlink is now
back (it shouldn't have gone away, that was my fault...)

I tried this with HAL 0.5.7, which is pretty old, and hal-device-manager
shows my network devices properly.

thanks for your patience,

greg k-h


---
 drivers/base/core.c |   21 +++++++++++++--------
 1 file changed, 13 insertions(+), 8 deletions(-)

--- gregkh-2.6.orig/drivers/base/core.c
+++ gregkh-2.6/drivers/base/core.c
@@ -584,17 +584,17 @@ int device_add(struct device *dev)
 		if (dev->kobj.parent != &dev->class->subsys.kset.kobj)
 			sysfs_create_link(&dev->class->subsys.kset.kobj,
 					  &dev->kobj, dev->bus_id);
-#ifdef CONFIG_SYSFS_DEPRECATED
 		if (parent) {
 			sysfs_create_link(&dev->kobj, &dev->parent->kobj,
 							"device");
+#ifdef CONFIG_SYSFS_DEPRECATED
 			class_name = make_class_name(dev->class->name,
 							&dev->kobj);
 			if (class_name)
 				sysfs_create_link(&dev->parent->kobj,
 						  &dev->kobj, class_name);
-		}
 #endif
+		}
 	}
 
 	if ((error = device_add_attrs(dev)))
@@ -651,17 +651,17 @@ int device_add(struct device *dev)
 		if (dev->kobj.parent != &dev->class->subsys.kset.kobj)
 			sysfs_remove_link(&dev->class->subsys.kset.kobj,
 					  dev->bus_id);
-#ifdef CONFIG_SYSFS_DEPRECATED
 		if (parent) {
+#ifdef CONFIG_SYSFS_DEPRECATED
 			char *class_name = make_class_name(dev->class->name,
 							   &dev->kobj);
 			if (class_name)
 				sysfs_remove_link(&dev->parent->kobj,
 						  class_name);
 			kfree(class_name);
+#endif
 			sysfs_remove_link(&dev->kobj, "device");
 		}
-#endif
 
 		down(&dev->class->sem);
 		/* notify any interfaces that the device is now gone */
@@ -761,17 +761,17 @@ void device_del(struct device * dev)
 		if (dev->kobj.parent != &dev->class->subsys.kset.kobj)
 			sysfs_remove_link(&dev->class->subsys.kset.kobj,
 					  dev->bus_id);
-#ifdef CONFIG_SYSFS_DEPRECATED
 		if (parent) {
+#ifdef CONFIG_SYSFS_DEPRECATED
 			char *class_name = make_class_name(dev->class->name,
 							   &dev->kobj);
 			if (class_name)
 				sysfs_remove_link(&dev->parent->kobj,
 						  class_name);
 			kfree(class_name);
+#endif
 			sysfs_remove_link(&dev->kobj, "device");
 		}
-#endif
 
 		down(&dev->class->sem);
 		/* notify any interfaces that the device is now gone */
@@ -1064,8 +1064,8 @@ static int device_move_class_links(struc
 				   struct device *old_parent,
 				   struct device *new_parent)
 {
+	int error = 0;
 #ifdef CONFIG_SYSFS_DEPRECATED
-	int error;
 	char *class_name;
 
 	class_name = make_class_name(dev->class->name, &dev->kobj);
@@ -1093,7 +1093,12 @@ out:
 	kfree(class_name);
 	return error;
 #else
-	return 0;
+	if (old_parent)
+		sysfs_remove_link(&dev->kobj, "device");
+	if (new_parent)
+		error = sysfs_create_link(&dev->kobj, &new_parent->kobj,
+					  "device");
+	return error;
 #endif
 }
 
