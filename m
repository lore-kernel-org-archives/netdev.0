From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH 41/50] media: usb: em28xx: make sure irq disabled before acquiring lock
Date: Thu, 11 Jul 2013 17:06:04 +0800
Message-ID: <1373533573-12272-42-git-send-email-ming.lei@canonical.com>
References: <1373533573-12272-1-git-send-email-ming.lei@canonical.com>
Cc: linux-usb@vger.kernel.org, Oliver Neukum <oliver@neukum.org>,
	Alan Stern <stern@rowland.harvard.edu>,
	linux-input@vger.kernel.org, linux-bluetooth@vger.kernel.org,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-media@vger.kernel.org, alsa-devel@alsa-project.org,
	Ming Lei <ming.lei@canonical.com>,
	Mauro Carvalho Chehab <mchehab@redhat.com>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:52842 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932451Ab3GKJMF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 05:12:05 -0400
In-Reply-To: <1373533573-12272-1-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Complete() will be run with interrupt enabled, so add local_irq_save()
before acquiring the lock without irqsave().

Cc: Mauro Carvalho Chehab <mchehab@redhat.com>
Cc: linux-media@vger.kernel.org
Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
 drivers/media/usb/em28xx/em28xx-audio.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/media/usb/em28xx/em28xx-audio.c b/drivers/media/usb/em28xx/em28xx-audio.c
index 2fdb66e..dca53ec 100644
--- a/drivers/media/usb/em28xx/em28xx-audio.c
+++ b/drivers/media/usb/em28xx/em28xx-audio.c
@@ -113,6 +113,7 @@ static void em28xx_audio_isocirq(struct urb *urb)
 		stride = runtime->frame_bits >> 3;
 
 		for (i = 0; i < urb->number_of_packets; i++) {
+			unsigned long flags;
 			int length =
 			    urb->iso_frame_desc[i].actual_length / stride;
 			cp = (unsigned char *)urb->transfer_buffer +
@@ -134,6 +135,7 @@ static void em28xx_audio_isocirq(struct urb *urb)
 				       length * stride);
 			}
 
+			local_irq_save(flags);
 			snd_pcm_stream_lock(substream);
 
 			dev->adev.hwptr_done_capture += length;
@@ -151,6 +153,7 @@ static void em28xx_audio_isocirq(struct urb *urb)
 			}
 
 			snd_pcm_stream_unlock(substream);
+			local_irq_restore(flags);
 		}
 		if (period_elapsed)
 			snd_pcm_period_elapsed(substream);
-- 
1.7.9.5
