From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 3/3] netxen: fix firmware type check
Date: Sat,  5 Dec 2009 14:23:56 -0800
Message-ID: <1260051836-14425-4-git-send-email-amit.salecha@qlogic.com>
References: <1260051836-14425-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, dhananjay.phadke@qlogic.com,
	Dhananjay Phadke <dhananjay@netxen.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:33742 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1755903AbZLEWXv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Dec 2009 17:23:51 -0500
In-Reply-To: <1260051836-14425-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dhananjay Phadke <dhananjay@netxen.com>

Unified firmware image may not contain MN type of firmware.
Driver should fall back to NOMN firmware type instead
of going to flash.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/netxen/netxen_nic_init.c |   14 +++++++++++++-
 1 files changed, 13 insertions(+), 1 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 80a6674..02f8d4b 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -619,17 +619,20 @@ nx_set_product_offs(struct netxen_adapter *adapter)
 	uint32_t i;
 	__le32 entries;
 
+	int mn_present = (NX_IS_REVISION_P2(adapter->ahw.revision_id)) ?
+			1 : netxen_p3_has_mn(adapter);
+
 	ptab_descr = nx_get_table_desc(unirom, NX_UNI_DIR_SECT_PRODUCT_TBL);
 	if (ptab_descr == NULL)
 		return -1;
 
 	entries = cpu_to_le32(ptab_descr->num_entries);
 
+nomn:
 	for (i = 0; i < entries; i++) {
 
 		__le32 flags, file_chiprev, offs;
 		u8 chiprev = adapter->ahw.revision_id;
-		int mn_present = netxen_p3_has_mn(adapter);
 		uint32_t flagbit;
 
 		offs = cpu_to_le32(ptab_descr->findex) +
@@ -647,6 +650,11 @@ nx_set_product_offs(struct netxen_adapter *adapter)
 		}
 	}
 
+	if (mn_present && NX_IS_REVISION_P3(adapter->ahw.revision_id)) {
+		mn_present = 0;
+		goto nomn;
+	}
+
 	return -1;
 }
 
@@ -1021,6 +1029,10 @@ netxen_p3_has_mn(struct netxen_adapter *adapter)
 	u32 capability, flashed_ver;
 	capability = 0;
 
+	/* NX2031 always had MN */
+	if (NX_IS_REVISION_P2(adapter->ahw.revision_id))
+		return 1;
+
 	netxen_rom_fast_read(adapter,
 			NX_FW_VERSION_OFFSET, (int *)&flashed_ver);
 	flashed_ver = NETXEN_DECODE_VERSION(flashed_ver);
-- 
1.6.0.2

