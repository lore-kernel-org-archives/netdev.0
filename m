From: John Heffner <jheffner@psc.edu>
Subject: [PATCH] window announcement with scaling
Date: Wed, 7 Jul 2004 17:45:13 -0400 (EDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <Pine.NEB.4.33.0407071603350.19720-100000@dexter.psc.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <netdev@oss.sgi.com>, <linux-net@vger.kernel.org>
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
List-Id: netdev.vger.kernel.org

See comments in patch below.

  -John

===== net/ipv4/tcp_output.c 1.40 vs edited =====
--- 1.40/net/ipv4/tcp_output.c	Tue Jun 22 02:52:20 2004
+++ edited/net/ipv4/tcp_output.c	Wed Jul  7 17:39:42 2004
@@ -682,17 +682,30 @@
 	if (free_space > tp->rcv_ssthresh)
 		free_space = tp->rcv_ssthresh;

-	/* Get the largest window that is a nice multiple of mss.
-	 * Window clamp already applied above.
-	 * If our current window offering is within 1 mss of the
-	 * free space we just keep it. This prevents the divide
-	 * and multiply from happening most of the time.
-	 * We also don't do any window rounding when the free space
-	 * is too small.
+	/* Don't do rounding if we are using window scaling, since the
+	 * scaled window will not line up with the MSS boundary anyway.
 	 */
 	window = tp->rcv_wnd;
-	if (window <= free_space - mss || window > free_space)
-		window = (free_space/mss)*mss;
+	if (tp->rcv_wscale) {
+		window = free_space;
+
+		/* Advertise enough space so that it won't get scaled away.
+		 * Import case: prevent zero window announcement if
+		 * 1<<rcv_wscale > mss. */
+		if (((window >> tp->rcv_wscale) << tp->rcv_wscale) != window)
+			window = ((window >> tp->rcv_wscale) + 1) << tp->rcv_wscale;
+	} else {
+		/* Get the largest window that is a nice multiple of mss.
+		 * Window clamp already applied above.
+		 * If our current window offering is within 1 mss of the
+		 * free space we just keep it. This prevents the divide
+		 * and multiply from happening most of the time.
+		 * We also don't do any window rounding when the free space
+		 * is too small.
+		 */
+		if (window <= free_space - mss || window > free_space)
+			window = (free_space/mss)*mss;
+	}

 	return window;
 }


