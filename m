From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH 38/50] media: usb: tlg2300: spin_lock in complete() cleanup
Date: Thu, 11 Jul 2013 17:06:01 +0800
Message-ID: <1373533573-12272-39-git-send-email-ming.lei@canonical.com>
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
Received: from mail-pb0-f45.google.com ([209.85.160.45]:61057 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932504Ab3GKJLm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 05:11:42 -0400
In-Reply-To: <1373533573-12272-1-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Complete() will be run with interrupt enabled, so change to
spin_lock_irqsave().

Cc: Mauro Carvalho Chehab <mchehab@redhat.com>
Cc: linux-media@vger.kernel.org
Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
 drivers/media/usb/tlg2300/pd-video.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/media/usb/tlg2300/pd-video.c b/drivers/media/usb/tlg2300/pd-video.c
index 8df668d..4e5bd07 100644
--- a/drivers/media/usb/tlg2300/pd-video.c
+++ b/drivers/media/usb/tlg2300/pd-video.c
@@ -151,11 +151,12 @@ static void init_copy(struct video_data *video, bool index)
 static bool get_frame(struct front_face *front, int *need_init)
 {
 	struct videobuf_buffer *vb = front->curr_frame;
+	unsigned long flags;
 
 	if (vb)
 		return true;
 
-	spin_lock(&front->queue_lock);
+	spin_lock_irqsave(&front->queue_lock, flags);
 	if (!list_empty(&front->active)) {
 		vb = list_entry(front->active.next,
 			       struct videobuf_buffer, queue);
@@ -164,7 +165,7 @@ static bool get_frame(struct front_face *front, int *need_init)
 		front->curr_frame = vb;
 		list_del_init(&vb->queue);
 	}
-	spin_unlock(&front->queue_lock);
+	spin_unlock_irqrestore(&front->queue_lock, flags);
 
 	return !!vb;
 }
-- 
1.7.9.5
