From: Somnath Kotur <somnath.kotur@emulex.com>
Subject: [PATCH net v3] be2net: Warn users of possible broken functionality on BE2 cards with very old FW versions with latest driver
Date: Wed, 23 Oct 2013 16:59:51 +0530
Message-ID: <6e195c58-1709-45de-a2e6-59cd40c0e591@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Somnath Kotur <somnath.kotur@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:45427 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753183Ab3JWLbO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Oct 2013 07:31:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On very old FW versions < 4.0, the mailbox command to set interrupts
on the card succeeds even though it is not supported and should have
failed, leading to a scenario where interrupts do not work.
Hence warn users to upgrade to a suitable FW version to avoid seeing
broken functionality.

Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>
---
v3: Incorporated comments from Ben Hutchings, Joe Perches and Ivan Vercera

 drivers/net/ethernet/emulex/benet/be.h      |    9 +++++++++
 drivers/net/ethernet/emulex/benet/be_main.c |    6 ++++++
 2 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index db02023..da9c04b 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -696,6 +696,15 @@ static inline int qnq_async_evt_rcvd(struct be_adapter *adapter)
 	return adapter->flags & BE_FLAGS_QNQ_ASYNC_EVT_RCVD;
 }
 
+static inline u32 fw_major_num(const char *fw_ver)
+{
+	int fw_major = 0;
+
+	sscanf(fw_ver, "%d.", &fw_major);
+
+	return fw_major;
+}
+
 extern void be_cq_notify(struct be_adapter *adapter, u16 qid, bool arm,
 		u16 num_popped);
 extern void be_link_status_update(struct be_adapter *adapter, u8 link_status);
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 2c38cc4..53ed58b 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -3247,6 +3247,12 @@ static int be_setup(struct be_adapter *adapter)
 
 	be_cmd_get_fw_ver(adapter, adapter->fw_ver, adapter->fw_on_flash);
 
+	if (BE2_chip(adapter) && fw_major_num(adapter->fw_ver) < 4) {
+		dev_err(dev, "Firmware on card is old(%s), IRQs may not work",
+			adapter->fw_ver);
+		dev_err(dev, "Please upgrade firmware to version >= 4.0\n");
+	}
+
 	if (adapter->vlans_added)
 		be_vid_config(adapter);
 
-- 
1.6.0.2
