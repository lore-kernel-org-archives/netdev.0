From: David Miller <davem@davemloft.net>
Subject: Re: TCP packet size and delivery packet decisions
Date: Wed, 15 Sep 2010 10:29:21 -0700 (PDT)
Message-ID: <20100915.102921.115927531.davem@davemloft.net>
References: <20100908121450.GA11412@ms2.inr.ac.ru>
	<20100912.182308.71115181.davem@davemloft.net>
	<20100914093758.GA24348@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, eric.dumazet@gmail.com,
	leandroal@gmail.com, netdev@vger.kernel.org
To: kuznet@ms2.inr.ac.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58383
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754791Ab0IOR3C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Sep 2010 13:29:02 -0400
In-Reply-To: <20100914093758.GA24348@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Date: Tue, 14 Sep 2010 13:37:58 +0400

> If we do not want to mess with tcp_write_xmit(), it is still possible
> to relax the bound to tp->max_window. (BTW, this even does not
> contradict to RFC, only Fs = 1 for tiny windows). This should work:

Looks good to me, here is final commit I used:

--------------------
>From 02923b5c7664d6ce85192ae986b7cdf62ee7dbf7 Mon Sep 17 00:00:00 2001
From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Date: Wed, 15 Sep 2010 10:27:52 -0700
Subject: [PATCH] tcp: Prevent overzealous packetization by SWS logic.

If peer uses tiny MSS (say, 75 bytes) and similarly tiny advertised
window, the SWS logic will packetize to half the MSS unnecessarily.

This causes problems with some embedded devices.

However for large MSS devices we do want to half-MSS packetize
otherwise we never get enough packets into the pipe for things
like fast retransmit and recovery to work.

Be careful also to handle the case where MSS > window, otherwise
we'll never send until the probe timer.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/tcp.h |   18 ++++++++++++++++--
 1 files changed, 16 insertions(+), 2 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index eaa9582..2222fc2 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -475,8 +475,22 @@ extern unsigned int tcp_current_mss(struct sock *sk);
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
-- 
1.7.2.2

