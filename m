From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next V5 3/9] liquidio CN23XX: Mailbox support
Date: Wed, 9 Nov 2016 15:13:46 -0800
Message-ID: <1478733232-15739-4-git-send-email-rvatsavayi@caviumnetworks.com>
References: <1478733232-15739-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
        Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
        Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>,
        Derek Chickles <derek.chickles@caviumnetworks.com>,
        Satanand Burla <satananda.burla@caviumnetworks.com>,
        Felix Manlunas <felix.manlunas@caviumnetworks.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0081.outbound.protection.outlook.com ([104.47.32.81]:54484
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754705AbcKIXOa (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 9 Nov 2016 18:14:30 -0500
In-Reply-To: <1478733232-15739-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds support for mailbox communication between PF and VF.

Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
---
 drivers/net/ethernet/cavium/liquidio/Makefile      |   1 +
 drivers/net/ethernet/cavium/liquidio/lio_core.c    |  32 +++
 .../net/ethernet/cavium/liquidio/liquidio_common.h |   6 +-
 .../net/ethernet/cavium/liquidio/octeon_device.h   |   4 +
 .../net/ethernet/cavium/liquidio/octeon_mailbox.c  | 318 +++++++++++++++++++++
 .../net/ethernet/cavium/liquidio/octeon_mailbox.h  | 115 ++++++++
 drivers/net/ethernet/cavium/liquidio/octeon_main.h |   2 +-
 7 files changed, 475 insertions(+), 3 deletions(-)
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
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_core.c b/drivers/net/ethernet/cavium/liquidio/lio_core.c
index 201eddb..e6026df 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_core.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_core.c
@@ -264,3 +264,35 @@ void liquidio_link_ctrl_cmd_completion(void *nctrl_ptr)
 			nctrl->ncmd.s.cmd);
 	}
 }
+
+void octeon_pf_changed_vf_macaddr(struct octeon_device *oct, u8 *mac)
+{
+	bool macaddr_changed = false;
+	struct net_device *netdev;
+	struct lio *lio;
+
+	rtnl_lock();
+
+	netdev = oct->props[0].netdev;
+	lio = GET_LIO(netdev);
+
+	lio->linfo.macaddr_is_admin_asgnd = true;
+
+	if (!ether_addr_equal(netdev->dev_addr, mac)) {
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
 
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.h b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
index cfd12ec..77a6eb7 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
@@ -492,6 +492,9 @@ struct octeon_device {
 
 	int msix_on;
 
+	/** Mail Box details of each octeon queue. */
+	struct octeon_mbox  *mbox[MAX_POSSIBLE_VFS];
+
 	/** IOq information of it's corresponding MSI-X interrupt. */
 	struct octeon_ioq_vector    *ioq_vector;
 
@@ -511,6 +514,7 @@ struct octeon_device {
 #define  OCTEON_CN6XXX(oct)           ((oct->chip_id == OCTEON_CN66XX) || \
 				       (oct->chip_id == OCTEON_CN68XX))
 #define  OCTEON_CN23XX_PF(oct)        (oct->chip_id == OCTEON_CN23XX_PF_VID)
+#define  OCTEON_CN23XX_VF(oct)        ((oct)->chip_id == OCTEON_CN23XX_VF_VID)
 #define CHIP_FIELD(oct, TYPE, field)             \
 	(((struct octeon_ ## TYPE  *)(oct->chip))->field)
 
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_mailbox.c b/drivers/net/ethernet/cavium/liquidio/octeon_mailbox.c
new file mode 100644
index 0000000..5309384
--- /dev/null
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_mailbox.c
@@ -0,0 +1,318 @@
+/**********************************************************************
+ * Author: Cavium, Inc.
+ *
+ * Contact: support@cavium.com
+ *          Please include "LiquidIO" in the subject.
+ *
+ * Copyright (c) 2003-2016 Cavium, Inc.
+ *
+ * This file is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License, Version 2, as
+ * published by the Free Software Foundation.
+ *
+ * This file is distributed in the hope that it will be useful, but
+ * AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
+ * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
+ * NONINFRINGEMENT.  See the GNU General Public License for more details.
+ ***********************************************************************/
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
+	union octeon_mbox_message msg;
+	int ret = 0;
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
+	u32 count, i, ret = OCTEON_MBOX_STATUS_SUCCESS;
+	unsigned long flags;
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
+		schedule_timeout_uninterruptible(LIO_MBOX_WRITE_WAIT_TIME);
+		if (count++ == LIO_MBOX_WRITE_WAIT_CNT) {
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
+				if (count++ == LIO_MBOX_WRITE_WAIT_CNT) {
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
+		dev_dbg(&oct->pci_dev->dev, "got vfactive sending data back\n");
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
+		pcie_capability_set_word(
+			oct->sriov_info.dpiring_to_vfpcidev_lut[mbox->q_no],
+			PCI_EXP_DEVCTL, PCI_EXP_DEVCTL_BCR_FLR);
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
index 0000000..fe60a3e
--- /dev/null
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_mailbox.h
@@ -0,0 +1,115 @@
+/**********************************************************************
+ * Author: Cavium, Inc.
+ *
+ * Contact: support@cavium.com
+ *          Please include "LiquidIO" in the subject.
+ *
+ * Copyright (c) 2003-2016 Cavium, Inc.
+ *
+ * This file is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License, Version 2, as
+ * published by the Free Software Foundation.
+ *
+ * This file is distributed in the hope that it will be useful, but
+ * AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
+ * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
+ * NONINFRINGEMENT.  See the GNU General Public License for more details.
+ ***********************************************************************/
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
+#define LIO_MBOX_WRITE_WAIT_CNT          1000
+#define LIO_MBOX_WRITE_WAIT_TIME           10
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
index 366298f..3cddf28 100644
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
-- 
1.8.3.1
