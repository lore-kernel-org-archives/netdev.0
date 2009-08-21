From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH RFC 2/6] gigaset: handle isoc frame errors more gracefully
Date: Fri, 21 Aug 2009 19:21:34 +0200 (CEST)
Message-ID: <20090821-patch-02.tilman@imap.cc>
References: <20090821-patch-00.tilman@imap.cc>
Cc: Hansjoerg Lipp <hjlipp@web.de>
To: i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.pxnet.com ([195.227.45.7]:50971 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932589AbZHURVm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Aug 2009 13:21:42 -0400
In-Reply-To: <20090821-patch-00.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don't drop the remainder of an URB if an isochronous frame has an error.

Impact: error handling improvement
Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/gigaset/bas-gigaset.c |   18 +++++++-----------
 1 files changed, 7 insertions(+), 11 deletions(-)

diff --git a/drivers/isdn/gigaset/bas-gigaset.c b/drivers/isdn/gigaset/bas-gigaset.c
index 781c404..9e7108a 100644
--- a/drivers/isdn/gigaset/bas-gigaset.c
+++ b/drivers/isdn/gigaset/bas-gigaset.c
@@ -1331,28 +1331,24 @@ static void read_iso_tasklet(unsigned long data)
 		rcvbuf = urb->transfer_buffer;
 		totleft = urb->actual_length;
 		for (frame = 0; totleft > 0 && frame < BAS_NUMFRAMES; frame++) {
-			if (unlikely(urb->iso_frame_desc[frame].status)) {
+			numbytes = urb->iso_frame_desc[frame].actual_length;
+			if (unlikely(urb->iso_frame_desc[frame].status))
 				dev_warn(cs->dev,
-					 "isochronous read: frame %d: %s\n",
-					 frame,
+					 "isochronous read: frame %d[%d]: %s\n",
+					 frame, numbytes,
 					 get_usb_statmsg(
 					    urb->iso_frame_desc[frame].status));
-				break;
-			}
-			numbytes = urb->iso_frame_desc[frame].actual_length;
-			if (unlikely(numbytes > BAS_MAXFRAME)) {
+			if (unlikely(numbytes > BAS_MAXFRAME))
 				dev_warn(cs->dev,
 					 "isochronous read: frame %d: "
 					 "numbytes (%d) > BAS_MAXFRAME\n",
 					 frame, numbytes);
-				break;
-			}
 			if (unlikely(numbytes > totleft)) {
 				dev_warn(cs->dev,
 					 "isochronous read: frame %d: "
 					 "numbytes (%d) > totleft (%d)\n",
 					 frame, numbytes, totleft);
-				break;
+				numbytes = totleft;
 			}
 			offset = urb->iso_frame_desc[frame].offset;
 			if (unlikely(offset + numbytes > BAS_INBUFSIZE)) {
@@ -1361,7 +1357,7 @@ static void read_iso_tasklet(unsigned long data)
 					 "offset (%d) + numbytes (%d) "
 					 "> BAS_INBUFSIZE\n",
 					 frame, offset, numbytes);
-				break;
+				numbytes = BAS_INBUFSIZE - offset;
 			}
 			gigaset_isoc_receive(rcvbuf + offset, numbytes, bcs);
 			totleft -= numbytes;
-- 
1.6.2.1.214.ge986c

