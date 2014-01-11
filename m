From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH 2/3] b43: Fix oops if firmware is not available
Date: Sat, 11 Jan 2014 13:48:33 -0600
Message-ID: <1389469714-13040-3-git-send-email-Larry.Finger@lwfinger.net>
References: <1389469714-13040-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Stable <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1389469714-13040-1-git-send-email-Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On openSUSE systems, the script that installs the firmware for b43 also
unloads and reloads the driver. When the firmware was not previously
available, the driver has stalled at a wait_for_completion(). When the
unload routine releases that hold, the driver encounters structures
that have already been deleted and generates a fatal condition. When
the user does a manual restart, the file system cleanup frequently
results in the firmware files being deleted and the user is never able
to install the firmware. The fix is to change the wait_for_completion()
with a wait_for_completion_timeout() with a 60 second wait period.

There is a potential race condition; however, the chances that less
than a minute has elapsed between the initial driver load and a
subsequent unload is very unlikely.

This patch also fixes a typo in a comment.

Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Cc: Stable <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
---
 drivers/net/wireless/b43/main.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/b43/main.c b/drivers/net/wireless/b43/main.c
index 86b2030..5ce9ecb 100644
--- a/drivers/net/wireless/b43/main.c
+++ b/drivers/net/wireless/b43/main.c
@@ -2150,12 +2150,13 @@ int b43_do_request_fw(struct b43_request_fw_context *ctx,
 			pr_err("Unable to load firmware\n");
 			return err;
 		}
-		/* stall here until fw ready */
-		wait_for_completion(&ctx->fw_load_complete);
+		/* stall here until fw ready or 60 sec elapses */
+		wait_for_completion_timeout(&ctx->fw_load_complete,
+					    msecs_to_jiffies(60000));
 		if (ctx->blob)
 			goto fw_ready;
 	/* On some ARM systems, the async request will fail, but the next sync
-	 * request works. For this reason, we dall through here
+	 * request works. For this reason, we fall through here
 	 */
 	}
 	err = request_firmware(&ctx->blob, ctx->fwname,
-- 
1.8.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
