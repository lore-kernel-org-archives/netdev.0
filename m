From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 02/10] bnxt_en: Retrieve the hardware bridge mode from the firmware.
Date: Mon, 24 Jul 2017 12:34:21 -0400
Message-ID: <1500914069-15724-3-git-send-email-michael.chan@broadcom.com>
References: <1500914069-15724-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f173.google.com ([209.85.220.173]:36442 "EHLO
        mail-qk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753718AbdGXQer (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 12:34:47 -0400
Received: by mail-qk0-f173.google.com with SMTP id d136so58489196qkg.3
        for <netdev@vger.kernel.org>; Mon, 24 Jul 2017 09:34:46 -0700 (PDT)
In-Reply-To: <1500914069-15724-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Retrieve and store the hardware bridge mode, so that we can implement
ndo_bridge_{get|set)link methods in the next patch.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 8 ++++++++
 drivers/net/ethernet/broadcom/bnxt/bnxt.h | 1 +
 2 files changed, 9 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 2103f14..ec8a195 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -33,6 +33,7 @@
 #include <linux/mii.h>
 #include <linux/if.h>
 #include <linux/if_vlan.h>
+#include <linux/if_bridge.h>
 #include <linux/rtc.h>
 #include <linux/bpf.h>
 #include <net/ip.h>
@@ -4610,6 +4611,13 @@ static int bnxt_hwrm_func_qcfg(struct bnxt *bp)
 		bp->port_partition_type = resp->port_partition_type;
 		break;
 	}
+	if (bp->hwrm_spec_code < 0x10707 ||
+	    resp->evb_mode == FUNC_QCFG_RESP_EVB_MODE_VEB)
+		bp->br_mode = BRIDGE_MODE_VEB;
+	else if (resp->evb_mode == FUNC_QCFG_RESP_EVB_MODE_VEPA)
+		bp->br_mode = BRIDGE_MODE_VEPA;
+	else
+		bp->br_mode = BRIDGE_MODE_UNDEF;
 
 func_qcfg_exit:
 	mutex_unlock(&bp->hwrm_cmd_lock);
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index 505691a..15d5a10 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -1164,6 +1164,7 @@ struct bnxt {
 	u8			nge_port_cnt;
 	__le16			nge_fw_dst_port_id;
 	u8			port_partition_type;
+	u16			br_mode;
 
 	u16			rx_coal_ticks;
 	u16			rx_coal_ticks_irq;
-- 
1.8.3.1
