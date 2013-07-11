From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH 43/50] sound: usb: midi: spin_lock in complete() cleanup
Date: Thu, 11 Jul 2013 17:06:06 +0800
Message-ID: <1373533573-12272-44-git-send-email-ming.lei@canonical.com>
References: <1373533573-12272-1-git-send-email-ming.lei@canonical.com>
Cc: linux-usb@vger.kernel.org, Oliver Neukum <oliver@neukum.org>,
	Alan Stern <stern@rowland.harvard.edu>,
	linux-input@vger.kernel.org, linux-bluetooth@vger.kernel.org,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-media@vger.kernel.org, alsa-devel@alsa-project.org,
	Ming Lei <ming.lei@canonical.com>,
	Jaroslav Kysela <perex@perex.cz>, Takashi Iwai <tiwai@suse.de>,
	Clemens Ladisch <clemens@ladisch.de>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:42314 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932451Ab3GKJMV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 05:12:21 -0400
In-Reply-To: <1373533573-12272-1-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Complete() will be run with interrupt enabled, so change to
spin_lock_irqsave().

Cc: Jaroslav Kysela <perex@perex.cz>
Cc: Takashi Iwai <tiwai@suse.de>
Cc: Clemens Ladisch <clemens@ladisch.de>
Cc: alsa-devel@alsa-project.org
Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
 sound/usb/midi.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/sound/usb/midi.c b/sound/usb/midi.c
index b901f46..86af276 100644
--- a/sound/usb/midi.c
+++ b/sound/usb/midi.c
@@ -279,15 +279,16 @@ static void snd_usbmidi_out_urb_complete(struct urb* urb)
 	struct out_urb_context *context = urb->context;
 	struct snd_usb_midi_out_endpoint* ep = context->ep;
 	unsigned int urb_index;
+	unsigned long flags;
 
-	spin_lock(&ep->buffer_lock);
+	spin_lock_irqsave(&ep->buffer_lock, flags);
 	urb_index = context - ep->urbs;
 	ep->active_urbs &= ~(1 << urb_index);
 	if (unlikely(ep->drain_urbs)) {
 		ep->drain_urbs &= ~(1 << urb_index);
 		wake_up(&ep->drain_wait);
 	}
-	spin_unlock(&ep->buffer_lock);
+	spin_unlock_irqrestore(&ep->buffer_lock, flags);
 	if (urb->status < 0) {
 		int err = snd_usbmidi_urb_error(urb->status);
 		if (err < 0) {
-- 
1.7.9.5
