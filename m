From: "Masayuki Ohtake" <masa-korg@dsn.okisemi.com>
Subject: [PATCH] Topcliff PHUB: Add The Packet Hub driver [1/2]
Date: Fri, 23 Apr 2010 22:49:52 +0900
Message-ID: <000501cae2eb$de97e950$66f8800a@maildom.okisemi.com>
Mime-Version: 1.0
Content-Type: message/partial;
	total=2;
	id="01CAE2EB.DDAE2590@tsmail03";
	number=1
Cc: "Wang, Yong Y" <yong.y.wang@intel.com>,
	"Wang, Qi" <qi.wang@intel.com>, "NETDEV" <netdev@vger.kernel.org>,
	<andrew.chih.howe.khor@intel.com>
To: "NETDEV" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sm-d311v.smileserver.ne.jp ([203.211.202.206]:29615 "EHLO
	sm-d311v.smileserver.ne.jp" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757416Ab0DWNuE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Apr 2010 09:50:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Masayuki Ohtake" <masa-korg@dsn.okisemi.com>
To: "NETDEV" <netdev@vger.kernel.org>
Cc: "Wang, Yong Y" <yong.y.wang@intel.com>,
	"Wang, Qi" <qi.wang@intel.com>,
	"NETDEV" <netdev@vger.kernel.org>,
	<andrew.chih.howe.khor@intel.com>
Subject: [PATCH] Topcliff PHUB: Add The Packet Hub driver
Date: Fri, 23 Apr 2010 22:49:52 +0900
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
X-Priority: 3
X-MSMail-Priority: Normal
X-Mailer: Microsoft Outlook Express 6.00.2800.1983
X-MimeOLE: Produced By Microsoft MimeOLE V6.00.2800.1983

From: Masayuki Ohtake <masa-korg@dsn.okisemi.com>

This patch adds the Packet Hub driver for Topcliff.
Patch created against 2.6.33.1

Signed-off-by: Masayuki Ohtake <masa-korg@dsn.okisemi.com>
---
 drivers/char/Kconfig                                 |    7++
 drivers/char/Makefile                                |    2
 drivers/char/pch_phub/Makefile                       |    9
 drivers/char/pch_phub/pch_common.h                   |    147
 drivers/char/pch_phub/pch_debug.h                    |    58
 drivers/char/pch_phub/pch_phub.c                     |    375
 drivers/char/pch_phub/pch_phub.h                     |    195
 drivers/char/pch_phub/pch_phub_hal.c                 |    544
 drivers/char/pch_phub/pch_phub_hal.h                 |    124
 drivers/char/pch_phub/pch_phub_pci.c                 |    499
+++++++++++++++++++++++++++++++ 10 files changed, 1960 insertions(+)
diff -urN linux-2.6.33.1/drivers/char/Kconfig
topcliff-2.6.33.1/drivers/char/Kconfig
--- linux-2.6.33.1/drivers/char/Kconfig 2010-03-16 01:09:39.000000000 +0900
+++ topcliff-2.6.33.1/drivers/char/Kconfig 2010-04-14 18:19:10.000000000
+0900
@@ -4,6 +4,13 @@

 menu "Character devices"

+config PCH_PHUB
+        tristate "PCH PHUB"
+        depends on PCI
+        help
+          If you say yes to this option, support will be included for the
+          PCH Packet Hub Host controller.
+
 config VT
  bool "Virtual terminal" if EMBEDDED
  depends on !S390
diff -urN linux-2.6.33.1/drivers/char/Makefile
topcliff-2.6.33.1/drivers/char/Makefile
--- linux-2.6.33.1/drivers/char/Makefile 2010-03-16 01:09:39.000000000 +0900
+++ topcliff-2.6.33.1/drivers/char/Makefile 2010-04-14 15:12:54.000000000
+0900
@@ -111,6 +111,8 @@
 obj-$(CONFIG_JS_RTC)  += js-rtc.o
 js-rtc-y = rtc.o

+obj-$(CONFIG_PCH_PHUB) += pch_phub/
+
 # Files generated that shall be removed upon make clean
 clean-files := consolemap_deftbl.c defkeymap.c

diff -urN linux-2.6.33.1/drivers/char/pch_phub/Makefile
topcliff-2.6.33.1/drivers/char/pch_phub/Makefile
--- linux-2.6.33.1/drivers/char/pch_phub/Makefile 1970-01-01
09:00:00.000000000 +0900
+++ topcliff-2.6.33.1/drivers/char/pch_phub/Makefile 2010-04-14
18:22:11.000000000 +0900
@@ -0,0 +1,9 @@
+ifeq ($(CONFIG_PHUB_DEBUG),y)
+EXTRA_CFLAGS += -DDEBUG
+endif
+
+obj-$(CONFIG_PCH_PHUB) += pch_phub_drv.o
+#to set CAN clock to 50Mhz
+EXTRA_CFLAGS+=-DIOH_CAN_PCLK_50MHZ
+
+pch_phub_drv-objs := pch_phub.o pch_phub_pci.o pch_phub_hal.o
diff -urN linux-2.6.33.1/drivers/char/pch_phub/pch_common.h
topcliff-2.6.33.1/drivers/char/pch_phub/pch_common.h
--- linux-2.6.33.1/drivers/char/pch_phub/pch_common.h 1970-01-01
09:00:00.000000000 +0900
+++ topcliff-2.6.33.1/drivers/char/pch_phub/pch_common.h 2010-04-14
15:29:48.000000000 +0900
@@ -0,0 +1,147 @@
+/*!
+ * @file pch_common.h
+ * @brief Provides the macro definitions used by all files.
+ * @version 1.0.0.0
+ * @section
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; version 2 of the License.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307,
USA.
+ */
+
+/*
+ * History:
+ * Copyright (C) 2010 OKI SEMICONDUCTOR Co., LTD.
+ *
+ * created:
+ * OKI SEMICONDUCTOR 04/14/2010
+ * modified:
+ *
+ */
+
+#ifndef __PCH_COMMON_H__
+#define __PCH_COMMON_H__
+
+/*! @ingroup Global
+@def      PCH_WRITE8
+@brief   Macro for writing 8 bit data to an io/mem address
+*/
+#define PCH_WRITE8(val, addr)   iowrite8((val), (void __iomem *)(addr))
+/*! @ingroup Global
+@def      PCH_LOG
+@brief   Macro for writing 16 bit data to an io/mem address
+*/
+#define PCH_WRITE16(val, addr)  iowrite16((val), (void __iomem *)(addr))
+/*! @ingroup Global
+@def      PCH_LOG
+@brief   Macro for writing 32 bit data to an io/mem address
+*/
+#define PCH_WRITE32(val, addr)  iowrite32((val), (void __iomem *)(addr))
+
+/*! @ingroup Global
+@def      PCH_READ8
+@brief   Macro for reading 8 bit data from an io/mem address
+*/
+#define PCH_READ8(addr)   ioread8((void __iomem *)(addr))
+/*! @ingroup Global
+@def      PCH_READ16
+@brief   Macro for reading 16 bit data from an io/mem address
+*/
+#define PCH_READ16(addr)  ioread16((void __iomem *)(addr))
+/*! @ingroup Global
+@def      PCH_READ32
+@brief   Macro for reading 32 bit data from an io/mem address
+*/
+#define PCH_READ32(addr)  ioread32((void __iomem *)(addr))
+/*! @ingroup Global
+@def      PCH_WRITE32_F
+@brief   Macro for writing 32 bit data to an io/mem address
+*/
+#define PCH_WRITE32_F(val, addr) \
+ do { \
+  PCH_WRITE32((val), (addr)); \
+  (void)PCH_READ32((addr)); \
+ } while (0);
+
+/*! @ingroup Global
+@def      PCH_WRITE_BYTE
+@brief   Macro for writing 1 byte data to an io/mem address
+*/
+#define PCH_WRITE_BYTE PCH_WRITE8
+/*! @ingroup Global
+@def      PCH_WRITE_WORD
+@brief   Macro for writing 1 word data to an io/mem address
+*/
+#define PCH_WRITE_WORD PCH_WRITE16
+/*! @ingroup Global
+@def      PCH_WRITE_LONG
+@brief   Macro for writing long data to an io/mem address
+*/
+#define PCH_WRITE_LONG PCH_WRITE32
+
+/*! @ingroup Global
+@def      PCH_READ_BYTE
+@brief   Macro for reading 1 byte data from an io/mem address
+*/
+#define PCH_READ_BYTE  PCH_READ8
+/*! @ingroup Global
+@def      PCH_READ_WORD
+@brief   Macro for reading 1 word data from an io/mem address
+*/
+#define PCH_READ_WORD  PCH_READ16
+/*! @ingroup Global
+@def      PCH_READ_LONG
+@brief   Macro for reading long data from an io/mem address
+*/
+#define PCH_READ_LONG  PCH_READ32
+
+/* Bit Manipulation Macros */
+
+/*! @ingroup Global
+@def      PCH_READ_LONG
+@brief   macro to set a specified bit(mask) at the
+   specified address
+*/
+#define PCH_SET_ADDR_BIT(addr, bitmask) PCH_WRITE_LONG((PCH_READ_LONG(addr)
|\
+        (bitmask)), (addr))
+
+/*! @ingroup Global
+@def     PCH_READ_LONG
+@brief  macro to clear a specified bit(mask) at the specified address
+*/
+#define PCH_CLR_ADDR_BIT(addr, bitmask) PCH_WRITE_LONG((PCH_READ_LONG(addr)
&\
+        ~(bitmask)), (addr))
+
+/*! @ingroup Global
+@def      PCH_READ_LONG
+@brief   macro to set a specified bitmask for a variable
+*/
+#define PCH_SET_BITMSK(var, bitmask) ((var) |= (bitmask))
+
+/*! @ingroup Global
+@def      PCH_READ_LONG
+@brief   macro to clear a specified bitmask for a variable
+*/
+#define PCH_CLR_BITMSK(var, bitmask) ((var) &= (~(bitmask)))
+
+/*! @ingroup Global
+@def      PCH_READ_LONG
+@brief   macro to set a specified bit for a variable
+*/
+#define PCH_SET_BIT(var, bit) ((var) |= (1<<(bit)))
+
+/*! @ingroup Global
+@def      PCH_READ_LONG
+@brief   macro to clear a specified bit for a variable
+*/
+#define PCH_CLR_BIT(var, bit) ((var) &= ~(1<<(bit)))
+
+#endif
diff -urN linux-2.6.33.1/drivers/char/pch_phub/pch_debug.h
topcliff-2.6.33.1/drivers/char/pch_phub/pch_debug.h
--- linux-2.6.33.1/drivers/char/pch_phub/pch_debug.h 1970-01-01
09:00:00.000000000 +0900
+++ topcliff-2.6.33.1/drivers/char/pch_phub/pch_debug.h 2010-04-14
15:29:47.000000000 +0900
@@ -0,0 +1,58 @@
+/*!
+ * @file pch_debug.h
+ * @brief Provides the macro definitions used for debugging.
+ * @version 1.0.0.0
+ * @section
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; version 2 of the License.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307,
USA.
+ */
+
+/*
+ * History:
+ * Copyright (C) 2010 OKI SEMICONDUCTOR Co., LTD.
+ *
+ * created:
+ * OKI SEMICONDUCTOR 04/14/2010
+ * modified:
+ *
+ */
+
+#ifndef __PCH_DEBUG_H__
+#define __PCH_DEBUG_H__
+
+#ifdef MODULE
+#define PCH_LOG(level, fmt, args...) printk(level "%s:" fmt "\n",\
+       THIS_MODULE->name, ##args)
+#else
+#define PCH_LOG(level, fmt, args...) printk(level "%s:" fmt "\n" ,\
+        __FILE__, ##args)
+#endif
+
+
+#ifdef DEBUG
+ #define PCH_DEBUG(fmt, args...) PCH_LOG(KERN_DEBUG, fmt, ##args)
+#else
+ #define PCH_DEBUG(fmt, args...)
+#endif
+
+#ifdef PCH_TRACE_ENABLED
+ #define PCH_TRACE PCH_DEBUG
+#else
+ #define PCH_TRACE(fmt, args...)
+#endif
+
+#define PCH_TRACE_ENTER PCH_TRACE("Enter %s", __func__)
+#define PCH_TRACE_EXIT  PCH_TRACE("Exit %s", __func__)
+
+
+#endif
diff -urN linux-2.6.33.1/drivers/char/pch_phub/pch_phub.c
topcliff-2.6.33.1/drivers/char/pch_phub/pch_phub.c
--- linux-2.6.33.1/drivers/char/pch_phub/pch_phub.c 1970-01-01
09:00:00.000000000 +0900
+++ topcliff-2.6.33.1/drivers/char/pch_phub/pch_phub.c 2010-04-14
18:39:08.000000000 +0900
@@ -0,0 +1,375 @@
+/*!
+ * @file pch_phub.c
+ * @brief Provides all the implementation of the interfaces pertaining to
+ *  the Packet Hub module.
+ * @version 1.0.0.0
+ * @section
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; version 2 of the License.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307,
USA.
+ */
+
+/*
+ * History:
+ * Copyright (C) 2010 OKI SEMICONDUCTOR Co., LTD.
+ *
+ * created:
+ * OKI SEMICONDUCTOR 04/14/2010
+ * modified:
+ *
+ */
+
+/* includes */
+
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/types.h>
+#include <linux/fs.h>
+#include <linux/uaccess.h>
+#include <linux/string.h>
+
+#include "pch_common.h"
+#include "pch_debug.h"
+#include "pch_phub.h"
+#include "pch_phub_hal.h"
+
+#define MODULE_NAME "pch_phub"
+
+/* global variables */
+s32 pch_phub_opencount; /* check whether opened or not */
+
+DEFINE_SPINLOCK(pch_phub_lock); /* for spin lock */
+
+/**
+ * file_operations structure initialization
+ */
+const struct file_operations pch_phub_fops = {
+ .owner = THIS_MODULE,
+ .open = pch_phub_open,
+ .release = pch_phub_release,
+ .ioctl = pch_phub_ioctl,
+};
+
+/*function implementations*/
+
+/*! @ingroup PHUB_InterfaceLayerAPI
+  @fn  int pch_phub_open( struct inode *inode,struct file *file)
+  @remarks  Implements the Initializing and opening of the Packet Hub
module.
+  @param  inode  [@ref INOUT] Contains the reference of the inode
+         structure
+  @param  file  [@ref INOUT] Contains the reference of the file structure
+  @retval returnvalue [@ref OUT] contains the result for the concerned
+         attempt.
+  The result would generally comprise of success code
+  or failure code. The failure code will indicate reason for
+  failure.
+  @see
+  EBUSY
+  */
+int pch_phub_open(struct inode *inode, struct file *file)
+{
+ int ret;
+
+ spin_lock(&pch_phub_lock);
+ PCH_DEBUG("pch_phub_open : open count value = %d",
+    pch_phub_opencount);
+ if (pch_phub_opencount) {
+  PCH_LOG(KERN_ERR,
+   "pch_phub_open :  device already opened\n");
+  ret = -EBUSY;
+ } else {
+  pch_phub_opencount++;
+  ret = PCH_PHUB_SUCCESS;
+ }
+ spin_unlock(&pch_phub_lock);
+
+ PCH_DEBUG("pch_phub_open returns=%d\n", ret);
+ return ret;
+}
+
+/*! @ingroup PHUB_InterfaceLayerAPI
+  @fn  int pch_phub_release(struct inode *inode,struct file *file)
+  @remarks  Implements the release functionality of the Packet Hub module.
+  @param  inode  [@ref INOUT] Contains the reference of the inode structure
+  @param  file   [@ref INOUT] Contains the reference of the file structure
+  @retval returnvalue  [@ref OUT] contains the result for the concerned
attempt.
+  The result would generally comprise of success code
+  or failure code. The failure code will indicate reason for
+  failure.
+  @see
+  SUCCESS
+  */
+int pch_phub_release(struct inode *inode, struct file *file)
+{
+ spin_lock(&pch_phub_lock);
+
+ if (pch_phub_opencount > 0)
+  pch_phub_opencount--;
+ spin_unlock(&pch_phub_lock);
+
+ PCH_DEBUG("pch_phub_release : pch_phub_opencount =%d\n",
+   pch_phub_opencount);
+
+ PCH_DEBUG("pch_phub_release returning=%d\n", PCH_PHUB_SUCCESS);
+ return PCH_PHUB_SUCCESS;
+}
+
+/*! @ingroup PHUB_InterfaceLayerAPI
+  @fn  int pch_phub_ioctl(struct inode * inode,struct file * file,
+      unsigned int cmd,unsigned long arg)
+  @remarks  Implements the various ioctl functionalities of
+  the Packet Hub module.
+  @param  inode [@ref INOUT] Contains the reference of the inode structure
+  @param  file  [@ref INOUT] Contains the reference of the file structure
+  @param  cmd  [@ref IN] Contains the command value
+  @param  arg  [@ref IN] Contains the command argument value
+  @retval returnvalue  [@ref OUT] contains the result for the concerned
attempt.
+  The result would generally comprise of success code
+  or failure code. The failure code will indicate reason for
+  failure.
+  @see
+  EINVAL
+  EFAULT
+  */
+int pch_phub_ioctl(struct inode *inode, struct file *file,
+   unsigned int cmd, unsigned long arg)
+{
+
+ int ret_value = PCH_PHUB_SUCCESS;
+ struct pch_phub_reqt *p_pch_phub_reqt;
+ unsigned long addr_offset;
+ unsigned long data;
+ unsigned long mask;
+
+ do {
+  if (pch_phub_suspended == true) {
+   PCH_LOG(KERN_ERR, "pch_phub_ioctl : "
+    "suspend initiated returning =%d\n",
+    PCH_PHUB_FAIL);
+   ret_value = PCH_PHUB_FAIL;
+   break;
+  }
+
+  p_pch_phub_reqt = (struct pch_phub_reqt *)arg;
+  ret_value =
+   copy_from_user((void *)&addr_offset,
+    (void *)&p_pch_phub_reqt->addr_offset,
+    sizeof(addr_offset));
+  if (ret_value) {
+   PCH_LOG(KERN_ERR, "pch_phub_ioctl : "
+    "copy_from_user fail returning =%d\n",
+    -EFAULT);
+   ret_value = -EFAULT;
+   break;
+  }
+  PCH_DEBUG("pch_phub_ioctl  : copy_from_user returns =%d\n",
+    ret_value);
+
+  switch (cmd) {
+  case IOCTL_PHUB_READ_REG:
+   {
+
+    pch_phub_read_reg(addr_offset, &data);
+    PCH_DEBUG("pch_phub_ioctl  : Invoked "
+     "pch_phub_read_reg successfully\n");
+
+    ret_value =
+        copy_to_user((void *)&p_pch_phub_reqt->
+       data, (void *)&data,
+       sizeof(data));
+    if (ret_value) {
+     PCH_LOG(KERN_ERR, "pch_phub_ioctl : "
+     "copy_to_user fail returning =%d\n",
+      -EFAULT);
+     ret_value = -EFAULT;
+     break;
+    }
+    break;
+   }
+
+  case IOCTL_PHUB_WRITE_REG:
+   {
+
+    ret_value =
+        copy_from_user((void *)&data,
+         (void *)&p_pch_phub_reqt->
+         data, sizeof(data));
+    if (ret_value) {
+     PCH_LOG(KERN_ERR, "pch_phub_ioctl : "
+     "copy_from_user fail returning =%d\n",
+      -EFAULT);
+     ret_value = -EFAULT;
+     break;
+    }
+    pch_phub_write_reg(addr_offset, data);
+    PCH_DEBUG("pch_phub_ioctl  : Invoked "
+     "pch_phub_write_reg successfully\n");
+    break;
+   }
+
+  case IOCTL_PHUB_READ_MODIFY_WRITE_REG:
+   {
+
+    ret_value =
+        copy_from_user((void *)&data,
+         (void *)&p_pch_phub_reqt->
+         data, sizeof(data));
+    if (ret_value) {
+     PCH_LOG(KERN_ERR, "pch_phub_ioctl : "
+      "copy_from_user fail "
+      "returning =%d\n", -EFAULT);
+     ret_value = -EFAULT;
+     break;
+    }
+    ret_value =
+        copy_from_user((void *)&mask,
+         (void *)&p_pch_phub_reqt->
+         mask, sizeof(mask));
+    if (ret_value) {
+     PCH_LOG(KERN_ERR, "pch_phub_ioctl : "
+      "copy_from_user fail "
+      "returning =%d\n", -EFAULT);
+     ret_value = -EFAULT;
+     break;
+    }
+    pch_phub_read_modify_write_reg(addr_offset,
+          data, mask);
+    PCH_DEBUG("pch_phub_ioctl  : Invoked "
+     "pch_phub_read_modify_write_reg "
+     "successfully\n");
+    break;
+   }
+
+  case IOCTL_PHUB_READ_OROM:
+   {
+
+    ret_value =
+        pch_phub_read_serial_rom(addr_offset,
+       (unsigned char *)&data);
+    if (ret_value) {
+     PCH_LOG(KERN_ERR,
+      "pch_phub_ioctl : Invoked "
+      "pch_phub_read_serial_rom "
+      "=%d\n", -EFAULT);
+     ret_value = -EFAULT;
+     break;
+    } else {
+     PCH_DEBUG("pch_phub_ioctl : Invoked "
+      "pch_phub_read_serial_rom "
+      "successfully\n");
+    }
+
+    ret_value =
+        copy_to_user((void *)&p_pch_phub_reqt->
+       data, (void *)&data,
+       sizeof(data));
+    if (ret_value) {
+     PCH_LOG(KERN_ERR, "pch_phub_ioctl : "
+      "copy_to_user fail returning "
+      "=%d\n", -EFAULT);
+     ret_value = -EFAULT;
+     break;
+    }
+    break;
+   }
+
+  case IOCTL_PHUB_WRITE_OROM:
+   {
+
+    ret_value =
+        copy_from_user((void *)&data,
+         (void *)&p_pch_phub_reqt->
+         data, sizeof(data));
+    if (ret_value) {
+     PCH_LOG(KERN_ERR, "pch_phub_ioctl : "
+      "copy_from_user fail returning "
+      "=%d\n", -EFAULT);
+     ret_value = -EFAULT;
+     break;
+    }
+    ret_value =
+        pch_phub_write_serial_rom(addr_offset,
+         data);
+    if (ret_value) {
+     PCH_LOG(KERN_ERR,
+      "pch_phub_ioctl : Invoked "
+      "pch_phub_write_serial_rom "
+      "=%d\n", -EFAULT);
+     ret_value = -EFAULT;
+     break;
+    } else {
+     PCH_DEBUG("pch_phub_ioctl : Invoked "
+      "pch_phub_write_serial_rom "
+      "successfully\n");
+    }
+    break;
+   }
+
+  case IOCTL_PHUB_READ_MAC_ADDR:
+   {
+
+    pch_phub_read_gbe_mac_addr(addr_offset,
+       (unsigned char *)&data);
+    PCH_DEBUG("pch_phub_ioctl : Invoked "
+     "pch_phub_read_gbe_mac_addr "
+     "successfully\n");
+
+    ret_value =
+        copy_to_user((void *)&p_pch_phub_reqt->
+       data, (void *)&data,
+       sizeof(data));
+    if (ret_value) {
+     PCH_LOG(KERN_ERR, "pch_phub_ioctl : "
+      "copy_to_user fail "
+      "returning =%d\n", -EFAULT);
+     ret_value = -EFAULT;
+     break;
+    }
+    break;
+   }
+
+  case IOCTL_PHUB_WRITE_MAC_ADDR:
+   {
+
+    ret_value =
+        copy_from_user((void *)&data,
+         (void *)&p_pch_phub_reqt->
+         data, sizeof(data));
+    if (ret_value) {
+     PCH_LOG(KERN_ERR, "pch_phub_ioctl : "
+      "copy_from_user fail "
+      "returning =%d\n", -EFAULT);
+     ret_value = -EFAULT;
+     break;
+    }
+    pch_phub_write_gbe_mac_addr(addr_offset,
+              data);
+    PCH_DEBUG("pch_phub_ioctl : Invoked "
+     "pch_phub_write_gbe_mac_addr "
+     "successfully\n");
+    break;
+   }
+
+  default:
+   {
+    PCH_LOG(KERN_ERR, "pch_write_ioctl invalid "
+     "command returning=%d\n", -EINVAL);
+    ret_value = -EINVAL;
+    break;
+   }
+  }
+  break;
+
+ } while (0);
+ PCH_LOG(KERN_ERR, "pch_write_ioctl returns=%d\n", ret_value);
+ return ret_value;
+}
diff -urN linux-2.6.33.1/drivers/char/pch_phub/pch_phub.h
topcliff-2.6.33.1/drivers/char/pch_phub/pch_phub.h
--- linux-2.6.33.1/drivers/char/pch_phub/pch_phub.h 1970-01-01
09:00:00.000000000 +0900
+++ topcliff-2.6.33.1/drivers/char/pch_phub/pch_phub.h 2010-04-14
18:39:05.000000000 +0900
@@ -0,0 +1,195 @@
+#ifndef __PCH_PHUB_H__
+#define __PCH_PHUB_H__
+/*!
+ * @file pch_phub.h
+ * @brief Provides all the interfaces pertaining to the Packet Hub module.
+ * @version 1.0.0.0
+ * @section
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; version 2 of the License.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307,
USA.
+ */
+
+/*
+ * History:
+ * Copyright (C) 2010 OKI SEMICONDUCTOR Co., LTD.
+ *
+ * created:
+ * OKI SEMICONDUCTOR 04/14/2010
+ * modified:
+ *
+ */
+
+/*! @defgroup PHUB */
+/*! @defgroup PHUB_Global      Global
+  @ingroup PHUB */
+/*! @defgroup PHUB_GlobalGeneral   General
+  @ingroup PHUB_Global */
+/*! @defgroup PHUB_GlobalResultCodes   StatusCodes
+  @ingroup PHUB_Global */
+/*! @defgroup PHUB_InterfaceLayer   InterfaceLayer
+  @ingroup PHUB */
+/*! @defgroup PHUB_InterfaceLayerAPI    Providers
+  @ingroup PHUB_InterfaceLayer
+  */
+/*! @defgroup PHUB_InterfaceLayerNotifyRoutines   Notifiers
+  @ingroup PHUB_InterfaceLayer
+  */
+/*! @defgroup PHUB_PCILayer    PCILayer
+  @ingroup PHUB */
+/*! @defgroup PHUB_PCILayerAPI     Providers
+  @ingroup PHUB_PCILayer
+  */
+/*! @defgroup PHUB_PCILayerFacilitators    Facilitators
+  @ingroup PHUB_PCILayer
+  */
+/*! @defgroup PHUB_HALLayer    HALLayer
+  @ingroup PHUB */
+/*! @defgroup PHUB_HALLayerAPI     Providers
+  @ingroup PHUB_HALLayer
+  */
+/*! @defgroup PHUB_HALLayerFacilitators    Facilitators
+  @ingroup PHUB_HALLayer
+  */
+/*! @defgroup PHUB_Utilities    Utilities
+  @ingroup PHUB */
+/*! @defgroup PHUB_UtilitiesAPI     Providers
+  @ingroup PHUB_Utilities
+  */
+
+/*! @ingroup PHUB_InterfaceLayer
+  @def PHUB_IOCTL_MAGIC
+  @brief Outlines the ioctl magic.
+  */
+#define PHUB_IOCTL_MAGIC   (0xf7)
+
+/*! @ingroup PHUB_InterfaceLayer
+  @def IOCTL_PHUB_READ_REG
+  @brief Outlines the read register function signature.
+  */
+#define IOCTL_PHUB_READ_REG (_IOW(PHUB_IOCTL_MAGIC, 1, unsigned long))
+
+/*! @ingroup PHUB_InterfaceLayer
+  @def IOCTL_PHUB_WRITE_REG
+  @brief Outlines the write register function signature.
+  */
+#define IOCTL_PHUB_WRITE_REG (_IOW(PHUB_IOCTL_MAGIC, 2, unsigned long))
+
+/*! @ingroup PHUB_InterfaceLayer
+  @def IOCTL_PHUB_READ_MODIFY_WRITE_REG
+  @brief Outlines the read, modify and write register function signature.
+  */
+#define IOCTL_PHUB_READ_MODIFY_WRITE_REG (_IOW(PHUB_IOCTL_MAGIC, 3,\
+         unsigned long))
+
+/*! @ingroup PHUB_InterfaceLayer
+  @def IOCTL_PHUB_READ_OROM
+  @brief Outlines the read option rom function signature.
+  */
+#define IOCTL_PHUB_READ_OROM (_IOW(PHUB_IOCTL_MAGIC, 4, unsigned long))
+
+/*! @ingroup PHUB_InterfaceLayer
+  @def IOCTL_PHUB_WRITE_OROM
+  @brief Outlines the write option rom function signature.
+  */
+#define IOCTL_PHUB_WRITE_OROM (_IOW(PHUB_IOCTL_MAGIC, 5, unsigned long))
+
+/*! @ingroup PHUB_InterfaceLayer
+  @def IOCTL_PHUB_READ_MAC_ADDR
+  @brief Outlines the read mac address function signature.
+  */
+#define IOCTL_PHUB_READ_MAC_ADDR (_IOW(PHUB_IOCTL_MAGIC, 6,\
+         unsigned long))
+
+/*! @ingroup PHUB_InterfaceLayer
+  @def IOCTL_PHUB_WRITE_MAC_ADDR
+  @brief Outlines the write mac address function signature.
+  */
+#define IOCTL_PHUB_WRITE_MAC_ADDR (_IOW(PHUB_IOCTL_MAGIC, 7,\
+         unsigned long))
+
+/*! @ingroup PHUB_InterfaceLayer
+  @def PHUB STATUS CODE
+  @brief Outlines PHUB SUCCESS STATUS CODE
+  */
+#define PCH_PHUB_SUCCESS  (0)
+
+/*! @ingroup PHUB_InterfaceLayer
+  @def PHUB STATUS CODE
+  @brief Outlines PHUB ERROR STATUS CODE
+  */
+#define PCH_PHUB_FAIL   (-1)
+
+/* Registers address offset */
+#define PCH_PHUB_PHUB_ID_REG   (0x0000)
+#define PCH_PHUB_QUEUE_PRI_VAL_REG  (0x0004)
+#define PCH_PHUB_RC_QUEUE_MAXSIZE_REG (0x0008)
+#define PCH_PHUB_BRI_QUEUE_MAXSIZE_REG (0x000C)
+#define PCH_PHUB_COMP_RESP_TIMEOUT_REG (0x0010)
+#define PCH_PHUB_BUS_SLAVE_CONTROL_REG (0x0014)
+#define PCH_PHUB_DEADLOCK_AVOID_TYPE_REG (0x0018)
+#define PCH_PHUB_INTPIN_REG_WPERMIT_REG0 (0x0020)
+#define PCH_PHUB_INTPIN_REG_WPERMIT_REG1 (0x0024)
+#define PCH_PHUB_INTPIN_REG_WPERMIT_REG2 (0x0028)
+#define PCH_PHUB_INTPIN_REG_WPERMIT_REG3 (0x002C)
+#define PCH_PHUB_INT_REDUCE_CONTROL_REG_BASE (0x0040)
+#define CLKCFG_REG_OFFSET             (0x500)
+
+/*structures*/
+/*! @ingroup PHUB_InterfaceLayer
+  @struct pch_phub_reqt
+  @brief It is a structure used for perserving information related to the
+  Packet Hub request.
+  @note
+  The concerned details should be provided during the read register,
+   write register and read / modify / write register.
+  @see
+  pch_phub_ioctl
+  */
+struct pch_phub_reqt {
+ unsigned long addr_offset; /*specifies the register address
+         offset */
+ unsigned long data; /*specifies the data */
+ unsigned long mask; /*specifies the mask */
+};
+
+/* exported function prototypes */
+/*! @ingroup PHUB_InterfaceLayerAPI
+  @fn nt pch_phub_open( struct inode *inode,struct file *file )
+  @brief  Provides the functionality of initialization of the module
+  */
+int pch_phub_open(struct inode *inode, struct file *file);
+
+/*! @ingroup PHUB_InterfaceLayerAPI
+  @fn int pch_phub_release(struct inode *inode,struct file *file)
+  @brief  Provides the functionality of releasing the module
+  */
+int pch_phub_release(struct inode *inode, struct file *file);
+
+/*! @ingroup PHUB_InterfaceLayerAPI
+  @fn int pch_phub_ioctl(struct inode * inode,struct file * file,
+        unsigned int cmd,
+  unsigned long arg)
+  @brief  Provides the functionality of invoking various functionalities of
+         the Packet Hub.
+  */
+int pch_phub_ioctl(struct inode *inode, struct file *file, unsigned int
cmd,
+        unsigned long arg);
+
+/**global variables*/
+extern u32 pch_phub_base_address; /* base address */
+extern s32 pch_phub_suspended; /* suspend status */
+
+extern s32 pch_phub_opencount;
+extern spinlock_t pch_phub_lock;
+extern const struct file_operations pch_phub_fops;
+#endif
diff -urN linux-2.6.33.1/drivers/char/pch_phub/pch_phub_hal.c
topcliff-2.6.33.1/drivers/char/pch_phub/pch_phub_hal.c
--- linux-2.6.33.1/drivers/char/pch_phub/pch_phub_hal.c 1970-01-01
09:00:00.000000000 +0900
+++ topcliff-2.6.33.1/drivers/char/pch_phub/pch_phub_hal.c 2010-04-14
18:32:23.000000000 +0900
@@ -0,0 +1,544 @@
+/*!
+ * @file pch_phub_hal.c
+ * @brief Provides all the implementation of the interfaces pertaining to
the
+ *           HAL.
+ * @version 1.0.0.0
+ * @section
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; version 2 of the License.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307,
USA.
+ */
+
+/*
+ * History:
+ * Copyright (C) 2010 OKI SEMICONDUCTOR Co., LTD.
+ *
+ * created:
+ * OKI SEMICONDUCTOR 04/14/2010
+ * modified:
+ *
+ */
+
+/*includes*/
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/pci.h>
+#include <linux/io.h>
+#include <linux/delay.h>
+#include "pch_common.h"
+#include "pch_debug.h"
+#include "pch_phub.h"
+#include "pch_phub_hal.h"
+
+/* Status Register offset */
+#define PHUB_STATUS (0x00)
+
+/* Control Register offset */
+#define PHUB_CONTROL (0x04)
+
+/* Time out value for Status Register */
+#define PHUB_TIMEOUT (0x05)
+
+/* Enabling for writing ROM */
+#define PCH_PHUB_ROM_WRITE_ENABLE (0x01)
+
+/* Disabling for writing ROM */
+#define PCH_PHUB_ROM_WRITE_DISABLE (0x00)
+
+/* ROM data area start address offset */
+#define PCH_PHUB_ROM_START_ADDR (0x14)
+
+/* MAX number of INT_REDUCE_CONTROL registers */
+#define MAX_NUM_INT_REDUCE_CONTROL_REG (128)
+
+/* global variables */
+struct pch_phub_reg {
+ u32 phub_id_reg; /* PHUB_ID register val */
+ u32 q_pri_val_reg; /* QUEUE_PRI_VAL register val */
+ u32 rc_q_maxsize_reg; /* RC_QUEUE_MAXSIZE register val */
+ u32 bri_q_maxsize_reg; /* BRI_QUEUE_MAXSIZE register val */
+ u32 comp_resp_timeout_reg; /* COMP_RESP_TIMEOUT register val */
+ u32 bus_slave_control_reg; /* BUS_SLAVE_CONTROL_REG register val */
+ u32 deadlock_avoid_type_reg; /* DEADLOCK_AVOID_TYPE register val */
+ u32 intpin_reg_wpermit_reg0; /* INTPIN_REG_WPERMIT register 0 val */
+ u32 intpin_reg_wpermit_reg1; /* INTPIN_REG_WPERMIT register 1 val */
+ u32 intpin_reg_wpermit_reg2; /* INTPIN_REG_WPERMIT register 2 val */
+ u32 intpin_reg_wpermit_reg3; /* INTPIN_REG_WPERMIT register 3 val */
+ /* INT_REDUCE_CONTROL registers val */
+ u32 int_reduce_control_reg[MAX_NUM_INT_REDUCE_CONTROL_REG];
+#ifdef PCH_CAN_PCLK_50MHZ
+ u32 clkcfg_reg;  /* CLK CFG register val */
+#endif
+} g_pch_phub_reg;
+
+/*functions implementations*/
+/*! @ingroup PHUB_HALLayerAPI
+  @fn  void pch_phub_read_reg(unsigned long reg_addr_offset,
+        unsigned long *data)
+  @remarks  Implements the functionality of reading register.
+  @param  reg_addr_offset [@ref IN] Contains the register offset address
value
+  @param  *data           [@ref INOUT] Contains the register value
+  @retval NONE
+  @see
+  */
+void pch_phub_read_reg(unsigned long reg_addr_offset, unsigned long *data)
+{
+ unsigned long reg_addr = pch_phub_base_address + reg_addr_offset;
+ *data = PCH_READ32(reg_addr);
+
+ return;
+}
+
+/*! @ingroup PHUB_HALLayerAPI
+  @fn  void pch_phub_write_reg(unsigned long reg_addr_offset,
+        unsigned long data)
+  @remarks  Implements the functionality of writing register.
+  @param  reg_addr_offset [@ref IN] Contains the register offset address
value
+  @param  data            [@ref IN] Contains the writing value
+  @retval NONE
+  @see
+  */
+void pch_phub_write_reg(unsigned long reg_addr_offset, unsigned long data)
+{
+ unsigned long reg_addr = pch_phub_base_address + reg_addr_offset;
+ PCH_WRITE32(data, reg_addr);
+
+ return;
+}
+
+/*! @ingroup PHUB_HALLayerAPI
+  @fn  void pch_phub_read_modify_write_reg(unsigned long reg_addr_offset,
+      unsigned long data, unsigned long mask)
+  @remarks  Implements the functionality of reading, modifying and writing
+         register.
+  @param  reg_addr_offset [@ref IN] Contains the register offset address
value
+  @param  data            [@ref IN] Contains the writing value
+  @param  mask            [@ref IN] Contains the mask value
+  @retval NONE
+  @see
+  */
+void pch_phub_read_modify_write_reg(unsigned long reg_addr_offset,
+           unsigned long data, unsigned long mask)
+{
+ unsigned long reg_addr = pch_phub_base_address + reg_addr_offset;
+ PCH_WRITE32(((PCH_READ32(reg_addr) & ~mask)) | data, reg_addr);
+
+ return;
+}
+
+/*! @ingroup PHUB_HALLayerAPI
+  @fn int pch_phub_read_gbe_mac_addr(unsigned long offset_address,
+        unsigned char *data)
+  @param  unsigned long offset_address
+ [@ref IN] Contains the Gigabit Ethernet MAC address offset value
+  @param  *data [@ref INOUT] Contains the Gigabit Ethernet MAC address
value
+  @retval return value [@ref OUT] contains the result
+    for the reading Gigabit Ethernet MAC address attempt
+  @see
+  */
+int pch_phub_read_gbe_mac_addr(unsigned long offset_address,
+      unsigned char *data)
+{
+ int retval = PCH_PHUB_SUCCESS;
+
+ retval = pch_phub_read_serial_rom_val(offset_address, data);
+
+ return retval;
+}
+EXPORT_SYMBOL(pch_phub_read_gbe_mac_addr);
+
+/*! @ingroup PHUB_HALLayerAPI
+  @fn int pch_phub_write_gbe_mac_addr(unsigned long offset_address,
+        unsigned char data)
+  @param  unsigned long offset_address
+ [@ref IN] Contains the Gigabit Ethernet MAC address offset value
+  @param  data [@ref IN] Contains the Gigabit Ethernet MAC address value
+  @retval return value [@ref OUT] contains the result for the
+     writing Gigabit Ethernet MAC address attempt
+  @see
+  */
+int pch_phub_write_gbe_mac_addr(unsigned long offset_address,
+       unsigned char data)
+{
+ int retval = PCH_PHUB_SUCCESS;
+
+ retval = pch_phub_gbe_serial_rom_conf();
+ retval |= pch_phub_write_serial_rom_val(offset_address, data);
+
+ return retval;
+}
+EXPORT_SYMBOL(pch_phub_write_gbe_mac_addr);
+
+/*! @ingroup PHUB_HALLayerAPI
+  @fn  void pch_phub_save_reg_conf(void)
+  @remarks  saves register configuration
+  @param NONE
+  @retval  NONE
+  @see
+  pch_phub_suspend
+  */
+void pch_phub_save_reg_conf(void)
+{
+ u32 base_addr = pch_phub_base_address;
+ u32 i = 0;
+
+ PCH_DEBUG("pch_phub_save_reg_conf ENTRY\n");
+ /* to store contents of PHUB_ID register */
+ g_pch_phub_reg.phub_id_reg =
+     PCH_READ32(base_addr + PCH_PHUB_PHUB_ID_REG);
+ /* to store contents of QUEUE_PRI_VAL register */
+ g_pch_phub_reg.q_pri_val_reg =
+     PCH_READ32(base_addr + PCH_PHUB_QUEUE_PRI_VAL_REG);
+ /* to store contents of RC_QUEUE_MAXSIZE register */
+ g_pch_phub_reg.rc_q_maxsize_reg =
+     PCH_READ32(base_addr + PCH_PHUB_RC_QUEUE_MAXSIZE_REG);
+ /* to store contents of BRI_QUEUE_MAXSIZE register */
+ g_pch_phub_reg.bri_q_maxsize_reg =
+     PCH_READ32(base_addr + PCH_PHUB_BRI_QUEUE_MAXSIZE_REG);
+ /* to store contents of COMP_RESP_TIMEOUT register */
+ g_pch_phub_reg.comp_resp_timeout_reg =
+     PCH_READ32(base_addr + PCH_PHUB_COMP_RESP_TIMEOUT_REG);
+ /* to store contents of BUS_SLAVE_CONTROL_REG register */
+ g_pch_phub_reg.bus_slave_control_reg =
+     PCH_READ32(base_addr + PCH_PHUB_BUS_SLAVE_CONTROL_REG);
+ /* to store contents of DEADLOCK_AVOID_TYPE register */
+ g_pch_phub_reg.deadlock_avoid_type_reg =
+     PCH_READ32(base_addr + PCH_PHUB_DEADLOCK_AVOID_TYPE_REG);
+ /* to store contents of INTPIN_REG_WPERMIT register 0 */
+ g_pch_phub_reg.intpin_reg_wpermit_reg0 =
+     PCH_READ32(base_addr + PCH_PHUB_INTPIN_REG_WPERMIT_REG0);
+ /* to store contents of INTPIN_REG_WPERMIT register 1 */
+ g_pch_phub_reg.intpin_reg_wpermit_reg1 =
+     PCH_READ32(base_addr + PCH_PHUB_INTPIN_REG_WPERMIT_REG1);
+ /* to store contents of INTPIN_REG_WPERMIT register 2 */
+ g_pch_phub_reg.intpin_reg_wpermit_reg2 =
+     PCH_READ32(base_addr + PCH_PHUB_INTPIN_REG_WPERMIT_REG2);
+ /* to store contents of INTPIN_REG_WPERMIT register 3 */
+ g_pch_phub_reg.intpin_reg_wpermit_reg3 =
+     PCH_READ32(base_addr + PCH_PHUB_INTPIN_REG_WPERMIT_REG3);
+ PCH_DEBUG("pch_phub_save_reg_conf : "
+  "g_pch_phub_reg.phub_id_reg=%x, "
+  "g_pch_phub_reg.q_pri_val_reg=%x, "
+  "g_pch_phub_reg.rc_q_maxsize_reg=%x, "
+  "g_pch_phub_reg.bri_q_maxsize_reg=%x, "
+  "g_pch_phub_reg.comp_resp_timeout_reg=%x, "
+  "g_pch_phub_reg.bus_slave_control_reg=%x, "
+  "g_pch_phub_reg.deadlock_avoid_type_reg=%x, "
+  "g_pch_phub_reg.intpin_reg_wpermit_reg0=%x, "
+  "g_pch_phub_reg.intpin_reg_wpermit_reg1=%x, "
+  "g_pch_phub_reg.intpin_reg_wpermit_reg2=%x, "
+  "g_pch_phub_reg.intpin_reg_wpermit_reg3=%x\n",
+  g_pch_phub_reg.phub_id_reg,
+  g_pch_phub_reg.q_pri_val_reg,
+  g_pch_phub_reg.rc_q_maxsize_reg,
+  g_pch_phub_reg.bri_q_maxsize_reg,
+  g_pch_phub_reg.comp_resp_timeout_reg,
+  g_pch_phub_reg.bus_slave_control_reg,
+  g_pch_phub_reg.deadlock_avoid_type_reg,
+  g_pch_phub_reg.intpin_reg_wpermit_reg0,
+  g_pch_phub_reg.intpin_reg_wpermit_reg1,
+  g_pch_phub_reg.intpin_reg_wpermit_reg2,
+  g_pch_phub_reg.intpin_reg_wpermit_reg3);
+ /* to store contents of INT_REDUCE_CONTROL registers */
+ for (i = 0; i < MAX_NUM_INT_REDUCE_CONTROL_REG; i++) {
+  g_pch_phub_reg.int_reduce_control_reg[i] =
+      PCH_READ32(base_addr +
+          PCH_PHUB_INT_REDUCE_CONTROL_REG_BASE + 4 * i);
+  PCH_DEBUG("pch_phub_save_reg_conf : "
+   "g_pch_phub_reg.int_reduce_control_reg[%d]=%x\n",
+   i, g_pch_phub_reg.int_reduce_control_reg[i]);
+ }
+#ifdef PCH_CAN_PCLK_50MHZ
+ /* save clk cfg register */
+ g_pch_phub_reg.clkcfg_reg =
+     PCH_READ32(base_addr + CLKCFG_REG_OFFSET);
+#endif
+ return;
+}
+
+/*! @ingroup PHUB_HALLayerAPI
+  @fn  void pch_phub_restore_reg_conf(void)
+  @remarks  restore register configuration
+  @param NONE
+  @retval  NONE
+  @see
+  pch_phub_resume
+  */
+void pch_phub_restore_reg_conf(void)
+{
+ u32 base_addr = pch_phub_base_address;
+ u32 i = 0;
+
+ PCH_DEBUG("pch_phub_restore_reg_conf ENTRY\n");
+ /* to store contents of PHUB_ID register */
+ PCH_WRITE32(g_pch_phub_reg.phub_id_reg,
+      base_addr + PCH_PHUB_PHUB_ID_REG);
+ /* to store contents of QUEUE_PRI_VAL register */
+ PCH_WRITE32(g_pch_phub_reg.q_pri_val_reg,
+      base_addr + PCH_PHUB_QUEUE_PRI_VAL_REG);
+ /* to store contents of RC_QUEUE_MAXSIZE register */
+ PCH_WRITE32(g_pch_phub_reg.rc_q_maxsize_reg,
+      base_addr + PCH_PHUB_RC_QUEUE_MAXSIZE_REG);
+ /* to store contents of BRI_QUEUE_MAXSIZE register */
+ PCH_WRITE32(g_pch_phub_reg.bri_q_maxsize_reg,
+      base_addr + PCH_PHUB_BRI_QUEUE_MAXSIZE_REG);
+ /* to store contents of COMP_RESP_TIMEOUT register */
+ PCH_WRITE32(g_pch_phub_reg.comp_resp_timeout_reg,
+      base_addr + PCH_PHUB_COMP_RESP_TIMEOUT_REG);
+ /* to store contents of BUS_SLAVE_CONTROL_REG register */
+ PCH_WRITE32(g_pch_phub_reg.bus_slave_control_reg,
+      base_addr + PCH_PHUB_BUS_SLAVE_CONTROL_REG);
+ /* to store contents of DEADLOCK_AVOID_TYPE register */
+ PCH_WRITE32(g_pch_phub_reg.deadlock_avoid_type_reg,
+      base_addr + PCH_PHUB_DEADLOCK_AVOID_TYPE_REG);
+ /* to store contents of INTPIN_REG_WPERMIT register 0 */
+ PCH_WRITE32(g_pch_phub_reg.intpin_reg_wpermit_reg0,
+      base_addr + PCH_PHUB_INTPIN_REG_WPERMIT_REG0);
+ /* to store contents of INTPIN_REG_WPERMIT register 1 */
+ PCH_WRITE32(g_pch_phub_reg.intpin_reg_wpermit_reg1,
+      base_addr + PCH_PHUB_INTPIN_REG_WPERMIT_REG1);
+ /* to store contents of INTPIN_REG_WPERMIT register 2 */
+ PCH_WRITE32(g_pch_phub_reg.intpin_reg_wpermit_reg2,
+      base_addr + PCH_PHUB_INTPIN_REG_WPERMIT_REG2);
+ /* to store contents of INTPIN_REG_WPERMIT register 3 */
+ PCH_WRITE32(g_pch_phub_reg.intpin_reg_wpermit_reg3,
+      base_addr + PCH_PHUB_INTPIN_REG_WPERMIT_REG3);
+ PCH_DEBUG("pch_phub_save_reg_conf : "
+  "g_pch_phub_reg.phub_id_reg=%x, "
+  "g_pch_phub_reg.q_pri_val_reg=%x, "
+  "g_pch_phub_reg.rc_q_maxsize_reg=%x, "
+  "g_pch_phub_reg.bri_q_maxsize_reg=%x, "
+  "g_pch_phub_reg.comp_resp_timeout_reg=%x, "
+  "g_pch_phub_reg.bus_slave_control_reg=%x, "
+  "g_pch_phub_reg.deadlock_avoid_type_reg=%x, "
+  "g_pch_phub_reg.intpin_reg_wpermit_reg0=%x, "
+  "g_pch_phub_reg.intpin_reg_wpermit_reg1=%x, "
+  "g_pch_phub_reg.intpin_reg_wpermit_reg2=%x, "

