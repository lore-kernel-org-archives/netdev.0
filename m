From: akpm@linux-foundation.org
Subject: [patch 7/8] gigaset: gigaset_isowbuf_getbytes() may return signed unnoticed
Date: Wed, 14 May 2008 16:19:45 -0700
Message-ID: <200805142319.m4ENJj6b026569@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org, tilman@imap.cc,
	12o3l@tiscali.nl
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:54112 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754532AbYENXUb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2008 19:20:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tilman Schmidt <tilman@imap.cc>

ifd->offset is unsigned.  gigaset_isowbuf_getbytes() may return signed
unnoticed.  Revised version of patch originally submitted by Roel Kluin
<12o3l@tiscali.nl>.

Signed-off-by: Tilman Schmidt <tilman@imap.cc>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/isdn/gigaset/bas-gigaset.c |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff -puN drivers/isdn/gigaset/bas-gigaset.c~gigaset-gigaset_isowbuf_getbytes-may-return-signed-unnoticed drivers/isdn/gigaset/bas-gigaset.c
--- a/drivers/isdn/gigaset/bas-gigaset.c~gigaset-gigaset_isowbuf_getbytes-may-return-signed-unnoticed
+++ a/drivers/isdn/gigaset/bas-gigaset.c
@@ -1050,10 +1050,9 @@ static int submit_iso_write_urb(struct i
 		}
 
 		/* retrieve block of data to send */
-		ifd->offset = gigaset_isowbuf_getbytes(ubc->isooutbuf,
-						       ifd->length);
-		if (ifd->offset < 0) {
-			if (ifd->offset == -EBUSY) {
+		rc = gigaset_isowbuf_getbytes(ubc->isooutbuf, ifd->length);
+		if (rc < 0) {
+			if (rc == -EBUSY) {
 				gig_dbg(DEBUG_ISO,
 					"%s: buffer busy at frame %d",
 					__func__, nframe);
@@ -1062,11 +1061,12 @@ static int submit_iso_write_urb(struct i
 			} else {
 				dev_err(ucx->bcs->cs->dev,
 					"%s: buffer error %d at frame %d\n",
-					__func__, ifd->offset, nframe);
-				return ifd->offset;
+					__func__, rc, nframe);
+				return rc;
 			}
 			break;
 		}
+		ifd->offset = rc;
 		ucx->limit = ubc->isooutbuf->nextread;
 		ifd->status = 0;
 		ifd->actual_length = 0;
_
