From: David VomLehn <dvomlehn@cisco.com>
Subject: [PATCH 1/5] initdev:kernel: Asynchronously-discovered device
	synchronization, v5
Date: Fri, 1 May 2009 19:25:51 -0700
Message-ID: <20090502022551.GA15600@cuplxvomd02.corp.sa.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, linux-usb@vger.kernel.org,
	greg@kroah.com, linux-scsi@vger.kernel.org, netdev@vger.kernel.org,
	arjan@infradead.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-scsi-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In days of yore, great fields of USB devices were discovered and initialized
long before they were harvested for use. Race conditions were unknown, and
all was well. As time passed in the land of Linux, the tilling of the bit
fields yielded great reductions in boot time, and there was much rejoicing.
Yet, some dispaired, for things were not as they had once been. The now-
hasty arrival at /bin/init startup meant some USB devices were not yet fully
ripened, leaving /dev/console unopened and network devices unconfigured.

In less rural language, my embedded system has no USB console and no USB
network device to telnet into.  Since 2.6.28.  Plenty of woe.

This patch adds infrastructure to allow bus support code to indicate
when it is in the process of asynchronously discovering devices. This allows
code that might want to use those devices during kernel boot to wait until
all attached devices are discovered and initialized.  Synchronization is
done by device type, so there is no need for block devices to wait for the
console to be initialized. Block, console, and network devices are currently
supported on USB and SCII buses.

And all was, well, better.

(Many thanks to Alan Stern, who said we could solve this without offensive
timeouts and then set about doing the integration into USB and SCSI)

History
v5	Change nomenclature to refer to initdevs instead of bootdevs.
	Devices supported by loadable modules can't be init devices, so
	create initdev_* functions that do nothing if MODULE is defined.
v4	Update documentation and move to its own file. Change names of
	functions to remove leading "bus_". Move functions into
	drivers/base/bootdev.c. Fix NETCONSOLE handling. Add function to
	be called from subsystems to wakeup waiters.
v3	Modify bus_bootdev_type_found to avoid superfluous wakeups.
v2      Remove global wait_queue for buses in favor of using the per-boot
	device type wait_queues. Correct wait condition in bus_wait_for_bootdev
	so that the done function will be called even if devices are still
	being discovered. Added bus_bootdev_type_found.
v1	Original release

Signed-off-by: David VomLehn <dvomlehn@cisco.com>
---
 Documentation/driver-model/initdev.txt |  115 +++++++++++++++++++
 drivers/base/Makefile                  |    3 +-
 drivers/base/base.h                    |    1 +
 drivers/base/init.c                    |    1 +
 drivers/base/initdev.c                 |  189 ++++++++++++++++++++++++++++++++
 include/linux/device.h                 |   51 +++++++++
 6 files changed, 359 insertions(+), 1 deletions(-)

diff --git a/Documentation/driver-model/initdev.txt b/Documentation/driver-model/initdev.txt
new file mode 100644
index 0000000..efc0679
--- /dev/null
+++ b/Documentation/driver-model/initdev.txt
@@ -0,0 +1,115 @@
+Init Device Discovery Synchronization
+=====================================
+Init devices are those devices that must be used or configured before
+starting up the /bin/init process.  They may be explicitly specified as
+kernel command line parameters, such as console=ttyUSB0,115200, or
+implicitly specified, such as ip=dhcp.
+
+Earlier versions of the Linux kernel used a single-threaded approach to
+boot initialization. This took a number of seconds, which meant that
+devices were generally set up before being used or configured. Modern
+kernels use a multithreaded approach, which requires synchronization between
+code that probes and initializes init devices, and code that uses and
+configures them.  Support of fine-grained boot concurrency requires
+distinguishing between types of init devices, so that devices can be used as
+soon as they are initialized.
+
+There are several types of init devices:
+-	consoles
+-	network devices
+-	block devices
+
+There is a distinction between the hardware type and the init device type.
+From the hardware view, most any serial device can be used as a console,
+but console support is generally configured separately. For example, USB
+serial devices should be considered console init devices only if the
+kernel is configured to support this usage. This is done by enabling the
+CONFIG_USB_SERIAL_CONSOLE option. If this option is disabled, the USB bus
+driver should not report that it has found any console devices.
+
+The sequence for buses with asynchronously-discoverable init devices is:
+1.	As each possible init devices is discovered, call initdev_found.
+2.	Optionally, if the device type wasn't known at the time
+	initdev_found was called but is determined later, call
+	initdev_type_found when the type is found.
+3.	As initialization is complete for each device, call
+	initdev_probe_done.
+
+Per-Device Functions
+--------------------
+Functions used to indicate the status of asynchronous device discovery on
+a device-by-device basis are:
+
+initdev_found(int initdev_mask)
+	This function must be called each time a possible init device device
+	is found.  It is passed a bit mask created by ORing any of the
+	following flags that apply to the device found:
+		BOOTDEV_CONSOLE_MASK
+		BOOTDEV_NETDEV_MASK
+		BOOTDEV_BLOCK_MASK
+	There is no need to call this function for a given device if it is
+	known that it cannot be used as a init device. If it is not
+	possible to determine whether a device is usable as a init device,
+	or the specific type of a init device, the argument BOOTDEV_ANY_MASK
+	should be passed.  This should be used only when necessary, as it
+	reduces the level of boot-time concurrency.
+
+initdev_type_found(int initdev_mask, enum initdev_type type)
+	If the type of a init device could not be found, but was determined
+	later, this function can be used to indicate the device type. It
+	is passed the mask that was originally passed to initdev_found.
+	Note that, if a device for which initdev_found is called is
+	subsequently determine not to be a possible init device, this function
+	should not be called. Instead, initdev_probe_done should be
+	called.
+
+initdev_probe_done(int initdev_mask)
+	This function indicates that initialization is complete for a device
+	which may be one of the init device types indicated by initdev_mask.
+	Note that calling this function does not imply that device
+	initialization has been successful; if initdev_found is called for a
+	device, initdev_probe_done must be called even if an error occurred.
+
+Some rules about correct usage:
+o	Each call to initdev_found *must* be matched by a call to
+	initdev_probe_done.
+o	The function initdev_type_found may be used only once for a given
+	device and must be called between the calls to initdev_found and
+	initdev_probe_done for that device.
+o	If initdev_type_found is called:
+	-	The value of initdev_mask must be the same as that passed to
+		initdev_found.
+	-	The bit corresponding to the type argument must have been set
+		in the initdev_mask argument of initdev_found.
+	-	The value of initdev_mask in the call to initdev_probe_done
+		must consist only of the bit corresponding to the argument
+		type passed to initdev_type_found.
+o	If initdev_type_found is not called, the value of initdev_mask
+	passed to initdev_found and initdev_probe_done for a given
+	device must be identical.
+
+Subsystem Functions
+-------------------
+Boot devices are registered with the appropriate subsystem as they are found
+Each subsystem determines when the init devices is manages are ready for use.
+
+initdev_wait(enum initdev_type type, bool (*done)(void))
+	Wait until one of two conditions is met:
+	o	All possible init devices of the given type have been probed
+	o	The "done" function returns true
+
+	The type is one of:
+		BOOTDEV_CONSOLE
+		BOOTDEV_NETDEV
+		BOOTDEV_BLOCK
+	The "done" function is subsystem-dependent and returns true if all
+	init devices required for that subsystem to continue booting have
+	been registered. Registration is indicated through use of the
+	initdev_registered function. If done always returns false,
+	initdev_wait will not return until all possible init devices of the
+	given type have been probed.
+
+initdev_registered(enum initdev_type type)
+	Called by each software subsystem that handles init devices of a given
+	type. For example, register_console would call this function with
+	a type of BOOTDEV_CONSOLE.
diff --git a/drivers/base/Makefile b/drivers/base/Makefile
index b5b8ba5..a288a46 100644
--- a/drivers/base/Makefile
+++ b/drivers/base/Makefile
@@ -3,7 +3,8 @@
 obj-y			:= core.o sys.o bus.o dd.o \
 			   driver.o class.o platform.o \
 			   cpu.o firmware.o init.o map.o devres.o \
-			   attribute_container.o transport_class.o
+			   attribute_container.o transport_class.o \
+			   initdev.o
 obj-y			+= power/
 obj-$(CONFIG_HAS_DMA)	+= dma-mapping.o
 obj-$(CONFIG_ISA)	+= isa.o
diff --git a/drivers/base/base.h b/drivers/base/base.h
index b528145..90dede0 100644
--- a/drivers/base/base.h
+++ b/drivers/base/base.h
@@ -90,6 +90,7 @@ struct device_private {
 	container_of(obj, struct device_private, knode_bus)
 
 /* initialisation functions */
+extern int initdevs_init(void);
 extern int devices_init(void);
 extern int buses_init(void);
 extern int classes_init(void);
diff --git a/drivers/base/init.c b/drivers/base/init.c
index 7bd9b6a..683bc0d 100644
--- a/drivers/base/init.c
+++ b/drivers/base/init.c
@@ -21,6 +21,7 @@ void __init driver_init(void)
 {
 	/* These are the core pieces */
 	devices_init();
+	initdevs_init();
 	buses_init();
 	classes_init();
 	firmware_init();
diff --git a/drivers/base/initdev.c b/drivers/base/initdev.c
new file mode 100644
index 0000000..eaf53e3
--- /dev/null
+++ b/drivers/base/initdev.c
@@ -0,0 +1,189 @@
+/*
+ *			initdev.c
+ *
+ * Primitives to synchronize boot device discovery and initialization with
+ * their boot-time use.
+ *
+ * Copyright (C) 2009  Scientific-Atlanta, Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
+ *
+ * Author: David VomLehn
+ */
+
+#include <linux/types.h>
+#include <linux/wait.h>
+#include <linux/device.h>
+#include <linux/sched.h>
+#include <linux/async.h>
+
+/*
+ * Information about how many boot devices have been found, but for which
+ * probing activity is not yet complete, by type, along with wait queues on
+ * which a wake up will be done as the probing completes.
+ */
+static struct {
+	atomic_t		pending;
+	wait_queue_head_t	wq;
+} initdev_info[BOOTDEV_NUM];
+
+__init int initdevs_init(void)
+{
+	int	i;
+
+	for (i = 0; i < ARRAY_SIZE(initdev_info); i++) {
+		atomic_set(&initdev_info[i].pending, 0);
+		init_waitqueue_head(&initdev_info[i].wq);
+	}
+
+	return 0;
+}
+
+/*
+ * Adds a console bit to the mask of boot devices if network consoles are used
+ * @mask:	Starting mask
+ *
+ * Returns mask with the %BOOTDEV_CONSOLE bit set if network consoles are
+ * configured into the system, since, from the boot device standpoint,
+ * a network device might be used as a console.
+ */
+#ifdef CONFIG_NETCONSOLE
+static int initdev_add_netconsole(int initdev_mask)
+{
+	return (initdev_mask & BOOTDEV_NETDEV_MASK) ?
+		initdev_mask | BOOTDEV_CONSOLE : initdev_mask;
+}
+#else
+static int initdev_add_netconsole(int initdev_mask)
+{
+	return initdev_mask;
+}
+#endif
+
+/**
+ * initdev_found - called when a new device is discovered on a bus.
+ * @initdev_mask:	Mask for possible devices
+ *
+ * The initdev_mask allows a caller to specify a restricted set of boot
+ * devices that might be probed. For example, if the bus is USB, it may be
+ * the case that %CONFIG_USB_SERIAL_CONSOLE is not defined. The call to this
+ * function might then omit %BOOTDEV_CONSOLE from the mask. When we go to
+ * wait for console devices, we won't wait for USB probing to complete. If
+ * a given bus type has no way to determine the type of device being probed,
+ * it can simply pass %BOOTDEV_ALL_MASK, but finer granularity will generally
+ * result in faster boot times.
+ */
+void initdev_found(int initdev_mask)
+{
+	int	i;
+
+	initdev_mask = initdev_add_netconsole(initdev_mask);
+
+	for (i = 0; i < ARRAY_SIZE(initdev_info); i++) {
+		if (initdev_mask & (1 << i))
+			atomic_inc(&initdev_info[i].pending);
+	}
+}
+
+/**
+ * initdev_type_found - called upon determining the type of a boot device
+ * @old_mask:	Mask used in the call to initdev_found
+ * @type:	Type of the boot device
+ *
+ * If initdev_found() was called but the type of the boot device was not
+ * yet available, this function can be called when the type is available.
+ * It allows waiters for boot devices of types other than the given @type
+ * to proceed.
+ */
+void initdev_type_found(int old_mask, enum initdev_type type)
+{
+	int	i;
+
+	old_mask = initdev_add_netconsole(old_mask);
+
+	for (i = 0; i < ARRAY_SIZE(initdev_info); i++) {
+		/* If this is one of the types we are dropping and we reduce
+		 * the pending count for that type of boot device to zero,
+		 * we need to wake up any waiters for that device. Otherwise,
+		 * we still have other devices being waited on and the wakeup
+		 * would be superfluous. */
+		if (i != type && (old_mask & (1 << i))) {
+			if (atomic_dec_return(&initdev_info[i].pending) == 0)
+				wake_up_all(&initdev_info[i].wq);
+		}
+	}
+}
+
+/**
+ * initdev_probe_done - indicate probing is complete for a device on a bus
+ * @initdev_mask:	Mask for possible devices
+ *
+ * The definition of probing complete for a given device is that the driver
+ * for that device must have been able to register its presence with its
+ * associated subsystem. So, devices supporting consoles must have called
+ * register_console(), networking device must have called register_netdevice(),
+ * etc.
+ */
+void initdev_probe_done(int initdev_mask)
+{
+	int	i;
+
+	initdev_mask = initdev_add_netconsole(initdev_mask);
+
+	for (i = 0; i < ARRAY_SIZE(initdev_info); i++) {
+		/* Decrement the count of pending probes and, if we reach
+		 * zero, wake up all waiters. */
+		if (initdev_mask & (1 << i)) {
+			if (atomic_dec_return(&initdev_info[i].pending) == 0)
+				wake_up_all(&initdev_info[i].wq);
+		}
+	}
+}
+
+/**
+ * initdev_wait - wait until desired boot devices are registered or probing done
+ * @type:	Type of boot device to wait for
+ * @done:	Pointer to function that determines whether all boot devices
+ *		have been acquired.
+ *
+ * This function exits if all devices of the given @type have been probed or
+ * the passed function indicates that all the expected boot devices have been
+ * acquired. Say, for example the kernel command line specifies the name of
+ * a boot device to use. The @done function can check to see whether that
+ * device has been registered and, if so, return true. This function will
+ * return even though probing has not completed on some devices, which allows
+ * faster boot times.
+ */
+void initdev_wait(enum initdev_type type, bool (*done)(void))
+{
+	/* Wait until initdev_probe_done has been called for all of the devices
+	 * of the type for which we are waiting, or for some minimal set of
+	 * those devices to be ready. This last condition is defined by the
+	 * caller through the implementation of the callback function. */
+	wait_event(initdev_info[type].wq,
+		done() || atomic_read(&initdev_info[type].pending) == 0);
+}
+
+/**
+ * initdev_registered - indicate boot device registration by its subsystem
+ * @type:	Type of boot device
+ *
+ * This will wake up all threads waiting on a given boot device @type so that
+ * they can see if they are ready to continue.
+ */
+void initdev_registered(enum initdev_type type)
+{
+	wake_up_all(&initdev_info[type].wq);
+}
diff --git a/include/linux/device.h b/include/linux/device.h
index 6a69caa..1e6b729 100644
--- a/include/linux/device.h
+++ b/include/linux/device.h
@@ -94,6 +94,57 @@ int __must_check bus_for_each_drv(struct bus_type *bus,
 void bus_sort_breadthfirst(struct bus_type *bus,
 			   int (*compare)(const struct device *a,
 					  const struct device *b));
+
+/*
+ * Definitions for synchronizing discovery of asynchronously-discoverable
+ * devices with their use as boot devices.
+ */
+/*
+ * Define boot device types. These are not the same as the device classes
+ * supported by various buses, but are tied to support of specific Linux kernel
+ * devices. For example, USB knows about serial devices, but a serial device
+ * is only a BOOTDEV_CONSOLE if CONFIG_USB_SERIAL_CONSOLE is defined.
+ */
+#define	BOOTDEV_CONSOLE_MASK	(1 << BOOTDEV_CONSOLE)
+#define	BOOTDEV_NETDEV_MASK	(1 << BOOTDEV_NETDEV)
+#define BOOTDEV_BLOCK_MASK	(1 << BOOTDEV_BLOCK)
+#define	BOOTDEV_ANY_MASK	((1 << BOOTDEV_NUM) - 1)
+
+enum initdev_type {
+	BOOTDEV_CONSOLE,		/* Device usable as a console */
+	BOOTDEV_NETDEV,			/* Autoconfigurable network device */
+	BOOTDEV_BLOCK,			/* Block device for boot filesystem */
+	BOOTDEV_NUM			/* Number of boot devices */
+};
+
+#ifndef MODULE
+extern void initdev_found(int initdev_mask);
+extern void initdev_type_found(int initdev_mask, enum initdev_type type);
+extern void initdev_probe_done(int initdev_mask);
+extern void initdev_registered(enum initdev_type type);
+extern void initdev_wait(enum initdev_type type, bool (*done)(void));
+#else
+static inline void initdev_found(int initdev_mask)
+{
+}
+
+static inline void initdev_type_found(int initdev_mask, enum initdev_type type)
+{
+}
+
+static inline void initdev_probe_done(int initdev_mask)
+{
+}
+
+static inline void initdev_registered(enum initdev_type type)
+{
+}
+
+static inline void initdev_wait(enum initdev_type type, bool (*done)(void))
+{
+}
+#endif
+
 /*
  * Bus notifiers: Get notified of addition/removal of devices
  * and binding/unbinding of drivers to devices.
