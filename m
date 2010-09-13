From: David Miller <davem@davemloft.net>
Subject: Re: TCP packet size and delivery packet decisions
Date: Sun, 12 Sep 2010 18:23:08 -0700 (PDT)
Message-ID: <20100912.182308.71115181.davem@davemloft.net>
References: <alpine.DEB.2.00.1009071443510.26447@wel-95.cs.helsinki.fi>
	<20100907.201843.179933180.davem@davemloft.net>
	<20100908121450.GA11412@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, eric.dumazet@gmail.com,
	leandroal@gmail.com, netdev@vger.kernel.org
To: kuznet@ms2.inr.ac.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33151
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753832Ab0IMBWu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Sep 2010 21:22:50 -0400
In-Reply-To: <20100908121450.GA11412@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Date: Wed, 8 Sep 2010 16:14:50 +0400

> I do not know actual context, of course. I can guess the situation
> can be like this: "I set window=mss exactly to see only one packet in flight
> all the times. Why the hell linux tries to send two mss/2 sized?" :-)

The context is that a very stupid embedded device takes commands that
are all some specific size (I think it was 75 bytes), and it's
TCP stack sets MSS and window to exactly 75 bytes.

Device will only process the commands sent to it over TCP properly
if they are sent full sized, 75 bytes, by the sending TCP stack.
Linux is the only stack with which the device will not work.

To be honest, at such tiny MSS and window sizes, such packetization
for the sake of SWS done by us is stupid.

Let's be a little bit postmodern and just turn off this stuff using
perhaps a modified version of your idea #1, elide the SWS "window / 2"
logic when "max_window >= 512" or something like that.

It seems to handle every angle:

1) Huge MTU (>= 65535) devices are still covered.

2) For sane ethernet derived MSS and normal large window
   behavior stays the same.

3) When speaking to devices using super tiny windows, it is
   apparent that loss recovery performance is not their primary
   concern. :-)

Therefore, how about the following?

diff --git a/include/net/tcp.h b/include/net/tcp.h
index eaa9582..f8744e0 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -475,7 +475,15 @@ extern unsigned int tcp_current_mss(struct sock *sk);
 /* Bound MSS / TSO packet size with the half of the window */
 static inline int tcp_bound_to_half_wnd(struct tcp_sock *tp, int pktsize)
 {
-	if (tp->max_window && pktsize > (tp->max_window >> 1))
+	/* When peer uses tiny windows, there is no use in packetizing
+	 * to sub-MSS pieces for the sake of SWS or making sure there
+	 * are enough packets in the pipe for fast recovery.
+	 *
+	 * On the other hand, for extremely large MSS devices, handling
+	 * smaller than MSS windows in this way does make sense.
+	 */
+	if (tp->max_window >= 512 &&
+	    pktsize > (tp->max_window >> 1))
 		return max(tp->max_window >> 1, 68U - tp->tcp_header_len);
 	else
 		return pktsize;
