From: Richard Purdie <rpurdie@rpsys.net>
Subject: Re: [Bugme-new] [Bug 8405] New: pppd does stops compresion with
	"Lost compression sync"
Date: Thu, 03 May 2007 01:23:06 +0100
Message-ID: <1178151786.5860.94.camel@localhost.localdomain>
References: <200704292001.l3TK1P6d000716@fire-2.osdl.org>
	 <200705010927.52426.stefan.wenk@gmx.at>
	 <1178054560.5883.87.camel@localhost.localdomain>
	 <200705021859.55296.stefan.wenk@gmx.at>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>
To: Stefan Wenk <stefan.wenk@gmx.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tim.rpsys.net ([194.106.48.114]:60613 "EHLO tim.rpsys.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1767283AbXECAX1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 May 2007 20:23:27 -0400
In-Reply-To: <200705021859.55296.stefan.wenk@gmx.at>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-05-02 at 18:59 +0200, Stefan Wenk wrote:
> The situation now is similar as without any modifications. Instead of -5 
> (Z_BUF_ERROR)
> we get back -3 (Z_DATA_ERROR) from zlib_inflate. Here is the kernel log
> 
> kernel: PPP generic driver version 2.4.2
> pppd[6101]: pppd 2.4.4 started by root, uid 0
> pppd[6101]: Using interface ppp0
> pppd[6101]: Connect: ppp0 <--> /dev/pts/8
> pppd[6101]: kernel does not support PPP filtering
> kernel: PPP BSD Compression module registered
> kernel: PPP Deflate Compression module registered
> pppd[6101]: Deflate (15) compression enabled
> pppd[6101]: Cannot determine ethernet address for proxy ARP
> pppd[6101]: local  IP address 192.168.3.2
> pppd[6101]: remote IP address 192.168.3.1
> kernel: z_decompress0: inflate returned -3 (),av in 0, av out 1, t in 1520, t 
> out 3070, dp 0, of 1, is 644, os 1504
> kernel: z_decompress0: inflate returned -3 ()
> pppd[6101]: Lost compression sync: disabling compression
> pppd[6101]: Terminating on signal 2
> pppd[6101]: Child process pppd (charshunt) (pid 6131) terminated with signal 2
> pppd[6101]: Modem hangup
> pppd[6101]: Connect time 0.2 minutes.
> pppd[6101]: Sent 2969 bytes, received 2774 bytes.
> pppd[6101]: Connection terminated.
> pppd[6101]: Exit.
> 
> Attached you find the corresponding pppdump file.

Thanks, the interesting bit is that overflow=1. The Z_DATA_ERROR is
probably coming from zlib_inflateSyncPacket() suggesting a logic error.

I managed to find a null modem cable, create this setup and occasionally
reproduce the problem. I think the change I suggested was half way there
but there is another problem. Could you try this patch and see if it
fixes your errors? 

I haven't seen the problem occur here on my box with the patch below
applied. Having said that, I was testing against a box running 2.6.11.2
and I did see similar looking compression errors appearing on that just
before I was about to send this after stressing the link for an hour.
This could mean there is some more subtle problem (not related to the
inflate patch). It is sending Reset requests rather than Term Requests
though so perhaps its some other problem. Lets see what you find with
the patch below...

Cheers,

Richard

Index: linux-2.6.20-rc4/lib/zlib_inflate/inflate.c
===================================================================
--- linux-2.6.20-rc4.orig/lib/zlib_inflate/inflate.c
+++ linux-2.6.20-rc4/lib/zlib_inflate/inflate.c
@@ -743,12 +745,14 @@ int zlib_inflate(z_streamp strm, int flu
 
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
 



