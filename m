From: David Hendel <david@silicom.co.il>
Subject: RE: Silicom bypass driver promote from staging
Date: Mon, 29 Sep 2014 07:18:35 +0000
Message-ID: <3BFAEADE799AF145974162DF00E013AF018F8C8A9F@exchange2010.silicom.local>
References: <3BFAEADE799AF145974162DF00E013AF018F80FFCF@exchange2010.silicom.local>
 <20140805150957.GC27303@kroah.com>
 <3BFAEADE799AF145974162DF00E013AF018F814DAB@exchange2010.silicom.local>
 <20140807215115.GB19520@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"arnd@arndb.de" <arnd@arndb.de>, Anna Lukin <annal@silicom.co.il>,
	"gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 105.74.80-QoS-user.in-addr.arpa ([80.74.105.217]:18732 "EHLO
	exchange2010.silicom.local" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751146AbaI2HTD convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Sep 2014 03:19:03 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,
Sorry, for the late response, we had to go over all the code and update as requested and then test to verify, so here it is.

See below with some responses and attached, hope we can move forward with that. getting the bypass driver into the kernel.

On Thu, 7 Aug 2014 19:56 Stephen Hemminger <stephen@networkplumber.org> wrote:
>The current driver uses a device specific /proc interface.
>That API programming model will not likely be acceptable in a standard network driver.
>Please consider doing something generic with netlink.

Actually, this is not a network driver, many of the users use this interface to  control the bypass/fail-to-wire to control this function. We can add netlink api as additional interface,  but  not having  proc interface maybe a problem.

On Thu, 7 Aug 2014 23:20 gregkh@linuxfoundation.org wrote:
>Making your patch an attachment in base64 mode, makes it impossible to 
>quote to review it :(
>
>Anyway, I stopped at the first header file.  The kernel already has BIT definitions, no driver should ever have to redefine these and do it on their own.
>  That leads me to believe that this code really isn't all that "cleaned up" at all.
>
>Should I just look at what is in drivers/staging/silicom/ right now as code to review?  Or have you changed it any by making this patch?

OK, will do that,
drivers/staging/silicom/ driver was created from silicom bypass driver released in December 2012. 
The driver we are providing now is based on this staging driver.
We updated it to our Latest release (adding support for new adapters, some changes in functionality) and fixed bug (loading the driver from staging led to kernel panic).


On Fri, 8 Aug 2014 00:51 Francois Romieu <romieu@fr.zoreil.com> wrote:
>Location is the easy part. Getting things reviewed is a different story.
>
>You shouldn't expect reviewers to swallow 300k of code (600k / 2 due to removal). Please split the submitted patch into smaller, self-consistent, logical ones.
>
We will include the patches in the following emails inline each will have smaller size, hope this will be as you expect.

>Notwithstanding Stephen and Jeff's remarks, you should also:
>- remove the (out-)commented code
>- reconsider the use of gorilla class macros vs plain functions
>- stop casting ioremap return into long, then later into void *. It's
>  void __iomem * and should stay so.
>- use a consistent locking style and remove BP_SYNC_FLAG
>- fix the 80 cols limit problem(s) (hardly surprizing after 5 levels of
 > nested "if")
>- avoid redefining stuff from include/uapi/linux/mii.h
> I may be wrong but BPCTLI_MII_CR_POWER_DOWN smells of BMCR_PDOWN and
>  BPCTLI_PHY_CONTROL, well, MII_BMCR ?
>- avoid returning with spinlock held (read_reg, wdt_pulse)
>- start explaining what did change between two submissions

This is what we changed in updated patch:
1. Avoid redefining BIT and MII .
2. Fixing returning with spinlock held
3. Remove BP_SYNC_FLAG
4. Use void __iomem * instead of long long in ioremap return
5. Cleanup with checkpatch.pl

Hope that it is OK now, or at least better.

Here is the code,


Bp_ctl patch,
--------------------------------------------------------------------------------------------------
Signed-off-by: Anna Lukin <annal@silicom.co.il>
diff -uprN -X linux-3.17-rc1-vanilla/Documentation/dontdiff linux-3.17-rc1-vanilla/drivers/bypass/Kconfig linux-3.17-rc1/drivers/bypass/Kconfig
--- linux-3.17-rc1-vanilla/drivers/bypass/Kconfig	1970-01-01 02:00:00.000000000 +0200
+++ linux-3.17-rc1/drivers/bypass/Kconfig	2014-08-03 13:48:27.000000000 +0300
@@ -0,0 +1,26 @@
+#
+# Bypass Devices configuration
+#
+
+menu "Bypass Devices"
+
+config BYPASS
+	bool "Bypass Devices"
+	default y
+	---help---
+	  If you have a bypass devices, say Y.
+
+	  Note that the answer to this question does not directly affect
+	  the kernel: saying N will just case the configurator to skip all
+	  the questions regarding bypass devices. If you say Y, you will be asked
+	  for your specific chipset/driver in the following questions.
+
+if BYPASS
+
+source "drivers/bypass/silicom/Kconfig"
+
+
+endif # BYPASS
+
+endmenu
+
diff -uprN -X linux-3.17-rc1-vanilla/Documentation/dontdiff linux-3.17-rc1-vanilla/drivers/bypass/Makefile linux-3.17-rc1/drivers/bypass/Makefile
--- linux-3.17-rc1-vanilla/drivers/bypass/Makefile	1970-01-01 02:00:00.000000000 +0200
+++ linux-3.17-rc1/drivers/bypass/Makefile	2014-07-22 08:55:56.000000000 +0300
@@ -0,0 +1,5 @@
+#
+# Makefile for the Bypass device drivers.
+#
+
+obj-$(CONFIG_NET_VENDOR_SILICOM) += silicom/
diff -uprN -X linux-3.17-rc1-vanilla/Documentation/dontdiff linux-3.17-rc1-vanilla/drivers/bypass/silicom/bp_ctl/bpctl_mod.c linux-3.17-rc1/drivers/bypass/silicom/bp_ctl/bpctl_mod.c
--- linux-3.17-rc1-vanilla/drivers/bypass/silicom/bp_ctl/bpctl_mod.c	1970-01-01 02:00:00.000000000 +0200
+++ linux-3.17-rc1/drivers/bypass/silicom/bp_ctl/bpctl_mod.c	2014-09-09 00:43:05.000000000 +0300
@@ -0,0 +1,7285 @@
+/******************************************************************************/
+/*                                                                            */
+/* Bypass Control utility, Copyright (c) 2005-2014 Silicom                    */
+/*                                                                            */
+/* This program is free software; you can redistribute it and/or modify       */
+/* it under the terms of the GNU General Public License as published by       */
+/* the Free Software Foundation, located in the file LICENSE.                 */
+/* Copyright(c) 2007 - 2009, 2013 Intel Corporation. All rights reserved.     */
+/*                                                                            */
+/*                                                                            */
+/******************************************************************************/
+
+#include <linux/kernel.h>       /* We're doing kernel work */
+#include <linux/module.h>       /* Specifically, a module */
+#include <linux/fs.h>
+#include <linux/pci.h>
+#include <linux/delay.h>
+#include <linux/netdevice.h>
+#include <linux/rtnetlink.h>
+#include <linux/rcupdate.h>
+#include <linux/etherdevice.h>
+
+#include <linux/uaccess.h>      /* for get_user and put_user */
+#include <linux/sched.h>
+#include <linux/ethtool.h>
+#include <linux/proc_fs.h>
+#include <uapi/linux/mii.h>
+
+#include "bp_ioctl.h"
+#include "bp_mod.h"
+#include "bypass.h"
+#include "libbp_sd.h"
+
+#define SUCCESS 0
+#define BP_MOD_VER  "9.0.4"
+#define BP_MOD_DESCR "Silicom Bypass-SD Control driver"
+
+MODULE_AUTHOR("Anna Lukin, annal@silicom.co.il");
+MODULE_LICENSE("GPL");
+MODULE_DESCRIPTION(BP_MOD_DESCR);
+MODULE_VERSION(BP_MOD_VER);
+
+static spinlock_t bpvm_lock;
+static struct bpctl_dev *bpctl_dev_arr;
+static struct semaphore bpctl_sema;
+static int device_num;
+static int major_num;
+
+#define BP_PROC_DIR "bypass"
+static struct proc_dir_entry *bp_procfs_dir;
+
+static int bypass_proc_create_dev_sd(struct bpctl_dev *pbp_device_block);
+static int bypass_proc_remove_dev_sd(struct bpctl_dev *pbp_device_block);
+
+static struct bpctl_dev *lookup_port(struct bpctl_dev *dev)
+{
+	struct bpctl_dev *p;
+	int n;
+
+	for (n = 0, p = bpctl_dev_arr; n < device_num && p->pdev; n++, p++) {
+		if (p->bus == dev->bus
+			&& p->slot == dev->slot
+			&& p->func == (dev->func ^ 1))
+			return p;
+	}
+	return NULL;
+}
+
+static struct bpctl_dev *get_status_port(struct bpctl_dev *pbpctl_dev)
+{
+	if (pbpctl_dev) {
+		if (pbpctl_dev->func == 0 || pbpctl_dev->func == 2)
+			return lookup_port(pbpctl_dev);
+	}
+	return NULL;
+}
+
+static struct bpctl_dev *get_master_port(struct bpctl_dev *pbpctl_dev)
+{
+	if (pbpctl_dev) {
+		if (pbpctl_dev->func == 1 || pbpctl_dev->func == 3)
+			return lookup_port(pbpctl_dev);
+	}
+	return NULL;
+}
+
+static int get_dev_idx_bsf(int bus, int slot, int func)
+{
+	int idx_dev = 0;
+
+	for (idx_dev = 0;
+		((bpctl_dev_arr[idx_dev].pdev != NULL) &&
+		 (idx_dev < device_num)); idx_dev++) {
+		if ((bus == bpctl_dev_arr[idx_dev].bus)
+			&& (slot == bpctl_dev_arr[idx_dev].slot)
+			&& (func == bpctl_dev_arr[idx_dev].func))
+
+			return idx_dev;
+	}
+	return BP_NOT_CAP;
+}
+
+static int bp_get_dev_idx_bsf(struct net_device *dev, int *index)
+{
+	struct ethtool_drvinfo drvinfo = {0};
+	char *buf;
+	int bus, slot, func;
+
+	if (dev->ethtool_ops && dev->ethtool_ops->get_drvinfo)
+		dev->ethtool_ops->get_drvinfo(dev, &drvinfo);
+	else
+		return -EOPNOTSUPP;
+
+	if (!strcmp(drvinfo.bus_info, "N/A"))
+		return -ENODATA;
+
+	buf = strchr(drvinfo.bus_info, ':');
+	if (!buf)
+		return -EINVAL;
+	buf++;
+	if (sscanf(buf, "%x:%x.%x", &bus, &slot, &func) != 3)
+		return -EINVAL;
+
+	*index = get_dev_idx_bsf(bus, slot, func);
+	return 0;
+}
+
+static int get_dev_idx(int ifindex)
+{
+	int idx_dev = 0;
+
+	for (idx_dev = 0;
+		((bpctl_dev_arr[idx_dev].pdev != NULL) &&
+		 (idx_dev < device_num)); idx_dev++) {
+		if (ifindex == bpctl_dev_arr[idx_dev].ifindex)
+			return idx_dev;
+	}
+
+	return BP_NOT_CAP;
+}
+
+static int is_bypass(struct bpctl_dev *pbpctl_dev)
+{
+	if (!pbpctl_dev)
+		return BP_NOT_CAP;
+
+	if ((pbpctl_dev->func == 0) || (pbpctl_dev->func == 2))
+		return 1;
+	return 0;
+}
+
+static int wdt_time_left(struct bpctl_dev *pbpctl_dev)
+{
+	unsigned long curr_time = jiffies, delta_time = 0, wdt_on_time =
+		pbpctl_dev->bypass_wdt_on_time, delta_time_msec = 0;
+	int time_left = 0;
+
+	switch (pbpctl_dev->wdt_status) {
+	case WDT_STATUS_DIS:
+		time_left = 0;
+		break;
+	case WDT_STATUS_EN:
+		delta_time =
+			(curr_time >= wdt_on_time) ?
+			(curr_time - wdt_on_time)
+			:
+			(~wdt_on_time + curr_time);
+		delta_time_msec = jiffies_to_msecs(delta_time);
+		time_left =
+			pbpctl_dev->bypass_timer_interval - delta_time_msec;
+		if (time_left < 0) {
+			time_left = -1;
+			pbpctl_dev->wdt_status = WDT_STATUS_EXP;
+		}
+		break;
+	case WDT_STATUS_EXP:
+		time_left = -1;
+		break;
+	}
+
+	return time_left;
+}
+
+static void write_pulse(struct bpctl_dev *pbpctl_dev,
+			unsigned int ctrl_ext,
+			unsigned char value, unsigned char len)
+{
+	unsigned char ctrl_val = 0;
+	unsigned int i = len;
+	unsigned int ctrl = 0;
+	struct bpctl_dev *pbpctl_dev_c = NULL;
+
+	switch (pbpctl_dev->nic_type) {
+	case bp_i80:
+		ctrl = BPCTL_READ_REG(pbpctl_dev, CTRL_EXT);
+		break;
+	case bp_540:
+		ctrl = BP10G_READ_REG(pbpctl_dev, ESDP);
+		break;
+	case bp_10g9:
+		pbpctl_dev_c = get_status_port(pbpctl_dev);
+		if (!pbpctl_dev_c)
+			return;
+		ctrl = BP10G_READ_REG(pbpctl_dev_c, ESDP);
+		break;
+	default:
+		break;
+	}
+
+	while (i--) {
+		ctrl_val = (value >> i) & 0x1;
+		if (ctrl_val) {
+			switch (pbpctl_dev->nic_type) {
+			case bp_10g9:
+				/* To start management : */
+				/* MCLK 1, MDIO 1, output */
+				/* DATA 1 CLK 1 */
+				BP10G_WRITE_REG(pbpctl_dev, I2CCTL,
+						ctrl_ext |
+						BP10G_MDIO_DATA_OUT9);
+				BP10G_WRITE_REG(pbpctl_dev_c, ESDP,
+						(ctrl | BP10G_MCLK_DATA_OUT9 |
+						 BP10G_MCLK_DIR_OUT9));
+				break;
+			case bp_fiber5:
+				BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL, (ctrl_ext |
+						BPCTLI_CTRL_EXT_MCLK_DIR5
+						|
+						BPCTLI_CTRL_EXT_MDIO_DIR5
+						|
+						BPCTLI_CTRL_EXT_MDIO_DATA5
+						|
+						BPCTLI_CTRL_EXT_MCLK_DATA5));
+				break;
+			case bp_i80:
+				BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL, (ctrl_ext |
+						BPCTLI_CTRL_EXT_MDIO_DIR80
+						|
+						BPCTLI_CTRL_EXT_MDIO_DATA80));
+
+				BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL_EXT, (ctrl |
+						BPCTLI_CTRL_EXT_MCLK_DIR80
+						|
+						BPCTLI_CTRL_EXT_MCLK_DATA80));
+				break;
+			case bp_540:
+				BP10G_WRITE_REG(pbpctl_dev, ESDP, (ctrl |
+						BP540_MDIO_DIR
+						|
+						BP540_MDIO_DATA
+						|
+						BP540_MCLK_DIR
+						|
+						BP540_MCLK_DATA));
+				break;
+			case bp_10gb:
+				BP10GB_WRITE_REG(pbpctl_dev, MISC_REG_SPIO,
+						 (ctrl_ext | BP10GB_MDIO_SET |
+						  BP10GB_MCLK_SET) &
+						 ~(BP10GB_MCLK_DIR |
+						   BP10GB_MDIO_DIR |
+						   BP10GB_MDIO_CLR |
+						   BP10GB_MCLK_CLR));
+				break;
+			case bp_10g:
+				/* To start management : */
+				/* MCLK 1, MDIO 1, output*/
+				BP10G_WRITE_REG(pbpctl_dev, EODSDP,
+						(ctrl_ext | BP10G_MCLK_DATA_OUT
+						 | BP10G_MDIO_DATA_OUT));
+				break;
+			default:
+				/* To start management : */
+				/* MCLK 1, MDIO 1, output */
+				BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL_EXT,
+						   (ctrl_ext |
+						   BPCTLI_CTRL_EXT_MCLK_DIR |
+						   BPCTLI_CTRL_EXT_MDIO_DIR |
+						   BPCTLI_CTRL_EXT_MDIO_DATA |
+						   BPCTLI_CTRL_EXT_MCLK_DATA));
+				break;
+			}
+			usec_delay(PULSE_TIME);
+			switch (pbpctl_dev->nic_type) {
+			case bp_10g9:
+				/* DATA 1 CLK 0 */
+				BP10G_WRITE_REG(pbpctl_dev, I2CCTL,
+						ctrl_ext |
+						BP10G_MDIO_DATA_OUT9);
+				BP10G_WRITE_REG(pbpctl_dev_c, ESDP,
+						(ctrl | BP10G_MCLK_DIR_OUT9) &
+						~BP10G_MCLK_DATA_OUT9);
+				break;
+			case bp_fiber5:
+				BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL,
+						((ctrl_ext |
+						 BPCTLI_CTRL_EXT_MCLK_DIR5 |
+						 BPCTLI_CTRL_EXT_MDIO_DIR5 |
+						 BPCTLI_CTRL_EXT_MDIO_DATA5)
+						 &
+						 ~
+						 (BPCTLI_CTRL_EXT_MCLK_DATA5)));
+				break;
+			case bp_i80:
+				BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL, (ctrl_ext |
+						BPCTLI_CTRL_EXT_MDIO_DIR80
+						  |
+						  BPCTLI_CTRL_EXT_MDIO_DATA80));
+				BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL_EXT,
+						((ctrl |
+						BPCTLI_CTRL_EXT_MCLK_DIR80)
+						&
+						~
+						(BPCTLI_CTRL_EXT_MCLK_DATA80)));
+				break;
+			case bp_540:
+				BP10G_WRITE_REG(pbpctl_dev, ESDP,
+						(ctrl | BP540_MDIO_DIR |
+						 BP540_MDIO_DATA |
+						 BP540_MCLK_DIR) &
+						 ~(BP540_MCLK_DATA));
+				break;
+			case bp_10gb:
+				BP10GB_WRITE_REG(pbpctl_dev, MISC_REG_SPIO,
+						 (ctrl_ext | BP10GB_MDIO_SET |
+						  BP10GB_MCLK_CLR) &
+						 ~(BP10GB_MCLK_DIR |
+						   BP10GB_MDIO_DIR |
+						   BP10GB_MDIO_CLR |
+						   BP10GB_MCLK_SET));
+				break;
+			case bp_10g:
+				BP10G_WRITE_REG(pbpctl_dev, EODSDP,
+						((ctrl_ext |
+						  BP10G_MDIO_DATA_OUT) &
+						 ~(BP10G_MCLK_DATA_OUT)));
+				break;
+			default:
+				BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL_EXT,
+						((ctrl_ext |
+						  BPCTLI_CTRL_EXT_MCLK_DIR |
+						  BPCTLI_CTRL_EXT_MDIO_DIR |
+						  BPCTLI_CTRL_EXT_MDIO_DATA)
+						  &
+						  ~
+						  (BPCTLI_CTRL_EXT_MCLK_DATA)));
+				break;
+			}
+			usec_delay(PULSE_TIME);
+		} else {
+			switch (pbpctl_dev->nic_type) {
+			case bp_10g9:
+				/* DATA 0 CLK 1 */
+				BP10G_WRITE_REG(pbpctl_dev, I2CCTL,
+						(ctrl_ext &
+						 ~BP10G_MDIO_DATA_OUT9));
+				BP10G_WRITE_REG(pbpctl_dev_c, ESDP,
+						(ctrl | BP10G_MCLK_DATA_OUT9 |
+						 BP10G_MCLK_DIR_OUT9));
+				break;
+			case bp_fiber5:
+				BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL,
+						((ctrl_ext |
+						  BPCTLI_CTRL_EXT_MCLK_DIR5 |
+						  BPCTLI_CTRL_EXT_MDIO_DIR5 |
+						  BPCTLI_CTRL_EXT_MCLK_DATA5)
+						  &
+						  ~
+						(BPCTLI_CTRL_EXT_MDIO_DATA5)));
+				break;
+			case bp_i80:
+				BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL,
+					((ctrl_ext |
+					  BPCTLI_CTRL_EXT_MDIO_DIR80)
+					  &
+					  ~
+					  (BPCTLI_CTRL_EXT_MDIO_DATA80)));
+				BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL_EXT,
+						(ctrl |
+						 BPCTLI_CTRL_EXT_MCLK_DIR80 |
+						 BPCTLI_CTRL_EXT_MCLK_DATA80));
+				break;
+			case bp_540:
+				BP10G_WRITE_REG(pbpctl_dev, ESDP,
+						((ctrl | BP540_MCLK_DIR |
+						  BP540_MCLK_DATA |
+						  BP540_MDIO_DIR) &
+						 ~(BP540_MDIO_DATA)));
+				break;
+			case bp_10gb:
+				BP10GB_WRITE_REG(pbpctl_dev, MISC_REG_SPIO,
+						 (ctrl_ext | BP10GB_MDIO_CLR |
+						  BP10GB_MCLK_SET) &
+						 ~(BP10GB_MCLK_DIR |
+						   BP10GB_MDIO_DIR |
+						   BP10GB_MDIO_SET |
+						   BP10GB_MCLK_CLR));
+				break;
+			case bp_10g:
+				BP10G_WRITE_REG(pbpctl_dev, EODSDP,
+						((ctrl_ext |
+						  BP10G_MCLK_DATA_OUT) &
+						  ~BP10G_MDIO_DATA_OUT));
+				break;
+			default:
+				BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL_EXT,
+					((ctrl_ext |
+					  BPCTLI_CTRL_EXT_MCLK_DIR |
+					  BPCTLI_CTRL_EXT_MDIO_DIR |
+					  BPCTLI_CTRL_EXT_MCLK_DATA)
+					  &
+					  ~
+					  (BPCTLI_CTRL_EXT_MDIO_DATA)));
+				break;
+			}
+			usec_delay(PULSE_TIME);
+			switch (pbpctl_dev->nic_type) {
+			case bp_10g9:
+				/* DATA 0 CLK 0 */
+				BP10G_WRITE_REG(pbpctl_dev, I2CCTL,
+						(ctrl_ext &
+						 ~BP10G_MDIO_DATA_OUT9));
+				BP10G_WRITE_REG(pbpctl_dev_c, ESDP,
+						((ctrl | BP10G_MCLK_DIR_OUT9) &
+						 ~(BP10G_MCLK_DATA_OUT9)));
+				break;
+			case bp_fiber5:
+				BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL,
+						((ctrl_ext |
+						BPCTLI_CTRL_EXT_MCLK_DIR5 |
+						BPCTLI_CTRL_EXT_MDIO_DIR5)
+						&
+						~(BPCTLI_CTRL_EXT_MCLK_DATA5
+						|
+						BPCTLI_CTRL_EXT_MDIO_DATA5)));
+				break;
+			case bp_i80:
+				BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL,
+					((ctrl_ext |
+					  BPCTLI_CTRL_EXT_MDIO_DIR80)
+					  &
+					  ~BPCTLI_CTRL_EXT_MDIO_DATA80));
+				BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL_EXT,
+					((ctrl |
+					  BPCTLI_CTRL_EXT_MCLK_DIR80)
+					  &
+					  ~
+					  (BPCTLI_CTRL_EXT_MCLK_DATA80)));
+				break;
+			case bp_540:
+				BP10G_WRITE_REG(pbpctl_dev, ESDP,
+						((ctrl | BP540_MCLK_DIR |
+						  BP540_MDIO_DIR) &
+						 ~(BP540_MDIO_DATA |
+						   BP540_MCLK_DATA)));
+				break;
+			case bp_10gb:
+				BP10GB_WRITE_REG(pbpctl_dev, MISC_REG_SPIO,
+						 (ctrl_ext | BP10GB_MDIO_CLR |
+						  BP10GB_MCLK_CLR) &
+						 ~(BP10GB_MCLK_DIR |
+						   BP10GB_MDIO_DIR |
+						   BP10GB_MDIO_SET |
+						   BP10GB_MCLK_SET));
+				break;
+			case bp_10g:
+				BP10G_WRITE_REG(pbpctl_dev, EODSDP,
+						(ctrl_ext &
+						 ~(BP10G_MCLK_DATA_OUT |
+						   BP10G_MDIO_DATA_OUT)));
+				break;
+			default:
+				BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL_EXT,
+						((ctrl_ext |
+						  BPCTLI_CTRL_EXT_MCLK_DIR |
+						  BPCTLI_CTRL_EXT_MDIO_DIR) &
+						  ~(BPCTLI_CTRL_EXT_MCLK_DATA
+						  |
+						  BPCTLI_CTRL_EXT_MDIO_DATA)));
+				break;
+			}
+			usec_delay(PULSE_TIME);
+		}
+	}
+}
+
+static int read_pulse(struct bpctl_dev *pbpctl_dev, unsigned int ctrl_ext,
+			  unsigned char len)
+{
+	unsigned char ctrl_val = 0;
+	unsigned int i = len;
+	unsigned int ctrl = 0;
+	struct bpctl_dev *pbpctl_dev_c = NULL;
+
+	switch (pbpctl_dev->nic_type) {
+	case bp_i80:
+		ctrl = BPCTL_READ_REG(pbpctl_dev, CTRL_EXT);
+		break;
+	case bp_540:
+		ctrl = BP10G_READ_REG(pbpctl_dev, ESDP);
+		break;
+	case bp_10g9:
+		pbpctl_dev_c = get_status_port(pbpctl_dev);
+		if (!pbpctl_dev_c)
+			return BP_NOT_CAP;
+		ctrl = BP10G_READ_REG(pbpctl_dev_c, ESDP);
+		break;
+	}
+
+	while (i--) {
+		switch (pbpctl_dev->nic_type) {
+		case bp_10g9:
+			/* DATA ? CLK 0 */
+			BP10G_WRITE_REG(pbpctl_dev_c, ESDP,
+					((ctrl | BP10G_MCLK_DIR_OUT9) &
+					 ~(BP10G_MCLK_DATA_OUT9)));
+			break;
+		case bp_fiber5:
+			BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL, ((ctrl_ext |
+					   BPCTLI_CTRL_EXT_MCLK_DIR5)
+					   &
+					   ~
+					   (BPCTLI_CTRL_EXT_MDIO_DIR5
+					   |
+					   BPCTLI_CTRL_EXT_MCLK_DATA5)));
+			break;
+		case bp_i80:
+			BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL,
+					   (ctrl_ext &
+					    ~BPCTLI_CTRL_EXT_MDIO_DIR80));
+			BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL_EXT,
+					((ctrl | BPCTLI_CTRL_EXT_MCLK_DIR80)
+					  & ~(BPCTLI_CTRL_EXT_MCLK_DATA80)));
+			break;
+		case bp_540:
+			BP10G_WRITE_REG(pbpctl_dev, ESDP,
+					((ctrl | BP540_MCLK_DIR) &
+					 ~(BP540_MDIO_DIR | BP540_MCLK_DATA)));
+			break;
+		case bp_10gb:
+			BP10GB_WRITE_REG(pbpctl_dev, MISC_REG_SPIO,
+					 (ctrl_ext | BP10GB_MDIO_DIR |
+					  BP10GB_MCLK_CLR) &
+					  ~(BP10GB_MCLK_DIR |
+					  BP10GB_MDIO_CLR |
+					  BP10GB_MDIO_SET |
+					  BP10GB_MCLK_SET));
+			break;
+		case bp_10g:
+			BP10G_WRITE_REG(pbpctl_dev, EODSDP, ((ctrl_ext |
+					BP10G_MDIO_DATA_OUT) &
+					~BP10G_MCLK_DATA_OUT));
+			break;
+		default:
+			BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL_EXT, ((ctrl_ext |
+					   BPCTLI_CTRL_EXT_MCLK_DIR)
+					   &
+					   ~
+					   (BPCTLI_CTRL_EXT_MDIO_DIR
+					   |
+					   BPCTLI_CTRL_EXT_MCLK_DATA)));
+			break;
+		}
+		usec_delay(PULSE_TIME);
+		switch (pbpctl_dev->nic_type) {
+		case bp_10g9:
+			/* DATA ? CLK 1 */
+			BP10G_WRITE_REG(pbpctl_dev_c, ESDP,
+					(ctrl | BP10G_MCLK_DATA_OUT9 |
+					 BP10G_MCLK_DIR_OUT9));
+			break;
+		case bp_fiber5:
+			BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL, ((ctrl_ext |
+					   BPCTLI_CTRL_EXT_MCLK_DIR5
+					   |
+					   BPCTLI_CTRL_EXT_MCLK_DATA5)
+					   &
+					   ~
+					   (BPCTLI_CTRL_EXT_MDIO_DIR5)));
+			break;
+		case bp_i80:
+			BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL,
+					   (ctrl_ext &
+					   ~(BPCTLI_CTRL_EXT_MDIO_DIR80)));
+			BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL_EXT,
+					   (ctrl | BPCTLI_CTRL_EXT_MCLK_DIR80 |
+					    BPCTLI_CTRL_EXT_MCLK_DATA80));
+			break;
+		case bp_540:
+			BP10G_WRITE_REG(pbpctl_dev, ESDP,
+					((ctrl | BP540_MCLK_DIR |
+					  BP540_MCLK_DATA) &
+					 ~(BP540_MDIO_DIR)));
+			break;
+		case bp_10gb:
+			BP10GB_WRITE_REG(pbpctl_dev, MISC_REG_SPIO,
+					 (ctrl_ext | BP10GB_MDIO_DIR |
+					  BP10GB_MCLK_SET) &
+					  ~(BP10GB_MCLK_DIR |
+					  BP10GB_MDIO_CLR |
+					  BP10GB_MDIO_SET |
+					  BP10GB_MCLK_CLR));
+			break;
+		case bp_10g:
+			BP10G_WRITE_REG(pbpctl_dev, EODSDP,
+					(ctrl_ext | BP10G_MCLK_DATA_OUT |
+					 BP10G_MDIO_DATA_OUT));
+			break;
+		default:
+			BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL_EXT, ((ctrl_ext |
+					   BPCTLI_CTRL_EXT_MCLK_DIR
+					   |
+					   BPCTLI_CTRL_EXT_MCLK_DATA)
+					   &
+					   ~
+					   (BPCTLI_CTRL_EXT_MDIO_DIR)));
+			break;
+		}
+
+		switch (pbpctl_dev->nic_type) {
+		case bp_10g9:
+			ctrl_ext = BP10G_READ_REG(pbpctl_dev, I2CCTL);
+			break;
+		case bp_fiber5:
+		case bp_i80:
+			ctrl_ext = BPCTL_READ_REG(pbpctl_dev, CTRL);
+			break;
+		case bp_540:
+			ctrl_ext = BP10G_READ_REG(pbpctl_dev, ESDP);
+			break;
+		case bp_10gb:
+			ctrl_ext = BP10GB_READ_REG(pbpctl_dev, MISC_REG_SPIO);
+			break;
+		case bp_10g:
+			ctrl_ext = BP10G_READ_REG(pbpctl_dev, EODSDP);
+			break;
+		default:
+			ctrl_ext = BPCTL_READ_REG(pbpctl_dev, CTRL_EXT);
+			break;
+		}
+		usec_delay(PULSE_TIME);
+		switch (pbpctl_dev->nic_type) {
+		case bp_10g9:
+			if (ctrl_ext & BP10G_MDIO_DATA_IN9)
+				ctrl_val |= 1 << i;
+			break;
+		case bp_fiber5:
+			if (ctrl_ext & BPCTLI_CTRL_EXT_MDIO_DATA5)
+				ctrl_val |= 1 << i;
+			break;
+		case bp_i80:
+			if (ctrl_ext & BPCTLI_CTRL_EXT_MDIO_DATA80)
+				ctrl_val |= 1 << i;
+			break;
+		case bp_540:
+			if (ctrl_ext & BP540_MDIO_DATA)
+				ctrl_val |= 1 << i;
+			break;
+		case bp_10gb:
+			if (ctrl_ext & BP10GB_MDIO_DATA)
+				ctrl_val |= 1 << i;
+			break;
+		case bp_10g:
+			if (ctrl_ext & BP10G_MDIO_DATA_IN)
+				ctrl_val |= 1 << i;
+			break;
+		default:
+			if (ctrl_ext & BPCTLI_CTRL_EXT_MDIO_DATA)
+				ctrl_val |= 1 << i;
+			break;
+		}
+	}
+
+	return ctrl_val;
+}
+
+static void write_reg(struct bpctl_dev *pbpctl_dev, unsigned char value,
+			  unsigned char addr)
+{
+	uint32_t ctrl_ext = 0, ctrl = 0;
+	struct bpctl_dev *pbpctl_dev_c = NULL;
+	unsigned long flags;
+
+	if (pbpctl_dev->nic_type == bp_10g9) {
+		pbpctl_dev_c = get_status_port(pbpctl_dev);
+		/* This should never fail... */
+		if (!pbpctl_dev_c)
+			return;
+	}
+	if ((pbpctl_dev->wdt_status == WDT_STATUS_EN) &&
+		(pbpctl_dev->bp_ext_ver < PXG4BPFI_VER))
+		wdt_time_left(pbpctl_dev);
+
+	spin_lock_irqsave(&pbpctl_dev->bypass_wr_lock, flags);
+	switch (pbpctl_dev->nic_type) {
+	case bp_10g9:
+		ctrl_ext = BP10G_READ_REG(pbpctl_dev, I2CCTL);
+		ctrl = BP10G_READ_REG(pbpctl_dev_c, ESDP);
+		/* DATA 0 CLK 0 */
+		BP10G_WRITE_REG(pbpctl_dev, I2CCTL,
+				(ctrl_ext & ~BP10G_MDIO_DATA_OUT9));
+		BP10G_WRITE_REG(pbpctl_dev_c, ESDP,
+				((ctrl | BP10G_MCLK_DIR_OUT9) &
+				 ~(BP10G_MCLK_DATA_OUT9)));
+		break;
+	case bp_fiber5:
+		ctrl_ext = BPCTL_READ_REG(pbpctl_dev, CTRL);
+		BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL, ((ctrl_ext |
+				   BPCTLI_CTRL_EXT_MCLK_DIR5
+				   |
+				   BPCTLI_CTRL_EXT_MDIO_DIR5)
+				   &
+				   ~
+				   (BPCTLI_CTRL_EXT_MDIO_DATA5
+				   |
+				   BPCTLI_CTRL_EXT_MCLK_DATA5)));
+		break;
+	case bp_i80:
+		ctrl_ext = BPCTL_READ_REG(pbpctl_dev, CTRL);
+		ctrl = BPCTL_READ_REG(pbpctl_dev, CTRL_EXT);
+		BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL, ((ctrl_ext |
+				   BPCTLI_CTRL_EXT_MDIO_DIR80)
+				   &
+				   ~BPCTLI_CTRL_EXT_MDIO_DATA80));
+		BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL_EXT,
+				   ((ctrl | BPCTLI_CTRL_EXT_MCLK_DIR80) &
+				   ~BPCTLI_CTRL_EXT_MCLK_DATA80));
+		break;
+	case bp_540:
+		ctrl = ctrl_ext = BP10G_READ_REG(pbpctl_dev, ESDP);
+		BP10G_WRITE_REG(pbpctl_dev, ESDP, ((ctrl |
+							BP540_MDIO_DIR |
+							BP540_MCLK_DIR) &
+						   ~(BP540_MDIO_DATA |
+							 BP540_MCLK_DATA)));
+		break;
+	case bp_10gb:
+		ctrl_ext = BP10GB_READ_REG(pbpctl_dev, MISC_REG_SPIO);
+		BP10GB_WRITE_REG(pbpctl_dev, MISC_REG_SPIO,
+				 (ctrl_ext | BP10GB_MDIO_CLR | BP10GB_MCLK_CLR)
+				 & ~(BP10GB_MCLK_DIR | BP10GB_MDIO_DIR |
+					 BP10GB_MDIO_SET | BP10GB_MCLK_SET));
+		break;
+	case bp_10g:
+		ctrl = BP10G_READ_REG(pbpctl_dev, ESDP);
+		ctrl_ext = BP10G_READ_REG(pbpctl_dev, EODSDP);
+		BP10G_WRITE_REG(pbpctl_dev, EODSDP,
+				(ctrl_ext &
+				 ~(BP10G_MCLK_DATA_OUT |
+				 BP10G_MDIO_DATA_OUT)));
+		break;
+	default:
+		ctrl_ext = BPCTL_READ_REG(pbpctl_dev, CTRL_EXT);
+		BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL_EXT, ((ctrl_ext |
+				   BPCTLI_CTRL_EXT_MCLK_DIR
+				   |
+				   BPCTLI_CTRL_EXT_MDIO_DIR)
+				   &
+				   ~
+				   (BPCTLI_CTRL_EXT_MDIO_DATA
+				   |
+				   BPCTLI_CTRL_EXT_MCLK_DATA)));
+		break;
+	}
+	usec_delay(CMND_INTERVAL);
+	/*send sync cmd */
+	write_pulse(pbpctl_dev, ctrl_ext, SYNC_CMD_VAL, SYNC_CMD_LEN);
+	/*send wr cmd */
+	write_pulse(pbpctl_dev, ctrl_ext, WR_CMD_VAL, WR_CMD_LEN);
+	write_pulse(pbpctl_dev, ctrl_ext, addr, ADDR_CMD_LEN);
+	/*write data */
+	write_pulse(pbpctl_dev, ctrl_ext, value, WR_DATA_LEN);
+	switch (pbpctl_dev->nic_type) {
+	case bp_10g9:
+		/* DATA 0 CLK 0 */
+		BP10G_WRITE_REG(pbpctl_dev, I2CCTL,
+				(ctrl_ext & ~BP10G_MDIO_DATA_OUT9));
+		BP10G_WRITE_REG(pbpctl_dev_c, ESDP,
+				((ctrl | BP10G_MCLK_DIR_OUT9) &
+				 ~(BP10G_MCLK_DATA_OUT9)));
+		break;
+	case bp_fiber5:
+		BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL, ((ctrl_ext |
+				   BPCTLI_CTRL_EXT_MCLK_DIR5
+				   |
+				   BPCTLI_CTRL_EXT_MDIO_DIR5)
+				   &
+				   ~
+				   (BPCTLI_CTRL_EXT_MDIO_DATA5
+				   |
+				   BPCTLI_CTRL_EXT_MCLK_DATA5)));
+		break;
+	case bp_i80:
+		BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL, ((ctrl_ext |
+				   BPCTLI_CTRL_EXT_MDIO_DIR80)
+				   &
+				   ~BPCTLI_CTRL_EXT_MDIO_DATA80));
+		BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL_EXT,
+				   ((ctrl | BPCTLI_CTRL_EXT_MCLK_DIR80) &
+					~BPCTLI_CTRL_EXT_MCLK_DATA80));
+		break;
+	case bp_540:
+		BP10G_WRITE_REG(pbpctl_dev, ESDP, ((ctrl |
+							BP540_MDIO_DIR |
+							BP540_MCLK_DIR) &
+							~(BP540_MDIO_DATA |
+							BP540_MCLK_DATA)));
+		break;
+	case bp_10gb:
+		BP10GB_WRITE_REG(pbpctl_dev, MISC_REG_SPIO,
+				 (ctrl_ext | BP10GB_MDIO_CLR | BP10GB_MCLK_CLR)
+				 & ~(BP10GB_MCLK_DIR | BP10GB_MDIO_DIR |
+					 BP10GB_MDIO_SET | BP10GB_MCLK_SET));
+		break;
+	case bp_10g:
+		BP10G_WRITE_REG(pbpctl_dev, EODSDP,
+				(ctrl_ext &
+				 ~(BP10G_MCLK_DATA_OUT |
+				 BP10G_MDIO_DATA_OUT)));
+		break;
+	default:
+		BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL_EXT, ((ctrl_ext |
+				   BPCTLI_CTRL_EXT_MCLK_DIR
+				   |
+				   BPCTLI_CTRL_EXT_MDIO_DIR)
+				   &
+				   ~
+				   (BPCTLI_CTRL_EXT_MDIO_DATA
+				   |
+				   BPCTLI_CTRL_EXT_MCLK_DATA)));
+		break;
+	}
+
+	usec_delay(CMND_INTERVAL);
+
+	if ((pbpctl_dev->wdt_status == WDT_STATUS_EN) &&
+		(pbpctl_dev->bp_ext_ver < PXG4BPFI_VER) &&
+		(addr == CMND_REG_ADDR))
+		pbpctl_dev->bypass_wdt_on_time = jiffies;
+	spin_unlock_irqrestore(&pbpctl_dev->bypass_wr_lock, flags);
+}
+
+static void write_data(struct bpctl_dev *pbpctl_dev, unsigned char value)
+{
+	write_reg(pbpctl_dev, value, CMND_REG_ADDR);
+}
+
+static int read_reg(struct bpctl_dev *pbpctl_dev, unsigned char addr)
+{
+	uint32_t ctrl_ext = 0, ctrl = 0, ctrl_value = 0;
+	struct bpctl_dev *pbpctl_dev_c = NULL;
+
+	unsigned long flags;
+
+	spin_lock_irqsave(&pbpctl_dev->bypass_wr_lock, flags);
+	if (pbpctl_dev->nic_type == bp_10g9) {
+		pbpctl_dev_c = get_status_port(pbpctl_dev);
+		if (!pbpctl_dev_c) {
+			spin_unlock_irqrestore(&pbpctl_dev->bypass_wr_lock,
+						flags);
+			return BP_NOT_CAP;
+		}
+	}
+	switch (pbpctl_dev->nic_type) {
+	case bp_10g9:
+		ctrl_ext = BP10G_READ_REG(pbpctl_dev, I2CCTL);
+		ctrl = BP10G_READ_REG(pbpctl_dev_c, ESDP);
+
+		/* DATA 0 CLK 0 */
+		BP10G_WRITE_REG(pbpctl_dev, I2CCTL,
+				(ctrl_ext & ~BP10G_MDIO_DATA_OUT9));
+		BP10G_WRITE_REG(pbpctl_dev_c, ESDP,
+				((ctrl | BP10G_MCLK_DIR_OUT9) &
+				 ~(BP10G_MCLK_DATA_OUT9)));
+		break;
+	case bp_fiber5:
+		ctrl_ext = BPCTL_READ_REG(pbpctl_dev, CTRL);
+
+		BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL, ((ctrl_ext |
+				   BPCTLI_CTRL_EXT_MCLK_DIR5
+				   |
+				   BPCTLI_CTRL_EXT_MDIO_DIR5)
+				   &
+				   ~
+				   (BPCTLI_CTRL_EXT_MDIO_DATA5
+				   |
+				   BPCTLI_CTRL_EXT_MCLK_DATA5)));
+		break;
+	case bp_i80:
+		ctrl_ext = BPCTL_READ_REG(pbpctl_dev, CTRL);
+		ctrl = BPCTL_READ_REG(pbpctl_dev, CTRL_EXT);
+
+		BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL, ((ctrl_ext |
+				   BPCTLI_CTRL_EXT_MDIO_DIR80)
+				   &
+				   ~BPCTLI_CTRL_EXT_MDIO_DATA80));
+		BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL_EXT,
+				   ((ctrl | BPCTLI_CTRL_EXT_MCLK_DIR80) &
+					~BPCTLI_CTRL_EXT_MCLK_DATA80));
+		break;
+	case bp_540:
+		ctrl_ext = BP10G_READ_REG(pbpctl_dev, ESDP);
+		ctrl = BP10G_READ_REG(pbpctl_dev, ESDP);
+
+		BP10G_WRITE_REG(pbpctl_dev, ESDP, ((ctrl | BP540_MCLK_DIR |
+							BP540_MDIO_DIR) &
+						   ~(BP540_MDIO_DATA |
+							 BP540_MCLK_DATA)));
+		break;
+	case bp_10gb:
+		ctrl_ext = BP10GB_READ_REG(pbpctl_dev, MISC_REG_SPIO);
+		BP10GB_WRITE_REG(pbpctl_dev, MISC_REG_SPIO,
+				 (ctrl_ext | BP10GB_MDIO_CLR | BP10GB_MCLK_CLR)
+				 & ~(BP10GB_MCLK_DIR | BP10GB_MDIO_DIR |
+					 BP10GB_MDIO_SET | BP10GB_MCLK_SET));
+		break;
+	case bp_10g:
+		ctrl = BP10G_READ_REG(pbpctl_dev, ESDP);
+		ctrl_ext = BP10G_READ_REG(pbpctl_dev, EODSDP);
+		BP10G_WRITE_REG(pbpctl_dev, EODSDP,
+				(ctrl_ext &
+				 ~(BP10G_MCLK_DATA_OUT |
+				 BP10G_MDIO_DATA_OUT)));
+		break;
+	default:
+		ctrl_ext = BPCTL_READ_REG(pbpctl_dev, CTRL_EXT);
+		BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL_EXT, ((ctrl_ext |
+				   BPCTLI_CTRL_EXT_MCLK_DIR
+				   |
+				   BPCTLI_CTRL_EXT_MDIO_DIR)
+				   &
+				   ~
+				   (BPCTLI_CTRL_EXT_MDIO_DATA
+				   |
+				   BPCTLI_CTRL_EXT_MCLK_DATA)));
+		break;
+	}
+
+	usec_delay(CMND_INTERVAL);
+
+	/*send sync cmd */
+	write_pulse(pbpctl_dev, ctrl_ext, SYNC_CMD_VAL, SYNC_CMD_LEN);
+	/*send rd cmd */
+	write_pulse(pbpctl_dev, ctrl_ext, RD_CMD_VAL, RD_CMD_LEN);
+	/*send addr */
+	write_pulse(pbpctl_dev, ctrl_ext, addr, ADDR_CMD_LEN);
+	/*read data */
+	/* zero */
+	switch (pbpctl_dev->nic_type) {
+	case bp_10g9:
+		/* DATA 0 CLK 1 */
+		BP10G_WRITE_REG(pbpctl_dev, I2CCTL,
+				(ctrl_ext | BP10G_MDIO_DATA_OUT9));
+		BP10G_WRITE_REG(pbpctl_dev_c, ESDP,
+				(ctrl | BP10G_MCLK_DATA_OUT9 |
+				 BP10G_MCLK_DIR_OUT9));
+		break;
+	case bp_fiber5:
+		BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL, ((ctrl_ext |
+				   BPCTLI_CTRL_EXT_MCLK_DIR5
+				   |
+				   BPCTLI_CTRL_EXT_MCLK_DATA5)
+				   &
+				   ~
+				   (BPCTLI_CTRL_EXT_MDIO_DIR5
+				   |
+				   BPCTLI_CTRL_EXT_MDIO_DATA5)));
+		break;
+	case bp_i80:
+		BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL,
+				   (ctrl_ext &
+					~(BPCTLI_CTRL_EXT_MDIO_DATA80 |
+					  BPCTLI_CTRL_EXT_MDIO_DIR80)));
+		BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL_EXT,
+				   (ctrl | BPCTLI_CTRL_EXT_MCLK_DIR80 |
+					BPCTLI_CTRL_EXT_MCLK_DATA80));
+		break;
+	case bp_540:
+		BP10G_WRITE_REG(pbpctl_dev, ESDP,
+				(((ctrl | BP540_MDIO_DIR | BP540_MCLK_DIR |
+				   BP540_MCLK_DATA) & ~BP540_MDIO_DATA)));
+		break;
+	case bp_10gb:
+		BP10GB_WRITE_REG(pbpctl_dev, MISC_REG_SPIO,
+				 (ctrl_ext | BP10GB_MDIO_DIR | BP10GB_MCLK_SET)
+				 & ~(BP10GB_MCLK_DIR | BP10GB_MDIO_SET |
+					 BP10GB_MDIO_CLR | BP10GB_MCLK_CLR));
+		break;
+	case bp_10g:
+		BP10G_WRITE_REG(pbpctl_dev, EODSDP,
+				(ctrl_ext | BP10G_MCLK_DATA_OUT |
+				 BP10G_MDIO_DATA_OUT));
+		break;
+	default:
+		BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL_EXT, ((ctrl_ext |
+				   BPCTLI_CTRL_EXT_MCLK_DIR
+				    |
+				    BPCTLI_CTRL_EXT_MCLK_DATA)
+				   &
+				   ~
+				   (BPCTLI_CTRL_EXT_MDIO_DIR
+				    |
+				    BPCTLI_CTRL_EXT_MDIO_DATA)));
+		break;
+	}
+
+	usec_delay(PULSE_TIME);
+
+	ctrl_value = read_pulse(pbpctl_dev, ctrl_ext, RD_DATA_LEN);
+	switch (pbpctl_dev->nic_type) {
+	case bp_10g9:
+		ctrl_ext = BP10G_READ_REG(pbpctl_dev, I2CCTL);
+		ctrl = BP10G_READ_REG(pbpctl_dev_c, ESDP);
+		/* DATA 0 CLK 0 */
+		BP10G_WRITE_REG(pbpctl_dev, I2CCTL,
+				(ctrl_ext & ~BP10G_MDIO_DATA_OUT9));
+		BP10G_WRITE_REG(pbpctl_dev_c, ESDP,
+				((ctrl | BP10G_MCLK_DIR_OUT9) &
+				 ~(BP10G_MCLK_DATA_OUT9)));
+		break;
+	case bp_fiber5:
+		BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL, ((ctrl_ext |
+				    BPCTLI_CTRL_EXT_MCLK_DIR5
+				    |
+				    BPCTLI_CTRL_EXT_MDIO_DIR5)
+				   &
+				   ~
+				   (BPCTLI_CTRL_EXT_MDIO_DATA5
+				    |
+				    BPCTLI_CTRL_EXT_MCLK_DATA5)));
+		break;
+	case bp_i80:
+		BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL, ((ctrl_ext |
+				    BPCTLI_CTRL_EXT_MDIO_DIR80)
+				   &
+				   ~BPCTLI_CTRL_EXT_MDIO_DATA80));
+		BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL_EXT,
+				   ((ctrl | BPCTLI_CTRL_EXT_MCLK_DIR80) &
+					~BPCTLI_CTRL_EXT_MCLK_DATA80));
+		break;
+	case bp_540:
+		ctrl = BP10G_READ_REG(pbpctl_dev, ESDP);
+		BP10G_WRITE_REG(pbpctl_dev, ESDP, ((ctrl | BP540_MCLK_DIR |
+							BP540_MDIO_DIR) &
+						   ~(BP540_MDIO_DATA |
+							 BP540_MCLK_DATA)));
+		break;
+	case bp_10gb:
+		ctrl_ext = BP10GB_READ_REG(pbpctl_dev, MISC_REG_SPIO);
+		BP10GB_WRITE_REG(pbpctl_dev, MISC_REG_SPIO,
+				 (ctrl_ext | BP10GB_MDIO_CLR | BP10GB_MCLK_CLR)
+				 & ~(BP10GB_MCLK_DIR | BP10GB_MDIO_DIR |
+					 BP10GB_MDIO_SET | BP10GB_MCLK_SET));
+		break;
+	case bp_10g:
+		ctrl = BP10G_READ_REG(pbpctl_dev, ESDP);
+		ctrl_ext = BP10G_READ_REG(pbpctl_dev, EODSDP);
+		BP10G_WRITE_REG(pbpctl_dev, EODSDP,
+				(ctrl_ext &
+				 ~(BP10G_MCLK_DATA_OUT |
+				 BP10G_MDIO_DATA_OUT)));
+		break;
+	default:
+		BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL_EXT, ((ctrl_ext |
+				    BPCTLI_CTRL_EXT_MCLK_DIR
+				    |
+				    BPCTLI_CTRL_EXT_MDIO_DIR)
+				   &
+				   ~
+				   (BPCTLI_CTRL_EXT_MDIO_DATA
+				    |
+				    BPCTLI_CTRL_EXT_MCLK_DATA)));
+		break;
+	}
+
+	usec_delay(CMND_INTERVAL);
+	spin_unlock_irqrestore(&pbpctl_dev->bypass_wr_lock, flags);
+
+	return ctrl_value;
+}
+
+static int wdt_pulse(struct bpctl_dev *pbpctl_dev)
+{
+	uint32_t ctrl_ext = 0, ctrl = 0;
+	struct bpctl_dev *pbpctl_dev_c = NULL;
+	unsigned long flags;
+
+	spin_lock_irqsave(&pbpctl_dev->bypass_wr_lock, flags);
+
+	if (pbpctl_dev->nic_type == bp_10g9) {
+		pbpctl_dev_c = get_status_port(pbpctl_dev);
+		if (!pbpctl_dev_c) {
+			spin_unlock_irqrestore(&pbpctl_dev->bypass_wr_lock,
+						flags);
+			return BP_NOT_CAP;
+		}
+	}
+
+	switch (pbpctl_dev->nic_type) {
+	case bp_10g9:
+		ctrl_ext = BP10G_READ_REG(pbpctl_dev, I2CCTL);
+		ctrl = BP10G_READ_REG(pbpctl_dev_c, ESDP);
+
+		/* DATA 0 CLK 0 */
+		BP10G_WRITE_REG(pbpctl_dev, I2CCTL,
+				(ctrl_ext & ~BP10G_MDIO_DATA_OUT9));
+		BP10G_WRITE_REG(pbpctl_dev_c, ESDP,
+				((ctrl | BP10G_MCLK_DIR_OUT9) &
+				 ~(BP10G_MCLK_DATA_OUT9)));
+		break;
+	case bp_fiber5:
+		ctrl_ext = BPCTL_READ_REG(pbpctl_dev, CTRL);
+		BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL, ((ctrl_ext |
+				    BPCTLI_CTRL_EXT_MCLK_DIR5
+				    |
+				    BPCTLI_CTRL_EXT_MDIO_DIR5)
+				   &
+				   ~
+				   (BPCTLI_CTRL_EXT_MDIO_DATA5
+				    |
+				    BPCTLI_CTRL_EXT_MCLK_DATA5)));
+		break;
+	case bp_i80:
+		ctrl_ext = BPCTL_READ_REG(pbpctl_dev, CTRL);
+		ctrl = BPCTL_READ_REG(pbpctl_dev, CTRL_EXT);
+		BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL, ((ctrl_ext |
+				    BPCTLI_CTRL_EXT_MDIO_DIR80)
+				   &
+				   ~BPCTLI_CTRL_EXT_MDIO_DATA80));
+		BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL_EXT,
+				   ((ctrl | BPCTLI_CTRL_EXT_MCLK_DIR80) &
+					~BPCTLI_CTRL_EXT_MCLK_DATA80));
+		break;
+	case bp_540:
+		ctrl_ext = ctrl = BP10G_READ_REG(pbpctl_dev, ESDP);
+		BP10G_WRITE_REG(pbpctl_dev, ESDP, ((ctrl | BP540_MCLK_DIR |
+							BP540_MDIO_DIR) &
+						   ~(BP540_MDIO_DATA |
+							 BP540_MCLK_DATA)));
+		break;
+	case bp_10gb:
+		ctrl_ext = BP10GB_READ_REG(pbpctl_dev, MISC_REG_SPIO);
+		BP10GB_WRITE_REG(pbpctl_dev, MISC_REG_SPIO,
+				 (ctrl_ext | BP10GB_MDIO_CLR | BP10GB_MCLK_CLR)
+				 & ~(BP10GB_MCLK_DIR | BP10GB_MDIO_DIR |
+					 BP10GB_MDIO_SET | BP10GB_MCLK_SET));
+		break;
+	case bp_10g:
+		ctrl = BP10G_READ_REG(pbpctl_dev, ESDP);
+		ctrl_ext = BP10G_READ_REG(pbpctl_dev, EODSDP);
+		BP10G_WRITE_REG(pbpctl_dev, EODSDP,
+				(ctrl_ext &
+				 ~(BP10G_MCLK_DATA_OUT | BP10G_MDIO_DATA_OUT)));
+		break;
+	default:
+		ctrl_ext = BPCTL_READ_REG(pbpctl_dev, CTRL_EXT);
+		BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL_EXT, ((ctrl_ext |
+				    BPCTLI_CTRL_EXT_MCLK_DIR
+				    |
+				    BPCTLI_CTRL_EXT_MDIO_DIR)
+				   &
+				   ~
+				   (BPCTLI_CTRL_EXT_MDIO_DATA
+				    |
+				    BPCTLI_CTRL_EXT_MCLK_DATA)));
+		break;
+	}
+
+	switch (pbpctl_dev->nic_type) {
+	case bp_10g9:
+		/* DATA 0 CLK 1 */
+		BP10G_WRITE_REG(pbpctl_dev, I2CCTL,
+				(ctrl_ext & ~BP10G_MDIO_DATA_OUT9));
+		BP10G_WRITE_REG(pbpctl_dev_c, ESDP,
+				(ctrl | BP10G_MCLK_DATA_OUT9 |
+				 BP10G_MCLK_DIR_OUT9));
+		break;
+	case bp_fiber5:
+		BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL, ((ctrl_ext |
+				    BPCTLI_CTRL_EXT_MCLK_DIR5
+				    |
+				    BPCTLI_CTRL_EXT_MDIO_DIR5
+				    |
+				    BPCTLI_CTRL_EXT_MCLK_DATA5)
+				   &
+				   ~
+				   (BPCTLI_CTRL_EXT_MDIO_DATA5)));
+		break;
+	case bp_i80:
+		BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL, ((ctrl_ext |
+				    BPCTLI_CTRL_EXT_MDIO_DIR80)
+				   &
+				   ~BPCTLI_CTRL_EXT_MDIO_DATA80));
+		BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL_EXT,
+				   (ctrl | BPCTLI_CTRL_EXT_MCLK_DIR80 |
+					BPCTLI_CTRL_EXT_MCLK_DATA80));
+		break;
+	case bp_540:
+		BP10G_WRITE_REG(pbpctl_dev, ESDP, ((ctrl |
+							BP540_MDIO_DIR |
+							BP540_MCLK_DIR |
+							BP540_MCLK_DATA) &
+						   ~BP540_MDIO_DATA));
+		break;
+	case bp_10gb:
+		ctrl_ext = BP10GB_READ_REG(pbpctl_dev, MISC_REG_SPIO);
+
+		BP10GB_WRITE_REG(pbpctl_dev, MISC_REG_SPIO,
+				 (ctrl_ext | BP10GB_MDIO_CLR | BP10GB_MCLK_SET)
+				 & ~(BP10GB_MCLK_DIR | BP10GB_MDIO_DIR |
+					 BP10GB_MDIO_SET | BP10GB_MCLK_CLR));
+		break;
+	case bp_10g:
+		BP10G_WRITE_REG(pbpctl_dev, EODSDP,
+				((ctrl_ext | BP10G_MCLK_DATA_OUT) &
+				 ~BP10G_MDIO_DATA_OUT));
+		break;
+	default:
+		BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL_EXT, ((ctrl_ext |
+				    BPCTLI_CTRL_EXT_MCLK_DIR
+				    |
+				    BPCTLI_CTRL_EXT_MDIO_DIR
+				    |
+				    BPCTLI_CTRL_EXT_MCLK_DATA)
+				   &
+				   ~
+				   (BPCTLI_CTRL_EXT_MDIO_DATA)));
+		break;
+	}
+
+	usec_delay(WDT_INTERVAL);
+
+	switch (pbpctl_dev->nic_type) {
+	case bp_10g9:
+		/* DATA 0 CLK 0 */
+		BP10G_WRITE_REG(pbpctl_dev, I2CCTL,
+				(ctrl_ext & ~BP10G_MDIO_DATA_OUT9));
+		BP10G_WRITE_REG(pbpctl_dev_c, ESDP,
+				((ctrl | BP10G_MCLK_DIR_OUT9) &
+				 ~(BP10G_MCLK_DATA_OUT9)));
+		break;
+	case bp_fiber5:
+		BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL, ((ctrl_ext |
+				    BPCTLI_CTRL_EXT_MCLK_DIR5
+				    |
+				    BPCTLI_CTRL_EXT_MDIO_DIR5)
+				   &
+				   ~
+				   (BPCTLI_CTRL_EXT_MCLK_DATA5
+				    |
+				    BPCTLI_CTRL_EXT_MDIO_DATA5)));
+		break;
+	case bp_i80:
+		BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL, ((ctrl_ext |
+				    BPCTLI_CTRL_EXT_MDIO_DIR80)
+				   &
+				   ~BPCTLI_CTRL_EXT_MDIO_DATA80));
+		BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL_EXT,
+				   ((ctrl | BPCTLI_CTRL_EXT_MCLK_DIR80) &
+					~BPCTLI_CTRL_EXT_MCLK_DATA80));
+		break;
+	case bp_540:
+		BP10G_WRITE_REG(pbpctl_dev, ESDP, ((ctrl | BP540_MCLK_DIR |
+							BP540_MDIO_DIR) &
+						   ~(BP540_MDIO_DATA |
+							 BP540_MCLK_DATA)));
+		break;
+	case bp_10gb:
+		ctrl_ext = BP10GB_READ_REG(pbpctl_dev, MISC_REG_SPIO);
+		BP10GB_WRITE_REG(pbpctl_dev, MISC_REG_SPIO,
+				 (ctrl_ext | BP10GB_MDIO_CLR | BP10GB_MCLK_CLR)
+				 & ~(BP10GB_MCLK_DIR | BP10GB_MDIO_DIR |
+					 BP10GB_MDIO_SET | BP10GB_MCLK_SET));
+		break;
+	case bp_10g:
+		BP10G_WRITE_REG(pbpctl_dev, EODSDP,
+				(ctrl_ext &
+				 ~(BP10G_MCLK_DATA_OUT |
+				 BP10G_MDIO_DATA_OUT)));
+		break;
+	default:
+		BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL_EXT, ((ctrl_ext |
+				    BPCTLI_CTRL_EXT_MCLK_DIR
+				    |
+				    BPCTLI_CTRL_EXT_MDIO_DIR)
+				   &
+				   ~
+				   (BPCTLI_CTRL_EXT_MCLK_DATA
+				    |
+				    BPCTLI_CTRL_EXT_MDIO_DATA)));
+	}
+	if (pbpctl_dev->wdt_status == WDT_STATUS_EN)
+		pbpctl_dev->bypass_wdt_on_time = jiffies;
+	spin_unlock_irqrestore(&pbpctl_dev->bypass_wr_lock, flags);
+	return 0;
+}
+
+static void data_pulse(struct bpctl_dev *pbpctl_dev, unsigned char value)
+{
+	uint32_t ctrl_ext = 0;
+	unsigned long flags;
+
+	wdt_time_left(pbpctl_dev);
+	spin_lock_irqsave(&pbpctl_dev->bypass_wr_lock, flags);
+
+	ctrl_ext = BPCTL_READ_REG(pbpctl_dev, CTRL_EXT);
+	BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL_EXT, ((ctrl_ext |
+			    BPCTLI_CTRL_EXT_SDP6_DIR |
+			    BPCTLI_CTRL_EXT_SDP7_DIR) &
+			   ~(BPCTLI_CTRL_EXT_SDP6_DATA |
+			    BPCTLI_CTRL_EXT_SDP7_DATA)));
+
+	usec_delay(INIT_CMND_INTERVAL);
+	BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL_EXT, ((ctrl_ext |
+						   BPCTLI_CTRL_EXT_SDP6_DIR |
+						   BPCTLI_CTRL_EXT_SDP7_DIR |
+						   BPCTLI_CTRL_EXT_SDP6_DATA) &
+						  ~
+						  (BPCTLI_CTRL_EXT_SDP7_DATA)));
+	usec_delay(INIT_CMND_INTERVAL);
+
+	while (value) {
+		BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL_EXT, ctrl_ext |
+				   BPCTLI_CTRL_EXT_SDP6_DIR |
+				   BPCTLI_CTRL_EXT_SDP7_DIR |
+				   BPCTLI_CTRL_EXT_SDP6_DATA |
+				   BPCTLI_CTRL_EXT_SDP7_DATA);
+		usec_delay(PULSE_INTERVAL);
+		BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL_EXT, ((ctrl_ext |
+				    BPCTLI_CTRL_EXT_SDP6_DIR
+				    |
+				    BPCTLI_CTRL_EXT_SDP7_DIR
+				    |
+				    BPCTLI_CTRL_EXT_SDP6_DATA)
+				   &
+				   ~BPCTLI_CTRL_EXT_SDP7_DATA));
+		usec_delay(PULSE_INTERVAL);
+		value--;
+	}
+	usec_delay(INIT_CMND_INTERVAL - PULSE_INTERVAL);
+	BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL_EXT, ((ctrl_ext |
+			    BPCTLI_CTRL_EXT_SDP6_DIR |
+			    BPCTLI_CTRL_EXT_SDP7_DIR) &
+			   ~(BPCTLI_CTRL_EXT_SDP6_DATA |
+			   BPCTLI_CTRL_EXT_SDP7_DATA)));
+	usec_delay(WDT_TIME_CNT);
+	if (pbpctl_dev->wdt_status == WDT_STATUS_EN)
+		pbpctl_dev->bypass_wdt_on_time = jiffies;
+	spin_unlock_irqrestore(&pbpctl_dev->bypass_wr_lock, flags);
+}
+
+static int send_wdt_pulse(struct bpctl_dev *pbpctl_dev)
+{
+	uint32_t ctrl_ext = 0;
+	unsigned long flags;
+
+	spin_lock_irqsave(&pbpctl_dev->bypass_wr_lock, flags);
+
+	wdt_time_left(pbpctl_dev);
+	ctrl_ext = BPCTL_READ_REG(pbpctl_dev, CTRL_EXT);
+
+	BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL_EXT, ctrl_ext |     /* 1 */
+			   BPCTLI_CTRL_EXT_SDP7_DIR |
+			   BPCTLI_CTRL_EXT_SDP7_DATA);
+	usec_delay(PULSE_INTERVAL);
+	BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL_EXT, ((ctrl_ext |   /* 0 */
+						   BPCTLI_CTRL_EXT_SDP7_DIR) &
+						  ~BPCTLI_CTRL_EXT_SDP7_DATA));
+
+	usec_delay(PULSE_INTERVAL);
+	if (pbpctl_dev->wdt_status == WDT_STATUS_EN)
+		pbpctl_dev->bypass_wdt_on_time = jiffies;
+	spin_unlock_irqrestore(&pbpctl_dev->bypass_wr_lock, flags);
+
+	return 0;
+}
+
+static void send_bypass_clear_pulse(struct bpctl_dev *pbpctl_dev,
+					unsigned int value)
+{
+	uint32_t ctrl_ext = 0;
+
+	ctrl_ext = BPCTL_READ_REG(pbpctl_dev, CTRL_EXT);
+	BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL_EXT, ((ctrl_ext |   /* 0 */
+						   BPCTLI_CTRL_EXT_SDP6_DIR) &
+						  ~BPCTLI_CTRL_EXT_SDP6_DATA));
+	usec_delay(PULSE_INTERVAL);
+	while (value) {
+		BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL_EXT, ctrl_ext |     /* 1 */
+				   BPCTLI_CTRL_EXT_SDP6_DIR |
+				   BPCTLI_CTRL_EXT_SDP6_DATA);
+		usec_delay(PULSE_INTERVAL);
+		value--;
+	}
+	BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL_EXT, ((ctrl_ext |   /* 0 */
+						   BPCTLI_CTRL_EXT_SDP6_DIR) &
+						  ~BPCTLI_CTRL_EXT_SDP6_DATA));
+	usec_delay(PULSE_INTERVAL);
+}
+
+/* end OLD_FW */
+
+/**************************************/
+/**************INTEL API***************/
+/**************************************/
+
+static void write_data_port_int(struct bpctl_dev *pbpctl_dev,
+				unsigned char ctrl_value)
+{
+	uint32_t value;
+
+	value = BPCTL_READ_REG(pbpctl_dev, CTRL);
+/* Make SDP0 Pin Directonality to Output */
+	value |= BPCTLI_CTRL_SDP0_DIR;
+	BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL, value);
+
+	value &= ~BPCTLI_CTRL_SDP0_DATA;
+	value |= ((ctrl_value & 0x1) << BPCTLI_CTRL_SDP0_SHIFT);
+	BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL, value);
+
+	value = (BPCTL_READ_REG(pbpctl_dev, CTRL_EXT));
+/* Make SDP2 Pin Directonality to Output */
+	value |= BPCTLI_CTRL_EXT_SDP6_DIR;
+	BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL_EXT, value);
+
+	value &= ~BPCTLI_CTRL_EXT_SDP6_DATA;
+	value |= (((ctrl_value & 0x2) >> 1) << BPCTLI_CTRL_EXT_SDP6_SHIFT);
+	BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL_EXT, value);
+}
+
+static int write_data_int(struct bpctl_dev *pbpctl_dev, unsigned char value)
+{
+	struct bpctl_dev *pbpctl_dev_b = NULL;
+
+	pbpctl_dev_b = get_status_port(pbpctl_dev);
+	if (!pbpctl_dev_b)
+		return BP_NOT_CAP;
+	atomic_set(&pbpctl_dev->wdt_busy, 1);
+	write_data_port_int(pbpctl_dev, value & 0x3);
+	write_data_port_int(pbpctl_dev_b, ((value & 0xc) >> 2));
+	atomic_set(&pbpctl_dev->wdt_busy, 0);
+
+	return 0;
+}
+
+static int wdt_pulse_int(struct bpctl_dev *pbpctl_dev)
+{
+
+	if ((atomic_read(&pbpctl_dev->wdt_busy)) == 1)
+		return BP_NOT_CAP;
+
+	if ((write_data_int(pbpctl_dev, RESET_WDT_INT)) < 0)
+		return BP_NOT_CAP;
+	msec_delay_bp(CMND_INTERVAL_INT);
+	if ((write_data_int(pbpctl_dev, CMND_OFF_INT)) < 0)
+		return BP_NOT_CAP;
+	msec_delay_bp(CMND_INTERVAL_INT);
+
+	if (pbpctl_dev->wdt_status == WDT_STATUS_EN)
+		pbpctl_dev->bypass_wdt_on_time = jiffies;
+
+	return 0;
+}
+
+/*************************************/
+/************* COMMANDS **************/
+/*************************************/
+
+/* CMND_ON  0x4 (100)*/
+static int cmnd_on(struct bpctl_dev *pbpctl_dev)
+{
+	if (!(pbpctl_dev->bp_caps & SW_CTL_CAP))
+		return BP_NOT_CAP;
+
+	if (INTEL_IF_SERIES(pbpctl_dev->subdevice))
+		return 0;
+	if (pbpctl_dev->bp_ext_ver >= PXG2BPI_VER)
+		write_data(pbpctl_dev, CMND_ON);
+	else
+		data_pulse(pbpctl_dev, CMND_ON);
+
+	return 0;
+}
+
+/* CMND_OFF  0x2 (10)*/
+static int cmnd_off(struct bpctl_dev *pbpctl_dev)
+{
+	int ret = BP_NOT_CAP;
+
+	if (pbpctl_dev->bp_caps & SW_CTL_CAP) {
+		if (INTEL_IF_SERIES(pbpctl_dev->subdevice)) {
+			write_data_int(pbpctl_dev, CMND_OFF_INT);
+			msec_delay_bp(CMND_INTERVAL_INT);
+		} else if (pbpctl_dev->bp_ext_ver >= PXG2BPI_VER)
+			write_data(pbpctl_dev, CMND_OFF);
+		else
+			data_pulse(pbpctl_dev, CMND_OFF);
+		ret = 0;
+	}
+	return ret;
+}
+
+/* BYPASS_ON (0xa)*/
+static int bypass_on(struct bpctl_dev *pbpctl_dev)
+{
+	int ret = BP_NOT_CAP;
+
+	if (pbpctl_dev->bp_caps & BP_CAP) {
+		if (INTEL_IF_SERIES(pbpctl_dev->subdevice)) {
+			write_data_int(pbpctl_dev, BYPASS_ON_INT);
+			msec_delay_bp(BYPASS_DELAY_INT);
+			pbpctl_dev->bp_status_un = 0;
+		} else if (pbpctl_dev->bp_ext_ver >= PXG2BPI_VER) {
+			write_data(pbpctl_dev, BYPASS_ON);
+			if (pbpctl_dev->bp_ext_ver >= PXG2TBPI_VER)
+				msec_delay_bp(LATCH_DELAY);
+		} else
+			data_pulse(pbpctl_dev, BYPASS_ON);
+		ret = 0;
+	}
+	return ret;
+}
+
+/* BYPASS_OFF (0x8 111)*/
+static int bypass_off(struct bpctl_dev *pbpctl_dev)
+{
+	int ret = BP_NOT_CAP;
+
+	if (pbpctl_dev->bp_caps & BP_CAP) {
+		if (INTEL_IF_SERIES(pbpctl_dev->subdevice)) {
+			write_data_int(pbpctl_dev, DIS_BYPASS_CAP_INT);
+			msec_delay_bp(BYPASS_DELAY_INT);
+			write_data_int(pbpctl_dev, PWROFF_BYPASS_ON_INT);
+			msec_delay_bp(BYPASS_DELAY_INT);
+			pbpctl_dev->bp_status_un = 0;
+		} else if (pbpctl_dev->bp_ext_ver >= PXG2BPI_VER) {
+			write_data(pbpctl_dev, BYPASS_OFF);
+			if (pbpctl_dev->bp_ext_ver >= PXG2TBPI_VER)
+				msec_delay_bp(LATCH_DELAY);
+		} else
+			data_pulse(pbpctl_dev, BYPASS_OFF);
+		ret = 0;
+	}
+	return ret;
+}
+
+/* TAP_OFF (0x9)*/
+static int tap_off(struct bpctl_dev *pbpctl_dev)
+{
+	int ret = BP_NOT_CAP;
+
+	if ((pbpctl_dev->bp_caps & TAP_CAP)
+		&& (pbpctl_dev->bp_ext_ver >= PXG2TBPI_VER)) {
+		write_data(pbpctl_dev, TAP_OFF);
+		msec_delay_bp(LATCH_DELAY);
+		ret = 0;
+	}
+	return ret;
+}
+
+/* TAP_ON (0xb)*/
+static int tap_on(struct bpctl_dev *pbpctl_dev)
+{
+	int ret = BP_NOT_CAP;
+
+	if ((pbpctl_dev->bp_caps & TAP_CAP)
+		&& (pbpctl_dev->bp_ext_ver >= PXG2TBPI_VER)) {
+		write_data(pbpctl_dev, TAP_ON);
+		msec_delay_bp(LATCH_DELAY);
+		ret = 0;
+	}
+	return ret;
+}
+
+/* DISC_OFF (0x9)*/
+static int disc_off(struct bpctl_dev *pbpctl_dev)
+{
+	int ret = 0;
+
+	if ((pbpctl_dev->bp_caps & DISC_CAP) &&
+	    (pbpctl_dev->bp_ext_ver >= 0x8)) {
+		write_data(pbpctl_dev, DISC_OFF);
+		msec_delay_bp(LATCH_DELAY);
+	} else
+		ret = BP_NOT_CAP;
+	return ret;
+}
+
+/* DISC_ON (0xb)*/
+static int disc_on(struct bpctl_dev *pbpctl_dev)
+{
+	int ret = 0;
+
+	if ((pbpctl_dev->bp_caps & DISC_CAP) &&
+	    (pbpctl_dev->bp_ext_ver >= 0x8)) {
+		write_data(pbpctl_dev, /*DISC_ON */ 0x85);
+		msec_delay_bp(LATCH_DELAY);
+	} else
+		ret = BP_NOT_CAP;
+	return ret;
+}
+
+/*TWO_PORT_LINK_HW_EN (0xe)*/
+static int tpl_hw_on(struct bpctl_dev *pbpctl_dev)
+{
+	int ret = 0, ctrl = 0;
+	struct bpctl_dev *pbpctl_dev_b = NULL;
+
+	pbpctl_dev_b = get_status_port(pbpctl_dev);
+	if (!pbpctl_dev_b)
+		return BP_NOT_CAP;
+
+	if (pbpctl_dev->bp_caps_ex & TPL2_CAP_EX) {
+		cmnd_on(pbpctl_dev);
+		write_data(pbpctl_dev, TPL2_ON);
+		msec_delay_bp(EEPROM_WR_DELAY);
+		cmnd_off(pbpctl_dev);
+		return ret;
+	}
+
+	if (TPL_IF_SERIES(pbpctl_dev->subdevice)) {
+		ctrl = BPCTL_READ_REG(pbpctl_dev_b, CTRL);
+		BPCTL_BP_WRITE_REG(pbpctl_dev_b, CTRL,
+				   ((ctrl | BPCTLI_CTRL_SWDPIO0) &
+					~BPCTLI_CTRL_SWDPIN0));
+	} else
+		ret = BP_NOT_CAP;
+	return ret;
+}
+
+/*TWO_PORT_LINK_HW_DIS (0xc)*/
+static int tpl_hw_off(struct bpctl_dev *pbpctl_dev)
+{
+	int ret = 0, ctrl = 0;
+	struct bpctl_dev *pbpctl_dev_b = NULL;
+
+	pbpctl_dev_b = get_status_port(pbpctl_dev);
+	if (!pbpctl_dev_b)
+		return BP_NOT_CAP;
+	if (pbpctl_dev->bp_caps_ex & TPL2_CAP_EX) {
+		cmnd_on(pbpctl_dev);
+		write_data(pbpctl_dev, TPL2_OFF);
+		msec_delay_bp(EEPROM_WR_DELAY);
+		cmnd_off(pbpctl_dev);
+		return ret;
+	}
+	if (TPL_IF_SERIES(pbpctl_dev->subdevice)) {
+		ctrl = BPCTL_READ_REG(pbpctl_dev_b, CTRL);
+		BPCTL_BP_WRITE_REG(pbpctl_dev_b, CTRL,
+				   (ctrl | BPCTLI_CTRL_SWDPIO0 |
+					BPCTLI_CTRL_SWDPIN0));
+	} else
+		ret = BP_NOT_CAP;
+	return ret;
+}
+
+/* WDT_OFF (0x6 110)*/
+static int wdt_off(struct bpctl_dev *pbpctl_dev)
+{
+	int ret = BP_NOT_CAP;
+
+	if (pbpctl_dev->bp_caps & WD_CTL_CAP) {
+		if (INTEL_IF_SERIES(pbpctl_dev->subdevice))
+			bypass_off(pbpctl_dev);
+		else if (pbpctl_dev->bp_ext_ver >= PXG2BPI_VER)
+			write_data(pbpctl_dev, WDT_OFF);
+		else
+			data_pulse(pbpctl_dev, WDT_OFF);
+		pbpctl_dev->wdt_status = WDT_STATUS_DIS;
+		ret = 0;
+	}
+	return ret;
+}
+
+/* WDT_ON (0x10)*/
+
+/***Global***/
+static unsigned int
+	wdt_val_array[] = { 1000, 1500, 2000, 3000, 4000,
+			    8000, 16000, 32000, 0 };
+
+static int wdt_on(struct bpctl_dev *pbpctl_dev, unsigned int timeout)
+{
+
+	if (pbpctl_dev->bp_caps & WD_CTL_CAP) {
+		unsigned int pulse = 0, temp_value = 0, temp_cnt = 0;
+
+		pbpctl_dev->wdt_status = 0;
+
+		if (INTEL_IF_SERIES(pbpctl_dev->subdevice)) {
+			for (; wdt_val_array[temp_cnt]; temp_cnt++)
+				if (timeout <= wdt_val_array[temp_cnt])
+					break;
+
+			if (!wdt_val_array[temp_cnt])
+				temp_cnt--;
+
+			timeout = wdt_val_array[temp_cnt];
+			temp_cnt += 0x7;
+
+			write_data_int(pbpctl_dev, DIS_BYPASS_CAP_INT);
+			msec_delay_bp(BYPASS_DELAY_INT);
+			pbpctl_dev->bp_status_un = 0;
+			write_data_int(pbpctl_dev, temp_cnt);
+			pbpctl_dev->bypass_wdt_on_time = jiffies;
+			msec_delay_bp(CMND_INTERVAL_INT);
+			pbpctl_dev->bypass_timer_interval = timeout;
+		} else {
+			timeout = (timeout < TIMEOUT_UNIT ?
+				  TIMEOUT_UNIT :
+				  (timeout > WDT_TIMEOUT_MAX ?
+					WDT_TIMEOUT_MAX : timeout));
+			temp_value = timeout / 100;
+			while ((temp_value >>= 1))
+				temp_cnt++;
+			if (timeout > ((1 << temp_cnt) * 100))
+				temp_cnt++;
+			pbpctl_dev->bypass_wdt_on_time = jiffies;
+			pulse = (WDT_ON | temp_cnt);
+			if (pbpctl_dev->bp_ext_ver == OLD_IF_VER)
+				data_pulse(pbpctl_dev, pulse);
+			else
+				write_data(pbpctl_dev, pulse);
+			pbpctl_dev->bypass_timer_interval =
+				(1 << temp_cnt) * 100;
+		}
+		pbpctl_dev->wdt_status = WDT_STATUS_EN;
+		return 0;
+	}
+	return BP_NOT_CAP;
+}
+
+static void bp75_put_hw_semaphore_generic(struct bpctl_dev *pbpctl_dev)
+{
+	u32 swsm;
+
+	swsm = BPCTL_READ_REG(pbpctl_dev, SWSM);
+
+	swsm &= ~(BPCTLI_SWSM_SMBI | BPCTLI_SWSM_SWESMBI);
+
+	BPCTL_WRITE_REG(pbpctl_dev, SWSM, swsm);
+}
+
+static s32 bp75_get_hw_semaphore_generic(struct bpctl_dev *pbpctl_dev)
+{
+	u32 swsm;
+	s32 ret_val = 0;
+	s32 timeout = 8192 + 1;
+	s32 i = 0;
+
+	/* Get the SW semaphore */
+	while (i < timeout) {
+		swsm = BPCTL_READ_REG(pbpctl_dev, SWSM);
+		if (!(swsm & BPCTLI_SWSM_SMBI))
+			break;
+
+		usec_delay(50);
+		i++;
+	}
+
+	if (i == timeout) {
+		pr_err("Can't access device - SMBI bit is set.\n");
+		ret_val = -1;
+		goto out;
+	}
+
+	/* Get the FW semaphore. */
+	for (i = 0; i < timeout; i++) {
+		swsm = BPCTL_READ_REG(pbpctl_dev, SWSM);
+		BPCTL_WRITE_REG(pbpctl_dev, SWSM, swsm | BPCTLI_SWSM_SWESMBI);
+
+		/* Semaphore acquired if bit latched */
+		if (BPCTL_READ_REG(pbpctl_dev, SWSM) & BPCTLI_SWSM_SWESMBI)
+			break;
+
+		usec_delay(50);
+	}
+
+	if (i == timeout) {
+		/* Release semaphores */
+		bp75_put_hw_semaphore_generic(pbpctl_dev);
+		pr_err("Can't access the NVM\n");
+		ret_val = -1;
+		goto out;
+	}
+
+ out:
+	return ret_val;
+}
+
+static void bp75_release_phy(struct bpctl_dev *pbpctl_dev)
+{
+	u16 mask = BPCTLI_SWFW_PHY0_SM;
+	u32 swfw_sync;
+	s32 ret_val;
+
+	if ((pbpctl_dev->func == 1) || (pbpctl_dev->func == 3))
+		mask = BPCTLI_SWFW_PHY1_SM;
+
+	do
+		ret_val = bp75_get_hw_semaphore_generic(pbpctl_dev);
+	while (ret_val != 0);
+
+	swfw_sync = BPCTL_READ_REG(pbpctl_dev, SW_FW_SYNC);
+	swfw_sync &= ~mask;
+	BPCTL_WRITE_REG(pbpctl_dev, SW_FW_SYNC, swfw_sync);
+
+	bp75_put_hw_semaphore_generic(pbpctl_dev);
+}
+
+static s32 bp75_acquire_phy(struct bpctl_dev *pbpctl_dev)
+{
+	u16 mask = BPCTLI_SWFW_PHY0_SM;
+	u32 swfw_sync;
+	u32 swmask;
+	u32 fwmask;
+	s32 ret_val = 0;
+	s32 i = 0, timeout = 200;
+
+	if ((pbpctl_dev->func == 1) || (pbpctl_dev->func == 3))
+		mask = BPCTLI_SWFW_PHY1_SM;
+
+	swmask = mask;
+	fwmask = mask << 16;
+
+	while (i < timeout) {
+		if (bp75_get_hw_semaphore_generic(pbpctl_dev)) {
+			ret_val = -1;
+			goto out;
+		}
+
+		swfw_sync = BPCTL_READ_REG(pbpctl_dev, SW_FW_SYNC);
+		if (!(swfw_sync & (fwmask | swmask)))
+			break;
+
+		bp75_put_hw_semaphore_generic(pbpctl_dev);
+		mdelay(5);
+		i++;
+	}
+
+	if (i == timeout) {
+		pr_err("SW_FW_SYNC timeout.\n");
+		ret_val = -1;
+		goto out;
+	}
+
+	swfw_sync |= swmask;
+	BPCTL_WRITE_REG(pbpctl_dev, SW_FW_SYNC, swfw_sync);
+
+	bp75_put_hw_semaphore_generic(pbpctl_dev);
+
+ out:
+	return ret_val;
+}
+
+static s32 bp75_read_phy_reg_mdic(struct bpctl_dev *pbpctl_dev, u32 offset,
+				  u16 *data)
+{
+	u32 i, mdic = 0;
+	s32 ret_val = 0;
+	u32 phy_addr = 1;
+
+	mdic = ((offset << BPCTLI_MDIC_REG_SHIFT) |
+		(phy_addr << BPCTLI_MDIC_PHY_SHIFT) | (BPCTLI_MDIC_OP_READ));
+
+	BPCTL_WRITE_REG(pbpctl_dev, MDIC, mdic);
+
+	for (i = 0; i < (BPCTLI_GEN_POLL_TIMEOUT * 3); i++) {
+		usec_delay(50);
+		mdic = BPCTL_READ_REG(pbpctl_dev, MDIC);
+		if (mdic & BPCTLI_MDIC_READY)
+			break;
+	}
+	if (!(mdic & BPCTLI_MDIC_READY)) {
+		pr_err("MDI Read did not complete\n");
+		ret_val = -1;
+		goto out;
+	}
+	if (mdic & BPCTLI_MDIC_ERROR) {
+		pr_err("MDI Error\n");
+		ret_val = -1;
+		goto out;
+	}
+	*data = (u16) mdic;
+
+ out:
+	return ret_val;
+}
+
+static s32 bp75_write_phy_reg_mdic(struct bpctl_dev *pbpctl_dev, u32 offset,
+				   u16 data)
+{
+	u32 i, mdic = 0;
+	s32 ret_val = 0;
+	u32 phy_addr = 1;
+
+	mdic = (((u32) data) |
+		(offset << BPCTLI_MDIC_REG_SHIFT) |
+		(phy_addr << BPCTLI_MDIC_PHY_SHIFT) | (BPCTLI_MDIC_OP_WRITE));
+
+	BPCTL_WRITE_REG(pbpctl_dev, MDIC, mdic);
+
+	for (i = 0; i < (BPCTLI_GEN_POLL_TIMEOUT * 3); i++) {
+		usec_delay(50);
+		mdic = BPCTL_READ_REG(pbpctl_dev, MDIC);
+		if (mdic & BPCTLI_MDIC_READY)
+			break;
+	}
+	if (!(mdic & BPCTLI_MDIC_READY)) {
+		pr_err("MDI Write did not complete\n");
+		ret_val = -1;
+		goto out;
+	}
+	if (mdic & BPCTLI_MDIC_ERROR) {
+		pr_err("MDI Error\n");
+		ret_val = -1;
+		goto out;
+	}
+
+ out:
+	return ret_val;
+}
+
+static s32 bp75_read_phy_reg(struct bpctl_dev *pbpctl_dev,
+			     u32 offset, u16 *data)
+{
+	s32 ret_val = 0;
+
+	ret_val = bp75_acquire_phy(pbpctl_dev);
+	if (ret_val)
+		goto out;
+
+	if (offset > BPCTLI_MAX_PHY_MULTI_PAGE_REG) {
+		ret_val = bp75_write_phy_reg_mdic(pbpctl_dev,
+					BPCTLI_IGP01E1000_PHY_PAGE_SELECT,
+					(u16) offset);
+		if (ret_val)
+			goto release;
+	}
+
+	ret_val =
+		bp75_read_phy_reg_mdic(pbpctl_dev,
+				   BPCTLI_MAX_PHY_REG_ADDRESS & offset, data);
+
+ release:
+	bp75_release_phy(pbpctl_dev);
+ out:
+	return ret_val;
+}
+
+static s32 bp75_write_phy_reg(struct bpctl_dev *pbpctl_dev,
+			      u32 offset, u16 data)
+{
+	s32 ret_val = 0;
+
+	ret_val = bp75_acquire_phy(pbpctl_dev);
+	if (ret_val)
+		goto out;
+
+	if (offset > BPCTLI_MAX_PHY_MULTI_PAGE_REG) {
+		ret_val = bp75_write_phy_reg_mdic(pbpctl_dev,
+					BPCTLI_IGP01E1000_PHY_PAGE_SELECT,
+					(u16) offset);
+		if (ret_val)
+			goto release;
+	}
+
+	ret_val =
+		bp75_write_phy_reg_mdic(pbpctl_dev,
+				BPCTLI_MAX_PHY_REG_ADDRESS & offset, data);
+
+ release:
+	bp75_release_phy(pbpctl_dev);
+
+ out:
+	return ret_val;
+}
+
+/* SET_TX  (non-Bypass command :)) */
+static int set_tx(struct bpctl_dev *pbpctl_dev, int tx_state)
+{
+	int ret = 0, ctrl = 0;
+	struct bpctl_dev *pbpctl_dev_m;
+
+	if ((is_bypass(pbpctl_dev)) == 1)
+		pbpctl_dev_m = pbpctl_dev;
+	else
+		pbpctl_dev_m = get_master_port(pbpctl_dev);
+	if (pbpctl_dev_m == NULL)
+		return BP_NOT_CAP;
+	if ((pbpctl_dev_m->bp_caps_ex & DISC_PORT_CAP_EX)
+		&& (pbpctl_dev->nic_type != bp_10g9)) {
+		ctrl = BPCTL_READ_REG(pbpctl_dev, CTRL);
+		if (!tx_state) {
+			switch (pbpctl_dev->nic_type) {
+			case bp_540:
+				ctrl = BP10G_READ_REG(pbpctl_dev, ESDP);
+				BP10G_WRITE_REG(pbpctl_dev, ESDP,
+						(ctrl | BP10G_SDP1_DIR |
+						 BP10G_SDP1_DATA));
+				break;
+			case bp_fiber5:
+				ctrl = BPCTL_READ_REG(pbpctl_dev, CTRL_EXT);
+				BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL_EXT,
+						(ctrl |
+						 BPCTLI_CTRL_EXT_SDP6_DIR |
+						 BPCTLI_CTRL_EXT_SDP6_DATA));
+				break;
+			default:
+				BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL,
+						(ctrl | BPCTLI_CTRL_SDP1_DIR
+						| BPCTLI_CTRL_SWDPIN1));
+				break;
+			}
+		} else {
+			switch (pbpctl_dev->nic_type) {
+			case bp_540:
+				ctrl = BP10G_READ_REG(pbpctl_dev, ESDP);
+				BP10G_WRITE_REG(pbpctl_dev, ESDP,
+						((ctrl | BP10G_SDP1_DIR) &
+						 ~BP10G_SDP1_DATA));
+				break;
+			case bp_fiber5:
+				ctrl = BPCTL_READ_REG(pbpctl_dev, CTRL_EXT);
+				BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL_EXT,
+						((ctrl |
+						 BPCTLI_CTRL_EXT_SDP6_DIR) &
+						~BPCTLI_CTRL_EXT_SDP6_DATA));
+				break;
+			default:
+				BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL,
+						((ctrl |
+						BPCTLI_CTRL_SDP1_DIR) &
+						~BPCTLI_CTRL_SWDPIN1));
+				break;
+			}
+			return ret;
+		}
+	} else if (pbpctl_dev->bp_caps & TX_CTL_CAP) {
+		if (PEG5_IF_SERIES(pbpctl_dev->subdevice)) {
+			if (tx_state) {
+				uint16_t mii_reg;
+
+				ret = bp75_read_phy_reg(pbpctl_dev,
+						  MII_BMCR,
+						  &mii_reg);
+				if (!ret) {
+					if (mii_reg & BMCR_PDOWN) {
+						ret =
+							bp75_write_phy_reg
+							(pbpctl_dev,
+							 MII_BMCR,
+							 mii_reg &
+							 ~BMCR_PDOWN);
+					}
+				}
+			} else {
+				uint16_t mii_reg;
+
+				ret = bp75_read_phy_reg(pbpctl_dev,
+						  MII_BMCR,
+						  &mii_reg);
+				if (!ret) {
+
+					mii_reg |= BMCR_PDOWN;
+					ret = bp75_write_phy_reg(pbpctl_dev,
+							   MII_BMCR,
+							   mii_reg);
+				}
+			}
+
+		}
+		switch (pbpctl_dev->nic_type) {
+		case bp_fiber5:
+			ctrl = BPCTL_READ_REG(pbpctl_dev, CTRL_EXT);
+			break;
+		case bp_10gb:
+			ctrl = BP10GB_READ_REG(pbpctl_dev, MISC_REG_GPIO);
+			break;
+		case bp_10g:
+			ctrl = BP10G_READ_REG(pbpctl_dev, ESDP);
+			break;
+		default:
+			ctrl = BPCTL_READ_REG(pbpctl_dev, CTRL);
+			break;
+		}
+
+		if (!tx_state) {
+			switch (pbpctl_dev->nic_type) {
+			case bp_10g9:
+				BP10G_WRITE_REG(pbpctl_dev, ESDP,
+						(ctrl | BP10G_SDP3_DATA |
+						 BP10G_SDP3_DIR));
+				break;
+			case bp_fiber5:
+				BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL_EXT,
+						(ctrl |
+						 BPCTLI_CTRL_EXT_SDP6_DIR |
+						 BPCTLI_CTRL_EXT_SDP6_DATA));
+				break;
+			case bp_10gb:
+				if ((pbpctl_dev->func == 1)
+					|| (pbpctl_dev->func == 3))
+					BP10GB_WRITE_REG(pbpctl_dev,
+							 MISC_REG_GPIO,
+							 (ctrl
+							  |
+							  BP10GB_GPIO0_SET_P1)
+							  &
+							 ~(BP10GB_GPIO0_CLR_P1 |
+							   BP10GB_GPIO0_OE_P1));
+				else
+					BP10GB_WRITE_REG(pbpctl_dev,
+							 MISC_REG_GPIO,
+							 (ctrl |
+							  BP10GB_GPIO0_OE_P0 |
+							  BP10GB_GPIO0_SET_P0));
+				break;
+			case bp_i80:
+				BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL,
+						   (ctrl | BPCTLI_CTRL_SDP1_DIR
+							| BPCTLI_CTRL_SWDPIN1));
+				break;
+			case bp_540:
+				ctrl = BP10G_READ_REG(pbpctl_dev, ESDP);
+				BP10G_WRITE_REG(pbpctl_dev, ESDP,
+						(ctrl | BP10G_SDP1_DIR |
+						 BP10G_SDP1_DATA));
+				break;
+			case bp_10g:
+				BP10G_WRITE_REG(pbpctl_dev, ESDP,
+						(ctrl | BP10G_SDP0_DATA |
+						 BP10G_SDP0_DIR));
+				break;
+			default:
+				BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL,
+						   (ctrl | BPCTLI_CTRL_SWDPIO0 |
+							BPCTLI_CTRL_SWDPIN0));
+				break;
+			}
+		} else {
+			switch (pbpctl_dev->nic_type) {
+			case bp_10g9:
+				BP10G_WRITE_REG(pbpctl_dev, ESDP,
+						((ctrl | BP10G_SDP3_DIR) &
+						 ~BP10G_SDP3_DATA));
+				break;
+			case bp_fiber5:
+				BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL_EXT,
+						((ctrl
+						  |
+						  BPCTLI_CTRL_EXT_SDP6_DIR)
+						  &
+						  ~
+						  BPCTLI_CTRL_EXT_SDP6_DATA));
+				break;
+			case bp_10gb:
+				if ((bpctl_dev_arr->func == 1)
+					|| (bpctl_dev_arr->func == 3))
+					BP10GB_WRITE_REG(pbpctl_dev,
+							 MISC_REG_GPIO,
+							 (ctrl |
+							  BP10GB_GPIO0_CLR_P1) &
+							 ~(BP10GB_GPIO0_SET_P1 |
+							   BP10GB_GPIO0_OE_P1));
+				else
+					BP10GB_WRITE_REG(pbpctl_dev,
+							 MISC_REG_GPIO,
+							 (ctrl |
+							  BP10GB_GPIO0_OE_P0 |
+							  BP10GB_GPIO0_CLR_P0));
+				break;
+			case bp_i80:
+				BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL,
+						   ((ctrl |
+							 BPCTLI_CTRL_SDP1_DIR) &
+							~BPCTLI_CTRL_SWDPIN1));
+				break;
+			case bp_540:
+				ctrl = BP10G_READ_REG(pbpctl_dev, ESDP);
+				BP10G_WRITE_REG(pbpctl_dev, ESDP,
+						((ctrl | BP10G_SDP1_DIR) &
+						 ~BP10G_SDP1_DATA));
+				break;
+			case bp_10g:
+				BP10G_WRITE_REG(pbpctl_dev, ESDP,
+						((ctrl | BP10G_SDP0_DIR) &
+						 ~BP10G_SDP0_DATA));
+
+				break;
+			default:
+				BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL,
+						   ((ctrl | BPCTLI_CTRL_SWDPIO0)
+						     & ~BPCTLI_CTRL_SWDPIN0));
+				if (!PEGF_IF_SERIES(pbpctl_dev->subdevice)) {
+					BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL,
+						(ctrl &
+						 ~
+						 (BPCTLI_CTRL_SDP0_DATA
+						 |
+						 BPCTLI_CTRL_SDP0_DIR)));
+				}
+				break;
+			}
+		}
+	} else
+		ret = BP_NOT_CAP;
+	return ret;
+
+}
+
+/* SET_FORCE_LINK  (non-Bypass command :)) */
+static int set_bp_force_link(struct bpctl_dev *pbpctl_dev, int tx_state)
+{
+	int ret = 0, ctrl = 0;
+
+	if (DBI_IF_SERIES(pbpctl_dev->subdevice)) {
+
+		if ((pbpctl_dev->nic_type == bp_10g) ||
+			 (pbpctl_dev->nic_type == bp_10g9)) {
+			ctrl = BPCTL_READ_REG(pbpctl_dev, CTRL);
+			if (!tx_state)
+				BP10G_WRITE_REG(pbpctl_dev, ESDP,
+						ctrl & ~BP10G_SDP1_DIR);
+			else
+				BP10G_WRITE_REG(pbpctl_dev, ESDP,
+						((ctrl | BP10G_SDP1_DIR) &
+						 ~BP10G_SDP1_DATA));
+			return ret;
+		}
+	}
+	return BP_NOT_CAP;
+}
+
+/*RESET_CONT 0x20 */
+static int reset_cont(struct bpctl_dev *pbpctl_dev)
+{
+	int ret = BP_NOT_CAP;
+
+	if (pbpctl_dev->bp_caps & SW_CTL_CAP) {
+		if (INTEL_IF_SERIES(pbpctl_dev->subdevice))
+			return BP_NOT_CAP;
+		if (pbpctl_dev->bp_ext_ver >= PXG2BPI_VER)
+			write_data(pbpctl_dev, RESET_CONT);
+		else
+			data_pulse(pbpctl_dev, RESET_CONT);
+		ret = 0;
+	}
+	return ret;
+}
+
+/*DIS_BYPASS_CAP 0x22 */
+static int dis_bypass_cap(struct bpctl_dev *pbpctl_dev)
+{
+
+	if (pbpctl_dev->bp_caps & BP_DIS_CAP) {
+		if (INTEL_IF_SERIES(pbpctl_dev->subdevice)) {
+			write_data_int(pbpctl_dev, DIS_BYPASS_CAP_INT);
+			msec_delay_bp(BYPASS_DELAY_INT);
+		} else {
+			write_data(pbpctl_dev, BYPASS_OFF);
+			msec_delay_bp(LATCH_DELAY);
+			write_data(pbpctl_dev, DIS_BYPASS_CAP);
+			msec_delay_bp(BYPASS_CAP_DELAY);
+		}
+		return 0;
+	}
+	return BP_NOT_CAP;
+}
+
+/*EN_BYPASS_CAP 0x24 */
+static int en_bypass_cap(struct bpctl_dev *pbpctl_dev)
+{
+	if (pbpctl_dev->bp_caps & BP_DIS_CAP) {
+		if (INTEL_IF_SERIES(pbpctl_dev->subdevice)) {
+			write_data_int(pbpctl_dev, PWROFF_BYPASS_ON_INT);
+			msec_delay_bp(BYPASS_DELAY_INT);
+		} else {
+			write_data(pbpctl_dev, EN_BYPASS_CAP);
+			msec_delay_bp(BYPASS_CAP_DELAY);
+		}
+		return 0;
+	}
+	return BP_NOT_CAP;
+}
+
+/* BYPASS_STATE_PWRON 0x26*/
+static int bypass_state_pwron(struct bpctl_dev *pbpctl_dev)
+{
+	if (pbpctl_dev->bp_caps & BP_PWUP_CTL_CAP) {
+		write_data(pbpctl_dev, BYPASS_STATE_PWRON);
+		if (pbpctl_dev->bp_ext_ver == PXG2BPI_VER)
+			msec_delay_bp(DFLT_PWRON_DELAY);
+		else
+			msec_delay_bp(EEPROM_WR_DELAY);
+		return 0;
+	}
+	return BP_NOT_CAP;
+}
+
+/* NORMAL_STATE_PWRON 0x28*/
+static int normal_state_pwron(struct bpctl_dev *pbpctl_dev)
+{
+	if ((pbpctl_dev->bp_caps & BP_PWUP_CTL_CAP)
+		|| (pbpctl_dev->bp_caps & TAP_PWUP_CTL_CAP)) {
+		write_data(pbpctl_dev, NORMAL_STATE_PWRON);
+		if (pbpctl_dev->bp_ext_ver == PXG2BPI_VER)
+			msec_delay_bp(DFLT_PWRON_DELAY);
+		else
+			msec_delay_bp(EEPROM_WR_DELAY);
+		return 0;
+	}
+	return BP_NOT_CAP;
+}
+
+/* BYPASS_STATE_PWROFF 0x27*/
+static int bypass_state_pwroff(struct bpctl_dev *pbpctl_dev)
+{
+	if (pbpctl_dev->bp_caps & BP_PWOFF_CTL_CAP) {
+		write_data(pbpctl_dev, BYPASS_STATE_PWROFF);
+		msec_delay_bp(EEPROM_WR_DELAY);
+		return 0;
+	}
+	return BP_NOT_CAP;
+}
+
+/* NORMAL_STATE_PWROFF 0x29*/
+static int normal_state_pwroff(struct bpctl_dev *pbpctl_dev)
+{
+	if ((pbpctl_dev->bp_caps & BP_PWOFF_CTL_CAP)) {
+		write_data(pbpctl_dev, NORMAL_STATE_PWROFF);
+		msec_delay_bp(EEPROM_WR_DELAY);
+		return 0;
+	}
+	return BP_NOT_CAP;
+}
+
+/*TAP_STATE_PWRON 0x2a*/
+static int tap_state_pwron(struct bpctl_dev *pbpctl_dev)
+{
+	if (pbpctl_dev->bp_caps & TAP_PWUP_CTL_CAP) {
+		write_data(pbpctl_dev, TAP_STATE_PWRON);
+		msec_delay_bp(EEPROM_WR_DELAY);
+		return 0;
+	}
+	return BP_NOT_CAP;
+}
+
+/*DIS_TAP_CAP 0x2c*/
+static int dis_tap_cap(struct bpctl_dev *pbpctl_dev)
+{
+	if (pbpctl_dev->bp_caps & TAP_DIS_CAP) {
+		write_data(pbpctl_dev, DIS_TAP_CAP);
+		msec_delay_bp(BYPASS_CAP_DELAY);
+		return 0;
+	}
+	return BP_NOT_CAP;
+}
+
+/*EN_TAP_CAP 0x2e*/
+static int en_tap_cap(struct bpctl_dev *pbpctl_dev)
+{
+	if (pbpctl_dev->bp_caps & TAP_DIS_CAP) {
+		write_data(pbpctl_dev, EN_TAP_CAP);
+		msec_delay_bp(BYPASS_CAP_DELAY);
+		return 0;
+	}
+	return BP_NOT_CAP;
+}
+
+/*DISC_STATE_PWRON 0x2a*/
+static int disc_state_pwron(struct bpctl_dev *pbpctl_dev)
+{
+	if (pbpctl_dev->bp_caps & DISC_PWUP_CTL_CAP) {
+		if (pbpctl_dev->bp_ext_ver >= 0x8) {
+			write_data(pbpctl_dev, DISC_STATE_PWRON);
+			msec_delay_bp(EEPROM_WR_DELAY);
+			return BP_OK;
+		}
+	}
+	return BP_NOT_CAP;
+}
+
+/*DIS_DISC_CAP 0x2c*/
+static int dis_disc_cap(struct bpctl_dev *pbpctl_dev)
+{
+	if (pbpctl_dev->bp_caps & DISC_DIS_CAP) {
+		if (pbpctl_dev->bp_ext_ver >= 0x8) {
+			write_data(pbpctl_dev, DIS_DISC_CAP);
+			msec_delay_bp(BYPASS_CAP_DELAY);
+			return BP_OK;
+		}
+	}
+	return BP_NOT_CAP;
+}
+
+/*EN_TAP_CAP 0x2e*/
+static int en_disc_cap(struct bpctl_dev *pbpctl_dev)
+{
+	if (pbpctl_dev->bp_caps & DISC_DIS_CAP) {
+		if (pbpctl_dev->bp_ext_ver >= 0x8) {
+			write_data(pbpctl_dev, EN_DISC_CAP);
+			msec_delay_bp(BYPASS_CAP_DELAY);
+			return BP_OK;
+		}
+	}
+	return BP_NOT_CAP;
+}
+
+static int std_nic_on(struct bpctl_dev *pbpctl_dev)
+{
+
+	if (pbpctl_dev->bp_caps & STD_NIC_CAP) {
+
+		if (INTEL_IF_SERIES(pbpctl_dev->subdevice)) {
+			write_data_int(pbpctl_dev, DIS_BYPASS_CAP_INT);
+			msec_delay_bp(BYPASS_DELAY_INT);
+			pbpctl_dev->bp_status_un = 0;
+			return BP_OK;
+		}
+
+		if (pbpctl_dev->bp_ext_ver >= 0x8) {
+			write_data(pbpctl_dev, STD_NIC_ON);
+			msec_delay_bp(BYPASS_CAP_DELAY);
+			return BP_OK;
+
+		}
+
+		if (pbpctl_dev->bp_ext_ver >= PXG2BPI_VER) {
+			wdt_off(pbpctl_dev);
+
+			if (pbpctl_dev->bp_caps & BP_CAP) {
+				write_data(pbpctl_dev, BYPASS_OFF);
+				msec_delay_bp(LATCH_DELAY);
+			}
+
+			if (pbpctl_dev->bp_caps & TAP_CAP) {
+				write_data(pbpctl_dev, TAP_OFF);
+				msec_delay_bp(LATCH_DELAY);
+			}
+
+			write_data(pbpctl_dev, NORMAL_STATE_PWRON);
+			if (pbpctl_dev->bp_ext_ver == PXG2BPI_VER)
+				msec_delay_bp(DFLT_PWRON_DELAY);
+			else
+				msec_delay_bp(EEPROM_WR_DELAY);
+
+			if (pbpctl_dev->bp_caps & BP_DIS_CAP) {
+				write_data(pbpctl_dev, DIS_BYPASS_CAP);
+				msec_delay_bp(BYPASS_CAP_DELAY);
+			}
+
+			if (pbpctl_dev->bp_caps & TAP_DIS_CAP) {
+				write_data(pbpctl_dev, DIS_TAP_CAP);
+				msec_delay_bp(BYPASS_CAP_DELAY);
+
+			}
+			return 0;
+		}
+	}
+	return BP_NOT_CAP;
+}
+
+static int std_nic_off(struct bpctl_dev *pbpctl_dev)
+{
+
+	if (pbpctl_dev->bp_caps & STD_NIC_CAP) {
+		if (INTEL_IF_SERIES(pbpctl_dev->subdevice)) {
+			write_data_int(pbpctl_dev, PWROFF_BYPASS_ON_INT);
+			msec_delay_bp(BYPASS_DELAY_INT);
+			return BP_OK;
+		}
+		if (pbpctl_dev->bp_ext_ver >= 0x8) {
+			write_data(pbpctl_dev, STD_NIC_OFF);
+			msec_delay_bp(BYPASS_CAP_DELAY);
+			return BP_OK;
+
+		}
+
+		if (pbpctl_dev->bp_ext_ver >= PXG2BPI_VER) {
+
+			if (pbpctl_dev->bp_caps & TAP_PWUP_CTL_CAP) {
+				write_data(pbpctl_dev, TAP_STATE_PWRON);
+				msec_delay_bp(EEPROM_WR_DELAY);
+			}
+
+			if (pbpctl_dev->bp_caps & BP_PWUP_CTL_CAP) {
+				write_data(pbpctl_dev, BYPASS_STATE_PWRON);
+				if (pbpctl_dev->bp_ext_ver > PXG2BPI_VER)
+					msec_delay_bp(LATCH_DELAY +
+							  EEPROM_WR_DELAY);
+				else
+					msec_delay_bp(DFLT_PWRON_DELAY);
+			}
+
+			if (pbpctl_dev->bp_caps & TAP_DIS_CAP) {
+				write_data(pbpctl_dev, EN_TAP_CAP);
+				msec_delay_bp(BYPASS_CAP_DELAY);
+			}
+			if (pbpctl_dev->bp_caps & DISC_DIS_CAP) {
+				write_data(pbpctl_dev, EN_DISC_CAP);
+				msec_delay_bp(BYPASS_CAP_DELAY);
+			}
+
+			if (pbpctl_dev->bp_caps & BP_DIS_CAP) {
+				write_data(pbpctl_dev, EN_BYPASS_CAP);
+				msec_delay_bp(BYPASS_CAP_DELAY);
+			}
+
+			return 0;
+		}
+	}
+	return BP_NOT_CAP;
+}
+
+static int wdt_timer(struct bpctl_dev *pbpctl_dev, int *time_left)
+{
+	int ret = 0;
+
+	if (pbpctl_dev->bp_caps & WD_CTL_CAP) {
+		{
+			if (pbpctl_dev->wdt_status == WDT_STATUS_UNKNOWN)
+				ret = BP_NOT_CAP;
+			else
+				*time_left = wdt_time_left(pbpctl_dev);
+		}
+
+	} else
+		ret = BP_NOT_CAP;
+	return ret;
+}
+
+static int wdt_timer_reload(struct bpctl_dev *pbpctl_dev)
+{
+
+	int ret = 0;
+
+	if ((pbpctl_dev->bp_caps & WD_CTL_CAP) &&
+		(pbpctl_dev->wdt_status != WDT_STATUS_UNKNOWN)) {
+		if (pbpctl_dev->wdt_status == WDT_STATUS_DIS)
+			return 0;
+		if (pbpctl_dev->bp_ext_ver >= PXG2BPI_VER)
+			ret = wdt_pulse(pbpctl_dev);
+		else if (INTEL_IF_SERIES(pbpctl_dev->subdevice))
+			ret = wdt_pulse_int(pbpctl_dev);
+		else
+			ret = send_wdt_pulse(pbpctl_dev);
+		return 1;
+	}
+	return BP_NOT_CAP;
+}
+
+static void wd_reset_timer(unsigned long param)
+{
+	struct bpctl_dev *pbpctl_dev = (struct bpctl_dev *) param;
+
+	if ((pbpctl_dev->bp_ext_ver >= PXG2BPI_VER) &&
+		((atomic_read(&pbpctl_dev->wdt_busy)) == 1)) {
+		mod_timer(&pbpctl_dev->bp_timer, jiffies + 1);
+		return;
+	}
+
+	wdt_timer_reload(pbpctl_dev);
+
+	if (pbpctl_dev->reset_time) {
+		mod_timer(&pbpctl_dev->bp_timer,
+			  jiffies + (HZ * pbpctl_dev->reset_time) / 1000);
+	}
+}
+
+/*WAIT_AT_PWRUP 0x80   */
+static int bp_wait_at_pwup_en(struct bpctl_dev *pbpctl_dev)
+{
+
+	if (pbpctl_dev->bp_caps & SW_CTL_CAP) {
+		if (pbpctl_dev->bp_ext_ver >= BP_FW_EXT_VER8) {
+			write_data(pbpctl_dev, BP_WAIT_AT_PWUP_EN);
+			msec_delay_bp(EEPROM_WR_DELAY);
+
+			return BP_OK;
+		}
+	}
+	return BP_NOT_CAP;
+}
+
+/*DIS_WAIT_AT_PWRUP       0x81 */
+static int bp_wait_at_pwup_dis(struct bpctl_dev *pbpctl_dev)
+{
+
+	if (pbpctl_dev->bp_caps & SW_CTL_CAP) {
+
+		if (pbpctl_dev->bp_ext_ver >= BP_FW_EXT_VER8) {
+			write_data(pbpctl_dev, BP_WAIT_AT_PWUP_DIS);
+			msec_delay_bp(EEPROM_WR_DELAY);
+
+			return BP_OK;
+		}
+	}
+	return BP_NOT_CAP;
+}
+
+/*EN_HW_RESET  0x82   */
+
+static int bp_hw_reset_en(struct bpctl_dev *pbpctl_dev)
+{
+
+	if (pbpctl_dev->bp_caps & SW_CTL_CAP) {
+		if (pbpctl_dev->bp_ext_ver >= BP_FW_EXT_VER8) {
+			write_data(pbpctl_dev, BP_HW_RESET_EN);
+			msec_delay_bp(EEPROM_WR_DELAY);
+
+			return BP_OK;
+		}
+	}
+	return BP_NOT_CAP;
+}
+
+/*DIS_HW_RESET             0x83   */
+
+static int bp_hw_reset_dis(struct bpctl_dev *pbpctl_dev)
+{
+
+	if (pbpctl_dev->bp_caps & SW_CTL_CAP) {
+		if (pbpctl_dev->bp_ext_ver >= BP_FW_EXT_VER8) {
+			write_data(pbpctl_dev, BP_HW_RESET_DIS);
+			msec_delay_bp(EEPROM_WR_DELAY);
+
+			return BP_OK;
+		}
+	}
+	return BP_NOT_CAP;
+}
+
+
+static int wdt_exp_mode(struct bpctl_dev *pbpctl_dev, int mode)
+{
+	uint32_t status_reg = 0, status_reg1 = 0;
+
+	if (!(pbpctl_dev->bp_caps & (TAP_STATUS_CAP | DISC_CAP)) ||
+	    !(pbpctl_dev->bp_caps & BP_CAP))
+		return BP_NOT_CAP;
+
+	if (pbpctl_dev->bp_ext_ver >= PXE2TBPI_VER) {
+		if ((pbpctl_dev->bp_ext_ver >= 0x8) &&
+			(mode == 2)
+			 && (pbpctl_dev->bp_caps & DISC_CAP)) {
+			status_reg1 =
+				read_reg(pbpctl_dev, STATUS_DISC_REG_ADDR);
+			if (status_reg1 == BP_NOT_CAP)
+				return BP_NOT_CAP;
+			if (!(status_reg1 & WDTE_DISC_BPN_MASK))
+				write_reg(pbpctl_dev,
+					  status_reg1 |
+					  WDTE_DISC_BPN_MASK,
+					  STATUS_DISC_REG_ADDR);
+			return BP_OK;
+		}
+	}
+	status_reg = read_reg(pbpctl_dev, STATUS_TAP_REG_ADDR);
+
+	if (status_reg == BP_NOT_CAP)
+		return BP_NOT_CAP;
+
+	if ((mode == 0) && (pbpctl_dev->bp_caps & BP_CAP)) {
+		if (pbpctl_dev->bp_ext_ver >= 0x8) {
+			status_reg1 =
+				read_reg(pbpctl_dev, STATUS_DISC_REG_ADDR);
+			if (status_reg1 & WDTE_DISC_BPN_MASK)
+				write_reg(pbpctl_dev,
+					  status_reg1 &
+					  ~WDTE_DISC_BPN_MASK,
+					  STATUS_DISC_REG_ADDR);
+		}
+		if (status_reg & WDTE_TAP_BPN_MASK)
+			write_reg(pbpctl_dev,
+				  status_reg & ~WDTE_TAP_BPN_MASK,
+				  STATUS_TAP_REG_ADDR);
+		return BP_OK;
+	} else if ((mode == 1) && (pbpctl_dev->bp_caps & TAP_CAP)) {
+		if (!(status_reg & WDTE_TAP_BPN_MASK))
+			write_reg(pbpctl_dev, status_reg | WDTE_TAP_BPN_MASK,
+				  STATUS_TAP_REG_ADDR);
+		return BP_OK;
+	}
+	return BP_NOT_CAP;
+}
+
+static int bypass_fw_ver(struct bpctl_dev *pbpctl_dev)
+{
+	if (!is_bypass(pbpctl_dev))
+		return BP_NOT_CAP;
+	return read_reg(pbpctl_dev, VER_REG_ADDR);
+}
+
+static int bypass_sign_check(struct bpctl_dev *pbpctl_dev)
+{
+	if (!is_bypass(pbpctl_dev))
+		return BP_NOT_CAP;
+	return (((read_reg(pbpctl_dev, PIC_SIGN_REG_ADDR)) ==
+			 PIC_SIGN_VALUE) ? 1 : 0);
+}
+
+static int tx_status(struct bpctl_dev *pbpctl_dev)
+{
+	uint32_t ctrl = 0;
+	struct bpctl_dev *pbpctl_dev_m;
+
+	if ((is_bypass(pbpctl_dev)) == 1)
+		pbpctl_dev_m = pbpctl_dev;
+	else
+		pbpctl_dev_m = get_master_port(pbpctl_dev);
+	if (pbpctl_dev_m == NULL)
+		return BP_NOT_CAP;
+	if (pbpctl_dev_m->bp_caps_ex & DISC_PORT_CAP_EX) {
+		ctrl = BPCTL_READ_REG(pbpctl_dev, CTRL);
+		if (pbpctl_dev->nic_type == bp_i80)
+			return ((ctrl & BPCTLI_CTRL_SWDPIN1) != 0 ? 0 : 1);
+		if (pbpctl_dev->nic_type == bp_540) {
+			ctrl = BP10G_READ_REG(pbpctl_dev, ESDP);
+
+			return ((ctrl & BP10G_SDP1_DATA) != 0 ? 0 : 1);
+		}
+	}
+
+	if (!(pbpctl_dev->bp_caps & TX_CTL_CAP))
+		return BP_NOT_CAP;
+
+	if (PEG5_IF_SERIES(pbpctl_dev->subdevice)) {
+		uint16_t mii_reg;
+
+		if (!(bp75_read_phy_reg(pbpctl_dev, MII_BMCR, &mii_reg))) {
+			if (mii_reg & BMCR_PDOWN)
+				return 0;
+			return 1;
+		}
+		return -1;
+	}
+
+	switch (pbpctl_dev->nic_type) {
+	case bp_10g9:
+		return ((BP10G_READ_REG(pbpctl_dev, ESDP) &
+			 BP10G_SDP3_DATA) != 0 ? 0 : 1);
+	case bp_fiber5:
+		ctrl = BPCTL_READ_REG(pbpctl_dev, CTRL_EXT);
+		if (ctrl & BPCTLI_CTRL_EXT_SDP6_DATA)
+			return 0;
+		return 1;
+	case bp_10gb:
+		ctrl = BP10GB_READ_REG(pbpctl_dev, MISC_REG_GPIO);
+		BP10GB_WRITE_REG(pbpctl_dev, MISC_REG_GPIO,
+				 (ctrl | BP10GB_GPIO0_OE_P1) &
+				 ~(BP10GB_GPIO0_SET_P1 |
+				   BP10GB_GPIO0_CLR_P1));
+		if ((pbpctl_dev->func == 1) || (pbpctl_dev->func == 3))
+			return (((BP10GB_READ_REG
+				  (pbpctl_dev,
+				   MISC_REG_GPIO)) & BP10GB_GPIO0_P1) !=
+				0 ? 0 : 1);
+		else
+			return (((BP10GB_READ_REG
+				  (pbpctl_dev,
+				   MISC_REG_GPIO)) & BP10GB_GPIO0_P0) !=
+				0 ? 0 : 1);
+		break;
+	case bp_10g:
+		return ((BP10G_READ_REG(pbpctl_dev, ESDP) &
+			 BP10G_SDP0_DATA) != 0 ? 0 : 1);
+	default:
+		ctrl = BPCTL_READ_REG(pbpctl_dev, CTRL);
+		if (pbpctl_dev->nic_type == bp_i80)
+			return ((ctrl & BPCTLI_CTRL_SWDPIN1) !=
+				0 ? 0 : 1);
+		if (pbpctl_dev->nic_type == bp_540) {
+			ctrl = BP10G_READ_REG(pbpctl_dev, ESDP);
+
+			return ((ctrl & BP10G_SDP1_DATA) != 0 ? 0 : 1);
+		}
+
+		return ((ctrl & BPCTLI_CTRL_SWDPIN0) != 0 ? 0 : 1);
+	}
+}
+
+static int bp_force_link_status(struct bpctl_dev *pbpctl_dev)
+{
+	if (!(DBI_IF_SERIES(pbpctl_dev->subdevice)))
+		return BP_NOT_CAP;
+
+	return ((BP10G_READ_REG(pbpctl_dev, ESDP) &
+			BP10G_SDP1_DIR) != 0 ? 1 : 0);
+}
+
+static int bypass_from_last_read(struct bpctl_dev *pbpctl_dev)
+{
+	uint32_t ctrl_ext = 0;
+	struct bpctl_dev *pbpctl_dev_b = NULL;
+
+	if (!(pbpctl_dev->bp_caps & SW_CTL_CAP))
+		return BP_NOT_CAP;
+
+	pbpctl_dev_b = get_status_port(pbpctl_dev);
+	if (!pbpctl_dev_b)
+		return BP_NOT_CAP;
+	ctrl_ext = BPCTL_READ_REG(pbpctl_dev_b, CTRL_EXT);
+	BPCTL_BP_WRITE_REG(pbpctl_dev_b, CTRL_EXT,
+			   (ctrl_ext & ~BPCTLI_CTRL_EXT_SDP7_DIR));
+	ctrl_ext = BPCTL_READ_REG(pbpctl_dev_b, CTRL_EXT);
+	if (ctrl_ext & BPCTLI_CTRL_EXT_SDP7_DATA)
+		return 0;
+	return 1;
+}
+
+static int bypass_status_clear(struct bpctl_dev *pbpctl_dev)
+{
+	struct bpctl_dev *pbpctl_dev_b = NULL;
+
+	if (!(pbpctl_dev->bp_caps & SW_CTL_CAP))
+		return BP_NOT_CAP;
+
+	pbpctl_dev_b = get_status_port(pbpctl_dev);
+	if (!pbpctl_dev_b)
+		return BP_NOT_CAP;
+	send_bypass_clear_pulse(pbpctl_dev_b, 1);
+	return 0;
+}
+
+static int bypass_flag_status(struct bpctl_dev *pbpctl_dev)
+{
+	if (!(pbpctl_dev->bp_caps & SW_CTL_CAP) ||
+		(pbpctl_dev->bp_ext_ver < PXG2BPI_VER))
+		return BP_NOT_CAP;
+
+	return ((((read_reg(pbpctl_dev, STATUS_REG_ADDR)) &
+				  BYPASS_FLAG_MASK) ==
+				 BYPASS_FLAG_MASK) ? 1 : 0);
+}
+
+static int bypass_flag_status_clear(struct bpctl_dev *pbpctl_dev)
+{
+	uint32_t status_reg = 0;
+
+	if (!(pbpctl_dev->bp_caps & BP_CAP) ||
+	    (pbpctl_dev->bp_ext_ver < PXG2BPI_VER))
+		return BP_NOT_CAP;
+
+	status_reg = read_reg(pbpctl_dev, STATUS_REG_ADDR);
+	write_reg(pbpctl_dev, status_reg & ~BYPASS_FLAG_MASK,
+			  STATUS_REG_ADDR);
+	return 0;
+}
+
+static int bypass_change_status(struct bpctl_dev *pbpctl_dev)
+{
+	int ret;
+
+	if (!(pbpctl_dev->bp_caps & BP_STATUS_CHANGE_CAP))
+		return BP_NOT_CAP;
+
+	if (pbpctl_dev->bp_ext_ver >= 0x8) {
+		ret = bypass_flag_status(pbpctl_dev);
+		bypass_flag_status_clear(pbpctl_dev);
+	} else if (pbpctl_dev->bp_ext_ver >= PXG2BPI_VER) {
+		ret = bypass_flag_status(pbpctl_dev);
+		bypass_flag_status_clear(pbpctl_dev);
+	} else {
+		ret = bypass_from_last_read(pbpctl_dev);
+		bypass_status_clear(pbpctl_dev);
+	}
+	return ret;
+}
+
+static int bypass_status(struct bpctl_dev *pbpctl_dev)
+{
+	u32 ctrl_ext = 0;
+	struct bpctl_dev *pbpctl_dev_b = NULL;
+
+	if (!(pbpctl_dev->bp_caps & BP_CAP))
+		return BP_NOT_CAP;
+
+	pbpctl_dev_b = get_status_port(pbpctl_dev);
+
+	if (!pbpctl_dev_b)
+		return BP_NOT_CAP;
+
+	if (INTEL_IF_SERIES(pbpctl_dev->subdevice)) {
+		if (!pbpctl_dev->bp_status_un)
+			return (((BPCTL_READ_REG(pbpctl_dev_b, CTRL_EXT)) &
+				 BPCTLI_CTRL_EXT_SDP7_DATA) != 0 ? 1 : 0);
+			else
+				return BP_NOT_CAP;
+	}
+
+	if (pbpctl_dev->bp_ext_ver >= 0x8) {
+		switch (pbpctl_dev->nic_type) {
+		case bp_10g9:
+			ctrl_ext = BP10G_READ_REG(pbpctl_dev_b, I2CCTL);
+			BP10G_WRITE_REG(pbpctl_dev_b, I2CCTL,
+					(ctrl_ext | BP10G_I2C_CLK_OUT));
+			return ((BP10G_READ_REG(pbpctl_dev_b, I2CCTL) &
+				 BP10G_I2C_CLK_IN) != 0 ? 0 : 1);
+		case bp_540:
+			ctrl_ext = BP10G_READ_REG(pbpctl_dev_b, ESDP);
+			BP10G_WRITE_REG(pbpctl_dev_b, ESDP,
+					(ctrl_ext | BIT(11)) & ~BIT(3));
+			return (((BP10G_READ_REG(pbpctl_dev_b, ESDP)) &
+				 BP10G_SDP0_DATA) != 0 ? 0 : 1);
+		case bp_fiber5:
+		case bp_i80:
+			return (((BPCTL_READ_REG(pbpctl_dev_b, CTRL)) &
+				 BPCTLI_CTRL_SWDPIN0) != 0 ? 0 : 1);
+		case bp_10gb:
+			ctrl_ext =
+				BP10GB_READ_REG(pbpctl_dev,
+						MISC_REG_GPIO);
+			BP10GB_WRITE_REG(pbpctl_dev, MISC_REG_GPIO,
+					 (ctrl_ext | BP10GB_GPIO3_OE_P0)
+					 & ~(BP10GB_GPIO3_SET_P0 |
+						 BP10GB_GPIO3_CLR_P0));
+			return (((BP10GB_READ_REG
+				  (pbpctl_dev,
+				   MISC_REG_GPIO)) & BP10GB_GPIO3_P0) !=
+								0 ? 0 : 1);
+			break;
+		case bp_10g:
+			ctrl_ext = BP10G_READ_REG(pbpctl_dev_b, EODSDP);
+			BP10G_WRITE_REG(pbpctl_dev_b, EODSDP,
+					(ctrl_ext |
+					 BP10G_SDP7_DATA_OUT));
+			return ((BP10G_READ_REG(pbpctl_dev_b, EODSDP) &
+				 BP10G_SDP7_DATA_IN) != 0 ? 0 : 1);
+		default:
+			return (((BPCTL_READ_REG
+				  (pbpctl_dev_b,
+				   CTRL_EXT)) &
+				 BPCTLI_CTRL_EXT_SDP7_DATA) != 0 ? 0 : 1);
+		}
+	} else if (pbpctl_dev->media_type == BP_COPPER) {
+		return (((BPCTL_READ_REG(pbpctl_dev_b, CTRL)) &
+			 BPCTLI_CTRL_SWDPIN1) != 0 ? 1 : 0);
+	} else if ((bypass_status_clear(pbpctl_dev)) >= 0)
+		return bypass_from_last_read(pbpctl_dev);
+	return BP_NOT_CAP;
+}
+
+static int default_pwron_status(struct bpctl_dev *pbpctl_dev)
+{
+	if (!(pbpctl_dev->bp_caps & SW_CTL_CAP) ||
+	    !(pbpctl_dev->bp_caps & BP_PWUP_CTL_CAP) ||
+	    (pbpctl_dev->bp_ext_ver < PXG2BPI_VER))
+		return BP_NOT_CAP;
+	return ((((read_reg(pbpctl_dev, STATUS_REG_ADDR)) & DFLT_PWRON_MASK) ==
+						 DFLT_PWRON_MASK) ? 0 : 1);
+}
+
+static int default_pwroff_status(struct bpctl_dev *pbpctl_dev)
+{
+	if (!(pbpctl_dev->bp_caps & SW_CTL_CAP)
+		|| !(pbpctl_dev->bp_caps & BP_PWOFF_CTL_CAP))
+		return BP_NOT_CAP;
+
+	return ((((read_reg(pbpctl_dev, STATUS_REG_ADDR)) &
+			  DFLT_PWROFF_MASK) == DFLT_PWROFF_MASK) ? 0 : 1);
+}
+
+static int dis_bypass_cap_status(struct bpctl_dev *pbpctl_dev)
+{
+	if (!(pbpctl_dev->bp_caps & BP_DIS_CAP) ||
+	     (pbpctl_dev->bp_ext_ver < PXG2BPI_VER))
+		return BP_NOT_CAP;
+	return ((((read_reg(pbpctl_dev, STATUS_REG_ADDR)) &
+			DIS_BYPASS_CAP_MASK) == DIS_BYPASS_CAP_MASK) ? 1 : 0);
+}
+
+static int wdt_programmed(struct bpctl_dev *pbpctl_dev, int *timeout)
+{
+	int ret = 0;
+
+	if (!(pbpctl_dev->bp_caps & WD_CTL_CAP))
+		return BP_NOT_CAP;
+
+	if (pbpctl_dev->bp_ext_ver >= PXG2BPI_VER) {
+		if ((read_reg(pbpctl_dev, STATUS_REG_ADDR)) & WDT_EN_MASK) {
+			u8 wdt_val;
+
+			wdt_val = read_reg(pbpctl_dev, WDT_REG_ADDR);
+			*timeout = (1 << wdt_val) * 100;
+		} else
+			*timeout = 0;
+	} else {
+		int curr_wdt_status = pbpctl_dev->wdt_status;
+
+		if (curr_wdt_status == WDT_STATUS_UNKNOWN)
+			*timeout = -1;
+		else
+			*timeout = curr_wdt_status == 0 ?
+				   0 : pbpctl_dev->bypass_timer_interval;
+	}
+	return ret;
+}
+
+static int normal_support(struct bpctl_dev *pbpctl_dev)
+{
+	if (pbpctl_dev->bp_caps & SW_CTL_CAP)
+		return BP_NOT_CAP;
+
+	if (pbpctl_dev->bp_ext_ver < PXG2TBPI_VER)
+		return 1;
+
+	return ((((read_reg(pbpctl_dev, PRODUCT_CAP_REG_ADDR)) &
+			   NORMAL_UNSUPPORT_MASK) ==
+			  NORMAL_UNSUPPORT_MASK) ? 0 : 1);
+}
+
+static int get_bp_prod_caps(struct bpctl_dev *pbpctl_dev)
+{
+	if (!(pbpctl_dev->bp_caps & SW_CTL_CAP) ||
+		(pbpctl_dev->bp_ext_ver < PXG2TBPI_VER))
+		return BP_NOT_CAP;
+
+	return read_reg(pbpctl_dev, PRODUCT_CAP_REG_ADDR);
+}
+
+static int tap_flag_status(struct bpctl_dev *pbpctl_dev)
+{
+
+	if (!(pbpctl_dev->bp_caps & TAP_STATUS_CAP) ||
+	     (pbpctl_dev->bp_ext_ver < PXG2TBPI_VER))
+		return BP_NOT_CAP;
+	return ((((read_reg(pbpctl_dev, STATUS_TAP_REG_ADDR)) &
+				  TAP_FLAG_MASK) == TAP_FLAG_MASK) ? 1 : 0);
+}
+
+static int tap_flag_status_clear(struct bpctl_dev *pbpctl_dev)
+{
+	uint32_t status_reg = 0;
+
+	if (!(pbpctl_dev->bp_caps & TAP_STATUS_CAP) ||
+	    (pbpctl_dev->bp_ext_ver < PXG2TBPI_VER))
+		return BP_NOT_CAP;
+
+	status_reg = read_reg(pbpctl_dev, STATUS_TAP_REG_ADDR);
+	write_reg(pbpctl_dev, status_reg & ~TAP_FLAG_MASK,
+				  STATUS_TAP_REG_ADDR);
+	return 0;
+}
+
+static int tap_change_status(struct bpctl_dev *pbpctl_dev)
+{
+	int ret = BP_NOT_CAP;
+
+	if ((pbpctl_dev->bp_ext_ver < PXG2TBPI_VER) ||
+		!(pbpctl_dev->bp_caps & TAP_CAP))
+		return BP_NOT_CAP;
+
+	if (pbpctl_dev->bp_caps & BP_CAP) {
+		ret = tap_flag_status(pbpctl_dev);
+		tap_flag_status_clear(pbpctl_dev);
+	} else {
+		ret = bypass_from_last_read(pbpctl_dev);
+		bypass_status_clear(pbpctl_dev);
+	}
+	return ret;
+}
+
+static int tap_status(struct bpctl_dev *pbpctl_dev)
+{
+	u32 ctrl_ext = 0;
+	struct bpctl_dev *pbpctl_dev_b = NULL;
+
+	if (!(pbpctl_dev->bp_caps & TAP_CAP))
+		return BP_NOT_CAP;
+
+	pbpctl_dev_b = get_status_port(pbpctl_dev);
+	if (!pbpctl_dev_b)
+		return BP_NOT_CAP;
+
+	if (pbpctl_dev->bp_ext_ver >= 0x8) {
+		if (pbpctl_dev->nic_type != bp_10g9)
+			return (((BPCTL_READ_REG
+				  (pbpctl_dev_b,
+				   CTRL_EXT)) &
+				 BPCTLI_CTRL_EXT_SDP6_DATA) !=
+				0 ? 0 : 1);
+		else {
+			ctrl_ext = BP10G_READ_REG(pbpctl_dev_b, EODSDP);
+			BP10G_WRITE_REG(pbpctl_dev_b, EODSDP,
+					(ctrl_ext | BP10G_SDP6_DATA_OUT));
+			return ((BP10G_READ_REG(pbpctl_dev_b, EODSDP) &
+				 BP10G_SDP6_DATA_IN) != 0 ? 0 : 1);
+		}
+
+	} else if (pbpctl_dev->media_type == BP_COPPER) {
+		return (((BPCTL_READ_REG(pbpctl_dev, CTRL)) &
+			 BPCTLI_CTRL_SWDPIN0) != 0 ? 1 : 0);
+	} else {
+		if ((bypass_status_clear(pbpctl_dev)) >= 0)
+			return bypass_from_last_read(pbpctl_dev);
+	}
+	return BP_NOT_CAP;
+}
+
+static int default_pwron_tap_status(struct bpctl_dev *pbpctl_dev)
+{
+	if (!(pbpctl_dev->bp_caps & TAP_PWUP_CTL_CAP) ||
+	     (pbpctl_dev->bp_ext_ver < PXG2TBPI_VER))
+		return BP_NOT_CAP;
+
+	return ((((read_reg(pbpctl_dev, STATUS_TAP_REG_ADDR)) &
+				  DFLT_PWRON_TAP_MASK) ==
+				 DFLT_PWRON_TAP_MASK) ? 1 : 0);
+}
+
+static int dis_tap_cap_status(struct bpctl_dev *pbpctl_dev)
+{
+	if (!(pbpctl_dev->bp_caps & TAP_PWUP_CTL_CAP) ||
+	   (pbpctl_dev->bp_ext_ver < PXG2TBPI_VER))
+		return BP_NOT_CAP;
+
+	return ((((read_reg(pbpctl_dev, STATUS_TAP_REG_ADDR)) &
+				  DIS_TAP_CAP_MASK) ==
+				 DIS_TAP_CAP_MASK) ? 1 : 0);
+}
+
+static int disc_flag_status(struct bpctl_dev *pbpctl_dev)
+{
+	if (!(pbpctl_dev->bp_caps & DISC_CAP) ||
+	    (pbpctl_dev->bp_ext_ver < 0x8))
+		return BP_NOT_CAP;
+	return ((((read_reg(pbpctl_dev, STATUS_DISC_REG_ADDR)) &
+				  DISC_FLAG_MASK) == DISC_FLAG_MASK) ? 1 : 0);
+}
+
+static int disc_flag_status_clear(struct bpctl_dev *pbpctl_dev)
+{
+	uint32_t status_reg = 0;
+
+	if (!(pbpctl_dev->bp_caps & DISC_CAP) ||
+	    (pbpctl_dev->bp_ext_ver < 0x8))
+		return BP_NOT_CAP;
+
+	status_reg = read_reg(pbpctl_dev, STATUS_DISC_REG_ADDR);
+	write_reg(pbpctl_dev, status_reg & ~DISC_FLAG_MASK,
+				  STATUS_DISC_REG_ADDR);
+	return BP_OK;
+}
+
+static int disc_change_status(struct bpctl_dev *pbpctl_dev)
+{
+	int ret = BP_NOT_CAP;
+
+	if (!(pbpctl_dev->bp_caps & DISC_CAP))
+		return BP_NOT_CAP;
+
+	ret = disc_flag_status(pbpctl_dev);
+	disc_flag_status_clear(pbpctl_dev);
+	return ret;
+}
+
+static int disc_off_status(struct bpctl_dev *pbpctl_dev)
+{
+	struct bpctl_dev *pbpctl_dev_b = NULL;
+	u32 ctrl_ext = 0;
+
+	if (!(pbpctl_dev->bp_caps & DISC_CAP))
+		return BP_NOT_CAP;
+
+	pbpctl_dev_b = get_status_port(pbpctl_dev);
+
+	if (!pbpctl_dev_b)
+		return BP_NOT_CAP;
+
+	if (DISCF_IF_SERIES(pbpctl_dev->subdevice))
+		return ((((read_reg(pbpctl_dev, STATUS_DISC_REG_ADDR)) &
+			  DISC_OFF_MASK) == DISC_OFF_MASK) ? 1 : 0);
+
+	switch (pbpctl_dev->nic_type) {
+	case bp_i80:
+		return (((BPCTL_READ_REG(pbpctl_dev_b, CTRL_EXT)) &
+			 BPCTLI_CTRL_EXT_SDP6_DATA) != 0 ? 1 : 0);
+	case bp_540:
+		ctrl_ext = BP10G_READ_REG(pbpctl_dev_b, ESDP);
+		BP10G_WRITE_REG(pbpctl_dev_b, ESDP,
+				(ctrl_ext | BIT(11)) & ~BIT(3));
+		return ((BP10G_READ_REG(pbpctl_dev_b, ESDP) &
+			 BP10G_SDP2_DATA) != 0 ? 1 : 0);
+	default:
+		break;
+	}
+
+	if (pbpctl_dev->media_type == BP_COPPER) {
+		if (pbpctl_dev->nic_type != bp_10g)
+			return (((BPCTL_READ_REG(pbpctl_dev_b, CTRL)) &
+				 BPCTLI_CTRL_SWDPIN1) != 0 ? 1 : 0);
+		else
+			return ((BP10G_READ_REG(pbpctl_dev_b, ESDP) &
+				 BP10G_SDP1_DATA) != 0 ? 1 : 0);
+	} else {
+		switch (pbpctl_dev->nic_type) {
+		case bp_10g9:
+			ctrl_ext = BP10G_READ_REG(pbpctl_dev_b, I2CCTL);
+			BP10G_WRITE_REG(pbpctl_dev_b, I2CCTL,
+					(ctrl_ext |
+					 BP10G_I2C_DATA_OUT));
+			return ((BP10G_READ_REG(pbpctl_dev_b, I2CCTL) &
+				 BP10G_I2C_DATA_IN) != 0 ? 1 : 0);
+		case bp_fiber5:
+			return (((BPCTL_READ_REG(pbpctl_dev_b, CTRL)) &
+				 BPCTLI_CTRL_SWDPIN1) != 0 ? 1 : 0);
+		case bp_10gb:
+			ctrl_ext =
+				BP10GB_READ_REG(pbpctl_dev,
+						MISC_REG_GPIO);
+			BP10GB_WRITE_REG(pbpctl_dev, MISC_REG_GPIO,
+					 (ctrl_ext | BP10GB_GPIO3_OE_P1)
+					 & ~(BP10GB_GPIO3_SET_P1 |
+						 BP10GB_GPIO3_CLR_P1));
+
+			return (((BP10GB_READ_REG
+				  (pbpctl_dev,
+				   MISC_REG_GPIO)) & BP10GB_GPIO3_P1) !=
+				0 ? 1 : 0);
+			break;
+		case bp_10g:
+			ctrl_ext = BP10G_READ_REG(pbpctl_dev_b, EODSDP);
+			BP10G_WRITE_REG(pbpctl_dev_b, EODSDP,
+					(ctrl_ext |
+					 BP10G_SDP6_DATA_OUT));
+			return (((BP10G_READ_REG(pbpctl_dev_b, EODSDP))
+				 & BP10G_SDP6_DATA_IN) != 0 ? 1 : 0);
+		default:
+			return (((BPCTL_READ_REG(pbpctl_dev_b, CTRL_EXT)) &
+				 BPCTLI_CTRL_EXT_SDP6_DATA) !=
+				0 ? 1 : 0);
+		}
+	}
+}
+
+static int disc_status(struct bpctl_dev *pbpctl_dev)
+{
+	int ctrl = 0;
+
+	if (!(pbpctl_dev->bp_caps & DISC_CAP))
+		return BP_NOT_CAP;
+
+	ctrl = disc_off_status(pbpctl_dev);
+	if (ctrl < 0)
+		return ctrl;
+	return ((ctrl == 0) ? 1 : 0);
+}
+
+static int default_pwron_disc_status(struct bpctl_dev *pbpctl_dev)
+{
+	if (!(pbpctl_dev->bp_caps & DISC_PWUP_CTL_CAP) ||
+	    (pbpctl_dev->bp_ext_ver < 0x8))
+		return BP_NOT_CAP;
+
+	return ((((read_reg(pbpctl_dev, STATUS_DISC_REG_ADDR)) &
+				  DFLT_PWRON_DISC_MASK) ==
+				 DFLT_PWRON_DISC_MASK) ? 1 : 0);
+}
+
+static int dis_disc_cap_status(struct bpctl_dev *pbpctl_dev)
+{
+	if (!(pbpctl_dev->bp_caps & DISC_PWUP_CTL_CAP) ||
+	    (pbpctl_dev->bp_ext_ver < 0x8))
+		return BP_NOT_CAP;
+
+	return ((((read_reg(pbpctl_dev, STATUS_DISC_REG_ADDR)) &
+				  DIS_DISC_CAP_MASK) ==
+				 DIS_DISC_CAP_MASK) ? 1 : 0);
+}
+
+static int wdt_exp_mode_status(struct bpctl_dev *pbpctl_dev)
+{
+	if (!(pbpctl_dev->bp_caps & WD_CTL_CAP))
+		return BP_NOT_CAP;
+
+	if (pbpctl_dev->bp_ext_ver <= PXG2BPI_VER)
+		return 0;       /* bypass mode */
+	else if (pbpctl_dev->bp_ext_ver == PXG2TBPI_VER)
+		return 1;       /* tap mode */
+	else if (pbpctl_dev->bp_ext_ver >= PXE2TBPI_VER) {
+		if ((pbpctl_dev->bp_ext_ver >= 0x8) &&
+		    (((read_reg(pbpctl_dev, STATUS_DISC_REG_ADDR)) &
+		      WDTE_DISC_BPN_MASK) == WDTE_DISC_BPN_MASK))
+			return 2;
+		return ((((read_reg(pbpctl_dev, STATUS_TAP_REG_ADDR)) &
+			  WDTE_TAP_BPN_MASK) ==
+			 WDTE_TAP_BPN_MASK) ? 1 : 0);
+	}
+	return BP_NOT_CAP;
+}
+
+static int tpl2_flag_status(struct bpctl_dev *pbpctl_dev)
+{
+	if (!(pbpctl_dev->bp_caps_ex & TPL2_CAP_EX))
+		return BP_NOT_CAP;
+
+	return ((((read_reg(pbpctl_dev, STATUS_DISC_REG_ADDR)) &
+			  TPL2_FLAG_MASK) == TPL2_FLAG_MASK) ? 1 : 0);
+}
+
+static int bp_wait_at_pwup_status(struct bpctl_dev *pbpctl_dev)
+{
+	if (!(pbpctl_dev->bp_caps & SW_CTL_CAP) ||
+	    (pbpctl_dev->bp_ext_ver < 0x8))
+		return BP_NOT_CAP;
+
+	return ((((read_reg(pbpctl_dev, CONT_CONFIG_REG_ADDR)) &
+				  WAIT_AT_PWUP_MASK) ==
+				 WAIT_AT_PWUP_MASK) ? 1 : 0);
+}
+
+static int bp_hw_reset_status(struct bpctl_dev *pbpctl_dev)
+{
+	if (!(pbpctl_dev->bp_caps & SW_CTL_CAP) ||
+	    (pbpctl_dev->bp_ext_ver < 0x8))
+		return BP_NOT_CAP;
+
+	return ((((read_reg(pbpctl_dev, CONT_CONFIG_REG_ADDR)) &
+				  EN_HW_RESET_MASK) ==
+				 EN_HW_RESET_MASK) ? 1 : 0);
+}
+
+
+static int std_nic_status(struct bpctl_dev *pbpctl_dev)
+{
+	int status_val = BP_NOT_CAP;
+
+	if (!(pbpctl_dev->bp_caps & STD_NIC_CAP) ||
+	    INTEL_IF_SERIES(pbpctl_dev->subdevice))
+		return BP_NOT_CAP;
+
+	if (pbpctl_dev->bp_ext_ver >= BP_FW_EXT_VER8) {
+		return ((((read_reg(pbpctl_dev, STATUS_DISC_REG_ADDR)) &
+			  STD_NIC_ON_MASK) == STD_NIC_ON_MASK) ? 1 : 0);
+	}
+
+	if (pbpctl_dev->bp_ext_ver < PXG2BPI_VER)
+		return BP_NOT_CAP;
+
+	if (pbpctl_dev->bp_caps & BP_CAP) {
+		status_val =
+			read_reg(pbpctl_dev, STATUS_REG_ADDR);
+		if (((!(status_val & WDT_EN_MASK))
+			 && ((status_val & STD_NIC_MASK) ==
+			 STD_NIC_MASK)))
+			status_val = 1;
+		else
+			return 0;
+	}
+	if (pbpctl_dev->bp_caps & TAP_CAP) {
+		status_val = read_reg(pbpctl_dev, STATUS_TAP_REG_ADDR);
+		if ((status_val & STD_NIC_TAP_MASK) ==
+			STD_NIC_TAP_MASK)
+			status_val = 1;
+		else
+			return 0;
+	}
+	if (pbpctl_dev->bp_caps & DISC_CAP) {
+		if ((disc_off_status(pbpctl_dev)))
+			status_val = 1;
+		else
+			return 0;
+	}
+
+	return status_val;
+}
+
+/******************************************************/
+/**************SW_INIT*********************************/
+/******************************************************/
+static void bypass_caps_init(struct bpctl_dev *pbpctl_dev)
+{
+	u_int32_t ctrl_ext = 0;
+	struct bpctl_dev *pbpctl_dev_m = NULL;
+	int cap_reg;
+
+	switch (pbpctl_dev->nic_type) {
+	case bp_fiber5:
+	case bp_10g9:
+		pbpctl_dev->media_type = BP_FIBER;
+		break;
+	case bp_10gb:
+		if (BP10GB_CX4_SERIES(pbpctl_dev->subdevice))
+			pbpctl_dev->media_type = BP_CX4;
+		else
+			pbpctl_dev->media_type = BP_FIBER;
+		break;
+	case bp_540:
+		pbpctl_dev->media_type = BP_NONE;
+		break;
+	case bp_10g:
+		if (BP10G_CX4_SERIES(pbpctl_dev->subdevice))
+			pbpctl_dev->media_type = BP_CX4;
+		else
+			pbpctl_dev->media_type = BP_FIBER;
+		break;
+	default:
+		ctrl_ext = BPCTL_READ_REG(pbpctl_dev, CTRL_EXT);
+		if ((ctrl_ext & BPCTLI_CTRL_EXT_LINK_MODE_MASK) == 0x0)
+			pbpctl_dev->media_type = BP_COPPER;
+		else
+			pbpctl_dev->media_type = BP_FIBER;
+		break;
+	}
+
+	if (is_bypass(pbpctl_dev)) {
+		pbpctl_dev->bp_caps |= BP_PWOFF_ON_CAP;
+		if (pbpctl_dev->media_type == BP_FIBER)
+			pbpctl_dev->bp_caps |=
+				(TX_CTL_CAP | TX_STATUS_CAP | TPL_CAP);
+
+		if (TPL_IF_SERIES(pbpctl_dev->subdevice))
+			pbpctl_dev->bp_caps |= TPL_CAP;
+
+		if ((pbpctl_dev->subdevice & 0xfe0) == 0xb40)
+			pbpctl_dev->bp_caps &= ~TPL_CAP;
+		if (pbpctl_dev->nic_type == bp_10g9)
+			pbpctl_dev->bp_caps &= ~TPL_CAP;
+
+		if (INTEL_IF_SERIES(pbpctl_dev->subdevice)) {
+			pbpctl_dev->bp_caps |=
+				(BP_CAP | BP_STATUS_CAP |
+				 SW_CTL_CAP | BP_PWUP_ON_CAP |
+				 BP_PWUP_OFF_CAP | BP_PWOFF_OFF_CAP |
+				 WD_CTL_CAP | WD_STATUS_CAP |
+				 STD_NIC_CAP | WD_TIMEOUT_CAP);
+
+			pbpctl_dev->bp_ext_ver = OLD_IF_VER;
+			return;
+		}
+
+		if ((pbpctl_dev->bp_fw_ver == 0xff) &&
+			OLD_IF_SERIES(pbpctl_dev->subdevice)) {
+			pbpctl_dev->bp_caps |=
+				(BP_CAP | BP_STATUS_CAP | BP_STATUS_CHANGE_CAP |
+				 SW_CTL_CAP | BP_PWUP_ON_CAP | WD_CTL_CAP |
+				 WD_STATUS_CAP | WD_TIMEOUT_CAP);
+
+			pbpctl_dev->bp_ext_ver = OLD_IF_VER;
+			return;
+		}
+		switch (pbpctl_dev->bp_fw_ver) {
+		case BP_FW_VER_A0:
+		case BP_FW_VER_A1:
+			pbpctl_dev->bp_ext_ver =
+					(pbpctl_dev->bp_fw_ver & EXT_VER_MASK);
+			break;
+		default:
+			if ((bypass_sign_check(pbpctl_dev)) != 1) {
+				pbpctl_dev->bp_caps = 0;
+				return;
+			}
+			pbpctl_dev->bp_ext_ver = (pbpctl_dev->bp_fw_ver
+						  & EXT_VER_MASK);
+			break;
+		}
+
+		if (pbpctl_dev->bp_ext_ver >= 0x9)
+			pbpctl_dev->bp_caps &= ~TPL_CAP;
+
+		if (pbpctl_dev->bp_ext_ver == PXG2BPI_VER)
+			pbpctl_dev->bp_caps |=
+				(BP_CAP | BP_STATUS_CAP |
+				 BP_STATUS_CHANGE_CAP | SW_CTL_CAP |
+				 BP_DIS_CAP | BP_DIS_STATUS_CAP |
+				 BP_PWUP_ON_CAP | BP_PWUP_OFF_CAP |
+				 BP_PWUP_CTL_CAP | WD_CTL_CAP |
+				 STD_NIC_CAP | WD_STATUS_CAP |
+				 WD_TIMEOUT_CAP);
+		else if (pbpctl_dev->bp_ext_ver >= PXG2TBPI_VER) {
+			pbpctl_dev->bp_caps |=
+				(SW_CTL_CAP | WD_CTL_CAP | WD_STATUS_CAP |
+				 WD_TIMEOUT_CAP);
+			cap_reg = get_bp_prod_caps(pbpctl_dev);
+
+			if ((cap_reg & NORMAL_UNSUPPORT_MASK) ==
+				NORMAL_UNSUPPORT_MASK)
+				pbpctl_dev->bp_caps |= NIC_CAP_NEG;
+			else
+				pbpctl_dev->bp_caps |= STD_NIC_CAP;
+
+			if ((normal_support(pbpctl_dev)) == 1)
+
+				pbpctl_dev->bp_caps |= STD_NIC_CAP;
+
+			else
+				pbpctl_dev->bp_caps |= NIC_CAP_NEG;
+			if ((cap_reg & BYPASS_SUPPORT_MASK) ==
+				BYPASS_SUPPORT_MASK) {
+				pbpctl_dev->bp_caps |=
+					(BP_CAP | BP_STATUS_CAP |
+					 BP_STATUS_CHANGE_CAP | BP_DIS_CAP |
+					 BP_DIS_STATUS_CAP | BP_PWUP_ON_CAP |
+					 BP_PWUP_OFF_CAP | BP_PWUP_CTL_CAP);
+				if (pbpctl_dev->bp_ext_ver >= BP_FW_EXT_VER7)
+					pbpctl_dev->bp_caps |=
+						BP_PWOFF_ON_CAP |
+						BP_PWOFF_OFF_CAP |
+						BP_PWOFF_CTL_CAP;
+			}
+			if ((cap_reg & TAP_SUPPORT_MASK) == TAP_SUPPORT_MASK) {
+				pbpctl_dev->bp_caps |=
+					(TAP_CAP | TAP_STATUS_CAP |
+					 TAP_STATUS_CHANGE_CAP | TAP_DIS_CAP |
+					 TAP_DIS_STATUS_CAP | TAP_PWUP_ON_CAP |
+					 TAP_PWUP_OFF_CAP | TAP_PWUP_CTL_CAP);
+			}
+			if (pbpctl_dev->bp_ext_ver >= BP_FW_EXT_VER8) {
+				if ((cap_reg & DISC_SUPPORT_MASK) ==
+					DISC_SUPPORT_MASK)
+					pbpctl_dev->bp_caps |=
+						(DISC_CAP | DISC_DIS_CAP |
+						 DISC_PWUP_CTL_CAP);
+				if ((cap_reg & TPL2_SUPPORT_MASK) ==
+					TPL2_SUPPORT_MASK) {
+					pbpctl_dev->bp_caps_ex |= TPL2_CAP_EX;
+					pbpctl_dev->bp_caps |= TPL_CAP;
+					pbpctl_dev->bp_tpl_flag =
+						tpl2_flag_status(pbpctl_dev);
+				}
+
+			}
+
+			if (pbpctl_dev->bp_ext_ver >= BP_FW_EXT_VER9) {
+				if ((cap_reg & DISC_PORT_SUPPORT_MASK) ==
+					DISC_PORT_SUPPORT_MASK) {
+					pbpctl_dev->bp_caps_ex |=
+						DISC_PORT_CAP_EX;
+					pbpctl_dev->bp_caps |=
+						(TX_CTL_CAP | TX_STATUS_CAP);
+				}
+
+			}
+
+		}
+		if (pbpctl_dev->bp_ext_ver >= PXG2BPI_VER) {
+			if ((read_reg(pbpctl_dev, STATUS_REG_ADDR)) &
+				WDT_EN_MASK)
+				pbpctl_dev->wdt_status = WDT_STATUS_EN;
+			else
+				pbpctl_dev->wdt_status = WDT_STATUS_DIS;
+		}
+
+	} else if ((P2BPFI_IF_SERIES(pbpctl_dev->subdevice)) ||
+		   (PEGF5_IF_SERIES(pbpctl_dev->subdevice)) ||
+		   (PEGF80_IF_SERIES(pbpctl_dev->subdevice)) ||
+		   (BP10G9_IF_SERIES(pbpctl_dev->subdevice))) {
+		pbpctl_dev->bp_caps |= (TX_CTL_CAP | TX_STATUS_CAP);
+	}
+	if ((pbpctl_dev->subdevice & 0xfe0) == 0xaa0)
+		pbpctl_dev->bp_caps |= (TX_CTL_CAP | TX_STATUS_CAP);
+	if (PEG5_IF_SERIES(pbpctl_dev->subdevice))
+		pbpctl_dev->bp_caps |= (TX_CTL_CAP | TX_STATUS_CAP);
+
+	if (BP10GB_IF_SERIES(pbpctl_dev->subdevice))
+		pbpctl_dev->bp_caps &= ~(TX_CTL_CAP | TX_STATUS_CAP);
+
+	if (pbpctl_dev->nic_type == bp_fiber5)
+		pbpctl_dev->bp_caps |= (TX_CTL_CAP | TX_STATUS_CAP);
+
+	pbpctl_dev_m = get_master_port(pbpctl_dev);
+	if ((pbpctl_dev_m != NULL) &&
+	    (pbpctl_dev_m->bp_ext_ver >= 0x9)) {
+		cap_reg = get_bp_prod_caps(pbpctl_dev_m);
+		if ((cap_reg & DISC_PORT_SUPPORT_MASK) ==
+			DISC_PORT_SUPPORT_MASK)
+			pbpctl_dev->bp_caps |= (TX_CTL_CAP | TX_STATUS_CAP);
+		pbpctl_dev->bp_caps_ex |= DISC_PORT_CAP_EX;
+	}
+}
+
+static void remove_bypass_wd_auto(struct bpctl_dev *pbpctl_dev)
+{
+	if (pbpctl_dev->bp_caps & WD_CTL_CAP)
+		del_timer_sync(&pbpctl_dev->bp_timer);
+}
+
+static int init_bypass_wd_auto(struct bpctl_dev *pbpctl_dev)
+{
+	if (!(pbpctl_dev->bp_caps & WD_CTL_CAP))
+		return BP_NOT_CAP;
+
+	init_timer(&pbpctl_dev->bp_timer);
+	pbpctl_dev->bp_timer.function = &wd_reset_timer;
+	pbpctl_dev->bp_timer.data = (unsigned long)pbpctl_dev;
+	return 1;
+}
+
+static int set_bypass_wd_auto(struct bpctl_dev *pbpctl_dev, unsigned int param)
+{
+	if (!(pbpctl_dev->bp_caps & WD_CTL_CAP))
+		return BP_NOT_CAP;
+	if (pbpctl_dev->reset_time != param) {
+		if (INTEL_IF_SERIES(pbpctl_dev->subdevice))
+			pbpctl_dev->reset_time = (param < WDT_AUTO_MIN_INT) ?
+						 WDT_AUTO_MIN_INT : param;
+		else
+			pbpctl_dev->reset_time = param;
+		if (param)
+			mod_timer(&pbpctl_dev->bp_timer, jiffies);
+	}
+	return 0;
+}
+
+static int get_bypass_wd_auto(struct bpctl_dev *pbpctl_dev)
+{
+	if (pbpctl_dev->bp_caps & WD_CTL_CAP)
+		return pbpctl_dev->reset_time;
+
+	return BP_NOT_CAP;
+}
+
+
+/**************************************************************/
+/************************* API ********************************/
+/**************************************************************/
+
+static int is_bypass_fn(struct bpctl_dev *pbpctl_dev)
+{
+	if (!pbpctl_dev)
+		return -1;
+
+	return is_bypass(pbpctl_dev);
+}
+
+static int set_bypass_fn(struct bpctl_dev *pbpctl_dev, int bypass_mode)
+{
+	int ret = 0;
+
+	if (!pbpctl_dev)
+		return  -1;
+
+	if (!(pbpctl_dev->bp_caps & BP_CAP))
+		return  -1;
+
+	ret = cmnd_on(pbpctl_dev);
+	if (ret < 0)
+		return ret;
+	if (!bypass_mode)
+		ret = bypass_off(pbpctl_dev);
+	else
+		ret = bypass_on(pbpctl_dev);
+	cmnd_off(pbpctl_dev);
+
+	return ret;
+}
+
+static int get_bypass_fn(struct bpctl_dev *pbpctl_dev)
+{
+	if (!pbpctl_dev)
+		return  -1;
+
+	return bypass_status(pbpctl_dev);
+}
+
+static int get_bypass_change_fn(struct bpctl_dev *pbpctl_dev)
+{
+	if (!pbpctl_dev)
+		return  -1;
+
+	return bypass_change_status(pbpctl_dev);
+}
+
+static int set_dis_bypass_fn(struct bpctl_dev *pbpctl_dev, int dis_param)
+{
+	int ret = 0;
+
+	if (!pbpctl_dev)
+		return  -1;
+
+	if (!(pbpctl_dev->bp_caps & BP_DIS_CAP))
+		return  -1;
+	ret = cmnd_on(pbpctl_dev);
+	if (ret < 0)
+		return ret;
+	if (dis_param)
+		ret = dis_bypass_cap(pbpctl_dev);
+	else
+		ret = en_bypass_cap(pbpctl_dev);
+	cmnd_off(pbpctl_dev);
+	return ret;
+}
+
+static int get_dis_bypass_fn(struct bpctl_dev *pbpctl_dev)
+{
+	if (!pbpctl_dev)
+		return  -1;
+
+	return dis_bypass_cap_status(pbpctl_dev);
+}
+
+static int set_bypass_pwoff_fn(struct bpctl_dev *pbpctl_dev, int bypass_mode)
+{
+	int ret = 0;
+
+	if (!pbpctl_dev)
+		return  -1;
+
+	if (!(pbpctl_dev->bp_caps & BP_PWOFF_CTL_CAP))
+		return  -1;
+	ret = cmnd_on(pbpctl_dev);
+	if (ret < 0)
+		return ret;
+	if (bypass_mode)
+		ret = bypass_state_pwroff(pbpctl_dev);
+	else
+		ret = normal_state_pwroff(pbpctl_dev);
+	cmnd_off(pbpctl_dev);
+	return ret;
+}
+
+static int get_bypass_pwoff_fn(struct bpctl_dev *pbpctl_dev)
+{
+	if (!pbpctl_dev)
+		return  -1;
+
+	return default_pwroff_status(pbpctl_dev);
+}
+
+static int set_bypass_pwup_fn(struct bpctl_dev *pbpctl_dev, int bypass_mode)
+{
+	int ret = 0;
+
+	if (!pbpctl_dev)
+		return  -1;
+
+	if (!(pbpctl_dev->bp_caps & BP_PWUP_CTL_CAP))
+		return  -1;
+	ret = cmnd_on(pbpctl_dev);
+	if (ret < 0)
+		return ret;
+	if (bypass_mode)
+		ret = bypass_state_pwron(pbpctl_dev);
+	else
+		ret = normal_state_pwron(pbpctl_dev);
+	cmnd_off(pbpctl_dev);
+	return ret;
+}
+
+static int get_bypass_pwup_fn(struct bpctl_dev *pbpctl_dev)
+{
+	if (!pbpctl_dev)
+		return  -1;
+
+	return default_pwron_status(pbpctl_dev);
+}
+
+static int set_bypass_wd_fn(struct bpctl_dev *pbpctl_dev, int timeout)
+{
+	int ret = 0;
+
+	if (!pbpctl_dev)
+		return  -1;
+
+	if (!(pbpctl_dev->bp_caps & WD_CTL_CAP))
+		return  -1;
+
+	ret = cmnd_on(pbpctl_dev);
+	if (ret < 0)
+		return ret;
+	if (!timeout)
+		ret = wdt_off(pbpctl_dev);
+	else {
+		wdt_on(pbpctl_dev, timeout);
+		ret = pbpctl_dev->bypass_timer_interval;
+	}
+	cmnd_off(pbpctl_dev);
+	return ret;
+}
+
+static int get_bypass_wd_fn(struct bpctl_dev *pbpctl_dev, int *timeout)
+{
+	if (!pbpctl_dev)
+		return  -1;
+
+	return wdt_programmed(pbpctl_dev, timeout);
+}
+
+static int get_wd_expire_time_fn(struct bpctl_dev *pbpctl_dev, int *time_left)
+{
+	if (!pbpctl_dev)
+		return  -1;
+
+	return wdt_timer(pbpctl_dev, time_left);
+}
+
+static int reset_bypass_wd_timer_fn(struct bpctl_dev *pbpctl_dev)
+{
+	if (!pbpctl_dev)
+		return  -1;
+
+	return wdt_timer_reload(pbpctl_dev);
+}
+
+static int get_wd_set_caps_fn(struct bpctl_dev *pbpctl_dev)
+{
+	int bp_status = 0;
+	unsigned int step_value = TIMEOUT_MAX_STEP + 1, bit_cnt = 0;
+
+	if (!pbpctl_dev)
+		return  -1;
+
+	if (INTEL_IF_SERIES(pbpctl_dev->subdevice))
+		return  -1;
+
+	while ((step_value >>= 1))
+		bit_cnt++;
+
+	if (is_bypass(pbpctl_dev)) {
+		bp_status =
+			WD_STEP_COUNT_MASK(bit_cnt) | WDT_STEP_TIME |
+			WD_MIN_TIME_MASK(TIMEOUT_UNIT / 100);
+	} else
+		return  -1;
+
+	return bp_status;
+}
+
+static int set_std_nic_fn(struct bpctl_dev *pbpctl_dev, int nic_mode)
+{
+	int ret = 0;
+
+	if (!pbpctl_dev)
+		return  -1;
+
+	if (!(pbpctl_dev->bp_caps & STD_NIC_CAP))
+		return  -1;
+
+	ret = cmnd_on(pbpctl_dev);
+	if (ret < 0)
+		return ret;
+	if (nic_mode)
+		ret = std_nic_on(pbpctl_dev);
+	else
+		ret = std_nic_off(pbpctl_dev);
+	cmnd_off(pbpctl_dev);
+	return ret;
+}
+
+static int get_std_nic_fn(struct bpctl_dev *pbpctl_dev)
+{
+	if (!pbpctl_dev)
+		return  -1;
+
+	return std_nic_status(pbpctl_dev);
+}
+
+static int set_tap_fn(struct bpctl_dev *pbpctl_dev, int tap_mode)
+{
+	if (!pbpctl_dev)
+		return  -1;
+
+	if ((pbpctl_dev->bp_caps & TAP_CAP) && ((cmnd_on(pbpctl_dev)) >= 0)) {
+		if (!tap_mode)
+			tap_off(pbpctl_dev);
+		else
+			tap_on(pbpctl_dev);
+		cmnd_off(pbpctl_dev);
+		return 0;
+	}
+	return  -1;
+}
+
+static int get_tap_fn(struct bpctl_dev *pbpctl_dev)
+{
+	if (!pbpctl_dev)
+		return  -1;
+
+	return tap_status(pbpctl_dev);
+}
+
+static int set_tap_pwup_fn(struct bpctl_dev *pbpctl_dev, int tap_mode)
+{
+	int ret = 0;
+
+	if (!pbpctl_dev)
+		return  -1;
+
+	if ((pbpctl_dev->bp_caps & TAP_PWUP_CTL_CAP)
+		&& ((cmnd_on(pbpctl_dev)) >= 0)) {
+		if (tap_mode)
+			ret = tap_state_pwron(pbpctl_dev);
+		else
+			ret = normal_state_pwron(pbpctl_dev);
+		cmnd_off(pbpctl_dev);
+	} else
+		ret = BP_NOT_CAP;
+	return ret;
+}
+
+static int get_tap_pwup_fn(struct bpctl_dev *pbpctl_dev)
+{
+	int ret = 0;
+
+	if (!pbpctl_dev)
+		return  -1;
+
+	ret = default_pwron_tap_status(pbpctl_dev);
+	if (ret < 0)
+		return ret;
+	return ((ret == 0) ? 1 : 0);
+}
+
+static int get_tap_change_fn(struct bpctl_dev *pbpctl_dev)
+{
+	if (!pbpctl_dev)
+		return  -1;
+
+	return tap_change_status(pbpctl_dev);
+}
+
+static int set_dis_tap_fn(struct bpctl_dev *pbpctl_dev, int dis_param)
+{
+	int ret = 0;
+
+	if (!pbpctl_dev)
+		return  -1;
+
+	if ((pbpctl_dev->bp_caps & TAP_DIS_CAP) &&
+		((cmnd_on(pbpctl_dev)) >= 0)) {
+		if (dis_param)
+			ret = dis_tap_cap(pbpctl_dev);
+		else
+			ret = en_tap_cap(pbpctl_dev);
+		cmnd_off(pbpctl_dev);
+		return ret;
+	}
+	return -1;
+}
+
+static int get_dis_tap_fn(struct bpctl_dev *pbpctl_dev)
+{
+	if (!pbpctl_dev)
+		return  -1;
+
+	return dis_tap_cap_status(pbpctl_dev);
+}
+
+static int set_disc_fn(struct bpctl_dev *pbpctl_dev, int disc_mode)
+{
+	if (!pbpctl_dev)
+		return  -1;
+
+	if ((pbpctl_dev->bp_caps & DISC_CAP) && ((cmnd_on(pbpctl_dev)) >= 0)) {
+		if (!disc_mode)
+			disc_off(pbpctl_dev);
+		else
+			disc_on(pbpctl_dev);
+		cmnd_off(pbpctl_dev);
+
+		return BP_OK;
+	}
+	return  -1;
+}
+
+static int get_disc_fn(struct bpctl_dev *pbpctl_dev)
+{
+	int ret = 0;
+
+	if (!pbpctl_dev)
+		return  -1;
+
+	ret = disc_status(pbpctl_dev);
+
+	return ret;
+}
+
+static int set_disc_pwup_fn(struct bpctl_dev *pbpctl_dev, int disc_mode)
+{
+	int ret = 0;
+
+	if (!pbpctl_dev)
+		return  -1;
+
+	if ((pbpctl_dev->bp_caps & DISC_PWUP_CTL_CAP)
+		&& ((cmnd_on(pbpctl_dev)) >= 0)) {
+		if (disc_mode)
+			ret = disc_state_pwron(pbpctl_dev);
+		else
+			ret = normal_state_pwron(pbpctl_dev);
+		cmnd_off(pbpctl_dev);
+	} else
+		ret = BP_NOT_CAP;
+	return ret;
+}
+
+static int get_disc_pwup_fn(struct bpctl_dev *pbpctl_dev)
+{
+	int ret = 0;
+
+	if (!pbpctl_dev)
+		return  -1;
+
+	ret = default_pwron_disc_status(pbpctl_dev);
+	return (ret == 0 ? 1 : (ret < 0 ? BP_NOT_CAP : 0));
+}
+
+static int get_disc_change_fn(struct bpctl_dev *pbpctl_dev)
+{
+	int ret = 0;
+
+	if (!pbpctl_dev)
+		return  -1;
+
+	ret = disc_change_status(pbpctl_dev);
+	return ret;
+}
+
+static int set_dis_disc_fn(struct bpctl_dev *pbpctl_dev, int dis_param)
+{
+	int ret = 0;
+
+	if (!pbpctl_dev)
+		return  -1;
+
+	if ((pbpctl_dev->bp_caps & DISC_DIS_CAP)
+		&& ((cmnd_on(pbpctl_dev)) >= 0)) {
+		if (dis_param)
+			ret = dis_disc_cap(pbpctl_dev);
+		else
+			ret = en_disc_cap(pbpctl_dev);
+		cmnd_off(pbpctl_dev);
+		return ret;
+	}
+	return -1;
+}
+
+static int get_dis_disc_fn(struct bpctl_dev *pbpctl_dev)
+{
+	int ret = 0;
+
+	if (!pbpctl_dev)
+		return  -1;
+
+	ret = dis_disc_cap_status(pbpctl_dev);
+
+	return ret;
+}
+
+static int get_wd_exp_mode_fn(struct bpctl_dev *pbpctl_dev)
+{
+	if (!pbpctl_dev)
+		return  -1;
+
+	return wdt_exp_mode_status(pbpctl_dev);
+}
+
+static int set_wd_exp_mode_fn(struct bpctl_dev *pbpctl_dev, int param)
+{
+	if (!pbpctl_dev)
+		return  -1;
+
+	return wdt_exp_mode(pbpctl_dev, param);
+}
+
+static int set_tx_fn(struct bpctl_dev *pbpctl_dev, int tx_state)
+{
+	struct bpctl_dev *pbpctl_dev_b = NULL;
+
+	if (!pbpctl_dev)
+		return  -1;
+
+	if ((pbpctl_dev->bp_caps & TPL_CAP) &&
+		(pbpctl_dev->bp_caps & SW_CTL_CAP)) {
+		if ((pbpctl_dev->bp_tpl_flag))
+			return  -1;
+	} else {
+		pbpctl_dev_b = get_master_port(pbpctl_dev);
+		if (pbpctl_dev_b &&
+			(pbpctl_dev_b->bp_caps & TPL_CAP) &&
+			(pbpctl_dev_b->bp_tpl_flag))
+			return  -1;
+	}
+	return set_tx(pbpctl_dev, tx_state);
+}
+
+static int set_bp_force_link_fn(int dev_num, int tx_state)
+{
+	static struct bpctl_dev *bpctl_dev_curr;
+
+	if ((dev_num < 0) || (dev_num > device_num)
+		|| (bpctl_dev_arr[dev_num].pdev == NULL))
+		return  -1;
+	bpctl_dev_curr = &bpctl_dev_arr[dev_num];
+
+	return set_bp_force_link(bpctl_dev_curr, tx_state);
+}
+
+static int set_wd_autoreset_fn(struct bpctl_dev *pbpctl_dev, int param)
+{
+	if (!pbpctl_dev)
+		return  -1;
+
+	return set_bypass_wd_auto(pbpctl_dev, param);
+}
+
+static int get_wd_autoreset_fn(struct bpctl_dev *pbpctl_dev)
+{
+	if (!pbpctl_dev)
+		return  -1;
+
+	return get_bypass_wd_auto(pbpctl_dev);
+}
+
+static int get_bypass_caps_fn(struct bpctl_dev *pbpctl_dev)
+{
+	if (!pbpctl_dev)
+		return  -1;
+
+	return pbpctl_dev->bp_caps;
+}
+
+static int get_bypass_slave_fn(struct bpctl_dev *pbpctl_dev,
+				   struct bpctl_dev **pbpctl_dev_out)
+{
+	int idx_dev = 0;
+
+	if (!pbpctl_dev)
+		return  -1;
+
+	if ((pbpctl_dev->func != 0) || (pbpctl_dev->func != 2))
+		return 0;
+
+	for (idx_dev = 0;
+		 ((bpctl_dev_arr[idx_dev].pdev != NULL)
+		  && (idx_dev < device_num)); idx_dev++) {
+		if ((bpctl_dev_arr[idx_dev].bus == pbpctl_dev->bus)
+			&& (bpctl_dev_arr[idx_dev].slot ==
+			pbpctl_dev->slot)) {
+			if ((pbpctl_dev->func == 0)
+				&& (bpctl_dev_arr[idx_dev].func == 1)) {
+				*pbpctl_dev_out =
+					&bpctl_dev_arr[idx_dev];
+				return 1;
+			}
+			if ((pbpctl_dev->func == 2) &&
+				(bpctl_dev_arr[idx_dev].func == 3)) {
+				*pbpctl_dev_out =
+					&bpctl_dev_arr[idx_dev];
+				return 1;
+			}
+		}
+	}
+	return  -1;
+}
+
+static int get_tx_fn(struct bpctl_dev *pbpctl_dev)
+{
+	struct bpctl_dev *pbpctl_dev_b = NULL;
+
+	if (!pbpctl_dev)
+		return  -1;
+
+	if ((pbpctl_dev->bp_caps & TPL_CAP) &&
+		(pbpctl_dev->bp_caps & SW_CTL_CAP)) {
+		if ((pbpctl_dev->bp_tpl_flag))
+			return  -1;
+	} else {
+		pbpctl_dev_b = get_master_port(pbpctl_dev);
+		if (pbpctl_dev_b &&
+			(pbpctl_dev_b->bp_caps & TPL_CAP) &&
+			(pbpctl_dev_b->bp_tpl_flag))
+			return  -1;
+	}
+	return tx_status(pbpctl_dev);
+}
+
+static int get_bp_force_link_fn(int dev_num)
+{
+	static struct bpctl_dev *bpctl_dev_curr;
+
+	if ((dev_num < 0) || (dev_num > device_num)
+		|| (bpctl_dev_arr[dev_num].pdev == NULL))
+		return  -1;
+	bpctl_dev_curr = &bpctl_dev_arr[dev_num];
+
+	return bp_force_link_status(bpctl_dev_curr);
+}
+
+static int get_bypass_link_status(struct bpctl_dev *pbpctl_dev)
+{
+	if (!pbpctl_dev)
+		return  -1;
+
+	if (pbpctl_dev->media_type == BP_FIBER)
+		return ((BPCTL_READ_REG(pbpctl_dev, CTRL) &
+			 BPCTLI_CTRL_SWDPIN1));
+	else
+		return ((BPCTL_READ_REG(pbpctl_dev, STATUS) &
+			 BPCTLI_STATUS_LU));
+}
+
+static void bp_tpl_timer_fn(unsigned long param)
+{
+	struct bpctl_dev *pbpctl_dev = (struct bpctl_dev *) param;
+	uint32_t link1, link2;
+	struct bpctl_dev *pbpctl_dev_b = NULL;
+
+	pbpctl_dev_b = get_status_port(pbpctl_dev);
+	if (!pbpctl_dev_b)
+		return;
+
+	if (!pbpctl_dev->bp_tpl_flag) {
+		set_tx(pbpctl_dev_b, 1);
+		set_tx(pbpctl_dev, 1);
+		return;
+	}
+	link1 = get_bypass_link_status(pbpctl_dev);
+
+	link2 = get_bypass_link_status(pbpctl_dev_b);
+	if ((link1) && (tx_status(pbpctl_dev))) {
+		if ((!link2) && (tx_status(pbpctl_dev_b)))
+			set_tx(pbpctl_dev, 0);
+		else if (!tx_status(pbpctl_dev_b))
+			set_tx(pbpctl_dev_b, 1);
+	} else if ((!link1) && (tx_status(pbpctl_dev))) {
+		if ((link2) && (tx_status(pbpctl_dev_b)))
+			set_tx(pbpctl_dev_b, 0);
+	} else if ((link1) && (!tx_status(pbpctl_dev))) {
+		if ((link2) && (tx_status(pbpctl_dev_b)))
+			set_tx(pbpctl_dev, 1);
+	} else if ((!link1) && (!tx_status(pbpctl_dev))) {
+		if ((link2) && (tx_status(pbpctl_dev_b)))
+			set_tx(pbpctl_dev, 1);
+	}
+
+	mod_timer(&pbpctl_dev->bp_tpl_timer, jiffies + BP_LINK_MON_DELAY * HZ);
+}
+
+static int get_tpl_fn(struct bpctl_dev *pbpctl_dev)
+{
+	int ret = BP_NOT_CAP;
+
+	if (!pbpctl_dev)
+		return  -1;
+	if (!(pbpctl_dev->bp_caps & TPL_CAP))
+		return  -1;
+
+	if (pbpctl_dev->bp_caps_ex & TPL2_CAP_EX)
+		return tpl2_flag_status(pbpctl_dev);
+	ret = pbpctl_dev->bp_tpl_flag;
+
+	return ret;
+}
+
+static int set_bp_wait_at_pwup_fn(struct bpctl_dev *pbpctl_dev, int tap_mode)
+{
+	if (!pbpctl_dev)
+		return  -1;
+	if (pbpctl_dev->bp_caps & SW_CTL_CAP)
+		return  -1;
+
+	cmnd_on(pbpctl_dev);
+	if (!tap_mode)
+		bp_wait_at_pwup_dis(pbpctl_dev);
+	else
+		bp_wait_at_pwup_en(pbpctl_dev);
+	cmnd_off(pbpctl_dev);
+
+	return BP_OK;
+}
+
+static int get_bp_wait_at_pwup_fn(struct bpctl_dev *pbpctl_dev)
+{
+	int ret = 0;
+
+	if (!pbpctl_dev)
+		return  -1;
+
+	ret = bp_wait_at_pwup_status(pbpctl_dev);
+
+	return ret;
+}
+
+static int set_bp_hw_reset_fn(struct bpctl_dev *pbpctl_dev, int tap_mode)
+{
+	if (!pbpctl_dev)
+		return  -1;
+	 if (pbpctl_dev->bp_caps & SW_CTL_CAP)
+		return  -1;
+
+	cmnd_on(pbpctl_dev);
+
+	if (!tap_mode)
+		bp_hw_reset_dis(pbpctl_dev);
+	else
+		bp_hw_reset_en(pbpctl_dev);
+
+	cmnd_off(pbpctl_dev);
+
+	return BP_OK;
+}
+
+static int get_bp_hw_reset_fn(struct bpctl_dev *pbpctl_dev)
+{
+	int ret = 0;
+
+	if (!pbpctl_dev)
+		return  -1;
+
+	ret = bp_hw_reset_status(pbpctl_dev);
+
+	return ret;
+}
+
+
+static int get_bypass_info_fn(struct bpctl_dev *pbpctl_dev, char *dev_name,
+			   char *add_param)
+{
+	if (!pbpctl_dev)
+		return  -1;
+	if (!is_bypass(pbpctl_dev))
+		return  -1;
+
+	strcpy(dev_name, pbpctl_dev->name);
+	*add_param = pbpctl_dev->bp_fw_ver;
+	return 0;
+}
+
+static struct bpctl_dev *get_dev_idx_p(int ifindex)
+{
+	int idx_dev = 0;
+
+	for (idx_dev = 0;
+		((bpctl_dev_arr[idx_dev].pdev != NULL) &&
+		 (idx_dev < device_num));
+		 idx_dev++) {
+		if (ifindex == bpctl_dev_arr[idx_dev].ifindex)
+			return &bpctl_dev_arr[idx_dev];
+	}
+
+	return NULL;
+}
+
+static int bp_device_event(struct notifier_block *unused,
+			   unsigned long event, void *ptr)
+{
+	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
+	static struct bpctl_dev *pbpctl_dev, *pbpctl_dev_m;
+	int dev_num = 0, ret = 0, ret_d = 0, time_left = 0;
+	int idx_dev;
+
+	if (!dev)
+		return NOTIFY_DONE;
+
+	switch (event) {
+	case NETDEV_REGISTER:
+		if (bp_get_dev_idx_bsf(dev, &idx_dev))
+			break;
+
+		if (idx_dev == -1)
+			break;
+
+		bpctl_dev_arr[idx_dev].ifindex = dev->ifindex;
+		bpctl_dev_arr[idx_dev].ndev = dev;
+
+		bypass_proc_remove_dev_sd(&bpctl_dev_arr[idx_dev]);
+		bypass_proc_create_dev_sd(&bpctl_dev_arr[idx_dev]);
+
+		break;
+
+	case NETDEV_UNREGISTER:
+		for (idx_dev = 0;
+			 ((bpctl_dev_arr[idx_dev].pdev != NULL)
+			  && (idx_dev < device_num)); idx_dev++) {
+			if (bpctl_dev_arr[idx_dev].ndev == dev) {
+				bypass_proc_remove_dev_sd(&bpctl_dev_arr
+							  [idx_dev]);
+				bpctl_dev_arr[idx_dev].ndev = NULL;
+
+				return NOTIFY_DONE;
+			}
+		}
+		break;
+
+	case NETDEV_CHANGENAME:
+		for (idx_dev = 0;
+			 ((bpctl_dev_arr[idx_dev].pdev != NULL)
+			  && (idx_dev < device_num)); idx_dev++) {
+			if (bpctl_dev_arr[idx_dev].ndev == dev) {
+				bypass_proc_remove_dev_sd(&bpctl_dev_arr
+							  [idx_dev]);
+				bypass_proc_create_dev_sd(&bpctl_dev_arr
+							  [idx_dev]);
+
+				return NOTIFY_DONE;
+			}
+		}
+		break;
+
+	case NETDEV_CHANGE:
+		if (netif_carrier_ok(dev))
+			break;
+
+		 dev_num = get_dev_idx(dev->ifindex);
+		 if (dev_num == -1)
+			break;
+
+		 pbpctl_dev = &bpctl_dev_arr[dev_num];
+		 if (!pbpctl_dev)
+			break;
+
+		 if ((is_bypass(pbpctl_dev)) == 1)
+			pbpctl_dev_m = pbpctl_dev;
+		 else
+			pbpctl_dev_m = get_master_port(pbpctl_dev);
+		 if (!pbpctl_dev_m)
+			break;
+		 ret = bypass_status(pbpctl_dev_m);
+		 if (ret == 1)
+			netdev_info(dev,
+				    "is in the Bypass mode now\n");
+		 ret_d = disc_status(pbpctl_dev_m);
+		 if (ret_d == 1)
+			netdev_info(dev,
+				    "is in the Disconnect mode now\n");
+		 if (ret || ret_d) {
+			wdt_timer(pbpctl_dev_m, &time_left);
+			if (time_left == -1)
+				netdev_info(dev, "WDT has expired\n");
+		 }
+		 break;
+
+	default:
+		return NOTIFY_DONE;
+
+	}
+	return NOTIFY_DONE;
+
+}
+static struct notifier_block bp_notifier_block = {
+	.notifier_call = bp_device_event,
+};
+
+
+static void if_scan_init(void)
+{
+	struct net_device *dev;
+
+	for_each_netdev(&init_net, dev) {
+		int idx_dev;
+
+		if (bp_get_dev_idx_bsf(dev, &idx_dev))
+			continue;
+
+		if (idx_dev == -1)
+			continue;
+
+		bpctl_dev_arr[idx_dev].ifindex = dev->ifindex;
+		bpctl_dev_arr[idx_dev].ndev = dev;
+	}
+}
+
+static int init_bypass_tpl_auto(struct bpctl_dev *pbpctl_dev)
+{
+	if (!pbpctl_dev)
+		return  -1;
+	if (!(pbpctl_dev->bp_caps & TPL_CAP))
+		return  -1;
+
+	init_timer(&pbpctl_dev->bp_tpl_timer);
+	pbpctl_dev->bp_tpl_timer.function = &bp_tpl_timer_fn;
+	pbpctl_dev->bp_tpl_timer.data = (unsigned long)pbpctl_dev;
+
+	return BP_OK;
+}
+
+static void remove_bypass_tpl_auto(struct bpctl_dev *pbpctl_dev)
+{
+	struct bpctl_dev *pbpctl_dev_b;
+
+	if (!pbpctl_dev)
+		return;
+	if (!(pbpctl_dev->bp_caps & TPL_CAP))
+		return;
+
+	if (get_tpl_fn(pbpctl_dev)) {
+		del_timer_sync(&pbpctl_dev->bp_tpl_timer);
+		pbpctl_dev->bp_tpl_flag = 0;
+		pbpctl_dev_b = get_status_port(pbpctl_dev);
+		if (pbpctl_dev_b)
+			set_tx(pbpctl_dev_b, 1);
+		set_tx(pbpctl_dev, 1);
+	}
+}
+
+static int set_bypass_tpl_auto(struct bpctl_dev *pbpctl_dev, unsigned int param)
+{
+	if (!pbpctl_dev)
+		return  -1;
+	if (!(pbpctl_dev->bp_caps & TPL_CAP))
+		return  -1;
+
+	if ((param) && (!pbpctl_dev->bp_tpl_flag)) {
+		pbpctl_dev->bp_tpl_flag = param;
+		mod_timer(&pbpctl_dev->bp_tpl_timer, jiffies + 1);
+		return BP_OK;
+	}
+	if ((!param) && (pbpctl_dev->bp_tpl_flag))
+		remove_bypass_tpl_auto(pbpctl_dev);
+
+	return BP_OK;
+}
+
+static int set_tpl_fn(struct bpctl_dev *pbpctl_dev, int tpl_mode)
+{
+	struct bpctl_dev *pbpctl_dev_b;
+
+	if (!pbpctl_dev)
+		return  -1;
+	if (!(pbpctl_dev->bp_caps & TPL_CAP))
+		return  -1;
+
+	if (tpl_mode) {
+		pbpctl_dev_b = get_status_port(pbpctl_dev);
+		if (pbpctl_dev_b)
+			set_tx(pbpctl_dev_b, 1);
+		set_tx(pbpctl_dev, 1);
+	}
+	if ((TPL_IF_SERIES(pbpctl_dev->subdevice)) ||
+		(pbpctl_dev->bp_caps_ex & TPL2_CAP_EX)) {
+		pbpctl_dev->bp_tpl_flag = tpl_mode;
+		if (!tpl_mode)
+			tpl_hw_off(pbpctl_dev);
+		else
+			tpl_hw_on(pbpctl_dev);
+	} else
+		set_bypass_tpl_auto(pbpctl_dev, tpl_mode);
+	return 0;
+}
+
+static long device_ioctl(struct file *file,
+			 unsigned int ioctl_num,
+			 unsigned long ioctl_param)
+{
+	struct bpctl_cmd bpctl_cmd;
+	int dev_idx = 0;
+	struct bpctl_dev *pbpctl_dev_out;
+	void __user *argp = (void __user *)ioctl_param;
+	int ret = 0;
+	unsigned long flags;
+
+	static struct bpctl_dev *pbpctl_dev;
+
+	if (down_interruptible(&bpctl_sema))
+		return -ERESTARTSYS;
+
+/* Switch according to the ioctl called */
+	if (ioctl_num == IOCTL_TX_MSG(IF_SCAN)) {
+		if_scan_init();
+		ret = SUCCESS;
+		goto bp_exit;
+	}
+	if (copy_from_user(&bpctl_cmd, argp, sizeof(struct bpctl_cmd))) {
+
+		ret = -EFAULT;
+		goto bp_exit;
+	}
+
+	if (ioctl_num == IOCTL_TX_MSG(GET_DEV_NUM)) {
+		bpctl_cmd.out_param[0] = device_num;
+		if (copy_to_user
+			(argp, (void *)&bpctl_cmd, sizeof(struct bpctl_cmd))) {
+			ret = -EFAULT;
+			goto bp_exit;
+		}
+		ret = SUCCESS;
+		goto bp_exit;
+
+	}
+	local_irq_save(flags);
+	if (!spin_trylock(&bpvm_lock)) {
+		local_irq_restore(flags);
+		up(&bpctl_sema);
+		return  -1;
+	}
+
+	if ((bpctl_cmd.in_param[5]) ||
+		(bpctl_cmd.in_param[6]) || (bpctl_cmd.in_param[7]))
+		dev_idx = get_dev_idx_bsf(bpctl_cmd.in_param[5],
+					  bpctl_cmd.in_param[6],
+					  bpctl_cmd.in_param[7]);
+	else if (bpctl_cmd.in_param[1] == 0)
+		dev_idx = bpctl_cmd.in_param[0];
+	else
+		dev_idx = get_dev_idx(bpctl_cmd.in_param[1]);
+
+	if (dev_idx < 0 || dev_idx > device_num) {
+		ret = -EOPNOTSUPP;
+		spin_unlock_irqrestore(&bpvm_lock, flags);
+		goto bp_exit;
+	}
+
+	bpctl_cmd.out_param[0] = bpctl_dev_arr[dev_idx].bus;
+	bpctl_cmd.out_param[1] = bpctl_dev_arr[dev_idx].slot;
+	bpctl_cmd.out_param[2] = bpctl_dev_arr[dev_idx].func;
+	bpctl_cmd.out_param[3] = bpctl_dev_arr[dev_idx].ifindex;
+
+	if ((bpctl_dev_arr[dev_idx].nic_type == bp_10gb)
+		&& (!(bpctl_dev_arr[dev_idx].ifindex))) {
+		pr_info("Please load network driver for %s adapter!\n",
+			   bpctl_dev_arr[dev_idx].name);
+		bpctl_cmd.status = -1;
+		ret = SUCCESS;
+		spin_unlock_irqrestore(&bpvm_lock, flags);
+		goto bp_exit;
+
+	}
+	if (((bpctl_dev_arr[dev_idx].nic_type == bp_10gb) &&
+		 (bpctl_dev_arr[dev_idx].ndev))
+	    &&
+	    (!(bpctl_dev_arr[dev_idx].ndev->flags & IFF_UP))) {
+		pr_info("Please bring up network interfaces for %s adapter!\n",
+			bpctl_dev_arr[dev_idx].name);
+		bpctl_cmd.status = -1;
+		ret = SUCCESS;
+		spin_unlock_irqrestore(&bpvm_lock, flags);
+		goto bp_exit;
+	}
+
+	if ((dev_idx < 0) || (dev_idx > device_num)
+		|| (bpctl_dev_arr[dev_idx].pdev == NULL)) {
+		bpctl_cmd.status = -1;
+		goto bpcmd_exit;
+	}
+
+	pbpctl_dev = &bpctl_dev_arr[dev_idx];
+
+	switch (ioctl_num) {
+	case IOCTL_TX_MSG(SET_BYPASS_PWOFF):
+		bpctl_cmd.status =
+			set_bypass_pwoff_fn(pbpctl_dev, bpctl_cmd.in_param[2]);
+		break;
+
+	case IOCTL_TX_MSG(GET_BYPASS_PWOFF):
+		bpctl_cmd.status = get_bypass_pwoff_fn(pbpctl_dev);
+		break;
+
+	case IOCTL_TX_MSG(SET_BYPASS_PWUP):
+		bpctl_cmd.status =
+			set_bypass_pwup_fn(pbpctl_dev, bpctl_cmd.in_param[2]);
+		break;
+
+	case IOCTL_TX_MSG(GET_BYPASS_PWUP):
+		bpctl_cmd.status = get_bypass_pwup_fn(pbpctl_dev);
+		break;
+
+	case IOCTL_TX_MSG(SET_BYPASS_WD):
+		bpctl_cmd.status =
+			set_bypass_wd_fn(pbpctl_dev, bpctl_cmd.in_param[2]);
+		break;
+
+	case IOCTL_TX_MSG(GET_BYPASS_WD):
+		bpctl_cmd.status =
+			get_bypass_wd_fn(pbpctl_dev,
+					  (int *)&(bpctl_cmd.data[0]));
+		break;
+
+	case IOCTL_TX_MSG(GET_WD_EXPIRE_TIME):
+		bpctl_cmd.status =
+			get_wd_expire_time_fn(pbpctl_dev,
+					  (int *)&(bpctl_cmd.data[0]));
+		break;
+
+	case IOCTL_TX_MSG(RESET_BYPASS_WD_TIMER):
+		bpctl_cmd.status = reset_bypass_wd_timer_fn(pbpctl_dev);
+		break;
+
+	case IOCTL_TX_MSG(GET_WD_SET_CAPS):
+		bpctl_cmd.status = get_wd_set_caps_fn(pbpctl_dev);
+		break;
+
+	case IOCTL_TX_MSG(SET_STD_NIC):
+		bpctl_cmd.status =
+			set_std_nic_fn(pbpctl_dev, bpctl_cmd.in_param[2]);
+		break;
+
+	case IOCTL_TX_MSG(GET_STD_NIC):
+		bpctl_cmd.status = get_std_nic_fn(pbpctl_dev);
+		break;
+
+	case IOCTL_TX_MSG(SET_TAP):
+		bpctl_cmd.status =
+			set_tap_fn(pbpctl_dev, bpctl_cmd.in_param[2]);
+		break;
+
+	case IOCTL_TX_MSG(GET_TAP):
+		bpctl_cmd.status = get_tap_fn(pbpctl_dev);
+		break;
+
+	case IOCTL_TX_MSG(GET_TAP_CHANGE):
+		bpctl_cmd.status = get_tap_change_fn(pbpctl_dev);
+		break;
+
+	case IOCTL_TX_MSG(SET_DIS_TAP):
+		bpctl_cmd.status =
+			set_dis_tap_fn(pbpctl_dev, bpctl_cmd.in_param[2]);
+		break;
+
+	case IOCTL_TX_MSG(GET_DIS_TAP):
+		bpctl_cmd.status = get_dis_tap_fn(pbpctl_dev);
+		break;
+
+	case IOCTL_TX_MSG(SET_TAP_PWUP):
+		bpctl_cmd.status =
+			set_tap_pwup_fn(pbpctl_dev, bpctl_cmd.in_param[2]);
+		break;
+
+	case IOCTL_TX_MSG(GET_TAP_PWUP):
+		bpctl_cmd.status = get_tap_pwup_fn(pbpctl_dev);
+		break;
+
+	case IOCTL_TX_MSG(SET_WD_EXP_MODE):
+		bpctl_cmd.status =
+			set_wd_exp_mode_fn(pbpctl_dev, bpctl_cmd.in_param[2]);
+		break;
+
+	case IOCTL_TX_MSG(GET_WD_EXP_MODE):
+		bpctl_cmd.status = get_wd_exp_mode_fn(pbpctl_dev);
+		break;
+
+	case IOCTL_TX_MSG(GET_DIS_BYPASS):
+		bpctl_cmd.status = get_dis_bypass_fn(pbpctl_dev);
+		break;
+
+	case IOCTL_TX_MSG(SET_DIS_BYPASS):
+		bpctl_cmd.status =
+			set_dis_bypass_fn(pbpctl_dev, bpctl_cmd.in_param[2]);
+		break;
+
+	case IOCTL_TX_MSG(GET_BYPASS_CHANGE):
+		bpctl_cmd.status = get_bypass_change_fn(pbpctl_dev);
+		break;
+
+	case IOCTL_TX_MSG(GET_BYPASS):
+		bpctl_cmd.status = get_bypass_fn(pbpctl_dev);
+		break;
+
+	case IOCTL_TX_MSG(SET_BYPASS):
+		bpctl_cmd.status =
+			set_bypass_fn(pbpctl_dev, bpctl_cmd.in_param[2]);
+		break;
+
+	case IOCTL_TX_MSG(GET_BYPASS_CAPS):
+		bpctl_cmd.status = get_bypass_caps_fn(pbpctl_dev);
+		spin_unlock_irqrestore(&bpvm_lock, flags);
+		if (copy_to_user
+			(argp, (void *)&bpctl_cmd, sizeof(struct bpctl_cmd))) {
+			ret = -EFAULT;
+			goto bp_exit;
+		}
+		goto bp_exit;
+
+	case IOCTL_TX_MSG(GET_BYPASS_SLAVE):
+		bpctl_cmd.status =
+			get_bypass_slave_fn(pbpctl_dev, &pbpctl_dev_out);
+		if (bpctl_cmd.status == 1) {
+			bpctl_cmd.out_param[4] = pbpctl_dev_out->bus;
+			bpctl_cmd.out_param[5] = pbpctl_dev_out->slot;
+			bpctl_cmd.out_param[6] = pbpctl_dev_out->func;
+			bpctl_cmd.out_param[7] = pbpctl_dev_out->ifindex;
+		}
+		break;
+
+	case IOCTL_TX_MSG(IS_BYPASS):
+		bpctl_cmd.status = is_bypass(pbpctl_dev);
+		break;
+	case IOCTL_TX_MSG(SET_TX):
+		bpctl_cmd.status = set_tx_fn(pbpctl_dev, bpctl_cmd.in_param[2]);
+		break;
+	case IOCTL_TX_MSG(GET_TX):
+		bpctl_cmd.status = get_tx_fn(pbpctl_dev);
+		break;
+	case IOCTL_TX_MSG(SET_WD_AUTORESET):
+		bpctl_cmd.status =
+			set_wd_autoreset_fn(pbpctl_dev, bpctl_cmd.in_param[2]);
+
+		break;
+	case IOCTL_TX_MSG(GET_WD_AUTORESET):
+
+		bpctl_cmd.status = get_wd_autoreset_fn(pbpctl_dev);
+		break;
+	case IOCTL_TX_MSG(SET_DISC):
+		bpctl_cmd.status =
+			set_disc_fn(pbpctl_dev, bpctl_cmd.in_param[2]);
+		break;
+	case IOCTL_TX_MSG(GET_DISC):
+		bpctl_cmd.status = get_disc_fn(pbpctl_dev);
+		break;
+	case IOCTL_TX_MSG(GET_DISC_CHANGE):
+		bpctl_cmd.status = get_disc_change_fn(pbpctl_dev);
+		break;
+	case IOCTL_TX_MSG(SET_DIS_DISC):
+		bpctl_cmd.status =
+			set_dis_disc_fn(pbpctl_dev, bpctl_cmd.in_param[2]);
+		break;
+	case IOCTL_TX_MSG(GET_DIS_DISC):
+		bpctl_cmd.status = get_dis_disc_fn(pbpctl_dev);
+		break;
+	case IOCTL_TX_MSG(SET_DISC_PWUP):
+		bpctl_cmd.status =
+			set_disc_pwup_fn(pbpctl_dev, bpctl_cmd.in_param[2]);
+		break;
+	case IOCTL_TX_MSG(GET_DISC_PWUP):
+		bpctl_cmd.status = get_disc_pwup_fn(pbpctl_dev);
+		break;
+
+	case IOCTL_TX_MSG(GET_BYPASS_INFO):
+
+		bpctl_cmd.status =
+			get_bypass_info_fn(pbpctl_dev, (char *)&bpctl_cmd.data,
+					   (char *)&bpctl_cmd.out_param[4]);
+		break;
+
+	case IOCTL_TX_MSG(SET_TPL):
+		bpctl_cmd.status =
+			set_tpl_fn(pbpctl_dev, bpctl_cmd.in_param[2]);
+		break;
+
+	case IOCTL_TX_MSG(GET_TPL):
+		bpctl_cmd.status = get_tpl_fn(pbpctl_dev);
+		break;
+	case IOCTL_TX_MSG(SET_BP_WAIT_AT_PWUP):
+		bpctl_cmd.status =
+			set_bp_wait_at_pwup_fn(pbpctl_dev,
+						  bpctl_cmd.in_param[2]);
+		break;
+
+	case IOCTL_TX_MSG(GET_BP_WAIT_AT_PWUP):
+		bpctl_cmd.status = get_bp_wait_at_pwup_fn(pbpctl_dev);
+		break;
+
+	case IOCTL_TX_MSG(SET_BP_HW_RESET):
+		bpctl_cmd.status =
+			set_bp_hw_reset_fn(pbpctl_dev, bpctl_cmd.in_param[2]);
+		break;
+
+	case IOCTL_TX_MSG(GET_BP_HW_RESET):
+		bpctl_cmd.status = get_bp_hw_reset_fn(pbpctl_dev);
+		break;
+
+	case IOCTL_TX_MSG(SET_BP_FORCE_LINK):
+		bpctl_cmd.status =
+			set_bp_force_link_fn(dev_idx, bpctl_cmd.in_param[2]);
+		break;
+
+	case IOCTL_TX_MSG(GET_BP_FORCE_LINK):
+		bpctl_cmd.status = get_bp_force_link_fn(dev_idx);
+		break;
+
+	default:
+
+		ret = -EOPNOTSUPP;
+		spin_unlock_irqrestore(&bpvm_lock, flags);
+		goto bp_exit;
+	}
+ bpcmd_exit:
+	spin_unlock_irqrestore(&bpvm_lock, flags);
+	if (copy_to_user(argp, (void *)&bpctl_cmd, sizeof(struct bpctl_cmd)))
+		ret = -EFAULT;
+	ret = SUCCESS;
+ bp_exit:
+	up(&bpctl_sema);
+	return ret;
+}
+
+static const struct file_operations Fops = {
+	.owner = THIS_MODULE,
+	.unlocked_ioctl = device_ioctl,
+};
+
+#ifndef PCI_DEVICE
+#define PCI_DEVICE(vend, dev) \
+	.vendor = (vend), .device = (dev), \
+	.subvendor = PCI_ANY_ID, .subdevice = PCI_ANY_ID
+#endif
+
+#define SILICOM_E1000BP_ETHERNET_DEVICE(device_id) {\
+	PCI_DEVICE(SILICOM_VID, device_id)}
+
+enum board_type {
+	PXG2BPFI,
+	PXG2BPFIL,
+	PXG2BPFILX,
+	PXG2BPFILLX,
+	PXGBPI,
+	PXGBPIG,
+	PXG2TBFI,
+	PXG4BPI,
+	PXG4BPFI,
+	PEG4BPI,
+	PEG2BPI,
+	PEG4BPIN,
+	PEG2BPFI,
+	PEG2BPFILX,
+	PMCXG2BPFI,
+	PMCXG2BPFIN,
+	PEG4BPII,
+	PEG4BPFII,
+	PXG4BPFILX,
+	PMCXG2BPIN,
+	PMCXG4BPIN,
+	PXG2BISC1,
+	PEG2TBFI,
+	PXG2TBI,
+	PXG4BPFID,
+	PEG4BPFI,
+	PEG4BPIPT,
+	PXG6BPI,
+	PEG4BPIL,
+	PMCXG2BPIN2,
+	PMCXG4BPIN2,
+	PMCX2BPI,
+	PEG2BPFID,
+	PEG2BPFIDLX,
+	PMCX4BPI,
+	MEG2BPFILN,
+	MEG2BPFINX,
+	PEG4BPFILX,
+	PE10G2BPISR,
+	PE10G2BPILR,
+	MHIO8AD,
+	PE10G2BPICX4,
+	PEG2BPI5,
+	PEG6BPI,
+	PEG4BPFI5,
+	PEG4BPFI5LX,
+	MEG2BPFILXLN,
+	PEG2BPIX1,
+	MEG2BPFILXNX,
+	XE10G2BPIT,
+	XE10G2BPICX4,
+	XE10G2BPISR,
+	XE10G2BPILR,
+	PEG4BPIIO,
+	XE10G2BPIXR,
+	PE10GDBISR,
+	PE10GDBILR,
+	PEG2BISC6,
+	PEG6BPIFC,
+	PE10G2BPTCX4,
+	PE10G2BPTSR,
+	PE10G2BPTLR,
+	PE10G2BPTT,
+	PEG4BPI6,
+	PEG4BPFI6,
+	PEG4BPFI6LX,
+	PEG4BPFI6ZX,
+	PEG4BPFI6CS,
+	PEG2BPI6,
+	PEG2BPFI6,
+	PEG2BPFI6LX,
+	PEG2BPFI6ZX,
+	PEG2BPFI6FLXM,
+	PEG2BPFI6FLXMRB2,
+	PEG4BPI6FC,
+	PEG4BPFI6FC,
+	PEG4BPFI6FCLX,
+	PEG4BPFI6FCZX,
+	PEG6BPI6,
+	PEG2BPI6SC6,
+	MEG2BPI6,
+	XEG2BPI6,
+	MEG4BPI6,
+	PEG2BPFI5,
+	PEG2BPFI5LX,
+	PXEG4BPFI,
+	M1EG2BPI6,
+	M1EG2BPFI6,
+	M1EG2BPFI6LX,
+	M1EG2BPFI6ZX,
+	M1EG4BPI6,
+	M1EG4BPFI6,
+	M1EG4BPFI6LX,
+	M1EG4BPFI6ZX,
+	M1EG6BPI6,
+	M1E2G4BPi80,
+	M1E2G4BPFi80,
+	M1E2G4BPFi80LX,
+	M1E2G4BPFi80ZX,
+	PE210G2SPI9,
+	M1E10G2BPI9CX4,
+	M1E10G2BPI9SR,
+	M1E10G2BPI9LR,
+	PE210G2BPI9CX4,
+	PE210G2BPI9SR,
+	PE210G2BPI9LR,
+	PE210G2BPI9SRD,
+	PE210G2BPI9LRD,
+	PE210G2BPI9T,
+	M1E210G2BPI9SRDJP,
+	M1E210G2BPI9SRDJP1,
+	M1E210G2BPI9LRDJP,
+	M1E210G2BPI9LRDJP1,
+	M2EG2BPFI6,
+	M2EG2BPFI6LX,
+	M2EG2BPFI6ZX,
+	M2EG4BPI6,
+	M2EG4BPFI6,
+	M2EG4BPFI6LX,
+	M2EG4BPFI6ZX,
+	M2EG6BPI6,
+	PEG2DBI6,
+	PEG2DBFI6,
+	PEG2DBFI6LX,
+	PEG2DBFI6ZX,
+	PE2G4BPi80,
+	PE2G4BPFi80,
+	PE2G4BPFi80LX,
+	PE2G4BPFi80ZX,
+	PE2G4BPi80L,
+	M6E2G8BPi80A,
+	PE2G2BPi35,
+	PAC1200BPi35,
+	PE2G2BPFi35,
+	PE2G2BPFi35ARB2,
+	PE2G2BPFi35LX,
+	PE2G2BPFi35ALXRB2,
+	PE2G2BPFi35ZX,
+	PE2G4BPi35,
+	PE2G4BPi35L,
+	PE2G4BPi35ALRB2,
+	PE2G4BPFi35,
+	PE2G4BPFi35ARB2,
+	PE2G4BPFi35CS,
+	PE2G4BPFi35LX,
+	PE2G4BPFi35ALXRB2,
+	PE2G4BPFi35ZX,
+	PE2G6BPi35,
+	PE2G6BPi35CX,
+	PE2G2BPi80,
+	PE2G2BPFi80,
+	PE2G2BPFi80LX,
+	PE2G2BPFi80ZX,
+	M2E10G2BPI9CX4,
+	M2E10G2BPI9SR,
+	M2E10G2BPI9LR,
+	M2E10G2BPI9T,
+	M6E2G8BPi80,
+	PE210G2DBi9SR,
+	PE210G2DBi9SRRB2,
+	PE210G2DBi9LR,
+	PE210G2DBi9LRRB2,
+	PE310G4DBi940SR,
+	PE310G4DBi940SRRB2,
+	PE310G4DBi940LR,
+	PE310G4DBi940LRRB2,
+	PE310G4DBi940T,
+	PE310G4DBi940TRB2,
+	PE310G4BPi9T,
+	PE310G4BPi9SR,
+	PE310G4BPi9LR,
+	PE310G4BPi9SRD,
+	PE310G4BPi9LRD,
+
+	PE210G2BPi40,
+	PE310G4BPi40,
+	M1E210G2BPI40T,
+	M6E310G4BPi9SR,
+	M6E310G4BPi9LR,
+	PE2G6BPI6CS,
+	PE2G6BPI6,
+
+	M1E2G4BPi35,
+	M1E2G4BPFi35,
+	M1E2G4BPFi35LX,
+	M1E2G4BPFi35ZX,
+
+	M1E2G4BPi35JP,
+	M1E2G4BPi35JP1,
+
+	PE310G4DBi9T,
+};
+
+struct bpmod_info {
+	unsigned int vendor;
+	unsigned int device;
+	unsigned int subvendor;
+	unsigned int subdevice;
+	unsigned int index;
+	char *bp_name;
+};
+
+struct {
+	char *name;
+} dev_desc[] = {
+	{"Silicom Bypass PXG2BPFI-SD series adapter"},
+	{"Silicom Bypass PXG2BPFIL-SD series adapter"},
+	{"Silicom Bypass PXG2BPFILX-SD series adapter"},
+	{"Silicom Bypass PXG2BPFILLX-SD series adapter"},
+	{"Silicom Bypass PXG2BPI-SD series adapter"},
+	{"Silicom Bypass PXG2BPIG-SD series adapter"},
+	{"Silicom Bypass PXG2TBFI-SD series adapter"},
+	{"Silicom Bypass PXG4BPI-SD series adapter"},
+	{"Silicom Bypass PXG4BPFI-SD series adapter"},
+	{"Silicom Bypass PEG4BPI-SD series adapter"},
+	{"Silicom Bypass PEG2BPI-SD series adapter"},
+	{"Silicom Bypass PEG4BPIN-SD series adapter"},
+	{"Silicom Bypass PEG2BPFI-SD series adapter"},
+	{"Silicom Bypass PEG2BPFI-LX-SD series adapter"},
+	{"Silicom Bypass PMCX2BPFI-SD series adapter"},
+	{"Silicom Bypass PMCX2BPFI-N series adapter"},
+	{"Intel Bypass PEG2BPII series adapter"},
+	{"Intel Bypass PEG2BPFII series adapter"},
+	{"Silicom Bypass PXG4BPFILX-SD series adapter"},
+	{"Silicom Bypass PMCX2BPI-N series adapter"},
+	{"Silicom Bypass PMCX4BPI-N series adapter"},
+	{"Silicom Bypass PXG2BISC1-SD series adapter"},
+	{"Silicom Bypass PEG2TBFI-SD series adapter"},
+	{"Silicom Bypass PXG2TBI-SD series adapter"},
+	{"Silicom Bypass PXG4BPFID-SD series adapter"},
+	{"Silicom Bypass PEG4BPFI-SD series adapter"},
+	{"Silicom Bypass PEG4BPIPT-SD series adapter"},
+	{"Silicom Bypass PXG6BPI-SD series adapter"},
+	{"Silicom Bypass PEG4BPIL-SD series adapter"},
+	{"Silicom Bypass PMCX2BPI-N2 series adapter"},
+	{"Silicom Bypass PMCX4BPI-N2 series adapter"},
+	{"Silicom Bypass PMCX2BPI-SD series adapter"},
+	{"Silicom Bypass PEG2BPFID-SD series adapter"},
+	{"Silicom Bypass PEG2BPFIDLX-SD series adapter"},
+	{"Silicom Bypass PMCX4BPI-SD series adapter"},
+	{"Silicom Bypass MEG2BPFILN-SD series adapter"},
+	{"Silicom Bypass MEG2BPFINX-SD series adapter"},
+	{"Silicom Bypass PEG4BPFILX-SD series adapter"},
+	{"Silicom Bypass PE10G2BPISR-SD series adapter"},
+	{"Silicom Bypass PE10G2BPILR-SD series adapter"},
+	{"Silicom Bypass MHIO8AD-SD series adapter"},
+	{"Silicom Bypass PE10G2BPICX4-SD series adapter"},
+	{"Silicom Bypass PEG2BPI5-SD series adapter"},
+	{"Silicom Bypass PEG6BPI5-SD series adapter"},
+	{"Silicom Bypass PEG4BPFI5-SD series adapter"},
+	{"Silicom Bypass PEG4BPFI5LX-SD series adapter"},
+	{"Silicom Bypass MEG2BPFILXLN-SD series adapter"},
+	{"Silicom Bypass PEG2BPIX1-SD series adapter"},
+	{"Silicom Bypass MEG2BPFILXNX-SD series adapter"},
+	{"Silicom Bypass XE10G2BPIT-SD series adapter"},
+	{"Silicom Bypass XE10G2BPICX4-SD series adapter"},
+	{"Silicom Bypass XE10G2BPISR-SD series adapter"},
+	{"Silicom Bypass XE10G2BPILR-SD series adapter"},
+	{"Intel Bypass PEG2BPFII0 series adapter"},
+	{"Silicom Bypass XE10G2BPIXR series adapter"},
+	{"Silicom Bypass PE10G2DBISR series adapter"},
+	{"Silicom Bypass PEG2BI5SC6 series adapter"},
+	{"Silicom Bypass PEG6BPI5FC series adapter"},
+
+	{"Silicom Bypass PE10G2BPTCX4 series adapter"},
+	{"Silicom Bypass PE10G2BPTSR series adapter"},
+	{"Silicom Bypass PE10G2BPTLR series adapter"},
+	{"Silicom Bypass PE10G2BPTT series adapter"},
+	{"Silicom Bypass PEG4BPI6 series adapter"},
+	{"Silicom Bypass PEG4BPFI6 series adapter"},
+	{"Silicom Bypass PEG4BPFI6LX series adapter"},
+	{"Silicom Bypass PEG4BPFI6ZX series adapter"},
+	{"Silicom Bypass PEG4BPFI6CS series adapter"},
+	{"Silicom Bypass PEG2BPI6 series adapter"},
+	{"Silicom Bypass PEG2BPFI6 series adapter"},
+	{"Silicom Bypass PEG2BPFI6LX series adapter"},
+	{"Silicom Bypass PEG2BPFI6ZX series adapter"},
+
+	{"Silicom Bypass PEG2BPFI6FLXM series adapter"},
+	{"Silicom Bypass PEG2BPFI6FLXMRB2 series adapter"},
+
+
+	{"Silicom Bypass PEG4BPI6FC series adapter"},
+	{"Silicom Bypass PEG4BPFI6FC series adapter"},
+	{"Silicom Bypass PEG4BPFI6FCLX series adapter"},
+	{"Silicom Bypass PEG4BPFI6FCZX series adapter"},
+	{"Silicom Bypass PEG6BPI6 series adapter"},
+	{"Silicom Bypass PEG2BPI6SC6 series adapter"},
+	{"Silicom Bypass MEG2BPI6 series adapter"},
+	{"Silicom Bypass XEG2BPI6 series adapter"},
+	{"Silicom Bypass MEG4BPI6 series adapter"},
+	{"Silicom Bypass PEG2BPFI5-SD series adapter"},
+	{"Silicom Bypass PEG2BPFI5LX-SD series adapter"},
+	{"Silicom Bypass PXEG4BPFI-SD series adapter"},
+	{"Silicom Bypass MxEG2BPI6 series adapter"},
+	{"Silicom Bypass MxEG2BPFI6 series adapter"},
+	{"Silicom Bypass MxEG2BPFI6LX series adapter"},
+	{"Silicom Bypass MxEG2BPFI6ZX series adapter"},
+	{"Silicom Bypass MxEG4BPI6 series adapter"},
+	{"Silicom Bypass MxEG4BPFI6 series adapter"},
+	{"Silicom Bypass MxEG4BPFI6LX series adapter"},
+	{"Silicom Bypass MxEG4BPFI6ZX series adapter"},
+	{"Silicom Bypass MxEG6BPI6 series adapter"},
+	{"Silicom Bypass MxE2G4BPi80 series adapter"},
+	{"Silicom Bypass MxE2G4BPFi80 series adapter"},
+	{"Silicom Bypass MxE2G4BPFi80LX series adapter"},
+	{"Silicom Bypass MxE2G4BPFi80ZX series adapter"},
+
+
+	{"Silicom Bypass PE210G2SPI9 series adapter"},
+
+
+	{"Silicom Bypass MxE210G2BPI9CX4 series adapter"},
+	{"Silicom Bypass MxE210G2BPI9SR series adapter"},
+	{"Silicom Bypass MxE210G2BPI9LR series adapter"},
+	{"Silicom Bypass MxE210G2BPI9T series adapter"},
+
+	{"Silicom Bypass PE210G2BPI9CX4 series adapter"},
+	{"Silicom Bypass PE210G2BPI9SR series adapter"},
+	{"Silicom Bypass PE210G2BPI9LR series adapter"},
+	{"Silicom Bypass PE210G2BPI9SRD series adapter"},
+	{"Silicom Bypass PE210G2BPI9LRD series adapter"},
+
+	{"Silicom Bypass PE210G2BPI9T series adapter"},
+	{"Silicom Bypass M1E210G2BPI9SRDJP series adapter"},
+	{"Silicom Bypass M1E210G2BPI9SRDJP1 series adapter"},
+	{"Silicom Bypass M1E210G2BPI9LRDJP series adapter"},
+	{"Silicom Bypass M1E210G2BPI9LRDJP1 series adapter"},
+
+	{"Silicom Bypass M2EG2BPFI6 series adapter"},
+	{"Silicom Bypass M2EG2BPFI6LX series adapter"},
+	{"Silicom Bypass M2EG2BPFI6ZX series adapter"},
+	{"Silicom Bypass M2EG4BPI6 series adapter"},
+	{"Silicom Bypass M2EG4BPFI6 series adapter"},
+	{"Silicom Bypass M2EG4BPFI6LX series adapter"},
+	{"Silicom Bypass M2EG4BPFI6ZX series adapter"},
+	{"Silicom Bypass M2EG6BPI6 series adapter"},
+
+
+
+	{"Silicom Bypass PEG2DBI6    series adapter"},
+	{"Silicom Bypass PEG2DBFI6   series adapter"},
+	{"Silicom Bypass PEG2DBFI6LX series adapter"},
+	{"Silicom Bypass PEG2DBFI6ZX series adapter"},
+
+
+	{"Silicom Bypass PE2G4BPi80 series adapter"},
+	{"Silicom Bypass PE2G4BPFi80 series adapter"},
+	{"Silicom Bypass PE2G4BPFi80LX series adapter"},
+	{"Silicom Bypass PE2G4BPFi80ZX series adapter"},
+
+	{"Silicom Bypass PE2G4BPi80L series adapter"},
+	{"Silicom Bypass MxE2G8BPi80A series adapter"},
+
+
+
+
+	{"Silicom Bypass PE2G2BPi35 series adapter"},
+	{"Silicom Bypass PAC1200BPi35 series adapter"},
+	{"Silicom Bypass PE2G2BPFi35 series adapter"},
+	{"Silicom Bypass PE2G2BPFi35ARB2 series adapter"},
+	{"Silicom Bypass PE2G2BPFi35LX series adapter"},
+	{"Silicom Bypass PE2G2BPFi35ALXRB2 series adapter"},
+	{"Silicom Bypass PE2G2BPFi35ZX series adapter"},
+
+
+
+	{"Silicom Bypass PE2G4BPi35 series adapter"},
+	{"Silicom Bypass PE2G4BPi35L series adapter"},
+	{"Silicom Bypass PE2G4BPi35ALRB2 series adapter"},
+	{"Silicom Bypass PE2G4BPFi35 series adapter"},
+	{"Silicom Bypass PE2G4BPFi35ARB2 series adapter"},
+	{"Silicom Bypass PE2G4BPFi35CS series adapter"},
+	{"Silicom Bypass PE2G4BPFi35LX series adapter"},
+	{"Silicom Bypass PE2G4BPFi35ALXRB2 series adapter"},
+	{"Silicom Bypass PE2G4BPFi35ZX series adapter"},
+
+	{"Silicom Bypass PE2G6BPi35 series adapter"},
+	{"Silicom Bypass PE2G6BPi35CX series adapter"},
+
+
+	{"Silicom Bypass PE2G2BPi80 series adapter"},
+	{"Silicom Bypass PE2G2BPFi80 series adapter"},
+	{"Silicom Bypass PE2G2BPFi80LX series adapter"},
+	{"Silicom Bypass PE2G2BPFi80ZX series adapter"},
+
+
+	{"Silicom Bypass M2E10G2BPI9CX4 series adapter"},
+	{"Silicom Bypass M2E10G2BPI9SR series adapter"},
+	{"Silicom Bypass M2E10G2BPI9LR series adapter"},
+	{"Silicom Bypass M2E10G2BPI9T series adapter"},
+	{"Silicom Bypass MxE2G8BPi80 series adapter"},
+	{"Silicom Bypass PE210G2DBi9SR series adapter"},
+	{"Silicom Bypass PE210G2DBi9SRRB2 series adapter"},
+	{"Silicom Bypass PE210G2DBi9LR series adapter"},
+	{"Silicom Bypass PE210G2DBi9LRRB2 series adapter"},
+	{"Silicom Bypass PE310G4DBi9-SR series adapter"},
+	{"Silicom Bypass PE310G4DBi9-SRRB2 series adapter"},
+	{"Silicom Bypass PE310G4BPi9T series adapter"},
+	{"Silicom Bypass PE310G4BPi9SR series adapter"},
+	{"Silicom Bypass PE310G4BPi9LR series adapter"},
+	{"Silicom Bypass PE310G4BPi9SRD series adapter"},
+	{"Silicom Bypass PE310G4BPi9LRD series adapter"},
+
+	{"Silicom Bypass PE210G2BPi40T series adapter"},
+	{"Silicom Bypass PE310G4BPi40T series adapter"},
+	{"Silicom Bypass M1E210G2BPI40T series adapter"},
+	{"Silicom Bypass M6E310G4BPi9SR series adapter"},
+	{"Silicom Bypass M6E310G4BPi9LR series adapter"},
+	{"Silicom Bypass PE2G6BPI6CS series adapter"},
+	{"Silicom Bypass PE2G6BPI6 series adapter"},
+
+	{"Silicom Bypass M1E2G4BPi35 series adapter"},
+	{"Silicom Bypass M1E2G4BPFi35 series adapter"},
+	{"Silicom Bypass M1E2G4BPFi35LX series adapter"},
+	{"Silicom Bypass M1E2G4BPFi35ZX series adapter"},
+	{"Silicom Bypass M1E2G4BPi35JP series adapter"},
+	{"Silicom Bypass M1E2G4BPi35JP1 series adapter"},
+
+	{"Silicom Bypass PE310G4DBi9T series adapter"},
+
+	{0},
+};
+
+static struct bpmod_info tx_ctl_pci_tbl[] = {
+	{0x8086, 0x107a, SILICOM_SVID, SILICOM_PXG2BPFI_SSID, PXG2BPFI,
+	 "PXG2BPFI-SD"},
+	{0x8086, 0x107a, SILICOM_SVID, SILICOM_PXG2BPFIL_SSID, PXG2BPFIL,
+	 "PXG2BPFIL-SD"},
+	{0x8086, 0x107a, SILICOM_SVID, SILICOM_PXG2BPFILX_SSID, PXG2BPFILX,
+	 "PXG2BPFILX-SD"},
+	{0x8086, 0x107a, SILICOM_SVID, SILICOM_PXG2BPFILLX_SSID, PXG2BPFILLX,
+	 "PXG2BPFILLXSD"},
+	{0x8086, 0x1010, SILICOM_SVID, SILICOM_PXGBPI_SSID, PXGBPI,
+	 "PXG2BPI-SD"},
+	{0x8086, 0x1079, SILICOM_SVID, SILICOM_PXGBPIG_SSID, PXGBPIG,
+	 "PXG2BPIG-SD"},
+	{0x8086, 0x107a, SILICOM_SVID, SILICOM_PXG2TBFI_SSID, PXG2TBFI,
+	 "PXG2TBFI-SD"},
+	{0x8086, 0x1079, SILICOM_SVID, SILICOM_PXG4BPI_SSID, PXG4BPI,
+	 "PXG4BPI-SD"},
+	{0x8086, 0x107a, SILICOM_SVID, SILICOM_PXG4BPFI_SSID, PXG4BPFI,
+	 "PXG4BPFI-SD"},
+	{0x8086, 0x107a, SILICOM_SVID, SILICOM_PXG4BPFILX_SSID, PXG4BPFILX,
+	 "PXG4BPFILX-SD"},
+	{0x8086, 0x1079, SILICOM_SVID, SILICOM_PEG4BPI_SSID, PEG4BPI,
+	 "PEXG4BPI-SD"},
+	{0x8086, 0x105e, SILICOM_SVID, SILICOM_PEG2BPI_SSID, PEG2BPI,
+	 "PEG2BPI-SD"},
+	{0x8086, 0x105e, SILICOM_SVID, SILICOM_PEG4BPIN_SSID, PEG4BPIN,
+	 "PEG4BPI-SD"},
+	{0x8086, 0x105f, SILICOM_SVID, SILICOM_PEG2BPFI_SSID, PEG2BPFI,
+	 "PEG2BPFI-SD"},
+	{0x8086, 0x105f, SILICOM_SVID, SILICOM_PEG2BPFILX_SSID, PEG2BPFILX,
+	 "PEG2BPFILX-SD"},
+	{0x8086, 0x107a, SILICOM_SVID, SILICOM_PMCXG2BPFI_SSID, PMCXG2BPFI,
+	 "PMCX2BPFI-SD"},
+	{0x8086, 0x107a, NOKIA_PMCXG2BPFIN_SVID, NOKIA_PMCXG2BPFIN_SSID,
+	 PMCXG2BPFIN, "PMCX2BPFI-N"},
+	{0x8086, INTEL_PEG4BPII_PID, 0x8086, INTEL_PEG4BPII_SSID, PEG4BPII,
+	 "PEG4BPII"},
+	{0x8086, INTEL_PEG4BPIIO_PID, 0x8086, INTEL_PEG4BPIIO_SSID, PEG4BPIIO,
+	 "PEG4BPII0"},
+	{0x8086, INTEL_PEG4BPFII_PID, 0x8086, INTEL_PEG4BPFII_SSID, PEG4BPFII,
+	 "PEG4BPFII"},
+	{0x8086, 0x1079, NOKIA_PMCXG2BPFIN_SVID, NOKIA_PMCXG2BPIN_SSID,
+	 PMCXG2BPIN, "PMCX2BPI-N"},
+	{0x8086, 0x1079, NOKIA_PMCXG2BPFIN_SVID, NOKIA_PMCXG4BPIN_SSID,
+	 PMCXG4BPIN, "PMCX4BPI-N"},
+	{0x8086, 0x1079, SILICOM_SVID, SILICOM_PXG2BISC1_SSID, PXG2BISC1,
+	 "PXG2BISC1-SD"},
+	{0x8086, 0x105f, SILICOM_SVID, SILICOM_PEG2TBFI_SSID, PEG2TBFI,
+	 "PEG2TBFI-SD"},
+	{0x8086, 0x1079, SILICOM_SVID, SILICOM_PXG2TBI_SSID, PXG2TBI,
+	 "PXG2TBI-SD"},
+	{0x8086, 0x107a, SILICOM_SVID, SILICOM_PXG4BPFID_SSID, PXG4BPFID,
+	 "PXG4BPFID-SD"},
+	{0x8086, 0x105f, SILICOM_SVID, SILICOM_PEG4BPFI_SSID, PEG4BPFI,
+	 "PEG4BPFI-SD"},
+	{0x8086, 0x105e, SILICOM_SVID, SILICOM_PEG4BPIPT_SSID, PEG4BPIPT,
+	 "PEG4BPIPT-SD"},
+	{0x8086, 0x1079, SILICOM_SVID, SILICOM_PXG6BPI_SSID, PXG6BPI,
+	 "PXG6BPI-SD"},
+	{0x8086, 0x10a7, SILICOM_SVID, SILICOM_PEG4BPIL_SSID, PEG4BPIL,
+	 "PEG4BPIL-SD"},
+	{0x8086, 0x1079, NOKIA_PMCXG2BPFIN_SVID, NOKIA_PMCXG2BPIN2_SSID,
+	 PMCXG2BPIN2, "PMCX2BPI-N2"},
+	{0x8086, 0x1079, NOKIA_PMCXG2BPFIN_SVID, NOKIA_PMCXG4BPIN2_SSID,
+	 PMCXG4BPIN2, "PMCX4BPI-N2"},
+	{0x8086, 0x1079, SILICOM_SVID, SILICOM_PMCX2BPI_SSID, PMCX2BPI,
+	 "PMCX2BPI-SD"},
+	{0x8086, 0x1079, SILICOM_SVID, SILICOM_PMCX4BPI_SSID, PMCX4BPI,
+	 "PMCX4BPI-SD"},
+	{0x8086, 0x105f, SILICOM_SVID, SILICOM_PEG2BPFID_SSID, PEG2BPFID,
+	 "PEG2BPFID-SD"},
+	{0x8086, 0x105f, SILICOM_SVID, SILICOM_PEG2BPFIDLX_SSID, PEG2BPFIDLX,
+	 "PEG2BPFIDLXSD"},
+	{0x8086, 0x105f, SILICOM_SVID, SILICOM_MEG2BPFILN_SSID, MEG2BPFILN,
+	 "MEG2BPFILN-SD"},
+	{0x8086, 0x105f, SILICOM_SVID, SILICOM_MEG2BPFINX_SSID, MEG2BPFINX,
+	 "MEG2BPFINX-SD"},
+	{0x8086, 0x105f, SILICOM_SVID, SILICOM_PEG4BPFILX_SSID, PEG4BPFILX,
+	 "PEG4BPFILX-SD"},
+	{0x8086, PCI_ANY_ID, SILICOM_SVID, SILICOM_PE10G2BPISR_SSID,
+	 PE10G2BPISR, "PE10G2BPISR"},
+	{0x8086, PCI_ANY_ID, SILICOM_SVID, SILICOM_PE10G2BPILR_SSID,
+	 PE10G2BPILR, "PE10G2BPILR"},
+	{0x8086, 0x10a9, SILICOM_SVID, SILICOM_MHIO8AD_SSID, MHIO8AD,
+	 "MHIO8AD-SD"},
+	{0x8086, PCI_ANY_ID, SILICOM_SVID, SILICOM_PE10G2BPICX4_SSID,
+	 PE10G2BPISR, "PE10G2BPICX4"},
+	{0x8086, 0x10a7, SILICOM_SVID, SILICOM_PEG2BPI5_SSID, PEG2BPI5,
+	 "PEG2BPI5-SD"},
+	{0x8086, 0x10a7, SILICOM_SVID, SILICOM_PEG6BPI_SSID, PEG6BPI,
+	 "PEG6BPI5"},
+	{0x8086, 0x10a9, SILICOM_SVID, SILICOM_PEG4BPFI5_SSID, PEG4BPFI5,
+	 "PEG4BPFI5"},
+	{0x8086, 0x10a9, SILICOM_SVID, SILICOM_PEG4BPFI5LX_SSID, PEG4BPFI5LX,
+	 "PEG4BPFI5LX"},
+	{0x8086, 0x105f, SILICOM_SVID, SILICOM_MEG2BPFILXLN_SSID, MEG2BPFILXLN,
+	 "MEG2BPFILXLN"},
+	{0x8086, 0x105e, SILICOM_SVID, SILICOM_PEG2BPIX1_SSID, PEG2BPIX1,
+	 "PEG2BPIX1-SD"},
+	{0x8086, 0x105f, SILICOM_SVID, SILICOM_MEG2BPFILXNX_SSID, MEG2BPFILXNX,
+	 "MEG2BPFILXNX"},
+	{0x8086, PCI_ANY_ID, SILICOM_SVID, SILICOM_XE10G2BPIT_SSID, XE10G2BPIT,
+	 "XE10G2BPIT"},
+	{0x8086, PCI_ANY_ID, SILICOM_SVID, SILICOM_XE10G2BPICX4_SSID,
+	 XE10G2BPICX4, "XE10G2BPICX4"},
+	{0x8086, 0x10C6, SILICOM_SVID, SILICOM_XE10G2BPISR_SSID, XE10G2BPISR,
+	 "XE10G2BPISR"},
+	{0x8086, 0x10C6, SILICOM_SVID, SILICOM_XE10G2BPILR_SSID, XE10G2BPILR,
+	 "XE10G2BPILR"},
+	{0x8086, 0x10C6, NOKIA_XE10G2BPIXR_SVID, NOKIA_XE10G2BPIXR_SSID,
+	 XE10G2BPIXR, "XE10G2BPIXR"},
+	{0x8086, 0x10C6, SILICOM_SVID, SILICOM_PE10GDBISR_SSID, PE10GDBISR,
+	 "PE10G2DBISR"},
+	{0x8086, 0x10C6, SILICOM_SVID, SILICOM_PE10GDBILR_SSID, PE10GDBILR,
+	 "PE10G2DBILR"},
+	{0x8086, 0x10a7, SILICOM_SVID, SILICOM_PEG2BISC6_SSID, PEG2BISC6,
+	 "PEG2BI5SC6"},
+	{0x8086, 0x10a7, SILICOM_SVID, SILICOM_PEG6BPIFC_SSID, PEG6BPIFC,
+	 "PEG6BPI5FC"},
+	{BROADCOM_VID, BROADCOM_PE10G2_PID, SILICOM_SVID,
+	 SILICOM_PE10G2BPTCX4_SSID, PE10G2BPTCX4, "PE10G2BPTCX4"},
+	{BROADCOM_VID, BROADCOM_PE10G2_PID, SILICOM_SVID,
+	 SILICOM_PE10G2BPTSR_SSID, PE10G2BPTSR, "PE10G2BPTSR"},
+	{BROADCOM_VID, BROADCOM_PE10G2_PID, SILICOM_SVID,
+	 SILICOM_PE10G2BPTLR_SSID, PE10G2BPTLR, "PE10G2BPTLR"},
+	{BROADCOM_VID, BROADCOM_PE10G2_PID, SILICOM_SVID,
+	 SILICOM_PE10G2BPTT_SSID, PE10G2BPTT, "PE10G2BPTT"},
+	{0x8086, 0x10c9, SILICOM_SVID, SILICOM_PEG4BPI6_SSID, PEG4BPI6,
+	 "PEG4BPI6"},
+	{0x8086, 0x10e6, SILICOM_SVID, SILICOM_PEG4BPFI6_SSID, PEG4BPFI6,
+	 "PEG4BPFI6"},
+	{0x8086, 0x10e6, SILICOM_SVID, SILICOM_PEG4BPFI6LX_SSID, PEG4BPFI6LX,
+	 "PEG4BPFI6LX"},
+	{0x8086, 0x10e6, SILICOM_SVID, SILICOM_PEG4BPFI6ZX_SSID, PEG4BPFI6ZX,
+	 "PEG4BPFI6ZX"},
+	{0x8086, 0x10c9, SILICOM_SVID, SILICOM_PEG2BPI6_SSID, PEG2BPI6,
+	 "PEG2BPI6"},
+	{0x8086, 0x10e6, SILICOM_SVID, SILICOM_PEG2BPFI6_SSID, PEG2BPFI6,
+	 "PEG2BPFI6"},
+	{0x8086, 0x10e6, SILICOM_SVID, SILICOM_PEG2BPFI6LX_SSID, PEG2BPFI6LX,
+	 "PEG2BPFI6LX"},
+	{0x8086, 0x10e6, SILICOM_SVID, SILICOM_PEG2BPFI6ZX_SSID, PEG2BPFI6ZX,
+	 "PEG2BPFI6ZX"},
+	{0x8086, 0x10e7, SILICOM_SVID, SILICOM_PEG2BPFI6FLXM_SSID,
+	 PEG2BPFI6FLXM, "PEG2BPFI6FLXM"},
+	{0x8086, 0x10e7, 0x1b2e , SILICOM_PEG2BPFI6FLXM_SSID,
+	 PEG2BPFI6FLXMRB2, "PEG2BPFI6FLXMRB2"},
+	{0x8086, 0x10c9, SILICOM_SVID, SILICOM_PEG4BPI6FC_SSID, PEG4BPI6FC,
+	 "PEG4BPI6FC"},
+	{0x8086, 0x10e6, SILICOM_SVID, SILICOM_PEG4BPFI6FC_SSID, PEG4BPFI6FC,
+	 "PEG4BPFI6FC"},
+	{0x8086, 0x10e6, SILICOM_SVID, SILICOM_PEG4BPFI6FCLX_SSID,
+	 PEG4BPFI6FCLX, "PEG4BPFI6FCLX"},
+	{0x8086, 0x10e6, SILICOM_SVID, SILICOM_PEG4BPFI6FCZX_SSID,
+	 PEG4BPFI6FCZX, "PEG4BPFI6FCZX"},
+	{0x8086, 0x10c9, SILICOM_SVID, SILICOM_PEG6BPI6_SSID, PEG6BPI6,
+	 "PEG6BPI6"},
+	{0x8086, 0x10c9, SILICOM_SVID, SILICOM_PEG2BPI6SC6_SSID, PEG2BPI6SC6,
+	 "PEG6BPI62SC6"},
+	{0x8086, 0x10c9, SILICOM_SVID, SILICOM_MEG2BPI6_SSID, MEG2BPI6,
+	 "MEG2BPI6"},
+	{0x8086, 0x10c9, SILICOM_SVID, SILICOM_XEG2BPI6_SSID, XEG2BPI6,
+	 "XEG2BPI6"},
+	{0x8086, 0x10c9, SILICOM_SVID, SILICOM_MEG4BPI6_SSID, MEG4BPI6,
+	 "MEG4BPI6"},
+	{0x8086, 0x10a9, SILICOM_SVID, SILICOM_PEG2BPFI5_SSID, PEG2BPFI5,
+	 "PEG2BPFI5"},
+	{0x8086, 0x10a9, SILICOM_SVID, SILICOM_PEG2BPFI5LX_SSID, PEG2BPFI5LX,
+	 "PEG2BPFI5LX"},
+	{0x8086, 0x105f, SILICOM_SVID, SILICOM_PXEG4BPFI_SSID, PXEG4BPFI,
+	 "PXEG4BPFI-SD"},
+	{0x8086, PCI_ANY_ID, SILICOM_SVID, SILICOM_M1EG2BPI6_SSID, M1EG2BPI6,
+	 "MxEG2BPI6"},
+	{0x8086, PCI_ANY_ID, SILICOM_SVID, SILICOM_M1EG2BPFI6_SSID, M1EG2BPFI6,
+	 "MxEG2BPFI6"},
+	{0x8086, PCI_ANY_ID, SILICOM_SVID, SILICOM_M1EG2BPFI6LX_SSID,
+	 M1EG2BPFI6LX, "MxEG2BPFI6LX"},
+	{0x8086, PCI_ANY_ID, SILICOM_SVID, SILICOM_M1EG2BPFI6ZX_SSID,
+	 M1EG2BPFI6ZX, "MxEG2BPFI6ZX"},
+	{0x8086, PCI_ANY_ID, SILICOM_SVID, SILICOM_M1EG4BPI6_SSID, M1EG4BPI6,
+	 "MxEG4BPI6"},
+	{0x8086, PCI_ANY_ID, SILICOM_SVID, SILICOM_M1EG4BPFI6_SSID, M1EG4BPFI6,
+	 "MxEG4BPFI6"},
+	{0x8086, PCI_ANY_ID, SILICOM_SVID, SILICOM_M1EG4BPFI6LX_SSID,
+	 M1EG4BPFI6LX, "MxEG4BPFI6LX"},
+	{0x8086, PCI_ANY_ID, SILICOM_SVID, SILICOM_M1EG4BPFI6ZX_SSID,
+	 M1EG4BPFI6ZX, "MxEG4BPFI6ZX"},
+	{0x8086, PCI_ANY_ID, SILICOM_SVID, SILICOM_M1EG6BPI6_SSID, M1EG6BPI6,
+	 "MxEG6BPI6"},
+	{0x8086, PCI_ANY_ID, SILICOM_SVID, SILICOM_M1E2G4BPi80_SSID,
+	 M1E2G4BPi80, "MxE2G4BPi80"},
+	{0x8086, PCI_ANY_ID, SILICOM_SVID, SILICOM_M1E2G4BPFi80_SSID,
+	 M1E2G4BPFi80, "MxE2G4BPFi80"},
+	{0x8086, PCI_ANY_ID, SILICOM_SVID, SILICOM_M1E2G4BPFi80LX_SSID,
+	 M1E2G4BPFi80LX, "MxE2G4BPFi80LX"},
+	{0x8086, PCI_ANY_ID, SILICOM_SVID, SILICOM_M1E2G4BPFi80ZX_SSID,
+	 M1E2G4BPFi80ZX, "MxE2G4BPFi80ZX"},
+	{0x8086, PCI_ANY_ID, SILICOM_SVID, SILICOM_M2EG2BPFI6_SSID, M2EG2BPFI6,
+	 "M2EG2BPFI6"},
+	{0x8086, PCI_ANY_ID, SILICOM_SVID, SILICOM_M2EG2BPFI6LX_SSID,
+	 M2EG2BPFI6LX, "M2EG2BPFI6LX"},
+	{0x8086, PCI_ANY_ID, SILICOM_SVID, SILICOM_M2EG2BPFI6ZX_SSID,
+	 M2EG2BPFI6ZX, "M2EG2BPFI6ZX"},
+	{0x8086, PCI_ANY_ID, SILICOM_SVID, SILICOM_M2EG4BPI6_SSID,
+	 M2EG4BPI6, "M2EG4BPI6"},
+	{0x8086, PCI_ANY_ID, SILICOM_SVID, SILICOM_M2EG4BPFI6_SSID, M2EG4BPFI6,
+	 "M2EG4BPFI6"},
+	{0x8086, PCI_ANY_ID, SILICOM_SVID, SILICOM_M2EG4BPFI6LX_SSID,
+	 M2EG4BPFI6LX, "M2EG4BPFI6LX"},
+	{0x8086, PCI_ANY_ID, SILICOM_SVID, SILICOM_M2EG4BPFI6ZX_SSID,
+	 M2EG4BPFI6ZX, "M2EG4BPFI6ZX"},
+	{0x8086, PCI_ANY_ID, SILICOM_SVID, SILICOM_M2EG6BPI6_SSID, M2EG6BPI6,
+	 "M2EG6BPI6"},
+	{0x8086, 0x10c9, SILICOM_SVID, SILICOM_PEG2DBI6_SSID, PEG2DBI6,
+	 "PEG2DBI6"},
+	{0x8086, 0x10e6, SILICOM_SVID, SILICOM_PEG2DBFI6_SSID, PEG2DBFI6,
+	 "PEG2DBFI6"},
+	{0x8086, 0x10e6, SILICOM_SVID, SILICOM_PEG2DBFI6LX_SSID, PEG2DBFI6LX,
+	 "PEG2DBFI6LX"},
+	{0x8086, 0x10e6, SILICOM_SVID, SILICOM_PEG2DBFI6ZX_SSID, PEG2DBFI6ZX,
+	 "PEG2DBFI6ZX"},
+	{0x8086, 0x10F9, SILICOM_SVID, SILICOM_PE210G2DBi9SR_SSID,
+	 PE210G2DBi9SR, "PE210G2DBi9SR"},
+	{0x8086, 0x10F9, 0X1B2E , SILICOM_PE210G2DBi9SRRB_SSID,
+	 PE210G2DBi9SRRB2, "PE210G2DBi9SRRB2"},
+	{0x8086, 0x10F9, SILICOM_SVID, SILICOM_PE210G2DBi9LR_SSID,
+	 PE210G2DBi9LR, "PE210G2DBi9LR"},
+	{0x8086, 0x10F9, 0X1B2E, SILICOM_PE210G2DBi9LRRB_SSID,
+	 PE210G2DBi9LRRB2, "PE210G2DBi9LRRB2"},
+	{0x8086, 0x10F9, SILICOM_SVID, SILICOM_PE310G4DBi940SR_SSID,
+	 PE310G4DBi940SR, "PE310G4DBi9SR"},
+	{0x8086, 0x10F9, 0X1B2E, SILICOM_PE310G4DBi940SR_SSID,
+	 PE310G4DBi940SRRB2, "PE310G4DBi9SRRB2"},
+	{0x8086, 0x10F9, SILICOM_SVID, SILICOM_PE310G4DBi940LR_SSID,
+	 PE310G4DBi940LR, "PE310G4DBi9LR"},
+	{0x8086, 0x10F9, 0X1B2E, SILICOM_PE310G4DBi940LR_SSID,
+	 PE310G4DBi940LRRB2, "PE310G4DBi9LRRB2"},
+	{0x8086, 0x10F9, SILICOM_SVID, SILICOM_PE310G4DBi940T_SSID,
+	 PE310G4DBi940T, "PE310G4DBi9T"},
+	{0x8086, 0x10F9, 0X1B2E, SILICOM_PE310G4DBi940T_SSID,
+	 PE310G4DBi940TRB2, "PE310G4DBi9TRB2"},
+	{0x8086, 0x10F9, SILICOM_SVID, SILICOM_PE310G4DBi9T_SSID,
+	 PE310G4DBi9T, "PE310G4DBi9T"},
+	{0x8086, 0x10Fb, SILICOM_SVID, SILICOM_PE310G4BPi9T_SSID,
+	 PE310G4BPi9T, "PE310G4BPi9T"},
+	{0x8086, 0x10Fb, SILICOM_SVID, SILICOM_PE310G4BPi9SR_SSID,
+	 PE310G4BPi9SR, "PE310G4BPi9SR"},
+	{0x8086, 0x10Fb, SILICOM_SVID, SILICOM_PE310G4BPi9LR_SSID,
+	 PE310G4BPi9LR, "PE310G4BPi9LR"},
+	{0x8086, 0x10Fb, SILICOM_SVID, SILICOM_PE310G4BPi9SRD_SSID,
+	 PE310G4BPi9SRD, "PE310G4BPi9SRD"},
+	{0x8086, 0x10Fb, SILICOM_SVID, SILICOM_PE310G4BPi9LRD_SSID,
+	 PE310G4BPi9LRD, "PE310G4BPi9LRD"},
+	{0x8086, PCI_ANY_ID, SILICOM_SVID, SILICOM_PE2G4BPi80_SSID,
+	 PE2G4BPi80, "PE2G4BPi80"},
+	{0x8086, PCI_ANY_ID, SILICOM_SVID, SILICOM_PE2G4BPFi80_SSID,
+	 PE2G4BPFi80, "PE2G4BPFi80"},
+	{0x8086, PCI_ANY_ID, SILICOM_SVID, SILICOM_PE2G4BPFi80LX_SSID,
+	 PE2G4BPFi80LX, "PE2G4BPFi80LX"},
+	{0x8086, PCI_ANY_ID, SILICOM_SVID, SILICOM_PE2G4BPFi80ZX_SSID,
+	 PE2G4BPFi80ZX, "PE2G4BPFi80ZX"},
+	{0x8086, PCI_ANY_ID, SILICOM_SVID, SILICOM_PE2G4BPi80L_SSID,
+	 PE2G4BPi80L, "PE2G4BPi80L"},
+	{0x8086, PCI_ANY_ID, SILICOM_SVID, SILICOM_M6E2G8BPi80A_SSID,
+	 M6E2G8BPi80A, "MxE2G8BPi80A"},
+	{0x8086, PCI_ANY_ID, SILICOM_SVID, SILICOM_PE2G2BPi35_SSID, PE2G2BPi35,
+	 "PE2G2BPi35"},
+	{0x8086, PCI_ANY_ID, SILICOM_SVID, SILICOM_PAC1200BPi35_SSID,
+	 PAC1200BPi35, "PAC1200BPi35"},
+	{0x8086, PCI_ANY_ID, SILICOM_SVID, SILICOM_PE2G2BPFi35_SSID,
+	 PE2G2BPFi35, "PE2G2BPFi35"},
+	{0x8086, 0x1522, 0x1B2E , SILICOM_PE2G2BPFi35_SSID, PE2G2BPFi35ARB2,
+	 "PE2G2BPFi35ARB2"},
+	{0x8086, PCI_ANY_ID, SILICOM_SVID, SILICOM_PE2G2BPFi35LX_SSID,
+	 PE2G2BPFi35LX, "PE2G2BPFi35LX"},
+	{0x8086, 0x1522, 0x1B2E , SILICOM_PE2G2BPFi35LX_SSID,
+	 PE2G2BPFi35ALXRB2, "PE2G2BPFi35ALXRB2"},
+	{0x8086, PCI_ANY_ID, SILICOM_SVID, SILICOM_PE2G2BPFi35ZX_SSID,
+	 PE2G2BPFi35ZX, "PE2G2BPFi35ZX"},
+	{0x8086, PCI_ANY_ID, SILICOM_SVID, SILICOM_PE2G4BPi35_SSID, PE2G4BPi35,
+	 "PE2G4BPi35"},
+	{0x8086, PCI_ANY_ID, SILICOM_SVID, SILICOM_PE2G4BPi35L_SSID,
+	 PE2G4BPi35L, "PE2G4BPi35L"},
+	{0x8086, 0x1521, 0x1B2E , SILICOM_PE2G4BPi35L_SSID, PE2G4BPi35ALRB2,
+	 "PE2G4BPi35ALRB2"},
+	{0x8086, PCI_ANY_ID, SILICOM_SVID, SILICOM_PE2G4BPFi35_SSID,
+	 PE2G4BPFi35, "PE2G4BPFi35"},
+	{0x8086, 0x1522, 0x1B2E , SILICOM_PE2G4BPFi35_SSID, PE2G4BPFi35ARB2,
+	 "PE2G4BPFi35ARB2"},
+	{0x8086, 0x1522, SILICOM_SVID, SILICOM_PE2G4BPFi35CS_SSID,
+	 PE2G4BPFi35CS, "PE2G4BPFi35CS"},
+	{0x8086, PCI_ANY_ID, SILICOM_SVID, SILICOM_PE2G4BPFi35LX_SSID,
+	 PE2G4BPFi35LX, "PE2G4BPFi35LX"},
+	{0x8086, 0x1522, 0x1B2E , SILICOM_PE2G4BPFi35LX_SSID, PE2G4BPFi35ALXRB2,
+	 "PE2G4BPFi35ALXRB2"},
+	{0x8086, PCI_ANY_ID, SILICOM_SVID, SILICOM_PE2G4BPFi35ZX_SSID,
+	 PE2G4BPFi35ZX, "PE2G4BPFi35ZX"},
+	{0x8086, 0x1521, SILICOM_SVID, SILICOM_M1E2G4BPi35_SSID, M1E2G4BPi35,
+	 "M1E2G4BPi35"},
+	{0x8086, 0x1521, 0x1304 , SILICOM_M1E2G4BPi35JP_SSID, M1E2G4BPi35JP,
+	 "M1E2G4BPi35JP"},
+	{0x8086, 0x1521, 0x1304 , SILICOM_M1E2G4BPi35JP1_SSID, M1E2G4BPi35JP1,
+	 "M1E2G4BPi35JP1"},
+	{0x8086, 0x1522, SILICOM_SVID, SILICOM_M1E2G4BPFi35_SSID, M1E2G4BPFi35,
+	 "M1E2G4BPFi35"},
+	{0x8086, 0x1522, SILICOM_SVID, SILICOM_M1E2G4BPFi35LX_SSID,
+	 M1E2G4BPFi35LX, "M1E2G4BPFi35LX"},
+	{0x8086, 0x1522, SILICOM_SVID, SILICOM_M1E2G4BPFi35ZX_SSID,
+	 M1E2G4BPFi35ZX, "M1E2G4BPFi35ZX"},
+	{0x8086, PCI_ANY_ID, SILICOM_SVID, SILICOM_PE2G6BPi35_SSID,
+	 PE2G6BPi35, "PE2G6BPi35"},
+	{0x8086, PCI_ANY_ID, SILICOM_SVID, 0xaa0, PE2G6BPi35CX,
+	 "PE2G6BPi35CX"},
+	{0x8086, PCI_ANY_ID, SILICOM_SVID, 0xaa1, PE2G6BPi35CX,
+	 "PE2G6BPi35CX"},
+	{0x8086, PCI_ANY_ID, SILICOM_SVID, 0xaa2, PE2G6BPi35CX,
+	 "PE2G6BPi35CX"},
+	{0x8086, PCI_ANY_ID, SILICOM_SVID, 0xaa3, PE2G6BPi35CX,
+	 "PE2G6BPi35CX"},
+	{0x8086, PCI_ANY_ID, SILICOM_SVID, 0xaa4, PE2G6BPi35CX,
+	 "PE2G6BPi35CX"},
+	{0x8086, PCI_ANY_ID, SILICOM_SVID, 0xaa5, PE2G6BPi35CX,
+	 "PE2G6BPi35CX"},
+	{0x8086, PCI_ANY_ID, SILICOM_SVID, 0xaa6, PE2G6BPi35CX,
+	 "PE2G6BPi35CX"},
+	{0x8086, PCI_ANY_ID, SILICOM_SVID, 0xaa7, PE2G6BPi35CX,
+	 "PE2G6BPi35CX"},
+	{0x8086, PCI_ANY_ID, SILICOM_SVID, 0xaa8, PE2G6BPi35CX,
+	 "PE2G6BPi35CX"},
+	{0x8086, PCI_ANY_ID, SILICOM_SVID, 0xaa9, PE2G6BPi35CX,
+	 "PE2G6BPi35CX"},
+	{0x8086, PCI_ANY_ID, SILICOM_SVID, 0xaaa, PE2G6BPi35CX,
+	 "PE2G6BPi35CX"},
+	{0x8086, PCI_ANY_ID, SILICOM_SVID, 0xaab, PE2G6BPi35CX,
+	 "PE2G6BPi35CX"},
+	{0x8086, PCI_ANY_ID, SILICOM_SVID, 0xaac, PE2G6BPi35CX,
+	 "PE2G6BPi35CX"},
+	{0x8086, PCI_ANY_ID, SILICOM_SVID, 0xaad, PE2G6BPi35CX,
+	 "PE2G6BPi35CX"},
+	{0x8086, PCI_ANY_ID, SILICOM_SVID, 0xaae, PE2G6BPi35CX,
+	 "PE2G6BPi35CX"},
+	{0x8086, PCI_ANY_ID, SILICOM_SVID, 0xaaf, PE2G6BPi35CX,
+	 "PE2G6BPi35CX"},
+	{0x8086, PCI_ANY_ID, SILICOM_SVID, 0xab0, PE2G6BPi35CX,
+	 "PE2G6BPi35CX"},
+	{0x8086, PCI_ANY_ID, SILICOM_SVID, 0xab1, PE2G6BPi35CX,
+	 "PE2G6BPi35CX"},
+	{0x8086, PCI_ANY_ID, SILICOM_SVID, 0xab2, PE2G6BPi35CX,
+	 "PE2G6BPi35CX"},
+	{0x8086, PCI_ANY_ID, SILICOM_SVID, 0xab3, PE2G6BPi35CX,
+	 "PE2G6BPi35CX"},
+	{0x8086, PCI_ANY_ID, SILICOM_SVID, 0xab4, PE2G6BPi35CX,
+	 "PE2G6BPi35CX"},
+	{0x8086, PCI_ANY_ID, SILICOM_SVID, 0xab5, PE2G6BPi35CX,
+	 "PE2G6BPi35CX"},
+	{0x8086, PCI_ANY_ID, SILICOM_SVID, 0xab6, PE2G6BPi35CX,
+	 "PE2G6BPi35CX"},
+	{0x8086, PCI_ANY_ID, SILICOM_SVID, 0xab7, PE2G6BPi35CX,
+	 "PE2G6BPi35CX"},
+	{0x8086, PCI_ANY_ID, SILICOM_SVID, 0xab8, PE2G6BPi35CX,
+	 "PE2G6BPi35CX"},
+	{0x8086, PCI_ANY_ID, SILICOM_SVID, 0xab9, PE2G6BPi35CX,
+	 "PE2G6BPi35CX"},
+	{0x8086, PCI_ANY_ID, SILICOM_SVID, 0xaba, PE2G6BPi35CX,
+	 "PE2G6BPi35CX"},
+	{0x8086, PCI_ANY_ID, SILICOM_SVID, 0xabb, PE2G6BPi35CX,
+	 "PE2G6BPi35CX"},
+	{0x8086, PCI_ANY_ID, SILICOM_SVID, 0xabc, PE2G6BPi35CX,
+	 "PE2G6BPi35CX"},
+	{0x8086, PCI_ANY_ID, SILICOM_SVID, 0xabd, PE2G6BPi35CX,
+	 "PE2G6BPi35CX"},
+	{0x8086, PCI_ANY_ID, SILICOM_SVID, 0xabe, PE2G6BPi35CX,
+	 "PE2G6BPi35CX"},
+	{0x8086, PCI_ANY_ID, SILICOM_SVID, 0xabf, PE2G6BPi35CX,
+	 "PE2G6BPi35CX"},
+	{0x8086, PCI_ANY_ID, SILICOM_SVID, SILICOM_PE2G2BPi80_SSID,
+	 PE2G2BPi80, "PE2G2BPi80"},
+	{0x8086, PCI_ANY_ID, SILICOM_SVID, SILICOM_PE2G2BPFi80_SSID,
+	 PE2G2BPFi80, "PE2G2BPFi80"},
+	{0x8086, PCI_ANY_ID, SILICOM_SVID, SILICOM_PE2G2BPFi80LX_SSID,
+	 PE2G2BPFi80LX, "PE2G2BPFi80LX"},
+	{0x8086, PCI_ANY_ID, SILICOM_SVID, SILICOM_PE2G2BPFi80ZX_SSID,
+	 PE2G2BPFi80ZX, "PE2G2BPFi80ZX"},
+	{0x8086, 0x10c9, SILICOM_SVID, SILICOM_MEG2BPI6_SSID, MEG2BPI6,
+	 "MEG2BPI6"},
+	{0x8086, 0x10c9, SILICOM_SVID, SILICOM_XEG2BPI6_SSID, XEG2BPI6,
+	 "XEG2BPI6"},
+	{0x8086, 0x10fb, SILICOM_SVID, SILICOM_M1E10G2BPI9CX4_SSID,
+	 M1E10G2BPI9CX4, "MxE210G2BPI9CX4"},
+	{0x8086, 0x10fb, SILICOM_SVID, SILICOM_M1E10G2BPI9SR_SSID,
+	 M1E10G2BPI9SR, "MxE210G2BPI9SR"},
+	{0x8086, 0x10fb, SILICOM_SVID, SILICOM_M1E10G2BPI9LR_SSID,
+	 M1E10G2BPI9LR, "MxE210G2BPI9LR"},
+	{0x8086, 0x10fb, SILICOM_SVID, SILICOM_M2E10G2BPI9CX4_SSID,
+	 M2E10G2BPI9CX4, "M2E10G2BPI9CX4"},
+	{0x8086, 0x10fb, SILICOM_SVID, SILICOM_M2E10G2BPI9SR_SSID,
+	 M2E10G2BPI9SR, "M2E10G2BPI9SR"},
+	{0x8086, 0x10fb, SILICOM_SVID, SILICOM_M2E10G2BPI9LR_SSID,
+	 M2E10G2BPI9LR, "M2E10G2BPI9LR"},
+	{0x8086, 0x10fb, SILICOM_SVID, SILICOM_M2E10G2BPI9T_SSID,
+	 M2E10G2BPI9T, "M2E10G2BPI9T"},
+	{0x8086, 0x10fb, SILICOM_SVID, SILICOM_PE210G2BPI9CX4_SSID,
+	 PE210G2BPI9CX4, "PE210G2BPI9CX4"},
+	{0x8086, 0x10fb, SILICOM_SVID, SILICOM_PE210G2BPI9SR_SSID,
+	 PE210G2BPI9SR, "PE210G2BPI9SR"},
+	{0x8086, 0x10fb, SILICOM_SVID, SILICOM_PE210G2BPI9LR_SSID,
+	 PE210G2BPI9LR, "PE210G2BPI9LR"},
+	{0x8086, 0x10fb, SILICOM_SVID, SILICOM_PE210G2BPI9SRD_SSID,
+	 PE210G2BPI9SRD, "PE210G2BPI9SRD"},
+	{0x8086, 0x10fb, SILICOM_SVID, SILICOM_PE210G2BPI9LRD_SSID,
+	 PE210G2BPI9LRD, "PE210G2BPI9LRD"},
+	{0x8086, 0x10fb, SILICOM_SVID, SILICOM_PE210G2BPI9T_SSID,
+	 PE210G2BPI9T, "PE210G2BPI9T"},
+	{0x8086, 0x10fb, SILICOM_SVID, SILICOM_PE210G2BPI9T_SSID,
+	 PE210G2BPI9T, "PE210G2BPI9T"},
+	{0x8086, 0x10fb, 0x1304, SILICOM_M1E210G2BPI9SRDJP_SSID,
+	 M1E210G2BPI9SRDJP, "M1E210G2BPI9SRDJP"},
+	{0x8086, 0x10fb, 0x1304, SILICOM_M1E210G2BPI9SRDJP1_SSID,
+	 M1E210G2BPI9SRDJP1, "M1E210G2BPI9SRDJP1"},
+	{0x8086, 0x10fb, 0x1304, SILICOM_M1E210G2BPI9LRDJP_SSID,
+	 M1E210G2BPI9LRDJP, "M1E210G2BPI9LRDJP"},
+	{0x8086, 0x10fb, 0x1304, SILICOM_M1E210G2BPI9LRDJP1_SSID,
+	 M1E210G2BPI9LRDJP1, "M1E210G2BPI9LRDJP1"},
+	{0x8086, PCI_ANY_ID, SILICOM_SVID, SILICOM_M6E2G8BPi80_SSID,
+	 M6E2G8BPi80, "MxE2G8BPi80"},
+	{0x8086, 0x1528, SILICOM_SVID, SILICOM_PE210G2BPi40_SSID,
+	 PE210G2BPi40, "PE210G2BPi40T"},
+	{0x8086, 0x1528, SILICOM_SVID, SILICOM_PE310G4BPi40_SSID,
+	 PE310G4BPi40, "PE310G4BPi40T"},
+	{0x8086, 0x1528, SILICOM_SVID, SILICOM_M1E210G2BPI40T_SSID,
+	 M1E210G2BPI40T, "M1E210G2BPi40T"},
+	/* required last entry */
+	{0,}
+};
+
+static void find_fw(struct bpctl_dev *dev)
+{
+	unsigned long mmio_start, mmio_len;
+	struct pci_dev *pdev1 = dev->pdev;
+	int cnt = 100;
+
+	if ((OLD_IF_SERIES(dev->subdevice)) ||
+		(INTEL_IF_SERIES(dev->subdevice)))
+		dev->bp_fw_ver = 0xff;
+	else
+		dev->bp_fw_ver = bypass_fw_ver(dev);
+
+	if (dev->nic_type != bp_10gb || dev->bp_fw_ver != 0xff)
+		goto out;
+
+	while (cnt--) {
+		iounmap((void *)dev->mem_map);
+		mmio_start = pci_resource_start(pdev1, 0);
+		mmio_len = pci_resource_len(pdev1, 0);
+		dev->mem_map = ioremap(mmio_start, mmio_len);
+
+		dev->bp_fw_ver = bypass_fw_ver(dev);
+		if (dev->bp_fw_ver == 0xa8)
+			break;
+	}
+out:
+	pr_info("Bypass firmware version: 0x%x\n", dev->bp_fw_ver);
+}
+
+static int init_one(struct bpctl_dev *dev, struct bpmod_info *info,
+			struct pci_dev *pdev1)
+{
+	unsigned long mmio_start, mmio_len;
+
+	mmio_start = pci_resource_start(pdev1, 0);
+	mmio_len = pci_resource_len(pdev1, 0);
+	if ((!mmio_len) || (!mmio_start))
+		return 0;
+	dev->pdev = pdev1;
+
+	dev->desc = dev_desc[info->index].name;
+	dev->name = info->bp_name;
+	dev->device = info->device;
+	dev->vendor = info->vendor;
+	dev->subdevice = info->subdevice;
+	dev->subvendor = info->subvendor;
+	dev->func = PCI_FUNC(pdev1->devfn);
+	dev->slot = PCI_SLOT(pdev1->devfn);
+	dev->bus = pdev1->bus->number;
+	dev->mem_map = ioremap(mmio_start, mmio_len);
+	spin_lock_init(&dev->bypass_wr_lock);
+	if (BP10G9_IF_SERIES(dev->subdevice))
+		dev->nic_type = bp_10g9;
+	if (BP10G_IF_SERIES(dev->subdevice))
+		dev->nic_type = bp_10g;
+	if (PEG540_IF_SERIES(dev->subdevice))
+		dev->nic_type = bp_540;
+	if (PEGF5_IF_SERIES(dev->subdevice))
+		dev->nic_type = bp_fiber5;
+	if (PEG80_IF_SERIES(dev->subdevice))
+		dev->nic_type = bp_i80;
+	if (PEGF80_IF_SERIES(dev->subdevice))
+		dev->nic_type = bp_i80;
+	if ((dev->subdevice & 0xfe0) == 0xaa0)
+		dev->nic_type = bp_i80;
+	if (BP10GB_IF_SERIES(dev->subdevice)) {
+		if (dev->ifindex == 0) {
+			pr_err("Please load network driver for %s adapter!\n",
+				dev->name);
+			return -1;
+		}
+
+		if (dev->ndev && !(dev->ndev->flags & IFF_UP)) {
+			pr_err(
+			"Please bring up network interfaces for %s adapter!\n",
+			dev->name);
+			return -1;
+		}
+		dev->nic_type = bp_10gb;
+	}
+
+	if (dev->nic_type != bp_10g9) {
+		if (is_bypass(dev)) {
+			pr_info("%s found\n", dev->name);
+			find_fw(dev);
+		}
+		dev->wdt_status = WDT_STATUS_UNKNOWN;
+		dev->reset_time = 0;
+		atomic_set(&dev->wdt_busy, 0);
+		dev->bp_status_un = 1;
+
+		bypass_caps_init(dev);
+
+		init_bypass_wd_auto(dev);
+		init_bypass_tpl_auto(dev);
+		if (NOKIA_SERIES(dev->subdevice))
+			reset_cont(dev);
+	}
+	return 0;
+}
+
+
+/* Initialize the module - Register the character device */
+
+
+static int __init bypass_init_module(void)
+{
+	int ret_val, i, idx, idx_dev = 0;
+	struct pci_dev *pdev1 = NULL;
+	struct bpctl_dev *dev;
+
+	pr_info(BP_MOD_DESCR " ver " BP_MOD_VER "\n");
+	ret_val = register_chrdev(major_num, DEVICE_NAME, &Fops);
+	if (ret_val < 0) {
+		pr_err("%s failed with %d\n", DEVICE_NAME, ret_val);
+		return ret_val;
+	}
+	major_num = ret_val;    /* dynamic */
+	for (idx = 0; tx_ctl_pci_tbl[idx].vendor; idx++) {
+		while ((pdev1 = pci_get_subsys(tx_ctl_pci_tbl[idx].vendor,
+						tx_ctl_pci_tbl[idx].device,
+						tx_ctl_pci_tbl[idx].subvendor,
+						tx_ctl_pci_tbl[idx].subdevice,
+						pdev1))) {
+
+			device_num++;
+		}
+	}
+	if (!device_num) {
+		pr_info("No such device\n");
+		unregister_chrdev(major_num, DEVICE_NAME);
+		return -1;
+	}
+
+	bpctl_dev_arr = kmalloc((device_num) * sizeof(struct bpctl_dev),
+				GFP_KERNEL);
+
+	if (!bpctl_dev_arr) {
+		pr_err("Allocation error\n");
+		unregister_chrdev(major_num, DEVICE_NAME);
+		return -1;
+	}
+	memset(bpctl_dev_arr, 0, ((device_num) * sizeof(struct bpctl_dev)));
+
+	pdev1 = NULL;
+	dev = bpctl_dev_arr;
+	for (idx = 0; tx_ctl_pci_tbl[idx].vendor; idx++) {
+		while ((pdev1 = pci_get_subsys(tx_ctl_pci_tbl[idx].vendor,
+						tx_ctl_pci_tbl[idx].device,
+						tx_ctl_pci_tbl[idx].subvendor,
+						tx_ctl_pci_tbl[idx].subdevice,
+						pdev1))) {
+			if (init_one(dev, &tx_ctl_pci_tbl[idx], pdev1) < 0) {
+				kfree(bpctl_dev_arr);
+				unregister_chrdev(major_num, DEVICE_NAME);
+				return -1;
+			}
+			if (dev->pdev)
+				dev++;
+		}
+	}
+	if_scan_init();
+
+	sema_init(&bpctl_sema, 1);
+	spin_lock_init(&bpvm_lock);
+
+	for (idx_dev = 0, dev = bpctl_dev_arr;
+		 idx_dev < device_num && dev->pdev;
+		 idx_dev++, dev++) {
+		if (dev->nic_type != bp_10g9)
+			continue;
+		if (is_bypass(dev)) {
+			pr_info("%s found\n", dev->name);
+			dev->bp_fw_ver = bypass_fw_ver(dev);
+			pr_info("Bypass firmware version: 0x%x\n",
+				 dev->bp_fw_ver);
+		}
+		dev->wdt_status = WDT_STATUS_UNKNOWN;
+		dev->reset_time = 0;
+		atomic_set(&dev->wdt_busy, 0);
+		dev->bp_status_un = 1;
+
+		bypass_caps_init(dev);
+
+		init_bypass_wd_auto(dev);
+		init_bypass_tpl_auto(dev);
+	}
+
+	bp_procfs_dir = proc_mkdir(BP_PROC_DIR, init_net.proc_net);
+	for (i = 0; i < device_num; i++) {
+		if (bpctl_dev_arr[i].ifindex) {
+			bypass_proc_remove_dev_sd(&bpctl_dev_arr[i]);
+			bypass_proc_create_dev_sd(&bpctl_dev_arr[i]);
+		}
+	}
+
+	register_netdevice_notifier(&bp_notifier_block);
+
+	return 0;
+}
+
+
+/* Cleanup - unregister the appropriate file from /proc */
+
+static void __exit bypass_cleanup_module(void)
+{
+	int i;
+
+	unregister_netdevice_notifier(&bp_notifier_block);
+
+	for (i = 0; i < device_num; i++) {
+		/* unsigned long flags; */
+		remove_bypass_wd_auto(&bpctl_dev_arr[i]);
+		bpctl_dev_arr[i].reset_time = 0;
+
+		remove_bypass_tpl_auto(&bpctl_dev_arr[i]);
+	}
+	remove_proc_entry(BP_PROC_DIR, init_net.proc_net);
+
+	/* unmap all devices */
+	for (i = 0; i < device_num; i++)
+		iounmap((void *)(bpctl_dev_arr[i].mem_map));
+
+	/* free all devices space */
+	kfree(bpctl_dev_arr);
+
+/* Unregister the device */
+	unregister_chrdev(major_num, DEVICE_NAME);
+}
+
+module_init(bypass_init_module);
+module_exit(bypass_cleanup_module);
+
+int is_bypass_sd(int ifindex)
+{
+	return is_bypass_fn(get_dev_idx_p(ifindex));
+}
+EXPORT_SYMBOL(is_bypass_sd);
+
+int set_bypass_sd(int ifindex, int bypass_mode)
+{
+	return set_bypass_fn(get_dev_idx_p(ifindex), bypass_mode);
+}
+EXPORT_SYMBOL(set_bypass_sd);
+
+int get_bypass_sd(int ifindex)
+{
+	return get_bypass_fn(get_dev_idx_p(ifindex));
+}
+EXPORT_SYMBOL(get_bypass_sd);
+
+int get_bypass_change_sd(int ifindex)
+{
+	return get_bypass_change_fn(get_dev_idx_p(ifindex));
+}
+EXPORT_SYMBOL(get_bypass_change_sd);
+
+int set_dis_bypass_sd(int ifindex, int dis_param)
+{
+	return set_dis_bypass_fn(get_dev_idx_p(ifindex), dis_param);
+}
+EXPORT_SYMBOL(set_dis_bypass_sd);
+
+int get_dis_bypass_sd(int ifindex)
+{
+	return get_dis_bypass_fn(get_dev_idx_p(ifindex));
+}
+EXPORT_SYMBOL(get_dis_bypass_sd);
+
+int set_bypass_pwoff_sd(int ifindex, int bypass_mode)
+{
+	return set_bypass_pwoff_fn(get_dev_idx_p(ifindex), bypass_mode);
+}
+EXPORT_SYMBOL(set_bypass_pwoff_sd);
+
+int get_bypass_pwoff_sd(int ifindex)
+{
+	return get_bypass_pwoff_fn(get_dev_idx_p(ifindex));
+}
+EXPORT_SYMBOL(get_bypass_pwoff_sd);
+
+int set_bypass_pwup_sd(int ifindex, int bypass_mode)
+{
+	return set_bypass_pwup_fn(get_dev_idx_p(ifindex), bypass_mode);
+}
+EXPORT_SYMBOL(set_bypass_pwup_sd);
+
+int get_bypass_pwup_sd(int ifindex)
+{
+	return get_bypass_pwup_fn(get_dev_idx_p(ifindex));
+}
+EXPORT_SYMBOL(get_bypass_pwup_sd);
+
+int set_bypass_wd_sd(int if_index, int ms_timeout, int *ms_timeout_set)
+{
+	if ((is_bypass(get_dev_idx_p(if_index))) <= 0)
+		return  -1;
+	*ms_timeout_set = set_bypass_wd_fn(get_dev_idx_p(if_index), ms_timeout);
+	return 0;
+}
+EXPORT_SYMBOL(set_bypass_wd_sd);
+
+int get_bypass_wd_sd(int ifindex, int *timeout)
+{
+	return get_bypass_wd_fn(get_dev_idx_p(ifindex), timeout);
+}
+EXPORT_SYMBOL(get_bypass_wd_sd);
+
+int get_wd_expire_time_sd(int ifindex, int *time_left)
+{
+	return get_wd_expire_time_fn(get_dev_idx_p(ifindex), time_left);
+}
+EXPORT_SYMBOL(get_wd_expire_time_sd);
+
+int reset_bypass_wd_timer_sd(int ifindex)
+{
+	return reset_bypass_wd_timer_fn(get_dev_idx_p(ifindex));
+}
+EXPORT_SYMBOL(reset_bypass_wd_timer_sd);
+
+int get_wd_set_caps_sd(int ifindex)
+{
+	return get_wd_set_caps_fn(get_dev_idx_p(ifindex));
+}
+EXPORT_SYMBOL(get_wd_set_caps_sd);
+
+int set_std_nic_sd(int ifindex, int nic_mode)
+{
+	return set_std_nic_fn(get_dev_idx_p(ifindex), nic_mode);
+}
+EXPORT_SYMBOL(set_std_nic_sd);
+
+int get_std_nic_sd(int ifindex)
+{
+	return get_std_nic_fn(get_dev_idx_p(ifindex));
+}
+EXPORT_SYMBOL(get_std_nic_sd);
+
+int set_tap_sd(int ifindex, int tap_mode)
+{
+	return set_tap_fn(get_dev_idx_p(ifindex), tap_mode);
+}
+EXPORT_SYMBOL(set_tap_sd);
+
+int get_tap_sd(int ifindex)
+{
+	return get_tap_fn(get_dev_idx_p(ifindex));
+}
+EXPORT_SYMBOL(get_tap_sd);
+
+int set_tap_pwup_sd(int ifindex, int tap_mode)
+{
+	return set_tap_pwup_fn(get_dev_idx_p(ifindex), tap_mode);
+}
+EXPORT_SYMBOL(set_tap_pwup_sd);
+
+int get_tap_pwup_sd(int ifindex)
+{
+	return get_tap_pwup_fn(get_dev_idx_p(ifindex));
+}
+EXPORT_SYMBOL(get_tap_pwup_sd);
+
+int get_tap_change_sd(int ifindex)
+{
+	return get_tap_change_fn(get_dev_idx_p(ifindex));
+}
+EXPORT_SYMBOL(get_tap_change_sd);
+
+int set_dis_tap_sd(int ifindex, int dis_param)
+{
+	return set_dis_tap_fn(get_dev_idx_p(ifindex), dis_param);
+}
+EXPORT_SYMBOL(set_dis_tap_sd);
+
+int get_dis_tap_sd(int ifindex)
+{
+	return get_dis_tap_fn(get_dev_idx_p(ifindex));
+}
+EXPORT_SYMBOL(get_dis_tap_sd);
+
+int set_bp_disc_sd(int ifindex, int disc_mode)
+{
+	return set_disc_fn(get_dev_idx_p(ifindex), disc_mode);
+}
+EXPORT_SYMBOL(set_bp_disc_sd);
+
+int get_bp_disc_sd(int ifindex)
+{
+	return get_disc_fn(get_dev_idx_p(ifindex));
+}
+EXPORT_SYMBOL(get_bp_disc_sd);
+
+int set_bp_disc_pwup_sd(int ifindex, int disc_mode)
+{
+	return set_disc_pwup_fn(get_dev_idx_p(ifindex), disc_mode);
+}
+EXPORT_SYMBOL(set_bp_disc_pwup_sd);
+
+int get_bp_disc_pwup_sd(int ifindex)
+{
+	return get_disc_pwup_fn(get_dev_idx_p(ifindex));
+}
+EXPORT_SYMBOL(get_bp_disc_pwup_sd);
+
+int get_bp_disc_change_sd(int ifindex)
+{
+	return get_disc_change_fn(get_dev_idx_p(ifindex));
+}
+EXPORT_SYMBOL(get_bp_disc_change_sd);
+
+int set_bp_dis_disc_sd(int ifindex, int dis_param)
+{
+	return set_dis_disc_fn(get_dev_idx_p(ifindex), dis_param);
+}
+EXPORT_SYMBOL(set_bp_dis_disc_sd);
+
+int get_bp_dis_disc_sd(int ifindex)
+{
+	return get_dis_disc_fn(get_dev_idx_p(ifindex));
+}
+EXPORT_SYMBOL(get_bp_dis_disc_sd);
+
+int get_wd_exp_mode_sd(int ifindex)
+{
+	return get_wd_exp_mode_fn(get_dev_idx_p(ifindex));
+}
+EXPORT_SYMBOL(get_wd_exp_mode_sd);
+
+int set_wd_exp_mode_sd(int ifindex, int param)
+{
+	return set_wd_exp_mode_fn(get_dev_idx_p(ifindex), param);
+}
+EXPORT_SYMBOL(set_wd_exp_mode_sd);
+
+int set_tx_sd(int ifindex, int tx_state)
+{
+	return set_tx_fn(get_dev_idx_p(ifindex), tx_state);
+}
+EXPORT_SYMBOL(set_tx_sd);
+
+int set_tpl_sd(int ifindex, int tpl_state)
+{
+	return set_tpl_fn(get_dev_idx_p(ifindex), tpl_state);
+}
+EXPORT_SYMBOL(set_tpl_sd);
+
+int set_bp_hw_reset_sd(int ifindex, int status)
+{
+	return set_bp_hw_reset_fn(get_dev_idx_p(ifindex), status);
+}
+EXPORT_SYMBOL(set_bp_hw_reset_sd);
+
+int set_wd_autoreset_sd(int ifindex, int param)
+{
+	return set_wd_autoreset_fn(get_dev_idx_p(ifindex), param);
+}
+EXPORT_SYMBOL(set_wd_autoreset_sd);
+
+int get_wd_autoreset_sd(int ifindex)
+{
+	return get_wd_autoreset_fn(get_dev_idx_p(ifindex));
+}
+EXPORT_SYMBOL(get_wd_autoreset_sd);
+
+int get_bypass_caps_sd(int ifindex)
+{
+	return get_bypass_caps_fn(get_dev_idx_p(ifindex));
+}
+EXPORT_SYMBOL(get_bypass_caps_sd);
+
+int get_bypass_slave_sd(int ifindex)
+{
+	struct bpctl_dev *pbpctl_dev_out;
+	int ret = get_bypass_slave_fn(get_dev_idx_p(ifindex), &pbpctl_dev_out);
+
+	if (ret == 1)
+		return pbpctl_dev_out->ifindex;
+	return  -1;
+}
+EXPORT_SYMBOL(get_bypass_slave_sd);
+
+int get_tx_sd(int ifindex)
+{
+	return get_tx_fn(get_dev_idx_p(ifindex));
+}
+EXPORT_SYMBOL(get_tx_sd);
+
+int get_tpl_sd(int ifindex)
+{
+	return get_tpl_fn(get_dev_idx_p(ifindex));
+}
+EXPORT_SYMBOL(get_tpl_sd);
+
+int get_bp_hw_reset_sd(int ifindex)
+{
+	return get_bp_hw_reset_fn(get_dev_idx_p(ifindex));
+}
+EXPORT_SYMBOL(get_bp_hw_reset_sd);
+
+int get_bypass_info_sd(int ifindex, struct bp_info *bp_info)
+{
+	return get_bypass_info_fn(get_dev_idx_p(ifindex), bp_info->prod_name,
+				  &bp_info->fw_ver);
+}
+EXPORT_SYMBOL(get_bypass_info_sd);
+
+int bp_if_scan_sd(void)
+{
+	if_scan_init();
+	return 0;
+}
+EXPORT_SYMBOL(bp_if_scan_sd);
+
+/**************************************************************/
+/********************* PROC Interface *************************/
+/**************************************************************/
+
+static int procfs_add(char *proc_name, const struct file_operations *fops,
+			  struct bpctl_dev *dev)
+{
+	struct bypass_pfs_sd *pfs = &dev->bypass_pfs_set;
+
+	if (!proc_create_data(proc_name, 0644, pfs->bypass_entry, fops, dev))
+		return  -1;
+	return 0;
+}
+
+static int show_bypass_info(struct seq_file *m, void *v)
+{
+	struct bpctl_dev *dev = m->private;
+
+	seq_printf(m, "Name\t\t\t%s\n", dev->name);
+	seq_printf(m, "Firmware version\t0x%x\n", dev->bp_fw_ver);
+	return 0;
+}
+
+static int bypass_info_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, show_bypass_info, PDE_DATA(inode));
+}
+
+static const struct file_operations bypass_info_ops = {
+	.open = bypass_info_open,
+	.read = seq_read,
+	.llseek = seq_lseek,
+	.release = single_release,
+};
+
+
+static int show_bypass_slave(struct seq_file *m, void *v)
+{
+	struct bpctl_dev *dev = m->private;
+	struct bpctl_dev *slave = get_status_port(dev);
+
+	if (!slave)
+		slave = dev;
+	if (!slave)
+		seq_puts(m, "fail\n");
+	else if (slave->ndev)
+		seq_printf(m, "%s\n", slave->ndev->name);
+	return 0;
+}
+
+static int bypass_slave_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, show_bypass_slave, PDE_DATA(inode));
+}
+
+static const struct file_operations bypass_slave_ops = {
+	.open = bypass_slave_open,
+	.read = seq_read,
+	.llseek = seq_lseek,
+	.release = single_release,
+};
+
+static int show_bypass_caps(struct seq_file *m, void *v)
+{
+	struct bpctl_dev *dev = m->private;
+	int ret = get_bypass_caps_fn(dev);
+
+	if (ret == BP_NOT_CAP)
+		seq_puts(m, "-1\n");
+	else
+		seq_printf(m, "0x%x\n", ret);
+	return 0;
+}
+
+static int bypass_caps_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, show_bypass_caps, PDE_DATA(inode));
+}
+
+static const struct file_operations bypass_caps_ops = {
+	.open = bypass_caps_open,
+	.read = seq_read,
+	.llseek = seq_lseek,
+	.release = single_release,
+};
+
+static int show_wd_set_caps(struct seq_file *m, void *v)
+{
+	struct bpctl_dev *dev = m->private;
+	int ret = get_wd_set_caps_fn(dev);
+
+	if (ret == BP_NOT_CAP)
+		seq_puts(m, "-1\n");
+	else
+		seq_printf(m, "0x%x\n", ret);
+	return 0;
+}
+
+static int wd_set_caps_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, show_wd_set_caps, PDE_DATA(inode));
+}
+
+static const struct file_operations wd_set_caps_ops = {
+	.open = wd_set_caps_open,
+	.read = seq_read,
+	.llseek = seq_lseek,
+	.release = single_release,
+};
+
+
+static int user_on_off(const void __user *buffer, size_t count)
+{
+	char kbuf[256];
+	int length = 0;
+
+	if (count > (sizeof(kbuf) - 1))
+		return  -1;
+
+	if (copy_from_user(&kbuf, buffer, count))
+		return  -1;
+
+	kbuf[count] = '\0';
+	length = strlen(kbuf);
+	if (kbuf[length - 1] == '\n')
+		kbuf[--length] = '\0';
+
+	if (strcmp(kbuf, "on") == 0)
+		return 1;
+	if (strcmp(kbuf, "off") == 0)
+		return 0;
+	return 0;
+}
+
+static ssize_t bypass_write(struct file *file, const char __user *buffer,
+				  size_t count, loff_t *pos)
+{
+	int bypass_param = user_on_off(buffer, count);
+
+	if (bypass_param < 0)
+		return  -1;
+
+	set_bypass_fn(PDE_DATA(file_inode(file)), bypass_param);
+	return count;
+}
+static int show_bypass(struct seq_file *m, void *v)
+{
+	struct bpctl_dev *dev = m->private;
+	int ret = get_bypass_fn(dev);
+
+	if (ret == BP_NOT_CAP)
+		seq_puts(m, "fail\n");
+	else if (ret == 1)
+		seq_puts(m, "on\n");
+	else if (ret == 0)
+		seq_puts(m, "off\n");
+	return 0;
+}
+
+static int bypass_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, show_bypass, PDE_DATA(inode));
+}
+static const struct file_operations bypass_ops = {
+	.open = bypass_open,
+	.read = seq_read,
+	.write = bypass_write,
+	.llseek = seq_lseek,
+	.release = single_release,
+};
+
+static ssize_t tap_write(struct file *file, const char __user *buffer,
+				  size_t count, loff_t *pos)
+{
+	int tap_param = user_on_off(buffer, count);
+
+	if (tap_param < 0)
+		return  -1;
+
+	set_tap_fn(PDE_DATA(file_inode(file)), tap_param);
+	return count;
+}
+static int show_tap(struct seq_file *m, void *v)
+{
+	struct bpctl_dev *dev = m->private;
+	int ret = get_tap_fn(dev);
+
+	if (ret == BP_NOT_CAP)
+		seq_puts(m, "fail\n");
+	else if (ret == 1)
+		seq_puts(m, "on\n");
+	else if (ret == 0)
+		seq_puts(m, "off\n");
+	return 0;
+}
+
+static int tap_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, show_tap, PDE_DATA(inode));
+}
+static const struct file_operations tap_ops = {
+	.open = tap_open,
+	.read = seq_read,
+	.write = tap_write,
+	.llseek = seq_lseek,
+	.release = single_release,
+};
+
+
+static ssize_t disc_write(struct file *file, const char __user *buffer,
+				  size_t count, loff_t *pos)
+{
+	int tap_param = user_on_off(buffer, count);
+
+	if (tap_param < 0)
+		return  -1;
+
+	set_disc_fn(PDE_DATA(file_inode(file)), tap_param);
+	return count;
+}
+static int show_disc(struct seq_file *m, void *v)
+{
+	struct bpctl_dev *dev = m->private;
+	int ret = get_disc_fn(dev);
+
+	if (ret == BP_NOT_CAP)
+		seq_puts(m, "fail\n");
+	else if (ret == 1)
+		seq_puts(m, "on\n");
+	else if (ret == 0)
+		seq_puts(m, "off\n");
+	return 0;
+}
+
+static int disc_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, show_disc, PDE_DATA(inode));
+}
+static const struct file_operations disc_ops = {
+	.open = disc_open,
+	.read = seq_read,
+	.write = disc_write,
+	.llseek = seq_lseek,
+	.release = single_release,
+};
+
+
+static int show_bypass_change(struct seq_file *m, void *v)
+{
+	struct bpctl_dev *dev = m->private;
+	int ret = get_bypass_change_fn(dev);
+
+	if (ret == 1)
+		seq_puts(m, "on\n");
+	else if (ret == 0)
+		seq_puts(m, "off\n");
+	else
+		seq_puts(m, "fail\n");
+	return 0;
+}
+
+static int bypass_change_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, show_bypass_change, PDE_DATA(inode));
+}
+
+static const struct file_operations bypass_change_ops = {
+	.open = bypass_change_open,
+	.read = seq_read,
+	.llseek = seq_lseek,
+	.release = single_release,
+};
+
+static int show_tap_change(struct seq_file *m, void *v)
+{
+	struct bpctl_dev *dev = m->private;
+	int ret = get_tap_change_fn(dev);
+
+	if (ret == 1)
+		seq_puts(m, "on\n");
+	else if (ret == 0)
+		seq_puts(m, "off\n");
+	else
+		seq_puts(m, "fail\n");
+	return 0;
+}
+
+static int tap_change_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, show_tap_change, PDE_DATA(inode));
+}
+
+static const struct file_operations tap_change_ops = {
+	.open = tap_change_open,
+	.read = seq_read,
+	.llseek = seq_lseek,
+	.release = single_release,
+};
+
+static int show_disc_change(struct seq_file *m, void *v)
+{
+	struct bpctl_dev *dev = m->private;
+	int ret = get_disc_change_fn(dev);
+
+	if (ret == 1)
+		seq_puts(m, "on\n");
+	else if (ret == 0)
+		seq_puts(m, "off\n");
+	else
+		seq_puts(m, "fail\n");
+	return 0;
+}
+
+static int disc_change_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, show_disc_change, PDE_DATA(inode));
+}
+
+static const struct file_operations disc_change_ops = {
+	.open = disc_change_open,
+	.read = seq_read,
+	.llseek = seq_lseek,
+	.release = single_release,
+};
+
+static ssize_t bypass_wd_write(struct file *file, const char __user *buffer,
+				  size_t count, loff_t *pos)
+{
+	struct bpctl_dev *dev = PDE_DATA(file_inode(file));
+	int timeout;
+	int ret = kstrtoint_from_user(buffer, count, 10, &timeout);
+
+	if (ret)
+		return ret;
+	set_bypass_wd_fn(dev, timeout);
+	return count;
+}
+
+static int show_bypass_wd(struct seq_file *m, void *v)
+{
+	struct bpctl_dev *dev = m->private;
+	int ret = 0, timeout = 0;
+
+	ret = get_bypass_wd_fn(dev, &timeout);
+	if (ret == BP_NOT_CAP)
+		seq_puts(m,  "fail\n");
+	else if (timeout == -1)
+		seq_puts(m,  "unknown\n");
+	else if (timeout == 0)
+		seq_puts(m,  "disable\n");
+	else
+		seq_printf(m, "%d\n", timeout);
+	return 0;
+}
+
+static int bypass_wd_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, show_bypass_wd, PDE_DATA(inode));
+}
+
+static const struct file_operations bypass_wd_ops = {
+	.open = bypass_wd_open,
+	.read = seq_read,
+	.write = bypass_wd_write,
+	.llseek = seq_lseek,
+	.release = single_release,
+};
+
+static int show_wd_expire_time(struct seq_file *m, void *v)
+{
+	struct bpctl_dev *dev = m->private;
+	int ret = 0, timeout = 0;
+
+	ret = get_wd_expire_time_fn(dev, &timeout);
+	if (ret == BP_NOT_CAP)
+		seq_puts(m, "fail\n");
+	else if (timeout == -1)
+		seq_puts(m, "expire\n");
+	else if (timeout == 0)
+		seq_puts(m, "disable\n");
+	else
+		seq_printf(m, "%d\n", timeout);
+	return 0;
+}
+
+static int wd_expire_time_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, show_wd_expire_time, PDE_DATA(inode));
+}
+
+static const struct file_operations wd_expire_time_ops = {
+	.open = wd_expire_time_open,
+	.read = seq_read,
+	.llseek = seq_lseek,
+	.release = single_release,
+};
+
+static ssize_t tpl_write(struct file *file, const char __user *buffer,
+				  size_t count, loff_t *pos)
+{
+	struct bpctl_dev *dev = PDE_DATA(file_inode(file));
+	int tpl_param = user_on_off(buffer, count);
+
+	if (tpl_param < 0)
+		return  -1;
+
+	set_tpl_fn(dev, tpl_param);
+	return count;
+}
+
+static int show_tpl(struct seq_file *m, void *v)
+{
+	struct bpctl_dev *dev = m->private;
+	int ret = get_tpl_fn(dev);
+
+	if (ret == BP_NOT_CAP)
+		seq_puts(m, "fail\n");
+	else if (ret == 1)
+		seq_puts(m, "on\n");
+	else if (ret == 0)
+		seq_puts(m, "off\n");
+	return 0;
+}
+
+static int tpl_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, show_tpl, PDE_DATA(inode));
+}
+
+static const struct file_operations tpl_ops = {
+	.open = tpl_open,
+	.read = seq_read,
+	.write = tpl_write,
+	.llseek = seq_lseek,
+	.release = single_release,
+};
+
+static ssize_t wait_at_pwup_write(struct file *file, const char __user *buffer,
+				  size_t count, loff_t *pos)
+{
+	struct bpctl_dev *dev = PDE_DATA(file_inode(file));
+	int tpl_param = user_on_off(buffer, count);
+
+	if (tpl_param < 0)
+		return  -1;
+
+	set_bp_wait_at_pwup_fn(dev, tpl_param);
+	return count;
+}
+
+static int show_wait_at_pwup(struct seq_file *m, void *v)
+{
+	struct bpctl_dev *dev = m->private;
+	int ret = get_bp_wait_at_pwup_fn(dev);
+
+	if (ret == BP_NOT_CAP)
+		seq_puts(m, "fail\n");
+	else if (ret == 1)
+		seq_puts(m, "on\n");
+	else if (ret == 0)
+		seq_puts(m, "off\n");
+	return 0;
+}
+
+static int wait_at_pwup_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, show_wait_at_pwup, PDE_DATA(inode));
+}
+
+static const struct file_operations wait_at_pwup_ops = {
+	.open = wait_at_pwup_open,
+	.read = seq_read,
+	.write = wait_at_pwup_write,
+	.llseek = seq_lseek,
+	.release = single_release,
+};
+
+static ssize_t hw_reset_write(struct file *file, const char __user *buffer,
+				  size_t count, loff_t *pos)
+{
+	struct bpctl_dev *dev = PDE_DATA(file_inode(file));
+	int tpl_param = user_on_off(buffer, count);
+
+	if (tpl_param < 0)
+		return  -1;
+
+	set_bp_hw_reset_fn(dev, tpl_param);
+	return count;
+}
+
+static int show_hw_reset(struct seq_file *m, void *v)
+{
+	struct bpctl_dev *dev = m->private;
+	int ret = get_bp_hw_reset_fn(dev);
+
+	if (ret == BP_NOT_CAP)
+		seq_puts(m, "fail\n");
+	else if (ret == 1)
+		seq_puts(m, "on\n");
+	else if (ret == 0)
+		seq_puts(m, "off\n");
+	return 0;
+}
+
+static int hw_reset_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, show_hw_reset, PDE_DATA(inode));
+}
+
+static const struct file_operations hw_reset_ops = {
+	.open = hw_reset_open,
+	.read = seq_read,
+	.write = hw_reset_write,
+	.llseek = seq_lseek,
+	.release = single_release,
+};
+
+
+static int show_reset_bypass_wd(struct seq_file *m, void *v)
+{
+	struct bpctl_dev *dev = m->private;
+	int ret = reset_bypass_wd_timer_fn(dev);
+
+	if (ret == BP_NOT_CAP)
+		seq_puts(m, "fail\n");
+	else if (ret == 0)
+		seq_puts(m, "disable\n");
+	else if (ret == 1)
+		seq_puts(m, "success\n");
+	return 0;
+}
+
+static int reset_bypass_wd_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, show_reset_bypass_wd, PDE_DATA(inode));
+}
+
+static const struct file_operations reset_bypass_wd_ops = {
+	.open = reset_bypass_wd_open,
+	.read = seq_read,
+	.llseek = seq_lseek,
+	.release = single_release,
+};
+
+
+static ssize_t dis_bypass_write(struct file *file, const char __user *buffer,
+				  size_t count, loff_t *pos)
+{
+	int bypass_param = user_on_off(buffer, count);
+
+	if (bypass_param < 0)
+		return -EINVAL;
+
+	set_dis_bypass_fn(PDE_DATA(file_inode(file)), bypass_param);
+	return count;
+}
+
+static int show_dis_bypass(struct seq_file *m, void *v)
+{
+	struct bpctl_dev *dev = m->private;
+	int ret = get_dis_bypass_fn(dev);
+
+	if (ret == BP_NOT_CAP)
+		seq_puts(m, "fail\n");
+	else if (ret == 0)
+		seq_puts(m, "off\n");
+	else
+		seq_puts(m, "on\n");
+	return 0;
+}
+
+static int dis_bypass_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, show_dis_bypass, PDE_DATA(inode));
+}
+
+static const struct file_operations dis_bypass_ops = {
+	.open = dis_bypass_open,
+	.read = seq_read,
+	.write = dis_bypass_write,
+	.llseek = seq_lseek,
+	.release = single_release,
+};
+
+
+static ssize_t dis_tap_write(struct file *file, const char __user *buffer,
+				  size_t count, loff_t *pos)
+{
+	int tap_param = user_on_off(buffer, count);
+
+	if (tap_param < 0)
+		return -EINVAL;
+
+	set_dis_tap_fn(PDE_DATA(file_inode(file)), tap_param);
+	return count;
+}
+static int show_dis_tap(struct seq_file *m, void *v)
+{
+	struct bpctl_dev *dev = m->private;
+	int ret = get_dis_tap_fn(dev);
+
+	if (ret == BP_NOT_CAP)
+		seq_puts(m, "fail\n");
+	else if (ret == 0)
+		seq_puts(m, "off\n");
+	else
+		seq_puts(m, "on\n");
+	return 0;
+}
+
+static int dis_tap_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, show_dis_tap, PDE_DATA(inode));
+}
+
+static const struct file_operations dis_tap_ops = {
+	.open = dis_tap_open,
+	.read = seq_read,
+	.write = dis_tap_write,
+	.llseek = seq_lseek,
+	.release = single_release,
+};
+
+static ssize_t dis_disc_write(struct file *file, const char __user *buffer,
+				  size_t count, loff_t *pos)
+{
+	int tap_param = user_on_off(buffer, count);
+
+	if (tap_param < 0)
+		return -EINVAL;
+
+	set_dis_disc_fn(PDE_DATA(file_inode(file)), tap_param);
+	return count;
+}
+
+static int show_dis_disc(struct seq_file *m, void *v)
+{
+	struct bpctl_dev *dev = m->private;
+	int ret = get_dis_disc_fn(dev);
+
+	if (ret == BP_NOT_CAP)
+		seq_puts(m, "fail\n");
+	else if (ret == 0)
+		seq_puts(m, "off\n");
+	else
+		seq_puts(m, "on\n");
+	return 0;
+}
+
+static int dis_disc_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, show_dis_disc, PDE_DATA(inode));
+}
+
+static const struct file_operations dis_disc_ops = {
+	.open = dis_disc_open,
+	.read = seq_read,
+	.write = dis_disc_write,
+	.llseek = seq_lseek,
+	.release = single_release,
+};
+
+
+static ssize_t bypass_pwup_write(struct file *file, const char __user *buffer,
+				  size_t count, loff_t *pos)
+{
+	int bypass_param = user_on_off(buffer, count);
+
+	if (bypass_param < 0)
+		return -EINVAL;
+
+	set_bypass_pwup_fn(PDE_DATA(file_inode(file)), bypass_param);
+	return count;
+}
+
+static int show_bypass_pwup(struct seq_file *m, void *v)
+{
+	struct bpctl_dev *dev = m->private;
+	int ret = get_bypass_pwup_fn(dev);
+
+	if (ret == BP_NOT_CAP)
+		seq_puts(m, "fail\n");
+	else if (ret == 0)
+		seq_puts(m, "off\n");
+	else
+		seq_puts(m, "on\n");
+	return 0;
+}
+
+static int bypass_pwup_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, show_bypass_pwup, PDE_DATA(inode));
+}
+
+static const struct file_operations bypass_pwup_ops = {
+	.open = bypass_pwup_open,
+	.read = seq_read,
+	.write = bypass_pwup_write,
+	.llseek = seq_lseek,
+	.release = single_release,
+};
+
+
+static ssize_t bypass_pwoff_write(struct file *file, const char __user *buffer,
+				  size_t count, loff_t *pos)
+{
+	int bypass_param = user_on_off(buffer, count);
+
+	if (bypass_param < 0)
+		return -EINVAL;
+
+	set_bypass_pwoff_fn(PDE_DATA(file_inode(file)), bypass_param);
+	return count;
+}
+
+static int show_bypass_pwoff(struct seq_file *m, void *v)
+{
+	struct bpctl_dev *dev = m->private;
+	int ret = get_bypass_pwoff_fn(dev);
+
+	if (ret == BP_NOT_CAP)
+		seq_puts(m, "fail\n");
+	else if (ret == 0)
+		seq_puts(m, "off\n");
+	else
+		seq_puts(m, "on\n");
+	return 0;
+}
+
+static int bypass_pwoff_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, show_bypass_pwoff, PDE_DATA(inode));
+}
+
+static const struct file_operations bypass_pwoff_ops = {
+	.open = bypass_pwoff_open,
+	.read = seq_read,
+	.write = bypass_pwoff_write,
+	.llseek = seq_lseek,
+	.release = single_release,
+};
+
+static ssize_t tap_pwup_write(struct file *file, const char __user *buffer,
+				  size_t count, loff_t *pos)
+{
+	int tap_param = user_on_off(buffer, count);
+
+	if (tap_param < 0)
+		return -EINVAL;
+
+	set_tap_pwup_fn(PDE_DATA(file_inode(file)), tap_param);
+	return count;
+}
+
+static int show_tap_pwup(struct seq_file *m, void *v)
+{
+	struct bpctl_dev *dev = m->private;
+	int ret = get_tap_pwup_fn(dev);
+
+	if (ret == BP_NOT_CAP)
+		seq_puts(m, "fail\n");
+	else if (ret == 0)
+		seq_puts(m, "off\n");
+	else
+		seq_puts(m, "on\n");
+	return 0;
+}
+
+static int tap_pwup_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, show_tap_pwup, PDE_DATA(inode));
+}
+
+static const struct file_operations tap_pwup_ops = {
+	.open = tap_pwup_open,
+	.read = seq_read,
+	.write = tap_pwup_write,
+	.llseek = seq_lseek,
+	.release = single_release,
+};
+
+static ssize_t disc_pwup_write(struct file *file, const char __user *buffer,
+				  size_t count, loff_t *pos)
+{
+	int tap_param = user_on_off(buffer, count);
+
+	if (tap_param < 0)
+		return -EINVAL;
+
+	set_disc_pwup_fn(PDE_DATA(file_inode(file)), tap_param);
+	return count;
+}
+
+static int show_disc_pwup(struct seq_file *m, void *v)
+{
+	struct bpctl_dev *dev = m->private;
+	int ret = get_disc_pwup_fn(dev);
+
+	if (ret == BP_NOT_CAP)
+		seq_puts(m, "fail\n");
+	else if (ret == 0)
+		seq_puts(m, "off\n");
+	else
+		seq_puts(m, "on\n");
+	return 0;
+}
+
+static int disc_pwup_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, show_disc_pwup, PDE_DATA(inode));
+}
+
+static const struct file_operations disc_pwup_ops = {
+	.open = disc_pwup_open,
+	.read = seq_read,
+	.write = disc_pwup_write,
+	.llseek = seq_lseek,
+	.release = single_release,
+};
+
+static ssize_t std_nic_write(struct file *file, const char __user *buffer,
+				  size_t count, loff_t *pos)
+{
+	int bypass_param = user_on_off(buffer, count);
+
+	if (bypass_param < 0)
+		return -EINVAL;
+
+	set_std_nic_fn(PDE_DATA(file_inode(file)), bypass_param);
+	return count;
+}
+
+static int show_std_nic(struct seq_file *m, void *v)
+{
+	struct bpctl_dev *dev = m->private;
+	int ret = get_std_nic_fn(dev);
+
+	if (ret == BP_NOT_CAP)
+		seq_puts(m, "fail\n");
+	else if (ret == 0)
+		seq_puts(m, "off\n");
+	else
+		seq_puts(m, "on\n");
+	return 0;
+}
+
+static int std_nic_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, show_std_nic, PDE_DATA(inode));
+}
+
+static const struct file_operations std_nic_ops = {
+	.open = std_nic_open,
+	.read = seq_read,
+	.write = std_nic_write,
+	.llseek = seq_lseek,
+	.release = single_release,
+};
+
+
+static ssize_t wd_exp_mode_write(struct file *file, const char __user *buffer,
+				  size_t count, loff_t *pos)
+{
+	char kbuf[256];
+	int bypass_param = 0, length = 0;
+
+	if (count > (sizeof(kbuf) - 1))
+		return  -1;
+
+	if (copy_from_user(&kbuf, buffer, count))
+		return  -1;
+
+	kbuf[count] = '\0';
+	length = strlen(kbuf);
+	if (kbuf[length - 1] == '\n')
+		kbuf[--length] = '\0';
+
+	if (strcmp(kbuf, "tap") == 0)
+		bypass_param = 1;
+	else if (strcmp(kbuf, "bypass") == 0)
+		bypass_param = 0;
+	else if (strcmp(kbuf, "disc") == 0)
+		bypass_param = 2;
+
+	set_wd_exp_mode_fn(PDE_DATA(file_inode(file)), bypass_param);
+
+	return count;
+}
+
+static int show_wd_exp_mode(struct seq_file *m, void *v)
+{
+	struct bpctl_dev *dev = m->private;
+	int ret = get_wd_exp_mode_fn(dev);
+
+	if (ret == 1)
+		seq_puts(m, "tap\n");
+	else if (ret == 0)
+		seq_puts(m, "bypass\n");
+	else if (ret == 2)
+		seq_puts(m, "disc\n");
+	else
+		seq_puts(m, "fail\n");
+	return 0;
+}
+
+static int wd_exp_mode_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, show_wd_exp_mode, PDE_DATA(inode));
+}
+
+static const struct file_operations wd_exp_mode_ops = {
+	.open = wd_exp_mode_open,
+	.read = seq_read,
+	.write = wd_exp_mode_write,
+	.llseek = seq_lseek,
+	.release = single_release,
+};
+
+static ssize_t wd_autoreset_write(struct file *file, const char __user *buffer,
+				  size_t count, loff_t *pos)
+{
+	int timeout;
+	int ret = kstrtoint_from_user(buffer, count, 10, &timeout);
+
+	if (ret)
+		return ret;
+	set_wd_autoreset_fn(PDE_DATA(file_inode(file)), timeout);
+	return count;
+}
+
+static int show_wd_autoreset(struct seq_file *m, void *v)
+{
+	struct bpctl_dev *dev = m->private;
+	int ret = get_wd_autoreset_fn(dev);
+
+	if (ret >= 0)
+		seq_printf(m, "%d\n", ret);
+	else
+		seq_puts(m, "fail\n");
+	return 0;
+}
+
+static int wd_autoreset_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, show_wd_autoreset, PDE_DATA(inode));
+}
+
+static const struct file_operations wd_autoreset_ops = {
+	.open = wd_autoreset_open,
+	.read = seq_read,
+	.write = wd_autoreset_write,
+	.llseek = seq_lseek,
+	.release = single_release,
+};
+
+static int bypass_proc_create_dev_sd(struct bpctl_dev *pbp_device_block)
+{
+	struct bypass_pfs_sd *current_pfs = &(pbp_device_block->bypass_pfs_set);
+	static struct proc_dir_entry *procfs_dir;
+	int ret = 0;
+
+	if (!pbp_device_block->ndev)
+		return  -1;
+	sprintf(current_pfs->dir_name, "bypass_%s",
+		pbp_device_block->ndev->name);
+
+	if (!bp_procfs_dir)
+		return  -1;
+
+	/* create device proc dir */
+	procfs_dir = proc_mkdir(current_pfs->dir_name, bp_procfs_dir);
+	if (!procfs_dir) {
+		pr_info("Could not create procfs directory %s\n",
+		       current_pfs->dir_name);
+		return  -1;
+	}
+	current_pfs->bypass_entry = procfs_dir;
+
+#define ENTRY(x) (ret |= procfs_add(#x, &x##_ops, pbp_device_block))
+
+	ENTRY(bypass_info);
+	if (pbp_device_block->bp_caps & SW_CTL_CAP) {
+		/* Create set param proc's */
+		ENTRY(bypass_slave);
+		ENTRY(bypass_caps);
+		ENTRY(wd_set_caps);
+		ENTRY(bypass_wd);
+		ENTRY(wd_expire_time);
+		ENTRY(reset_bypass_wd);
+		ENTRY(std_nic);
+		if (pbp_device_block->bp_caps & BP_CAP) {
+			ENTRY(bypass);
+			ENTRY(dis_bypass);
+			ENTRY(bypass_pwup);
+			ENTRY(bypass_pwoff);
+			ENTRY(bypass_change);
+		}
+		if (pbp_device_block->bp_caps & TAP_CAP) {
+			ENTRY(tap);
+			ENTRY(dis_tap);
+			ENTRY(tap_pwup);
+			ENTRY(tap_change);
+		}
+		if (pbp_device_block->bp_caps & DISC_CAP) {
+			ENTRY(disc);
+			ENTRY(dis_disc);
+			ENTRY(disc_pwup);
+			ENTRY(disc_change);
+		}
+
+		ENTRY(wd_exp_mode);
+		ENTRY(wd_autoreset);
+		ENTRY(tpl);
+		ENTRY(wait_at_pwup);
+		ENTRY(hw_reset);
+	}
+#undef ENTRY
+	if (ret < 0)
+		pr_info("Create proc entry failed\n");
+
+	return ret;
+}
+
+static int bypass_proc_remove_dev_sd(struct bpctl_dev *pbp_device_block)
+{
+	struct bypass_pfs_sd *current_pfs = &pbp_device_block->bypass_pfs_set;
+
+	remove_proc_subtree(current_pfs->dir_name, bp_procfs_dir);
+	current_pfs->bypass_entry = NULL;
+	return 0;
+}
diff -uprN -X linux-3.17-rc1-vanilla/Documentation/dontdiff linux-3.17-rc1-vanilla/drivers/bypass/silicom/bp_ctl/bp_ioctl.h linux-3.17-rc1/drivers/bypass/silicom/bp_ctl/bp_ioctl.h
--- linux-3.17-rc1-vanilla/drivers/bypass/silicom/bp_ctl/bp_ioctl.h	1970-01-01 02:00:00.000000000 +0200
+++ linux-3.17-rc1/drivers/bypass/silicom/bp_ctl/bp_ioctl.h	2014-08-24 06:40:19.000000000 +0300
@@ -0,0 +1,135 @@
+/******************************************************************************/
+/*                                                                            */
+/* Silicom Bypass Control Utility, Copyright (c) 2005-2007 Silicom            */
+/* All rights reserved.                                                       */
+/*                                                                            */
+/* This program is free software; you can redistribute it and/or modify       */
+/* it under the terms of the GNU General Public License as published by       */
+/* the Free Software Foundation, located in the file LICENSE.                 */
+/*                                                                            */
+/*                                                                            */
+/******************************************************************************/
+
+#ifndef BP_IOCTL_H
+#define BP_IOCTL_H
+
+#define BP_CAP                   0x01	/* BIT_0 */
+#define BP_STATUS_CAP            0x02
+#define BP_STATUS_CHANGE_CAP     0x04
+#define SW_CTL_CAP               0x08
+#define BP_DIS_CAP               0x10
+#define BP_DIS_STATUS_CAP        0x20
+#define STD_NIC_CAP              0x40
+#define BP_PWOFF_ON_CAP          0x80
+#define BP_PWOFF_OFF_CAP         0x0100
+#define BP_PWOFF_CTL_CAP         0x0200
+#define BP_PWUP_ON_CAP           0x0400
+#define BP_PWUP_OFF_CAP          0x0800
+#define BP_PWUP_CTL_CAP          0x1000
+#define WD_CTL_CAP               0x2000
+#define WD_STATUS_CAP            0x4000
+#define WD_TIMEOUT_CAP           0x8000
+#define TX_CTL_CAP               0x10000
+#define TX_STATUS_CAP            0x20000
+#define TAP_CAP                  0x40000
+#define TAP_STATUS_CAP           0x80000
+#define TAP_STATUS_CHANGE_CAP    0x100000
+#define TAP_DIS_CAP              0x200000
+#define TAP_DIS_STATUS_CAP       0x400000
+#define TAP_PWUP_ON_CAP          0x800000
+#define TAP_PWUP_OFF_CAP         0x1000000
+#define TAP_PWUP_CTL_CAP         0x2000000
+#define NIC_CAP_NEG              0x4000000
+#define TPL_CAP                  0x8000000
+#define DISC_CAP                 0x10000000
+#define DISC_DIS_CAP             0x20000000
+#define DISC_PWUP_CTL_CAP        0x40000000
+
+#define TPL2_CAP_EX              0x01
+#define DISC_PORT_CAP_EX         0x02
+
+#define WD_MIN_TIME_MASK(val)      (val & 0xf)
+#define WD_STEP_COUNT_MASK(val)    ((val & 0xf) << 5)
+#define WDT_STEP_TIME              0x10	/* BIT_4 */
+
+#define WD_MIN_TIME_GET(desc)   (desc & 0xf)
+#define WD_STEP_COUNT_GET(desc) ((desc>>5) & 0xf)
+
+enum {
+	IF_SCAN,
+	GET_DEV_NUM,
+	IS_BYPASS,
+	GET_BYPASS_SLAVE,
+	GET_BYPASS_CAPS,
+	GET_WD_SET_CAPS,
+	SET_BYPASS,
+	GET_BYPASS,
+	GET_BYPASS_CHANGE,
+	SET_BYPASS_WD,
+	GET_BYPASS_WD,
+	GET_WD_EXPIRE_TIME,
+	RESET_BYPASS_WD_TIMER,
+	SET_DIS_BYPASS,
+	GET_DIS_BYPASS,
+	SET_BYPASS_PWOFF,
+	GET_BYPASS_PWOFF,
+	SET_BYPASS_PWUP,
+	GET_BYPASS_PWUP,
+	SET_STD_NIC,
+	GET_STD_NIC,
+	SET_TX,
+	GET_TX,
+	SET_TAP,
+	GET_TAP,
+	GET_TAP_CHANGE,
+	SET_DIS_TAP,
+	GET_DIS_TAP,
+	SET_TAP_PWUP,
+	GET_TAP_PWUP,
+	SET_WD_EXP_MODE,
+	GET_WD_EXP_MODE,
+	SET_WD_AUTORESET,
+	GET_WD_AUTORESET,
+	SET_TPL,
+	GET_TPL,
+	SET_DISC,
+	GET_DISC,
+	GET_DISC_CHANGE,
+	SET_DIS_DISC,
+	GET_DIS_DISC,
+	SET_DISC_PWUP,
+	GET_DISC_PWUP,
+	GET_BYPASS_INFO = 100,
+	GET_BP_WAIT_AT_PWUP,
+	SET_BP_WAIT_AT_PWUP,
+	GET_BP_HW_RESET,
+	SET_BP_HW_RESET,
+	SET_DISC_PORT,
+	GET_DISC_PORT,
+	SET_DISC_PORT_PWUP,
+	GET_DISC_PORT_PWUP,
+	SET_BP_FORCE_LINK,
+	GET_BP_FORCE_LINK,
+};
+
+/*
+* The major device number. We can't rely on dynamic
+* registration any more, because ioctls need to know
+* it.
+*/
+
+#define MAGIC_NUM 'J'
+
+/* for passing single values */
+struct bpctl_cmd {
+	int status;
+	int data[8];
+	int in_param[8];
+	int out_param[8];
+};
+
+#define IOCTL_TX_MSG(cmd) _IOWR(MAGIC_NUM, cmd, struct bpctl_cmd)
+
+#define DEVICE_NAME "bpctl"
+
+#endif
diff -uprN -X linux-3.17-rc1-vanilla/Documentation/dontdiff linux-3.17-rc1-vanilla/drivers/bypass/silicom/bp_ctl/bp_mod.h linux-3.17-rc1/drivers/bypass/silicom/bp_ctl/bp_mod.h
--- linux-3.17-rc1-vanilla/drivers/bypass/silicom/bp_ctl/bp_mod.h	1970-01-01 02:00:00.000000000 +0200
+++ linux-3.17-rc1/drivers/bypass/silicom/bp_ctl/bp_mod.h	2014-08-28 07:08:21.000000000 +0300
@@ -0,0 +1,812 @@
+/******************************************************************************/
+/*                                                                            */
+/* Bypass Control utility, Copyright (c) 2005 Silicom                         */
+/*                                                                            */
+/* This program is free software; you can redistribute it and/or modify       */
+/* it under the terms of the GNU General Public License as published by       */
+/* the Free Software Foundation, located in the file LICENSE.                 */
+/*                                                                            */
+/*                                                                            */
+/* bp_mod.h                                                                   */
+/*                                                                            */
+/******************************************************************************/
+
+#ifndef BP_MOD_H
+#define BP_MOD_H
+
+#define usec_delay(x) udelay(x)
+#ifndef msec_delay_bp
+	#define msec_delay_bp(x) msleep(x)
+#endif
+
+#include <linux/param.h>
+#include <linux/bitops.h>
+
+#ifndef jiffies_to_msecs
+#define jiffies_to_msecs(x) _kc_jiffies_to_msecs(x)
+static inline unsigned int jiffies_to_msecs(const unsigned long j)
+{
+#if HZ <= 1000 && !(1000 % HZ)
+	return (1000 / HZ) * j;
+#elif HZ > 1000 && !(HZ % 1000)
+	return (j + (HZ / 1000) - 1) / (HZ / 1000);
+#else
+	return (j * 1000) / HZ;
+#endif
+}
+#endif
+
+
+/* Media Types */
+enum bp_media_type {
+	BP_COPPER,
+	BP_FIBER,
+	BP_CX4,
+	BP_NONE,
+};
+
+enum bp_nic_type {
+	bp_10g = 1,
+	bp_10gb,
+	bp_10g9,
+	bp_fiber5,
+	bp_i80,
+	bp_540,
+};
+
+struct bypass_pfs_sd {
+	char dir_name[32];
+	struct proc_dir_entry *bypass_entry;
+};
+
+struct bpctl_dev {
+	char *name;
+	char *desc;
+	struct pci_dev *pdev;   /* PCI device */
+	struct net_device *ndev;        /* net device */
+	void __iomem *mem_map;
+	uint8_t bus;
+	uint8_t slot;
+	uint8_t func;
+	u_int32_t device;
+	u_int32_t vendor;
+	u_int32_t subvendor;
+	u_int32_t subdevice;
+	int ifindex;
+	uint32_t bp_caps;
+	uint32_t bp_caps_ex;
+	uint8_t bp_fw_ver;
+	int bp_ext_ver;
+	int wdt_status;
+	unsigned long bypass_wdt_on_time;
+	uint32_t bypass_timer_interval;
+	struct timer_list bp_timer;
+	uint32_t reset_time;
+	uint8_t bp_status_un;
+	atomic_t wdt_busy;
+	enum bp_media_type media_type;
+	int bp_tpl_flag;
+	struct timer_list bp_tpl_timer;
+	spinlock_t bypass_wr_lock;
+	int nic_type;
+	const struct net_device_ops *old_ops;
+	struct net_device_ops new_ops;
+	int bp_self_test_flag;
+	char *bp_tx_data;
+	struct bypass_pfs_sd bypass_pfs_set;
+
+};
+
+#define SILICOM_VID              0x1374
+#define SILICOM_SVID             0x1374
+
+#define SILICOM_PXG2BPFI_SSID    0x0026
+#define SILICOM_PXG2BPFILX_SSID  0x0027
+#define SILICOM_PXGBPI_SSID      0x0028
+#define SILICOM_PXGBPIG_SSID     0x0029
+#define SILICOM_PXG2TBFI_SSID    0x002a
+#define SILICOM_PXG4BPI_SSID     0x002c
+#define SILICOM_PXG4BPFI_SSID    0x002d
+#define SILICOM_PXG4BPFILX_SSID  0x002e
+#define SILICOM_PXG2BPFIL_SSID   0x002F
+#define SILICOM_PXG2BPFILLX_SSID 0x0030
+#define SILICOM_PEG4BPI_SSID     0x0031
+#define SILICOM_PEG2BPI_SSID     0x0037
+#define SILICOM_PEG4BPIN_SSID    0x0038
+#define SILICOM_PEG2BPFI_SSID    0x0039
+#define SILICOM_PEG2BPFILX_SSID  0x003A
+#define SILICOM_PMCXG2BPFI_SSID  0x003B
+#define NOKIA_PMCXG2BPFIN_SSID   0x0510
+#define NOKIA_PMCXG2BPIN_SSID    0x0513
+#define NOKIA_PMCXG4BPIN_SSID    0x0514
+#define NOKIA_PMCXG2BPFIN_SVID   0x13B8
+#define NOKIA_PMCXG2BPIN2_SSID    0x0515
+#define NOKIA_PMCXG4BPIN2_SSID    0x0516
+#define SILICOM_PMCX2BPI_SSID       0x041
+#define SILICOM_PMCX4BPI_SSID       0x042
+#define SILICOM_PXG2BISC1_SSID   0x003d
+#define SILICOM_PEG2TBFI_SSID    0x003E
+#define SILICOM_PXG2TBI_SSID     0x003f
+#define SILICOM_PXG4BPFID_SSID   0x0043
+#define SILICOM_PEG4BPFI_SSID    0x0040
+#define SILICOM_PEG4BPIPT_SSID   0x0044
+#define SILICOM_PXG6BPI_SSID     0x0045
+#define SILICOM_PEG4BPIL_SSID    0x0046
+#define SILICOM_PEG2BPI5_SSID    0x0052
+#define SILICOM_PEG6BPI_SSID    0x0053
+#define SILICOM_PEG4BPFI5_SSID   0x0050
+#define SILICOM_PEG4BPFI5LX_SSID   0x0051
+#define SILICOM_PEG2BISC6_SSID 0x54
+
+#define SILICOM_PEG6BPIFC_SSID 0x55
+
+#define SILICOM_PEG2BPFI5_SSID   0x0056
+#define SILICOM_PEG2BPFI5LX_SSID   0x0057
+
+#define SILICOM_PXEG4BPFI_SSID    0x0058
+
+#define SILICOM_PEG2BPFID_SSID   0x0047
+#define SILICOM_PEG2BPFIDLX_SSID  0x004C
+#define SILICOM_MEG2BPFILN_SSID  0x0048
+#define SILICOM_MEG2BPFINX_SSID  0x0049
+#define SILICOM_PEG4BPFILX_SSID  0x004A
+#define SILICOM_MHIO8AD_SSID    0x004F
+
+#define SILICOM_MEG2BPFILXLN_SSID 0x004b
+#define SILICOM_PEG2BPIX1_SSID    0x004d
+#define SILICOM_MEG2BPFILXNX_SSID 0x004e
+
+#define SILICOM_PE10G2BPISR_SSID  0x0102
+#define SILICOM_PE10G2BPILR_SSID  0x0103
+#define SILICOM_PE10G2BPICX4_SSID  0x0101
+
+#define SILICOM_XE10G2BPILR_SSID 0x0163
+#define SILICOM_XE10G2BPISR_SSID 0x0162
+#define SILICOM_XE10G2BPICX4_SSID 0x0161
+#define SILICOM_XE10G2BPIT_SSID   0x0160
+
+#define SILICOM_PE10GDBISR_SSID   0x0181
+#define SILICOM_PE10GDBILR_SSID   0x0182
+
+#define SILICOM_PE210G2DBi9SR_SSID	    0x0188
+#define SILICOM_PE210G2DBi9SRRB_SSID	0x0188
+#define SILICOM_PE210G2DBi9LR_SSID	    0x0189
+#define SILICOM_PE210G2DBi9LRRB_SSID	0x0189
+#define SILICOM_PE310G4DBi940SR_SSID	0x018C
+#define SILICOM_PE310G4DBi940LR_SSID	0x018D
+#define SILICOM_PE310G4DBi940T_SSID	0x018e
+
+#define SILICOM_PE310G4DBi9T_SSID       0x18e
+
+
+
+
+
+#define SILICOM_PE310G4BPi9T_SSID       0x130
+#define SILICOM_PE310G4BPi9SR_SSID        0x132
+#define SILICOM_PE310G4BPi9LR_SSID        0x133
+
+#define SILICOM_PE310G4BPi9SRD_SSID        0x134
+#define SILICOM_PE310G4BPi9LRD_SSID        0x135
+
+
+
+
+
+#define SILICOM_M6E310G4BPi9SR_SSID        0x0492
+#define SILICOM_M6E310G4BPi9LR_SSID        0x0493
+
+
+
+
+#define NOKIA_XE10G2BPIXR_SVID   0x13B8
+#define NOKIA_XE10G2BPIXR_SSID   0x051C
+
+#define INTEL_PEG4BPII_PID   0x10A0
+#define INTEL_PEG4BPFII_PID   0x10A1
+#define INTEL_PEG4BPII_SSID   0x11A0
+#define INTEL_PEG4BPFII_SSID   0x11A1
+
+#define INTEL_PEG4BPIIO_SSID   0x10A0
+#define INTEL_PEG4BPIIO_PID   0x105e
+
+#define BROADCOM_VID         0x14e4
+#define BROADCOM_PE10G2_PID  0x164e
+
+#define SILICOM_PE10G2BPTCX4_SSID 0x0141
+#define SILICOM_PE10G2BPTSR_SSID  0x0142
+#define SILICOM_PE10G2BPTLR_SSID  0x0143
+#define SILICOM_PE10G2BPTT_SSID   0x0140
+
+#define SILICOM_PEG4BPI6_SSID     0x0320
+#define SILICOM_PEG4BPFI6_SSID    0x0321
+#define SILICOM_PEG4BPFI6LX_SSID    0x0322
+#define SILICOM_PEG4BPFI6ZX_SSID    0x0323
+
+#define SILICOM_PEG2BPI6_SSID    0x0300
+#define SILICOM_PEG2BPFI6_SSID    0x0301
+#define SILICOM_PEG2BPFI6LX_SSID    0x0302
+#define SILICOM_PEG2BPFI6ZX_SSID    0x0303
+#define SILICOM_PEG2BPFI6FLXM_SSID  0x0304
+
+#define SILICOM_PEG2DBI6_SSID    0x0308
+#define SILICOM_PEG2DBFI6_SSID    0x0309
+#define SILICOM_PEG2DBFI6LX_SSID    0x030A
+#define SILICOM_PEG2DBFI6ZX_SSID    0x030B
+
+#define SILICOM_MEG2BPI6_SSID     0x0310
+#define SILICOM_XEG2BPI6_SSID    0x0318
+#define SILICOM_PEG4BPI6FC_SSID     0x0328
+#define SILICOM_PEG4BPFI6FC_SSID    0x0329
+#define SILICOM_PEG4BPFI6FCLX_SSID    0x032A
+#define SILICOM_PEG4BPFI6FCZX_SSID    0x032B
+
+#define SILICOM_PEG6BPI6_SSID     0x0340
+#define SILICOM_PE2G6BPI6_SSID     0x0341
+
+#define SILICOM_PEG2BPI6SC6_SSID     0x0360
+
+#define SILICOM_MEG2BPI6_SSID     0x0310
+#define SILICOM_XEG2BPI6_SSID     0x0318
+#define SILICOM_MEG4BPI6_SSID     0x0330
+
+#define SILICOM_PE2G4BPi80L_SSID    0x0380
+
+#define SILICOM_M6E2G8BPi80A_SSID    0x0474
+
+#define SILICOM_PE2G4BPi35_SSID    0x03d8
+
+#define SILICOM_PE2G4BPFi80_SSID    0x0381
+#define SILICOM_PE2G4BPFi80LX_SSID    0x0382
+#define SILICOM_PE2G4BPFi80ZX_SSID    0x0383
+
+#define SILICOM_PE2G4BPi80_SSID    0x0388
+
+#define SILICOM_PE2G2BPi80_SSID    0x0390
+#define SILICOM_PE2G2BPFi80_SSID    0x0391
+#define SILICOM_PE2G2BPFi80LX_SSID    0x0392
+#define SILICOM_PE2G2BPFi80ZX_SSID    0x0393
+
+#define SILICOM_PE2G4BPi35L_SSID    0x03D0
+#define SILICOM_PE2G4BPFi35_SSID    0x03D1
+
+#define SILICOM_PE2G4BPFi35CS_SSID    0x0b80
+
+
+#define SILICOM_PE2G4BPFi35LX_SSID    0x03D2
+#define SILICOM_PE2G4BPFi35ZX_SSID    0x03D3
+
+#define SILICOM_M1E2G4BPi35_SSID    0x04D0
+#define SILICOM_M1E2G4BPFi35_SSID    0x04D1
+#define SILICOM_M1E2G4BPFi35LX_SSID    0x04D2
+#define SILICOM_M1E2G4BPFi35ZX_SSID    0x04D3
+
+#define SILICOM_M1E2G4BPi35JP_SSID    0x1800
+#define SILICOM_M1E2G4BPi35JP1_SSID    0x1801
+
+#define SILICOM_PE2G2BPi35_SSID    0x03c0
+#define SILICOM_PAC1200BPi35_SSID    0x03cc
+#define SILICOM_PE2G2BPFi35_SSID    0x03C1
+#define SILICOM_PE2G2BPFi35LX_SSID    0x03C2
+#define SILICOM_PE2G2BPFi35ZX_SSID    0x03C3
+
+#define SILICOM_PE2G6BPi35_SSID    0x03E0
+#define SILICOM_PE2G6BPi35CX_SSID  0x0AA0
+
+#define INTEL_PE210G2SPI9_SSID     0x00C
+
+#define SILICOM_M1EG2BPI6_SSID     0x400
+
+#define SILICOM_M1EG2BPFI6_SSID     0x0401
+#define SILICOM_M1EG2BPFI6LX_SSID     0x0402
+#define SILICOM_M1EG2BPFI6ZX_SSID     0x0403
+
+#define SILICOM_M1EG4BPI6_SSID     0x0420
+
+#define SILICOM_M1EG4BPFI6_SSID       0x0421
+#define SILICOM_M1EG4BPFI6LX_SSID     0x0422
+#define SILICOM_M1EG4BPFI6ZX_SSID     0x0423
+
+#define SILICOM_M1EG6BPI6_SSID     0x0440
+
+#define SILICOM_M1E2G4BPi80_SSID     0x0460
+#define SILICOM_M1E2G4BPFi80_SSID       0x0461
+#define SILICOM_M1E2G4BPFi80LX_SSID     0x0462
+#define SILICOM_M1E2G4BPFi80ZX_SSID     0x0463
+
+#define SILICOM_M6E2G8BPi80_SSID        0x0470
+#define SILICOM_PE210G2BPi40_SSID       0x01a0
+
+#define SILICOM_M1E210G2BPI40T_SSID     0x0480
+#define SILICOM_PE310G4BPi40_SSID       0x01a4
+
+#define PEG540_IF_SERIES(pid) \
+	((pid == SILICOM_PE210G2BPi40_SSID) || \
+	 (pid == SILICOM_PE310G4BPi40_SSID) || \
+	 (pid == SILICOM_M1E210G2BPI40T_SSID))
+
+
+#define OLD_IF_SERIES(pid)\
+	((pid == SILICOM_PXG2BPFI_SSID) || \
+	 (pid == SILICOM_PXG2BPFILX_SSID))
+
+#define P2BPFI_IF_SERIES(pid) \
+	((pid == SILICOM_PXG2BPFI_SSID) || \
+	 (pid == SILICOM_PXG2BPFILX_SSID) || \
+	 (pid == SILICOM_PEG2BPFI_SSID) || \
+	 (pid == SILICOM_PEG2BPFID_SSID) || \
+	 (pid == SILICOM_PEG2BPFIDLX_SSID) || \
+	 (pid == SILICOM_MEG2BPFILN_SSID) || \
+	 (pid == SILICOM_MEG2BPFINX_SSID) || \
+	 (pid == SILICOM_PEG4BPFILX_SSID) || \
+	 (pid == SILICOM_PEG4BPFI_SSID) || \
+	 (pid == SILICOM_PXEG4BPFI_SSID) || \
+	 (pid == SILICOM_PXG4BPFID_SSID) || \
+	 (pid == SILICOM_PEG2TBFI_SSID) || \
+	 (pid == SILICOM_PE10G2BPISR_SSID) || \
+	 (pid == SILICOM_PE10G2BPILR_SSID) || \
+	 (pid == SILICOM_PEG2BPFILX_SSID) || \
+	 (pid == SILICOM_PMCXG2BPFI_SSID) || \
+	 (pid == SILICOM_MHIO8AD_SSID) || \
+	 (pid == SILICOM_PEG4BPFI5LX_SSID) || \
+	 (pid == SILICOM_PEG4BPFI5_SSID) || \
+	 (pid == SILICOM_PEG4BPFI6FC_SSID) || \
+	 (pid == SILICOM_PEG4BPFI6FCLX_SSID) || \
+	 (pid == SILICOM_PEG4BPFI6FCZX_SSID) || \
+	 (pid == NOKIA_PMCXG2BPFIN_SSID) || \
+	 (pid == SILICOM_MEG2BPFILXLN_SSID) || \
+	 (pid == SILICOM_MEG2BPFILXNX_SSID) || \
+	 (pid == SILICOM_XE10G2BPIT_SSID) || \
+	 (pid == SILICOM_XE10G2BPICX4_SSID) || \
+	 (pid == SILICOM_XE10G2BPISR_SSID) || \
+	 (pid == NOKIA_XE10G2BPIXR_SSID) || \
+	 (pid == SILICOM_PE10GDBISR_SSID) || \
+	 (pid == SILICOM_PE10GDBILR_SSID) || \
+	 (pid == SILICOM_XE10G2BPILR_SSID))
+
+#define INTEL_IF_SERIES(pid) \
+	((pid == INTEL_PEG4BPII_SSID) || \
+	 (pid == INTEL_PEG4BPIIO_SSID) || \
+	 (pid == INTEL_PEG4BPFII_SSID))
+
+#define NOKIA_SERIES(pid) \
+	((pid == NOKIA_PMCXG2BPIN_SSID) || \
+	 (pid == NOKIA_PMCXG4BPIN_SSID) || \
+	 (pid == SILICOM_PMCX4BPI_SSID) || \
+	 (pid == NOKIA_PMCXG2BPFIN_SSID) || \
+	 (pid == SILICOM_PMCXG2BPFI_SSID) || \
+	 (pid == NOKIA_PMCXG2BPIN2_SSID) || \
+	 (pid == NOKIA_PMCXG4BPIN2_SSID) || \
+	 (pid == SILICOM_PMCX2BPI_SSID))
+
+#define DISCF_IF_SERIES(pid) \
+	(pid == SILICOM_PEG2TBFI_SSID)
+
+#define PEGF_IF_SERIES(pid) \
+	((pid == SILICOM_PEG2BPFI_SSID) || \
+	 (pid == SILICOM_PEG2BPFID_SSID) || \
+	 (pid == SILICOM_PEG2BPFIDLX_SSID) || \
+	 (pid == SILICOM_PEG2BPFILX_SSID) || \
+	 (pid == SILICOM_PEG4BPFI_SSID) || \
+	 (pid == SILICOM_PXEG4BPFI_SSID) || \
+	 (pid == SILICOM_MEG2BPFILN_SSID) || \
+	 (pid == SILICOM_MEG2BPFINX_SSID) || \
+	 (pid == SILICOM_PEG4BPFILX_SSID) || \
+	 (pid == SILICOM_PEG2TBFI_SSID) || \
+	 (pid == SILICOM_MEG2BPFILXLN_SSID) || \
+	 (pid == SILICOM_MEG2BPFILXNX_SSID))
+
+#define TPL_IF_SERIES(pid) \
+	((pid == SILICOM_PXG2BPFIL_SSID) || \
+	 (pid == SILICOM_PXG2BPFILLX_SSID) || \
+	 (pid == SILICOM_PXG2TBFI_SSID) || \
+	 (pid == SILICOM_PXG4BPFID_SSID) || \
+	 (pid == SILICOM_PXG4BPFI_SSID))
+
+#define BP10G_IF_SERIES(pid) \
+	((pid == SILICOM_PE10G2BPISR_SSID) || \
+	 (pid == SILICOM_PE10G2BPICX4_SSID) || \
+	 (pid == SILICOM_PE10G2BPILR_SSID) || \
+	 (pid == SILICOM_XE10G2BPIT_SSID) || \
+	 (pid == SILICOM_XE10G2BPICX4_SSID) || \
+	 (pid == SILICOM_XE10G2BPISR_SSID) || \
+	 (pid == NOKIA_XE10G2BPIXR_SSID) || \
+	 (pid == SILICOM_PE10GDBISR_SSID) || \
+	 (pid == SILICOM_PE10GDBILR_SSID) || \
+	 (pid == SILICOM_XE10G2BPILR_SSID))
+
+#define BP10GB_IF_SERIES(pid) \
+	((pid == SILICOM_PE10G2BPTCX4_SSID) || \
+	 (pid == SILICOM_PE10G2BPTSR_SSID) || \
+	 (pid == SILICOM_PE10G2BPTLR_SSID) || \
+	 (pid == SILICOM_PE10G2BPTT_SSID))
+
+#define BP10G_CX4_SERIES(pid) \
+	(pid == SILICOM_PE10G2BPICX4_SSID)
+
+#define BP10GB_CX4_SERIES(pid) \
+	(pid == SILICOM_PE10G2BPTCX4_SSID)
+
+#define SILICOM_M2EG2BPFI6_SSID       0x0501
+#define SILICOM_M2EG2BPFI6LX_SSID     0x0502
+#define SILICOM_M2EG2BPFI6ZX_SSID     0x0503
+#define SILICOM_M2EG4BPI6_SSID        0x0520
+
+#define SILICOM_M2EG4BPFI6_SSID       0x0521
+#define SILICOM_M2EG4BPFI6LX_SSID     0x0522
+#define SILICOM_M2EG4BPFI6ZX_SSID     0x0523
+
+#define SILICOM_M2EG6BPI6_SSID     0x0540
+
+#define SILICOM_M1E10G2BPI9CX4_SSID  0x481
+#define SILICOM_M1E10G2BPI9SR_SSID   0x482
+#define SILICOM_M1E10G2BPI9LR_SSID   0x483
+
+#define SILICOM_M2E10G2BPI9CX4_SSID  0x581
+#define SILICOM_M2E10G2BPI9SR_SSID   0x582
+#define SILICOM_M2E10G2BPI9LR_SSID   0x583
+#define SILICOM_M2E10G2BPI9T_SSID    0x580
+
+#define SILICOM_PE210G2BPI9CX4_SSID  0x121
+#define SILICOM_PE210G2BPI9SR_SSID   0x122
+#define SILICOM_PE210G2BPI9LR_SSID   0x123
+#define SILICOM_PE210G2BPI9LRD_SSID  0x125
+#define SILICOM_PE210G2BPI9SRD_SSID  0x124
+#define SILICOM_PE210G2BPI9T_SSID    0x120
+
+#define SILICOM_M1E210G2BPI9SRDJP_SSID 0x1E00
+#define SILICOM_M1E210G2BPI9SRDJP1_SSID 0x1E10
+#define SILICOM_M1E210G2BPI9LRDJP_SSID 0x1F00
+#define SILICOM_M1E210G2BPI9LRDJP1_SSID 0x1F10
+
+
+
+#define DBI_IF_SERIES(pid) \
+	((pid == SILICOM_PE10GDBISR_SSID) || \
+	 (pid == SILICOM_PE10GDBILR_SSID) || \
+	 (pid == SILICOM_XE10G2BPILR_SSID) || \
+	 (pid == SILICOM_PE210G2DBi9LR_SSID))
+
+#define PEGF5_IF_SERIES(pid) \
+	((pid == SILICOM_PEG2BPFI5_SSID) || \
+	 (pid == SILICOM_PEG2BPFI5LX_SSID) || \
+	 (pid == SILICOM_PEG4BPFI6_SSID) || \
+	 (pid == SILICOM_PEG4BPFI6LX_SSID) || \
+	 (pid == SILICOM_PEG4BPFI6ZX_SSID) || \
+	 (pid == SILICOM_PEG2BPFI6_SSID) || \
+	 (pid == SILICOM_PEG2BPFI6LX_SSID) || \
+	 (pid == SILICOM_PEG2BPFI6ZX_SSID) || \
+	 (pid == SILICOM_PEG2BPFI6FLXM_SSID) || \
+	 (pid == SILICOM_PEG2DBFI6_SSID) || \
+	 (pid == SILICOM_PEG2DBFI6LX_SSID) || \
+	 (pid == SILICOM_PEG2DBFI6ZX_SSID) || \
+	 (pid == SILICOM_PEG4BPI6FC_SSID) || \
+	 (pid == SILICOM_PEG4BPFI6FCLX_SSID) || \
+	 (pid == SILICOM_PEG4BPI6FC_SSID) || \
+	 (pid == SILICOM_M1EG2BPFI6_SSID) || \
+	 (pid == SILICOM_M1EG2BPFI6LX_SSID) || \
+	 (pid == SILICOM_M1EG2BPFI6ZX_SSID) || \
+	 (pid == SILICOM_M1EG4BPFI6_SSID) || \
+	 (pid == SILICOM_M1EG4BPFI6LX_SSID) || \
+	 (pid == SILICOM_M1EG4BPFI6ZX_SSID) || \
+	 (pid == SILICOM_M2EG2BPFI6_SSID) || \
+	 (pid == SILICOM_M2EG2BPFI6LX_SSID) || \
+	 (pid == SILICOM_M2EG2BPFI6ZX_SSID) || \
+	 (pid == SILICOM_M2EG4BPFI6_SSID) || \
+	 (pid == SILICOM_M2EG4BPFI6LX_SSID) || \
+	 (pid == SILICOM_M2EG4BPFI6ZX_SSID) || \
+	 (pid == SILICOM_PEG4BPFI6FCZX_SSID))
+
+#define PEG5_IF_SERIES(pid) \
+	((pid == SILICOM_PEG4BPI6_SSID) || \
+	 (pid == SILICOM_PEG2BPI6_SSID) || \
+	 (pid == SILICOM_PEG2BPI6SC6_SSID) || \
+	 (pid == SILICOM_PEG4BPI6FC_SSID) || \
+	 (pid == SILICOM_PEG6BPI6_SSID) || \
+	 (pid == SILICOM_MEG2BPI6_SSID) || \
+	 (pid == SILICOM_XEG2BPI6_SSID) || \
+	 (pid == SILICOM_MEG4BPI6_SSID) || \
+	 (pid == SILICOM_M1EG2BPI6_SSID) || \
+	 (pid == SILICOM_M1EG4BPI6_SSID) || \
+	 (pid == SILICOM_M1EG6BPI6_SSID) || \
+	 (pid == SILICOM_PEG6BPI_SSID) || \
+	 (pid == SILICOM_PEG4BPIL_SSID) || \
+	 (pid == SILICOM_PEG2BISC6_SSID) || \
+	 (pid == SILICOM_PEG2BPI5_SSID))
+
+
+#define PEG80_IF_SERIES(pid) \
+	((pid == SILICOM_M1E2G4BPi80_SSID) || \
+	 (pid == SILICOM_M6E2G8BPi80_SSID) || \
+	 (pid == SILICOM_PE2G4BPi80L_SSID) || \
+	 (pid == SILICOM_M6E2G8BPi80A_SSID) || \
+	 (pid == SILICOM_PE2G2BPi35_SSID) || \
+	 (pid == SILICOM_PAC1200BPi35_SSID) || \
+	 (pid == SILICOM_PE2G4BPi35_SSID) || \
+	 (pid == SILICOM_PE2G4BPi35L_SSID) || \
+	 (pid == SILICOM_M1E2G4BPi35_SSID) || \
+	 (pid == SILICOM_M1E2G4BPi35JP_SSID) || \
+	 (pid == SILICOM_M1E2G4BPi35JP1_SSID) || \
+	 (pid == SILICOM_PE2G6BPi35_SSID) || \
+	 (pid == SILICOM_PE2G2BPi80_SSID) || \
+	 (pid == SILICOM_PE2G4BPi80_SSID) || \
+	 (pid == SILICOM_PE2G4BPFi80_SSID) || \
+	 (pid == SILICOM_PE2G4BPFi80LX_SSID) || \
+	 (pid == SILICOM_PE2G4BPFi80ZX_SSID) || \
+	 (pid == SILICOM_PE2G4BPFi80ZX_SSID) || \
+	 (pid == SILICOM_PE2G2BPFi80_SSID) || \
+	 (pid == SILICOM_PE2G2BPFi80LX_SSID) || \
+	 (pid == SILICOM_PE2G2BPFi80ZX_SSID) || \
+	 (pid == SILICOM_PE2G2BPFi35_SSID) || \
+	 (pid == SILICOM_PE2G2BPFi35LX_SSID) || \
+	 (pid == SILICOM_PE2G2BPFi35ZX_SSID) || \
+	 (pid == SILICOM_M1E2G4BPFi35_SSID) || \
+	 (pid == SILICOM_M1E2G4BPFi35LX_SSID) || \
+	 (pid == SILICOM_M1E2G4BPFi35ZX_SSID) || \
+	 (pid == SILICOM_PE2G4BPFi35_SSID) || \
+	 (pid == SILICOM_PE2G4BPFi35CS_SSID) || \
+	 (pid == SILICOM_PE2G4BPFi35LX_SSID) || \
+	 (pid == SILICOM_PE2G4BPFi35ZX_SSID))
+
+#define PEGF80_IF_SERIES(pid) \
+	((pid == SILICOM_PE2G4BPFi80_SSID) || \
+	 (pid == SILICOM_PE2G4BPFi80LX_SSID) || \
+	 (pid == SILICOM_PE2G4BPFi80ZX_SSID) || \
+	 (pid == SILICOM_PE2G4BPFi80ZX_SSID) || \
+	 (pid == SILICOM_M1E2G4BPFi80_SSID) || \
+	 (pid == SILICOM_M1E2G4BPFi80LX_SSID) || \
+	 (pid == SILICOM_M1E2G4BPFi80ZX_SSID) || \
+	 (pid == SILICOM_PE2G2BPFi80_SSID) || \
+	 (pid == SILICOM_PE2G2BPFi80LX_SSID) || \
+	 (pid == SILICOM_PE2G2BPFi80ZX_SSID) || \
+	 (pid == SILICOM_PE2G2BPFi35_SSID) || \
+	 (pid == SILICOM_PE2G2BPFi35LX_SSID) || \
+	 (pid == SILICOM_PE2G2BPFi35ZX_SSID) || \
+	 (pid == SILICOM_M1E2G4BPFi35_SSID) || \
+	 (pid == SILICOM_M1E2G4BPFi35LX_SSID) || \
+	 (pid == SILICOM_M1E2G4BPFi35ZX_SSID) || \
+	 (pid == SILICOM_PE2G4BPFi35_SSID) || \
+	 (pid == SILICOM_PE2G4BPFi35CS_SSID) || \
+	 (pid == SILICOM_PE2G4BPFi35LX_SSID) || \
+	 (pid == SILICOM_PE2G4BPFi35ZX_SSID))
+
+#define BP10G9_IF_SERIES(pid) \
+	((pid == INTEL_PE210G2SPI9_SSID) || \
+	 (pid == SILICOM_M1E10G2BPI9CX4_SSID) || \
+	 (pid == SILICOM_M1E10G2BPI9SR_SSID) || \
+	 (pid == SILICOM_M1E10G2BPI9LR_SSID) || \
+	 (pid == SILICOM_M2E10G2BPI9CX4_SSID) || \
+	 (pid == SILICOM_M2E10G2BPI9SR_SSID) || \
+	 (pid == SILICOM_M2E10G2BPI9LR_SSID) || \
+	 (pid == SILICOM_M2E10G2BPI9T_SSID) || \
+	 (pid == SILICOM_PE210G2BPI9CX4_SSID) || \
+	 (pid == SILICOM_PE210G2BPI9SR_SSID) || \
+	 (pid == SILICOM_PE210G2BPI9LR_SSID) || \
+	 (pid == SILICOM_PE210G2BPI9LRD_SSID) || \
+	 (pid == SILICOM_PE210G2BPI9SRD_SSID) || \
+	 (pid == SILICOM_PE210G2DBi9SR_SSID) || \
+	 (pid == SILICOM_PE210G2DBi9SRRB_SSID) || \
+	 (pid == SILICOM_PE210G2DBi9LR_SSID) || \
+	 (pid == SILICOM_PE210G2DBi9LRRB_SSID) || \
+	 (pid == SILICOM_PE310G4DBi940SR_SSID) || \
+	 (pid == SILICOM_PE310G4DBi940LR_SSID) || \
+	 (pid == SILICOM_PE310G4DBi940T_SSID) || \
+	 (pid == SILICOM_PE310G4DBi9T_SSID) || \
+	 (pid == SILICOM_PE310G4BPi9T_SSID) || \
+	 (pid == SILICOM_PE310G4BPi9SR_SSID) || \
+	 (pid == SILICOM_PE310G4BPi9SRD_SSID) || \
+	 (pid == SILICOM_M6E310G4BPi9SR_SSID) || \
+	 (pid == SILICOM_M6E310G4BPi9LR_SSID) || \
+	 (pid == SILICOM_PE310G4BPi9LR_SSID) || \
+	 (pid == SILICOM_PE310G4BPi9LRD_SSID) || \
+	 (pid == SILICOM_M1E210G2BPI9SRDJP_SSID) || \
+	 (pid == SILICOM_M1E210G2BPI9SRDJP1_SSID) || \
+	 (pid == SILICOM_M1E210G2BPI9LRDJP_SSID) || \
+	 (pid == SILICOM_M1E210G2BPI9LRDJP1_SSID) || \
+	 (pid == SILICOM_PE210G2BPI9T_SSID))
+
+/*******************************************************/
+/* 1G INTERFACE ****************************************/
+/*******************************************************/
+
+/* Intel Registers */
+#define BPCTLI_CTRL          0x00000
+#define BPCTLI_CTRL_SWDPIO0  0x00400000
+#define BPCTLI_CTRL_SWDPIN0  0x00040000
+
+#define BPCTLI_CTRL_EXT 0x00018	/* Extended Device Control - RW */
+#define BPCTLI_STATUS   0x00008	/* Device Status - RO */
+
+/* HW related */
+#define BPCTLI_CTRL_EXT_SDP6_DATA 0x00000040
+#define BPCTLI_CTRL_EXT_SDP7_DATA 0x00000080
+#define BPCTLI_CTRL_SDP0_DATA     0x00040000
+#define BPCTLI_CTRL_EXT_SDP6_DIR  0x00000400
+#define BPCTLI_CTRL_EXT_SDP7_DIR  0x00000800
+#define BPCTLI_CTRL_SDP0_DIR      0x00400000
+#define BPCTLI_CTRL_SWDPIN1       0x00080000
+#define BPCTLI_CTRL_SDP1_DIR      0x00800000
+
+#define BPCTLI_STATUS_LU          0x00000002	/* Link up.0=no,1=link */
+
+#define BPCTLI_CTRL_SDP0_SHIFT     18
+#define BPCTLI_CTRL_EXT_SDP6_SHIFT 6
+
+#define BPCTLI_STATUS_TBIMODE     0x00000020
+#define BPCTLI_CTRL_EXT_LINK_MODE_PCIE_SERDES  0x00C00000
+#define BPCTLI_CTRL_EXT_LINK_MODE_MASK         0x00C00000
+
+#define BPCTLI_CTRL_EXT_MCLK_DIR  BPCTLI_CTRL_EXT_SDP7_DIR
+#define BPCTLI_CTRL_EXT_MCLK_DATA BPCTLI_CTRL_EXT_SDP7_DATA
+#define BPCTLI_CTRL_EXT_MDIO_DIR  BPCTLI_CTRL_EXT_SDP6_DIR
+#define BPCTLI_CTRL_EXT_MDIO_DATA BPCTLI_CTRL_EXT_SDP6_DATA
+
+#define BPCTLI_CTRL_EXT_MCLK_DIR5  BPCTLI_CTRL_SDP1_DIR
+#define BPCTLI_CTRL_EXT_MCLK_DATA5 BPCTLI_CTRL_SWDPIN1
+#define BPCTLI_CTRL_EXT_MCLK_DIR80  BPCTLI_CTRL_EXT_SDP6_DIR
+#define BPCTLI_CTRL_EXT_MCLK_DATA80 BPCTLI_CTRL_EXT_SDP6_DATA
+#define BPCTLI_CTRL_EXT_MDIO_DIR5  BPCTLI_CTRL_SWDPIO0
+#define BPCTLI_CTRL_EXT_MDIO_DATA5 BPCTLI_CTRL_SWDPIN0
+#define BPCTLI_CTRL_EXT_MDIO_DIR80  BPCTLI_CTRL_SWDPIO0
+#define BPCTLI_CTRL_EXT_MDIO_DATA80 BPCTLI_CTRL_SWDPIN0
+
+#define BPCTL_WRITE_REG(a, reg, value) \
+	(writel((value), (void *)(((a)->mem_map) + BPCTLI_##reg)))
+
+#define BPCTL_READ_REG(a, reg) ( \
+	readl((void *)((a)->mem_map) + BPCTLI_##reg))
+
+#define BPCTL_WRITE_FLUSH(a) BPCTL_READ_REG(a, STATUS)
+
+#define BPCTL_BP_WRITE_REG(a, reg, value) ({ \
+	BPCTL_WRITE_REG(a, reg, value); \
+	BPCTL_WRITE_FLUSH(a); })
+
+/**************************************************************/
+/************** 82575 Interface********************************/
+/**************************************************************/
+
+#define BPCTLI_MDIC     0x00020	/* MDI Control - RW */
+#define BPCTLI_IGP01E1000_PHY_PAGE_SELECT        0x1F	/* Page Select */
+#define BPCTLI_MAX_PHY_REG_ADDRESS    0x1F	/* 5 bit address bus (0-0x1F) */
+
+#define BPCTLI_MDIC_DATA_MASK 0x0000FFFF
+#define BPCTLI_MDIC_REG_MASK  0x001F0000
+#define BPCTLI_MDIC_REG_SHIFT 16
+#define BPCTLI_MDIC_PHY_MASK  0x03E00000
+#define BPCTLI_MDIC_PHY_SHIFT 21
+#define BPCTLI_MDIC_OP_WRITE  0x04000000
+#define BPCTLI_MDIC_OP_READ   0x08000000
+#define BPCTLI_MDIC_READY     0x10000000
+#define BPCTLI_MDIC_INT_EN    0x20000000
+#define BPCTLI_MDIC_ERROR     0x40000000
+
+#define BPCTLI_SWFW_PHY0_SM  0x02
+#define BPCTLI_SWFW_PHY1_SM  0x04
+
+#define BPCTLI_SW_FW_SYNC  0x05B5C
+#define BPCTLI_SWSM      0x05B50 /* SW Semaphore */
+#define BPCTLI_FWSM      0x05B54 /* FW Semaphore */
+
+#define BPCTLI_SWSM_SMBI         0x00000001	/* Driver Semaphore bit */
+#define BPCTLI_SWSM_SWESMBI      0x00000002	/* FW Semaphore bit */
+#define BPCTLI_MAX_PHY_MULTI_PAGE_REG 0xF
+#define BPCTLI_GEN_POLL_TIMEOUT          640
+
+/********************************************************/
+
+/********************************************************/
+/* 10G INTERFACE ****************************************/
+/********************************************************/
+
+#define BP10G_I2CCTL              0x28
+
+/* I2CCTL Bit Masks */
+#define BP10G_I2C_CLK_IN    0x00000001
+#define BP10G_I2C_CLK_OUT   0x00000002
+#define BP10G_I2C_DATA_IN   0x00000004
+#define BP10G_I2C_DATA_OUT  0x00000008
+
+#define BP10G_ESDP                0x20
+
+#define BP10G_SDP0_DIR            0x100
+#define BP10G_SDP1_DIR            0x200
+#define BP10G_SDP3_DIR            0x800
+#define BP10G_SDP4_DIR            BIT(12)
+#define BP10G_SDP5_DIR            0x2000
+#define BP10G_SDP0_DATA           0x001
+#define BP10G_SDP1_DATA           0x002
+#define BP10G_SDP3_DATA           0x008
+#define BP10G_SDP4_DATA           0x010
+#define BP10G_SDP5_DATA           0x020
+
+#define BP10G_SDP2_DIR            0x400
+#define BP10G_SDP2_DATA            0x4
+
+#define BP10G_EODSDP              0x28
+
+#define BP10G_SDP6_DATA_IN        0x001
+#define BP10G_SDP6_DATA_OUT       0x002
+
+#define BP10G_SDP7_DATA_IN        0x004
+#define BP10G_SDP7_DATA_OUT       0x008
+
+#define BP10G_MCLK_DATA_OUT       BP10G_SDP7_DATA_OUT
+#define BP10G_MDIO_DATA_OUT       BP10G_SDP6_DATA_OUT
+#define BP10G_MDIO_DATA_IN        BP10G_SDP6_DATA_IN
+
+#define BP10G_MDIO_DATA           BP10G_SDP3_DATA
+#define BP10G_MDIO_DIR            BP10G_SDP3_DATA
+#define BP10G_MDIO_DATA_OUT9      BP10G_I2C_DATA_OUT
+
+/* VIA EOSDP ! */
+#define BP10G_MCLK_DATA_OUT9           BP10G_SDP4_DATA
+#define BP10G_MCLK_DIR_OUT9            BP10G_SDP4_DIR
+
+
+#define BP10G_MDIO_DATA_IN9           BP10G_I2C_DATA_IN
+
+#define BP540_MDIO_DATA           BP10G_SDP0_DATA
+#define BP540_MDIO_DIR            BP10G_SDP0_DIR
+#define BP540_MCLK_DATA           BP10G_SDP2_DATA
+#define BP540_MCLK_DIR            BP10G_SDP2_DIR
+
+#define BP10G_WRITE_REG(a, reg, value) \
+	(writel((value), (void *)(((a)->mem_map) + BP10G_##reg)))
+
+#define BP10G_READ_REG(a, reg) ( \
+	readl((void *)((a)->mem_map) + BP10G_##reg))
+
+/*****BROADCOM*******************************************/
+
+#define BP10GB_MISC_REG_GPIO			     0xa490
+#define BP10GB_GPIO3_P0                              BIT(3)
+#define BP10GB_GPIO3_P1                              BIT(7)
+
+#define BP10GB_GPIO3_SET_P0                          BIT(11)
+#define BP10GB_GPIO3_CLR_P0                          BIT(19)
+#define BP10GB_GPIO3_OE_P0                           BIT(27)
+
+#define BP10GB_GPIO3_SET_P1                          BIT(15)
+#define BP10GB_GPIO3_CLR_P1                          BIT(23)
+#define BP10GB_GPIO3_OE_P1                           BIT(31)
+
+#define BP10GB_GPIO0_P1                              0x10
+#define BP10GB_GPIO0_P0                              0x1
+#define BP10GB_GPIO0_CLR_P0                          0x10000
+#define BP10GB_GPIO0_CLR_P1                          0x100000
+#define BP10GB_GPIO0_SET_P0                          0x100
+#define BP10GB_GPIO0_SET_P1                          0x1000
+
+#define BP10GB_GPIO0_OE_P1                           0x10000000
+#define BP10GB_GPIO0_OE_P0                           0x1000000
+
+#define BP10GB_MISC_REG_SPIO			     0xa4fc
+#define BP10GB_GPIO4_OE                              BIT(28)
+#define BP10GB_GPIO5_OE                              BIT(29)
+#define BP10GB_GPIO4_CLR                             BIT(20)
+#define BP10GB_GPIO5_CLR                             BIT(21)
+#define BP10GB_GPIO4_SET                             BIT(12)
+#define BP10GB_GPIO5_SET                             BIT(13)
+#define BP10GB_GPIO4                                 BIT(4)
+#define BP10GB_GPIO5                                 BIT(5)
+
+#define BP10GB_MCLK_DIR  BP10GB_GPIO5_OE
+#define BP10GB_MDIO_DIR  BP10GB_GPIO4_OE
+
+#define BP10GB_MCLK_DATA BP10GB_GPIO5
+#define BP10GB_MDIO_DATA BP10GB_GPIO4
+
+#define BP10GB_MCLK_SET BP10GB_GPIO5_SET
+#define BP10GB_MDIO_SET BP10GB_GPIO4_SET
+
+#define BP10GB_MCLK_CLR BP10GB_GPIO5_CLR
+#define BP10GB_MDIO_CLR BP10GB_GPIO4_CLR
+
+#define BP10GB_WRITE_REG(a, reg, value) \
+	(writel((value), (void *)(((a)->mem_map) + BP10GB_##reg)))
+
+#define BP10GB_READ_REG(a, reg) ( \
+	readl((void *)((a)->mem_map) + BP10GB_##reg))
+
+#endif
diff -uprN -X linux-3.17-rc1-vanilla/Documentation/dontdiff linux-3.17-rc1-vanilla/drivers/bypass/silicom/bp_ctl/bypass.h linux-3.17-rc1/drivers/bypass/silicom/bp_ctl/bypass.h
--- linux-3.17-rc1-vanilla/drivers/bypass/silicom/bp_ctl/bypass.h	1970-01-01 02:00:00.000000000 +0200
+++ linux-3.17-rc1/drivers/bypass/silicom/bp_ctl/bypass.h	2014-08-24 06:39:56.000000000 +0300
@@ -0,0 +1,200 @@
+/******************************************************************************/
+/*                                                                            */
+/* Bypass Control utility, Copyright (c) 2005 Silicom                         */
+/* All rights reserved.                                                       */
+/*                                                                            */
+/* This program is free software; you can redistribute it and/or modify       */
+/* it under the terms of the GNU General Public License as published by       */
+/* the Free Software Foundation, located in the file LICENSE.                 */
+/*                                                                            */
+/*                                                                            */
+/******************************************************************************/
+
+#ifndef BYPASS_H
+#define BYPASS_H
+
+/* Bypass related */
+
+#define SYNC_CMD_VAL               2	/* 10b */
+#define SYNC_CMD_LEN               2
+
+#define WR_CMD_VAL                 2	/* 10b */
+#define WR_CMD_LEN                 2
+
+#define RD_CMD_VAL                 1	/* 10b */
+#define RD_CMD_LEN                 2
+
+#define ADDR_CMD_LEN               4
+
+#define WR_DATA_LEN                8
+#define RD_DATA_LEN                8
+
+#define PIC_SIGN_REG_ADDR          0x7
+#define PIC_SIGN_VALUE         0xcd
+
+#define STATUS_REG_ADDR           0
+#define WDT_EN_MASK            0x01	/* BIT_0 */
+#define CMND_EN_MASK           0x02	/* BIT_1 */
+#define DIS_BYPASS_CAP_MASK    0x04	/* BIT_2    Bypass Cap is disable*/
+#define DFLT_PWRON_MASK        0x08	/* BIT_3 */
+#define BYPASS_OFF_MASK        0x10	/* BIT_4 */
+#define BYPASS_FLAG_MASK       0x20	/* BIT_5 */
+#define STD_NIC_MASK           ((DIS_BYPASS_CAP_MASK | BYPASS_OFF_MASK | \
+				DFLT_PWRON_MASK))
+
+#define WD_EXP_FLAG_MASK       0x40	/* BIT_6 */
+#define DFLT_PWROFF_MASK       0x80	/* BIT_7 */
+#define STD_NIC_PWOFF_MASK     ((DIS_BYPASS_CAP_MASK | BYPASS_OFF_MASK | \
+				DFLT_PWRON_MASK | DFLT_PWROFF_MASK))
+
+#define PRODUCT_CAP_REG_ADDR   0x5
+#define BYPASS_SUPPORT_MASK    0x01	/* BIT_0 */
+#define TAP_SUPPORT_MASK       0x02	/* BIT_1 */
+#define NORMAL_UNSUPPORT_MASK  0x04	/* BIT_2 */
+#define DISC_SUPPORT_MASK      0x08	/* BIT_3 */
+#define TPL2_SUPPORT_MASK      0x10	/* BIT_4 */
+#define DISC_PORT_SUPPORT_MASK 0x20	/* BIT_5 */
+
+#define STATUS_TAP_REG_ADDR    0x6
+#define WDTE_TAP_BPN_MASK      0x01	/* BIT_1 */
+#define DIS_TAP_CAP_MASK       0x04	/* BIT_2 */
+#define DFLT_PWRON_TAP_MASK    0x08	/* BIT_3 */
+#define TAP_OFF_MASK           0x10	/* BIT_4 */
+#define TAP_FLAG_MASK          0x20	/* BIT_5 */
+#define TX_DISA_MASK            0x40
+#define TX_DISB_MASK            0x80
+
+#define STD_NIC_TAP_MASK       ((DIS_TAP_CAP_MASK | TAP_OFF_MASK | \
+				 DFLT_PWRON_TAP_MASK))
+
+#define STATUS_DISC_REG_ADDR    13
+#define WDTE_DISC_BPN_MASK      0x01	/* BIT_0 */
+#define STD_NIC_ON_MASK         0x02	/* BIT_1 */
+#define DIS_DISC_CAP_MASK       0x04	/* BIT_2 */
+#define DFLT_PWRON_DISC_MASK    0x08	/* BIT_3 */
+#define DISC_OFF_MASK           0x10	/* BIT_4 */
+#define DISC_FLAG_MASK          0x20	/* BIT_5 */
+#define TPL2_FLAG_MASK          0x40	/* BIT_6 */
+#define STD_NIC_DISC_MASK       DIS_DISC_CAP_MASK
+
+#define CONT_CONFIG_REG_ADDR    12
+#define EN_HW_RESET_MASK       0x2	/* BIT_1 */
+#define WAIT_AT_PWUP_MASK      0x1	/* BIT_0 */
+
+#define VER_REG_ADDR               0x1
+#define BP_FW_VER_A0         0xa0
+#define BP_FW_VER_A1         0xa1
+
+#define INT_VER_MASK           0xf0
+#define EXT_VER_MASK           0xf
+/* */
+#define PXG2BPI_VER            0x0
+#define PXG2TBPI_VER           0x1
+#define PXE2TBPI_VER           0x2
+#define PXG4BPFI_VER           0x4
+#define BP_FW_EXT_VER7         0x6
+#define BP_FW_EXT_VER8         0x8
+#define BP_FW_EXT_VER9         0x9
+
+#define OLD_IF_VER              -1
+
+#define CMND_REG_ADDR              10	/* 1010b */
+#define WDT_REG_ADDR               4
+#define TMRL_REG_ADDR              2
+#define TMRH_REG_ADDR              3
+
+/* NEW_FW */
+#define WDT_INTERVAL               1	/* 5 */
+#define WDT_CMND_INTERVAL          200	/* 50 */
+#define CMND_INTERVAL              200	/* 100 usec */
+#define PULSE_TIME                 100
+
+/* OLD_FW */
+#define INIT_CMND_INTERVAL         40
+#define PULSE_INTERVAL             5
+#define WDT_TIME_CNT               3
+
+/* Intel Commands */
+
+#define CMND_OFF_INT               0xf
+#define PWROFF_BYPASS_ON_INT       0x5
+#define BYPASS_ON_INT              0x6
+#define DIS_BYPASS_CAP_INT         0x4
+#define RESET_WDT_INT              0x1
+
+/* Intel timing */
+
+#define BYPASS_DELAY_INT           4	/* msec */
+#define CMND_INTERVAL_INT          2	/* msec */
+
+/* Silicom Commands */
+#define CMND_ON                    0x4
+#define CMND_OFF                   0x2
+#define BYPASS_ON                  0xa
+#define BYPASS_OFF                 0x8
+#define PORT_LINK_EN               0xe
+#define PORT_LINK_DIS              0xc
+#define WDT_ON                     0x10	/* 0x1f (11111) - max */
+#define TIMEOUT_UNIT           100
+#define TIMEOUT_MAX_STEP       15
+#define WDT_TIMEOUT_MIN        100	/*  msec */
+#define WDT_TIMEOUT_MAX        3276800	/*  msec */
+#define WDT_AUTO_MIN_INT           500
+#define WDT_TIMEOUT_DEF        WDT_TIMEOUT_MIN
+#define WDT_OFF                    0x6
+#define WDT_RELOAD                 0x9
+#define RESET_CONT                 0x20
+#define DIS_BYPASS_CAP             0x22
+#define EN_BYPASS_CAP              0x24
+#define BYPASS_STATE_PWRON         0x26
+#define NORMAL_STATE_PWRON         0x28
+#define BYPASS_STATE_PWROFF        0x27
+#define NORMAL_STATE_PWROFF        0x29
+#define TAP_ON                     0xb
+#define TAP_OFF                    0x9
+#define TAP_STATE_PWRON            0x2a
+#define DIS_TAP_CAP                0x2c
+#define EN_TAP_CAP                 0x2e
+#define STD_NIC_OFF       0x86
+#define STD_NIC_ON       0x84
+#define DISC_ON           0x85
+#define DISC_OFF          0x8a
+#define DISC_STATE_PWRON  0x87
+#define DIS_DISC_CAP      0x88
+#define EN_DISC_CAP       0x89
+#define TPL2_ON                    0x8c
+#define TPL2_OFF                   0x8b
+#define BP_WAIT_AT_PWUP_EN        0x80
+#define BP_WAIT_AT_PWUP_DIS       0x81
+#define BP_HW_RESET_EN             0x82
+#define BP_HW_RESET_DIS            0x83
+
+#define TX_DISA                0x8d
+#define TX_DISB                0x8e
+#define TX_ENA                 0xA0
+#define TX_ENB                 0xA1
+
+#define TX_DISA_PWRUP          0xA2
+#define TX_DISB_PWRUP          0xA3
+#define TX_ENA_PWRUP           0xA4
+#define TX_ENB_PWRUP           0xA5
+
+#define BYPASS_CAP_DELAY           21	/* msec */
+#define DFLT_PWRON_DELAY           10	/* msec */
+#define LATCH_DELAY                13	/* msec */
+#define EEPROM_WR_DELAY             8	/* msec */
+
+#define BP_LINK_MON_DELAY          4	/* sec */
+
+#define BP_FW_EXT_VER0                 0xa0
+#define BP_FW_EXT_VER1                 0xa1
+#define BP_FW_EXT_VER2                0xb1
+
+#define BP_OK        0
+#define BP_NOT_CAP  -1
+#define WDT_STATUS_EXP -2
+#define WDT_STATUS_UNKNOWN -1
+#define WDT_STATUS_EN 1
+#define WDT_STATUS_DIS 0
+
+#endif				/* BYPASS_H */
diff -uprN -X linux-3.17-rc1-vanilla/Documentation/dontdiff linux-3.17-rc1-vanilla/drivers/bypass/silicom/bp_ctl/libbp_sd.h linux-3.17-rc1/drivers/bypass/silicom/bp_ctl/libbp_sd.h
--- linux-3.17-rc1-vanilla/drivers/bypass/silicom/bp_ctl/libbp_sd.h	1970-01-01 02:00:00.000000000 +0200
+++ linux-3.17-rc1/drivers/bypass/silicom/bp_ctl/libbp_sd.h	2014-08-18 10:26:16.000000000 +0300
@@ -0,0 +1,634 @@
+/******************************************************************************/
+/*                                                                            */
+/* bypass library, Copyright (c) 2004 Silicom, Ltd                            */
+/* Corporation.                                                               */
+/*                                                                            */
+/* This program is free software; you can redistribute it and/or modify       */
+/* it under the terms of the GNU General Public License as published by       */
+/* the Free Software Foundation, located in the file LICENSE.                 */
+/*                                                                            */
+/* Ver 1.0.0                                                                  */
+/*                                                                            */
+/* libbypass.h                                                                */
+/*                                                                            */
+/******************************************************************************/
+
+#define BP_CAP                   0x01	/* BIT_0 */
+#define BP_STATUS_CAP            0x02
+#define BP_STATUS_CHANGE_CAP     0x04
+#define SW_CTL_CAP               0x08
+#define BP_DIS_CAP               0x10
+#define BP_DIS_STATUS_CAP        0x20
+#define STD_NIC_CAP              0x40
+#define BP_PWOFF_ON_CAP          0x80
+#define BP_PWOFF_OFF_CAP         0x0100
+#define BP_PWOFF_CTL_CAP         0x0200
+#define BP_PWUP_ON_CAP           0x0400
+#define BP_PWUP_OFF_CAP          0x0800
+#define BP_PWUP_CTL_CAP          0x1000
+#define WD_CTL_CAP               0x2000
+#define WD_STATUS_CAP            0x4000
+#define WD_TIMEOUT_CAP           0x8000
+#define TX_CTL_CAP               0x10000
+#define TX_STATUS_CAP            0x20000
+#define TAP_CAP                  0x40000
+#define TAP_STATUS_CAP           0x80000
+#define TAP_STATUS_CHANGE_CAP    0x100000
+#define TAP_DIS_CAP              0x200000
+#define TAP_DIS_STATUS_CAP       0x400000
+#define TAP_PWUP_ON_CAP          0x800000
+#define TAP_PWUP_OFF_CAP         0x1000000
+#define TAP_PWUP_CTL_CAP         0x2000000
+#define NIC_CAP_NEG              0x4000000	/* BIT 26 */
+
+#define WD_MIN_TIME_GET(desc)   (desc & 0xf)
+#define WDT_STEP_TIME           0x10
+
+struct bp_info {
+	char prod_name[14];
+	unsigned char fw_ver;
+};
+
+/**
+ * is_bypass - check if device is a Bypass controlling device
+ * @if_index: network device index
+ *
+ * Output:
+ *  1 -  if device is bypass controlling device,
+ *  0 -  if device is bypass slave device
+ * -1 -  device not support Bypass
+ **/
+int is_bypass_sd(int if_index);
+
+/**
+ * get_bypass_slave - get second port participate in the Bypass pair
+ * @if_index: network device index
+ *
+ * Output:
+ *  network device index of the slave device
+ * -1 - on failure (device not support Bypass or it's a slave device)
+ **/
+int get_bypass_slave_sd(int if_index);
+
+/**
+ * get_bypass_caps - get second port participate in the Bypass pair
+ * @if_index: network device index
+ *
+ * Output:
+ * flags word on success;flag word is a 32-bit mask word with each bit defines
+ * different capability as described bellow.
+ * Value of 1 for supporting this feature. 0 for not supporting this feature.
+ * -1 - on failure (if the device is not capable of the operation or not a
+ * Bypass device)
+ * Bit	feature	                description
+ *
+ * 0	BP_CAP	                The interface is Bypass capable in general
+ *
+ * 1	BP_STATUS_CAP	        The interface can report of the current Bypass
+ *                              mode
+ *
+ * 2	BP_STATUS_CHANGE_CAP	The interface can report on a change to Bypass
+ *				mode from the last time the mode was defined
+ *
+ * 3	SW_CTL_CAP		The interface is Software controlled capable for
+ *				bypass/non bypass modes.
+ *
+ * 4	BP_DIS_CAP	        The interface is capable of disabling the Bypass
+ *				mode at all times.  This mode will retain its
+ *				mode even during power loss and also after power
+ *				recovery. This will overcome on any bypass
+ *				operation due to watchdog timeout or set bypass
+ *				command.
+ *
+ * 5	BP_DIS_STATUS_CAP	The interface can report of the current
+ *				DIS_BP_CAP
+ *
+ * 6	STD_NIC_CAP		The interface is capable to be configured to
+ *				operate as standard, non Bypass, NIC interface
+ *				(have direct connection to interfaces at all
+ *				power modes)
+ *
+ * 7	BP_PWOFF_NO_CAP		The interface can be in Bypass mode at power off
+ *				state
+ *
+ * 8	BP_PWOFF_OFF_CAP	The interface can disconnect the Bypass mode at
+ *				power off state without effecting all the other
+ *				states of operation
+ *
+ * 9	BP_PWOFF_CTL_CAP	The behavior of the Bypass mode at Power-off
+ *				state can be controlled by software without
+ *				effecting any other state
+ *
+ *10  BP_PWUP_ON_CAP		The interface can be in Bypass mode when power
+ *				is turned on (until the system take control of
+ *				the bypass functionality)
+ *
+ *11	BP_PWUP_OFF_CAP		The interface can disconnect from Bypass mode
+ *				when power is turned on (until the system take
+ *				control of the bypass functionality)
+ *
+ *12	BP_PWUP_CTL_CAP		The behavior of the Bypass mode at Power-up can
+ *				be controlled by software
+ *
+ *13	WD_CTL_CAP		The interface has watchdog capabilities to turn
+ *				to Bypass mode when not reset for defined period
+ *				of time.
+ *
+ *14	WD_STATUS_CAP		The interface can report on the watchdog status
+ *				(Active/inactive)
+ *
+ *15	WD_TIMEOUT_CAP		The interface can report the time left till
+ *				watchdog triggers to Bypass mode.
+ *
+ *16-31 RESERVED
+ *
+ * **/
+int get_bypass_caps_sd(int if_index);
+
+/**
+ * get_wd_set_caps - Obtain watchdog timer setting capabilities
+ * @if_index: network device index
+ *
+ * Output:
+ *
+ * Set of numbers defining the various parameters of the watchdog capable
+ * to be set to as described bellow.
+ * -1 - on failure (device not support Bypass or it's a slave device)
+ *
+ * Bit	feature	        description
+ *
+ * 0-3	WD_MIN_TIME	    The interface WD minimal time period  in 100mS units
+ *
+ * 4	WD_STEP_TIME	The steps of the WD timer in
+ *                      0 - for linear steps (WD_MIN_TIME * X)
+ *                      1 - for multiply by 2 from previous step
+ *                          (WD_MIN_TIME * 2^X)
+ *
+ * 5-8	WD_STEP_COUNT	Number of steps the WD timer supports in 2^X
+ *                      (X bit available for defining the value)
+ *
+ *
+ *
+ **/
+int get_wd_set_caps_sd(int if_index);
+
+/**
+ * set_bypass - set Bypass state
+ * @if_index: network device index of the controlling device
+ * @bypass_mode:  bypass mode (1=on, 0=off)
+ * Output:
+ *  0 - on success
+ * -1 - on failure (device not support Bypass or it's a slave device)
+ **/
+int set_bypass_sd(int if_index, int bypass_mode);
+
+/**
+ * get_bypass - Get Bypass mode state
+ * @if_index: network device index of the controlling device
+ * Output:
+ *  0/1 - (off/on) on success
+ * -1 - on failure (device not support Bypass or it's a slave device)
+ **/
+int get_bypass_sd(int if_index);
+
+/**
+ * get_bypass_change - Get change of Bypass mode state from last status check
+ * @if_index: network device index of the controlling device
+ * Output:
+ *  0/1 - (off/on) on success
+ * -1 - on failure (device not support Bypass or it's a slave device)
+ **/
+int get_bypass_change_sd(int if_index);
+
+/**
+ * set_dis_bypass - Set Disable Bypass mode
+ * @if_index: network device index of the controlling device
+ * @dis_bypass: disable bypass(1=dis, 0=en)
+ * Output:
+ *  0 - on success
+ * -1 - on failure (device is not capable of the operation or device not support
+ *                  Bypass or it's a slave device)
+ **/
+int set_dis_bypass_sd(int if_index, int dis_bypass);
+
+/**
+ * get_dis_bypass - Get Disable Bypass mode state
+ * @if_index: network device index of the controlling device
+ * Output:
+ *  0/1 - on success (normal Bypass mode/ Disable bypass)
+ * -1 - on failure (device is not capable of the operation or device not support
+ *                  Bypass or it's a slave device)
+ **/
+int get_dis_bypass_sd(int if_index);
+
+/**
+ * set_bypass_pwoff - Set Bypass mode at power-off state
+ * @if_index: network device index of the controlling device
+ * @bypass_mode: bypass mode setting at power off state (1=BP en, 0=BP Dis)
+ * Output:
+ *  0 - on success
+ * -1 - on failure (device is not capable of the operation or device not support
+ *                  Bypass or it's a slave device)
+ **/
+int set_bypass_pwoff_sd(int if_index, int bypass_mode);
+
+/**
+ * get_bypass_pwoff - Get Bypass mode state at power-off state
+ * @if_index: network device index of the controlling device
+ * Output:
+ *  0/1 - on success (Disable bypass at power off state / normal Bypass mode)
+ * -1 - on failure (device is not capable of the operation or device not support
+ *                  Bypass or it's a slave device)
+ **/
+int get_bypass_pwoff_sd(int if_index);
+
+/**
+ * set_bypass_pwup - Set Bypass mode at power-up state
+ * @if_index: network device index of the controlling device
+ * @bypass_mode: bypass mode setting at power up state (1=BP en, 0=BP Dis)
+ * Output:
+ *  0 - on success
+ * -1 - on failure (device is not capable of the operation or device not support
+ *                  Bypass or it's a slave device)
+ **/
+int set_bypass_pwup_sd(int if_index, int bypass_mode);
+
+/**
+ * get_bypass_pwup - Get Bypass mode state at power-up state
+ * @if_index: network device index of the controlling device
+ * Output:
+ *  0/1 - on success (Disable bypass at power up state / normal Bypass mode)
+ * -1 - on failure (device is not capable of the operation or device not support
+ *                  Bypass or it's a slave device)
+ **/
+int get_bypass_pwup_sd(int if_index);
+
+/**
+ * set_bypass_wd - Set watchdog state
+ * @if_index: network device index of the controlling device
+ * @ms_timeout: requested timeout (in ms units), 0 for disabling the watchdog
+ *              timer
+ * @ms_timeout_set(output): requested timeout (in ms units), that the adapter
+ *                          supports and will be used by the watchdog
+ * Output:
+ * 0  - on success
+ * -1 - on failure (device is not capable of the operation or device not support
+ *                  Bypass or it's a slave device)
+ **/
+int set_bypass_wd_sd(int if_index, int ms_timeout, int *ms_timeout_set);
+
+/**
+ * get_bypass_wd - Get watchdog state
+ * @if_index: network device index of the controlling device
+ * @ms_timeout (output): WDT timeout (in ms units),
+ *                       -1 for unknown wdt status
+ *                        0 if WDT is disabled
+ * Output:
+ * 0  - on success
+ * -1 - on failure (device is not capable of the operation or device not support
+ *                  Bypass or it's a slave device)
+ **/
+int get_bypass_wd_sd(int if_index, int *ms_timeout_set);
+
+/**
+ * get_wd_expire_time - Get watchdog expire
+ * @if_index: network device index of the controlling device
+ * @ms_time_left (output): time left till watchdog time expire,
+ *                       -1 if WDT has expired
+ *                       0  if WDT is disabled
+ * Output:
+ * 0  - on success
+ * -1 - on failure (device is not capable of the operation or device not support
+ *                  Bypass or it's a slave device or unknown wdt status)
+ **/
+int get_wd_expire_time_sd(int if_index, int *ms_time_left);
+
+/**
+ * reset_bypass_wd_timer - Reset watchdog timer
+ * @if_index: network device index of the controlling device
+ *
+ * Output:
+ * 1  - on success
+ * 0 - watchdog is not configured
+ * -1 - on failure (device is not capable of the operation or device not support
+ *                  Bypass or it's a slave device or unknown wdt status)
+ **/
+int reset_bypass_wd_timer_sd(int if_index);
+
+/**
+ * set_std_nic - Standard NIC mode of operation
+ * @if_index: network device index of the controlling device
+ * @nic_mode: 0/1 (Default Bypass mode / Standard NIC mode)
+ *
+ * Output:
+ * 0  - on success
+ * -1 - on failure (device is not capable of the operation or device not support
+ *                  Bypass or it's a slave device)
+ **/
+int set_std_nic_sd(int if_index, int nic_mode);
+
+/**
+ * get_std_nic - Get Standard NIC mode setting
+ * @if_index: network device index of the controlling device
+ *
+ * Output:
+ * 0/1 (Default Bypass mode / Standard NIC mode) on success
+ * -1 - on failure (device is not capable of the operation or device not support
+ *                  Bypass or it's a slave device)
+ **/
+int get_std_nic_sd(int if_index);
+
+/**
+ * set_tx - set transmitter enable/disable
+ * @if_index: network device index of the controlling device
+ * @tx_state: 0/1 (Transmit Disable / Transmit Enable)
+ *
+ * Output:
+ * 0  - on success
+ * -1 - on failure (device is not capable of the operation )
+ **/
+int set_tx_sd(int if_index, int tx_state);
+
+/**
+ * get_tx - get transmitter state (disable / enable)
+ * @if_index: network device index of the controlling device
+ *
+ * Output:
+ * 0/1 (ransmit Disable / Transmit Enable) on success
+ * -1 - on failure (device is not capable of the operation ordevice not
+ * support Bypass)
+ **/
+int get_tx_sd(int if_index);
+
+/**
+ * set_tpl - set TPL enable/disable
+ * @if_index: network device index of the controlling device
+ * @tx_state: 0/1 (TPL Disable / TPL Enable)
+ *
+ * Output:
+ * 0  - on success
+ * -1 - on failure (device is not capable of the operation )
+ **/
+int set_tpl_sd(int if_index, int tpl_state);
+
+/**
+ * get_tpl - get TPL state (disable / enable)
+ * @if_index: network device index of the controlling device
+ *
+ * Output:
+ * 0/1 (TPL Disable / TPL Enable) on success
+ * -1 - on failure (device is not capable of the operation)
+ **/
+int get_tpl_sd(int if_index);
+
+int get_bp_hw_reset_sd(int if_index);
+
+int set_bp_hw_reset_sd(int if_index, int status);
+
+/**
+ * set_tap - set TAP state
+ * @if_index: network device index of the controlling device
+ * @tap_mode: 1 tap mode , 0 normal nic mode
+ * Output:
+ *  0 - on success
+ * -1 - on failure (device not support TAP or it's a slave device)
+ **/
+int set_tap_sd(int if_index, int tap_mode);
+
+/**
+ * get_tap - Get TAP mode state
+ * @if_index: network device index of the controlling device
+ * Output:
+ *  0/1 - (off/on) on success
+ * -1 - on failure (device not support TAP or it's a slave device)
+ **/
+int get_tap_sd(int if_index);
+
+/**
+ * get_tap_change - Get change of TAP mode state from last status check
+ * @if_index: network device index of the controlling device
+ * Output:
+ *  0/1 - (off/on) on success
+ * -1 - on failure (device not support TAP or it's a slave device)
+ **/
+int get_tap_change_sd(int if_index);
+
+/**
+ * set_dis_tap - Set Disable TAP mode
+ * @if_index: network device index of the controlling device
+ * @dis_tap: disable tap(1=dis, 0=en)
+ * Output:
+ *  0 - on success
+ * -1 - on failure (device is not capable of the operation or device not support
+ *                  TAP or it's a slave device)
+ **/
+int set_dis_tap_sd(int if_index, int dis_tap);
+
+/**
+ * get_dis_tap - Get Disable TAP mode state
+ * @if_index: network device index of the controlling device
+ * Output:
+ *  0/1 - on success (normal TAP mode/ Disable TAP)
+ * -1 - on failure (device is not capable of the operation or device not support
+ *                  TAP or it's a slave device)
+ **/
+int get_dis_tap_sd(int if_index);
+
+/**
+ * set_tap_pwup - Set TAP mode at power-up state
+ * @if_index: network device index of the controlling device
+ * @bypass_mode: tap mode setting at power up state (1=TAP en, 0=TAP Dis)
+ * Output:
+ *  0 - on success
+ * -1 - on failure (device is not capable of the operation or device not
+ *                  support TAP or it's a slave device)
+ **/
+int set_tap_pwup_sd(int if_index, int tap_mode);
+
+/**
+ * get_tap_pwup - Get TAP mode state at power-up state
+ * @if_index: network device index of the controlling device
+ * Output:
+ *  0/1 - on success (Disable TAP at power up state / normal TAP mode)
+ * -1 - on failure (device is not capable of the operation or device not
+ *                  support TAP or it's a slave device)
+ **/
+int get_tap_pwup_sd(int if_index);
+
+/**
+ * set_bp_disc - set Disconnect state
+ * @if_index: network device index of the controlling device
+ * @tap_mode: 1 disc mode , 0 non-disc mode
+
+
+
+
+
+
+
+
+
+
+
+
+
+
+
+
+
+
+
+
+
+
+
+
+
+
+
+
+
+
+
+
+
+
+
+
+
+
+
+
+
+ * Output:
+ *  0 - on success
+ * -1 - on failure (device not support disconnect or it's a slave device)
+ **/
+int set_bp_disc_sd(int if_index, int disc_mode);
+
+/**
+ * get_bp_disc - Get Disconnect mode state
+ * @if_index: network device index of the controlling device
+ * Output:
+ *  0/1 - (off/on) on success
+ * -1 - on failure (device not support disconnect or it's a slave device)
+ **/
+int get_bp_disc_sd(int if_index);
+
+/**
+ * get_bp_disc_change - Get change of Disconnect mode state from last status check
+ * @if_index: network device index of the controlling device
+ * Output:
+ *  0/1 - (off/on) on success
+ * -1 - on failure (device not support disconnect or it's a slave device)
+ **/
+int get_bp_disc_change_sd(int if_index);
+
+/**
+ * set_bp_dis_disc - Set Disable Disconnect mode
+ * @if_index: network device index of the controlling device
+ * @dis_tap: disable tap(1=dis, 0=en)
+ * Output:
+ *  0 - on success
+ * -1 - on failure (device is not capable ofthe operation or device not
+ *                  support Disconnect or it's a slave device)
+ **/
+int set_bp_dis_disc_sd(int if_index, int dis_disc);
+
+/**
+ * get_bp_dis_disc - Get Disable Disconnect mode state
+ * @if_index: network device index of the controlling device
+ * Output:
+ *  0/1 - on success (normal Disconnect mode/ Disable Disconnect)
+ * -1 - on failure (device is not capable of the operation or device not
+ *                  support Disconnect or it's a slave device)
+ **/
+int get_bp_dis_disc_sd(int if_index);
+
+/**
+ * set_bp_disc_pwup - Set Disconnect mode at power-up state
+ * @if_index: network device index of the controlling device
+ * @disc_mode: DISC mode setting at power up state (1= en, 0= Dis)
+ * Output:
+ *  0 - on success
+ * -1 - on failure (device is not capable of the operation or device not
+ *                  support Disconnect or it's a slave device)
+ **/
+int set_bp_disc_pwup_sd(int if_index, int disc_mode);
+
+/**
+ * get_bp_disc_pwup - Get Disconnect mode state at power-up state
+ * @if_index: network device index of the controlling device
+ * Output:
+ *  0/1 - on success (Disable Disconnect at power up state / normal Disconnect
+ *                    mode)
+ * -1 - on failure (device is not capable of the operation or device not
+ *                  support TAP or it's a slave device)
+ **/
+int get_bp_disc_pwup_sd(int if_index);
+
+/**
+ * set_wd_exp_mode - Set adapter state when WDT expired.
+ * @if_index: network device index of the controlling device
+ * @bypass_mode:  adapter mode (1=tap mode, 0=bypass mode)
+ * Output:
+ *  0 - on success
+ * -1 - on failure (device not support Bypass or it's a slave device)
+ **/
+int set_wd_exp_mode_sd(int if_index, int bypass_mode);
+
+/**
+ * get_wd_exp_mode - Get adapter state when WDT expired.
+ * @if_index: network device index of the controlling device
+ * Output:
+ *  0/1 - (bypass/tap) on success
+ * -1 - on failure (device not support Bypass or it's a slave device)
+ **/
+int get_wd_exp_mode_sd(int if_index);
+
+/**
+ * set_wd_autoreset - reset WDT periodically.
+ * @if_index: network device index of the controlling device
+ * @bypass_mode:  adapter mode (1=tap mode, 0=bypass mode)
+ * Output:
+ * 1  - on success
+ * -1 - on failure (device is not capable of the operation or device not
+ *                  support Bypass or it's a slave device or unknown wdt
+ *                  status)
+ **/
+int set_wd_autoreset_sd(int if_index, int time);
+
+/**
+ * set_wd_autoreset - reset WDT periodically.
+ * @if_index: network device index of the controlling device
+ * @bypass_mode:  adapter mode (1=tap mode, 0=bypass mode)
+ * Output:
+ * 1  - on success
+ * -1 - on failure (device is not capable of the operation or device not
+ *                  support Bypass or it's a slave device or unknown wdt
+ *                  status)
+ **/
+int get_wd_autoreset_sd(int if_index);
+
+/**
+ * set_tpl - set TPL state
+ * @if_index: network device index of the controlling device
+ * @tpl_mode: 1 tpl mode , 0 normal nic mode
+ * Output:
+ *  0 - on success
+ * -1 - on failure (device not support TPL)
+ **/
+int set_tpl_sd(int if_index, int tpl_mode);
+
+/**
+ * get_tpl - Get TPL mode state
+ * @if_index: network device index of the controlling device
+ * Output:
+ *  0/1 - (off/on) on success
+ * -1 - on failure (device not support TPL or it's a slave device)
+ **/
+int get_tpl_sd(int if_index);
+
+int get_bypass_info_sd(int if_index, struct bp_info *bp_info);
+int bp_if_scan_sd(void);
+/*int get_dev_num_sd(void);*/
diff -uprN -X linux-3.17-rc1-vanilla/Documentation/dontdiff linux-3.17-rc1-vanilla/drivers/bypass/silicom/bp_ctl/Makefile linux-3.17-rc1/drivers/bypass/silicom/bp_ctl/Makefile
--- linux-3.17-rc1-vanilla/drivers/bypass/silicom/bp_ctl/Makefile	1970-01-01 02:00:00.000000000 +0200
+++ linux-3.17-rc1/drivers/bypass/silicom/bp_ctl/Makefile	2014-07-22 15:04:53.000000000 +0300
@@ -0,0 +1,5 @@
+#
+# Makefile for the Bypass network device drivers.
+#
+
+obj-$(CONFIG_SBYPASS_CTL) += bpctl_mod.o
diff -uprN -X linux-3.17-rc1-vanilla/Documentation/dontdiff linux-3.17-rc1-vanilla/drivers/bypass/silicom/Kconfig linux-3.17-rc1/drivers/bypass/silicom/Kconfig
--- linux-3.17-rc1-vanilla/drivers/bypass/silicom/Kconfig	1970-01-01 02:00:00.000000000 +0200
+++ linux-3.17-rc1/drivers/bypass/silicom/Kconfig	2014-09-08 23:03:59.000000000 +0300
@@ -0,0 +1,45 @@
+#
+# Silicom device configuration
+#
+
+config NET_VENDOR_SILICOM
+	bool "Silicom devices"
+	default y
+	---help---
+	  If you have a Bypass device belonging to this class,
+	  say Y.
+
+	  Note that the answer to this question does not directly affect
+	  the kernel: saying N will just case the configurator to skip all
+	  the questions regarding Silicom chipsets. If you say Y, you will be asked
+	  for your specific chipset/driver in the following questions.
+
+if NET_VENDOR_SILICOM
+
+config SBYPASS_LIB
+	tristate "Silicom BypassCTL library support"
+	depends on PCI && NETDEVICES
+	---help---
+	  Kernel Level Library for Silicom Bypass Interface cards
+
+	  If you have a network (Ethernet) controller of this type, say Y
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called bypass.
+
+config SBYPASS_CTL
+	tristate "Silicom BypassCTL driver support"
+	depends on PCI && NETDEVICES
+	select MII
+	---help---
+	  Driver for Silicom Bypass Interface cards.
+
+	  If you have a network (Ethernet) controller of this type, say Y
+	  or M and read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called bpctl_mod.
+
+
+endif # NET_VENDOR_SILICOM
diff -uprN -X linux-3.17-rc1-vanilla/Documentation/dontdiff linux-3.17-rc1-vanilla/drivers/bypass/silicom/Makefile linux-3.17-rc1/drivers/bypass/silicom/Makefile
--- linux-3.17-rc1-vanilla/drivers/bypass/silicom/Makefile	1970-01-01 02:00:00.000000000 +0200
+++ linux-3.17-rc1/drivers/bypass/silicom/Makefile	2014-07-22 15:34:08.000000000 +0300
@@ -0,0 +1,5 @@
+#
+# Makefile for the Silicom Bypass device drivers.
+#
+obj-$(CONFIG_SBYPASS_LIB) += bp_lib/
+obj-$(CONFIG_SBYPASS_CTL) += bp_ctl/
diff -uprN -X linux-3.17-rc1-vanilla/Documentation/dontdiff linux-3.17-rc1-vanilla/drivers/bypass/silicom/README linux-3.17-rc1/drivers/bypass/silicom/README
--- linux-3.17-rc1-vanilla/drivers/bypass/silicom/README	1970-01-01 02:00:00.000000000 +0200
+++ linux-3.17-rc1/drivers/bypass/silicom/README	2014-08-03 15:28:47.000000000 +0300
@@ -0,0 +1,14 @@
+
+Theory of Operation:
+
+The Silicom Bypass Network Interface Cards (NICs) are network cards with paired ports (2 or 4)
+The pairs either act as a "wire" allowing the network packets to pass or insert the device in
+between the two ports.  When paired with the on-board hardware watchdog or other failsafe,
+they provide high availability for the network in the face of software outages or maintenance
+
+The software requirements are for a kernel level driver that interfaces with the bypass and watchdog,
+as well as for control software. User control can be either the provided standalone executable
+(/bin/bpctl) or the API exposed by the Silicom library
+
+
+
diff -uprN -X linux-3.17-rc1-vanilla/Documentation/dontdiff linux-3.17-rc1-vanilla/drivers/Kconfig linux-3.17-rc1/drivers/Kconfig
--- linux-3.17-rc1-vanilla/drivers/Kconfig	2014-08-16 19:40:26.000000000 +0300
+++ linux-3.17-rc1/drivers/Kconfig	2014-09-09 00:43:05.000000000 +0300
@@ -180,4 +180,6 @@ source "drivers/ras/Kconfig"
 
 source "drivers/thunderbolt/Kconfig"
 
+source "drivers/bypass/Kconfig"
+
 endmenu
diff -uprN -X linux-3.17-rc1-vanilla/Documentation/dontdiff linux-3.17-rc1-vanilla/drivers/Makefile linux-3.17-rc1/drivers/Makefile
--- linux-3.17-rc1-vanilla/drivers/Makefile	2014-08-16 19:40:26.000000000 +0300
+++ linux-3.17-rc1/drivers/Makefile	2014-09-09 00:45:13.000000000 +0300
@@ -161,3 +161,4 @@ obj-$(CONFIG_POWERCAP)		+= powercap/
 obj-$(CONFIG_MCB)		+= mcb/
 obj-$(CONFIG_RAS)		+= ras/
 obj-$(CONFIG_THUNDERBOLT)	+= thunderbolt/
+obj-$(CONFIG_BYPASS)		+= bypass/
---------------------------------------------------------------------------------------------------

David Hendel.
