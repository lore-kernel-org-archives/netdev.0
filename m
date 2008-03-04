From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] TCP cubic v2.2
Date: Tue, 4 Mar 2008 11:57:40 -0800
Message-ID: <20080304115740.63f8fa7c@extreme>
References: <005d01c87a97$1ccee2b0$4a580e98@ncsu2cc0c3fa00>
	<20080228223148.01a7cbae@extreme>
	<00a801c87ad7$7db74820$4a580e98@ncsu2cc0c3fa00>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <sha2@ncsu.edu>,
	netdev@vger.kernel.org
To: "Injong Rhee" <rhee@eos.ncsu.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:54779 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752356AbYCDT5w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Mar 2008 14:57:52 -0500
In-Reply-To: <00a801c87ad7$7db74820$4a580e98@ncsu2cc0c3fa00>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We have updated CUBIC to fix some issues with slow increase in large BDP 
networks. We also improved its convergence speed. The fix is in fact very 
simple --  the window increase limit of smax during the window probing phase 
(i.e., convex growth phase) is removed. We found that this does not affect 
TCP friendliness, but only improves its scalability. We have run some tests 
in our lab and also over the Internet path from NCSU to Japan. These results 
can be seen from the following page:


http://netsrv.csc.ncsu.edu/wiki/index.php/Intra_protocol_fairness_testing_with_linux-2.6.23.9
http://netsrv.csc.ncsu.edu/wiki/index.php/RTT_fairness_testing_with_linux-2.6.23.9
http://netsrv.csc.ncsu.edu/wiki/index.php/TCP_friendliness_testing_with_linux-2.6.23.9

Signed-off-by: Sangtae Ha <sha2@ncsu.edu>
Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 net/ipv4/tcp_cubic.c |   32 +++++++-------------------------
 1 file changed, 7 insertions(+), 25 deletions(-)

Fixed mailer damage and compiler warnings from unused variables. --sch

--- a/net/ipv4/tcp_cubic.c	2008-03-03 09:10:01.000000000 -0800
+++ b/net/ipv4/tcp_cubic.c	2008-03-03 09:34:32.000000000 -0800
@@ -1,12 +1,13 @@
 /*
- * TCP CUBIC: Binary Increase Congestion control for TCP v2.1
- *
+ * TCP CUBIC: Binary Increase Congestion control for TCP v2.2
+ * Home page:
+ *      http://netsrv.csc.ncsu.edu/twiki/bin/view/Main/BIC
  * This is from the implementation of CUBIC TCP in
  * Injong Rhee, Lisong Xu.
  *  "CUBIC: A New TCP-Friendly High-Speed TCP Variant
  *  in PFLDnet 2005
  * Available from:
- *  http://www.csc.ncsu.edu/faculty/rhee/export/bitcp/cubic-paper.pdf
+ *  http://netsrv.csc.ncsu.edu/export/cubic-paper.pdf
  *
  * Unless CUBIC is enabled and congestion window is large
  * this behaves the same as the original Reno.
@@ -20,15 +21,10 @@
 #define BICTCP_BETA_SCALE    1024	/* Scale factor beta calculation
 					 * max_cwnd = snd_cwnd * beta
 					 */
-#define BICTCP_B		4	 /*
-					  * In binary search,
-					  * go to point (max+min)/N
-					  */
 #define	BICTCP_HZ		10	/* BIC HZ 2^10 = 1024 */
 
 static int fast_convergence __read_mostly = 1;
-static int max_increment __read_mostly = 16;
-static int beta __read_mostly = 819;	/* = 819/1024 (BICTCP_BETA_SCALE) */
+static int beta __read_mostly = 717;	/* = 717/1024 (BICTCP_BETA_SCALE) */
 static int initial_ssthresh __read_mostly;
 static int bic_scale __read_mostly = 41;
 static int tcp_friendliness __read_mostly = 1;
@@ -40,9 +36,7 @@ static u64 cube_factor __read_mostly;
 /* Note parameters that are used for precomputing scale factors are read-only */
 module_param(fast_convergence, int, 0644);
 MODULE_PARM_DESC(fast_convergence, "turn on/off fast convergence");
-module_param(max_increment, int, 0644);
-MODULE_PARM_DESC(max_increment, "Limit on increment allowed during binary search");
-module_param(beta, int, 0444);
+module_param(beta, int, 0644);
 MODULE_PARM_DESC(beta, "beta for multiplicative increase");
 module_param(initial_ssthresh, int, 0644);
 MODULE_PARM_DESC(initial_ssthresh, "initial value of slow start threshold");
@@ -145,7 +139,7 @@ static u32 cubic_root(u64 a)
 static inline void bictcp_update(struct bictcp *ca, u32 cwnd)
 {
 	u64 offs;
-	u32 delta, t, bic_target, min_cnt, max_cnt;
+	u32 delta, t, bic_target, max_cnt;
 
 	ca->ack_cnt++;	/* count the number of ACKs */
 
@@ -211,19 +205,6 @@ static inline void bictcp_update(struct 
 		ca->cnt = 100 * cwnd;              /* very small increment*/
 	}
 
-	if (ca->delay_min > 0) {
-		/* max increment = Smax * rtt / 0.1  */
-		min_cnt = (cwnd * HZ * 8)/(10 * max_increment * ca->delay_min);
-
-		/* use concave growth when the target is above the origin */
-		if (ca->cnt < min_cnt && t >= ca->bic_K)
-			ca->cnt = min_cnt;
-	}
-
-	/* slow start and low utilization  */
-	if (ca->loss_cwnd == 0)		/* could be aggressive in slow start */
-		ca->cnt = 50;
-
 	/* TCP Friendly */
 	if (tcp_friendliness) {
 		u32 scale = beta_scale;
@@ -391,4 +372,4 @@ module_exit(cubictcp_unregister);
 MODULE_AUTHOR("Sangtae Ha, Stephen Hemminger");
 MODULE_LICENSE("GPL");
 MODULE_DESCRIPTION("CUBIC TCP");
-MODULE_VERSION("2.1");
+MODULE_VERSION("2.2");
