From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 3/4] r8169: support new firmware format.
Date: Fri, 17 Jun 2011 21:31:33 +0200
Message-ID: <20110617193133.GC2287@electric-eye.fr.zoreil.com>
References: <20110617192826.GA2277@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Realtek linux nic maintainers <nic_swsd@realtek.com>,
	Hayes Wang <hayeswang@realtek.com>,
	Ben Hutchings <ben@decadent.org.uk>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:55803 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752339Ab1FQToU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2011 15:44:20 -0400
Content-Disposition: inline
In-Reply-To: <20110617192826.GA2277@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The new firmware format adds versioning as firmware for a specific
chipset appears to be subject to change. Current "legacy" format is
still supported.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/r8169.c |   43 +++++++++++++++++++++++++++++++++++++++++--
 1 files changed, 41 insertions(+), 2 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 452db86..c695c73 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1753,15 +1753,54 @@ static void rtl_writephy_batch(struct rtl8169_private *tp,
 #define PHY_DELAY_MS		0xe0000000
 #define PHY_WRITE_ERI_WORD	0xf0000000
 
+struct fw_info {
+	u32	magic;
+	char	version[RTL_VER_SIZE];
+	__le32	fw_start;
+	__le32	fw_len;
+	u8	chksum;
+} __packed;
+
 #define FW_OPCODE_SIZE	sizeof(typeof(*((struct rtl_fw_phy_action *)0)->code))
 
 static bool rtl_fw_format_ok(struct rtl8169_private *tp, struct rtl_fw *rtl_fw)
 {
 	const struct firmware *fw = rtl_fw->fw;
+	struct fw_info *fw_info = (struct fw_info *)fw->data;
 	struct rtl_fw_phy_action *pa = &rtl_fw->phy_action;
 	bool rc = false;
 
-	if (!(fw->size % FW_OPCODE_SIZE)) {
+	if (fw->size < FW_OPCODE_SIZE)
+		goto out;
+
+	if (!fw_info->magic) {
+		size_t i, size, start;
+		u8 checksum = 0;
+
+		if (fw->size < sizeof(*fw_info))
+			goto out;
+
+		for (i = 0; i < fw->size; i++)
+			checksum += fw->data[i];
+		if (checksum != 0)
+			goto out;
+
+		start = le32_to_cpu(fw_info->fw_start);
+		if (start > fw->size)
+			goto out;
+
+		size = le32_to_cpu(fw_info->fw_len);
+		if (size > (fw->size - start) / FW_OPCODE_SIZE)
+			goto out;
+
+		memcpy(rtl_fw->version, fw_info->version, RTL_VER_SIZE);
+
+		pa->code = (__le32 *)(fw->data + start);
+		pa->size = size;
+	} else {
+		if (fw->size % FW_OPCODE_SIZE)
+			goto out;
+
 		snprintf(rtl_fw->version, RTL_VER_SIZE, "%s",
 			 rtl_lookup_firmware_name(tp));
 
@@ -1771,7 +1810,7 @@ static bool rtl_fw_format_ok(struct rtl8169_private *tp, struct rtl_fw *rtl_fw)
 	rtl_fw->version[RTL_VER_SIZE - 1] = 0;
 
 	rc = true;
-
+out:
 	return rc;
 }
 
-- 
1.7.4.4

