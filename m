From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 7/8] qlge: Add support for using alternate MAC address.
Date: Tue,  9 Jun 2009 08:39:33 -0700
Message-ID: <1244561974-25662-7-git-send-email-ron.mercer@qlogic.com>
References: <1244561974-25662-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:58941 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753228AbZFIPrR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2009 11:47:17 -0400
In-Reply-To: <1244561974-25662-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Extract either manufacturer or Bladecenter Open Fabric
Manager (BOFM) MAC address.  BOFM may indicate an
alternate MAC address.  This patch honors that request
by extracting the MAC address from a different
flash location if a flag is set.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |   17 +++++++++++++++--
 1 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index d5f3628..5055f5b 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -675,6 +675,7 @@ static int ql_get_8000_flash_params(struct ql_adapter *qdev)
 	int status;
 	__le32 *p = (__le32 *)&qdev->flash;
 	u32 offset;
+	u8 mac_addr[6];
 
 	/* Get flash offset for function and adjust
 	 * for dword access.
@@ -705,14 +706,26 @@ static int ql_get_8000_flash_params(struct ql_adapter *qdev)
 		goto exit;
 	}
 
-	if (!is_valid_ether_addr(qdev->flash.flash_params_8000.mac_addr)) {
+	/* Extract either manufacturer or BOFM modified
+	 * MAC address.
+	 */
+	if (qdev->flash.flash_params_8000.data_type1 == 2)
+		memcpy(mac_addr,
+			qdev->flash.flash_params_8000.mac_addr1,
+			qdev->ndev->addr_len);
+	else
+		memcpy(mac_addr,
+			qdev->flash.flash_params_8000.mac_addr,
+			qdev->ndev->addr_len);
+
+	if (!is_valid_ether_addr(mac_addr)) {
 		QPRINTK(qdev, IFUP, ERR, "Invalid MAC address.\n");
 		status = -EINVAL;
 		goto exit;
 	}
 
 	memcpy(qdev->ndev->dev_addr,
-		qdev->flash.flash_params_8000.mac_addr,
+		mac_addr,
 		qdev->ndev->addr_len);
 
 exit:
-- 
1.6.0.2

