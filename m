From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCH 2/2] iwlegacy: convert hex_dump_to_buffer() to %*ph
Date: Thu, 16 Jul 2015 15:42:15 +0300
Message-ID: <1437050535-22858-2-git-send-email-andriy.shevchenko@linux.intel.com>
References: <1437050535-22858-1-git-send-email-andriy.shevchenko@linux.intel.com>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	Johannes Berg <johannes.berg@intel.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	Stanislaw Gruszka <sgruszka@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:59417 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753493AbbGPMmT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jul 2015 08:42:19 -0400
In-Reply-To: <1437050535-22858-1-git-send-email-andriy.shevchenko@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no need to use hex_dump_to_buffer() in the cases like this:

	hexdump_to_buffer(buf, len, 16, 1, outbuf, outlen, false);	/* len <= 16 */
	sprintf("%s\n", outbuf);

since it maybe easily converted to simple:

	sprintf("%*ph\n", len, buf);

Note: it seems in the case the output is groupped by 2 bytes and looks like a
typo. Thus, patch changes that to plain byte stream.

Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
---
 drivers/net/wireless/iwlegacy/3945-mac.c | 2 +-
 drivers/net/wireless/iwlegacy/debug.c    | 8 ++------
 2 files changed, 3 insertions(+), 7 deletions(-)

diff --git a/drivers/net/wireless/iwlegacy/3945-mac.c b/drivers/net/wireless/iwlegacy/3945-mac.c
index 7f4cb69..af1b3e6 100644
--- a/drivers/net/wireless/iwlegacy/3945-mac.c
+++ b/drivers/net/wireless/iwlegacy/3945-mac.c
@@ -3259,7 +3259,7 @@ il3945_show_measurement(struct device *d, struct device_attribute *attr,
 
 	while (size && PAGE_SIZE - len) {
 		hex_dump_to_buffer(data + ofs, size, 16, 1, buf + len,
-				   PAGE_SIZE - len, 1);
+				   PAGE_SIZE - len, true);
 		len = strlen(buf);
 		if (PAGE_SIZE - len)
 			buf[len++] = '\n';
diff --git a/drivers/net/wireless/iwlegacy/debug.c b/drivers/net/wireless/iwlegacy/debug.c
index 3440101..908b9f4 100644
--- a/drivers/net/wireless/iwlegacy/debug.c
+++ b/drivers/net/wireless/iwlegacy/debug.c
@@ -515,12 +515,8 @@ il_dbgfs_nvm_read(struct file *file, char __user *user_buf, size_t count,
 	    scnprintf(buf + pos, buf_size - pos, "EEPROM " "version: 0x%x\n",
 		      eeprom_ver);
 	for (ofs = 0; ofs < eeprom_len; ofs += 16) {
-		pos += scnprintf(buf + pos, buf_size - pos, "0x%.4x ", ofs);
-		hex_dump_to_buffer(ptr + ofs, 16, 16, 2, buf + pos,
-				   buf_size - pos, 0);
-		pos += strlen(buf + pos);
-		if (buf_size - pos > 0)
-			buf[pos++] = '\n';
+		pos += scnprintf(buf + pos, buf_size - pos, "0x%.4x %16ph\n",
+				 ofs, ptr + ofs);
 	}
 
 	ret = simple_read_from_buffer(user_buf, count, ppos, buf, pos);
-- 
2.1.4
