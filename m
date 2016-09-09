From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next 3/5] liquidio CN23XX: Mailbox support
Date: Fri, 9 Sep 2016 13:08:25 -0700
Message-ID: <1473451707-26397-4-git-send-email-rvatsavayi@caviumnetworks.com>
References: <1473451707-26397-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
        Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
        Derek Chickles <derek.chickles@caviumnetworks.com>,
        Satanand Burla <satananda.burla@caviumnetworks.com>,
        Felix Manlunas <felix.manlunas@caviumnetworks.com>,
        Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0050.outbound.protection.outlook.com ([104.47.42.50]:62176
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751120AbcIIUIy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 9 Sep 2016 16:08:54 -0400
In-Reply-To: <1473451707-26397-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds support for mailbox communication between PF and VF.

Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
---
 drivers/net/ethernet/cavium/liquidio/Makefile      |   1 +
 .../ethernet/cavium/liquidio/cn23xx_pf_device.c    |   4 +-
 .../net/ethernet/cavium/liquidio/cn68xx_device.c   |  13 +-
 drivers/net/ethernet/cavium/liquidio/lio_core.c    |  32 ++
 .../net/ethernet/cavium/liquidio/liquidio_common.h |   6 +-
 .../net/ethernet/cavium/liquidio/octeon_console.c  |  16 +-
 .../net/ethernet/cavium/liquidio/octeon_device.h   |   4 +
 .../net/ethernet/cavium/liquidio/octeon_mailbox.c  | 322 +++++++++++++++++++++
 .../net/ethernet/cavium/liquidio/octeon_mailbox.h  | 116 ++++++++
 drivers/net/ethernet/cavium/liquidio/octeon_main.h |  12 +-
 .../net/ethernet/cavium/liquidio/request_manager.c |   9 +-
 11 files changed, 507 insertions(+), 28 deletions(-)
 create mode 100644 drivers/net/ethernet/cavium/liquidio/octeon_mailbox.c
 create mode 100644 drivers/net/ethernet/cavium/liquidio/octeon_mailbox.h

diff --git a/drivers/net/ethernet/cavium/liquidio/Makefile b/drivers/net/ethernet/cavium/liquidio/Makefile
index 5a27b2a..14958de 100644
--- a/drivers/net/ethernet/cavium/liquidio/Makefile
+++ b/drivers/net/ethernet/cavium/liquidio/Makefile
@@ -11,6 +11,7 @@ liquidio-$(CONFIG_LIQUIDIO) += lio_ethtool.o \
 			cn66xx_device.o    \
 			cn68xx_device.o    \
 			cn23xx_pf_device.o \
+			octeon_mailbox.o   \
 			octeon_mem_ops.o   \
 			octeon_droq.o      \
 			octeon_nic.o
diff --git a/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c b/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c
index deec869..b3c61302 100644
--- a/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c
@@ -270,8 +270,8 @@ static void cn23xx_enable_error_reporting(struct octeon_device *oct)
 
 	regval |= 0xf; /* Enable Link error reporting */
 
-	dev_dbg(&oct->pci_dev->dev, "OCTEON[%d]: Enabling PCI-E error reporting..\n",
-		oct->octeon_id);
+	pr_devel("OCTEON[%d]: Enabling PCI-E error reporting..\n",
+		 oct->octeon_id);
 	pci_write_config_dword(oct->pci_dev, CN23XX_CONFIG_PCIE_DEVCTL, regval);
 }
 
diff --git a/drivers/net/ethernet/cavium/liquidio/cn68xx_device.c b/drivers/net/ethernet/cavium/liquidio/cn68xx_device.c
index dbf3566..424125e 100644
--- a/drivers/net/ethernet/cavium/liquidio/cn68xx_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/cn68xx_device.c
@@ -19,6 +19,7 @@
 * This file may also be available under a different license from Cavium.
 * Contact Cavium, Inc. for more information
 **********************************************************************/
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 #include <linux/pci.h>
 #include <linux/netdevice.h>
 #include "liquidio_common.h"
@@ -37,8 +38,8 @@ static void lio_cn68xx_set_dpi_regs(struct octeon_device *oct)
 	u32 fifo_sizes[6] = { 3, 3, 1, 1, 1, 8 };
 
 	lio_pci_writeq(oct, CN6XXX_DPI_DMA_CTL_MASK, CN6XXX_DPI_DMA_CONTROL);
-	dev_dbg(&oct->pci_dev->dev, "DPI_DMA_CONTROL: 0x%016llx\n",
-		lio_pci_readq(oct, CN6XXX_DPI_DMA_CONTROL));
+	pr_devel("DPI_DMA_CONTROL: 0x%016llx\n",
+		 lio_pci_readq(oct, CN6XXX_DPI_DMA_CONTROL));
 
 	for (i = 0; i < 6; i++) {
 		/* Prevent service of instruction queue for all DMA engines
@@ -47,8 +48,8 @@ static void lio_cn68xx_set_dpi_regs(struct octeon_device *oct)
 		 */
 		lio_pci_writeq(oct, 0, CN6XXX_DPI_DMA_ENG_ENB(i));
 		lio_pci_writeq(oct, fifo_sizes[i], CN6XXX_DPI_DMA_ENG_BUF(i));
-		dev_dbg(&oct->pci_dev->dev, "DPI_ENG_BUF%d: 0x%016llx\n", i,
-			lio_pci_readq(oct, CN6XXX_DPI_DMA_ENG_BUF(i)));
+		pr_devel("DPI_ENG_BUF%d: 0x%016llx\n", i,
+			 lio_pci_readq(oct, CN6XXX_DPI_DMA_ENG_BUF(i)));
 	}
 
 	/* DPI_SLI_PRT_CFG has MPS and MRRS settings that will be set
@@ -56,8 +57,8 @@ static void lio_cn68xx_set_dpi_regs(struct octeon_device *oct)
 	 */
 
 	lio_pci_writeq(oct, 1, CN6XXX_DPI_CTL);
-	dev_dbg(&oct->pci_dev->dev, "DPI_CTL: 0x%016llx\n",
-		lio_pci_readq(oct, CN6XXX_DPI_CTL));
+	pr_devel("DPI_CTL: 0x%016llx\n",
+		 lio_pci_readq(oct, CN6XXX_DPI_CTL));
 }
 
 static int lio_cn68xx_soft_reset(struct octeon_device *oct)
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_core.c b/drivers/net/ethernet/cavium/liquidio/lio_core.c
index 201eddb..4626b1f 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_core.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_core.c
@@ -264,3 +264,35 @@ void liquidio_link_ctrl_cmd_completion(void *nctrl_ptr)
 			nctrl->ncmd.s.cmd);
 	}
 }
+
+void octeon_pf_changed_vf_macaddr(struct octeon_device *oct, u8 *mac)
+{
+	struct net_device *netdev;
+	struct lio *lio;
+	bool macaddr_changed = false;
+
+	rtnl_lock();
+
+	netdev = oct->props[0].netdev;
+	lio = GET_LIO(netdev);
+
+	lio->linfo.macaddr_is_admin_asgnd = true;
+
+	if (ether_addr_equal(netdev->dev_addr, mac)) {
+		macaddr_changed = true;
+		ether_addr_copy(netdev->dev_addr, mac);
+		ether_addr_copy(((u8 *)&lio->linfo.hw_addr) + 2, mac);
+		call_netdevice_notifiers(NETDEV_CHANGEADDR, netdev);
+	}
+
+	rtnl_unlock();
+
+	if (macaddr_changed)
+		dev_info(&oct->pci_dev->dev,
+			 "PF changed VF's MAC address to %02hhx:%02hhx:%02hhx:%02hhx:%02hhx:%02hhx\n",
+			 mac[0], mac[1], mac[2], mac[3], mac[4], mac[5]);
+
+	/* no need to notify the firmware of the macaddr change because
+	 * the PF did that already
+	 */
+}
diff --git a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
index 0d990ac..caeff9a 100644
--- a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
+++ b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
@@ -731,13 +731,15 @@ struct oct_link_info {
 
 #ifdef __BIG_ENDIAN_BITFIELD
 	u64 gmxport:16;
-	u64 rsvd:32;
+	u64 macaddr_is_admin_asgnd:1;
+	u64 rsvd:31;
 	u64 num_txpciq:8;
 	u64 num_rxpciq:8;
 #else
 	u64 num_rxpciq:8;
 	u64 num_txpciq:8;
-	u64 rsvd:32;
+	u64 rsvd:31;
+	u64 macaddr_is_admin_asgnd:1;
 	u64 gmxport:16;
 #endif
 
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_console.c b/drivers/net/ethernet/cavium/liquidio/octeon_console.c
index 01a50f3..edbbda4 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_console.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_console.c
@@ -19,10 +19,10 @@
 * This file may also be available under a different license from Cavium.
 * Contact Cavium, Inc. for more information
 **********************************************************************/
-
 /**
  * @file octeon_console.c
  */
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 #include <linux/pci.h>
 #include <linux/netdevice.h>
 #include <linux/crc32.h>
@@ -267,8 +267,8 @@ static int __cvmx_bootmem_check_version(struct octeon_device *oct,
 		(u32)CVMX_BOOTMEM_DESC_GET_FIELD(oct, major_version);
 	minor_version =
 		(u32)CVMX_BOOTMEM_DESC_GET_FIELD(oct, minor_version);
-	dev_dbg(&oct->pci_dev->dev, "%s: major_version=%d\n", __func__,
-		major_version);
+	pr_devel("%s: major_version=%d\n", __func__,
+		 major_version);
 	if ((major_version > 3) ||
 	    (exact_match && major_version != exact_match)) {
 		dev_err(&oct->pci_dev->dev, "bootmem ver mismatch %d.%d addr:0x%llx\n",
@@ -391,7 +391,7 @@ int octeon_console_send_cmd(struct octeon_device *oct, char *cmd_str,
 {
 	u32 len = (u32)strlen(cmd_str);
 
-	dev_dbg(&oct->pci_dev->dev, "sending \"%s\" to bootloader\n", cmd_str);
+	pr_devel("sending \"%s\" to bootloader\n", cmd_str);
 
 	if (len > BOOTLOADER_PCI_WRITE_BUFFER_STR_LEN - 1) {
 		dev_err(&oct->pci_dev->dev, "Command string too long, max length is: %d\n",
@@ -428,8 +428,8 @@ int octeon_console_send_cmd(struct octeon_device *oct, char *cmd_str,
 int octeon_wait_for_bootloader(struct octeon_device *oct,
 			       u32 wait_time_hundredths)
 {
-	dev_dbg(&oct->pci_dev->dev, "waiting %d0 ms for bootloader\n",
-		wait_time_hundredths);
+	pr_devel("waiting %d0 ms for bootloader\n",
+		 wait_time_hundredths);
 
 	if (octeon_mem_access_ok(oct))
 		return -1;
@@ -569,8 +569,8 @@ int octeon_init_consoles(struct octeon_device *oct)
 			num_consoles));
 	oct->console_desc_addr = addr;
 
-	dev_dbg(&oct->pci_dev->dev, "Initialized consoles. %d available\n",
-		oct->num_consoles);
+	pr_devel("Initialized consoles. %d available\n",
+		 oct->num_consoles);
 
 	return ret;
 }
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.h b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
index 18e3050..3a71451 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
@@ -486,6 +486,9 @@ struct octeon_device {
 
 	int msix_on;
 
+	/** Mail Box details of each octeon queue. */
+	struct octeon_mbox  *mbox[MAX_POSSIBLE_VFS];
+
 	/** IOq information of it's corresponding MSI-X interrupt. */
 	struct octeon_ioq_vector    *ioq_vector;
 
@@ -505,6 +508,7 @@ struct octeon_device {
 #define  OCTEON_CN6XXX(oct)           ((oct->chip_id == OCTEON_CN66XX) || \
 				       (oct->chip_id == OCTEON_CN68XX))
 #define  OCTEON_CN23XX_PF(oct)        (oct->chip_id == OCTEON_CN23XX_PF_VID)
+#define  OCTEON_CN23XX_VF(oct)        (oct->chip_id == OCTEON_CN23XX_VF_VID)
 #define CHIP_FIELD(oct, TYPE, field)             \
 	(((struct octeon_ ## TYPE  *)(oct->chip))->field)
 
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_mailbox.c b/drivers/net/ethernet/cavium/liquidio/octeon_mailbox.c
new file mode 100644
index 0000000..178f4f5
--- /dev/null
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_mailbox.c
@@ -0,0 +1,322 @@
+/**********************************************************************
+* Author: Cavium, Inc.
+*
+* Contact: support@cavium.com
+*          Please include "LiquidIO" in the subject.
+*
+* Copyright (c) 2003-2015 Cavium, Inc.
+*
+* This file is free software; you can redistribute it and/or modify
+* it under the terms of the GNU General Public License, Version 2, as
+* published by the Free Software Foundation.
+*
+* This file is distributed in the hope that it will be useful, but
+* AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
+* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
+* NONINFRINGEMENT.  See the GNU General Public License for more
+* details.
+*
+* This file may also be available under a different license from Cavium.
+* Contact Cavium, Inc. for more information
+**********************************************************************/
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+#include <linux/pci.h>
+#include <linux/netdevice.h>
+#include "liquidio_common.h"
+#include "octeon_droq.h"
+#include "octeon_iq.h"
+#include "response_manager.h"
+#include "octeon_device.h"
+#include "octeon_main.h"
+#include "octeon_mailbox.h"
+
+/**
+ * octeon_mbox_read:
+ * @oct: Pointer mailbox
+ *
+ * Reads the 8-bytes of data from the mbox register
+ * Writes back the acknowldgement inidcating completion of read
+ */
+int octeon_mbox_read(struct octeon_mbox *mbox)
+{
+	int ret = 0;
+	union octeon_mbox_message msg;
+
+	spin_lock(&mbox->lock);
+
+	msg.u64 = readq(mbox->mbox_read_reg);
+
+	if ((msg.u64 == OCTEON_PFVFACK) || (msg.u64 == OCTEON_PFVFSIG)) {
+		spin_unlock(&mbox->lock);
+		return 0;
+	}
+
+	if (mbox->state & OCTEON_MBOX_STATE_REQUEST_RECEIVING) {
+		mbox->mbox_req.data[mbox->mbox_req.recv_len - 1] = msg.u64;
+		mbox->mbox_req.recv_len++;
+	} else {
+		if (mbox->state & OCTEON_MBOX_STATE_RESPONSE_RECEIVING) {
+			mbox->mbox_resp.data[mbox->mbox_resp.recv_len - 1] =
+				msg.u64;
+			mbox->mbox_resp.recv_len++;
+		} else {
+			if ((mbox->state & OCTEON_MBOX_STATE_IDLE) &&
+			    (msg.s.type == OCTEON_MBOX_REQUEST)) {
+				mbox->state &= ~OCTEON_MBOX_STATE_IDLE;
+				mbox->state |=
+				    OCTEON_MBOX_STATE_REQUEST_RECEIVING;
+				mbox->mbox_req.msg.u64 = msg.u64;
+				mbox->mbox_req.q_no = mbox->q_no;
+				mbox->mbox_req.recv_len = 1;
+			} else {
+				if ((mbox->state &
+				     OCTEON_MBOX_STATE_RESPONSE_PENDING) &&
+				    (msg.s.type == OCTEON_MBOX_RESPONSE)) {
+					mbox->state &=
+					    ~OCTEON_MBOX_STATE_RESPONSE_PENDING;
+					mbox->state |=
+					    OCTEON_MBOX_STATE_RESPONSE_RECEIVING
+					    ;
+					mbox->mbox_resp.msg.u64 = msg.u64;
+					mbox->mbox_resp.q_no = mbox->q_no;
+					mbox->mbox_resp.recv_len = 1;
+				} else {
+					writeq(OCTEON_PFVFERR,
+					       mbox->mbox_read_reg);
+					mbox->state |= OCTEON_MBOX_STATE_ERROR;
+					spin_unlock(&mbox->lock);
+					return 1;
+				}
+			}
+		}
+	}
+
+	if (mbox->state & OCTEON_MBOX_STATE_REQUEST_RECEIVING) {
+		if (mbox->mbox_req.recv_len < msg.s.len) {
+			ret = 0;
+		} else {
+			mbox->state &= ~OCTEON_MBOX_STATE_REQUEST_RECEIVING;
+			mbox->state |= OCTEON_MBOX_STATE_REQUEST_RECEIVED;
+			ret = 1;
+		}
+	} else {
+		if (mbox->state & OCTEON_MBOX_STATE_RESPONSE_RECEIVING) {
+			if (mbox->mbox_resp.recv_len < msg.s.len) {
+				ret = 0;
+			} else {
+				mbox->state &=
+				    ~OCTEON_MBOX_STATE_RESPONSE_RECEIVING;
+				mbox->state |=
+				    OCTEON_MBOX_STATE_RESPONSE_RECEIVED;
+				ret = 1;
+			}
+		} else {
+			WARN_ON(1);
+		}
+	}
+
+	writeq(OCTEON_PFVFACK, mbox->mbox_read_reg);
+
+	spin_unlock(&mbox->lock);
+
+	return ret;
+}
+
+/**
+ * octeon_mbox_write:
+ * @oct: Pointer Octeon Device
+ * @mbox_cmd: Cmd to send to mailbox.
+ *
+ * Populates the queue specific mbox structure
+ * with cmd information.
+ * Write the cmd to mbox register
+ */
+int octeon_mbox_write(struct octeon_device *oct,
+		      struct octeon_mbox_cmd *mbox_cmd)
+{
+	struct octeon_mbox *mbox = oct->mbox[mbox_cmd->q_no];
+	unsigned long flags;
+	u32 count, i, ret = OCTEON_MBOX_STATUS_SUCCESS;
+
+	spin_lock_irqsave(&mbox->lock, flags);
+
+	if ((mbox_cmd->msg.s.type == OCTEON_MBOX_RESPONSE) &&
+	    !(mbox->state & OCTEON_MBOX_STATE_REQUEST_RECEIVED)) {
+		spin_unlock_irqrestore(&mbox->lock, flags);
+		return OCTEON_MBOX_STATUS_FAILED;
+	}
+
+	if ((mbox_cmd->msg.s.type == OCTEON_MBOX_REQUEST) &&
+	    !(mbox->state & OCTEON_MBOX_STATE_IDLE)) {
+		spin_unlock_irqrestore(&mbox->lock, flags);
+		return OCTEON_MBOX_STATUS_BUSY;
+	}
+
+	if (mbox_cmd->msg.s.type == OCTEON_MBOX_REQUEST) {
+		memcpy(&mbox->mbox_resp, mbox_cmd,
+		       sizeof(struct octeon_mbox_cmd));
+		mbox->state = OCTEON_MBOX_STATE_RESPONSE_PENDING;
+	}
+
+	spin_unlock_irqrestore(&mbox->lock, flags);
+
+	count = 0;
+
+	while (readq(mbox->mbox_write_reg) != OCTEON_PFVFSIG) {
+		schedule_timeout_uninterruptible(10);
+		if (count++ == 1000) {
+			ret = OCTEON_MBOX_STATUS_FAILED;
+			break;
+		}
+	}
+
+	if (ret == OCTEON_MBOX_STATUS_SUCCESS) {
+		writeq(mbox_cmd->msg.u64, mbox->mbox_write_reg);
+		for (i = 0; i < (u32)(mbox_cmd->msg.s.len - 1); i++) {
+			count = 0;
+			while (readq(mbox->mbox_write_reg) !=
+			       OCTEON_PFVFACK) {
+				schedule_timeout_uninterruptible(10);
+				if (count++ == 1000) {
+					ret = OCTEON_MBOX_STATUS_FAILED;
+					break;
+				}
+			}
+			writeq(mbox_cmd->data[i], mbox->mbox_write_reg);
+		}
+	}
+
+	spin_lock_irqsave(&mbox->lock, flags);
+	if (mbox_cmd->msg.s.type == OCTEON_MBOX_RESPONSE) {
+		mbox->state = OCTEON_MBOX_STATE_IDLE;
+		writeq(OCTEON_PFVFSIG, mbox->mbox_read_reg);
+	} else {
+		if ((!mbox_cmd->msg.s.resp_needed) ||
+		    (ret == OCTEON_MBOX_STATUS_FAILED)) {
+			mbox->state &= ~OCTEON_MBOX_STATE_RESPONSE_PENDING;
+			if (!(mbox->state &
+			      (OCTEON_MBOX_STATE_REQUEST_RECEIVING |
+			       OCTEON_MBOX_STATE_REQUEST_RECEIVED)))
+				mbox->state = OCTEON_MBOX_STATE_IDLE;
+		}
+	}
+	spin_unlock_irqrestore(&mbox->lock, flags);
+
+	return ret;
+}
+
+/**
+ * octeon_mbox_process_cmd:
+ * @mbox: Pointer mailbox
+ * @mbox_cmd: Pointer to command received
+ *
+ * Process the cmd received in mbox
+ */
+static int octeon_mbox_process_cmd(struct octeon_mbox *mbox,
+				   struct octeon_mbox_cmd *mbox_cmd)
+{
+	struct octeon_device *oct = mbox->oct_dev;
+
+	switch (mbox_cmd->msg.s.cmd) {
+	case OCTEON_VF_ACTIVE:
+		pr_devel("got vfactive sending data back\n");
+		mbox_cmd->msg.s.type = OCTEON_MBOX_RESPONSE;
+		mbox_cmd->msg.s.resp_needed = 1;
+		mbox_cmd->msg.s.len = 2;
+		mbox_cmd->data[0] = 0; /* VF version is in mbox_cmd->data[0] */
+		((struct lio_version *)&mbox_cmd->data[0])->major =
+			LIQUIDIO_BASE_MAJOR_VERSION;
+		((struct lio_version *)&mbox_cmd->data[0])->minor =
+			LIQUIDIO_BASE_MINOR_VERSION;
+		((struct lio_version *)&mbox_cmd->data[0])->micro =
+			LIQUIDIO_BASE_MICRO_VERSION;
+		memcpy(mbox_cmd->msg.s.params, (uint8_t *)&oct->pfvf_hsword, 6);
+		/* Sending core cofig info to the corresponding active VF.*/
+		octeon_mbox_write(oct, mbox_cmd);
+		break;
+
+	case OCTEON_VF_FLR_REQUEST:
+		dev_info(&oct->pci_dev->dev,
+			 "got a request for FLR from VF that owns DPI ring %u\n",
+			 mbox->q_no);
+		pci_reset_function(
+			oct->sriov_info.dpiring_to_vfpcidev_lut[mbox->q_no]);
+		break;
+
+	case OCTEON_PF_CHANGED_VF_MACADDR:
+		if (OCTEON_CN23XX_VF(oct))
+			octeon_pf_changed_vf_macaddr(oct,
+						     mbox_cmd->msg.s.params);
+		break;
+
+	default:
+		break;
+	}
+	return 0;
+}
+
+/**
+ *octeon_mbox_process_message:
+ *
+ * Process the received mbox message.
+ */
+int octeon_mbox_process_message(struct octeon_mbox *mbox)
+{
+	struct octeon_mbox_cmd mbox_cmd;
+	unsigned long flags;
+
+	spin_lock_irqsave(&mbox->lock, flags);
+
+	if (mbox->state & OCTEON_MBOX_STATE_ERROR) {
+		if (mbox->state & (OCTEON_MBOX_STATE_RESPONSE_PENDING |
+				   OCTEON_MBOX_STATE_RESPONSE_RECEIVING)) {
+			memcpy(&mbox_cmd, &mbox->mbox_resp,
+			       sizeof(struct octeon_mbox_cmd));
+			mbox->state = OCTEON_MBOX_STATE_IDLE;
+			writeq(OCTEON_PFVFSIG, mbox->mbox_read_reg);
+			spin_unlock_irqrestore(&mbox->lock, flags);
+			mbox_cmd.recv_status = 1;
+			if (mbox_cmd.fn)
+				mbox_cmd.fn(mbox->oct_dev, &mbox_cmd,
+					    mbox_cmd.fn_arg);
+			return 0;
+		}
+
+		mbox->state = OCTEON_MBOX_STATE_IDLE;
+		writeq(OCTEON_PFVFSIG, mbox->mbox_read_reg);
+		spin_unlock_irqrestore(&mbox->lock, flags);
+		return 0;
+	}
+
+	if (mbox->state & OCTEON_MBOX_STATE_RESPONSE_RECEIVED) {
+		memcpy(&mbox_cmd, &mbox->mbox_resp,
+		       sizeof(struct octeon_mbox_cmd));
+		mbox->state = OCTEON_MBOX_STATE_IDLE;
+		writeq(OCTEON_PFVFSIG, mbox->mbox_read_reg);
+		spin_unlock_irqrestore(&mbox->lock, flags);
+		mbox_cmd.recv_status = 0;
+		if (mbox_cmd.fn)
+			mbox_cmd.fn(mbox->oct_dev, &mbox_cmd, mbox_cmd.fn_arg);
+		return 0;
+	}
+
+	if (mbox->state & OCTEON_MBOX_STATE_REQUEST_RECEIVED) {
+		memcpy(&mbox_cmd, &mbox->mbox_req,
+		       sizeof(struct octeon_mbox_cmd));
+		if (!mbox_cmd.msg.s.resp_needed) {
+			mbox->state &= ~OCTEON_MBOX_STATE_REQUEST_RECEIVED;
+			if (!(mbox->state &&
+			      OCTEON_MBOX_STATE_RESPONSE_PENDING))
+				mbox->state = OCTEON_MBOX_STATE_IDLE;
+			writeq(OCTEON_PFVFSIG, mbox->mbox_read_reg);
+		}
+
+		spin_unlock_irqrestore(&mbox->lock, flags);
+		octeon_mbox_process_cmd(mbox, &mbox_cmd);
+		return 0;
+	}
+
+	WARN_ON(1);
+
+	return 0;
+}
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_mailbox.h b/drivers/net/ethernet/cavium/liquidio/octeon_mailbox.h
new file mode 100644
index 0000000..9a3bdec
--- /dev/null
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_mailbox.h
@@ -0,0 +1,116 @@
+/**********************************************************************
+* Author: Cavium, Inc.
+*
+* Contact: support@cavium.com
+*          Please include "LiquidIO" in the subject.
+*
+* Copyright (c) 2003-2015 Cavium, Inc.
+*
+* This file is free software; you can redistribute it and/or modify
+* it under the terms of the GNU General Public License, Version 2, as
+* published by the Free Software Foundation.
+*
+* This file is distributed in the hope that it will be useful, but
+* AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
+* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
+* NONINFRINGEMENT.  See the GNU General Public License for more
+* details.
+*
+* This file may also be available under a different license from Cavium.
+* Contact Cavium, Inc. for more information
+**********************************************************************/
+#ifndef __MAILBOX_H__
+#define __MAILBOX_H__
+
+/* Macros for Mail Box Communication */
+
+#define OCTEON_MBOX_DATA_MAX	32
+
+#define OCTEON_VF_ACTIVE		0x1
+#define OCTEON_VF_FLR_REQUEST		0x2
+#define OCTEON_PF_CHANGED_VF_MACADDR	0x4
+
+/*Macro for Read acknowldgement*/
+#define OCTEON_PFVFACK			0xffffffffffffffff
+#define OCTEON_PFVFSIG			0x1122334455667788
+#define OCTEON_PFVFERR			0xDEADDEADDEADDEAD
+
+enum octeon_mbox_cmd_status {
+	OCTEON_MBOX_STATUS_SUCCESS = 0,
+	OCTEON_MBOX_STATUS_FAILED = 1,
+	OCTEON_MBOX_STATUS_BUSY = 2
+};
+
+enum octeon_mbox_message_type {
+	OCTEON_MBOX_REQUEST = 0,
+	OCTEON_MBOX_RESPONSE = 1
+};
+
+union octeon_mbox_message {
+	u64 u64;
+	struct {
+		u16 type : 1;
+		u16 resp_needed : 1;
+		u16 cmd : 6;
+		u16 len : 8;
+		u8 params[6];
+	} s;
+};
+
+typedef void (*octeon_mbox_callback_t)(void *, void *, void *);
+
+struct octeon_mbox_cmd {
+	union octeon_mbox_message msg;
+	u64 data[OCTEON_MBOX_DATA_MAX];
+	u32 q_no;
+	u32 recv_len;
+	u32 recv_status;
+	octeon_mbox_callback_t fn;
+	void *fn_arg;
+};
+
+enum octeon_mbox_state {
+	OCTEON_MBOX_STATE_IDLE = 1,
+	OCTEON_MBOX_STATE_REQUEST_RECEIVING = 2,
+	OCTEON_MBOX_STATE_REQUEST_RECEIVED = 4,
+	OCTEON_MBOX_STATE_RESPONSE_PENDING = 8,
+	OCTEON_MBOX_STATE_RESPONSE_RECEIVING = 16,
+	OCTEON_MBOX_STATE_RESPONSE_RECEIVED = 16,
+	OCTEON_MBOX_STATE_ERROR = 32
+};
+
+struct octeon_mbox {
+	/** A spinlock to protect access to this q_mbox. */
+	spinlock_t lock;
+
+	struct octeon_device *oct_dev;
+
+	u32 q_no;
+
+	enum octeon_mbox_state state;
+
+	struct cavium_wk mbox_poll_wk;
+
+	/** SLI_MAC_PF_MBOX_INT for PF, SLI_PKT_MBOX_INT for VF. */
+	void *mbox_int_reg;
+
+	/** SLI_PKT_PF_VF_MBOX_SIG(0) for PF, SLI_PKT_PF_VF_MBOX_SIG(1) for VF.
+	 */
+	void *mbox_write_reg;
+
+	/** SLI_PKT_PF_VF_MBOX_SIG(1) for PF, SLI_PKT_PF_VF_MBOX_SIG(0) for VF.
+	 */
+	void *mbox_read_reg;
+
+	struct octeon_mbox_cmd mbox_req;
+
+	struct octeon_mbox_cmd mbox_resp;
+
+};
+
+int octeon_mbox_read(struct octeon_mbox *mbox);
+int octeon_mbox_write(struct octeon_device *oct,
+		      struct octeon_mbox_cmd *mbox_cmd);
+int octeon_mbox_process_message(struct octeon_mbox *mbox);
+
+#endif
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_main.h b/drivers/net/ethernet/cavium/liquidio/octeon_main.h
index 366298f..4ad9d67 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_main.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_main.h
@@ -66,7 +66,7 @@ void octeon_update_tx_completion_counters(void *buf, int reqtype,
 					  unsigned int *bytes_compl);
 void octeon_report_tx_completion_to_bql(void *txq, unsigned int pkts_compl,
 					unsigned int bytes_compl);
-
+void octeon_pf_changed_vf_macaddr(struct octeon_device *oct, u8 *mac);
 /** Swap 8B blocks */
 static inline void octeon_swap_8B_data(u64 *data, u32 blocks)
 {
@@ -84,8 +84,8 @@ static inline void octeon_swap_8B_data(u64 *data, u32 blocks)
   */
 static inline void octeon_unmap_pci_barx(struct octeon_device *oct, int baridx)
 {
-	dev_dbg(&oct->pci_dev->dev, "Freeing PCI mapped regions for Bar%d\n",
-		baridx);
+	pr_devel("Freeing PCI mapped regions for Bar%d\n",
+		 baridx);
 
 	if (oct->mmio[baridx].done)
 		iounmap(oct->mmio[baridx].hw_addr);
@@ -125,9 +125,9 @@ static inline int octeon_map_pci_barx(struct octeon_device *oct,
 		ioremap(oct->mmio[baridx].start, mapped_len);
 	oct->mmio[baridx].mapped_len = mapped_len;
 
-	dev_dbg(&oct->pci_dev->dev, "BAR%d start: 0x%llx mapped %u of %u bytes\n",
-		baridx, oct->mmio[baridx].start, mapped_len,
-		oct->mmio[baridx].len);
+	pr_devel("BAR%d start: 0x%llx mapped %u of %u bytes\n",
+		 baridx, oct->mmio[baridx].start, mapped_len,
+		 oct->mmio[baridx].len);
 
 	if (!oct->mmio[baridx].hw_addr) {
 		dev_err(&oct->pci_dev->dev, "error ioremap for bar %d\n",
diff --git a/drivers/net/ethernet/cavium/liquidio/request_manager.c b/drivers/net/ethernet/cavium/liquidio/request_manager.c
index 90866bb..4291b37 100644
--- a/drivers/net/ethernet/cavium/liquidio/request_manager.c
+++ b/drivers/net/ethernet/cavium/liquidio/request_manager.c
@@ -19,6 +19,7 @@
  * This file may also be available under a different license from Cavium.
  * Contact Cavium, Inc. for more information
  **********************************************************************/
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 #include <linux/pci.h>
 #include <linux/netdevice.h>
 #include <linux/vmalloc.h>
@@ -125,8 +126,8 @@ int octeon_init_instr_queue(struct octeon_device *oct,
 
 	memset(iq->request_list, 0, sizeof(*iq->request_list) * num_descs);
 
-	dev_dbg(&oct->pci_dev->dev, "IQ[%d]: base: %p basedma: %llx count: %d\n",
-		iq_no, iq->base_addr, iq->base_addr_dma, iq->max_count);
+	pr_devel("IQ[%d]: base: %p basedma: %llx count: %d\n",
+		 iq_no, iq->base_addr, iq->base_addr_dma, iq->max_count);
 
 	iq->txpciq.u64 = txpciq.u64;
 	iq->fill_threshold = (u32)conf->db_min;
@@ -211,8 +212,8 @@ int octeon_setup_iq(struct octeon_device *oct,
 	int numa_node = cpu_to_node(iq_no % num_online_cpus());
 
 	if (oct->instr_queue[iq_no]) {
-		dev_dbg(&oct->pci_dev->dev, "IQ is in use. Cannot create the IQ: %d again\n",
-			iq_no);
+		pr_devel("IQ is in use. Cannot create the IQ: %d again\n",
+			 iq_no);
 		oct->instr_queue[iq_no]->txpciq.u64 = txpciq.u64;
 		oct->instr_queue[iq_no]->app_ctx = app_ctx;
 		return 0;
-- 
1.8.3.1
