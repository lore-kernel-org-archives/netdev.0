From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH 32/50] wireless: ath: carl9170: spin_lock in complete() cleanup
Date: Thu, 11 Jul 2013 17:05:55 +0800
Message-ID: <1373533573-12272-33-git-send-email-ming.lei@canonical.com>
References: <1373533573-12272-1-git-send-email-ming.lei@canonical.com>
Cc: linux-usb@vger.kernel.org, Oliver Neukum <oliver@neukum.org>,
	Alan Stern <stern@rowland.harvard.edu>,
	linux-input@vger.kernel.org, linux-bluetooth@vger.kernel.org,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-media@vger.kernel.org, alsa-devel@alsa-project.org,
	Ming Lei <ming.lei@canonical.com>,
	Christian Lamparter <chunkeey@googlemail.com>,
	"John W. Linville" <linville@tuxdriver.com>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:42834 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932278Ab3GKJKy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 05:10:54 -0400
In-Reply-To: <1373533573-12272-1-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Complete() will be run with interrupt enabled, so change to
spin_lock_irqsave().

Cc: Christian Lamparter <chunkeey@googlemail.com>
Cc: "John W. Linville" <linville@tuxdriver.com>
Cc: linux-wireless@vger.kernel.org
Cc: netdev@vger.kernel.org
Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
 drivers/net/wireless/ath/carl9170/rx.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/ath/carl9170/rx.c b/drivers/net/wireless/ath/carl9170/rx.c
index 4684dd9..61f62a6 100644
--- a/drivers/net/wireless/ath/carl9170/rx.c
+++ b/drivers/net/wireless/ath/carl9170/rx.c
@@ -129,6 +129,7 @@ static int carl9170_check_sequence(struct ar9170 *ar, unsigned int seq)
 
 static void carl9170_cmd_callback(struct ar9170 *ar, u32 len, void *buffer)
 {
+	unsigned long flags;
 	/*
 	 * Some commands may have a variable response length
 	 * and we cannot predict the correct length in advance.
@@ -148,7 +149,7 @@ static void carl9170_cmd_callback(struct ar9170 *ar, u32 len, void *buffer)
 		carl9170_restart(ar, CARL9170_RR_INVALID_RSP);
 	}
 
-	spin_lock(&ar->cmd_lock);
+	spin_lock_irqsave(&ar->cmd_lock, flags);
 	if (ar->readbuf) {
 		if (len >= 4)
 			memcpy(ar->readbuf, buffer + 4, len - 4);
@@ -156,7 +157,7 @@ static void carl9170_cmd_callback(struct ar9170 *ar, u32 len, void *buffer)
 		ar->readbuf = NULL;
 	}
 	complete(&ar->cmd_wait);
-	spin_unlock(&ar->cmd_lock);
+	spin_unlock_irqrestore(&ar->cmd_lock, flags);
 }
 
 void carl9170_handle_command_response(struct ar9170 *ar, void *buf, u32 len)
-- 
1.7.9.5
