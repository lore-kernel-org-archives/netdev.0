From: Jan Olderdissen <jan@ixiacom.com>
Subject: [PATCH] TCP window remains locked at one mss
Date: Tue, 11 May 2004 16:47:21 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <15FDCE057B48784C80836803AE3598D50627ACD2@racerx.ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Marko Rauhamaa <Marko@ixiacom.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Summary:

The patch below will fix an annoying situation where an IPv4 TCP connection
will never advertise the maximum available window size. The patch also
properly sets the window size when free_space is less than 1 mss. The
original code would just set the window size to zero.

Target:

The patch applies cleanly against 2.6.6.

Discussion:

The intent of the code at the bottom of __tcp_select_window() in
ipv4/tcp_output.c is to round the window size to a multiple of mss while
avoiding execution the div/mul code that aligns the window size to a
multiple of mss. However, if the current window size happens to be max-mss
it will stay that way indefinitely. This may not be a big deal for TCP
connections with large buffers, but we regularly use buffer sizes of 4k to
minimize memory use and quite often connections are stuck at a window size
of 1448. This is quite detrimental to throughput.

I propose that on most current architectures the savings in cycles in
negligible, well outweighed by the cost of reducing the window size by 1
mss.

As a separate item, the original code didn't match the comments in that the
rounding code was executed even for very small free_space values. This would
lead to the window size becoming zero.

Testing:

This patch was tested against 2.4.21 on IBM PowerPC 750CXe. It applies and
compiles cleanly on 2.6.6.

8<--------------------------------------------------------------------------
---
--- linux.orig/net/ipv4/tcp_output.c    2004-05-11 13:59:41.000000000 -0700
+++ linux/net/ipv4/tcp_output.c 2004-05-11 15:18:25.000000000 -0700
@@ -746,15 +746,13 @@ u32 __tcp_select_window(struct sock *sk)

    /* Get the largest window that is a nice multiple of mss.
     * Window clamp already applied above.
-    * If our current window offering is within 1 mss of the
-    * free space we just keep it. This prevents the divide
-    * and multiply from happening most of the time.
-    * We also don't do any window rounding when the free space
+    * We don't do any window rounding when the free space
     * is too small.
     */
-   window = tp->rcv_wnd;
-   if (window <= free_space - mss || window > free_space)
+   if (free_space > mss)
        window = (free_space/mss)*mss;
+   else
+       window = free_space;

    return window;
 }
8<--------------------------------------------------------------------------
---

Jan
