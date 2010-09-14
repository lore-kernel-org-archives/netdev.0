From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: TCP packet size and delivery packet decisions
Date: Tue, 14 Sep 2010 13:37:58 +0400
Message-ID: <20100914093758.GA24348@ms2.inr.ac.ru>
References: <alpine.DEB.2.00.1009071443510.26447@wel-95.cs.helsinki.fi> <20100907.201843.179933180.davem@davemloft.net> <20100908121450.GA11412@ms2.inr.ac.ru> <20100912.182308.71115181.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ilpo.jarvinen@helsinki.fi, eric.dumazet@gmail.com,
	leandroal@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:53871 "HELO ms2.inr.ac.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1751696Ab0INJiT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Sep 2010 05:38:19 -0400
Content-Disposition: inline
In-Reply-To: <20100912.182308.71115181.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

> Therefore, how about the following?

This will work.

There is one trap though. If pktsize > max_window, packets never
will be transmitted in normal path, only from probe timer, which
will be very slow.

If we do not want to mess with tcp_write_xmit(), it is still possible
to relax the bound to tp->max_window. (BTW, this even does not
contradict to RFC, only Fs = 1 for tiny windows). This should work:

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 34f5cc2..8cf8cdb 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -501,8 +501,22 @@ extern unsigned int tcp_current_mss(struct sock *sk);
 /* Bound MSS / TSO packet size with the half of the window */
 static inline int tcp_bound_to_half_wnd(struct tcp_sock *tp, int pktsize)
 {
-	if (tp->max_window && pktsize > (tp->max_window >> 1))
-		return max(tp->max_window >> 1, 68U - tp->tcp_header_len);
+	int cutoff;
+
+	/* When peer uses tiny windows, there is no use in packetizing
+	 * to sub-MSS pieces for the sake of SWS or making sure there
+	 * are enough packets in the pipe for fast recovery.
+	 *
+	 * On the other hand, for extremely large MSS devices, handling
+	 * smaller than MSS windows in this way does make sense.
+	 */
+	if (tp->max_window >= 512)
+		cutoff = (tp->max_window >> 1);
+	else
+		cutoff = tp->max_window;
+
+	if (cutoff && pktsize > cutoff)
+		return max(cutoff, 68U - tp->tcp_header_len);
 	else
 		return pktsize;
 }


