From: Richard Purdie <rpurdie@rpsys.net>
Subject: [PATCH] Fix ppp_deflate issues with recent zlib_inflate changes
Date: Thu, 03 May 2007 23:18:09 +0100
Message-ID: <1178230689.27450.9.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stefan Wenk <stefan.wenk@gmx.at>, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tim.rpsys.net ([194.106.48.114]:48032 "EHLO tim.rpsys.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754180AbXECWSZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 May 2007 18:18:25 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The last zlib_inflate update broke certain corner cases for ppp_deflate
decompression handling. This patch fixes some logic to make things work
properly again. Users other than ppp_deflate (the only Z_PACKET_FLUSH
user) should be unaffected.

Fixes bug 8405 (confirmed by the reporter).

Signed-off-by: Richard Purdie <rpurdie@rpsys.net>

Index: linux/lib/zlib_inflate/inflate.c
===================================================================
--- linux.orig/lib/zlib_inflate/inflate.c	2007-05-03 23:08:27.000000000 +0100
+++ linux/lib/zlib_inflate/inflate.c	2007-05-03 23:09:39.000000000 +0100
@@ -743,12 +743,14 @@ int zlib_inflate(z_streamp strm, int flu
 
     strm->data_type = state->bits + (state->last ? 64 : 0) +
                       (state->mode == TYPE ? 128 : 0);
-    if (((in == 0 && out == 0) || flush == Z_FINISH) && ret == Z_OK)
-        ret = Z_BUF_ERROR;
 
     if (flush == Z_PACKET_FLUSH && ret == Z_OK &&
-            (strm->avail_out != 0 || strm->avail_in == 0))
+            strm->avail_out != 0 && strm->avail_in == 0)
 		return zlib_inflateSyncPacket(strm);
+
+    if (((in == 0 && out == 0) || flush == Z_FINISH) && ret == Z_OK)
+        ret = Z_BUF_ERROR;
+
     return ret;
 }
 

