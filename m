From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 04/12] gigaset: handle isoc frame errors more gracefully
Date: Sat, 19 Sep 2009 01:57:43 +0200 (CEST)
Message-ID: <20090919-patch-gigaset-04.tilman@imap.cc>
References: <20090919-patch-gigaset-00.tilman@imap.cc>
Cc: Hansjoerg Lipp <hjlipp@web.de>, davem@davemloft.net,
	i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>,
	Karsten Keil <keil@b1-systems.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755432AbZIRX7W@vger.kernel.org>
In-Reply-To: <20090919-patch-gigaset-00.tilman@imap.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
