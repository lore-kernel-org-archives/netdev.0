From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Subject: [PATCH 7/9 net-next-2.6] qlcnic: Use flt method to determine flash
 fw region
Date: Wed, 30 Mar 2011 13:23:34 -0700
Message-ID: <alpine.OSX.2.00.1103301315200.31005@macintosh-2.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: Dept_NX_Linux_NIC_Driver <Dept_NX_Linux_NIC_Driver@qlogic.com>
To: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe001.messaging.microsoft.com ([216.32.180.11]:47033
	"EHLO VA3EHSOBE001.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932855Ab1C3UZB convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Mar 2011 16:25:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sritej Velaga <sritej.velaga@qlogic.com>

Use flash layout table to get flash fw starting address and its size. If that
fails, use legacy method.

Signed-off-by: Sritej Velaga <sritej.velaga@qlogic.com>
Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h      |    3 ++-
 drivers/net/qlcnic/qlcnic_init.c |   17 ++++++++++++++---
 2 files changed, 16 insertions(+), 4 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index 9d2e630..d9dd2c4 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -292,6 +292,7 @@ struct uni_data_desc{
 /* Flash Defines and Structures */
 #define QLCNIC_FLT_LOCATION    0x3F1000
 #define QLCNIC_FW_IMAGE_REGION 0x74
+#define QLCNIC_BOOTLD_REGION    0X72
 struct qlcnic_flt_header {
        u16 version;
        u16 len;
@@ -306,7 +307,7 @@ struct qlcnic_flt_entry {
        u8 reserved1;
        u32 size;
        u32 start_addr;
-       u32 end_add;
+       u32 end_addr;
 };

 /* Magic number to let user know flash is programmed */
diff --git a/drivers/net/qlcnic/qlcnic_init.c b/drivers/net/qlcnic/qlcnic_init.c
index 74ec96d..4ec0eeb 100644
--- a/drivers/net/qlcnic/qlcnic_init.c
+++ b/drivers/net/qlcnic/qlcnic_init.c
@@ -1130,9 +1130,20 @@ qlcnic_load_firmware(struct qlcnic_adapter *adapter)
        } else {
                u64 data;
                u32 hi, lo;
-
-               size = (QLCNIC_IMAGE_START - QLCNIC_BOOTLD_START) / 8;
-               flashaddr = QLCNIC_BOOTLD_START;
+               int ret;
+               struct qlcnic_flt_entry bootld_entry;
+
+               ret = qlcnic_get_flt_entry(adapter, QLCNIC_BOOTLD_REGION,
+                                       &bootld_entry);
+               if (!ret) {
+                       size = bootld_entry.size / 8;
+                       flashaddr = bootld_entry.start_addr;
+               } else {
+                       size = (QLCNIC_IMAGE_START - QLCNIC_BOOTLD_START) / 8;
+                       flashaddr = QLCNIC_BOOTLD_START;
+                       dev_info(&pdev->dev,
+                               "using legacy method to get flash fw region");
+               }

                for (i = 0; i < size; i++) {
                        if (qlcnic_rom_fast_read(adapter,
--
1.6.5.2


This message and any attached documents contain information from QLogic Corporation or its wholly-owned subsidiaries that may be confidential. If you are not the intended recipient, you may not read, copy, distribute, or use this information. If you have received this transmission in error, please notify the sender immediately by reply e-mail and then delete this message.

