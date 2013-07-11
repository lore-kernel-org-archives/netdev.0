From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH 44/50] sound: usb: caiaq: spin_lock in complete() cleanup
Date: Thu, 11 Jul 2013 17:06:07 +0800
Message-ID: <1373533573-12272-45-git-send-email-ming.lei@canonical.com>
References: <1373533573-12272-1-git-send-email-ming.lei@canonical.com>
Cc: linux-usb@vger.kernel.org, Oliver Neukum <oliver@neukum.org>,
	Alan Stern <stern@rowland.harvard.edu>,
	linux-input@vger.kernel.org, linux-bluetooth@vger.kernel.org,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-media@vger.kernel.org, alsa-devel@alsa-project.org,
	Ming Lei <ming.lei@canonical.com>,
	Daniel Mack <zonque@gmail.com>,
	Jaroslav Kysela <perex@perex.cz>, Takashi Iwai <tiwai@suse.de>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:42452 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932535Ab3GKJMa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 05:12:30 -0400
In-Reply-To: <1373533573-12272-1-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Complete() will be run with interrupt enabled, so change to
spin_lock_irqsave().

Cc: Daniel Mack <zonque@gmail.com>
Cc: Jaroslav Kysela <perex@perex.cz>
Cc: Takashi Iwai <tiwai@suse.de>
Cc: alsa-devel@alsa-project.org
Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
 sound/usb/caiaq/audio.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/sound/usb/caiaq/audio.c b/sound/usb/caiaq/audio.c
index 7103b09..e5675ab 100644
--- a/sound/usb/caiaq/audio.c
+++ b/sound/usb/caiaq/audio.c
@@ -672,10 +672,11 @@ static void read_completed(struct urb *urb)
 		offset += len;
 
 		if (len > 0) {
-			spin_lock(&cdev->spinlock);
+			unsigned long flags;
+			spin_lock_irqsave(&cdev->spinlock, flags);
 			fill_out_urb(cdev, out, &out->iso_frame_desc[outframe]);
 			read_in_urb(cdev, urb, &urb->iso_frame_desc[frame]);
-			spin_unlock(&cdev->spinlock);
+			spin_unlock_irqrestore(&cdev->spinlock, flags);
 			check_for_elapsed_periods(cdev, cdev->sub_playback);
 			check_for_elapsed_periods(cdev, cdev->sub_capture);
 			send_it = 1;
-- 
1.7.9.5
