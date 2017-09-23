From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next] liquidio: pass date and time info to NIC firmware
Date: Fri, 22 Sep 2017 17:35:18 -0700
Message-ID: <20170923003518.GA1583@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        manish.awasthi@cavium.com, veerasenareddy.burru@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0067.outbound.protection.outlook.com ([104.47.37.67]:12638
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751845AbdIWAfX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 22 Sep 2017 20:35:23 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veerasenareddy Burru <veerasenareddy.burru@cavium.com>

Signed-off-by: Veerasenareddy Burru <veerasenareddy.burru@cavium.com>
Signed-off-by: Manish Awasthi <manish.awasthi@cavium.com>
Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
---
 .../net/ethernet/cavium/liquidio/octeon_console.c  | 28 +++++++++++++++++++---
 1 file changed, 25 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_console.c b/drivers/net/ethernet/cavium/liquidio/octeon_console.c
index ec3dd69..eda799b 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_console.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_console.c
@@ -803,15 +803,19 @@ static int octeon_console_read(struct octeon_device *oct, u32 console_num,
 }
 
 #define FBUF_SIZE	(4 * 1024 * 1024)
+#define MAX_DATE_SIZE    30
 
 int octeon_download_firmware(struct octeon_device *oct, const u8 *data,
 			     size_t size)
 {
-	int ret = 0;
+	struct octeon_firmware_file_header *h;
+	char date[MAX_DATE_SIZE];
+	struct timeval time;
 	u32 crc32_result;
+	struct tm tm_val;
 	u64 load_addr;
 	u32 image_len;
-	struct octeon_firmware_file_header *h;
+	int ret = 0;
 	u32 i, rem;
 
 	if (size < sizeof(struct octeon_firmware_file_header)) {
@@ -890,11 +894,29 @@ int octeon_download_firmware(struct octeon_device *oct, const u8 *data,
 			load_addr += size;
 		}
 	}
+
+	/* Get time of the day */
+	do_gettimeofday(&time);
+	time_to_tm(time.tv_sec, (-sys_tz.tz_minuteswest) * 60,  &tm_val);
+	ret = snprintf(date, MAX_DATE_SIZE,
+		       " date=%04ld.%02d.%02d-%02d:%02d:%02d",
+		       tm_val.tm_year + 1900, tm_val.tm_mon + 1, tm_val.tm_mday,
+		       tm_val.tm_hour, tm_val.tm_min, tm_val.tm_sec);
+	if ((sizeof(h->bootcmd) - strnlen(h->bootcmd, sizeof(h->bootcmd))) <
+		ret) {
+		dev_err(&oct->pci_dev->dev, "Boot command buffer too small\n");
+		return -EINVAL;
+	}
+	strncat(h->bootcmd, date,
+		sizeof(h->bootcmd) - strnlen(h->bootcmd, sizeof(h->bootcmd)));
+
 	dev_info(&oct->pci_dev->dev, "Writing boot command: %s\n",
 		 h->bootcmd);
 
 	/* Invoke the bootcmd */
 	ret = octeon_console_send_cmd(oct, h->bootcmd, 50);
+	if (ret)
+		dev_info(&oct->pci_dev->dev, "Boot command send failed\n");
 
-	return 0;
+	return ret;
 }
