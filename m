From: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
Subject: [PATCH net-next 1/5] be2net: Provide an alternate way to read pf_num for BEx chips
Date: Sun,  9 Oct 2016 09:58:49 +0530
Message-ID: <20161009042853.20601-2-sriharsha.basavapatna@broadcom.com>
References: <20161009042853.20601-1-sriharsha.basavapatna@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [192.19.245.250] ([192.19.245.250]:1200 "EHLO
        CMRELAYP1.ad.emulex.com" rhost-flags-FAIL-FAIL-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751360AbcJIE3e (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 9 Oct 2016 00:29:34 -0400
In-Reply-To: <20161009042853.20601-1-sriharsha.basavapatna@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver gets the pf_num for Skyhawk and Lancer using
GET_FUNC_CONFIG FW command. But since that command is not
supported in BEx, we need to get it from some other command.
Otherwise TPE recovery would fail since all NIC PFs would
end up with a func num of 0. There's a pci function number
field in the response  of GET_CNTL_ATTRIBUTES command that
can be read to get the same info for BEx adapters.

Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c | 5 +++++
 drivers/net/ethernet/emulex/benet/be_cmds.h | 6 +++++-
 2 files changed, 10 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 9cffe48..45d1742 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -3527,6 +3527,11 @@ int be_cmd_get_cntl_attributes(struct be_adapter *adapter)
 		for (i = 0; i < CNTL_SERIAL_NUM_WORDS; i++)
 			adapter->serial_num[i] = le32_to_cpu(serial_num[i]) &
 				(BIT_MASK(16) - 1);
+		/* For BEx, since GET_FUNC_CONFIG command is not
+		 * supported, we read funcnum here as a workaround.
+		 */
+		if (BEx_chip(adapter))
+			adapter->pf_num = attribs->hba_attribs.pci_funcnum;
 	}
 
 err:
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
index 1bd82bc..09da2d8 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -1720,7 +1720,11 @@ struct mgmt_hba_attribs {
 	u32 rsvd2[55];
 	u8 rsvd3[3];
 	u8 phy_port;
-	u32 rsvd4[13];
+	u32 rsvd4[15];
+	u8 rsvd5[2];
+	u8 pci_funcnum;
+	u8 rsvd6;
+	u32 rsvd7[6];
 } __packed;
 
 struct mgmt_controller_attrib {
-- 
2.10.0.478.g3ef7618
