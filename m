From: James Ketrenos <jketreno@linux.intel.com>
Subject: [PATCH] ipw2100 v1.1.0
Date: Wed, 23 Mar 2005 17:32:29 -0600
Message-ID: <4241FC8D.40400@linux.intel.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050204000700060403060604"
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050204000700060403060604
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


Ok, we recently pushed the latest version of the IPW2100 driver to a 
stable version.  The last stable version was 1.0.0, which wasn't 
compatible with the latest ieee80211 subsystem currently in netdev-2.6.

In addition to fixing to be compatible w/ the ieee80211 stack, 1.1.0 
also includes quite a few fixes over what was in 1.0.0.

Anyway, attached is the patch against netdev-2.6 (build tested w/ the 
tip of wireless-2.6) that adds ipw2100 1.1.0 to the tree. 

Please let me know your comments and feedback.

I wasn't sure where to actually stick the driver's selection it in the 
Kconfig menu.  Where its at now, it doesn't show up until you enable 
'Generic IEEE 80211 subsystem', and then it shows up down under Wireless 
Lan entries.

Any opposition to creating a Wireless Drivers under the Generic IEEE 
80211 level and putting drivers using that stack into that location?

In terms of the process used for validation on the ipw2100, our plan is 
to only push patches out for kernel mainline inclusion that have gone 
through internal regression testing. 

Kernel API migration changes aren't much of an issue, but any 
functionality changes or fixes would need to go into our development 
versions on SourceForge first before we would want them pushed into 
mainline (assuming we get this into netdev, and then pushed upstream...)

I'll be sending an ipw2200-1.0.0 patch out soon.  We also have some 
fixes for ieee80211 that have been incorporated into the latest 
development snapshots for the ipw2200 project that I'll send a patch out 
for.

Thanks,
James

--------------050204000700060403060604
Content-Type: text/x-patch;
 name="netdev-2.6-ipw2100-1.1.0.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="netdev-2.6-ipw2100-1.1.0.patch"

diff -Nur --exclude=RCS --exclude=CVS --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet netdev-2.6/Documentation/networking/README.ipw2100 ipw2100-2.6/Documentation/networking/README.ipw2100
--- netdev-2.6/Documentation/networking/README.ipw2100	1969-12-31 18:00:00 -06:00
+++ ipw2100-2.6/Documentation/networking/README.ipw2100	2005-03-23 13:13:50 -06:00
@@ -0,0 +1,246 @@
+
+===========================
+Intel(R) PRO/Wireless 2100 Network Connection Driver for Linux
+README.ipw2100
+
+March 14, 2005
+
+===========================
+Index
+---------------------------
+0. Introduction
+1. Release 1.1.0 Current Features
+2. Command Line Parameters
+3. Sysfs Helper Files
+4. Radio Kill Switch
+5. Dynamic Firmware
+6. Power Management
+7. Support
+8. License
+
+
+===========================
+0. Introduction
+------------ -----   -----       ----       ---       --         -     
+
+This document provides a brief overview of the features supported by the 
+IPW2100 driver project.  The main project website, where the latest 
+development version of the driver can be found, is:
+
+	http://ipw2100.sourceforge.net
+
+There you can find the not only the latest releases, but also information about
+potential fixes and patches, as well as links to the development mailing list
+for the driver project.
+
+
+===========================
+1. Release 1.1.0 Current Supported Features
+---------------------------     
+- Managed (BSS) and Ad-Hoc (IBSS)
+- WEP (shared key and open)
+- Wireless Tools support 
+- 802.1x (tested with XSupplicant 1.0.1)
+
+Enabled (but not supported) features:
+- Monitor/RFMon mode
+- WPA/WPA2
+
+The distinction between officially supported and enabled is a reflection
+on the amount of validation and interoperability testing that has been
+performed on a given feature.
+
+
+===========================
+2. Command Line Parameters
+---------------------------     
+
+If the driver is built as a module, the following optional parameters are used
+by entering them on the command line with the modprobe command using this
+syntax:
+
+	modprobe ipw2100 [<option>=<VAL1><,VAL2>...]
+
+For example, to disable the radio on driver loading, enter:
+
+	modprobe ipw2100 disable=1
+
+The ipw2100 driver supports the following module parameters:
+
+Name		Value		Example:
+debug		0x0-0xffffffff	debug=1024
+mode		0,1,2		mode=1   /* AdHoc */
+channel		int		channel=3 /* Only valid in AdHoc or Monitor */
+associate	boolean		associate=0 /* Do NOT auto associate */
+disable		boolean		disable=1 /* Do not power the HW */
+
+
+===========================
+3. Sysfs Helper Files
+---------------------------     
+
+There are several ways to control the behavior of the driver.  Many of the 
+general capabilities are exposed through the Wireless Tools (iwconfig).  There
+are a few capabilities that are exposed through entries in the Linux Sysfs.
+
+
+----- Driver Level ------
+For the driver level files, look in /sys/bus/pci/drivers/ipw2100/
+
+  debug_level  
+	
+	This controls the same global as the 'debug' module parameter.  For 
+        information on the various debugging levels available, run the 'dvals'
+	script found in the driver source directory.
+
+	NOTE:  'debug_level' is only enabled if CONFIG_IPW2100_DEBUG is turn
+	       on.
+
+----- Device Level ------
+For the device level files look in
+	
+	/sys/bus/pci/drivers/ipw2100/{PCI-ID}/
+
+For example:
+	/sys/bus/pci/drivers/ipw2100/0000:02:01.0
+
+For the device level files, see /sys/bus/pci/drivers/ipw2100:
+
+  rf_kill
+	read - 
+	0 = RF kill not enabled (radio on)
+	1 = SW based RF kill active (radio off)
+	2 = HW based RF kill active (radio off)
+	3 = Both HW and SW RF kill active (radio off)
+	write -
+	0 = If SW based RF kill active, turn the radio back on
+	1 = If radio is on, activate SW based RF kill
+
+	NOTE: If you enable the SW based RF kill and then toggle the HW
+  	based RF kill from ON -> OFF -> ON, the radio will NOT come back on
+
+
+===========================
+4. Radio Kill Switch
+---------------------------
+Most laptops provide the ability for the user to physically disable the radio.
+Some vendors have implemented this as a physical switch that requires no
+software to turn the radio off and on.  On other laptops, however, the switch
+is controlled through a button being pressed and a software driver then making
+calls to turn the radio off and on.  This is referred to as a "software based
+RF kill switch"
+
+See the Sysfs helper file 'rf_kill' for determining the state of the RF switch
+on your system.
+
+
+===========================
+5. Dynamic Firmware
+---------------------------     
+As the firmware is licensed under a restricted use license, it can not be 
+included within the kernel sources.  To enable the IPW2100 you will need a 
+firmware image to load into the wireless NIC's processors.
+
+You can obtain these images from <http://ipw2100.sf.net/firmware.php>.
+
+See INSTALL for instructions on installing the firmware.
+
+
+===========================
+6. Power Management
+---------------------------     
+The IPW2100 supports the configuration of the Power Save Protocol 
+through a private wireless extension interface.  The IPW2100 supports 
+the following different modes:
+
+	off	No power management.  Radio is always on.
+	on	Automatic power management
+	1-5	Different levels of power management.  The higher the 
+		number the greater the power savings, but with an impact to 
+		packet latencies. 
+
+Power management works by powering down the radio after a certain 
+interval of time has passed where no packets are passed through the 
+radio.  Once powered down, the radio remains in that state for a given 
+period of time.  For higher power savings, the interval between last 
+packet processed to sleep is shorter and the sleep period is longer.
+
+When the radio is asleep, the access point sending data to the station 
+must buffer packets at the AP until the station wakes up and requests 
+any buffered packets.  If you have an AP that does not correctly support 
+the PSP protocol you may experience packet loss or very poor performance 
+while power management is enabled.  If this is the case, you will need 
+to try and find a firmware update for your AP, or disable power 
+management (via `iwconfig eth1 power off`)
+
+To configure the power level on the IPW2100 you use a combination of 
+iwconfig and iwpriv.  iwconfig is used to turn power management on, off, 
+and set it to auto.
+
+	iwconfig eth1 power off    Disables radio power down
+	iwconfig eth1 power on     Enables radio power management to 
+				   last set level (defaults to AUTO)
+	iwpriv eth1 set_power 0    Sets power level to AUTO and enables 
+				   power management if not previously 
+				   enabled.
+	iwpriv eth1 set_power 1-5  Set the power level as specified, 
+				   enabling power management if not 
+				   previously enabled.
+
+You can view the current power level setting via:
+	
+	iwpriv eth1 get_power
+
+It will return the current period or timeout that is configured as a string
+in the form of xxxx/yyyy (z) where xxxx is the timeout interval (amount of
+time after packet processing), yyyy is the period to sleep (amount of time to 
+wait before powering the radio and querying the access point for buffered
+packets), and z is the 'power level'.  If power management is turned off the
+xxxx/yyyy will be replaced with 'off' -- the level reported will be the active
+level if `iwconfig eth1 power on` is invoked.
+
+
+===========================
+7. Support
+---------------------------     
+
+For general development information and support,
+go to:
+	
+    http://ipw2100.sf.net/
+
+The ipw2100 1.1.0 driver and firmware can be downloaded from:  
+
+    http://support.intel.com
+
+For installation support on the ipw2100 1.1.0 driver on Linux kernels 
+2.6.8 or greater, email support is available from:  
+
+    http://supportmail.intel.com
+
+===========================
+8. License
+---------------------------     
+
+  Copyright(c) 2003 - 2005 Intel Corporation. All rights reserved.
+
+  This program is free software; you can redistribute it and/or modify it 
+  under the terms of the GNU General Public License (version 2) as 
+  published by the Free Software Foundation.
+  
+  This program is distributed in the hope that it will be useful, but WITHOUT 
+  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or 
+  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for 
+  more details.
+  
+  You should have received a copy of the GNU General Public License along with
+  this program; if not, write to the Free Software Foundation, Inc., 59 
+  Temple Place - Suite 330, Boston, MA  02111-1307, USA.
+  
+  The full GNU General Public License is included in this distribution in the
+  file called LICENSE.
+  
+  License Contact Information:
+  James P. Ketrenos <ipw2100-admin@linux.intel.com>
+  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+
diff -Nur --exclude=RCS --exclude=CVS --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet netdev-2.6/drivers/net/wireless/Kconfig ipw2100-2.6/drivers/net/wireless/Kconfig
--- netdev-2.6/drivers/net/wireless/Kconfig	2005-03-23 11:12:09 -06:00
+++ ipw2100-2.6/drivers/net/wireless/Kconfig	2005-03-23 13:50:39 -06:00
@@ -137,6 +137,59 @@
 comment "Wireless 802.11b ISA/PCI cards support"
 	depends on NET_RADIO && (ISA || PCI || PPC_PMAC || PCMCIA)
 
+config IPW2100
+	tristate "Intel PRO/Wireless 2100 Network Connection"
+	depends on NET_RADIO && PCI && IEEE80211
+	select FW_LOADER
+	---help---
+          A driver for the Intel PRO/Wireless 2100 Network 
+	  Connection 802.11b wireless network adapter.
+
+          See <file:Documentation/networking/README.ipw2100> for information on
+          the capabilities currently enabled in this driver and for tips
+          for debugging issues and problems.
+
+	  In order to use this driver, you will need a firmware image for it.
+          You can obtain the firmware from
+	  <http://ipw2100.sf.net/>.  Once you have the firmware image, you 
+	  will need to place it in /etc/firmware.
+
+          You will also very likely need the Wireless Tools in order to
+          configure your card:
+
+          <http://www.hpl.hp.com/personal/Jean_Tourrilhes/Linux/Tools.html>.
+ 
+          If you want to compile the driver as a module ( = code which can be
+          inserted in and remvoed from the running kernel whenever you want),
+          say M here and read <file:Documentation/modules.txt>.  The module
+          will be called ipw2100.ko.
+	
+config IPW2100_PROMISC
+        bool "Enable promiscuous mode"
+        depends on IPW2100
+        ---help---
+	  Enables promiscuous/monitor mode support for the ipw2100 driver.
+	  With this feature compiled into the driver, you can switch to 
+	  promiscuous mode via the Wireless Tool's Monitor mode.  While in this
+	  mode, no packets can be sent.
+
+config IPW_DEBUG
+	bool "Enable full debugging output in IPW2100 module."
+	depends on IPW2100
+	---help---
+	  This option will enable debug tracing output for the IPW2100.  
+
+	  This will result in the kernel module being ~60k larger.  You can 
+	  control which debug output is sent to the kernel log by setting the 
+	  value in 
+
+	  /sys/bus/pci/drivers/ipw2100/debug_level
+
+	  This entry will only exist if this option is enabled.
+
+	  If you are not trying to debug or develop the IPW2100 driver, you 
+	  most likely want to say N here.
+
 config AIRO
 	tristate "Cisco/Aironet 34X/35X/4500/4800 ISA and PCI cards"
 	depends on NET_RADIO && ISA && (PCI || BROKEN)
diff -Nur --exclude=RCS --exclude=CVS --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet netdev-2.6/drivers/net/wireless/Makefile ipw2100-2.6/drivers/net/wireless/Makefile
--- netdev-2.6/drivers/net/wireless/Makefile	2005-03-23 11:12:09 -06:00
+++ ipw2100-2.6/drivers/net/wireless/Makefile	2005-03-23 13:09:54 -06:00
@@ -2,6 +2,8 @@
 # Makefile for the Linux Wireless network device drivers.
 #
 
+obj-$(CONFIG_IPW2100) += ipw2100.o
+
 obj-$(CONFIG_STRIP) += strip.o
 obj-$(CONFIG_ARLAN) += arlan.o 
 
diff -Nur --exclude=RCS --exclude=CVS --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet netdev-2.6/drivers/net/wireless/ipw2100.c ipw2100-2.6/drivers/net/wireless/ipw2100.c
--- netdev-2.6/drivers/net/wireless/ipw2100.c	1969-12-31 18:00:00 -06:00
+++ ipw2100-2.6/drivers/net/wireless/ipw2100.c	2005-03-23 13:31:27 -06:00
@@ -0,0 +1,8649 @@
+/******************************************************************************
+
+  Copyright(c) 2003 - 2005 Intel Corporation. All rights reserved.
+
+  This program is free software; you can redistribute it and/or modify it
+  under the terms of version 2 of the GNU General Public License as
+  published by the Free Software Foundation.
+
+  This program is distributed in the hope that it will be useful, but WITHOUT
+  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+  more details.
+
+  You should have received a copy of the GNU General Public License along with
+  this program; if not, write to the Free Software Foundation, Inc., 59
+  Temple Place - Suite 330, Boston, MA  02111-1307, USA.
+
+  The full GNU General Public License is included in this distribution in the
+  file called LICENSE.
+
+  Contact Information:
+  James P. Ketrenos <ipw2100-admin@linux.intel.com>
+  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+
+  Portions of this file are based on the sample_* files provided by Wireless
+  Extensions 0.26 package and copyright (c) 1997-2003 Jean Tourrilhes
+  <jt@hpl.hp.com>
+
+  Portions of this file are based on the Host AP project,
+  Copyright (c) 2001-2002, SSH Communications Security Corp and Jouni Malinen
+    <jkmaline@cc.hut.fi>
+  Copyright (c) 2002-2003, Jouni Malinen <jkmaline@cc.hut.fi>
+
+  Portions of ipw2100_mod_firmware_load, ipw2100_do_mod_firmware_load, and
+  ipw2100_fw_load are loosely based on drivers/sound/sound_firmware.c
+  available in the 2.4.25 kernel sources, and are copyright (c) Alan Cox
+
+******************************************************************************/
+/*
+
+ Initial driver on which this is based was developed by Janusz Gorycki,
+ Maciej Urbaniak, and Maciej Sosnowski.
+
+ Promiscuous mode support added by Jacek Wysoczynski and Maciej Urbaniak.
+
+Theory of Operation
+
+Tx - Commands and Data
+
+Firmware and host share a circular queue of Transmit Buffer Descriptors (TBDs)
+Each TBD contains a pointer to the physical (dma_addr_t) address of data being
+sent to the firmware as well as the length of the data.
+
+The host writes to the TBD queue at the WRITE index.  The WRITE index points
+to the _next_ packet to be written and is advanced when after the TBD has been
+filled.
+
+The firmware pulls from the TBD queue at the READ index.  The READ index points
+to the currently being read entry, and is advanced once the firmware is
+done with a packet.
+
+When data is sent to the firmware, the first TBD is used to indicate to the
+firmware if a Command or Data is being sent.  If it is Command, all of the
+command information is contained within the physical address referred to by the
+TBD.  If it is Data, the first TBD indicates the type of data packet, number
+of fragments, etc.  The next TBD then referrs to the actual packet location.
+
+The Tx flow cycle is as follows:
+
+1) ipw2100_tx() is called by kernel with SKB to transmit
+2) Packet is move from the tx_free_list and appended to the transmit pending
+   list (tx_pend_list)
+3) work is scheduled to move pending packets into the shared circular queue.
+4) when placing packet in the circular queue, the incoming SKB is DMA mapped
+   to a physical address.  That address is entered into a TBD.  Two TBDs are
+   filled out.  The first indicating a data packet, the second referring to the
+   actual payload data.
+5) the packet is removed from tx_pend_list and placed on the end of the
+   firmware pending list (fw_pend_list)
+6) firmware is notified that the WRITE index has
+7) Once the firmware has processed the TBD, INTA is triggered.
+8) For each Tx interrupt received from the firmware, the READ index is checked
+   to see which TBDs are done being processed.
+9) For each TBD that has been processed, the ISR pulls the oldest packet
+   from the fw_pend_list.
+10)The packet structure contained in the fw_pend_list is then used
+   to unmap the DMA address and to free the SKB originally passed to the driver
+   from the kernel.
+11)The packet structure is placed onto the tx_free_list
+
+The above steps are the same for commands, only the msg_free_list/msg_pend_list
+are used instead of tx_free_list/tx_pend_list
+
+...
+
+Critical Sections / Locking :
+
+There are two locks utilized.  The first is the low level lock (priv->low_lock)
+that protects the following:
+
+- Access to the Tx/Rx queue lists via priv->low_lock. The lists are as follows:
+
+  tx_free_list : Holds pre-allocated Tx buffers.
+    TAIL modified in __ipw2100_tx_process()
+    HEAD modified in ipw2100_tx()
+
+  tx_pend_list : Holds used Tx buffers waiting to go into the TBD ring
+    TAIL modified ipw2100_tx()
+    HEAD modified by X__ipw2100_tx_send_data()
+
+  msg_free_list : Holds pre-allocated Msg (Command) buffers
+    TAIL modified in __ipw2100_tx_process()
+    HEAD modified in ipw2100_hw_send_command()
+
+  msg_pend_list : Holds used Msg buffers waiting to go into the TBD ring
+    TAIL modified in ipw2100_hw_send_command()
+    HEAD modified in X__ipw2100_tx_send_commands()
+
+  The flow of data on the TX side is as follows:
+
+  MSG_FREE_LIST + COMMAND => MSG_PEND_LIST => TBD => MSG_FREE_LIST
+  TX_FREE_LIST + DATA => TX_PEND_LIST => TBD => TX_FREE_LIST
+
+  The methods that work on the TBD ring are protected via priv->low_lock.
+
+- The internal data state of the device itself
+- Access to the firmware read/write indexes for the BD queues
+  and associated logic
+
+All external entry functions are locked with the priv->action_lock to ensure
+that only one external action is invoked at a time.
+
+
+*/
+
+#include <linux/compiler.h>
+#include <linux/config.h>
+#include <linux/errno.h>
+#include <linux/if_arp.h>
+#include <linux/in6.h>
+#include <linux/in.h>
+#include <linux/ip.h>
+#include <linux/kernel.h>
+#include <linux/kmod.h>
+#include <linux/module.h>
+#include <linux/netdevice.h>
+#include <linux/ethtool.h>
+#include <linux/pci.h>
+#include <linux/proc_fs.h>
+#include <linux/skbuff.h>
+#include <asm/uaccess.h>
+#include <asm/io.h>
+#define __KERNEL_SYSCALLS__
+#include <linux/fs.h>
+#include <linux/mm.h>
+#include <linux/slab.h>
+#include <linux/unistd.h>
+#include <linux/stringify.h>
+#include <linux/tcp.h>
+#include <linux/types.h>
+#include <linux/version.h>
+#include <linux/time.h>
+#include <linux/firmware.h>
+#include <linux/acpi.h>
+#include <linux/ctype.h>
+
+#include "ipw2100.h"
+
+#define IPW2100_VERSION "1.1.0"
+
+#define DRV_NAME	"ipw2100"
+#define DRV_VERSION	IPW2100_VERSION
+#define DRV_DESCRIPTION	"Intel(R) PRO/Wireless 2100 Network Driver"
+#define DRV_COPYRIGHT	"Copyright(c) 2003-2004 Intel Corporation"
+
+
+/* Debugging stuff */
+#ifdef CONFIG_IPW_DEBUG
+#define CONFIG_IPW2100_RX_DEBUG   /* Reception debugging */
+#endif
+
+MODULE_DESCRIPTION(DRV_DESCRIPTION);
+MODULE_VERSION(DRV_VERSION);
+MODULE_AUTHOR(DRV_COPYRIGHT);
+MODULE_LICENSE("GPL");
+
+static int debug = 0;
+static int mode = 0;
+static int channel = 0;
+static int associate = 1;
+static int disable = 0;
+#ifdef CONFIG_PM
+static struct ipw2100_fw ipw2100_firmware;
+#endif
+
+#include <linux/moduleparam.h>
+module_param(debug, int, 0444);
+module_param(mode, int, 0444);
+module_param(channel, int, 0444);
+module_param(associate, int, 0444);
+module_param(disable, int, 0444);
+
+MODULE_PARM_DESC(debug, "debug level");
+MODULE_PARM_DESC(mode, "network mode (0=BSS,1=IBSS,2=Monitor)");
+MODULE_PARM_DESC(channel, "channel");
+MODULE_PARM_DESC(associate, "auto associate when scanning (default on)");
+MODULE_PARM_DESC(disable, "manually disable the radio (default 0 [radio on])");
+
+u32 ipw2100_debug_level = IPW_DL_NONE;
+
+#ifdef CONFIG_IPW_DEBUG
+static const char *command_types[] = {
+	"undefined",
+	"unused", /* HOST_ATTENTION */
+	"HOST_COMPLETE",
+	"unused", /* SLEEP */
+	"unused", /* HOST_POWER_DOWN */
+	"unused",
+	"SYSTEM_CONFIG",
+	"unused", /* SET_IMR */
+	"SSID",
+	"MANDATORY_BSSID",
+	"AUTHENTICATION_TYPE",
+	"ADAPTER_ADDRESS",
+	"PORT_TYPE",
+	"INTERNATIONAL_MODE",
+	"CHANNEL",
+	"RTS_THRESHOLD",
+	"FRAG_THRESHOLD",
+	"POWER_MODE",
+	"TX_RATES",
+	"BASIC_TX_RATES",
+	"WEP_KEY_INFO",
+	"unused",
+	"unused",
+	"unused",
+	"unused",
+	"WEP_KEY_INDEX",
+	"WEP_FLAGS",
+	"ADD_MULTICAST",
+	"CLEAR_ALL_MULTICAST",
+	"BEACON_INTERVAL",
+	"ATIM_WINDOW",
+	"CLEAR_STATISTICS",
+	"undefined",
+	"undefined",
+	"undefined",
+	"undefined",
+	"TX_POWER_INDEX",
+	"undefined",
+	"undefined",
+	"undefined",
+	"undefined",
+	"undefined",
+	"undefined",
+	"BROADCAST_SCAN",
+	"CARD_DISABLE",
+	"PREFERRED_BSSID",
+	"SET_SCAN_OPTIONS",
+	"SCAN_DWELL_TIME",
+	"SWEEP_TABLE",
+	"AP_OR_STATION_TABLE",
+	"GROUP_ORDINALS",
+	"SHORT_RETRY_LIMIT",
+	"LONG_RETRY_LIMIT",
+	"unused", /* SAVE_CALIBRATION */
+	"unused", /* RESTORE_CALIBRATION */
+	"undefined",
+	"undefined",
+	"undefined",
+	"HOST_PRE_POWER_DOWN",
+	"unused", /* HOST_INTERRUPT_COALESCING */
+	"undefined",
+	"CARD_DISABLE_PHY_OFF",
+	"MSDU_TX_RATES"
+	"undefined",
+	"undefined",
+	"SET_STATION_STAT_BITS",
+	"CLEAR_STATIONS_STAT_BITS",
+	"LEAP_ROGUE_MODE",
+	"SET_SECURITY_INFORMATION",
+	"DISASSOCIATION_BSSID",
+	"SET_WPA_ASS_IE"
+};
+#endif
+
+
+/* Pre-decl until we get the code solid and then we can clean it up */
+static void X__ipw2100_tx_send_commands(struct ipw2100_priv *priv);
+static void X__ipw2100_tx_send_data(struct ipw2100_priv *priv);
+static int ipw2100_adapter_setup(struct ipw2100_priv *priv);
+
+static void ipw2100_queues_initialize(struct ipw2100_priv *priv);
+static void ipw2100_queues_free(struct ipw2100_priv *priv);
+static int ipw2100_queues_allocate(struct ipw2100_priv *priv);
+
+
+static inline void read_register(struct net_device *dev, u32 reg, u32 *val)
+{
+	*val = readl((void *)(dev->base_addr + reg));
+	IPW_DEBUG_IO("r: 0x%08X => 0x%08X\n", reg, *val);
+}
+
+static inline void write_register(struct net_device *dev, u32 reg, u32 val)
+{
+	writel(val, (void *)(dev->base_addr + reg));
+	IPW_DEBUG_IO("w: 0x%08X <= 0x%08X\n", reg, val);
+}
+
+static inline void read_register_word(struct net_device *dev, u32 reg, u16 *val)
+{
+	*val = readw((void *)(dev->base_addr + reg));
+	IPW_DEBUG_IO("r: 0x%08X => %04X\n", reg, *val);
+}
+
+static inline void read_register_byte(struct net_device *dev, u32 reg, u8 *val)
+{
+	*val = readb((void *)(dev->base_addr + reg));
+	IPW_DEBUG_IO("r: 0x%08X => %02X\n", reg, *val);
+}
+
+static inline void write_register_word(struct net_device *dev, u32 reg, u16 val)
+{
+	writew(val, (void *)(dev->base_addr + reg));
+	IPW_DEBUG_IO("w: 0x%08X <= %04X\n", reg, val);
+}
+
+
+static inline void write_register_byte(struct net_device *dev, u32 reg, u8 val)
+{
+	writeb(val, (void *)(dev->base_addr + reg));
+	IPW_DEBUG_IO("w: 0x%08X =< %02X\n", reg, val);
+}
+
+static inline void read_nic_dword(struct net_device *dev, u32 addr, u32 *val)
+{
+	write_register(dev, IPW_REG_INDIRECT_ACCESS_ADDRESS,
+		       addr & IPW_REG_INDIRECT_ADDR_MASK);
+	read_register(dev, IPW_REG_INDIRECT_ACCESS_DATA, val);
+}
+
+static inline void write_nic_dword(struct net_device *dev, u32 addr, u32 val)
+{
+	write_register(dev, IPW_REG_INDIRECT_ACCESS_ADDRESS,
+		       addr & IPW_REG_INDIRECT_ADDR_MASK);
+	write_register(dev, IPW_REG_INDIRECT_ACCESS_DATA, val);
+}
+
+static inline void read_nic_word(struct net_device *dev, u32 addr, u16 *val)
+{
+	write_register(dev, IPW_REG_INDIRECT_ACCESS_ADDRESS,
+		       addr & IPW_REG_INDIRECT_ADDR_MASK);
+	read_register_word(dev, IPW_REG_INDIRECT_ACCESS_DATA, val);
+}
+
+static inline void write_nic_word(struct net_device *dev, u32 addr, u16 val)
+{
+	write_register(dev, IPW_REG_INDIRECT_ACCESS_ADDRESS,
+		       addr & IPW_REG_INDIRECT_ADDR_MASK);
+	write_register_word(dev, IPW_REG_INDIRECT_ACCESS_DATA, val);
+}
+
+static inline void read_nic_byte(struct net_device *dev, u32 addr, u8 *val)
+{
+	write_register(dev, IPW_REG_INDIRECT_ACCESS_ADDRESS,
+		       addr & IPW_REG_INDIRECT_ADDR_MASK);
+	read_register_byte(dev, IPW_REG_INDIRECT_ACCESS_DATA, val);
+}
+
+static inline void write_nic_byte(struct net_device *dev, u32 addr, u8 val)
+{
+	write_register(dev, IPW_REG_INDIRECT_ACCESS_ADDRESS,
+		       addr & IPW_REG_INDIRECT_ADDR_MASK);
+	write_register_byte(dev, IPW_REG_INDIRECT_ACCESS_DATA, val);
+}
+
+static inline void write_nic_auto_inc_address(struct net_device *dev, u32 addr)
+{
+	write_register(dev, IPW_REG_AUTOINCREMENT_ADDRESS,
+		       addr & IPW_REG_INDIRECT_ADDR_MASK);
+}
+
+static inline void write_nic_dword_auto_inc(struct net_device *dev, u32 val)
+{
+	write_register(dev, IPW_REG_AUTOINCREMENT_DATA, val);
+}
+
+static inline void write_nic_memory(struct net_device *dev, u32 addr, u32 len,
+				    const u8 *buf)
+{
+	u32 aligned_addr;
+	u32 aligned_len;
+	u32 dif_len;
+	u32 i;
+
+	/* read first nibble byte by byte */
+	aligned_addr = addr & (~0x3);
+	dif_len = addr - aligned_addr;
+	if (dif_len) {
+		/* Start reading at aligned_addr + dif_len */
+		write_register(dev, IPW_REG_INDIRECT_ACCESS_ADDRESS,
+			       aligned_addr);
+		for (i = dif_len; i < 4; i++, buf++)
+			write_register_byte(
+				dev, IPW_REG_INDIRECT_ACCESS_DATA + i,
+				*buf);
+
+		len -= dif_len;
+		aligned_addr += 4;
+	}
+
+	/* read DWs through autoincrement registers */
+	write_register(dev, IPW_REG_AUTOINCREMENT_ADDRESS,
+		       aligned_addr);
+	aligned_len = len & (~0x3);
+	for (i = 0; i < aligned_len; i += 4, buf += 4, aligned_addr += 4)
+		write_register(
+			dev, IPW_REG_AUTOINCREMENT_DATA, *(u32 *)buf);
+
+	/* copy the last nibble */
+	dif_len = len - aligned_len;
+	write_register(dev, IPW_REG_INDIRECT_ACCESS_ADDRESS, aligned_addr);
+	for (i = 0; i < dif_len; i++, buf++)
+		write_register_byte(
+			dev, IPW_REG_INDIRECT_ACCESS_DATA + i, *buf);
+}
+
+static inline void read_nic_memory(struct net_device *dev, u32 addr, u32 len,
+				   u8 *buf)
+{
+	u32 aligned_addr;
+	u32 aligned_len;
+	u32 dif_len;
+	u32 i;
+
+	/* read first nibble byte by byte */
+	aligned_addr = addr & (~0x3);
+	dif_len = addr - aligned_addr;
+	if (dif_len) {
+		/* Start reading at aligned_addr + dif_len */
+		write_register(dev, IPW_REG_INDIRECT_ACCESS_ADDRESS,
+			       aligned_addr);
+		for (i = dif_len; i < 4; i++, buf++)
+			read_register_byte(
+				dev, IPW_REG_INDIRECT_ACCESS_DATA + i, buf);
+
+		len -= dif_len;
+		aligned_addr += 4;
+	}
+
+	/* read DWs through autoincrement registers */
+	write_register(dev, IPW_REG_AUTOINCREMENT_ADDRESS,
+		       aligned_addr);
+	aligned_len = len & (~0x3);
+	for (i = 0; i < aligned_len; i += 4, buf += 4, aligned_addr += 4)
+		read_register(dev, IPW_REG_AUTOINCREMENT_DATA,
+			      (u32 *)buf);
+
+	/* copy the last nibble */
+	dif_len = len - aligned_len;
+	write_register(dev, IPW_REG_INDIRECT_ACCESS_ADDRESS,
+		       aligned_addr);
+	for (i = 0; i < dif_len; i++, buf++)
+		read_register_byte(dev, IPW_REG_INDIRECT_ACCESS_DATA +
+				   i, buf);
+}
+
+static inline int ipw2100_hw_is_adapter_in_system(struct net_device *dev)
+{
+	return (dev->base_addr &&
+		(readl((void *)(dev->base_addr + IPW_REG_DOA_DEBUG_AREA_START))
+		 == IPW_DATA_DOA_DEBUG_VALUE));
+}
+
+int ipw2100_get_ordinal(struct ipw2100_priv *priv, u32 ord,
+			void *val, u32 *len)
+{
+	struct ipw2100_ordinals *ordinals = &priv->ordinals;
+	u32 addr;
+	u32 field_info;
+	u16 field_len;
+	u16 field_count;
+	u32 total_length;
+
+	if (ordinals->table1_addr == 0) {
+		IPW_DEBUG_WARNING(DRV_NAME ": attempt to use fw ordinals "
+		       "before they have been loaded.\n");
+		return -EINVAL;
+	}
+
+	if (IS_ORDINAL_TABLE_ONE(ordinals, ord)) {
+		if (*len < IPW_ORD_TAB_1_ENTRY_SIZE) {
+			*len = IPW_ORD_TAB_1_ENTRY_SIZE;
+
+			IPW_DEBUG_WARNING(DRV_NAME
+			       ": ordinal buffer length too small, need %d\n",
+			       IPW_ORD_TAB_1_ENTRY_SIZE);
+
+			return -EINVAL;
+		}
+
+		read_nic_dword(priv->net_dev, ordinals->table1_addr + (ord << 2),
+			       &addr);
+		read_nic_dword(priv->net_dev, addr, val);
+
+		*len = IPW_ORD_TAB_1_ENTRY_SIZE;
+
+		return 0;
+	}
+
+	if (IS_ORDINAL_TABLE_TWO(ordinals, ord)) {
+
+		ord -= IPW_START_ORD_TAB_2;
+
+		/* get the address of statistic */
+		read_nic_dword(priv->net_dev, ordinals->table2_addr + (ord << 3),
+			       &addr);
+
+		/* get the second DW of statistics ;
+		 * two 16-bit words - first is length, second is count */
+		read_nic_dword(priv->net_dev,
+			       ordinals->table2_addr + (ord << 3) + sizeof(u32),
+			       &field_info);
+
+		/* get each entry length */
+		field_len = *((u16 *)&field_info);
+
+		/* get number of entries */
+		field_count = *(((u16 *)&field_info) + 1);
+
+		/* abort if no enought memory */
+		total_length = field_len * field_count;
+		if (total_length > *len) {
+			*len = total_length;
+			return -EINVAL;
+		}
+
+		*len = total_length;
+		if (!total_length)
+			return 0;
+
+		/* read the ordinal data from the SRAM */
+		read_nic_memory(priv->net_dev, addr, total_length, val);
+
+		return 0;
+	}
+
+	IPW_DEBUG_WARNING(DRV_NAME ": ordinal %d neither in table 1 nor "
+	       "in table 2\n", ord);
+
+	return -EINVAL;
+}
+
+static int ipw2100_set_ordinal(struct ipw2100_priv *priv, u32 ord, u32 *val,
+			       u32 *len)
+{
+	struct ipw2100_ordinals *ordinals = &priv->ordinals;
+	u32 addr;
+
+	if (IS_ORDINAL_TABLE_ONE(ordinals, ord)) {
+		if (*len != IPW_ORD_TAB_1_ENTRY_SIZE) {
+			*len = IPW_ORD_TAB_1_ENTRY_SIZE;
+			IPW_DEBUG_INFO("wrong size\n");
+			return -EINVAL;
+		}
+
+		read_nic_dword(priv->net_dev, ordinals->table1_addr + (ord << 2),
+			       &addr);
+
+		write_nic_dword(priv->net_dev, addr, *val);
+
+		*len = IPW_ORD_TAB_1_ENTRY_SIZE;
+
+		return 0;
+	}
+
+	IPW_DEBUG_INFO("wrong table\n");
+	if (IS_ORDINAL_TABLE_TWO(ordinals, ord))
+		return -EINVAL;
+
+	return -EINVAL;
+}
+
+static char *snprint_line(char *buf, size_t count,
+			  const u8 *data, u32 len, u32 ofs)
+{
+	int out, i, j, l;
+	char c;
+
+	out = snprintf(buf, count, "%08X", ofs);
+
+	for (l = 0, i = 0; i < 2; i++) {
+		out += snprintf(buf + out, count - out, " ");
+		for (j = 0; j < 8 && l < len; j++, l++)
+			out += snprintf(buf + out, count - out, "%02X ",
+					data[(i * 8 + j)]);
+		for (; j < 8; j++)
+			out += snprintf(buf + out, count - out, "   ");
+	}
+
+	out += snprintf(buf + out, count - out, " ");
+	for (l = 0, i = 0; i < 2; i++) {
+		out += snprintf(buf + out, count - out, " ");
+		for (j = 0; j < 8 && l < len; j++, l++) {
+			c = data[(i * 8 + j)];
+			if (!isascii(c) || !isprint(c))
+				c = '.';
+
+			out += snprintf(buf + out, count - out, "%c", c);
+		}
+
+		for (; j < 8; j++)
+			out += snprintf(buf + out, count - out, " ");
+	}
+
+	return buf;
+}
+
+static void printk_buf(int level, const u8 *data, u32 len)
+{
+	char line[81];
+	u32 ofs = 0;
+	if (!(ipw2100_debug_level & level))
+		return;
+
+	while (len) {
+		printk(KERN_DEBUG "%s\n",
+		       snprint_line(line, sizeof(line), &data[ofs],
+				    min(len, 16U), ofs));
+		ofs += 16;
+		len -= min(len, 16U);
+	}
+}
+
+
+
+#define MAX_RESET_BACKOFF 10
+
+static inline void schedule_reset(struct ipw2100_priv *priv)
+{
+	unsigned long now = get_seconds();
+
+	/* If we haven't received a reset request within the backoff period,
+	 * then we can reset the backoff interval so this reset occurs
+	 * immediately */
+	if (priv->reset_backoff &&
+	    (now - priv->last_reset > priv->reset_backoff))
+		priv->reset_backoff = 0;
+
+	priv->last_reset = get_seconds();
+
+	if (!(priv->status & STATUS_RESET_PENDING)) {
+		IPW_DEBUG_INFO("%s: Scheduling firmware restart (%ds).\n",
+			       priv->net_dev->name, priv->reset_backoff);
+		netif_carrier_off(priv->net_dev);
+		netif_stop_queue(priv->net_dev);
+		priv->status |= STATUS_RESET_PENDING;
+		if (priv->reset_backoff)
+			queue_delayed_work(priv->workqueue, &priv->reset_work,
+					   priv->reset_backoff * HZ);
+		else
+			queue_work(priv->workqueue, &priv->reset_work);
+
+		if (priv->reset_backoff < MAX_RESET_BACKOFF)
+			priv->reset_backoff++;
+
+		wake_up_interruptible(&priv->wait_command_queue);
+	} else
+		IPW_DEBUG_INFO("%s: Firmware restart already in progress.\n",
+			       priv->net_dev->name);
+
+}
+
+#define HOST_COMPLETE_TIMEOUT (2 * HZ)
+static int ipw2100_hw_send_command(struct ipw2100_priv *priv,
+				   struct host_command * cmd)
+{
+	struct list_head *element;
+	struct ipw2100_tx_packet *packet;
+	unsigned long flags;
+	int err = 0;
+
+	IPW_DEBUG_HC("Sending %s command (#%d), %d bytes\n",
+		     command_types[cmd->host_command], cmd->host_command,
+		     cmd->host_command_length);
+	printk_buf(IPW_DL_HC, (u8*)cmd->host_command_parameters,
+		   cmd->host_command_length);
+
+	spin_lock_irqsave(&priv->low_lock, flags);
+
+	if (priv->fatal_error) {
+		IPW_DEBUG_INFO("Attempt to send command while hardware in fatal error condition.\n");
+		err = -EIO;
+		goto fail_unlock;
+	}
+
+	if (!(priv->status & STATUS_RUNNING)) {
+		IPW_DEBUG_INFO("Attempt to send command while hardware is not running.\n");
+		err = -EIO;
+		goto fail_unlock;
+	}
+
+	if (priv->status & STATUS_CMD_ACTIVE) {
+		IPW_DEBUG_INFO("Attempt to send command while another command is pending.\n");
+		err = -EBUSY;
+		goto fail_unlock;
+	}
+
+	if (list_empty(&priv->msg_free_list)) {
+		IPW_DEBUG_INFO("no available msg buffers\n");
+		goto fail_unlock;
+	}
+
+	priv->status |= STATUS_CMD_ACTIVE;
+	priv->messages_sent++;
+
+	element = priv->msg_free_list.next;
+
+	packet = list_entry(element, struct ipw2100_tx_packet, list);
+	packet->jiffy_start = jiffies;
+
+	/* initialize the firmware command packet */
+	packet->info.c_struct.cmd->host_command_reg = cmd->host_command;
+	packet->info.c_struct.cmd->host_command_reg1 = cmd->host_command1;
+	packet->info.c_struct.cmd->host_command_len_reg = cmd->host_command_length;
+	packet->info.c_struct.cmd->sequence = cmd->host_command_sequence;
+
+	memcpy(packet->info.c_struct.cmd->host_command_params_reg,
+	       cmd->host_command_parameters,
+	       sizeof(packet->info.c_struct.cmd->host_command_params_reg));
+
+	list_del(element);
+	DEC_STAT(&priv->msg_free_stat);
+
+	list_add_tail(element, &priv->msg_pend_list);
+	INC_STAT(&priv->msg_pend_stat);
+
+	X__ipw2100_tx_send_commands(priv);
+	X__ipw2100_tx_send_data(priv);
+
+	spin_unlock_irqrestore(&priv->low_lock, flags);
+
+	/*
+	 * We must wait for this command to complete before another
+	 * command can be sent...  but if we wait more than 3 seconds
+	 * then there is a problem.
+	 */
+
+	err = wait_event_interruptible_timeout(
+		priv->wait_command_queue, !(priv->status & STATUS_CMD_ACTIVE),
+		HOST_COMPLETE_TIMEOUT);
+
+	if (err == 0) {
+		IPW_DEBUG_INFO("Command completion failed out after %dms.\n",
+			       HOST_COMPLETE_TIMEOUT / (HZ / 100));
+		priv->fatal_error = IPW2100_ERR_MSG_TIMEOUT;
+		priv->status &= ~STATUS_CMD_ACTIVE;
+		schedule_reset(priv);
+		return -EIO;
+	}
+
+	if (priv->fatal_error) {
+		IPW_DEBUG_WARNING("%s: firmware fatal error\n",
+		       priv->net_dev->name);
+		return -EIO;
+	}
+
+	/* !!!!! HACK TEST !!!!!
+	 * When lots of debug trace statements are enabled, the driver
+	 * doesn't seem to have as many firmware restart cycles...
+	 *
+	 * As a test, we're sticking in a 1/100s delay here */
+	set_current_state(TASK_UNINTERRUPTIBLE);
+	schedule_timeout(HZ / 100);
+
+	return 0;
+
+ fail_unlock:
+	spin_unlock_irqrestore(&priv->low_lock, flags);
+
+	return err;
+}
+
+
+/*
+ * Verify the values and data access of the hardware
+ * No locks needed or used.  No functions called.
+ */
+static int ipw2100_verify(struct ipw2100_priv *priv)
+{
+	u32 data1, data2;
+	u32 address;
+
+	u32 val1 = 0x76543210;
+	u32 val2 = 0xFEDCBA98;
+
+	/* Domain 0 check - all values should be DOA_DEBUG */
+	for (address = IPW_REG_DOA_DEBUG_AREA_START;
+	     address < IPW_REG_DOA_DEBUG_AREA_END;
+	     address += sizeof(u32)) {
+		read_register(priv->net_dev, address, &data1);
+		if (data1 != IPW_DATA_DOA_DEBUG_VALUE)
+			return -EIO;
+	}
+
+	/* Domain 1 check - use arbitrary read/write compare  */
+	for (address = 0; address < 5; address++) {
+		/* The memory area is not used now */
+		write_register(priv->net_dev, IPW_REG_DOMAIN_1_OFFSET + 0x32,
+			       val1);
+		write_register(priv->net_dev, IPW_REG_DOMAIN_1_OFFSET + 0x36,
+			       val2);
+		read_register(priv->net_dev, IPW_REG_DOMAIN_1_OFFSET + 0x32,
+			      &data1);
+		read_register(priv->net_dev, IPW_REG_DOMAIN_1_OFFSET + 0x36,
+			      &data2);
+		if (val1 == data1 && val2 == data2)
+			return 0;
+	}
+
+	return -EIO;
+}
+
+/*
+ *
+ * Loop until the CARD_DISABLED bit is the same value as the
+ * supplied parameter
+ *
+ * TODO: See if it would be more efficient to do a wait/wake
+ *       cycle and have the completion event trigger the wakeup
+ *
+ */
+#define IPW_CARD_DISABLE_COMPLETE_WAIT		    100	// 100 milli
+static int ipw2100_wait_for_card_state(struct ipw2100_priv *priv, int state)
+{
+	int i;
+	u32 card_state;
+	u32 len = sizeof(card_state);
+	int err;
+
+	for (i = 0; i <= IPW_CARD_DISABLE_COMPLETE_WAIT * 1000; i += 50) {
+		err = ipw2100_get_ordinal(priv, IPW_ORD_CARD_DISABLED,
+					  &card_state, &len);
+		if (err) {
+			IPW_DEBUG_INFO("Query of CARD_DISABLED ordinal "
+				       "failed.\n");
+			return 0;
+		}
+
+		/* We'll break out if either the HW state says it is
+		 * in the state we want, or if HOST_COMPLETE command
+		 * finishes */
+		if ((card_state == state) ||
+		    ((priv->status & STATUS_ENABLED) ?
+		     IPW_HW_STATE_ENABLED : IPW_HW_STATE_DISABLED) == state) {
+			if (state == IPW_HW_STATE_ENABLED)
+				priv->status |= STATUS_ENABLED;
+			else
+				priv->status &= ~STATUS_ENABLED;
+
+			return 0;
+		}
+
+		udelay(50);
+	}
+
+	IPW_DEBUG_INFO("ipw2100_wait_for_card_state to %s state timed out\n",
+		       state ? "DISABLED" : "ENABLED");
+	return -EIO;
+}
+
+
+/*********************************************************************
+    Procedure   :   sw_reset_and_clock
+    Purpose     :   Asserts s/w reset, asserts clock initialization
+                    and waits for clock stabilization
+ ********************************************************************/
+static int sw_reset_and_clock(struct ipw2100_priv *priv)
+{
+	int i;
+	u32 r;
+
+	// assert s/w reset
+	write_register(priv->net_dev, IPW_REG_RESET_REG,
+		       IPW_AUX_HOST_RESET_REG_SW_RESET);
+
+	// wait for clock stabilization
+	for (i = 0; i < 1000; i++) {
+		udelay(IPW_WAIT_RESET_ARC_COMPLETE_DELAY);
+
+		// check clock ready bit
+		read_register(priv->net_dev, IPW_REG_RESET_REG, &r);
+		if (r & IPW_AUX_HOST_RESET_REG_PRINCETON_RESET)
+			break;
+	}
+
+	if (i == 1000)
+		return -EIO;	// TODO: better error value
+
+	/* set "initialization complete" bit to move adapter to
+	 * D0 state */
+	write_register(priv->net_dev, IPW_REG_GP_CNTRL,
+		       IPW_AUX_HOST_GP_CNTRL_BIT_INIT_DONE);
+
+	/* wait for clock stabilization */
+	for (i = 0; i < 10000; i++) {
+		udelay(IPW_WAIT_CLOCK_STABILIZATION_DELAY * 4);
+
+		/* check clock ready bit */
+		read_register(priv->net_dev, IPW_REG_GP_CNTRL, &r);
+		if (r & IPW_AUX_HOST_GP_CNTRL_BIT_CLOCK_READY)
+			break;
+	}
+
+	if (i == 10000)
+		return -EIO;	/* TODO: better error value */
+
+//#if CONFIG_IPW2100_D0ENABLED
+	/* set D0 standby bit */
+	read_register(priv->net_dev, IPW_REG_GP_CNTRL, &r);
+	write_register(priv->net_dev, IPW_REG_GP_CNTRL,
+		       r | IPW_AUX_HOST_GP_CNTRL_BIT_HOST_ALLOWS_STANDBY);
+//#endif
+
+	return 0;
+}
+
+/*********************************************************************
+    Procedure   :   ipw2100_ipw2100_download_firmware
+    Purpose     :   Initiaze adapter after power on.
+                    The sequence is:
+                    1. assert s/w reset first!
+                    2. awake clocks & wait for clock stabilization
+                    3. hold ARC (don't ask me why...)
+                    4. load Dino ucode and reset/clock init again
+                    5. zero-out shared mem
+                    6. download f/w
+ *******************************************************************/
+static int ipw2100_download_firmware(struct ipw2100_priv *priv)
+{
+	u32 address;
+	int err;
+
+#ifndef CONFIG_PM
+	/* Fetch the firmware and microcode */
+	struct ipw2100_fw ipw2100_firmware;
+#endif
+
+	if (priv->fatal_error) {
+		IPW_DEBUG_ERROR("%s: ipw2100_download_firmware called after "
+		       "fatal error %d.  Interface must be brought down.\n",
+		       priv->net_dev->name, priv->fatal_error);
+		return -EINVAL;
+	}
+
+#ifdef CONFIG_PM
+	if (!ipw2100_firmware.version) {
+		err = ipw2100_get_firmware(priv, &ipw2100_firmware);
+		if (err) {
+			IPW_DEBUG_ERROR("%s: ipw2100_get_firmware failed: %d\n",
+			       priv->net_dev->name, err);
+			priv->fatal_error = IPW2100_ERR_FW_LOAD;
+			goto fail;
+		}
+	}
+#else
+	err = ipw2100_get_firmware(priv, &ipw2100_firmware);
+	if (err) {
+		IPW_DEBUG_ERROR("%s: ipw2100_get_firmware failed: %d\n",
+		       priv->net_dev->name, err);
+		priv->fatal_error = IPW2100_ERR_FW_LOAD;
+		goto fail;
+	}
+#endif
+	priv->firmware_version = ipw2100_firmware.version;
+
+	/* s/w reset and clock stabilization */
+	err = sw_reset_and_clock(priv);
+	if (err) {
+		IPW_DEBUG_ERROR("%s: sw_reset_and_clock failed: %d\n",
+		       priv->net_dev->name, err);
+		goto fail;
+	}
+
+	err = ipw2100_verify(priv);
+	if (err) {
+		IPW_DEBUG_ERROR("%s: ipw2100_verify failed: %d\n",
+		       priv->net_dev->name, err);
+		goto fail;
+	}
+
+	/* Hold ARC */
+	write_nic_dword(priv->net_dev,
+			IPW_INTERNAL_REGISTER_HALT_AND_RESET,
+			0x80000000);
+
+	/* allow ARC to run */
+	write_register(priv->net_dev, IPW_REG_RESET_REG, 0);
+
+	/* load microcode */
+	err = ipw2100_ucode_download(priv, &ipw2100_firmware);
+	if (err) {
+		IPW_DEBUG_ERROR("%s: Error loading microcode: %d\n",
+		       priv->net_dev->name, err);
+		goto fail;
+	}
+
+	/* release ARC */
+	write_nic_dword(priv->net_dev,
+			IPW_INTERNAL_REGISTER_HALT_AND_RESET,
+			0x00000000);
+
+	/* s/w reset and clock stabilization (again!!!) */
+	err = sw_reset_and_clock(priv);
+	if (err) {
+		IPW_DEBUG_ERROR("%s: sw_reset_and_clock failed: %d\n",
+		       priv->net_dev->name, err);
+		goto fail;
+	}
+
+	/* load f/w */
+	err = ipw2100_fw_download(priv, &ipw2100_firmware);
+	if (err) {
+		IPW_DEBUG_ERROR("%s: Error loading firmware: %d\n",
+		       priv->net_dev->name, err);
+		goto fail;
+	}
+
+#ifndef CONFIG_PM
+	/*
+	 * When the .resume method of the driver is called, the other
+	 * part of the system, i.e. the ide driver could still stay in
+	 * the suspend stage. This prevents us from loading the firmware
+	 * from the disk.  --YZ
+	 */
+
+	/* free any storage allocated for firmware image */
+	ipw2100_release_firmware(priv, &ipw2100_firmware);
+#endif
+
+	/* zero out Domain 1 area indirectly (Si requirement) */
+	for (address = IPW_HOST_FW_SHARED_AREA0;
+	     address < IPW_HOST_FW_SHARED_AREA0_END; address += 4)
+		write_nic_dword(priv->net_dev, address, 0);
+	for (address = IPW_HOST_FW_SHARED_AREA1;
+	     address < IPW_HOST_FW_SHARED_AREA1_END; address += 4)
+		write_nic_dword(priv->net_dev, address, 0);
+	for (address = IPW_HOST_FW_SHARED_AREA2;
+	     address < IPW_HOST_FW_SHARED_AREA2_END; address += 4)
+		write_nic_dword(priv->net_dev, address, 0);
+	for (address = IPW_HOST_FW_SHARED_AREA3;
+	     address < IPW_HOST_FW_SHARED_AREA3_END; address += 4)
+		write_nic_dword(priv->net_dev, address, 0);
+	for (address = IPW_HOST_FW_INTERRUPT_AREA;
+	     address < IPW_HOST_FW_INTERRUPT_AREA_END; address += 4)
+		write_nic_dword(priv->net_dev, address, 0);
+
+	return 0;
+
+ fail:
+	ipw2100_release_firmware(priv, &ipw2100_firmware);
+	return err;
+}
+
+static inline void ipw2100_enable_interrupts(struct ipw2100_priv *priv)
+{
+	if (priv->status & STATUS_INT_ENABLED)
+		return;
+	priv->status |= STATUS_INT_ENABLED;
+	write_register(priv->net_dev, IPW_REG_INTA_MASK, IPW_INTERRUPT_MASK);
+}
+
+static inline void ipw2100_disable_interrupts(struct ipw2100_priv *priv)
+{
+	if (!(priv->status & STATUS_INT_ENABLED))
+		return;
+	priv->status &= ~STATUS_INT_ENABLED;
+	write_register(priv->net_dev, IPW_REG_INTA_MASK, 0x0);
+}
+
+
+static void ipw2100_initialize_ordinals(struct ipw2100_priv *priv)
+{
+	struct ipw2100_ordinals *ord = &priv->ordinals;
+
+	IPW_DEBUG_INFO("enter\n");
+
+	read_register(priv->net_dev, IPW_MEM_HOST_SHARED_ORDINALS_TABLE_1,
+		      &ord->table1_addr);
+
+	read_register(priv->net_dev, IPW_MEM_HOST_SHARED_ORDINALS_TABLE_2,
+		      &ord->table2_addr);
+
+	read_nic_dword(priv->net_dev, ord->table1_addr, &ord->table1_size);
+	read_nic_dword(priv->net_dev, ord->table2_addr, &ord->table2_size);
+
+	ord->table2_size &= 0x0000FFFF;
+
+	IPW_DEBUG_INFO("table 1 size: %d\n", ord->table1_size);
+	IPW_DEBUG_INFO("table 2 size: %d\n", ord->table2_size);
+	IPW_DEBUG_INFO("exit\n");
+}
+
+static inline void ipw2100_hw_set_gpio(struct ipw2100_priv *priv)
+{
+	u32 reg = 0;
+	/*
+	 * Set GPIO 3 writable by FW; GPIO 1 writable
+	 * by driver and enable clock
+	 */
+	reg = (IPW_BIT_GPIO_GPIO3_MASK | IPW_BIT_GPIO_GPIO1_ENABLE |
+	       IPW_BIT_GPIO_LED_OFF);
+	write_register(priv->net_dev, IPW_REG_GPIO, reg);
+}
+
+static inline int rf_kill_active(struct ipw2100_priv *priv)
+{
+#define MAX_RF_KILL_CHECKS 5
+#define RF_KILL_CHECK_DELAY 40
+#define RF_KILL_CHECK_THRESHOLD 3
+
+	unsigned short value = 0;
+	u32 reg = 0;
+	int i;
+
+	if (!(priv->hw_features & HW_FEATURE_RFKILL)) {
+		priv->status &= ~STATUS_RF_KILL_HW;
+		return 0;
+	}
+
+	for (i = 0; i < MAX_RF_KILL_CHECKS; i++) {
+		udelay(RF_KILL_CHECK_DELAY);
+		read_register(priv->net_dev, IPW_REG_GPIO, &reg);
+		value = (value << 1) | ((reg & IPW_BIT_GPIO_RF_KILL) ? 0 : 1);
+	}
+
+	if (value == 0)
+		priv->status |= STATUS_RF_KILL_HW;
+	else
+		priv->status &= ~STATUS_RF_KILL_HW;
+
+	return (value == 0);
+}
+
+static int ipw2100_get_hw_features(struct ipw2100_priv *priv)
+{
+	u32 addr, len;
+	u32 val;
+
+	/*
+	 * EEPROM_SRAM_DB_START_ADDRESS using ordinal in ordinal table 1
+	 */
+	len = sizeof(addr);
+	if (ipw2100_get_ordinal(
+		    priv, IPW_ORD_EEPROM_SRAM_DB_BLOCK_START_ADDRESS,
+		    &addr, &len)) {
+		IPW_DEBUG_INFO("failed querying ordinals at line %d\n",
+		       __LINE__);
+		return -EIO;
+	}
+
+	IPW_DEBUG_INFO("EEPROM address: %08X\n", addr);
+
+	/*
+	 * EEPROM version is the byte at offset 0xfd in firmware
+	 * We read 4 bytes, then shift out the byte we actually want */
+	read_nic_dword(priv->net_dev, addr + 0xFC, &val);
+	priv->eeprom_version = (val >> 24) & 0xFF;
+	IPW_DEBUG_INFO("EEPROM version: %d\n", priv->eeprom_version);
+
+        /*
+	 *  HW RF Kill enable is bit 0 in byte at offset 0x21 in firmware
+	 *
+	 *  notice that the EEPROM bit is reverse polarity, i.e.
+	 *     bit = 0  signifies HW RF kill switch is supported
+	 *     bit = 1  signifies HW RF kill switch is NOT supported
+	 */
+	read_nic_dword(priv->net_dev, addr + 0x20, &val);
+	if (!((val >> 24) & 0x01))
+		priv->hw_features |= HW_FEATURE_RFKILL;
+
+	IPW_DEBUG_INFO("HW RF Kill: %ssupported.\n",
+			   (priv->hw_features & HW_FEATURE_RFKILL) ?
+			   "" : "not ");
+
+	return 0;
+}
+
+/*
+ * Start firmware execution after power on and intialization
+ * The sequence is:
+ *  1. Release ARC
+ *  2. Wait for f/w initialization completes;
+ */
+static int ipw2100_start_adapter(struct ipw2100_priv *priv)
+{
+#define IPW_WAIT_FW_INIT_COMPLETE_DELAY (40 * HZ / 1000)
+	int i;
+	u32 inta, inta_mask, gpio;
+
+	IPW_DEBUG_INFO("enter\n");
+
+	if (priv->status & STATUS_RUNNING)
+		return 0;
+
+	/*
+	 * Initialize the hw - drive adapter to DO state by setting
+	 * init_done bit. Wait for clk_ready bit and Download
+	 * fw & dino ucode
+	 */
+	if (ipw2100_download_firmware(priv)) {
+		IPW_DEBUG_ERROR("%s: Failed to power on the adapter.\n",
+		       priv->net_dev->name);
+		return -EIO;
+	}
+
+	/* Clear the Tx, Rx and Msg queues and the r/w indexes
+	 * in the firmware RBD and TBD ring queue */
+	ipw2100_queues_initialize(priv);
+
+	ipw2100_hw_set_gpio(priv);
+
+	/* TODO -- Look at disabling interrupts here to make sure none
+	 * get fired during FW initialization */
+
+	/* Release ARC - clear reset bit */
+	write_register(priv->net_dev, IPW_REG_RESET_REG, 0);
+
+	/* wait for f/w intialization complete */
+	IPW_DEBUG_FW("Waiting for f/w initialization to complete...\n");
+	i = 5000;
+	do {
+  		set_current_state(TASK_UNINTERRUPTIBLE);
+		schedule_timeout(IPW_WAIT_FW_INIT_COMPLETE_DELAY);
+		/* Todo... wait for sync command ... */
+
+		read_register(priv->net_dev, IPW_REG_INTA, &inta);
+
+		/* check "init done" bit */
+		if (inta & IPW2100_INTA_FW_INIT_DONE) {
+			/* reset "init done" bit */
+			write_register(priv->net_dev, IPW_REG_INTA,
+				       IPW2100_INTA_FW_INIT_DONE);
+			break;
+		}
+
+		/* check error conditions : we check these after the firmware
+		 * check so that if there is an error, the interrupt handler
+		 * will see it and the adapter will be reset */
+		if (inta &
+		    (IPW2100_INTA_FATAL_ERROR | IPW2100_INTA_PARITY_ERROR)) {
+			/* clear error conditions */
+			write_register(priv->net_dev, IPW_REG_INTA,
+				       IPW2100_INTA_FATAL_ERROR |
+				       IPW2100_INTA_PARITY_ERROR);
+		}
+	} while (i--);
+
+	/* Clear out any pending INTAs since we aren't supposed to have
+	 * interrupts enabled at this point... */
+	read_register(priv->net_dev, IPW_REG_INTA, &inta);
+	read_register(priv->net_dev, IPW_REG_INTA_MASK, &inta_mask);
+	inta &= IPW_INTERRUPT_MASK;
+	/* Clear out any pending interrupts */
+	if (inta & inta_mask)
+		write_register(priv->net_dev, IPW_REG_INTA, inta);
+
+	IPW_DEBUG_FW("f/w initialization complete: %s\n",
+		     i ? "SUCCESS" : "FAILED");
+
+	if (!i) {
+		IPW_DEBUG_WARNING("%s: Firmware did not initialize.\n",
+		       priv->net_dev->name);
+		return -EIO;
+	}
+
+	/* allow firmware to write to GPIO1 & GPIO3 */
+	read_register(priv->net_dev, IPW_REG_GPIO, &gpio);
+
+	gpio |= (IPW_BIT_GPIO_GPIO1_MASK | IPW_BIT_GPIO_GPIO3_MASK);
+
+	write_register(priv->net_dev, IPW_REG_GPIO, gpio);
+
+	/* Ready to receive commands */
+	priv->status |= STATUS_RUNNING;
+
+	/* The adapter has been reset; we are not associated */
+	priv->status &= ~(STATUS_ASSOCIATING | STATUS_ASSOCIATED);
+
+	IPW_DEBUG_INFO("exit\n");
+
+	return 0;
+}
+
+static inline void ipw2100_reset_fatalerror(struct ipw2100_priv *priv)
+{
+	if (!priv->fatal_error)
+		return;
+
+	priv->fatal_errors[priv->fatal_index++] = priv->fatal_error;
+	priv->fatal_index %= IPW2100_ERROR_QUEUE;
+	priv->fatal_error = 0;
+}
+
+
+/* NOTE: Our interrupt is disabled when this method is called */
+static int ipw2100_power_cycle_adapter(struct ipw2100_priv *priv)
+{
+	u32 reg;
+	int i;
+
+	IPW_DEBUG_INFO("Power cycling the hardware.\n");
+
+	ipw2100_hw_set_gpio(priv);
+
+	/* Step 1. Stop Master Assert */
+	write_register(priv->net_dev, IPW_REG_RESET_REG,
+		       IPW_AUX_HOST_RESET_REG_STOP_MASTER);
+
+	/* Step 2. Wait for stop Master Assert
+	 *         (not more then 50us, otherwise ret error */
+	i = 5;
+	do {
+		udelay(IPW_WAIT_RESET_MASTER_ASSERT_COMPLETE_DELAY);
+		read_register(priv->net_dev, IPW_REG_RESET_REG, &reg);
+
+		if (reg & IPW_AUX_HOST_RESET_REG_MASTER_DISABLED)
+			break;
+	}  while(i--);
+
+	priv->status &= ~STATUS_RESET_PENDING;
+
+	if (!i) {
+		IPW_DEBUG_INFO("exit - waited too long for master assert stop\n");
+		return -EIO;
+	}
+
+	write_register(priv->net_dev, IPW_REG_RESET_REG,
+		       IPW_AUX_HOST_RESET_REG_SW_RESET);
+
+
+	/* Reset any fatal_error conditions */
+	ipw2100_reset_fatalerror(priv);
+
+	/* At this point, the adapter is now stopped and disabled */
+	priv->status &= ~(STATUS_RUNNING | STATUS_ASSOCIATING |
+			  STATUS_ASSOCIATED | STATUS_ENABLED);
+
+	return 0;
+}
+
+/*
+ * Send the CARD_DISABLE_PHY_OFF comamnd to the card to disable it
+ *
+ * After disabling, if the card was associated, a STATUS_ASSN_LOST will be sent.
+ *
+ * STATUS_CARD_DISABLE_NOTIFICATION will be sent regardless of
+ * if STATUS_ASSN_LOST is sent.
+ */
+static int ipw2100_hw_phy_off(struct ipw2100_priv *priv)
+{
+
+#define HW_PHY_OFF_LOOP_DELAY (HZ / 5000)
+
+	struct host_command cmd = {
+		.host_command = CARD_DISABLE_PHY_OFF,
+		.host_command_sequence = 0,
+		.host_command_length = 0,
+	};
+	int err, i;
+	u32 val1, val2;
+
+	IPW_DEBUG_HC("CARD_DISABLE_PHY_OFF\n");
+
+	/* Turn off the radio */
+	err = ipw2100_hw_send_command(priv, &cmd);
+	if (err)
+		return err;
+
+	for (i = 0; i < 2500; i++) {
+		read_nic_dword(priv->net_dev, IPW2100_CONTROL_REG, &val1);
+		read_nic_dword(priv->net_dev, IPW2100_COMMAND, &val2);
+
+		if ((val1 & IPW2100_CONTROL_PHY_OFF) &&
+		    (val2 & IPW2100_COMMAND_PHY_OFF))
+			return 0;
+
+		set_current_state(TASK_UNINTERRUPTIBLE);
+		schedule_timeout(HW_PHY_OFF_LOOP_DELAY);
+	}
+
+	return -EIO;
+}
+
+
+static int ipw2100_enable_adapter(struct ipw2100_priv *priv)
+{
+	struct host_command cmd = {
+		.host_command = HOST_COMPLETE,
+		.host_command_sequence = 0,
+		.host_command_length = 0
+	};
+	int err = 0;
+
+	IPW_DEBUG_HC("HOST_COMPLETE\n");
+
+	if (priv->status & STATUS_ENABLED)
+		return 0;
+
+	down(&priv->adapter_sem);
+
+	if (rf_kill_active(priv)) {
+		IPW_DEBUG_HC("Command aborted due to RF kill active.\n");
+		goto fail_up;
+	}
+
+	err = ipw2100_hw_send_command(priv, &cmd);
+	if (err) {
+		IPW_DEBUG_INFO("Failed to send HOST_COMPLETE command\n");
+		goto fail_up;
+	}
+
+	err = ipw2100_wait_for_card_state(priv, IPW_HW_STATE_ENABLED);
+	if (err) {
+		IPW_DEBUG_INFO(
+		       "%s: card not responding to init command.\n",
+		       priv->net_dev->name);
+		goto fail_up;
+	}
+
+	if (priv->stop_hang_check) {
+		priv->stop_hang_check = 0;
+		queue_delayed_work(priv->workqueue, &priv->hang_check, HZ / 2);
+	}
+
+fail_up:
+	up(&priv->adapter_sem);
+	return err;
+}
+
+static int ipw2100_hw_stop_adapter(struct ipw2100_priv *priv)
+{
+#define HW_POWER_DOWN_DELAY (HZ / 10)
+
+	struct host_command cmd = {
+		.host_command = HOST_PRE_POWER_DOWN,
+		.host_command_sequence = 0,
+		.host_command_length = 0,
+	};
+	int err, i;
+	u32 reg;
+
+	if (!(priv->status & STATUS_RUNNING))
+		return 0;
+
+	priv->status |= STATUS_STOPPING;
+
+	/* We can only shut down the card if the firmware is operational.  So,
+	 * if we haven't reset since a fatal_error, then we can not send the
+	 * shutdown commands. */
+	if (!priv->fatal_error) {
+		/* First, make sure the adapter is enabled so that the PHY_OFF
+		 * command can shut it down */
+		ipw2100_enable_adapter(priv);
+
+		err = ipw2100_hw_phy_off(priv);
+		if (err)
+			IPW_DEBUG_WARNING("Error disabling radio %d\n", err);
+
+		/*
+		 * If in D0-standby mode going directly to D3 may cause a
+		 * PCI bus violation.  Therefore we must change out of the D0
+		 * state.
+		 *
+		 * Sending the PREPARE_FOR_POWER_DOWN will restrict the
+		 * hardware from going into standby mode and will transition
+		 * out of D0-standy if it is already in that state.
+		 *
+		 * STATUS_PREPARE_POWER_DOWN_COMPLETE will be sent by the
+		 * driver upon completion.  Once received, the driver can
+		 * proceed to the D3 state.
+		 *
+		 * Prepare for power down command to fw.  This command would
+		 * take HW out of D0-standby and prepare it for D3 state.
+		 *
+		 * Currently FW does not support event notification for this
+		 * event. Therefore, skip waiting for it.  Just wait a fixed
+		 * 100ms
+		 */
+		IPW_DEBUG_HC("HOST_PRE_POWER_DOWN\n");
+
+		err = ipw2100_hw_send_command(priv, &cmd);
+		if (err)
+			IPW_DEBUG_WARNING(
+			       "%s: Power down command failed: Error %d\n",
+			       priv->net_dev->name, err);
+		else {
+			set_current_state(TASK_UNINTERRUPTIBLE);
+			schedule_timeout(HW_POWER_DOWN_DELAY);
+		}
+	}
+
+	priv->status &= ~STATUS_ENABLED;
+
+	/*
+	 * Set GPIO 3 writable by FW; GPIO 1 writable
+	 * by driver and enable clock
+	 */
+	ipw2100_hw_set_gpio(priv);
+
+	/*
+	 * Power down adapter.  Sequence:
+	 * 1. Stop master assert (RESET_REG[9]=1)
+	 * 2. Wait for stop master (RESET_REG[8]==1)
+	 * 3. S/w reset assert (RESET_REG[7] = 1)
+	 */
+
+	/* Stop master assert */
+	write_register(priv->net_dev, IPW_REG_RESET_REG,
+		       IPW_AUX_HOST_RESET_REG_STOP_MASTER);
+
+	/* wait stop master not more than 50 usec.
+	 * Otherwise return error. */
+	for (i = 5; i > 0; i--) {
+		udelay(10);
+
+		/* Check master stop bit */
+		read_register(priv->net_dev, IPW_REG_RESET_REG, &reg);
+
+		if (reg & IPW_AUX_HOST_RESET_REG_MASTER_DISABLED)
+			break;
+	}
+
+	if (i == 0)
+		IPW_DEBUG_WARNING(DRV_NAME
+		       ": %s: Could now power down adapter.\n",
+		       priv->net_dev->name);
+
+	/* assert s/w reset */
+	write_register(priv->net_dev, IPW_REG_RESET_REG,
+		       IPW_AUX_HOST_RESET_REG_SW_RESET);
+
+	priv->status &= ~(STATUS_RUNNING | STATUS_STOPPING);
+
+	return 0;
+}
+
+
+static int ipw2100_disable_adapter(struct ipw2100_priv *priv)
+{
+	struct host_command cmd = {
+		.host_command = CARD_DISABLE,
+		.host_command_sequence = 0,
+		.host_command_length = 0
+	};
+	int err = 0;
+
+	IPW_DEBUG_HC("CARD_DISABLE\n");
+
+	if (!(priv->status & STATUS_ENABLED))
+		return 0;
+
+	/* Make sure we clear the associated state */
+	priv->status &= ~(STATUS_ASSOCIATED | STATUS_ASSOCIATING);
+
+	if (!priv->stop_hang_check) {
+		priv->stop_hang_check = 1;
+		cancel_delayed_work(&priv->hang_check);
+	}
+
+	down(&priv->adapter_sem);
+
+	err = ipw2100_hw_send_command(priv, &cmd);
+	if (err) {
+		IPW_DEBUG_WARNING("exit - failed to send CARD_DISABLE command\n");
+		goto fail_up;
+	}
+
+	err = ipw2100_wait_for_card_state(priv, IPW_HW_STATE_DISABLED);
+	if (err) {
+		IPW_DEBUG_WARNING("exit - card failed to change to DISABLED\n");
+		goto fail_up;
+	}
+
+	IPW_DEBUG_INFO("TODO: implement scan state machine\n");
+
+fail_up:
+	up(&priv->adapter_sem);
+	return err;
+}
+
+int ipw2100_set_scan_options(struct ipw2100_priv *priv)
+{
+	struct host_command cmd = {
+		.host_command = SET_SCAN_OPTIONS,
+		.host_command_sequence = 0,
+		.host_command_length = 8
+	};
+	int err;
+
+	IPW_DEBUG_INFO("enter\n");
+
+	IPW_DEBUG_SCAN("setting scan options\n");
+
+	cmd.host_command_parameters[0] = 0;
+
+	if (!(priv->config & CFG_ASSOCIATE))
+		cmd.host_command_parameters[0] |= IPW_SCAN_NOASSOCIATE;
+	if ((priv->sec.flags & SEC_ENABLED) && priv->sec.enabled)
+		cmd.host_command_parameters[0] |= IPW_SCAN_MIXED_CELL;
+	if (priv->config & CFG_PASSIVE_SCAN)
+		cmd.host_command_parameters[0] |= IPW_SCAN_PASSIVE;
+
+	cmd.host_command_parameters[1] = priv->channel_mask;
+
+	err = ipw2100_hw_send_command(priv, &cmd);
+
+	IPW_DEBUG_HC("SET_SCAN_OPTIONS 0x%04X\n",
+		     cmd.host_command_parameters[0]);
+
+	return err;
+}
+
+int ipw2100_start_scan(struct ipw2100_priv *priv)
+{
+	struct host_command cmd = {
+		.host_command = BROADCAST_SCAN,
+		.host_command_sequence = 0,
+		.host_command_length = 4
+	};
+	int err;
+
+	IPW_DEBUG_HC("START_SCAN\n");
+
+	cmd.host_command_parameters[0] = 0;
+
+	/* No scanning if in monitor mode */
+	if (priv->ieee->iw_mode == IW_MODE_MONITOR)
+		return 1;
+
+	if (priv->status & STATUS_SCANNING) {
+		IPW_DEBUG_SCAN("Scan requested while already in scan...\n");
+		return 0;
+	}
+
+	IPW_DEBUG_INFO("enter\n");
+
+	/* Not clearing here; doing so makes iwlist always return nothing...
+	 *
+	 * We should modify the table logic to use aging tables vs. clearing
+	 * the table on each scan start.
+	 */
+	IPW_DEBUG_SCAN("starting scan\n");
+
+	priv->status |= STATUS_SCANNING;
+	err = ipw2100_hw_send_command(priv, &cmd);
+	if (err)
+		priv->status &= ~STATUS_SCANNING;
+
+	IPW_DEBUG_INFO("exit\n");
+
+	return err;
+}
+
+static int ipw2100_up(struct ipw2100_priv *priv, int deferred)
+{
+	unsigned long flags;
+	int rc = 0;
+	u32 lock;
+	u32 ord_len = sizeof(lock);
+
+	/* Quite if manually disabled. */
+	if (priv->status & STATUS_RF_KILL_SW) {
+		IPW_DEBUG_INFO("%s: Radio is disabled by Manual Disable "
+			       "switch\n", priv->net_dev->name);
+		return 0;
+	}
+
+	/* If the interrupt is enabled, turn it off... */
+	spin_lock_irqsave(&priv->low_lock, flags);
+	ipw2100_disable_interrupts(priv);
+
+	/* Reset any fatal_error conditions */
+	ipw2100_reset_fatalerror(priv);
+	spin_unlock_irqrestore(&priv->low_lock, flags);
+
+	if (priv->status & STATUS_POWERED ||
+	    (priv->status & STATUS_RESET_PENDING)) {
+		/* Power cycle the card ... */
+		if (ipw2100_power_cycle_adapter(priv)) {
+			IPW_DEBUG_WARNING("%s: Could not cycle adapter.\n",
+					  priv->net_dev->name);
+			rc = 1;
+			goto exit;
+		}
+	} else
+		priv->status |= STATUS_POWERED;
+
+	/* Load the firmeware, start the clocks, etc. */
+	if (ipw2100_start_adapter(priv)) {
+	       	IPW_DEBUG_ERROR("%s: Failed to start the firmware.\n",
+				priv->net_dev->name);
+		rc = 1;
+		goto exit;
+	}
+
+	ipw2100_initialize_ordinals(priv);
+
+	/* Determine capabilities of this particular HW configuration */
+	if (ipw2100_get_hw_features(priv)) {
+		IPW_DEBUG_ERROR("%s: Failed to determine HW features.\n",
+				priv->net_dev->name);
+		rc = 1;
+		goto exit;
+	}
+
+	lock = LOCK_NONE;
+	if (ipw2100_set_ordinal(priv, IPW_ORD_PERS_DB_LOCK, &lock, &ord_len)) {
+		IPW_DEBUG_ERROR("%s: Failed to clear ordinal lock.\n",
+				priv->net_dev->name);
+		rc = 1;
+		goto exit;
+	}
+
+	priv->status &= ~STATUS_SCANNING;
+
+	if (rf_kill_active(priv)) {
+		printk(KERN_INFO "%s: Radio is disabled by RF switch.\n",
+		       priv->net_dev->name);
+
+		if (priv->stop_rf_kill) {
+			priv->stop_rf_kill = 0;
+			queue_delayed_work(priv->workqueue, &priv->rf_kill, HZ);
+		}
+
+		deferred = 1;
+	}
+
+	/* Turn on the interrupt so that commands can be processed */
+	ipw2100_enable_interrupts(priv);
+
+	/* Send all of the commands that must be sent prior to
+	 * HOST_COMPLETE */
+	if (ipw2100_adapter_setup(priv)) {
+		IPW_DEBUG_ERROR("%s: Failed to start the card.\n",
+				priv->net_dev->name);
+		rc = 1;
+		goto exit;
+	}
+
+	if (!deferred) {
+		/* Enable the adapter - sends HOST_COMPLETE */
+		if (ipw2100_enable_adapter(priv)) {
+			IPW_DEBUG_ERROR(
+				"%s: failed in call to enable adapter.\n",
+				priv->net_dev->name);
+			ipw2100_hw_stop_adapter(priv);
+			rc = 1;
+			goto exit;
+		}
+
+
+		/* Start a scan . . . */
+		ipw2100_set_scan_options(priv);
+		ipw2100_start_scan(priv);
+	}
+
+ exit:
+	return rc;
+}
+
+/* Called by register_netdev() */
+static int ipw2100_net_init(struct net_device *dev)
+{
+	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	return ipw2100_up(priv, 1);
+}
+
+static void ipw2100_down(struct ipw2100_priv *priv)
+{
+	unsigned long flags;
+	union iwreq_data wrqu = {
+		.ap_addr = {
+			.sa_family = ARPHRD_ETHER
+		}
+	};
+	int associated = priv->status & STATUS_ASSOCIATED;
+
+	/* Kill the RF switch timer */
+	if (!priv->stop_rf_kill) {
+		priv->stop_rf_kill = 1;
+		cancel_delayed_work(&priv->rf_kill);
+	}
+
+	/* Kill the firmare hang check timer */
+	if (!priv->stop_hang_check) {
+		priv->stop_hang_check = 1;
+		cancel_delayed_work(&priv->hang_check);
+	}
+
+	/* Kill any pending resets */
+	if (priv->status & STATUS_RESET_PENDING)
+		cancel_delayed_work(&priv->reset_work);
+
+	/* Make sure the interrupt is on so that FW commands will be
+	 * processed correctly */
+	spin_lock_irqsave(&priv->low_lock, flags);
+	ipw2100_enable_interrupts(priv);
+	spin_unlock_irqrestore(&priv->low_lock, flags);
+
+	if (ipw2100_hw_stop_adapter(priv))
+		IPW_DEBUG_ERROR("%s: Error stopping adapter.\n",
+		       priv->net_dev->name);
+
+	/* Do not disable the interrupt until _after_ we disable
+	 * the adaptor.  Otherwise the CARD_DISABLE command will never
+	 * be ack'd by the firmware */
+	spin_lock_irqsave(&priv->low_lock, flags);
+	ipw2100_disable_interrupts(priv);
+	spin_unlock_irqrestore(&priv->low_lock, flags);
+
+#ifdef ACPI_CSTATE_LIMIT_DEFINED
+	if (priv->config & CFG_C3_DISABLED) {
+		IPW_DEBUG_INFO(DRV_NAME ": Resetting C3 transitions.\n");
+		acpi_set_cstate_limit(priv->cstate_limit);
+		priv->config &= ~CFG_C3_DISABLED;
+	}
+#endif
+
+	/* We have to signal any supplicant if we are disassociating */
+	if (associated)
+		wireless_send_event(priv->net_dev, SIOCGIWAP, &wrqu, NULL);
+
+	priv->status &= ~(STATUS_ASSOCIATED | STATUS_ASSOCIATING);
+	netif_carrier_off(priv->net_dev);
+	netif_stop_queue(priv->net_dev);
+}
+
+void ipw2100_reset_adapter(struct ipw2100_priv *priv)
+{
+	unsigned long flags;
+	union iwreq_data wrqu = {
+		.ap_addr = {
+			.sa_family = ARPHRD_ETHER
+		}
+	};
+	int associated = priv->status & STATUS_ASSOCIATED;
+
+	spin_lock_irqsave(&priv->low_lock, flags);
+	IPW_DEBUG_INFO(DRV_NAME ": %s: Restarting adapter.\n",
+		       priv->net_dev->name);
+	priv->resets++;
+	priv->status &= ~(STATUS_ASSOCIATED | STATUS_ASSOCIATING);
+	priv->status |= STATUS_SECURITY_UPDATED;
+
+	/* Force a power cycle even if interface hasn't been opened
+	 * yet */
+	cancel_delayed_work(&priv->reset_work);
+	priv->status |= STATUS_RESET_PENDING;
+	spin_unlock_irqrestore(&priv->low_lock, flags);
+
+	down(&priv->action_sem);
+	/* stop timed checks so that they don't interfere with reset */
+	priv->stop_hang_check = 1;
+	cancel_delayed_work(&priv->hang_check);
+
+	/* We have to signal any supplicant if we are disassociating */
+	if (associated)
+		wireless_send_event(priv->net_dev, SIOCGIWAP, &wrqu, NULL);
+
+	ipw2100_up(priv, 0);
+	up(&priv->action_sem);
+
+}
+
+
+static void isr_indicate_associated(struct ipw2100_priv *priv, u32 status)
+{
+
+#define MAC_ASSOCIATION_READ_DELAY (HZ)
+	int ret, len, essid_len;
+	char essid[IW_ESSID_MAX_SIZE];
+	u32 txrate;
+	u32 chan;
+	char *txratename;
+ 	u8 bssid[ETH_ALEN];
+
+	/*
+	 * TBD: BSSID is usually 00:00:00:00:00:00 here and not
+	 *      an actual MAC of the AP. Seems like FW sets this
+	 *      address too late. Read it later and expose through
+	 *      /proc or schedule a later task to query and update
+	 */
+
+	essid_len = IW_ESSID_MAX_SIZE;
+	ret = ipw2100_get_ordinal(priv, IPW_ORD_STAT_ASSN_SSID,
+				  essid, &essid_len);
+	if (ret) {
+		IPW_DEBUG_INFO("failed querying ordinals at line %d\n",
+				   __LINE__);
+		return;
+	}
+
+	len = sizeof(u32);
+	ret = ipw2100_get_ordinal(priv, IPW_ORD_CURRENT_TX_RATE,
+				  &txrate, &len);
+	if (ret) {
+		IPW_DEBUG_INFO("failed querying ordinals at line %d\n",
+				   __LINE__);
+		return;
+	}
+
+	len = sizeof(u32);
+	ret = ipw2100_get_ordinal(priv, IPW_ORD_OUR_FREQ, &chan, &len);
+	if (ret) {
+		IPW_DEBUG_INFO("failed querying ordinals at line %d\n",
+				   __LINE__);
+		return;
+	}
+	len = ETH_ALEN;
+        ipw2100_get_ordinal(priv, IPW_ORD_STAT_ASSN_AP_BSSID, &bssid,  &len);
+	if (ret) {
+		IPW_DEBUG_INFO("failed querying ordinals at line %d\n",
+				   __LINE__);
+		return;
+	}
+	memcpy(priv->ieee->bssid, bssid, ETH_ALEN);
+
+
+	switch (txrate) {
+	case TX_RATE_1_MBIT:
+		txratename = "1Mbps";
+		break;
+	case TX_RATE_2_MBIT:
+		txratename = "2Mbsp";
+		break;
+	case TX_RATE_5_5_MBIT:
+		txratename = "5.5Mbps";
+		break;
+	case TX_RATE_11_MBIT:
+		txratename = "11Mbps";
+		break;
+	default:
+		IPW_DEBUG_INFO("Unknown rate: %d\n", txrate);
+		txratename = "unknown rate";
+		break;
+	}
+
+	IPW_DEBUG_INFO("%s: Associated with '%s' at %s, channel %d (BSSID="
+		       MAC_FMT ")\n",
+		       priv->net_dev->name, escape_essid(essid, essid_len),
+		       txratename, chan, MAC_ARG(bssid));
+
+	/* now we copy read ssid into dev */
+	if (!(priv->config & CFG_STATIC_ESSID)) {
+		priv->essid_len = min((u8)essid_len, (u8)IW_ESSID_MAX_SIZE);
+		memcpy(priv->essid, essid, priv->essid_len);
+	}
+	priv->channel = chan;
+	memcpy(priv->bssid, bssid, ETH_ALEN);
+
+	priv->status |= STATUS_ASSOCIATING;
+	priv->connect_start = get_seconds();
+
+	queue_delayed_work(priv->workqueue, &priv->wx_event_work, HZ / 10);
+}
+
+
+int ipw2100_set_essid(struct ipw2100_priv *priv, char *essid,
+		      int length, int batch_mode)
+{
+	int ssid_len = min(length, IW_ESSID_MAX_SIZE);
+	struct host_command cmd = {
+		.host_command = SSID,
+		.host_command_sequence = 0,
+		.host_command_length = ssid_len
+	};
+	int err;
+
+	IPW_DEBUG_HC("SSID: '%s'\n", escape_essid(essid, ssid_len));
+
+	if (ssid_len)
+		memcpy((char*)cmd.host_command_parameters,
+		       essid, ssid_len);
+
+	if (!batch_mode) {
+		err = ipw2100_disable_adapter(priv);
+		if (err)
+			return err;
+	}
+
+	/* Bug in FW currently doesn't honor bit 0 in SET_SCAN_OPTIONS to
+	 * disable auto association -- so we cheat by setting a bogus SSID */
+	if (!ssid_len && !(priv->config & CFG_ASSOCIATE)) {
+		int i;
+		u8 *bogus = (u8*)cmd.host_command_parameters;
+		for (i = 0; i < IW_ESSID_MAX_SIZE; i++)
+			bogus[i] = 0x18 + i;
+		cmd.host_command_length = IW_ESSID_MAX_SIZE;
+	}
+
+	/* NOTE:  We always send the SSID command even if the provided ESSID is
+	 * the same as what we currently think is set. */
+
+	err = ipw2100_hw_send_command(priv, &cmd);
+	if (!err) {
+		memset(priv->essid + ssid_len, 0,
+		       IW_ESSID_MAX_SIZE - ssid_len);
+		memcpy(priv->essid, essid, ssid_len);
+		priv->essid_len = ssid_len;
+	}
+
+	if (!batch_mode) {
+		if (ipw2100_enable_adapter(priv))
+			err = -EIO;
+	}
+
+	return err;
+}
+
+static void isr_indicate_association_lost(struct ipw2100_priv *priv, u32 status)
+{
+	IPW_DEBUG(IPW_DL_NOTIF | IPW_DL_STATE | IPW_DL_ASSOC,
+		  "disassociated: '%s' " MAC_FMT " \n",
+		  escape_essid(priv->essid, priv->essid_len),
+		  MAC_ARG(priv->bssid));
+
+	priv->status &= ~(STATUS_ASSOCIATED | STATUS_ASSOCIATING);
+
+	if (priv->status & STATUS_STOPPING) {
+		IPW_DEBUG_INFO("Card is stopping itself, discard ASSN_LOST.\n");
+		return;
+	}
+
+	memset(priv->bssid, 0, ETH_ALEN);
+	memset(priv->ieee->bssid, 0, ETH_ALEN);
+
+	netif_carrier_off(priv->net_dev);
+	netif_stop_queue(priv->net_dev);
+
+	if (!(priv->status & STATUS_RUNNING))
+		return;
+
+	if (priv->status & STATUS_SECURITY_UPDATED)
+		queue_work(priv->workqueue, &priv->security_work);
+
+	queue_work(priv->workqueue, &priv->wx_event_work);
+}
+
+static void isr_indicate_rf_kill(struct ipw2100_priv *priv, u32 status)
+{
+	IPW_DEBUG_INFO("%s: RF Kill state changed to radio OFF.\n",
+	       priv->net_dev->name);
+
+	/* RF_KILL is now enabled (else we wouldn't be here) */
+	priv->status |= STATUS_RF_KILL_HW;
+
+#ifdef ACPI_CSTATE_LIMIT_DEFINED
+	if (priv->config & CFG_C3_DISABLED) {
+		IPW_DEBUG_INFO(DRV_NAME ": Resetting C3 transitions.\n");
+		acpi_set_cstate_limit(priv->cstate_limit);
+		priv->config &= ~CFG_C3_DISABLED;
+	}
+#endif
+
+	/* Make sure the RF Kill check timer is running */
+	priv->stop_rf_kill = 0;
+	cancel_delayed_work(&priv->rf_kill);
+	queue_delayed_work(priv->workqueue, &priv->rf_kill, HZ);
+}
+
+static void isr_scan_complete(struct ipw2100_priv *priv, u32 status)
+{
+	IPW_DEBUG_SCAN("scan complete\n");
+	/* Age the scan results... */
+	priv->ieee->scans++;
+	priv->status &= ~STATUS_SCANNING;
+}
+
+#ifdef CONFIG_IPW_DEBUG
+#define IPW2100_HANDLER(v, f) { v, f, # v }
+struct ipw2100_status_indicator {
+	int status;
+	void (*cb)(struct ipw2100_priv *priv, u32 status);
+	char *name;
+};
+#else
+#define IPW2100_HANDLER(v, f) { v, f }
+struct ipw2100_status_indicator {
+	int status;
+	void (*cb)(struct ipw2100_priv *priv, u32 status);
+};
+#endif /* CONFIG_IPW_DEBUG */
+
+static void isr_indicate_scanning(struct ipw2100_priv *priv, u32 status)
+{
+	IPW_DEBUG_SCAN("Scanning...\n");
+	priv->status |= STATUS_SCANNING;
+}
+
+const struct ipw2100_status_indicator status_handlers[] = {
+	IPW2100_HANDLER(IPW_STATE_INITIALIZED, 0),
+	IPW2100_HANDLER(IPW_STATE_COUNTRY_FOUND, 0),
+	IPW2100_HANDLER(IPW_STATE_ASSOCIATED, isr_indicate_associated),
+	IPW2100_HANDLER(IPW_STATE_ASSN_LOST, isr_indicate_association_lost),
+	IPW2100_HANDLER(IPW_STATE_ASSN_CHANGED, 0),
+	IPW2100_HANDLER(IPW_STATE_SCAN_COMPLETE, isr_scan_complete),
+	IPW2100_HANDLER(IPW_STATE_ENTERED_PSP, 0),
+	IPW2100_HANDLER(IPW_STATE_LEFT_PSP, 0),
+	IPW2100_HANDLER(IPW_STATE_RF_KILL, isr_indicate_rf_kill),
+	IPW2100_HANDLER(IPW_STATE_DISABLED, 0),
+	IPW2100_HANDLER(IPW_STATE_POWER_DOWN, 0),
+	IPW2100_HANDLER(IPW_STATE_SCANNING, isr_indicate_scanning),
+	IPW2100_HANDLER(-1, 0)
+};
+
+
+static void isr_status_change(struct ipw2100_priv *priv, int status)
+{
+	int i;
+
+	if (status == IPW_STATE_SCANNING &&
+	    priv->status & STATUS_ASSOCIATED &&
+	    !(priv->status & STATUS_SCANNING)) {
+		IPW_DEBUG_INFO("Scan detected while associated, with "
+			       "no scan request.  Restarting firmware.\n");
+
+		/* Wake up any sleeping jobs */
+		schedule_reset(priv);
+	}
+
+	for (i = 0; status_handlers[i].status != -1; i++) {
+		if (status == status_handlers[i].status) {
+			IPW_DEBUG_NOTIF("Status change: %s\n",
+					 status_handlers[i].name);
+			if (status_handlers[i].cb)
+				status_handlers[i].cb(priv, status);
+			priv->wstats.status = status;
+			return;
+		}
+	}
+
+	IPW_DEBUG_NOTIF("unknown status received: %04x\n", status);
+}
+
+static void isr_rx_complete_command(
+	struct ipw2100_priv *priv,
+	struct ipw2100_cmd_header *cmd)
+{
+#ifdef CONFIG_IPW_DEBUG
+	if (cmd->host_command_reg < ARRAY_SIZE(command_types)) {
+		IPW_DEBUG_HC("Command completed '%s (%d)'\n",
+			     command_types[cmd->host_command_reg],
+			     cmd->host_command_reg);
+	}
+#endif
+	if (cmd->host_command_reg == HOST_COMPLETE)
+		priv->status |= STATUS_ENABLED;
+
+	if (cmd->host_command_reg == CARD_DISABLE)
+		priv->status &= ~STATUS_ENABLED;
+
+	priv->status &= ~STATUS_CMD_ACTIVE;
+
+	wake_up_interruptible(&priv->wait_command_queue);
+}
+
+#ifdef CONFIG_IPW_DEBUG
+const char *frame_types[] = {
+	"COMMAND_STATUS_VAL",
+	"STATUS_CHANGE_VAL",
+	"P80211_DATA_VAL",
+	"P8023_DATA_VAL",
+	"HOST_NOTIFICATION_VAL"
+};
+#endif
+
+
+static inline int ipw2100_alloc_skb(
+	struct ipw2100_priv *priv,
+	struct ipw2100_rx_packet *packet)
+{
+	packet->skb = dev_alloc_skb(sizeof(struct ipw2100_rx));
+	if (!packet->skb)
+		return -ENOMEM;
+
+	packet->rxp = (struct ipw2100_rx *)packet->skb->data;
+	packet->dma_addr = pci_map_single(priv->pci_dev, packet->skb->data,
+					  sizeof(struct ipw2100_rx),
+					  PCI_DMA_FROMDEVICE);
+	/* NOTE: pci_map_single does not return an error code, and 0 is a valid
+	 *       dma_addr */
+
+	return 0;
+}
+
+
+#define SEARCH_ERROR   0xffffffff
+#define SEARCH_FAIL    0xfffffffe
+#define SEARCH_SUCCESS 0xfffffff0
+#define SEARCH_DISCARD 0
+#define SEARCH_SNAPSHOT 1
+
+#define SNAPSHOT_ADDR(ofs) (priv->snapshot[((ofs) >> 12) & 0xff] + ((ofs) & 0xfff))
+static inline int ipw2100_snapshot_alloc(struct ipw2100_priv *priv)
+{
+	int i;
+	if (priv->snapshot[0])
+		return 1;
+	for (i = 0; i < 0x30; i++) {
+		priv->snapshot[i] = (u8*)kmalloc(0x1000, GFP_ATOMIC);
+		if (!priv->snapshot[i]) {
+			IPW_DEBUG_INFO("%s: Error allocating snapshot "
+			       "buffer %d\n", priv->net_dev->name, i);
+			while (i > 0)
+				kfree(priv->snapshot[--i]);
+			priv->snapshot[0] = NULL;
+			return 0;
+		}
+	}
+
+	return 1;
+}
+
+static inline void ipw2100_snapshot_free(struct ipw2100_priv *priv)
+{
+	int i;
+	if (!priv->snapshot[0])
+		return;
+	for (i = 0; i < 0x30; i++)
+		kfree(priv->snapshot[i]);
+	priv->snapshot[0] = NULL;
+}
+
+static inline u32 ipw2100_match_buf(struct ipw2100_priv *priv, u8 *in_buf,
+				    size_t len, int mode)
+{
+	u32 i, j;
+	u32 tmp;
+	u8 *s, *d;
+	u32 ret;
+
+	s = in_buf;
+	if (mode == SEARCH_SNAPSHOT) {
+		if (!ipw2100_snapshot_alloc(priv))
+			mode = SEARCH_DISCARD;
+	}
+
+	for (ret = SEARCH_FAIL, i = 0; i < 0x30000; i += 4) {
+		read_nic_dword(priv->net_dev, i, &tmp);
+		if (mode == SEARCH_SNAPSHOT)
+			*(u32 *)SNAPSHOT_ADDR(i) = tmp;
+		if (ret == SEARCH_FAIL) {
+			d = (u8*)&tmp;
+			for (j = 0; j < 4; j++) {
+				if (*s != *d) {
+					s = in_buf;
+					continue;
+				}
+
+				s++;
+				d++;
+
+				if ((s - in_buf) == len)
+					ret = (i + j) - len + 1;
+			}
+		} else if (mode == SEARCH_DISCARD)
+			return ret;
+	}
+
+	return ret;
+}
+
+/*
+ *
+ * 0) Disconnect the SKB from the firmware (just unmap)
+ * 1) Pack the ETH header into the SKB
+ * 2) Pass the SKB to the network stack
+ *
+ * When packet is provided by the firmware, it contains the following:
+ *
+ * .  ieee80211_hdr
+ * .  ieee80211_snap_hdr
+ *
+ * The size of the constructed ethernet
+ *
+ */
+#ifdef CONFIG_IPW2100_RX_DEBUG
+u8 packet_data[IPW_RX_NIC_BUFFER_LENGTH];
+#endif
+
+static inline void ipw2100_corruption_detected(struct ipw2100_priv *priv,
+					       int i)
+{
+#ifdef CONFIG_IPW_DEBUG_C3
+	struct ipw2100_status *status = &priv->status_queue.drv[i];
+	u32 match, reg;
+	int j;
+#endif
+#ifdef ACPI_CSTATE_LIMIT_DEFINED
+	int limit;
+#endif
+
+	IPW_DEBUG_INFO(DRV_NAME ": PCI latency error detected at "
+		       "0x%04X.\n", i * sizeof(struct ipw2100_status));
+
+#ifdef ACPI_CSTATE_LIMIT_DEFINED
+	IPW_DEBUG_INFO(DRV_NAME ": Disabling C3 transitions.\n");
+	limit = acpi_get_cstate_limit();
+	if (limit > 2) {
+		priv->cstate_limit = limit;
+		acpi_set_cstate_limit(2);
+		priv->config |= CFG_C3_DISABLED;
+	}
+#endif
+
+#ifdef CONFIG_IPW_DEBUG_C3
+	/* Halt the fimrware so we can get a good image */
+	write_register(priv->net_dev, IPW_REG_RESET_REG,
+		       IPW_AUX_HOST_RESET_REG_STOP_MASTER);
+	j = 5;
+	do {
+		udelay(IPW_WAIT_RESET_MASTER_ASSERT_COMPLETE_DELAY);
+		read_register(priv->net_dev, IPW_REG_RESET_REG, &reg);
+
+		if (reg & IPW_AUX_HOST_RESET_REG_MASTER_DISABLED)
+			break;
+	}  while (j--);
+
+	match = ipw2100_match_buf(priv, (u8*)status,
+				  sizeof(struct ipw2100_status),
+				  SEARCH_SNAPSHOT);
+	if (match < SEARCH_SUCCESS)
+		IPW_DEBUG_INFO("%s: DMA status match in Firmware at "
+			       "offset 0x%06X, length %d:\n",
+			       priv->net_dev->name, match,
+			       sizeof(struct ipw2100_status));
+	else
+		IPW_DEBUG_INFO("%s: No DMA status match in "
+			       "Firmware.\n", priv->net_dev->name);
+
+	printk_buf((u8*)priv->status_queue.drv,
+		   sizeof(struct ipw2100_status) * RX_QUEUE_LENGTH);
+#endif
+
+	priv->fatal_error = IPW2100_ERR_C3_CORRUPTION;
+	priv->ieee->stats.rx_errors++;
+	schedule_reset(priv);
+}
+
+static inline void isr_rx(struct ipw2100_priv *priv, int i,
+			  struct ieee80211_rx_stats *stats)
+{
+	struct ipw2100_status *status = &priv->status_queue.drv[i];
+	struct ipw2100_rx_packet *packet = &priv->rx_buffers[i];
+
+	IPW_DEBUG_RX("Handler...\n");
+
+	if (unlikely(status->frame_size > skb_tailroom(packet->skb))) {
+		IPW_DEBUG_INFO("%s: frame_size (%u) > skb_tailroom (%u)!"
+			       "  Dropping.\n",
+			       priv->net_dev->name,
+			       status->frame_size, skb_tailroom(packet->skb));
+		priv->ieee->stats.rx_errors++;
+		return;
+	}
+
+	if (unlikely(!netif_running(priv->net_dev))) {
+		priv->ieee->stats.rx_errors++;
+		priv->wstats.discard.misc++;
+		IPW_DEBUG_DROP("Dropping packet while interface is not up.\n");
+		return;
+	}
+
+	if (unlikely(priv->ieee->iw_mode == IW_MODE_MONITOR &&
+		     status->flags & IPW_STATUS_FLAG_CRC_ERROR)) {
+		IPW_DEBUG_RX("CRC error in packet.  Dropping.\n");
+		priv->ieee->stats.rx_errors++;
+		return;
+	}
+
+	if (unlikely(priv->ieee->iw_mode != IW_MODE_MONITOR &&
+		!(priv->status & STATUS_ASSOCIATED))) {
+		IPW_DEBUG_DROP("Dropping packet while not associated.\n");
+		priv->wstats.discard.misc++;
+		return;
+	}
+
+
+	pci_unmap_single(priv->pci_dev,
+			 packet->dma_addr,
+			 sizeof(struct ipw2100_rx),
+			 PCI_DMA_FROMDEVICE);
+
+	skb_put(packet->skb, status->frame_size);
+
+#ifdef CONFIG_IPW2100_RX_DEBUG
+	/* Make a copy of the frame so we can dump it to the logs if
+	 * ieee80211_rx fails */
+	memcpy(packet_data, packet->skb->data,
+	       min(status->frame_size, IPW_RX_NIC_BUFFER_LENGTH));
+#endif
+
+	if (!ieee80211_rx(priv->ieee, packet->skb, stats)) {
+#ifdef CONFIG_IPW2100_RX_DEBUG
+		IPW_DEBUG_DROP("%s: Non consumed packet:\n",
+			       priv->net_dev->name);
+		printk_buf(IPW_DL_DROP, packet_data, status->frame_size);
+#endif
+		priv->ieee->stats.rx_errors++;
+
+		/* ieee80211_rx failed, so it didn't free the SKB */
+		dev_kfree_skb_any(packet->skb);
+		packet->skb = NULL;
+	}
+
+	/* We need to allocate a new SKB and attach it to the RDB. */
+	if (unlikely(ipw2100_alloc_skb(priv, packet))) {
+		IPW_DEBUG_WARNING(
+			"%s: Unable to allocate SKB onto RBD ring - disabling "
+			"adapter.\n", priv->net_dev->name);
+		/* TODO: schedule adapter shutdown */
+		IPW_DEBUG_INFO("TODO: Shutdown adapter...\n");
+	}
+
+	/* Update the RDB entry */
+	priv->rx_queue.drv[i].host_addr = packet->dma_addr;
+}
+
+static inline int ipw2100_corruption_check(struct ipw2100_priv *priv, int i)
+{
+	struct ipw2100_status *status = &priv->status_queue.drv[i];
+	struct ipw2100_rx *u = priv->rx_buffers[i].rxp;
+	u16 frame_type = status->status_fields & STATUS_TYPE_MASK;
+
+	switch (frame_type) {
+	case COMMAND_STATUS_VAL:
+		return (status->frame_size != sizeof(u->rx_data.command));
+	case STATUS_CHANGE_VAL:
+		return (status->frame_size != sizeof(u->rx_data.status));
+	case HOST_NOTIFICATION_VAL:
+		return (status->frame_size < sizeof(u->rx_data.notification));
+	case P80211_DATA_VAL:
+	case P8023_DATA_VAL:
+#ifdef CONFIG_IPW2100_MONITOR
+		return 0;
+#else
+		switch (WLAN_FC_GET_TYPE(u->rx_data.header.frame_ctl)) {
+		case IEEE80211_FTYPE_MGMT:
+		case IEEE80211_FTYPE_CTL:
+			return 0;
+		case IEEE80211_FTYPE_DATA:
+			return (status->frame_size >
+				IPW_MAX_802_11_PAYLOAD_LENGTH);
+		}
+#endif
+	}
+
+	return 1;
+}
+
+/*
+ * ipw2100 interrupts are disabled at this point, and the ISR
+ * is the only code that calls this method.  So, we do not need
+ * to play with any locks.
+ *
+ * RX Queue works as follows:
+ *
+ * Read index - firmware places packet in entry identified by the
+ *              Read index and advances Read index.  In this manner,
+ *              Read index will always point to the next packet to
+ *              be filled--but not yet valid.
+ *
+ * Write index - driver fills this entry with an unused RBD entry.
+ *               This entry has not filled by the firmware yet.
+ *
+ * In between the W and R indexes are the RBDs that have been received
+ * but not yet processed.
+ *
+ * The process of handling packets will start at WRITE + 1 and advance
+ * until it reaches the READ index.
+ *
+ * The WRITE index is cached in the variable 'priv->rx_queue.next'.
+ *
+ */
+static inline void __ipw2100_rx_process(struct ipw2100_priv *priv)
+{
+	struct ipw2100_bd_queue *rxq = &priv->rx_queue;
+	struct ipw2100_status_queue *sq = &priv->status_queue;
+	struct ipw2100_rx_packet *packet;
+	u16 frame_type;
+	u32 r, w, i, s;
+	struct ipw2100_rx *u;
+	struct ieee80211_rx_stats stats = {
+		.mac_time = jiffies,
+	};
+
+	read_register(priv->net_dev, IPW_MEM_HOST_SHARED_RX_READ_INDEX, &r);
+	read_register(priv->net_dev, IPW_MEM_HOST_SHARED_RX_WRITE_INDEX, &w);
+
+	if (r >= rxq->entries) {
+		IPW_DEBUG_RX("exit - bad read index\n");
+		return;
+	}
+
+	i = (rxq->next + 1) % rxq->entries;
+	s = i;
+	while (i != r) {
+		/* IPW_DEBUG_RX("r = %d : w = %d : processing = %d\n",
+		   r, rxq->next, i); */
+
+		packet = &priv->rx_buffers[i];
+
+		/* Sync the DMA for the STATUS buffer so CPU is sure to get
+		 * the correct values */
+		pci_dma_sync_single_for_cpu(
+			priv->pci_dev,
+			sq->nic + sizeof(struct ipw2100_status) * i,
+			sizeof(struct ipw2100_status),
+			PCI_DMA_FROMDEVICE);
+
+		/* Sync the DMA for the RX buffer so CPU is sure to get
+		 * the correct values */
+		pci_dma_sync_single_for_cpu(priv->pci_dev, packet->dma_addr,
+					    sizeof(struct ipw2100_rx),
+					    PCI_DMA_FROMDEVICE);
+
+		if (unlikely(ipw2100_corruption_check(priv, i))) {
+			ipw2100_corruption_detected(priv, i);
+			goto increment;
+		}
+
+		u = packet->rxp;
+		frame_type = sq->drv[i].status_fields &
+			STATUS_TYPE_MASK;
+		stats.rssi = sq->drv[i].rssi + IPW2100_RSSI_TO_DBM;
+		stats.len = sq->drv[i].frame_size;
+
+		stats.mask = 0;
+		if (stats.rssi != 0)
+			stats.mask |= IEEE80211_STATMASK_RSSI;
+		stats.freq = IEEE80211_24GHZ_BAND;
+
+		IPW_DEBUG_RX(
+			"%s: '%s' frame type received (%d).\n",
+			priv->net_dev->name, frame_types[frame_type],
+			stats.len);
+
+		switch (frame_type) {
+		case COMMAND_STATUS_VAL:
+			/* Reset Rx watchdog */
+			isr_rx_complete_command(
+				priv, &u->rx_data.command);
+			break;
+
+		case STATUS_CHANGE_VAL:
+			isr_status_change(priv, u->rx_data.status);
+			break;
+
+		case P80211_DATA_VAL:
+		case P8023_DATA_VAL:
+#ifdef CONFIG_IPW2100_MONITOR
+			if (priv->ieee->iw_mode == IW_MODE_MONITOR) {
+				isr_rx(priv, i, &stats);
+				break;
+			}
+#endif
+			if (stats.len < sizeof(u->rx_data.header))
+				break;
+			switch (WLAN_FC_GET_TYPE(u->rx_data.header.
+						 frame_ctl)) {
+			case IEEE80211_FTYPE_MGMT:
+				ieee80211_rx_mgt(priv->ieee,
+						 &u->rx_data.header,
+						 &stats);
+				break;
+
+			case IEEE80211_FTYPE_CTL:
+				break;
+
+			case IEEE80211_FTYPE_DATA:
+				isr_rx(priv, i, &stats);
+				break;
+
+			}
+			break;
+		}
+
+	increment:
+		/* clear status field associated with this RBD */
+		rxq->drv[i].status.info.field = 0;
+
+		i = (i + 1) % rxq->entries;
+	}
+
+	if (i != s) {
+		/* backtrack one entry, wrapping to end if at 0 */
+		rxq->next = (i ? i : rxq->entries) - 1;
+
+		write_register(priv->net_dev,
+			       IPW_MEM_HOST_SHARED_RX_WRITE_INDEX,
+			       rxq->next);
+	}
+}
+
+
+/*
+ * __ipw2100_tx_process
+ *
+ * This routine will determine whether the next packet on
+ * the fw_pend_list has been processed by the firmware yet.
+ *
+ * If not, then it does nothing and returns.
+ *
+ * If so, then it removes the item from the fw_pend_list, frees
+ * any associated storage, and places the item back on the
+ * free list of its source (either msg_free_list or tx_free_list)
+ *
+ * TX Queue works as follows:
+ *
+ * Read index - points to the next TBD that the firmware will
+ *              process.  The firmware will read the data, and once
+ *              done processing, it will advance the Read index.
+ *
+ * Write index - driver fills this entry with an constructed TBD
+ *               entry.  The Write index is not advanced until the
+ *               packet has been configured.
+ *
+ * In between the W and R indexes are the TBDs that have NOT been
+ * processed.  Lagging behind the R index are packets that have
+ * been processed but have not been freed by the driver.
+ *
+ * In order to free old storage, an internal index will be maintained
+ * that points to the next packet to be freed.  When all used
+ * packets have been freed, the oldest index will be the same as the
+ * firmware's read index.
+ *
+ * The OLDEST index is cached in the variable 'priv->tx_queue.oldest'
+ *
+ * Because the TBD structure can not contain arbitrary data, the
+ * driver must keep an internal queue of cached allocations such that
+ * it can put that data back into the tx_free_list and msg_free_list
+ * for use by future command and data packets.
+ *
+ */
+static inline int __ipw2100_tx_process(struct ipw2100_priv *priv)
+{
+	struct ipw2100_bd_queue *txq = &priv->tx_queue;
+        struct ipw2100_bd *tbd;
+	struct list_head *element;
+	struct ipw2100_tx_packet *packet;
+	int descriptors_used;
+	int e, i;
+	u32 r, w, frag_num = 0;
+
+	if (list_empty(&priv->fw_pend_list))
+		return 0;
+
+	element = priv->fw_pend_list.next;
+
+	packet = list_entry(element, struct ipw2100_tx_packet, list);
+        tbd = &txq->drv[packet->index];
+
+	/* Determine how many TBD entries must be finished... */
+	switch (packet->type) {
+	case COMMAND:
+		/* COMMAND uses only one slot; don't advance */
+		descriptors_used = 1;
+		e = txq->oldest;
+		break;
+
+	case DATA:
+		/* DATA uses two slots; advance and loop position. */
+		descriptors_used = tbd->num_fragments;
+                frag_num = tbd->num_fragments - 1;
+		e = txq->oldest + frag_num;
+		e %= txq->entries;
+		break;
+
+	default:
+		IPW_DEBUG_WARNING("%s: Bad fw_pend_list entry!\n",
+				   priv->net_dev->name);
+		return 0;
+	}
+
+	/* if the last TBD is not done by NIC yet, then packet is
+	 * not ready to be released.
+	 *
+	 */
+	read_register(priv->net_dev, IPW_MEM_HOST_SHARED_TX_QUEUE_READ_INDEX,
+		      &r);
+	read_register(priv->net_dev, IPW_MEM_HOST_SHARED_TX_QUEUE_WRITE_INDEX,
+		      &w);
+	if (w != txq->next)
+		IPW_DEBUG_WARNING("%s: write index mismatch\n",
+		       priv->net_dev->name);
+
+        /*
+	 * txq->next is the index of the last packet written txq->oldest is
+	 * the index of the r is the index of the next packet to be read by
+	 * firmware
+	 */
+
+
+	/*
+	 * Quick graphic to help you visualize the following
+	 * if / else statement
+	 *
+	 * ===>|                     s---->|===============
+	 *                               e>|
+	 * | a | b | c | d | e | f | g | h | i | j | k | l
+	 *       r---->|
+	 *               w
+	 *
+	 * w - updated by driver
+	 * r - updated by firmware
+	 * s - start of oldest BD entry (txq->oldest)
+	 * e - end of oldest BD entry
+	 *
+	 */
+	if (!((r <= w && (e < r || e >= w)) || (e < r && e >= w))) {
+		IPW_DEBUG_TX("exit - no processed packets ready to release.\n");
+		return 0;
+	}
+
+	list_del(element);
+	DEC_STAT(&priv->fw_pend_stat);
+
+#ifdef CONFIG_IPW_DEBUG
+	{
+		int i = txq->oldest;
+		IPW_DEBUG_TX(
+			"TX%d V=%p P=%p T=%p L=%d\n", i,
+			&txq->drv[i],
+			(void*)txq->nic + i * sizeof(struct ipw2100_bd),
+			(void*)txq->drv[i].host_addr,
+			txq->drv[i].buf_length);
+
+		if (packet->type == DATA) {
+			i = (i + 1) % txq->entries;
+
+			IPW_DEBUG_TX(
+				"TX%d V=%p P=%p T=%p L=%d\n", i,
+				&txq->drv[i],
+				(void*)txq->nic + i *
+				sizeof(struct ipw2100_bd),
+				(void*)txq->drv[i].host_addr,
+				txq->drv[i].buf_length);
+		}
+	}
+#endif
+
+	switch (packet->type) {
+	case DATA:
+		if (txq->drv[txq->oldest].status.info.fields.txType != 0)
+			IPW_DEBUG_WARNING("%s: Queue mismatch.  "
+			       "Expecting DATA TBD but pulled "
+			       "something else: ids %d=%d.\n",
+			       priv->net_dev->name, txq->oldest, packet->index);
+
+		/* DATA packet; we have to unmap and free the SKB */
+		priv->ieee->stats.tx_packets++;
+		for (i = 0; i < frag_num; i++) {
+			tbd = &txq->drv[(packet->index + 1 + i) %
+					txq->entries];
+
+			IPW_DEBUG_TX(
+				"TX%d P=%08x L=%d\n",
+				(packet->index + 1 + i) % txq->entries,
+				tbd->host_addr, tbd->buf_length);
+
+			pci_unmap_single(priv->pci_dev,
+					 tbd->host_addr,
+					 tbd->buf_length,
+					 PCI_DMA_TODEVICE);
+		}
+
+		priv->ieee->stats.tx_bytes += packet->info.d_struct.txb->payload_size;
+		ieee80211_txb_free(packet->info.d_struct.txb);
+		packet->info.d_struct.txb = NULL;
+
+		list_add_tail(element, &priv->tx_free_list);
+		INC_STAT(&priv->tx_free_stat);
+
+		/* We have a free slot in the Tx queue, so wake up the
+		 * transmit layer if it is stopped. */
+		if (priv->status & STATUS_ASSOCIATED &&
+		    netif_queue_stopped(priv->net_dev)) {
+			IPW_DEBUG_INFO(KERN_INFO
+					   "%s: Waking net queue.\n",
+					   priv->net_dev->name);
+			netif_wake_queue(priv->net_dev);
+		}
+
+		/* A packet was processed by the hardware, so update the
+		 * watchdog */
+		priv->net_dev->trans_start = jiffies;
+
+		break;
+
+	case COMMAND:
+		if (txq->drv[txq->oldest].status.info.fields.txType != 1)
+			IPW_DEBUG_WARNING("%s: Queue mismatch.  "
+			       "Expecting COMMAND TBD but pulled "
+			       "something else: ids %d=%d.\n",
+			       priv->net_dev->name, txq->oldest, packet->index);
+
+#ifdef CONFIG_IPW_DEBUG
+		if (packet->info.c_struct.cmd->host_command_reg <
+		    sizeof(command_types) / sizeof(*command_types))
+			IPW_DEBUG_TX(
+				"Command '%s (%d)' processed: %d.\n",
+				command_types[packet->info.c_struct.cmd->host_command_reg],
+				packet->info.c_struct.cmd->host_command_reg,
+				packet->info.c_struct.cmd->cmd_status_reg);
+#endif
+
+		list_add_tail(element, &priv->msg_free_list);
+		INC_STAT(&priv->msg_free_stat);
+		break;
+	}
+
+	/* advance oldest used TBD pointer to start of next entry */
+	txq->oldest = (e + 1) % txq->entries;
+	/* increase available TBDs number */
+	txq->available += descriptors_used;
+	SET_STAT(&priv->txq_stat, txq->available);
+
+	IPW_DEBUG_TX("packet latency (send to process)  %ld jiffies\n",
+			 jiffies - packet->jiffy_start);
+
+	return (!list_empty(&priv->fw_pend_list));
+}
+
+
+static inline void __ipw2100_tx_complete(struct ipw2100_priv *priv)
+{
+	int i = 0;
+
+	while (__ipw2100_tx_process(priv) && i < 200) i++;
+
+	if (i == 200) {
+		IPW_DEBUG_WARNING(
+		       "%s: Driver is running slow (%d iters).\n",
+		       priv->net_dev->name, i);
+	}
+}
+
+
+static void X__ipw2100_tx_send_commands(struct ipw2100_priv *priv)
+{
+	struct list_head *element;
+	struct ipw2100_tx_packet *packet;
+	struct ipw2100_bd_queue *txq = &priv->tx_queue;
+	struct ipw2100_bd *tbd;
+	int next = txq->next;
+
+	while (!list_empty(&priv->msg_pend_list)) {
+		/* if there isn't enough space in TBD queue, then
+		 * don't stuff a new one in.
+		 * NOTE: 3 are needed as a command will take one,
+		 *       and there is a minimum of 2 that must be
+		 *       maintained between the r and w indexes
+		 */
+		if (txq->available <= 3) {
+			IPW_DEBUG_TX("no room in tx_queue\n");
+			break;
+		}
+
+		element = priv->msg_pend_list.next;
+		list_del(element);
+		DEC_STAT(&priv->msg_pend_stat);
+
+		packet = list_entry(element,
+				    struct ipw2100_tx_packet, list);
+
+		IPW_DEBUG_TX("using TBD at virt=%p, phys=%p\n",
+				 &txq->drv[txq->next],
+				 (void*)(txq->nic + txq->next *
+					 sizeof(struct ipw2100_bd)));
+
+		packet->index = txq->next;
+
+		tbd = &txq->drv[txq->next];
+
+		/* initialize TBD */
+		tbd->host_addr = packet->info.c_struct.cmd_phys;
+		tbd->buf_length = sizeof(struct ipw2100_cmd_header);
+		/* not marking number of fragments causes problems
+		 * with f/w debug version */
+		tbd->num_fragments = 1;
+		tbd->status.info.field =
+			IPW_BD_STATUS_TX_FRAME_COMMAND |
+			IPW_BD_STATUS_TX_INTERRUPT_ENABLE;
+
+		/* update TBD queue counters */
+		txq->next++;
+		txq->next %= txq->entries;
+		txq->available--;
+		DEC_STAT(&priv->txq_stat);
+
+		list_add_tail(element, &priv->fw_pend_list);
+		INC_STAT(&priv->fw_pend_stat);
+	}
+
+	if (txq->next != next) {
+		/* kick off the DMA by notifying firmware the
+		 * write index has moved; make sure TBD stores are sync'd */
+		wmb();
+		write_register(priv->net_dev,
+			       IPW_MEM_HOST_SHARED_TX_QUEUE_WRITE_INDEX,
+			       txq->next);
+	}
+}
+
+
+/*
+ * X__ipw2100_tx_send_data
+ *
+ */
+static void X__ipw2100_tx_send_data(struct ipw2100_priv *priv)
+{
+	struct list_head *element;
+	struct ipw2100_tx_packet *packet;
+	struct ipw2100_bd_queue *txq = &priv->tx_queue;
+	struct ipw2100_bd *tbd;
+	int next = txq->next;
+        int i = 0;
+	struct ipw2100_data_header *ipw_hdr;
+	struct ieee80211_hdr *hdr;
+
+	while (!list_empty(&priv->tx_pend_list)) {
+		/* if there isn't enough space in TBD queue, then
+		 * don't stuff a new one in.
+		 * NOTE: 4 are needed as a data will take two,
+		 *       and there is a minimum of 2 that must be
+		 *       maintained between the r and w indexes
+		 */
+		element = priv->tx_pend_list.next;
+                packet = list_entry(element, struct ipw2100_tx_packet, list);
+
+		if (unlikely(1 + packet->info.d_struct.txb->nr_frags >
+			     IPW_MAX_BDS)) {
+			/* TODO: Support merging buffers if more than
+			 * IPW_MAX_BDS are used */
+			IPW_DEBUG_INFO(
+			       "%s: Maximum BD theshold exceeded.  "
+			       "Increase fragmentation level.\n",
+			       priv->net_dev->name);
+		}
+
+		if (txq->available <= 3 +
+		    packet->info.d_struct.txb->nr_frags) {
+			IPW_DEBUG_TX("no room in tx_queue\n");
+			break;
+		}
+
+		list_del(element);
+		DEC_STAT(&priv->tx_pend_stat);
+
+		tbd = &txq->drv[txq->next];
+
+		packet->index = txq->next;
+
+		ipw_hdr = packet->info.d_struct.data;
+		hdr = (struct ieee80211_hdr *)packet->info.d_struct.txb->
+			fragments[0]->data;
+
+		if (priv->ieee->iw_mode == IW_MODE_INFRA) {
+			/* To DS: Addr1 = BSSID, Addr2 = SA,
+			   Addr3 = DA */
+			memcpy(ipw_hdr->src_addr, hdr->addr2, ETH_ALEN);
+			memcpy(ipw_hdr->dst_addr, hdr->addr3, ETH_ALEN);
+		} else if (priv->ieee->iw_mode == IW_MODE_ADHOC) {
+			/* not From/To DS: Addr1 = DA, Addr2 = SA,
+			   Addr3 = BSSID */
+			memcpy(ipw_hdr->src_addr, hdr->addr2, ETH_ALEN);
+			memcpy(ipw_hdr->dst_addr, hdr->addr1, ETH_ALEN);
+		}
+
+		ipw_hdr->host_command_reg = SEND;
+		ipw_hdr->host_command_reg1 = 0;
+
+		/* For now we only support host based encryption */
+		ipw_hdr->needs_encryption = 0;
+		ipw_hdr->encrypted = packet->info.d_struct.txb->encrypted;
+		if (packet->info.d_struct.txb->nr_frags > 1)
+			ipw_hdr->fragment_size =
+				packet->info.d_struct.txb->frag_size - IEEE80211_3ADDR_LEN;
+		else
+			ipw_hdr->fragment_size = 0;
+
+		tbd->host_addr = packet->info.d_struct.data_phys;
+		tbd->buf_length = sizeof(struct ipw2100_data_header);
+		tbd->num_fragments = 1 + packet->info.d_struct.txb->nr_frags;
+		tbd->status.info.field =
+			IPW_BD_STATUS_TX_FRAME_802_3 |
+			IPW_BD_STATUS_TX_FRAME_NOT_LAST_FRAGMENT;
+		txq->next++;
+		txq->next %= txq->entries;
+
+		IPW_DEBUG_TX(
+			"data header tbd TX%d P=%08x L=%d\n",
+			packet->index, tbd->host_addr,
+			tbd->buf_length);
+#ifdef CONFIG_IPW_DEBUG
+		if (packet->info.d_struct.txb->nr_frags > 1)
+			IPW_DEBUG_FRAG("fragment Tx: %d frames\n",
+				       packet->info.d_struct.txb->nr_frags);
+#endif
+
+                for (i = 0; i < packet->info.d_struct.txb->nr_frags; i++) {
+		        tbd = &txq->drv[txq->next];
+			if (i == packet->info.d_struct.txb->nr_frags - 1)
+				tbd->status.info.field =
+					IPW_BD_STATUS_TX_FRAME_802_3 |
+					IPW_BD_STATUS_TX_INTERRUPT_ENABLE;
+			else
+				tbd->status.info.field =
+					IPW_BD_STATUS_TX_FRAME_802_3 |
+					IPW_BD_STATUS_TX_FRAME_NOT_LAST_FRAGMENT;
+
+			tbd->buf_length = packet->info.d_struct.txb->
+				fragments[i]->len - IEEE80211_3ADDR_LEN;
+
+                        tbd->host_addr = pci_map_single(
+				priv->pci_dev,
+				packet->info.d_struct.txb->fragments[i]->data +
+				IEEE80211_3ADDR_LEN,
+				tbd->buf_length,
+				PCI_DMA_TODEVICE);
+
+			IPW_DEBUG_TX(
+				"data frag tbd TX%d P=%08x L=%d\n",
+				txq->next, tbd->host_addr, tbd->buf_length);
+
+			pci_dma_sync_single_for_device(
+				priv->pci_dev, tbd->host_addr,
+				tbd->buf_length,
+				PCI_DMA_TODEVICE);
+
+			txq->next++;
+			txq->next %= txq->entries;
+                }
+
+		txq->available -= 1 + packet->info.d_struct.txb->nr_frags;
+		SET_STAT(&priv->txq_stat, txq->available);
+
+		list_add_tail(element, &priv->fw_pend_list);
+		INC_STAT(&priv->fw_pend_stat);
+	}
+
+	if (txq->next != next) {
+		/* kick off the DMA by notifying firmware the
+		 * write index has moved; make sure TBD stores are sync'd */
+		write_register(priv->net_dev,
+			       IPW_MEM_HOST_SHARED_TX_QUEUE_WRITE_INDEX,
+			       txq->next);
+	}
+        return;
+}
+
+static void ipw2100_irq_tasklet(struct ipw2100_priv *priv)
+{
+	struct net_device *dev = priv->net_dev;
+	unsigned long flags;
+	u32 inta, tmp;
+
+	spin_lock_irqsave(&priv->low_lock, flags);
+	ipw2100_disable_interrupts(priv);
+
+	read_register(dev, IPW_REG_INTA, &inta);
+
+	IPW_DEBUG_ISR("enter - INTA: 0x%08lX\n",
+		      (unsigned long)inta & IPW_INTERRUPT_MASK);
+
+	priv->in_isr++;
+	priv->interrupts++;
+
+	/* We do not loop and keep polling for more interrupts as this
+	 * is frowned upon and doesn't play nicely with other potentially
+	 * chained IRQs */
+	IPW_DEBUG_ISR("INTA: 0x%08lX\n",
+		      (unsigned long)inta & IPW_INTERRUPT_MASK);
+
+	if (inta & IPW2100_INTA_FATAL_ERROR) {
+		IPW_DEBUG_WARNING(DRV_NAME
+				  ": Fatal interrupt. Scheduling firmware restart.\n");
+		priv->inta_other++;
+		write_register(
+			dev, IPW_REG_INTA,
+			IPW2100_INTA_FATAL_ERROR);
+
+		read_nic_dword(dev, IPW_NIC_FATAL_ERROR, &priv->fatal_error);
+		IPW_DEBUG_INFO("%s: Fatal error value: 0x%08X\n",
+			       priv->net_dev->name, priv->fatal_error);
+
+		read_nic_dword(dev, IPW_ERROR_ADDR(priv->fatal_error), &tmp);
+		IPW_DEBUG_INFO("%s: Fatal error address value: 0x%08X\n",
+			       priv->net_dev->name, tmp);
+
+		/* Wake up any sleeping jobs */
+		schedule_reset(priv);
+	}
+
+	if (inta & IPW2100_INTA_PARITY_ERROR) {
+		IPW_DEBUG_ERROR("***** PARITY ERROR INTERRUPT !!!! \n");
+		priv->inta_other++;
+		write_register(
+			dev, IPW_REG_INTA,
+			IPW2100_INTA_PARITY_ERROR);
+	}
+
+	if (inta & IPW2100_INTA_RX_TRANSFER) {
+		IPW_DEBUG_ISR("RX interrupt\n");
+
+		priv->rx_interrupts++;
+
+		write_register(
+			dev, IPW_REG_INTA,
+			IPW2100_INTA_RX_TRANSFER);
+
+		__ipw2100_rx_process(priv);
+		__ipw2100_tx_complete(priv);
+	}
+
+	if (inta & IPW2100_INTA_TX_TRANSFER) {
+		IPW_DEBUG_ISR("TX interrupt\n");
+
+		priv->tx_interrupts++;
+
+		write_register(dev, IPW_REG_INTA,
+			       IPW2100_INTA_TX_TRANSFER);
+
+		__ipw2100_tx_complete(priv);
+		X__ipw2100_tx_send_commands(priv);
+		X__ipw2100_tx_send_data(priv);
+	}
+
+	if (inta & IPW2100_INTA_TX_COMPLETE) {
+		IPW_DEBUG_ISR("TX complete\n");
+		priv->inta_other++;
+		write_register(
+			dev, IPW_REG_INTA,
+			IPW2100_INTA_TX_COMPLETE);
+
+		__ipw2100_tx_complete(priv);
+	}
+
+	if (inta & IPW2100_INTA_EVENT_INTERRUPT) {
+		/* ipw2100_handle_event(dev); */
+		priv->inta_other++;
+		write_register(
+			dev, IPW_REG_INTA,
+			IPW2100_INTA_EVENT_INTERRUPT);
+	}
+
+	if (inta & IPW2100_INTA_FW_INIT_DONE) {
+		IPW_DEBUG_ISR("FW init done interrupt\n");
+		priv->inta_other++;
+
+		read_register(dev, IPW_REG_INTA, &tmp);
+		if (tmp & (IPW2100_INTA_FATAL_ERROR |
+			   IPW2100_INTA_PARITY_ERROR)) {
+			write_register(
+				dev, IPW_REG_INTA,
+				IPW2100_INTA_FATAL_ERROR |
+				IPW2100_INTA_PARITY_ERROR);
+		}
+
+		write_register(dev, IPW_REG_INTA,
+			       IPW2100_INTA_FW_INIT_DONE);
+	}
+
+	if (inta & IPW2100_INTA_STATUS_CHANGE) {
+		IPW_DEBUG_ISR("Status change interrupt\n");
+		priv->inta_other++;
+		write_register(
+			dev, IPW_REG_INTA,
+			IPW2100_INTA_STATUS_CHANGE);
+	}
+
+	if (inta & IPW2100_INTA_SLAVE_MODE_HOST_COMMAND_DONE) {
+		IPW_DEBUG_ISR("slave host mode interrupt\n");
+		priv->inta_other++;
+		write_register(
+			dev, IPW_REG_INTA,
+			IPW2100_INTA_SLAVE_MODE_HOST_COMMAND_DONE);
+	}
+
+	priv->in_isr--;
+	ipw2100_enable_interrupts(priv);
+
+	spin_unlock_irqrestore(&priv->low_lock, flags);
+
+	IPW_DEBUG_ISR("exit\n");
+}
+
+
+static irqreturn_t ipw2100_interrupt(int irq, void *data,
+				     struct pt_regs *regs)
+{
+	struct ipw2100_priv *priv = data;
+	u32 inta, inta_mask;
+
+	if (!data)
+		return IRQ_NONE;
+
+ 	spin_lock(&priv->low_lock);
+
+	/* We check to see if we should be ignoring interrupts before
+	 * we touch the hardware.  During ucode load if we try and handle
+	 * an interrupt we can cause keyboard problems as well as cause
+	 * the ucode to fail to initialize */
+	if (!(priv->status & STATUS_INT_ENABLED)) {
+		/* Shared IRQ */
+		goto none;
+	}
+
+	read_register(priv->net_dev, IPW_REG_INTA_MASK, &inta_mask);
+	read_register(priv->net_dev, IPW_REG_INTA, &inta);
+
+	if (inta == 0xFFFFFFFF) {
+		/* Hardware disappeared */
+		IPW_DEBUG_WARNING("IRQ INTA == 0xFFFFFFFF\n");
+		goto none;
+	}
+
+	inta &= IPW_INTERRUPT_MASK;
+
+	if (!(inta & inta_mask)) {
+		/* Shared interrupt */
+		goto none;
+	}
+
+	/* We disable the hardware interrupt here just to prevent unneeded
+	 * calls to be made.  We disable this again within the actual
+	 * work tasklet, so if another part of the code re-enables the
+	 * interrupt, that is fine */
+	ipw2100_disable_interrupts(priv);
+
+	tasklet_schedule(&priv->irq_tasklet);
+ 	spin_unlock(&priv->low_lock);
+
+	return IRQ_HANDLED;
+ none:
+	spin_unlock(&priv->low_lock);
+	return IRQ_NONE;
+}
+
+static int ipw2100_tx(struct ieee80211_txb *txb, struct net_device *dev)
+{
+	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct list_head *element;
+	struct ipw2100_tx_packet *packet;
+	unsigned long flags;
+
+	spin_lock_irqsave(&priv->low_lock, flags);
+
+	if (!(priv->status & STATUS_ASSOCIATED)) {
+		IPW_DEBUG_INFO("Can not transmit when not connected.\n");
+		priv->ieee->stats.tx_carrier_errors++;
+		netif_stop_queue(dev);
+		goto fail_unlock;
+	}
+
+	if (list_empty(&priv->tx_free_list))
+		goto fail_unlock;
+
+	element = priv->tx_free_list.next;
+	packet = list_entry(element, struct ipw2100_tx_packet, list);
+
+	packet->info.d_struct.txb = txb;
+
+	IPW_DEBUG_TX("Sending fragment (%d bytes):\n",
+			 txb->fragments[0]->len);
+	printk_buf(IPW_DL_TX, txb->fragments[0]->data,
+		   txb->fragments[0]->len);
+
+	packet->jiffy_start = jiffies;
+
+	list_del(element);
+	DEC_STAT(&priv->tx_free_stat);
+
+	list_add_tail(element, &priv->tx_pend_list);
+	INC_STAT(&priv->tx_pend_stat);
+
+	X__ipw2100_tx_send_data(priv);
+
+	spin_unlock_irqrestore(&priv->low_lock, flags);
+	return 0;
+
+ fail_unlock:
+	netif_stop_queue(dev);
+	spin_unlock_irqrestore(&priv->low_lock, flags);
+	return 1;
+}
+
+
+static int ipw2100_msg_allocate(struct ipw2100_priv *priv)
+{
+	int i, j, err = -EINVAL;
+	void *v;
+	dma_addr_t p;
+
+	priv->msg_buffers = (struct ipw2100_tx_packet *)kmalloc(
+		IPW_COMMAND_POOL_SIZE * sizeof(struct ipw2100_tx_packet),
+		GFP_KERNEL);
+	if (!priv->msg_buffers) {
+		IPW_DEBUG_ERROR("%s: PCI alloc failed for msg "
+		       "buffers.\n", priv->net_dev->name);
+		return -ENOMEM;
+	}
+
+	for (i = 0; i < IPW_COMMAND_POOL_SIZE; i++) {
+		v = pci_alloc_consistent(
+			priv->pci_dev,
+			sizeof(struct ipw2100_cmd_header),
+			&p);
+		if (!v) {
+			IPW_DEBUG_ERROR(
+			       "%s: PCI alloc failed for msg "
+			       "buffers.\n",
+			       priv->net_dev->name);
+			err = -ENOMEM;
+			break;
+		}
+
+		memset(v, 0, sizeof(struct ipw2100_cmd_header));
+
+		priv->msg_buffers[i].type = COMMAND;
+		priv->msg_buffers[i].info.c_struct.cmd =
+			(struct ipw2100_cmd_header*)v;
+		priv->msg_buffers[i].info.c_struct.cmd_phys = p;
+	}
+
+	if (i == IPW_COMMAND_POOL_SIZE)
+		return 0;
+
+	for (j = 0; j < i; j++) {
+		pci_free_consistent(
+			priv->pci_dev,
+			sizeof(struct ipw2100_cmd_header),
+			priv->msg_buffers[j].info.c_struct.cmd,
+			priv->msg_buffers[j].info.c_struct.cmd_phys);
+	}
+
+	kfree(priv->msg_buffers);
+	priv->msg_buffers = NULL;
+
+	return err;
+}
+
+static int ipw2100_msg_initialize(struct ipw2100_priv *priv)
+{
+	int i;
+
+	INIT_LIST_HEAD(&priv->msg_free_list);
+	INIT_LIST_HEAD(&priv->msg_pend_list);
+
+	for (i = 0; i < IPW_COMMAND_POOL_SIZE; i++)
+		list_add_tail(&priv->msg_buffers[i].list, &priv->msg_free_list);
+	SET_STAT(&priv->msg_free_stat, i);
+
+	return 0;
+}
+
+static void ipw2100_msg_free(struct ipw2100_priv *priv)
+{
+	int i;
+
+	if (!priv->msg_buffers)
+		return;
+
+	for (i = 0; i < IPW_COMMAND_POOL_SIZE; i++) {
+		pci_free_consistent(priv->pci_dev,
+				    sizeof(struct ipw2100_cmd_header),
+				    priv->msg_buffers[i].info.c_struct.cmd,
+				    priv->msg_buffers[i].info.c_struct.cmd_phys);
+	}
+
+	kfree(priv->msg_buffers);
+	priv->msg_buffers = NULL;
+}
+
+static ssize_t show_pci(struct device *d, char *buf)
+{
+	struct pci_dev *pci_dev = container_of(d, struct pci_dev, dev);
+	char *out = buf;
+	int i, j;
+	u32 val;
+
+	for (i = 0; i < 16; i++) {
+		out += sprintf(out, "[%08X] ", i * 16);
+		for (j = 0; j < 16; j += 4) {
+			pci_read_config_dword(pci_dev, i * 16 + j, &val);
+			out += sprintf(out, "%08X ", val);
+		}
+		out += sprintf(out, "\n");
+	}
+
+	return out - buf;
+}
+static DEVICE_ATTR(pci, S_IRUGO, show_pci, NULL);
+
+static ssize_t show_cfg(struct device *d, char *buf)
+{
+	struct ipw2100_priv *p = (struct ipw2100_priv *)d->driver_data;
+	return sprintf(buf, "0x%08x\n", (int)p->config);
+}
+static DEVICE_ATTR(cfg, S_IRUGO, show_cfg, NULL);
+
+static ssize_t show_status(struct device *d, char *buf)
+{
+	struct ipw2100_priv *p = (struct ipw2100_priv *)d->driver_data;
+	return sprintf(buf, "0x%08x\n", (int)p->status);
+}
+static DEVICE_ATTR(status, S_IRUGO, show_status, NULL);
+
+static ssize_t show_capability(struct device *d, char *buf)
+{
+	struct ipw2100_priv *p = (struct ipw2100_priv *)d->driver_data;
+	return sprintf(buf, "0x%08x\n", (int)p->capability);
+}
+static DEVICE_ATTR(capability, S_IRUGO, show_capability, NULL);
+
+
+#define IPW2100_REG(x) { IPW_ ##x, #x }
+const struct {
+	u32 addr;
+	const char *name;
+} hw_data[] = {
+	IPW2100_REG(REG_GP_CNTRL),
+	IPW2100_REG(REG_GPIO),
+	IPW2100_REG(REG_INTA),
+	IPW2100_REG(REG_INTA_MASK),
+	IPW2100_REG(REG_RESET_REG),
+};
+#define IPW2100_NIC(x, s) { x, #x, s }
+const struct {
+	u32 addr;
+	const char *name;
+	size_t size;
+} nic_data[] = {
+	IPW2100_NIC(IPW2100_CONTROL_REG, 2),
+	IPW2100_NIC(0x210014, 1),
+	IPW2100_NIC(0x210000, 1),
+};
+#define IPW2100_ORD(x, d) { IPW_ORD_ ##x, #x, d }
+const struct {
+	u8 index;
+	const char *name;
+	const char *desc;
+} ord_data[] = {
+	IPW2100_ORD(STAT_TX_HOST_REQUESTS, "requested Host Tx's (MSDU)"),
+	IPW2100_ORD(STAT_TX_HOST_COMPLETE, "successful Host Tx's (MSDU)"),
+	IPW2100_ORD(STAT_TX_DIR_DATA,	   "successful Directed Tx's (MSDU)"),
+	IPW2100_ORD(STAT_TX_DIR_DATA1,	   "successful Directed Tx's (MSDU) @ 1MB"),
+	IPW2100_ORD(STAT_TX_DIR_DATA2,	   "successful Directed Tx's (MSDU) @ 2MB"),
+	IPW2100_ORD(STAT_TX_DIR_DATA5_5,   "successful Directed Tx's (MSDU) @ 5_5MB"),
+	IPW2100_ORD(STAT_TX_DIR_DATA11,	   "successful Directed Tx's (MSDU) @ 11MB"),
+	IPW2100_ORD(STAT_TX_NODIR_DATA1,   "successful Non_Directed Tx's (MSDU) @ 1MB"),
+	IPW2100_ORD(STAT_TX_NODIR_DATA2,   "successful Non_Directed Tx's (MSDU) @ 2MB"),
+	IPW2100_ORD(STAT_TX_NODIR_DATA5_5, "successful Non_Directed Tx's (MSDU) @ 5.5MB"),
+	IPW2100_ORD(STAT_TX_NODIR_DATA11,  "successful Non_Directed Tx's (MSDU) @ 11MB"),
+	IPW2100_ORD(STAT_NULL_DATA,	   "successful NULL data Tx's"),
+	IPW2100_ORD(STAT_TX_RTS,	   "successful Tx RTS"),
+	IPW2100_ORD(STAT_TX_CTS,	   "successful Tx CTS"),
+	IPW2100_ORD(STAT_TX_ACK,	   "successful Tx ACK"),
+	IPW2100_ORD(STAT_TX_ASSN,	   "successful Association Tx's"),
+	IPW2100_ORD(STAT_TX_ASSN_RESP,	   "successful Association response Tx's"),
+	IPW2100_ORD(STAT_TX_REASSN,	   "successful Reassociation Tx's"),
+	IPW2100_ORD(STAT_TX_REASSN_RESP,   "successful Reassociation response Tx's"),
+	IPW2100_ORD(STAT_TX_PROBE,	   "probes successfully transmitted"),
+	IPW2100_ORD(STAT_TX_PROBE_RESP,	   "probe responses successfully transmitted"),
+	IPW2100_ORD(STAT_TX_BEACON,	   "tx beacon"),
+	IPW2100_ORD(STAT_TX_ATIM,	   "Tx ATIM"),
+	IPW2100_ORD(STAT_TX_DISASSN,	   "successful Disassociation TX"),
+	IPW2100_ORD(STAT_TX_AUTH,	   "successful Authentication Tx"),
+	IPW2100_ORD(STAT_TX_DEAUTH,	   "successful Deauthentication TX"),
+	IPW2100_ORD(STAT_TX_TOTAL_BYTES,   "Total successful Tx data bytes"),
+	IPW2100_ORD(STAT_TX_RETRIES,       "Tx retries"),
+	IPW2100_ORD(STAT_TX_RETRY1,        "Tx retries at 1MBPS"),
+	IPW2100_ORD(STAT_TX_RETRY2,        "Tx retries at 2MBPS"),
+	IPW2100_ORD(STAT_TX_RETRY5_5,	   "Tx retries at 5.5MBPS"),
+	IPW2100_ORD(STAT_TX_RETRY11,	   "Tx retries at 11MBPS"),
+	IPW2100_ORD(STAT_TX_FAILURES,	   "Tx Failures"),
+	IPW2100_ORD(STAT_TX_MAX_TRIES_IN_HOP,"times max tries in a hop failed"),
+	IPW2100_ORD(STAT_TX_DISASSN_FAIL,	"times disassociation failed"),
+	IPW2100_ORD(STAT_TX_ERR_CTS,         "missed/bad CTS frames"),
+	IPW2100_ORD(STAT_TX_ERR_ACK,	"tx err due to acks"),
+	IPW2100_ORD(STAT_RX_HOST,	"packets passed to host"),
+	IPW2100_ORD(STAT_RX_DIR_DATA,	"directed packets"),
+	IPW2100_ORD(STAT_RX_DIR_DATA1,	"directed packets at 1MB"),
+	IPW2100_ORD(STAT_RX_DIR_DATA2,	"directed packets at 2MB"),
+	IPW2100_ORD(STAT_RX_DIR_DATA5_5,	"directed packets at 5.5MB"),
+	IPW2100_ORD(STAT_RX_DIR_DATA11,	"directed packets at 11MB"),
+	IPW2100_ORD(STAT_RX_NODIR_DATA,"nondirected packets"),
+	IPW2100_ORD(STAT_RX_NODIR_DATA1,	"nondirected packets at 1MB"),
+	IPW2100_ORD(STAT_RX_NODIR_DATA2,	"nondirected packets at 2MB"),
+	IPW2100_ORD(STAT_RX_NODIR_DATA5_5,	"nondirected packets at 5.5MB"),
+	IPW2100_ORD(STAT_RX_NODIR_DATA11,	"nondirected packets at 11MB"),
+	IPW2100_ORD(STAT_RX_NULL_DATA,	"null data rx's"),
+	IPW2100_ORD(STAT_RX_RTS,	"Rx RTS"),
+	IPW2100_ORD(STAT_RX_CTS,	"Rx CTS"),
+	IPW2100_ORD(STAT_RX_ACK,	"Rx ACK"),
+	IPW2100_ORD(STAT_RX_CFEND,	"Rx CF End"),
+	IPW2100_ORD(STAT_RX_CFEND_ACK,	"Rx CF End + CF Ack"),
+	IPW2100_ORD(STAT_RX_ASSN,	"Association Rx's"),
+	IPW2100_ORD(STAT_RX_ASSN_RESP,	"Association response Rx's"),
+	IPW2100_ORD(STAT_RX_REASSN,	"Reassociation Rx's"),
+	IPW2100_ORD(STAT_RX_REASSN_RESP,	"Reassociation response Rx's"),
+	IPW2100_ORD(STAT_RX_PROBE,	"probe Rx's"),
+	IPW2100_ORD(STAT_RX_PROBE_RESP,	"probe response Rx's"),
+	IPW2100_ORD(STAT_RX_BEACON,	"Rx beacon"),
+	IPW2100_ORD(STAT_RX_ATIM,	"Rx ATIM"),
+	IPW2100_ORD(STAT_RX_DISASSN,	"disassociation Rx"),
+	IPW2100_ORD(STAT_RX_AUTH,	"authentication Rx"),
+	IPW2100_ORD(STAT_RX_DEAUTH,	"deauthentication Rx"),
+	IPW2100_ORD(STAT_RX_TOTAL_BYTES,"Total rx data bytes received"),
+	IPW2100_ORD(STAT_RX_ERR_CRC,	 "packets with Rx CRC error"),
+	IPW2100_ORD(STAT_RX_ERR_CRC1,	 "Rx CRC errors at 1MB"),
+	IPW2100_ORD(STAT_RX_ERR_CRC2,	 "Rx CRC errors at 2MB"),
+	IPW2100_ORD(STAT_RX_ERR_CRC5_5,	 "Rx CRC errors at 5.5MB"),
+	IPW2100_ORD(STAT_RX_ERR_CRC11,	 "Rx CRC errors at 11MB"),
+	IPW2100_ORD(STAT_RX_DUPLICATE1, "duplicate rx packets at 1MB"),
+	IPW2100_ORD(STAT_RX_DUPLICATE2,	 "duplicate rx packets at 2MB"),
+	IPW2100_ORD(STAT_RX_DUPLICATE5_5,	 "duplicate rx packets at 5.5MB"),
+	IPW2100_ORD(STAT_RX_DUPLICATE11,	 "duplicate rx packets at 11MB"),
+	IPW2100_ORD(STAT_RX_DUPLICATE, "duplicate rx packets"),
+	IPW2100_ORD(PERS_DB_LOCK,	"locking fw permanent  db"),
+	IPW2100_ORD(PERS_DB_SIZE,	"size of fw permanent  db"),
+	IPW2100_ORD(PERS_DB_ADDR,	"address of fw permanent  db"),
+	IPW2100_ORD(STAT_RX_INVALID_PROTOCOL,	"rx frames with invalid protocol"),
+	IPW2100_ORD(SYS_BOOT_TIME,	"Boot time"),
+	IPW2100_ORD(STAT_RX_NO_BUFFER,	"rx frames rejected due to no buffer"),
+	IPW2100_ORD(STAT_RX_MISSING_FRAG,	"rx frames dropped due to missing fragment"),
+	IPW2100_ORD(STAT_RX_ORPHAN_FRAG,	"rx frames dropped due to non-sequential fragment"),
+	IPW2100_ORD(STAT_RX_ORPHAN_FRAME,	"rx frames dropped due to unmatched 1st frame"),
+	IPW2100_ORD(STAT_RX_FRAG_AGEOUT,	"rx frames dropped due to uncompleted frame"),
+	IPW2100_ORD(STAT_RX_ICV_ERRORS,	"ICV errors during decryption"),
+	IPW2100_ORD(STAT_PSP_SUSPENSION,"times adapter suspended"),
+	IPW2100_ORD(STAT_PSP_BCN_TIMEOUT,	"beacon timeout"),
+	IPW2100_ORD(STAT_PSP_POLL_TIMEOUT,	"poll response timeouts"),
+	IPW2100_ORD(STAT_PSP_NONDIR_TIMEOUT, "timeouts waiting for last {broad,multi}cast pkt"),
+	IPW2100_ORD(STAT_PSP_RX_DTIMS,	"PSP DTIMs received"),
+	IPW2100_ORD(STAT_PSP_RX_TIMS,	"PSP TIMs received"),
+	IPW2100_ORD(STAT_PSP_STATION_ID,"PSP Station ID"),
+	IPW2100_ORD(LAST_ASSN_TIME,	"RTC time of last association"),
+	IPW2100_ORD(STAT_PERCENT_MISSED_BCNS,"current calculation of % missed beacons"),
+	IPW2100_ORD(STAT_PERCENT_RETRIES,"current calculation of % missed tx retries"),
+	IPW2100_ORD(ASSOCIATED_AP_PTR,	"0 if not associated, else pointer to AP table entry"),
+	IPW2100_ORD(AVAILABLE_AP_CNT,	"AP's decsribed in the AP table"),
+	IPW2100_ORD(AP_LIST_PTR,	"Ptr to list of available APs"),
+	IPW2100_ORD(STAT_AP_ASSNS,	"associations"),
+	IPW2100_ORD(STAT_ASSN_FAIL,	"association failures"),
+	IPW2100_ORD(STAT_ASSN_RESP_FAIL,"failures due to response fail"),
+	IPW2100_ORD(STAT_FULL_SCANS,	"full scans"),
+	IPW2100_ORD(CARD_DISABLED,	"Card Disabled"),
+	IPW2100_ORD(STAT_ROAM_INHIBIT,	"times roaming was inhibited due to activity"),
+	IPW2100_ORD(RSSI_AT_ASSN,	"RSSI of associated AP at time of association"),
+	IPW2100_ORD(STAT_ASSN_CAUSE1,	"reassociation: no probe response or TX on hop"),
+	IPW2100_ORD(STAT_ASSN_CAUSE2,	"reassociation: poor tx/rx quality"),
+	IPW2100_ORD(STAT_ASSN_CAUSE3,	"reassociation: tx/rx quality (excessive AP load"),
+	IPW2100_ORD(STAT_ASSN_CAUSE4,	"reassociation: AP RSSI level"),
+	IPW2100_ORD(STAT_ASSN_CAUSE5,	"reassociations due to load leveling"),
+	IPW2100_ORD(STAT_AUTH_FAIL,	"times authentication failed"),
+	IPW2100_ORD(STAT_AUTH_RESP_FAIL,"times authentication response failed"),
+	IPW2100_ORD(STATION_TABLE_CNT,	"entries in association table"),
+	IPW2100_ORD(RSSI_AVG_CURR,	"Current avg RSSI"),
+	IPW2100_ORD(POWER_MGMT_MODE,	"Power mode - 0=CAM, 1=PSP"),
+	IPW2100_ORD(COUNTRY_CODE,	"IEEE country code as recv'd from beacon"),
+	IPW2100_ORD(COUNTRY_CHANNELS,	"channels suported by country"),
+	IPW2100_ORD(RESET_CNT,	"adapter resets (warm)"),
+	IPW2100_ORD(BEACON_INTERVAL,	"Beacon interval"),
+	IPW2100_ORD(ANTENNA_DIVERSITY,	"TRUE if antenna diversity is disabled"),
+	IPW2100_ORD(DTIM_PERIOD,	"beacon intervals between DTIMs"),
+	IPW2100_ORD(OUR_FREQ,	"current radio freq lower digits - channel ID"),
+	IPW2100_ORD(RTC_TIME,	"current RTC time"),
+	IPW2100_ORD(PORT_TYPE,	"operating mode"),
+	IPW2100_ORD(CURRENT_TX_RATE,	"current tx rate"),
+	IPW2100_ORD(SUPPORTED_RATES,	"supported tx rates"),
+	IPW2100_ORD(ATIM_WINDOW,	"current ATIM Window"),
+	IPW2100_ORD(BASIC_RATES,	"basic tx rates"),
+	IPW2100_ORD(NIC_HIGHEST_RATE,	"NIC highest tx rate"),
+	IPW2100_ORD(AP_HIGHEST_RATE,	"AP highest tx rate"),
+	IPW2100_ORD(CAPABILITIES,	"Management frame capability field"),
+	IPW2100_ORD(AUTH_TYPE,	"Type of authentication"),
+	IPW2100_ORD(RADIO_TYPE,	"Adapter card platform type"),
+	IPW2100_ORD(RTS_THRESHOLD,	"Min packet length for RTS handshaking"),
+	IPW2100_ORD(INT_MODE,	"International mode"),
+	IPW2100_ORD(FRAGMENTATION_THRESHOLD,	"protocol frag threshold"),
+	IPW2100_ORD(EEPROM_SRAM_DB_BLOCK_START_ADDRESS,	"EEPROM offset in SRAM"),
+	IPW2100_ORD(EEPROM_SRAM_DB_BLOCK_SIZE,	"EEPROM size in SRAM"),
+	IPW2100_ORD(EEPROM_SKU_CAPABILITY,	"EEPROM SKU Capability"),
+	IPW2100_ORD(EEPROM_IBSS_11B_CHANNELS,	"EEPROM IBSS 11b channel set"),
+	IPW2100_ORD(MAC_VERSION,	"MAC Version"),
+	IPW2100_ORD(MAC_REVISION,	"MAC Revision"),
+	IPW2100_ORD(RADIO_VERSION,	"Radio Version"),
+	IPW2100_ORD(NIC_MANF_DATE_TIME,	"MANF Date/Time STAMP"),
+	IPW2100_ORD(UCODE_VERSION,	"Ucode Version"),
+};
+
+
+static ssize_t show_registers(struct device *d, char *buf)
+{
+	int i;
+	struct ipw2100_priv *priv = dev_get_drvdata(d);
+	struct net_device *dev = priv->net_dev;
+	char * out = buf;
+	u32 val = 0;
+
+	out += sprintf(out, "%30s [Address ] : Hex\n", "Register");
+
+	for (i = 0; i < (sizeof(hw_data) / sizeof(*hw_data)); i++) {
+		read_register(dev, hw_data[i].addr, &val);
+		out += sprintf(out, "%30s [%08X] : %08X\n",
+			       hw_data[i].name, hw_data[i].addr, val);
+	}
+
+	return out - buf;
+}
+static DEVICE_ATTR(registers, S_IRUGO, show_registers, NULL);
+
+
+static ssize_t show_hardware(struct device *d, char *buf)
+{
+	struct ipw2100_priv *priv = dev_get_drvdata(d);
+	struct net_device *dev = priv->net_dev;
+	char * out = buf;
+	int i;
+
+	out += sprintf(out, "%30s [Address ] : Hex\n", "NIC entry");
+
+	for (i = 0; i < (sizeof(nic_data) / sizeof(*nic_data)); i++) {
+		u8 tmp8;
+		u16 tmp16;
+		u32 tmp32;
+
+		switch (nic_data[i].size) {
+		case 1:
+			read_nic_byte(dev, nic_data[i].addr, &tmp8);
+			out += sprintf(out, "%30s [%08X] : %02X\n",
+				       nic_data[i].name, nic_data[i].addr,
+				       tmp8);
+			break;
+		case 2:
+			read_nic_word(dev, nic_data[i].addr, &tmp16);
+			out += sprintf(out, "%30s [%08X] : %04X\n",
+				       nic_data[i].name, nic_data[i].addr,
+				       tmp16);
+			break;
+		case 4:
+			read_nic_dword(dev, nic_data[i].addr, &tmp32);
+			out += sprintf(out, "%30s [%08X] : %08X\n",
+				       nic_data[i].name, nic_data[i].addr,
+				       tmp32);
+			break;
+		}
+	}
+	return out - buf;
+}
+static DEVICE_ATTR(hardware, S_IRUGO, show_hardware, NULL);
+
+
+static ssize_t show_memory(struct device *d, char *buf)
+{
+	struct ipw2100_priv *priv = dev_get_drvdata(d);
+	struct net_device *dev = priv->net_dev;
+	static unsigned long loop = 0;
+	int len = 0;
+	u32 buffer[4];
+	int i;
+	char line[81];
+
+	if (loop >= 0x30000)
+		loop = 0;
+
+	/* sysfs provides us PAGE_SIZE buffer */
+	while (len < PAGE_SIZE - 128 && loop < 0x30000) {
+
+		if (priv->snapshot[0]) for (i = 0; i < 4; i++)
+			buffer[i] = *(u32 *)SNAPSHOT_ADDR(loop + i * 4);
+		else for (i = 0; i < 4; i++)
+			read_nic_dword(dev, loop + i * 4, &buffer[i]);
+
+		if (priv->dump_raw)
+			len += sprintf(buf + len,
+				       "%c%c%c%c"
+				       "%c%c%c%c"
+				       "%c%c%c%c"
+				       "%c%c%c%c",
+				       ((u8*)buffer)[0x0],
+				       ((u8*)buffer)[0x1],
+				       ((u8*)buffer)[0x2],
+				       ((u8*)buffer)[0x3],
+				       ((u8*)buffer)[0x4],
+				       ((u8*)buffer)[0x5],
+				       ((u8*)buffer)[0x6],
+				       ((u8*)buffer)[0x7],
+				       ((u8*)buffer)[0x8],
+				       ((u8*)buffer)[0x9],
+				       ((u8*)buffer)[0xa],
+				       ((u8*)buffer)[0xb],
+				       ((u8*)buffer)[0xc],
+				       ((u8*)buffer)[0xd],
+				       ((u8*)buffer)[0xe],
+				       ((u8*)buffer)[0xf]);
+		else
+			len += sprintf(buf + len, "%s\n",
+				       snprint_line(line, sizeof(line),
+						    (u8*)buffer, 16, loop));
+		loop += 16;
+	}
+
+	return len;
+}
+
+static ssize_t store_memory(struct device *d, const char *buf, size_t count)
+{
+	struct ipw2100_priv *priv = dev_get_drvdata(d);
+	struct net_device *dev = priv->net_dev;
+	const char *p = buf;
+
+	if (count < 1)
+		return count;
+
+	if (p[0] == '1' ||
+	    (count >= 2 && tolower(p[0]) == 'o' && tolower(p[1]) == 'n')) {
+		IPW_DEBUG_INFO("%s: Setting memory dump to RAW mode.\n",
+		       dev->name);
+		priv->dump_raw = 1;
+
+	} else if (p[0] == '0' || (count >= 2 && tolower(p[0]) == 'o' &&
+				  tolower(p[1]) == 'f')) {
+		IPW_DEBUG_INFO("%s: Setting memory dump to HEX mode.\n",
+		       dev->name);
+		priv->dump_raw = 0;
+
+	} else if (tolower(p[0]) == 'r') {
+		IPW_DEBUG_INFO("%s: Resetting firmware snapshot.\n",
+		       dev->name);
+		ipw2100_snapshot_free(priv);
+
+	} else
+		IPW_DEBUG_INFO("%s: Usage: 0|on = HEX, 1|off = RAW, "
+		       "reset = clear memory snapshot\n",
+		       dev->name);
+
+	return count;
+}
+static DEVICE_ATTR(memory, S_IWUSR|S_IRUGO, show_memory, store_memory);
+
+
+static ssize_t show_ordinals(struct device *d, char *buf)
+{
+	struct ipw2100_priv *priv = dev_get_drvdata(d);
+	u32 val = 0;
+	int len = 0;
+	u32 val_len;
+	static int loop = 0;
+
+	if (loop >= sizeof(ord_data) / sizeof(*ord_data))
+		loop = 0;
+
+	/* sysfs provides us PAGE_SIZE buffer */
+	while (len < PAGE_SIZE - 128 &&
+	       loop < (sizeof(ord_data) / sizeof(*ord_data))) {
+
+		val_len = sizeof(u32);
+
+		if (ipw2100_get_ordinal(priv, ord_data[loop].index, &val,
+					&val_len))
+			len += sprintf(buf + len, "[0x%02X] = ERROR    %s\n",
+				       ord_data[loop].index,
+				       ord_data[loop].desc);
+		else
+			len += sprintf(buf + len, "[0x%02X] = 0x%08X %s\n",
+				       ord_data[loop].index, val,
+				       ord_data[loop].desc);
+		loop++;
+	}
+
+	return len;
+}
+static DEVICE_ATTR(ordinals, S_IRUGO, show_ordinals, NULL);
+
+
+static ssize_t show_stats(struct device *d, char *buf)
+{
+	struct ipw2100_priv *priv = dev_get_drvdata(d);
+	char * out = buf;
+
+	out += sprintf(out, "interrupts: %d {tx: %d, rx: %d, other: %d}\n",
+		       priv->interrupts, priv->tx_interrupts,
+		       priv->rx_interrupts, priv->inta_other);
+	out += sprintf(out, "firmware resets: %d\n", priv->resets);
+	out += sprintf(out, "firmware hangs: %d\n", priv->hangs);
+#ifdef CONFIG_IPW_DEBUG
+	out += sprintf(out, "packet mismatch image: %s\n",
+		       priv->snapshot[0] ? "YES" : "NO");
+#endif
+
+	return out - buf;
+}
+static DEVICE_ATTR(stats, S_IRUGO, show_stats, NULL);
+
+
+int ipw2100_switch_mode(struct ipw2100_priv *priv, u32 mode)
+{
+	int err;
+
+	if (mode == priv->ieee->iw_mode)
+		return 0;
+
+	err = ipw2100_disable_adapter(priv);
+	if (err) {
+		IPW_DEBUG_ERROR("%s: Could not disable adapter %d\n",
+		       priv->net_dev->name, err);
+		return err;
+	}
+
+	switch (mode) {
+	case IW_MODE_INFRA:
+		priv->net_dev->type = ARPHRD_ETHER;
+		break;
+	case IW_MODE_ADHOC:
+		priv->net_dev->type = ARPHRD_ETHER;
+		break;
+#ifdef CONFIG_IPW2100_MONITOR
+	case IW_MODE_MONITOR:
+		priv->last_mode = priv->ieee->iw_mode;
+		priv->net_dev->type = ARPHRD_IEEE80211;
+		break;
+#endif /* CONFIG_IPW2100_MONITOR */
+	}
+
+	priv->ieee->iw_mode = mode;
+
+#ifdef CONFIG_PM
+        /* Indicate ipw2100_download_firmware download firmware
+	 * from disk instead of memory. */
+	ipw2100_firmware.version = 0;
+#endif
+
+	printk(KERN_INFO "%s: Reseting on mode change.\n",
+		priv->net_dev->name);
+	priv->reset_backoff = 0;
+	schedule_reset(priv);
+
+	return 0;
+}
+
+static ssize_t show_internals(struct device *d, char *buf)
+{
+	struct ipw2100_priv *priv = dev_get_drvdata(d);
+	int len = 0;
+
+#define DUMP_VAR(x,y) len += sprintf(buf + len, # x ": %" # y "\n", priv-> x)
+
+	if (priv->status & STATUS_ASSOCIATED)
+		len += sprintf(buf + len, "connected: %lu\n",
+			       get_seconds() - priv->connect_start);
+	else
+		len += sprintf(buf + len, "not connected\n");
+
+	DUMP_VAR(ieee->crypt[priv->ieee->tx_keyidx], p);
+	DUMP_VAR(status, 08lx);
+	DUMP_VAR(config, 08lx);
+	DUMP_VAR(capability, 08lx);
+
+	len += sprintf(buf + len, "last_rtc: %lu\n", (unsigned long)priv->last_rtc);
+
+	DUMP_VAR(fatal_error, d);
+	DUMP_VAR(stop_hang_check, d);
+	DUMP_VAR(stop_rf_kill, d);
+	DUMP_VAR(messages_sent, d);
+
+	DUMP_VAR(tx_pend_stat.value, d);
+	DUMP_VAR(tx_pend_stat.hi, d);
+
+	DUMP_VAR(tx_free_stat.value, d);
+	DUMP_VAR(tx_free_stat.lo, d);
+
+	DUMP_VAR(msg_free_stat.value, d);
+	DUMP_VAR(msg_free_stat.lo, d);
+
+	DUMP_VAR(msg_pend_stat.value, d);
+	DUMP_VAR(msg_pend_stat.hi, d);
+
+	DUMP_VAR(fw_pend_stat.value, d);
+	DUMP_VAR(fw_pend_stat.hi, d);
+
+	DUMP_VAR(txq_stat.value, d);
+	DUMP_VAR(txq_stat.lo, d);
+
+	DUMP_VAR(ieee->scans, d);
+	DUMP_VAR(reset_backoff, d);
+
+	return len;
+}
+static DEVICE_ATTR(internals, S_IRUGO, show_internals, NULL);
+
+
+static ssize_t show_bssinfo(struct device *d, char *buf)
+{
+	struct ipw2100_priv *priv = dev_get_drvdata(d);
+	char essid[IW_ESSID_MAX_SIZE + 1];
+	u8 bssid[ETH_ALEN];
+	u32 chan = 0;
+	char * out = buf;
+	int length;
+	int ret;
+
+	memset(essid, 0, sizeof(essid));
+	memset(bssid, 0, sizeof(bssid));
+
+	length = IW_ESSID_MAX_SIZE;
+	ret = ipw2100_get_ordinal(priv, IPW_ORD_STAT_ASSN_SSID, essid, &length);
+	if (ret)
+		IPW_DEBUG_INFO("failed querying ordinals at line %d\n",
+			       __LINE__);
+
+	length = sizeof(bssid);
+	ret = ipw2100_get_ordinal(priv, IPW_ORD_STAT_ASSN_AP_BSSID,
+				  bssid, &length);
+	if (ret)
+		IPW_DEBUG_INFO("failed querying ordinals at line %d\n",
+			       __LINE__);
+
+	length = sizeof(u32);
+	ret = ipw2100_get_ordinal(priv, IPW_ORD_OUR_FREQ, &chan, &length);
+	if (ret)
+		IPW_DEBUG_INFO("failed querying ordinals at line %d\n",
+			       __LINE__);
+
+	out += sprintf(out, "ESSID: %s\n", essid);
+	out += sprintf(out, "BSSID:   %02x:%02x:%02x:%02x:%02x:%02x\n",
+		       bssid[0], bssid[1], bssid[2],
+		       bssid[3], bssid[4], bssid[5]);
+	out += sprintf(out, "Channel: %d\n", chan);
+
+	return out - buf;
+}
+static DEVICE_ATTR(bssinfo, S_IRUGO, show_bssinfo, NULL);
+
+
+
+
+#ifdef CONFIG_IPW_DEBUG
+static ssize_t show_debug_level(struct device_driver *d, char *buf)
+{
+	return sprintf(buf, "0x%08X\n", ipw2100_debug_level);
+}
+
+static ssize_t store_debug_level(struct device_driver *d, const char *buf,
+				 size_t count)
+{
+	char *p = (char *)buf;
+	u32 val;
+
+	if (p[1] == 'x' || p[1] == 'X' || p[0] == 'x' || p[0] == 'X') {
+		p++;
+		if (p[0] == 'x' || p[0] == 'X')
+			p++;
+		val = simple_strtoul(p, &p, 16);
+	} else
+		val = simple_strtoul(p, &p, 10);
+	if (p == buf)
+		IPW_DEBUG_INFO(DRV_NAME
+		       ": %s is not in hex or decimal form.\n", buf);
+	else
+		ipw2100_debug_level = val;
+
+	return strnlen(buf, count);
+}
+static DRIVER_ATTR(debug_level, S_IWUSR | S_IRUGO, show_debug_level,
+		   store_debug_level);
+#endif /* CONFIG_IPW_DEBUG */
+
+
+static ssize_t show_fatal_error(struct device *d, char *buf)
+{
+	struct ipw2100_priv *priv = dev_get_drvdata(d);
+	char *out = buf;
+	int i;
+
+	if (priv->fatal_error)
+		out += sprintf(out, "0x%08X\n",
+			       priv->fatal_error);
+	else
+		out += sprintf(out, "0\n");
+
+	for (i = 1; i <= IPW2100_ERROR_QUEUE; i++) {
+		if (!priv->fatal_errors[(priv->fatal_index - i) %
+					IPW2100_ERROR_QUEUE])
+			continue;
+
+		out += sprintf(out, "%d. 0x%08X\n", i,
+			       priv->fatal_errors[(priv->fatal_index - i) %
+						  IPW2100_ERROR_QUEUE]);
+	}
+
+	return out - buf;
+}
+
+static ssize_t store_fatal_error(struct device *d, const char *buf,
+				 size_t count)
+{
+	struct ipw2100_priv *priv = dev_get_drvdata(d);
+	schedule_reset(priv);
+	return count;
+}
+static DEVICE_ATTR(fatal_error, S_IWUSR|S_IRUGO, show_fatal_error, store_fatal_error);
+
+
+static ssize_t show_scan_age(struct device *d, char *buf)
+{
+	struct ipw2100_priv *priv = dev_get_drvdata(d);
+	return sprintf(buf, "%d\n", priv->ieee->scan_age);
+}
+
+static ssize_t store_scan_age(struct device *d, const char *buf, size_t count)
+{
+	struct ipw2100_priv *priv = dev_get_drvdata(d);
+	struct net_device *dev = priv->net_dev;
+	char buffer[] = "00000000";
+	unsigned long len =
+	    (sizeof(buffer) - 1) > count ? count : sizeof(buffer) - 1;
+	unsigned long val;
+	char *p = buffer;
+
+	IPW_DEBUG_INFO("enter\n");
+
+	strncpy(buffer, buf, len);
+	buffer[len] = 0;
+
+	if (p[1] == 'x' || p[1] == 'X' || p[0] == 'x' || p[0] == 'X') {
+		p++;
+		if (p[0] == 'x' || p[0] == 'X')
+			p++;
+		val = simple_strtoul(p, &p, 16);
+	} else
+		val = simple_strtoul(p, &p, 10);
+	if (p == buffer) {
+		IPW_DEBUG_INFO("%s: user supplied invalid value.\n",
+		       dev->name);
+	} else {
+		priv->ieee->scan_age = val;
+		IPW_DEBUG_INFO("set scan_age = %u\n", priv->ieee->scan_age);
+	}
+
+	IPW_DEBUG_INFO("exit\n");
+	return len;
+}
+static DEVICE_ATTR(scan_age, S_IWUSR | S_IRUGO, show_scan_age, store_scan_age);
+
+
+static ssize_t show_rf_kill(struct device *d, char *buf)
+{
+	/* 0 - RF kill not enabled
+	   1 - SW based RF kill active (sysfs)
+	   2 - HW based RF kill active
+	   3 - Both HW and SW baed RF kill active */
+	struct ipw2100_priv *priv = (struct ipw2100_priv *)d->driver_data;
+	int val = ((priv->status & STATUS_RF_KILL_SW) ? 0x1 : 0x0) |
+		(rf_kill_active(priv) ? 0x2 : 0x0);
+	return sprintf(buf, "%i\n", val);
+}
+
+static int ipw_radio_kill_sw(struct ipw2100_priv *priv, int disable_radio)
+{
+	if ((disable_radio ? 1 : 0) ==
+	    (priv->status & STATUS_RF_KILL_SW ? 1 : 0))
+		return 0 ;
+
+	IPW_DEBUG_RF_KILL("Manual SW RF Kill set to: RADIO  %s\n",
+			  disable_radio ? "OFF" : "ON");
+
+	down(&priv->action_sem);
+
+	if (disable_radio) {
+		priv->status |= STATUS_RF_KILL_SW;
+		ipw2100_down(priv);
+	} else {
+		priv->status &= ~STATUS_RF_KILL_SW;
+		if (rf_kill_active(priv)) {
+			IPW_DEBUG_RF_KILL("Can not turn radio back on - "
+					  "disabled by HW switch\n");
+			/* Make sure the RF_KILL check timer is running */
+			priv->stop_rf_kill = 0;
+			cancel_delayed_work(&priv->rf_kill);
+			queue_delayed_work(priv->workqueue, &priv->rf_kill,
+					   HZ);
+		} else
+			schedule_reset(priv);
+	}
+
+	up(&priv->action_sem);
+	return 1;
+}
+
+static ssize_t store_rf_kill(struct device *d, const char *buf, size_t count)
+{
+	struct ipw2100_priv *priv = dev_get_drvdata(d);
+	ipw_radio_kill_sw(priv, buf[0] == '1');
+	return count;
+}
+static DEVICE_ATTR(rf_kill, S_IWUSR|S_IRUGO, show_rf_kill, store_rf_kill);
+
+
+static struct attribute *ipw2100_sysfs_entries[] = {
+	&dev_attr_hardware.attr,
+	&dev_attr_registers.attr,
+	&dev_attr_ordinals.attr,
+	&dev_attr_pci.attr,
+	&dev_attr_stats.attr,
+	&dev_attr_internals.attr,
+	&dev_attr_bssinfo.attr,
+	&dev_attr_memory.attr,
+	&dev_attr_scan_age.attr,
+	&dev_attr_fatal_error.attr,
+	&dev_attr_rf_kill.attr,
+	&dev_attr_cfg.attr,
+	&dev_attr_status.attr,
+	&dev_attr_capability.attr,
+	NULL,
+};
+
+static struct attribute_group ipw2100_attribute_group = {
+	.attrs = ipw2100_sysfs_entries,
+};
+
+
+static int status_queue_allocate(struct ipw2100_priv *priv, int entries)
+{
+	struct ipw2100_status_queue *q = &priv->status_queue;
+
+	IPW_DEBUG_INFO("enter\n");
+
+	q->size = entries * sizeof(struct ipw2100_status);
+	q->drv = (struct ipw2100_status *)pci_alloc_consistent(
+		priv->pci_dev, q->size, &q->nic);
+	if (!q->drv) {
+		IPW_DEBUG_WARNING(
+		       "Can not allocate status queue.\n");
+		return -ENOMEM;
+	}
+
+	memset(q->drv, 0, q->size);
+
+	IPW_DEBUG_INFO("exit\n");
+
+	return 0;
+}
+
+static void status_queue_free(struct ipw2100_priv *priv)
+{
+	IPW_DEBUG_INFO("enter\n");
+
+	if (priv->status_queue.drv) {
+		pci_free_consistent(
+			priv->pci_dev, priv->status_queue.size,
+			priv->status_queue.drv, priv->status_queue.nic);
+		priv->status_queue.drv = NULL;
+	}
+
+	IPW_DEBUG_INFO("exit\n");
+}
+
+static int bd_queue_allocate(struct ipw2100_priv *priv,
+			     struct ipw2100_bd_queue *q, int entries)
+{
+	IPW_DEBUG_INFO("enter\n");
+
+	memset(q, 0, sizeof(struct ipw2100_bd_queue));
+
+	q->entries = entries;
+	q->size = entries * sizeof(struct ipw2100_bd);
+	q->drv = pci_alloc_consistent(priv->pci_dev, q->size, &q->nic);
+	if (!q->drv) {
+		IPW_DEBUG_INFO("can't allocate shared memory for buffer descriptors\n");
+		return -ENOMEM;
+	}
+	memset(q->drv, 0, q->size);
+
+	IPW_DEBUG_INFO("exit\n");
+
+	return 0;
+}
+
+static void bd_queue_free(struct ipw2100_priv *priv,
+			  struct ipw2100_bd_queue *q)
+{
+	IPW_DEBUG_INFO("enter\n");
+
+	if (!q)
+		return;
+
+	if (q->drv) {
+		pci_free_consistent(priv->pci_dev,
+				    q->size, q->drv, q->nic);
+		q->drv = NULL;
+	}
+
+	IPW_DEBUG_INFO("exit\n");
+}
+
+static void bd_queue_initialize(
+	struct ipw2100_priv *priv, struct ipw2100_bd_queue * q,
+	u32 base, u32 size, u32 r, u32 w)
+{
+	IPW_DEBUG_INFO("enter\n");
+
+	IPW_DEBUG_INFO("initializing bd queue at virt=%p, phys=%08x\n", q->drv, q->nic);
+
+	write_register(priv->net_dev, base, q->nic);
+	write_register(priv->net_dev, size, q->entries);
+	write_register(priv->net_dev, r, q->oldest);
+	write_register(priv->net_dev, w, q->next);
+
+	IPW_DEBUG_INFO("exit\n");
+}
+
+static void ipw2100_kill_workqueue(struct ipw2100_priv *priv)
+{
+	if (priv->workqueue) {
+		priv->stop_rf_kill = 1;
+		priv->stop_hang_check = 1;
+		cancel_delayed_work(&priv->reset_work);
+		cancel_delayed_work(&priv->security_work);
+		cancel_delayed_work(&priv->wx_event_work);
+		cancel_delayed_work(&priv->hang_check);
+		cancel_delayed_work(&priv->rf_kill);
+		destroy_workqueue(priv->workqueue);
+		priv->workqueue = NULL;
+	}
+}
+
+static int ipw2100_tx_allocate(struct ipw2100_priv *priv)
+{
+	int i, j, err = -EINVAL;
+	void *v;
+	dma_addr_t p;
+
+	IPW_DEBUG_INFO("enter\n");
+
+	err = bd_queue_allocate(priv, &priv->tx_queue, TX_QUEUE_LENGTH);
+	if (err) {
+		IPW_DEBUG_ERROR("%s: failed bd_queue_allocate\n",
+		       priv->net_dev->name);
+		return err;
+	}
+
+	priv->tx_buffers = (struct ipw2100_tx_packet *)kmalloc(
+		TX_PENDED_QUEUE_LENGTH * sizeof(struct ipw2100_tx_packet),
+		GFP_ATOMIC);
+	if (!priv->tx_buffers) {
+		IPW_DEBUG_ERROR("%s: alloc failed form tx buffers.\n",
+		       priv->net_dev->name);
+		bd_queue_free(priv, &priv->tx_queue);
+		return -ENOMEM;
+	}
+
+	for (i = 0; i < TX_PENDED_QUEUE_LENGTH; i++) {
+		v = pci_alloc_consistent(
+			priv->pci_dev, sizeof(struct ipw2100_data_header), &p);
+		if (!v) {
+			IPW_DEBUG_ERROR("%s: PCI alloc failed for tx "
+			       "buffers.\n", priv->net_dev->name);
+			err = -ENOMEM;
+			break;
+		}
+
+		priv->tx_buffers[i].type = DATA;
+		priv->tx_buffers[i].info.d_struct.data = (struct ipw2100_data_header*)v;
+		priv->tx_buffers[i].info.d_struct.data_phys = p;
+		priv->tx_buffers[i].info.d_struct.txb = NULL;
+	}
+
+	if (i == TX_PENDED_QUEUE_LENGTH)
+		return 0;
+
+	for (j = 0; j < i; j++) {
+		pci_free_consistent(
+			priv->pci_dev,
+			sizeof(struct ipw2100_data_header),
+			priv->tx_buffers[j].info.d_struct.data,
+			priv->tx_buffers[j].info.d_struct.data_phys);
+	}
+
+	kfree(priv->tx_buffers);
+	priv->tx_buffers = NULL;
+
+	return err;
+}
+
+static void ipw2100_tx_initialize(struct ipw2100_priv *priv)
+{
+	int i;
+
+	IPW_DEBUG_INFO("enter\n");
+
+	/*
+	 * reinitialize packet info lists
+	 */
+	INIT_LIST_HEAD(&priv->fw_pend_list);
+	INIT_STAT(&priv->fw_pend_stat);
+
+	/*
+	 * reinitialize lists
+	 */
+	INIT_LIST_HEAD(&priv->tx_pend_list);
+	INIT_LIST_HEAD(&priv->tx_free_list);
+	INIT_STAT(&priv->tx_pend_stat);
+	INIT_STAT(&priv->tx_free_stat);
+
+	for (i = 0; i < TX_PENDED_QUEUE_LENGTH; i++) {
+		/* We simply drop any SKBs that have been queued for
+		 * transmit */
+		if (priv->tx_buffers[i].info.d_struct.txb) {
+			ieee80211_txb_free(priv->tx_buffers[i].info.d_struct.txb);
+			priv->tx_buffers[i].info.d_struct.txb = NULL;
+		}
+
+		list_add_tail(&priv->tx_buffers[i].list, &priv->tx_free_list);
+	}
+
+	SET_STAT(&priv->tx_free_stat, i);
+
+	priv->tx_queue.oldest = 0;
+	priv->tx_queue.available = priv->tx_queue.entries;
+	priv->tx_queue.next = 0;
+	INIT_STAT(&priv->txq_stat);
+	SET_STAT(&priv->txq_stat, priv->tx_queue.available);
+
+	bd_queue_initialize(priv, &priv->tx_queue,
+			    IPW_MEM_HOST_SHARED_TX_QUEUE_BD_BASE,
+			    IPW_MEM_HOST_SHARED_TX_QUEUE_BD_SIZE,
+			    IPW_MEM_HOST_SHARED_TX_QUEUE_READ_INDEX,
+			    IPW_MEM_HOST_SHARED_TX_QUEUE_WRITE_INDEX);
+
+	IPW_DEBUG_INFO("exit\n");
+
+}
+
+static void ipw2100_tx_free(struct ipw2100_priv *priv)
+{
+	int i;
+
+	IPW_DEBUG_INFO("enter\n");
+
+	bd_queue_free(priv, &priv->tx_queue);
+
+	if (!priv->tx_buffers)
+		return;
+
+	for (i = 0; i < TX_PENDED_QUEUE_LENGTH; i++) {
+		if (priv->tx_buffers[i].info.d_struct.txb) {
+			ieee80211_txb_free(priv->tx_buffers[i].info.d_struct.txb);
+			priv->tx_buffers[i].info.d_struct.txb = NULL;
+		}
+		if (priv->tx_buffers[i].info.d_struct.data)
+			pci_free_consistent(
+				priv->pci_dev,
+				sizeof(struct ipw2100_data_header),
+				priv->tx_buffers[i].info.d_struct.data,
+				priv->tx_buffers[i].info.d_struct.data_phys);
+	}
+
+	kfree(priv->tx_buffers);
+	priv->tx_buffers = NULL;
+
+	IPW_DEBUG_INFO("exit\n");
+}
+
+
+
+static int ipw2100_rx_allocate(struct ipw2100_priv *priv)
+{
+	int i, j, err = -EINVAL;
+
+	IPW_DEBUG_INFO("enter\n");
+
+	err = bd_queue_allocate(priv, &priv->rx_queue, RX_QUEUE_LENGTH);
+	if (err) {
+		IPW_DEBUG_INFO("failed bd_queue_allocate\n");
+		return err;
+	}
+
+	err = status_queue_allocate(priv, RX_QUEUE_LENGTH);
+	if (err) {
+		IPW_DEBUG_INFO("failed status_queue_allocate\n");
+		bd_queue_free(priv, &priv->rx_queue);
+		return err;
+	}
+
+	/*
+	 * allocate packets
+	 */
+	priv->rx_buffers = (struct ipw2100_rx_packet *)
+	    kmalloc(RX_QUEUE_LENGTH * sizeof(struct ipw2100_rx_packet),
+		    GFP_KERNEL);
+	if (!priv->rx_buffers) {
+		IPW_DEBUG_INFO("can't allocate rx packet buffer table\n");
+
+		bd_queue_free(priv, &priv->rx_queue);
+
+		status_queue_free(priv);
+
+		return -ENOMEM;
+	}
+
+	for (i = 0; i < RX_QUEUE_LENGTH; i++) {
+		struct ipw2100_rx_packet *packet = &priv->rx_buffers[i];
+
+		err = ipw2100_alloc_skb(priv, packet);
+		if (unlikely(err)) {
+			err = -ENOMEM;
+			break;
+		}
+
+		/* The BD holds the cache aligned address */
+		priv->rx_queue.drv[i].host_addr = packet->dma_addr;
+		priv->rx_queue.drv[i].buf_length = IPW_RX_NIC_BUFFER_LENGTH;
+		priv->status_queue.drv[i].status_fields = 0;
+	}
+
+	if (i == RX_QUEUE_LENGTH)
+		return 0;
+
+	for (j = 0; j < i; j++) {
+		pci_unmap_single(priv->pci_dev, priv->rx_buffers[j].dma_addr,
+				 sizeof(struct ipw2100_rx_packet),
+				 PCI_DMA_FROMDEVICE);
+		dev_kfree_skb(priv->rx_buffers[j].skb);
+	}
+
+	kfree(priv->rx_buffers);
+	priv->rx_buffers = NULL;
+
+	bd_queue_free(priv, &priv->rx_queue);
+
+	status_queue_free(priv);
+
+	return err;
+}
+
+static void ipw2100_rx_initialize(struct ipw2100_priv *priv)
+{
+	IPW_DEBUG_INFO("enter\n");
+
+	priv->rx_queue.oldest = 0;
+	priv->rx_queue.available = priv->rx_queue.entries - 1;
+	priv->rx_queue.next = priv->rx_queue.entries - 1;
+
+	INIT_STAT(&priv->rxq_stat);
+	SET_STAT(&priv->rxq_stat, priv->rx_queue.available);
+
+	bd_queue_initialize(priv, &priv->rx_queue,
+			    IPW_MEM_HOST_SHARED_RX_BD_BASE,
+			    IPW_MEM_HOST_SHARED_RX_BD_SIZE,
+			    IPW_MEM_HOST_SHARED_RX_READ_INDEX,
+			    IPW_MEM_HOST_SHARED_RX_WRITE_INDEX);
+
+	/* set up the status queue */
+	write_register(priv->net_dev, IPW_MEM_HOST_SHARED_RX_STATUS_BASE,
+		       priv->status_queue.nic);
+
+	IPW_DEBUG_INFO("exit\n");
+}
+
+static void ipw2100_rx_free(struct ipw2100_priv *priv)
+{
+	int i;
+
+	IPW_DEBUG_INFO("enter\n");
+
+	bd_queue_free(priv, &priv->rx_queue);
+	status_queue_free(priv);
+
+	if (!priv->rx_buffers)
+		return;
+
+	for (i = 0; i < RX_QUEUE_LENGTH; i++) {
+		if (priv->rx_buffers[i].rxp) {
+			pci_unmap_single(priv->pci_dev,
+					 priv->rx_buffers[i].dma_addr,
+					 sizeof(struct ipw2100_rx),
+					 PCI_DMA_FROMDEVICE);
+			dev_kfree_skb(priv->rx_buffers[i].skb);
+		}
+	}
+
+	kfree(priv->rx_buffers);
+	priv->rx_buffers = NULL;
+
+	IPW_DEBUG_INFO("exit\n");
+}
+
+static int ipw2100_read_mac_address(struct ipw2100_priv *priv)
+{
+	u32 length = ETH_ALEN;
+	u8 mac[ETH_ALEN];
+
+	int err;
+
+	err = ipw2100_get_ordinal(priv, IPW_ORD_STAT_ADAPTER_MAC,
+				  mac, &length);
+	if (err) {
+		IPW_DEBUG_INFO("MAC address read failed\n");
+		return -EIO;
+	}
+	IPW_DEBUG_INFO("card MAC is %02X:%02X:%02X:%02X:%02X:%02X\n",
+	       mac[0], mac[1], mac[2], mac[3], mac[4], mac[5]);
+
+	memcpy(priv->net_dev->dev_addr, mac, ETH_ALEN);
+
+	return 0;
+}
+
+/********************************************************************
+ *
+ * Firmware Commands
+ *
+ ********************************************************************/
+
+int ipw2100_set_mac_address(struct ipw2100_priv *priv, int batch_mode)
+{
+	struct host_command cmd = {
+		.host_command = ADAPTER_ADDRESS,
+		.host_command_sequence = 0,
+		.host_command_length = ETH_ALEN
+	};
+	int err;
+
+	IPW_DEBUG_HC("SET_MAC_ADDRESS\n");
+
+	IPW_DEBUG_INFO("enter\n");
+
+	if (priv->config & CFG_CUSTOM_MAC) {
+		memcpy(cmd.host_command_parameters, priv->mac_addr,
+		       ETH_ALEN);
+		memcpy(priv->net_dev->dev_addr, priv->mac_addr, ETH_ALEN);
+	} else
+		memcpy(cmd.host_command_parameters, priv->net_dev->dev_addr,
+		       ETH_ALEN);
+
+	err = ipw2100_hw_send_command(priv, &cmd);
+
+	IPW_DEBUG_INFO("exit\n");
+	return err;
+}
+
+int ipw2100_set_port_type(struct ipw2100_priv *priv, u32 port_type,
+				 int batch_mode)
+{
+	struct host_command cmd = {
+		.host_command = PORT_TYPE,
+		.host_command_sequence = 0,
+		.host_command_length = sizeof(u32)
+	};
+	int err;
+
+	switch (port_type) {
+	case IW_MODE_INFRA:
+		cmd.host_command_parameters[0] = IPW_BSS;
+		break;
+	case IW_MODE_ADHOC:
+		cmd.host_command_parameters[0] = IPW_IBSS;
+		break;
+	}
+
+	IPW_DEBUG_HC("PORT_TYPE: %s\n",
+		     port_type == IPW_IBSS ? "Ad-Hoc" : "Managed");
+
+	if (!batch_mode) {
+		err = ipw2100_disable_adapter(priv);
+		if (err) {
+			IPW_DEBUG_ERROR("%s: Could not disable adapter %d\n",
+			       priv->net_dev->name, err);
+			return err;
+		}
+	}
+
+	/* send cmd to firmware */
+	err = ipw2100_hw_send_command(priv, &cmd);
+
+	if (!batch_mode)
+		ipw2100_enable_adapter(priv);
+
+	return err;
+}
+
+
+int ipw2100_set_channel(struct ipw2100_priv *priv, u32 channel, int batch_mode)
+{
+	struct host_command cmd = {
+		.host_command = CHANNEL,
+		.host_command_sequence = 0,
+		.host_command_length = sizeof(u32)
+	};
+	int err;
+
+	cmd.host_command_parameters[0] = channel;
+
+	IPW_DEBUG_HC("CHANNEL: %d\n", channel);
+
+	/* If BSS then we don't support channel selection */
+	if (priv->ieee->iw_mode == IW_MODE_INFRA)
+		return 0;
+
+	if ((channel != 0) &&
+	    ((channel < REG_MIN_CHANNEL) || (channel > REG_MAX_CHANNEL)))
+		return -EINVAL;
+
+	if (!batch_mode) {
+		err = ipw2100_disable_adapter(priv);
+		if (err)
+			return err;
+	}
+
+	err = ipw2100_hw_send_command(priv, &cmd);
+	if (err) {
+		IPW_DEBUG_INFO("Failed to set channel to %d",
+			       channel);
+		return err;
+	}
+
+	if (channel)
+		priv->config |= CFG_STATIC_CHANNEL;
+	else
+		priv->config &= ~CFG_STATIC_CHANNEL;
+
+	priv->channel = channel;
+
+	if (!batch_mode) {
+		err = ipw2100_enable_adapter(priv);
+		if (err)
+			return err;
+	}
+
+	return 0;
+}
+
+int ipw2100_system_config(struct ipw2100_priv *priv, int batch_mode)
+{
+	struct host_command cmd = {
+		.host_command = SYSTEM_CONFIG,
+		.host_command_sequence = 0,
+		.host_command_length = 12,
+	};
+	u32 ibss_mask, len = sizeof(u32);
+	int err;
+
+	/* Set system configuration */
+
+	if (!batch_mode) {
+		err = ipw2100_disable_adapter(priv);
+		if (err)
+			return err;
+	}
+
+	if (priv->ieee->iw_mode == IW_MODE_ADHOC)
+		cmd.host_command_parameters[0] |= IPW_CFG_IBSS_AUTO_START;
+
+	cmd.host_command_parameters[0] |= IPW_CFG_IBSS_MASK |
+		IPW_CFG_BSS_MASK |
+		IPW_CFG_802_1x_ENABLE;
+
+	if (!(priv->config & CFG_LONG_PREAMBLE))
+		cmd.host_command_parameters[0] |= IPW_CFG_PREAMBLE_AUTO;
+
+	err = ipw2100_get_ordinal(priv,
+				  IPW_ORD_EEPROM_IBSS_11B_CHANNELS,
+				  &ibss_mask,  &len);
+	if (err)
+		ibss_mask = IPW_IBSS_11B_DEFAULT_MASK;
+
+	cmd.host_command_parameters[1] = REG_CHANNEL_MASK;
+	cmd.host_command_parameters[2] = REG_CHANNEL_MASK & ibss_mask;
+
+	/* 11b only */
+	/*cmd.host_command_parameters[0] |= DIVERSITY_ANTENNA_A;*/
+
+	err = ipw2100_hw_send_command(priv, &cmd);
+	if (err)
+		return err;
+
+/* If IPv6 is configured in the kernel then we don't want to filter out all
+ * of the multicast packets as IPv6 needs some. */
+#if !defined(CONFIG_IPV6) && !defined(CONFIG_IPV6_MODULE)
+	cmd.host_command = ADD_MULTICAST;
+	cmd.host_command_sequence = 0;
+	cmd.host_command_length = 0;
+
+	ipw2100_hw_send_command(priv, &cmd);
+#endif
+	if (!batch_mode) {
+		err = ipw2100_enable_adapter(priv);
+		if (err)
+			return err;
+	}
+
+	return 0;
+}
+
+int ipw2100_set_tx_rates(struct ipw2100_priv *priv, u32 rate, int batch_mode)
+{
+	struct host_command cmd = {
+		.host_command = BASIC_TX_RATES,
+		.host_command_sequence = 0,
+		.host_command_length = 4
+	};
+	int err;
+
+	cmd.host_command_parameters[0] = rate & TX_RATE_MASK;
+
+	if (!batch_mode) {
+		err = ipw2100_disable_adapter(priv);
+		if (err)
+			return err;
+	}
+
+	/* Set BASIC TX Rate first */
+	ipw2100_hw_send_command(priv, &cmd);
+
+	/* Set TX Rate */
+	cmd.host_command = TX_RATES;
+	ipw2100_hw_send_command(priv, &cmd);
+
+	/* Set MSDU TX Rate */
+	cmd.host_command = MSDU_TX_RATES;
+	ipw2100_hw_send_command(priv, &cmd);
+
+	if (!batch_mode) {
+		err = ipw2100_enable_adapter(priv);
+		if (err)
+			return err;
+	}
+
+	priv->tx_rates = rate;
+
+	return 0;
+}
+
+int ipw2100_set_power_mode(struct ipw2100_priv *priv,
+			   int power_level)
+{
+	struct host_command cmd = {
+		.host_command = POWER_MODE,
+		.host_command_sequence = 0,
+		.host_command_length = 4
+	};
+	int err;
+
+	cmd.host_command_parameters[0] = power_level;
+
+	err = ipw2100_hw_send_command(priv, &cmd);
+	if (err)
+		return err;
+
+	if (power_level == IPW_POWER_MODE_CAM)
+		priv->power_mode = IPW_POWER_LEVEL(priv->power_mode);
+	else
+		priv->power_mode = IPW_POWER_ENABLED | power_level;
+
+#ifdef CONFIG_IPW2100_TX_POWER
+	if (priv->port_type == IBSS &&
+	    priv->adhoc_power != DFTL_IBSS_TX_POWER) {
+		/* Set beacon interval */
+		cmd.host_command = TX_POWER_INDEX;
+		cmd.host_command_parameters[0] = (u32)priv->adhoc_power;
+
+		err = ipw2100_hw_send_command(priv, &cmd);
+		if (err)
+			return err;
+	}
+#endif
+
+	return 0;
+}
+
+
+int ipw2100_set_rts_threshold(struct ipw2100_priv *priv, u32 threshold)
+{
+	struct host_command cmd = {
+		.host_command = RTS_THRESHOLD,
+		.host_command_sequence = 0,
+		.host_command_length = 4
+	};
+	int err;
+
+	if (threshold & RTS_DISABLED)
+		cmd.host_command_parameters[0] = MAX_RTS_THRESHOLD;
+	else
+		cmd.host_command_parameters[0] = threshold & ~RTS_DISABLED;
+
+	err = ipw2100_hw_send_command(priv, &cmd);
+	if (err)
+		return err;
+
+	priv->rts_threshold = threshold;
+
+	return 0;
+}
+
+#if 0
+int ipw2100_set_fragmentation_threshold(struct ipw2100_priv *priv,
+					u32 threshold, int batch_mode)
+{
+	struct host_command cmd = {
+		.host_command = FRAG_THRESHOLD,
+		.host_command_sequence = 0,
+		.host_command_length = 4,
+		.host_command_parameters[0] = 0,
+	};
+	int err;
+
+	if (!batch_mode) {
+		err = ipw2100_disable_adapter(priv);
+		if (err)
+			return err;
+	}
+
+	if (threshold == 0)
+		threshold = DEFAULT_FRAG_THRESHOLD;
+	else {
+		threshold = max(threshold, MIN_FRAG_THRESHOLD);
+		threshold = min(threshold, MAX_FRAG_THRESHOLD);
+	}
+
+	cmd.host_command_parameters[0] = threshold;
+
+	IPW_DEBUG_HC("FRAG_THRESHOLD: %u\n", threshold);
+
+	err = ipw2100_hw_send_command(priv, &cmd);
+
+	if (!batch_mode)
+		ipw2100_enable_adapter(priv);
+
+	if (!err)
+		priv->frag_threshold = threshold;
+
+	return err;
+}
+#endif
+
+int ipw2100_set_short_retry(struct ipw2100_priv *priv, u32 retry)
+{
+	struct host_command cmd = {
+		.host_command = SHORT_RETRY_LIMIT,
+		.host_command_sequence = 0,
+		.host_command_length = 4
+	};
+	int err;
+
+	cmd.host_command_parameters[0] = retry;
+
+	err = ipw2100_hw_send_command(priv, &cmd);
+	if (err)
+		return err;
+
+	priv->short_retry_limit = retry;
+
+	return 0;
+}
+
+int ipw2100_set_long_retry(struct ipw2100_priv *priv, u32 retry)
+{
+	struct host_command cmd = {
+		.host_command = LONG_RETRY_LIMIT,
+		.host_command_sequence = 0,
+		.host_command_length = 4
+	};
+	int err;
+
+	cmd.host_command_parameters[0] = retry;
+
+	err = ipw2100_hw_send_command(priv, &cmd);
+	if (err)
+		return err;
+
+	priv->long_retry_limit = retry;
+
+	return 0;
+}
+
+
+int ipw2100_set_mandatory_bssid(struct ipw2100_priv *priv, u8 *bssid,
+				int batch_mode)
+{
+	struct host_command cmd = {
+		.host_command = MANDATORY_BSSID,
+		.host_command_sequence = 0,
+		.host_command_length = (bssid == NULL) ? 0 : ETH_ALEN
+	};
+	int err;
+
+#ifdef CONFIG_IPW_DEBUG
+	if (bssid != NULL)
+		IPW_DEBUG_HC(
+			"MANDATORY_BSSID: %02X:%02X:%02X:%02X:%02X:%02X\n",
+			bssid[0], bssid[1], bssid[2], bssid[3], bssid[4],
+			bssid[5]);
+	else
+		IPW_DEBUG_HC("MANDATORY_BSSID: <clear>\n");
+#endif
+	/* if BSSID is empty then we disable mandatory bssid mode */
+	if (bssid != NULL)
+		memcpy((u8 *)cmd.host_command_parameters, bssid, ETH_ALEN);
+
+	if (!batch_mode) {
+		err = ipw2100_disable_adapter(priv);
+		if (err)
+			return err;
+	}
+
+	err = ipw2100_hw_send_command(priv, &cmd);
+
+	if (!batch_mode)
+		ipw2100_enable_adapter(priv);
+
+	return err;
+}
+
+#ifdef CONFIG_IEEE80211_WPA
+static int ipw2100_disassociate_bssid(struct ipw2100_priv *priv)
+{
+	struct host_command cmd = {
+		.host_command = DISASSOCIATION_BSSID,
+		.host_command_sequence = 0,
+		.host_command_length = ETH_ALEN
+	};
+	int err;
+	int len;
+
+	IPW_DEBUG_HC("DISASSOCIATION_BSSID\n");
+
+	len = ETH_ALEN;
+	/* The Firmware currently ignores the BSSID and just disassociates from
+	 * the currently associated AP -- but in the off chance that a future
+	 * firmware does use the BSSID provided here, we go ahead and try and
+	 * set it to the currently associated AP's BSSID */
+	memcpy(cmd.host_command_parameters, priv->bssid, ETH_ALEN);
+
+	err = ipw2100_hw_send_command(priv, &cmd);
+
+	return err;
+}
+#endif
+
+/*
+ * Pseudo code for setting up wpa_frame:
+ */
+#if 0
+void x(struct ieee80211_assoc_frame *wpa_assoc)
+{
+	struct ipw2100_wpa_assoc_frame frame;
+	frame->fixed_ie_mask = IPW_WPA_CAPABILTIES |
+		IPW_WPA_LISTENINTERVAL |
+		IPW_WPA_AP_ADDRESS;
+	frame->capab_info = wpa_assoc->capab_info;
+	frame->lisen_interval = wpa_assoc->listent_interval;
+	memcpy(frame->current_ap, wpa_assoc->current_ap, ETH_ALEN);
+
+	/* UNKNOWN -- I'm not postivive about this part; don't have any WPA
+	 * setup here to test it with.
+	 *
+	 * Walk the IEs in the wpa_assoc and figure out the total size of all
+	 * that data.  Stick that into frame->var_ie_len.  Then memcpy() all of
+	 * the IEs from wpa_frame into frame.
+	 */
+	frame->var_ie_len = calculate_ie_len(wpa_assoc);
+	memcpy(frame->var_ie,  wpa_assoc->variable, frame->var_ie_len);
+
+	ipw2100_set_wpa_ie(priv, &frame, 0);
+}
+#endif
+
+
+
+
+static int ipw2100_set_wpa_ie(struct ipw2100_priv *,
+			      struct ipw2100_wpa_assoc_frame *, int)
+__attribute__ ((unused));
+
+static int ipw2100_set_wpa_ie(struct ipw2100_priv *priv,
+			      struct ipw2100_wpa_assoc_frame *wpa_frame,
+			      int batch_mode)
+{
+	struct host_command cmd = {
+		.host_command = SET_WPA_IE,
+		.host_command_sequence = 0,
+		.host_command_length = sizeof(struct ipw2100_wpa_assoc_frame),
+	};
+	int err;
+
+	IPW_DEBUG_HC("SET_WPA_IE\n");
+
+	if (!batch_mode) {
+		err = ipw2100_disable_adapter(priv);
+		if (err)
+			return err;
+	}
+
+	memcpy(cmd.host_command_parameters, wpa_frame,
+	       sizeof(struct ipw2100_wpa_assoc_frame));
+
+	err = ipw2100_hw_send_command(priv, &cmd);
+
+	if (!batch_mode) {
+		if (ipw2100_enable_adapter(priv))
+			err = -EIO;
+	}
+
+	return err;
+}
+
+struct security_info_params {
+	u32 allowed_ciphers;
+	u16 version;
+	u8 auth_mode;
+	u8 replay_counters_number;
+	u8 unicast_using_group;
+} __attribute__ ((packed));
+
+int ipw2100_set_security_information(struct ipw2100_priv *priv,
+				     int auth_mode,
+				     int security_level,
+				     int unicast_using_group,
+				     int batch_mode)
+{
+	struct host_command cmd = {
+		.host_command = SET_SECURITY_INFORMATION,
+		.host_command_sequence = 0,
+		.host_command_length = sizeof(struct security_info_params)
+	};
+	struct security_info_params *security =
+		(struct security_info_params *)&cmd.host_command_parameters;
+	int err;
+	memset(security, 0, sizeof(*security));
+
+	/* If shared key AP authentication is turned on, then we need to
+	 * configure the firmware to try and use it.
+	 *
+	 * Actual data encryption/decryption is handled by the host. */
+	security->auth_mode = auth_mode;
+	security->unicast_using_group = unicast_using_group;
+
+	switch (security_level) {
+	default:
+	case SEC_LEVEL_0:
+		security->allowed_ciphers = IPW_NONE_CIPHER;
+		break;
+	case SEC_LEVEL_1:
+		security->allowed_ciphers = IPW_WEP40_CIPHER |
+			IPW_WEP104_CIPHER;
+		break;
+	case SEC_LEVEL_2:
+		security->allowed_ciphers = IPW_WEP40_CIPHER |
+			IPW_WEP104_CIPHER | IPW_TKIP_CIPHER;
+		break;
+	case SEC_LEVEL_2_CKIP:
+		security->allowed_ciphers = IPW_WEP40_CIPHER |
+			IPW_WEP104_CIPHER | IPW_CKIP_CIPHER;
+		break;
+	case SEC_LEVEL_3:
+		security->allowed_ciphers = IPW_WEP40_CIPHER |
+			IPW_WEP104_CIPHER | IPW_TKIP_CIPHER | IPW_CCMP_CIPHER;
+		break;
+	}
+
+	IPW_DEBUG_HC(
+		"SET_SECURITY_INFORMATION: auth:%d cipher:0x%02X (level %d)\n",
+		security->auth_mode, security->allowed_ciphers, security_level);
+
+	security->replay_counters_number = 0;
+
+	if (!batch_mode) {
+		err = ipw2100_disable_adapter(priv);
+		if (err)
+			return err;
+	}
+
+	err = ipw2100_hw_send_command(priv, &cmd);
+
+	if (!batch_mode)
+		ipw2100_enable_adapter(priv);
+
+	return err;
+}
+
+int ipw2100_set_tx_power(struct ipw2100_priv *priv,
+			 u32 tx_power)
+{
+	struct host_command cmd = {
+		.host_command = TX_POWER_INDEX,
+		.host_command_sequence = 0,
+		.host_command_length = 4
+	};
+	int err = 0;
+
+	cmd.host_command_parameters[0] = tx_power;
+
+	if (priv->ieee->iw_mode == IW_MODE_ADHOC)
+		err = ipw2100_hw_send_command(priv, &cmd);
+	if (!err)
+		priv->tx_power = tx_power;
+
+	return 0;
+}
+
+int ipw2100_set_ibss_beacon_interval(struct ipw2100_priv *priv,
+				     u32 interval, int batch_mode)
+{
+	struct host_command cmd = {
+		.host_command = BEACON_INTERVAL,
+		.host_command_sequence = 0,
+		.host_command_length = 4
+	};
+	int err;
+
+	cmd.host_command_parameters[0] = interval;
+
+	IPW_DEBUG_INFO("enter\n");
+
+	if (priv->ieee->iw_mode == IW_MODE_ADHOC) {
+		if (!batch_mode) {
+			err = ipw2100_disable_adapter(priv);
+			if (err)
+				return err;
+		}
+
+		ipw2100_hw_send_command(priv, &cmd);
+
+		if (!batch_mode) {
+			err = ipw2100_enable_adapter(priv);
+			if (err)
+				return err;
+		}
+	}
+
+	IPW_DEBUG_INFO("exit\n");
+
+	return 0;
+}
+
+
+void ipw2100_queues_initialize(struct ipw2100_priv *priv)
+{
+	ipw2100_tx_initialize(priv);
+	ipw2100_rx_initialize(priv);
+	ipw2100_msg_initialize(priv);
+}
+
+void ipw2100_queues_free(struct ipw2100_priv *priv)
+{
+	ipw2100_tx_free(priv);
+	ipw2100_rx_free(priv);
+	ipw2100_msg_free(priv);
+}
+
+int ipw2100_queues_allocate(struct ipw2100_priv *priv)
+{
+	if (ipw2100_tx_allocate(priv) ||
+	    ipw2100_rx_allocate(priv) ||
+	    ipw2100_msg_allocate(priv))
+		goto fail;
+
+	return 0;
+
+ fail:
+	ipw2100_tx_free(priv);
+	ipw2100_rx_free(priv);
+	ipw2100_msg_free(priv);
+	return -ENOMEM;
+}
+
+#define IPW_PRIVACY_CAPABLE 0x0008
+
+static int ipw2100_set_wep_flags(struct ipw2100_priv *priv, u32 flags,
+				 int batch_mode)
+{
+	struct host_command cmd = {
+		.host_command = WEP_FLAGS,
+		.host_command_sequence = 0,
+		.host_command_length = 4
+	};
+	int err;
+
+	cmd.host_command_parameters[0] = flags;
+
+	IPW_DEBUG_HC("WEP_FLAGS: flags = 0x%08X\n", flags);
+
+	if (!batch_mode) {
+		err = ipw2100_disable_adapter(priv);
+		if (err) {
+			IPW_DEBUG_ERROR("%s: Could not disable adapter %d\n",
+			       priv->net_dev->name, err);
+			return err;
+		}
+	}
+
+	/* send cmd to firmware */
+	err = ipw2100_hw_send_command(priv, &cmd);
+
+	if (!batch_mode)
+		ipw2100_enable_adapter(priv);
+
+	return err;
+}
+
+struct ipw2100_wep_key {
+	u8 idx;
+	u8 len;
+	u8 key[13];
+};
+
+/* Macros to ease up priting WEP keys */
+#define WEP_FMT_64  "%02X%02X%02X%02X-%02X"
+#define WEP_FMT_128 "%02X%02X%02X%02X-%02X%02X%02X%02X-%02X%02X%02X"
+#define WEP_STR_64(x) x[0],x[1],x[2],x[3],x[4]
+#define WEP_STR_128(x) x[0],x[1],x[2],x[3],x[4],x[5],x[6],x[7],x[8],x[9],x[10]
+
+
+/**
+ * Set a the wep key
+ *
+ * @priv: struct to work on
+ * @idx: index of the key we want to set
+ * @key: ptr to the key data to set
+ * @len: length of the buffer at @key
+ * @batch_mode: FIXME perform the operation in batch mode, not
+ *              disabling the device.
+ *
+ * @returns 0 if OK, < 0 errno code on error.
+ *
+ * Fill out a command structure with the new wep key, length an
+ * index and send it down the wire.
+ */
+static int ipw2100_set_key(struct ipw2100_priv *priv,
+			   int idx, char *key, int len, int batch_mode)
+{
+	int keylen = len ? (len <= 5 ? 5 : 13) : 0;
+	struct host_command cmd = {
+		.host_command = WEP_KEY_INFO,
+		.host_command_sequence = 0,
+		.host_command_length = sizeof(struct ipw2100_wep_key),
+	};
+	struct ipw2100_wep_key *wep_key = (void*)cmd.host_command_parameters;
+	int err;
+
+	IPW_DEBUG_HC("WEP_KEY_INFO: index = %d, len = %d/%d\n",
+				 idx, keylen, len);
+
+	/* NOTE: We don't check cached values in case the firmware was reset
+	 * or some other problem is occuring.  If the user is setting the key,
+	 * then we push the change */
+
+	wep_key->idx = idx;
+	wep_key->len = keylen;
+
+	if (keylen) {
+		memcpy(wep_key->key, key, len);
+		memset(wep_key->key + len, 0, keylen - len);
+	}
+
+	/* Will be optimized out on debug not being configured in */
+	if (keylen == 0)
+		IPW_DEBUG_WEP("%s: Clearing key %d\n",
+				  priv->net_dev->name, wep_key->idx);
+	else if (keylen == 5)
+		IPW_DEBUG_WEP("%s: idx: %d, len: %d key: " WEP_FMT_64 "\n",
+				  priv->net_dev->name, wep_key->idx, wep_key->len,
+				  WEP_STR_64(wep_key->key));
+	else
+		IPW_DEBUG_WEP("%s: idx: %d, len: %d key: " WEP_FMT_128
+				  "\n",
+				  priv->net_dev->name, wep_key->idx, wep_key->len,
+				  WEP_STR_128(wep_key->key));
+
+	if (!batch_mode) {
+		err = ipw2100_disable_adapter(priv);
+		/* FIXME: IPG: shouldn't this prink be in _disable_adapter()? */
+		if (err) {
+			IPW_DEBUG_ERROR("%s: Could not disable adapter %d\n",
+			       priv->net_dev->name, err);
+			return err;
+		}
+	}
+
+	/* send cmd to firmware */
+	err = ipw2100_hw_send_command(priv, &cmd);
+
+	if (!batch_mode) {
+		int err2 = ipw2100_enable_adapter(priv);
+		if (err == 0)
+			err = err2;
+	}
+	return err;
+}
+
+static int ipw2100_set_key_index(struct ipw2100_priv *priv,
+				 int idx, int batch_mode)
+{
+	struct host_command cmd = {
+		.host_command = WEP_KEY_INDEX,
+		.host_command_sequence = 0,
+		.host_command_length = 4,
+		.host_command_parameters[0] = idx,
+	};
+	int err;
+
+	IPW_DEBUG_HC("WEP_KEY_INDEX: index = %d\n", idx);
+
+	if (idx < 0 || idx > 3)
+		return -EINVAL;
+
+	if (!batch_mode) {
+		err = ipw2100_disable_adapter(priv);
+		if (err) {
+			IPW_DEBUG_ERROR("%s: Could not disable adapter %d\n",
+			       priv->net_dev->name, err);
+			return err;
+		}
+	}
+
+	/* send cmd to firmware */
+	err = ipw2100_hw_send_command(priv, &cmd);
+
+	if (!batch_mode)
+		ipw2100_enable_adapter(priv);
+
+	return err;
+}
+
+
+static int ipw2100_configure_security(struct ipw2100_priv *priv,
+				      int batch_mode)
+{
+	int i, err, auth_mode, sec_level, use_group;
+
+	if (!(priv->status & STATUS_RUNNING))
+		return 0;
+
+	if (!batch_mode) {
+		err = ipw2100_disable_adapter(priv);
+		if (err)
+			return err;
+	}
+
+	if (!priv->sec.enabled) {
+		err = ipw2100_set_security_information(
+			priv, IPW_AUTH_OPEN, SEC_LEVEL_0, 0, 1);
+	} else {
+		auth_mode = IPW_AUTH_OPEN;
+		if ((priv->sec.flags & SEC_AUTH_MODE) &&
+		    (priv->sec.auth_mode == WLAN_AUTH_SHARED_KEY))
+			auth_mode = IPW_AUTH_SHARED;
+
+		sec_level = SEC_LEVEL_0;
+		if (priv->sec.flags & SEC_LEVEL)
+			sec_level = priv->sec.level;
+
+		use_group = 0;
+		if (priv->sec.flags & SEC_UNICAST_GROUP)
+			use_group = priv->sec.unicast_uses_group;
+
+		err = ipw2100_set_security_information(
+			    priv, auth_mode, sec_level, use_group, 1);
+	}
+
+	if (err)
+		goto exit;
+
+	if (priv->sec.enabled) {
+		for (i = 0; i < 4; i++) {
+			if (!(priv->sec.flags & (1 << i))) {
+				memset(priv->sec.keys[i], 0, WEP_KEY_LEN);
+				priv->sec.key_sizes[i] = 0;
+			} else {
+				err = ipw2100_set_key(priv, i,
+						      priv->sec.keys[i],
+						      priv->sec.key_sizes[i],
+						      1);
+				if (err)
+					goto exit;
+			}
+		}
+
+		ipw2100_set_key_index(priv, priv->ieee->tx_keyidx, 1);
+	}
+
+	/* Always enable privacy so the Host can filter WEP packets if
+	 * encrypted data is sent up */
+	err = ipw2100_set_wep_flags(
+		priv, priv->sec.enabled ? IPW_PRIVACY_CAPABLE : 0, 1);
+	if (err)
+		goto exit;
+
+	priv->status &= ~STATUS_SECURITY_UPDATED;
+
+ exit:
+	if (!batch_mode)
+		ipw2100_enable_adapter(priv);
+
+	return err;
+}
+
+static void ipw2100_security_work(struct ipw2100_priv *priv)
+{
+	/* If we happen to have reconnected before we get a chance to
+	 * process this, then update the security settings--which causes
+	 * a disassociation to occur */
+	if (!(priv->status & STATUS_ASSOCIATED) &&
+	    priv->status & STATUS_SECURITY_UPDATED)
+		ipw2100_configure_security(priv, 0);
+}
+
+static void shim__set_security(struct net_device *dev,
+			       struct ieee80211_security *sec)
+{
+	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	int i, force_update = 0;
+
+	down(&priv->action_sem);
+	if (!(priv->status & STATUS_INITIALIZED))
+		goto done;
+
+	for (i = 0; i < 4; i++) {
+		if (sec->flags & (1 << i)) {
+			priv->sec.key_sizes[i] = sec->key_sizes[i];
+			if (sec->key_sizes[i] == 0)
+				priv->sec.flags &= ~(1 << i);
+			else
+				memcpy(priv->sec.keys[i], sec->keys[i],
+				       sec->key_sizes[i]);
+			priv->sec.flags |= (1 << i);
+			priv->status |= STATUS_SECURITY_UPDATED;
+		}
+	}
+
+	if ((sec->flags & SEC_ACTIVE_KEY) &&
+	    priv->sec.active_key != sec->active_key) {
+		if (sec->active_key <= 3) {
+			priv->sec.active_key = sec->active_key;
+			priv->sec.flags |= SEC_ACTIVE_KEY;
+		} else
+			priv->sec.flags &= ~SEC_ACTIVE_KEY;
+
+		priv->status |= STATUS_SECURITY_UPDATED;
+	}
+
+	if ((sec->flags & SEC_AUTH_MODE) &&
+	    (priv->sec.auth_mode != sec->auth_mode)) {
+		priv->sec.auth_mode = sec->auth_mode;
+		priv->sec.flags |= SEC_AUTH_MODE;
+		priv->status |= STATUS_SECURITY_UPDATED;
+	}
+
+	if (sec->flags & SEC_ENABLED &&
+	    priv->sec.enabled != sec->enabled) {
+		priv->sec.flags |= SEC_ENABLED;
+		priv->sec.enabled = sec->enabled;
+		priv->status |= STATUS_SECURITY_UPDATED;
+		force_update = 1;
+	}
+
+	if (sec->flags & SEC_LEVEL &&
+	    priv->sec.level != sec->level) {
+		priv->sec.level = sec->level;
+		priv->sec.flags |= SEC_LEVEL;
+		priv->status |= STATUS_SECURITY_UPDATED;
+	}
+
+	IPW_DEBUG_WEP("Security flags: %c %c%c%c%c %c%c%c%c\n",
+			  priv->sec.flags & (1<<8) ? '1' : '0',
+			  priv->sec.flags & (1<<7) ? '1' : '0',
+			  priv->sec.flags & (1<<6) ? '1' : '0',
+			  priv->sec.flags & (1<<5) ? '1' : '0',
+			  priv->sec.flags & (1<<4) ? '1' : '0',
+			  priv->sec.flags & (1<<3) ? '1' : '0',
+			  priv->sec.flags & (1<<2) ? '1' : '0',
+			  priv->sec.flags & (1<<1) ? '1' : '0',
+			  priv->sec.flags & (1<<0) ? '1' : '0');
+
+/* As a temporary work around to enable WPA until we figure out why
+ * wpa_supplicant toggles the security capability of the driver, which
+ * forces a disassocation with force_update...
+ *
+ *	if (force_update || !(priv->status & STATUS_ASSOCIATED))*/
+	if (!(priv->status & (STATUS_ASSOCIATED | STATUS_ASSOCIATING)))
+		ipw2100_configure_security(priv, 0);
+done:
+	up(&priv->action_sem);
+}
+
+static int ipw2100_adapter_setup(struct ipw2100_priv *priv)
+{
+	int err;
+	int batch_mode = 1;
+	u8 *bssid;
+
+	IPW_DEBUG_INFO("enter\n");
+
+	err = ipw2100_disable_adapter(priv);
+	if (err)
+		return err;
+#ifdef CONFIG_IPW2100_MONITOR
+	if (priv->ieee->iw_mode == IW_MODE_MONITOR) {
+		err = ipw2100_set_channel(priv, priv->channel, batch_mode);
+		if (err)
+			return err;
+
+		IPW_DEBUG_INFO("exit\n");
+
+		return 0;
+	}
+#endif /* CONFIG_IPW2100_MONITOR */
+
+	err = ipw2100_read_mac_address(priv);
+	if (err)
+		return -EIO;
+
+	err = ipw2100_set_mac_address(priv, batch_mode);
+	if (err)
+		return err;
+
+	err = ipw2100_set_port_type(priv, priv->ieee->iw_mode, batch_mode);
+	if (err)
+		return err;
+
+	if (priv->ieee->iw_mode == IW_MODE_ADHOC) {
+		err = ipw2100_set_channel(priv, priv->channel, batch_mode);
+		if (err)
+			return err;
+	}
+
+	err  = ipw2100_system_config(priv, batch_mode);
+	if (err)
+		return err;
+
+	err = ipw2100_set_tx_rates(priv, priv->tx_rates, batch_mode);
+	if (err)
+		return err;
+
+	/* Default to power mode OFF */
+	err = ipw2100_set_power_mode(priv, IPW_POWER_MODE_CAM);
+	if (err)
+		return err;
+
+	err = ipw2100_set_rts_threshold(priv, priv->rts_threshold);
+	if (err)
+		return err;
+
+	if (priv->config & CFG_STATIC_BSSID)
+		bssid = priv->bssid;
+	else
+		bssid = NULL;
+	err = ipw2100_set_mandatory_bssid(priv, bssid, batch_mode);
+	if (err)
+		return err;
+
+	if (priv->config & CFG_STATIC_ESSID)
+		err = ipw2100_set_essid(priv, priv->essid, priv->essid_len,
+					batch_mode);
+	else
+		err = ipw2100_set_essid(priv, NULL, 0, batch_mode);
+	if (err)
+		return err;
+
+	err = ipw2100_configure_security(priv, batch_mode);
+	if (err)
+		return err;
+
+	if (priv->ieee->iw_mode == IW_MODE_ADHOC) {
+		err = ipw2100_set_ibss_beacon_interval(
+			priv, priv->beacon_interval, batch_mode);
+		if (err)
+			return err;
+
+		err = ipw2100_set_tx_power(priv, priv->tx_power);
+		if (err)
+			return err;
+	}
+
+	/*
+	  err = ipw2100_set_fragmentation_threshold(
+	  priv, priv->frag_threshold, batch_mode);
+	  if (err)
+	  return err;
+	*/
+
+	IPW_DEBUG_INFO("exit\n");
+
+	return 0;
+}
+
+
+/*************************************************************************
+ *
+ * EXTERNALLY CALLED METHODS
+ *
+ *************************************************************************/
+
+/* This method is called by the network layer -- not to be confused with
+ * ipw2100_set_mac_address() declared above called by this driver (and this
+ * method as well) to talk to the firmware */
+static int ipw2100_set_address(struct net_device *dev, void *p)
+{
+	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct sockaddr *addr = p;
+	int err = 0;
+
+	if (!is_valid_ether_addr(addr->sa_data))
+		return -EADDRNOTAVAIL;
+
+	down(&priv->action_sem);
+
+	priv->config |= CFG_CUSTOM_MAC;
+	memcpy(priv->mac_addr, addr->sa_data, ETH_ALEN);
+
+	err = ipw2100_set_mac_address(priv, 0);
+	if (err)
+		goto done;
+
+	priv->reset_backoff = 0;
+	up(&priv->action_sem);
+	ipw2100_reset_adapter(priv);
+	return 0;
+
+ done:
+	up(&priv->action_sem);
+	return err;
+}
+
+static int ipw2100_open(struct net_device *dev)
+{
+	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	unsigned long flags;
+	IPW_DEBUG_INFO("dev->open\n");
+
+	spin_lock_irqsave(&priv->low_lock, flags);
+	if (priv->status & STATUS_ASSOCIATED)
+		netif_start_queue(dev);
+	spin_unlock_irqrestore(&priv->low_lock, flags);
+
+	return 0;
+}
+
+static int ipw2100_close(struct net_device *dev)
+{
+	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	unsigned long flags;
+	struct list_head *element;
+	struct ipw2100_tx_packet *packet;
+
+	IPW_DEBUG_INFO("enter\n");
+
+	spin_lock_irqsave(&priv->low_lock, flags);
+
+	if (priv->status & STATUS_ASSOCIATED)
+		netif_carrier_off(dev);
+	netif_stop_queue(dev);
+
+	/* Flush the TX queue ... */
+	while (!list_empty(&priv->tx_pend_list)) {
+		element = priv->tx_pend_list.next;
+                packet = list_entry(element, struct ipw2100_tx_packet, list);
+
+		list_del(element);
+		DEC_STAT(&priv->tx_pend_stat);
+
+		ieee80211_txb_free(packet->info.d_struct.txb);
+		packet->info.d_struct.txb = NULL;
+
+		list_add_tail(element, &priv->tx_free_list);
+		INC_STAT(&priv->tx_free_stat);
+	}
+	spin_unlock_irqrestore(&priv->low_lock, flags);
+
+	IPW_DEBUG_INFO("exit\n");
+
+	return 0;
+}
+
+
+
+/*
+ * TODO:  Fix this function... its just wrong
+ */
+static void ipw2100_tx_timeout(struct net_device *dev)
+{
+	struct ipw2100_priv *priv = ieee80211_priv(dev);
+
+	priv->ieee->stats.tx_errors++;
+
+#ifdef CONFIG_IPW2100_MONITOR
+	if (priv->ieee->iw_mode == IW_MODE_MONITOR)
+		return;
+#endif
+
+	IPW_DEBUG_INFO("%s: TX timed out.  Scheduling firmware restart.\n",
+		       dev->name);
+	schedule_reset(priv);
+}
+
+
+/*
+ * TODO: reimplement it so that it reads statistics
+ *       from the adapter using ordinal tables
+ *       instead of/in addition to collecting them
+ *       in the driver
+ */
+static struct net_device_stats *ipw2100_stats(struct net_device *dev)
+{
+	struct ipw2100_priv *priv = ieee80211_priv(dev);
+
+	return &priv->ieee->stats;
+}
+
+/* Support for wpa_supplicant. Will be replaced with WEXT once
+ * they get WPA support. */
+#ifdef CONFIG_IEEE80211_WPA
+
+/* following definitions must match definitions in driver_ipw2100.c */
+
+#define IPW2100_IOCTL_WPA_SUPPLICANT		SIOCIWFIRSTPRIV+30
+
+#define IPW2100_CMD_SET_WPA_PARAM		1
+#define	IPW2100_CMD_SET_WPA_IE			2
+#define IPW2100_CMD_SET_ENCRYPTION		3
+#define IPW2100_CMD_MLME			4
+
+#define IPW2100_PARAM_WPA_ENABLED		1
+#define IPW2100_PARAM_TKIP_COUNTERMEASURES	2
+#define IPW2100_PARAM_DROP_UNENCRYPTED		3
+#define IPW2100_PARAM_PRIVACY_INVOKED		4
+#define IPW2100_PARAM_AUTH_ALGS			5
+#define IPW2100_PARAM_IEEE_802_1X		6
+
+#define IPW2100_MLME_STA_DEAUTH			1
+#define IPW2100_MLME_STA_DISASSOC		2
+
+#define IPW2100_CRYPT_ERR_UNKNOWN_ALG		2
+#define IPW2100_CRYPT_ERR_UNKNOWN_ADDR		3
+#define IPW2100_CRYPT_ERR_CRYPT_INIT_FAILED	4
+#define IPW2100_CRYPT_ERR_KEY_SET_FAILED	5
+#define IPW2100_CRYPT_ERR_TX_KEY_SET_FAILED	6
+#define IPW2100_CRYPT_ERR_CARD_CONF_FAILED	7
+
+#define	IPW2100_CRYPT_ALG_NAME_LEN		16
+
+struct ipw2100_param {
+	u32 cmd;
+	u8 sta_addr[ETH_ALEN];
+        union {
+		struct {
+			u8 name;
+			u32 value;
+		} wpa_param;
+		struct {
+			u32 len;
+			u8 *data;
+		} wpa_ie;
+	        struct{
+			int command;
+    			int reason_code;
+		} mlme;
+		struct {
+			u8 alg[IPW2100_CRYPT_ALG_NAME_LEN];
+			u8 set_tx;
+			u32 err;
+			u8 idx;
+			u8 seq[8]; /* sequence counter (set: RX, get: TX) */
+			u16 key_len;
+			u8 key[0];
+		} crypt;
+
+	} u;
+};
+
+/* end of driver_ipw2100.c code */
+
+static int ipw2100_wpa_enable(struct ipw2100_priv *priv, int value){
+
+	struct ieee80211_device *ieee = priv->ieee;
+	struct ieee80211_security sec = {
+		.flags = SEC_LEVEL | SEC_ENABLED,
+	};
+	int ret = 0;
+
+	ieee->wpa_enabled = value;
+
+	if (value){
+		sec.level = SEC_LEVEL_3;
+		sec.enabled = 1;
+	} else {
+		sec.level = SEC_LEVEL_0;
+		sec.enabled = 0;
+	}
+
+	if (ieee->set_security)
+		ieee->set_security(ieee->dev, &sec);
+	else
+		ret = -EOPNOTSUPP;
+
+	return ret;
+}
+
+#define AUTH_ALG_OPEN_SYSTEM			0x1
+#define AUTH_ALG_SHARED_KEY			0x2
+
+static int ipw2100_wpa_set_auth_algs(struct ipw2100_priv *priv, int value){
+
+	struct ieee80211_device *ieee = priv->ieee;
+	struct ieee80211_security sec = {
+		.flags = SEC_AUTH_MODE,
+	};
+	int ret = 0;
+
+	if (value & AUTH_ALG_SHARED_KEY){
+		sec.auth_mode = WLAN_AUTH_SHARED_KEY;
+		ieee->open_wep = 0;
+	} else {
+		sec.auth_mode = WLAN_AUTH_OPEN;
+		ieee->open_wep = 1;
+	}
+
+	if (ieee->set_security)
+		ieee->set_security(ieee->dev, &sec);
+	else
+		ret = -EOPNOTSUPP;
+
+	return ret;
+}
+
+
+static int ipw2100_wpa_set_param(struct net_device *dev, u8 name, u32 value){
+
+	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	int ret=0;
+
+	switch(name){
+		case IPW2100_PARAM_WPA_ENABLED:
+			ret = ipw2100_wpa_enable(priv, value);
+			break;
+
+		case IPW2100_PARAM_TKIP_COUNTERMEASURES:
+			priv->ieee->tkip_countermeasures=value;
+			break;
+
+		case IPW2100_PARAM_DROP_UNENCRYPTED:
+			priv->ieee->drop_unencrypted=value;
+			break;
+
+		case IPW2100_PARAM_PRIVACY_INVOKED:
+			priv->ieee->privacy_invoked=value;
+			break;
+
+		case IPW2100_PARAM_AUTH_ALGS:
+			ret = ipw2100_wpa_set_auth_algs(priv, value);
+			break;
+
+		case IPW2100_PARAM_IEEE_802_1X:
+			priv->ieee->ieee802_1x=value;
+			break;
+
+		default:
+			IPW_DEBUG_ERROR("%s: Unknown WPA param: %d\n",
+					    dev->name, name);
+			ret = -EOPNOTSUPP;
+	}
+
+	return ret;
+}
+
+static int ipw2100_wpa_mlme(struct net_device *dev, int command, int reason){
+
+	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	int ret=0;
+
+	switch(command){
+		case IPW2100_MLME_STA_DEAUTH:
+			// silently ignore
+			break;
+
+		case IPW2100_MLME_STA_DISASSOC:
+			ipw2100_disassociate_bssid(priv);
+			break;
+
+		default:
+			IPW_DEBUG_ERROR("%s: Unknown MLME request: %d\n",
+					    dev->name, command);
+			ret = -EOPNOTSUPP;
+	}
+
+	return ret;
+}
+
+
+void ipw2100_wpa_assoc_frame(struct ipw2100_priv *priv,
+			     char *wpa_ie, int wpa_ie_len){
+
+	struct ipw2100_wpa_assoc_frame frame;
+
+	frame.fixed_ie_mask = 0;
+
+	/* copy WPA IE */
+	memcpy(frame.var_ie, wpa_ie, wpa_ie_len);
+	frame.var_ie_len = wpa_ie_len;
+
+	/* make sure WPA is enabled */
+	ipw2100_wpa_enable(priv, 1);
+	ipw2100_set_wpa_ie(priv, &frame, 0);
+}
+
+
+static int ipw2100_wpa_set_wpa_ie(struct net_device *dev,
+				struct ipw2100_param *param, int plen){
+
+	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ieee80211_device *ieee = priv->ieee;
+	u8 *buf;
+
+	if (! ieee->wpa_enabled)
+	    return -EOPNOTSUPP;
+
+	if (param->u.wpa_ie.len > MAX_WPA_IE_LEN ||
+	   (param->u.wpa_ie.len &&
+		param->u.wpa_ie.data==NULL))
+		return -EINVAL;
+
+	if (param->u.wpa_ie.len){
+		buf = kmalloc(param->u.wpa_ie.len, GFP_KERNEL);
+		if (buf == NULL)
+			return -ENOMEM;
+
+		memcpy(buf, param->u.wpa_ie.data, param->u.wpa_ie.len);
+
+		kfree(ieee->wpa_ie);
+		ieee->wpa_ie = buf;
+		ieee->wpa_ie_len = param->u.wpa_ie.len;
+
+	} else {
+		kfree(ieee->wpa_ie);
+		ieee->wpa_ie = NULL;
+		ieee->wpa_ie_len = 0;
+	}
+
+	ipw2100_wpa_assoc_frame(priv, ieee->wpa_ie, ieee->wpa_ie_len);
+
+	return 0;
+}
+
+/* implementation borrowed from hostap driver */
+
+static int ipw2100_wpa_set_encryption(struct net_device *dev,
+				struct ipw2100_param *param, int param_len){
+
+	int ret = 0;
+	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct ieee80211_device *ieee = priv->ieee;
+	struct ieee80211_crypto_ops *ops;
+	struct ieee80211_crypt_data **crypt;
+
+	struct ieee80211_security sec = {
+		.flags = 0,
+	};
+
+	param->u.crypt.err = 0;
+	param->u.crypt.alg[IPW2100_CRYPT_ALG_NAME_LEN - 1] = '\0';
+
+	if (param_len !=
+	    (int) ((char *) param->u.crypt.key - (char *) param) +
+	    param->u.crypt.key_len){
+		IPW_DEBUG_INFO("Len mismatch %d, %d\n", param_len, param->u.crypt.key_len);
+		return -EINVAL;
+	}
+	if (param->sta_addr[0] == 0xff && param->sta_addr[1] == 0xff &&
+	    param->sta_addr[2] == 0xff && param->sta_addr[3] == 0xff &&
+	    param->sta_addr[4] == 0xff && param->sta_addr[5] == 0xff) {
+		if (param->u.crypt.idx >= WEP_KEYS)
+			return -EINVAL;
+		crypt = &ieee->crypt[param->u.crypt.idx];
+	} else {
+		return -EINVAL;
+	}
+
+	if (strcmp(param->u.crypt.alg, "none") == 0) {
+		if (crypt){
+			sec.enabled = 0;
+			sec.level = SEC_LEVEL_0;
+			sec.flags |= SEC_ENABLED | SEC_LEVEL;
+			ieee80211_crypt_delayed_deinit(ieee, crypt);
+		}
+		goto done;
+	}
+	sec.enabled = 1;
+	sec.flags |= SEC_ENABLED;
+
+	ops = ieee80211_get_crypto_ops(param->u.crypt.alg);
+	if (ops == NULL && strcmp(param->u.crypt.alg, "WEP") == 0) {
+		request_module("ieee80211_crypt_wep");
+		ops = ieee80211_get_crypto_ops(param->u.crypt.alg);
+	} else if (ops == NULL && strcmp(param->u.crypt.alg, "TKIP") == 0) {
+		request_module("ieee80211_crypt_tkip");
+		ops = ieee80211_get_crypto_ops(param->u.crypt.alg);
+	} else if (ops == NULL && strcmp(param->u.crypt.alg, "CCMP") == 0) {
+		request_module("ieee80211_crypt_ccmp");
+		ops = ieee80211_get_crypto_ops(param->u.crypt.alg);
+	}
+	if (ops == NULL) {
+		IPW_DEBUG_INFO("%s: unknown crypto alg '%s'\n",
+		       dev->name, param->u.crypt.alg);
+		param->u.crypt.err = IPW2100_CRYPT_ERR_UNKNOWN_ALG;
+		ret = -EINVAL;
+		goto done;
+	}
+
+	if (*crypt == NULL || (*crypt)->ops != ops) {
+		struct ieee80211_crypt_data *new_crypt;
+
+		ieee80211_crypt_delayed_deinit(ieee, crypt);
+
+		new_crypt = (struct ieee80211_crypt_data *)
+			kmalloc(sizeof(struct ieee80211_crypt_data), GFP_KERNEL);
+		if (new_crypt == NULL) {
+			ret = -ENOMEM;
+			goto done;
+		}
+		memset(new_crypt, 0, sizeof(struct ieee80211_crypt_data));
+		new_crypt->ops = ops;
+		if (new_crypt->ops && try_module_get(new_crypt->ops->owner))
+			new_crypt->priv = new_crypt->ops->init(param->u.crypt.idx);
+
+		if (new_crypt->priv == NULL) {
+			kfree(new_crypt);
+			param->u.crypt.err =
+				IPW2100_CRYPT_ERR_CRYPT_INIT_FAILED;
+			ret = -EINVAL;
+			goto done;
+		}
+
+		*crypt = new_crypt;
+	}
+
+	if (param->u.crypt.key_len > 0 && (*crypt)->ops->set_key &&
+	    (*crypt)->ops->set_key(param->u.crypt.key,
+				   param->u.crypt.key_len, param->u.crypt.seq,
+				   (*crypt)->priv) < 0) {
+		IPW_DEBUG_INFO("%s: key setting failed\n",
+		       dev->name);
+		param->u.crypt.err = IPW2100_CRYPT_ERR_KEY_SET_FAILED;
+		ret = -EINVAL;
+		goto done;
+	}
+
+	if (param->u.crypt.set_tx){
+		ieee->tx_keyidx = param->u.crypt.idx;
+		sec.active_key = param->u.crypt.idx;
+		sec.flags |= SEC_ACTIVE_KEY;
+	}
+
+	if (ops->name != NULL){
+
+		if (strcmp(ops->name, "WEP") == 0) {
+			memcpy(sec.keys[param->u.crypt.idx], param->u.crypt.key, param->u.crypt.key_len);
+			sec.key_sizes[param->u.crypt.idx] = param->u.crypt.key_len;
+			sec.flags |= (1 << param->u.crypt.idx);
+			sec.flags |= SEC_LEVEL;
+			sec.level = SEC_LEVEL_1;
+		} else if (strcmp(ops->name, "TKIP") == 0) {
+			sec.flags |= SEC_LEVEL;
+			sec.level = SEC_LEVEL_2;
+		} else if (strcmp(ops->name, "CCMP") == 0) {
+			sec.flags |= SEC_LEVEL;
+			sec.level = SEC_LEVEL_3;
+		}
+	}
+ done:
+	if (ieee->set_security)
+		ieee->set_security(ieee->dev, &sec);
+
+	/* Do not reset port if card is in Managed mode since resetting will
+	 * generate new IEEE 802.11 authentication which may end up in looping
+	 * with IEEE 802.1X.  If your hardware requires a reset after WEP
+	 * configuration (for example... Prism2), implement the reset_port in
+	 * the callbacks structures used to initialize the 802.11 stack. */
+	if (ieee->reset_on_keychange &&
+	    ieee->iw_mode != IW_MODE_INFRA &&
+	    ieee->reset_port &&
+	    ieee->reset_port(dev)) {
+		IPW_DEBUG_INFO("%s: reset_port failed\n", dev->name);
+		param->u.crypt.err = IPW2100_CRYPT_ERR_CARD_CONF_FAILED;
+		return -EINVAL;
+	}
+
+	return ret;
+}
+
+
+static int ipw2100_wpa_supplicant(struct net_device *dev, struct iw_point *p){
+
+	struct ipw2100_param *param;
+	int ret=0;
+
+	IPW_DEBUG_IOCTL("wpa_supplicant: len=%d\n", p->length);
+
+	if (p->length < sizeof(struct ipw2100_param) || !p->pointer)
+		return -EINVAL;
+
+	param = (struct ipw2100_param *)kmalloc(p->length, GFP_KERNEL);
+	if (param == NULL)
+		return -ENOMEM;
+
+	if (copy_from_user(param, p->pointer, p->length)){
+		kfree(param);
+		return -EFAULT;
+	}
+
+	switch (param->cmd){
+
+	case IPW2100_CMD_SET_WPA_PARAM:
+		ret = ipw2100_wpa_set_param(dev, param->u.wpa_param.name,
+					    param->u.wpa_param.value);
+		break;
+
+	case IPW2100_CMD_SET_WPA_IE:
+		ret = ipw2100_wpa_set_wpa_ie(dev, param, p->length);
+		break;
+
+	case IPW2100_CMD_SET_ENCRYPTION:
+		ret = ipw2100_wpa_set_encryption(dev, param, p->length);
+		break;
+
+	case IPW2100_CMD_MLME:
+		ret = ipw2100_wpa_mlme(dev, param->u.mlme.command,
+				       param->u.mlme.reason_code);
+		break;
+
+	default:
+		IPW_DEBUG_ERROR("%s: Unknown WPA supplicant request: %d\n",
+				dev->name, param->cmd);
+		ret = -EOPNOTSUPP;
+
+	}
+
+	if (ret == 0 && copy_to_user(p->pointer, param, p->length))
+		ret = -EFAULT;
+
+	kfree(param);
+	return ret;
+}
+#endif /* CONFIG_IEEE80211_WPA */
+
+static int ipw2100_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
+{
+#ifdef CONFIG_IEEE80211_WPA
+	struct iwreq *wrq = (struct iwreq *) rq;
+	int ret=-1;
+	switch (cmd){
+	    case IPW2100_IOCTL_WPA_SUPPLICANT:
+		ret = ipw2100_wpa_supplicant(dev, &wrq->u.data);
+		return ret;
+
+	    default:
+		return -EOPNOTSUPP;
+	}
+
+#endif /* CONFIG_IEEE80211_WPA */
+
+	return -EOPNOTSUPP;
+}
+
+
+static void ipw_ethtool_get_drvinfo(struct net_device *dev,
+				    struct ethtool_drvinfo *info)
+{
+	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	char fw_ver[64], ucode_ver[64];
+
+	strcpy(info->driver, DRV_NAME);
+	strcpy(info->version, DRV_VERSION);
+
+	ipw2100_get_fwversion(priv, fw_ver, sizeof(fw_ver));
+	ipw2100_get_ucodeversion(priv, ucode_ver, sizeof(ucode_ver));
+
+	snprintf(info->fw_version, sizeof(info->fw_version), "%s:%d:%s",
+		 fw_ver, priv->eeprom_version, ucode_ver);
+
+	strcpy(info->bus_info, pci_name(priv->pci_dev));
+}
+
+static u32 ipw2100_ethtool_get_link(struct net_device *dev)
+{
+    struct ipw2100_priv *priv = ieee80211_priv(dev);
+    return (priv->status & STATUS_ASSOCIATED) ? 1 : 0;
+}
+
+
+static struct ethtool_ops ipw2100_ethtool_ops = {
+    .get_link        = ipw2100_ethtool_get_link,
+    .get_drvinfo     = ipw_ethtool_get_drvinfo,
+};
+
+static void ipw2100_hang_check(void *adapter)
+{
+	struct ipw2100_priv *priv = adapter;
+	unsigned long flags;
+	u32 rtc = 0xa5a5a5a5;
+	u32 len = sizeof(rtc);
+	int restart = 0;
+
+	spin_lock_irqsave(&priv->low_lock, flags);
+
+	if (priv->fatal_error != 0) {
+		/* If fatal_error is set then we need to restart */
+		IPW_DEBUG_INFO("%s: Hardware fatal error detected.\n",
+			       priv->net_dev->name);
+
+		restart = 1;
+	} else if (ipw2100_get_ordinal(priv, IPW_ORD_RTC_TIME, &rtc, &len) ||
+		   (rtc == priv->last_rtc)) {
+		/* Check if firmware is hung */
+		IPW_DEBUG_INFO("%s: Firmware RTC stalled.\n",
+			       priv->net_dev->name);
+
+		restart = 1;
+	}
+
+	if (restart) {
+		/* Kill timer */
+		priv->stop_hang_check = 1;
+		priv->hangs++;
+
+		/* Restart the NIC */
+		schedule_reset(priv);
+	}
+
+	priv->last_rtc = rtc;
+
+	if (!priv->stop_hang_check)
+		queue_delayed_work(priv->workqueue, &priv->hang_check, HZ / 2);
+
+	spin_unlock_irqrestore(&priv->low_lock, flags);
+}
+
+
+static void ipw2100_rf_kill(void *adapter)
+{
+	struct ipw2100_priv *priv = adapter;
+	unsigned long flags;
+
+	spin_lock_irqsave(&priv->low_lock, flags);
+
+	if (rf_kill_active(priv)) {
+		IPW_DEBUG_RF_KILL("RF Kill active, rescheduling GPIO check\n");
+		if (!priv->stop_rf_kill)
+			queue_delayed_work(priv->workqueue, &priv->rf_kill, HZ);
+		goto exit_unlock;
+	}
+
+	/* RF Kill is now disabled, so bring the device back up */
+
+	if (!(priv->status & STATUS_RF_KILL_MASK)) {
+		IPW_DEBUG_RF_KILL("HW RF Kill no longer active, restarting "
+				  "device\n");
+		schedule_reset(priv);
+	} else
+		IPW_DEBUG_RF_KILL("HW RF Kill deactivated.  SW RF Kill still "
+				  "enabled\n");
+
+ exit_unlock:
+	spin_unlock_irqrestore(&priv->low_lock, flags);
+}
+
+static void ipw2100_irq_tasklet(struct ipw2100_priv *priv);
+
+/* Look into using netdev destructor to shutdown ieee80211? */
+
+static struct net_device *ipw2100_alloc_device(
+	struct pci_dev *pci_dev,
+	char *base_addr,
+	unsigned long mem_start,
+	unsigned long mem_len)
+{
+	struct ipw2100_priv *priv;
+	struct net_device *dev;
+
+	dev = alloc_ieee80211(sizeof(struct ipw2100_priv));
+	if (!dev)
+		return NULL;
+	priv = ieee80211_priv(dev);
+	priv->ieee = netdev_priv(dev);
+	priv->pci_dev = pci_dev;
+	priv->net_dev = dev;
+
+	priv->ieee->hard_start_xmit = ipw2100_tx;
+	priv->ieee->set_security = shim__set_security;
+
+	dev->open = ipw2100_open;
+	dev->stop = ipw2100_close;
+	dev->init = ipw2100_net_init;
+	dev->do_ioctl = ipw2100_ioctl;
+	dev->get_stats = ipw2100_stats;
+	dev->ethtool_ops = &ipw2100_ethtool_ops;
+	dev->tx_timeout = ipw2100_tx_timeout;
+	dev->wireless_handlers = &ipw2100_wx_handler_def;
+	dev->get_wireless_stats = ipw2100_wx_wireless_stats;
+	dev->set_mac_address = ipw2100_set_address;
+	dev->watchdog_timeo = 3*HZ;
+	dev->irq = 0;
+
+	dev->base_addr = (unsigned long)base_addr;
+	dev->mem_start = mem_start;
+	dev->mem_end = dev->mem_start + mem_len - 1;
+
+	/* NOTE: We don't use the wireless_handlers hook
+	 * in dev as the system will start throwing WX requests
+	 * to us before we're actually initialized and it just
+	 * ends up causing problems.  So, we just handle
+	 * the WX extensions through the ipw2100_ioctl interface */
+
+
+	/* memset() puts everything to 0, so we only have explicitely set
+	 * those values that need to be something else */
+
+	/* If power management is turned on, default to AUTO mode */
+	priv->power_mode = IPW_POWER_AUTO;
+
+
+
+#ifdef CONFIG_IEEE80211_WPA
+	priv->ieee->wpa_enabled = 0;
+	priv->ieee->tkip_countermeasures = 0;
+	priv->ieee->drop_unencrypted = 0;
+	priv->ieee->privacy_invoked = 0;
+	priv->ieee->ieee802_1x = 1;
+#endif /* CONFIG_IEEE80211_WPA */
+
+	/* Set module parameters */
+	switch (mode) {
+	case 1:
+		priv->ieee->iw_mode = IW_MODE_ADHOC;
+		break;
+#ifdef CONFIG_IPW2100_MONITOR
+	case 2:
+		priv->ieee->iw_mode = IW_MODE_MONITOR;
+		break;
+#endif
+	default:
+	case 0:
+		priv->ieee->iw_mode = IW_MODE_INFRA;
+		break;
+	}
+
+	if (disable == 1)
+		priv->status |= STATUS_RF_KILL_SW;
+
+	if (channel != 0 &&
+	    ((channel >= REG_MIN_CHANNEL) &&
+	     (channel <= REG_MAX_CHANNEL))) {
+		priv->config |= CFG_STATIC_CHANNEL;
+		priv->channel = channel;
+	}
+
+	if (associate)
+		priv->config |= CFG_ASSOCIATE;
+
+	priv->beacon_interval = DEFAULT_BEACON_INTERVAL;
+	priv->short_retry_limit = DEFAULT_SHORT_RETRY_LIMIT;
+	priv->long_retry_limit = DEFAULT_LONG_RETRY_LIMIT;
+	priv->rts_threshold = DEFAULT_RTS_THRESHOLD | RTS_DISABLED;
+	priv->frag_threshold = DEFAULT_FTS | FRAG_DISABLED;
+	priv->tx_power = IPW_TX_POWER_DEFAULT;
+	priv->tx_rates = DEFAULT_TX_RATES;
+
+	strcpy(priv->nick, "ipw2100");
+
+	spin_lock_init(&priv->low_lock);
+	sema_init(&priv->action_sem, 1);
+	sema_init(&priv->adapter_sem, 1);
+
+	init_waitqueue_head(&priv->wait_command_queue);
+
+	netif_carrier_off(dev);
+
+	INIT_LIST_HEAD(&priv->msg_free_list);
+	INIT_LIST_HEAD(&priv->msg_pend_list);
+	INIT_STAT(&priv->msg_free_stat);
+	INIT_STAT(&priv->msg_pend_stat);
+
+	INIT_LIST_HEAD(&priv->tx_free_list);
+	INIT_LIST_HEAD(&priv->tx_pend_list);
+	INIT_STAT(&priv->tx_free_stat);
+	INIT_STAT(&priv->tx_pend_stat);
+
+	INIT_LIST_HEAD(&priv->fw_pend_list);
+	INIT_STAT(&priv->fw_pend_stat);
+
+
+#ifdef CONFIG_SOFTWARE_SUSPEND2
+	priv->workqueue = create_workqueue(DRV_NAME, 0);
+#else
+	priv->workqueue = create_workqueue(DRV_NAME);
+#endif
+	INIT_WORK(&priv->reset_work,
+		  (void (*)(void *))ipw2100_reset_adapter, priv);
+	INIT_WORK(&priv->security_work,
+		  (void (*)(void *))ipw2100_security_work, priv);
+	INIT_WORK(&priv->wx_event_work,
+		  (void (*)(void *))ipw2100_wx_event_work, priv);
+	INIT_WORK(&priv->hang_check, ipw2100_hang_check, priv);
+	INIT_WORK(&priv->rf_kill, ipw2100_rf_kill, priv);
+
+	tasklet_init(&priv->irq_tasklet, (void (*)(unsigned long))
+		     ipw2100_irq_tasklet, (unsigned long)priv);
+
+	/* NOTE:  We do not start the deferred work for status checks yet */
+	priv->stop_rf_kill = 1;
+	priv->stop_hang_check = 1;
+
+	return dev;
+}
+
+
+
+#define PCI_DMA_32BIT   0x00000000ffffffffULL
+
+static int ipw2100_pci_init_one(struct pci_dev *pci_dev,
+				const struct pci_device_id *ent)
+{
+	unsigned long mem_start, mem_len, mem_flags;
+	char *base_addr = NULL;
+	struct net_device *dev = NULL;
+	struct ipw2100_priv *priv = NULL;
+	int err = 0;
+	int registered = 0;
+	u32 val;
+
+	IPW_DEBUG_INFO("enter\n");
+
+	mem_start = pci_resource_start(pci_dev, 0);
+	mem_len = pci_resource_len(pci_dev, 0);
+	mem_flags = pci_resource_flags(pci_dev, 0);
+
+	if ((mem_flags & IORESOURCE_MEM) != IORESOURCE_MEM) {
+		IPW_DEBUG_INFO("weird - resource type is not memory\n");
+		err = -ENODEV;
+		goto fail;
+	}
+
+	base_addr = ioremap_nocache(mem_start, mem_len);
+	if (!base_addr) {
+		printk(KERN_WARNING DRV_NAME
+		       "Error calling ioremap_nocache.\n");
+		err = -EIO;
+		goto fail;
+	}
+
+	/* allocate and initialize our net_device */
+	dev = ipw2100_alloc_device(pci_dev, base_addr, mem_start, mem_len);
+	if (!dev) {
+		printk(KERN_WARNING DRV_NAME
+		       "Error calling ipw2100_alloc_device.\n");
+		err = -ENOMEM;
+		goto fail;
+	}
+
+	/* set up PCI mappings for device */
+	err = pci_enable_device(pci_dev);
+	if (err) {
+		printk(KERN_WARNING DRV_NAME
+		       "Error calling pci_enable_device.\n");
+		return err;
+	}
+
+	priv = ieee80211_priv(dev);
+
+	pci_set_master(pci_dev);
+	pci_set_drvdata(pci_dev, priv);
+
+	err = pci_set_dma_mask(pci_dev, PCI_DMA_32BIT);
+	if (err) {
+		printk(KERN_WARNING DRV_NAME
+		       "Error calling pci_set_dma_mask.\n");
+		pci_disable_device(pci_dev);
+		return err;
+	}
+
+	err = pci_request_regions(pci_dev, DRV_NAME);
+	if (err) {
+		printk(KERN_WARNING DRV_NAME
+		       "Error calling pci_request_regions.\n");
+		pci_disable_device(pci_dev);
+		return err;
+	}
+
+        /* We disable the RETRY_TIMEOUT register (0x41) to keep
+	 * PCI Tx retries from interfering with C3 CPU state */
+	pci_read_config_dword(pci_dev, 0x40, &val);
+	if ((val & 0x0000ff00) != 0)
+		pci_write_config_dword(pci_dev, 0x40, val & 0xffff00ff);
+
+	pci_set_power_state(pci_dev, 0);
+
+	if (!ipw2100_hw_is_adapter_in_system(dev)) {
+		printk(KERN_WARNING DRV_NAME
+		       "Device not found via register read.\n");
+		err = -ENODEV;
+		goto fail;
+	}
+
+	SET_NETDEV_DEV(dev, &pci_dev->dev);
+
+	/* Force interrupts to be shut off on the device */
+	priv->status |= STATUS_INT_ENABLED;
+	ipw2100_disable_interrupts(priv);
+
+	/* Allocate and initialize the Tx/Rx queues and lists */
+	if (ipw2100_queues_allocate(priv)) {
+		printk(KERN_WARNING DRV_NAME
+		       "Error calilng ipw2100_queues_allocate.\n");
+		err = -ENOMEM;
+		goto fail;
+	}
+	ipw2100_queues_initialize(priv);
+
+	err = request_irq(pci_dev->irq,
+			  ipw2100_interrupt, SA_SHIRQ,
+			  dev->name, priv);
+	if (err) {
+		printk(KERN_WARNING DRV_NAME
+		       "Error calling request_irq: %d.\n",
+		       pci_dev->irq);
+		goto fail;
+	}
+	dev->irq = pci_dev->irq;
+
+	IPW_DEBUG_INFO("Attempting to register device...\n");
+
+	SET_MODULE_OWNER(dev);
+
+	printk(KERN_INFO DRV_NAME
+	       ": Detected Intel PRO/Wireless 2100 Network Connection\n");
+
+	/* Bring up the interface.  Pre 0.46, after we registered the
+	 * network device we would call ipw2100_up.  This introduced a race
+	 * condition with newer hotplug configurations (network was coming
+	 * up and making calls before the device was initialized).
+	 *
+	 * If we called ipw2100_up before we registered the device, then the
+	 * device name wasn't registered.  So, we instead use the net_dev->init
+	 * member to call a function that then just turns and calls ipw2100_up.
+	 * net_dev->init is called after name allocation but before the
+	 * notifier chain is called */
+	down(&priv->action_sem);
+	err = register_netdev(dev);
+	if (err) {
+		printk(KERN_WARNING DRV_NAME
+		       "Error calling register_netdev.\n");
+		goto fail_unlock;
+	}
+	registered = 1;
+
+	IPW_DEBUG_INFO("%s: Bound to %s\n", dev->name, pci_name(pci_dev));
+
+	/* perform this after register_netdev so that dev->name is set */
+	sysfs_create_group(&pci_dev->dev.kobj, &ipw2100_attribute_group);
+	netif_carrier_off(dev);
+
+	/* If the RF Kill switch is disabled, go ahead and complete the
+	 * startup sequence */
+	if (!(priv->status & STATUS_RF_KILL_MASK)) {
+		/* Enable the adapter - sends HOST_COMPLETE */
+		if (ipw2100_enable_adapter(priv)) {
+			printk(KERN_WARNING DRV_NAME
+			       ": %s: failed in call to enable adapter.\n",
+			       priv->net_dev->name);
+			ipw2100_hw_stop_adapter(priv);
+			err = -EIO;
+			goto fail_unlock;
+		}
+
+		/* Start a scan . . . */
+		ipw2100_set_scan_options(priv);
+		ipw2100_start_scan(priv);
+	}
+
+	IPW_DEBUG_INFO("exit\n");
+
+	priv->status |= STATUS_INITIALIZED;
+
+	up(&priv->action_sem);
+
+	return 0;
+
+ fail_unlock:
+	up(&priv->action_sem);
+
+ fail:
+	if (dev) {
+		if (registered)
+			unregister_netdev(dev);
+
+		ipw2100_hw_stop_adapter(priv);
+
+		ipw2100_disable_interrupts(priv);
+
+		if (dev->irq)
+			free_irq(dev->irq, priv);
+
+		ipw2100_kill_workqueue(priv);
+
+		/* These are safe to call even if they weren't allocated */
+		ipw2100_queues_free(priv);
+		sysfs_remove_group(&pci_dev->dev.kobj, &ipw2100_attribute_group);
+
+		free_ieee80211(dev);
+		pci_set_drvdata(pci_dev, NULL);
+	}
+
+	if (base_addr)
+		iounmap((char*)base_addr);
+
+	pci_release_regions(pci_dev);
+	pci_disable_device(pci_dev);
+
+	return err;
+}
+
+static void __devexit ipw2100_pci_remove_one(struct pci_dev *pci_dev)
+{
+	struct ipw2100_priv *priv = pci_get_drvdata(pci_dev);
+	struct net_device *dev;
+
+	if (priv) {
+		down(&priv->action_sem);
+
+		priv->status &= ~STATUS_INITIALIZED;
+
+		dev = priv->net_dev;
+		sysfs_remove_group(&pci_dev->dev.kobj, &ipw2100_attribute_group);
+
+#ifdef CONFIG_PM
+		if (ipw2100_firmware.version)
+			ipw2100_release_firmware(priv, &ipw2100_firmware);
+#endif
+		/* Take down the hardware */
+		ipw2100_down(priv);
+
+		/* Release the semaphore so that the network subsystem can
+		 * complete any needed calls into the driver... */
+		up(&priv->action_sem);
+
+		/* Unregister the device first - this results in close()
+		 * being called if the device is open.  If we free storage
+		 * first, then close() will crash. */
+		unregister_netdev(dev);
+
+		/* ipw2100_down will ensure that there is no more pending work
+		 * in the workqueue's, so we can safely remove them now. */
+		ipw2100_kill_workqueue(priv);
+
+		ipw2100_queues_free(priv);
+
+		/* Free potential debugging firmware snapshot */
+		ipw2100_snapshot_free(priv);
+
+		if (dev->irq)
+			free_irq(dev->irq, priv);
+
+		if (dev->base_addr)
+			iounmap((unsigned char *)dev->base_addr);
+
+		free_ieee80211(dev);
+	}
+
+	pci_release_regions(pci_dev);
+	pci_disable_device(pci_dev);
+
+	IPW_DEBUG_INFO("exit\n");
+}
+
+
+#ifdef CONFIG_PM
+#if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,11)
+static int ipw2100_suspend(struct pci_dev *pci_dev, u32 state)
+#else
+static int ipw2100_suspend(struct pci_dev *pci_dev, pm_message_t state)
+#endif
+{
+	struct ipw2100_priv *priv = pci_get_drvdata(pci_dev);
+	struct net_device *dev = priv->net_dev;
+
+	IPW_DEBUG_INFO("%s: Going into suspend...\n",
+	       dev->name);
+
+	down(&priv->action_sem);
+	if (priv->status & STATUS_INITIALIZED) {
+		/* Take down the device; powers it off, etc. */
+		ipw2100_down(priv);
+	}
+
+	/* Remove the PRESENT state of the device */
+	netif_device_detach(dev);
+
+#if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,10)
+	pci_save_state(pci_dev, priv->pm_state);
+#else
+	pci_save_state(pci_dev);
+#endif
+	pci_disable_device (pci_dev);
+#if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,11)
+	pci_set_power_state(pci_dev, state);
+#else
+	pci_set_power_state(pci_dev, PCI_D3hot);
+#endif
+
+	up(&priv->action_sem);
+
+	return 0;
+}
+
+static int ipw2100_resume(struct pci_dev *pci_dev)
+{
+	struct ipw2100_priv *priv = pci_get_drvdata(pci_dev);
+	struct net_device *dev = priv->net_dev;
+	u32 val;
+
+	if (IPW2100_PM_DISABLED)
+		return 0;
+
+	down(&priv->action_sem);
+
+	IPW_DEBUG_INFO("%s: Coming out of suspend...\n",
+	       dev->name);
+
+#if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,11)
+	pci_set_power_state(pci_dev, 0);
+#else
+	pci_set_power_state(pci_dev, PCI_D0);
+#endif
+	pci_enable_device(pci_dev);
+#if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,10)
+	pci_restore_state(pci_dev, priv->pm_state);
+#else
+	pci_restore_state(pci_dev);
+#endif
+
+	/*
+	 * Suspend/Resume resets the PCI configuration space, so we have to
+	 * re-disable the RETRY_TIMEOUT register (0x41) to keep PCI Tx retries
+	 * from interfering with C3 CPU state. pci_restore_state won't help
+	 * here since it only restores the first 64 bytes pci config header.
+	 */
+	pci_read_config_dword(pci_dev, 0x40, &val);
+	if ((val & 0x0000ff00) != 0)
+		pci_write_config_dword(pci_dev, 0x40, val & 0xffff00ff);
+
+	/* Set the device back into the PRESENT state; this will also wake
+	 * the queue of needed */
+	netif_device_attach(dev);
+
+        /* Bring the device back up */
+        if (!(priv->status & STATUS_RF_KILL_SW))
+                ipw2100_up(priv, 0);
+
+	up(&priv->action_sem);
+
+	return 0;
+}
+#endif
+
+
+#define IPW2100_DEV_ID(x) { PCI_VENDOR_ID_INTEL, 0x1043, 0x8086, x }
+
+static struct pci_device_id ipw2100_pci_id_table[] __devinitdata = {
+	IPW2100_DEV_ID(0x2520), /* IN 2100A mPCI 3A */
+	IPW2100_DEV_ID(0x2521), /* IN 2100A mPCI 3B */
+	IPW2100_DEV_ID(0x2524), /* IN 2100A mPCI 3B */
+	IPW2100_DEV_ID(0x2525), /* IN 2100A mPCI 3B */
+	IPW2100_DEV_ID(0x2526), /* IN 2100A mPCI Gen A3 */
+	IPW2100_DEV_ID(0x2522), /* IN 2100 mPCI 3B */
+	IPW2100_DEV_ID(0x2523), /* IN 2100 mPCI 3A */
+	IPW2100_DEV_ID(0x2527), /* IN 2100 mPCI 3B */
+	IPW2100_DEV_ID(0x2528), /* IN 2100 mPCI 3B */
+	IPW2100_DEV_ID(0x2529), /* IN 2100 mPCI 3B */
+	IPW2100_DEV_ID(0x252B), /* IN 2100 mPCI 3A */
+	IPW2100_DEV_ID(0x252C), /* IN 2100 mPCI 3A */
+	IPW2100_DEV_ID(0x252D), /* IN 2100 mPCI 3A */
+
+	IPW2100_DEV_ID(0x2550), /* IB 2100A mPCI 3B */
+	IPW2100_DEV_ID(0x2551), /* IB 2100 mPCI 3B */
+	IPW2100_DEV_ID(0x2553), /* IB 2100 mPCI 3B */
+	IPW2100_DEV_ID(0x2554), /* IB 2100 mPCI 3B */
+	IPW2100_DEV_ID(0x2555), /* IB 2100 mPCI 3B */
+
+	IPW2100_DEV_ID(0x2560), /* DE 2100A mPCI 3A */
+	IPW2100_DEV_ID(0x2562), /* DE 2100A mPCI 3A */
+	IPW2100_DEV_ID(0x2563), /* DE 2100A mPCI 3A */
+	IPW2100_DEV_ID(0x2561), /* DE 2100 mPCI 3A */
+	IPW2100_DEV_ID(0x2565), /* DE 2100 mPCI 3A */
+	IPW2100_DEV_ID(0x2566), /* DE 2100 mPCI 3A */
+	IPW2100_DEV_ID(0x2567), /* DE 2100 mPCI 3A */
+
+	IPW2100_DEV_ID(0x2570), /* GA 2100 mPCI 3B */
+
+	IPW2100_DEV_ID(0x2580), /* TO 2100A mPCI 3B */
+	IPW2100_DEV_ID(0x2582), /* TO 2100A mPCI 3B */
+	IPW2100_DEV_ID(0x2583), /* TO 2100A mPCI 3B */
+	IPW2100_DEV_ID(0x2581), /* TO 2100 mPCI 3B */
+	IPW2100_DEV_ID(0x2585), /* TO 2100 mPCI 3B */
+	IPW2100_DEV_ID(0x2586), /* TO 2100 mPCI 3B */
+	IPW2100_DEV_ID(0x2587), /* TO 2100 mPCI 3B */
+
+	IPW2100_DEV_ID(0x2590), /* SO 2100A mPCI 3B */
+	IPW2100_DEV_ID(0x2592), /* SO 2100A mPCI 3B */
+	IPW2100_DEV_ID(0x2591), /* SO 2100 mPCI 3B */
+	IPW2100_DEV_ID(0x2593), /* SO 2100 mPCI 3B */
+	IPW2100_DEV_ID(0x2596), /* SO 2100 mPCI 3B */
+	IPW2100_DEV_ID(0x2598), /* SO 2100 mPCI 3B */
+
+	IPW2100_DEV_ID(0x25A0), /* HP 2100 mPCI 3B */
+	{0,},
+};
+
+MODULE_DEVICE_TABLE(pci, ipw2100_pci_id_table);
+
+static struct pci_driver ipw2100_pci_driver = {
+	.name = DRV_NAME,
+	.id_table = ipw2100_pci_id_table,
+	.probe = ipw2100_pci_init_one,
+	.remove = __devexit_p(ipw2100_pci_remove_one),
+#ifdef CONFIG_PM
+	.suspend = ipw2100_suspend,
+	.resume = ipw2100_resume,
+#endif
+};
+
+
+/**
+ * Initialize the ipw2100 driver/module
+ *
+ * @returns 0 if ok, < 0 errno node con error.
+ *
+ * Note: we cannot init the /proc stuff until the PCI driver is there,
+ * or we risk an unlikely race condition on someone accessing
+ * uninitialized data in the PCI dev struct through /proc.
+ */
+static int __init ipw2100_init(void)
+{
+	int ret;
+
+	printk(KERN_INFO DRV_NAME ": %s, %s\n", DRV_DESCRIPTION, DRV_VERSION);
+	printk(KERN_INFO DRV_NAME ": %s\n", DRV_COPYRIGHT);
+
+#ifdef CONFIG_IEEE80211_NOWEP
+	IPW_DEBUG_INFO(DRV_NAME ": Compiled with WEP disabled.\n");
+#endif
+
+	ret = pci_module_init(&ipw2100_pci_driver);
+
+#ifdef CONFIG_IPW_DEBUG
+	ipw2100_debug_level = debug;
+	driver_create_file(&ipw2100_pci_driver.driver,
+			   &driver_attr_debug_level);
+#endif
+
+	return ret;
+}
+
+
+/**
+ * Cleanup ipw2100 driver registration
+ */
+static void __exit ipw2100_exit(void)
+{
+	/* FIXME: IPG: check that we have no instances of the devices open */
+#ifdef CONFIG_IPW_DEBUG
+	driver_remove_file(&ipw2100_pci_driver.driver,
+			   &driver_attr_debug_level);
+#endif
+	pci_unregister_driver(&ipw2100_pci_driver);
+}
+
+module_init(ipw2100_init);
+module_exit(ipw2100_exit);
+
+#define WEXT_USECHANNELS 1
+
+const long ipw2100_frequencies[] = {
+	2412, 2417, 2422, 2427,
+	2432, 2437, 2442, 2447,
+	2452, 2457, 2462, 2467,
+	2472, 2484
+};
+
+#define FREQ_COUNT (sizeof(ipw2100_frequencies) / \
+                    sizeof(ipw2100_frequencies[0]))
+
+const long ipw2100_rates_11b[] = {
+	1000000,
+	2000000,
+	5500000,
+	11000000
+};
+
+#define RATE_COUNT (sizeof(ipw2100_rates_11b) / sizeof(ipw2100_rates_11b[0]))
+
+static int ipw2100_wx_get_name(struct net_device *dev,
+			       struct iw_request_info *info,
+			       union iwreq_data *wrqu, char *extra)
+{
+	/*
+	 * This can be called at any time.  No action lock required
+	 */
+
+	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	if (!(priv->status & STATUS_ASSOCIATED))
+		strcpy(wrqu->name, "unassociated");
+	else
+		snprintf(wrqu->name, IFNAMSIZ, "IEEE 802.11b");
+
+	IPW_DEBUG_WX("Name: %s\n", wrqu->name);
+	return 0;
+}
+
+
+static int ipw2100_wx_set_freq(struct net_device *dev,
+			       struct iw_request_info *info,
+			       union iwreq_data *wrqu, char *extra)
+{
+	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct iw_freq *fwrq = &wrqu->freq;
+	int err = 0;
+
+	if (priv->ieee->iw_mode == IW_MODE_INFRA)
+		return -EOPNOTSUPP;
+
+	down(&priv->action_sem);
+	if (!(priv->status & STATUS_INITIALIZED)) {
+		err = -EIO;
+		goto done;
+	}
+
+	/* if setting by freq convert to channel */
+	if (fwrq->e == 1) {
+		if ((fwrq->m >= (int) 2.412e8 &&
+		     fwrq->m <= (int) 2.487e8)) {
+			int f = fwrq->m / 100000;
+			int c = 0;
+
+			while ((c < REG_MAX_CHANNEL) &&
+			       (f != ipw2100_frequencies[c]))
+				c++;
+
+			/* hack to fall through */
+			fwrq->e = 0;
+			fwrq->m = c + 1;
+		}
+	}
+
+	if (fwrq->e > 0 || fwrq->m > 1000)
+		return -EOPNOTSUPP;
+	else { /* Set the channel */
+		IPW_DEBUG_WX("SET Freq/Channel -> %d \n", fwrq->m);
+		err = ipw2100_set_channel(priv, fwrq->m, 0);
+	}
+
+ done:
+	up(&priv->action_sem);
+	return err;
+}
+
+
+static int ipw2100_wx_get_freq(struct net_device *dev,
+			       struct iw_request_info *info,
+			       union iwreq_data *wrqu, char *extra)
+{
+	/*
+	 * This can be called at any time.  No action lock required
+	 */
+
+	struct ipw2100_priv *priv = ieee80211_priv(dev);
+
+	wrqu->freq.e = 0;
+
+	/* If we are associated, trying to associate, or have a statically
+	 * configured CHANNEL then return that; otherwise return ANY */
+	if (priv->config & CFG_STATIC_CHANNEL ||
+	    priv->status & STATUS_ASSOCIATED)
+		wrqu->freq.m = priv->channel;
+	else
+		wrqu->freq.m = 0;
+
+	IPW_DEBUG_WX("GET Freq/Channel -> %d \n", priv->channel);
+	return 0;
+
+}
+
+static int ipw2100_wx_set_mode(struct net_device *dev,
+			       struct iw_request_info *info,
+			       union iwreq_data *wrqu, char *extra)
+{
+	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	int err = 0;
+
+	IPW_DEBUG_WX("SET Mode -> %d \n", wrqu->mode);
+
+	if (wrqu->mode == priv->ieee->iw_mode)
+		return 0;
+
+	down(&priv->action_sem);
+	if (!(priv->status & STATUS_INITIALIZED)) {
+		err = -EIO;
+		goto done;
+	}
+
+	switch (wrqu->mode) {
+#ifdef CONFIG_IPW2100_MONITOR
+	case IW_MODE_MONITOR:
+		err = ipw2100_switch_mode(priv, IW_MODE_MONITOR);
+		break;
+#endif /* CONFIG_IPW2100_MONITOR */
+	case IW_MODE_ADHOC:
+		err = ipw2100_switch_mode(priv, IW_MODE_ADHOC);
+		break;
+	case IW_MODE_INFRA:
+	case IW_MODE_AUTO:
+	default:
+		err = ipw2100_switch_mode(priv, IW_MODE_INFRA);
+		break;
+	}
+
+done:
+	up(&priv->action_sem);
+ 	return err;
+}
+
+static int ipw2100_wx_get_mode(struct net_device *dev,
+			       struct iw_request_info *info,
+			       union iwreq_data *wrqu, char *extra)
+{
+	/*
+	 * This can be called at any time.  No action lock required
+	 */
+
+	struct ipw2100_priv *priv = ieee80211_priv(dev);
+
+	wrqu->mode = priv->ieee->iw_mode;
+	IPW_DEBUG_WX("GET Mode -> %d\n", wrqu->mode);
+
+	return 0;
+}
+
+
+#define POWER_MODES 5
+
+/* Values are in microsecond */
+const s32 timeout_duration[POWER_MODES] = {
+	350000,
+	250000,
+	75000,
+	37000,
+	25000,
+};
+
+const s32 period_duration[POWER_MODES] = {
+	400000,
+	700000,
+	1000000,
+	1000000,
+	1000000
+};
+
+static int ipw2100_wx_get_range(struct net_device *dev,
+				struct iw_request_info *info,
+				union iwreq_data *wrqu, char *extra)
+{
+	/*
+	 * This can be called at any time.  No action lock required
+	 */
+
+	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct iw_range *range = (struct iw_range *)extra;
+	u16 val;
+	int i, level;
+
+	wrqu->data.length = sizeof(*range);
+	memset(range, 0, sizeof(*range));
+
+	/* Let's try to keep this struct in the same order as in
+	 * linux/include/wireless.h
+	 */
+
+	/* TODO: See what values we can set, and remove the ones we can't
+	 * set, or fill them with some default data.
+	 */
+
+	/* ~5 Mb/s real (802.11b) */
+	range->throughput = 5 * 1000 * 1000;
+
+//	range->sensitivity;	/* signal level threshold range */
+
+	range->max_qual.qual = 100;
+	/* TODO: Find real max RSSI and stick here */
+	range->max_qual.level = 0;
+	range->max_qual.noise = 0;
+	range->max_qual.updated = 7; /* Updated all three */
+
+	range->avg_qual.qual = 70; /* > 8% missed beacons is 'bad' */
+	/* TODO: Find real 'good' to 'bad' threshol value for RSSI */
+	range->avg_qual.level = 20 + IPW2100_RSSI_TO_DBM;
+	range->avg_qual.noise = 0;
+	range->avg_qual.updated = 7; /* Updated all three */
+
+	range->num_bitrates = RATE_COUNT;
+
+	for (i = 0; i < RATE_COUNT && i < IW_MAX_BITRATES; i++) {
+		range->bitrate[i] = ipw2100_rates_11b[i];
+	}
+
+	range->min_rts = MIN_RTS_THRESHOLD;
+	range->max_rts = MAX_RTS_THRESHOLD;
+	range->min_frag = MIN_FRAG_THRESHOLD;
+	range->max_frag = MAX_FRAG_THRESHOLD;
+
+	range->min_pmp = period_duration[0];	/* Minimal PM period */
+	range->max_pmp = period_duration[POWER_MODES-1];/* Maximal PM period */
+	range->min_pmt = timeout_duration[POWER_MODES-1];	/* Minimal PM timeout */
+	range->max_pmt = timeout_duration[0];/* Maximal PM timeout */
+
+        /* How to decode max/min PM period */
+	range->pmp_flags = IW_POWER_PERIOD;
+        /* How to decode max/min PM period */
+	range->pmt_flags = IW_POWER_TIMEOUT;
+	/* What PM options are supported */
+	range->pm_capa = IW_POWER_TIMEOUT | IW_POWER_PERIOD;
+
+	range->encoding_size[0] = 5;
+	range->encoding_size[1] = 13;           /* Different token sizes */
+	range->num_encoding_sizes = 2;		/* Number of entry in the list */
+	range->max_encoding_tokens = WEP_KEYS;  /* Max number of tokens */
+//	range->encoding_login_index;		/* token index for login token */
+
+	if (priv->ieee->iw_mode == IW_MODE_ADHOC) {
+		range->txpower_capa = IW_TXPOW_DBM;
+		range->num_txpower = IW_MAX_TXPOWER;
+		for (i = 0, level = (IPW_TX_POWER_MAX_DBM * 16); i < IW_MAX_TXPOWER;
+		     i++, level -= ((IPW_TX_POWER_MAX_DBM - IPW_TX_POWER_MIN_DBM) * 16) /
+			     (IW_MAX_TXPOWER - 1))
+			range->txpower[i] = level / 16;
+	} else {
+		range->txpower_capa = 0;
+		range->num_txpower = 0;
+	}
+
+
+	/* Set the Wireless Extension versions */
+	range->we_version_compiled = WIRELESS_EXT;
+	range->we_version_source = 16;
+
+//	range->retry_capa;	/* What retry options are supported */
+//	range->retry_flags;	/* How to decode max/min retry limit */
+//	range->r_time_flags;	/* How to decode max/min retry life */
+//	range->min_retry;	/* Minimal number of retries */
+//	range->max_retry;	/* Maximal number of retries */
+//	range->min_r_time;	/* Minimal retry lifetime */
+//	range->max_r_time;	/* Maximal retry lifetime */
+
+        range->num_channels = FREQ_COUNT;
+
+	val = 0;
+	for (i = 0; i < FREQ_COUNT; i++) {
+		// TODO: Include only legal frequencies for some countries
+//		if (local->channel_mask & (1 << i)) {
+			range->freq[val].i = i + 1;
+			range->freq[val].m = ipw2100_frequencies[i] * 100000;
+			range->freq[val].e = 1;
+			val++;
+//		}
+		if (val == IW_MAX_FREQUENCIES)
+		break;
+	}
+	range->num_frequency = val;
+
+	IPW_DEBUG_WX("GET Range\n");
+
+	return 0;
+}
+
+static int ipw2100_wx_set_wap(struct net_device *dev,
+			      struct iw_request_info *info,
+			      union iwreq_data *wrqu, char *extra)
+{
+	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	int err = 0;
+
+	static const unsigned char any[] = {
+		0xff, 0xff, 0xff, 0xff, 0xff, 0xff
+	};
+	static const unsigned char off[] = {
+		0x00, 0x00, 0x00, 0x00, 0x00, 0x00
+	};
+
+	// sanity checks
+	if (wrqu->ap_addr.sa_family != ARPHRD_ETHER)
+		return -EINVAL;
+
+	down(&priv->action_sem);
+	if (!(priv->status & STATUS_INITIALIZED)) {
+		err = -EIO;
+		goto done;
+	}
+
+	if (!memcmp(any, wrqu->ap_addr.sa_data, ETH_ALEN) ||
+	    !memcmp(off, wrqu->ap_addr.sa_data, ETH_ALEN)) {
+		/* we disable mandatory BSSID association */
+		IPW_DEBUG_WX("exit - disable mandatory BSSID\n");
+		priv->config &= ~CFG_STATIC_BSSID;
+		err = ipw2100_set_mandatory_bssid(priv, NULL, 0);
+		goto done;
+	}
+
+	priv->config |= CFG_STATIC_BSSID;
+	memcpy(priv->mandatory_bssid_mac, wrqu->ap_addr.sa_data, ETH_ALEN);
+
+	err = ipw2100_set_mandatory_bssid(priv, wrqu->ap_addr.sa_data, 0);
+
+	IPW_DEBUG_WX("SET BSSID -> %02X:%02X:%02X:%02X:%02X:%02X\n",
+		     wrqu->ap_addr.sa_data[0] & 0xff,
+		     wrqu->ap_addr.sa_data[1] & 0xff,
+		     wrqu->ap_addr.sa_data[2] & 0xff,
+		     wrqu->ap_addr.sa_data[3] & 0xff,
+		     wrqu->ap_addr.sa_data[4] & 0xff,
+		     wrqu->ap_addr.sa_data[5] & 0xff);
+
+ done:
+	up(&priv->action_sem);
+	return err;
+}
+
+static int ipw2100_wx_get_wap(struct net_device *dev,
+			      struct iw_request_info *info,
+			      union iwreq_data *wrqu, char *extra)
+{
+	/*
+	 * This can be called at any time.  No action lock required
+	 */
+
+	struct ipw2100_priv *priv = ieee80211_priv(dev);
+
+	/* If we are associated, trying to associate, or have a statically
+	 * configured BSSID then return that; otherwise return ANY */
+	if (priv->config & CFG_STATIC_BSSID ||
+	    priv->status & STATUS_ASSOCIATED) {
+		wrqu->ap_addr.sa_family = ARPHRD_ETHER;
+		memcpy(wrqu->ap_addr.sa_data, &priv->bssid, ETH_ALEN);
+	} else
+		memset(wrqu->ap_addr.sa_data, 0, ETH_ALEN);
+
+	IPW_DEBUG_WX("Getting WAP BSSID: " MAC_FMT "\n",
+		     MAC_ARG(wrqu->ap_addr.sa_data));
+	return 0;
+}
+
+static int ipw2100_wx_set_essid(struct net_device *dev,
+				struct iw_request_info *info,
+				union iwreq_data *wrqu, char *extra)
+{
+	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	char *essid = ""; /* ANY */
+	int length = 0;
+	int err = 0;
+
+	down(&priv->action_sem);
+	if (!(priv->status & STATUS_INITIALIZED)) {
+		err = -EIO;
+		goto done;
+	}
+
+	if (wrqu->essid.flags && wrqu->essid.length) {
+		length = wrqu->essid.length - 1;
+		essid = extra;
+	}
+
+	if (length == 0) {
+		IPW_DEBUG_WX("Setting ESSID to ANY\n");
+		priv->config &= ~CFG_STATIC_ESSID;
+		err = ipw2100_set_essid(priv, NULL, 0, 0);
+		goto done;
+	}
+
+	length = min(length, IW_ESSID_MAX_SIZE);
+
+	priv->config |= CFG_STATIC_ESSID;
+
+	if (priv->essid_len == length && !memcmp(priv->essid, extra, length)) {
+		IPW_DEBUG_WX("ESSID set to current ESSID.\n");
+		err = 0;
+		goto done;
+	}
+
+	IPW_DEBUG_WX("Setting ESSID: '%s' (%d)\n", escape_essid(essid, length),
+		     length);
+
+	priv->essid_len = length;
+	memcpy(priv->essid, essid, priv->essid_len);
+
+	err = ipw2100_set_essid(priv, essid, length, 0);
+
+ done:
+	up(&priv->action_sem);
+	return err;
+}
+
+static int ipw2100_wx_get_essid(struct net_device *dev,
+				struct iw_request_info *info,
+				union iwreq_data *wrqu, char *extra)
+{
+	/*
+	 * This can be called at any time.  No action lock required
+	 */
+
+	struct ipw2100_priv *priv = ieee80211_priv(dev);
+
+	/* If we are associated, trying to associate, or have a statically
+	 * configured ESSID then return that; otherwise return ANY */
+	if (priv->config & CFG_STATIC_ESSID ||
+	    priv->status & STATUS_ASSOCIATED) {
+		IPW_DEBUG_WX("Getting essid: '%s'\n",
+			     escape_essid(priv->essid, priv->essid_len));
+		memcpy(extra, priv->essid, priv->essid_len);
+		wrqu->essid.length = priv->essid_len;
+		wrqu->essid.flags = 1; /* active */
+	} else {
+		IPW_DEBUG_WX("Getting essid: ANY\n");
+		wrqu->essid.length = 0;
+		wrqu->essid.flags = 0; /* active */
+	}
+
+	return 0;
+}
+
+static int ipw2100_wx_set_nick(struct net_device *dev,
+			       struct iw_request_info *info,
+			       union iwreq_data *wrqu, char *extra)
+{
+	/*
+	 * This can be called at any time.  No action lock required
+	 */
+
+	struct ipw2100_priv *priv = ieee80211_priv(dev);
+
+	if (wrqu->data.length > IW_ESSID_MAX_SIZE)
+		return -E2BIG;
+
+	wrqu->data.length = min((size_t)wrqu->data.length, sizeof(priv->nick));
+	memset(priv->nick, 0, sizeof(priv->nick));
+	memcpy(priv->nick, extra,  wrqu->data.length);
+
+	IPW_DEBUG_WX("SET Nickname -> %s \n", priv->nick);
+
+	return 0;
+}
+
+static int ipw2100_wx_get_nick(struct net_device *dev,
+			       struct iw_request_info *info,
+			       union iwreq_data *wrqu, char *extra)
+{
+	/*
+	 * This can be called at any time.  No action lock required
+	 */
+
+	struct ipw2100_priv *priv = ieee80211_priv(dev);
+
+	wrqu->data.length = strlen(priv->nick) + 1;
+	memcpy(extra, priv->nick, wrqu->data.length);
+	wrqu->data.flags = 1; /* active */
+
+	IPW_DEBUG_WX("GET Nickname -> %s \n", extra);
+
+	return 0;
+}
+
+static int ipw2100_wx_set_rate(struct net_device *dev,
+			       struct iw_request_info *info,
+			       union iwreq_data *wrqu, char *extra)
+{
+	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	u32 target_rate = wrqu->bitrate.value;
+	u32 rate;
+	int err = 0;
+
+	down(&priv->action_sem);
+	if (!(priv->status & STATUS_INITIALIZED)) {
+		err = -EIO;
+		goto done;
+	}
+
+	rate = 0;
+
+	if (target_rate == 1000000 ||
+	    (!wrqu->bitrate.fixed && target_rate > 1000000))
+		rate |= TX_RATE_1_MBIT;
+	if (target_rate == 2000000 ||
+	    (!wrqu->bitrate.fixed && target_rate > 2000000))
+		rate |= TX_RATE_2_MBIT;
+	if (target_rate == 5500000 ||
+	    (!wrqu->bitrate.fixed && target_rate > 5500000))
+		rate |= TX_RATE_5_5_MBIT;
+	if (target_rate == 11000000 ||
+	    (!wrqu->bitrate.fixed && target_rate > 11000000))
+		rate |= TX_RATE_11_MBIT;
+	if (rate == 0)
+		rate = DEFAULT_TX_RATES;
+
+	err = ipw2100_set_tx_rates(priv, rate, 0);
+
+	IPW_DEBUG_WX("SET Rate -> %04X \n", rate);
+ done:
+	up(&priv->action_sem);
+	return err;
+}
+
+
+static int ipw2100_wx_get_rate(struct net_device *dev,
+			       struct iw_request_info *info,
+			       union iwreq_data *wrqu, char *extra)
+{
+	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	int val;
+	int len = sizeof(val);
+	int err = 0;
+
+	if (!(priv->status & STATUS_ENABLED) ||
+	    priv->status & STATUS_RF_KILL_MASK ||
+	    !(priv->status & STATUS_ASSOCIATED)) {
+		wrqu->bitrate.value = 0;
+		return 0;
+	}
+
+	down(&priv->action_sem);
+	if (!(priv->status & STATUS_INITIALIZED)) {
+		err = -EIO;
+		goto done;
+	}
+
+	err = ipw2100_get_ordinal(priv, IPW_ORD_CURRENT_TX_RATE, &val, &len);
+	if (err) {
+		IPW_DEBUG_WX("failed querying ordinals.\n");
+		return err;
+	}
+
+	switch (val & TX_RATE_MASK) {
+	case TX_RATE_1_MBIT:
+		wrqu->bitrate.value = 1000000;
+		break;
+	case TX_RATE_2_MBIT:
+		wrqu->bitrate.value = 2000000;
+		break;
+	case TX_RATE_5_5_MBIT:
+		wrqu->bitrate.value = 5500000;
+		break;
+	case TX_RATE_11_MBIT:
+		wrqu->bitrate.value = 11000000;
+		break;
+	default:
+		wrqu->bitrate.value = 0;
+	}
+
+	IPW_DEBUG_WX("GET Rate -> %d \n", wrqu->bitrate.value);
+
+ done:
+	up(&priv->action_sem);
+	return err;
+}
+
+static int ipw2100_wx_set_rts(struct net_device *dev,
+			      struct iw_request_info *info,
+			      union iwreq_data *wrqu, char *extra)
+{
+	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	int value, err;
+
+	/* Auto RTS not yet supported */
+	if (wrqu->rts.fixed == 0)
+		return -EINVAL;
+
+	down(&priv->action_sem);
+	if (!(priv->status & STATUS_INITIALIZED)) {
+		err = -EIO;
+		goto done;
+	}
+
+	if (wrqu->rts.disabled)
+		value = priv->rts_threshold | RTS_DISABLED;
+	else {
+		if (wrqu->rts.value < 1 ||
+		    wrqu->rts.value > 2304) {
+			err = -EINVAL;
+			goto done;
+		}
+		value = wrqu->rts.value;
+	}
+
+	err = ipw2100_set_rts_threshold(priv, value);
+
+	IPW_DEBUG_WX("SET RTS Threshold -> 0x%08X \n", value);
+ done:
+	up(&priv->action_sem);
+	return err;
+}
+
+static int ipw2100_wx_get_rts(struct net_device *dev,
+			      struct iw_request_info *info,
+			      union iwreq_data *wrqu, char *extra)
+{
+	/*
+	 * This can be called at any time.  No action lock required
+	 */
+
+	struct ipw2100_priv *priv = ieee80211_priv(dev);
+
+	wrqu->rts.value = priv->rts_threshold & ~RTS_DISABLED;
+	wrqu->rts.fixed = 1; /* no auto select */
+
+	/* If RTS is set to the default value, then it is disabled */
+	wrqu->rts.disabled = (priv->rts_threshold & RTS_DISABLED) ? 1 : 0;
+
+	IPW_DEBUG_WX("GET RTS Threshold -> 0x%08X \n", wrqu->rts.value);
+
+	return 0;
+}
+
+static int ipw2100_wx_set_txpow(struct net_device *dev,
+				struct iw_request_info *info,
+				union iwreq_data *wrqu, char *extra)
+{
+	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	int err = 0, value;
+
+	if (priv->ieee->iw_mode != IW_MODE_ADHOC)
+		return -EINVAL;
+
+	if (wrqu->txpower.disabled == 1 || wrqu->txpower.fixed == 0)
+		value = IPW_TX_POWER_DEFAULT;
+	else {
+		if (wrqu->txpower.value < IPW_TX_POWER_MIN_DBM ||
+		    wrqu->txpower.value > IPW_TX_POWER_MAX_DBM)
+			return -EINVAL;
+
+		value = (wrqu->txpower.value - IPW_TX_POWER_MIN_DBM) * 16 /
+			(IPW_TX_POWER_MAX_DBM - IPW_TX_POWER_MIN_DBM);
+	}
+
+	down(&priv->action_sem);
+	if (!(priv->status & STATUS_INITIALIZED)) {
+		err = -EIO;
+		goto done;
+	}
+
+	err = ipw2100_set_tx_power(priv, value);
+
+	IPW_DEBUG_WX("SET TX Power -> %d \n", value);
+
+ done:
+	up(&priv->action_sem);
+	return err;
+}
+
+static int ipw2100_wx_get_txpow(struct net_device *dev,
+				struct iw_request_info *info,
+				union iwreq_data *wrqu, char *extra)
+{
+	/*
+	 * This can be called at any time.  No action lock required
+	 */
+
+	struct ipw2100_priv *priv = ieee80211_priv(dev);
+
+	if (priv->ieee->iw_mode != IW_MODE_ADHOC) {
+		wrqu->power.disabled = 1;
+		return 0;
+	}
+
+	if (priv->tx_power == IPW_TX_POWER_DEFAULT) {
+		wrqu->power.fixed = 0;
+		wrqu->power.value = IPW_TX_POWER_MAX_DBM;
+		wrqu->power.disabled = 1;
+	} else {
+		wrqu->power.disabled = 0;
+		wrqu->power.fixed = 1;
+		wrqu->power.value =
+			(priv->tx_power *
+			 (IPW_TX_POWER_MAX_DBM - IPW_TX_POWER_MIN_DBM)) /
+			(IPW_TX_POWER_MAX - IPW_TX_POWER_MIN) +
+			IPW_TX_POWER_MIN_DBM;
+	}
+
+	wrqu->power.flags = IW_TXPOW_DBM;
+
+	IPW_DEBUG_WX("GET TX Power -> %d \n", wrqu->power.value);
+
+	return 0;
+}
+
+static int ipw2100_wx_set_frag(struct net_device *dev,
+			       struct iw_request_info *info,
+			       union iwreq_data *wrqu, char *extra)
+{
+	/*
+	 * This can be called at any time.  No action lock required
+	 */
+
+	struct ipw2100_priv *priv = ieee80211_priv(dev);
+
+	if (!wrqu->frag.fixed)
+		return -EINVAL;
+
+	if (wrqu->frag.disabled) {
+		priv->frag_threshold |= FRAG_DISABLED;
+		priv->ieee->fts = DEFAULT_FTS;
+	} else {
+		if (wrqu->frag.value < MIN_FRAG_THRESHOLD ||
+		    wrqu->frag.value > MAX_FRAG_THRESHOLD)
+			return -EINVAL;
+
+		priv->ieee->fts = wrqu->frag.value & ~0x1;
+		priv->frag_threshold = priv->ieee->fts;
+	}
+
+	IPW_DEBUG_WX("SET Frag Threshold -> %d \n", priv->ieee->fts);
+
+	return 0;
+}
+
+static int ipw2100_wx_get_frag(struct net_device *dev,
+			       struct iw_request_info *info,
+			       union iwreq_data *wrqu, char *extra)
+{
+	/*
+	 * This can be called at any time.  No action lock required
+	 */
+
+	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	wrqu->frag.value = priv->frag_threshold & ~FRAG_DISABLED;
+	wrqu->frag.fixed = 0;	/* no auto select */
+	wrqu->frag.disabled = (priv->frag_threshold & FRAG_DISABLED) ? 1 : 0;
+
+	IPW_DEBUG_WX("GET Frag Threshold -> %d \n", wrqu->frag.value);
+
+	return 0;
+}
+
+static int ipw2100_wx_set_retry(struct net_device *dev,
+				struct iw_request_info *info,
+				union iwreq_data *wrqu, char *extra)
+{
+	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	int err = 0;
+
+	if (wrqu->retry.flags & IW_RETRY_LIFETIME ||
+	    wrqu->retry.disabled)
+		return -EINVAL;
+
+	if (!(wrqu->retry.flags & IW_RETRY_LIMIT))
+		return 0;
+
+	down(&priv->action_sem);
+	if (!(priv->status & STATUS_INITIALIZED)) {
+		err = -EIO;
+		goto done;
+	}
+
+	if (wrqu->retry.flags & IW_RETRY_MIN) {
+		err = ipw2100_set_short_retry(priv, wrqu->retry.value);
+		IPW_DEBUG_WX("SET Short Retry Limit -> %d \n",
+		       wrqu->retry.value);
+		goto done;
+	}
+
+	if (wrqu->retry.flags & IW_RETRY_MAX) {
+		err = ipw2100_set_long_retry(priv, wrqu->retry.value);
+		IPW_DEBUG_WX("SET Long Retry Limit -> %d \n",
+		       wrqu->retry.value);
+		goto done;
+	}
+
+	err = ipw2100_set_short_retry(priv, wrqu->retry.value);
+	if (!err)
+		err = ipw2100_set_long_retry(priv, wrqu->retry.value);
+
+	IPW_DEBUG_WX("SET Both Retry Limits -> %d \n", wrqu->retry.value);
+
+ done:
+	up(&priv->action_sem);
+	return err;
+}
+
+static int ipw2100_wx_get_retry(struct net_device *dev,
+				struct iw_request_info *info,
+				union iwreq_data *wrqu, char *extra)
+{
+	/*
+	 * This can be called at any time.  No action lock required
+	 */
+
+	struct ipw2100_priv *priv = ieee80211_priv(dev);
+
+	wrqu->retry.disabled = 0; /* can't be disabled */
+
+	if ((wrqu->retry.flags & IW_RETRY_TYPE) ==
+	    IW_RETRY_LIFETIME)
+		return -EINVAL;
+
+	if (wrqu->retry.flags & IW_RETRY_MAX) {
+		wrqu->retry.flags = IW_RETRY_LIMIT & IW_RETRY_MAX;
+		wrqu->retry.value = priv->long_retry_limit;
+	} else {
+		wrqu->retry.flags =
+		    (priv->short_retry_limit !=
+		     priv->long_retry_limit) ?
+		    IW_RETRY_LIMIT & IW_RETRY_MIN : IW_RETRY_LIMIT;
+
+		wrqu->retry.value = priv->short_retry_limit;
+	}
+
+	IPW_DEBUG_WX("GET Retry -> %d \n", wrqu->retry.value);
+
+	return 0;
+}
+
+static int ipw2100_wx_set_scan(struct net_device *dev,
+			       struct iw_request_info *info,
+			       union iwreq_data *wrqu, char *extra)
+{
+	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	int err = 0;
+
+	down(&priv->action_sem);
+	if (!(priv->status & STATUS_INITIALIZED)) {
+		err = -EIO;
+		goto done;
+	}
+
+	IPW_DEBUG_WX("Initiating scan...\n");
+	if (ipw2100_set_scan_options(priv) ||
+	    ipw2100_start_scan(priv)) {
+		IPW_DEBUG_WX("Start scan failed.\n");
+
+		/* TODO: Mark a scan as pending so when hardware initialized
+		 *       a scan starts */
+	}
+
+ done:
+	up(&priv->action_sem);
+	return err;
+}
+
+static int ipw2100_wx_get_scan(struct net_device *dev,
+			       struct iw_request_info *info,
+			       union iwreq_data *wrqu, char *extra)
+{
+	/*
+	 * This can be called at any time.  No action lock required
+	 */
+
+	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	return ieee80211_wx_get_scan(priv->ieee, info, wrqu, extra);
+}
+
+
+/*
+ * Implementation based on code in hostap-driver v0.1.3 hostap_ioctl.c
+ */
+static int ipw2100_wx_set_encode(struct net_device *dev,
+				 struct iw_request_info *info,
+				 union iwreq_data *wrqu, char *key)
+{
+	/*
+	 * No check of STATUS_INITIALIZED required
+	 */
+
+	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	return ieee80211_wx_set_encode(priv->ieee, info, wrqu, key);
+}
+
+static int ipw2100_wx_get_encode(struct net_device *dev,
+				 struct iw_request_info *info,
+				 union iwreq_data *wrqu, char *key)
+{
+	/*
+	 * This can be called at any time.  No action lock required
+	 */
+
+	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	return ieee80211_wx_get_encode(priv->ieee, info, wrqu, key);
+}
+
+static int ipw2100_wx_set_power(struct net_device *dev,
+			        struct iw_request_info *info,
+			        union iwreq_data *wrqu, char *extra)
+{
+	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	int err = 0;
+
+	down(&priv->action_sem);
+	if (!(priv->status & STATUS_INITIALIZED)) {
+		err = -EIO;
+		goto done;
+	}
+
+	if (wrqu->power.disabled) {
+		priv->power_mode = IPW_POWER_LEVEL(priv->power_mode);
+		err = ipw2100_set_power_mode(priv, IPW_POWER_MODE_CAM);
+		IPW_DEBUG_WX("SET Power Management Mode -> off\n");
+		goto done;
+	}
+
+	switch (wrqu->power.flags & IW_POWER_MODE) {
+	case IW_POWER_ON:    /* If not specified */
+	case IW_POWER_MODE:  /* If set all mask */
+	case IW_POWER_ALL_R: /* If explicitely state all */
+		break;
+	default: /* Otherwise we don't support it */
+		IPW_DEBUG_WX("SET PM Mode: %X not supported.\n",
+			     wrqu->power.flags);
+		err = -EOPNOTSUPP;
+		goto done;
+	}
+
+	/* If the user hasn't specified a power management mode yet, default
+	 * to BATTERY */
+	priv->power_mode = IPW_POWER_ENABLED | priv->power_mode;
+	err = ipw2100_set_power_mode(priv, IPW_POWER_LEVEL(priv->power_mode));
+
+	IPW_DEBUG_WX("SET Power Management Mode -> 0x%02X\n",
+		     priv->power_mode);
+
+ done:
+	up(&priv->action_sem);
+	return err;
+
+}
+
+static int ipw2100_wx_get_power(struct net_device *dev,
+			        struct iw_request_info *info,
+			        union iwreq_data *wrqu, char *extra)
+{
+	/*
+	 * This can be called at any time.  No action lock required
+	 */
+
+	struct ipw2100_priv *priv = ieee80211_priv(dev);
+
+	if (!(priv->power_mode & IPW_POWER_ENABLED)) {
+		wrqu->power.disabled = 1;
+	} else {
+		wrqu->power.disabled = 0;
+		wrqu->power.flags = 0;
+	}
+
+	IPW_DEBUG_WX("GET Power Management Mode -> %02X\n", priv->power_mode);
+
+	return 0;
+}
+
+
+/*
+ *
+ * IWPRIV handlers
+ *
+ */
+#ifdef CONFIG_IPW2100_MONITOR
+static int ipw2100_wx_set_promisc(struct net_device *dev,
+				  struct iw_request_info *info,
+				  union iwreq_data *wrqu, char *extra)
+{
+	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	int *parms = (int *)extra;
+	int enable = (parms[0] > 0);
+	int err = 0;
+
+	down(&priv->action_sem);
+	if (!(priv->status & STATUS_INITIALIZED)) {
+		err = -EIO;
+		goto done;
+	}
+
+	if (enable) {
+		if (priv->ieee->iw_mode == IW_MODE_MONITOR) {
+			err = ipw2100_set_channel(priv, parms[1], 0);
+			goto done;
+		}
+		priv->channel = parms[1];
+		err = ipw2100_switch_mode(priv, IW_MODE_MONITOR);
+	} else {
+		if (priv->ieee->iw_mode == IW_MODE_MONITOR)
+			err = ipw2100_switch_mode(priv, priv->last_mode);
+	}
+ done:
+	up(&priv->action_sem);
+	return err;
+}
+
+static int ipw2100_wx_reset(struct net_device *dev,
+			    struct iw_request_info *info,
+			    union iwreq_data *wrqu, char *extra)
+{
+	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	if (priv->status & STATUS_INITIALIZED)
+		schedule_reset(priv);
+	return 0;
+}
+
+#endif
+
+static int ipw2100_wx_set_powermode(struct net_device *dev,
+				    struct iw_request_info *info,
+				    union iwreq_data *wrqu, char *extra)
+{
+	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	int err = 0, mode = *(int *)extra;
+
+	down(&priv->action_sem);
+	if (!(priv->status & STATUS_INITIALIZED)) {
+		err = -EIO;
+		goto done;
+	}
+
+	if ((mode < 1) || (mode > POWER_MODES))
+		mode = IPW_POWER_AUTO;
+
+	if (priv->power_mode != mode)
+		err = ipw2100_set_power_mode(priv, mode);
+ done:
+	up(&priv->action_sem);
+	return err;
+}
+
+#define MAX_POWER_STRING 80
+static int ipw2100_wx_get_powermode(struct net_device *dev,
+				    struct iw_request_info *info,
+				    union iwreq_data *wrqu, char *extra)
+{
+	/*
+	 * This can be called at any time.  No action lock required
+	 */
+
+	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	int level = IPW_POWER_LEVEL(priv->power_mode);
+	s32 timeout, period;
+
+	if (!(priv->power_mode & IPW_POWER_ENABLED)) {
+		snprintf(extra, MAX_POWER_STRING,
+			 "Power save level: %d (Off)", level);
+	} else {
+		switch (level) {
+		case IPW_POWER_MODE_CAM:
+			snprintf(extra, MAX_POWER_STRING,
+				 "Power save level: %d (None)", level);
+			break;
+		case IPW_POWER_AUTO:
+		snprintf(extra, MAX_POWER_STRING,
+			 "Power save level: %d (Auto)", 0);
+			break;
+		default:
+			timeout = timeout_duration[level - 1] / 1000;
+			period = period_duration[level - 1] / 1000;
+			snprintf(extra, MAX_POWER_STRING,
+				 "Power save level: %d "
+				 "(Timeout %dms, Period %dms)",
+				 level, timeout, period);
+		}
+	}
+
+	wrqu->data.length = strlen(extra) + 1;
+
+	return 0;
+}
+
+
+static int ipw2100_wx_set_preamble(struct net_device *dev,
+				   struct iw_request_info *info,
+				   union iwreq_data *wrqu, char *extra)
+{
+	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	int err, mode = *(int *)extra;
+
+	down(&priv->action_sem);
+	if (!(priv->status & STATUS_INITIALIZED)) {
+		err = -EIO;
+		goto done;
+	}
+
+	if (mode == 1)
+		priv->config |= CFG_LONG_PREAMBLE;
+	else if (mode == 0)
+		priv->config &= ~CFG_LONG_PREAMBLE;
+	else {
+		err = -EINVAL;
+		goto done;
+	}
+
+	err = ipw2100_system_config(priv, 0);
+
+done:
+	up(&priv->action_sem);
+	return err;
+}
+
+static int ipw2100_wx_get_preamble(struct net_device *dev,
+				    struct iw_request_info *info,
+				    union iwreq_data *wrqu, char *extra)
+{
+	/*
+	 * This can be called at any time.  No action lock required
+	 */
+
+	struct ipw2100_priv *priv = ieee80211_priv(dev);
+
+	if (priv->config & CFG_LONG_PREAMBLE)
+		snprintf(wrqu->name, IFNAMSIZ, "long (1)");
+	else
+		snprintf(wrqu->name, IFNAMSIZ, "auto (0)");
+
+	return 0;
+}
+
+static iw_handler ipw2100_wx_handlers[] =
+{
+        NULL,                     /* SIOCSIWCOMMIT */
+        ipw2100_wx_get_name,      /* SIOCGIWNAME */
+        NULL,                     /* SIOCSIWNWID */
+        NULL,                     /* SIOCGIWNWID */
+        ipw2100_wx_set_freq,      /* SIOCSIWFREQ */
+        ipw2100_wx_get_freq,      /* SIOCGIWFREQ */
+        ipw2100_wx_set_mode,      /* SIOCSIWMODE */
+        ipw2100_wx_get_mode,      /* SIOCGIWMODE */
+        NULL,                     /* SIOCSIWSENS */
+        NULL,                     /* SIOCGIWSENS */
+        NULL,                     /* SIOCSIWRANGE */
+        ipw2100_wx_get_range,     /* SIOCGIWRANGE */
+        NULL,                     /* SIOCSIWPRIV */
+        NULL,                     /* SIOCGIWPRIV */
+        NULL,                     /* SIOCSIWSTATS */
+        NULL,                     /* SIOCGIWSTATS */
+        NULL,                     /* SIOCSIWSPY */
+        NULL,                     /* SIOCGIWSPY */
+        NULL,                     /* SIOCGIWTHRSPY */
+        NULL,                     /* SIOCWIWTHRSPY */
+        ipw2100_wx_set_wap,       /* SIOCSIWAP */
+        ipw2100_wx_get_wap,       /* SIOCGIWAP */
+        NULL,                     /* -- hole -- */
+        NULL,                     /* SIOCGIWAPLIST -- depricated */
+        ipw2100_wx_set_scan,      /* SIOCSIWSCAN */
+        ipw2100_wx_get_scan,      /* SIOCGIWSCAN */
+        ipw2100_wx_set_essid,     /* SIOCSIWESSID */
+        ipw2100_wx_get_essid,     /* SIOCGIWESSID */
+        ipw2100_wx_set_nick,      /* SIOCSIWNICKN */
+        ipw2100_wx_get_nick,      /* SIOCGIWNICKN */
+        NULL,                     /* -- hole -- */
+        NULL,                     /* -- hole -- */
+        ipw2100_wx_set_rate,      /* SIOCSIWRATE */
+        ipw2100_wx_get_rate,      /* SIOCGIWRATE */
+        ipw2100_wx_set_rts,       /* SIOCSIWRTS */
+        ipw2100_wx_get_rts,       /* SIOCGIWRTS */
+        ipw2100_wx_set_frag,      /* SIOCSIWFRAG */
+        ipw2100_wx_get_frag,      /* SIOCGIWFRAG */
+        ipw2100_wx_set_txpow,     /* SIOCSIWTXPOW */
+        ipw2100_wx_get_txpow,     /* SIOCGIWTXPOW */
+        ipw2100_wx_set_retry,     /* SIOCSIWRETRY */
+        ipw2100_wx_get_retry,     /* SIOCGIWRETRY */
+        ipw2100_wx_set_encode,    /* SIOCSIWENCODE */
+        ipw2100_wx_get_encode,    /* SIOCGIWENCODE */
+        ipw2100_wx_set_power,     /* SIOCSIWPOWER */
+        ipw2100_wx_get_power,     /* SIOCGIWPOWER */
+};
+
+#define IPW2100_PRIV_SET_MONITOR	SIOCIWFIRSTPRIV
+#define IPW2100_PRIV_RESET		SIOCIWFIRSTPRIV+1
+#define IPW2100_PRIV_SET_POWER		SIOCIWFIRSTPRIV+2
+#define IPW2100_PRIV_GET_POWER		SIOCIWFIRSTPRIV+3
+#define IPW2100_PRIV_SET_LONGPREAMBLE	SIOCIWFIRSTPRIV+4
+#define IPW2100_PRIV_GET_LONGPREAMBLE	SIOCIWFIRSTPRIV+5
+
+static const struct iw_priv_args ipw2100_private_args[] = {
+
+#ifdef CONFIG_IPW2100_MONITOR
+	{
+		IPW2100_PRIV_SET_MONITOR,
+		IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 2, 0, "monitor"
+	},
+	{
+		IPW2100_PRIV_RESET,
+		IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 0, 0, "reset"
+	},
+#endif /* CONFIG_IPW2100_MONITOR */
+
+	{
+		IPW2100_PRIV_SET_POWER,
+		IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1, 0, "set_power"
+	},
+	{
+		IPW2100_PRIV_GET_POWER,
+		0, IW_PRIV_TYPE_CHAR | IW_PRIV_SIZE_FIXED | MAX_POWER_STRING, "get_power"
+	},
+	{
+		IPW2100_PRIV_SET_LONGPREAMBLE,
+		IW_PRIV_TYPE_INT | IW_PRIV_SIZE_FIXED | 1, 0, "set_preamble"
+	},
+	{
+		IPW2100_PRIV_GET_LONGPREAMBLE,
+		0, IW_PRIV_TYPE_CHAR | IW_PRIV_SIZE_FIXED | IFNAMSIZ, "get_preamble"
+	},
+};
+
+static iw_handler ipw2100_private_handler[] = {
+#ifdef CONFIG_IPW2100_MONITOR
+	ipw2100_wx_set_promisc,
+	ipw2100_wx_reset,
+#else /* CONFIG_IPW2100_MONITOR */
+	NULL,
+	NULL,
+#endif /* CONFIG_IPW2100_MONITOR */
+	ipw2100_wx_set_powermode,
+	ipw2100_wx_get_powermode,
+	ipw2100_wx_set_preamble,
+	ipw2100_wx_get_preamble,
+};
+
+struct iw_handler_def ipw2100_wx_handler_def =
+{
+	.standard = ipw2100_wx_handlers,
+	.num_standard = sizeof(ipw2100_wx_handlers) / sizeof(iw_handler),
+	.num_private = sizeof(ipw2100_private_handler) / sizeof(iw_handler),
+ 	.num_private_args = sizeof(ipw2100_private_args) /
+	sizeof(struct iw_priv_args),
+	.private = (iw_handler *)ipw2100_private_handler,
+	.private_args = (struct iw_priv_args *)ipw2100_private_args,
+};
+
+/*
+ * Get wireless statistics.
+ * Called by /proc/net/wireless
+ * Also called by SIOCGIWSTATS
+ */
+struct iw_statistics *ipw2100_wx_wireless_stats(struct net_device * dev)
+{
+	enum {
+		POOR = 30,
+		FAIR = 60,
+		GOOD = 80,
+		VERY_GOOD = 90,
+		EXCELLENT = 95,
+		PERFECT = 100
+	};
+	int rssi_qual;
+	int tx_qual;
+	int beacon_qual;
+
+	struct ipw2100_priv *priv = ieee80211_priv(dev);
+	struct iw_statistics *wstats;
+	u32 rssi, quality, tx_retries, missed_beacons, tx_failures;
+	u32 ord_len = sizeof(u32);
+
+	if (!priv)
+		return (struct iw_statistics *) NULL;
+
+	wstats = &priv->wstats;
+
+	/* if hw is disabled, then ipw2100_get_ordinal() can't be called.
+	 * ipw2100_wx_wireless_stats seems to be called before fw is
+	 * initialized.  STATUS_ASSOCIATED will only be set if the hw is up
+	 * and associated; if not associcated, the values are all meaningless
+	 * anyway, so set them all to NULL and INVALID */
+	if (!(priv->status & STATUS_ASSOCIATED)) {
+		wstats->miss.beacon = 0;
+		wstats->discard.retries = 0;
+		wstats->qual.qual = 0;
+		wstats->qual.level = 0;
+		wstats->qual.noise = 0;
+		wstats->qual.updated = 7;
+		wstats->qual.updated |= IW_QUAL_NOISE_INVALID |
+			IW_QUAL_QUAL_INVALID | IW_QUAL_LEVEL_INVALID;
+		return wstats;
+	}
+
+	if (ipw2100_get_ordinal(priv, IPW_ORD_STAT_PERCENT_MISSED_BCNS,
+				&missed_beacons, &ord_len))
+		goto fail_get_ordinal;
+
+        /* If we don't have a connection the quality and level is 0*/
+	if (!(priv->status & STATUS_ASSOCIATED)) {
+		wstats->qual.qual = 0;
+		wstats->qual.level = 0;
+	} else {
+		if (ipw2100_get_ordinal(priv, IPW_ORD_RSSI_AVG_CURR,
+					&rssi, &ord_len))
+			goto fail_get_ordinal;
+		wstats->qual.level = rssi + IPW2100_RSSI_TO_DBM;
+		if (rssi < 10)
+			rssi_qual = rssi * POOR / 10;
+		else if (rssi < 15)
+			rssi_qual = (rssi - 10) * (FAIR - POOR) / 5 + POOR;
+		else if (rssi < 20)
+			rssi_qual = (rssi - 15) * (GOOD - FAIR) / 5 + FAIR;
+		else if (rssi < 30)
+			rssi_qual = (rssi - 20) * (VERY_GOOD - GOOD) /
+				10 + GOOD;
+		else
+			rssi_qual = (rssi - 30) * (PERFECT - VERY_GOOD) /
+				10 + VERY_GOOD;
+
+		if (ipw2100_get_ordinal(priv, IPW_ORD_STAT_PERCENT_RETRIES,
+					&tx_retries, &ord_len))
+			goto fail_get_ordinal;
+
+		if (tx_retries > 75)
+			tx_qual = (90 - tx_retries) * POOR / 15;
+		else if (tx_retries > 70)
+			tx_qual = (75 - tx_retries) * (FAIR - POOR) / 5 + POOR;
+		else if (tx_retries > 65)
+			tx_qual = (70 - tx_retries) * (GOOD - FAIR) / 5 + FAIR;
+		else if (tx_retries > 50)
+			tx_qual = (65 - tx_retries) * (VERY_GOOD - GOOD) /
+				15 + GOOD;
+		else
+			tx_qual = (50 - tx_retries) *
+				(PERFECT - VERY_GOOD) / 50 + VERY_GOOD;
+
+		if (missed_beacons > 50)
+			beacon_qual = (60 - missed_beacons) * POOR / 10;
+		else if (missed_beacons > 40)
+			beacon_qual = (50 - missed_beacons) * (FAIR - POOR) /
+				10 + POOR;
+		else if (missed_beacons > 32)
+			beacon_qual = (40 - missed_beacons) * (GOOD - FAIR) /
+				18 + FAIR;
+		else if (missed_beacons > 20)
+			beacon_qual = (32 - missed_beacons) *
+				(VERY_GOOD - GOOD) / 20 + GOOD;
+		else
+			beacon_qual = (20 - missed_beacons) *
+				(PERFECT - VERY_GOOD) / 20 + VERY_GOOD;
+
+		quality = min(beacon_qual, min(tx_qual, rssi_qual));
+
+#ifdef CONFIG_IPW_DEBUG
+		if (beacon_qual == quality)
+			IPW_DEBUG_WX("Quality clamped by Missed Beacons\n");
+		else if (tx_qual == quality)
+			IPW_DEBUG_WX("Quality clamped by Tx Retries\n");
+		else if (quality != 100)
+			IPW_DEBUG_WX("Quality clamped by Signal Strength\n");
+		else
+			IPW_DEBUG_WX("Quality not clamped.\n");
+#endif
+
+		wstats->qual.qual = quality;
+		wstats->qual.level = rssi + IPW2100_RSSI_TO_DBM;
+	}
+
+	wstats->qual.noise = 0;
+	wstats->qual.updated = 7;
+	wstats->qual.updated |= IW_QUAL_NOISE_INVALID;
+
+        /* FIXME: this is percent and not a # */
+	wstats->miss.beacon = missed_beacons;
+
+	if (ipw2100_get_ordinal(priv, IPW_ORD_STAT_TX_FAILURES,
+				&tx_failures, &ord_len))
+		goto fail_get_ordinal;
+	wstats->discard.retries = tx_failures;
+
+	return wstats;
+
+ fail_get_ordinal:
+	IPW_DEBUG_WX("failed querying ordinals.\n");
+
+	return (struct iw_statistics *) NULL;
+}
+
+void ipw2100_wx_event_work(struct ipw2100_priv *priv)
+{
+	union iwreq_data wrqu;
+	int len = ETH_ALEN;
+
+	if (priv->status & STATUS_STOPPING)
+		return;
+
+	down(&priv->action_sem);
+
+	IPW_DEBUG_WX("enter\n");
+
+	up(&priv->action_sem);
+
+	wrqu.ap_addr.sa_family = ARPHRD_ETHER;
+
+	/* Fetch BSSID from the hardware */
+	if (!(priv->status & (STATUS_ASSOCIATING | STATUS_ASSOCIATED)) ||
+	    priv->status & STATUS_RF_KILL_MASK ||
+	    ipw2100_get_ordinal(priv, IPW_ORD_STAT_ASSN_AP_BSSID,
+				&priv->bssid,  &len)) {
+		memset(wrqu.ap_addr.sa_data, 0, ETH_ALEN);
+	} else {
+		/* We now have the BSSID, so can finish setting to the full
+		 * associated state */
+		memcpy(wrqu.ap_addr.sa_data, priv->bssid, ETH_ALEN);
+		memcpy(&priv->ieee->bssid, priv->bssid, ETH_ALEN);
+		priv->status &= ~STATUS_ASSOCIATING;
+		priv->status |= STATUS_ASSOCIATED;
+		netif_carrier_on(priv->net_dev);
+		if (netif_queue_stopped(priv->net_dev)) {
+			IPW_DEBUG_INFO("Waking net queue.\n");
+			netif_wake_queue(priv->net_dev);
+		} else {
+			IPW_DEBUG_INFO("Starting net queue.\n");
+			netif_start_queue(priv->net_dev);
+		}
+	}
+
+	if (!(priv->status & STATUS_ASSOCIATED)) {
+		IPW_DEBUG_WX("Configuring ESSID\n");
+		down(&priv->action_sem);
+		/* This is a disassociation event, so kick the firmware to
+		 * look for another AP */
+		if (priv->config & CFG_STATIC_ESSID)
+			ipw2100_set_essid(priv, priv->essid, priv->essid_len, 0);
+		else
+			ipw2100_set_essid(priv, NULL, 0, 0);
+		up(&priv->action_sem);
+	}
+
+	wireless_send_event(priv->net_dev, SIOCGIWAP, &wrqu, NULL);
+}
+
+#define IPW2100_FW_MAJOR_VERSION 1
+#define IPW2100_FW_MINOR_VERSION 3
+
+#define IPW2100_FW_MINOR(x) ((x & 0xff) >> 8)
+#define IPW2100_FW_MAJOR(x) (x & 0xff)
+
+#define IPW2100_FW_VERSION ((IPW2100_FW_MINOR_VERSION << 8) | \
+                             IPW2100_FW_MAJOR_VERSION)
+
+#define IPW2100_FW_PREFIX "ipw2100-" __stringify(IPW2100_FW_MAJOR_VERSION) \
+"." __stringify(IPW2100_FW_MINOR_VERSION)
+
+#define IPW2100_FW_NAME(x) IPW2100_FW_PREFIX "" x ".fw"
+
+
+/*
+
+BINARY FIRMWARE HEADER FORMAT
+
+offset      length   desc
+0           2        version
+2           2        mode == 0:BSS,1:IBSS,2:MONITOR
+4           4        fw_len
+8           4        uc_len
+C           fw_len   firmware data
+12 + fw_len uc_len   microcode data
+
+*/
+
+struct ipw2100_fw_header {
+	short version;
+	short mode;
+	unsigned int fw_size;
+	unsigned int uc_size;
+} __attribute__ ((packed));
+
+
+
+static int ipw2100_mod_firmware_load(struct ipw2100_fw *fw)
+{
+	struct ipw2100_fw_header *h =
+		(struct ipw2100_fw_header *)fw->fw_entry->data;
+
+	if (IPW2100_FW_MAJOR(h->version) != IPW2100_FW_MAJOR_VERSION) {
+		IPW_DEBUG_WARNING("Firmware image not compatible "
+		       "(detected version id of %u). "
+		       "See Documentation/networking/README.ipw2100\n",
+		       h->version);
+		return 1;
+	}
+
+	fw->version = h->version;
+	fw->fw.data = fw->fw_entry->data + sizeof(struct ipw2100_fw_header);
+	fw->fw.size = h->fw_size;
+	fw->uc.data = fw->fw.data + h->fw_size;
+	fw->uc.size = h->uc_size;
+
+	return 0;
+}
+
+
+int ipw2100_get_firmware(struct ipw2100_priv *priv, struct ipw2100_fw *fw)
+{
+	char *fw_name;
+	int rc;
+
+	IPW_DEBUG_INFO("%s: Using hotplug firmware load.\n",
+	       priv->net_dev->name);
+
+	switch (priv->ieee->iw_mode) {
+	case IW_MODE_ADHOC:
+		fw_name = IPW2100_FW_NAME("-i");
+		break;
+#ifdef CONFIG_IPW2100_MONITOR
+	case IW_MODE_MONITOR:
+		fw_name = IPW2100_FW_NAME("-p");
+		break;
+#endif
+	case IW_MODE_INFRA:
+	default:
+		fw_name = IPW2100_FW_NAME("");
+		break;
+	}
+
+	rc = request_firmware(&fw->fw_entry, fw_name, &priv->pci_dev->dev);
+
+	if (rc < 0) {
+		IPW_DEBUG_ERROR(
+		       "%s: Firmware '%s' not available or load failed.\n",
+		       priv->net_dev->name, fw_name);
+		return rc;
+	}
+	IPW_DEBUG_INFO("firmware data %p size %d\n", fw->fw_entry->data,
+			   fw->fw_entry->size);
+
+	ipw2100_mod_firmware_load(fw);
+
+	return 0;
+}
+
+void ipw2100_release_firmware(struct ipw2100_priv *priv,
+			      struct ipw2100_fw *fw)
+{
+	fw->version = 0;
+	if (fw->fw_entry)
+		release_firmware(fw->fw_entry);
+	fw->fw_entry = NULL;
+}
+
+
+int ipw2100_get_fwversion(struct ipw2100_priv *priv, char *buf, size_t max)
+{
+	char ver[MAX_FW_VERSION_LEN];
+	u32 len = MAX_FW_VERSION_LEN;
+	u32 tmp;
+	int i;
+	/* firmware version is an ascii string (max len of 14) */
+	if (ipw2100_get_ordinal(priv, IPW_ORD_STAT_FW_VER_NUM,
+				ver, &len))
+		return -EIO;
+	tmp = max;
+	if (len >= max)
+		len = max - 1;
+	for (i = 0; i < len; i++)
+		buf[i] = ver[i];
+	buf[i] = '\0';
+	return tmp;
+}
+
+int ipw2100_get_ucodeversion(struct ipw2100_priv *priv, char *buf, size_t max)
+{
+	u32 ver;
+	u32 len = sizeof(ver);
+	/* microcode version is a 32 bit integer */
+	if (ipw2100_get_ordinal(priv, IPW_ORD_UCODE_VERSION,
+				&ver, &len))
+		return -EIO;
+	return snprintf(buf, max, "%08X", ver);
+}
+
+/*
+ * On exit, the firmware will have been freed from the fw list
+ */
+int ipw2100_fw_download(struct ipw2100_priv *priv, struct ipw2100_fw *fw)
+{
+	/* firmware is constructed of N contiguous entries, each entry is
+	 * structured as:
+	 *
+	 * offset    sie         desc
+	 * 0         4           address to write to
+	 * 4         2           length of data run
+         * 6         length      data
+	 */
+	unsigned int addr;
+	unsigned short len;
+
+	const unsigned char *firmware_data = fw->fw.data;
+	unsigned int firmware_data_left = fw->fw.size;
+
+	while (firmware_data_left > 0) {
+	   	addr = *(u32 *)(firmware_data);
+		firmware_data      += 4;
+		firmware_data_left -= 4;
+
+	   	len = *(u16 *)(firmware_data);
+		firmware_data      += 2;
+		firmware_data_left -= 2;
+
+		if (len > 32) {
+			IPW_DEBUG_ERROR(
+			       "Invalid firmware run-length of %d bytes\n",
+			       len);
+			return -EINVAL;
+		}
+
+		write_nic_memory(priv->net_dev, addr, len, firmware_data);
+		firmware_data      += len;
+		firmware_data_left -= len;
+	}
+
+	return 0;
+}
+
+struct symbol_alive_response {
+	u8 cmd_id;
+	u8 seq_num;
+	u8 ucode_rev;
+	u8 eeprom_valid;
+	u16 valid_flags;
+	u8 IEEE_addr[6];
+	u16 flags;
+	u16 pcb_rev;
+	u16 clock_settle_time;	// 1us LSB
+	u16 powerup_settle_time;	// 1us LSB
+	u16 hop_settle_time;	// 1us LSB
+	u8 date[3];		// month, day, year
+	u8 time[2];		// hours, minutes
+	u8 ucode_valid;
+};
+
+int ipw2100_ucode_download(struct ipw2100_priv *priv, struct ipw2100_fw *fw)
+{
+	struct net_device *dev = priv->net_dev;
+	const unsigned char *microcode_data = fw->uc.data;
+	unsigned int microcode_data_left = fw->uc.size;
+
+	struct symbol_alive_response response;
+	int i, j;
+	u8 data;
+
+	/* Symbol control */
+	write_nic_word(dev, IPW2100_CONTROL_REG, 0x703);
+	readl((void *)(dev->base_addr));
+	write_nic_word(dev, IPW2100_CONTROL_REG, 0x707);
+	readl((void *)(dev->base_addr));
+
+	/* HW config */
+	write_nic_byte(dev, 0x210014, 0x72);	/* fifo width =16 */
+	readl((void *)(dev->base_addr));
+	write_nic_byte(dev, 0x210014, 0x72);	/* fifo width =16 */
+	readl((void *)(dev->base_addr));
+
+	/* EN_CS_ACCESS bit to reset control store pointer */
+	write_nic_byte(dev, 0x210000, 0x40);
+	readl((void *)(dev->base_addr));
+	write_nic_byte(dev, 0x210000, 0x0);
+	readl((void *)(dev->base_addr));
+	write_nic_byte(dev, 0x210000, 0x40);
+	readl((void *)(dev->base_addr));
+
+	/* copy microcode from buffer into Symbol */
+
+	while (microcode_data_left > 0) {
+		write_nic_byte(dev, 0x210010, *microcode_data++);
+		write_nic_byte(dev, 0x210010, *microcode_data++);
+		microcode_data_left -= 2;
+	}
+
+	/* EN_CS_ACCESS bit to reset the control store pointer */
+	write_nic_byte(dev, 0x210000, 0x0);
+	readl((void *)(dev->base_addr));
+
+	/* Enable System (Reg 0)
+	 * first enable causes garbage in RX FIFO */
+	write_nic_byte(dev, 0x210000, 0x0);
+	readl((void *)(dev->base_addr));
+	write_nic_byte(dev, 0x210000, 0x80);
+	readl((void *)(dev->base_addr));
+
+	/* Reset External Baseband Reg */
+	write_nic_word(dev, IPW2100_CONTROL_REG, 0x703);
+	readl((void *)(dev->base_addr));
+	write_nic_word(dev, IPW2100_CONTROL_REG, 0x707);
+	readl((void *)(dev->base_addr));
+
+	/* HW Config (Reg 5) */
+	write_nic_byte(dev, 0x210014, 0x72);	// fifo width =16
+	readl((void *)(dev->base_addr));
+	write_nic_byte(dev, 0x210014, 0x72);	// fifo width =16
+	readl((void *)(dev->base_addr));
+
+	/* Enable System (Reg 0)
+	 * second enable should be OK */
+	write_nic_byte(dev, 0x210000, 0x00);	// clear enable system
+	readl((void *)(dev->base_addr));
+	write_nic_byte(dev, 0x210000, 0x80);	// set enable system
+
+	/* check Symbol is enabled - upped this from 5 as it wasn't always
+	 * catching the update */
+	for (i = 0; i < 10; i++) {
+		udelay(10);
+
+		/* check Dino is enabled bit */
+		read_nic_byte(dev, 0x210000, &data);
+		if (data & 0x1)
+			break;
+	}
+
+	if (i == 10) {
+		IPW_DEBUG_ERROR("%s: Error initializing Symbol\n",
+		       dev->name);
+		return -EIO;
+	}
+
+	/* Get Symbol alive response */
+	for (i = 0; i < 30; i++) {
+		/* Read alive response structure */
+		for (j = 0;
+		     j < (sizeof(struct symbol_alive_response) >> 1);
+		     j++)
+			read_nic_word(dev, 0x210004,
+				      ((u16 *)&response) + j);
+
+		if ((response.cmd_id == 1) &&
+		    (response.ucode_valid == 0x1))
+			break;
+		udelay(10);
+	}
+
+	if (i == 30) {
+		IPW_DEBUG_ERROR("%s: No response from Symbol - hw not alive\n",
+		       dev->name);
+		printk_buf(IPW_DL_ERROR, (u8*)&response, sizeof(response));
+		return -EIO;
+	}
+
+	return 0;
+}
diff -Nur --exclude=RCS --exclude=CVS --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet netdev-2.6/drivers/net/wireless/ipw2100.h ipw2100-2.6/drivers/net/wireless/ipw2100.h
--- netdev-2.6/drivers/net/wireless/ipw2100.h	1969-12-31 18:00:00 -06:00
+++ ipw2100-2.6/drivers/net/wireless/ipw2100.h	2005-03-23 13:31:36 -06:00
@@ -0,0 +1,1278 @@
+/******************************************************************************
+
+  Copyright(c) 2003 - 2005 Intel Corporation. All rights reserved.
+
+  This program is free software; you can redistribute it and/or modify it
+  under the terms of version 2 of the GNU General Public License as
+  published by the Free Software Foundation.
+
+  This program is distributed in the hope that it will be useful, but WITHOUT
+  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+  more details.
+
+  You should have received a copy of the GNU General Public License along with
+  this program; if not, write to the Free Software Foundation, Inc., 59
+  Temple Place - Suite 330, Boston, MA  02111-1307, USA.
+
+  The full GNU General Public License is included in this distribution in the
+  file called LICENSE.
+
+  Contact Information:
+  James P. Ketrenos <ipw2100-admin@linux.intel.com>
+  Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+
+******************************************************************************/
+#ifndef _IPW2100_H
+#define _IPW2100_H
+
+#include <linux/sched.h>
+#include <linux/interrupt.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/list.h>
+#include <linux/delay.h>
+#include <linux/skbuff.h>
+#include <asm/io.h>
+#include <linux/socket.h>
+#include <linux/if_arp.h>
+#include <linux/wireless.h>
+#include <linux/version.h>
+#include <net/iw_handler.h>	// new driver API
+
+#include <net/ieee80211.h>
+
+#include <linux/workqueue.h>
+
+#ifndef IRQ_NONE
+typedef void irqreturn_t;
+#define IRQ_NONE
+#define IRQ_HANDLED
+#define IRQ_RETVAL(x)
+#endif
+
+#if WIRELESS_EXT < 17
+#define IW_QUAL_QUAL_INVALID  0x10
+#define IW_QUAL_LEVEL_INVALID 0x20
+#define IW_QUAL_NOISE_INVALID 0x40
+#endif
+
+#if ( LINUX_VERSION_CODE < KERNEL_VERSION(2,6,5) )
+#define pci_dma_sync_single_for_cpu	pci_dma_sync_single
+#define pci_dma_sync_single_for_device	pci_dma_sync_single
+#endif
+
+#ifndef HAVE_FREE_NETDEV
+#define free_netdev(x) kfree(x)
+#endif
+
+
+
+struct ipw2100_priv;
+struct ipw2100_tx_packet;
+struct ipw2100_rx_packet;
+
+#ifdef CONFIG_IPW_DEBUG
+enum { IPW_DEBUG_ENABLED = 1 };
+extern u32 ipw2100_debug_level;
+#define IPW_DEBUG(level, message...) \
+do { \
+	if (ipw2100_debug_level & (level)) { \
+		printk(KERN_DEBUG "ipw2100: %c %s ", \
+                       in_interrupt() ? 'I' : 'U',  __FUNCTION__); \
+		printk(message); \
+	} \
+} while (0)
+#else
+enum { IPW_DEBUG_ENABLED = 0 };
+#define IPW_DEBUG(level, message...) do {} while (0)
+#endif /* CONFIG_IPW_DEBUG */
+
+#define IPW_DL_UNINIT    0x80000000
+#define IPW_DL_NONE      0x00000000
+#define IPW_DL_ALL       0x7FFFFFFF
+
+/*
+ * To use the debug system;
+ *
+ * If you are defining a new debug classification, simply add it to the #define
+ * list here in the form of:
+ *
+ * #define IPW_DL_xxxx VALUE
+ *
+ * shifting value to the left one bit from the previous entry.  xxxx should be
+ * the name of the classification (for example, WEP)
+ *
+ * You then need to either add a IPW2100_xxxx_DEBUG() macro definition for your
+ * classification, or use IPW_DEBUG(IPW_DL_xxxx, ...) whenever you want
+ * to send output to that classification.
+ *
+ * To add your debug level to the list of levels seen when you perform
+ *
+ * % cat /proc/net/ipw2100/debug_level
+ *
+ * you simply need to add your entry to the ipw2100_debug_levels array.
+ *
+ * If you do not see debug_level in /proc/net/ipw2100 then you do not have
+ * CONFIG_IPW_DEBUG defined in your kernel configuration
+ *
+ */
+
+#define IPW_DL_ERROR         (1<<0)
+#define IPW_DL_WARNING       (1<<1)
+#define IPW_DL_INFO          (1<<2)
+#define IPW_DL_WX            (1<<3)
+#define IPW_DL_HC            (1<<5)
+#define IPW_DL_STATE         (1<<6)
+
+#define IPW_DL_NOTIF         (1<<10)
+#define IPW_DL_SCAN          (1<<11)
+#define IPW_DL_ASSOC         (1<<12)
+#define IPW_DL_DROP          (1<<13)
+
+#define IPW_DL_IOCTL         (1<<14)
+#define IPW_DL_RF_KILL       (1<<17)
+
+
+#define IPW_DL_MANAGE        (1<<15)
+#define IPW_DL_FW            (1<<16)
+
+#define IPW_DL_FRAG          (1<<21)
+#define IPW_DL_WEP           (1<<22)
+#define IPW_DL_TX            (1<<23)
+#define IPW_DL_RX            (1<<24)
+#define IPW_DL_ISR           (1<<25)
+#define IPW_DL_IO            (1<<26)
+#define IPW_DL_TRACE         (1<<28)
+
+#define IPW_DEBUG_ERROR(f, a...) printk(KERN_ERR DRV_NAME ": " f, ## a)
+#define IPW_DEBUG_WARNING(f, a...) printk(KERN_WARNING DRV_NAME ": " f, ## a)
+#define IPW_DEBUG_INFO(f...)    IPW_DEBUG(IPW_DL_INFO, ## f)
+#define IPW_DEBUG_WX(f...)     IPW_DEBUG(IPW_DL_WX, ## f)
+#define IPW_DEBUG_SCAN(f...)   IPW_DEBUG(IPW_DL_SCAN, ## f)
+#define IPW_DEBUG_NOTIF(f...) IPW_DEBUG(IPW_DL_NOTIF, ## f)
+#define IPW_DEBUG_TRACE(f...)  IPW_DEBUG(IPW_DL_TRACE, ## f)
+#define IPW_DEBUG_RX(f...)     IPW_DEBUG(IPW_DL_RX, ## f)
+#define IPW_DEBUG_TX(f...)     IPW_DEBUG(IPW_DL_TX, ## f)
+#define IPW_DEBUG_ISR(f...)    IPW_DEBUG(IPW_DL_ISR, ## f)
+#define IPW_DEBUG_MANAGEMENT(f...) IPW_DEBUG(IPW_DL_MANAGE, ## f)
+#define IPW_DEBUG_WEP(f...)    IPW_DEBUG(IPW_DL_WEP, ## f)
+#define IPW_DEBUG_HC(f...) IPW_DEBUG(IPW_DL_HC, ## f)
+#define IPW_DEBUG_FRAG(f...) IPW_DEBUG(IPW_DL_FRAG, ## f)
+#define IPW_DEBUG_FW(f...) IPW_DEBUG(IPW_DL_FW, ## f)
+#define IPW_DEBUG_RF_KILL(f...) IPW_DEBUG(IPW_DL_RF_KILL, ## f)
+#define IPW_DEBUG_DROP(f...) IPW_DEBUG(IPW_DL_DROP, ## f)
+#define IPW_DEBUG_IO(f...) IPW_DEBUG(IPW_DL_IO, ## f)
+#define IPW_DEBUG_IOCTL(f...) IPW_DEBUG(IPW_DL_IOCTL, ## f)
+#define IPW_DEBUG_STATE(f, a...) IPW_DEBUG(IPW_DL_STATE | IPW_DL_ASSOC | IPW_DL_INFO, f, ## a)
+#define IPW_DEBUG_ASSOC(f, a...) IPW_DEBUG(IPW_DL_ASSOC | IPW_DL_INFO, f, ## a)
+
+
+#define VERIFY(f) \
+{ \
+  int status = 0; \
+  status = f; \
+  if(status) \
+     return status; \
+}
+
+enum {
+	IPW_HW_STATE_DISABLED = 1,
+	IPW_HW_STATE_ENABLED = 0
+};
+
+struct ssid_context {
+	char ssid[IW_ESSID_MAX_SIZE + 1];
+	int ssid_len;
+	unsigned char bssid[ETH_ALEN];
+	int port_type;
+	int channel;
+
+};
+
+extern const char *port_type_str[];
+extern const char *band_str[];
+
+#define NUMBER_OF_BD_PER_COMMAND_PACKET		1
+#define NUMBER_OF_BD_PER_DATA_PACKET		2
+
+#define IPW_MAX_BDS 6
+#define NUMBER_OF_OVERHEAD_BDS_PER_PACKETR	2
+#define NUMBER_OF_BDS_TO_LEAVE_FOR_COMMANDS	1
+
+#define REQUIRED_SPACE_IN_RING_FOR_COMMAND_PACKET \
+    (IPW_BD_QUEUE_W_R_MIN_SPARE + NUMBER_OF_BD_PER_COMMAND_PACKET)
+
+struct bd_status {
+	union {
+		struct { u8 nlf:1, txType:2, intEnabled:1, reserved:4;} fields;
+		u8 field;
+	} info;
+} __attribute__ ((packed));
+
+#define	IPW_BUFDESC_LAST_FRAG 0
+
+struct ipw2100_bd {
+	u32 host_addr;
+	u32 buf_length;
+	struct bd_status status;
+        /* number of fragments for frame (should be set only for
+	 * 1st TBD) */
+	u8 num_fragments;
+	u8 reserved[6];
+} __attribute__ ((packed));
+
+#define IPW_BD_QUEUE_LENGTH(n) (1<<n)
+#define IPW_BD_ALIGNMENT(L)    (L*sizeof(struct ipw2100_bd))
+
+#define IPW_BD_STATUS_TX_FRAME_802_3             0x00
+#define IPW_BD_STATUS_TX_FRAME_NOT_LAST_FRAGMENT 0x01
+#define IPW_BD_STATUS_TX_FRAME_COMMAND		 0x02
+#define IPW_BD_STATUS_TX_FRAME_802_11	         0x04
+#define IPW_BD_STATUS_TX_INTERRUPT_ENABLE	 0x08
+
+struct ipw2100_bd_queue {
+	/* driver (virtual) pointer to queue */
+	struct ipw2100_bd *drv;
+
+	/* firmware (physical) pointer to queue */
+	dma_addr_t nic;
+
+	/* Length of phy memory allocated for BDs */
+	u32 size;
+
+	/* Number of BDs in queue (and in array) */
+	u32 entries;
+
+	/* Number of available BDs (invalid for NIC BDs) */
+	u32 available;
+
+	/* Offset of oldest used BD in array (next one to
+	 * check for completion) */
+	u32 oldest;
+
+	/* Offset of next available (unused) BD */
+	u32 next;
+};
+
+#define RX_QUEUE_LENGTH 256
+#define TX_QUEUE_LENGTH 256
+#define HW_QUEUE_LENGTH 256
+
+#define TX_PENDED_QUEUE_LENGTH (TX_QUEUE_LENGTH / NUMBER_OF_BD_PER_DATA_PACKET)
+
+#define STATUS_TYPE_MASK	0x0000000f
+#define COMMAND_STATUS_VAL	0
+#define STATUS_CHANGE_VAL	1
+#define P80211_DATA_VAL 	2
+#define P8023_DATA_VAL		3
+#define HOST_NOTIFICATION_VAL	4
+
+#define IPW2100_RSSI_TO_DBM (-98)
+
+struct ipw2100_status {
+	u32 frame_size;
+	u16 status_fields;
+	u8 flags;
+#define IPW_STATUS_FLAG_DECRYPTED	(1<<0)
+#define IPW_STATUS_FLAG_WEP_ENCRYPTED	(1<<1)
+#define IPW_STATUS_FLAG_CRC_ERROR       (1<<2)
+	u8 rssi;
+} __attribute__ ((packed));
+
+struct ipw2100_status_queue {
+	/* driver (virtual) pointer to queue */
+	struct ipw2100_status *drv;
+
+	/* firmware (physical) pointer to queue */
+	dma_addr_t nic;
+
+	/* Length of phy memory allocated for BDs */
+	u32 size;
+};
+
+#define HOST_COMMAND_PARAMS_REG_LEN	100
+#define CMD_STATUS_PARAMS_REG_LEN 	3
+
+#define IPW_WPA_CAPABILITIES   0x1
+#define IPW_WPA_LISTENINTERVAL 0x2
+#define IPW_WPA_AP_ADDRESS     0x4
+
+#define IPW_MAX_VAR_IE_LEN ((HOST_COMMAND_PARAMS_REG_LEN - 4) * sizeof(u32))
+
+struct ipw2100_wpa_assoc_frame {
+	u16 fixed_ie_mask;
+	struct {
+		u16 capab_info;
+		u16 listen_interval;
+		u8 current_ap[ETH_ALEN];
+	} fixed_ies;
+	u32 var_ie_len;
+	u8 var_ie[IPW_MAX_VAR_IE_LEN];
+};
+
+#define IPW_BSS     1
+#define IPW_MONITOR 2
+#define IPW_IBSS    3
+
+/**
+ * @struct _tx_cmd - HWCommand
+ * @brief H/W command structure.
+ */
+struct ipw2100_cmd_header {
+	u32 host_command_reg;
+	u32 host_command_reg1;
+	u32 sequence;
+	u32 host_command_len_reg;
+	u32 host_command_params_reg[HOST_COMMAND_PARAMS_REG_LEN];
+	u32 cmd_status_reg;
+	u32 cmd_status_params_reg[CMD_STATUS_PARAMS_REG_LEN];
+	u32 rxq_base_ptr;
+	u32 rxq_next_ptr;
+	u32 rxq_host_ptr;
+	u32 txq_base_ptr;
+	u32 txq_next_ptr;
+	u32 txq_host_ptr;
+	u32 tx_status_reg;
+	u32 reserved;
+	u32 status_change_reg;
+	u32 reserved1[3];
+	u32 *ordinal1_ptr;
+	u32 *ordinal2_ptr;
+} __attribute__ ((packed));
+
+struct ipw2100_data_header {
+	u32 host_command_reg;
+	u32 host_command_reg1;
+	u8 encrypted;	// BOOLEAN in win! TRUE if frame is enc by driver
+	u8 needs_encryption;	// BOOLEAN in win! TRUE if frma need to be enc in NIC
+	u8 wep_index;		// 0 no key, 1-4 key index, 0xff immediate key
+	u8 key_size;	// 0 no imm key, 0x5 64bit encr, 0xd 128bit encr, 0x10 128bit encr and 128bit IV
+	u8 key[16];
+	u8 reserved[10];	// f/w reserved
+	u8 src_addr[ETH_ALEN];
+	u8 dst_addr[ETH_ALEN];
+	u16 fragment_size;
+} __attribute__ ((packed));
+
+// Host command data structure
+struct host_command {
+	u32 host_command;		// COMMAND ID
+	u32 host_command1;		// COMMAND ID
+	u32 host_command_sequence;	// UNIQUE COMMAND NUMBER (ID)
+	u32 host_command_length;	// LENGTH
+	u32 host_command_parameters[HOST_COMMAND_PARAMS_REG_LEN];	// COMMAND PARAMETERS
+} __attribute__ ((packed));
+
+
+typedef enum {
+	POWER_ON_RESET,
+	EXIT_POWER_DOWN_RESET,
+	SW_RESET,
+	EEPROM_RW,
+	SW_RE_INIT
+} ipw2100_reset_event;
+
+enum {
+	COMMAND = 0xCAFE,
+	DATA,
+	RX
+};
+
+
+struct ipw2100_tx_packet {
+	int type;
+	int index;
+	union {
+		struct { /* COMMAND */
+			struct ipw2100_cmd_header* cmd;
+			dma_addr_t cmd_phys;
+		} c_struct;
+		struct { /* DATA */
+			struct ipw2100_data_header* data;
+			dma_addr_t data_phys;
+			struct ieee80211_txb *txb;
+		} d_struct;
+	} info;
+	int jiffy_start;
+
+	struct list_head list;
+};
+
+
+struct ipw2100_rx_packet {
+	struct ipw2100_rx *rxp;
+	dma_addr_t dma_addr;
+	int jiffy_start;
+	struct sk_buff *skb;
+	struct list_head list;
+};
+
+#define FRAG_DISABLED             (1<<31)
+#define RTS_DISABLED              (1<<31)
+#define MAX_RTS_THRESHOLD         2304U
+#define MIN_RTS_THRESHOLD         1U
+#define DEFAULT_RTS_THRESHOLD     1000U
+
+#define DEFAULT_BEACON_INTERVAL   100U
+#define	DEFAULT_SHORT_RETRY_LIMIT 7U
+#define	DEFAULT_LONG_RETRY_LIMIT  4U
+
+struct ipw2100_ordinals {
+	u32 table1_addr;
+	u32 table2_addr;
+	u32 table1_size;
+	u32 table2_size;
+};
+
+/* Host Notification header */
+struct ipw2100_notification {
+	u32 hnhdr_subtype;	/* type of host notification */
+	u32 hnhdr_size;		/* size in bytes of data
+				   or number of entries, if table.
+				   Does NOT include header */
+} __attribute__ ((packed));
+
+#define MAX_KEY_SIZE	16
+#define	MAX_KEYS	8
+
+#define IPW2100_WEP_ENABLE     (1<<1)
+#define IPW2100_WEP_DROP_CLEAR (1<<2)
+
+#define IPW_NONE_CIPHER   (1<<0)
+#define IPW_WEP40_CIPHER  (1<<1)
+#define IPW_TKIP_CIPHER   (1<<2)
+#define IPW_CCMP_CIPHER   (1<<4)
+#define IPW_WEP104_CIPHER (1<<5)
+#define IPW_CKIP_CIPHER   (1<<6)
+
+#define	IPW_AUTH_OPEN     0
+#define	IPW_AUTH_SHARED   1
+
+struct statistic {
+	int value;
+	int hi;
+	int lo;
+};
+
+#define INIT_STAT(x) do {  \
+  (x)->value = (x)->hi = 0; \
+  (x)->lo = 0x7fffffff; \
+} while (0)
+#define SET_STAT(x,y) do { \
+  (x)->value = y; \
+  if ((x)->value > (x)->hi) (x)->hi = (x)->value; \
+  if ((x)->value < (x)->lo) (x)->lo = (x)->value; \
+} while (0)
+#define INC_STAT(x) do { if (++(x)->value > (x)->hi) (x)->hi = (x)->value; } \
+while (0)
+#define DEC_STAT(x) do { if (--(x)->value < (x)->lo) (x)->lo = (x)->value; } \
+while (0)
+
+#define IPW2100_ERROR_QUEUE 5
+
+/* Power management code: enable or disable? */
+enum {
+#ifdef CONFIG_PM
+	IPW2100_PM_DISABLED = 0,
+	PM_STATE_SIZE = 16,
+#else
+	IPW2100_PM_DISABLED = 1,
+	PM_STATE_SIZE = 0,
+#endif
+};
+
+#define STATUS_POWERED          (1<<0)
+#define STATUS_CMD_ACTIVE       (1<<1)  /**< host command in progress */
+#define STATUS_RUNNING          (1<<2)  /* Card initialized, but not enabled */
+#define STATUS_ENABLED          (1<<3)  /* Card enabled -- can scan,Tx,Rx */
+#define STATUS_STOPPING         (1<<4)  /* Card is in shutdown phase */
+#define STATUS_INITIALIZED      (1<<5)  /* Card is ready for external calls */
+#define STATUS_ASSOCIATING      (1<<9)  /* Associated, but no BSSID yet */
+#define STATUS_ASSOCIATED       (1<<10) /* Associated and BSSID valid */
+#define STATUS_INT_ENABLED      (1<<11)
+#define STATUS_RF_KILL_HW       (1<<12)
+#define STATUS_RF_KILL_SW       (1<<13)
+#define STATUS_RF_KILL_MASK     (STATUS_RF_KILL_HW | STATUS_RF_KILL_SW)
+#define STATUS_EXIT_PENDING     (1<<14)
+
+#define STATUS_SCAN_PENDING     (1<<23)
+#define STATUS_SCANNING         (1<<24)
+#define STATUS_SCAN_ABORTING    (1<<25)
+#define STATUS_SCAN_COMPLETE    (1<<26)
+#define STATUS_WX_EVENT_PENDING (1<<27)
+#define STATUS_RESET_PENDING    (1<<29)
+#define STATUS_SECURITY_UPDATED (1<<30) /* Security sync needed */
+
+
+
+/* Internal NIC states */
+#define IPW_STATE_INITIALIZED	(1<<0)
+#define IPW_STATE_COUNTRY_FOUND	(1<<1)
+#define IPW_STATE_ASSOCIATED    (1<<2)
+#define IPW_STATE_ASSN_LOST	(1<<3)
+#define IPW_STATE_ASSN_CHANGED 	(1<<4)
+#define IPW_STATE_SCAN_COMPLETE	(1<<5)
+#define IPW_STATE_ENTERED_PSP 	(1<<6)
+#define IPW_STATE_LEFT_PSP 	(1<<7)
+#define IPW_STATE_RF_KILL       (1<<8)
+#define IPW_STATE_DISABLED	(1<<9)
+#define IPW_STATE_POWER_DOWN	(1<<10)
+#define IPW_STATE_SCANNING      (1<<11)
+
+
+
+#define CFG_STATIC_CHANNEL      (1<<0) /* Restrict assoc. to single channel */
+#define CFG_STATIC_ESSID        (1<<1) /* Restrict assoc. to single SSID */
+#define CFG_STATIC_BSSID        (1<<2) /* Restrict assoc. to single BSSID */
+#define CFG_CUSTOM_MAC          (1<<3)
+#define CFG_LONG_PREAMBLE       (1<<4)
+#define CFG_ASSOCIATE           (1<<6)
+#define CFG_FIXED_RATE          (1<<7)
+#define CFG_ADHOC_CREATE        (1<<8)
+#define CFG_C3_DISABLED         (1<<9)
+#define CFG_PASSIVE_SCAN        (1<<10)
+
+#define CAP_SHARED_KEY          (1<<0) /* Off = OPEN */
+#define CAP_PRIVACY_ON          (1<<1) /* Off = No privacy */
+
+struct ipw2100_priv {
+
+	int stop_hang_check; /* Set 1 when shutting down to kill hang_check */
+	int stop_rf_kill; /* Set 1 when shutting down to kill rf_kill */
+
+	struct ieee80211_device *ieee;
+	unsigned long status;
+	unsigned long config;
+	unsigned long capability;
+
+	/* Statistics */
+	int resets;
+	int reset_backoff;
+
+	/* Context */
+	u8 essid[IW_ESSID_MAX_SIZE];
+	u8 essid_len;
+	u8 bssid[ETH_ALEN];
+	u8 channel;
+	int last_mode;
+	int cstate_limit;
+
+	unsigned long connect_start;
+	unsigned long last_reset;
+
+	u32 channel_mask;
+	u32 fatal_error;
+	u32 fatal_errors[IPW2100_ERROR_QUEUE];
+	u32 fatal_index;
+	int eeprom_version;
+	int firmware_version;
+	unsigned long hw_features;
+	int hangs;
+	u32 last_rtc;
+	int dump_raw; /* 1 to dump raw bytes in /sys/.../memory */
+	u8* snapshot[0x30];
+
+	u8 mandatory_bssid_mac[ETH_ALEN];
+	u8 mac_addr[ETH_ALEN];
+
+	int power_mode;
+
+	/* WEP data */
+	struct ieee80211_security sec;
+	int messages_sent;
+
+
+	int short_retry_limit;
+	int long_retry_limit;
+
+	u32 rts_threshold;
+	u32 frag_threshold;
+
+	int in_isr;
+
+	u32 tx_rates;
+	int tx_power;
+	u32 beacon_interval;
+
+	char nick[IW_ESSID_MAX_SIZE + 1];
+
+	struct ipw2100_status_queue status_queue;
+
+	struct statistic txq_stat;
+	struct statistic rxq_stat;
+	struct ipw2100_bd_queue rx_queue;
+	struct ipw2100_bd_queue tx_queue;
+	struct ipw2100_rx_packet *rx_buffers;
+
+	struct statistic fw_pend_stat;
+	struct list_head fw_pend_list;
+
+	struct statistic msg_free_stat;
+	struct statistic msg_pend_stat;
+	struct list_head msg_free_list;
+	struct list_head msg_pend_list;
+	struct ipw2100_tx_packet *msg_buffers;
+
+	struct statistic tx_free_stat;
+	struct statistic tx_pend_stat;
+	struct list_head tx_free_list;
+	struct list_head tx_pend_list;
+	struct ipw2100_tx_packet *tx_buffers;
+
+	struct ipw2100_ordinals ordinals;
+
+	struct pci_dev *pci_dev;
+
+	struct proc_dir_entry *dir_dev;
+
+	struct net_device *net_dev;
+	struct iw_statistics wstats;
+
+	struct tasklet_struct irq_tasklet;
+
+	struct workqueue_struct *workqueue;
+	struct work_struct reset_work;
+	struct work_struct security_work;
+	struct work_struct wx_event_work;
+	struct work_struct hang_check;
+	struct work_struct rf_kill;
+
+	u32 interrupts;
+	int tx_interrupts;
+	int rx_interrupts;
+	int inta_other;
+
+	spinlock_t low_lock;
+	struct semaphore action_sem;
+	struct semaphore adapter_sem;
+
+	wait_queue_head_t wait_command_queue;
+#if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,10)
+	u32 pm_state[PM_STATE_SIZE];
+#endif
+};
+
+
+/*********************************************************
+ * Host Command -> From Driver to FW
+ *********************************************************/
+
+/**
+ * Host command identifiers
+ */
+#define HOST_COMPLETE           2
+#define SYSTEM_CONFIG           6
+#define SSID                    8
+#define MANDATORY_BSSID         9
+#define AUTHENTICATION_TYPE    10
+#define ADAPTER_ADDRESS        11
+#define PORT_TYPE              12
+#define INTERNATIONAL_MODE     13
+#define CHANNEL                14
+#define RTS_THRESHOLD          15
+#define FRAG_THRESHOLD         16
+#define POWER_MODE             17
+#define TX_RATES               18
+#define BASIC_TX_RATES         19
+#define WEP_KEY_INFO           20
+#define WEP_KEY_INDEX          25
+#define WEP_FLAGS              26
+#define ADD_MULTICAST          27
+#define CLEAR_ALL_MULTICAST    28
+#define BEACON_INTERVAL        29
+#define ATIM_WINDOW            30
+#define CLEAR_STATISTICS       31
+#define SEND		       33
+#define TX_POWER_INDEX         36
+#define BROADCAST_SCAN         43
+#define CARD_DISABLE           44
+#define PREFERRED_BSSID        45
+#define SET_SCAN_OPTIONS       46
+#define SCAN_DWELL_TIME        47
+#define SWEEP_TABLE            48
+#define AP_OR_STATION_TABLE    49
+#define GROUP_ORDINALS         50
+#define SHORT_RETRY_LIMIT      51
+#define LONG_RETRY_LIMIT       52
+
+#define HOST_PRE_POWER_DOWN    58
+#define CARD_DISABLE_PHY_OFF   61
+#define MSDU_TX_RATES          62
+
+
+// Rogue AP Detection
+#define SET_STATION_STAT_BITS      64
+#define CLEAR_STATIONS_STAT_BITS   65
+#define LEAP_ROGUE_MODE            66	//TODO tbw replaced by CFG_LEAP_ROGUE_AP
+#define SET_SECURITY_INFORMATION   67
+#define DISASSOCIATION_BSSID	   68
+#define SET_WPA_IE                 69
+
+
+
+// system configuration bit mask:
+//#define IPW_CFG_ANTENNA_SETTING           0x03
+//#define IPW_CFG_ANTENNA_A                 0x01
+//#define IPW_CFG_ANTENNA_B                 0x02
+#define IPW_CFG_MONITOR               0x00004
+//#define IPW_CFG_TX_STATUS_ENABLE    0x00008
+#define IPW_CFG_PREAMBLE_AUTO        0x00010
+#define IPW_CFG_IBSS_AUTO_START     0x00020
+//#define IPW_CFG_KERBEROS_ENABLE     0x00040
+#define IPW_CFG_LOOPBACK            0x00100
+//#define IPW_CFG_WNMP_PING_PASS      0x00200
+//#define IPW_CFG_DEBUG_ENABLE        0x00400
+#define IPW_CFG_ANSWER_BCSSID_PROBE 0x00800
+//#define IPW_CFG_BT_PRIORITY         0x01000
+#define IPW_CFG_BT_SIDEBAND_SIGNAL	0x02000
+#define IPW_CFG_802_1x_ENABLE       0x04000
+#define IPW_CFG_BSS_MASK		0x08000
+#define IPW_CFG_IBSS_MASK		0x10000
+//#define IPW_CFG_DYNAMIC_CW          0x10000
+
+#define IPW_SCAN_NOASSOCIATE (1<<0)
+#define IPW_SCAN_MIXED_CELL (1<<1)
+/* RESERVED (1<<2) */
+#define IPW_SCAN_PASSIVE (1<<3)
+
+#define IPW_NIC_FATAL_ERROR 0x2A7F0
+#define IPW_ERROR_ADDR(x) (x & 0x3FFFF)
+#define IPW_ERROR_CODE(x) ((x & 0xFF000000) >> 24)
+#define IPW2100_ERR_C3_CORRUPTION (0x10 << 24)
+#define IPW2100_ERR_MSG_TIMEOUT   (0x11 << 24)
+#define IPW2100_ERR_FW_LOAD       (0x12 << 24)
+
+#define IPW_MEM_SRAM_HOST_SHARED_LOWER_BOUND			0x200
+#define IPW_MEM_SRAM_HOST_INTERRUPT_AREA_LOWER_BOUND  	IPW_MEM_SRAM_HOST_SHARED_LOWER_BOUND + 0x0D80
+
+#define IPW_MEM_HOST_SHARED_RX_BD_BASE                  (IPW_MEM_SRAM_HOST_SHARED_LOWER_BOUND + 0x40)
+#define IPW_MEM_HOST_SHARED_RX_STATUS_BASE              (IPW_MEM_SRAM_HOST_SHARED_LOWER_BOUND + 0x44)
+#define IPW_MEM_HOST_SHARED_RX_BD_SIZE                  (IPW_MEM_SRAM_HOST_SHARED_LOWER_BOUND + 0x48)
+#define IPW_MEM_HOST_SHARED_RX_READ_INDEX               (IPW_MEM_SRAM_HOST_SHARED_LOWER_BOUND + 0xa0)
+
+#define IPW_MEM_HOST_SHARED_TX_QUEUE_BD_BASE          (IPW_MEM_SRAM_HOST_SHARED_LOWER_BOUND + 0x00)
+#define IPW_MEM_HOST_SHARED_TX_QUEUE_BD_SIZE          (IPW_MEM_SRAM_HOST_SHARED_LOWER_BOUND + 0x04)
+#define IPW_MEM_HOST_SHARED_TX_QUEUE_READ_INDEX       (IPW_MEM_SRAM_HOST_SHARED_LOWER_BOUND + 0x80)
+
+#define IPW_MEM_HOST_SHARED_RX_WRITE_INDEX \
+    (IPW_MEM_SRAM_HOST_INTERRUPT_AREA_LOWER_BOUND + 0x20)
+
+#define IPW_MEM_HOST_SHARED_TX_QUEUE_WRITE_INDEX \
+    (IPW_MEM_SRAM_HOST_INTERRUPT_AREA_LOWER_BOUND)
+
+
+#if 0
+#define IPW_MEM_HOST_SHARED_TX_QUEUE_0_BD_BASE          (IPW_MEM_SRAM_HOST_SHARED_LOWER_BOUND + 0x00)
+#define IPW_MEM_HOST_SHARED_TX_QUEUE_0_BD_SIZE          (IPW_MEM_SRAM_HOST_SHARED_LOWER_BOUND + 0x04)
+#define IPW_MEM_HOST_SHARED_TX_QUEUE_1_BD_BASE          (IPW_MEM_SRAM_HOST_SHARED_LOWER_BOUND + 0x08)
+#define IPW_MEM_HOST_SHARED_TX_QUEUE_1_BD_SIZE          (IPW_MEM_SRAM_HOST_SHARED_LOWER_BOUND + 0x0c)
+#define IPW_MEM_HOST_SHARED_TX_QUEUE_2_BD_BASE          (IPW_MEM_SRAM_HOST_SHARED_LOWER_BOUND + 0x10)
+#define IPW_MEM_HOST_SHARED_TX_QUEUE_2_BD_SIZE          (IPW_MEM_SRAM_HOST_SHARED_LOWER_BOUND + 0x14)
+#define IPW_MEM_HOST_SHARED_TX_QUEUE_3_BD_BASE          (IPW_MEM_SRAM_HOST_SHARED_LOWER_BOUND + 0x18)
+#define IPW_MEM_HOST_SHARED_TX_QUEUE_3_BD_SIZE          (IPW_MEM_SRAM_HOST_SHARED_LOWER_BOUND + 0x1c)
+#define IPW_MEM_HOST_SHARED_TX_QUEUE_0_READ_INDEX       (IPW_MEM_SRAM_HOST_SHARED_LOWER_BOUND + 0x80)
+#define IPW_MEM_HOST_SHARED_TX_QUEUE_1_READ_INDEX       (IPW_MEM_SRAM_HOST_SHARED_LOWER_BOUND + 0x84)
+#define IPW_MEM_HOST_SHARED_TX_QUEUE_2_READ_INDEX       (IPW_MEM_SRAM_HOST_SHARED_LOWER_BOUND + 0x88)
+#define IPW_MEM_HOST_SHARED_TX_QUEUE_3_READ_INDEX       (IPW_MEM_SRAM_HOST_SHARED_LOWER_BOUND + 0x8c)
+
+#define IPW_MEM_HOST_SHARED_TX_QUEUE_BD_BASE(QueueNum) \
+    (IPW_MEM_SRAM_HOST_SHARED_LOWER_BOUND + (QueueNum<<3))
+#define IPW_MEM_HOST_SHARED_TX_QUEUE_BD_SIZE(QueueNum) \
+    (IPW_MEM_SRAM_HOST_SHARED_LOWER_BOUND + 0x0004+(QueueNum<<3))
+#define IPW_MEM_HOST_SHARED_TX_QUEUE_READ_INDEX(QueueNum) \
+    (IPW_MEM_SRAM_HOST_SHARED_LOWER_BOUND + 0x0080+(QueueNum<<2))
+
+#define IPW_MEM_HOST_SHARED_TX_QUEUE_0_WRITE_INDEX \
+    (IPW_MEM_SRAM_HOST_INTERRUPT_AREA_LOWER_BOUND + 0x00)
+#define IPW_MEM_HOST_SHARED_TX_QUEUE_1_WRITE_INDEX \
+    (IPW_MEM_SRAM_HOST_INTERRUPT_AREA_LOWER_BOUND + 0x04)
+#define IPW_MEM_HOST_SHARED_TX_QUEUE_2_WRITE_INDEX \
+    (IPW_MEM_SRAM_HOST_INTERRUPT_AREA_LOWER_BOUND + 0x08)
+#define IPW_MEM_HOST_SHARED_TX_QUEUE_3_WRITE_INDEX \
+    (IPW_MEM_SRAM_HOST_INTERRUPT_AREA_LOWER_BOUND + 0x0c)
+#define IPW_MEM_HOST_SHARED_SLAVE_MODE_INT_REGISTER \
+    (IPW_MEM_SRAM_HOST_INTERRUPT_AREA_LOWER_BOUND + 0x78)
+
+#endif
+
+#define IPW_MEM_HOST_SHARED_ORDINALS_TABLE_1   (IPW_MEM_SRAM_HOST_SHARED_LOWER_BOUND + 0x180)
+#define IPW_MEM_HOST_SHARED_ORDINALS_TABLE_2   (IPW_MEM_SRAM_HOST_SHARED_LOWER_BOUND + 0x184)
+
+#define IPW2100_INTA_TX_TRANSFER               (0x00000001)	// Bit 0 (LSB)
+#define IPW2100_INTA_RX_TRANSFER               (0x00000002)	// Bit 1
+#define IPW2100_INTA_TX_COMPLETE	       (0x00000004)	// Bit 2
+#define IPW2100_INTA_EVENT_INTERRUPT           (0x00000008)     // Bit 3
+#define IPW2100_INTA_STATUS_CHANGE             (0x00000010)	// Bit 4
+#define IPW2100_INTA_BEACON_PERIOD_EXPIRED     (0x00000020)	// Bit 5
+#define IPW2100_INTA_SLAVE_MODE_HOST_COMMAND_DONE  (0x00010000)	// Bit 16
+#define IPW2100_INTA_FW_INIT_DONE              (0x01000000)	// Bit 24
+#define IPW2100_INTA_FW_CALIBRATION_CALC       (0x02000000)	// Bit 25
+#define IPW2100_INTA_FATAL_ERROR               (0x40000000)	// Bit 30
+#define IPW2100_INTA_PARITY_ERROR              (0x80000000)	// Bit 31 (MSB)
+
+#define IPW_AUX_HOST_RESET_REG_PRINCETON_RESET              (0x00000001)
+#define IPW_AUX_HOST_RESET_REG_FORCE_NMI                    (0x00000002)
+#define IPW_AUX_HOST_RESET_REG_PCI_HOST_CLUSTER_FATAL_NMI   (0x00000004)
+#define IPW_AUX_HOST_RESET_REG_CORE_FATAL_NMI               (0x00000008)
+#define IPW_AUX_HOST_RESET_REG_SW_RESET                     (0x00000080)
+#define IPW_AUX_HOST_RESET_REG_MASTER_DISABLED              (0x00000100)
+#define IPW_AUX_HOST_RESET_REG_STOP_MASTER                  (0x00000200)
+
+#define IPW_AUX_HOST_GP_CNTRL_BIT_CLOCK_READY           (0x00000001)	// Bit 0 (LSB)
+#define IPW_AUX_HOST_GP_CNTRL_BIT_HOST_ALLOWS_STANDBY   (0x00000002)	// Bit 1
+#define IPW_AUX_HOST_GP_CNTRL_BIT_INIT_DONE             (0x00000004)	// Bit 2
+#define IPW_AUX_HOST_GP_CNTRL_BITS_SYS_CONFIG           (0x000007c0)	// Bits 6-10
+#define IPW_AUX_HOST_GP_CNTRL_BIT_BUS_TYPE              (0x00000200)	// Bit 9
+#define IPW_AUX_HOST_GP_CNTRL_BIT_BAR0_BLOCK_SIZE       (0x00000400)	// Bit 10
+#define IPW_AUX_HOST_GP_CNTRL_BIT_USB_MODE              (0x20000000)	// Bit 29
+#define IPW_AUX_HOST_GP_CNTRL_BIT_HOST_FORCES_SYS_CLK   (0x40000000)	// Bit 30
+#define IPW_AUX_HOST_GP_CNTRL_BIT_FW_FORCES_SYS_CLK     (0x80000000)	// Bit 31 (MSB)
+
+#define IPW_BIT_GPIO_GPIO1_MASK         0x0000000C
+#define IPW_BIT_GPIO_GPIO3_MASK         0x000000C0
+#define IPW_BIT_GPIO_GPIO1_ENABLE       0x00000008
+#define IPW_BIT_GPIO_RF_KILL            0x00010000
+
+#define IPW_BIT_GPIO_LED_OFF            0x00002000	// Bit 13 = 1
+
+#define IPW_REG_DOMAIN_0_OFFSET 	0x0000
+#define IPW_REG_DOMAIN_1_OFFSET 	IPW_MEM_SRAM_HOST_SHARED_LOWER_BOUND
+
+#define IPW_REG_INTA			IPW_REG_DOMAIN_0_OFFSET + 0x0008
+#define IPW_REG_INTA_MASK		IPW_REG_DOMAIN_0_OFFSET + 0x000C
+#define IPW_REG_INDIRECT_ACCESS_ADDRESS	IPW_REG_DOMAIN_0_OFFSET + 0x0010
+#define IPW_REG_INDIRECT_ACCESS_DATA	IPW_REG_DOMAIN_0_OFFSET + 0x0014
+#define IPW_REG_AUTOINCREMENT_ADDRESS	IPW_REG_DOMAIN_0_OFFSET + 0x0018
+#define IPW_REG_AUTOINCREMENT_DATA	IPW_REG_DOMAIN_0_OFFSET + 0x001C
+#define IPW_REG_RESET_REG		IPW_REG_DOMAIN_0_OFFSET + 0x0020
+#define IPW_REG_GP_CNTRL		IPW_REG_DOMAIN_0_OFFSET + 0x0024
+#define IPW_REG_GPIO			IPW_REG_DOMAIN_0_OFFSET + 0x0030
+#define IPW_REG_FW_TYPE                 IPW_REG_DOMAIN_1_OFFSET + 0x0188
+#define IPW_REG_FW_VERSION 		IPW_REG_DOMAIN_1_OFFSET + 0x018C
+#define IPW_REG_FW_COMPATABILITY_VERSION IPW_REG_DOMAIN_1_OFFSET + 0x0190
+
+#define IPW_REG_INDIRECT_ADDR_MASK	0x00FFFFFC
+
+#define IPW_INTERRUPT_MASK		0xC1010013
+
+#define IPW2100_CONTROL_REG             0x220000
+#define IPW2100_CONTROL_PHY_OFF         0x8
+
+#define IPW2100_COMMAND			0x00300004
+#define IPW2100_COMMAND_PHY_ON		0x0
+#define IPW2100_COMMAND_PHY_OFF		0x1
+
+/* in DEBUG_AREA, values of memory always 0xd55555d5 */
+#define IPW_REG_DOA_DEBUG_AREA_START    IPW_REG_DOMAIN_0_OFFSET + 0x0090
+#define IPW_REG_DOA_DEBUG_AREA_END      IPW_REG_DOMAIN_0_OFFSET + 0x00FF
+#define IPW_DATA_DOA_DEBUG_VALUE        0xd55555d5
+
+#define IPW_INTERNAL_REGISTER_HALT_AND_RESET	0x003000e0
+
+#define IPW_WAIT_CLOCK_STABILIZATION_DELAY	    50	// micro seconds
+#define IPW_WAIT_RESET_ARC_COMPLETE_DELAY	    10	// micro seconds
+#define IPW_WAIT_RESET_MASTER_ASSERT_COMPLETE_DELAY 10	// micro seconds
+
+// BD ring queue read/write difference
+#define IPW_BD_QUEUE_W_R_MIN_SPARE 2
+
+#define IPW_CACHE_LINE_LENGTH_DEFAULT		    0x80
+
+#define IPW_CARD_DISABLE_PHY_OFF_COMPLETE_WAIT	    100	// 100 milli
+#define IPW_PREPARE_POWER_DOWN_COMPLETE_WAIT	    100	// 100 milli
+
+
+
+
+#define IPW_HEADER_802_11_SIZE		 sizeof(struct ieee80211_header_data)
+#define IPW_MAX_80211_PAYLOAD_SIZE              2304U
+#define IPW_MAX_802_11_PAYLOAD_LENGTH		2312
+#define IPW_MAX_ACCEPTABLE_TX_FRAME_LENGTH	1536
+#define IPW_MIN_ACCEPTABLE_RX_FRAME_LENGTH	60
+#define IPW_MAX_ACCEPTABLE_RX_FRAME_LENGTH \
+	(IPW_MAX_ACCEPTABLE_TX_FRAME_LENGTH + IPW_HEADER_802_11_SIZE - \
+        sizeof(struct ethhdr))
+
+#define IPW_802_11_FCS_LENGTH 4
+#define IPW_RX_NIC_BUFFER_LENGTH \
+        (IPW_MAX_802_11_PAYLOAD_LENGTH + IPW_HEADER_802_11_SIZE + \
+		IPW_802_11_FCS_LENGTH)
+
+#define IPW_802_11_PAYLOAD_OFFSET \
+        (sizeof(struct ieee80211_header_data) + \
+         sizeof(struct ieee80211_snap_hdr))
+
+struct ipw2100_rx {
+	union {
+		unsigned char payload[IPW_RX_NIC_BUFFER_LENGTH];
+		struct ieee80211_hdr header;
+		u32 status;
+		struct ipw2100_notification notification;
+		struct ipw2100_cmd_header command;
+	} rx_data;
+} __attribute__ ((packed));
+
+// Bit 0-7 are for 802.11b tx rates - .  Bit 5-7 are reserved
+#define TX_RATE_1_MBIT              0x0001
+#define TX_RATE_2_MBIT              0x0002
+#define TX_RATE_5_5_MBIT            0x0004
+#define TX_RATE_11_MBIT             0x0008
+#define TX_RATE_MASK                0x000F
+#define DEFAULT_TX_RATES            0x000F
+
+#define IPW_POWER_MODE_CAM           0x00	//(always on)
+#define IPW_POWER_INDEX_1            0x01
+#define IPW_POWER_INDEX_2            0x02
+#define IPW_POWER_INDEX_3            0x03
+#define IPW_POWER_INDEX_4            0x04
+#define IPW_POWER_INDEX_5            0x05
+#define IPW_POWER_AUTO               0x06
+#define IPW_POWER_MASK               0x0F
+#define IPW_POWER_ENABLED            0x10
+#define IPW_POWER_LEVEL(x)           ((x) & IPW_POWER_MASK)
+
+#define IPW_TX_POWER_AUTO            0
+#define IPW_TX_POWER_ENHANCED        1
+
+#define IPW_TX_POWER_DEFAULT         32
+#define IPW_TX_POWER_MIN             0
+#define IPW_TX_POWER_MAX             16
+#define IPW_TX_POWER_MIN_DBM         (-12)
+#define IPW_TX_POWER_MAX_DBM         16
+
+#define FW_SCAN_DONOT_ASSOCIATE     0x0001 // Dont Attempt to Associate after Scan
+#define FW_SCAN_PASSIVE             0x0008 // Force PASSSIVE Scan
+
+#define REG_MIN_CHANNEL             0
+#define REG_MAX_CHANNEL             14
+
+#define REG_CHANNEL_MASK            0x00003FFF
+#define IPW_IBSS_11B_DEFAULT_MASK   0x87ff
+
+#define DIVERSITY_EITHER            0	// Use both antennas
+#define DIVERSITY_ANTENNA_A         1	// Use antenna A
+#define DIVERSITY_ANTENNA_B         2	// Use antenna B
+
+
+#define HOST_COMMAND_WAIT 0
+#define HOST_COMMAND_NO_WAIT 1
+
+#define LOCK_NONE 0
+#define LOCK_DRIVER 1
+#define LOCK_FW 2
+
+#define TYPE_SWEEP_ORD                  0x000D
+#define TYPE_IBSS_STTN_ORD              0x000E
+#define TYPE_BSS_AP_ORD                 0x000F
+#define TYPE_RAW_BEACON_ENTRY           0x0010
+#define TYPE_CALIBRATION_DATA           0x0011
+#define TYPE_ROGUE_AP_DATA              0x0012
+#define TYPE_ASSOCIATION_REQUEST	0x0013
+#define TYPE_REASSOCIATION_REQUEST	0x0014
+
+
+#define HW_FEATURE_RFKILL (0x0001)
+#define RF_KILLSWITCH_OFF (1)
+#define RF_KILLSWITCH_ON  (0)
+
+#define IPW_COMMAND_POOL_SIZE        40
+
+#define IPW_START_ORD_TAB_1			1
+#define IPW_START_ORD_TAB_2			1000
+
+#define IPW_ORD_TAB_1_ENTRY_SIZE		sizeof(u32)
+
+#define IS_ORDINAL_TABLE_ONE(mgr,id) \
+    ((id >= IPW_START_ORD_TAB_1) && (id < mgr->table1_size))
+#define IS_ORDINAL_TABLE_TWO(mgr,id) \
+    ((id >= IPW_START_ORD_TAB_2) && (id < (mgr->table2_size + IPW_START_ORD_TAB_2)))
+
+#define BSS_ID_LENGTH               6
+
+// Fixed size data: Ordinal Table 1
+typedef enum _ORDINAL_TABLE_1 {	// NS - means Not Supported by FW
+// Transmit statistics
+	IPW_ORD_STAT_TX_HOST_REQUESTS = 1,// # of requested Host Tx's (MSDU)
+	IPW_ORD_STAT_TX_HOST_COMPLETE,	// # of successful Host Tx's (MSDU)
+	IPW_ORD_STAT_TX_DIR_DATA,	// # of successful Directed Tx's (MSDU)
+
+	IPW_ORD_STAT_TX_DIR_DATA1 = 4,	// # of successful Directed Tx's (MSDU) @ 1MB
+	IPW_ORD_STAT_TX_DIR_DATA2,	// # of successful Directed Tx's (MSDU) @ 2MB
+	IPW_ORD_STAT_TX_DIR_DATA5_5,	// # of successful Directed Tx's (MSDU) @ 5_5MB
+	IPW_ORD_STAT_TX_DIR_DATA11,	// # of successful Directed Tx's (MSDU) @ 11MB
+	IPW_ORD_STAT_TX_DIR_DATA22,	// # of successful Directed Tx's (MSDU) @ 22MB
+
+	IPW_ORD_STAT_TX_NODIR_DATA1 = 13,// # of successful Non_Directed Tx's (MSDU) @ 1MB
+	IPW_ORD_STAT_TX_NODIR_DATA2,	// # of successful Non_Directed Tx's (MSDU) @ 2MB
+	IPW_ORD_STAT_TX_NODIR_DATA5_5,	// # of successful Non_Directed Tx's (MSDU) @ 5.5MB
+	IPW_ORD_STAT_TX_NODIR_DATA11,	// # of successful Non_Directed Tx's (MSDU) @ 11MB
+
+	IPW_ORD_STAT_NULL_DATA = 21,	// # of successful NULL data Tx's
+	IPW_ORD_STAT_TX_RTS,	        // # of successful Tx RTS
+	IPW_ORD_STAT_TX_CTS,	        // # of successful Tx CTS
+	IPW_ORD_STAT_TX_ACK,	        // # of successful Tx ACK
+	IPW_ORD_STAT_TX_ASSN,	        // # of successful Association Tx's
+	IPW_ORD_STAT_TX_ASSN_RESP,	// # of successful Association response Tx's
+	IPW_ORD_STAT_TX_REASSN,	        // # of successful Reassociation Tx's
+	IPW_ORD_STAT_TX_REASSN_RESP,	// # of successful Reassociation response Tx's
+	IPW_ORD_STAT_TX_PROBE,	        // # of probes successfully transmitted
+	IPW_ORD_STAT_TX_PROBE_RESP,	// # of probe responses successfully transmitted
+	IPW_ORD_STAT_TX_BEACON,	        // # of tx beacon
+	IPW_ORD_STAT_TX_ATIM,	        // # of Tx ATIM
+	IPW_ORD_STAT_TX_DISASSN,	// # of successful Disassociation TX
+	IPW_ORD_STAT_TX_AUTH,	        // # of successful Authentication Tx
+	IPW_ORD_STAT_TX_DEAUTH,	        // # of successful Deauthentication TX
+
+	IPW_ORD_STAT_TX_TOTAL_BYTES = 41,// Total successful Tx data bytes
+	IPW_ORD_STAT_TX_RETRIES,         // # of Tx retries
+	IPW_ORD_STAT_TX_RETRY1,          // # of Tx retries at 1MBPS
+	IPW_ORD_STAT_TX_RETRY2,          // # of Tx retries at 2MBPS
+	IPW_ORD_STAT_TX_RETRY5_5,	 // # of Tx retries at 5.5MBPS
+	IPW_ORD_STAT_TX_RETRY11,	 // # of Tx retries at 11MBPS
+
+	IPW_ORD_STAT_TX_FAILURES = 51,	// # of Tx Failures
+	IPW_ORD_STAT_TX_ABORT_AT_HOP,	//NS // # of Tx's aborted at hop time
+	IPW_ORD_STAT_TX_MAX_TRIES_IN_HOP,// # of times max tries in a hop failed
+	IPW_ORD_STAT_TX_ABORT_LATE_DMA,	//NS // # of times tx aborted due to late dma setup
+	IPW_ORD_STAT_TX_ABORT_STX,	//NS // # of times backoff aborted
+	IPW_ORD_STAT_TX_DISASSN_FAIL,	// # of times disassociation failed
+	IPW_ORD_STAT_TX_ERR_CTS,         // # of missed/bad CTS frames
+	IPW_ORD_STAT_TX_BPDU,	        //NS // # of spanning tree BPDUs sent
+	IPW_ORD_STAT_TX_ERR_ACK,	// # of tx err due to acks
+
+	// Receive statistics
+	IPW_ORD_STAT_RX_HOST = 61,	// # of packets passed to host
+	IPW_ORD_STAT_RX_DIR_DATA,	// # of directed packets
+	IPW_ORD_STAT_RX_DIR_DATA1,	// # of directed packets at 1MB
+	IPW_ORD_STAT_RX_DIR_DATA2,	// # of directed packets at 2MB
+	IPW_ORD_STAT_RX_DIR_DATA5_5,	// # of directed packets at 5.5MB
+	IPW_ORD_STAT_RX_DIR_DATA11,	// # of directed packets at 11MB
+	IPW_ORD_STAT_RX_DIR_DATA22,	// # of directed packets at 22MB
+
+	IPW_ORD_STAT_RX_NODIR_DATA = 71,// # of nondirected packets
+	IPW_ORD_STAT_RX_NODIR_DATA1,	// # of nondirected packets at 1MB
+	IPW_ORD_STAT_RX_NODIR_DATA2,	// # of nondirected packets at 2MB
+	IPW_ORD_STAT_RX_NODIR_DATA5_5,	// # of nondirected packets at 5.5MB
+	IPW_ORD_STAT_RX_NODIR_DATA11,	// # of nondirected packets at 11MB
+
+	IPW_ORD_STAT_RX_NULL_DATA = 80,	// # of null data rx's
+	IPW_ORD_STAT_RX_POLL,	//NS // # of poll rx
+	IPW_ORD_STAT_RX_RTS,	// # of Rx RTS
+	IPW_ORD_STAT_RX_CTS,	// # of Rx CTS
+	IPW_ORD_STAT_RX_ACK,	// # of Rx ACK
+	IPW_ORD_STAT_RX_CFEND,	// # of Rx CF End
+	IPW_ORD_STAT_RX_CFEND_ACK,	// # of Rx CF End + CF Ack
+	IPW_ORD_STAT_RX_ASSN,	// # of Association Rx's
+	IPW_ORD_STAT_RX_ASSN_RESP,	// # of Association response Rx's
+	IPW_ORD_STAT_RX_REASSN,	// # of Reassociation Rx's
+	IPW_ORD_STAT_RX_REASSN_RESP,	// # of Reassociation response Rx's
+	IPW_ORD_STAT_RX_PROBE,	// # of probe Rx's
+	IPW_ORD_STAT_RX_PROBE_RESP,	// # of probe response Rx's
+	IPW_ORD_STAT_RX_BEACON,	// # of Rx beacon
+	IPW_ORD_STAT_RX_ATIM,	// # of Rx ATIM
+	IPW_ORD_STAT_RX_DISASSN,	// # of disassociation Rx
+	IPW_ORD_STAT_RX_AUTH,	// # of authentication Rx
+	IPW_ORD_STAT_RX_DEAUTH,	// # of deauthentication Rx
+
+	IPW_ORD_STAT_RX_TOTAL_BYTES = 101,// Total rx data bytes received
+	IPW_ORD_STAT_RX_ERR_CRC,	 // # of packets with Rx CRC error
+	IPW_ORD_STAT_RX_ERR_CRC1,	 // # of Rx CRC errors at 1MB
+	IPW_ORD_STAT_RX_ERR_CRC2,	 // # of Rx CRC errors at 2MB
+	IPW_ORD_STAT_RX_ERR_CRC5_5,	 // # of Rx CRC errors at 5.5MB
+	IPW_ORD_STAT_RX_ERR_CRC11,	 // # of Rx CRC errors at 11MB
+
+	IPW_ORD_STAT_RX_DUPLICATE1 = 112, // # of duplicate rx packets at 1MB
+	IPW_ORD_STAT_RX_DUPLICATE2,	 // # of duplicate rx packets at 2MB
+	IPW_ORD_STAT_RX_DUPLICATE5_5,	 // # of duplicate rx packets at 5.5MB
+	IPW_ORD_STAT_RX_DUPLICATE11,	 // # of duplicate rx packets at 11MB
+	IPW_ORD_STAT_RX_DUPLICATE = 119, // # of duplicate rx packets
+
+	IPW_ORD_PERS_DB_LOCK = 120,	// # locking fw permanent  db
+	IPW_ORD_PERS_DB_SIZE,	// # size of fw permanent  db
+	IPW_ORD_PERS_DB_ADDR,	// # address of fw permanent  db
+	IPW_ORD_STAT_RX_INVALID_PROTOCOL,	// # of rx frames with invalid protocol
+	IPW_ORD_SYS_BOOT_TIME,	// # Boot time
+	IPW_ORD_STAT_RX_NO_BUFFER,	// # of rx frames rejected due to no buffer
+	IPW_ORD_STAT_RX_ABORT_LATE_DMA,	//NS // # of rx frames rejected due to dma setup too late
+	IPW_ORD_STAT_RX_ABORT_AT_HOP,	//NS // # of rx frames aborted due to hop
+	IPW_ORD_STAT_RX_MISSING_FRAG,	// # of rx frames dropped due to missing fragment
+	IPW_ORD_STAT_RX_ORPHAN_FRAG,	// # of rx frames dropped due to non-sequential fragment
+	IPW_ORD_STAT_RX_ORPHAN_FRAME,	// # of rx frames dropped due to unmatched 1st frame
+	IPW_ORD_STAT_RX_FRAG_AGEOUT,	// # of rx frames dropped due to uncompleted frame
+	IPW_ORD_STAT_RX_BAD_SSID,	//NS // Bad SSID (unused)
+	IPW_ORD_STAT_RX_ICV_ERRORS,	// # of ICV errors during decryption
+
+// PSP Statistics
+	IPW_ORD_STAT_PSP_SUSPENSION = 137,// # of times adapter suspended
+	IPW_ORD_STAT_PSP_BCN_TIMEOUT,	// # of beacon timeout
+	IPW_ORD_STAT_PSP_POLL_TIMEOUT,	// # of poll response timeouts
+	IPW_ORD_STAT_PSP_NONDIR_TIMEOUT,// # of timeouts waiting for last broadcast/muticast pkt
+	IPW_ORD_STAT_PSP_RX_DTIMS,	// # of PSP DTIMs received
+	IPW_ORD_STAT_PSP_RX_TIMS,	// # of PSP TIMs received
+	IPW_ORD_STAT_PSP_STATION_ID,	// PSP Station ID
+
+// Association and roaming
+	IPW_ORD_LAST_ASSN_TIME = 147,	// RTC time of last association
+	IPW_ORD_STAT_PERCENT_MISSED_BCNS,// current calculation of % missed beacons
+	IPW_ORD_STAT_PERCENT_RETRIES,	// current calculation of % missed tx retries
+	IPW_ORD_ASSOCIATED_AP_PTR,	// If associated, this is ptr to the associated
+	// AP table entry. set to 0 if not associated
+	IPW_ORD_AVAILABLE_AP_CNT,	// # of AP's decsribed in the AP table
+	IPW_ORD_AP_LIST_PTR,	// Ptr to list of available APs
+	IPW_ORD_STAT_AP_ASSNS,	// # of associations
+	IPW_ORD_STAT_ASSN_FAIL,	// # of association failures
+	IPW_ORD_STAT_ASSN_RESP_FAIL,	// # of failuresdue to response fail
+	IPW_ORD_STAT_FULL_SCANS,	// # of full scans
+
+	IPW_ORD_CARD_DISABLED,	// # Card Disabled
+	IPW_ORD_STAT_ROAM_INHIBIT,	// # of times roaming was inhibited due to ongoing activity
+	IPW_FILLER_40,
+	IPW_ORD_RSSI_AT_ASSN = 160,	// RSSI of associated AP at time of association
+	IPW_ORD_STAT_ASSN_CAUSE1,	// # of reassociations due to no tx from AP in last N
+	// hops or no prob_ responses in last 3 minutes
+	IPW_ORD_STAT_ASSN_CAUSE2,	// # of reassociations due to poor tx/rx quality
+	IPW_ORD_STAT_ASSN_CAUSE3,	// # of reassociations due to tx/rx quality with excessive
+	// load at the AP
+	IPW_ORD_STAT_ASSN_CAUSE4,	// # of reassociations due to AP RSSI level fell below
+	// eligible group
+	IPW_ORD_STAT_ASSN_CAUSE5,	// # of reassociations due to load leveling
+	IPW_ORD_STAT_ASSN_CAUSE6,	//NS // # of reassociations due to dropped by Ap
+	IPW_FILLER_41,
+	IPW_FILLER_42,
+	IPW_FILLER_43,
+	IPW_ORD_STAT_AUTH_FAIL,	// # of times authentication failed
+	IPW_ORD_STAT_AUTH_RESP_FAIL,	// # of times authentication response failed
+	IPW_ORD_STATION_TABLE_CNT,	// # of entries in association table
+
+// Other statistics
+	IPW_ORD_RSSI_AVG_CURR = 173,	// Current avg RSSI
+	IPW_ORD_STEST_RESULTS_CURR,	//NS // Current self test results word
+	IPW_ORD_STEST_RESULTS_CUM,	//NS // Cummulative self test results word
+	IPW_ORD_SELF_TEST_STATUS,	//NS //
+	IPW_ORD_POWER_MGMT_MODE,	// Power mode - 0=CAM, 1=PSP
+	IPW_ORD_POWER_MGMT_INDEX,	//NS //
+	IPW_ORD_COUNTRY_CODE,	// IEEE country code as recv'd from beacon
+	IPW_ORD_COUNTRY_CHANNELS,	// channels suported by country
+// IPW_ORD_COUNTRY_CHANNELS:
+// For 11b the lower 2-byte are used for channels from 1-14
+//   and the higher 2-byte are not used.
+	IPW_ORD_RESET_CNT,	// # of adapter resets (warm)
+	IPW_ORD_BEACON_INTERVAL,	// Beacon interval
+
+	IPW_ORD_PRINCETON_VERSION = 184,	//NS // Princeton Version
+	IPW_ORD_ANTENNA_DIVERSITY,	// TRUE if antenna diversity is disabled
+	IPW_ORD_CCA_RSSI,	//NS // CCA RSSI value (factory programmed)
+	IPW_ORD_STAT_EEPROM_UPDATE,	//NS // # of times config EEPROM updated
+	IPW_ORD_DTIM_PERIOD,	// # of beacon intervals between DTIMs
+	IPW_ORD_OUR_FREQ,	// current radio freq lower digits - channel ID
+
+	IPW_ORD_RTC_TIME = 190,	// current RTC time
+	IPW_ORD_PORT_TYPE,	// operating mode
+	IPW_ORD_CURRENT_TX_RATE,	// current tx rate
+	IPW_ORD_SUPPORTED_RATES,	// Bitmap of supported tx rates
+	IPW_ORD_ATIM_WINDOW,	// current ATIM Window
+	IPW_ORD_BASIC_RATES,	// bitmap of basic tx rates
+	IPW_ORD_NIC_HIGHEST_RATE,	// bitmap of basic tx rates
+	IPW_ORD_AP_HIGHEST_RATE,	// bitmap of basic tx rates
+	IPW_ORD_CAPABILITIES,	// Management frame capability field
+	IPW_ORD_AUTH_TYPE,	// Type of authentication
+	IPW_ORD_RADIO_TYPE,	// Adapter card platform type
+	IPW_ORD_RTS_THRESHOLD = 201,	// Min length of packet after which RTS handshaking is used
+	IPW_ORD_INT_MODE,	// International mode
+	IPW_ORD_FRAGMENTATION_THRESHOLD,	// protocol frag threshold
+	IPW_ORD_EEPROM_SRAM_DB_BLOCK_START_ADDRESS,	// EEPROM offset in SRAM
+	IPW_ORD_EEPROM_SRAM_DB_BLOCK_SIZE,	// EEPROM size in SRAM
+	IPW_ORD_EEPROM_SKU_CAPABILITY,	// EEPROM SKU Capability    206 =
+	IPW_ORD_EEPROM_IBSS_11B_CHANNELS,	// EEPROM IBSS 11b channel set
+
+	IPW_ORD_MAC_VERSION = 209,	// MAC Version
+	IPW_ORD_MAC_REVISION,	// MAC Revision
+	IPW_ORD_RADIO_VERSION,	// Radio Version
+	IPW_ORD_NIC_MANF_DATE_TIME,	// MANF Date/Time STAMP
+	IPW_ORD_UCODE_VERSION,	// Ucode Version
+	IPW_ORD_HW_RF_SWITCH_STATE = 214,	// HW RF Kill Switch State
+} ORDINALTABLE1;
+//ENDOF TABLE1
+
+// ordinal table 2
+// Variable length data:
+#define IPW_FIRST_VARIABLE_LENGTH_ORDINAL   1001
+
+typedef enum _ORDINAL_TABLE_2 {	// NS - means Not Supported by FW
+	IPW_ORD_STAT_BASE = 1000,	// contains number of variable ORDs
+	IPW_ORD_STAT_ADAPTER_MAC = 1001,	// 6 bytes: our adapter MAC address
+	IPW_ORD_STAT_PREFERRED_BSSID = 1002,	// 6 bytes: BSSID of the preferred AP
+	IPW_ORD_STAT_MANDATORY_BSSID = 1003,	// 6 bytes: BSSID of the mandatory AP
+	IPW_FILL_1,		//NS //
+	IPW_ORD_STAT_COUNTRY_TEXT = 1005,	// 36 bytes: Country name text, First two bytes are Country code
+	IPW_ORD_STAT_ASSN_SSID = 1006,	// 32 bytes: ESSID String
+	IPW_ORD_STATION_TABLE = 1007,	// ? bytes: Station/AP table (via Direct SSID Scans)
+	IPW_ORD_STAT_SWEEP_TABLE = 1008,	// ? bytes: Sweep/Host Table table (via Broadcast Scans)
+	IPW_ORD_STAT_ROAM_LOG = 1009,	// ? bytes: Roaming log
+	IPW_ORD_STAT_RATE_LOG = 1010,	//NS // 0 bytes: Rate log
+	IPW_ORD_STAT_FIFO = 1011,	//NS // 0 bytes: Fifo buffer data structures
+	IPW_ORD_STAT_FW_VER_NUM = 1012,	// 14 bytes: fw version ID string as in (a.bb.ccc; "0.08.011")
+	IPW_ORD_STAT_FW_DATE = 1013,	// 14 bytes: fw date string (mmm dd yyyy; "Mar 13 2002")
+	IPW_ORD_STAT_ASSN_AP_BSSID = 1014,	// 6 bytes: MAC address of associated AP
+	IPW_ORD_STAT_DEBUG = 1015,	//NS // ? bytes:
+	IPW_ORD_STAT_NIC_BPA_NUM = 1016,	// 11 bytes: NIC BPA number in ASCII
+	IPW_ORD_STAT_UCODE_DATE = 1017,	// 5 bytes: uCode date
+	IPW_ORD_SECURITY_NGOTIATION_RESULT = 1018,
+} ORDINALTABLE2;		// NS - means Not Supported by FW
+
+#define IPW_LAST_VARIABLE_LENGTH_ORDINAL   1018
+
+#ifndef WIRELESS_SPY
+#define WIRELESS_SPY		// enable iwspy support
+#endif
+
+extern struct iw_handler_def ipw2100_wx_handler_def;
+extern struct iw_statistics *ipw2100_wx_wireless_stats(struct net_device * dev);
+extern void ipw2100_wx_event_work(struct ipw2100_priv *priv);
+
+#define IPW_HOST_FW_SHARED_AREA0 	0x0002f200
+#define IPW_HOST_FW_SHARED_AREA0_END 	0x0002f510	// 0x310 bytes
+
+#define IPW_HOST_FW_SHARED_AREA1 	0x0002f610
+#define IPW_HOST_FW_SHARED_AREA1_END 	0x0002f630	// 0x20 bytes
+
+#define IPW_HOST_FW_SHARED_AREA2 	0x0002fa00
+#define IPW_HOST_FW_SHARED_AREA2_END 	0x0002fa20	// 0x20 bytes
+
+#define IPW_HOST_FW_SHARED_AREA3 	0x0002fc00
+#define IPW_HOST_FW_SHARED_AREA3_END 	0x0002fc10	// 0x10 bytes
+
+#define IPW_HOST_FW_INTERRUPT_AREA 	0x0002ff80
+#define IPW_HOST_FW_INTERRUPT_AREA_END 	0x00030000	// 0x80 bytes
+
+struct ipw2100_fw_chunk {
+	unsigned char *buf;
+	long len;
+	long pos;
+	struct list_head list;
+};
+
+struct ipw2100_fw_chunk_set {
+   	const void *data;
+	unsigned long size;
+};
+
+struct ipw2100_fw {
+	int version;
+	struct ipw2100_fw_chunk_set fw;
+	struct ipw2100_fw_chunk_set uc;
+	const struct firmware *fw_entry;
+};
+
+int ipw2100_get_firmware(struct ipw2100_priv *priv, struct ipw2100_fw *fw);
+void ipw2100_release_firmware(struct ipw2100_priv *priv, struct ipw2100_fw *fw);
+int ipw2100_fw_download(struct ipw2100_priv *priv, struct ipw2100_fw *fw);
+int ipw2100_ucode_download(struct ipw2100_priv *priv, struct ipw2100_fw *fw);
+
+#define MAX_FW_VERSION_LEN 14
+
+int ipw2100_get_fwversion(struct ipw2100_priv *priv, char *buf, size_t max);
+int ipw2100_get_ucodeversion(struct ipw2100_priv *priv, char *buf, size_t max);
+
+#endif /* _IPW2100_H */

--------------050204000700060403060604--
