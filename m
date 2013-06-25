From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: [PATCH] net/tg3: Avoid delay during MMIO access
Date: Tue, 25 Jun 2013 15:24:32 +0800
Message-ID: <1372145072-8559-1-git-send-email-shangw@linux.vnet.ibm.com>
Cc: mcarlson@broadcom.com, benh@kernel.crashing.org,
	Gavin Shan <shangw@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e38.co.us.ibm.com ([32.97.110.159]:33089 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751219Ab3FYHYl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jun 2013 03:24:41 -0400
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <shangw@linux.vnet.ibm.com>;
	Tue, 25 Jun 2013 01:24:41 -0600
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id C4FF31FF001C
	for <netdev@vger.kernel.org>; Tue, 25 Jun 2013 01:19:22 -0600 (MDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5P7Oc94154676
	for <netdev@vger.kernel.org>; Tue, 25 Jun 2013 01:24:38 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r5P7Oa7n015857
	for <netdev@vger.kernel.org>; Tue, 25 Jun 2013 01:24:37 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the EEH error is the result of a fenced host bridge, MMIO accesses
can be very slow (milliseconds) to timeout and return all 1's,
thus causing the driver various timeout loops to take way too long and
trigger soft-lockup warnings (in addition to taking minutes to recover).

It might be worthwhile to check if for any of these cases, ffffffff is
a valid possible value, and if not, bail early since that means the HW
is either gone or isolated. In the meantime, checking that the PCI channel
is offline would be workaround of the problem.

Cc: <stable@vger.kernel.org> # v3.0+
Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
---
 drivers/net/ethernet/broadcom/tg3.c |   36 +++++++++++++++++++++++++++++++++++
 1 files changed, 36 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index c777b90..a13463e 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -744,6 +744,9 @@ static int tg3_ape_lock(struct tg3 *tp, int locknum)
 		status = tg3_ape_read32(tp, gnt + off);
 		if (status == bit)
 			break;
+		if (pci_channel_offline(tp->pdev))
+			break;
+
 		udelay(10);
 	}
 
@@ -1635,6 +1638,9 @@ static void tg3_wait_for_event_ack(struct tg3 *tp)
 	for (i = 0; i < delay_cnt; i++) {
 		if (!(tr32(GRC_RX_CPU_EVENT) & GRC_RX_CPU_DRIVER_EVENT))
 			break;
+		if (pci_channel_offline(tp->pdev))
+			break;
+
 		udelay(8);
 	}
 }
@@ -1813,6 +1819,9 @@ static int tg3_poll_fw(struct tg3 *tp)
 		for (i = 0; i < 200; i++) {
 			if (tr32(VCPU_STATUS) & VCPU_STATUS_INIT_DONE)
 				return 0;
+			if (pci_channel_offline(tp->pdev))
+				return -ENODEV;
+
 			udelay(100);
 		}
 		return -ENODEV;
@@ -1823,6 +1832,15 @@ static int tg3_poll_fw(struct tg3 *tp)
 		tg3_read_mem(tp, NIC_SRAM_FIRMWARE_MBOX, &val);
 		if (val == ~NIC_SRAM_FIRMWARE_MBOX_MAGIC1)
 			break;
+		if (pci_channel_offline(tp->pdev)) {
+			if (!tg3_flag(tp, NO_FWARE_REPORTED)) {
+				tg3_flag_set(tp, NO_FWARE_REPORTED);
+				netdev_info(tp->dev, "No firmware running\n");
+			}
+
+			break;
+		}
+
 		udelay(10);
 	}
 
@@ -3520,6 +3538,8 @@ static int tg3_pause_cpu(struct tg3 *tp, u32 cpu_base)
 		tw32(cpu_base + CPU_MODE,  CPU_MODE_HALT);
 		if (tr32(cpu_base + CPU_MODE) & CPU_MODE_HALT)
 			break;
+		if (pci_channel_offline(tp->pdev))
+			return -EBUSY;
 	}
 
 	return (i == iters) ? -EBUSY : 0;
@@ -8589,6 +8609,14 @@ static int tg3_stop_block(struct tg3 *tp, unsigned long ofs, u32 enable_bit, boo
 	tw32_f(ofs, val);
 
 	for (i = 0; i < MAX_WAIT_CNT; i++) {
+		if (pci_channel_offline(tp->pdev)) {
+			dev_err(&tp->pdev->dev,
+				"tg3_stop_block device offline, "
+				"ofs=%lx enable_bit=%x\n",
+				ofs, enable_bit);
+			return -ENODEV;
+		}
+
 		udelay(100);
 		val = tr32(ofs);
 		if ((val & enable_bit) == 0)
@@ -8612,6 +8640,13 @@ static int tg3_abort_hw(struct tg3 *tp, bool silent)
 
 	tg3_disable_ints(tp);
 
+	if (pci_channel_offline(tp->pdev)) {
+		tp->rx_mode &= ~(RX_MODE_ENABLE | TX_MODE_ENABLE);
+		tp->mac_mode &= ~MAC_MODE_TDE_ENABLE;
+		err = -ENODEV;
+		goto err_no_dev;
+	}
+
 	tp->rx_mode &= ~RX_MODE_ENABLE;
 	tw32_f(MAC_RX_MODE, tp->rx_mode);
 	udelay(10);
@@ -8660,6 +8695,7 @@ static int tg3_abort_hw(struct tg3 *tp, bool silent)
 	err |= tg3_stop_block(tp, BUFMGR_MODE, BUFMGR_MODE_ENABLE, silent);
 	err |= tg3_stop_block(tp, MEMARB_MODE, MEMARB_MODE_ENABLE, silent);
 
+err_no_dev:
 	for (i = 0; i < tp->irq_cnt; i++) {
 		struct tg3_napi *tnapi = &tp->napi[i];
 		if (tnapi->hw_status)
-- 
1.7.5.4
