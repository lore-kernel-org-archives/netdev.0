From: Christoph Lameter <christoph@lameter.com>
Subject: Re: A new 10GB Ethernet Driver by Chelsio Communications (fwd)
Date: Wed, 23 Mar 2005 21:31:25 -0800 (PST)
Message-ID: <Pine.LNX.4.58.0503232131080.13010@server.graphe.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Driver modified as suggested by Pekka Enberg, Stephen Hemminger and
Andrian Bunk. Patch against the existing driver in 2.6.12-rc1-mm1.
Reduces the size of the driver to ~260k.

- clean up tabs
- removed my3126.c
- removed 85% of suni1x10gexp_regs.h
- removed 80% of regs.h
- removed various calls, renamed variables/functions.
- removed system specific and other wrappers (usleep, msleep)
- removed dead code
- dropped redundant casts in osdep.h
- dropped redundant check of kfree
- dropped weird code (MODVERSIONS stuff)
- reduced number of #ifdefs
- use kcalloc now instead of kmalloc
- Add information about known issues with the driver
- Add information about authors

Signed-off-by: Scott Bardone <sbardone@chelsio.com>
Signed-off-by: Christoph Lameter <christoph@lameter.com>

diff -Naur linux-2.6.12-rc1-mm1/Documentation/networking/cxgb.txt linux-2.6.12-rc1-mm1.patched/Documentation/networking/cxgb.txt
--- linux-2.6.12-rc1-mm1/Documentation/networking/cxgb.txt	2005-03-22 13:05:43.000000000 -0800
+++ linux-2.6.12-rc1-mm1.patched/Documentation/networking/cxgb.txt	2005-03-22 13:03:24.000000000 -0800
@@ -198,6 +198,98 @@
      eth#: link is down


+KNOWN ISSUES
+============
+
+ These issues have been identified during testing. The following information
+ is provided as a workaround to the problem. In some cases, this problem is
+ inherent to Linux or to a particular Linux Distribution and/or hardware
+ platform.
+
+  1. Large number of TCP retransmits on a multiprocessor (SMP) system.
+
+      On a system with multiple CPUs, the interrupt (IRQ) for the network
+      controller may be bound to more than one CPU. This will cause TCP
+      retransmits if the packet data were to be split across different CPUs
+      and re-assembled in a different order than expected.
+
+      To eliminate the TCP retransmits, set smp_affinity on the particular
+      interrupt to a single CPU. You can locate the interrupt (IRQ) used on
+      the N110/N210 by using ifconfig:
+          ifconfig <dev_name> | grep Interrupt
+      Set the smp_affinity to a single CPU:
+          echo 1 > /proc/irq/<interrupt_number>/smp_affinity
+
+      It is highly suggested that you do not run the irqbalance daemon on your
+      system, as this will change any smp_affinity setting you have applied.
+      The irqbalance daemon runs on a 10 second interval and binds interrupts
+      to the least loaded CPU determined by the daemon. To disable this daemon:
+          chkconfig --level 2345 irqbalance off
+
+      By default, some Linux distributions enable the kernel feature,
+      irqbalance, which performs the same function as the daemon. To disable
+      this feature, add the following line to your bootloader:
+          noirqbalance
+
+          Example using the Grub bootloader:
+              title Red Hat Enterprise Linux AS (2.4.21-27.ELsmp)
+              root (hd0,0)
+              kernel /vmlinuz-2.4.21-27.ELsmp ro root=/dev/hda3 noirqbalance
+              initrd /initrd-2.4.21-27.ELsmp.img
+
+  2. After running insmod, the driver is loaded and the incorrect network
+     interface is brought up without running ifup.
+
+      When using 2.4.x kernels, including RHEL kernels, the Linux kernel
+      invokes a script named "hotplug". This script is primarily used to
+      automatically bring up USB devices when they are plugged in, however,
+      the script also attempts to automatically bring up a network interface
+      after loading the kernel module. The hotplug script does this by scanning
+      the ifcfg-eth# config files in /etc/sysconfig/network-scripts, looking
+      for HWADDR=<mac_address>.
+
+      If the hotplug script does not find the HWADDRR within any of the
+      ifcfg-eth# files, it will bring up the device with the next available
+      interface name. If this interface is already configured for a different
+      network card, your new interface will have incorrect IP address and
+      network settings.
+
+      To solve this issue, you can add the HWADDR=<mac_address> key to the
+      interface config file of your network controller.
+
+      To disable this "hotplug" feature, you may add the driver (module name)
+      to the "blacklist" file located in /etc/hotplug. It has been noted that
+      this does not work for network devices because the net.agent script
+      does not use the blacklist file. Simply remove, or rename, the net.agent
+      script located in /etc/hotplug to disable this feature.
+
+  3. Transport Protocol (TP) hangs when running heavy multi-connection traffic
+     on an AMD Opteron system with HyperTransport PCI-X Tunnel chipset.
+
+      If your AMD Opteron system uses the AMD-8131 HyperTransport PCI-X Tunnel
+      chipset, you may experience the "133-Mhz Mode Split Completion Data
+      Corruption" bug identified by AMD while using a 133Mhz PCI-X card on the
+      bus PCI-X bus.
+
+      AMD states, "Under highly specific conditions, the AMD-8131 PCI-X Tunnel
+      can provide stale data via split completion cycles to a PCI-X card that
+      is operating at 133 Mhz", causing data corruption.
+
+      AMD's provides three workarounds for this problem, however, Chelsio
+      recommends the first option for best performance with this bug:
+
+        For 133Mhz secondary bus operation, limit the transaction length and
+        the number of outstanding transactions, via BIOS configuration
+        programming of the PCI-X card, to the following:
+
+           Data Length (bytes): 2k
+           Total allowed outstanding transactions: 1
+
+      Please refer to AMD 8131-HT/PCI-X Errata 26310 Rev 3.08 August 2004,
+      section 56, "133-MHz Mode Split Completion Data Corruption" for more
+      details with this bug and workarounds suggested by AMD.
+
+
 SUPPORT
 =======

diff -Naur linux-2.6.12-rc1-mm1/drivers/net/chelsio/ch_ethtool.h linux-2.6.12-rc1-mm1.patched/drivers/net/chelsio/ch_ethtool.h
--- linux-2.6.12-rc1-mm1/drivers/net/chelsio/ch_ethtool.h	2005-03-22 13:05:45.000000000 -0800
+++ linux-2.6.12-rc1-mm1.patched/drivers/net/chelsio/ch_ethtool.h	2005-03-22 23:56:43.000000000 -0800
@@ -1,41 +1,44 @@
-/*******************************************************************************
- *                                                                             *
- * File: ch_ethtool.h                                                          *
- * Revision: 1.3                                                               *
- * Date: 2005/03/10 20:39:32                                                   *
- * Description:                                                                *
- *  part of the Chelsio 10Gb Ethernet Driver.                                  *
- *                                                                             *
- * This program is free software; you can redistribute it and/or modify        *
- * it under the terms of the GNU General Public License, version 2, as         *
- * published by the Free Software Foundation.                                  *
- *                                                                             *
- * You should have received a copy of the GNU General Public License along     *
- * with this program; if not, write to the Free Software Foundation, Inc.,     *
- * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.                   *
- *                                                                             *
- * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR IMPLIED      *
- * WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF        *
- * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.                       *
- *                                                                             *
- * http://www.chelsio.com                                                      *
- *                                                                             *
- * Copyright (c) 2003 - 2005 Chelsio Communications, Inc.                      *
- * All rights reserved.                                                        *
- *                                                                             *
- * Maintainers: maintainers@chelsio.com                                        *
- *                                                                             *
- * History:                                                                    *
- *                                                                             *
- ******************************************************************************/
-
+/*****************************************************************************
+ *                                                                           *
+ * File: ch_ethtool.h                                                        *
+ * $Revision: 1.5 $                                                          *
+ * $Date: 2005/03/23 07:15:58 $                                              *
+ * Description:                                                              *
+ *  part of the Chelsio 10Gb Ethernet Driver.                                *
+ *                                                                           *
+ * This program is free software; you can redistribute it and/or modify      *
+ * it under the terms of the GNU General Public License, version 2, as       *
+ * published by the Free Software Foundation.                                *
+ *                                                                           *
+ * You should have received a copy of the GNU General Public License along   *
+ * with this program; if not, write to the Free Software Foundation, Inc.,   *
+ * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.                 *
+ *                                                                           *
+ * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR IMPLIED    *
+ * WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF      *
+ * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.                     *
+ *                                                                           *
+ * http://www.chelsio.com                                                    *
+ *                                                                           *
+ * Copyright (c) 2003 - 2005 Chelsio Communications, Inc.                    *
+ * All rights reserved.                                                      *
+ *                                                                           *
+ * Maintainers: maintainers@chelsio.com                                      *
+ *                                                                           *
+ * Authors: Dimitrios Michailidis   <dm@chelsio.com>                         *
+ *          Tina Yang               <tainay@chelsio.com>                     *
+ *          Felix Marti             <felix@chelsio.com>                      *
+ *          Scott Bardone           <sbardone@chelsio.com>                   *
+ *          Kurt Ottaway            <kottaway@chelsio.com>                   *
+ *          Frank DiMambro          <frank@chelsio.com>                      *
+ *                                                                           *
+ * History:                                                                  *
+ *                                                                           *
+ ****************************************************************************/
+
 #ifndef __CHETHTOOL_LINUX_H__
 #define __CHETHTOOL_LINUX_H__

-#ifndef TCB_SIZE
-# define TCB_SIZE   128
-#endif
-
 /* TCB size in 32-bit words */
 #define TCB_WORDS (TCB_SIZE / 4)

diff -Naur linux-2.6.12-rc1-mm1/drivers/net/chelsio/common.h linux-2.6.12-rc1-mm1.patched/drivers/net/chelsio/common.h
--- linux-2.6.12-rc1-mm1/drivers/net/chelsio/common.h	2005-03-22 13:05:45.000000000 -0800
+++ linux-2.6.12-rc1-mm1.patched/drivers/net/chelsio/common.h	2005-03-22 23:56:43.000000000 -0800
@@ -1,33 +1,40 @@
-/*******************************************************************************
- *                                                                             *
- * File: common.h                                                              *
- * Revision: 1.2                                                               *
- * Date: 2005/03/10 07:07:38                                                   *
- * Description:                                                                *
- *  part of the Chelsio 10Gb Ethernet Driver.                                  *
- *                                                                             *
- * This program is free software; you can redistribute it and/or modify        *
- * it under the terms of the GNU General Public License, version 2, as         *
- * published by the Free Software Foundation.                                  *
- *                                                                             *
- * You should have received a copy of the GNU General Public License along     *
- * with this program; if not, write to the Free Software Foundation, Inc.,     *
- * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.                   *
- *                                                                             *
- * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR IMPLIED      *
- * WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF        *
- * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.                       *
- *                                                                             *
- * http://www.chelsio.com                                                      *
- *                                                                             *
- * Copyright (c) 2003 - 2005 Chelsio Communications, Inc.                      *
- * All rights reserved.                                                        *
- *                                                                             *
- * Maintainers: maintainers@chelsio.com                                        *
- *                                                                             *
- * History:                                                                    *
- *                                                                             *
- ******************************************************************************/
+/*****************************************************************************
+ *                                                                           *
+ * File: common.h                                                            *
+ * $Revision: 1.5 $                                                          *
+ * $Date: 2005/03/23 07:41:27 $                                              *
+ * Description:                                                              *
+ *  part of the Chelsio 10Gb Ethernet Driver.                                *
+ *                                                                           *
+ * This program is free software; you can redistribute it and/or modify      *
+ * it under the terms of the GNU General Public License, version 2, as       *
+ * published by the Free Software Foundation.                                *
+ *                                                                           *
+ * You should have received a copy of the GNU General Public License along   *
+ * with this program; if not, write to the Free Software Foundation, Inc.,   *
+ * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.                 *
+ *                                                                           *
+ * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR IMPLIED    *
+ * WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF      *
+ * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.                     *
+ *                                                                           *
+ * http://www.chelsio.com                                                    *
+ *                                                                           *
+ * Copyright (c) 2003 - 2005 Chelsio Communications, Inc.                    *
+ * All rights reserved.                                                      *
+ *                                                                           *
+ * Maintainers: maintainers@chelsio.com                                      *
+ *                                                                           *
+ * Authors: Dimitrios Michailidis   <dm@chelsio.com>                         *
+ *          Tina Yang               <tainay@chelsio.com>                     *
+ *          Felix Marti             <felix@chelsio.com>                      *
+ *          Scott Bardone           <sbardone@chelsio.com>                   *
+ *          Kurt Ottaway            <kottaway@chelsio.com>                   *
+ *          Frank DiMambro          <frank@chelsio.com>                      *
+ *                                                                           *
+ * History:                                                                  *
+ *                                                                           *
+ ****************************************************************************/

 #ifndef CHELSIO_COMMON_H
 #define CHELSIO_COMMON_H
@@ -90,18 +97,18 @@
 struct tp_params {
 	unsigned int pm_size;
 	unsigned int cm_size;
-        unsigned int pm_rx_base;
-        unsigned int pm_tx_base;
-        unsigned int pm_rx_pg_size;
-        unsigned int pm_tx_pg_size;
-        unsigned int pm_rx_num_pgs;
-        unsigned int pm_tx_num_pgs;
+	unsigned int pm_rx_base;
+	unsigned int pm_tx_base;
+	unsigned int pm_rx_pg_size;
+	unsigned int pm_tx_pg_size;
+	unsigned int pm_rx_num_pgs;
+	unsigned int pm_tx_num_pgs;
 	unsigned int use_5tuple_mode;
 };

 struct sge_params {
-        unsigned int cmdQ_size[2];
-        unsigned int freelQ_size[2];
+	unsigned int cmdQ_size[2];
+	unsigned int freelQ_size[2];
 	unsigned int large_buf_capacity;
 	unsigned int rx_coalesce_usecs;
 	unsigned int last_rx_coalesce_raw;
@@ -112,9 +119,9 @@
 };

 struct mc5_params {
-	unsigned int mode;       /* selects MC5 width */
-	unsigned int nservers;   /* size of server region */
-	unsigned int nroutes;    /* size of routing region */
+	unsigned int mode;	/* selects MC5 width */
+	unsigned int nservers;	/* size of server region */
+	unsigned int nroutes;	/* size of routing region */
 };

 /* Default MC5 region sizes */
@@ -126,7 +133,7 @@
 	unsigned char  width;
 	unsigned char  is_pcix;
 };
-
+
 struct adapter_params {
 	struct sge_params sge;
 	struct mc5_params mc5;
@@ -142,7 +149,7 @@
 	unsigned char  chip_version;
 	unsigned char  is_asic;
 };
-
+
 struct pci_err_cnt {
 	unsigned int master_parity_err;
 	unsigned int sig_target_abort;
@@ -159,9 +166,9 @@
 struct link_config {
 	unsigned int   supported;        /* link capabilities */
 	unsigned int   advertising;      /* advertised capabilities */
-        unsigned short requested_speed;  /* speed user has requested */
+	unsigned short requested_speed;  /* speed user has requested */
 	unsigned short speed;            /* actual link speed */
-        unsigned char  requested_duplex; /* duplex user has requested */
+	unsigned char  requested_duplex; /* duplex user has requested */
 	unsigned char  duplex;           /* actual link duplex */
 	unsigned char  requested_fc;     /* flow control user has requested */
 	unsigned char  fc;               /* actual link flow control */
@@ -238,12 +245,8 @@
 	return board_info(adap)->clock_core / 1000000;
 }

-int __t1_tpi_read(adapter_t *adapter, u32 addr, u32 *valp);
-int __t1_tpi_write(adapter_t *adapter, u32 addr, u32 value);
 int t1_tpi_write(adapter_t *adapter, u32 addr, u32 value);
 int t1_tpi_read(adapter_t *adapter, u32 addr, u32 *value);
-int t1_wait_op_done(adapter_t *adapter, int reg, u32 mask, int polarity,
-                    int attempts, int delay);

 void t1_interrupts_enable(adapter_t *adapter);
 void t1_interrupts_disable(adapter_t *adapter);
diff -Naur linux-2.6.12-rc1-mm1/drivers/net/chelsio/cphy.h linux-2.6.12-rc1-mm1.patched/drivers/net/chelsio/cphy.h
--- linux-2.6.12-rc1-mm1/drivers/net/chelsio/cphy.h	2005-03-22 13:05:45.000000000 -0800
+++ linux-2.6.12-rc1-mm1.patched/drivers/net/chelsio/cphy.h	2005-03-22 23:56:43.000000000 -0800
@@ -1,33 +1,40 @@
-/*******************************************************************************
- *                                                                             *
- * File: cphy.h                                                                *
- * Revision: 1.2                                                               *
- * Date: 2005/03/10 07:07:38                                                   *
- * Description:                                                                *
- *  part of the Chelsio 10Gb Ethernet Driver.                                  *
- *                                                                             *
- * This program is free software; you can redistribute it and/or modify        *
- * it under the terms of the GNU General Public License, version 2, as         *
- * published by the Free Software Foundation.                                  *
- *                                                                             *
- * You should have received a copy of the GNU General Public License along     *
- * with this program; if not, write to the Free Software Foundation, Inc.,     *
- * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.                   *
- *                                                                             *
- * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR IMPLIED      *
- * WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF        *
- * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.                       *
- *                                                                             *
- * http://www.chelsio.com                                                      *
- *                                                                             *
- * Copyright (c) 2003 - 2005 Chelsio Communications, Inc.                      *
- * All rights reserved.                                                        *
- *                                                                             *
- * Maintainers: maintainers@chelsio.com                                        *
- *                                                                             *
- * History:                                                                    *
- *                                                                             *
- ******************************************************************************/
+/*****************************************************************************
+ *                                                                           *
+ * File: cphy.h                                                              *
+ * $Revision: 1.4 $                                                          *
+ * $Date: 2005/03/23 07:41:27 $                                              *
+ * Description:                                                              *
+ *  part of the Chelsio 10Gb Ethernet Driver.                                *
+ *                                                                           *
+ * This program is free software; you can redistribute it and/or modify      *
+ * it under the terms of the GNU General Public License, version 2, as       *
+ * published by the Free Software Foundation.                                *
+ *                                                                           *
+ * You should have received a copy of the GNU General Public License along   *
+ * with this program; if not, write to the Free Software Foundation, Inc.,   *
+ * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.                 *
+ *                                                                           *
+ * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR IMPLIED    *
+ * WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF      *
+ * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.                     *
+ *                                                                           *
+ * http://www.chelsio.com                                                    *
+ *                                                                           *
+ * Copyright (c) 2003 - 2005 Chelsio Communications, Inc.                    *
+ * All rights reserved.                                                      *
+ *                                                                           *
+ * Maintainers: maintainers@chelsio.com                                      *
+ *                                                                           *
+ * Authors: Dimitrios Michailidis   <dm@chelsio.com>                         *
+ *          Tina Yang               <tainay@chelsio.com>                     *
+ *          Felix Marti             <felix@chelsio.com>                      *
+ *          Scott Bardone           <sbardone@chelsio.com>                   *
+ *          Kurt Ottaway            <kottaway@chelsio.com>                   *
+ *          Frank DiMambro          <frank@chelsio.com>                      *
+ *                                                                           *
+ * History:                                                                  *
+ *                                                                           *
+ ****************************************************************************/

 #ifndef CHELSIO_CPHY_H
 #define CHELSIO_CPHY_H
@@ -38,7 +45,7 @@
 	void (*init)(adapter_t *adapter, const struct board_info *bi);
 	int  (*read)(adapter_t *adapter, int phy_addr, int mmd_addr,
 		     int reg_addr, unsigned int *val);
-        int  (*write)(adapter_t *adapter, int phy_addr, int mmd_addr,
+	int  (*write)(adapter_t *adapter, int phy_addr, int mmd_addr,
 		      int reg_addr, unsigned int val);
 };

@@ -78,7 +85,7 @@
 	struct cphy_ops *ops;                /* PHY operations */
 	int (*mdio_read)(adapter_t *adapter, int phy_addr, int mmd_addr,
 			 int reg_addr, unsigned int *val);
-        int (*mdio_write)(adapter_t *adapter, int phy_addr, int mmd_addr,
+	int (*mdio_write)(adapter_t *adapter, int phy_addr, int mmd_addr,
 			  int reg_addr, unsigned int val);
 	struct cphy_instance *instance;
 };
@@ -87,13 +94,13 @@
 static inline int mdio_read(struct cphy *cphy, int mmd, int reg,
 			    unsigned int *valp)
 {
-        return cphy->mdio_read(cphy->adapter, cphy->addr, mmd, reg, valp);
+	return cphy->mdio_read(cphy->adapter, cphy->addr, mmd, reg, valp);
 }

 static inline int mdio_write(struct cphy *cphy, int mmd, int reg,
 			     unsigned int val)
 {
-        return cphy->mdio_write(cphy->adapter, cphy->addr, mmd, reg, val);
+	return cphy->mdio_write(cphy->adapter, cphy->addr, mmd, reg, val);
 }

 static inline int simple_mdio_read(struct cphy *cphy, int reg,
diff -Naur linux-2.6.12-rc1-mm1/drivers/net/chelsio/cpl5_cmd.h linux-2.6.12-rc1-mm1.patched/drivers/net/chelsio/cpl5_cmd.h
--- linux-2.6.12-rc1-mm1/drivers/net/chelsio/cpl5_cmd.h	2005-03-22 13:05:45.000000000 -0800
+++ linux-2.6.12-rc1-mm1.patched/drivers/net/chelsio/cpl5_cmd.h	2005-03-22 23:56:43.000000000 -0800
@@ -1,33 +1,40 @@
-/*******************************************************************************
- *                                                                             *
- * File: cpl5_cmd.h                                                            *
- * Revision: 1.3                                                               *
- * Date: 2005/03/11 06:44:38                                                   *
- * Description:                                                                *
- *  part of the Chelsio 10Gb Ethernet Driver.                                  *
- *                                                                             *
- * This program is free software; you can redistribute it and/or modify        *
- * it under the terms of the GNU General Public License, version 2, as         *
- * published by the Free Software Foundation.                                  *
- *                                                                             *
- * You should have received a copy of the GNU General Public License along     *
- * with this program; if not, write to the Free Software Foundation, Inc.,     *
- * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.                   *
- *                                                                             *
- * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR IMPLIED      *
- * WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF        *
- * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.                       *
- *                                                                             *
- * http://www.chelsio.com                                                      *
- *                                                                             *
- * Copyright (c) 2003 - 2005 Chelsio Communications, Inc.                      *
- * All rights reserved.                                                        *
- *                                                                             *
- * Maintainers: maintainers@chelsio.com                                        *
- *                                                                             *
- * History:                                                                    *
- *                                                                             *
- ******************************************************************************/
+/*****************************************************************************
+ *                                                                           *
+ * File: cpl5_cmd.h                                                          *
+ * $Revision: 1.4 $                                                          *
+ * $Date: 2005/03/23 07:15:58 $                                              *
+ * Description:                                                              *
+ *  part of the Chelsio 10Gb Ethernet Driver.                                *
+ *                                                                           *
+ * This program is free software; you can redistribute it and/or modify      *
+ * it under the terms of the GNU General Public License, version 2, as       *
+ * published by the Free Software Foundation.                                *
+ *                                                                           *
+ * You should have received a copy of the GNU General Public License along   *
+ * with this program; if not, write to the Free Software Foundation, Inc.,   *
+ * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.                 *
+ *                                                                           *
+ * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR IMPLIED    *
+ * WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF      *
+ * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.                     *
+ *                                                                           *
+ * http://www.chelsio.com                                                    *
+ *                                                                           *
+ * Copyright (c) 2003 - 2005 Chelsio Communications, Inc.                    *
+ * All rights reserved.                                                      *
+ *                                                                           *
+ * Maintainers: maintainers@chelsio.com                                      *
+ *                                                                           *
+ * Authors: Dimitrios Michailidis   <dm@chelsio.com>                         *
+ *          Tina Yang               <tainay@chelsio.com>                     *
+ *          Felix Marti             <felix@chelsio.com>                      *
+ *          Scott Bardone           <sbardone@chelsio.com>                   *
+ *          Kurt Ottaway            <kottaway@chelsio.com>                   *
+ *          Frank DiMambro          <frank@chelsio.com>                      *
+ *                                                                           *
+ * History:                                                                  *
+ *                                                                           *
+ ****************************************************************************/

 #ifndef _CPL5_CMD_H
 #define _CPL5_CMD_H
@@ -51,17 +58,12 @@
 	CPL_ETH_802_3_VLAN
 };

-union opcode_tid {
-	__u32 opcode_tid;
-	__u8 opcode;
-};
-
 struct cpl_rx_data {
-	union opcode_tid ot;
+	__u32 rsvd0;
 	__u32 len;
 	__u32 seq;
 	__u16 urg;
-	__u8  rsvd;
+	__u8  rsvd1;
 	__u8  status;
 };

@@ -141,9 +143,3 @@
 };

 #endif
-
-/*
- * Local Variables:
- * c-basic-offset: 4
- * End:
- */
diff -Naur linux-2.6.12-rc1-mm1/drivers/net/chelsio/cxgb2.c linux-2.6.12-rc1-mm1.patched/drivers/net/chelsio/cxgb2.c
--- linux-2.6.12-rc1-mm1/drivers/net/chelsio/cxgb2.c	2005-03-22 13:05:45.000000000 -0800
+++ linux-2.6.12-rc1-mm1.patched/drivers/net/chelsio/cxgb2.c	2005-03-22 23:56:43.000000000 -0800
@@ -1,34 +1,41 @@
-/*******************************************************************************
- *                                                                             *
- * File: cxgb2.c                                                               *
- * Revision: 1.5                                                               *
- * Date: 2005/03/11 06:44:38                                                   *
- * Description:                                                                *
- *  Chelsio 10Gb Ethernet Driver.                                              *
- *                                                                             *
- * This program is free software; you can redistribute it and/or modify        *
- * it under the terms of the GNU General Public License, version 2, as         *
- * published by the Free Software Foundation.                                  *
- *                                                                             *
- * You should have received a copy of the GNU General Public License along     *
- * with this program; if not, write to the Free Software Foundation, Inc.,     *
- * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.                   *
- *                                                                             *
- * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR IMPLIED      *
- * WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF        *
- * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.                       *
- *                                                                             *
- * http://www.chelsio.com                                                      *
- *                                                                             *
- * Copyright (c) 2003 - 2005 Chelsio Communications, Inc.                      *
- * All rights reserved.                                                        *
- *                                                                             *
- * Maintainers: maintainers@chelsio.com                                        *
- *                                                                             *
- * History:                                                                    *
- *                                                                             *
- ******************************************************************************/
-
+/*****************************************************************************
+ *                                                                           *
+ * File: cxgb2.c                                                             *
+ * $Revision: 1.11 $                                                          *
+ * $Date: 2005/03/23 07:41:27 $                                              *
+ * Description:                                                              *
+ *  Chelsio 10Gb Ethernet Driver.                                            *
+ *                                                                           *
+ * This program is free software; you can redistribute it and/or modify      *
+ * it under the terms of the GNU General Public License, version 2, as       *
+ * published by the Free Software Foundation.                                *
+ *                                                                           *
+ * You should have received a copy of the GNU General Public License along   *
+ * with this program; if not, write to the Free Software Foundation, Inc.,   *
+ * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.                 *
+ *                                                                           *
+ * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR IMPLIED    *
+ * WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF      *
+ * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.                     *
+ *                                                                           *
+ * http://www.chelsio.com                                                    *
+ *                                                                           *
+ * Copyright (c) 2003 - 2005 Chelsio Communications, Inc.                    *
+ * All rights reserved.                                                      *
+ *                                                                           *
+ * Maintainers: maintainers@chelsio.com                                      *
+ *                                                                           *
+ * Authors: Dimitrios Michailidis   <dm@chelsio.com>                         *
+ *          Tina Yang               <tainay@chelsio.com>                     *
+ *          Felix Marti             <felix@chelsio.com>                      *
+ *          Scott Bardone           <sbardone@chelsio.com>                   *
+ *          Kurt Ottaway            <kottaway@chelsio.com>                   *
+ *          Frank DiMambro          <frank@chelsio.com>                      *
+ *                                                                           *
+ * History:                                                                  *
+ *                                                                           *
+ ****************************************************************************/
+
 #include "common.h"

 #include <linux/config.h>
@@ -42,6 +49,7 @@
 #include <linux/sockios.h>
 #include <linux/proc_fs.h>
 #include <linux/version.h>
+#include <linux/workqueue.h>
 #include <asm/uaccess.h>

 #include "ch_ethtool.h"
@@ -53,36 +61,6 @@
 #include "tp.h"
 #include "espi.h"

-#ifdef work_struct
-#include <linux/tqueue.h>
-#define INIT_WORK INIT_TQUEUE
-#define schedule_work schedule_task
-#define flush_scheduled_work flush_scheduled_tasks
-
-static inline void schedule_mac_stats_update(struct adapter *ap, int secs)
-{
-	mod_timer(&ap->stats_update_timer, jiffies + secs * HZ);
-}
-
-static inline void cancel_mac_stats_update(struct adapter *ap)
-{
-	del_timer_sync(&ap->stats_update_timer);
-	flush_scheduled_tasks();
-}
-
-/*
- * Stats update timer for 2.4.  It schedules a task to do the actual update as
- * we need to access MAC statistics in process context.
- */
-static void mac_stats_timer(unsigned long data)
-{
-	struct adapter *ap = (struct adapter *)data;
-
-	schedule_task(&ap->stats_update_task);
-}
-#else
-#include <linux/workqueue.h>
-
 static inline void schedule_mac_stats_update(struct adapter *ap, int secs)
 {
 	schedule_delayed_work(&ap->stats_update_task, secs * HZ);
@@ -92,7 +70,6 @@
 {
 	cancel_delayed_work(&ap->stats_update_task);
 }
-#endif

 #if BITS_PER_LONG == 64 && !defined(CONFIG_X86_64)
 # define FMT64 "l"
@@ -100,10 +77,6 @@
 # define FMT64 "ll"
 #endif

-#ifndef HAVE_FREE_NETDEV
-#define free_netdev(dev) kfree(dev)
-#endif
-
 # define DRV_TYPE ""
 # define MODULE_DESC "Chelsio Network Driver"

@@ -351,7 +324,6 @@
 	return ns;
 }

-#ifdef SET_ETHTOOL_OPS
 static u32 get_msglevel(struct net_device *dev)
 {
 	struct adapter *adapter = dev->priv;
@@ -367,39 +339,39 @@
 }

 static char stats_strings[][ETH_GSTRING_LEN] = {
-        "TxOctetsOK",
-        "TxOctetsBad",
-        "TxUnicastFramesOK",
-        "TxMulticastFramesOK",
-        "TxBroadcastFramesOK",
-        "TxPauseFrames",
-        "TxFramesWithDeferredXmissions",
-        "TxLateCollisions",
-        "TxTotalCollisions",
-        "TxFramesAbortedDueToXSCollisions",
-        "TxUnderrun",
-        "TxLengthErrors",
-        "TxInternalMACXmitError",
-        "TxFramesWithExcessiveDeferral",
-        "TxFCSErrors",
-
-        "RxOctetsOK",
-        "RxOctetsBad",
-        "RxUnicastFramesOK",
-        "RxMulticastFramesOK",
-        "RxBroadcastFramesOK",
-        "RxPauseFrames",
-        "RxFCSErrors",
-        "RxAlignErrors",
-        "RxSymbolErrors",
-        "RxDataErrors",
-        "RxSequenceErrors",
-        "RxRuntErrors",
-        "RxJabberErrors",
-        "RxInternalMACRcvError",
-        "RxInRangeLengthErrors",
-        "RxOutOfRangeLengthField",
-        "RxFrameTooLongErrors"
+	"TxOctetsOK",
+	"TxOctetsBad",
+	"TxUnicastFramesOK",
+	"TxMulticastFramesOK",
+	"TxBroadcastFramesOK",
+	"TxPauseFrames",
+	"TxFramesWithDeferredXmissions",
+	"TxLateCollisions",
+	"TxTotalCollisions",
+	"TxFramesAbortedDueToXSCollisions",
+	"TxUnderrun",
+	"TxLengthErrors",
+	"TxInternalMACXmitError",
+	"TxFramesWithExcessiveDeferral",
+	"TxFCSErrors",
+
+	"RxOctetsOK",
+	"RxOctetsBad",
+	"RxUnicastFramesOK",
+	"RxMulticastFramesOK",
+	"RxBroadcastFramesOK",
+	"RxPauseFrames",
+	"RxFCSErrors",
+	"RxAlignErrors",
+	"RxSymbolErrors",
+	"RxDataErrors",
+	"RxSequenceErrors",
+	"RxRuntErrors",
+	"RxJabberErrors",
+	"RxInternalMACRcvError",
+	"RxInRangeLengthErrors",
+	"RxOutOfRangeLengthField",
+	"RxFrameTooLongErrors"
 };

 static void get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
@@ -432,39 +404,39 @@

 	s = mac->ops->statistics_update(mac, MAC_STATS_UPDATE_FULL);

-        *data++ = s->TxOctetsOK;
-        *data++ = s->TxOctetsBad;
-        *data++ = s->TxUnicastFramesOK;
-        *data++ = s->TxMulticastFramesOK;
-        *data++ = s->TxBroadcastFramesOK;
-        *data++ = s->TxPauseFrames;
-        *data++ = s->TxFramesWithDeferredXmissions;
-        *data++ = s->TxLateCollisions;
-        *data++ = s->TxTotalCollisions;
-        *data++ = s->TxFramesAbortedDueToXSCollisions;
-        *data++ = s->TxUnderrun;
-        *data++ = s->TxLengthErrors;
-        *data++ = s->TxInternalMACXmitError;
-        *data++ = s->TxFramesWithExcessiveDeferral;
-        *data++ = s->TxFCSErrors;
-
-        *data++ = s->RxOctetsOK;
-        *data++ = s->RxOctetsBad;
-        *data++ = s->RxUnicastFramesOK;
-        *data++ = s->RxMulticastFramesOK;
-        *data++ = s->RxBroadcastFramesOK;
-        *data++ = s->RxPauseFrames;
-        *data++ = s->RxFCSErrors;
-        *data++ = s->RxAlignErrors;
-        *data++ = s->RxSymbolErrors;
-        *data++ = s->RxDataErrors;
-        *data++ = s->RxSequenceErrors;
-        *data++ = s->RxRuntErrors;
-        *data++ = s->RxJabberErrors;
-        *data++ = s->RxInternalMACRcvError;
-        *data++ = s->RxInRangeLengthErrors;
-        *data++ = s->RxOutOfRangeLengthField;
-        *data++ = s->RxFrameTooLongErrors;
+	*data++ = s->TxOctetsOK;
+	*data++ = s->TxOctetsBad;
+	*data++ = s->TxUnicastFramesOK;
+	*data++ = s->TxMulticastFramesOK;
+	*data++ = s->TxBroadcastFramesOK;
+	*data++ = s->TxPauseFrames;
+	*data++ = s->TxFramesWithDeferredXmissions;
+	*data++ = s->TxLateCollisions;
+	*data++ = s->TxTotalCollisions;
+	*data++ = s->TxFramesAbortedDueToXSCollisions;
+	*data++ = s->TxUnderrun;
+	*data++ = s->TxLengthErrors;
+	*data++ = s->TxInternalMACXmitError;
+	*data++ = s->TxFramesWithExcessiveDeferral;
+	*data++ = s->TxFCSErrors;
+
+	*data++ = s->RxOctetsOK;
+	*data++ = s->RxOctetsBad;
+	*data++ = s->RxUnicastFramesOK;
+	*data++ = s->RxMulticastFramesOK;
+	*data++ = s->RxBroadcastFramesOK;
+	*data++ = s->RxPauseFrames;
+	*data++ = s->RxFCSErrors;
+	*data++ = s->RxAlignErrors;
+	*data++ = s->RxSymbolErrors;
+	*data++ = s->RxDataErrors;
+	*data++ = s->RxSequenceErrors;
+	*data++ = s->RxRuntErrors;
+	*data++ = s->RxJabberErrors;
+	*data++ = s->RxInternalMACRcvError;
+	*data++ = s->RxInRangeLengthErrors;
+	*data++ = s->RxOutOfRangeLengthField;
+	*data++ = s->RxFrameTooLongErrors;
 }

 static int get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
@@ -483,12 +455,12 @@
 		cmd->duplex = -1;
 	}

-        cmd->port = (cmd->supported & SUPPORTED_TP) ? PORT_TP : PORT_FIBRE;
-        cmd->phy_address = p->phy->addr;
-        cmd->transceiver = XCVR_EXTERNAL;
-        cmd->autoneg = p->link_config.autoneg;
-        cmd->maxtxpkt = 0;
-        cmd->maxrxpkt = 0;
+	cmd->port = (cmd->supported & SUPPORTED_TP) ? PORT_TP : PORT_FIBRE;
+	cmd->phy_address = p->phy->addr;
+	cmd->transceiver = XCVR_EXTERNAL;
+	cmd->autoneg = p->link_config.autoneg;
+	cmd->maxtxpkt = 0;
+	cmd->maxrxpkt = 0;
 	return 0;
 }

@@ -534,7 +506,7 @@
 	struct link_config *lc = &p->link_config;

 	if (!(lc->supported & SUPPORTED_Autoneg))
-		return -EOPNOTSUPP;             /* can't change speed/duplex */
+		return -EOPNOTSUPP;		/* can't change speed/duplex */

 	if (cmd->autoneg == AUTONEG_DISABLE) {
 		int cap = speed_duplex_to_caps(cmd->speed, cmd->duplex);
@@ -620,7 +592,6 @@
 	return 0;
 }

-#ifdef NETIF_F_TSO
 static int set_tso(struct net_device *dev, u32 value)
 {
 	struct adapter *adapter = dev->priv;
@@ -629,7 +600,6 @@
 		return value ? -EOPNOTSUPP : 0;
 	return ethtool_op_set_tso(dev, value);
 }
-#endif

 static void get_sge_param(struct net_device *dev, struct ethtool_ringparam *e)
 {
@@ -674,19 +644,19 @@
 static int set_coalesce(struct net_device *dev, struct ethtool_coalesce *c)
 {
 	struct adapter *adapter = dev->priv;
-
-        unsigned int sge_coalesce_usecs = 0;
+
+	unsigned int sge_coalesce_usecs = 0;

 	sge_coalesce_usecs = adapter->params.sge.last_rx_coalesce_raw;
 	sge_coalesce_usecs /= board_info(adapter)->clock_core / 1000000;
-	if ( (adapter->params.sge.coalesce_enable && !c->use_adaptive_rx_coalesce) &&
+	if ( (adapter->params.sge.coalesce_enable && !c->use_adaptive_rx_coalesce) &&
 	     (c->rx_coalesce_usecs == sge_coalesce_usecs) ) {
 		adapter->params.sge.rx_coalesce_usecs =
-			adapter->params.sge.default_rx_coalesce_usecs;
+			adapter->params.sge.default_rx_coalesce_usecs;
 	} else {
 		adapter->params.sge.rx_coalesce_usecs = c->rx_coalesce_usecs;
-        }
-
+	}
+
 	adapter->params.sge.last_rx_coalesce_raw = adapter->params.sge.rx_coalesce_usecs;
 	adapter->params.sge.last_rx_coalesce_raw *= (board_info(adapter)->clock_core / 1000000);
 	adapter->params.sge.sample_interval_usecs = c->rate_sample_interval;
@@ -758,17 +728,9 @@
 	.get_strings       = get_strings,
 	.get_stats_count   = get_stats_count,
 	.get_ethtool_stats = get_stats,
-#ifdef NETIF_F_TSO
 	.get_tso           = ethtool_op_get_tso,
 	.set_tso           = set_tso,
-#endif
 };
-#endif
-
-#define cxgb_setup_dev(adapter) NULL
-#define cxgb_proc_cleanup(dir)
-#define update_mtu_tab(adapter)
-#define write_smt_entry(adapter, idx)

 static int ethtool_ioctl(struct net_device *dev, void *useraddr)
 {
@@ -776,7 +738,7 @@
 	struct adapter *adapter = dev->priv;

 	if (copy_from_user(&cmd, useraddr, sizeof(cmd)))
-                return -EFAULT;
+		return -EFAULT;

 	switch (cmd) {
 	case ETHTOOL_SETREG: {
@@ -849,31 +811,31 @@

 static int t1_ioctl(struct net_device *dev, struct ifreq *req, int cmd)
 {
-        struct adapter *adapter = dev->priv;
-        struct mii_ioctl_data *data = (struct mii_ioctl_data *)&req->ifr_data;
+	struct adapter *adapter = dev->priv;
+	struct mii_ioctl_data *data = (struct mii_ioctl_data *)&req->ifr_data;

 	switch (cmd) {
-        case SIOCGMIIPHY:
-                data->phy_id = adapter->port[dev->if_port].phy->addr;
-                /* FALLTHRU */
-        case SIOCGMIIREG: {
+	case SIOCGMIIPHY:
+		data->phy_id = adapter->port[dev->if_port].phy->addr;
+		/* FALLTHRU */
+	case SIOCGMIIREG: {
 		struct cphy *phy = adapter->port[dev->if_port].phy;
 		u32 val;

 		if (!phy->mdio_read) return -EOPNOTSUPP;
 		phy->mdio_read(adapter, data->phy_id, 0, data->reg_num & 0x1f,
 			       &val);
-                data->val_out = val;
-                break;
+		data->val_out = val;
+		break;
 	}
-        case SIOCSMIIREG: {
+	case SIOCSMIIREG: {
 		struct cphy *phy = adapter->port[dev->if_port].phy;

-                if (!capable(CAP_NET_ADMIN)) return -EPERM;
+		if (!capable(CAP_NET_ADMIN)) return -EPERM;
 		if (!phy->mdio_write) return -EOPNOTSUPP;
 		phy->mdio_write(adapter, data->phy_id, 0, data->reg_num & 0x1f,
-			        data->val_in);
-                break;
+				data->val_in);
+		break;
 	}

 	case SIOCCHETHTOOL:
@@ -942,7 +904,7 @@
 {
 	struct adapter *adapter = dev->priv;

-        t1_interrupt(adapter->pdev->irq, adapter, NULL);
+	t1_interrupt(adapter->pdev->irq, adapter, NULL);
 }
 #endif

@@ -1012,7 +974,7 @@
 		t1_interrupts_disable(adapter);
 	}
 	CH_ALERT("%s: encountered fatal error, operation suspended\n",
-		 adapter_name(adapter));
+		 adapter->name);
 }


@@ -1079,9 +1041,8 @@
 		}

 		SET_MODULE_OWNER(netdev);
-#ifdef SET_NETDEV_DEV
 		SET_NETDEV_DEV(netdev, &pdev->dev);
-#endif
+
 		if (!adapter) {
 			adapter = netdev->priv;
 			adapter->pdev = pdev;
@@ -1113,17 +1074,9 @@
 				  ext_intr_task, adapter);
 			INIT_WORK(&adapter->stats_update_task, mac_stats_task,
 				  adapter);
-#ifdef work_struct
-			init_timer(&adapter->stats_update_timer);
-			adapter->stats_update_timer.function = mac_stats_timer;
-			adapter->stats_update_timer.data =
-				(unsigned long)adapter;
-#endif

 			pci_set_drvdata(pdev, netdev);

-			if (bi->clock_mc4)
-				adapter->tdev = cxgb_setup_dev(adapter);
 		}

 		pi = &adapter->port[i];
@@ -1147,10 +1100,8 @@
 			netdev->vlan_rx_register = vlan_rx_register;
 			netdev->vlan_rx_kill_vid = vlan_rx_kill_vid;
 #endif
-#ifdef NETIF_F_TSO
 			adapter->flags |= TSO_CAPABLE;
 			netdev->features |= NETIF_F_TSO;
-#endif
 		}

 		netdev->open = cxgb_open;
@@ -1168,9 +1119,8 @@
 		netdev->poll_controller = t1_netpoll;
 #endif
 		netdev->weight = 64;
-#ifdef SET_ETHTOOL_OPS
+
 		SET_ETHTOOL_OPS(netdev, &t1_ethtool_ops);
-#endif
 	}

 	if (t1_init_sw_modules(adapter, bi) < 0) {
@@ -1216,8 +1166,6 @@
 	t1_free_sw_modules(adapter);
  out_free_dev:
 	if (adapter) {
-		if (adapter->tdev)
-			kfree(adapter->tdev);
 		if (adapter->regs)
 			iounmap(adapter->regs);
 		for (i = bi->port_number - 1; i >= 0; --i)
@@ -1251,7 +1199,6 @@

 		t1_free_sw_modules(adapter);
 		iounmap(adapter->regs);
-		kfree(adapter->tdev);
 		while (--i >= 0)
 			if (adapter->port[i].dev)
 				free_netdev(adapter->port[i].dev);
diff -Naur linux-2.6.12-rc1-mm1/drivers/net/chelsio/cxgb2.h linux-2.6.12-rc1-mm1.patched/drivers/net/chelsio/cxgb2.h
--- linux-2.6.12-rc1-mm1/drivers/net/chelsio/cxgb2.h	2005-03-22 13:05:45.000000000 -0800
+++ linux-2.6.12-rc1-mm1.patched/drivers/net/chelsio/cxgb2.h	2005-03-22 23:56:43.000000000 -0800
@@ -1,33 +1,40 @@
-/*******************************************************************************
- *                                                                             *
- * File: cxgb2.h                                                               *
- * Revision: 1.5                                                               *
- * Date: 2005/03/11 06:44:38                                                   *
- * Description:                                                                *
- *  part of the Chelsio 10Gb Ethernet Driver.                                  *
- *                                                                             *
- * This program is free software; you can redistribute it and/or modify        *
- * it under the terms of the GNU General Public License, version 2, as         *
- * published by the Free Software Foundation.                                  *
- *                                                                             *
- * You should have received a copy of the GNU General Public License along     *
- * with this program; if not, write to the Free Software Foundation, Inc.,     *
- * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.                   *
- *                                                                             *
- * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR IMPLIED      *
- * WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF        *
- * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.                       *
- *                                                                             *
- * http://www.chelsio.com                                                      *
- *                                                                             *
- * Copyright (c) 2003 - 2005 Chelsio Communications, Inc.                      *
- * All rights reserved.                                                        *
- *                                                                             *
- * Maintainers: maintainers@chelsio.com                                        *
- *                                                                             *
- * History:                                                                    *
- *                                                                             *
- ******************************************************************************/
+/*****************************************************************************
+ *                                                                           *
+ * File: cxgb2.h                                                             *
+ * $Revision: 1.8 $                                                          *
+ * $Date: 2005/03/23 07:41:27 $                                              *
+ * Description:                                                              *
+ *  part of the Chelsio 10Gb Ethernet Driver.                                *
+ *                                                                           *
+ * This program is free software; you can redistribute it and/or modify      *
+ * it under the terms of the GNU General Public License, version 2, as       *
+ * published by the Free Software Foundation.                                *
+ *                                                                           *
+ * You should have received a copy of the GNU General Public License along   *
+ * with this program; if not, write to the Free Software Foundation, Inc.,   *
+ * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.                 *
+ *                                                                           *
+ * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR IMPLIED    *
+ * WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF      *
+ * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.                     *
+ *                                                                           *
+ * http://www.chelsio.com                                                    *
+ *                                                                           *
+ * Copyright (c) 2003 - 2005 Chelsio Communications, Inc.                    *
+ * All rights reserved.                                                      *
+ *                                                                           *
+ * Maintainers: maintainers@chelsio.com                                      *
+ *                                                                           *
+ * Authors: Dimitrios Michailidis   <dm@chelsio.com>                         *
+ *          Tina Yang               <tainay@chelsio.com>                     *
+ *          Felix Marti             <felix@chelsio.com>                      *
+ *          Scott Bardone           <sbardone@chelsio.com>                   *
+ *          Kurt Ottaway            <kottaway@chelsio.com>                   *
+ *          Frank DiMambro          <frank@chelsio.com>                      *
+ *                                                                           *
+ * History:                                                                  *
+ *                                                                           *
+ ****************************************************************************/

 #ifndef __CXGB_LINUX_H__
 #define __CXGB_LINUX_H__
@@ -64,7 +71,7 @@
 struct work_struct;
 struct vlan_group;

-enum {                                        /* adapter flags */
+enum {					/* adapter flags */
 	FULL_INIT_DONE        = 0x1,
 	USING_MSI             = 0x2,
 	TSO_CAPABLE           = 0x4,
@@ -77,7 +84,6 @@
 struct adapter {
 	u8 *regs;
 	struct pci_dev *pdev;
-	struct cxgbdev *tdev;
 	unsigned long registered_device_map;
 	unsigned long open_device_map;
 	unsigned int flags;
diff -Naur linux-2.6.12-rc1-mm1/drivers/net/chelsio/elmer0.h linux-2.6.12-rc1-mm1.patched/drivers/net/chelsio/elmer0.h
--- linux-2.6.12-rc1-mm1/drivers/net/chelsio/elmer0.h	2005-03-22 13:05:45.000000000 -0800
+++ linux-2.6.12-rc1-mm1.patched/drivers/net/chelsio/elmer0.h	2005-03-22 23:56:43.000000000 -0800
@@ -1,33 +1,40 @@
-/*******************************************************************************
- *                                                                             *
- * File: elmer0.h                                                              *
- * Revision: 1.2                                                               *
- * Date: 2005/03/10 07:07:38                                                   *
- * Description:                                                                *
- *  part of the Chelsio 10Gb Ethernet Driver.                                  *
- *                                                                             *
- * This program is free software; you can redistribute it and/or modify        *
- * it under the terms of the GNU General Public License, version 2, as         *
- * published by the Free Software Foundation.                                  *
- *                                                                             *
- * You should have received a copy of the GNU General Public License along     *
- * with this program; if not, write to the Free Software Foundation, Inc.,     *
- * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.                   *
- *                                                                             *
- * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR IMPLIED      *
- * WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF        *
- * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.                       *
- *                                                                             *
- * http://www.chelsio.com                                                      *
- *                                                                             *
- * Copyright (c) 2003 - 2005 Chelsio Communications, Inc.                      *
- * All rights reserved.                                                        *
- *                                                                             *
- * Maintainers: maintainers@chelsio.com                                        *
- *                                                                             *
- * History:                                                                    *
- *                                                                             *
- ******************************************************************************/
+/*****************************************************************************
+ *                                                                           *
+ * File: elmer0.h                                                            *
+ * $Revision: 1.3 $                                                          *
+ * $Date: 2005/03/23 07:15:58 $                                              *
+ * Description:                                                              *
+ *  part of the Chelsio 10Gb Ethernet Driver.                                *
+ *                                                                           *
+ * This program is free software; you can redistribute it and/or modify      *
+ * it under the terms of the GNU General Public License, version 2, as       *
+ * published by the Free Software Foundation.                                *
+ *                                                                           *
+ * You should have received a copy of the GNU General Public License along   *
+ * with this program; if not, write to the Free Software Foundation, Inc.,   *
+ * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.                 *
+ *                                                                           *
+ * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR IMPLIED    *
+ * WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF      *
+ * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.                     *
+ *                                                                           *
+ * http://www.chelsio.com                                                    *
+ *                                                                           *
+ * Copyright (c) 2003 - 2005 Chelsio Communications, Inc.                    *
+ * All rights reserved.                                                      *
+ *                                                                           *
+ * Maintainers: maintainers@chelsio.com                                      *
+ *                                                                           *
+ * Authors: Dimitrios Michailidis   <dm@chelsio.com>                         *
+ *          Tina Yang               <tainay@chelsio.com>                     *
+ *          Felix Marti             <felix@chelsio.com>                      *
+ *          Scott Bardone           <sbardone@chelsio.com>                   *
+ *          Kurt Ottaway            <kottaway@chelsio.com>                   *
+ *          Frank DiMambro          <frank@chelsio.com>                      *
+ *                                                                           *
+ * History:                                                                  *
+ *                                                                           *
+ ****************************************************************************/

 #ifndef CHELSIO_ELMER0_H
 #define CHELSIO_ELMER0_H
diff -Naur linux-2.6.12-rc1-mm1/drivers/net/chelsio/espi.c linux-2.6.12-rc1-mm1.patched/drivers/net/chelsio/espi.c
--- linux-2.6.12-rc1-mm1/drivers/net/chelsio/espi.c	2005-03-22 13:05:45.000000000 -0800
+++ linux-2.6.12-rc1-mm1.patched/drivers/net/chelsio/espi.c	2005-03-22 23:56:43.000000000 -0800
@@ -1,34 +1,41 @@
-/*******************************************************************************
- *                                                                             *
- * File: espi.c                                                                *
- * Revision: 1.2                                                               *
- * Date: 2005/03/10 07:07:38                                                   *
- * Description:                                                                *
- *  Ethernet SPI functionality.                                                *
- *  part of the Chelsio 10Gb Ethernet Driver.                                  *
- *                                                                             *
- * This program is free software; you can redistribute it and/or modify        *
- * it under the terms of the GNU General Public License, version 2, as         *
- * published by the Free Software Foundation.                                  *
- *                                                                             *
- * You should have received a copy of the GNU General Public License along     *
- * with this program; if not, write to the Free Software Foundation, Inc.,     *
- * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.                   *
- *                                                                             *
- * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR IMPLIED      *
- * WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF        *
- * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.                       *
- *                                                                             *
- * http://www.chelsio.com                                                      *
- *                                                                             *
- * Copyright (c) 2003 - 2005 Chelsio Communications, Inc.                      *
- * All rights reserved.                                                        *
- *                                                                             *
- * Maintainers: maintainers@chelsio.com                                        *
- *                                                                             *
- * History:                                                                    *
- *                                                                             *
- ******************************************************************************/
+/*****************************************************************************
+ *                                                                           *
+ * File: espi.c                                                              *
+ * $Revision: 1.9 $                                                          *
+ * $Date: 2005/03/23 07:41:27 $                                              *
+ * Description:                                                              *
+ *  Ethernet SPI functionality.                                              *
+ *  part of the Chelsio 10Gb Ethernet Driver.                                *
+ *                                                                           *
+ * This program is free software; you can redistribute it and/or modify      *
+ * it under the terms of the GNU General Public License, version 2, as       *
+ * published by the Free Software Foundation.                                *
+ *                                                                           *
+ * You should have received a copy of the GNU General Public License along   *
+ * with this program; if not, write to the Free Software Foundation, Inc.,   *
+ * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.                 *
+ *                                                                           *
+ * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR IMPLIED    *
+ * WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF      *
+ * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.                     *
+ *                                                                           *
+ * http://www.chelsio.com                                                    *
+ *                                                                           *
+ * Copyright (c) 2003 - 2005 Chelsio Communications, Inc.                    *
+ * All rights reserved.                                                      *
+ *                                                                           *
+ * Maintainers: maintainers@chelsio.com                                      *
+ *                                                                           *
+ * Authors: Dimitrios Michailidis   <dm@chelsio.com>                         *
+ *          Tina Yang               <tainay@chelsio.com>                     *
+ *          Felix Marti             <felix@chelsio.com>                      *
+ *          Scott Bardone           <sbardone@chelsio.com>                   *
+ *          Kurt Ottaway            <kottaway@chelsio.com>                   *
+ *          Frank DiMambro          <frank@chelsio.com>                      *
+ *                                                                           *
+ * History:                                                                  *
+ *                                                                           *
+ ****************************************************************************/

 #include "common.h"
 #include "regs.h"
@@ -68,7 +75,7 @@
 	} while (busy && --attempts);

 	if (busy)
-		CH_ERR("%s: TRICN write timed out\n", adapter_name(adapter));
+		CH_ERR("%s: TRICN write timed out\n", adapter->name);

 	return busy;
 }
@@ -78,51 +85,51 @@
 /* 3. Deassert rx_reset_link */
 static int tricn_init(adapter_t *adapter)
 {
-    int     i               = 0;
-    int     sme             = 1;
-    int     stat            = 0;
-    int     timeout         = 0;
-    int     is_ready        = 0;
-    int     dynamic_deskew  = 0;
-
-    if (dynamic_deskew)
-        sme = 0;
-
-
-    /* 1 */
-    timeout=1000;
-    do {
-        stat = t1_read_reg_4(adapter, A_ESPI_RX_RESET);
-        is_ready = (stat & 0x4);
-        timeout--;
-        DELAY_US(5);
-    } while (!is_ready || (timeout==0));
-    t1_write_reg_4(adapter, A_ESPI_RX_RESET, 0x2);
-    if (timeout==0)
-    {
-        CH_ERR("ESPI : ERROR : Timeout tricn_init() \n");
-        t1_fatal_err(adapter);
-    }
-
-    /* 2 */
-    if (sme) {
-        tricn_write(adapter, 0, 0, 0, TRICN_CNFG, 0x81);
-        tricn_write(adapter, 0, 1, 0, TRICN_CNFG, 0x81);
-        tricn_write(adapter, 0, 2, 0, TRICN_CNFG, 0x81);
-    }
-    for (i=1; i<= 8; i++) tricn_write(adapter, 0, 0, i, TRICN_CNFG, 0xf1);
-    for (i=1; i<= 2; i++) tricn_write(adapter, 0, 1, i, TRICN_CNFG, 0xf1);
-    for (i=1; i<= 3; i++) tricn_write(adapter, 0, 2, i, TRICN_CNFG, 0xe1);
-    for (i=4; i<= 4; i++) tricn_write(adapter, 0, 2, i, TRICN_CNFG, 0xf1);
-    for (i=5; i<= 5; i++) tricn_write(adapter, 0, 2, i, TRICN_CNFG, 0xe1);
-    for (i=6; i<= 6; i++) tricn_write(adapter, 0, 2, i, TRICN_CNFG, 0xf1);
-    for (i=7; i<= 7; i++) tricn_write(adapter, 0, 2, i, TRICN_CNFG, 0x80);
-    for (i=8; i<= 8; i++) tricn_write(adapter, 0, 2, i, TRICN_CNFG, 0xf1);
+	int     i               = 0;
+	int     sme             = 1;
+	int     stat            = 0;
+	int     timeout         = 0;
+	int     is_ready        = 0;
+	int     dynamic_deskew  = 0;

-    /* 3 */
-    t1_write_reg_4(adapter, A_ESPI_RX_RESET, 0x3);
+	if (dynamic_deskew)
+		sme = 0;

-    return 0;
+
+	/* 1 */
+	timeout=1000;
+	do {
+		stat = t1_read_reg_4(adapter, A_ESPI_RX_RESET);
+		is_ready = (stat & 0x4);
+		timeout--;
+		udelay(5);
+	} while (!is_ready || (timeout==0));
+	t1_write_reg_4(adapter, A_ESPI_RX_RESET, 0x2);
+	if (timeout==0)
+	{
+		CH_ERR("ESPI : ERROR : Timeout tricn_init() \n");
+		t1_fatal_err(adapter);
+	}
+
+	/* 2 */
+	if (sme) {
+		tricn_write(adapter, 0, 0, 0, TRICN_CNFG, 0x81);
+		tricn_write(adapter, 0, 1, 0, TRICN_CNFG, 0x81);
+		tricn_write(adapter, 0, 2, 0, TRICN_CNFG, 0x81);
+	}
+	for (i=1; i<= 8; i++) tricn_write(adapter, 0, 0, i, TRICN_CNFG, 0xf1);
+	for (i=1; i<= 2; i++) tricn_write(adapter, 0, 1, i, TRICN_CNFG, 0xf1);
+	for (i=1; i<= 3; i++) tricn_write(adapter, 0, 2, i, TRICN_CNFG, 0xe1);
+	for (i=4; i<= 4; i++) tricn_write(adapter, 0, 2, i, TRICN_CNFG, 0xf1);
+	for (i=5; i<= 5; i++) tricn_write(adapter, 0, 2, i, TRICN_CNFG, 0xe1);
+	for (i=6; i<= 6; i++) tricn_write(adapter, 0, 2, i, TRICN_CNFG, 0xf1);
+	for (i=7; i<= 7; i++) tricn_write(adapter, 0, 2, i, TRICN_CNFG, 0x80);
+	for (i=8; i<= 8; i++) tricn_write(adapter, 0, 2, i, TRICN_CNFG, 0xf1);
+
+	/* 3 */
+	t1_write_reg_4(adapter, A_ESPI_RX_RESET, 0x3);
+
+	return 0;
 }

 void t1_espi_intr_enable(struct peespi *espi)
@@ -171,7 +178,7 @@
 	if (status & F_RAMPARITYERR)
 		espi->intr_cnt.parity_err++;
 	if (status & F_DIP2PARITYERR) {
-		espi->intr_cnt.DIP2_parity_err++;
+		espi->intr_cnt.DIP2_parity_err++;

 		/*
 		 * Must read the error count to clear the interrupt
@@ -190,11 +197,6 @@
 	return 0;
 }

-const struct espi_intr_counts *t1_espi_get_intr_counts(struct peespi *espi)
-{
-	return &espi->intr_cnt;
-}
-
 static void espi_setup_for_pm3393(adapter_t *adapter)
 {
 	u32 wmark = t1_is_T1B(adapter) ? 0x4000 : 0x3200;
@@ -300,10 +302,10 @@
 		cnt = t1_read_reg_4(espi->adapter, A_ESPI_DIP2_ERR_COUNT);
 	}

-        /*
-         * For T1B we need to write 1 to clear ESPI interrupts.  For T2+ we
-         * write the status as is.
-         */
+	/*
+	 * For T1B we need to write 1 to clear ESPI interrupts.  For T2+ we
+	 * write the status as is.
+	 */
 	if (status && t1_is_T1B(espi->adapter))
 		status = 1;
 	t1_write_reg_4(espi->adapter, A_ESPI_INTR_STATUS, status);
@@ -313,15 +315,15 @@

 	if (is_T2(adapter)) {
 		tricn_init(adapter);
-		/*
-		 * Always position the control at the 1st port egress IN
+		/*
+		 * Always position the control at the 1st port egress IN
 		 * (sop,eop) counter to reduce PIOs for T/N210 workaround.
 		 */
 		espi->misc_ctrl = (t1_read_reg_4(adapter, A_ESPI_MISC_CONTROL)
 				   & ~MON_MASK) | (F_MONITORED_DIRECTION
 				   | F_MONITORED_INTERFACE);
-		t1_write_reg_4(adapter, A_ESPI_MISC_CONTROL, espi->misc_ctrl);
-		spin_lock_init(&espi->lock);
+		t1_write_reg_4(adapter, A_ESPI_MISC_CONTROL, espi->misc_ctrl);
+		spin_lock_init(&espi->lock);
 	}

 	return 0;
@@ -329,12 +331,14 @@

 void t1_espi_destroy(struct peespi *espi)
 {
-	t1_free((void *)espi, sizeof(*espi));
+	kfree(espi);
 }

 struct peespi *t1_espi_create(adapter_t *adapter)
 {
-	struct peespi *espi = t1_malloc(sizeof(*espi));
+	struct peespi *espi = kmalloc(sizeof(*espi), GFP_KERNEL);
+
+	memset(espi, 0, sizeof(*espi));

 	if (espi)
 		espi->adapter = adapter;
@@ -348,7 +352,7 @@
 	if (!is_T2(adapter))
 		return;
 	spin_lock(&espi->lock);
-	espi->misc_ctrl = (val & ~MON_MASK) |
+	espi->misc_ctrl = (val & ~MON_MASK) |
 			  (espi->misc_ctrl & MON_MASK);
 	t1_write_reg_4(adapter, A_ESPI_MISC_CONTROL, espi->misc_ctrl);
 	spin_unlock(&espi->lock);
@@ -369,10 +373,10 @@
 	else
 		spin_lock(&espi->lock);
 	if ((sel != (espi->misc_ctrl & MON_MASK))) {
-		t1_write_reg_4(adapter, A_ESPI_MISC_CONTROL,
+		t1_write_reg_4(adapter, A_ESPI_MISC_CONTROL,
 			       ((espi->misc_ctrl & ~MON_MASK) | sel));
 		sel = t1_read_reg_4(adapter, A_ESPI_SCH_TOKEN3);
-		t1_write_reg_4(adapter, A_ESPI_MISC_CONTROL,
+		t1_write_reg_4(adapter, A_ESPI_MISC_CONTROL,
 			       espi->misc_ctrl);
 	}
 	else
diff -Naur linux-2.6.12-rc1-mm1/drivers/net/chelsio/espi.h linux-2.6.12-rc1-mm1.patched/drivers/net/chelsio/espi.h
--- linux-2.6.12-rc1-mm1/drivers/net/chelsio/espi.h	2005-03-22 13:05:45.000000000 -0800
+++ linux-2.6.12-rc1-mm1.patched/drivers/net/chelsio/espi.h	2005-03-22 23:56:43.000000000 -0800
@@ -1,33 +1,40 @@
-/*******************************************************************************
- *                                                                             *
- * File: espi.h                                                                *
- * Revision: 1.2                                                               *
- * Date: 2005/03/10 07:07:38                                                   *
- * Description:                                                                *
- *  part of the Chelsio 10Gb Ethernet Driver.                                  *
- *                                                                             *
- * This program is free software; you can redistribute it and/or modify        *
- * it under the terms of the GNU General Public License, version 2, as         *
- * published by the Free Software Foundation.                                  *
- *                                                                             *
- * You should have received a copy of the GNU General Public License along     *
- * with this program; if not, write to the Free Software Foundation, Inc.,     *
- * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.                   *
- *                                                                             *
- * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR IMPLIED      *
- * WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF        *
- * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.                       *
- *                                                                             *
- * http://www.chelsio.com                                                      *
- *                                                                             *
- * Copyright (c) 2003 - 2005 Chelsio Communications, Inc.                      *
- * All rights reserved.                                                        *
- *                                                                             *
- * Maintainers: maintainers@chelsio.com                                        *
- *                                                                             *
- * History:                                                                    *
- *                                                                             *
- ******************************************************************************/
+/*****************************************************************************
+ *                                                                           *
+ * File: espi.h                                                              *
+ * $Revision: 1.4 $                                                          *
+ * $Date: 2005/03/23 07:15:58 $                                              *
+ * Description:                                                              *
+ *  part of the Chelsio 10Gb Ethernet Driver.                                *
+ *                                                                           *
+ * This program is free software; you can redistribute it and/or modify      *
+ * it under the terms of the GNU General Public License, version 2, as       *
+ * published by the Free Software Foundation.                                *
+ *                                                                           *
+ * You should have received a copy of the GNU General Public License along   *
+ * with this program; if not, write to the Free Software Foundation, Inc.,   *
+ * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.                 *
+ *                                                                           *
+ * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR IMPLIED    *
+ * WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF      *
+ * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.                     *
+ *                                                                           *
+ * http://www.chelsio.com                                                    *
+ *                                                                           *
+ * Copyright (c) 2003 - 2005 Chelsio Communications, Inc.                    *
+ * All rights reserved.                                                      *
+ *                                                                           *
+ * Maintainers: maintainers@chelsio.com                                      *
+ *                                                                           *
+ * Authors: Dimitrios Michailidis   <dm@chelsio.com>                         *
+ *          Tina Yang               <tainay@chelsio.com>                     *
+ *          Felix Marti             <felix@chelsio.com>                      *
+ *          Scott Bardone           <sbardone@chelsio.com>                   *
+ *          Kurt Ottaway            <kottaway@chelsio.com>                   *
+ *          Frank DiMambro          <frank@chelsio.com>                      *
+ *                                                                           *
+ * History:                                                                  *
+ *                                                                           *
+ ****************************************************************************/

 #ifndef CHELSIO_ESPI_H
 #define CHELSIO_ESPI_H
@@ -53,7 +60,6 @@
 void t1_espi_intr_clear(struct peespi *);
 void t1_espi_intr_disable(struct peespi *);
 int t1_espi_intr_handler(struct peespi *);
-const struct espi_intr_counts *t1_espi_get_intr_counts(struct peespi *espi);

 void t1_espi_set_misc_ctrl(adapter_t *adapter, u32 val);
 u32 t1_espi_get_mon(adapter_t *adapter, u32 addr, u8 wait);
diff -Naur linux-2.6.12-rc1-mm1/drivers/net/chelsio/gmac.h linux-2.6.12-rc1-mm1.patched/drivers/net/chelsio/gmac.h
--- linux-2.6.12-rc1-mm1/drivers/net/chelsio/gmac.h	2005-03-22 13:05:45.000000000 -0800
+++ linux-2.6.12-rc1-mm1.patched/drivers/net/chelsio/gmac.h	2005-03-22 23:56:44.000000000 -0800
@@ -1,34 +1,41 @@
-/*******************************************************************************
- *                                                                             *
- * File: gmac.h                                                                *
- * Revision: 1.2                                                               *
- * Date: 2005/03/10 07:07:38                                                   *
- * Description:                                                                *
- *  Generic MAC functionality.                                                 *
- *  part of the Chelsio 10Gb Ethernet Driver.                                  *
- *                                                                             *
- * This program is free software; you can redistribute it and/or modify        *
- * it under the terms of the GNU General Public License, version 2, as         *
- * published by the Free Software Foundation.                                  *
- *                                                                             *
- * You should have received a copy of the GNU General Public License along     *
- * with this program; if not, write to the Free Software Foundation, Inc.,     *
- * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.                   *
- *                                                                             *
- * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR IMPLIED      *
- * WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF        *
- * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.                       *
- *                                                                             *
- * http://www.chelsio.com                                                      *
- *                                                                             *
- * Copyright (c) 2003 - 2005 Chelsio Communications, Inc.                      *
- * All rights reserved.                                                        *
- *                                                                             *
- * Maintainers: maintainers@chelsio.com                                        *
- *                                                                             *
- * History:                                                                    *
- *                                                                             *
- ******************************************************************************/
+/*****************************************************************************
+ *                                                                           *
+ * File: gmac.h                                                              *
+ * $Revision: 1.3 $                                                          *
+ * $Date: 2005/03/23 07:15:58 $                                              *
+ * Description:                                                              *
+ *  Generic MAC functionality.                                               *
+ *  part of the Chelsio 10Gb Ethernet Driver.                                *
+ *                                                                           *
+ * This program is free software; you can redistribute it and/or modify      *
+ * it under the terms of the GNU General Public License, version 2, as       *
+ * published by the Free Software Foundation.                                *
+ *                                                                           *
+ * You should have received a copy of the GNU General Public License along   *
+ * with this program; if not, write to the Free Software Foundation, Inc.,   *
+ * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.                 *
+ *                                                                           *
+ * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR IMPLIED    *
+ * WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF      *
+ * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.                     *
+ *                                                                           *
+ * http://www.chelsio.com                                                    *
+ *                                                                           *
+ * Copyright (c) 2003 - 2005 Chelsio Communications, Inc.                    *
+ * All rights reserved.                                                      *
+ *                                                                           *
+ * Maintainers: maintainers@chelsio.com                                      *
+ *                                                                           *
+ * Authors: Dimitrios Michailidis   <dm@chelsio.com>                         *
+ *          Tina Yang               <tainay@chelsio.com>                     *
+ *          Felix Marti             <felix@chelsio.com>                      *
+ *          Scott Bardone           <sbardone@chelsio.com>                   *
+ *          Kurt Ottaway            <kottaway@chelsio.com>                   *
+ *          Frank DiMambro          <frank@chelsio.com>                      *
+ *                                                                           *
+ * History:                                                                  *
+ *                                                                           *
+ ****************************************************************************/

 #ifndef CHELSIO_GMAC_H
 #define CHELSIO_GMAC_H
diff -Naur linux-2.6.12-rc1-mm1/drivers/net/chelsio/Makefile linux-2.6.12-rc1-mm1.patched/drivers/net/chelsio/Makefile
--- linux-2.6.12-rc1-mm1/drivers/net/chelsio/Makefile	2005-03-22 13:05:45.000000000 -0800
+++ linux-2.6.12-rc1-mm1.patched/drivers/net/chelsio/Makefile	2005-03-22 23:56:44.000000000 -0800
@@ -7,7 +7,6 @@
 EXTRA_CFLAGS += -I$(TOPDIR)/drivers/net/chelsio $(DEBUG_FLAGS)


-cxgb-objs := cxgb2.o espi.o tp.o pm3393.o sge.o subr.o \
-             mv88x201x.o my3126.o $(cxgb-y)
+cxgb-objs := cxgb2.o espi.o tp.o pm3393.o sge.o subr.o mv88x201x.o


diff -Naur linux-2.6.12-rc1-mm1/drivers/net/chelsio/mv88x201x.c linux-2.6.12-rc1-mm1.patched/drivers/net/chelsio/mv88x201x.c
--- linux-2.6.12-rc1-mm1/drivers/net/chelsio/mv88x201x.c	2005-03-22 13:05:45.000000000 -0800
+++ linux-2.6.12-rc1-mm1.patched/drivers/net/chelsio/mv88x201x.c	2005-03-22 23:56:44.000000000 -0800
@@ -1,34 +1,41 @@
-/*******************************************************************************
- *                                                                             *
- * File: mv88x201x.c                                                           *
- * Revision: 1.2                                                               *
- * Date: 2005/03/10 07:07:38                                                   *
- * Description:                                                                *
- *  Marvell PHY (mv88x201x) functionality.                                     *
- *  part of the Chelsio 10Gb Ethernet Driver.                                  *
- *                                                                             *
- * This program is free software; you can redistribute it and/or modify        *
- * it under the terms of the GNU General Public License, version 2, as         *
- * published by the Free Software Foundation.                                  *
- *                                                                             *
- * You should have received a copy of the GNU General Public License along     *
- * with this program; if not, write to the Free Software Foundation, Inc.,     *
- * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.                   *
- *                                                                             *
- * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR IMPLIED      *
- * WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF        *
- * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.                       *
- *                                                                             *
- * http://www.chelsio.com                                                      *
- *                                                                             *
- * Copyright (c) 2003 - 2005 Chelsio Communications, Inc.                      *
- * All rights reserved.                                                        *
- *                                                                             *
- * Maintainers: maintainers@chelsio.com                                        *
- *                                                                             *
- * History:                                                                    *
- *                                                                             *
- ******************************************************************************/
+/*****************************************************************************
+ *                                                                           *
+ * File: mv88x201x.c                                                         *
+ * $Revision: 1.7 $                                                          *
+ * $Date: 2005/03/23 07:15:59 $                                              *
+ * Description:                                                              *
+ *  Marvell PHY (mv88x201x) functionality.                                   *
+ *  part of the Chelsio 10Gb Ethernet Driver.                                *
+ *                                                                           *
+ * This program is free software; you can redistribute it and/or modify      *
+ * it under the terms of the GNU General Public License, version 2, as       *
+ * published by the Free Software Foundation.                                *
+ *                                                                           *
+ * You should have received a copy of the GNU General Public License along   *
+ * with this program; if not, write to the Free Software Foundation, Inc.,   *
+ * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.                 *
+ *                                                                           *
+ * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR IMPLIED    *
+ * WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF      *
+ * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.                     *
+ *                                                                           *
+ * http://www.chelsio.com                                                    *
+ *                                                                           *
+ * Copyright (c) 2003 - 2005 Chelsio Communications, Inc.                    *
+ * All rights reserved.                                                      *
+ *                                                                           *
+ * Maintainers: maintainers@chelsio.com                                      *
+ *                                                                           *
+ * Authors: Dimitrios Michailidis   <dm@chelsio.com>                         *
+ *          Tina Yang               <tainay@chelsio.com>                     *
+ *          Felix Marti             <felix@chelsio.com>                      *
+ *          Scott Bardone           <sbardone@chelsio.com>                   *
+ *          Kurt Ottaway            <kottaway@chelsio.com>                   *
+ *          Frank DiMambro          <frank@chelsio.com>                      *
+ *                                                                           *
+ * History:                                                                  *
+ *                                                                           *
+ ****************************************************************************/

 #include "cphy.h"
 #include "elmer0.h"
@@ -120,7 +127,7 @@
 	mdio_read(cphy, 0x1, 0x9005, &val);

 	/* Read this register after the others above it else
-	 * the register doesn't clear correctly.
+	 * the register doesn't clear correctly.
 	 */
 	mdio_read(cphy, 0x1, 0x1, &val);
 #endif
@@ -186,7 +193,7 @@

 static void mv88x201x_destroy(struct cphy *cphy)
 {
-	t1_free((void *) cphy, sizeof(*cphy));
+	kfree(cphy);
 }

 static struct cphy_ops mv88x201x_ops = {
@@ -204,11 +211,11 @@
 					 struct mdio_ops *mdio_ops)
 {
 	u32 val;
-	struct cphy *cphy = t1_malloc(sizeof(*cphy));
+	struct cphy *cphy = kmalloc(sizeof(*cphy), GFP_KERNEL);

 	if (!cphy)
 		return NULL;
-
+	memset(cphy, 0, sizeof(*cphy));
 	cphy_init(cphy, adapter, phy_addr, &mv88x201x_ops, mdio_ops);

 	/* Commands the PHY to enable XFP's clock. */
@@ -232,16 +239,16 @@
 	t1_tpi_read(adapter, A_ELMER0_GPO, &val);
 	val &= ~4;
 	t1_tpi_write(adapter, A_ELMER0_GPO, val);
-	DELAY_MS(100);
+	msleep(100);

 	t1_tpi_write(adapter, A_ELMER0_GPO, val | 4);
-	DELAY_MS(1000);
+	msleep(1000);

 	/* Now lets enable the Laser. Delay 100us */
 	t1_tpi_read(adapter, A_ELMER0_GPO, &val);
 	val |= 0x8000;
 	t1_tpi_write(adapter, A_ELMER0_GPO, val);
-	DELAY_US(100);
+	udelay(100);
 	return 0;
 }

diff -Naur linux-2.6.12-rc1-mm1/drivers/net/chelsio/my3126.c linux-2.6.12-rc1-mm1.patched/drivers/net/chelsio/my3126.c
--- linux-2.6.12-rc1-mm1/drivers/net/chelsio/my3126.c	2005-03-22 13:05:45.000000000 -0800
+++ linux-2.6.12-rc1-mm1.patched/drivers/net/chelsio/my3126.c	1969-12-31 16:00:00.000000000 -0800
@@ -1,129 +0,0 @@
-/*******************************************************************************
- *                                                                             *
- * File: my3126.c                                                              *
- * Revision: 1.2                                                               *
- * Date: 2005/03/10 07:07:38                                                   *
- * Description:                                                                *
- *  CX-4 PHY functionality.                                                    *
- *  part of the Chelsio 10Gb Ethernet Driver.                                  *
- *                                                                             *
- * This program is free software; you can redistribute it and/or modify        *
- * it under the terms of the GNU General Public License, version 2, as         *
- * published by the Free Software Foundation.                                  *
- *                                                                             *
- * You should have received a copy of the GNU General Public License along     *
- * with this program; if not, write to the Free Software Foundation, Inc.,     *
- * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.                   *
- *                                                                             *
- * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR IMPLIED      *
- * WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF        *
- * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.                       *
- *                                                                             *
- * http://www.chelsio.com                                                      *
- *                                                                             *
- * Copyright (c) 2003 - 2005 Chelsio Communications, Inc.                      *
- * All rights reserved.                                                        *
- *                                                                             *
- * Maintainers: maintainers@chelsio.com                                        *
- *                                                                             *
- * History:                                                                    *
- *                                                                             *
- ******************************************************************************/
-
-#include "cphy.h"
-#include "elmer0.h"
-
-/* Port Reset */
-static int my3126_reset(struct cphy *cphy, int wait)
-{
-	/* This can be done through registers.  It is not required since
-	 * a full chip reset is used.
-	 */
-	return 0;
-}
-
-static int my3126_interrupt_enable(struct cphy *cphy)
-{
-	return 0;
-}
-
-static int my3126_interrupt_disable(struct cphy *cphy)
-{
-	return 0;
-}
-
-static int my3126_interrupt_clear(struct cphy *cphy)
-{
-	return 0;
-}
-
-static int my3126_interrupt_handler(struct cphy *cphy)
-{
-	my3126_interrupt_clear(cphy);
-
-	/* We have only enabled link change interrupts so it must be that */
-	return cphy_cause_link_change;
-}
-
-static int my3126_set_loopback(struct cphy *cphy, int on)
-{
-	return 0;
-}
-
-static int my3126_get_link_status(struct cphy *cphy, int *link_ok, int *speed,
-				  int *duplex, int *fc)
-{
-	return 0;
-}
-
-static void my3126_destroy(struct cphy *cphy)
-{
-	t1_free((void *) cphy, sizeof(*cphy));
-}
-
-static struct cphy_ops my3126_ops = {
-	.destroy           = my3126_destroy,
-	.reset             = my3126_reset,
-	.interrupt_enable  = my3126_interrupt_enable,
-	.interrupt_disable = my3126_interrupt_disable,
-	.interrupt_clear   = my3126_interrupt_clear,
-	.interrupt_handler = my3126_interrupt_handler,
-	.get_link_status   = my3126_get_link_status,
-	.set_loopback      = my3126_set_loopback,
-};
-
-static struct cphy *my3126_phy_create(adapter_t *adapter, int phy_addr,
-				      struct mdio_ops *mdio_ops)
-{
-	struct cphy *cphy = t1_malloc(sizeof(*cphy));
-
-	if (cphy)
-		cphy_init(cphy, adapter, phy_addr, &my3126_ops, mdio_ops);
-	return cphy;
-}
-
-/* Chip Reset */
-static int my3126_phy_reset(adapter_t * adapter)
-{
-	u32 val;
-
-	t1_tpi_read(adapter, A_ELMER0_GPO, &val);
-	val &= ~4;
-	t1_tpi_write(adapter, A_ELMER0_GPO, val);
-	DELAY_MS(100);
-
-	t1_tpi_write(adapter, A_ELMER0_GPO, val | 4);
-	DELAY_MS(1000);
-
-	/* Now lets enable the Laser. Delay 100us */
-	t1_tpi_read(adapter, A_ELMER0_GPO, &val);
-	val |= 0x8000;
-	t1_tpi_write(adapter, A_ELMER0_GPO, val);
-	DELAY_US(100);
-	return 0;
-}
-
-struct gphy t1_my3126_ops = {
-	my3126_phy_create,
-	my3126_phy_reset
-};
diff -Naur linux-2.6.12-rc1-mm1/drivers/net/chelsio/osdep.h linux-2.6.12-rc1-mm1.patched/drivers/net/chelsio/osdep.h
--- linux-2.6.12-rc1-mm1/drivers/net/chelsio/osdep.h	2005-03-22 13:05:45.000000000 -0800
+++ linux-2.6.12-rc1-mm1.patched/drivers/net/chelsio/osdep.h	2005-03-22 23:56:44.000000000 -0800
@@ -1,45 +1,46 @@
-/*******************************************************************************
- *                                                                             *
- * File: osdep.h                                                               *
- * Revision: 1.3                                                               *
- * Date: 2005/03/10 20:47:04                                                   *
- * Description:                                                                *
- *  part of the Chelsio 10Gb Ethernet Driver.                                  *
- *                                                                             *
- * This program is free software; you can redistribute it and/or modify        *
- * it under the terms of the GNU General Public License, version 2, as         *
- * published by the Free Software Foundation.                                  *
- *                                                                             *
- * You should have received a copy of the GNU General Public License along     *
- * with this program; if not, write to the Free Software Foundation, Inc.,     *
- * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.                   *
- *                                                                             *
- * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR IMPLIED      *
- * WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF        *
- * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.                       *
- *                                                                             *
- * http://www.chelsio.com                                                      *
- *                                                                             *
- * Copyright (c) 2003 - 2005 Chelsio Communications, Inc.                      *
- * All rights reserved.                                                        *
- *                                                                             *
- * Maintainers: maintainers@chelsio.com                                        *
- *                                                                             *
- * History:                                                                    *
- *                                                                             *
- ******************************************************************************/
+/*****************************************************************************
+ *                                                                           *
+ * File: osdep.h                                                             *
+ * $Revision: 1.9 $                                                          *
+ * $Date: 2005/03/23 07:41:27 $                                              *
+ * Description:                                                              *
+ *  part of the Chelsio 10Gb Ethernet Driver.                                *
+ *                                                                           *
+ * This program is free software; you can redistribute it and/or modify      *
+ * it under the terms of the GNU General Public License, version 2, as       *
+ * published by the Free Software Foundation.                                *
+ *                                                                           *
+ * You should have received a copy of the GNU General Public License along   *
+ * with this program; if not, write to the Free Software Foundation, Inc.,   *
+ * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.                 *
+ *                                                                           *
+ * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR IMPLIED    *
+ * WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF      *
+ * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.                     *
+ *                                                                           *
+ * http://www.chelsio.com                                                    *
+ *                                                                           *
+ * Copyright (c) 2003 - 2005 Chelsio Communications, Inc.                    *
+ * All rights reserved.                                                      *
+ *                                                                           *
+ * Maintainers: maintainers@chelsio.com                                      *
+ *                                                                           *
+ * Authors: Dimitrios Michailidis   <dm@chelsio.com>                         *
+ *          Tina Yang               <tainay@chelsio.com>                     *
+ *          Felix Marti             <felix@chelsio.com>                      *
+ *          Scott Bardone           <sbardone@chelsio.com>                   *
+ *          Kurt Ottaway            <kottaway@chelsio.com>                   *
+ *          Frank DiMambro          <frank@chelsio.com>                      *
+ *                                                                           *
+ * History:                                                                  *
+ *                                                                           *
+ ****************************************************************************/

 #ifndef __CHELSIO_OSDEP_H
 #define __CHELSIO_OSDEP_H

 #include <linux/version.h>
-#if defined(MODULE) && ! defined(MODVERSIONS)
-#define MODVERSIONS
-#endif
-#ifdef MODULE
 #include <linux/module.h>
-#endif
-
 #include <linux/config.h>
 #include <linux/types.h>
 #include <linux/delay.h>
@@ -71,7 +72,7 @@

 #ifdef DEBUG
 # define CH_DBG(adapter, category, fmt, ...) \
-        CH_MSG(adapter, DEBUG, category, fmt, ## __VA_ARGS__)
+	CH_MSG(adapter, DEBUG, category, fmt, ## __VA_ARGS__)
 #else
 # define CH_DBG(fmt, ...)
 #endif
@@ -94,8 +95,6 @@
  */
 typedef struct adapter adapter_t;

-#define DELAY_US(x) udelay(x)
-
 #define TPI_LOCK(adapter) spin_lock(&(adapter)->tpi_lock)
 #define TPI_UNLOCK(adapter) spin_unlock(&(adapter)->tpi_lock)

@@ -103,16 +102,6 @@
 void t1_link_changed(adapter_t *adapter, int port_id, int link_status,
 			int speed, int duplex, int fc);

-static inline void DELAY_MS(unsigned long ms)
-{
-	unsigned long ticks = (ms * HZ + 999) / 1000 + 1;
-
-	while (ticks) {
-		set_current_state(TASK_UNINTERRUPTIBLE);
-		ticks = schedule_timeout(ticks);
-	}
-}
-
 static inline u16 t1_read_reg_2(adapter_t *adapter, u32 reg_addr)
 {
 	u16 val = readw(adapter->regs + reg_addr);
@@ -145,48 +134,6 @@
 	writel(val, adapter->regs + reg_addr);
 }

-static inline void *t1_malloc(size_t len)
-{
-	void *m = kmalloc(len, GFP_KERNEL);
-	if (m)
-		memset(m, 0, len);
-	return m;
-}
-
-static inline void t1_free(void *v, size_t len)
-{
-	kfree(v);
-}
-
-static inline void t1_pci_write_config_4(adapter_t *adapter, int reg,
-					    u32 val)
-{
-	pci_write_config_dword(adapter->pdev, reg, val);
-}
-
-static inline void t1_pci_read_config_4(adapter_t *adapter, int reg,
-					   u32 *val)
-{
-	pci_read_config_dword(adapter->pdev, reg, val);
-}
-
-static inline void t1_pci_write_config_2(adapter_t *adapter, int reg,
-					    u16 val)
-{
-	pci_write_config_word(adapter->pdev, reg, val);
-}
-
-static inline void t1_pci_read_config_2(adapter_t *adapter, int reg,
-					   u16 *val)
-{
-	pci_read_config_word(adapter->pdev, reg, val);
-}
-
-static inline const char *adapter_name(adapter_t *adapter)
-{
-	return adapter->name;
-}
-
 static inline const char *port_name(adapter_t *adapter, int port_idx)
 {
 	return adapter->port[port_idx].dev->name;
@@ -204,9 +151,9 @@
 	struct dev_mc_list *list;
 };

-#define t1_rx_mode_promisc(rm)	(rm->dev->flags & IFF_PROMISC)
-#define t1_rx_mode_allmulti(rm)	(rm->dev->flags & IFF_ALLMULTI)
-#define t1_rx_mode_mc_cnt(rm)	(rm->dev->mc_count)
+#define t1_rx_mode_promisc(rm)	(rm->dev->flags & IFF_PROMISC)
+#define t1_rx_mode_allmulti(rm)	(rm->dev->flags & IFF_ALLMULTI)
+#define t1_rx_mode_mc_cnt(rm)	(rm->dev->mc_count)

 static inline u8 *t1_get_next_mcaddr(struct t1_rx_mode *rm)
 {
diff -Naur linux-2.6.12-rc1-mm1/drivers/net/chelsio/pm3393.c linux-2.6.12-rc1-mm1.patched/drivers/net/chelsio/pm3393.c
--- linux-2.6.12-rc1-mm1/drivers/net/chelsio/pm3393.c	2005-03-22 13:05:45.000000000 -0800
+++ linux-2.6.12-rc1-mm1.patched/drivers/net/chelsio/pm3393.c	2005-03-22 23:56:44.000000000 -0800
@@ -1,34 +1,41 @@
-/*******************************************************************************
- *                                                                             *
- * File: pm3393.c                                                              *
- * Revision: 1.2                                                               *
- * Date: 2005/03/10 07:07:38                                                   *
- * Description:                                                                *
- *  PMC/SIERRA (pm3393) MAC-PHY functionality.                                 *
- *  part of the Chelsio 10Gb Ethernet Driver.                                  *
- *                                                                             *
- * This program is free software; you can redistribute it and/or modify        *
- * it under the terms of the GNU General Public License, version 2, as         *
- * published by the Free Software Foundation.                                  *
- *                                                                             *
- * You should have received a copy of the GNU General Public License along     *
- * with this program; if not, write to the Free Software Foundation, Inc.,     *
- * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.                   *
- *                                                                             *
- * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR IMPLIED      *
- * WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF        *
- * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.                       *
- *                                                                             *
- * http://www.chelsio.com                                                      *
- *                                                                             *
- * Copyright (c) 2003 - 2005 Chelsio Communications, Inc.                      *
- * All rights reserved.                                                        *
- *                                                                             *
- * Maintainers: maintainers@chelsio.com                                        *
- *                                                                             *
- * History:                                                                    *
- *                                                                             *
- ******************************************************************************/
+/*****************************************************************************
+ *                                                                           *
+ * File: pm3393.c                                                            *
+ * $Revision: 1.9 $                                                          *
+ * $Date: 2005/03/23 07:41:27 $                                              *
+ * Description:                                                              *
+ *  PMC/SIERRA (pm3393) MAC-PHY functionality.                               *
+ *  part of the Chelsio 10Gb Ethernet Driver.                                *
+ *                                                                           *
+ * This program is free software; you can redistribute it and/or modify      *
+ * it under the terms of the GNU General Public License, version 2, as       *
+ * published by the Free Software Foundation.                                *
+ *                                                                           *
+ * You should have received a copy of the GNU General Public License along   *
+ * with this program; if not, write to the Free Software Foundation, Inc.,   *
+ * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.                 *
+ *                                                                           *
+ * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR IMPLIED    *
+ * WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF      *
+ * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.                     *
+ *                                                                           *
+ * http://www.chelsio.com                                                    *
+ *                                                                           *
+ * Copyright (c) 2003 - 2005 Chelsio Communications, Inc.                    *
+ * All rights reserved.                                                      *
+ *                                                                           *
+ * Maintainers: maintainers@chelsio.com                                      *
+ *                                                                           *
+ * Authors: Dimitrios Michailidis   <dm@chelsio.com>                         *
+ *          Tina Yang               <tainay@chelsio.com>                     *
+ *          Felix Marti             <felix@chelsio.com>                      *
+ *          Scott Bardone           <sbardone@chelsio.com>                   *
+ *          Kurt Ottaway            <kottaway@chelsio.com>                   *
+ *          Frank DiMambro          <frank@chelsio.com>                      *
+ *                                                                           *
+ * History:                                                                  *
+ *                                                                           *
+ ****************************************************************************/

 #include "common.h"
 #include "regs.h"
@@ -55,10 +62,10 @@

 #define IPG 12
 #define TXXG_CONF1_VAL ((IPG << SUNI1x10GEXP_BITOFF_TXXG_IPGT) | \
-    SUNI1x10GEXP_BITMSK_TXXG_32BIT_ALIGN | SUNI1x10GEXP_BITMSK_TXXG_CRCEN | \
-    SUNI1x10GEXP_BITMSK_TXXG_PADEN)
+	SUNI1x10GEXP_BITMSK_TXXG_32BIT_ALIGN | SUNI1x10GEXP_BITMSK_TXXG_CRCEN | \
+	SUNI1x10GEXP_BITMSK_TXXG_PADEN)
 #define RXXG_CONF1_VAL (SUNI1x10GEXP_BITMSK_RXXG_PUREP | 0x14 | \
-    SUNI1x10GEXP_BITMSK_RXXG_FLCHK | SUNI1x10GEXP_BITMSK_RXXG_CRC_STRIP)
+	SUNI1x10GEXP_BITMSK_RXXG_FLCHK | SUNI1x10GEXP_BITMSK_RXXG_CRC_STRIP)

 /* Update statistics every 15 minutes */
 #define STATS_TICK_SECS (15 * 60)
@@ -113,11 +120,11 @@

 /*
  * Enable interrupts for the PM3393
-
-    1. Enable PM3393 BLOCK interrupts.
-    2. Enable PM3393 Master Interrupt bit(INTE)
-    3. Enable ELMER's PM3393 bit.
-    4. Enable Terminator external interrupt.
+
+	1. Enable PM3393 BLOCK interrupts.
+	2. Enable PM3393 Master Interrupt bit(INTE)
+	3. Enable ELMER's PM3393 bit.
+	4. Enable Terminator external interrupt.
 */
 static int pm3393_interrupt_enable(struct cmac *cmac)
 {
@@ -223,7 +230,7 @@
 	pmread(cmac, SUNI1x10GEXP_REG_PL4IO_LOCK_DETECT_STATUS, &val32);
 	pmread(cmac, SUNI1x10GEXP_REG_PL4IO_LOCK_DETECT_CHANGE, &val32);

-	/* PM3393 - Global interrupt status
+	/* PM3393 - Global interrupt status
 	 */
 	pmread(cmac, SUNI1x10GEXP_REG_MASTER_INTERRUPT_STATUS, &val32);

@@ -233,7 +240,7 @@
 	elmer |= ELMER0_GP_BIT1;
 	t1_tpi_write(cmac->adapter, A_ELMER0_INT_CAUSE, elmer);

-	/* TERMINATOR - PL_INTERUPTS_EXT
+	/* TERMINATOR - PL_INTERUPTS_EXT
 	 */
 	pl_intr = t1_read_reg_4(cmac->adapter, A_PL_CAUSE);
 	pl_intr |= F_PL_INTR_EXT;
@@ -247,9 +254,9 @@
 {
 	u32 master_intr_status;
 /*
-    1. Read master interrupt register.
-    2. Read BLOCK's interrupt status registers.
-    3. Handle BLOCK interrupts.
+	1. Read master interrupt register.
+	2. Read BLOCK's interrupt status registers.
+	3. Handle BLOCK interrupts.
 */
 	/* Read the master interrupt status register. */
 	pmread(cmac, SUNI1x10GEXP_REG_MASTER_INTERRUPT_STATUS,
@@ -257,70 +264,6 @@
 	CH_DBG(cmac->adapter, INTR, "PM3393 intr cause 0x%x\n",
 	       master_intr_status);

-	/* Handle BLOCK's interrupts. */
-
-	if (SUNI1x10GEXP_BITMSK_TOP_PL4IO_INT & master_intr_status) {
-	}
-
-	if (SUNI1x10GEXP_BITMSK_TOP_IRAM_INT & master_intr_status) {
-	}
-
-	if (SUNI1x10GEXP_BITMSK_TOP_ERAM_INT & master_intr_status) {
-	}
-
-	/* SERDES */
-	if (SUNI1x10GEXP_BITMSK_TOP_XAUI_INT & master_intr_status) {
-	}
-
-	/* MSTAT */
-	if (SUNI1x10GEXP_BITMSK_TOP_MSTAT_INT & master_intr_status) {
-	}
-
-	/* RXXG */
-	if (SUNI1x10GEXP_BITMSK_TOP_RXXG_INT & master_intr_status) {
-	}
-
-	/* TXXG */
-	if (SUNI1x10GEXP_BITMSK_TOP_TXXG_INT & master_intr_status) {
-	}
-
-	/* XRF */
-	if (SUNI1x10GEXP_BITMSK_TOP_XRF_INT & master_intr_status) {
-	}
-
-	/* XTEF */
-	if (SUNI1x10GEXP_BITMSK_TOP_XTEF_INT & master_intr_status) {
-	}
-
-	/* MDIO */
-	if (SUNI1x10GEXP_BITMSK_TOP_MDIO_BUSY_INT & master_intr_status) {
-		/* Not used. 8000 uses MDIO through Elmer. */
-	}
-
-	/* RXOAM */
-	if (SUNI1x10GEXP_BITMSK_TOP_RXOAM_INT & master_intr_status) {
-	}
-
-	/* TXOAM */
-	if (SUNI1x10GEXP_BITMSK_TOP_TXOAM_INT & master_intr_status) {
-	}
-
-	/* IFLX */
-	if (SUNI1x10GEXP_BITMSK_TOP_IFLX_INT & master_intr_status) {
-	}
-
-	/* EFLX */
-	if (SUNI1x10GEXP_BITMSK_TOP_EFLX_INT & master_intr_status) {
-	}
-
-	/* PL4ODP */
-	if (SUNI1x10GEXP_BITMSK_TOP_PL4ODP_INT & master_intr_status) {
-	}
-
-	/* PL4IDU */
-	if (SUNI1x10GEXP_BITMSK_TOP_PL4IDU_INT & master_intr_status) {
-	}
-
 	/* TBD XXX Lets just clear everything for now */
 	pm3393_interrupt_clear(cmac);

@@ -352,7 +295,7 @@
 	/* Clear port statistics */
 	pmwrite(cmac, SUNI1x10GEXP_REG_MSTAT_CONTROL,
 		SUNI1x10GEXP_BITMSK_MSTAT_CLEAR);
-	DELAY_US(2);
+	udelay(2);
 	memset(&cmac->stats, 0, sizeof(struct cmac_statistics));

 	pm3393_enable(cmac, which);
@@ -381,7 +324,7 @@
 	 * The disable is graceful. Give the PM3393 time.  Can't wait very
 	 * long here, we may be holding locks.
 	 */
-	DELAY_US(20);
+	udelay(20);

 	cmac->instance->enabled &= ~which;
 	return 0;
@@ -420,29 +363,29 @@

 static u32 calc_crc(u8 *b, int len)
 {
-        int i;
+	int i;
 	u32 crc = (u32)~0;

 	/* calculate crc one bit at a time */
-        while (len--) {
-                crc ^= *b++;
-                for (i = 0; i < 8; i++) {
+	while (len--) {
+		crc ^= *b++;
+		for (i = 0; i < 8; i++) {
 			if (crc & 0x1)
 				crc = (crc >> 1) ^ 0xedb88320;
 			else
 				crc = (crc >> 1);
 		}
-        }
+	}

 	/* reverse bits */
-        crc = ((crc >> 4) & 0x0f0f0f0f) | ((crc << 4) & 0xf0f0f0f0);
-        crc = ((crc >> 2) & 0x33333333) | ((crc << 2) & 0xcccccccc);
-        crc = ((crc >> 1) & 0x55555555) | ((crc << 1) & 0xaaaaaaaa);
+	crc = ((crc >> 4) & 0x0f0f0f0f) | ((crc << 4) & 0xf0f0f0f0);
+	crc = ((crc >> 2) & 0x33333333) | ((crc << 2) & 0xcccccccc);
+	crc = ((crc >> 1) & 0x55555555) | ((crc << 1) & 0xaaaaaaaa);
 	/* swap bytes */
-        crc = (crc >> 16) | (crc << 16);
-        crc = (crc >> 8 & 0x00ff00ff) | (crc << 8 & 0xff00ff00);
+	crc = (crc >> 16) | (crc << 16);
+	crc = (crc >> 8 & 0x00ff00ff) | (crc << 8 & 0xff00ff00);

-        return crc;
+	return crc;
 }

 static int pm3393_set_rx_mode(struct cmac *cmac, struct t1_rx_mode *rm)
@@ -460,19 +403,19 @@
 	pmwrite(cmac, SUNI1x10GEXP_REG_RXXG_ADDRESS_FILTER_CONTROL_2,
 		(u16)rx_mode);

-        if (t1_rx_mode_promisc(rm)) {
-                /* Promiscuous mode. */
+	if (t1_rx_mode_promisc(rm)) {
+		/* Promiscuous mode. */
 		rx_mode |= SUNI1x10GEXP_BITMSK_RXXG_PMODE;
-        }
+	}
 	if (t1_rx_mode_allmulti(rm)) {
-                /* Accept all multicast. */
+		/* Accept all multicast. */
 		pmwrite(cmac, SUNI1x10GEXP_REG_RXXG_MULTICAST_HASH_LOW, 0xffff);
 		pmwrite(cmac, SUNI1x10GEXP_REG_RXXG_MULTICAST_HASH_MIDLOW, 0xffff);
 		pmwrite(cmac, SUNI1x10GEXP_REG_RXXG_MULTICAST_HASH_MIDHIGH, 0xffff);
 		pmwrite(cmac, SUNI1x10GEXP_REG_RXXG_MULTICAST_HASH_HIGH, 0xffff);
 		rx_mode |= SUNI1x10GEXP_BITMSK_RXXG_MHASH_EN;
-        } else if (t1_rx_mode_mc_cnt(rm)) {
-                /* Accept one or more multicast(s). */
+	} else if (t1_rx_mode_mc_cnt(rm)) {
+		/* Accept one or more multicast(s). */
 		u8 *addr;
 		int bit;
 		u16 mc_filter[4] = { 0, };
@@ -486,7 +429,7 @@
 		pmwrite(cmac, SUNI1x10GEXP_REG_RXXG_MULTICAST_HASH_MIDHIGH, mc_filter[2]);
 		pmwrite(cmac, SUNI1x10GEXP_REG_RXXG_MULTICAST_HASH_HIGH, mc_filter[3]);
 		rx_mode |= SUNI1x10GEXP_BITMSK_RXXG_MHASH_EN;
-        }
+	}

 	pmwrite(cmac, SUNI1x10GEXP_REG_RXXG_ADDRESS_FILTER_CONTROL_2, (u16)rx_mode);

@@ -608,7 +551,7 @@
 	 * ma[1] = 0x07
 	 * ma[0] = 0x00
 	 *
-	 * The PM3393 requires byte swapping and reverse order entry
+	 * The PM3393 requires byte swapping and reverse order entry
 	 * when programming MAC addresses:
 	 *
 	 * low_bits[15:0]    = ma[1]:ma[0]
@@ -659,7 +602,7 @@

 static void pm3393_destroy(struct cmac *cmac)
 {
-	t1_free((void *)cmac, sizeof(*cmac) + sizeof(cmac_instance));
+	kfree(cmac);
 }

 static struct cmac_ops pm3393_ops = {
@@ -686,9 +629,10 @@
 {
 	struct cmac *cmac;

-	cmac = t1_malloc(sizeof(*cmac) + sizeof(cmac_instance));
+	cmac = kmalloc(sizeof(*cmac) + sizeof(cmac_instance), GFP_KERNEL);
 	if (!cmac)
 		return NULL;
+	memset(cmac, 0, sizeof(*cmac));

 	cmac->ops = &pm3393_ops;
 	cmac->instance = (cmac_instance *) (cmac + 1);
@@ -810,7 +754,7 @@
 	 * 4. Wait minimum of 1ms. (after external clocks and REFEL are stable)
 	 * 5. De-assert RSTB ( write 1 )
 	 * 6. Wait until internal timers to expires after ~14ms.
-	 *    - Allows analog clock synthesizer(PL4CSU) to stabilize to
+	 *    - Allows analog clock synthesizer(PL4CSU) to stabilize to
 	 *      selected reference frequency before allowing the digital
 	 *      portion of the device to operate.
 	 * 7. Wait at least 200us for XAUI interface to stabilize.
@@ -827,23 +771,23 @@
 		t1_tpi_write(adapter, A_ELMER0_GPO, val);

 		/* 2 */
-		DELAY_MS(1);
+		msleep(1);

 		/* 3 */
-		DELAY_MS(1);
+		msleep(1);

 		/* 4 */
-		DELAY_MS(2 /*1 extra ms for safety */ );
+		msleep(2 /*1 extra ms for safety */ );

 		/* 5 */
 		val |= 1;
 		t1_tpi_write(adapter, A_ELMER0_GPO, val);

 		/* 6 */
-		DELAY_MS(15 /*1 extra ms for safety */ );
+		msleep(15 /*1 extra ms for safety */ );

 		/* 7 */
-		DELAY_MS(1);
+		msleep(1);

 		/* 8 */

diff -Naur linux-2.6.12-rc1-mm1/drivers/net/chelsio/regs.h linux-2.6.12-rc1-mm1.patched/drivers/net/chelsio/regs.h
--- linux-2.6.12-rc1-mm1/drivers/net/chelsio/regs.h	2005-03-22 13:05:45.000000000 -0800
+++ linux-2.6.12-rc1-mm1.patched/drivers/net/chelsio/regs.h	2005-03-22 23:56:44.000000000 -0800
@@ -1,33 +1,40 @@
-/*******************************************************************************
- *                                                                             *
- * File: regs.h                                                                *
- * Revision: 1.2                                                               *
- * Date: 2005/03/10 07:07:38                                                   *
- * Description:                                                                *
- *  part of the Chelsio 10Gb Ethernet Driver.                                  *
- *                                                                             *
- * This program is free software; you can redistribute it and/or modify        *
- * it under the terms of the GNU General Public License, version 2, as         *
- * published by the Free Software Foundation.                                  *
- *                                                                             *
- * You should have received a copy of the GNU General Public License along     *
- * with this program; if not, write to the Free Software Foundation, Inc.,     *
- * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.                   *
- *                                                                             *
- * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR IMPLIED      *
- * WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF        *
- * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.                       *
- *                                                                             *
- * http://www.chelsio.com                                                      *
- *                                                                             *
- * Copyright (c) 2003 - 2005 Chelsio Communications, Inc.                      *
- * All rights reserved.                                                        *
- *                                                                             *
- * Maintainers: maintainers@chelsio.com                                        *
- *                                                                             *
- * History:                                                                    *
- *                                                                             *
- ******************************************************************************/
+/*****************************************************************************
+ *                                                                           *
+ * File: regs.h                                                              *
+ * $Revision: 1.4 $                                                          *
+ * $Date: 2005/03/23 07:15:59 $                                              *
+ * Description:                                                              *
+ *  part of the Chelsio 10Gb Ethernet Driver.                                *
+ *                                                                           *
+ * This program is free software; you can redistribute it and/or modify      *
+ * it under the terms of the GNU General Public License, version 2, as       *
+ * published by the Free Software Foundation.                                *
+ *                                                                           *
+ * You should have received a copy of the GNU General Public License along   *
+ * with this program; if not, write to the Free Software Foundation, Inc.,   *
+ * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.                 *
+ *                                                                           *
+ * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR IMPLIED    *
+ * WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF      *
+ * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.                     *
+ *                                                                           *
+ * http://www.chelsio.com                                                    *
+ *                                                                           *
+ * Copyright (c) 2003 - 2005 Chelsio Communications, Inc.                    *
+ * All rights reserved.                                                      *
+ *                                                                           *
+ * Maintainers: maintainers@chelsio.com                                      *
+ *                                                                           *
+ * Authors: Dimitrios Michailidis   <dm@chelsio.com>                         *
+ *          Tina Yang               <tainay@chelsio.com>                     *
+ *          Felix Marti             <felix@chelsio.com>                      *
+ *          Scott Bardone           <sbardone@chelsio.com>                   *
+ *          Kurt Ottaway            <kottaway@chelsio.com>                   *
+ *          Frank DiMambro          <frank@chelsio.com>                      *
+ *                                                                           *
+ * History:                                                                  *
+ *                                                                           *
+ ****************************************************************************/

 /* Do not edit this file */

@@ -63,38 +70,20 @@
 #define V_CMDQ_PRIORITY(x) ((x) << S_CMDQ_PRIORITY)
 #define G_CMDQ_PRIORITY(x) (((x) >> S_CMDQ_PRIORITY) & M_CMDQ_PRIORITY)

-#define S_DISABLE_CMDQ0_GTS    8
-#define V_DISABLE_CMDQ0_GTS(x) ((x) << S_DISABLE_CMDQ0_GTS)
-#define F_DISABLE_CMDQ0_GTS    V_DISABLE_CMDQ0_GTS(1U)
-
 #define S_DISABLE_CMDQ1_GTS    9
 #define V_DISABLE_CMDQ1_GTS(x) ((x) << S_DISABLE_CMDQ1_GTS)
 #define F_DISABLE_CMDQ1_GTS    V_DISABLE_CMDQ1_GTS(1U)

-#define S_DISABLE_FL0_GTS    10
-#define V_DISABLE_FL0_GTS(x) ((x) << S_DISABLE_FL0_GTS)
-#define F_DISABLE_FL0_GTS    V_DISABLE_FL0_GTS(1U)
-
-#define S_DISABLE_FL1_GTS    11
-#define V_DISABLE_FL1_GTS(x) ((x) << S_DISABLE_FL1_GTS)
-#define F_DISABLE_FL1_GTS    V_DISABLE_FL1_GTS(1U)
-
 #define S_ENABLE_BIG_ENDIAN    12
 #define V_ENABLE_BIG_ENDIAN(x) ((x) << S_ENABLE_BIG_ENDIAN)
 #define F_ENABLE_BIG_ENDIAN    V_ENABLE_BIG_ENDIAN(1U)

-#define S_FL_SELECTION_CRITERIA    13
-#define V_FL_SELECTION_CRITERIA(x) ((x) << S_FL_SELECTION_CRITERIA)
-#define F_FL_SELECTION_CRITERIA    V_FL_SELECTION_CRITERIA(1U)
-
 #define S_ISCSI_COALESCE    14
 #define V_ISCSI_COALESCE(x) ((x) << S_ISCSI_COALESCE)
 #define F_ISCSI_COALESCE    V_ISCSI_COALESCE(1U)

 #define S_RX_PKT_OFFSET    15
-#define M_RX_PKT_OFFSET    0x7
 #define V_RX_PKT_OFFSET(x) ((x) << S_RX_PKT_OFFSET)
-#define G_RX_PKT_OFFSET(x) (((x) >> S_RX_PKT_OFFSET) & M_RX_PKT_OFFSET)

 #define S_VLAN_XTRACT    18
 #define V_VLAN_XTRACT(x) ((x) << S_VLAN_XTRACT)
@@ -110,114 +99,16 @@
 #define A_SG_FL1BASELWR 0x20
 #define A_SG_FL1BASEUPR 0x24
 #define A_SG_CMD0SIZE 0x28
-
-#define S_CMDQ0_SIZE    0
-#define M_CMDQ0_SIZE    0x1ffff
-#define V_CMDQ0_SIZE(x) ((x) << S_CMDQ0_SIZE)
-#define G_CMDQ0_SIZE(x) (((x) >> S_CMDQ0_SIZE) & M_CMDQ0_SIZE)
-
 #define A_SG_FL0SIZE 0x2c
-
-#define S_FL0_SIZE    0
-#define M_FL0_SIZE    0x1ffff
-#define V_FL0_SIZE(x) ((x) << S_FL0_SIZE)
-#define G_FL0_SIZE(x) (((x) >> S_FL0_SIZE) & M_FL0_SIZE)
-
 #define A_SG_RSPSIZE 0x30
-
-#define S_RESPQ_SIZE    0
-#define M_RESPQ_SIZE    0x1ffff
-#define V_RESPQ_SIZE(x) ((x) << S_RESPQ_SIZE)
-#define G_RESPQ_SIZE(x) (((x) >> S_RESPQ_SIZE) & M_RESPQ_SIZE)
-
 #define A_SG_RSPBASELWR 0x34
 #define A_SG_RSPBASEUPR 0x38
 #define A_SG_FLTHRESHOLD 0x3c
-
-#define S_FL_THRESHOLD    0
-#define M_FL_THRESHOLD    0xffff
-#define V_FL_THRESHOLD(x) ((x) << S_FL_THRESHOLD)
-#define G_FL_THRESHOLD(x) (((x) >> S_FL_THRESHOLD) & M_FL_THRESHOLD)
-
 #define A_SG_RSPQUEUECREDIT 0x40
-
-#define S_RESPQ_CREDIT    0
-#define M_RESPQ_CREDIT    0x1ffff
-#define V_RESPQ_CREDIT(x) ((x) << S_RESPQ_CREDIT)
-#define G_RESPQ_CREDIT(x) (((x) >> S_RESPQ_CREDIT) & M_RESPQ_CREDIT)
-
 #define A_SG_SLEEPING 0x48
-
-#define S_SLEEPING    0
-#define M_SLEEPING    0xffff
-#define V_SLEEPING(x) ((x) << S_SLEEPING)
-#define G_SLEEPING(x) (((x) >> S_SLEEPING) & M_SLEEPING)
-
 #define A_SG_INTRTIMER 0x4c
-
-#define S_INTERRUPT_TIMER_COUNT    0
-#define M_INTERRUPT_TIMER_COUNT    0xffffff
-#define V_INTERRUPT_TIMER_COUNT(x) ((x) << S_INTERRUPT_TIMER_COUNT)
-#define G_INTERRUPT_TIMER_COUNT(x) (((x) >> S_INTERRUPT_TIMER_COUNT) & M_INTERRUPT_TIMER_COUNT)
-
-#define A_SG_CMD0PTR 0x50
-
-#define S_CMDQ0_POINTER    0
-#define M_CMDQ0_POINTER    0xffff
-#define V_CMDQ0_POINTER(x) ((x) << S_CMDQ0_POINTER)
-#define G_CMDQ0_POINTER(x) (((x) >> S_CMDQ0_POINTER) & M_CMDQ0_POINTER)
-
-#define S_CURRENT_GENERATION_BIT    16
-#define V_CURRENT_GENERATION_BIT(x) ((x) << S_CURRENT_GENERATION_BIT)
-#define F_CURRENT_GENERATION_BIT    V_CURRENT_GENERATION_BIT(1U)
-
-#define A_SG_CMD1PTR 0x54
-
-#define S_CMDQ1_POINTER    0
-#define M_CMDQ1_POINTER    0xffff
-#define V_CMDQ1_POINTER(x) ((x) << S_CMDQ1_POINTER)
-#define G_CMDQ1_POINTER(x) (((x) >> S_CMDQ1_POINTER) & M_CMDQ1_POINTER)
-
-#define A_SG_FL0PTR 0x58
-
-#define S_FL0_POINTER    0
-#define M_FL0_POINTER    0xffff
-#define V_FL0_POINTER(x) ((x) << S_FL0_POINTER)
-#define G_FL0_POINTER(x) (((x) >> S_FL0_POINTER) & M_FL0_POINTER)
-
-#define A_SG_FL1PTR 0x5c
-
-#define S_FL1_POINTER    0
-#define M_FL1_POINTER    0xffff
-#define V_FL1_POINTER(x) ((x) << S_FL1_POINTER)
-#define G_FL1_POINTER(x) (((x) >> S_FL1_POINTER) & M_FL1_POINTER)
-
-#define A_SG_VERSION 0x6c
-
-#define S_DAY    0
-#define M_DAY    0x1f
-#define V_DAY(x) ((x) << S_DAY)
-#define G_DAY(x) (((x) >> S_DAY) & M_DAY)
-
-#define S_MONTH    5
-#define M_MONTH    0xf
-#define V_MONTH(x) ((x) << S_MONTH)
-#define G_MONTH(x) (((x) >> S_MONTH) & M_MONTH)
-
 #define A_SG_CMD1SIZE 0xb0
-
-#define S_CMDQ1_SIZE    0
-#define M_CMDQ1_SIZE    0x1ffff
-#define V_CMDQ1_SIZE(x) ((x) << S_CMDQ1_SIZE)
-#define G_CMDQ1_SIZE(x) (((x) >> S_CMDQ1_SIZE) & M_CMDQ1_SIZE)
-
 #define A_SG_FL1SIZE 0xb4
-
-#define S_FL1_SIZE    0
-#define M_FL1_SIZE    0x1ffff
-#define V_FL1_SIZE(x) ((x) << S_FL1_SIZE)
-#define G_FL1_SIZE(x) (((x) >> S_FL1_SIZE) & M_FL1_SIZE)
-
 #define A_SG_INT_ENABLE 0xb8

 #define S_RESPQ_EXHAUSTED    0
@@ -241,372 +132,23 @@
 #define F_PACKET_MISMATCH    V_PACKET_MISMATCH(1U)

 #define A_SG_INT_CAUSE 0xbc
-#define A_SG_RESPACCUTIMER 0xc0

 /* MC3 registers */
-#define A_MC3_CFG 0x100
-
-#define S_CLK_ENABLE    0
-#define V_CLK_ENABLE(x) ((x) << S_CLK_ENABLE)
-#define F_CLK_ENABLE    V_CLK_ENABLE(1U)

 #define S_READY    1
 #define V_READY(x) ((x) << S_READY)
 #define F_READY    V_READY(1U)

-#define S_READ_TO_WRITE_DELAY    2
-#define M_READ_TO_WRITE_DELAY    0x7
-#define V_READ_TO_WRITE_DELAY(x) ((x) << S_READ_TO_WRITE_DELAY)
-#define G_READ_TO_WRITE_DELAY(x) (((x) >> S_READ_TO_WRITE_DELAY) & M_READ_TO_WRITE_DELAY)
-
-#define S_WRITE_TO_READ_DELAY    5
-#define M_WRITE_TO_READ_DELAY    0x7
-#define V_WRITE_TO_READ_DELAY(x) ((x) << S_WRITE_TO_READ_DELAY)
-#define G_WRITE_TO_READ_DELAY(x) (((x) >> S_WRITE_TO_READ_DELAY) & M_WRITE_TO_READ_DELAY)
-
-#define S_MC3_BANK_CYCLE    8
-#define M_MC3_BANK_CYCLE    0xf
-#define V_MC3_BANK_CYCLE(x) ((x) << S_MC3_BANK_CYCLE)
-#define G_MC3_BANK_CYCLE(x) (((x) >> S_MC3_BANK_CYCLE) & M_MC3_BANK_CYCLE)
-
-#define S_REFRESH_CYCLE    12
-#define M_REFRESH_CYCLE    0xf
-#define V_REFRESH_CYCLE(x) ((x) << S_REFRESH_CYCLE)
-#define G_REFRESH_CYCLE(x) (((x) >> S_REFRESH_CYCLE) & M_REFRESH_CYCLE)
-
-#define S_PRECHARGE_CYCLE    16
-#define M_PRECHARGE_CYCLE    0x3
-#define V_PRECHARGE_CYCLE(x) ((x) << S_PRECHARGE_CYCLE)
-#define G_PRECHARGE_CYCLE(x) (((x) >> S_PRECHARGE_CYCLE) & M_PRECHARGE_CYCLE)
-
-#define S_ACTIVE_TO_READ_WRITE_DELAY    18
-#define V_ACTIVE_TO_READ_WRITE_DELAY(x) ((x) << S_ACTIVE_TO_READ_WRITE_DELAY)
-#define F_ACTIVE_TO_READ_WRITE_DELAY    V_ACTIVE_TO_READ_WRITE_DELAY(1U)
-
-#define S_ACTIVE_TO_PRECHARGE_DELAY    19
-#define M_ACTIVE_TO_PRECHARGE_DELAY    0x7
-#define V_ACTIVE_TO_PRECHARGE_DELAY(x) ((x) << S_ACTIVE_TO_PRECHARGE_DELAY)
-#define G_ACTIVE_TO_PRECHARGE_DELAY(x) (((x) >> S_ACTIVE_TO_PRECHARGE_DELAY) & M_ACTIVE_TO_PRECHARGE_DELAY)
-
-#define S_WRITE_RECOVERY_DELAY    22
-#define M_WRITE_RECOVERY_DELAY    0x3
-#define V_WRITE_RECOVERY_DELAY(x) ((x) << S_WRITE_RECOVERY_DELAY)
-#define G_WRITE_RECOVERY_DELAY(x) (((x) >> S_WRITE_RECOVERY_DELAY) & M_WRITE_RECOVERY_DELAY)
-
-#define S_DENSITY    24
-#define M_DENSITY    0x3
-#define V_DENSITY(x) ((x) << S_DENSITY)
-#define G_DENSITY(x) (((x) >> S_DENSITY) & M_DENSITY)
-
-#define S_ORGANIZATION    26
-#define V_ORGANIZATION(x) ((x) << S_ORGANIZATION)
-#define F_ORGANIZATION    V_ORGANIZATION(1U)
-
-#define S_BANKS    27
-#define V_BANKS(x) ((x) << S_BANKS)
-#define F_BANKS    V_BANKS(1U)
-
-#define S_UNREGISTERED    28
-#define V_UNREGISTERED(x) ((x) << S_UNREGISTERED)
-#define F_UNREGISTERED    V_UNREGISTERED(1U)
-
-#define S_MC3_WIDTH    29
-#define M_MC3_WIDTH    0x3
-#define V_MC3_WIDTH(x) ((x) << S_MC3_WIDTH)
-#define G_MC3_WIDTH(x) (((x) >> S_MC3_WIDTH) & M_MC3_WIDTH)
-
-#define S_MC3_SLOW    31
-#define V_MC3_SLOW(x) ((x) << S_MC3_SLOW)
-#define F_MC3_SLOW    V_MC3_SLOW(1U)
-
-#define A_MC3_MODE 0x104
-
-#define S_MC3_MODE    0
-#define M_MC3_MODE    0x3fff
-#define V_MC3_MODE(x) ((x) << S_MC3_MODE)
-#define G_MC3_MODE(x) (((x) >> S_MC3_MODE) & M_MC3_MODE)
-
-#define S_BUSY    31
-#define V_BUSY(x) ((x) << S_BUSY)
-#define F_BUSY    V_BUSY(1U)
-
-#define A_MC3_EXT_MODE 0x108
-
-#define S_MC3_EXTENDED_MODE    0
-#define M_MC3_EXTENDED_MODE    0x3fff
-#define V_MC3_EXTENDED_MODE(x) ((x) << S_MC3_EXTENDED_MODE)
-#define G_MC3_EXTENDED_MODE(x) (((x) >> S_MC3_EXTENDED_MODE) & M_MC3_EXTENDED_MODE)
-
-#define A_MC3_PRECHARG 0x10c
-#define A_MC3_REFRESH 0x110
-
-#define S_REFRESH_ENABLE    0
-#define V_REFRESH_ENABLE(x) ((x) << S_REFRESH_ENABLE)
-#define F_REFRESH_ENABLE    V_REFRESH_ENABLE(1U)
-
-#define S_REFRESH_DIVISOR    1
-#define M_REFRESH_DIVISOR    0x3fff
-#define V_REFRESH_DIVISOR(x) ((x) << S_REFRESH_DIVISOR)
-#define G_REFRESH_DIVISOR(x) (((x) >> S_REFRESH_DIVISOR) & M_REFRESH_DIVISOR)
-
-#define A_MC3_STROBE 0x114
-
-#define S_MASTER_DLL_RESET    0
-#define V_MASTER_DLL_RESET(x) ((x) << S_MASTER_DLL_RESET)
-#define F_MASTER_DLL_RESET    V_MASTER_DLL_RESET(1U)
-
-#define S_MASTER_DLL_TAP_COUNT    1
-#define M_MASTER_DLL_TAP_COUNT    0xff
-#define V_MASTER_DLL_TAP_COUNT(x) ((x) << S_MASTER_DLL_TAP_COUNT)
-#define G_MASTER_DLL_TAP_COUNT(x) (((x) >> S_MASTER_DLL_TAP_COUNT) & M_MASTER_DLL_TAP_COUNT)
-
-#define S_MASTER_DLL_LOCKED    9
-#define V_MASTER_DLL_LOCKED(x) ((x) << S_MASTER_DLL_LOCKED)
-#define F_MASTER_DLL_LOCKED    V_MASTER_DLL_LOCKED(1U)
-
-#define S_MASTER_DLL_MAX_TAP_COUNT    10
-#define V_MASTER_DLL_MAX_TAP_COUNT(x) ((x) << S_MASTER_DLL_MAX_TAP_COUNT)
-#define F_MASTER_DLL_MAX_TAP_COUNT    V_MASTER_DLL_MAX_TAP_COUNT(1U)
-
-#define S_MASTER_DLL_TAP_COUNT_OFFSET    11
-#define M_MASTER_DLL_TAP_COUNT_OFFSET    0x3f
-#define V_MASTER_DLL_TAP_COUNT_OFFSET(x) ((x) << S_MASTER_DLL_TAP_COUNT_OFFSET)
-#define G_MASTER_DLL_TAP_COUNT_OFFSET(x) (((x) >> S_MASTER_DLL_TAP_COUNT_OFFSET) & M_MASTER_DLL_TAP_COUNT_OFFSET)
-
-#define S_SLAVE_DLL_RESET    11
-#define V_SLAVE_DLL_RESET(x) ((x) << S_SLAVE_DLL_RESET)
-#define F_SLAVE_DLL_RESET    V_SLAVE_DLL_RESET(1U)
-
-#define S_SLAVE_DLL_DELTA    12
-#define M_SLAVE_DLL_DELTA    0xf
-#define V_SLAVE_DLL_DELTA(x) ((x) << S_SLAVE_DLL_DELTA)
-#define G_SLAVE_DLL_DELTA(x) (((x) >> S_SLAVE_DLL_DELTA) & M_SLAVE_DLL_DELTA)
-
-#define S_SLAVE_DELAY_LINE_MANUAL_TAP_COUNT    17
-#define M_SLAVE_DELAY_LINE_MANUAL_TAP_COUNT    0x3f
-#define V_SLAVE_DELAY_LINE_MANUAL_TAP_COUNT(x) ((x) << S_SLAVE_DELAY_LINE_MANUAL_TAP_COUNT)
-#define G_SLAVE_DELAY_LINE_MANUAL_TAP_COUNT(x) (((x) >> S_SLAVE_DELAY_LINE_MANUAL_TAP_COUNT) & M_SLAVE_DELAY_LINE_MANUAL_TAP_COUNT)
-
-#define S_SLAVE_DELAY_LINE_MANUAL_TAP_COUNT_ENABLE    23
-#define V_SLAVE_DELAY_LINE_MANUAL_TAP_COUNT_ENABLE(x) ((x) << S_SLAVE_DELAY_LINE_MANUAL_TAP_COUNT_ENABLE)
-#define F_SLAVE_DELAY_LINE_MANUAL_TAP_COUNT_ENABLE    V_SLAVE_DELAY_LINE_MANUAL_TAP_COUNT_ENABLE(1U)
-
-#define S_SLAVE_DELAY_LINE_TAP_COUNT    24
-#define M_SLAVE_DELAY_LINE_TAP_COUNT    0x3f
-#define V_SLAVE_DELAY_LINE_TAP_COUNT(x) ((x) << S_SLAVE_DELAY_LINE_TAP_COUNT)
-#define G_SLAVE_DELAY_LINE_TAP_COUNT(x) (((x) >> S_SLAVE_DELAY_LINE_TAP_COUNT) & M_SLAVE_DELAY_LINE_TAP_COUNT)
-
-#define A_MC3_ECC_CNTL 0x118
-
-#define S_ECC_GENERATION_ENABLE    0
-#define V_ECC_GENERATION_ENABLE(x) ((x) << S_ECC_GENERATION_ENABLE)
-#define F_ECC_GENERATION_ENABLE    V_ECC_GENERATION_ENABLE(1U)
-
-#define S_ECC_CHECK_ENABLE    1
-#define V_ECC_CHECK_ENABLE(x) ((x) << S_ECC_CHECK_ENABLE)
-#define F_ECC_CHECK_ENABLE    V_ECC_CHECK_ENABLE(1U)
-
-#define S_CORRECTABLE_ERROR_COUNT    2
-#define M_CORRECTABLE_ERROR_COUNT    0xff
-#define V_CORRECTABLE_ERROR_COUNT(x) ((x) << S_CORRECTABLE_ERROR_COUNT)
-#define G_CORRECTABLE_ERROR_COUNT(x) (((x) >> S_CORRECTABLE_ERROR_COUNT) & M_CORRECTABLE_ERROR_COUNT)
-
-#define S_UNCORRECTABLE_ERROR_COUNT    10
-#define M_UNCORRECTABLE_ERROR_COUNT    0xff
-#define V_UNCORRECTABLE_ERROR_COUNT(x) ((x) << S_UNCORRECTABLE_ERROR_COUNT)
-#define G_UNCORRECTABLE_ERROR_COUNT(x) (((x) >> S_UNCORRECTABLE_ERROR_COUNT) & M_UNCORRECTABLE_ERROR_COUNT)
-
-#define A_MC3_CE_ADDR 0x11c
-
-#define S_MC3_CE_ADDR    4
-#define M_MC3_CE_ADDR    0xfffffff
-#define V_MC3_CE_ADDR(x) ((x) << S_MC3_CE_ADDR)
-#define G_MC3_CE_ADDR(x) (((x) >> S_MC3_CE_ADDR) & M_MC3_CE_ADDR)
-
-#define A_MC3_CE_DATA0 0x120
-#define A_MC3_CE_DATA1 0x124
-#define A_MC3_CE_DATA2 0x128
-#define A_MC3_CE_DATA3 0x12c
-#define A_MC3_CE_DATA4 0x130
-#define A_MC3_UE_ADDR 0x134
-
-#define S_MC3_UE_ADDR    4
-#define M_MC3_UE_ADDR    0xfffffff
-#define V_MC3_UE_ADDR(x) ((x) << S_MC3_UE_ADDR)
-#define G_MC3_UE_ADDR(x) (((x) >> S_MC3_UE_ADDR) & M_MC3_UE_ADDR)
-
-#define A_MC3_UE_DATA0 0x138
-#define A_MC3_UE_DATA1 0x13c
-#define A_MC3_UE_DATA2 0x140
-#define A_MC3_UE_DATA3 0x144
-#define A_MC3_UE_DATA4 0x148
-#define A_MC3_BD_ADDR 0x14c
-#define A_MC3_BD_DATA0 0x150
-#define A_MC3_BD_DATA1 0x154
-#define A_MC3_BD_DATA2 0x158
-#define A_MC3_BD_DATA3 0x15c
-#define A_MC3_BD_DATA4 0x160
-#define A_MC3_BD_OP 0x164
-
-#define S_BACK_DOOR_OPERATION    0
-#define V_BACK_DOOR_OPERATION(x) ((x) << S_BACK_DOOR_OPERATION)
-#define F_BACK_DOOR_OPERATION    V_BACK_DOOR_OPERATION(1U)
-
-#define A_MC3_BIST_ADDR_BEG 0x168
-#define A_MC3_BIST_ADDR_END 0x16c
-#define A_MC3_BIST_DATA 0x170
-#define A_MC3_BIST_OP 0x174
-
-#define S_OP    0
-#define V_OP(x) ((x) << S_OP)
-#define F_OP    V_OP(1U)
-
-#define S_DATA_PATTERN    1
-#define M_DATA_PATTERN    0x3
-#define V_DATA_PATTERN(x) ((x) << S_DATA_PATTERN)
-#define G_DATA_PATTERN(x) (((x) >> S_DATA_PATTERN) & M_DATA_PATTERN)
-
-#define S_CONTINUOUS    3
-#define V_CONTINUOUS(x) ((x) << S_CONTINUOUS)
-#define F_CONTINUOUS    V_CONTINUOUS(1U)
-
-#define A_MC3_INT_ENABLE 0x178
-
-#define S_MC3_CORR_ERR    0
-#define V_MC3_CORR_ERR(x) ((x) << S_MC3_CORR_ERR)
-#define F_MC3_CORR_ERR    V_MC3_CORR_ERR(1U)
-
-#define S_MC3_UNCORR_ERR    1
-#define V_MC3_UNCORR_ERR(x) ((x) << S_MC3_UNCORR_ERR)
-#define F_MC3_UNCORR_ERR    V_MC3_UNCORR_ERR(1U)
-
-#define S_MC3_PARITY_ERR    2
-#define M_MC3_PARITY_ERR    0xff
-#define V_MC3_PARITY_ERR(x) ((x) << S_MC3_PARITY_ERR)
-#define G_MC3_PARITY_ERR(x) (((x) >> S_MC3_PARITY_ERR) & M_MC3_PARITY_ERR)
-
-#define S_MC3_ADDR_ERR    10
-#define V_MC3_ADDR_ERR(x) ((x) << S_MC3_ADDR_ERR)
-#define F_MC3_ADDR_ERR    V_MC3_ADDR_ERR(1U)
-
-#define A_MC3_INT_CAUSE 0x17c
-
 /* MC4 registers */
-#define A_MC4_CFG 0x180
-
-#define S_POWER_UP    0
-#define V_POWER_UP(x) ((x) << S_POWER_UP)
-#define F_POWER_UP    V_POWER_UP(1U)
-
-#define S_MC4_BANK_CYCLE    8
-#define M_MC4_BANK_CYCLE    0x7
-#define V_MC4_BANK_CYCLE(x) ((x) << S_MC4_BANK_CYCLE)
-#define G_MC4_BANK_CYCLE(x) (((x) >> S_MC4_BANK_CYCLE) & M_MC4_BANK_CYCLE)
-
-#define S_MC4_NARROW    24
-#define V_MC4_NARROW(x) ((x) << S_MC4_NARROW)
-#define F_MC4_NARROW    V_MC4_NARROW(1U)

+#define A_MC4_CFG 0x180
 #define S_MC4_SLOW    25
 #define V_MC4_SLOW(x) ((x) << S_MC4_SLOW)
 #define F_MC4_SLOW    V_MC4_SLOW(1U)

-#define S_MC4A_WIDTH    24
-#define M_MC4A_WIDTH    0x3
-#define V_MC4A_WIDTH(x) ((x) << S_MC4A_WIDTH)
-#define G_MC4A_WIDTH(x) (((x) >> S_MC4A_WIDTH) & M_MC4A_WIDTH)
-
-#define S_MC4A_SLOW    26
-#define V_MC4A_SLOW(x) ((x) << S_MC4A_SLOW)
-#define F_MC4A_SLOW    V_MC4A_SLOW(1U)
-
-#define A_MC4_MODE 0x184
-
-#define S_MC4_MODE    0
-#define M_MC4_MODE    0x7fff
-#define V_MC4_MODE(x) ((x) << S_MC4_MODE)
-#define G_MC4_MODE(x) (((x) >> S_MC4_MODE) & M_MC4_MODE)
-
-#define A_MC4_EXT_MODE 0x188
-
-#define S_MC4_EXTENDED_MODE    0
-#define M_MC4_EXTENDED_MODE    0x7fff
-#define V_MC4_EXTENDED_MODE(x) ((x) << S_MC4_EXTENDED_MODE)
-#define G_MC4_EXTENDED_MODE(x) (((x) >> S_MC4_EXTENDED_MODE) & M_MC4_EXTENDED_MODE)
-
-#define A_MC4_REFRESH 0x190
-#define A_MC4_STROBE 0x194
-#define A_MC4_ECC_CNTL 0x198
-#define A_MC4_CE_ADDR 0x19c
-
-#define S_MC4_CE_ADDR    4
-#define M_MC4_CE_ADDR    0xffffff
-#define V_MC4_CE_ADDR(x) ((x) << S_MC4_CE_ADDR)
-#define G_MC4_CE_ADDR(x) (((x) >> S_MC4_CE_ADDR) & M_MC4_CE_ADDR)
-
-#define A_MC4_CE_DATA0 0x1a0
-#define A_MC4_CE_DATA1 0x1a4
-#define A_MC4_CE_DATA2 0x1a8
-#define A_MC4_CE_DATA3 0x1ac
-#define A_MC4_CE_DATA4 0x1b0
-#define A_MC4_UE_ADDR 0x1b4
-
-#define S_MC4_UE_ADDR    4
-#define M_MC4_UE_ADDR    0xffffff
-#define V_MC4_UE_ADDR(x) ((x) << S_MC4_UE_ADDR)
-#define G_MC4_UE_ADDR(x) (((x) >> S_MC4_UE_ADDR) & M_MC4_UE_ADDR)
-
-#define A_MC4_UE_DATA0 0x1b8
-#define A_MC4_UE_DATA1 0x1bc
-#define A_MC4_UE_DATA2 0x1c0
-#define A_MC4_UE_DATA3 0x1c4
-#define A_MC4_UE_DATA4 0x1c8
-#define A_MC4_BD_ADDR 0x1cc
-
-#define S_MC4_BACK_DOOR_ADDR    0
-#define M_MC4_BACK_DOOR_ADDR    0xfffffff
-#define V_MC4_BACK_DOOR_ADDR(x) ((x) << S_MC4_BACK_DOOR_ADDR)
-#define G_MC4_BACK_DOOR_ADDR(x) (((x) >> S_MC4_BACK_DOOR_ADDR) & M_MC4_BACK_DOOR_ADDR)
-
-#define A_MC4_BD_DATA0 0x1d0
-#define A_MC4_BD_DATA1 0x1d4
-#define A_MC4_BD_DATA2 0x1d8
-#define A_MC4_BD_DATA3 0x1dc
-#define A_MC4_BD_DATA4 0x1e0
-#define A_MC4_BD_OP 0x1e4
-
-#define S_OPERATION    0
-#define V_OPERATION(x) ((x) << S_OPERATION)
-#define F_OPERATION    V_OPERATION(1U)
-
-#define A_MC4_BIST_ADDR_BEG 0x1e8
-#define A_MC4_BIST_ADDR_END 0x1ec
-#define A_MC4_BIST_DATA 0x1f0
-#define A_MC4_BIST_OP 0x1f4
-#define A_MC4_INT_ENABLE 0x1f8
-
-#define S_MC4_CORR_ERR    0
-#define V_MC4_CORR_ERR(x) ((x) << S_MC4_CORR_ERR)
-#define F_MC4_CORR_ERR    V_MC4_CORR_ERR(1U)
-
-#define S_MC4_UNCORR_ERR    1
-#define V_MC4_UNCORR_ERR(x) ((x) << S_MC4_UNCORR_ERR)
-#define F_MC4_UNCORR_ERR    V_MC4_UNCORR_ERR(1U)
-
-#define S_MC4_ADDR_ERR    2
-#define V_MC4_ADDR_ERR(x) ((x) << S_MC4_ADDR_ERR)
-#define F_MC4_ADDR_ERR    V_MC4_ADDR_ERR(1U)
-
-#define A_MC4_INT_CAUSE 0x1fc
-
 /* TPI registers */
-#define A_TPI_ADDR 0x280
-
-#define S_TPI_ADDRESS    0
-#define M_TPI_ADDRESS    0xffffff
-#define V_TPI_ADDRESS(x) ((x) << S_TPI_ADDRESS)
-#define G_TPI_ADDRESS(x) (((x) >> S_TPI_ADDRESS) & M_TPI_ADDRESS)

+#define A_TPI_ADDR 0x280
 #define A_TPI_WR_DATA 0x284
 #define A_TPI_RD_DATA 0x288
 #define A_TPI_CSR 0x28c
@@ -619,10 +161,6 @@
 #define V_TPIRDY(x) ((x) << S_TPIRDY)
 #define F_TPIRDY    V_TPIRDY(1U)

-#define S_INT_DIR    31
-#define V_INT_DIR(x) ((x) << S_INT_DIR)
-#define F_INT_DIR    V_INT_DIR(1U)
-
 #define A_TPI_PAR 0x29c

 #define S_TPIPAR    0
@@ -630,26 +168,14 @@
 #define V_TPIPAR(x) ((x) << S_TPIPAR)
 #define G_TPIPAR(x) (((x) >> S_TPIPAR) & M_TPIPAR)

-
 /* TP registers */
-#define A_TP_IN_CONFIG 0x300

-#define S_TP_IN_CSPI_TUNNEL    0
-#define V_TP_IN_CSPI_TUNNEL(x) ((x) << S_TP_IN_CSPI_TUNNEL)
-#define F_TP_IN_CSPI_TUNNEL    V_TP_IN_CSPI_TUNNEL(1U)
-
-#define S_TP_IN_CSPI_ETHERNET    1
-#define V_TP_IN_CSPI_ETHERNET(x) ((x) << S_TP_IN_CSPI_ETHERNET)
-#define F_TP_IN_CSPI_ETHERNET    V_TP_IN_CSPI_ETHERNET(1U)
+#define A_TP_IN_CONFIG 0x300

 #define S_TP_IN_CSPI_CPL    3
 #define V_TP_IN_CSPI_CPL(x) ((x) << S_TP_IN_CSPI_CPL)
 #define F_TP_IN_CSPI_CPL    V_TP_IN_CSPI_CPL(1U)

-#define S_TP_IN_CSPI_POS    4
-#define V_TP_IN_CSPI_POS(x) ((x) << S_TP_IN_CSPI_POS)
-#define F_TP_IN_CSPI_POS    V_TP_IN_CSPI_POS(1U)
-
 #define S_TP_IN_CSPI_CHECK_IP_CSUM    5
 #define V_TP_IN_CSPI_CHECK_IP_CSUM(x) ((x) << S_TP_IN_CSPI_CHECK_IP_CSUM)
 #define F_TP_IN_CSPI_CHECK_IP_CSUM    V_TP_IN_CSPI_CHECK_IP_CSUM(1U)
@@ -658,22 +184,10 @@
 #define V_TP_IN_CSPI_CHECK_TCP_CSUM(x) ((x) << S_TP_IN_CSPI_CHECK_TCP_CSUM)
 #define F_TP_IN_CSPI_CHECK_TCP_CSUM    V_TP_IN_CSPI_CHECK_TCP_CSUM(1U)

-#define S_TP_IN_ESPI_TUNNEL    7
-#define V_TP_IN_ESPI_TUNNEL(x) ((x) << S_TP_IN_ESPI_TUNNEL)
-#define F_TP_IN_ESPI_TUNNEL    V_TP_IN_ESPI_TUNNEL(1U)
-
 #define S_TP_IN_ESPI_ETHERNET    8
 #define V_TP_IN_ESPI_ETHERNET(x) ((x) << S_TP_IN_ESPI_ETHERNET)
 #define F_TP_IN_ESPI_ETHERNET    V_TP_IN_ESPI_ETHERNET(1U)

-#define S_TP_IN_ESPI_CPL    10
-#define V_TP_IN_ESPI_CPL(x) ((x) << S_TP_IN_ESPI_CPL)
-#define F_TP_IN_ESPI_CPL    V_TP_IN_ESPI_CPL(1U)
-
-#define S_TP_IN_ESPI_POS    11
-#define V_TP_IN_ESPI_POS(x) ((x) << S_TP_IN_ESPI_POS)
-#define F_TP_IN_ESPI_POS    V_TP_IN_ESPI_POS(1U)
-
 #define S_TP_IN_ESPI_CHECK_IP_CSUM    12
 #define V_TP_IN_ESPI_CHECK_IP_CSUM(x) ((x) << S_TP_IN_ESPI_CHECK_IP_CSUM)
 #define F_TP_IN_ESPI_CHECK_IP_CSUM    V_TP_IN_ESPI_CHECK_IP_CSUM(1U)
@@ -688,42 +202,14 @@

 #define A_TP_OUT_CONFIG 0x304

-#define S_TP_OUT_C_ETH    0
-#define V_TP_OUT_C_ETH(x) ((x) << S_TP_OUT_C_ETH)
-#define F_TP_OUT_C_ETH    V_TP_OUT_C_ETH(1U)
-
 #define S_TP_OUT_CSPI_CPL    2
 #define V_TP_OUT_CSPI_CPL(x) ((x) << S_TP_OUT_CSPI_CPL)
 #define F_TP_OUT_CSPI_CPL    V_TP_OUT_CSPI_CPL(1U)

-#define S_TP_OUT_CSPI_POS    3
-#define V_TP_OUT_CSPI_POS(x) ((x) << S_TP_OUT_CSPI_POS)
-#define F_TP_OUT_CSPI_POS    V_TP_OUT_CSPI_POS(1U)
-
-#define S_TP_OUT_CSPI_GENERATE_IP_CSUM    4
-#define V_TP_OUT_CSPI_GENERATE_IP_CSUM(x) ((x) << S_TP_OUT_CSPI_GENERATE_IP_CSUM)
-#define F_TP_OUT_CSPI_GENERATE_IP_CSUM    V_TP_OUT_CSPI_GENERATE_IP_CSUM(1U)
-
-#define S_TP_OUT_CSPI_GENERATE_TCP_CSUM    5
-#define V_TP_OUT_CSPI_GENERATE_TCP_CSUM(x) ((x) << S_TP_OUT_CSPI_GENERATE_TCP_CSUM)
-#define F_TP_OUT_CSPI_GENERATE_TCP_CSUM    V_TP_OUT_CSPI_GENERATE_TCP_CSUM(1U)
-
 #define S_TP_OUT_ESPI_ETHERNET    6
 #define V_TP_OUT_ESPI_ETHERNET(x) ((x) << S_TP_OUT_ESPI_ETHERNET)
 #define F_TP_OUT_ESPI_ETHERNET    V_TP_OUT_ESPI_ETHERNET(1U)

-#define S_TP_OUT_ESPI_TAG_ETHERNET    7
-#define V_TP_OUT_ESPI_TAG_ETHERNET(x) ((x) << S_TP_OUT_ESPI_TAG_ETHERNET)
-#define F_TP_OUT_ESPI_TAG_ETHERNET    V_TP_OUT_ESPI_TAG_ETHERNET(1U)
-
-#define S_TP_OUT_ESPI_CPL    8
-#define V_TP_OUT_ESPI_CPL(x) ((x) << S_TP_OUT_ESPI_CPL)
-#define F_TP_OUT_ESPI_CPL    V_TP_OUT_ESPI_CPL(1U)
-
-#define S_TP_OUT_ESPI_POS    9
-#define V_TP_OUT_ESPI_POS(x) ((x) << S_TP_OUT_ESPI_POS)
-#define F_TP_OUT_ESPI_POS    V_TP_OUT_ESPI_POS(1U)
-
 #define S_TP_OUT_ESPI_GENERATE_IP_CSUM    10
 #define V_TP_OUT_ESPI_GENERATE_IP_CSUM(x) ((x) << S_TP_OUT_ESPI_GENERATE_IP_CSUM)
 #define F_TP_OUT_ESPI_GENERATE_IP_CSUM    V_TP_OUT_ESPI_GENERATE_IP_CSUM(1U)
@@ -737,16 +223,6 @@
 #define S_IP_TTL    0
 #define M_IP_TTL    0xff
 #define V_IP_TTL(x) ((x) << S_IP_TTL)
-#define G_IP_TTL(x) (((x) >> S_IP_TTL) & M_IP_TTL)
-
-#define S_TCAM_SERVER_REGION_USAGE    8
-#define M_TCAM_SERVER_REGION_USAGE    0x3
-#define V_TCAM_SERVER_REGION_USAGE(x) ((x) << S_TCAM_SERVER_REGION_USAGE)
-#define G_TCAM_SERVER_REGION_USAGE(x) (((x) >> S_TCAM_SERVER_REGION_USAGE) & M_TCAM_SERVER_REGION_USAGE)
-
-#define S_QOS_MAPPING    10
-#define V_QOS_MAPPING(x) ((x) << S_QOS_MAPPING)
-#define F_QOS_MAPPING    V_QOS_MAPPING(1U)

 #define S_TCP_CSUM    11
 #define V_TCP_CSUM(x) ((x) << S_TCP_CSUM)
@@ -760,476 +236,27 @@
 #define V_IP_CSUM(x) ((x) << S_IP_CSUM)
 #define F_IP_CSUM    V_IP_CSUM(1U)

-#define S_IP_ID_SPLIT    14
-#define V_IP_ID_SPLIT(x) ((x) << S_IP_ID_SPLIT)
-#define F_IP_ID_SPLIT    V_IP_ID_SPLIT(1U)
-
 #define S_PATH_MTU    15
 #define V_PATH_MTU(x) ((x) << S_PATH_MTU)
 #define F_PATH_MTU    V_PATH_MTU(1U)

 #define S_5TUPLE_LOOKUP    17
-#define M_5TUPLE_LOOKUP    0x3
 #define V_5TUPLE_LOOKUP(x) ((x) << S_5TUPLE_LOOKUP)
-#define G_5TUPLE_LOOKUP(x) (((x) >> S_5TUPLE_LOOKUP) & M_5TUPLE_LOOKUP)
-
-#define S_IP_FRAGMENT_DROP    19
-#define V_IP_FRAGMENT_DROP(x) ((x) << S_IP_FRAGMENT_DROP)
-#define F_IP_FRAGMENT_DROP    V_IP_FRAGMENT_DROP(1U)
-
-#define S_PING_DROP    20
-#define V_PING_DROP(x) ((x) << S_PING_DROP)
-#define F_PING_DROP    V_PING_DROP(1U)
-
-#define S_PROTECT_MODE    21
-#define V_PROTECT_MODE(x) ((x) << S_PROTECT_MODE)
-#define F_PROTECT_MODE    V_PROTECT_MODE(1U)
-
-#define S_SYN_COOKIE_ALGORITHM    22
-#define V_SYN_COOKIE_ALGORITHM(x) ((x) << S_SYN_COOKIE_ALGORITHM)
-#define F_SYN_COOKIE_ALGORITHM    V_SYN_COOKIE_ALGORITHM(1U)
-
-#define S_ATTACK_FILTER    23
-#define V_ATTACK_FILTER(x) ((x) << S_ATTACK_FILTER)
-#define F_ATTACK_FILTER    V_ATTACK_FILTER(1U)
-
-#define S_INTERFACE_TYPE    24
-#define V_INTERFACE_TYPE(x) ((x) << S_INTERFACE_TYPE)
-#define F_INTERFACE_TYPE    V_INTERFACE_TYPE(1U)
-
-#define S_DISABLE_RX_FLOW_CONTROL    25
-#define V_DISABLE_RX_FLOW_CONTROL(x) ((x) << S_DISABLE_RX_FLOW_CONTROL)
-#define F_DISABLE_RX_FLOW_CONTROL    V_DISABLE_RX_FLOW_CONTROL(1U)

 #define S_SYN_COOKIE_PARAMETER    26
-#define M_SYN_COOKIE_PARAMETER    0x3f
 #define V_SYN_COOKIE_PARAMETER(x) ((x) << S_SYN_COOKIE_PARAMETER)
-#define G_SYN_COOKIE_PARAMETER(x) (((x) >> S_SYN_COOKIE_PARAMETER) & M_SYN_COOKIE_PARAMETER)
-
-#define A_TP_GLOBAL_RX_CREDITS 0x30c
-#define A_TP_CM_SIZE 0x310
-#define A_TP_CM_MM_BASE 0x314
-
-#define S_CM_MEMMGR_BASE    0
-#define M_CM_MEMMGR_BASE    0xfffffff
-#define V_CM_MEMMGR_BASE(x) ((x) << S_CM_MEMMGR_BASE)
-#define G_CM_MEMMGR_BASE(x) (((x) >> S_CM_MEMMGR_BASE) & M_CM_MEMMGR_BASE)
-
-#define A_TP_CM_TIMER_BASE 0x318
-
-#define S_CM_TIMER_BASE    0
-#define M_CM_TIMER_BASE    0xfffffff
-#define V_CM_TIMER_BASE(x) ((x) << S_CM_TIMER_BASE)
-#define G_CM_TIMER_BASE(x) (((x) >> S_CM_TIMER_BASE) & M_CM_TIMER_BASE)
-
-#define A_TP_PM_SIZE 0x31c
-#define A_TP_PM_TX_BASE 0x320
-#define A_TP_PM_DEFRAG_BASE 0x324
-#define A_TP_PM_RX_BASE 0x328
-#define A_TP_PM_RX_PG_SIZE 0x32c
-#define A_TP_PM_RX_MAX_PGS 0x330
-#define A_TP_PM_TX_PG_SIZE 0x334
-#define A_TP_PM_TX_MAX_PGS 0x338
-#define A_TP_TCP_OPTIONS 0x340
-
-#define S_TIMESTAMP    0
-#define M_TIMESTAMP    0x3
-#define V_TIMESTAMP(x) ((x) << S_TIMESTAMP)
-#define G_TIMESTAMP(x) (((x) >> S_TIMESTAMP) & M_TIMESTAMP)
-
-#define S_WINDOW_SCALE    2
-#define M_WINDOW_SCALE    0x3
-#define V_WINDOW_SCALE(x) ((x) << S_WINDOW_SCALE)
-#define G_WINDOW_SCALE(x) (((x) >> S_WINDOW_SCALE) & M_WINDOW_SCALE)
-
-#define S_SACK    4
-#define M_SACK    0x3
-#define V_SACK(x) ((x) << S_SACK)
-#define G_SACK(x) (((x) >> S_SACK) & M_SACK)
-
-#define S_ECN    6
-#define M_ECN    0x3
-#define V_ECN(x) ((x) << S_ECN)
-#define G_ECN(x) (((x) >> S_ECN) & M_ECN)
-
-#define S_SACK_ALGORITHM    8
-#define M_SACK_ALGORITHM    0x3
-#define V_SACK_ALGORITHM(x) ((x) << S_SACK_ALGORITHM)
-#define G_SACK_ALGORITHM(x) (((x) >> S_SACK_ALGORITHM) & M_SACK_ALGORITHM)
-
-#define S_MSS    10
-#define V_MSS(x) ((x) << S_MSS)
-#define F_MSS    V_MSS(1U)
-
-#define S_DEFAULT_PEER_MSS    16
-#define M_DEFAULT_PEER_MSS    0xffff
-#define V_DEFAULT_PEER_MSS(x) ((x) << S_DEFAULT_PEER_MSS)
-#define G_DEFAULT_PEER_MSS(x) (((x) >> S_DEFAULT_PEER_MSS) & M_DEFAULT_PEER_MSS)
-
-#define A_TP_DACK_CONFIG 0x344
-
-#define S_DACK_MODE    0
-#define V_DACK_MODE(x) ((x) << S_DACK_MODE)
-#define F_DACK_MODE    V_DACK_MODE(1U)
-
-#define S_DACK_AUTO_MGMT    1
-#define V_DACK_AUTO_MGMT(x) ((x) << S_DACK_AUTO_MGMT)
-#define F_DACK_AUTO_MGMT    V_DACK_AUTO_MGMT(1U)
-
-#define S_DACK_AUTO_CAREFUL    2
-#define V_DACK_AUTO_CAREFUL(x) ((x) << S_DACK_AUTO_CAREFUL)
-#define F_DACK_AUTO_CAREFUL    V_DACK_AUTO_CAREFUL(1U)
-
-#define S_DACK_MSS_SELECTOR    3
-#define M_DACK_MSS_SELECTOR    0x3
-#define V_DACK_MSS_SELECTOR(x) ((x) << S_DACK_MSS_SELECTOR)
-#define G_DACK_MSS_SELECTOR(x) (((x) >> S_DACK_MSS_SELECTOR) & M_DACK_MSS_SELECTOR)
-
-#define S_DACK_BYTE_THRESHOLD    5
-#define M_DACK_BYTE_THRESHOLD    0xfffff
-#define V_DACK_BYTE_THRESHOLD(x) ((x) << S_DACK_BYTE_THRESHOLD)
-#define G_DACK_BYTE_THRESHOLD(x) (((x) >> S_DACK_BYTE_THRESHOLD) & M_DACK_BYTE_THRESHOLD)

 #define A_TP_PC_CONFIG 0x348
-
-#define S_TP_ACCESS_LATENCY    0
-#define M_TP_ACCESS_LATENCY    0xf
-#define V_TP_ACCESS_LATENCY(x) ((x) << S_TP_ACCESS_LATENCY)
-#define G_TP_ACCESS_LATENCY(x) (((x) >> S_TP_ACCESS_LATENCY) & M_TP_ACCESS_LATENCY)
-
-#define S_HELD_FIN_DISABLE    4
-#define V_HELD_FIN_DISABLE(x) ((x) << S_HELD_FIN_DISABLE)
-#define F_HELD_FIN_DISABLE    V_HELD_FIN_DISABLE(1U)
-
-#define S_DDP_FC_ENABLE    5
-#define V_DDP_FC_ENABLE(x) ((x) << S_DDP_FC_ENABLE)
-#define F_DDP_FC_ENABLE    V_DDP_FC_ENABLE(1U)
-
-#define S_RDMA_ERR_ENABLE    6
-#define V_RDMA_ERR_ENABLE(x) ((x) << S_RDMA_ERR_ENABLE)
-#define F_RDMA_ERR_ENABLE    V_RDMA_ERR_ENABLE(1U)
-
-#define S_FAST_PDU_DELIVERY    7
-#define V_FAST_PDU_DELIVERY(x) ((x) << S_FAST_PDU_DELIVERY)
-#define F_FAST_PDU_DELIVERY    V_FAST_PDU_DELIVERY(1U)
-
-#define S_CLEAR_FIN    8
-#define V_CLEAR_FIN(x) ((x) << S_CLEAR_FIN)
-#define F_CLEAR_FIN    V_CLEAR_FIN(1U)
-
-#define S_DIS_TX_FILL_WIN_PUSH    12
-#define V_DIS_TX_FILL_WIN_PUSH(x) ((x) << S_DIS_TX_FILL_WIN_PUSH)
-#define F_DIS_TX_FILL_WIN_PUSH    V_DIS_TX_FILL_WIN_PUSH(1U)
-
 #define S_TP_PC_REV    30
 #define M_TP_PC_REV    0x3
-#define V_TP_PC_REV(x) ((x) << S_TP_PC_REV)
 #define G_TP_PC_REV(x) (((x) >> S_TP_PC_REV) & M_TP_PC_REV)
-
-#define A_TP_BACKOFF0 0x350
-
-#define S_ELEMENT0    0
-#define M_ELEMENT0    0xff
-#define V_ELEMENT0(x) ((x) << S_ELEMENT0)
-#define G_ELEMENT0(x) (((x) >> S_ELEMENT0) & M_ELEMENT0)
-
-#define S_ELEMENT1    8
-#define M_ELEMENT1    0xff
-#define V_ELEMENT1(x) ((x) << S_ELEMENT1)
-#define G_ELEMENT1(x) (((x) >> S_ELEMENT1) & M_ELEMENT1)
-
-#define S_ELEMENT2    16
-#define M_ELEMENT2    0xff
-#define V_ELEMENT2(x) ((x) << S_ELEMENT2)
-#define G_ELEMENT2(x) (((x) >> S_ELEMENT2) & M_ELEMENT2)
-
-#define S_ELEMENT3    24
-#define M_ELEMENT3    0xff
-#define V_ELEMENT3(x) ((x) << S_ELEMENT3)
-#define G_ELEMENT3(x) (((x) >> S_ELEMENT3) & M_ELEMENT3)
-
-#define A_TP_BACKOFF1 0x354
-#define A_TP_BACKOFF2 0x358
-#define A_TP_BACKOFF3 0x35c
-#define A_TP_PARA_REG0 0x360
-
-#define S_VAR_MULT    0
-#define M_VAR_MULT    0xf
-#define V_VAR_MULT(x) ((x) << S_VAR_MULT)
-#define G_VAR_MULT(x) (((x) >> S_VAR_MULT) & M_VAR_MULT)
-
-#define S_VAR_GAIN    4
-#define M_VAR_GAIN    0xf
-#define V_VAR_GAIN(x) ((x) << S_VAR_GAIN)
-#define G_VAR_GAIN(x) (((x) >> S_VAR_GAIN) & M_VAR_GAIN)
-
-#define S_SRTT_GAIN    8
-#define M_SRTT_GAIN    0xf
-#define V_SRTT_GAIN(x) ((x) << S_SRTT_GAIN)
-#define G_SRTT_GAIN(x) (((x) >> S_SRTT_GAIN) & M_SRTT_GAIN)
-
-#define S_RTTVAR_INIT    12
-#define M_RTTVAR_INIT    0xf
-#define V_RTTVAR_INIT(x) ((x) << S_RTTVAR_INIT)
-#define G_RTTVAR_INIT(x) (((x) >> S_RTTVAR_INIT) & M_RTTVAR_INIT)
-
-#define S_DUP_THRESH    20
-#define M_DUP_THRESH    0xf
-#define V_DUP_THRESH(x) ((x) << S_DUP_THRESH)
-#define G_DUP_THRESH(x) (((x) >> S_DUP_THRESH) & M_DUP_THRESH)
-
-#define S_INIT_CONG_WIN    24
-#define M_INIT_CONG_WIN    0x7
-#define V_INIT_CONG_WIN(x) ((x) << S_INIT_CONG_WIN)
-#define G_INIT_CONG_WIN(x) (((x) >> S_INIT_CONG_WIN) & M_INIT_CONG_WIN)
-
-#define A_TP_PARA_REG1 0x364
-
-#define S_INITIAL_SLOW_START_THRESHOLD    0
-#define M_INITIAL_SLOW_START_THRESHOLD    0xffff
-#define V_INITIAL_SLOW_START_THRESHOLD(x) ((x) << S_INITIAL_SLOW_START_THRESHOLD)
-#define G_INITIAL_SLOW_START_THRESHOLD(x) (((x) >> S_INITIAL_SLOW_START_THRESHOLD) & M_INITIAL_SLOW_START_THRESHOLD)
-
-#define S_RECEIVE_BUFFER_SIZE    16
-#define M_RECEIVE_BUFFER_SIZE    0xffff
-#define V_RECEIVE_BUFFER_SIZE(x) ((x) << S_RECEIVE_BUFFER_SIZE)
-#define G_RECEIVE_BUFFER_SIZE(x) (((x) >> S_RECEIVE_BUFFER_SIZE) & M_RECEIVE_BUFFER_SIZE)
-
-#define A_TP_PARA_REG2 0x368
-
-#define S_RX_COALESCE_SIZE    0
-#define M_RX_COALESCE_SIZE    0xffff
-#define V_RX_COALESCE_SIZE(x) ((x) << S_RX_COALESCE_SIZE)
-#define G_RX_COALESCE_SIZE(x) (((x) >> S_RX_COALESCE_SIZE) & M_RX_COALESCE_SIZE)
-
-#define S_MAX_RX_SIZE    16
-#define M_MAX_RX_SIZE    0xffff
-#define V_MAX_RX_SIZE(x) ((x) << S_MAX_RX_SIZE)
-#define G_MAX_RX_SIZE(x) (((x) >> S_MAX_RX_SIZE) & M_MAX_RX_SIZE)
-
-#define A_TP_PARA_REG3 0x36c
-
-#define S_RX_COALESCING_PSH_DELIVER    0
-#define V_RX_COALESCING_PSH_DELIVER(x) ((x) << S_RX_COALESCING_PSH_DELIVER)
-#define F_RX_COALESCING_PSH_DELIVER    V_RX_COALESCING_PSH_DELIVER(1U)
-
-#define S_RX_COALESCING_ENABLE    1
-#define V_RX_COALESCING_ENABLE(x) ((x) << S_RX_COALESCING_ENABLE)
-#define F_RX_COALESCING_ENABLE    V_RX_COALESCING_ENABLE(1U)
-
-#define S_TAHOE_ENABLE    2
-#define V_TAHOE_ENABLE(x) ((x) << S_TAHOE_ENABLE)
-#define F_TAHOE_ENABLE    V_TAHOE_ENABLE(1U)
-
-#define S_MAX_REORDER_FRAGMENTS    12
-#define M_MAX_REORDER_FRAGMENTS    0x7
-#define V_MAX_REORDER_FRAGMENTS(x) ((x) << S_MAX_REORDER_FRAGMENTS)
-#define G_MAX_REORDER_FRAGMENTS(x) (((x) >> S_MAX_REORDER_FRAGMENTS) & M_MAX_REORDER_FRAGMENTS)
-
-#define A_TP_TIMER_RESOLUTION 0x390
-
-#define S_DELAYED_ACK_TIMER_RESOLUTION    0
-#define M_DELAYED_ACK_TIMER_RESOLUTION    0x3f
-#define V_DELAYED_ACK_TIMER_RESOLUTION(x) ((x) << S_DELAYED_ACK_TIMER_RESOLUTION)
-#define G_DELAYED_ACK_TIMER_RESOLUTION(x) (((x) >> S_DELAYED_ACK_TIMER_RESOLUTION) & M_DELAYED_ACK_TIMER_RESOLUTION)
-
-#define S_GENERIC_TIMER_RESOLUTION    16
-#define M_GENERIC_TIMER_RESOLUTION    0x3f
-#define V_GENERIC_TIMER_RESOLUTION(x) ((x) << S_GENERIC_TIMER_RESOLUTION)
-#define G_GENERIC_TIMER_RESOLUTION(x) (((x) >> S_GENERIC_TIMER_RESOLUTION) & M_GENERIC_TIMER_RESOLUTION)
-
-#define A_TP_2MSL 0x394
-
-#define S_2MSL    0
-#define M_2MSL    0x3fffffff
-#define V_2MSL(x) ((x) << S_2MSL)
-#define G_2MSL(x) (((x) >> S_2MSL) & M_2MSL)
-
-#define A_TP_RXT_MIN 0x398
-
-#define S_RETRANSMIT_TIMER_MIN    0
-#define M_RETRANSMIT_TIMER_MIN    0xffff
-#define V_RETRANSMIT_TIMER_MIN(x) ((x) << S_RETRANSMIT_TIMER_MIN)
-#define G_RETRANSMIT_TIMER_MIN(x) (((x) >> S_RETRANSMIT_TIMER_MIN) & M_RETRANSMIT_TIMER_MIN)
-
-#define A_TP_RXT_MAX 0x39c
-
-#define S_RETRANSMIT_TIMER_MAX    0
-#define M_RETRANSMIT_TIMER_MAX    0x3fffffff
-#define V_RETRANSMIT_TIMER_MAX(x) ((x) << S_RETRANSMIT_TIMER_MAX)
-#define G_RETRANSMIT_TIMER_MAX(x) (((x) >> S_RETRANSMIT_TIMER_MAX) & M_RETRANSMIT_TIMER_MAX)
-
-#define A_TP_PERS_MIN 0x3a0
-
-#define S_PERSIST_TIMER_MIN    0
-#define M_PERSIST_TIMER_MIN    0xffff
-#define V_PERSIST_TIMER_MIN(x) ((x) << S_PERSIST_TIMER_MIN)
-#define G_PERSIST_TIMER_MIN(x) (((x) >> S_PERSIST_TIMER_MIN) & M_PERSIST_TIMER_MIN)
-
-#define A_TP_PERS_MAX 0x3a4
-
-#define S_PERSIST_TIMER_MAX    0
-#define M_PERSIST_TIMER_MAX    0x3fffffff
-#define V_PERSIST_TIMER_MAX(x) ((x) << S_PERSIST_TIMER_MAX)
-#define G_PERSIST_TIMER_MAX(x) (((x) >> S_PERSIST_TIMER_MAX) & M_PERSIST_TIMER_MAX)
-
-#define A_TP_KEEP_IDLE 0x3ac
-
-#define S_KEEP_ALIVE_IDLE_TIME    0
-#define M_KEEP_ALIVE_IDLE_TIME    0x3fffffff
-#define V_KEEP_ALIVE_IDLE_TIME(x) ((x) << S_KEEP_ALIVE_IDLE_TIME)
-#define G_KEEP_ALIVE_IDLE_TIME(x) (((x) >> S_KEEP_ALIVE_IDLE_TIME) & M_KEEP_ALIVE_IDLE_TIME)
-
-#define A_TP_KEEP_INTVL 0x3b0
-
-#define S_KEEP_ALIVE_INTERVAL_TIME    0
-#define M_KEEP_ALIVE_INTERVAL_TIME    0x3fffffff
-#define V_KEEP_ALIVE_INTERVAL_TIME(x) ((x) << S_KEEP_ALIVE_INTERVAL_TIME)
-#define G_KEEP_ALIVE_INTERVAL_TIME(x) (((x) >> S_KEEP_ALIVE_INTERVAL_TIME) & M_KEEP_ALIVE_INTERVAL_TIME)
-
-#define A_TP_INIT_SRTT 0x3b4
-
-#define S_INITIAL_SRTT    0
-#define M_INITIAL_SRTT    0xffff
-#define V_INITIAL_SRTT(x) ((x) << S_INITIAL_SRTT)
-#define G_INITIAL_SRTT(x) (((x) >> S_INITIAL_SRTT) & M_INITIAL_SRTT)
-
-#define A_TP_DACK_TIME 0x3b8
-
-#define S_DELAYED_ACK_TIME    0
-#define M_DELAYED_ACK_TIME    0x7ff
-#define V_DELAYED_ACK_TIME(x) ((x) << S_DELAYED_ACK_TIME)
-#define G_DELAYED_ACK_TIME(x) (((x) >> S_DELAYED_ACK_TIME) & M_DELAYED_ACK_TIME)
-
-#define A_TP_FINWAIT2_TIME 0x3bc
-
-#define S_FINWAIT2_TIME    0
-#define M_FINWAIT2_TIME    0x3fffffff
-#define V_FINWAIT2_TIME(x) ((x) << S_FINWAIT2_TIME)
-#define G_FINWAIT2_TIME(x) (((x) >> S_FINWAIT2_TIME) & M_FINWAIT2_TIME)
-
-#define A_TP_FAST_FINWAIT2_TIME 0x3c0
-
-#define S_FAST_FINWAIT2_TIME    0
-#define M_FAST_FINWAIT2_TIME    0x3fffffff
-#define V_FAST_FINWAIT2_TIME(x) ((x) << S_FAST_FINWAIT2_TIME)
-#define G_FAST_FINWAIT2_TIME(x) (((x) >> S_FAST_FINWAIT2_TIME) & M_FAST_FINWAIT2_TIME)
-
-#define A_TP_SHIFT_CNT 0x3c4
-
-#define S_KEEPALIVE_MAX    0
-#define M_KEEPALIVE_MAX    0xff
-#define V_KEEPALIVE_MAX(x) ((x) << S_KEEPALIVE_MAX)
-#define G_KEEPALIVE_MAX(x) (((x) >> S_KEEPALIVE_MAX) & M_KEEPALIVE_MAX)
-
-#define S_WINDOWPROBE_MAX    8
-#define M_WINDOWPROBE_MAX    0xff
-#define V_WINDOWPROBE_MAX(x) ((x) << S_WINDOWPROBE_MAX)
-#define G_WINDOWPROBE_MAX(x) (((x) >> S_WINDOWPROBE_MAX) & M_WINDOWPROBE_MAX)
-
-#define S_RETRANSMISSION_MAX    16
-#define M_RETRANSMISSION_MAX    0xff
-#define V_RETRANSMISSION_MAX(x) ((x) << S_RETRANSMISSION_MAX)
-#define G_RETRANSMISSION_MAX(x) (((x) >> S_RETRANSMISSION_MAX) & M_RETRANSMISSION_MAX)
-
-#define S_SYN_MAX    24
-#define M_SYN_MAX    0xff
-#define V_SYN_MAX(x) ((x) << S_SYN_MAX)
-#define G_SYN_MAX(x) (((x) >> S_SYN_MAX) & M_SYN_MAX)
-
-#define A_TP_QOS_REG0 0x3e0
-
-#define S_L3_VALUE    0
-#define M_L3_VALUE    0x3f
-#define V_L3_VALUE(x) ((x) << S_L3_VALUE)
-#define G_L3_VALUE(x) (((x) >> S_L3_VALUE) & M_L3_VALUE)
-
-#define A_TP_QOS_REG1 0x3e4
-#define A_TP_QOS_REG2 0x3e8
-#define A_TP_QOS_REG3 0x3ec
-#define A_TP_QOS_REG4 0x3f0
-#define A_TP_QOS_REG5 0x3f4
-#define A_TP_QOS_REG6 0x3f8
-#define A_TP_QOS_REG7 0x3fc
-#define A_TP_MTU_REG0 0x404
-#define A_TP_MTU_REG1 0x408
-#define A_TP_MTU_REG2 0x40c
-#define A_TP_MTU_REG3 0x410
-#define A_TP_MTU_REG4 0x414
-#define A_TP_MTU_REG5 0x418
-#define A_TP_MTU_REG6 0x41c
-#define A_TP_MTU_REG7 0x420
 #define A_TP_RESET 0x44c
-
 #define S_TP_RESET    0
 #define V_TP_RESET(x) ((x) << S_TP_RESET)
 #define F_TP_RESET    V_TP_RESET(1U)

-#define S_CM_MEMMGR_INIT    1
-#define V_CM_MEMMGR_INIT(x) ((x) << S_CM_MEMMGR_INIT)
-#define F_CM_MEMMGR_INIT    V_CM_MEMMGR_INIT(1U)
-
-#define A_TP_MIB_INDEX 0x450
-#define A_TP_MIB_DATA 0x454
-#define A_TP_SYNC_TIME_HI 0x458
-#define A_TP_SYNC_TIME_LO 0x45c
-#define A_TP_CM_MM_RX_FLST_BASE 0x460
-
-#define S_CM_MEMMGR_RX_FREE_LIST_BASE    0
-#define M_CM_MEMMGR_RX_FREE_LIST_BASE    0xfffffff
-#define V_CM_MEMMGR_RX_FREE_LIST_BASE(x) ((x) << S_CM_MEMMGR_RX_FREE_LIST_BASE)
-#define G_CM_MEMMGR_RX_FREE_LIST_BASE(x) (((x) >> S_CM_MEMMGR_RX_FREE_LIST_BASE) & M_CM_MEMMGR_RX_FREE_LIST_BASE)
-
-#define A_TP_CM_MM_TX_FLST_BASE 0x464
-
-#define S_CM_MEMMGR_TX_FREE_LIST_BASE    0
-#define M_CM_MEMMGR_TX_FREE_LIST_BASE    0xfffffff
-#define V_CM_MEMMGR_TX_FREE_LIST_BASE(x) ((x) << S_CM_MEMMGR_TX_FREE_LIST_BASE)
-#define G_CM_MEMMGR_TX_FREE_LIST_BASE(x) (((x) >> S_CM_MEMMGR_TX_FREE_LIST_BASE) & M_CM_MEMMGR_TX_FREE_LIST_BASE)
-
-#define A_TP_CM_MM_P_FLST_BASE 0x468
-
-#define S_CM_MEMMGR_PSTRUCT_FREE_LIST_BASE    0
-#define M_CM_MEMMGR_PSTRUCT_FREE_LIST_BASE    0xfffffff
-#define V_CM_MEMMGR_PSTRUCT_FREE_LIST_BASE(x) ((x) << S_CM_MEMMGR_PSTRUCT_FREE_LIST_BASE)
-#define G_CM_MEMMGR_PSTRUCT_FREE_LIST_BASE(x) (((x) >> S_CM_MEMMGR_PSTRUCT_FREE_LIST_BASE) & M_CM_MEMMGR_PSTRUCT_FREE_LIST_BASE)
-
-#define A_TP_CM_MM_MAX_P 0x46c
-
-#define S_CM_MEMMGR_MAX_PSTRUCT    0
-#define M_CM_MEMMGR_MAX_PSTRUCT    0xfffffff
-#define V_CM_MEMMGR_MAX_PSTRUCT(x) ((x) << S_CM_MEMMGR_MAX_PSTRUCT)
-#define G_CM_MEMMGR_MAX_PSTRUCT(x) (((x) >> S_CM_MEMMGR_MAX_PSTRUCT) & M_CM_MEMMGR_MAX_PSTRUCT)
-
 #define A_TP_INT_ENABLE 0x470
-
-#define S_TX_FREE_LIST_EMPTY    0
-#define V_TX_FREE_LIST_EMPTY(x) ((x) << S_TX_FREE_LIST_EMPTY)
-#define F_TX_FREE_LIST_EMPTY    V_TX_FREE_LIST_EMPTY(1U)
-
-#define S_RX_FREE_LIST_EMPTY    1
-#define V_RX_FREE_LIST_EMPTY(x) ((x) << S_RX_FREE_LIST_EMPTY)
-#define F_RX_FREE_LIST_EMPTY    V_RX_FREE_LIST_EMPTY(1U)
-
 #define A_TP_INT_CAUSE 0x474
-#define A_TP_TIMER_SEPARATOR 0x4a4
-
-#define S_DISABLE_PAST_TIMER_INSERTION    0
-#define V_DISABLE_PAST_TIMER_INSERTION(x) ((x) << S_DISABLE_PAST_TIMER_INSERTION)
-#define F_DISABLE_PAST_TIMER_INSERTION    V_DISABLE_PAST_TIMER_INSERTION(1U)
-
-#define S_MODULATION_TIMER_SEPARATOR    1
-#define M_MODULATION_TIMER_SEPARATOR    0x7fff
-#define V_MODULATION_TIMER_SEPARATOR(x) ((x) << S_MODULATION_TIMER_SEPARATOR)
-#define G_MODULATION_TIMER_SEPARATOR(x) (((x) >> S_MODULATION_TIMER_SEPARATOR) & M_MODULATION_TIMER_SEPARATOR)
-
-#define S_GLOBAL_TIMER_SEPARATOR    16
-#define M_GLOBAL_TIMER_SEPARATOR    0xffff
-#define V_GLOBAL_TIMER_SEPARATOR(x) ((x) << S_GLOBAL_TIMER_SEPARATOR)
-#define G_GLOBAL_TIMER_SEPARATOR(x) (((x) >> S_GLOBAL_TIMER_SEPARATOR) & M_GLOBAL_TIMER_SEPARATOR)
-
-#define A_TP_CM_FC_MODE 0x4b0
-#define A_TP_PC_CONGESTION_CNTL 0x4b4
 #define A_TP_TX_DROP_CONFIG 0x4b8

 #define S_ENABLE_TX_DROP    31
@@ -1241,108 +268,12 @@
 #define F_ENABLE_TX_ERROR    V_ENABLE_TX_ERROR(1U)

 #define S_DROP_TICKS_CNT    4
-#define M_DROP_TICKS_CNT    0x3ffffff
 #define V_DROP_TICKS_CNT(x) ((x) << S_DROP_TICKS_CNT)
-#define G_DROP_TICKS_CNT(x) (((x) >> S_DROP_TICKS_CNT) & M_DROP_TICKS_CNT)

 #define S_NUM_PKTS_DROPPED    0
-#define M_NUM_PKTS_DROPPED    0xf
 #define V_NUM_PKTS_DROPPED(x) ((x) << S_NUM_PKTS_DROPPED)
-#define G_NUM_PKTS_DROPPED(x) (((x) >> S_NUM_PKTS_DROPPED) & M_NUM_PKTS_DROPPED)
-
-#define A_TP_TX_DROP_COUNT 0x4bc
-
-/* RAT registers */
-#define A_RAT_ROUTE_CONTROL 0x580
-
-#define S_USE_ROUTE_TABLE    0
-#define V_USE_ROUTE_TABLE(x) ((x) << S_USE_ROUTE_TABLE)
-#define F_USE_ROUTE_TABLE    V_USE_ROUTE_TABLE(1U)
-
-#define S_ENABLE_CSPI    1
-#define V_ENABLE_CSPI(x) ((x) << S_ENABLE_CSPI)
-#define F_ENABLE_CSPI    V_ENABLE_CSPI(1U)
-
-#define S_ENABLE_PCIX    2
-#define V_ENABLE_PCIX(x) ((x) << S_ENABLE_PCIX)
-#define F_ENABLE_PCIX    V_ENABLE_PCIX(1U)
-
-#define A_RAT_ROUTE_TABLE_INDEX 0x584
-
-#define S_ROUTE_TABLE_INDEX    0
-#define M_ROUTE_TABLE_INDEX    0xf
-#define V_ROUTE_TABLE_INDEX(x) ((x) << S_ROUTE_TABLE_INDEX)
-#define G_ROUTE_TABLE_INDEX(x) (((x) >> S_ROUTE_TABLE_INDEX) & M_ROUTE_TABLE_INDEX)
-
-#define A_RAT_ROUTE_TABLE_DATA 0x588
-#define A_RAT_NO_ROUTE 0x58c
-
-#define S_CPL_OPCODE    0
-#define M_CPL_OPCODE    0xff
-#define V_CPL_OPCODE(x) ((x) << S_CPL_OPCODE)
-#define G_CPL_OPCODE(x) (((x) >> S_CPL_OPCODE) & M_CPL_OPCODE)
-
-#define A_RAT_INTR_ENABLE 0x590
-
-#define S_ZEROROUTEERROR    0
-#define V_ZEROROUTEERROR(x) ((x) << S_ZEROROUTEERROR)
-#define F_ZEROROUTEERROR    V_ZEROROUTEERROR(1U)
-
-#define S_CSPIFRAMINGERROR    1
-#define V_CSPIFRAMINGERROR(x) ((x) << S_CSPIFRAMINGERROR)
-#define F_CSPIFRAMINGERROR    V_CSPIFRAMINGERROR(1U)
-
-#define S_SGEFRAMINGERROR    2
-#define V_SGEFRAMINGERROR(x) ((x) << S_SGEFRAMINGERROR)
-#define F_SGEFRAMINGERROR    V_SGEFRAMINGERROR(1U)
-
-#define S_TPFRAMINGERROR    3
-#define V_TPFRAMINGERROR(x) ((x) << S_TPFRAMINGERROR)
-#define F_TPFRAMINGERROR    V_TPFRAMINGERROR(1U)
-
-#define A_RAT_INTR_CAUSE 0x594

 /* CSPI registers */
-#define A_CSPI_RX_AE_WM 0x810
-#define A_CSPI_RX_AF_WM 0x814
-#define A_CSPI_CALENDAR_LEN 0x818
-
-#define S_CALENDARLENGTH    0
-#define M_CALENDARLENGTH    0xffff
-#define V_CALENDARLENGTH(x) ((x) << S_CALENDARLENGTH)
-#define G_CALENDARLENGTH(x) (((x) >> S_CALENDARLENGTH) & M_CALENDARLENGTH)
-
-#define A_CSPI_FIFO_STATUS_ENABLE 0x820
-
-#define S_FIFOSTATUSENABLE    0
-#define V_FIFOSTATUSENABLE(x) ((x) << S_FIFOSTATUSENABLE)
-#define F_FIFOSTATUSENABLE    V_FIFOSTATUSENABLE(1U)
-
-#define A_CSPI_MAXBURST1_MAXBURST2 0x828
-
-#define S_MAXBURST1    0
-#define M_MAXBURST1    0xffff
-#define V_MAXBURST1(x) ((x) << S_MAXBURST1)
-#define G_MAXBURST1(x) (((x) >> S_MAXBURST1) & M_MAXBURST1)
-
-#define S_MAXBURST2    16
-#define M_MAXBURST2    0xffff
-#define V_MAXBURST2(x) ((x) << S_MAXBURST2)
-#define G_MAXBURST2(x) (((x) >> S_MAXBURST2) & M_MAXBURST2)
-
-#define A_CSPI_TRAIN 0x82c
-
-#define S_CSPI_TRAIN_ALPHA    0
-#define M_CSPI_TRAIN_ALPHA    0xffff
-#define V_CSPI_TRAIN_ALPHA(x) ((x) << S_CSPI_TRAIN_ALPHA)
-#define G_CSPI_TRAIN_ALPHA(x) (((x) >> S_CSPI_TRAIN_ALPHA) & M_CSPI_TRAIN_ALPHA)
-
-#define S_CSPI_TRAIN_DATA_MAXT    16
-#define M_CSPI_TRAIN_DATA_MAXT    0xffff
-#define V_CSPI_TRAIN_DATA_MAXT(x) ((x) << S_CSPI_TRAIN_DATA_MAXT)
-#define G_CSPI_TRAIN_DATA_MAXT(x) (((x) >> S_CSPI_TRAIN_DATA_MAXT) & M_CSPI_TRAIN_DATA_MAXT)
-
-#define A_CSPI_INTR_STATUS 0x848

 #define S_DIP4ERR    0
 #define V_DIP4ERR(x) ((x) << S_DIP4ERR)
@@ -1364,63 +295,22 @@
 #define V_RAMPARITYERR(x) ((x) << S_RAMPARITYERR)
 #define F_RAMPARITYERR    V_RAMPARITYERR(1U)

-#define A_CSPI_INTR_ENABLE 0x84c
-
 /* ESPI registers */
-#define A_ESPI_SCH_TOKEN0 0x880
-
-#define S_SCHTOKEN0    0
-#define M_SCHTOKEN0    0xffff
-#define V_SCHTOKEN0(x) ((x) << S_SCHTOKEN0)
-#define G_SCHTOKEN0(x) (((x) >> S_SCHTOKEN0) & M_SCHTOKEN0)

+#define A_ESPI_SCH_TOKEN0 0x880
 #define A_ESPI_SCH_TOKEN1 0x884
-
-#define S_SCHTOKEN1    0
-#define M_SCHTOKEN1    0xffff
-#define V_SCHTOKEN1(x) ((x) << S_SCHTOKEN1)
-#define G_SCHTOKEN1(x) (((x) >> S_SCHTOKEN1) & M_SCHTOKEN1)
-
 #define A_ESPI_SCH_TOKEN2 0x888
-
-#define S_SCHTOKEN2    0
-#define M_SCHTOKEN2    0xffff
-#define V_SCHTOKEN2(x) ((x) << S_SCHTOKEN2)
-#define G_SCHTOKEN2(x) (((x) >> S_SCHTOKEN2) & M_SCHTOKEN2)
-
 #define A_ESPI_SCH_TOKEN3 0x88c
-
-#define S_SCHTOKEN3    0
-#define M_SCHTOKEN3    0xffff
-#define V_SCHTOKEN3(x) ((x) << S_SCHTOKEN3)
-#define G_SCHTOKEN3(x) (((x) >> S_SCHTOKEN3) & M_SCHTOKEN3)
-
 #define A_ESPI_RX_FIFO_ALMOST_EMPTY_WATERMARK 0x890
-
-#define S_ALMOSTEMPTY    0
-#define M_ALMOSTEMPTY    0xffff
-#define V_ALMOSTEMPTY(x) ((x) << S_ALMOSTEMPTY)
-#define G_ALMOSTEMPTY(x) (((x) >> S_ALMOSTEMPTY) & M_ALMOSTEMPTY)
-
 #define A_ESPI_RX_FIFO_ALMOST_FULL_WATERMARK 0x894
-
-#define S_ALMOSTFULL    0
-#define M_ALMOSTFULL    0xffff
-#define V_ALMOSTFULL(x) ((x) << S_ALMOSTFULL)
-#define G_ALMOSTFULL(x) (((x) >> S_ALMOSTFULL) & M_ALMOSTFULL)
-
 #define A_ESPI_CALENDAR_LENGTH 0x898
 #define A_PORT_CONFIG 0x89c

 #define S_RX_NPORTS    0
-#define M_RX_NPORTS    0xff
 #define V_RX_NPORTS(x) ((x) << S_RX_NPORTS)
-#define G_RX_NPORTS(x) (((x) >> S_RX_NPORTS) & M_RX_NPORTS)

 #define S_TX_NPORTS    8
-#define M_TX_NPORTS    0xff
 #define V_TX_NPORTS(x) ((x) << S_TX_NPORTS)
-#define G_TX_NPORTS(x) (((x) >> S_TX_NPORTS) & M_TX_NPORTS)

 #define A_ESPI_FIFO_STATUS_ENABLE 0x8a0

@@ -1428,124 +318,12 @@
 #define V_RXSTATUSENABLE(x) ((x) << S_RXSTATUSENABLE)
 #define F_RXSTATUSENABLE    V_RXSTATUSENABLE(1U)

-#define S_TXDROPENABLE    1
-#define V_TXDROPENABLE(x) ((x) << S_TXDROPENABLE)
-#define F_TXDROPENABLE    V_TXDROPENABLE(1U)
-
-#define S_RXENDIANMODE    2
-#define V_RXENDIANMODE(x) ((x) << S_RXENDIANMODE)
-#define F_RXENDIANMODE    V_RXENDIANMODE(1U)
-
-#define S_TXENDIANMODE    3
-#define V_TXENDIANMODE(x) ((x) << S_TXENDIANMODE)
-#define F_TXENDIANMODE    V_TXENDIANMODE(1U)
-
 #define S_INTEL1010MODE    4
 #define V_INTEL1010MODE(x) ((x) << S_INTEL1010MODE)
 #define F_INTEL1010MODE    V_INTEL1010MODE(1U)

 #define A_ESPI_MAXBURST1_MAXBURST2 0x8a8
 #define A_ESPI_TRAIN 0x8ac
-
-#define S_MAXTRAINALPHA    0
-#define M_MAXTRAINALPHA    0xffff
-#define V_MAXTRAINALPHA(x) ((x) << S_MAXTRAINALPHA)
-#define G_MAXTRAINALPHA(x) (((x) >> S_MAXTRAINALPHA) & M_MAXTRAINALPHA)
-
-#define S_MAXTRAINDATA    16
-#define M_MAXTRAINDATA    0xffff
-#define V_MAXTRAINDATA(x) ((x) << S_MAXTRAINDATA)
-#define G_MAXTRAINDATA(x) (((x) >> S_MAXTRAINDATA) & M_MAXTRAINDATA)
-
-#define A_RAM_STATUS 0x8b0
-
-#define S_RXFIFOPARITYERROR    0
-#define M_RXFIFOPARITYERROR    0x3ff
-#define V_RXFIFOPARITYERROR(x) ((x) << S_RXFIFOPARITYERROR)
-#define G_RXFIFOPARITYERROR(x) (((x) >> S_RXFIFOPARITYERROR) & M_RXFIFOPARITYERROR)
-
-#define S_TXFIFOPARITYERROR    10
-#define M_TXFIFOPARITYERROR    0x3ff
-#define V_TXFIFOPARITYERROR(x) ((x) << S_TXFIFOPARITYERROR)
-#define G_TXFIFOPARITYERROR(x) (((x) >> S_TXFIFOPARITYERROR) & M_TXFIFOPARITYERROR)
-
-#define S_RXFIFOOVERFLOW    20
-#define M_RXFIFOOVERFLOW    0x3ff
-#define V_RXFIFOOVERFLOW(x) ((x) << S_RXFIFOOVERFLOW)
-#define G_RXFIFOOVERFLOW(x) (((x) >> S_RXFIFOOVERFLOW) & M_RXFIFOOVERFLOW)
-
-#define A_TX_DROP_COUNT0 0x8b4
-
-#define S_TXPORT0DROPCNT    0
-#define M_TXPORT0DROPCNT    0xffff
-#define V_TXPORT0DROPCNT(x) ((x) << S_TXPORT0DROPCNT)
-#define G_TXPORT0DROPCNT(x) (((x) >> S_TXPORT0DROPCNT) & M_TXPORT0DROPCNT)
-
-#define S_TXPORT1DROPCNT    16
-#define M_TXPORT1DROPCNT    0xffff
-#define V_TXPORT1DROPCNT(x) ((x) << S_TXPORT1DROPCNT)
-#define G_TXPORT1DROPCNT(x) (((x) >> S_TXPORT1DROPCNT) & M_TXPORT1DROPCNT)
-
-#define A_TX_DROP_COUNT1 0x8b8
-
-#define S_TXPORT2DROPCNT    0
-#define M_TXPORT2DROPCNT    0xffff
-#define V_TXPORT2DROPCNT(x) ((x) << S_TXPORT2DROPCNT)
-#define G_TXPORT2DROPCNT(x) (((x) >> S_TXPORT2DROPCNT) & M_TXPORT2DROPCNT)
-
-#define S_TXPORT3DROPCNT    16
-#define M_TXPORT3DROPCNT    0xffff
-#define V_TXPORT3DROPCNT(x) ((x) << S_TXPORT3DROPCNT)
-#define G_TXPORT3DROPCNT(x) (((x) >> S_TXPORT3DROPCNT) & M_TXPORT3DROPCNT)
-
-#define A_RX_DROP_COUNT0 0x8bc
-
-#define S_RXPORT0DROPCNT    0
-#define M_RXPORT0DROPCNT    0xffff
-#define V_RXPORT0DROPCNT(x) ((x) << S_RXPORT0DROPCNT)
-#define G_RXPORT0DROPCNT(x) (((x) >> S_RXPORT0DROPCNT) & M_RXPORT0DROPCNT)
-
-#define S_RXPORT1DROPCNT    16
-#define M_RXPORT1DROPCNT    0xffff
-#define V_RXPORT1DROPCNT(x) ((x) << S_RXPORT1DROPCNT)
-#define G_RXPORT1DROPCNT(x) (((x) >> S_RXPORT1DROPCNT) & M_RXPORT1DROPCNT)
-
-#define A_RX_DROP_COUNT1 0x8c0
-
-#define S_RXPORT2DROPCNT    0
-#define M_RXPORT2DROPCNT    0xffff
-#define V_RXPORT2DROPCNT(x) ((x) << S_RXPORT2DROPCNT)
-#define G_RXPORT2DROPCNT(x) (((x) >> S_RXPORT2DROPCNT) & M_RXPORT2DROPCNT)
-
-#define S_RXPORT3DROPCNT    16
-#define M_RXPORT3DROPCNT    0xffff
-#define V_RXPORT3DROPCNT(x) ((x) << S_RXPORT3DROPCNT)
-#define G_RXPORT3DROPCNT(x) (((x) >> S_RXPORT3DROPCNT) & M_RXPORT3DROPCNT)
-
-#define A_DIP4_ERROR_COUNT 0x8c4
-
-#define S_DIP4ERRORCNT    0
-#define M_DIP4ERRORCNT    0xfff
-#define V_DIP4ERRORCNT(x) ((x) << S_DIP4ERRORCNT)
-#define G_DIP4ERRORCNT(x) (((x) >> S_DIP4ERRORCNT) & M_DIP4ERRORCNT)
-
-#define S_DIP4ERRORCNTSHADOW    12
-#define M_DIP4ERRORCNTSHADOW    0xfff
-#define V_DIP4ERRORCNTSHADOW(x) ((x) << S_DIP4ERRORCNTSHADOW)
-#define G_DIP4ERRORCNTSHADOW(x) (((x) >> S_DIP4ERRORCNTSHADOW) & M_DIP4ERRORCNTSHADOW)
-
-#define S_TRICN_RX_TRAIN_ERR    24
-#define V_TRICN_RX_TRAIN_ERR(x) ((x) << S_TRICN_RX_TRAIN_ERR)
-#define F_TRICN_RX_TRAIN_ERR    V_TRICN_RX_TRAIN_ERR(1U)
-
-#define S_TRICN_RX_TRAINING    25
-#define V_TRICN_RX_TRAINING(x) ((x) << S_TRICN_RX_TRAINING)
-#define F_TRICN_RX_TRAINING    V_TRICN_RX_TRAINING(1U)
-
-#define S_TRICN_RX_TRAIN_OK    26
-#define V_TRICN_RX_TRAIN_OK(x) ((x) << S_TRICN_RX_TRAIN_OK)
-#define F_TRICN_RX_TRAIN_OK    V_TRICN_RX_TRAIN_OK(1U)
-
 #define A_ESPI_INTR_STATUS 0x8c8

 #define S_DIP2PARITYERR    5
@@ -1555,56 +333,19 @@
 #define A_ESPI_INTR_ENABLE 0x8cc
 #define A_RX_DROP_THRESHOLD 0x8d0
 #define A_ESPI_RX_RESET 0x8ec
-
-#define S_ESPI_RX_LNK_RST    0
-#define V_ESPI_RX_LNK_RST(x) ((x) << S_ESPI_RX_LNK_RST)
-#define F_ESPI_RX_LNK_RST    V_ESPI_RX_LNK_RST(1U)
-
-#define S_ESPI_RX_CORE_RST    1
-#define V_ESPI_RX_CORE_RST(x) ((x) << S_ESPI_RX_CORE_RST)
-#define F_ESPI_RX_CORE_RST    V_ESPI_RX_CORE_RST(1U)
-
-#define S_RX_CLK_STATUS    2
-#define V_RX_CLK_STATUS(x) ((x) << S_RX_CLK_STATUS)
-#define F_RX_CLK_STATUS    V_RX_CLK_STATUS(1U)
-
 #define A_ESPI_MISC_CONTROL 0x8f0

 #define S_OUT_OF_SYNC_COUNT    0
-#define M_OUT_OF_SYNC_COUNT    0xf
 #define V_OUT_OF_SYNC_COUNT(x) ((x) << S_OUT_OF_SYNC_COUNT)
-#define G_OUT_OF_SYNC_COUNT(x) (((x) >> S_OUT_OF_SYNC_COUNT) & M_OUT_OF_SYNC_COUNT)
-
-#define S_DIP2_COUNT_MODE_ENABLE    4
-#define V_DIP2_COUNT_MODE_ENABLE(x) ((x) << S_DIP2_COUNT_MODE_ENABLE)
-#define F_DIP2_COUNT_MODE_ENABLE    V_DIP2_COUNT_MODE_ENABLE(1U)

 #define S_DIP2_PARITY_ERR_THRES    5
-#define M_DIP2_PARITY_ERR_THRES    0xf
 #define V_DIP2_PARITY_ERR_THRES(x) ((x) << S_DIP2_PARITY_ERR_THRES)
-#define G_DIP2_PARITY_ERR_THRES(x) (((x) >> S_DIP2_PARITY_ERR_THRES) & M_DIP2_PARITY_ERR_THRES)

 #define S_DIP4_THRES    9
-#define M_DIP4_THRES    0xfff
 #define V_DIP4_THRES(x) ((x) << S_DIP4_THRES)
-#define G_DIP4_THRES(x) (((x) >> S_DIP4_THRES) & M_DIP4_THRES)
-
-#define S_DIP4_THRES_ENABLE    21
-#define V_DIP4_THRES_ENABLE(x) ((x) << S_DIP4_THRES_ENABLE)
-#define F_DIP4_THRES_ENABLE    V_DIP4_THRES_ENABLE(1U)
-
-#define S_FORCE_DISABLE_STATUS    22
-#define V_FORCE_DISABLE_STATUS(x) ((x) << S_FORCE_DISABLE_STATUS)
-#define F_FORCE_DISABLE_STATUS    V_FORCE_DISABLE_STATUS(1U)
-
-#define S_DYNAMIC_DESKEW    23
-#define V_DYNAMIC_DESKEW(x) ((x) << S_DYNAMIC_DESKEW)
-#define F_DYNAMIC_DESKEW    V_DYNAMIC_DESKEW(1U)

 #define S_MONITORED_PORT_NUM    25
-#define M_MONITORED_PORT_NUM    0x3
 #define V_MONITORED_PORT_NUM(x) ((x) << S_MONITORED_PORT_NUM)
-#define G_MONITORED_PORT_NUM(x) (((x) >> S_MONITORED_PORT_NUM) & M_MONITORED_PORT_NUM)

 #define S_MONITORED_DIRECTION    27
 #define V_MONITORED_DIRECTION(x) ((x) << S_MONITORED_DIRECTION)
@@ -1615,125 +356,33 @@
 #define F_MONITORED_INTERFACE    V_MONITORED_INTERFACE(1U)

 #define A_ESPI_DIP2_ERR_COUNT 0x8f4
-
-#define S_DIP2_ERR_CNT    0
-#define M_DIP2_ERR_CNT    0xf
-#define V_DIP2_ERR_CNT(x) ((x) << S_DIP2_ERR_CNT)
-#define G_DIP2_ERR_CNT(x) (((x) >> S_DIP2_ERR_CNT) & M_DIP2_ERR_CNT)
-
 #define A_ESPI_CMD_ADDR 0x8f8

 #define S_WRITE_DATA    0
-#define M_WRITE_DATA    0xff
 #define V_WRITE_DATA(x) ((x) << S_WRITE_DATA)
-#define G_WRITE_DATA(x) (((x) >> S_WRITE_DATA) & M_WRITE_DATA)

 #define S_REGISTER_OFFSET    8
-#define M_REGISTER_OFFSET    0xf
 #define V_REGISTER_OFFSET(x) ((x) << S_REGISTER_OFFSET)
-#define G_REGISTER_OFFSET(x) (((x) >> S_REGISTER_OFFSET) & M_REGISTER_OFFSET)

 #define S_CHANNEL_ADDR    12
-#define M_CHANNEL_ADDR    0xf
 #define V_CHANNEL_ADDR(x) ((x) << S_CHANNEL_ADDR)
-#define G_CHANNEL_ADDR(x) (((x) >> S_CHANNEL_ADDR) & M_CHANNEL_ADDR)

 #define S_MODULE_ADDR    16
-#define M_MODULE_ADDR    0x3
 #define V_MODULE_ADDR(x) ((x) << S_MODULE_ADDR)
-#define G_MODULE_ADDR(x) (((x) >> S_MODULE_ADDR) & M_MODULE_ADDR)

 #define S_BUNDLE_ADDR    20
-#define M_BUNDLE_ADDR    0x3
 #define V_BUNDLE_ADDR(x) ((x) << S_BUNDLE_ADDR)
-#define G_BUNDLE_ADDR(x) (((x) >> S_BUNDLE_ADDR) & M_BUNDLE_ADDR)

 #define S_SPI4_COMMAND    24
-#define M_SPI4_COMMAND    0xff
 #define V_SPI4_COMMAND(x) ((x) << S_SPI4_COMMAND)
-#define G_SPI4_COMMAND(x) (((x) >> S_SPI4_COMMAND) & M_SPI4_COMMAND)

 #define A_ESPI_GOSTAT 0x8fc
-
-#define S_READ_DATA    0
-#define M_READ_DATA    0xff
-#define V_READ_DATA(x) ((x) << S_READ_DATA)
-#define G_READ_DATA(x) (((x) >> S_READ_DATA) & M_READ_DATA)
-
 #define S_ESPI_CMD_BUSY    8
 #define V_ESPI_CMD_BUSY(x) ((x) << S_ESPI_CMD_BUSY)
 #define F_ESPI_CMD_BUSY    V_ESPI_CMD_BUSY(1U)

-#define S_ERROR_ACK    9
-#define V_ERROR_ACK(x) ((x) << S_ERROR_ACK)
-#define F_ERROR_ACK    V_ERROR_ACK(1U)
-
-#define S_UNMAPPED_ERR    10
-#define V_UNMAPPED_ERR(x) ((x) << S_UNMAPPED_ERR)
-#define F_UNMAPPED_ERR    V_UNMAPPED_ERR(1U)
-
-#define S_TRANSACTION_TIMER    16
-#define M_TRANSACTION_TIMER    0xff
-#define V_TRANSACTION_TIMER(x) ((x) << S_TRANSACTION_TIMER)
-#define G_TRANSACTION_TIMER(x) (((x) >> S_TRANSACTION_TIMER) & M_TRANSACTION_TIMER)
-
-
-/* ULP registers */
-#define A_ULP_ULIMIT 0x980
-#define A_ULP_TAGMASK 0x984
-#define A_ULP_HREG_INDEX 0x988
-#define A_ULP_HREG_DATA 0x98c
-#define A_ULP_INT_ENABLE 0x990
-#define A_ULP_INT_CAUSE 0x994
-
-#define S_HREG_PAR_ERR    0
-#define V_HREG_PAR_ERR(x) ((x) << S_HREG_PAR_ERR)
-#define F_HREG_PAR_ERR    V_HREG_PAR_ERR(1U)
-
-#define S_EGRS_DATA_PAR_ERR    1
-#define V_EGRS_DATA_PAR_ERR(x) ((x) << S_EGRS_DATA_PAR_ERR)
-#define F_EGRS_DATA_PAR_ERR    V_EGRS_DATA_PAR_ERR(1U)
-
-#define S_INGRS_DATA_PAR_ERR    2
-#define V_INGRS_DATA_PAR_ERR(x) ((x) << S_INGRS_DATA_PAR_ERR)
-#define F_INGRS_DATA_PAR_ERR    V_INGRS_DATA_PAR_ERR(1U)
-
-#define S_PM_INTR    3
-#define V_PM_INTR(x) ((x) << S_PM_INTR)
-#define F_PM_INTR    V_PM_INTR(1U)
-
-#define S_PM_E2C_SYNC_ERR    4
-#define V_PM_E2C_SYNC_ERR(x) ((x) << S_PM_E2C_SYNC_ERR)
-#define F_PM_E2C_SYNC_ERR    V_PM_E2C_SYNC_ERR(1U)
-
-#define S_PM_C2E_SYNC_ERR    5
-#define V_PM_C2E_SYNC_ERR(x) ((x) << S_PM_C2E_SYNC_ERR)
-#define F_PM_C2E_SYNC_ERR    V_PM_C2E_SYNC_ERR(1U)
-
-#define S_PM_E2C_EMPTY_ERR    6
-#define V_PM_E2C_EMPTY_ERR(x) ((x) << S_PM_E2C_EMPTY_ERR)
-#define F_PM_E2C_EMPTY_ERR    V_PM_E2C_EMPTY_ERR(1U)
-
-#define S_PM_C2E_EMPTY_ERR    7
-#define V_PM_C2E_EMPTY_ERR(x) ((x) << S_PM_C2E_EMPTY_ERR)
-#define F_PM_C2E_EMPTY_ERR    V_PM_C2E_EMPTY_ERR(1U)
-
-#define S_PM_PAR_ERR    8
-#define M_PM_PAR_ERR    0xffff
-#define V_PM_PAR_ERR(x) ((x) << S_PM_PAR_ERR)
-#define G_PM_PAR_ERR(x) (((x) >> S_PM_PAR_ERR) & M_PM_PAR_ERR)
-
-#define S_PM_E2C_WRT_FULL    24
-#define V_PM_E2C_WRT_FULL(x) ((x) << S_PM_E2C_WRT_FULL)
-#define F_PM_E2C_WRT_FULL    V_PM_E2C_WRT_FULL(1U)
-
-#define S_PM_C2E_WRT_FULL    25
-#define V_PM_C2E_WRT_FULL(x) ((x) << S_PM_C2E_WRT_FULL)
-#define F_PM_C2E_WRT_FULL    V_PM_C2E_WRT_FULL(1U)
-
-#define A_ULP_PIO_CTRL 0x998
-
 /* PL registers */
+
 #define A_PL_ENABLE 0xa00

 #define S_PL_INTR_SGE_ERR    0
@@ -1744,38 +393,14 @@
 #define V_PL_INTR_SGE_DATA(x) ((x) << S_PL_INTR_SGE_DATA)
 #define F_PL_INTR_SGE_DATA    V_PL_INTR_SGE_DATA(1U)

-#define S_PL_INTR_MC3    2
-#define V_PL_INTR_MC3(x) ((x) << S_PL_INTR_MC3)
-#define F_PL_INTR_MC3    V_PL_INTR_MC3(1U)
-
-#define S_PL_INTR_MC4    3
-#define V_PL_INTR_MC4(x) ((x) << S_PL_INTR_MC4)
-#define F_PL_INTR_MC4    V_PL_INTR_MC4(1U)
-
-#define S_PL_INTR_MC5    4
-#define V_PL_INTR_MC5(x) ((x) << S_PL_INTR_MC5)
-#define F_PL_INTR_MC5    V_PL_INTR_MC5(1U)
-
-#define S_PL_INTR_RAT    5
-#define V_PL_INTR_RAT(x) ((x) << S_PL_INTR_RAT)
-#define F_PL_INTR_RAT    V_PL_INTR_RAT(1U)
-
 #define S_PL_INTR_TP    6
 #define V_PL_INTR_TP(x) ((x) << S_PL_INTR_TP)
 #define F_PL_INTR_TP    V_PL_INTR_TP(1U)

-#define S_PL_INTR_ULP    7
-#define V_PL_INTR_ULP(x) ((x) << S_PL_INTR_ULP)
-#define F_PL_INTR_ULP    V_PL_INTR_ULP(1U)
-
 #define S_PL_INTR_ESPI    8
 #define V_PL_INTR_ESPI(x) ((x) << S_PL_INTR_ESPI)
 #define F_PL_INTR_ESPI    V_PL_INTR_ESPI(1U)

-#define S_PL_INTR_CSPI    9
-#define V_PL_INTR_CSPI(x) ((x) << S_PL_INTR_CSPI)
-#define F_PL_INTR_CSPI    V_PL_INTR_CSPI(1U)
-
 #define S_PL_INTR_PCIX    10
 #define V_PL_INTR_PCIX(x) ((x) << S_PL_INTR_PCIX)
 #define F_PL_INTR_PCIX    V_PL_INTR_PCIX(1U)
@@ -1787,373 +412,42 @@
 #define A_PL_CAUSE 0xa04

 /* MC5 registers */
-#define A_MC5_CONFIG 0xc04

-#define S_MODE    0
-#define V_MODE(x) ((x) << S_MODE)
-#define F_MODE    V_MODE(1U)
+#define A_MC5_CONFIG 0xc04

 #define S_TCAM_RESET    1
 #define V_TCAM_RESET(x) ((x) << S_TCAM_RESET)
 #define F_TCAM_RESET    V_TCAM_RESET(1U)

-#define S_TCAM_READY    2
-#define V_TCAM_READY(x) ((x) << S_TCAM_READY)
-#define F_TCAM_READY    V_TCAM_READY(1U)
-
-#define S_DBGI_ENABLE    4
-#define V_DBGI_ENABLE(x) ((x) << S_DBGI_ENABLE)
-#define F_DBGI_ENABLE    V_DBGI_ENABLE(1U)
-
 #define S_M_BUS_ENABLE    5
 #define V_M_BUS_ENABLE(x) ((x) << S_M_BUS_ENABLE)
 #define F_M_BUS_ENABLE    V_M_BUS_ENABLE(1U)

-#define S_PARITY_ENABLE    6
-#define V_PARITY_ENABLE(x) ((x) << S_PARITY_ENABLE)
-#define F_PARITY_ENABLE    V_PARITY_ENABLE(1U)
-
-#define S_SYN_ISSUE_MODE    7
-#define M_SYN_ISSUE_MODE    0x3
-#define V_SYN_ISSUE_MODE(x) ((x) << S_SYN_ISSUE_MODE)
-#define G_SYN_ISSUE_MODE(x) (((x) >> S_SYN_ISSUE_MODE) & M_SYN_ISSUE_MODE)
-
-#define S_BUILD    16
-#define V_BUILD(x) ((x) << S_BUILD)
-#define F_BUILD    V_BUILD(1U)
-
-#define S_COMPRESSION_ENABLE    17
-#define V_COMPRESSION_ENABLE(x) ((x) << S_COMPRESSION_ENABLE)
-#define F_COMPRESSION_ENABLE    V_COMPRESSION_ENABLE(1U)
-
-#define S_NUM_LIP    18
-#define M_NUM_LIP    0x3f
-#define V_NUM_LIP(x) ((x) << S_NUM_LIP)
-#define G_NUM_LIP(x) (((x) >> S_NUM_LIP) & M_NUM_LIP)
-
-#define S_TCAM_PART_CNT    24
-#define M_TCAM_PART_CNT    0x3
-#define V_TCAM_PART_CNT(x) ((x) << S_TCAM_PART_CNT)
-#define G_TCAM_PART_CNT(x) (((x) >> S_TCAM_PART_CNT) & M_TCAM_PART_CNT)
-
-#define S_TCAM_PART_TYPE    26
-#define M_TCAM_PART_TYPE    0x3
-#define V_TCAM_PART_TYPE(x) ((x) << S_TCAM_PART_TYPE)
-#define G_TCAM_PART_TYPE(x) (((x) >> S_TCAM_PART_TYPE) & M_TCAM_PART_TYPE)
-
-#define S_TCAM_PART_SIZE    28
-#define M_TCAM_PART_SIZE    0x3
-#define V_TCAM_PART_SIZE(x) ((x) << S_TCAM_PART_SIZE)
-#define G_TCAM_PART_SIZE(x) (((x) >> S_TCAM_PART_SIZE) & M_TCAM_PART_SIZE)
-
-#define S_TCAM_PART_TYPE_HI    30
-#define V_TCAM_PART_TYPE_HI(x) ((x) << S_TCAM_PART_TYPE_HI)
-#define F_TCAM_PART_TYPE_HI    V_TCAM_PART_TYPE_HI(1U)
-
-#define A_MC5_SIZE 0xc08
-
-#define S_SIZE    0
-#define M_SIZE    0x3fffff
-#define V_SIZE(x) ((x) << S_SIZE)
-#define G_SIZE(x) (((x) >> S_SIZE) & M_SIZE)
-
-#define A_MC5_ROUTING_TABLE_INDEX 0xc0c
-
-#define S_START_OF_ROUTING_TABLE    0
-#define M_START_OF_ROUTING_TABLE    0x3fffff
-#define V_START_OF_ROUTING_TABLE(x) ((x) << S_START_OF_ROUTING_TABLE)
-#define G_START_OF_ROUTING_TABLE(x) (((x) >> S_START_OF_ROUTING_TABLE) & M_START_OF_ROUTING_TABLE)
-
-#define A_MC5_SERVER_INDEX 0xc14
-
-#define S_START_OF_SERVER_INDEX    0
-#define M_START_OF_SERVER_INDEX    0x3fffff
-#define V_START_OF_SERVER_INDEX(x) ((x) << S_START_OF_SERVER_INDEX)
-#define G_START_OF_SERVER_INDEX(x) (((x) >> S_START_OF_SERVER_INDEX) & M_START_OF_SERVER_INDEX)
-
-#define A_MC5_LIP_RAM_ADDR 0xc18
-
-#define S_LOCAL_IP_RAM_ADDR    0
-#define M_LOCAL_IP_RAM_ADDR    0x3f
-#define V_LOCAL_IP_RAM_ADDR(x) ((x) << S_LOCAL_IP_RAM_ADDR)
-#define G_LOCAL_IP_RAM_ADDR(x) (((x) >> S_LOCAL_IP_RAM_ADDR) & M_LOCAL_IP_RAM_ADDR)
-
-#define S_RAM_WRITE_ENABLE    8
-#define V_RAM_WRITE_ENABLE(x) ((x) << S_RAM_WRITE_ENABLE)
-#define F_RAM_WRITE_ENABLE    V_RAM_WRITE_ENABLE(1U)
-
-#define A_MC5_LIP_RAM_DATA 0xc1c
-#define A_MC5_RSP_LATENCY 0xc20
-
-#define S_SEARCH_RESPONSE_LATENCY    0
-#define M_SEARCH_RESPONSE_LATENCY    0x1f
-#define V_SEARCH_RESPONSE_LATENCY(x) ((x) << S_SEARCH_RESPONSE_LATENCY)
-#define G_SEARCH_RESPONSE_LATENCY(x) (((x) >> S_SEARCH_RESPONSE_LATENCY) & M_SEARCH_RESPONSE_LATENCY)
-
-#define S_LEARN_RESPONSE_LATENCY    8
-#define M_LEARN_RESPONSE_LATENCY    0x1f
-#define V_LEARN_RESPONSE_LATENCY(x) ((x) << S_LEARN_RESPONSE_LATENCY)
-#define G_LEARN_RESPONSE_LATENCY(x) (((x) >> S_LEARN_RESPONSE_LATENCY) & M_LEARN_RESPONSE_LATENCY)
-
-#define A_MC5_PARITY_LATENCY 0xc24
-
-#define S_SRCHLAT    0
-#define M_SRCHLAT    0x1f
-#define V_SRCHLAT(x) ((x) << S_SRCHLAT)
-#define G_SRCHLAT(x) (((x) >> S_SRCHLAT) & M_SRCHLAT)
-
-#define S_PARLAT    8
-#define M_PARLAT    0x1f
-#define V_PARLAT(x) ((x) << S_PARLAT)
-#define G_PARLAT(x) (((x) >> S_PARLAT) & M_PARLAT)
-
-#define A_MC5_WR_LRN_VERIFY 0xc28
-
-#define S_POVEREN    0
-#define V_POVEREN(x) ((x) << S_POVEREN)
-#define F_POVEREN    V_POVEREN(1U)
-
-#define S_LRNVEREN    1
-#define V_LRNVEREN(x) ((x) << S_LRNVEREN)
-#define F_LRNVEREN    V_LRNVEREN(1U)
-
-#define S_VWVEREN    2
-#define V_VWVEREN(x) ((x) << S_VWVEREN)
-#define F_VWVEREN    V_VWVEREN(1U)
-
-#define A_MC5_PART_ID_INDEX 0xc2c
-
-#define S_IDINDEX    0
-#define M_IDINDEX    0xf
-#define V_IDINDEX(x) ((x) << S_IDINDEX)
-#define G_IDINDEX(x) (((x) >> S_IDINDEX) & M_IDINDEX)
-
-#define A_MC5_RESET_MAX 0xc30
-
-#define S_RSTMAX    0
-#define M_RSTMAX    0x1ff
-#define V_RSTMAX(x) ((x) << S_RSTMAX)
-#define G_RSTMAX(x) (((x) >> S_RSTMAX) & M_RSTMAX)
-
-#define A_MC5_INT_ENABLE 0xc40
-
-#define S_MC5_INT_HIT_OUT_ACTIVE_REGION_ERR    0
-#define V_MC5_INT_HIT_OUT_ACTIVE_REGION_ERR(x) ((x) << S_MC5_INT_HIT_OUT_ACTIVE_REGION_ERR)
-#define F_MC5_INT_HIT_OUT_ACTIVE_REGION_ERR    V_MC5_INT_HIT_OUT_ACTIVE_REGION_ERR(1U)
-
-#define S_MC5_INT_HIT_IN_ACTIVE_REGION_ERR    1
-#define V_MC5_INT_HIT_IN_ACTIVE_REGION_ERR(x) ((x) << S_MC5_INT_HIT_IN_ACTIVE_REGION_ERR)
-#define F_MC5_INT_HIT_IN_ACTIVE_REGION_ERR    V_MC5_INT_HIT_IN_ACTIVE_REGION_ERR(1U)
-
-#define S_MC5_INT_HIT_IN_RT_REGION_ERR    2
-#define V_MC5_INT_HIT_IN_RT_REGION_ERR(x) ((x) << S_MC5_INT_HIT_IN_RT_REGION_ERR)
-#define F_MC5_INT_HIT_IN_RT_REGION_ERR    V_MC5_INT_HIT_IN_RT_REGION_ERR(1U)
-
-#define S_MC5_INT_MISS_ERR    3
-#define V_MC5_INT_MISS_ERR(x) ((x) << S_MC5_INT_MISS_ERR)
-#define F_MC5_INT_MISS_ERR    V_MC5_INT_MISS_ERR(1U)
-
-#define S_MC5_INT_LIP0_ERR    4
-#define V_MC5_INT_LIP0_ERR(x) ((x) << S_MC5_INT_LIP0_ERR)
-#define F_MC5_INT_LIP0_ERR    V_MC5_INT_LIP0_ERR(1U)
-
-#define S_MC5_INT_LIP_MISS_ERR    5
-#define V_MC5_INT_LIP_MISS_ERR(x) ((x) << S_MC5_INT_LIP_MISS_ERR)
-#define F_MC5_INT_LIP_MISS_ERR    V_MC5_INT_LIP_MISS_ERR(1U)
-
-#define S_MC5_INT_PARITY_ERR    6
-#define V_MC5_INT_PARITY_ERR(x) ((x) << S_MC5_INT_PARITY_ERR)
-#define F_MC5_INT_PARITY_ERR    V_MC5_INT_PARITY_ERR(1U)
-
-#define S_MC5_INT_ACTIVE_REGION_FULL    7
-#define V_MC5_INT_ACTIVE_REGION_FULL(x) ((x) << S_MC5_INT_ACTIVE_REGION_FULL)
-#define F_MC5_INT_ACTIVE_REGION_FULL    V_MC5_INT_ACTIVE_REGION_FULL(1U)
-
-#define S_MC5_INT_NFA_SRCH_ERR    8
-#define V_MC5_INT_NFA_SRCH_ERR(x) ((x) << S_MC5_INT_NFA_SRCH_ERR)
-#define F_MC5_INT_NFA_SRCH_ERR    V_MC5_INT_NFA_SRCH_ERR(1U)
-
-#define S_MC5_INT_SYN_COOKIE    9
-#define V_MC5_INT_SYN_COOKIE(x) ((x) << S_MC5_INT_SYN_COOKIE)
-#define F_MC5_INT_SYN_COOKIE    V_MC5_INT_SYN_COOKIE(1U)
-
-#define S_MC5_INT_SYN_COOKIE_BAD    10
-#define V_MC5_INT_SYN_COOKIE_BAD(x) ((x) << S_MC5_INT_SYN_COOKIE_BAD)
-#define F_MC5_INT_SYN_COOKIE_BAD    V_MC5_INT_SYN_COOKIE_BAD(1U)
-
-#define S_MC5_INT_SYN_COOKIE_OFF    11
-#define V_MC5_INT_SYN_COOKIE_OFF(x) ((x) << S_MC5_INT_SYN_COOKIE_OFF)
-#define F_MC5_INT_SYN_COOKIE_OFF    V_MC5_INT_SYN_COOKIE_OFF(1U)
-
-#define S_MC5_INT_UNKNOWN_CMD    15
-#define V_MC5_INT_UNKNOWN_CMD(x) ((x) << S_MC5_INT_UNKNOWN_CMD)
-#define F_MC5_INT_UNKNOWN_CMD    V_MC5_INT_UNKNOWN_CMD(1U)
-
-#define S_MC5_INT_REQUESTQ_PARITY_ERR    16
-#define V_MC5_INT_REQUESTQ_PARITY_ERR(x) ((x) << S_MC5_INT_REQUESTQ_PARITY_ERR)
-#define F_MC5_INT_REQUESTQ_PARITY_ERR    V_MC5_INT_REQUESTQ_PARITY_ERR(1U)
-
-#define S_MC5_INT_DISPATCHQ_PARITY_ERR    17
-#define V_MC5_INT_DISPATCHQ_PARITY_ERR(x) ((x) << S_MC5_INT_DISPATCHQ_PARITY_ERR)
-#define F_MC5_INT_DISPATCHQ_PARITY_ERR    V_MC5_INT_DISPATCHQ_PARITY_ERR(1U)
-
-#define S_MC5_INT_DEL_ACT_EMPTY    18
-#define V_MC5_INT_DEL_ACT_EMPTY(x) ((x) << S_MC5_INT_DEL_ACT_EMPTY)
-#define F_MC5_INT_DEL_ACT_EMPTY    V_MC5_INT_DEL_ACT_EMPTY(1U)
-
-#define A_MC5_INT_CAUSE 0xc44
-#define A_MC5_INT_TID 0xc48
-#define A_MC5_INT_PTID 0xc4c
-#define A_MC5_DBGI_CONFIG 0xc74
-#define A_MC5_DBGI_REQ_CMD 0xc78
-
-#define S_CMDMODE    0
-#define M_CMDMODE    0x7
-#define V_CMDMODE(x) ((x) << S_CMDMODE)
-#define G_CMDMODE(x) (((x) >> S_CMDMODE) & M_CMDMODE)
-
-#define S_SADRSEL    4
-#define V_SADRSEL(x) ((x) << S_SADRSEL)
-#define F_SADRSEL    V_SADRSEL(1U)
-
-#define S_WRITE_BURST_SIZE    22
-#define M_WRITE_BURST_SIZE    0x3ff
-#define V_WRITE_BURST_SIZE(x) ((x) << S_WRITE_BURST_SIZE)
-#define G_WRITE_BURST_SIZE(x) (((x) >> S_WRITE_BURST_SIZE) & M_WRITE_BURST_SIZE)
-
-#define A_MC5_DBGI_REQ_ADDR0 0xc7c
-#define A_MC5_DBGI_REQ_ADDR1 0xc80
-#define A_MC5_DBGI_REQ_ADDR2 0xc84
-#define A_MC5_DBGI_REQ_DATA0 0xc88
-#define A_MC5_DBGI_REQ_DATA1 0xc8c
-#define A_MC5_DBGI_REQ_DATA2 0xc90
-#define A_MC5_DBGI_REQ_DATA3 0xc94
-#define A_MC5_DBGI_REQ_DATA4 0xc98
-#define A_MC5_DBGI_REQ_MASK0 0xc9c
-#define A_MC5_DBGI_REQ_MASK1 0xca0
-#define A_MC5_DBGI_REQ_MASK2 0xca4
-#define A_MC5_DBGI_REQ_MASK3 0xca8
-#define A_MC5_DBGI_REQ_MASK4 0xcac
-#define A_MC5_DBGI_RSP_STATUS 0xcb0
-
-#define S_DBGI_RSP_VALID    0
-#define V_DBGI_RSP_VALID(x) ((x) << S_DBGI_RSP_VALID)
-#define F_DBGI_RSP_VALID    V_DBGI_RSP_VALID(1U)
-
-#define S_DBGI_RSP_HIT    1
-#define V_DBGI_RSP_HIT(x) ((x) << S_DBGI_RSP_HIT)
-#define F_DBGI_RSP_HIT    V_DBGI_RSP_HIT(1U)
-
-#define S_DBGI_RSP_ERR    2
-#define V_DBGI_RSP_ERR(x) ((x) << S_DBGI_RSP_ERR)
-#define F_DBGI_RSP_ERR    V_DBGI_RSP_ERR(1U)
-
-#define S_DBGI_RSP_ERR_REASON    8
-#define M_DBGI_RSP_ERR_REASON    0x7
-#define V_DBGI_RSP_ERR_REASON(x) ((x) << S_DBGI_RSP_ERR_REASON)
-#define G_DBGI_RSP_ERR_REASON(x) (((x) >> S_DBGI_RSP_ERR_REASON) & M_DBGI_RSP_ERR_REASON)
-
-#define A_MC5_DBGI_RSP_DATA0 0xcb4
-#define A_MC5_DBGI_RSP_DATA1 0xcb8
-#define A_MC5_DBGI_RSP_DATA2 0xcbc
-#define A_MC5_DBGI_RSP_DATA3 0xcc0
-#define A_MC5_DBGI_RSP_DATA4 0xcc4
-#define A_MC5_DBGI_RSP_LAST_CMD 0xcc8
-#define A_MC5_POPEN_DATA_WR_CMD 0xccc
-#define A_MC5_POPEN_MASK_WR_CMD 0xcd0
-#define A_MC5_AOPEN_SRCH_CMD 0xcd4
-#define A_MC5_AOPEN_LRN_CMD 0xcd8
-#define A_MC5_SYN_SRCH_CMD 0xcdc
-#define A_MC5_SYN_LRN_CMD 0xce0
-#define A_MC5_ACK_SRCH_CMD 0xce4
-#define A_MC5_ACK_LRN_CMD 0xce8
-#define A_MC5_ILOOKUP_CMD 0xcec
-#define A_MC5_ELOOKUP_CMD 0xcf0
-#define A_MC5_DATA_WRITE_CMD 0xcf4
-#define A_MC5_DATA_READ_CMD 0xcf8
-#define A_MC5_MASK_WRITE_CMD 0xcfc
-
 /* PCICFG registers */
+
 #define A_PCICFG_PM_CSR 0x44
 #define A_PCICFG_VPD_ADDR 0x4a

-#define S_VPD_ADDR    0
-#define M_VPD_ADDR    0x7fff
-#define V_VPD_ADDR(x) ((x) << S_VPD_ADDR)
-#define G_VPD_ADDR(x) (((x) >> S_VPD_ADDR) & M_VPD_ADDR)
-
 #define S_VPD_OP_FLAG    15
 #define V_VPD_OP_FLAG(x) ((x) << S_VPD_OP_FLAG)
 #define F_VPD_OP_FLAG    V_VPD_OP_FLAG(1U)

 #define A_PCICFG_VPD_DATA 0x4c
-#define A_PCICFG_PCIX_CMD 0x60
-#define A_PCICFG_INTR_ENABLE 0xf4
-
-#define S_MASTER_PARITY_ERR    0
-#define V_MASTER_PARITY_ERR(x) ((x) << S_MASTER_PARITY_ERR)
-#define F_MASTER_PARITY_ERR    V_MASTER_PARITY_ERR(1U)
-
-#define S_SIG_TARGET_ABORT    1
-#define V_SIG_TARGET_ABORT(x) ((x) << S_SIG_TARGET_ABORT)
-#define F_SIG_TARGET_ABORT    V_SIG_TARGET_ABORT(1U)
-
-#define S_RCV_TARGET_ABORT    2
-#define V_RCV_TARGET_ABORT(x) ((x) << S_RCV_TARGET_ABORT)
-#define F_RCV_TARGET_ABORT    V_RCV_TARGET_ABORT(1U)
-
-#define S_RCV_MASTER_ABORT    3
-#define V_RCV_MASTER_ABORT(x) ((x) << S_RCV_MASTER_ABORT)
-#define F_RCV_MASTER_ABORT    V_RCV_MASTER_ABORT(1U)
-
-#define S_SIG_SYS_ERR    4
-#define V_SIG_SYS_ERR(x) ((x) << S_SIG_SYS_ERR)
-#define F_SIG_SYS_ERR    V_SIG_SYS_ERR(1U)
-
-#define S_DET_PARITY_ERR    5
-#define V_DET_PARITY_ERR(x) ((x) << S_DET_PARITY_ERR)
-#define F_DET_PARITY_ERR    V_DET_PARITY_ERR(1U)
-
-#define S_PIO_PARITY_ERR    6
-#define V_PIO_PARITY_ERR(x) ((x) << S_PIO_PARITY_ERR)
-#define F_PIO_PARITY_ERR    V_PIO_PARITY_ERR(1U)
-
-#define S_WF_PARITY_ERR    7
-#define V_WF_PARITY_ERR(x) ((x) << S_WF_PARITY_ERR)
-#define F_WF_PARITY_ERR    V_WF_PARITY_ERR(1U)
-
-#define S_RF_PARITY_ERR    8
-#define M_RF_PARITY_ERR    0x3
-#define V_RF_PARITY_ERR(x) ((x) << S_RF_PARITY_ERR)
-#define G_RF_PARITY_ERR(x) (((x) >> S_RF_PARITY_ERR) & M_RF_PARITY_ERR)
-
-#define S_CF_PARITY_ERR    10
-#define M_CF_PARITY_ERR    0x3
-#define V_CF_PARITY_ERR(x) ((x) << S_CF_PARITY_ERR)
-#define G_CF_PARITY_ERR(x) (((x) >> S_CF_PARITY_ERR) & M_CF_PARITY_ERR)

+#define A_PCICFG_INTR_ENABLE 0xf4
 #define A_PCICFG_INTR_CAUSE 0xf8
+
 #define A_PCICFG_MODE 0xfc

 #define S_PCI_MODE_64BIT    0
 #define V_PCI_MODE_64BIT(x) ((x) << S_PCI_MODE_64BIT)
 #define F_PCI_MODE_64BIT    V_PCI_MODE_64BIT(1U)

-#define S_PCI_MODE_66MHZ    1
-#define V_PCI_MODE_66MHZ(x) ((x) << S_PCI_MODE_66MHZ)
-#define F_PCI_MODE_66MHZ    V_PCI_MODE_66MHZ(1U)
-
-#define S_PCI_MODE_PCIX_INITPAT    2
-#define M_PCI_MODE_PCIX_INITPAT    0x7
-#define V_PCI_MODE_PCIX_INITPAT(x) ((x) << S_PCI_MODE_PCIX_INITPAT)
-#define G_PCI_MODE_PCIX_INITPAT(x) (((x) >> S_PCI_MODE_PCIX_INITPAT) & M_PCI_MODE_PCIX_INITPAT)
-
 #define S_PCI_MODE_PCIX    5
 #define V_PCI_MODE_PCIX(x) ((x) << S_PCI_MODE_PCIX)
 #define F_PCI_MODE_PCIX    V_PCI_MODE_PCIX(1U)

 #define S_PCI_MODE_CLK    6
 #define M_PCI_MODE_CLK    0x3
-#define V_PCI_MODE_CLK(x) ((x) << S_PCI_MODE_CLK)
 #define G_PCI_MODE_CLK(x) (((x) >> S_PCI_MODE_CLK) & M_PCI_MODE_CLK)

diff -Naur linux-2.6.12-rc1-mm1/drivers/net/chelsio/sge.c linux-2.6.12-rc1-mm1.patched/drivers/net/chelsio/sge.c
--- linux-2.6.12-rc1-mm1/drivers/net/chelsio/sge.c	2005-03-22 13:05:45.000000000 -0800
+++ linux-2.6.12-rc1-mm1.patched/drivers/net/chelsio/sge.c	2005-03-22 23:56:44.000000000 -0800
@@ -1,34 +1,41 @@
-/*******************************************************************************
- *                                                                             *
- * File: sge.c                                                                 *
- * Revision: 1.5                                                               *
- * Date: 2005/03/11 06:48:09                                                   *
- * Description:                                                                *
- *  DMA engine.                                                                *
- *  part of the Chelsio 10Gb Ethernet Driver.                                  *
- *                                                                             *
- * This program is free software; you can redistribute it and/or modify        *
- * it under the terms of the GNU General Public License, version 2, as         *
- * published by the Free Software Foundation.                                  *
- *                                                                             *
- * You should have received a copy of the GNU General Public License along     *
- * with this program; if not, write to the Free Software Foundation, Inc.,     *
- * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.                   *
- *                                                                             *
- * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR IMPLIED      *
- * WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF        *
- * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.                       *
- *                                                                             *
- * http://www.chelsio.com                                                      *
- *                                                                             *
- * Copyright (c) 2003 - 2005 Chelsio Communications, Inc.                      *
- * All rights reserved.                                                        *
- *                                                                             *
- * Maintainers: maintainers@chelsio.com                                        *
- *                                                                             *
- * History:                                                                    *
- *                                                                             *
- ******************************************************************************/
+/*****************************************************************************
+ *                                                                           *
+ * File: sge.c                                                               *
+ * $Revision: 1.13 $                                                         *
+ * $Date: 2005/03/23 07:41:27 $                                              *
+ * Description:                                                              *
+ *  DMA engine.                                                              *
+ *  part of the Chelsio 10Gb Ethernet Driver.                                *
+ *                                                                           *
+ * This program is free software; you can redistribute it and/or modify      *
+ * it under the terms of the GNU General Public License, version 2, as       *
+ * published by the Free Software Foundation.                                *
+ *                                                                           *
+ * You should have received a copy of the GNU General Public License along   *
+ * with this program; if not, write to the Free Software Foundation, Inc.,   *
+ * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.                 *
+ *                                                                           *
+ * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR IMPLIED    *
+ * WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF      *
+ * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.                     *
+ *                                                                           *
+ * http://www.chelsio.com                                                    *
+ *                                                                           *
+ * Copyright (c) 2003 - 2005 Chelsio Communications, Inc.                    *
+ * All rights reserved.                                                      *
+ *                                                                           *
+ * Maintainers: maintainers@chelsio.com                                      *
+ *                                                                           *
+ * Authors: Dimitrios Michailidis   <dm@chelsio.com>                         *
+ *          Tina Yang               <tainay@chelsio.com>                     *
+ *          Felix Marti             <felix@chelsio.com>                      *
+ *          Scott Bardone           <sbardone@chelsio.com>                   *
+ *          Kurt Ottaway            <kottaway@chelsio.com>                   *
+ *          Frank DiMambro          <frank@chelsio.com>                      *
+ *                                                                           *
+ * History:                                                                  *
+ *                                                                           *
+ ****************************************************************************/

 #include "common.h"

@@ -51,10 +58,7 @@
 #include "regs.h"
 #include "espi.h"

-
-#ifdef NETIF_F_TSO
 #include <linux/tcp.h>
-#endif

 #define SGE_CMDQ_N		2
 #define SGE_FREELQ_N		2
@@ -207,7 +211,7 @@
 	u16		pidx;		/* producer index (SW) */
 	u16		cidx;		/* consumer index (HW) */
 	u16		rx_buffer_size; /* Buffer size on this free list */
-	u16             dma_offset;     /* DMA offset to align IP headers */
+	u16		dma_offset;     /* DMA offset to align IP headers */
 	u8		genbit;		/* current generation (=valid) bit */
 	struct freelQ_e	*entries;	/* HW freelist descriptor Q */
 	struct freelQ_ce *centries;	/* SW freelist conext descriptor Q */
@@ -250,6 +254,9 @@
 	struct cmdQ cmdQ[SGE_CMDQ_N] ____cacheline_aligned; /* command Q(s)*/
 };

+static unsigned int t1_sge_tx(struct sk_buff *skb, struct adapter *adapter,
+			unsigned int qid);
+
 /*
  * PIO to indicate that memory mapped Q contains valid descriptor(s).
  */
@@ -271,25 +278,25 @@
 }

 static u8 ch_mac_addr[ETH_ALEN] = {0x0, 0x7, 0x43, 0x0, 0x0, 0x0};
-void t1_espi_workaround(void *data)
+static void t1_espi_workaround(void *data)
 {
 	struct adapter *adapter = (struct adapter *)data;
 	struct sge *sge = adapter->sge;

-	if (netif_running(adapter->port[0].dev) &&
-	    atomic_read(&sge->cmdQ[0].asleep)) {
+	if (netif_running(adapter->port[0].dev) &&
+		atomic_read(&sge->cmdQ[0].asleep)) {

 		u32 seop = t1_espi_get_mon(adapter, 0x930, 0);
-
+
 		if ((seop & 0xfff0fff) == 0xfff && sge->pskb) {
-			struct sk_buff *skb = sge->pskb;
+			struct sk_buff *skb = sge->pskb;
 			if (!skb->cb[0]) {
 				memcpy(skb->data+sizeof(struct cpl_tx_pkt), ch_mac_addr, ETH_ALEN);
 				memcpy(skb->data+skb->len-10, ch_mac_addr, ETH_ALEN);
-
+
 				skb->cb[0] = 0xff;
 			}
-			t1_sge_tx(skb, adapter,0);
+			t1_sge_tx(skb, adapter,0);
 		}
 	}
 	mod_timer(&adapter->sge->ptimer, jiffies + sge->ptimeout);
@@ -335,7 +342,7 @@
 	p->freelQ_size[!sge->jumbo_fl] = SGE_FREEL_SIZE;
 	p->freelQ_size[sge->jumbo_fl] = SGE_JUMBO_FREEL_SIZE;
 	p->rx_coalesce_usecs = SGE_INTRTIMER1;
-	p->last_rx_coalesce_raw = SGE_INTRTIMER1 *
+	p->last_rx_coalesce_raw = SGE_INTRTIMER1 *
 	  (board_info(sge->adapter)->clock_core / 1000000);
 	p->default_rx_coalesce_usecs = SGE_INTRTIMER1;
 	p->coalesce_enable = 0;	/* Turn off adaptive algorithm by default */
@@ -414,11 +421,10 @@
 		if (!Q->entries)
 			goto err_no_mem;
 		memset(Q->entries, 0, size);
-		size = sizeof(struct freelQ_ce) * Q->entries_n;
-		Q->centries = (struct freelQ_ce *) kmalloc(size, GFP_KERNEL);
+		Q->centries = kcalloc(Q->entries_n, sizeof(struct freelQ_ce),
+				      GFP_KERNEL);
 		if (!Q->centries)
 			goto err_no_mem;
-		memset(Q->centries, 0, size);
 	}

 	/*
@@ -465,8 +471,8 @@
 	struct cmdQ_ce *ce, *cq = Q->centries;
 	unsigned int entries_n = Q->entries_n, cidx = Q->cidx,
 		     i = credits_pend;
-
-
+
+
 	ce = &cq[cidx];
 	while (i--) {
 		if (ce->single)
@@ -479,11 +485,11 @@
 				       PCI_DMA_TODEVICE);
 		if (totpayload)
 			*totpayload += pci_unmap_len(ce, dma_len);
-
+
 		skb = ce->skb;
 		if (skb)
 			dev_kfree_skb_irq(skb);
-
+
 		ce++;
 		if (++cidx == entries_n) {
 			cidx = 0;
@@ -546,11 +552,10 @@
 		if (!Q->entries)
 			goto err_no_mem;
 		memset(Q->entries, 0, size);
-		size = sizeof(struct cmdQ_ce) * Q->entries_n;
-		Q->centries = (struct cmdQ_ce *) kmalloc(size, GFP_KERNEL);
+		Q->centries = kcalloc(Q->entries_n, sizeof(struct cmdQ_ce),
+				      GFP_KERNEL);
 		if (!Q->centries)
 			goto err_no_mem;
-		memset(Q->centries, 0, size);
 	}

 	return 0;
@@ -611,7 +616,7 @@
 {
 	struct adapter *ap = sge->adapter;
 	int i;
-
+
 	t1_write_reg_4(ap, A_SG_CONTROL, 0);
 	setup_ring_params(ap, sge->cmdQ[0].dma_addr, sge->cmdQ[0].entries_n,
 			  A_SG_CMD0BASELWR, A_SG_CMD0BASEUPR, A_SG_CMD0SIZE);
@@ -855,7 +860,7 @@
 	if (cause & F_RESPQ_OVERFLOW) {
 		sge->intr_cnt.respQ_overflow++;
 		CH_ALERT("%s: SGE response queue overflow\n",
-			 adapter_name(adapter));
+			 adapter->name);
 	}
 	if (cause & F_FL_EXHAUSTED) {
 		sge->intr_cnt.freelistQ_empty++;
@@ -864,11 +869,11 @@
 	if (cause & F_PACKET_TOO_BIG) {
 		sge->intr_cnt.pkt_too_big++;
 		CH_ALERT("%s: SGE max packet size exceeded\n",
-			 adapter_name(adapter));
+			 adapter->name);
 	}
 	if (cause & F_PACKET_MISMATCH) {
 		sge->intr_cnt.pkt_mismatch++;
-		CH_ALERT("%s: SGE packet mismatch\n", adapter_name(adapter));
+		CH_ALERT("%s: SGE packet mismatch\n", adapter->name);
 	}
 	if (cause & SGE_INT_FATAL)
 		t1_fatal_err(adapter);
@@ -877,11 +882,6 @@
 	return 0;
 }

-const struct sge_intr_counts *t1_sge_get_intr_counts(struct sge *sge)
-{
-	return &sge->intr_cnt;
-}
-
 /*
  * The following code is copied from 2.6, where the skb_pull is doing the
  * right thing and only pulls ETH_HLEN.
@@ -999,7 +999,7 @@
 		skb->protocol = sge_eth_type_trans(skb, skb->dev);
 		if ((adapter->flags & RX_CSUM_ENABLED) && p->csum == 0xffff &&
 		    skb->protocol == htons(ETH_P_IP) &&
-		    (skb->data[9] == IPPROTO_TCP ||
+		    (skb->data[9] == IPPROTO_TCP ||
 		     skb->data[9] == IPPROTO_UDP))
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
 		else
@@ -1034,7 +1034,7 @@
 static inline void update_intr_timer(struct sge *sge, unsigned int avg_payload)
 {
 	unsigned int newIndex;
-
+
 	newIndex = avg_payload / SGE_INTR_BUCKETSIZE;
 	if (newIndex > SGE_INTR_MAXBUCKETS - 1) {
 		newIndex = SGE_INTR_MAXBUCKETS - 1;
@@ -1044,7 +1044,7 @@
 		t1_write_reg_4(sge->adapter, A_SG_INTRTIMER,
 			       sge->intrtimer[newIndex]);
 		sge->currIndex = newIndex;
-		sge->adapter->params.sge.last_rx_coalesce_raw =
+		sge->adapter->params.sge.last_rx_coalesce_raw =
 			sge->intrtimer[newIndex];
 	}
 }
@@ -1055,7 +1055,7 @@
  */
 static inline int enough_free_Tx_descs(struct sge *sge, int q_num)
 {
-	return atomic_read(&sge->cmdQ[q_num].credits) >
+	return atomic_read(&sge->cmdQ[q_num].credits) >
 		(sge->cmdQ[q_num].entries_n >> 2);
 }

@@ -1102,8 +1102,8 @@
 				BUG();
 			t1_sge_rx(sge, &sge->freelQ[e->FreelistQid],
 				  e->BufferLength, e->Offload);
-                        tot_rxpayload += e->BufferLength;
-                        ++n_rx;
+			tot_rxpayload += e->BufferLength;
+			++n_rx;
 		}
 		flags |= e->Qsleeping;
 		credits_pend[0] += e->Cmdq0CreditReturn;
@@ -1119,7 +1119,7 @@
 		 * this loop.
 		 */
 		if (unlikely(credits_pend[0] > SGE_FREEL_REFILL_THRESH)) {
-			free_cmdQ_buffers(sge, &sge->cmdQ[0], credits_pend[0],
+			free_cmdQ_buffers(sge, &sge->cmdQ[0], credits_pend[0],
 					  &tot_txpayload);
 			n_tx += credits_pend[0];
 			credits_pend[0] = 0;
@@ -1149,23 +1149,23 @@
 		n_tx += credits_pend[0] + credits_pend[1];

 		/*
-                 * Choose larger avg. payload size to increase
-                 * throughput and reduce [CPU util., intr/s.]
-                 *
-                 * Throughput behavior favored in mixed-mode.
+		 * Choose larger avg. payload size to increase
+		 * throughput and reduce [CPU util., intr/s.]
+		 *
+		 * Throughput behavior favored in mixed-mode.
 		 */
 		if (n_tx)
 			avg_txpayload = tot_txpayload/n_tx;
 		if (n_rx)
 			avg_rxpayload = tot_rxpayload/n_rx;
-
+
 		if (n_tx && avg_txpayload > avg_rxpayload){
 			update_intr_timer(sge, avg_txpayload);
 		} else if (n_rx) {
 			update_intr_timer(sge, avg_rxpayload);
 		}
-        }
-
+	}
+
 	if (flags & F_CMDQ0_ENABLE) {
 		struct cmdQ *cmdQ = &sge->cmdQ[0];

@@ -1201,7 +1201,7 @@
  * lock when we actually enqueue (which might be expensive, especially on
  * architectures with IO MMUs).
  */
-unsigned int t1_sge_tx(struct sk_buff *skb, struct adapter *adapter,
+static unsigned int t1_sge_tx(struct sk_buff *skb, struct adapter *adapter,
 		       unsigned int qid)
 {
 	struct sge *sge = adapter->sge;
@@ -1357,7 +1357,6 @@
 			return -ENOMEM;
 	}

-#ifdef NETIF_F_TSO
 	if (skb_shinfo(skb)->tso_size) {
 		int eth_type;
 		struct cpl_tx_pkt_lso *hdr;
@@ -1375,7 +1374,6 @@
 		hdr->len = htonl(skb->len - sizeof(*hdr));
 		cpl = (struct cpl_tx_pkt *)hdr;
 	} else
-#endif
 	{
 		/*
 		 * An Ethernet packet must have at least space for
@@ -1397,10 +1395,10 @@
 		    skb->nh.iph->protocol == IPPROTO_UDP &&
 		    skb_checksum_help(skb, 0))
 			goto t1_start_xmit_fail3;
-
+

 		if (!adapter->sge->pskb) {
-			if (skb->protocol == htons(ETH_P_ARP) &&
+			if (skb->protocol == htons(ETH_P_ARP) &&
 			    skb->nh.arph->ar_op == htons(ARPOP_REQUEST))
 				adapter->sge->pskb = skb;
 		}
diff -Naur linux-2.6.12-rc1-mm1/drivers/net/chelsio/sge.h linux-2.6.12-rc1-mm1.patched/drivers/net/chelsio/sge.h
--- linux-2.6.12-rc1-mm1/drivers/net/chelsio/sge.h	2005-03-22 13:05:45.000000000 -0800
+++ linux-2.6.12-rc1-mm1.patched/drivers/net/chelsio/sge.h	2005-03-22 23:56:44.000000000 -0800
@@ -1,33 +1,40 @@
-/*******************************************************************************
- *                                                                             *
- * File: sge.h                                                                 *
- * Revision: 1.3                                                               *
- * Date: 2005/03/10 20:47:04                                                   *
- * Description:                                                                *
- *  part of the Chelsio 10Gb Ethernet Driver.                                  *
- *                                                                             *
- * This program is free software; you can redistribute it and/or modify        *
- * it under the terms of the GNU General Public License, version 2, as         *
- * published by the Free Software Foundation.                                  *
- *                                                                             *
- * You should have received a copy of the GNU General Public License along     *
- * with this program; if not, write to the Free Software Foundation, Inc.,     *
- * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.                   *
- *                                                                             *
- * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR IMPLIED      *
- * WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF        *
- * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.                       *
- *                                                                             *
- * http://www.chelsio.com                                                      *
- *                                                                             *
- * Copyright (c) 2003 - 2005 Chelsio Communications, Inc.                      *
- * All rights reserved.                                                        *
- *                                                                             *
- * Maintainers: maintainers@chelsio.com                                        *
- *                                                                             *
- * History:                                                                    *
- *                                                                             *
- ******************************************************************************/
+/*****************************************************************************
+ *                                                                           *
+ * File: sge.h                                                               *
+ * $Revision: 1.7 $                                                          *
+ * $Date: 2005/03/23 07:15:59 $                                              *
+ * Description:                                                              *
+ *  part of the Chelsio 10Gb Ethernet Driver.                                *
+ *                                                                           *
+ * This program is free software; you can redistribute it and/or modify      *
+ * it under the terms of the GNU General Public License, version 2, as       *
+ * published by the Free Software Foundation.                                *
+ *                                                                           *
+ * You should have received a copy of the GNU General Public License along   *
+ * with this program; if not, write to the Free Software Foundation, Inc.,   *
+ * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.                 *
+ *                                                                           *
+ * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR IMPLIED    *
+ * WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF      *
+ * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.                     *
+ *                                                                           *
+ * http://www.chelsio.com                                                    *
+ *                                                                           *
+ * Copyright (c) 2003 - 2005 Chelsio Communications, Inc.                    *
+ * All rights reserved.                                                      *
+ *                                                                           *
+ * Maintainers: maintainers@chelsio.com                                      *
+ *                                                                           *
+ * Authors: Dimitrios Michailidis   <dm@chelsio.com>                         *
+ *          Tina Yang               <tainay@chelsio.com>                     *
+ *          Felix Marti             <felix@chelsio.com>                      *
+ *          Scott Bardone           <sbardone@chelsio.com>                   *
+ *          Kurt Ottaway            <kottaway@chelsio.com>                   *
+ *          Frank DiMambro          <frank@chelsio.com>                      *
+ *                                                                           *
+ * History:                                                                  *
+ *                                                                           *
+ ****************************************************************************/

 #ifndef _CHELSIO_LINUX_SGE_H_
 #define _CHELSIO_LINUX_SGE_H_
@@ -36,11 +43,6 @@
 #include <linux/interrupt.h>
 #include <asm/byteorder.h>

-#ifndef IRQ_RETVAL
-#define IRQ_RETVAL(x)
-typedef void irqreturn_t;
-#endif
-
 struct sge_intr_counts {
 	unsigned int respQ_empty;      /* # times respQ empty */
 	unsigned int respQ_overflow;   /* # respQ overflow (fatal) */
@@ -62,8 +64,6 @@
 int t1_sge_set_coalesce_params(struct sge *, struct sge_params *);
 void t1_sge_destroy(struct sge *);
 irqreturn_t t1_interrupt(int, void *, struct pt_regs *);
-unsigned int t1_sge_tx(struct sk_buff *skb, struct adapter *adapter,
-		       unsigned int qid);
 int t1_start_xmit(struct sk_buff *skb, struct net_device *dev);
 void t1_set_vlan_accel(struct adapter *adapter, int on_off);
 void t1_sge_start(struct sge *);
@@ -72,7 +72,6 @@
 void t1_sge_intr_enable(struct sge *);
 void t1_sge_intr_disable(struct sge *);
 void t1_sge_intr_clear(struct sge *);
-const struct sge_intr_counts *t1_sge_get_intr_counts(struct sge *sge);

 void t1_sge_set_ptimeout(adapter_t *adapter, u32 val);
 u32 t1_sge_get_ptimeout(adapter_t *adapter);
diff -Naur linux-2.6.12-rc1-mm1/drivers/net/chelsio/subr.c linux-2.6.12-rc1-mm1.patched/drivers/net/chelsio/subr.c
--- linux-2.6.12-rc1-mm1/drivers/net/chelsio/subr.c	2005-03-22 13:05:45.000000000 -0800
+++ linux-2.6.12-rc1-mm1.patched/drivers/net/chelsio/subr.c	2005-03-22 23:56:44.000000000 -0800
@@ -1,34 +1,41 @@
-/*******************************************************************************
- *                                                                             *
- * File: subr.c                                                                *
- * Revision: 1.5                                                               *
- * Date: 2005/03/11 06:48:09                                                   *
- * Description:                                                                *
- *  Various subroutines (intr,pio,etc.) used by Chelsio 10G Ethernet driver.   *
- *  part of the Chelsio 10Gb Ethernet Driver.                                  *
- *                                                                             *
- * This program is free software; you can redistribute it and/or modify        *
- * it under the terms of the GNU General Public License, version 2, as         *
- * published by the Free Software Foundation.                                  *
- *                                                                             *
- * You should have received a copy of the GNU General Public License along     *
- * with this program; if not, write to the Free Software Foundation, Inc.,     *
- * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.                   *
- *                                                                             *
- * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR IMPLIED      *
- * WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF        *
- * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.                       *
- *                                                                             *
- * http://www.chelsio.com                                                      *
- *                                                                             *
- * Copyright (c) 2003 - 2005 Chelsio Communications, Inc.                      *
- * All rights reserved.                                                        *
- *                                                                             *
- * Maintainers: maintainers@chelsio.com                                        *
- *                                                                             *
- * History:                                                                    *
- *                                                                             *
- ******************************************************************************/
+/*****************************************************************************
+ *                                                                           *
+ * File: subr.c                                                              *
+ * $Revision: 1.12 $                                                         *
+ * $Date: 2005/03/23 07:41:27 $                                              *
+ * Description:                                                              *
+ *  Various subroutines (intr,pio,etc.) used by Chelsio 10G Ethernet driver. *
+ *  part of the Chelsio 10Gb Ethernet Driver.                                *
+ *                                                                           *
+ * This program is free software; you can redistribute it and/or modify      *
+ * it under the terms of the GNU General Public License, version 2, as       *
+ * published by the Free Software Foundation.                                *
+ *                                                                           *
+ * You should have received a copy of the GNU General Public License along   *
+ * with this program; if not, write to the Free Software Foundation, Inc.,   *
+ * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.                 *
+ *                                                                           *
+ * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR IMPLIED    *
+ * WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF      *
+ * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.                     *
+ *                                                                           *
+ * http://www.chelsio.com                                                    *
+ *                                                                           *
+ * Copyright (c) 2003 - 2005 Chelsio Communications, Inc.                    *
+ * All rights reserved.                                                      *
+ *                                                                           *
+ * Maintainers: maintainers@chelsio.com                                      *
+ *                                                                           *
+ * Authors: Dimitrios Michailidis   <dm@chelsio.com>                         *
+ *          Tina Yang               <tainay@chelsio.com>                     *
+ *          Felix Marti             <felix@chelsio.com>                      *
+ *          Scott Bardone           <sbardone@chelsio.com>                   *
+ *          Kurt Ottaway            <kottaway@chelsio.com>                   *
+ *          Frank DiMambro          <frank@chelsio.com>                      *
+ *                                                                           *
+ * History:                                                                  *
+ *                                                                           *
+ ****************************************************************************/

 #include "common.h"
 #include "elmer0.h"
@@ -40,7 +47,6 @@
 #include "tp.h"
 #include "espi.h"

-
 /**
  *	t1_wait_op_done - wait until an operation is completed
  *	@adapter: the adapter performing the operation
@@ -54,7 +60,7 @@
  *	up to @attempts times.  Returns %0 if the operation completes and %1
  *	otherwise.
  */
-int t1_wait_op_done(adapter_t *adapter, int reg, u32 mask, int polarity,
+static int t1_wait_op_done(adapter_t *adapter, int reg, u32 mask, int polarity,
 		    int attempts, int delay)
 {
 	while (1) {
@@ -65,7 +71,7 @@
 		if (--attempts == 0)
 			return 1;
 		if (delay)
-			DELAY_US(delay);
+			udelay(delay);
 	}
 }

@@ -74,7 +80,7 @@
 /*
  * Write a register over the TPI interface (unlocked and locked versions).
  */
-int __t1_tpi_write(adapter_t *adapter, u32 addr, u32 value)
+static int __t1_tpi_write(adapter_t *adapter, u32 addr, u32 value)
 {
 	int tpi_busy;

@@ -86,7 +92,7 @@
 				   TPI_ATTEMPTS, 3);
 	if (tpi_busy)
 		CH_ALERT("%s: TPI write to 0x%x failed\n",
-			 adapter_name(adapter), addr);
+			 adapter->name, addr);
 	return tpi_busy;
 }

@@ -103,7 +109,7 @@
 /*
  * Read a register over the TPI interface (unlocked and locked versions).
  */
-int __t1_tpi_read(adapter_t *adapter, u32 addr, u32 *valp)
+static int __t1_tpi_read(adapter_t *adapter, u32 addr, u32 *valp)
 {
 	int tpi_busy;

@@ -114,7 +120,7 @@
 				   TPI_ATTEMPTS, 3);
 	if (tpi_busy)
 		CH_ALERT("%s: TPI read from 0x%x failed\n",
-			 adapter_name(adapter), addr);
+			 adapter->name, addr);
 	else
 		*valp = t1_read_reg_4(adapter, A_TPI_RD_DATA);
 	return tpi_busy;
@@ -170,10 +176,10 @@
 {
 	u32 pcix_cause;

-    	t1_pci_read_config_4(adapter, A_PCICFG_INTR_CAUSE, &pcix_cause);
+    	pci_read_config_dword(adapter->pdev, A_PCICFG_INTR_CAUSE, &pcix_cause);

 	if (pcix_cause) {
-		t1_pci_write_config_4(adapter, A_PCICFG_INTR_CAUSE,
+		pci_write_config_dword(adapter->pdev, A_PCICFG_INTR_CAUSE,
 					 pcix_cause);
 		t1_fatal_err(adapter);    /* PCI errors are fatal */
 	}
@@ -194,11 +200,11 @@
 		__t1_tpi_read(adapter, mi1_reg, &val);
 		busy = val & F_MI1_OP_BUSY;
 		if (busy)
-			DELAY_US(10);
+			udelay(10);
 	} while (busy && --attempts);
 	if (busy)
 		CH_ALERT("%s: MDIO operation timed out\n",
-			 adapter_name(adapter));
+			 adapter->name);
 	return busy;
 }

@@ -207,13 +213,13 @@
  */
 static void mi1_mdio_init(adapter_t *adapter, const struct board_info *bi)
 {
-        u32 clkdiv = bi->clock_elmer0 / (2 * bi->mdio_mdc) - 1;
-        u32 val = F_MI1_PREAMBLE_ENABLE | V_MI1_MDI_INVERT(bi->mdio_mdiinv) |
-                V_MI1_MDI_ENABLE(bi->mdio_mdien) | V_MI1_CLK_DIV(clkdiv);
+	u32 clkdiv = bi->clock_elmer0 / (2 * bi->mdio_mdc) - 1;
+	u32 val = F_MI1_PREAMBLE_ENABLE | V_MI1_MDI_INVERT(bi->mdio_mdiinv) |
+		V_MI1_MDI_ENABLE(bi->mdio_mdien) | V_MI1_CLK_DIV(clkdiv);

 	if (!(bi->caps & SUPPORTED_10000baseT_Full))
 		val |= V_MI1_SOF(1);
-        t1_tpi_write(adapter, A_ELMER0_PORT0_MI1_CFG, val);
+	t1_tpi_write(adapter, A_ELMER0_PORT0_MI1_CFG, val);
 }

 static int mi1_mdio_ext_read(adapter_t *adapter, int phy_addr, int mmd_addr,
@@ -299,10 +305,9 @@
 struct pci_device_id t1_pci_tbl[] = {
 	CH_DEVICE(7, 0, CH_BRD_N110_1F),
 	CH_DEVICE(10, 1, CH_BRD_N210_1F),
-        { 0, }
+	{ 0, }
 };

-#ifndef CH_DEVICE_COMMON
 /*
  * Return the board_info structure with a given index.  Out-of-range indices
  * return NULL.
@@ -311,29 +316,13 @@
 {
 	return board_id < DIMOF(t1_board) ? &t1_board[board_id] : NULL;
 }
-#else
-/*
- * Return the board_info structure that corresponds to a given PCI devid/ssid
- * pair.  Return NULL if the id combination is unknown.
- */
-const struct board_info *t1_get_board_info_from_ids(unsigned int devid,
-						    unsigned short ssid)
-{
-	struct pci_device_id *p;

-	for (p = t1_pci_tbl; p->devid; ++p)
-		if (p->devid == devid && p->ssid == ssid)
-			return &t1_board[p->board_info_index];
-	return NULL;
-}
-#endif
-
-typedef struct {
+struct chelsio_vpd_t {
 	u32 format_version;
 	u8 serial_number[16];
 	u8 mac_base_address[6];
 	u8 pad[2];           /* make multiple-of-4 size requirement explicit */
-} chelsio_vpd_t;
+};

 #define EEPROMSIZE        (8 * 1024)
 #define EEPROM_MAX_POLL   4
@@ -351,23 +340,23 @@
 	if (addr >= EEPROMSIZE || (addr & 3))
 		return -EINVAL;

-	t1_pci_write_config_2(adapter, A_PCICFG_VPD_ADDR, (u16)addr);
+	pci_write_config_word(adapter->pdev, A_PCICFG_VPD_ADDR, (u16)addr);
 	do {
-		DELAY_US(50);
-		t1_pci_read_config_2(adapter, A_PCICFG_VPD_ADDR, &val);
+		udelay(50);
+		pci_read_config_word(adapter->pdev, A_PCICFG_VPD_ADDR, &val);
 	} while (!(val & F_VPD_OP_FLAG) && --i);

 	if (!(val & F_VPD_OP_FLAG)) {
 		CH_ERR("%s: reading EEPROM address 0x%x failed\n",
-		       adapter_name(adapter), addr);
+		       adapter->name, addr);
 		return -EIO;
 	}
-	t1_pci_read_config_4(adapter, A_PCICFG_VPD_DATA, data);
+	pci_read_config_dword(adapter->pdev, A_PCICFG_VPD_DATA, data);
 	*data = le32_to_cpu(*data);
 	return 0;
 }

-static int t1_eeprom_vpd_get(adapter_t *adapter, chelsio_vpd_t *vpd)
+static int t1_eeprom_vpd_get(adapter_t *adapter, struct chelsio_vpd_t *vpd)
 {
 	int addr, ret = 0;

@@ -383,7 +372,7 @@
  */
 static int vpd_macaddress_get(adapter_t *adapter, int index, u8 mac_addr[])
 {
-	chelsio_vpd_t vpd;
+	struct chelsio_vpd_t vpd;

 	if (t1_eeprom_vpd_get(adapter, &vpd))
 		return 1;
@@ -462,15 +451,15 @@
     		CH_DBG(adapter, INTR, "External interrupt cause 0x%x\n",
 		       cause);
 		if (cause & ELMER0_GP_BIT1) {        /* PMC3393 INTB */
-        		struct cmac *mac = adapter->port[0].mac;
+			struct cmac *mac = adapter->port[0].mac;

-        		mac->ops->interrupt_handler(mac);
+			mac->ops->interrupt_handler(mac);
 		}
 		if (cause & ELMER0_GP_BIT5) {        /* XPAK MOD_DETECT */
 			u32 mod_detect;

-        		t1_tpi_read(adapter, A_ELMER0_GPI_STAT, &mod_detect);
-            		CH_MSG(adapter, INFO, LINK, "XPAK %s\n",
+			t1_tpi_read(adapter, A_ELMER0_GPI_STAT, &mod_detect);
+	    		CH_MSG(adapter, INFO, LINK, "XPAK %s\n",
 			       mod_detect ? "removed" : "inserted");
     		}
 		break;
@@ -499,12 +488,12 @@
 		adapter->port[i].phy->ops->interrupt_enable(adapter->port[i].phy);
 	}

-	/* Enable PCIX & external chip interrupts on ASIC boards. */
+	/* Enable PCIX & external chip interrupts on ASIC boards. */
 	if (t1_is_asic(adapter)) {
 		u32 pl_intr = t1_read_reg_4(adapter, A_PL_ENABLE);

 		/* PCI-X interrupts */
-		t1_pci_write_config_4(adapter, A_PCICFG_INTR_ENABLE,
+		pci_write_config_dword(adapter->pdev, A_PCICFG_INTR_ENABLE,
 					 0xffffffff);

 		adapter->slow_intr_mask |= F_PL_INTR_EXT | F_PL_INTR_PCIX;
@@ -529,12 +518,12 @@
 		adapter->port[i].phy->ops->interrupt_disable(adapter->port[i].phy);
 	}

-	/* Disable PCIX & external chip interrupts. */
+	/* Disable PCIX & external chip interrupts. */
 	if (t1_is_asic(adapter))
 	    	t1_write_reg_4(adapter, A_PL_ENABLE, 0);

 	/* PCI-X interrupts */
-	t1_pci_write_config_4(adapter, A_PCICFG_INTR_ENABLE, 0);
+	pci_write_config_dword(adapter->pdev, A_PCICFG_INTR_ENABLE, 0);

 	adapter->slow_intr_mask = 0;
 }
@@ -555,7 +544,7 @@
 		adapter->port[i].phy->ops->interrupt_clear(adapter->port[i].phy);
 	}

-	/* Enable interrupts for external devices. */
+	/* Enable interrupts for external devices. */
 	if (t1_is_asic(adapter)) {
 	    	u32 pl_intr = t1_read_reg_4(adapter, A_PL_CAUSE);

@@ -564,7 +553,7 @@
 	}

 	/* PCI-X interrupts */
-	t1_pci_write_config_4(adapter, A_PCICFG_INTR_CAUSE, 0xffffffff);
+	pci_write_config_dword(adapter->pdev, A_PCICFG_INTR_CAUSE, 0xffffffff);
 }

 /*
@@ -621,7 +610,7 @@
 	p->chip_version = bi->chip_term;
 	p->is_asic = (p->chip_version != CHBT_TERM_FPGA);
 	if (p->chip_version == CHBT_TERM_T1 ||
-	    p->chip_version == CHBT_TERM_T2 ||
+	    p->chip_version == CHBT_TERM_T2 ||
 	    p->chip_version == CHBT_TERM_FPGA) {
 		u32 val = t1_read_reg_4(adapter, A_TP_PC_CONFIG);

@@ -706,7 +695,7 @@
 	static unsigned short speed_map[] = { 33, 66, 100, 133 };
 	u32 pci_mode;

-	t1_pci_read_config_4(adapter, A_PCICFG_MODE, &pci_mode);
+	pci_read_config_dword(adapter->pdev, A_PCICFG_MODE, &pci_mode);
 	p->speed = speed_map[G_PCI_MODE_CLK(pci_mode)];
 	p->width = (pci_mode & F_PCI_MODE_64BIT) ? 64 : 32;
 	p->is_pcix = (pci_mode & F_PCI_MODE_PCIX) != 0;
@@ -727,13 +716,13 @@
 			mac->ops->destroy(mac);
 		if (phy)
 			phy->ops->destroy(phy);
-        }
+	}

-        if (adapter->sge)
+	if (adapter->sge)
 		t1_sge_destroy(adapter->sge);
-        if (adapter->tp)
+	if (adapter->tp)
 		t1_tp_destroy(adapter->tp);
-        if (adapter->espi)
+	if (adapter->espi)
 		t1_espi_destroy(adapter->espi);
 }

@@ -771,7 +760,7 @@
 	adapter->sge = t1_sge_create(adapter, &adapter->params.sge);
 	if (!adapter->sge) {
 		CH_ERR("%s: SGE initialization failed\n",
-		       adapter_name(adapter));
+		       adapter->name);
 		goto error;
 	}

@@ -779,23 +768,23 @@

 	if (bi->espi_nports && !(adapter->espi = t1_espi_create(adapter))) {
 		CH_ERR("%s: ESPI initialization failed\n",
-		       adapter_name(adapter));
+		       adapter->name);
 		goto error;
 	}

-        adapter->tp = t1_tp_create(adapter, &adapter->params.tp);
+	adapter->tp = t1_tp_create(adapter, &adapter->params.tp);
 	if (!adapter->tp) {
 		CH_ERR("%s: TP initialization failed\n",
-		       adapter_name(adapter));
+		       adapter->name);
 		goto error;
 	}

 	board_init(adapter, bi);
 	bi->mdio_ops->init(adapter, bi);
-        if (bi->gphy->reset)
-                bi->gphy->reset(adapter);
-        if (bi->gmac->reset)
-                bi->gmac->reset(adapter);
+	if (bi->gphy->reset)
+		bi->gphy->reset(adapter);
+	if (bi->gmac->reset)
+		bi->gmac->reset(adapter);

 	for_each_port(adapter, i) {
 		u8 hw_addr[6];
@@ -806,14 +795,14 @@
 							bi->mdio_ops);
 		if (!adapter->port[i].phy) {
 			CH_ERR("%s: PHY %d initialization failed\n",
-			       adapter_name(adapter), i);
+			       adapter->name, i);
 			goto error;
 		}

 		adapter->port[i].mac = mac = bi->gmac->create(adapter, i);
 		if (!mac) {
 			CH_ERR("%s: MAC %d initialization failed\n",
-			       adapter_name(adapter), i);
+			       adapter->name, i);
 			goto error;
 		}

diff -Naur linux-2.6.12-rc1-mm1/drivers/net/chelsio/suni1x10gexp_regs.h linux-2.6.12-rc1-mm1.patched/drivers/net/chelsio/suni1x10gexp_regs.h
--- linux-2.6.12-rc1-mm1/drivers/net/chelsio/suni1x10gexp_regs.h	2005-03-22 13:05:45.000000000 -0800
+++ linux-2.6.12-rc1-mm1.patched/drivers/net/chelsio/suni1x10gexp_regs.h	2005-03-22 23:56:44.000000000 -0800
@@ -1,63 +1,45 @@
-/*******************************************************************************
- *                                                                             *
- * File: suni1x10gexp_regs.h                                                   *
- * Revision: 1.2                                                               *
- * Date: 2005/03/10 07:07:38                                                   *
- * Description:                                                                *
- *  PMC/SIERRA (pm3393) MAC-PHY functionality.                                 *
- *  part of the Chelsio 10Gb Ethernet Driver.                                  *
- *                                                                             *
- * This program is free software; you can redistribute it and/or modify        *
- * it under the terms of the GNU General Public License, version 2, as         *
- * published by the Free Software Foundation.                                  *
- *                                                                             *
- * You should have received a copy of the GNU General Public License along     *
- * with this program; if not, write to the Free Software Foundation, Inc.,     *
- * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.                   *
- *                                                                             *
- * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR IMPLIED      *
- * WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF        *
- * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.                       *
- *                                                                             *
- * http://www.chelsio.com                                                      *
- *                                                                             *
- * Copyright (c) 2003 - 2005 Chelsio Communications, Inc.                      *
- * All rights reserved.                                                        *
- *                                                                             *
- * Maintainers: maintainers@chelsio.com                                        *
- *                                                                             *
- * History:                                                                    *
- *                                                                             *
- ******************************************************************************/
+/*****************************************************************************
+ *                                                                           *
+ * File: suni1x10gexp_regs.h                                                 *
+ * $Revision: 1.4 $                                                          *
+ * $Date: 2005/03/23 07:15:59 $                                              *
+ * Description:                                                              *
+ *  PMC/SIERRA (pm3393) MAC-PHY functionality.                               *
+ *  part of the Chelsio 10Gb Ethernet Driver.                                *
+ *                                                                           *
+ * This program is free software; you can redistribute it and/or modify      *
+ * it under the terms of the GNU General Public License, version 2, as       *
+ * published by the Free Software Foundation.                                *
+ *                                                                           *
+ * You should have received a copy of the GNU General Public License along   *
+ * with this program; if not, write to the Free Software Foundation, Inc.,   *
+ * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.                 *
+ *                                                                           *
+ * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR IMPLIED    *
+ * WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF      *
+ * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.                     *
+ *                                                                           *
+ * http://www.chelsio.com                                                    *
+ *                                                                           *
+ * Copyright (c) 2003 - 2005 Chelsio Communications, Inc.                    *
+ * All rights reserved.                                                      *
+ *                                                                           *
+ * Maintainers: maintainers@chelsio.com                                      *
+ *                                                                           *
+ * Authors: Dimitrios Michailidis   <dm@chelsio.com>                         *
+ *          Tina Yang               <tainay@chelsio.com>                     *
+ *          Felix Marti             <felix@chelsio.com>                      *
+ *          Scott Bardone           <sbardone@chelsio.com>                   *
+ *          Kurt Ottaway            <kottaway@chelsio.com>                   *
+ *          Frank DiMambro          <frank@chelsio.com>                      *
+ *                                                                           *
+ * History:                                                                  *
+ *                                                                           *
+ ****************************************************************************/

 #ifndef _SUNI1x10GEXP_REGS_H
 #define _SUNI1x10GEXP_REGS_H

-
-/*
-** Space allocated for each Exact Match Filter
-**     There are 8 filter configurations
-*/
-#define SUNI1x10GEXP_REG_SIZEOF_MAC_FILTER 0x0003
-
-#define mSUNI1x10GEXP_MAC_FILTER_OFFSET(filterId)       ( (filterId) * SUNI1x10GEXP_REG_SIZEOF_MAC_FILTER )
-
-/*
-** Space allocated for VLAN-Id Filter
-**      There are 8 filter configurations
-*/
-#define SUNI1x10GEXP_REG_SIZEOF_MAC_VID_FILTER 0x0001
-
-#define mSUNI1x10GEXP_MAC_VID_FILTER_OFFSET(filterId)   ( (filterId) * SUNI1x10GEXP_REG_SIZEOF_MAC_VID_FILTER )
-
-/*
-** Space allocated for each MSTAT Counter
-*/
-#define SUNI1x10GEXP_REG_SIZEOF_MSTAT_COUNT 0x0004
-
-#define mSUNI1x10GEXP_MSTAT_COUNT_OFFSET(countId)       ( (countId) * SUNI1x10GEXP_REG_SIZEOF_MSTAT_COUNT )
-
-
 /******************************************************************************/
 /** S/UNI-1x10GE-XP REGISTER ADDRESS MAP                                     **/
 /******************************************************************************/
@@ -65,125 +47,33 @@
 /* to the S/UNI-1x10GE-XP Data Sheet for the signification of each bit        */
 /******************************************************************************/

-
-#define SUNI1x10GEXP_REG_IDENTIFICATION                                  0x0000
-#define SUNI1x10GEXP_REG_PRODUCT_REVISION                                0x0001
-#define SUNI1x10GEXP_REG_CONFIG_AND_RESET_CONTROL                        0x0002
-#define SUNI1x10GEXP_REG_LOOPBACK_MISC_CTRL                              0x0003
 #define SUNI1x10GEXP_REG_DEVICE_STATUS                                   0x0004
-#define SUNI1x10GEXP_REG_GLOBAL_PERFORMANCE_MONITOR_UPDATE               0x0005
-
-#define SUNI1x10GEXP_REG_MDIO_COMMAND                                    0x0006
-#define SUNI1x10GEXP_REG_MDIO_INTERRUPT_ENABLE                           0x0007
-#define SUNI1x10GEXP_REG_MDIO_INTERRUPT_STATUS                           0x0008
-#define SUNI1x10GEXP_REG_MMD_PHY_ADDRESS                                 0x0009
-#define SUNI1x10GEXP_REG_MMD_CONTROL_ADDRESS_DATA                        0x000A
-#define SUNI1x10GEXP_REG_MDIO_READ_STATUS_DATA                           0x000B
-
-#define SUNI1x10GEXP_REG_OAM_INTF_CTRL                                   0x000C
 #define SUNI1x10GEXP_REG_MASTER_INTERRUPT_STATUS                         0x000D
 #define SUNI1x10GEXP_REG_GLOBAL_INTERRUPT_ENABLE                         0x000E
-#define SUNI1x10GEXP_REG_FREE                                            0x000F
-
-#define SUNI1x10GEXP_REG_XTEF_MISC_CTRL                                  0x0010
-#define SUNI1x10GEXP_REG_XRF_MISC_CTRL                                   0x0011
-
-#define SUNI1x10GEXP_REG_SERDES_3125_CONFIG_1                            0x0100
-#define SUNI1x10GEXP_REG_SERDES_3125_CONFIG_2                            0x0101
 #define SUNI1x10GEXP_REG_SERDES_3125_INTERRUPT_ENABLE                    0x0102
-#define SUNI1x10GEXP_REG_SERDES_3125_INTERRUPT_VISIBLE                   0x0103
 #define SUNI1x10GEXP_REG_SERDES_3125_INTERRUPT_STATUS                    0x0104
-#define SUNI1x10GEXP_REG_SERDES_3125_TEST_CONFIG                         0x0107
-
 #define SUNI1x10GEXP_REG_RXXG_CONFIG_1                                   0x2040
-#define SUNI1x10GEXP_REG_RXXG_CONFIG_2                                   0x2041
 #define SUNI1x10GEXP_REG_RXXG_CONFIG_3                                   0x2042
 #define SUNI1x10GEXP_REG_RXXG_INTERRUPT                                  0x2043
 #define SUNI1x10GEXP_REG_RXXG_MAX_FRAME_LENGTH                           0x2045
 #define SUNI1x10GEXP_REG_RXXG_SA_15_0                                    0x2046
 #define SUNI1x10GEXP_REG_RXXG_SA_31_16                                   0x2047
 #define SUNI1x10GEXP_REG_RXXG_SA_47_32                                   0x2048
-#define SUNI1x10GEXP_REG_RXXG_RECEIVE_FIFO_THRESHOLD                     0x2049
-#define mSUNI1x10GEXP_REG_RXXG_EXACT_MATCH_ADDR_LOW(filterId) (0x204A + mSUNI1x10GEXP_MAC_FILTER_OFFSET(filterId))
-#define mSUNI1x10GEXP_REG_RXXG_EXACT_MATCH_ADDR_MID(filterId) (0x204B + mSUNI1x10GEXP_MAC_FILTER_OFFSET(filterId))
-#define mSUNI1x10GEXP_REG_RXXG_EXACT_MATCH_ADDR_HIGH(filterId)(0x204C + mSUNI1x10GEXP_MAC_FILTER_OFFSET(filterId))
-#define mSUNI1x10GEXP_REG_RXXG_EXACT_MATCH_VID(filterId)      (0x2062 + mSUNI1x10GEXP_MAC_VID_FILTER_OFFSET(filterId)
-#define SUNI1x10GEXP_REG_RXXG_EXACT_MATCH_ADDR_0_LOW                     0x204A
-#define SUNI1x10GEXP_REG_RXXG_EXACT_MATCH_ADDR_0_MID                     0x204B
-#define SUNI1x10GEXP_REG_RXXG_EXACT_MATCH_ADDR_0_HIGH                    0x204C
 #define SUNI1x10GEXP_REG_RXXG_EXACT_MATCH_ADDR_1_LOW                     0x204D
 #define SUNI1x10GEXP_REG_RXXG_EXACT_MATCH_ADDR_1_MID                     0x204E
 #define SUNI1x10GEXP_REG_RXXG_EXACT_MATCH_ADDR_1_HIGH                    0x204F
-#define SUNI1x10GEXP_REG_RXXG_EXACT_MATCH_ADDR_2_LOW                     0x2050
-#define SUNI1x10GEXP_REG_RXXG_EXACT_MATCH_ADDR_2_MID                     0x2051
-#define SUNI1x10GEXP_REG_RXXG_EXACT_MATCH_ADDR_2_HIGH                    0x2052
-#define SUNI1x10GEXP_REG_RXXG_EXACT_MATCH_ADDR_3_LOW                     0x2053
-#define SUNI1x10GEXP_REG_RXXG_EXACT_MATCH_ADDR_3_MID                     0x2054
-#define SUNI1x10GEXP_REG_RXXG_EXACT_MATCH_ADDR_3_HIGH                    0x2055
-#define SUNI1x10GEXP_REG_RXXG_EXACT_MATCH_ADDR_4_LOW                     0x2056
-#define SUNI1x10GEXP_REG_RXXG_EXACT_MATCH_ADDR_4_MID                     0x2057
-#define SUNI1x10GEXP_REG_RXXG_EXACT_MATCH_ADDR_4_HIGH                    0x2058
-#define SUNI1x10GEXP_REG_RXXG_EXACT_MATCH_ADDR_5_LOW                     0x2059
-#define SUNI1x10GEXP_REG_RXXG_EXACT_MATCH_ADDR_5_MID                     0x205A
-#define SUNI1x10GEXP_REG_RXXG_EXACT_MATCH_ADDR_5_HIGH                    0x205B
-#define SUNI1x10GEXP_REG_RXXG_EXACT_MATCH_ADDR_6_LOW                     0x205C
-#define SUNI1x10GEXP_REG_RXXG_EXACT_MATCH_ADDR_6_MID                     0x205D
-#define SUNI1x10GEXP_REG_RXXG_EXACT_MATCH_ADDR_6_HIGH                    0x205E
-#define SUNI1x10GEXP_REG_RXXG_EXACT_MATCH_ADDR_7_LOW                     0x205F
-#define SUNI1x10GEXP_REG_RXXG_EXACT_MATCH_ADDR_7_MID                     0x2060
-#define SUNI1x10GEXP_REG_RXXG_EXACT_MATCH_ADDR_7_HIGH                    0x2061
-#define SUNI1x10GEXP_REG_RXXG_EXACT_MATCH_VID_0                          0x2062
-#define SUNI1x10GEXP_REG_RXXG_EXACT_MATCH_VID_1                          0x2063
-#define SUNI1x10GEXP_REG_RXXG_EXACT_MATCH_VID_2                          0x2064
-#define SUNI1x10GEXP_REG_RXXG_EXACT_MATCH_VID_3                          0x2065
-#define SUNI1x10GEXP_REG_RXXG_EXACT_MATCH_VID_4                          0x2066
-#define SUNI1x10GEXP_REG_RXXG_EXACT_MATCH_VID_5                          0x2067
-#define SUNI1x10GEXP_REG_RXXG_EXACT_MATCH_VID_6                          0x2068
-#define SUNI1x10GEXP_REG_RXXG_EXACT_MATCH_VID_7                          0x2069
 #define SUNI1x10GEXP_REG_RXXG_MULTICAST_HASH_LOW                         0x206A
 #define SUNI1x10GEXP_REG_RXXG_MULTICAST_HASH_MIDLOW                      0x206B
 #define SUNI1x10GEXP_REG_RXXG_MULTICAST_HASH_MIDHIGH                     0x206C
 #define SUNI1x10GEXP_REG_RXXG_MULTICAST_HASH_HIGH                        0x206D
 #define SUNI1x10GEXP_REG_RXXG_ADDRESS_FILTER_CONTROL_0                   0x206E
-#define SUNI1x10GEXP_REG_RXXG_ADDRESS_FILTER_CONTROL_1                   0x206F
 #define SUNI1x10GEXP_REG_RXXG_ADDRESS_FILTER_CONTROL_2                   0x2070
-
-#define SUNI1x10GEXP_REG_XRF_PATTERN_GEN_CTRL                            0x2081
-#define SUNI1x10GEXP_REG_XRF_8BTB_ERR_COUNT_LANE_0                       0x2084
-#define SUNI1x10GEXP_REG_XRF_8BTB_ERR_COUNT_LANE_1                       0x2085
-#define SUNI1x10GEXP_REG_XRF_8BTB_ERR_COUNT_LANE_2                       0x2086
-#define SUNI1x10GEXP_REG_XRF_8BTB_ERR_COUNT_LANE_3                       0x2087
 #define SUNI1x10GEXP_REG_XRF_INTERRUPT_ENABLE                            0x2088
 #define SUNI1x10GEXP_REG_XRF_INTERRUPT_STATUS                            0x2089
-#define SUNI1x10GEXP_REG_XRF_ERR_STATUS                                  0x208A
 #define SUNI1x10GEXP_REG_XRF_DIAG_INTERRUPT_ENABLE                       0x208B
 #define SUNI1x10GEXP_REG_XRF_DIAG_INTERRUPT_STATUS                       0x208C
-#define SUNI1x10GEXP_REG_XRF_CODE_ERR_THRES                              0x2092
-
-#define SUNI1x10GEXP_REG_RXOAM_CONFIG                                    0x20C0
-#define SUNI1x10GEXP_REG_RXOAM_FILTER_1_CONFIG                           0x20C1
-#define SUNI1x10GEXP_REG_RXOAM_FILTER_2_CONFIG                           0x20C2
-#define SUNI1x10GEXP_REG_RXOAM_CONFIG_2                                  0x20C3
-#define SUNI1x10GEXP_REG_RXOAM_HEC_CONFIG                                0x20C4
-#define SUNI1x10GEXP_REG_RXOAM_HEC_ERR_THRES                             0x20C5
 #define SUNI1x10GEXP_REG_RXOAM_INTERRUPT_ENABLE                          0x20C7
 #define SUNI1x10GEXP_REG_RXOAM_INTERRUPT_STATUS                          0x20C8
-#define SUNI1x10GEXP_REG_RXOAM_STATUS                                    0x20C9
-#define SUNI1x10GEXP_REG_RXOAM_HEC_ERR_COUNT                             0x20CA
-#define SUNI1x10GEXP_REG_RXOAM_FIFO_OVERFLOW_COUNT                       0x20CB
-#define SUNI1x10GEXP_REG_RXOAM_FILTER_MISMATCH_COUNT_LSB                 0x20CC
-#define SUNI1x10GEXP_REG_RXOAM_FILTER_MISMATCH_COUNT_MSB                 0x20CD
-#define SUNI1x10GEXP_REG_RXOAM_FILTER_1_MISMATCH_COUNT_LSB               0x20CE
-#define SUNI1x10GEXP_REG_RXOAM_FILTER_1_MISMATCH_COUNT_MSB               0x20CF
-#define SUNI1x10GEXP_REG_RXOAM_FILTER_2_MISMATCH_COUNT_LSB               0x20D0
-#define SUNI1x10GEXP_REG_RXOAM_FILTER_2_MISMATCH_COUNT_MSB               0x20D1
-#define SUNI1x10GEXP_REG_RXOAM_OAM_EXTRACT_COUNT_LSB                     0x20D2
-#define SUNI1x10GEXP_REG_RXOAM_OAM_EXTRACT_COUNT_MSB                     0x20D3
-#define SUNI1x10GEXP_REG_RXOAM_MINI_PACKET_COUNT_LSB                     0x20D4
-#define SUNI1x10GEXP_REG_RXOAM_MINI_PACKET_COUNT_MSB                     0x20D5
-#define SUNI1x10GEXP_REG_RXOAM_FILTER_MISMATCH_THRES_LSB                 0x20D6
-#define SUNI1x10GEXP_REG_RXOAM_FILTER_MISMATCH_THRES_MSB                 0x20D7
-
 #define SUNI1x10GEXP_REG_MSTAT_CONTROL                                   0x2100
 #define SUNI1x10GEXP_REG_MSTAT_COUNTER_ROLLOVER_0                        0x2101
 #define SUNI1x10GEXP_REG_MSTAT_COUNTER_ROLLOVER_1                        0x2102
@@ -193,321 +83,50 @@
 #define SUNI1x10GEXP_REG_MSTAT_INTERRUPT_MASK_1                          0x2106
 #define SUNI1x10GEXP_REG_MSTAT_INTERRUPT_MASK_2                          0x2107
 #define SUNI1x10GEXP_REG_MSTAT_INTERRUPT_MASK_3                          0x2108
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_WRITE_ADDRESS                     0x2109
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_WRITE_DATA_LOW                    0x210A
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_WRITE_DATA_MIDDLE                 0x210B
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_WRITE_DATA_HIGH                   0x210C
-#define mSUNI1x10GEXP_REG_MSTAT_COUNTER_LOW(countId)   (0x2110 + mSUNI1x10GEXP_MSTAT_COUNT_OFFSET(countId))
-#define mSUNI1x10GEXP_REG_MSTAT_COUNTER_MID(countId)   (0x2111 + mSUNI1x10GEXP_MSTAT_COUNT_OFFSET(countId))
-#define mSUNI1x10GEXP_REG_MSTAT_COUNTER_HIGH(countId)  (0x2112 + mSUNI1x10GEXP_MSTAT_COUNT_OFFSET(countId))
 #define SUNI1x10GEXP_REG_MSTAT_COUNTER_0_LOW                             0x2110
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_0_MID                             0x2111
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_0_HIGH                            0x2112
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_0_RESVD                           0x2113
 #define SUNI1x10GEXP_REG_MSTAT_COUNTER_1_LOW                             0x2114
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_1_MID                             0x2115
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_1_HIGH                            0x2116
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_1_RESVD                           0x2117
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_2_LOW                             0x2118
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_2_MID                             0x2119
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_2_HIGH                            0x211A
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_2_RESVD                           0x211B
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_3_LOW                             0x211C
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_3_MID                             0x211D
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_3_HIGH                            0x211E
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_3_RESVD                           0x211F
 #define SUNI1x10GEXP_REG_MSTAT_COUNTER_4_LOW                             0x2120
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_4_MID                             0x2121
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_4_HIGH                            0x2122
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_4_RESVD                           0x2123
 #define SUNI1x10GEXP_REG_MSTAT_COUNTER_5_LOW                             0x2124
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_5_MID                             0x2125
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_5_HIGH                            0x2126
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_5_RESVD                           0x2127
 #define SUNI1x10GEXP_REG_MSTAT_COUNTER_6_LOW                             0x2128
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_6_MID                             0x2129
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_6_HIGH                            0x212A
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_6_RESVD                           0x212B
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_7_LOW                             0x212C
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_7_MID                             0x212D
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_7_HIGH                            0x212E
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_7_RESVD                           0x212F
 #define SUNI1x10GEXP_REG_MSTAT_COUNTER_8_LOW                             0x2130
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_8_MID                             0x2131
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_8_HIGH                            0x2132
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_8_RESVD                           0x2133
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_9_LOW                             0x2134
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_9_MID                             0x2135
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_9_HIGH                            0x2136
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_9_RESVD                           0x2137
 #define SUNI1x10GEXP_REG_MSTAT_COUNTER_10_LOW                            0x2138
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_10_MID                            0x2139
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_10_HIGH                           0x213A
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_10_RESVD                          0x213B
 #define SUNI1x10GEXP_REG_MSTAT_COUNTER_11_LOW                            0x213C
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_11_MID                            0x213D
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_11_HIGH                           0x213E
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_11_RESVD                          0x213F
 #define SUNI1x10GEXP_REG_MSTAT_COUNTER_12_LOW                            0x2140
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_12_MID                            0x2141
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_12_HIGH                           0x2142
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_12_RESVD                          0x2143
 #define SUNI1x10GEXP_REG_MSTAT_COUNTER_13_LOW                            0x2144
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_13_MID                            0x2145
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_13_HIGH                           0x2146
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_13_RESVD                          0x2147
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_14_LOW                            0x2148
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_14_MID                            0x2149
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_14_HIGH                           0x214A
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_14_RESVD                          0x214B
 #define SUNI1x10GEXP_REG_MSTAT_COUNTER_15_LOW                            0x214C
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_15_MID                            0x214D
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_15_HIGH                           0x214E
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_15_RESVD                          0x214F
 #define SUNI1x10GEXP_REG_MSTAT_COUNTER_16_LOW                            0x2150
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_16_MID                            0x2151
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_16_HIGH                           0x2152
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_16_RESVD                          0x2153
 #define SUNI1x10GEXP_REG_MSTAT_COUNTER_17_LOW                            0x2154
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_17_MID                            0x2155
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_17_HIGH                           0x2156
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_17_RESVD                          0x2157
 #define SUNI1x10GEXP_REG_MSTAT_COUNTER_18_LOW                            0x2158
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_18_MID                            0x2159
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_18_HIGH                           0x215A
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_18_RESVD                          0x215B
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_19_LOW                            0x215C
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_19_MID                            0x215D
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_19_HIGH                           0x215E
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_19_RESVD                          0x215F
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_20_LOW                            0x2160
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_20_MID                            0x2161
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_20_HIGH                           0x2162
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_20_RESVD                          0x2163
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_21_LOW                            0x2164
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_21_MID                            0x2165
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_21_HIGH                           0x2166
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_21_RESVD                          0x2167
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_22_LOW                            0x2168
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_22_MID                            0x2169
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_22_HIGH                           0x216A
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_22_RESVD                          0x216B
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_23_LOW                            0x216C
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_23_MID                            0x216D
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_23_HIGH                           0x216E
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_23_RESVD                          0x216F
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_24_LOW                            0x2170
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_24_MID                            0x2171
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_24_HIGH                           0x2172
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_24_RESVD                          0x2173
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_25_LOW                            0x2174
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_25_MID                            0x2175
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_25_HIGH                           0x2176
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_25_RESVD                          0x2177
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_26_LOW                            0x2178
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_26_MID                            0x2179
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_26_HIGH                           0x217a
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_26_RESVD                          0x217b
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_27_LOW                            0x217c
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_27_MID                            0x217d
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_27_HIGH                           0x217e
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_27_RESVD                          0x217f
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_28_LOW                            0x2180
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_28_MID                            0x2181
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_28_HIGH                           0x2182
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_28_RESVD                          0x2183
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_29_LOW                            0x2184
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_29_MID                            0x2185
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_29_HIGH                           0x2186
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_29_RESVD                          0x2187
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_30_LOW                            0x2188
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_30_MID                            0x2189
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_30_HIGH                           0x218A
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_30_RESVD                          0x218B
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_31_LOW                            0x218C
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_31_MID                            0x218D
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_31_HIGH                           0x218E
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_31_RESVD                          0x218F
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_32_LOW                            0x2190
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_32_MID                            0x2191
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_32_HIGH                           0x2192
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_32_RESVD                          0x2193
 #define SUNI1x10GEXP_REG_MSTAT_COUNTER_33_LOW                            0x2194
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_33_MID                            0x2195
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_33_HIGH                           0x2196
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_33_RESVD                          0x2197
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_34_LOW                            0x2198
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_34_MID                            0x2199
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_34_HIGH                           0x219A
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_34_RESVD                          0x219B
 #define SUNI1x10GEXP_REG_MSTAT_COUNTER_35_LOW                            0x219C
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_35_MID                            0x219D
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_35_HIGH                           0x219E
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_35_RESVD                          0x219F
 #define SUNI1x10GEXP_REG_MSTAT_COUNTER_36_LOW                            0x21A0
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_36_MID                            0x21A1
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_36_HIGH                           0x21A2
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_36_RESVD                          0x21A3
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_37_LOW                            0x21A4
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_37_MID                            0x21A5
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_37_HIGH                           0x21A6
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_37_RESVD                          0x21A7
 #define SUNI1x10GEXP_REG_MSTAT_COUNTER_38_LOW                            0x21A8
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_38_MID                            0x21A9
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_38_HIGH                           0x21AA
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_38_RESVD                          0x21AB
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_39_LOW                            0x21AC
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_39_MID                            0x21AD
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_39_HIGH                           0x21AE
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_39_RESVD                          0x21AF
 #define SUNI1x10GEXP_REG_MSTAT_COUNTER_40_LOW                            0x21B0
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_40_MID                            0x21B1
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_40_HIGH                           0x21B2
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_40_RESVD                          0x21B3
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_41_LOW                            0x21B4
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_41_MID                            0x21B5
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_41_HIGH                           0x21B6
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_41_RESVD                          0x21B7
 #define SUNI1x10GEXP_REG_MSTAT_COUNTER_42_LOW                            0x21B8
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_42_MID                            0x21B9
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_42_HIGH                           0x21BA
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_42_RESVD                          0x21BB
 #define SUNI1x10GEXP_REG_MSTAT_COUNTER_43_LOW                            0x21BC
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_43_MID                            0x21BD
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_43_HIGH                           0x21BE
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_43_RESVD                          0x21BF
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_44_LOW                            0x21C0
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_44_MID                            0x21C1
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_44_HIGH                           0x21C2
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_44_RESVD                          0x21C3
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_45_LOW                            0x21C4
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_45_MID                            0x21C5
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_45_HIGH                           0x21C6
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_45_RESVD                          0x21C7
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_46_LOW                            0x21C8
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_46_MID                            0x21C9
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_46_HIGH                           0x21CA
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_46_RESVD                          0x21CB
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_47_LOW                            0x21CC
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_47_MID                            0x21CD
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_47_HIGH                           0x21CE
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_47_RESVD                          0x21CF
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_48_LOW                            0x21D0
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_48_MID                            0x21D1
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_48_HIGH                           0x21D2
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_48_RESVD                          0x21D3
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_49_LOW                            0x21D4
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_49_MID                            0x21D5
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_49_HIGH                           0x21D6
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_49_RESVD                          0x21D7
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_50_LOW                            0x21D8
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_50_MID                            0x21D9
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_50_HIGH                           0x21DA
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_50_RESVD                          0x21DB
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_51_LOW                            0x21DC
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_51_MID                            0x21DD
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_51_HIGH                           0x21DE
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_51_RESVD                          0x21DF
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_52_LOW                            0x21E0
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_52_MID                            0x21E1
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_52_HIGH                           0x21E2
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_52_RESVD                          0x21E3
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_53_LOW                            0x21E4
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_53_MID                            0x21E5
-#define SUNI1x10GEXP_REG_MSTAT_COUNTER_53_HIGH                           0x21E6
-#define SUNI1x10GEXP_CNTR_MAC_ETHERNET_NUM                               51
-
-#define SUNI1x10GEXP_REG_IFLX_GLOBAL_CONFIG                              0x2200
-#define SUNI1x10GEXP_REG_IFLX_CHANNEL_PROVISION                          0x2201
 #define SUNI1x10GEXP_REG_IFLX_FIFO_OVERFLOW_ENABLE                       0x2209
 #define SUNI1x10GEXP_REG_IFLX_FIFO_OVERFLOW_INTERRUPT                    0x220A
-#define SUNI1x10GEXP_REG_IFLX_INDIR_CHANNEL_ADDRESS                      0x220D
-#define SUNI1x10GEXP_REG_IFLX_INDIR_LOGICAL_FIFO_LOW_LIMIT_PROVISION     0x220E
-#define SUNI1x10GEXP_REG_IFLX_INDIR_LOGICAL_FIFO_HIGH_LIMIT              0x220F
-#define SUNI1x10GEXP_REG_IFLX_INDIR_FULL_ALMOST_FULL_STATUS_LIMIT        0x2210
-#define SUNI1x10GEXP_REG_IFLX_INDIR_EMPTY_ALMOST_EMPTY_STATUS_LIMIT      0x2211
-
-#define SUNI1x10GEXP_REG_PL4MOS_CONFIG                                   0x2240
-#define SUNI1x10GEXP_REG_PL4MOS_MASK                                     0x2241
-#define SUNI1x10GEXP_REG_PL4MOS_FAIRNESS_MASKING                         0x2242
-#define SUNI1x10GEXP_REG_PL4MOS_MAXBURST1                                0x2243
-#define SUNI1x10GEXP_REG_PL4MOS_MAXBURST2                                0x2244
-#define SUNI1x10GEXP_REG_PL4MOS_TRANSFER_SIZE                            0x2245
-
-#define SUNI1x10GEXP_REG_PL4ODP_CONFIG                                   0x2280
 #define SUNI1x10GEXP_REG_PL4ODP_INTERRUPT_MASK                           0x2282
 #define SUNI1x10GEXP_REG_PL4ODP_INTERRUPT                                0x2283
-#define SUNI1x10GEXP_REG_PL4ODP_CONFIG_MAX_T                             0x2284
-
 #define SUNI1x10GEXP_REG_PL4IO_LOCK_DETECT_STATUS                        0x2300
 #define SUNI1x10GEXP_REG_PL4IO_LOCK_DETECT_CHANGE                        0x2301
 #define SUNI1x10GEXP_REG_PL4IO_LOCK_DETECT_MASK                          0x2302
-#define SUNI1x10GEXP_REG_PL4IO_LOCK_DETECT_LIMITS                        0x2303
-#define SUNI1x10GEXP_REG_PL4IO_CALENDAR_REPETITIONS                      0x2304
-#define SUNI1x10GEXP_REG_PL4IO_CONFIG                                    0x2305
-
 #define SUNI1x10GEXP_REG_TXXG_CONFIG_1                                   0x3040
-#define SUNI1x10GEXP_REG_TXXG_CONFIG_2                                   0x3041
 #define SUNI1x10GEXP_REG_TXXG_CONFIG_3                                   0x3042
 #define SUNI1x10GEXP_REG_TXXG_INTERRUPT                                  0x3043
-#define SUNI1x10GEXP_REG_TXXG_STATUS                                     0x3044
 #define SUNI1x10GEXP_REG_TXXG_MAX_FRAME_SIZE                             0x3045
-#define SUNI1x10GEXP_REG_TXXG_MIN_FRAME_SIZE                             0x3046
 #define SUNI1x10GEXP_REG_TXXG_SA_15_0                                    0x3047
 #define SUNI1x10GEXP_REG_TXXG_SA_31_16                                   0x3048
 #define SUNI1x10GEXP_REG_TXXG_SA_47_32                                   0x3049
-#define SUNI1x10GEXP_REG_TXXG_PAUSE_TIMER                                0x304D
-#define SUNI1x10GEXP_REG_TXXG_PAUSE_TIMER_INTERVAL                       0x304E
-#define SUNI1x10GEXP_REG_TXXG_FILTER_ERROR_COUNTER                       0x3051
-#define SUNI1x10GEXP_REG_TXXG_PAUSE_QUANTUM_CONFIG                       0x3052
-
-#define SUNI1x10GEXP_REG_XTEF_CTRL                                       0x3080
 #define SUNI1x10GEXP_REG_XTEF_INTERRUPT_STATUS                           0x3084
 #define SUNI1x10GEXP_REG_XTEF_INTERRUPT_ENABLE                           0x3085
-#define SUNI1x10GEXP_REG_XTEF_VISIBILITY                                 0x3086
-
-#define SUNI1x10GEXP_REG_TXOAM_OAM_CONFIG                                0x30C0
-#define SUNI1x10GEXP_REG_TXOAM_MINI_RATE_CONFIG                          0x30C1
-#define SUNI1x10GEXP_REG_TXOAM_MINI_GAP_FIFO_CONFIG                      0x30C2
-#define SUNI1x10GEXP_REG_TXOAM_P1P2_STATIC_VALUES                        0x30C3
-#define SUNI1x10GEXP_REG_TXOAM_P3P4_STATIC_VALUES                        0x30C4
-#define SUNI1x10GEXP_REG_TXOAM_P5P6_STATIC_VALUES                        0x30C5
 #define SUNI1x10GEXP_REG_TXOAM_INTERRUPT_ENABLE                          0x30C6
 #define SUNI1x10GEXP_REG_TXOAM_INTERRUPT_STATUS                          0x30C7
-#define SUNI1x10GEXP_REG_TXOAM_INSERT_COUNT_LSB                          0x30C8
-#define SUNI1x10GEXP_REG_TXOAM_INSERT_COUNT_MSB                          0x30C9
-#define SUNI1x10GEXP_REG_TXOAM_OAM_MINI_COUNT_LSB                        0x30CA
-#define SUNI1x10GEXP_REG_TXOAM_OAM_MINI_COUNT_MSB                        0x30CB
-#define SUNI1x10GEXP_REG_TXOAM_P1P2_MINI_MASK                            0x30CC
-#define SUNI1x10GEXP_REG_TXOAM_P3P4_MINI_MASK                            0x30CD
-#define SUNI1x10GEXP_REG_TXOAM_P5P6_MINI_MASK                            0x30CE
-#define SUNI1x10GEXP_REG_TXOAM_COSET                                     0x30CF
-#define SUNI1x10GEXP_REG_TXOAM_EMPTY_FIFO_INS_OP_CNT_LSB                 0x30D0
-#define SUNI1x10GEXP_REG_TXOAM_EMPTY_FIFO_INS_OP_CNT_MSB                 0x30D1
-#define SUNI1x10GEXP_REG_TXOAM_STATIC_VALUE_MINI_COUNT_LSB               0x30D2
-#define SUNI1x10GEXP_REG_TXOAM_STATIC_VALUE_MINI_COUNT_MSB               0x30D3
-
-
-#define SUNI1x10GEXP_REG_EFLX_GLOBAL_CONFIG                              0x3200
-#define SUNI1x10GEXP_REG_EFLX_ERCU_GLOBAL_STATUS                         0x3201
-#define SUNI1x10GEXP_REG_EFLX_INDIR_CHANNEL_ADDRESS                      0x3202
-#define SUNI1x10GEXP_REG_EFLX_INDIR_FIFO_LOW_LIMIT                       0x3203
-#define SUNI1x10GEXP_REG_EFLX_INDIR_FIFO_HIGH_LIMIT                      0x3204
-#define SUNI1x10GEXP_REG_EFLX_INDIR_FULL_ALMOST_FULL_STATUS_AND_LIMIT    0x3205
-#define SUNI1x10GEXP_REG_EFLX_INDIR_EMPTY_ALMOST_EMPTY_STATUS_AND_LIMIT  0x3206
-#define SUNI1x10GEXP_REG_EFLX_INDIR_FIFO_CUT_THROUGH_THRESHOLD           0x3207
 #define SUNI1x10GEXP_REG_EFLX_FIFO_OVERFLOW_ERROR_ENABLE                 0x320C
 #define SUNI1x10GEXP_REG_EFLX_FIFO_OVERFLOW_ERROR_INDICATION             0x320D
-#define SUNI1x10GEXP_REG_EFLX_CHANNEL_PROVISION                          0x3210
-
-#define SUNI1x10GEXP_REG_PL4IDU_CONFIG                                   0x3280
 #define SUNI1x10GEXP_REG_PL4IDU_INTERRUPT_MASK                           0x3282
 #define SUNI1x10GEXP_REG_PL4IDU_INTERRUPT                                0x3283

-
-/*----------------------------------------*/
-#define SUNI1x10GEXP_REG_MAX_OFFSET                                      0x3480
-
 /******************************************************************************/
 /*                 -- End register offset definitions --                      */
 /******************************************************************************/
@@ -516,81 +135,6 @@
 /** SUNI-1x10GE-XP REGISTER BIT MASKS                                        **/
 /******************************************************************************/

-#define SUNI1x10GEXP_BITMSK_BITS_1   0x00001
-#define SUNI1x10GEXP_BITMSK_BITS_2   0x00003
-#define SUNI1x10GEXP_BITMSK_BITS_3   0x00007
-#define SUNI1x10GEXP_BITMSK_BITS_4   0x0000f
-#define SUNI1x10GEXP_BITMSK_BITS_5   0x0001f
-#define SUNI1x10GEXP_BITMSK_BITS_6   0x0003f
-#define SUNI1x10GEXP_BITMSK_BITS_7   0x0007f
-#define SUNI1x10GEXP_BITMSK_BITS_8   0x000ff
-#define SUNI1x10GEXP_BITMSK_BITS_9   0x001ff
-#define SUNI1x10GEXP_BITMSK_BITS_10  0x003ff
-#define SUNI1x10GEXP_BITMSK_BITS_11  0x007ff
-#define SUNI1x10GEXP_BITMSK_BITS_12  0x00fff
-#define SUNI1x10GEXP_BITMSK_BITS_13  0x01fff
-#define SUNI1x10GEXP_BITMSK_BITS_14  0x03fff
-#define SUNI1x10GEXP_BITMSK_BITS_15  0x07fff
-#define SUNI1x10GEXP_BITMSK_BITS_16  0x0ffff
-
-#define mSUNI1x10GEXP_CLR_MSBITS_1(v)  ((v) & SUNI1x10GEXP_BITMSK_BITS_15)
-#define mSUNI1x10GEXP_CLR_MSBITS_2(v)  ((v) & SUNI1x10GEXP_BITMSK_BITS_14)
-#define mSUNI1x10GEXP_CLR_MSBITS_3(v)  ((v) & SUNI1x10GEXP_BITMSK_BITS_13)
-#define mSUNI1x10GEXP_CLR_MSBITS_4(v)  ((v) & SUNI1x10GEXP_BITMSK_BITS_12)
-#define mSUNI1x10GEXP_CLR_MSBITS_5(v)  ((v) & SUNI1x10GEXP_BITMSK_BITS_11)
-#define mSUNI1x10GEXP_CLR_MSBITS_6(v)  ((v) & SUNI1x10GEXP_BITMSK_BITS_10)
-#define mSUNI1x10GEXP_CLR_MSBITS_7(v)  ((v) & SUNI1x10GEXP_BITMSK_BITS_9)
-#define mSUNI1x10GEXP_CLR_MSBITS_8(v)  ((v) & SUNI1x10GEXP_BITMSK_BITS_8)
-#define mSUNI1x10GEXP_CLR_MSBITS_9(v)  ((v) & SUNI1x10GEXP_BITMSK_BITS_7)
-#define mSUNI1x10GEXP_CLR_MSBITS_10(v) ((v) & SUNI1x10GEXP_BITMSK_BITS_6)
-#define mSUNI1x10GEXP_CLR_MSBITS_11(v) ((v) & SUNI1x10GEXP_BITMSK_BITS_5)
-#define mSUNI1x10GEXP_CLR_MSBITS_12(v) ((v) & SUNI1x10GEXP_BITMSK_BITS_4)
-#define mSUNI1x10GEXP_CLR_MSBITS_13(v) ((v) & SUNI1x10GEXP_BITMSK_BITS_3)
-#define mSUNI1x10GEXP_CLR_MSBITS_14(v) ((v) & SUNI1x10GEXP_BITMSK_BITS_2)
-#define mSUNI1x10GEXP_CLR_MSBITS_15(v) ((v) & SUNI1x10GEXP_BITMSK_BITS_1)
-
-#define mSUNI1x10GEXP_GET_BIT(val, bitMsk) (((val)&(bitMsk)) ? 1:0)
-
-
-
-/*----------------------------------------------------------------------------
- * Register 0x0001: S/UNI-1x10GE-XP Product Revision
- *    Bit 3-0  REVISION
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_REVISION  0x000F
-
-/*----------------------------------------------------------------------------
- * Register 0x0002: S/UNI-1x10GE-XP Configuration and Reset Control
- *    Bit 2  XAUI_ARESETB
- *    Bit 1  PL4_ARESETB
- *    Bit 0  DRESETB
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_XAUI_ARESET  0x0004
-#define SUNI1x10GEXP_BITMSK_PL4_ARESET   0x0002
-#define SUNI1x10GEXP_BITMSK_DRESETB      0x0001
-
-/*----------------------------------------------------------------------------
- * Register 0x0003: S/UNI-1x10GE-XP Loop Back and Miscellaneous Control
- *    Bit 11  PL4IO_OUTCLKSEL
- *    Bit 9   SYSPCSLB
- *    Bit 8   LINEPCSLB
- *    Bit 7   MSTAT_BYPASS
- *    Bit 6   RXXG_BYPASS
- *    Bit 5   TXXG_BYPASS
- *    Bit 4   SOP_PAD_EN
- *    Bit 1   LOS_INV
- *    Bit 0   OVERRIDE_LOS
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_PL4IO_OUTCLKSEL  0x0800
-#define SUNI1x10GEXP_BITMSK_SYSPCSLB         0x0200
-#define SUNI1x10GEXP_BITMSK_LINEPCSLB        0x0100
-#define SUNI1x10GEXP_BITMSK_MSTAT_BYPASS     0x0080
-#define SUNI1x10GEXP_BITMSK_RXXG_BYPASS      0x0040
-#define SUNI1x10GEXP_BITMSK_TXXG_BYPASS      0x0020
-#define SUNI1x10GEXP_BITMSK_SOP_PAD_EN       0x0010
-#define SUNI1x10GEXP_BITMSK_LOS_INV          0x0002
-#define SUNI1x10GEXP_BITMSK_OVERRIDE_LOS     0x0001
-
 /*----------------------------------------------------------------------------
  * Register 0x0004: S/UNI-1x10GE-XP Device Status
  *    Bit 9 TOP_SXRA_EXPIRED
@@ -605,10 +149,7 @@
  *    Bit 0 TOP_PL4_OUT_ROOL
  *----------------------------------------------------------------------------*/
 #define SUNI1x10GEXP_BITMSK_TOP_SXRA_EXPIRED  0x0200
-#define SUNI1x10GEXP_BITMSK_TOP_MDIO_BUSY     0x0100
-#define SUNI1x10GEXP_BITMSK_TOP_DTRB          0x0080
 #define SUNI1x10GEXP_BITMSK_TOP_EXPIRED       0x0040
-#define SUNI1x10GEXP_BITMSK_TOP_PAUSED        0x0020
 #define SUNI1x10GEXP_BITMSK_TOP_PL4_ID_DOOL   0x0010
 #define SUNI1x10GEXP_BITMSK_TOP_PL4_IS_DOOL   0x0008
 #define SUNI1x10GEXP_BITMSK_TOP_PL4_ID_ROOL   0x0004
@@ -616,219 +157,12 @@
 #define SUNI1x10GEXP_BITMSK_TOP_PL4_OUT_ROOL  0x0001

 /*----------------------------------------------------------------------------
- * Register 0x0005: Global Performance Update and Clock Monitors
- *    Bit 15 TIP
- *    Bit 8  XAUI_REF_CLKA
- *    Bit 7  RXLANE3CLKA
- *    Bit 6  RXLANE2CLKA
- *    Bit 5  RXLANE1CLKA
- *    Bit 4  RXLANE0CLKA
- *    Bit 3  CSUCLKA
- *    Bit 2  TDCLKA
- *    Bit 1  RSCLKA
- *    Bit 0  RDCLKA
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_TIP            0x8000
-#define SUNI1x10GEXP_BITMSK_XAUI_REF_CLKA  0x0100
-#define SUNI1x10GEXP_BITMSK_RXLANE3CLKA    0x0080
-#define SUNI1x10GEXP_BITMSK_RXLANE2CLKA    0x0040
-#define SUNI1x10GEXP_BITMSK_RXLANE1CLKA    0x0020
-#define SUNI1x10GEXP_BITMSK_RXLANE0CLKA    0x0010
-#define SUNI1x10GEXP_BITMSK_CSUCLKA        0x0008
-#define SUNI1x10GEXP_BITMSK_TDCLKA         0x0004
-#define SUNI1x10GEXP_BITMSK_RSCLKA         0x0002
-#define SUNI1x10GEXP_BITMSK_RDCLKA         0x0001
-
-/*----------------------------------------------------------------------------
- * Register 0x0006: MDIO Command
- *    Bit 4 MDIO_RDINC
- *    Bit 3 MDIO_RSTAT
- *    Bit 2 MDIO_LCTLD
- *    Bit 1 MDIO_LCTLA
- *    Bit 0 MDIO_SPRE
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_MDIO_RDINC  0x0010
-#define SUNI1x10GEXP_BITMSK_MDIO_RSTAT  0x0008
-#define SUNI1x10GEXP_BITMSK_MDIO_LCTLD  0x0004
-#define SUNI1x10GEXP_BITMSK_MDIO_LCTLA  0x0002
-#define SUNI1x10GEXP_BITMSK_MDIO_SPRE   0x0001
-
-/*----------------------------------------------------------------------------
- * Register 0x0007: MDIO Interrupt Enable
- *    Bit 0 MDIO_BUSY_EN
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_MDIO_BUSY_EN  0x0001
-
-/*----------------------------------------------------------------------------
- * Register 0x0008: MDIO Interrupt Status
- *    Bit 0 MDIO_BUSYI
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_MDIO_BUSYI  0x0001
-
-/*----------------------------------------------------------------------------
- * Register 0x0009: MMD PHY Address
- *    Bit 12-8 MDIO_DEVADR
- *    Bit 4-0 MDIO_PRTADR
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_MDIO_DEVADR  0x1F00
-#define SUNI1x10GEXP_BITOFF_MDIO_DEVADR  8
-#define SUNI1x10GEXP_BITMSK_MDIO_PRTADR  0x001F
-#define SUNI1x10GEXP_BITOFF_MDIO_PRTADR  0
-
-/*----------------------------------------------------------------------------
- * Register 0x000C: OAM Interface Control
- *    Bit 6 MDO_OD_ENB
- *    Bit 5 MDI_INV
- *    Bit 4 MDI_SEL
- *    Bit 3 RXOAMEN
- *    Bit 2 RXOAMCLKEN
- *    Bit 1 TXOAMEN
- *    Bit 0 TXOAMCLKEN
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_MDO_OD_ENB  0x0040
-#define SUNI1x10GEXP_BITMSK_MDI_INV     0x0020
-#define SUNI1x10GEXP_BITMSK_MDI_SEL     0x0010
-#define SUNI1x10GEXP_BITMSK_RXOAMEN     0x0008
-#define SUNI1x10GEXP_BITMSK_RXOAMCLKEN  0x0004
-#define SUNI1x10GEXP_BITMSK_TXOAMEN     0x0002
-#define SUNI1x10GEXP_BITMSK_TXOAMCLKEN  0x0001
-
-/*----------------------------------------------------------------------------
- * Register 0x000D: S/UNI-1x10GE-XP Master Interrupt Status
- *    Bit 15 TOP_PL4IO_INT
- *    Bit 14 TOP_IRAM_INT
- *    Bit 13 TOP_ERAM_INT
- *    Bit 12 TOP_XAUI_INT
- *    Bit 11 TOP_MSTAT_INT
- *    Bit 10 TOP_RXXG_INT
- *    Bit 9 TOP_TXXG_INT
- *    Bit 8 TOP_XRF_INT
- *    Bit 7 TOP_XTEF_INT
- *    Bit 6 TOP_MDIO_BUSY_INT
- *    Bit 5 TOP_RXOAM_INT
- *    Bit 4 TOP_TXOAM_INT
- *    Bit 3 TOP_IFLX_INT
- *    Bit 2 TOP_EFLX_INT
- *    Bit 1 TOP_PL4ODP_INT
- *    Bit 0 TOP_PL4IDU_INT
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_TOP_PL4IO_INT      0x8000
-#define SUNI1x10GEXP_BITMSK_TOP_IRAM_INT       0x4000
-#define SUNI1x10GEXP_BITMSK_TOP_ERAM_INT       0x2000
-#define SUNI1x10GEXP_BITMSK_TOP_XAUI_INT       0x1000
-#define SUNI1x10GEXP_BITMSK_TOP_MSTAT_INT      0x0800
-#define SUNI1x10GEXP_BITMSK_TOP_RXXG_INT       0x0400
-#define SUNI1x10GEXP_BITMSK_TOP_TXXG_INT       0x0200
-#define SUNI1x10GEXP_BITMSK_TOP_XRF_INT        0x0100
-#define SUNI1x10GEXP_BITMSK_TOP_XTEF_INT       0x0080
-#define SUNI1x10GEXP_BITMSK_TOP_MDIO_BUSY_INT  0x0040
-#define SUNI1x10GEXP_BITMSK_TOP_RXOAM_INT      0x0020
-#define SUNI1x10GEXP_BITMSK_TOP_TXOAM_INT      0x0010
-#define SUNI1x10GEXP_BITMSK_TOP_IFLX_INT       0x0008
-#define SUNI1x10GEXP_BITMSK_TOP_EFLX_INT       0x0004
-#define SUNI1x10GEXP_BITMSK_TOP_PL4ODP_INT     0x0002
-#define SUNI1x10GEXP_BITMSK_TOP_PL4IDU_INT     0x0001
-
-/*----------------------------------------------------------------------------
  * Register 0x000E:PM3393 Global interrupt enable
  *    Bit 15 TOP_INTE
  *----------------------------------------------------------------------------*/
 #define SUNI1x10GEXP_BITMSK_TOP_INTE  0x8000

 /*----------------------------------------------------------------------------
- * Register 0x0010: XTEF Miscellaneous Control
- *    Bit 7 RF_VAL
- *    Bit 6 RF_OVERRIDE
- *    Bit 5 LF_VAL
- *    Bit 4 LF_OVERRIDE
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_RF_VAL             0x0080
-#define SUNI1x10GEXP_BITMSK_RF_OVERRIDE        0x0040
-#define SUNI1x10GEXP_BITMSK_LF_VAL             0x0020
-#define SUNI1x10GEXP_BITMSK_LF_OVERRIDE        0x0010
-#define SUNI1x10GEXP_BITMSK_LFRF_OVERRIDE_VAL  0x00F0
-
-/*----------------------------------------------------------------------------
- * Register 0x0011: XRF Miscellaneous Control
- *    Bit 6-4 EN_IDLE_REP
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_EN_IDLE_REP  0x0070
-
-/*----------------------------------------------------------------------------
- * Register 0x0100: SERDES 3125 Configuration Register 1
- *    Bit 10 RXEQB_3
- *    Bit 8  RXEQB_2
- *    Bit 6  RXEQB_1
- *    Bit 4  RXEQB_0
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_RXEQB    0x0FF0
-#define SUNI1x10GEXP_BITOFF_RXEQB_3  10
-#define SUNI1x10GEXP_BITOFF_RXEQB_2  8
-#define SUNI1x10GEXP_BITOFF_RXEQB_1  6
-#define SUNI1x10GEXP_BITOFF_RXEQB_0  4
-
-/*----------------------------------------------------------------------------
- * Register 0x0101: SERDES 3125 Configuration Register 2
- *    Bit 12 YSEL
- *    Bit  7 PRE_EMPH_3
- *    Bit  6 PRE_EMPH_2
- *    Bit  5 PRE_EMPH_1
- *    Bit  4 PRE_EMPH_0
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_YSEL        0x1000
-#define SUNI1x10GEXP_BITMSK_PRE_EMPH    0x00F0
-#define SUNI1x10GEXP_BITMSK_PRE_EMPH_3  0x0080
-#define SUNI1x10GEXP_BITMSK_PRE_EMPH_2  0x0040
-#define SUNI1x10GEXP_BITMSK_PRE_EMPH_1  0x0020
-#define SUNI1x10GEXP_BITMSK_PRE_EMPH_0  0x0010
-
-/*----------------------------------------------------------------------------
- * Register 0x0102: SERDES 3125 Interrupt Enable Register
- *    Bit 3 LASIE
- *    Bit 2 SPLL_RAE
- *    Bit 1 MPLL_RAE
- *    Bit 0 PLL_LOCKE
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_LASIE      0x0008
-#define SUNI1x10GEXP_BITMSK_SPLL_RAE   0x0004
-#define SUNI1x10GEXP_BITMSK_MPLL_RAE   0x0002
-#define SUNI1x10GEXP_BITMSK_PLL_LOCKE  0x0001
-
-/*----------------------------------------------------------------------------
- * Register 0x0103: SERDES 3125 Interrupt Visibility Register
- *    Bit 3 LASIV
- *    Bit 2 SPLL_RAV
- *    Bit 1 MPLL_RAV
- *    Bit 0 PLL_LOCKV
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_LASIV      0x0008
-#define SUNI1x10GEXP_BITMSK_SPLL_RAV   0x0004
-#define SUNI1x10GEXP_BITMSK_MPLL_RAV   0x0002
-#define SUNI1x10GEXP_BITMSK_PLL_LOCKV  0x0001
-
-/*----------------------------------------------------------------------------
- * Register 0x0104: SERDES 3125 Interrupt Status Register
- *    Bit 3 LASII
- *    Bit 2 SPLL_RAI
- *    Bit 1 MPLL_RAI
- *    Bit 0 PLL_LOCKI
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_LASII      0x0008
-#define SUNI1x10GEXP_BITMSK_SPLL_RAI   0x0004
-#define SUNI1x10GEXP_BITMSK_MPLL_RAI   0x0002
-#define SUNI1x10GEXP_BITMSK_PLL_LOCKI  0x0001
-
-/*----------------------------------------------------------------------------
- * Register 0x0107: SERDES 3125 Test Configuration
- *    Bit 12 DUALTX
- *    Bit 10 HC_1
- *    Bit  9 HC_0
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_DUALTX  0x1000
-#define SUNI1x10GEXP_BITMSK_HC      0x0600
-#define SUNI1x10GEXP_BITOFF_HC_0    9
-
-/*----------------------------------------------------------------------------
  * Register 0x2040: RXXG Configuration 1
  *    Bit 15  RXXG_RXEN
  *    Bit 14  RXXG_ROCF
@@ -842,84 +176,11 @@
  *    Bit 2-0 RXXG_MIFG
  *----------------------------------------------------------------------------*/
 #define SUNI1x10GEXP_BITMSK_RXXG_RXEN       0x8000
-#define SUNI1x10GEXP_BITMSK_RXXG_ROCF       0x4000
-#define SUNI1x10GEXP_BITMSK_RXXG_PAD_STRIP  0x2000
 #define SUNI1x10GEXP_BITMSK_RXXG_PUREP      0x0400
-#define SUNI1x10GEXP_BITMSK_RXXG_LONGP      0x0200
-#define SUNI1x10GEXP_BITMSK_RXXG_PARF       0x0100
 #define SUNI1x10GEXP_BITMSK_RXXG_FLCHK      0x0080
-#define SUNI1x10GEXP_BITMSK_RXXG_PASS_CTRL  0x0020
 #define SUNI1x10GEXP_BITMSK_RXXG_CRC_STRIP  0x0008

 /*----------------------------------------------------------------------------
- * Register 0x02041: RXXG Configuration 2
- *    Bit 7-0 RXXG_HDRSIZE
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_RXXG_HDRSIZE  0x00FF
-
-/*----------------------------------------------------------------------------
- * Register 0x2042: RXXG Configuration 3
- *    Bit 15 RXXG_MIN_LERRE
- *    Bit 14 RXXG_MAX_LERRE
- *    Bit 12 RXXG_LINE_ERRE
- *    Bit 10 RXXG_RX_OVRE
- *    Bit 9  RXXG_ADR_FILTERE
- *    Bit 8  RXXG_ERR_FILTERE
- *    Bit 5  RXXG_PRMB_ERRE
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_RXXG_MIN_LERRE     0x8000
-#define SUNI1x10GEXP_BITMSK_RXXG_MAX_LERRE     0x4000
-#define SUNI1x10GEXP_BITMSK_RXXG_LINE_ERRE     0x1000
-#define SUNI1x10GEXP_BITMSK_RXXG_RX_OVRE       0x0400
-#define SUNI1x10GEXP_BITMSK_RXXG_ADR_FILTERE   0x0200
-#define SUNI1x10GEXP_BITMSK_RXXG_ERR_FILTERRE  0x0100
-#define SUNI1x10GEXP_BITMSK_RXXG_PRMB_ERRE     0x0020
-
-/*----------------------------------------------------------------------------
- * Register 0x2043: RXXG Interrupt
- *    Bit 15 RXXG_MIN_LERRI
- *    Bit 14 RXXG_MAX_LERRI
- *    Bit 12 RXXG_LINE_ERRI
- *    Bit 10 RXXG_RX_OVRI
- *    Bit 9  RXXG_ADR_FILTERI
- *    Bit 8  RXXG_ERR_FILTERI
- *    Bit 5  RXXG_PRMB_ERRE
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_RXXG_MIN_LERRI    0x8000
-#define SUNI1x10GEXP_BITMSK_RXXG_MAX_LERRI    0x4000
-#define SUNI1x10GEXP_BITMSK_RXXG_LINE_ERRI    0x1000
-#define SUNI1x10GEXP_BITMSK_RXXG_RX_OVRI      0x0400
-#define SUNI1x10GEXP_BITMSK_RXXG_ADR_FILTERI  0x0200
-#define SUNI1x10GEXP_BITMSK_RXXG_ERR_FILTERI  0x0100
-#define SUNI1x10GEXP_BITMSK_RXXG_PRMB_ERRE    0x0020
-
-/*----------------------------------------------------------------------------
- * Register 0x2049: RXXG Receive FIFO Threshold
- *    Bit 2-0 RXXG_CUT_THRU
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_RXXG_CUT_THRU  0x0007
-#define SUNI1x10GEXP_BITOFF_RXXG_CUT_THRU  0
-
-/*----------------------------------------------------------------------------
- * Register 0x2062H - 0x2069: RXXG Exact Match VID
- *    Bit 11-0 RXXG_VID_MATCH
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_RXXG_VID_MATCH  0x0FFF
-#define SUNI1x10GEXP_BITOFF_RXXG_VID_MATCH  0
-
-/*----------------------------------------------------------------------------
- * Register 0x206EH - 0x206F: RXXG Address Filter Control
- *    Bit 3 RXXG_FORWARD_ENABLE
- *    Bit 2 RXXG_VLAN_ENABLE
- *    Bit 1 RXXG_SRC_ADDR
- *    Bit 0 RXXG_MATCH_ENABLE
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_RXXG_FORWARD_ENABLE  0x0008
-#define SUNI1x10GEXP_BITMSK_RXXG_VLAN_ENABLE     0x0004
-#define SUNI1x10GEXP_BITMSK_RXXG_SRC_ADDR        0x0002
-#define SUNI1x10GEXP_BITMSK_RXXG_MATCH_ENABLE    0x0001
-
-/*----------------------------------------------------------------------------
  * Register 0x2070: RXXG Address Filter Control 2
  *    Bit 1 RXXG_PMODE
  *    Bit 0 RXXG_MHASH_EN
@@ -928,446 +189,15 @@
 #define SUNI1x10GEXP_BITMSK_RXXG_MHASH_EN  0x0001

 /*----------------------------------------------------------------------------
- * Register 0x2081: XRF Control Register 2
- *    Bit 6   EN_PKT_GEN
- *    Bit 4-2 PATT
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_EN_PKT_GEN  0x0040
-#define SUNI1x10GEXP_BITMSK_PATT        0x001C
-#define SUNI1x10GEXP_BITOFF_PATT        2
-
-/*----------------------------------------------------------------------------
- * Register 0x2088: XRF Interrupt Enable
- *    Bit 12-9 LANE_HICERE
- *    Bit 8-5  HS_SD_LANEE
- *    Bit 4    ALIGN_STATUS_ERRE
- *    Bit 3-0  LANE_SYNC_STAT_ERRE
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_LANE_HICERE          0x1E00
-#define SUNI1x10GEXP_BITOFF_LANE_HICERE          9
-#define SUNI1x10GEXP_BITMSK_HS_SD_LANEE          0x01E0
-#define SUNI1x10GEXP_BITOFF_HS_SD_LANEE          5
-#define SUNI1x10GEXP_BITMSK_ALIGN_STATUS_ERRE    0x0010
-#define SUNI1x10GEXP_BITMSK_LANE_SYNC_STAT_ERRE  0x000F
-#define SUNI1x10GEXP_BITOFF_LANE_SYNC_STAT_ERRE  0
-
-/*----------------------------------------------------------------------------
- * Register 0x2089: XRF Interrupt Status
- *    Bit 12-9 LANE_HICERI
- *    Bit 8-5  HS_SD_LANEI
- *    Bit 4    ALIGN_STATUS_ERRI
- *    Bit 3-0  LANE_SYNC_STAT_ERRI
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_LANE_HICERI          0x1E00
-#define SUNI1x10GEXP_BITOFF_LANE_HICERI          9
-#define SUNI1x10GEXP_BITMSK_HS_SD_LANEI          0x01E0
-#define SUNI1x10GEXP_BITOFF_HS_SD_LANEI          5
-#define SUNI1x10GEXP_BITMSK_ALIGN_STATUS_ERRI    0x0010
-#define SUNI1x10GEXP_BITMSK_LANE_SYNC_STAT_ERRI  0x000F
-#define SUNI1x10GEXP_BITOFF_LANE_SYNC_STAT_ERRI  0
-
-/*----------------------------------------------------------------------------
- * Register 0x208A: XRF Error Status
- *    Bit 8-5  HS_SD_LANE
- *    Bit 4    ALIGN_STATUS_ERR
- *    Bit 3-0  LANE_SYNC_STAT_ERR
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_HS_SD_LANE3          0x0100
-#define SUNI1x10GEXP_BITMSK_HS_SD_LANE2          0x0080
-#define SUNI1x10GEXP_BITMSK_HS_SD_LANE1          0x0040
-#define SUNI1x10GEXP_BITMSK_HS_SD_LANE0          0x0020
-#define SUNI1x10GEXP_BITMSK_ALIGN_STATUS_ERR     0x0010
-#define SUNI1x10GEXP_BITMSK_LANE3_SYNC_STAT_ERR  0x0008
-#define SUNI1x10GEXP_BITMSK_LANE2_SYNC_STAT_ERR  0x0004
-#define SUNI1x10GEXP_BITMSK_LANE1_SYNC_STAT_ERR  0x0002
-#define SUNI1x10GEXP_BITMSK_LANE0_SYNC_STAT_ERR  0x0001
-
-/*----------------------------------------------------------------------------
- * Register 0x208B: XRF Diagnostic Interrupt Enable
- *    Bit 7-4 LANE_OVERRUNE
- *    Bit 3-0 LANE_UNDERRUNE
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_LANE_OVERRUNE   0x00F0
-#define SUNI1x10GEXP_BITOFF_LANE_OVERRUNE   4
-#define SUNI1x10GEXP_BITMSK_LANE_UNDERRUNE  0x000F
-#define SUNI1x10GEXP_BITOFF_LANE_UNDERRUNE  0
-
-/*----------------------------------------------------------------------------
- * Register 0x208C: XRF Diagnostic Interrupt Status
- *    Bit 7-4 LANE_OVERRUNI
- *    Bit 3-0 LANE_UNDERRUNI
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_LANE_OVERRUNI   0x00F0
-#define SUNI1x10GEXP_BITOFF_LANE_OVERRUNI   4
-#define SUNI1x10GEXP_BITMSK_LANE_UNDERRUNI  0x000F
-#define SUNI1x10GEXP_BITOFF_LANE_UNDERRUNI  0
-
-/*----------------------------------------------------------------------------
- * Register 0x20C0: RXOAM Configuration
- *    Bit 15    RXOAM_BUSY
- *    Bit 14-12 RXOAM_F2_SEL
- *    Bit 10-8  RXOAM_F1_SEL
- *    Bit 7-6   RXOAM_FILTER_CTRL
- *    Bit 5-0   RXOAM_PX_EN
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_RXOAM_BUSY         0x8000
-#define SUNI1x10GEXP_BITMSK_RXOAM_F2_SEL       0x7000
-#define SUNI1x10GEXP_BITOFF_RXOAM_F2_SEL       12
-#define SUNI1x10GEXP_BITMSK_RXOAM_F1_SEL       0x0700
-#define SUNI1x10GEXP_BITOFF_RXOAM_F1_SEL       8
-#define SUNI1x10GEXP_BITMSK_RXOAM_FILTER_CTRL  0x00C0
-#define SUNI1x10GEXP_BITOFF_RXOAM_FILTER_CTRL  6
-#define SUNI1x10GEXP_BITMSK_RXOAM_PX_EN        0x003F
-#define SUNI1x10GEXP_BITOFF_RXOAM_PX_EN        0
-
-/*----------------------------------------------------------------------------
- * Register 0x20C1,0x20C2: RXOAM Filter Configuration
- *    Bit 15-8 RXOAM_FX_MASK
- *    Bit 7-0  RXOAM_FX_VAL
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_RXOAM_FX_MASK  0xFF00
-#define SUNI1x10GEXP_BITOFF_RXOAM_FX_MASK  8
-#define SUNI1x10GEXP_BITMSK_RXOAM_FX_VAL   0x00FF
-#define SUNI1x10GEXP_BITOFF_RXOAM_FX_VAl   0
-
-/*----------------------------------------------------------------------------
- * Register 0x20C3: RXOAM Configuration Register 2
- *    Bit 13    RXOAM_REC_BYTE_VAL
- *    Bit 11-10 RXOAM_BYPASS_MODE
- *    Bit 5-0   RXOAM_PX_CLEAR
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_RXOAM_REC_BYTE_VAL  0x2000
-#define SUNI1x10GEXP_BITMSK_RXOAM_BYPASS_MODE   0x0C00
-#define SUNI1x10GEXP_BITOFF_RXOAM_BYPASS_MODE   10
-#define SUNI1x10GEXP_BITMSK_RXOAM_PX_CLEAR      0x003F
-#define SUNI1x10GEXP_BITOFF_RXOAM_PX_CLEAR      0
-
-/*----------------------------------------------------------------------------
- * Register 0x20C4: RXOAM HEC Configuration
- *    Bit 15-8 RXOAM_COSET
- *    Bit 2    RXOAM_HEC_ERR_PKT
- *    Bit 0    RXOAM_HEC_EN
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_RXOAM_COSET        0xFF00
-#define SUNI1x10GEXP_BITOFF_RXOAM_COSET        8
-#define SUNI1x10GEXP_BITMSK_RXOAM_HEC_ERR_PKT  0x0004
-#define SUNI1x10GEXP_BITMSK_RXOAM_HEC_EN       0x0001
-
-/*----------------------------------------------------------------------------
- * Register 0x20C7: RXOAM Interrupt Enable
- *    Bit 10 RXOAM_FILTER_THRSHE
- *    Bit 9  RXOAM_OAM_ERRE
- *    Bit 8  RXOAM_HECE_THRSHE
- *    Bit 7  RXOAM_SOPE
- *    Bit 6  RXOAM_RFE
- *    Bit 5  RXOAM_LFE
- *    Bit 4  RXOAM_DV_ERRE
- *    Bit 3  RXOAM_DATA_INVALIDE
- *    Bit 2  RXOAM_FILTER_DROPE
- *    Bit 1  RXOAM_HECE
- *    Bit 0  RXOAM_OFLE
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_RXOAM_FILTER_THRSHE  0x0400
-#define SUNI1x10GEXP_BITMSK_RXOAM_OAM_ERRE       0x0200
-#define SUNI1x10GEXP_BITMSK_RXOAM_HECE_THRSHE    0x0100
-#define SUNI1x10GEXP_BITMSK_RXOAM_SOPE           0x0080
-#define SUNI1x10GEXP_BITMSK_RXOAM_RFE            0x0040
-#define SUNI1x10GEXP_BITMSK_RXOAM_LFE            0x0020
-#define SUNI1x10GEXP_BITMSK_RXOAM_DV_ERRE        0x0010
-#define SUNI1x10GEXP_BITMSK_RXOAM_DATA_INVALIDE  0x0008
-#define SUNI1x10GEXP_BITMSK_RXOAM_FILTER_DROPE   0x0004
-#define SUNI1x10GEXP_BITMSK_RXOAM_HECE           0x0002
-#define SUNI1x10GEXP_BITMSK_RXOAM_OFLE           0x0001
-
-/*----------------------------------------------------------------------------
- * Register 0x20C8: RXOAM Interrupt Status
- *    Bit 10 RXOAM_FILTER_THRSHI
- *    Bit 9  RXOAM_OAM_ERRI
- *    Bit 8  RXOAM_HECE_THRSHI
- *    Bit 7  RXOAM_SOPI
- *    Bit 6  RXOAM_RFI
- *    Bit 5  RXOAM_LFI
- *    Bit 4  RXOAM_DV_ERRI
- *    Bit 3  RXOAM_DATA_INVALIDI
- *    Bit 2  RXOAM_FILTER_DROPI
- *    Bit 1  RXOAM_HECI
- *    Bit 0  RXOAM_OFLI
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_RXOAM_FILTER_THRSHI  0x0400
-#define SUNI1x10GEXP_BITMSK_RXOAM_OAM_ERRI       0x0200
-#define SUNI1x10GEXP_BITMSK_RXOAM_HECE_THRSHI    0x0100
-#define SUNI1x10GEXP_BITMSK_RXOAM_SOPI           0x0080
-#define SUNI1x10GEXP_BITMSK_RXOAM_RFI            0x0040
-#define SUNI1x10GEXP_BITMSK_RXOAM_LFI            0x0020
-#define SUNI1x10GEXP_BITMSK_RXOAM_DV_ERRI        0x0010
-#define SUNI1x10GEXP_BITMSK_RXOAM_DATA_INVALIDI  0x0008
-#define SUNI1x10GEXP_BITMSK_RXOAM_FILTER_DROPI   0x0004
-#define SUNI1x10GEXP_BITMSK_RXOAM_HECI           0x0002
-#define SUNI1x10GEXP_BITMSK_RXOAM_OFLI           0x0001
-
-/*----------------------------------------------------------------------------
- * Register 0x20C9: RXOAM Status
- *    Bit 10 RXOAM_FILTER_THRSHV
- *    Bit 8  RXOAM_HECE_THRSHV
- *    Bit 6  RXOAM_RFV
- *    Bit 5  RXOAM_LFV
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_RXOAM_FILTER_THRSHV  0x0400
-#define SUNI1x10GEXP_BITMSK_RXOAM_HECE_THRSHV    0x0100
-#define SUNI1x10GEXP_BITMSK_RXOAM_RFV            0x0040
-#define SUNI1x10GEXP_BITMSK_RXOAM_LFV            0x0020
-
-/*----------------------------------------------------------------------------
  * Register 0x2100: MSTAT Control
  *    Bit 2 MSTAT_WRITE
  *    Bit 1 MSTAT_CLEAR
  *    Bit 0 MSTAT_SNAP
  *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_MSTAT_WRITE  0x0004
 #define SUNI1x10GEXP_BITMSK_MSTAT_CLEAR  0x0002
 #define SUNI1x10GEXP_BITMSK_MSTAT_SNAP   0x0001

 /*----------------------------------------------------------------------------
- * Register 0x2109: MSTAT Counter Write Address
- *    Bit 5-0 MSTAT_WRITE_ADDRESS
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_MSTAT_WRITE_ADDRESS 0x003F
-#define SUNI1x10GEXP_BITOFF_MSTAT_WRITE_ADDRESS 0
-
-/*----------------------------------------------------------------------------
- * Register 0x2200: IFLX Global Configuration Register
- *    Bit 15   IFLX_IRCU_ENABLE
- *    Bit 14   IFLX_IDSWT_ENABLE
- *    Bit 13-0 IFLX_IFD_CNT
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_IFLX_IRCU_ENABLE   0x8000
-#define SUNI1x10GEXP_BITMSK_IFLX_IDSWT_ENABLE  0x4000
-#define SUNI1x10GEXP_BITMSK_IFLX_IFD_CNT       0x3FFF
-#define SUNI1x10GEXP_BITOFF_IFLX_IFD_CNT       0
-
-/*----------------------------------------------------------------------------
- * Register 0x2209: IFLX FIFO Overflow Enable
- *    Bit 0 IFLX_OVFE
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_IFLX_OVFE 0x0001
-
-/*----------------------------------------------------------------------------
- * Register 0x220A: IFLX FIFO Overflow Interrupt
- *    Bit 0 IFLX_OVFI
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_IFLX_OVFI 0x0001
-
-/*----------------------------------------------------------------------------
- * Register 0x220D: IFLX Indirect Channel Address
- *    Bit 15 IFLX_BUSY
- *    Bit 14 IFLX_RWB
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_IFLX_BUSY  0x8000
-#define SUNI1x10GEXP_BITMSK_IFLX_RWB   0x4000
-
-/*----------------------------------------------------------------------------
- * Register 0x220E: IFLX Indirect Logical FIFO Low Limit & Provision
- *    Bit 9-0 IFLX_LOLIM
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_IFLX_LOLIM  0x03FF
-#define SUNI1x10GEXP_BITOFF_IFLX_LOLIM  0
-
-/*----------------------------------------------------------------------------
- * Register 0x220F: IFLX Indirect Logical FIFO High Limit
- *    Bit 9-0 IFLX_HILIM
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_IFLX_HILIM  0x03FF
-#define SUNI1x10GEXP_BITOFF_IFLX_HILIM  0
-
-/*----------------------------------------------------------------------------
- * Register 0x2210: IFLX Indirect Full/Almost Full Status & Limit
- *    Bit 15   IFLX_FULL
- *    Bit 14   IFLX_AFULL
- *    Bit 13-0 IFLX_AFTH
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_IFLX_FULL   0x8000
-#define SUNI1x10GEXP_BITMSK_IFLX_AFULL  0x4000
-#define SUNI1x10GEXP_BITMSK_IFLX_AFTH   0x3FFF
-#define SUNI1x10GEXP_BITOFF_IFLX_AFTH   0
-
-/*----------------------------------------------------------------------------
- * Register 0x2211: IFLX Indirect Empty/Almost Empty Status & Limit
- *    Bit 15   IFLX_EMPTY
- *    Bit 14   IFLX_AEMPTY
- *    Bit 13-0 IFLX_AETH
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_IFLX_EMPTY   0x8000
-#define SUNI1x10GEXP_BITMSK_IFLX_AEMPTY  0x4000
-#define SUNI1x10GEXP_BITMSK_IFLX_AETH    0x3FFF
-#define SUNI1x10GEXP_BITOFF_IFLX_AETH    0
-
-/*----------------------------------------------------------------------------
- * Register 0x2240: PL4MOS Configuration Register
- *    Bit 3 PL4MOS_RE_INIT
- *    Bit 2 PL4MOS_EN
- *    Bit 1 PL4MOS_NO_STATUS
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_PL4MOS_RE_INIT          0x0008
-#define SUNI1x10GEXP_BITMSK_PL4MOS_EN               0x0004
-#define SUNI1x10GEXP_BITMSK_PL4MOS_NO_STATUS        0x0002
-
-/*----------------------------------------------------------------------------
- * Register 0x2243: PL4MOS MaxBurst1 Register
- *    Bit 11-0 PL4MOS_MAX_BURST1
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_PL4MOS_MAX_BURST1  0x0FFF
-#define SUNI1x10GEXP_BITOFF_PL4MOS_MAX_BURST1  0
-
-/*----------------------------------------------------------------------------
- * Register 0x2244: PL4MOS MaxBurst2 Register
- *    Bit 11-0 PL4MOS_MAX_BURST2
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_PL4MOS_MAX_BURST2  0x0FFF
-#define SUNI1x10GEXP_BITOFF_PL4MOS_MAX_BURST2  0
-
-/*----------------------------------------------------------------------------
- * Register 0x2245: PL4MOS Transfer Size Register
- *    Bit 7-0 PL4MOS_MAX_TRANSFER
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_PL4MOS_MAX_TRANSFER  0x00FF
-#define SUNI1x10GEXP_BITOFF_PL4MOS_MAX_TRANSFER  0
-
-/*----------------------------------------------------------------------------
- * Register 0x2280: PL4ODP Configuration
- *    Bit 15-12 PL4ODP_REPEAT_T
- *    Bit 8     PL4ODP_SOP_RULE
- *    Bit 1     PL4ODP_EN_PORTS
- *    Bit 0     PL4ODP_EN_DFWD
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_PL4ODP_REPEAT_T   0xF000
-#define SUNI1x10GEXP_BITOFF_PL4ODP_REPEAT_T   12
-#define SUNI1x10GEXP_BITMSK_PL4ODP_SOP_RULE   0x0100
-#define SUNI1x10GEXP_BITMSK_PL4ODP_EN_PORTS   0x0002
-#define SUNI1x10GEXP_BITMSK_PL4ODP_EN_DFWD    0x0001
-
-/*----------------------------------------------------------------------------
- * Register 0x2282: PL4ODP Interrupt Mask
- *    Bit 0 PL4ODP_OUT_DISE
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_PL4ODP_OUT_DISE     0x0001
-
-
-
-#define SUNI1x10GEXP_BITMSK_PL4ODP_PPE_EOPEOBE  0x0080
-#define SUNI1x10GEXP_BITMSK_PL4ODP_PPE_ERREOPE  0x0040
-#define SUNI1x10GEXP_BITMSK_PL4ODP_PPE_MEOPE    0x0008
-#define SUNI1x10GEXP_BITMSK_PL4ODP_PPE_MSOPE    0x0004
-#define SUNI1x10GEXP_BITMSK_PL4ODP_ES_OVRE      0x0002
-
-
-/*----------------------------------------------------------------------------
- * Register 0x2283: PL4ODP Interrupt
- *    Bit 0 PL4ODP_OUT_DISI
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_PL4ODP_OUT_DISI     0x0001
-
-
-
-#define SUNI1x10GEXP_BITMSK_PL4ODP_PPE_EOPEOBI  0x0080
-#define SUNI1x10GEXP_BITMSK_PL4ODP_PPE_ERREOPI  0x0040
-#define SUNI1x10GEXP_BITMSK_PL4ODP_PPE_MEOPI    0x0008
-#define SUNI1x10GEXP_BITMSK_PL4ODP_PPE_MSOPI    0x0004
-#define SUNI1x10GEXP_BITMSK_PL4ODP_ES_OVRI      0x0002
-
-/*----------------------------------------------------------------------------
- * Register 0x2300:  PL4IO Lock Detect Status
- *    Bit 15 PL4IO_OUT_ROOLV
- *    Bit 12 PL4IO_IS_ROOLV
- *    Bit 11 PL4IO_DIP2_ERRV
- *    Bit 8  PL4IO_ID_ROOLV
- *    Bit 4  PL4IO_IS_DOOLV
- *    Bit 0  PL4IO_ID_DOOLV
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_PL4IO_OUT_ROOLV  0x8000
-#define SUNI1x10GEXP_BITMSK_PL4IO_IS_ROOLV   0x1000
-#define SUNI1x10GEXP_BITMSK_PL4IO_DIP2_ERRV  0x0800
-#define SUNI1x10GEXP_BITMSK_PL4IO_ID_ROOLV   0x0100
-#define SUNI1x10GEXP_BITMSK_PL4IO_IS_DOOLV   0x0010
-#define SUNI1x10GEXP_BITMSK_PL4IO_ID_DOOLV   0x0001
-
-/*----------------------------------------------------------------------------
- * Register 0x2301:  PL4IO Lock Detect Change
- *    Bit 15 PL4IO_OUT_ROOLI
- *    Bit 12 PL4IO_IS_ROOLI
- *    Bit 11 PL4IO_DIP2_ERRI
- *    Bit 8  PL4IO_ID_ROOLI
- *    Bit 4  PL4IO_IS_DOOLI
- *    Bit 0  PL4IO_ID_DOOLI
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_PL4IO_OUT_ROOLI  0x8000
-#define SUNI1x10GEXP_BITMSK_PL4IO_IS_ROOLI   0x1000
-#define SUNI1x10GEXP_BITMSK_PL4IO_DIP2_ERRI  0x0800
-#define SUNI1x10GEXP_BITMSK_PL4IO_ID_ROOLI   0x0100
-#define SUNI1x10GEXP_BITMSK_PL4IO_IS_DOOLI   0x0010
-#define SUNI1x10GEXP_BITMSK_PL4IO_ID_DOOLI   0x0001
-
-/*----------------------------------------------------------------------------
- * Register 0x2302:  PL4IO Lock Detect Mask
- *    Bit 15 PL4IO_OUT_ROOLE
- *    Bit 12 PL4IO_IS_ROOLE
- *    Bit 11 PL4IO_DIP2_ERRE
- *    Bit 8  PL4IO_ID_ROOLE
- *    Bit 4  PL4IO_IS_DOOLE
- *    Bit 0  PL4IO_ID_DOOLE
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_PL4IO_OUT_ROOLE  0x8000
-#define SUNI1x10GEXP_BITMSK_PL4IO_IS_ROOLE   0x1000
-#define SUNI1x10GEXP_BITMSK_PL4IO_DIP2_ERRE  0x0800
-#define SUNI1x10GEXP_BITMSK_PL4IO_ID_ROOLE   0x0100
-#define SUNI1x10GEXP_BITMSK_PL4IO_IS_DOOLE   0x0010
-#define SUNI1x10GEXP_BITMSK_PL4IO_ID_DOOLE   0x0001
-
-/*----------------------------------------------------------------------------
- * Register 0x2303:  PL4IO Lock Detect Limits
- *    Bit 15-8 PL4IO_REF_LIMIT
- *    Bit 7-0  PL4IO_TRAN_LIMIT
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_PL4IO_REF_LIMIT   0xFF00
-#define SUNI1x10GEXP_BITOFF_PL4IO_REF_LIMIT   8
-#define SUNI1x10GEXP_BITMSK_PL4IO_TRAN_LIMIT  0x00FF
-#define SUNI1x10GEXP_BITOFF_PL4IO_TRAN_LIMIT  0
-
-/*----------------------------------------------------------------------------
- * Register 0x2304:  PL4IO Calendar Repetitions
- *    Bit 15-8 PL4IO_IN_MUL
- *    Bit 7-0  PL4IO_OUT_MUL
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_PL4IO_IN_MUL   0xFF00
-#define SUNI1x10GEXP_BITOFF_PL4IO_IN_MUL   8
-#define SUNI1x10GEXP_BITMSK_PL4IO_OUT_MUL  0x00FF
-#define SUNI1x10GEXP_BITOFF_PL4IO_OUT_MUL  0
-
-/*----------------------------------------------------------------------------
- * Register 0x2305:  PL4IO Configuration
- *    Bit 15  PL4IO_DIP2_ERR_CHK
- *    Bit 11  PL4IO_ODAT_DIS
- *    Bit 10  PL4IO_TRAIN_DIS
- *    Bit 9   PL4IO_OSTAT_DIS
- *    Bit 8   PL4IO_ISTAT_DIS
- *    Bit 7   PL4IO_NO_ISTAT
- *    Bit 6   PL4IO_STAT_OUTSEL
- *    Bit 5   PL4IO_INSEL
- *    Bit 4   PL4IO_DLSEL
- *    Bit 1-0 PL4IO_OUTSEL
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_PL4IO_DIP2_ERR_CHK  0x8000
-#define SUNI1x10GEXP_BITMSK_PL4IO_ODAT_DIS      0x0800
-#define SUNI1x10GEXP_BITMSK_PL4IO_TRAIN_DIS     0x0400
-#define SUNI1x10GEXP_BITMSK_PL4IO_OSTAT_DIS     0x0200
-#define SUNI1x10GEXP_BITMSK_PL4IO_ISTAT_DIS     0x0100
-#define SUNI1x10GEXP_BITMSK_PL4IO_NO_ISTAT      0x0080
-#define SUNI1x10GEXP_BITMSK_PL4IO_STAT_OUTSEL   0x0040
-#define SUNI1x10GEXP_BITMSK_PL4IO_INSEL         0x0020
-#define SUNI1x10GEXP_BITMSK_PL4IO_DLSEL         0x0010
-#define SUNI1x10GEXP_BITMSK_PL4IO_OUTSEL        0x0003
-#define SUNI1x10GEXP_BITOFF_PL4IO_OUTSEL        0
-
-/*----------------------------------------------------------------------------
  * Register 0x3040: TXXG Configuration Register 1
  *    Bit 15   TXXG_TXEN0
  *    Bit 13   TXXG_HOSTPAUSE
@@ -1376,272 +206,16 @@
  *    Bit 4    TXXG_CRCEN
  *    Bit 3    TXXG_FCTX
  *    Bit 2    TXXG_FCRX
- *    Bit 1    TXXG_PADEN
+ *    Bit 1    TXXG_PADEN
  *    Bit 0    TXXG_SPRE
  *----------------------------------------------------------------------------*/
 #define SUNI1x10GEXP_BITMSK_TXXG_TXEN0        0x8000
-#define SUNI1x10GEXP_BITMSK_TXXG_HOSTPAUSE    0x2000
-#define SUNI1x10GEXP_BITMSK_TXXG_IPGT         0x1F80
 #define SUNI1x10GEXP_BITOFF_TXXG_IPGT         7
 #define SUNI1x10GEXP_BITMSK_TXXG_32BIT_ALIGN  0x0020
 #define SUNI1x10GEXP_BITMSK_TXXG_CRCEN        0x0010
 #define SUNI1x10GEXP_BITMSK_TXXG_FCTX         0x0008
 #define SUNI1x10GEXP_BITMSK_TXXG_FCRX         0x0004
 #define SUNI1x10GEXP_BITMSK_TXXG_PADEN        0x0002
-#define SUNI1x10GEXP_BITMSK_TXXG_SPRE         0x0001
-
-/*----------------------------------------------------------------------------
- * Register 0x3041: TXXG Configuration Register 2
- *    Bit 7-0   TXXG_HDRSIZE
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_TXXG_HDRSIZE  0x00FF
-
-/*----------------------------------------------------------------------------
- * Register 0x3042: TXXG Configuration Register 3
- *    Bit 15 TXXG_FIFO_ERRE
- *    Bit 14 TXXG_FIFO_UDRE
- *    Bit 13 TXXG_MAX_LERRE
- *    Bit 12 TXXG_MIN_LERRE
- *    Bit 11 TXXG_XFERE
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_TXXG_FIFO_ERRE  0x8000
-#define SUNI1x10GEXP_BITMSK_TXXG_FIFO_UDRE  0x4000
-#define SUNI1x10GEXP_BITMSK_TXXG_MAX_LERRE  0x2000
-#define SUNI1x10GEXP_BITMSK_TXXG_MIN_LERRE  0x1000
-#define SUNI1x10GEXP_BITMSK_TXXG_XFERE      0x0800
-
-/*----------------------------------------------------------------------------
- * Register 0x3043: TXXG Interrupt
- *    Bit 15 TXXG_FIFO_ERRI
- *    Bit 14 TXXG_FIFO_UDRI
- *    Bit 13 TXXG_MAX_LERRI
- *    Bit 12 TXXG_MIN_LERRI
- *    Bit 11 TXXG_XFERI
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_TXXG_FIFO_ERRI  0x8000
-#define SUNI1x10GEXP_BITMSK_TXXG_FIFO_UDRI  0x4000
-#define SUNI1x10GEXP_BITMSK_TXXG_MAX_LERRI  0x2000
-#define SUNI1x10GEXP_BITMSK_TXXG_MIN_LERRI  0x1000
-#define SUNI1x10GEXP_BITMSK_TXXG_XFERI      0x0800
-
-/*----------------------------------------------------------------------------
- * Register 0x3044: TXXG Status Register
- *    Bit 1 TXXG_TXACTIVE
- *    Bit 0 TXXG_PAUSED
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_TXXG_TXACTIVE  0x0002
-#define SUNI1x10GEXP_BITMSK_TXXG_PAUSED    0x0001
-
-/*----------------------------------------------------------------------------
- * Register 0x3046: TXXG TX_MINFR -  Transmit Min Frame Size Register
- *    Bit 7-0 TXXG_TX_MINFR
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_TXXG_TX_MINFR  0x00FF
-#define SUNI1x10GEXP_BITOFF_TXXG_TX_MINFR  0
-
-/*----------------------------------------------------------------------------
- * Register 0x3052: TXXG Pause Quantum Value Configuration Register
- *    Bit 7-0 TXXG_FC_PAUSE_QNTM
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_TXXG_FC_PAUSE_QNTM  0x00FF
-#define SUNI1x10GEXP_BITOFF_TXXG_FC_PAUSE_QNTM  0
-
-/*----------------------------------------------------------------------------
- * Register 0x3080: XTEF Control
- *    Bit 3-0 XTEF_FORCE_PARITY_ERR
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_XTEF_FORCE_PARITY_ERR  0x000F
-#define SUNI1x10GEXP_BITOFF_XTEF_FORCE_PARITY_ERR  0
-
-/*----------------------------------------------------------------------------
- * Register 0x3084: XTEF Interrupt Event Register
- *    Bit 0 XTEF_LOST_SYNCI
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_XTEF_LOST_SYNCI  0x0001
-
-/*----------------------------------------------------------------------------
- * Register 0x3085: XTEF Interrupt Enable Register
- *    Bit 0 XTEF_LOST_SYNCE
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_XTEF_LOST_SYNCE  0x0001
-
-/*----------------------------------------------------------------------------
- * Register 0x3086: XTEF Visibility Register
- *    Bit 0 XTEF_LOST_SYNCV
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_XTEF_LOST_SYNCV  0x0001
-
-/*----------------------------------------------------------------------------
- * Register 0x30C0: TXOAM OAM Configuration
- *    Bit 15   TXOAM_HEC_EN
- *    Bit 14   TXOAM_EMPTYCODE_EN
- *    Bit 13   TXOAM_FORCE_IDLE
- *    Bit 12   TXOAM_IGNORE_IDLE
- *    Bit 11-6 TXOAM_PX_OVERWRITE
- *    Bit 5-0  TXOAM_PX_SEL
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_TXOAM_HEC_EN        0x8000
-#define SUNI1x10GEXP_BITMSK_TXOAM_EMPTYCODE_EN  0x4000
-#define SUNI1x10GEXP_BITMSK_TXOAM_FORCE_IDLE    0x2000
-#define SUNI1x10GEXP_BITMSK_TXOAM_IGNORE_IDLE   0x1000
-#define SUNI1x10GEXP_BITMSK_TXOAM_PX_OVERWRITE  0x0FC0
-#define SUNI1x10GEXP_BITOFF_TXOAM_PX_OVERWRITE  6
-#define SUNI1x10GEXP_BITMSK_TXOAM_PX_SEL        0x003F
-#define SUNI1x10GEXP_BITOFF_TXOAM_PX_SEL        0
-
-/*----------------------------------------------------------------------------
- * Register 0x30C1: TXOAM Mini-Packet Rate Configuration
- *    Bit 15   TXOAM_MINIDIS
- *    Bit 14   TXOAM_BUSY
- *    Bit 13   TXOAM_TRANS_EN
- *    Bit 10-0 TXOAM_MINIRATE
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_TXOAM_MINIDIS   0x8000
-#define SUNI1x10GEXP_BITMSK_TXOAM_BUSY      0x4000
-#define SUNI1x10GEXP_BITMSK_TXOAM_TRANS_EN  0x2000
-#define SUNI1x10GEXP_BITMSK_TXOAM_MINIRATE  0x07FF
-
-/*----------------------------------------------------------------------------
- * Register 0x30C2: TXOAM Mini-Packet Gap and FIFO Configuration
- *    Bit 13-10 TXOAM_FTHRESH
- *    Bit 9-6   TXOAM_MINIPOST
- *    Bit 5-0   TXOAM_MINIPRE
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_TXOAM_FTHRESH   0x3C00
-#define SUNI1x10GEXP_BITOFF_TXOAM_FTHRESH   10
-#define SUNI1x10GEXP_BITMSK_TXOAM_MINIPOST  0x03C0
-#define SUNI1x10GEXP_BITOFF_TXOAM_MINIPOST  6
-#define SUNI1x10GEXP_BITMSK_TXOAM_MINIPRE   0x003F
-
-/*----------------------------------------------------------------------------
- * Register 0x30C6: TXOAM Interrupt Enable
- *    Bit 2 TXOAM_SOP_ERRE
- *    Bit 1 TXOAM_OFLE
- *    Bit 0 TXOAM_ERRE
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_TXOAM_SOP_ERRE    0x0004
-#define SUNI1x10GEXP_BITMSK_TXOAM_OFLE        0x0002
-#define SUNI1x10GEXP_BITMSK_TXOAM_ERRE        0x0001
-
-/*----------------------------------------------------------------------------
- * Register 0x30C7: TXOAM Interrupt Status
- *    Bit 2 TXOAM_SOP_ERRI
- *    Bit 1 TXOAM_OFLI
- *    Bit 0 TXOAM_ERRI
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_TXOAM_SOP_ERRI    0x0004
-#define SUNI1x10GEXP_BITMSK_TXOAM_OFLI        0x0002
-#define SUNI1x10GEXP_BITMSK_TXOAM_ERRI        0x0001
-
-/*----------------------------------------------------------------------------
- * Register 0x30CF: TXOAM Coset
- *    Bit 7-0 TXOAM_COSET
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_TXOAM_COSET  0x00FF
-
-/*----------------------------------------------------------------------------
- * Register 0x3200: EFLX Global Configuration
- *    Bit 15 EFLX_ERCU_EN
- *    Bit 7  EFLX_EN_EDSWT
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_EFLX_ERCU_EN   0x8000
-#define SUNI1x10GEXP_BITMSK_EFLX_EN_EDSWT  0x0080
-
-/*----------------------------------------------------------------------------
- * Register 0x3201: EFLX ERCU Global Status
- *    Bit 13 EFLX_OVF_ERR
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_EFLX_OVF_ERR  0x2000
-
-/*----------------------------------------------------------------------------
- * Register 0x3202: EFLX Indirect Channel Address
- *    Bit 15 EFLX_BUSY
- *    Bit 14 EFLX_RDWRB
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_EFLX_BUSY   0x8000
-#define SUNI1x10GEXP_BITMSK_EFLX_RDWRB  0x4000
-
-/*----------------------------------------------------------------------------
- * Register 0x3203: EFLX Indirect Logical FIFO Low Limit
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_EFLX_LOLIM                    0x03FF
-#define SUNI1x10GEXP_BITOFF_EFLX_LOLIM                    0
-
-/*----------------------------------------------------------------------------
- * Register 0x3204: EFLX Indirect Logical FIFO High Limit
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_EFLX_HILIM                    0x03FF
-#define SUNI1x10GEXP_BITOFF_EFLX_HILIM                    0
-
-/*----------------------------------------------------------------------------
- * Register 0x3205: EFLX Indirect Full/Almost-Full Status and Limit
- *    Bit 15   EFLX_FULL
- *    Bit 14   EFLX_AFULL
- *    Bit 13-0 EFLX_AFTH
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_EFLX_FULL   0x8000
-#define SUNI1x10GEXP_BITMSK_EFLX_AFULL  0x4000
-#define SUNI1x10GEXP_BITMSK_EFLX_AFTH   0x3FFF
-#define SUNI1x10GEXP_BITOFF_EFLX_AFTH   0
-
-/*----------------------------------------------------------------------------
- * Register 0x3206: EFLX Indirect Empty/Almost-Empty Status and Limit
- *    Bit 15   EFLX_EMPTY
- *    Bit 14   EFLX_AEMPTY
- *    Bit 13-0 EFLX_AETH
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_EFLX_EMPTY   0x8000
-#define SUNI1x10GEXP_BITMSK_EFLX_AEMPTY  0x4000
-#define SUNI1x10GEXP_BITMSK_EFLX_AETH    0x3FFF
-#define SUNI1x10GEXP_BITOFF_EFLX_AETH    0
-
-/*----------------------------------------------------------------------------
- * Register 0x3207: EFLX Indirect FIFO Cut-Through Threshold
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_EFLX_CUT_THRU                 0x3FFF
-#define SUNI1x10GEXP_BITOFF_EFLX_CUT_THRU                 0
-
-/*----------------------------------------------------------------------------
- * Register 0x320C: EFLX FIFO Overflow Error Enable
- *    Bit 0 EFLX_OVFE
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_EFLX_OVFE  0x0001
-
-/*----------------------------------------------------------------------------
- * Register 0x320D: EFLX FIFO Overflow Error Indication
- *    Bit 0 EFLX_OVFI
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_EFLX_OVFI  0x0001
-
-/*----------------------------------------------------------------------------
- * Register 0x3210: EFLX Channel Provision
- *    Bit 0 EFLX_PROV
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_EFLX_PROV  0x0001
-
-/*----------------------------------------------------------------------------
- * Register 0x3280: PL4IDU Configuration
- *    Bit 2 PL4IDU_SYNCH_ON_TRAIN
- *    Bit 1 PL4IDU_EN_PORTS
- *    Bit 0 PL4IDU_EN_DFWD
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_PL4IDU_SYNCH_ON_TRAIN  0x0004
-#define SUNI1x10GEXP_BITMSK_PL4IDU_EN_PORTS        0x0002
-#define SUNI1x10GEXP_BITMSK_PL4IDU_EN_DFWD         0x0001
-
-/*----------------------------------------------------------------------------
- * Register 0x3282: PL4IDU Interrupt Mask
- *    Bit 1 PL4IDU_DIP4E
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_PL4IDU_DIP4E       0x0002
-
-/*----------------------------------------------------------------------------
- * Register 0x3283: PL4IDU Interrupt
- *    Bit 1 PL4IDU_DIP4I
- *----------------------------------------------------------------------------*/
-#define SUNI1x10GEXP_BITMSK_PL4IDU_DIP4I       0x0002
-
-

 #endif /* _SUNI1x10GEXP_REGS_H */

diff -Naur linux-2.6.12-rc1-mm1/drivers/net/chelsio/tp.c linux-2.6.12-rc1-mm1.patched/drivers/net/chelsio/tp.c
--- linux-2.6.12-rc1-mm1/drivers/net/chelsio/tp.c	2005-03-22 13:05:45.000000000 -0800
+++ linux-2.6.12-rc1-mm1.patched/drivers/net/chelsio/tp.c	2005-03-22 23:56:44.000000000 -0800
@@ -1,34 +1,41 @@
-/*******************************************************************************
- *                                                                             *
- * File: tp.c                                                                  *
- * Revision: 1.2                                                               *
- * Date: 2005/03/10 07:07:38                                                   *
- * Description:                                                                *
- *  Core ASIC Management.                                                      *
- *  part of the Chelsio 10Gb Ethernet Driver.                                  *
- *                                                                             *
- * This program is free software; you can redistribute it and/or modify        *
- * it under the terms of the GNU General Public License, version 2, as         *
- * published by the Free Software Foundation.                                  *
- *                                                                             *
- * You should have received a copy of the GNU General Public License along     *
- * with this program; if not, write to the Free Software Foundation, Inc.,     *
- * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.                   *
- *                                                                             *
- * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR IMPLIED      *
- * WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF        *
- * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.                       *
- *                                                                             *
- * http://www.chelsio.com                                                      *
- *                                                                             *
- * Copyright (c) 2003 - 2005 Chelsio Communications, Inc.                      *
- * All rights reserved.                                                        *
- *                                                                             *
- * Maintainers: maintainers@chelsio.com                                        *
- *                                                                             *
- * History:                                                                    *
- *                                                                             *
- ******************************************************************************/
+/*****************************************************************************
+ *                                                                           *
+ * File: tp.c                                                                *
+ * $Revision: 1.6 $                                                          *
+ * $Date: 2005/03/23 07:15:59 $                                              *
+ * Description:                                                              *
+ *  Core ASIC Management.                                                    *
+ *  part of the Chelsio 10Gb Ethernet Driver.                                *
+ *                                                                           *
+ * This program is free software; you can redistribute it and/or modify      *
+ * it under the terms of the GNU General Public License, version 2, as       *
+ * published by the Free Software Foundation.                                *
+ *                                                                           *
+ * You should have received a copy of the GNU General Public License along   *
+ * with this program; if not, write to the Free Software Foundation, Inc.,   *
+ * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.                 *
+ *                                                                           *
+ * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR IMPLIED    *
+ * WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF      *
+ * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.                     *
+ *                                                                           *
+ * http://www.chelsio.com                                                    *
+ *                                                                           *
+ * Copyright (c) 2003 - 2005 Chelsio Communications, Inc.                    *
+ * All rights reserved.                                                      *
+ *                                                                           *
+ * Maintainers: maintainers@chelsio.com                                      *
+ *                                                                           *
+ * Authors: Dimitrios Michailidis   <dm@chelsio.com>                         *
+ *          Tina Yang               <tainay@chelsio.com>                     *
+ *          Felix Marti             <felix@chelsio.com>                      *
+ *          Scott Bardone           <sbardone@chelsio.com>                   *
+ *          Kurt Ottaway            <kottaway@chelsio.com>                   *
+ *          Frank DiMambro          <frank@chelsio.com>                      *
+ *                                                                           *
+ * History:                                                                  *
+ *                                                                           *
+ ****************************************************************************/

 #include "common.h"
 #include "regs.h"
@@ -83,15 +90,15 @@

 void t1_tp_destroy(struct petp *tp)
 {
-	t1_free((void *)tp, sizeof(*tp));
+	kfree(tp);
 }

 struct petp * __devinit t1_tp_create(adapter_t *adapter, struct tp_params *p)
 {
-	struct petp *tp = t1_malloc(sizeof(*tp));
+	struct petp *tp = kmalloc(sizeof(*tp), GFP_KERNEL);
 	if (!tp)
 		return NULL;
-
+	memset(tp, 0, sizeof(*tp));
 	tp->adapter = adapter;

 	return tp;
@@ -176,6 +183,6 @@
 		t1_write_reg_4(adapter, A_TP_RESET, F_TP_RESET);
 	else
 		CH_ERR("%s: TP initialization timed out\n",
-		       adapter_name(adapter));
+		       adapter->name);
 	return busy;
 }
diff -Naur linux-2.6.12-rc1-mm1/drivers/net/chelsio/tp.h linux-2.6.12-rc1-mm1.patched/drivers/net/chelsio/tp.h
--- linux-2.6.12-rc1-mm1/drivers/net/chelsio/tp.h	2005-03-22 13:05:45.000000000 -0800
+++ linux-2.6.12-rc1-mm1.patched/drivers/net/chelsio/tp.h	2005-03-22 23:56:44.000000000 -0800
@@ -1,33 +1,40 @@
-/*******************************************************************************
- *                                                                             *
- * File: tp.h                                                                  *
- * Revision: 1.2                                                               *
- * Date: 2005/03/10 07:07:38                                                   *
- * Description:                                                                *
- *  part of the Chelsio 10Gb Ethernet Driver.                                  *
- *                                                                             *
- * This program is free software; you can redistribute it and/or modify        *
- * it under the terms of the GNU General Public License, version 2, as         *
- * published by the Free Software Foundation.                                  *
- *                                                                             *
- * You should have received a copy of the GNU General Public License along     *
- * with this program; if not, write to the Free Software Foundation, Inc.,     *
- * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.                   *
- *                                                                             *
- * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR IMPLIED      *
- * WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF        *
- * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.                       *
- *                                                                             *
- * http://www.chelsio.com                                                      *
- *                                                                             *
- * Copyright (c) 2003 - 2005 Chelsio Communications, Inc.                      *
- * All rights reserved.                                                        *
- *                                                                             *
- * Maintainers: maintainers@chelsio.com                                        *
- *                                                                             *
- * History:                                                                    *
- *                                                                             *
- ******************************************************************************/
+/*****************************************************************************
+ *                                                                           *
+ * File: tp.h                                                                *
+ * $Revision: 1.3 $                                                          *
+ * $Date: 2005/03/23 07:15:59 $                                              *
+ * Description:                                                              *
+ *  part of the Chelsio 10Gb Ethernet Driver.                                *
+ *                                                                           *
+ * This program is free software; you can redistribute it and/or modify      *
+ * it under the terms of the GNU General Public License, version 2, as       *
+ * published by the Free Software Foundation.                                *
+ *                                                                           *
+ * You should have received a copy of the GNU General Public License along   *
+ * with this program; if not, write to the Free Software Foundation, Inc.,   *
+ * 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.                 *
+ *                                                                           *
+ * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR IMPLIED    *
+ * WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF      *
+ * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.                     *
+ *                                                                           *
+ * http://www.chelsio.com                                                    *
+ *                                                                           *
+ * Copyright (c) 2003 - 2005 Chelsio Communications, Inc.                    *
+ * All rights reserved.                                                      *
+ *                                                                           *
+ * Maintainers: maintainers@chelsio.com                                      *
+ *                                                                           *
+ * Authors: Dimitrios Michailidis   <dm@chelsio.com>                         *
+ *          Tina Yang               <tainay@chelsio.com>                     *
+ *          Felix Marti             <felix@chelsio.com>                      *
+ *          Scott Bardone           <sbardone@chelsio.com>                   *
+ *          Kurt Ottaway            <kottaway@chelsio.com>                   *
+ *          Frank DiMambro          <frank@chelsio.com>                      *
+ *                                                                           *
+ * History:                                                                  *
+ *                                                                           *
+ ****************************************************************************/

 #ifndef CHELSIO_TP_H
 #define CHELSIO_TP_H
