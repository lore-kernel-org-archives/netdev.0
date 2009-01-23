From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 01/21] [next] qlge: Change to device ID 8000 and corresponding flash access.
Date: Fri, 23 Jan 2009 07:16:19 -0800
Message-ID: <1232723799-8620-1-git-send-email-ron.mercer@qlogic.com>
References: <20090123151513.GA8526@linux-ox1b.qlogic.org>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:48587 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754153AbZAWPRs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2009 10:17:48 -0500
In-Reply-To: <20090123151513.GA8526@linux-ox1b.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge.h      |   36 ++++++++++++++++++++++++++-------
 drivers/net/qlge/qlge_main.c |   45 ++++++++++++++++++++++++++++++++++++-----
 2 files changed, 67 insertions(+), 14 deletions(-)

diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
index c1dadad..02c7812 100644
--- a/drivers/net/qlge/qlge.h
+++ b/drivers/net/qlge/qlge.h
@@ -28,7 +28,7 @@
        } while (0)
 
 #define QLGE_VENDOR_ID    0x1077
-#define QLGE_DEVICE_ID    0x8012
+#define QLGE_DEVICE_ID   0x8000
 
 #define MAX_CPUS 8
 #define MAX_TX_RINGS MAX_CPUS
@@ -785,17 +785,37 @@ struct mbox_params {
 	int out_count;
 };
 
+
+#define FUNC0_FLASH_OFFSET 0x140200
+#define FUNC1_FLASH_OFFSET 0x140600
+
+/* Flash related data structures. */
 struct flash_params {
-	u8 dev_id_str[4];
-	u16 size;
-	u16 csum;
-	u16 ver;
-	u16 sub_dev_id;
+	u8 dev_id_str[4];	/* "8000" */
+	__le16 ver;
+	__le16 size;
+	__le16 csum;
+	__le16 reserved0;
+	__le16 total_size;
+	__le16 entry_count;
+	u8 data_type0;
+	u8 data_size0;
 	u8 mac_addr[6];
-	u16 res;
+	u8 data_type1;
+	u8 data_size1;
+	u8 mac_addr1[6];
+	u8 data_type2;
+	u8 data_size2;
+	__le16 vlan_id;
+	u8 data_type3;
+	u8 data_size3;
+	__le16 last;
+	u8 reserved1[464];
+	__le16	subsys_ven_id;
+	__le16	subsys_dev_id;
+	u8 reserved2[4];
 };
 
-
 /*
  * doorbell space for the rx ring context
  */
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 16eb9dd..a530f5b 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -641,7 +641,30 @@ static void ql_enable_all_completion_interrupts(struct ql_adapter *qdev)
 
 }
 
-static int ql_read_flash_word(struct ql_adapter *qdev, int offset, u32 *data)
+static int ql_validate_flash(struct ql_adapter *qdev)
+{
+	int status, i, size;
+	u16 csum = 0;
+	__le16 *flash = (__le16 *)&qdev->flash;
+
+	status = strncmp(qdev->flash.dev_id_str, "8000", 4);
+	if (status) {
+		QPRINTK(qdev, IFUP, ERR, "Invalid flash signature %s.\n",
+			qdev->flash.dev_id_str);
+		return	status;
+	}
+
+	size = sizeof(struct flash_params) / sizeof(u16);
+	for (i = 0; i < size; i++)
+		csum += le16_to_cpu(*flash++);
+
+	if (csum)
+		QPRINTK(qdev, IFUP, ERR, "Invalid flash checksum.\n");
+
+	return csum;
+}
+
+static int ql_read_flash_word(struct ql_adapter *qdev, int offset, __le32 *data)
 {
 	int status = 0;
 	/* wait for reg to come ready */
@@ -657,28 +680,38 @@ static int ql_read_flash_word(struct ql_adapter *qdev, int offset, u32 *data)
 	if (status)
 		goto exit;
 	/* get the data */
-	*data = ql_read32(qdev, FLASH_DATA);
+	*data = cpu_to_le32(ql_read32(qdev, FLASH_DATA));
 exit:
 	return status;
 }
 
 static int ql_get_flash_params(struct ql_adapter *qdev)
 {
-	int i;
+	u32 i;
 	int status;
-	u32 *p = (u32 *)&qdev->flash;
+	__le32 *p = (__le32 *)&qdev->flash;
+	u32 offset;
+
+	/* Get flash offset for function and adjust
+	 * for dword access.
+	 */
+	if (!qdev->func)
+		offset = FUNC0_FLASH_OFFSET / sizeof(u32);
+	else
+		offset = FUNC1_FLASH_OFFSET / sizeof(u32);
 
 	if (ql_sem_spinlock(qdev, SEM_FLASH_MASK))
 		return -ETIMEDOUT;
 
 	for (i = 0; i < sizeof(qdev->flash) / sizeof(u32); i++, p++) {
-		status = ql_read_flash_word(qdev, i, p);
+		status = ql_read_flash_word(qdev, i+offset, p);
 		if (status) {
 			QPRINTK(qdev, IFUP, ERR, "Error reading flash.\n");
 			goto exit;
 		}
-
 	}
+
+	status = ql_validate_flash(qdev);
 exit:
 	ql_sem_unlock(qdev, SEM_FLASH_MASK);
 	return status;
-- 
1.6.0.2

