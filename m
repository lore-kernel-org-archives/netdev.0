From: Richard Purdie <rpurdie@rpsys.net>
Subject: Re: [Bugme-new] [Bug 8405] New: pppd does stops compresion with
	"Lost compression sync"
Date: Mon, 30 Apr 2007 14:31:09 +0100
Message-ID: <1177939870.5872.29.camel@localhost.localdomain>
References: <200704292001.l3TK1P6d000716@fire-2.osdl.org>
	 <20070429142047.d8617669.akpm@linux-foundation.org>
	 <200704301408.58185.stefan.wenk@gmx.at>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>
To: Stefan Wenk <stefan.wenk@gmx.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tim.rpsys.net ([194.106.48.114]:60199 "EHLO tim.rpsys.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423264AbXD3NbW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Apr 2007 09:31:22 -0400
In-Reply-To: <200704301408.58185.stefan.wenk@gmx.at>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-04-30 at 14:08 +0200, Stefan Wenk wrote:
> On Sunday 29 April 2007 23:20, Andrew Morton wrote:
> > (switch to email - please retain all ccs)
> >
> > On Sun, 29 Apr 2007 13:01:25 -0700 bugme-daemon@bugzilla.kernel.org wrote:
> > > http://bugzilla.kernel.org/show_bug.cgi?id=8405
> > >
> > > Here is the log vor /var/log/messages:
> > >
> > > Apr 29 16:53:34 linux kernel: PPP Deflate Compression module registered
> > > Apr 29 16:53:47 linux pppd[9090]: pppd 2.4.4 started by root, uid 0
> > > Apr 29 16:53:47 linux pppd[9090]: Using interface ppp0
> > > Apr 29 16:53:47 linux pppd[9090]: Connect: ppp0 <--> /dev/pts/9
> > > Apr 29 16:53:47 linux pppd[9090]: kernel does not support PPP filtering
> > > Apr 29 16:53:47 linux pppd[9090]: Deflate (15) compression enabled
> > > Apr 29 16:53:47 linux pppd[9090]: Cannot determine ethernet address for
> > > proxy ARP Apr 29 16:53:47 linux pppd[9090]: local  IP address 192.168.3.2
> > > Apr 29 16:53:47 linux pppd[9090]: remote IP address 192.168.3.1
> > > Apr 29 16:54:03 linux kernel: z_decompress0: inflate returned -5 ()
> > > Apr 29 16:54:03 linux pppd[9090]: PPPIOCGFLAGS flags: c030c0
> > > Apr 29 16:54:03 linux pppd[9090]: Lost compression sync: disabling
> > > compression
> > >
> > > I had a look at the kernel patch of 2.6.18 - the lib/zlib/zlib_inflate
> > > was changed a lot and for me it looks to be the reason of the problem.
> >
> > If you're referring to 4f3865fb57a04db7cca068fed1c15badc064a302,
> > "zlib_inflate: Upgrade library code to a recent version" then that was
> > mainly a zlib_inflate change, not a zlib_deflate change.
> >
> > But yes, I'd say that this patch might well have been the cause.
> >
> > http://userweb.kernel.org/~akpm/zlib-backout.patch is a backout patch
> > against 2.6.21.  If you apply that to 2.6.21 does it make ppp work again?
> 
> thanks for this backout patch. I have applied it to 2.6.21 and now pppd is 
> working with deflate again.

The key line of that log is 
"Apr 29 16:54:03 linux kernel: z_decompress0: inflate returned -5 ()"

linux/zlib.h says:

#define Z_BUF_ERROR    (-5)

so somehow we're triggering a buffer error...

Looking at zlib_inflate() in lib/zlib_inflate/inflate.c, it seems that
error only occurs if we had success (Z_OK) but no remaining input/output
space. I suspect you can just have ppp_deflate ignore that "error" code
and it might just work.

Can you try the following patch:

Index: linux-2.6.20/drivers/net/ppp_deflate.c
===================================================================
--- linux-2.6.20.orig/drivers/net/ppp_deflate.c	2007-02-04 18:44:54.000000000 +0000
+++ linux-2.6.20/drivers/net/ppp_deflate.c	2007-04-30 14:27:08.000000000 +0100
@@ -487,12 +487,16 @@ int z_decompress(void *arg, unsigned cha
 	 */
 	for (;;) {
 		r = zlib_inflate(&state->strm, Z_PACKET_FLUSH);
-		if (r != Z_OK) {
+		if ((r != Z_OK) && (r != Z_BUF_ERROR)) {
 			if (state->debug)
 				printk(KERN_DEBUG "z_decompress%d: inflate returned %d (%s)\n",
 				       state->unit, r, (state->strm.msg? state->strm.msg: ""));
 			return DECOMP_FATALERROR;
 		}
+		if (r == Z_BUF_ERROR) {
+			printk(KERN_DEBUG "z_decompress%d: Would have triggered an error as inflate returned %d (%s)\n",
+				       state->unit, r, (state->strm.msg? state->strm.msg: ""));
+		}
 		if (state->strm.avail_out != 0)
 			break;		/* all done */
 		if (decode_proto) {

This should continue but print some debug output when the problem
occurs.

Richard




