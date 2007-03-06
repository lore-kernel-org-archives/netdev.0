From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] TCP Yeah: cleanup
Date: Tue, 6 Mar 2007 14:56:05 -0800
Message-ID: <20070306145605.3731d39d@freekitty>
References: <45D97FEA.1080006@gmail.com>
	<45D98084.5030907@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Andrea Baiocchi <andrea.baiocchi@uniroma1.it>,
	Francesco Vacirca <francesco@net.infocom.uniroma1.it>
To: "Angelo P. Castellani" <angelo.castellani@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:34885 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030578AbXCFW4r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 17:56:47 -0500
In-Reply-To: <45D98084.5030907@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Eliminate need for full 6/4/64 divide to compute queue.
Variable maxqueue was really a constant.
Fix indentation.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
	  
---
 net/ipv4/tcp_yeah.c |   42 +++++++++++++++++++++++-------------------
 1 file changed, 23 insertions(+), 19 deletions(-)

--- net-2.6.22.orig/net/ipv4/tcp_yeah.c	2007-03-06 11:46:34.000000000 -0800
+++ net-2.6.22/net/ipv4/tcp_yeah.c	2007-03-06 11:54:54.000000000 -0800
@@ -74,7 +74,7 @@
 }
 
 static void tcp_yeah_cong_avoid(struct sock *sk, u32 ack,
-				 u32 seq_rtt, u32 in_flight, int flag)
+				u32 seq_rtt, u32 in_flight, int flag)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct yeah *yeah = inet_csk_ca(sk);
@@ -142,8 +142,8 @@
 		 */
 
 		if (yeah->cntRTT > 2) {
-			u32 rtt;
-			u32 queue, maxqueue;
+			u32 rtt, queue;
+			u64 bw;
 
 			/* We have enough RTT samples, so, using the Vegas
 			 * algorithm, we determine if we should increase or
@@ -158,32 +158,36 @@
 			 */
 			rtt = yeah->minRTT;
 
-			queue = (u32)div64_64((u64)tp->snd_cwnd * (rtt - yeah->baseRTT), rtt);
-
-			maxqueue = TCP_YEAH_ALPHA;
-
-			if (queue > maxqueue ||
-				    rtt - yeah->baseRTT > (yeah->baseRTT / TCP_YEAH_PHY)) {
-
-				if (queue > maxqueue && tp->snd_cwnd > yeah->reno_count) {
-					u32 reduction = min( queue / TCP_YEAH_GAMMA ,
-					                 tp->snd_cwnd >> TCP_YEAH_EPSILON );
+			/* Compute excess number of packets above bandwidth
+			 * Avoid doing full 64 bit divide.
+			 */
+			bw = tp->snd_cwnd;
+			bw *= rtt - yeah->baseRTT;
+			do_div(bw, rtt);
+			queue = bw;
+
+			if (queue > TCP_YEAH_ALPHA ||
+			    rtt - yeah->baseRTT > (yeah->baseRTT / TCP_YEAH_PHY)) {
+				if (queue > TCP_YEAH_ALPHA
+				    && tp->snd_cwnd > yeah->reno_count) {
+					u32 reduction = min(queue / TCP_YEAH_GAMMA ,
+							    tp->snd_cwnd >> TCP_YEAH_EPSILON);
 
 					tp->snd_cwnd -= reduction;
 
-					tp->snd_cwnd = max( tp->snd_cwnd, yeah->reno_count);
+					tp->snd_cwnd = max(tp->snd_cwnd,
+							   yeah->reno_count);
 
 					tp->snd_ssthresh = tp->snd_cwnd;
-			}
+				}
 
 				if (yeah->reno_count <= 2)
-					yeah->reno_count = max( tp->snd_cwnd>>1, 2U);
+					yeah->reno_count = max(tp->snd_cwnd>>1, 2U);
 				else
 					yeah->reno_count++;
 
-				yeah->doing_reno_now =
-					           min_t( u32, yeah->doing_reno_now + 1 , 0xffffff);
-
+				yeah->doing_reno_now = min(yeah->doing_reno_now + 1,
+							   0xffffffU);
 			} else {
 				yeah->fast_count++;
 
