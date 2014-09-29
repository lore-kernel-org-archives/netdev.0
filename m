From: David Hendel <david@silicom.co.il>
Subject: RE: Silicom bypass driver promote from staging
Date: Mon, 29 Sep 2014 07:22:31 +0000
Message-ID: <3BFAEADE799AF145974162DF00E013AF018F8C8AE3@exchange2010.silicom.local>
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
Received: from 105.74.80-QoS-user.in-addr.arpa ([80.74.105.217]:64360 "EHLO
	exchange2010.silicom.local" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751083AbaI2HWj convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Sep 2014 03:22:39 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is for the second part, with the code for bp_lib

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

Bp_lib patch,
-------------------------------------------------------------------------------------
Signed-off-by: Anna Lukin <annal@silicom.co.il>
diff -uprN -X linux-3.17-rc5-vanilla/Documentation/dontdiff linux-3.17-rc5-vanilla/drivers/bypass/silicom/bp_lib/bp_ioctl.h linux-3.17-rc5/drivers/bypass/silicom/bp_lib/bp_ioctl.h
--- linux-3.17-rc5-vanilla/drivers/bypass/silicom/bp_lib/bp_ioctl.h	1970-01-01 02:00:00.000000000 +0200
+++ linux-3.17-rc5/drivers/bypass/silicom/bp_lib/bp_ioctl.h	2014-09-21 13:53:27.073734859 +0300
@@ -0,0 +1,198 @@
+/******************************************************************************/
+/*                                                                            */
+/* bypass library, Copyright (c) 2004-2006 Silicom, Ltd                       */
+/* Corporation.                                                               */
+/*                                                                            */
+/* This program is free software; you can redistribute it and/or modify       */
+/* it under the terms of the GNU General Public License as published by       */
+/* the Free Software Foundation, located in the file LICENSE.                 */
+/*                                                                            */
+/*                                                                            */
+/*                                                                            */
+/******************************************************************************/
+
+#ifndef BP_IOCTL_H
+#define BP_IOCTL_H
+
+#define BP_CAP                   0x01	/* BIT_0 */
+#define BP_STATUS_CAP            0x02	/* BIT_1 */
+#define BP_STATUS_CHANGE_CAP     0x04	/* BIT_2 */
+#define SW_CTL_CAP               0x08	/* BIT_3 */
+#define BP_DIS_CAP               0x10	/* BIT_4 */
+#define BP_DIS_STATUS_CAP        0x20	/* BIT_5 */
+#define STD_NIC_CAP              0x40	/* BIT_6 */
+#define BP_PWOFF_ON_CAP          0x80	/* BIT_7 */
+#define BP_PWOFF_OFF_CAP         0x0100	/* BIT_8 */
+#define BP_PWOFF_CTL_CAP         0x0200	/* BIT_9 */
+#define BP_PWUP_ON_CAP           0x0400	/* BIT_10 */
+#define BP_PWUP_OFF_CAP          0x0800	/* BIT_11 */
+#define BP_PWUP_CTL_CAP          0x1000	/* BIT_12 */
+#define WD_CTL_CAP               0x2000	/* BIT_13 */
+#define WD_STATUS_CAP            0x4000	/* BIT_14 */
+#define WD_TIMEOUT_CAP           0x8000	/* BIT_15 */
+#define TX_CTL_CAP               0x10000	/* BIT_16 */
+#define TX_STATUS_CAP            0x20000	/* BIT_17 */
+#define TAP_CAP                  0x40000	/* BIT_18 */
+#define TAP_STATUS_CAP           0x80000	/* BIT_19 */
+#define TAP_STATUS_CHANGE_CAP    0x100000	/* BIT_20 */
+#define TAP_DIS_CAP              0x200000	/* BIT_21 */
+#define TAP_DIS_STATUS_CAP       0x400000	/* BIT_22 */
+#define TAP_PWUP_ON_CAP          0x800000	/* BIT_23 */
+#define TAP_PWUP_OFF_CAP         0x1000000	/* BIT 24 */
+#define TAP_PWUP_CTL_CAP         0x2000000	/* BIT 25 */
+#define NIC_CAP_NEG              0x4000000	/* BIT 26 */
+#define TPL_CAP                  0x8000000	/* BIT 27 */
+#define DISC_CAP                 0x10000000	/* BIT 28 */
+#define DISC_DIS_CAP             0x20000000	/* BIT 29 */
+#define DISC_PWUP_CTL_CAP        0x40000000	/* BIT 30 */
+
+#define WD_MIN_TIME_MASK(val)      (val & 0xf)
+#define WD_STEP_COUNT_MASK(val)    ((val & 0xf) << 5)
+#define WDT_STEP_TIME              0x10	/* BIT_4 */
+
+#define WD_MIN_TIME_GET(desc)   (desc & 0xf)
+#define WD_STEP_COUNT_GET(desc) ((desc>>5) & 0xf)
+
+enum {
+	IS_BYPASS = 1,
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
+
+	GET_BYPASS_INFO = 100,
+	GET_BP_WAIT_AT_PWUP,
+	SET_BP_WAIT_AT_PWUP,
+	GET_BP_HW_RESET,
+	SET_BP_HW_RESET,
+};
+
+enum {
+	IF_SCAN_SD,
+	GET_DEV_NUM_SD,
+	IS_BYPASS_SD,
+	GET_BYPASS_SLAVE_SD,
+	GET_BYPASS_CAPS_SD,
+	GET_WD_SET_CAPS_SD,
+	SET_BYPASS_SD,
+	GET_BYPASS_SD,
+	GET_BYPASS_CHANGE_SD,
+	SET_BYPASS_WD_SD,
+	GET_BYPASS_WD_SD,
+	GET_WD_EXPIRE_TIME_SD,
+	RESET_BYPASS_WD_TIMER_SD,
+	SET_DIS_BYPASS_SD,
+	GET_DIS_BYPASS_SD,
+	SET_BYPASS_PWOFF_SD,
+	GET_BYPASS_PWOFF_SD,
+	SET_BYPASS_PWUP_SD,
+	GET_BYPASS_PWUP_SD,
+	SET_STD_NIC_SD,
+	GET_STD_NIC_SD,
+	SET_TX_SD,
+	GET_TX_SD,
+	SET_TAP_SD,
+	GET_TAP_SD,
+	GET_TAP_CHANGE_SD,
+	SET_DIS_TAP_SD,
+	GET_DIS_TAP_SD,
+	SET_TAP_PWUP_SD,
+	GET_TAP_PWUP_SD,
+	SET_WD_EXP_MODE_SD,
+	GET_WD_EXP_MODE_SD,
+	SET_WD_AUTORESET_SD,
+	GET_WD_AUTORESET_SD,
+	SET_TPL_SD,
+	GET_TPL_SD,
+	SET_DISC_SD,
+	GET_DISC_SD,
+	GET_DISC_CHANGE_SD,
+	SET_DIS_DISC_SD,
+	GET_DIS_DISC_SD,
+	SET_DISC_PWUP_SD,
+	GET_DISC_PWUP_SD,
+
+	GET_BYPASS_INFO_SD = 100,
+	GET_BP_WAIT_AT_PWUP_SD,
+	SET_BP_WAIT_AT_PWUP_SD,
+	GET_BP_HW_RESET_SD,
+	SET_BP_HW_RESET_SD,
+
+};
+
+#define SIOCGIFBYPASS (SIOCDEVPRIVATE+10)
+
+struct bp_info {
+	char prod_name[14];
+	unsigned char fw_ver;
+};
+
+/* for passing single values */
+struct if_bypass {
+	char if_name[IFNAMSIZ];
+	int cmd;
+	int data;
+};
+struct if_bypass_info {
+	char if_name[IFNAMSIZ];
+	char cmd;
+	struct bp_info bp_info;
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
diff -uprN -X linux-3.17-rc5-vanilla/Documentation/dontdiff linux-3.17-rc5-vanilla/drivers/bypass/silicom/bp_lib/bplibk.h linux-3.17-rc5/drivers/bypass/silicom/bp_lib/bplibk.h
--- linux-3.17-rc5-vanilla/drivers/bypass/silicom/bp_lib/bplibk.h	1970-01-01 02:00:00.000000000 +0200
+++ linux-3.17-rc5/drivers/bypass/silicom/bp_lib/bplibk.h	2014-09-21 13:53:27.073734859 +0300
@@ -0,0 +1,34 @@
+/******************************************************************************/
+/*                                                                            */
+/* bypass library, Copyright (c) 2004 Silicom, Ltd                            */
+/*                                                                            */
+/* This program is free software; you can redistribute it and/or modify       */
+/* it under the terms of the GNU General Public License as published by       */
+/* the Free Software Foundation, located in the file LICENSE.                 */
+/*                                                                            */
+/*                                                                            */
+/* bplib.h                                                                    */
+/*                                                                            */
+/******************************************************************************/
+#ifndef BYPASS_H
+#define BYPASS_H
+
+#include "bp_ioctl.h"
+#include "libbp_sd.h"
+
+#define IF_NAME            "eth"
+#define SILICOM_VID        0x1374
+#define SILICOM_BP_PID_MIN 0x24
+#define SILICOM_BP_PID_MAX 0x5f
+#define INTEL_PEG4BPII_PID  0x10a0
+#define INTEL_PEG4BPFII_PID 0x10a1
+
+#define PEGII_IF_SERIES(vid, pid) \
+	((vid == 0x8086) && \
+	 ((pid == INTEL_PEG4BPII_PID) ||   \
+	  (pid == INTEL_PEG4BPFII_PID)))
+
+char *bp_desc_array[] = { "e1000bp", "e1000bpe", "slcm5700",
+			"bnx2xbp", "ixgbp", "ixgbpe", NULL };
+
+#endif
diff -uprN -X linux-3.17-rc5-vanilla/Documentation/dontdiff linux-3.17-rc5-vanilla/drivers/bypass/silicom/bp_lib/bypass.c linux-3.17-rc5/drivers/bypass/silicom/bp_lib/bypass.c
--- linux-3.17-rc5-vanilla/drivers/bypass/silicom/bp_lib/bypass.c	1970-01-01 02:00:00.000000000 +0200
+++ linux-3.17-rc5/drivers/bypass/silicom/bp_lib/bypass.c	2014-09-21 13:53:27.077734859 +0300
@@ -0,0 +1,530 @@
+/******************************************************************************/
+/*                                                                            */
+/* bypass library, Copyright (c) 2004-2007 Silicom, Ltd                       */
+/*                                                                            */
+/* This program is free software; you can redistribute it and/or modify       */
+/* it under the terms of the GNU General Public License as published by       */
+/* the Free Software Foundation, located in the file LICENSE.                 */
+/*                                                                            */
+/*                                                                            */
+/* bypass.c                                                                   */
+/*                                                                            */
+/******************************************************************************/
+
+#if defined(CONFIG_SMP) && !defined(__SMP__)
+#define __SMP__
+#endif
+
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <asm/unistd.h>
+
+#include <linux/sched.h>
+#include <linux/wait.h>
+
+#include <linux/netdevice.h>	/* struct device, and other headers */
+#include <linux/kernel_stat.h>
+#include <linux/pci.h>
+#include <linux/rtnetlink.h>
+#include <linux/ethtool.h>
+
+#include <net/net_namespace.h>
+
+#include "bplibk.h"
+
+#define MOD_NAME "Bypass Control library"
+
+#define VERSION ""MOD_NAME" ver 9.0.4\n"
+
+MODULE_AUTHOR("www.silicom.co.il");
+
+MODULE_LICENSE("GPL");
+
+static int do_cmd(struct net_device *dev, struct ifreq *ifr, int cmd, int *data)
+{
+	int ret = -1;
+	struct if_bypass *bypass_cb;
+
+	bypass_cb = (struct if_bypass *)ifr;
+	bypass_cb->cmd = cmd;
+	bypass_cb->data = *data;
+
+	if (dev->netdev_ops && dev->netdev_ops->ndo_do_ioctl) {
+		ret = dev->netdev_ops->ndo_do_ioctl(dev, ifr, SIOCGIFBYPASS);
+		*data = bypass_cb->data;
+	}
+
+	return ret;
+}
+
+static int doit(int cmd, int if_index, int *data)
+{
+	struct ifreq ifr;
+	int ret = -1;
+	struct net_device *dev;
+	struct net_device *n;
+
+	for_each_netdev_safe(&init_net, dev, n) {
+		if (dev->ifindex == if_index) {
+			ret = do_cmd(dev, &ifr, cmd, data);
+			if (ret < 0)
+				ret = -1;
+		}
+	}
+
+	return ret;
+}
+
+#define bp_symbol_get(fn_name) symbol_get(fn_name)
+#define bp_symbol_put(fn_name) symbol_put(fn_name)
+
+#define SET_BPLIB_INT_FN(fn_name, arg_type, arg, ret)	\
+({	int (*fn_ex)(arg_type) = NULL;			\
+	fn_ex = bp_symbol_get(fn_name##_sd);		\
+	if (fn_ex) {					\
+		ret = fn_ex(arg);			\
+		bp_symbol_put(fn_name##_sd);		\
+	} else {					\
+		ret = -1;				\
+	}						\
+})
+
+#define  SET_BPLIB_INT_FN2(fn_name, arg_type, arg, arg_type1, arg1, ret)\
+({	int (*fn_ex)(arg_type, arg_type1) = NULL;			\
+	fn_ex = bp_symbol_get(fn_name##_sd);				\
+	if (fn_ex) {							\
+		ret = fn_ex(arg, arg1);					\
+		bp_symbol_put(fn_name##_sd);				\
+	} else {							\
+		ret = -1;						\
+	}								\
+})
+
+#define SET_BPLIB_INT_FN3(fn_name, arg_type, arg, arg_type1, arg1,	\
+			  arg_type2, arg2, ret)				\
+({	int (*fn_ex)(arg_type, arg_type1, arg_type2) = NULL;		\
+	fn_ex = bp_symbol_get(fn_name##_sd);				\
+	if (fn_ex) {							\
+		ret = fn_ex(arg, arg1, arg2);				\
+		bp_symbol_put(fn_name##_sd);				\
+	} else {							\
+		ret = -1;						\
+	}								\
+})
+
+#define DO_BPLIB_GET_ARG_FN(fn_name, ioctl_val, if_index)	\
+({	int data, ret = 0;					\
+	if (is_dev_sd(if_index)) {				\
+		SET_BPLIB_INT_FN(fn_name, int, if_index, ret);	\
+		return ret;					\
+	}							\
+	return doit(ioctl_val, if_index, &data);		\
+})
+
+#define DO_BPLIB_SET_ARG_FN(fn_name, ioctl_val, if_index, arg)	\
+({	int data, ret = 0;					\
+	if (is_dev_sd(if_index)) {				\
+		SET_BPLIB_INT_FN2(fn_name, int, if_index, int,	\
+				  arg, ret);			\
+		return ret;					\
+	}							\
+	data = arg;						\
+	return doit(ioctl_val, if_index, &data);		\
+})
+
+static int is_dev_sd(int if_index)
+{
+	int ret = 0;
+
+	SET_BPLIB_INT_FN(is_bypass, int, if_index, ret);
+	return ret >= 0 ? 1 : 0;
+}
+
+static int is_bypass_dev(int if_index)
+{
+	struct pci_dev *pdev = NULL;
+	struct net_device *dev = NULL;
+	struct ifreq ifr;
+	int ret = 0;
+	int data = 0;
+
+	while ((pdev = pci_get_class(PCI_CLASS_NETWORK_ETHERNET << 8, pdev))) {
+		dev = pci_get_drvdata(pdev);
+		if ((dev != NULL) && (dev->ifindex == if_index)) {
+			if ((pdev->vendor == SILICOM_VID) &&
+			    (pdev->device >= SILICOM_BP_PID_MIN) &&
+			    (pdev->device <= SILICOM_BP_PID_MAX))
+				goto send_cmd;
+		} else {
+			struct ethtool_drvinfo info;
+			const struct ethtool_ops *ops =
+					dev->ethtool_ops;
+			int k = 0;
+
+			if (ops->get_drvinfo) {
+				memset(&info, 0, sizeof(info));
+				info.cmd = ETHTOOL_GDRVINFO;
+				ops->get_drvinfo(dev, &info);
+				for (; bp_desc_array[k]; k++)
+					if (!(strcmp(bp_desc_array[k],
+						     info.driver)))
+						goto send_cmd;
+			}
+			return -1;
+		}
+	}
+ send_cmd:
+	ret = do_cmd(dev, &ifr, IS_BYPASS, &data);
+	return ret < 0 ? -1 : ret;
+}
+
+static int is_bypass(int if_index)
+{
+	int ret = 0;
+
+	SET_BPLIB_INT_FN(is_bypass, int, if_index, ret);
+
+	if (ret < 0)
+		return is_bypass_dev(if_index);
+	return ret;
+}
+EXPORT_SYMBOL(is_bypass);
+
+static int get_bypass_slave(int if_index)
+{
+	DO_BPLIB_GET_ARG_FN(get_bypass_slave, GET_BYPASS_SLAVE, if_index);
+}
+EXPORT_SYMBOL(get_bypass_slave);
+
+static int get_bypass_caps(int if_index)
+{
+	DO_BPLIB_GET_ARG_FN(get_bypass_caps, GET_BYPASS_CAPS, if_index);
+}
+EXPORT_SYMBOL(get_bypass_caps);
+
+static int get_wd_set_caps(int if_index)
+{
+	DO_BPLIB_GET_ARG_FN(get_wd_set_caps, GET_WD_SET_CAPS, if_index);
+}
+EXPORT_SYMBOL(get_wd_set_caps);
+
+static int set_bypass(int if_index, int bypass_mode)
+{
+	DO_BPLIB_SET_ARG_FN(set_bypass, SET_BYPASS, if_index, bypass_mode);
+}
+EXPORT_SYMBOL(set_bypass);
+
+static int get_bypass(int if_index)
+{
+	DO_BPLIB_GET_ARG_FN(get_bypass, GET_BYPASS, if_index);
+}
+EXPORT_SYMBOL(get_bypass);
+
+static int get_bypass_change(int if_index)
+{
+	DO_BPLIB_GET_ARG_FN(get_bypass_change, GET_BYPASS_CHANGE, if_index);
+}
+EXPORT_SYMBOL(get_bypass_change);
+
+static int set_dis_bypass(int if_index, int dis_bypass)
+{
+	DO_BPLIB_SET_ARG_FN(set_dis_bypass, SET_DIS_BYPASS, if_index,
+			    dis_bypass);
+}
+EXPORT_SYMBOL(set_dis_bypass);
+
+static int get_dis_bypass(int if_index)
+{
+	DO_BPLIB_GET_ARG_FN(get_dis_bypass, GET_DIS_BYPASS, if_index);
+}
+EXPORT_SYMBOL(get_dis_bypass);
+
+static int set_bypass_pwoff(int if_index, int bypass_mode)
+{
+	DO_BPLIB_SET_ARG_FN(set_bypass_pwoff, SET_BYPASS_PWOFF, if_index,
+			    bypass_mode);
+}
+EXPORT_SYMBOL(set_bypass_pwoff);
+
+static int get_bypass_pwoff(int if_index)
+{
+	DO_BPLIB_GET_ARG_FN(get_bypass_pwoff, GET_BYPASS_PWOFF, if_index);
+}
+EXPORT_SYMBOL(get_bypass_pwoff);
+
+static int set_bypass_pwup(int if_index, int bypass_mode)
+{
+	DO_BPLIB_SET_ARG_FN(set_bypass_pwup, SET_BYPASS_PWUP, if_index,
+			    bypass_mode);
+}
+EXPORT_SYMBOL(set_bypass_pwup);
+
+static int get_bypass_pwup(int if_index)
+{
+	DO_BPLIB_GET_ARG_FN(get_bypass_pwup, GET_BYPASS_PWUP, if_index);
+}
+EXPORT_SYMBOL(get_bypass_pwup);
+
+static int set_bypass_wd(int if_index, int ms_timeout, int *ms_timeout_set)
+{
+	int data = ms_timeout;
+	int ret = 0;
+
+	if (is_dev_sd(if_index)) {
+		SET_BPLIB_INT_FN3(set_bypass_wd, int, if_index, int, ms_timeout,
+				  int *, ms_timeout_set, ret);
+	} else {
+		ret = doit(SET_BYPASS_WD, if_index, &data);
+		if (ret > 0) {
+			*ms_timeout_set = ret;
+			ret = 0;
+		}
+	}
+	return ret;
+}
+EXPORT_SYMBOL(set_bypass_wd);
+
+static int get_bypass_wd(int if_index, int *ms_timeout_set)
+{
+	int *data = ms_timeout_set;
+	int ret = 0;
+
+	if (is_dev_sd(if_index))
+		SET_BPLIB_INT_FN2(get_bypass_wd, int, if_index, int *,
+				  ms_timeout_set, ret);
+	else
+		ret = doit(GET_BYPASS_WD, if_index, data);
+	return ret;
+}
+EXPORT_SYMBOL(get_bypass_wd);
+
+static int get_wd_expire_time(int if_index, int *ms_time_left)
+{
+	int *data = ms_time_left, ret = 0;
+
+	if (is_dev_sd(if_index)) {
+		SET_BPLIB_INT_FN2(get_wd_expire_time, int, if_index, int *,
+				  ms_time_left, ret);
+	} else {
+		ret = doit(GET_WD_EXPIRE_TIME, if_index, data);
+		if ((ret == 0) && (*data != 0))
+			ret = 1;
+	}
+	return ret;
+}
+EXPORT_SYMBOL(get_wd_expire_time);
+
+static int reset_bypass_wd_timer(int if_index)
+{
+	DO_BPLIB_GET_ARG_FN(reset_bypass_wd_timer, RESET_BYPASS_WD_TIMER,
+			    if_index);
+}
+EXPORT_SYMBOL(reset_bypass_wd_timer);
+
+static int set_std_nic(int if_index, int bypass_mode)
+{
+	DO_BPLIB_SET_ARG_FN(set_std_nic, SET_STD_NIC, if_index, bypass_mode);
+}
+EXPORT_SYMBOL(set_std_nic);
+
+static int get_std_nic(int if_index)
+{
+	DO_BPLIB_GET_ARG_FN(get_std_nic, GET_STD_NIC, if_index);
+}
+EXPORT_SYMBOL(get_std_nic);
+
+static int set_tx(int if_index, int tx_state)
+{
+	DO_BPLIB_SET_ARG_FN(set_tx, SET_TX, if_index, tx_state);
+}
+EXPORT_SYMBOL(set_tx);
+
+static int get_tx(int if_index)
+{
+	DO_BPLIB_GET_ARG_FN(get_tx, GET_TX, if_index);
+}
+EXPORT_SYMBOL(get_tx);
+
+static int set_tap(int if_index, int tap_mode)
+{
+	DO_BPLIB_SET_ARG_FN(set_tap, SET_TAP, if_index, tap_mode);
+}
+EXPORT_SYMBOL(set_tap);
+
+static int get_tap(int if_index)
+{
+	DO_BPLIB_GET_ARG_FN(get_tap, GET_TAP, if_index);
+}
+EXPORT_SYMBOL(get_tap);
+
+static int get_tap_change(int if_index)
+{
+	DO_BPLIB_GET_ARG_FN(get_tap_change, GET_TAP_CHANGE, if_index);
+}
+EXPORT_SYMBOL(get_tap_change);
+
+static int set_dis_tap(int if_index, int dis_tap)
+{
+	DO_BPLIB_SET_ARG_FN(set_dis_tap, SET_DIS_TAP, if_index, dis_tap);
+}
+EXPORT_SYMBOL(set_dis_tap);
+
+static int get_dis_tap(int if_index)
+{
+	DO_BPLIB_GET_ARG_FN(get_dis_tap, GET_DIS_TAP, if_index);
+}
+EXPORT_SYMBOL(get_dis_tap);
+
+static int set_tap_pwup(int if_index, int tap_mode)
+{
+	DO_BPLIB_SET_ARG_FN(set_tap_pwup, SET_TAP_PWUP, if_index, tap_mode);
+}
+EXPORT_SYMBOL(set_tap_pwup);
+
+static int get_tap_pwup(int if_index)
+{
+	DO_BPLIB_GET_ARG_FN(get_tap_pwup, GET_TAP_PWUP, if_index);
+}
+EXPORT_SYMBOL(get_tap_pwup);
+
+static int set_bp_disc(int if_index, int disc_mode)
+{
+	DO_BPLIB_SET_ARG_FN(set_bp_disc, SET_DISC, if_index, disc_mode);
+}
+EXPORT_SYMBOL(set_bp_disc);
+
+static int get_bp_disc(int if_index)
+{
+	DO_BPLIB_GET_ARG_FN(get_bp_disc, GET_DISC, if_index);
+}
+EXPORT_SYMBOL(get_bp_disc);
+
+static int get_bp_disc_change(int if_index)
+{
+	DO_BPLIB_GET_ARG_FN(get_bp_disc_change, GET_DISC_CHANGE, if_index);
+}
+EXPORT_SYMBOL(get_bp_disc_change);
+
+static int set_bp_dis_disc(int if_index, int dis_disc)
+{
+	DO_BPLIB_SET_ARG_FN(set_bp_dis_disc, SET_DIS_DISC, if_index, dis_disc);
+}
+EXPORT_SYMBOL(set_bp_dis_disc);
+
+static int get_bp_dis_disc(int if_index)
+{
+	DO_BPLIB_GET_ARG_FN(get_bp_dis_disc, GET_DIS_DISC, if_index);
+}
+EXPORT_SYMBOL(get_bp_dis_disc);
+
+static int set_bp_disc_pwup(int if_index, int disc_mode)
+{
+	DO_BPLIB_SET_ARG_FN(set_bp_disc_pwup, SET_DISC_PWUP, if_index,
+			    disc_mode);
+}
+EXPORT_SYMBOL(set_bp_disc_pwup);
+
+static int get_bp_disc_pwup(int if_index)
+{
+	DO_BPLIB_GET_ARG_FN(get_bp_disc_pwup, GET_DISC_PWUP, if_index);
+}
+EXPORT_SYMBOL(get_bp_disc_pwup);
+
+static int set_wd_exp_mode(int if_index, int mode)
+{
+	DO_BPLIB_SET_ARG_FN(set_wd_exp_mode, SET_WD_EXP_MODE, if_index, mode);
+}
+EXPORT_SYMBOL(set_wd_exp_mode);
+
+static int get_wd_exp_mode(int if_index)
+{
+	DO_BPLIB_GET_ARG_FN(get_wd_exp_mode, GET_WD_EXP_MODE, if_index);
+}
+EXPORT_SYMBOL(get_wd_exp_mode);
+
+static int set_wd_autoreset(int if_index, int time)
+{
+	DO_BPLIB_SET_ARG_FN(set_wd_autoreset, SET_WD_AUTORESET, if_index, time);
+}
+EXPORT_SYMBOL(set_wd_autoreset);
+
+static int get_wd_autoreset(int if_index)
+{
+	DO_BPLIB_GET_ARG_FN(get_wd_autoreset, GET_WD_AUTORESET, if_index);
+}
+EXPORT_SYMBOL(get_wd_autoreset);
+
+static int set_tpl(int if_index, int tpl_mode)
+{
+	DO_BPLIB_SET_ARG_FN(set_tpl, SET_TPL, if_index, tpl_mode);
+}
+EXPORT_SYMBOL(set_tpl);
+
+static int get_tpl(int if_index)
+{
+	DO_BPLIB_GET_ARG_FN(get_tpl, GET_TPL, if_index);
+}
+EXPORT_SYMBOL(get_tpl);
+
+static int set_bp_hw_reset(int if_index, int mode)
+{
+	DO_BPLIB_SET_ARG_FN(set_tpl, SET_BP_HW_RESET, if_index, mode);
+}
+EXPORT_SYMBOL(set_bp_hw_reset);
+
+static int get_bp_hw_reset(int if_index)
+{
+	DO_BPLIB_GET_ARG_FN(get_tpl, GET_BP_HW_RESET, if_index);
+}
+EXPORT_SYMBOL(get_bp_hw_reset);
+
+static int get_bypass_info(int if_index, struct bp_info *bp_info)
+{
+	int ret = 0;
+
+	if (is_dev_sd(if_index)) {
+		SET_BPLIB_INT_FN2(get_bypass_info, int, if_index,
+				  struct bp_info *, bp_info, ret);
+	} else {
+		struct net_device *dev;
+		struct net_device *n;
+
+		for_each_netdev_safe(&init_net, dev, n) {
+			if (dev->ifindex == if_index) {
+				struct if_bypass_info *bypass_cb;
+				struct ifreq ifr;
+
+				memset(&ifr, 0, sizeof(ifr));
+				bypass_cb = (struct if_bypass_info *)&ifr;
+				bypass_cb->cmd = GET_BYPASS_INFO;
+
+				if (dev->netdev_ops &&
+					dev->netdev_ops->ndo_do_ioctl)
+					ret = dev->netdev_ops->ndo_do_ioctl(dev,
+						&ifr, SIOCGIFBYPASS);
+				else
+					ret = -1;
+				if (ret == 0)
+					memcpy(bp_info, &bypass_cb->bp_info,
+					       sizeof(struct bp_info));
+				ret = ret < 0 ? -1 : 0;
+				break;
+			}
+		}
+	}
+	return ret;
+}
+EXPORT_SYMBOL(get_bypass_info);
+
+static int __init init_lib_module(void)
+{
+	pr_info(VERSION);
+	return 0;
+}
+
+static void __exit cleanup_lib_module(void)
+{
+}
+
+module_init(init_lib_module);
+module_exit(cleanup_lib_module);
diff -uprN -X linux-3.17-rc5-vanilla/Documentation/dontdiff linux-3.17-rc5-vanilla/drivers/bypass/silicom/bp_lib/libbp_sd.h linux-3.17-rc5/drivers/bypass/silicom/bp_lib/libbp_sd.h
--- linux-3.17-rc5-vanilla/drivers/bypass/silicom/bp_lib/libbp_sd.h	1970-01-01 02:00:00.000000000 +0200
+++ linux-3.17-rc5/drivers/bypass/silicom/bp_lib/libbp_sd.h	2014-09-21 13:53:27.077734859 +0300
@@ -0,0 +1,532 @@
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
+ *  Bypass device)
+ * Bit	feature			description
+ *
+ * 0	BP_CAP			The interface is Bypass capable in general
+ *
+ * 1	BP_STATUS_CAP		The interface can report of the current Bypass
+ *				mode
+ *
+ * 2	BP_STATUS_CHANGE_CAP	The interface can report on a change to bypass
+ *				mode from the last time the mode was defined
+ *
+ * 3	SW_CTL_CAP		The interface is Software controlled capable for
+ *				bypass/non bypass modes.
+ *
+ * 4	BP_DIS_CAP		The interface is capable of disabling the Bypass
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
+ * -1 - on failure (device is not capable of the operation or device not support
+ *                  Bypass)
+ **/
+int get_tx_sd(int if_index);
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
+ * Output:
+ *  0 - on success
+ * -1 - on failure (device not support Disconnect or it's a slave device)
+ **/
+int set_bp_disc_sd(int if_index, int disc_mode);
+
+/**
+ * get_bp_disc - Get Disconnect mode state
+ * @if_index: network device index of the controlling device
+ * Output:
+ *  0/1 - (off/on) on success
+ * -1 - on failure (device not support Disconnect or it's a slave device)
+ **/
+int get_bp_disc_sd(int if_index);
+
+/**
+ * get_bp_disc_change - Get change of Disconnect mode state from last status check
+ * @if_index: network device index of the controlling device
+ * Output:
+ *  0/1 - (off/on) on success
+ * -1 - on failure (device not support Disconnect or it's a slave device)
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
diff -uprN -X linux-3.17-rc5-vanilla/Documentation/dontdiff linux-3.17-rc5-vanilla/drivers/bypass/silicom/bp_lib/Makefile linux-3.17-rc5/drivers/bypass/silicom/bp_lib/Makefile
--- linux-3.17-rc5-vanilla/drivers/bypass/silicom/bp_lib/Makefile	1970-01-01 02:00:00.000000000 +0200
+++ linux-3.17-rc5/drivers/bypass/silicom/bp_lib/Makefile	2014-09-21 13:53:27.077734859 +0300
@@ -0,0 +1,6 @@
+#
+# Makefile for the Bypass network device drivers.
+#
+
+obj-$(CONFIG_SBYPASS_LIB) += bypass.o
+
diff -uprN -X linux-3.17-rc5-vanilla/Documentation/dontdiff linux-3.17-rc5-vanilla/include/bypass/silicom/libbypass.h linux-3.17-rc5/include/bypass/silicom/libbypass.h
--- linux-3.17-rc5-vanilla/include/bypass/silicom/libbypass.h	1970-01-01 02:00:00.000000000 +0200
+++ linux-3.17-rc5/include/bypass/silicom/libbypass.h	2014-09-22 09:13:15.600022866 +0300
@@ -0,0 +1,536 @@
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
+/**
+ * is_bypass - check if device is a Bypass controlling device
+ * @if_index: network device index
+ *
+ * Output:
+ *  1 -  if device is bypass controlling device,
+ *  0 -  if device is bypass slave device
+ * -1 -  device not support Bypass
+ **/
+int is_bypass(int if_index);
+
+/**
+ * get_bypass_slave - get second port participate in the Bypass pair
+ * @if_index: network device index
+ *
+ * Output:
+ *  network device index of the slave device
+ * -1 - on failure (device not support Bypass or it's a slave device)
+ **/
+int get_bypass_slave(int if_index);
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
+ *  Bypass device)
+ * Bit	feature			description
+ *
+ * 0	BP_CAP			The interface is Bypass capable in general
+ *
+ * 1	BP_STATUS_CAP		The interface can report of the current Bypass
+ *				mode
+ *
+ * 2	BP_STATUS_CHANGE_CAP	The interface can report on a change to bypass
+ *				mode from the last time the mode was defined
+ *
+ * 3	SW_CTL_CAP		The interface is Software controlled capable for
+ *				bypass/non bypass modes.
+ *
+ * 4	BP_DIS_CAP		The interface is capable of disabling the Bypass
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
+int get_bypass_caps(int if_index);
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
+int get_wd_set_caps(int if_index);
+
+/**
+ * set_bypass - set Bypass state
+ * @if_index: network device index of the controlling device
+ * @bypass_mode:  bypass mode (1=on, 0=off)
+ * Output:
+ *  0 - on success
+ * -1 - on failure (device not support Bypass or it's a slave device)
+ **/
+int set_bypass(int if_index, int bypass_mode);
+
+/**
+ * get_bypass - Get Bypass mode state
+ * @if_index: network device index of the controlling device
+ * Output:
+ *  0/1 - (off/on) on success
+ * -1 - on failure (device not support Bypass or it's a slave device)
+ **/
+int get_bypass(int if_index);
+
+/**
+ * get_bypass_change - Get change of Bypass mode state from last status check
+ * @if_index: network device index of the controlling device
+ * Output:
+ *  0/1 - (off/on) on success
+ * -1 - on failure (device not support Bypass or it's a slave device)
+ **/
+int get_bypass_change(int if_index);
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
+int set_dis_bypass(int if_index, int dis_bypass);
+
+/**
+ * get_dis_bypass - Get Disable Bypass mode state
+ * @if_index: network device index of the controlling device
+ * Output:
+ *  0/1 - on success (normal Bypass mode/ Disable bypass)
+ * -1 - on failure (device is not capable of the operation or device not support
+ *                  Bypass or it's a slave device)
+ **/
+int get_dis_bypass(int if_index);
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
+int set_bypass_pwoff(int if_index, int bypass_mode);
+
+/**
+ * get_bypass_pwoff - Get Bypass mode state at power-off state
+ * @if_index: network device index of the controlling device
+ * Output:
+ *  0/1 - on success (Disable bypass at power off state / normal Bypass mode)
+ * -1 - on failure (device is not capable of the operation or device not support
+ *                  Bypass or it's a slave device)
+ **/
+int get_bypass_pwoff(int if_index);
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
+int set_bypass_pwup(int if_index, int bypass_mode);
+
+/**
+ * get_bypass_pwup - Get Bypass mode state at power-up state
+ * @if_index: network device index of the controlling device
+ * Output:
+ *  0/1 - on success (Disable bypass at power up state / normal Bypass mode)
+ * -1 - on failure (device is not capable of the operation or device not support
+ *                  Bypass or it's a slave device)
+ **/
+int get_bypass_pwup(int if_index);
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
+int set_bypass_wd(int if_index, int ms_timeout, int *ms_timeout_set);
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
+int get_bypass_wd(int if_index, int *ms_timeout_set);
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
+int get_wd_expire_time(int if_index, int *ms_time_left);
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
+int reset_bypass_wd_timer(int if_index);
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
+int set_std_nic(int if_index, int nic_mode);
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
+int get_std_nic(int if_index);
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
+int set_tx(int if_index, int tx_state);
+
+/**
+ * get_tx - get transmitter state (disable / enable)
+ * @if_index: network device index of the controlling device
+ *
+ * Output:
+ * 0/1 (ransmit Disable / Transmit Enable) on success
+ * -1 - on failure (device is not capable of the operation or device not support
+ *                  Bypass)
+ **/
+int get_tx(int if_index);
+
+/**
+ * set_tap - set TAP state
+ * @if_index: network device index of the controlling device
+ * @tap_mode: 1 tap mode , 0 normal nic mode
+ * Output:
+ *  0 - on success
+ * -1 - on failure (device not support TAP or it's a slave device)
+ **/
+int set_tap(int if_index, int tap_mode);
+
+/**
+ * get_tap - Get TAP mode state
+ * @if_index: network device index of the controlling device
+ * Output:
+ *  0/1 - (off/on) on success
+ * -1 - on failure (device not support TAP or it's a slave device)
+ **/
+int get_tap(int if_index);
+
+/**
+ * get_tap_change - Get change of TAP mode state from last status check
+ * @if_index: network device index of the controlling device
+ * Output:
+ *  0/1 - (off/on) on success
+ * -1 - on failure (device not support TAP or it's a slave device)
+ **/
+int get_tap_change(int if_index);
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
+int set_dis_tap(int if_index, int dis_tap);
+
+/**
+ * get_dis_tap - Get Disable TAP mode state
+ * @if_index: network device index of the controlling device
+ * Output:
+ *  0/1 - on success (normal TAP mode/ Disable TAP)
+ * -1 - on failure (device is not capable of the operation or device not support
+ *                  TAP or it's a slave device)
+ **/
+int get_dis_tap(int if_index);
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
+int set_tap_pwup(int if_index, int tap_mode);
+
+/**
+ * get_tap_pwup - Get TAP mode state at power-up state
+ * @if_index: network device index of the controlling device
+ * Output:
+ *  0/1 - on success (Disable TAP at power up state / normal TAP mode)
+ * -1 - on failure (device is not capable of the operation or device not
+ *                  support TAP or it's a slave device)
+ **/
+int get_tap_pwup(int if_index);
+
+/**
+ * set_bp_disc - set Disconnect state
+ * @if_index: network device index of the controlling device
+ * @tap_mode: 1 disc mode , 0 non-disc mode
+ * Output:
+ *  0 - on success
+ * -1 - on failure (device not support Disconnect or it's a slave device)
+ **/
+int set_bp_disc(int if_index, int disc_mode);
+
+/**
+ * get_bp_disc - Get Disconnect mode state
+ * @if_index: network device index of the controlling device
+ * Output:
+ *  0/1 - (off/on) on success
+ * -1 - on failure (device not support Disconnect or it's a slave device)
+ **/
+int get_bp_disc(int if_index);
+
+/**
+ * get_bp_disc_change - Get change of Disconnect mode state from last status check
+ * @if_index: network device index of the controlling device
+ * Output:
+ *  0/1 - (off/on) on success
+ * -1 - on failure (device not support Disconnect or it's a slave device)
+ **/
+int get_bp_disc_change(int if_index);
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
+int set_bp_dis_disc(int if_index, int dis_disc);
+
+/**
+ * get_bp_dis_disc - Get Disable Disconnect mode state
+ * @if_index: network device index of the controlling device
+ * Output:
+ *  0/1 - on success (normal Disconnect mode/ Disable Disconnect)
+ * -1 - on failure (device is not capable of the operation or device not
+ *                  support Disconnect or it's a slave device)
+ **/
+int get_bp_dis_disc(int if_index);
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
+int set_bp_disc_pwup(int if_index, int disc_mode);
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
+int get_bp_disc_pwup(int if_index);
+
+/**
+ * set_wd_exp_mode - Set adapter state when WDT expired.
+ * @if_index: network device index of the controlling device
+ * @bypass_mode:  adapter mode (1=tap mode, 0=bypass mode)
+ * Output:
+ *  0 - on success
+ * -1 - on failure (device not support Bypass or it's a slave device)
+ **/
+int set_wd_exp_mode(int if_index, int bypass_mode);
+
+/**
+ * get_wd_exp_mode - Get adapter state when WDT expired.
+ * @if_index: network device index of the controlling device
+ * Output:
+ *  0/1 - (bypass/tap) on success
+ * -1 - on failure (device not support Bypass or it's a slave device)
+ **/
+int get_wd_exp_mode(int if_index);
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
+int set_wd_autoreset(int if_index, int time);
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
+int get_wd_autoreset(int if_index);
+
+/**
+ * set_tpl - set TPL state
+ * @if_index: network device index of the controlling device
+ * @tpl_mode: 1 tpl mode , 0 normal nic mode
+ * Output:
+ *  0 - on success
+ * -1 - on failure (device not support TPL)
+ **/
+int set_tpl(int if_index, int tpl_mode);
+
+/**
+ * get_tpl - Get TPL mode state
+ * @if_index: network device index of the controlling device
+ * Output:
+ *  0/1 - (off/on) on success
+ * -1 - on failure (device not support TPL or it's a slave device)
+ **/
+int get_tpl(int if_index);
+
+struct bp_info {
+	char prod_name[14];
+	unsigned char fw_ver;
+};
+
+int get_bypass_info(int if_index, struct bp_info *bp_info);
+int bp_if_scan(void);
-----------------------------------------------------------------------------

David Hendel.
