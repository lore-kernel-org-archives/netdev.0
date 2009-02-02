From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 1/3] qlge: bugfix: Fix endian issue when reading flash.
Date: Mon,  2 Feb 2009 13:41:52 -0800
Message-ID: <1233610914-7448-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:12624 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754966AbZBBVnu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2009 16:43:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge.h      |   10 +++++-----
 drivers/net/qlge/qlge_main.c |   11 +++++++----
 2 files changed, 12 insertions(+), 9 deletions(-)

diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
index c1dadad..e6fdce9 100644
--- a/drivers/net/qlge/qlge.h
+++ b/drivers/net/qlge/qlge.h
@@ -787,12 +787,12 @@ struct mbox_params {
 
 struct flash_params {
 	u8 dev_id_str[4];
-	u16 size;
-	u16 csum;
-	u16 ver;
-	u16 sub_dev_id;
+	__le16 size;
+	__le16 csum;
+	__le16 ver;
+	__le16 sub_dev_id;
 	u8 mac_addr[6];
-	u16 res;
+	__le16 res;
 };
 
 
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 45421c8..17d02eb 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -641,7 +641,7 @@ static void ql_enable_all_completion_interrupts(struct ql_adapter *qdev)
 
 }
 
-static int ql_read_flash_word(struct ql_adapter *qdev, int offset, u32 *data)
+static int ql_read_flash_word(struct ql_adapter *qdev, int offset, __le32 *data)
 {
 	int status = 0;
 	/* wait for reg to come ready */
@@ -656,8 +656,11 @@ static int ql_read_flash_word(struct ql_adapter *qdev, int offset, u32 *data)
 			FLASH_ADDR, FLASH_ADDR_RDY, FLASH_ADDR_ERR);
 	if (status)
 		goto exit;
-	/* get the data */
-	*data = ql_read32(qdev, FLASH_DATA);
+	 /* This data is stored on flash as an array of
+	 * __le32.  Since ql_read32() returns cpu endian
+	 * we need to swap it back.
+	 */
+	*data = cpu_to_le32(ql_read32(qdev, FLASH_DATA));
 exit:
 	return status;
 }
@@ -666,7 +669,7 @@ static int ql_get_flash_params(struct ql_adapter *qdev)
 {
 	int i;
 	int status;
-	u32 *p = (u32 *)&qdev->flash;
+	__le32 *p = (__le32 *)&qdev->flash;
 
 	if (ql_sem_spinlock(qdev, SEM_FLASH_MASK))
 		return -ETIMEDOUT;
-- 
1.6.0.2

