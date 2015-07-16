From: Andy Shevchenko <andriy.shevchenko-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: [PATCH 1/2] iwlwifi: convert hex_dump_to_buffer() to %*ph
Date: Thu, 16 Jul 2015 15:42:14 +0300
Message-ID: <1437050535-22858-1-git-send-email-andriy.shevchenko@linux.intel.com>
Cc: Andy Shevchenko <andriy.shevchenko-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Stanislaw Gruszka <sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

There is no need to use hex_dump_to_buffer() in the cases like this:

	hexdump_to_buffer(buf, len, 16, 1, outbuf, outlen, false);	/* len <= 16 */
	sprintf("%s\n", outbuf);

since it maybe easily converted to simple:

	sprintf("%*ph\n", len, buf);

Note: it seems in one case the output is groupped by 2 bytes and looks like a
typo. Thus, patch changes that to plain byte stream.

Signed-off-by: Andy Shevchenko <andriy.shevchenko-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
---
 drivers/net/wireless/iwlwifi/dvm/debugfs.c | 8 ++------
 drivers/net/wireless/iwlwifi/mvm/debugfs.c | 7 +------
 2 files changed, 3 insertions(+), 12 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/dvm/debugfs.c b/drivers/net/wireless/iwlwifi/dvm/debugfs.c
index 0ffb6ff..b15e44f 100644
--- a/drivers/net/wireless/iwlwifi/dvm/debugfs.c
+++ b/drivers/net/wireless/iwlwifi/dvm/debugfs.c
@@ -310,12 +310,8 @@ static ssize_t iwl_dbgfs_nvm_read(struct file *file,
 	pos += scnprintf(buf + pos, buf_size - pos,
 			 "NVM version: 0x%x\n", nvm_ver);
 	for (ofs = 0 ; ofs < eeprom_len ; ofs += 16) {
-		pos += scnprintf(buf + pos, buf_size - pos, "0x%.4x ", ofs);
-		hex_dump_to_buffer(ptr + ofs, 16 , 16, 2, buf + pos,
-				   buf_size - pos, 0);
-		pos += strlen(buf + pos);
-		if (buf_size - pos > 0)
-			buf[pos++] = '\n';
+		pos += scnprintf(buf + pos, buf_size - pos, "0x%.4x %16ph\n",
+				 ofs, ptr + ofs);
 	}
 
 	ret = simple_read_from_buffer(user_buf, count, ppos, buf, pos);
diff --git a/drivers/net/wireless/iwlwifi/mvm/debugfs.c b/drivers/net/wireless/iwlwifi/mvm/debugfs.c
index ffb4b5c..98abd31 100644
--- a/drivers/net/wireless/iwlwifi/mvm/debugfs.c
+++ b/drivers/net/wireless/iwlwifi/mvm/debugfs.c
@@ -1200,12 +1200,7 @@ static ssize_t iwl_dbgfs_d3_sram_read(struct file *file, char __user *user_buf,
 	if (ptr) {
 		for (ofs = 0; ofs < len; ofs += 16) {
 			pos += scnprintf(buf + pos, bufsz - pos,
-					 "0x%.4x ", ofs);
-			hex_dump_to_buffer(ptr + ofs, 16, 16, 1, buf + pos,
-					   bufsz - pos, false);
-			pos += strlen(buf + pos);
-			if (bufsz - pos > 0)
-				buf[pos++] = '\n';
+					 "0x%.4x %16ph\n", ofs, ptr + ofs);
 		}
 	} else {
 		pos += scnprintf(buf + pos, bufsz - pos,
-- 
2.1.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
