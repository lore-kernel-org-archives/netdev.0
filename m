From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH 01/50] USB: devio: spin_lock in complete() cleanup
Date: Thu, 11 Jul 2013 17:05:24 +0800
Message-ID: <1373533573-12272-2-git-send-email-ming.lei@canonical.com>
References: <1373533573-12272-1-git-send-email-ming.lei@canonical.com>
Cc: linux-usb@vger.kernel.org, Oliver Neukum <oliver@neukum.org>,
	Alan Stern <stern@rowland.harvard.edu>,
	linux-input@vger.kernel.org, linux-bluetooth@vger.kernel.org,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-media@vger.kernel.org, alsa-devel@alsa-project.org,
	Ming Lei <ming.lei@canonical.com>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:41678 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755838Ab3GKJGo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 05:06:44 -0400
In-Reply-To: <1373533573-12272-1-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Complete() will be run with interrupt enabled, so change to
spin_lock_irqsave().

Cc: Alan Stern <stern@rowland.harvard.edu>
Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
 drivers/usb/core/devio.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/usb/core/devio.c b/drivers/usb/core/devio.c
index 0598650..21e6ec6 100644
--- a/drivers/usb/core/devio.c
+++ b/drivers/usb/core/devio.c
@@ -495,8 +495,9 @@ static void async_completed(struct urb *urb)
 	u32 secid = 0;
 	const struct cred *cred = NULL;
 	int signr;
+	unsigned long flags;
 
-	spin_lock(&ps->lock);
+	spin_lock_irqsave(&ps->lock, flags);
 	list_move_tail(&as->asynclist, &ps->async_completed);
 	as->status = urb->status;
 	signr = as->signr;
@@ -518,7 +519,7 @@ static void async_completed(struct urb *urb)
 	if (as->status < 0 && as->bulk_addr && as->status != -ECONNRESET &&
 			as->status != -ENOENT)
 		cancel_bulk_urbs(ps, as->bulk_addr);
-	spin_unlock(&ps->lock);
+	spin_unlock_irqrestore(&ps->lock, flags);
 
 	if (signr) {
 		kill_pid_info_as_cred(sinfo.si_signo, &sinfo, pid, cred, secid);
-- 
1.7.9.5
