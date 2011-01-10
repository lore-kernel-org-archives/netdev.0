From: Casey Leedom <leedom@chelsio.com>
Subject: [PATCH net-26] cxgb4vf: fix mailbox data/control coherency domain race
Date: Mon, 10 Jan 2011 13:51:01 -0800
Message-ID: <1294696261-21209-1-git-send-email-leedom@chelsio.com>
Cc: davem@davemloft.net, Casey Leedom <leedom@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:2252 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752874Ab1AJVvH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jan 2011 16:51:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For the VFs, the Mailbox Data "registers" are actually backed by
T4's "MA" interface rather than PL Registers (as is the case for
the PFs).  Because these are in different coherency domains, the
write to the VF's PL-register-backed Mailbox Control can race in
front of the writes to the MA-backed VF Mailbox Data "registers".
So we need to do a read-back on at least one byte of the VF Mailbox
Data registers before doing the write to the VF Mailbox Control
register.

Signed-off-by: Casey Leedom <leedom@chelsio.com>
---
 drivers/net/cxgb4vf/t4vf_hw.c |   11 +++++++++++
 1 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/drivers/net/cxgb4vf/t4vf_hw.c b/drivers/net/cxgb4vf/t4vf_hw.c
index e4bec78..0f51c80 100644
--- a/drivers/net/cxgb4vf/t4vf_hw.c
+++ b/drivers/net/cxgb4vf/t4vf_hw.c
@@ -147,9 +147,20 @@ int t4vf_wr_mbox_core(struct adapter *adapter, const void *cmd, int size,
 	/*
 	 * Write the command array into the Mailbox Data register array and
 	 * transfer ownership of the mailbox to the firmware.
+	 *
+	 * For the VFs, the Mailbox Data "registers" are actually backed by
+	 * T4's "MA" interface rather than PL Registers (as is the case for
+	 * the PFs).  Because these are in different coherency domains, the
+	 * write to the VF's PL-register-backed Mailbox Control can race in
+	 * front of the writes to the MA-backed VF Mailbox Data "registers".
+	 * So we need to do a read-back on at least one byte of the VF Mailbox
+	 * Data registers before doing the write to the VF Mailbox Control
+	 * register.
 	 */
 	for (i = 0, p = cmd; i < size; i += 8)
 		t4_write_reg64(adapter, mbox_data + i, be64_to_cpu(*p++));
+	t4_read_reg(adapter, mbox_data);         /* flush write */
+
 	t4_write_reg(adapter, mbox_ctl,
 		     MBMSGVALID | MBOWNER(MBOX_OWNER_FW));
 	t4_read_reg(adapter, mbox_ctl);          /* flush write */
-- 
1.7.0.4

