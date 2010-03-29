From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 5/5] netxen: fix interrupt for NX2031
Date: Mon, 29 Mar 2010 05:43:45 -0700
Message-ID: <1269866625-26151-6-git-send-email-amit.salecha@qlogic.com>
References: <1269866625-26151-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:33825 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1751477Ab0C2Mnq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Mar 2010 08:43:46 -0400
In-Reply-To: <1269866625-26151-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>

For NX2031, msix is supported from fw version > 3.4.336.
This fw version check should take flash fw in consider instead of
running fw or fw from file.
---
 drivers/net/netxen/netxen_nic_main.c |   25 ++++++++++++++++---------
 1 files changed, 16 insertions(+), 9 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 68903bf..f1daa9a 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -772,15 +772,22 @@ netxen_check_options(struct netxen_adapter *adapter)
 	if (NX_IS_REVISION_P3(adapter->ahw.revision_id)) {
 		adapter->msix_supported = !!use_msi_x;
 		adapter->rss_supported = !!use_msi_x;
-	} else if (adapter->fw_version >= NETXEN_VERSION_CODE(3, 4, 336)) {
-		switch (adapter->ahw.board_type) {
-		case NETXEN_BRDTYPE_P2_SB31_10G:
-		case NETXEN_BRDTYPE_P2_SB31_10G_CX4:
-			adapter->msix_supported = !!use_msi_x;
-			adapter->rss_supported = !!use_msi_x;
-			break;
-		default:
-			break;
+	} else {
+		u32 flashed_ver = 0;
+		netxen_rom_fast_read(adapter,
+				NX_FW_VERSION_OFFSET, (int *)&flashed_ver);
+		flashed_ver = NETXEN_DECODE_VERSION(flashed_ver);
+
+		if (flashed_ver >= NETXEN_VERSION_CODE(3, 4, 336)) {
+			switch (adapter->ahw.board_type) {
+			case NETXEN_BRDTYPE_P2_SB31_10G:
+			case NETXEN_BRDTYPE_P2_SB31_10G_CX4:
+				adapter->msix_supported = !!use_msi_x;
+				adapter->rss_supported = !!use_msi_x;
+				break;
+			default:
+				break;
+			}
 		}
 	}
 
-- 
1.6.0.2

