From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 14/39] i2400m: documentation and instructions for usage
Date: Mon, 24 Nov 2008 13:50:37 -0800
Message-ID: <ba4e174971f44fa95fe1458c0ec73ef7a7debad1.1227562829.git.inaky@linux.intel.com>
References: <cover.1227562829.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga12.intel.com ([143.182.124.36]:57411 "EHLO
	azsmga102.ch.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753219AbYKXVvY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 16:51:24 -0500
In-Reply-To: <cover.1227562829.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver for the i2400m is a stacked driver. There is a core driver,
the bus-generic driver that has no knowledge or dependencies on how
the device is connected to the system; it only knows how to speak the
device protocol. Then there are the bus-specific drivers (for USB and
SDIO) that provide backends for the generic driver to communicate with
the device.

The bus generic driver connects to the network and WiMAX stacks on the
top side, and on the bottom to the bus-specific drivers.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 Documentation/wimax/README.i2400m |  235 +++++++++++++++++++++++++++++++++++++
 1 files changed, 235 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/wimax/README.i2400m

diff --git a/Documentation/wimax/README.i2400m b/Documentation/wimax/README.i2400m
new file mode 100644
index 0000000..11ac5dc
--- /dev/null
+++ b/Documentation/wimax/README.i2400m
@@ -0,0 +1,235 @@
+   Driver for the Intel Wireless Wimax Connection 2400m
+
+   (C) 2008 Intel Corporation < linux-wimax@intel.com >
+
+   This provides a driver for the Intel Wireless WiMAX Connection 2400m
+   and a basic Linux kernel WiMAX stack.
+
+Requirements
+
+     * Linux installation with Linux kernel 2.6.22 or newer (if building
+       from a separate tree)
+     * Intel i2400m Echo Peak or Baxter Peak
+     * build tools:
+          + Linux kernel development package for the target kernel; to
+            build against your currently running kernel, you need to have
+            the kernel development package corresponding to the running
+            image installed (usually if your kernel is named
+            linux-VERSION, the development package is called
+            linux-dev-VERSION or linux-headers-VERSION).
+          + GNU C Compiler, make
+
+Compilation and installation
+
+Compilation of the drivers included in the kernel
+
+   Configure the kernel; to enable the WiMAX drivers select Drivers >
+   Networking Drivers > WiMAX device support. Enable all of them as
+   modules (easier).
+
+   If USB or SDIO are not enabled in the kernel configuration, the options
+   to build the i2400m USB or SDIO drivers will not show. Enable said
+   subsystems and go back to the WiMAX menu to enable the drivers.
+
+   Compile and install your kernel as usual.
+
+Compilation of the drivers distributed as an standalone module
+
+   To compile
+
+$ cd source/directory
+$ make
+
+   Once built you can load and unload using the provided load.sh script;
+   load.sh will load the modules, load.sh u will unload them.
+
+   To install in the default kernel directories (and enable auto loading
+   when the device is plugged):
+
+$ make install
+$ depmod -a
+
+   If your kernel development files are located in a non standard
+   directory or if you want to build for a kernel that is not the
+   currently running one, set KDIR to the right location:
+
+$ make KDIR=/path/to/kernel/dev/tree
+
+   For more information, please contact linux-wimax@intel.com.
+
+Installing the firmware
+
+   The firmware can be obtained from http://linuxwimax.org or might have
+   been supplied with your hardware.
+
+   It has to be installed in the target system:
+     *
+$ cp FIRMWAREFILE.sbcf /lib/firmware/i2400m-fw-BUSTYPE-1.3.sbcf
+
+     * NOTE: if your firmware came in an .rpm or .deb file, just install
+       it as normal, with the rpm (rpm -i FIRMWARE.rpm) or dpkg
+       (dpkg -i FIRMWARE.deb) commands. No further action is needed.
+     * BUSTYPE will be usb or sdio, depending on the hardware you have.
+       Each hardware type comes with its own firmware and will not work
+       with other types.
+
+Design
+
+   This package contains two major parts: a WiMAX kernel stack and a
+   driver for the Intel i2400m.
+
+   The WiMAX stack is designed to provide for common WiMAX control
+   services to current and future WiMAX devices from any vendor; please
+   see README.wimax for details.
+
+   The i2400m kernel driver is broken up in two main parts: the bus
+   generic driver and the bus-specific drivers. The bus generic driver
+   forms the drivercore and contain no knowledge of the actual method we
+   use to connect to the device. The bus specific drivers are just the
+   glue to connect the bus-generic driver and the device. Currently only
+   USB and SDIO are supported. See drivers/net/wimax/i2400m/i2400m.h for
+   more information.
+
+   The bus generic driver is logically broken up in two parts: OS-glue and
+   hardware-glue. The OS-glue interfaces with Linux. The hardware-glue
+   interfaces with the device on using an interface provided by the
+   bus-specific driver. The reason for this breakup is to be able to
+   easily reuse the hardware-glue to write drivers for other OSes; note
+   the hardware glue part is written as a native Linux driver; no
+   abstraction layers are used, so to port to another OS, the Linux kernel
+   API calls should be replaced with the target OS's.
+
+Usage
+
+   To load the driver, follow the instructions in the install section;
+   once the driver is loaded, plug in the device (unless it is permanently
+   plugged in). The driver will enumerate the device, upload the firmware
+   and output messages in the kernel log (dmesg, /var/log/messages or
+   /var/log/kern.log) such as:
+
+...
+i2400m_usb 5-4:1.0: firmware interface version 8.0.0
+i2400m_usb 5-4:1.0: WiMAX interface wmx0 (00:1d:e1:01:94:2c) ready
+
+   At this point the device is ready to work.
+
+   Current versions require the Intel WiMAX Network Service in userspace
+   to make things work. See the network service's README for instructions
+   on how to scan, connect and disconnect.
+
+Module parameters
+
+   Module parameters can be set at kernel or module load time or by
+   echoing values:
+
+$ echo VALUE > /sys/module/MODULENAME/parameters/PARAMETERNAME
+
+   To make changes permanent, for example, for the i2400m module, you can
+   also create a file named /etc/modprobe.d/i2400m containing:
+
+options i2400m idle_mode_disabled=1
+
+   To find which parameters are supported by a module, run:
+
+$ modinfo path/to/module.ko
+
+   During kernel bootup (if the driver is linked in the kernel), specify
+   the following to the kernel command line:
+
+i2400m.PARAMETER=VALUE
+
+i2400m: idle_mode_disabled
+
+   The i2400m module supports a parameter to disable idle mode. This
+   parameter, once set, will take effect only when the device is
+   reinitialized by the driver (eg: following a reset or a reconnect).
+
+Controlling the device through sysfs
+
+   sysfs files to control the device behaviour are located in the
+   per-device directories /sys/class/net/wmxX*:
+
+$ cd /sys/class/net/wmx0
+$ ls -1 wimax/* i2400m*
+i2400m_debug
+i2400m_debug_levels
+i2400m_reset_cold
+i2400m_reset_warm
+i2400m_rx_stats
+i2400m_suspend
+i2400m_trace_msg_from_user
+i2400m_tx_stats
+i2400m_usb_debug_levels
+wimax/debug_levels
+wimax/gnl_family_id
+wimax/gnl_version
+
+Increasing debug output
+
+   Each *debug_levels file corresponds controls the debug level settings
+   for a module (wimax, i2400m or i2400m-usb). Each one contains a list of
+   submodules and their current debug levels (default to zero):
+
+$ cat i2400m_debug_levels
+0 control
+0 driver
+0 fw
+0 netdev
+0 rfkill
+0 rx
+0 sysfs
+0 tx
+
+   To increase the debug level of, for example, the TX engine, just write:
+
+$ echo 3 tx > i2400m_debug_levels
+
+   Increasing numbers yield increasing debug information; for deatails of
+   what is printed, check the source.
+
+Performing a device reset
+
+   By writing a 1 to the i2400m_reset_cold file, the device will be
+   disconnected from the bus and reenumerated (as if the device had been
+   physically plugged in and out.
+
+   By writing a 1 to the i2400m_reset_warm file, the device will
+   internally reset, but not reconnect to the bus.
+
+   This feature is currently not working.
+
+RX and TX statistics
+
+   This file provides with statistics about the data reception from the
+   device:
+
+$ cat /sys/class/net/wmx0/i2400m_rx_stats
+45 1 3
+34 3104 48 480
+
+   The numbers reported are
+     * packets/RX-buffer: total, min, max
+     * RX-buffers: total RX buffers received, accumulated RX buffer size
+       in bytes, min size received, max size received
+
+   Thus, to find the average buffer size received, divide accumulated
+   RX-buffer / total RX-buffers.
+
+   To clear the statistics back to 0:
+
+$ echo 1 > /sys/class/net/wmx0/i2400m_rx_stats
+
+   Likewise for TX
+
+Troubleshooting
+
+Driver complains about 'i2400m-fw-usb-1.2.sbcf: request failed'
+
+   If upon connecting the device, the following is output in the kernel
+   log:
+
+i2400m_usb 5-4:1.0: fw i2400m-fw-usb-1.3.sbcf: request failed: -2
+
+   This means that the driver cannot locate the firmware file named
+   /lib/firmware/i2400m-fw-usb-1.2.sbcf. Check that the file is present in
+   the right location.
-- 
1.5.6.5

