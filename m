From: Brent Taylor <motobud-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] ath6kl: Use vmalloc to allocate ar->fw for api1 method
Date: Mon, 30 Nov 2015 23:41:10 -0600
Message-ID: <1448948470-31111-1-git-send-email-motobud@gmail.com>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ath6kl-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	Brent Taylor <motobud-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Since commit 8437754c83351d6213c1a47ff029c1126d6042a7, ar->fw is expected to be pointing to memory allocated by vmalloc.  If the api1 method (via ath6kl_fetch_fw_api1) is used to allocate memory for ar->fw, then kmemdup is used.  This patch checks if the firmware being loaded is the 'fw' image, then use vmalloc, otherwise use kmalloc.

Signed-off-by: Brent Taylor <motobud-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/wireless/ath/ath6kl/init.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ath/ath6kl/init.c b/drivers/net/wireless/ath/ath6kl/init.c
index 6ae0734..4f2b124d 100644
--- a/drivers/net/wireless/ath/ath6kl/init.c
+++ b/drivers/net/wireless/ath/ath6kl/init.c
@@ -673,10 +673,15 @@ static int ath6kl_get_fw(struct ath6kl *ar, const char *filename,
 		return ret;
 
 	*fw_len = fw_entry->size;
-	*fw = kmemdup(fw_entry->data, fw_entry->size, GFP_KERNEL);
+   if (&ar->fw == fw)
+		*fw = vmalloc(fw_entry->size);
+   else
+		*fw = kmalloc(fw_entry->size, GFP_KERNEL);
 
 	if (*fw == NULL)
 		ret = -ENOMEM;
+	else
+		memcpy(*fw, fw_entry->data, fw_entry->size);
 
 	release_firmware(fw_entry);
 
-- 
2.6.3

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
