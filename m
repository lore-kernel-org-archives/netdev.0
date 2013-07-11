From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH 42/50] media: usb: tlg2300: spin_lock in complete() cleanup
Date: Thu, 11 Jul 2013 17:06:05 +0800
Message-ID: <1373533573-12272-43-git-send-email-ming.lei@canonical.com>
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
Received: from mail-pb0-f44.google.com ([209.85.160.44]:47334 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932451Ab3GKJMN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 05:12:13 -0400
In-Reply-To: <1373533573-12272-1-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Complete() will be run with interrupt enabled, so disable local
interrupt before holding a global lock which is held without
irqsave.

Cc: Mauro Carvalho Chehab <mchehab@redhat.com>
Cc: linux-media@vger.kernel.org
Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
 drivers/media/usb/tlg2300/pd-alsa.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/media/usb/tlg2300/pd-alsa.c b/drivers/media/usb/tlg2300/pd-alsa.c
index 3f3e141..cbccc96 100644
--- a/drivers/media/usb/tlg2300/pd-alsa.c
+++ b/drivers/media/usb/tlg2300/pd-alsa.c
@@ -141,6 +141,7 @@ static inline void handle_audio_data(struct urb *urb, int *period_elapsed)
 	int len		= urb->actual_length / stride;
 	unsigned char *cp	= urb->transfer_buffer;
 	unsigned int oldptr	= pa->rcv_position;
+	unsigned long flags;
 
 	if (urb->actual_length == AUDIO_BUF_SIZE - 4)
 		len -= (AUDIO_TRAILER_SIZE / stride);
@@ -156,6 +157,7 @@ static inline void handle_audio_data(struct urb *urb, int *period_elapsed)
 		memcpy(runtime->dma_area + oldptr * stride, cp, len * stride);
 
 	/* update the statas */
+	local_irq_save(flags);
 	snd_pcm_stream_lock(pa->capture_pcm_substream);
 	pa->rcv_position	+= len;
 	if (pa->rcv_position >= runtime->buffer_size)
@@ -167,6 +169,7 @@ static inline void handle_audio_data(struct urb *urb, int *period_elapsed)
 		*period_elapsed = 1;
 	}
 	snd_pcm_stream_unlock(pa->capture_pcm_substream);
+	local_irq_restore(flags);
 }
 
 static void complete_handler_audio(struct urb *urb)
-- 
1.7.9.5
