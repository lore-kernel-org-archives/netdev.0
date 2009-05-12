From: Wolfgang Grandegger <wg@grandegger.com>
Subject: [PATCH v2 1/7] [PATCH 1/8] can: Documentation for the CAN device driver interface
Date: Tue, 12 May 2009 11:27:58 +0200
Message-ID: <20090512092757.243124409@denx.de>
References: <20090512092757.048938233@denx.de>
Cc: linux-kernel@vger.kernel.org,
	Wolfgang Grandegger <wg@grandegger.com>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758091AbZELJ3B@vger.kernel.org>
Content-Disposition: inline; filename=01-driver-documentation.patch
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch documents the CAN netowrk device drivers interface, removes
obsolete documentation and adds some useful links to CAN resources.

Signed-off-by: Wolfgang Grandegger <wg@grandegger.com>
Signed-off-by: Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
---
 Documentation/networking/can.txt |  239 ++++++++++++++++++++++++++++++++-------
 1 file changed, 199 insertions(+), 40 deletions(-)

Index: net-next-2.6/Documentation/networking/can.txt
===================================================================
--- net-next-2.6.orig/Documentation/networking/can.txt	2009-05-12 10:47:10.546720893 +0200
+++ net-next-2.6/Documentation/networking/can.txt	2009-05-12 10:47:23.470719178 +0200
@@ -36,10 +36,15 @@
     6.2 local loopback of sent frames
     6.3 CAN controller hardware filters
     6.4 The virtual CAN driver (vcan)
-    6.5 currently supported CAN hardware
-    6.6 todo
+    6.5 The CAN network device driver interface
+      6.5.1 Netlink interface to set/get devices properties
+      6.5.2 Setting the CAN bit-timing
+      6.5.3 Starting and stopping the CAN network device
+    6.6 supported CAN hardware
 
-  7 Credits
+  7 Socket CAN resources
+
+  8 Credits
 
 ============================================================================
 
@@ -234,6 +239,8 @@
   the user application using the common CAN filter mechanisms. Inside
   this filter definition the (interested) type of errors may be
   selected. The reception of error frames is disabled by default.
+  The format of the CAN error frame is briefly decribed in the Linux
+  header file "include/linux/can/error.h".
 
 4. How to use Socket CAN
 ------------------------
@@ -605,61 +612,213 @@
   removal of vcan network devices can be managed with the ip(8) tool:
 
   - Create a virtual CAN network interface:
-       ip link add type vcan
+       $ ip link add type vcan
 
   - Create a virtual CAN network interface with a specific name 'vcan42':
-       ip link add dev vcan42 type vcan
+       $ ip link add dev vcan42 type vcan
 
   - Remove a (virtual CAN) network interface 'vcan42':
-       ip link del vcan42
-
-  The tool 'vcan' from the SocketCAN SVN repository on BerliOS is obsolete.
-
-  Virtual CAN network device creation in older Kernels:
-  In Linux Kernel versions < 2.6.24 the vcan driver creates 4 vcan
-  netdevices at module load time by default. This value can be changed
-  with the module parameter 'numdev'. E.g. 'modprobe vcan numdev=8'
-
-  6.5 currently supported CAN hardware
-
-  On the project website http://developer.berlios.de/projects/socketcan
-  there are different drivers available:
-
-    vcan:    Virtual CAN interface driver (if no real hardware is available)
-    sja1000: Philips SJA1000 CAN controller (recommended)
-    i82527:  Intel i82527 CAN controller
-    mscan:   Motorola/Freescale CAN controller (e.g. inside SOC MPC5200)
-    ccan:    CCAN controller core (e.g. inside SOC h7202)
-    slcan:   For a bunch of CAN adaptors that are attached via a
-             serial line ASCII protocol (for serial / USB adaptors)
+       $ ip link del vcan42
 
-  Additionally the different CAN adaptors (ISA/PCI/PCMCIA/USB/Parport)
-  from PEAK Systemtechnik support the CAN netdevice driver model
-  since Linux driver v6.0: http://www.peak-system.com/linux/index.htm
+  6.5 The CAN network device driver interface
 
-  Please check the Mailing Lists on the berlios OSS project website.
+  The CAN network device driver interface provides a generic interface
+  to setup, configure and monitor CAN network devices. The user can then
+  configure the CAN device, like setting the bit-timing parameters, via
+  the netlink interface using the program "ip" from the "IPROUTE2"
+  utility suite. The following chapter describes briefly how to use it.
+  Furthermore, the interface uses a common data structure and exports a
+  set of common functions, which all real CAN network device drivers
+  should use. Please have a look to the SJA1000 or MSCAN driver to
+  understand how to use them. The name of the module is can-dev.ko.
+
+  6.5.1 Netlink interface to set/get devices properties
+
+  The CAN device must be configured via netlink interface. The supported
+  netlink message types are defined and briefly described in
+  "include/linux/can/netlink.h". CAN link support for the program "ip"
+  of the IPROUTE2 utility suite is avaiable and it can be used as shown
+  below:
+
+  - Setting CAN device properties:
+
+    $ ip link set can0 type can help
+    Usage: ip link set DEVICE type can
+    	[ bitrate BITRATE [ sample-point SAMPLE-POINT] ] |
+    	[ tq TQ prop-seg PROP_SEG phase-seg1 PHASE-SEG1
+     	  phase-seg2 PHASE-SEG2 [ sjw SJW ] ]
+
+    	[ loopback { on | off } ]
+    	[ listen-only { on | off } ]
+    	[ triple-sampling { on | off } ]
+
+    	[ restart-ms TIME-MS ]
+    	[ restart ]
+
+    	Where: BITRATE       := { 1..1000000 }
+    	       SAMPLE-POINT  := { 0.000..0.999 }
+    	       TQ            := { NUMBER }
+    	       PROP-SEG      := { 1..8 }
+    	       PHASE-SEG1    := { 1..8 }
+    	       PHASE-SEG2    := { 1..8 }
+    	       SJW           := { 1..4 }
+    	       RESTART-MS    := { 0 | NUMBER }
+
+  - Display CAN device details and statistics:
+
+    $ ip -details -statistics link show can0
+    2: can0: <NOARP,UP,LOWER_UP,ECHO> mtu 16 qdisc pfifo_fast state UP qlen 10
+      link/can
+      can <TRIPLE-SAMPLING> state ERROR-ACTIVE restart-ms 100
+      bitrate 125000 sample_point 0.875
+      tq 125 prop-seg 6 phase-seg1 7 phase-seg2 2 sjw 1
+      sja1000: tseg1 1..16 tseg2 1..8 sjw 1..4 brp 1..64 brp-inc 1
+      clock 8000000
+      re-started bus-errors arbit-lost error-warn error-pass bus-off
+      41         17457      0          41         42         41
+      RX: bytes  packets  errors  dropped overrun mcast
+      140859     17608    17457   0       0       0
+      TX: bytes  packets  errors  dropped carrier collsns
+      861        112      0       41      0       0
+
+  More info to the above output:
+
+    "<TRIPLE-SAMPLING>"
+	Shows the list of selected CAN controller modes: LOOPBACK,
+	LISTEN-ONLY, or TRIPLE-SAMPLING.
+
+    "state ERROR-ACTIVE"
+	The current state of the CAN controller: "ERROR-ACTIVE",
+	"ERROR-WARNING", "ERROR-PASSIVE", "BUS-OFF" or "STOPPED"
+
+    "restart-ms 100"
+	Automatic restart delay time. If set to a non-zero value, a
+	restart of the CAN controller will be triggered automatically
+	in case of a bus-off condition after the specified delay time
+	in milliseconds. By default it's off.
+
+    "bitrate 125000 sample_point 0.875"
+	Shows the real bit-rate in bits/sec and the sample-point in the
+	range 0.000..0.999. If the calculation of bit-timing parameters
+	is enabled in the kernel (CONFIG_CAN_CALC_BITTIMING=y), the
+	bit-timing can be defined by setting the "bitrate" argument.
+	Optionally the "sample-point" can be specified. By default it's
+	0.000 assuming CIA-recommended sample-points.
+
+    "tq 125 prop-seg 6 phase-seg1 7 phase-seg2 2 sjw 1"
+	Shows the time quanta in ns, propagation segment, phase buffer
+	segment 1 and 2 and the synchronisation jump width in units of
+	tq. They allow to define the CAN bit-timing in a hardware
+	independent format as proposed by the Bosch CAN 2.0 spec (see
+	chapter 8 of http://www.semiconductors.bosch.de/pdf/can2spec.pdf).
+
+    "sja1000: tseg1 1..16 tseg2 1..8 sjw 1..4 brp 1..64 brp-inc 1
+     clock 8000000"
+	Shows the bit-timing constants of the CAN controller, here the
+	"sja1000". The minimum and maximum values of the time segment 1
+	and 2, the synchronisation jump width in units of tq, the
+	bitrate pre-scaler and the CAN system clock frequency in Hz.
+	These constants could be used for user-defined (non-standard)
+	bit-timing calculation algorithms in user-space.
+
+    "re-started bus-errors arbit-lost error-warn error-pass bus-off"
+	Shows the number of restarts, bus and arbitration lost errors,
+	and the state changes to the error-warning, error-passive and
+	bus-off state. RX overrun errors are listed in the "overrun"
+	field of the standard network statistics.
+
+  6.5.2 Setting the CAN bit-timing
+
+  The CAN bit-timing parameters can always be defined in a hardware
+  independent format as proposed in the Bosch CAN 2.0 specification
+  specifying the arguments "tq", "prop_seg", "phase_seg1", "phase_seg2"
+  and "sjw":
+
+    $ ip link set canX type can tq 125 prop-seg 6 \
+				phase-seg1 7 phase-seg2 2 sjw 1
+
+  If the kernel option CONFIG_CAN_CALC_BITTIMING is enabled, CIA
+  recommended CAN bit-timing parameters will be calculated if the bit-
+  rate is specified with the argument "bitrate":
+
+    $ ip link set canX type can bitrate 125000
+
+  Note that this works fine for the most common CAN controllers with
+  standard bit-rates but may *fail* for exotic bit-rates or CAN system
+  clock frequencies. Disabling CONFIG_CAN_CALC_BITTIMING saves some
+  space and allows user-space tools to solely determine and set the
+  bit-timing parameters. The CAN controller specific bit-timing
+  constants can be used for that purpose. They are listed by the
+  following command:
+
+    $ ip -details link show can0
+    ...
+      sja1000: clock 8000000 tseg1 1..16 tseg2 1..8 sjw 1..4 brp 1..64 brp-inc 1
+
+  6.5.3 Starting and stopping the CAN network device
+
+  A CAN network device is started or stopped as usual with the command
+  "ifconfig canX up/down" or "ip link set canX up/down". Be aware that
+  you *must* define proper bit-timing parameters for real CAN devices
+  before you can start it to avoid error-prone default settings:
+
+    $ ip link set canX up type can bitrate 125000
+
+  A device may enter the "bus-off" state if too much errors occurred on
+  the CAN bus. Then no more messages are received or sent. An automatic
+  bus-off recovery can be enabled by setting the "restart-ms" to a
+  non-zero value, e.g.:
+
+    $ ip link set canX type can restart-ms 100
+
+  Alternatively, the application may realize the "bus-off" condition
+  by monitoring CAN error frames and do a restart when appropriate with
+  the command:
+
+    $ ip link set canX type can restart
+
+  Note that a restart will also create a CAN error frame (see also
+  chapter 3.4).
+
+  6.6 Supported CAN hardware
+
+  Please check the "Kconfig" file in "drivers/net/can" to get an actual
+  list of the support CAN hardware. On the Socket CAN project website
+  (see chapter 7) there might be further drivers available, also for
+  older kernel versions.
+
+7. Socket CAN resources
+-----------------------
+
+  You can find further resources for Socket CAN like user space tools,
+  support for old kernel versions, more drivers, mailing lists, etc.
+  at the BerliOS OSS project website for Socket CAN:
 
-  6.6 todo
+    http://developer.berlios.de/projects/socketcan
 
-  The configuration interface for CAN network drivers is still an open
-  issue that has not been finalized in the socketcan project. Also the
-  idea of having a library module (candev.ko) that holds functions
-  that are needed by all CAN netdevices is not ready to ship.
-  Your contribution is welcome.
+  If you have questions, bug fixes, etc., don't hesitate to post them to
+  the Socketcan-Users mailing list. But please search the archives first.
 
-7. Credits
+8. Credits
 ----------
 
-  Oliver Hartkopp (PF_CAN core, filters, drivers, bcm)
+  Oliver Hartkopp (PF_CAN core, filters, drivers, bcm, SJA1000 driver)
   Urs Thuermann (PF_CAN core, kernel integration, socket interfaces, raw, vcan)
   Jan Kizka (RT-SocketCAN core, Socket-API reconciliation)
-  Wolfgang Grandegger (RT-SocketCAN core & drivers, Raw Socket-API reviews)
+  Wolfgang Grandegger (RT-SocketCAN core & drivers, Raw Socket-API reviews,
+                       CAN device driver interface, MSCAN driver)
   Robert Schwebel (design reviews, PTXdist integration)
   Marc Kleine-Budde (design reviews, Kernel 2.6 cleanups, drivers)
   Benedikt Spranger (reviews)
   Thomas Gleixner (LKML reviews, coding style, posting hints)
-  Andrey Volkov (kernel subtree structure, ioctls, mscan driver)
+  Andrey Volkov (kernel subtree structure, ioctls, MSCAN driver)
   Matthias Brukner (first SJA1000 CAN netdevice implementation Q2/2003)
   Klaus Hitschler (PEAK driver integration)
   Uwe Koppe (CAN netdevices with PF_PACKET approach)
   Michael Schulze (driver layer loopback requirement, RT CAN drivers review)
+  Pavel Pisa (Bit-timing calculation)
+  Sascha Hauer (SJA1000 platform driver)
+  Sebastian Haas (SJA1000 EMS PCI driver)
+  Markus Plessing (SJA1000 EMS PCI driver)
+  Per Dalen (SJA1000 Kvaser PCI driver)
+  Sam Ravnborg (reviews, coding style, kbuild help)
