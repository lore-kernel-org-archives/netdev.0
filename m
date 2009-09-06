From: Tilman Schmidt <tilman-ZTO5kqT2PaM@public.gmane.org>
Subject: [PATCH 04/12] gigaset: handle isoc frame errors more gracefully
Date: Sun,  6 Sep 2009 20:58:52 +0200 (CEST)
Message-ID: <20090906-patch-gigaset-04.tilman@imap.cc>
References: <20090906-patch-gigaset-00.tilman@imap.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Hansjoerg Lipp <hjlipp-S0/GAf8tV78@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        i4ldeveloper-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org
Return-path: <i4ldeveloper-bounces-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org>
In-Reply-To: <20090906-patch-gigaset-00.tilman-ZTO5kqT2PaM@public.gmane.org>
List-Unsubscribe: <https://www.isdn4linux.de/mailman/listinfo/i4ldeveloper>,
	<mailto:i4ldeveloper-request-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org?subject=unsubscribe>
List-Archive: <http://www.isdn4linux.de/pipermail/i4ldeveloper>
List-Post: <mailto:i4ldeveloper-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org>
List-Help: <mailto:i4ldeveloper-request-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org?subject=help>
List-Subscribe: <https://www.isdn4linux.de/mailman/listinfo/i4ldeveloper>,
	<mailto:i4ldeveloper-request-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org?subject=subscribe>
Sender: i4ldeveloper-bounces-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org
Errors-To: i4ldeveloper-bounces-JX7+OpRa80SjiSfgN6Y1Ib39b6g2fGNp@public.gmane.org
List-Id: netdev.vger.kernel.org

Don't drop the remainder of an URB if an isochronous frame has an error.

Impact: error handling improvement
Signed-off-by: Tilman Schmidt <tilman-ZTO5kqT2PaM@public.gmane.org>
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
