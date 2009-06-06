From: David VomLehn <dvomlehn@cisco.com>
Subject: [PATCH 1/7] initdev:kernel:Asynchronously-discovered device
	synchronization, v6
Date: Fri, 5 Jun 2009 19:34:03 -0700
Message-ID: <20090606023403.GA5645@cuplxvomd02.corp.sa.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, linux-usb@vger.kernel.org,
	greg@kroah.com, linux-scsi@vger.kernel.org, netdev@vger.kernel.org,
	arjan@infradead.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:62814 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753104AbZFFDAl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Jun 2009 23:00:41 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the initdev infrastructure used by the rest of the patches. See
Documentation/driver-model/initdev.txt for details on these functions.

History
v6	o	Change names of initdev types and masks to be INITDEV_*
		instead of BOOTDEV_*.
	o	Drop initdev_type_found; it's not really needed.
	o	Add _TYPE to the enumerated initdev_type names to distinguish
		more clearly from the masks created from these values.
	o	Initdevs_init() no longer returns a type as one isn't needed.
	o	Fix initdev_add_netconsole so that it ORs in a mask and not
		a type.
	o	Use atomic_dec_and_test() instead of checking the return
		value from atomic_dec_return().
	o	Do initialization purely by initialization, removing the
		need to call initdevs_init().
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
 Documentation/driver-model/initdev.txt |   91 ++++++++++++++++++
 drivers/base/Makefile                  |    3 +-
 drivers/base/base.h                    |    1 +
 drivers/base/initdev.c                 |  164 ++++++++++++++++++++++++++++++++
 include/linux/device.h                 |   51 ++++++++++
 5 files changed, 309 insertions(+), 1 deletions(-)

diff --git a/Documentation/driver-model/initdev.txt b/Documentation/driver-model/initdev.txt
new file mode 100644
index 0000000..0bb4bc0
--- /dev/null
+++ b/Documentation/driver-model/initdev.txt
@@ -0,0 +1,91 @@
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
+2.	As initialization is complete for each device, call
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
+		INITDEV_CONSOLE_MASK
+		INITDEV_NETDEV_MASK
+		INITDEV_BLOCK_MASK
+	There is no need to call this function for a given device if it is
+	known that it cannot be used as a init device. If it is not
+	possible to determine whether a device is usable as a init device,
+	or the specific type of a init device, the argument INITDEV_ANY_MASK
+	should be passed.  This should be used only when necessary, as it
+	reduces the level of boot-time concurrency.
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
+o	The value of initdev_mask passed to initdev_found and
+	initdev_probe_done for a given device must be identical.
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
+		INITDEV_CONSOLE_TYPE
+		INITDEV_NETDEV_TYPE
+		INITDEV_BLOCK_TYPE
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
+	a type of INITDEV_CONSOLE_TYPE.
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
diff --git a/drivers/base/initdev.c b/drivers/base/initdev.c
new file mode 100644
index 0000000..62b7c45
--- /dev/null
+++ b/drivers/base/initdev.c
@@ -0,0 +1,164 @@
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
+} initdev_info[INITDEV_TYPE_NUM] = {
+	[INITDEV_CONSOLE_TYPE] = {
+		ATOMIC_INIT(0),
+		__WAIT_QUEUE_HEAD_INITIALIZER(initdev_info
+			[INITDEV_CONSOLE_TYPE].wq)
+	},
+	[INITDEV_NETDEV_TYPE] = {
+		ATOMIC_INIT(0),
+		__WAIT_QUEUE_HEAD_INITIALIZER(initdev_info
+			[INITDEV_NETDEV_TYPE].wq)
+	},
+	[INITDEV_BLOCK_TYPE] = {
+		ATOMIC_INIT(0),
+		__WAIT_QUEUE_HEAD_INITIALIZER(initdev_info
+			[INITDEV_BLOCK_TYPE].wq)
+	},
+};
+
+/*
+ * Adds a console bit to the mask of boot devices if network consoles are used
+ * @mask:	Starting mask
+ *
+ * Returns mask with the %INITDEV_CONSOLE_TYPE bit set if network consoles are
+ * configured into the system, since, from the boot device standpoint,
+ * a network device might be used as a console.
+ */
+#ifdef CONFIG_NETCONSOLE
+static int initdev_add_netconsole(int initdev_mask)
+{
+	return (initdev_mask & INITDEV_NETDEV_MASK) ?
+		(initdev_mask | INITDEV_CONSOLE_MASK) : initdev_mask;
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
+ * function might then omit %INITDEV_CONSOLE_MASK from the mask. When we go to
+ * wait for console devices, we won't wait for USB probing to complete. If
+ * a given bus type has no way to determine the type of device being probed,
+ * it can simply pass %INITDEV_ALL_MASK, but finer granularity will generally
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
+			if (atomic_dec_and_test(&initdev_info[i].pending))
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
index 5d5c197..7ab8e22 100644
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
+ * is only a %INITDEV_CONSOLE_TYPE if %CONFIG_USB_SERIAL_CONSOLE is defined.
+ */
+#define	INITDEV_CONSOLE_MASK	(1 << INITDEV_CONSOLE_TYPE)
+#define	INITDEV_NETDEV_MASK	(1 << INITDEV_NETDEV_TYPE)
+#define INITDEV_BLOCK_MASK	(1 << INITDEV_BLOCK_TYPE)
+#define	INITDEV_ANY_MASK	((1 << INITDEV_TYPE_NUM) - 1)
+
+enum initdev_type {
+	INITDEV_CONSOLE_TYPE,		/* Device usable as a console */
+	INITDEV_NETDEV_TYPE,		/* Autoconfigurable network device */
+	INITDEV_BLOCK_TYPE,		/* Block device for boot filesystem */
+	INITDEV_TYPE_NUM		/* Number of boot devices */
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
