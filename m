From: Richard Purdie <rpurdie@rpsys.net>
Subject: Re: [Bugme-new] [Bug 8405] New: pppd does stops compresion with
	"Lost compression sync"
Date: Tue, 01 May 2007 22:22:40 +0100
Message-ID: <1178054560.5883.87.camel@localhost.localdomain>
References: <200704292001.l3TK1P6d000716@fire-2.osdl.org>
	 <200705010520.10097.stefan.wenk@gmx.at>
	 <20070430203606.ce9bc944.akpm@linux-foundation.org>
	 <200705010927.52426.stefan.wenk@gmx.at>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>
To: Stefan Wenk <stefan.wenk@gmx.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tim.rpsys.net ([194.106.48.114]:56902 "EHLO tim.rpsys.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423661AbXEAVXE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 May 2007 17:23:04 -0400
In-Reply-To: <200705010927.52426.stefan.wenk@gmx.at>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-05-01 at 09:27 +0200, Stefan Wenk wrote:
> Now I have changed these modifications 
> back, and I do not see more debug information except those below:
> 
> z_decompress0: Would have triggered an error as inflate returned -5 ()
> z_decompress0: Would have triggered an error as inflate returned -5 ()
> z_decompress0: Would have triggered an error as inflate returned -5 ()
> ..
> As there are no debug logs in inflate.c I can't provide more information by 
> now.

I had a look at that trace you sent, the echo and replys were normal but
obviously something is going wrong and it tries to negotiate turning off
the compression...

Having looked at the code a bit further, I have a theory that it was
impossible to reach the zlib_inflateSyncPacket call ppp deflate needs.
The patch below fixes that and also adds some debugging so if that isn't
the problem, we might get some further clues as to what the problem
is...

Thanks for the patience :)

Richard

Index: linux/drivers/net/ppp_deflate.c
===================================================================
--- linux.orig/drivers/net/ppp_deflate.c	2007-01-18 00:52:50.000000000 +0000
+++ linux/drivers/net/ppp_deflate.c	2007-05-01 22:21:27.000000000 +0100
@@ -488,6 +488,13 @@ int z_decompress(void *arg, unsigned cha
 	for (;;) {
 		r = zlib_inflate(&state->strm, Z_PACKET_FLUSH);
 		if (r != Z_OK) {
+			printk(KERN_ERR "z_decompress%d: inflate returned %d (%s)"
+				",av in %d, av out %d, t in %ld, t out %ld, dp %d,"
+				" of %d, is %d, os %d\n",
+				state->unit, r, (state->strm.msg? state->strm.msg: ""),
+				state->strm.avail_in, state->strm.avail_out,
+				state->strm.total_in, state->strm.total_out,
+				decode_proto, overflow, isize, osize);
 			if (state->debug)
 				printk(KERN_DEBUG "z_decompress%d: inflate returned %d (%s)\n",
 				       state->unit, r, (state->strm.msg? state->strm.msg: ""));
Index: linux/lib/zlib_inflate/inflate.c
===================================================================
--- linux.orig/lib/zlib_inflate/inflate.c	2007-01-18 00:53:08.000000000 +0000
+++ linux/lib/zlib_inflate/inflate.c	2007-05-01 22:03:53.000000000 +0100
@@ -743,12 +743,14 @@ int zlib_inflate(z_streamp strm, int flu
 
     strm->data_type = state->bits + (state->last ? 64 : 0) +
                       (state->mode == TYPE ? 128 : 0);
-    if (((in == 0 && out == 0) || flush == Z_FINISH) && ret == Z_OK)
-        ret = Z_BUF_ERROR;
 
     if (flush == Z_PACKET_FLUSH && ret == Z_OK &&
             (strm->avail_out != 0 || strm->avail_in == 0))
 		return zlib_inflateSyncPacket(strm);
+
+    if (((in == 0 && out == 0) || flush == Z_FINISH) && ret == Z_OK)
+        ret = Z_BUF_ERROR;
+
     return ret;
 }
 




