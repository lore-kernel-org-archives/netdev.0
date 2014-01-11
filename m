From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 3/3] b43legacy: Fix oops if firmware is not available
Date: Sat, 11 Jan 2014 13:48:34 -0600
Message-ID: <1389469714-13040-4-git-send-email-Larry.Finger@lwfinger.net>
References: <1389469714-13040-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org, Stable <stable@vger.kernel.org>
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f49.google.com ([209.85.219.49]:51340 "EHLO
	mail-oa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754602AbaAKTsq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jan 2014 14:48:46 -0500
In-Reply-To: <1389469714-13040-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On openSUSE systems, the script that installs the firmware for b43legacy
also unloads and reloads the driver. When the firmware was not previously
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

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Stable <stable@vger.kernel.org>
---
 drivers/net/wireless/b43legacy/main.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/b43legacy/main.c b/drivers/net/wireless/b43legacy/main.c
index 5726688..bd5f142 100644
--- a/drivers/net/wireless/b43legacy/main.c
+++ b/drivers/net/wireless/b43legacy/main.c
@@ -1546,8 +1546,9 @@ static int do_request_fw(struct b43legacy_wldev *dev,
 			b43legacyerr(dev->wl, "Unable to load firmware\n");
 			return err;
 		}
-		/* stall here until fw ready */
-		wait_for_completion(&dev->fw_load_complete);
+		/* stall here until fw ready or 60 sec elapses */
+		wait_for_completion_timeout(&dev->fw_load_complete,
+					    msecs_to_jiffies(60000));
 		if (!dev->fwp)
 			err = -EINVAL;
 		*fw = dev->fwp;
-- 
1.8.4
