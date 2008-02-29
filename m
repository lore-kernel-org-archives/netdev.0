From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] New Update on CUBIC
Date: Fri, 29 Feb 2008 08:27:54 -0800
Message-ID: <20080229082754.19177227@extreme>
References: <008401c87ad6$aea52e30$4a580e98@ncsu2cc0c3fa00>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>
To: "Injong Rhee" <rhee@eos.ncsu.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:33099 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932668AbYB2Q2G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Feb 2008 11:28:06 -0500
In-Reply-To: <008401c87ad6$aea52e30$4a580e98@ncsu2cc0c3fa00>
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

---
Fixed the whitespace breakage in your patch.

--- a/net/ipv4/tcp_cubic.c	2008-02-29 08:24:52.000000000 -0800
+++ b/net/ipv4/tcp_cubic.c	2008-02-29 08:25:02.000000000 -0800
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
@@ -20,15 +21,11 @@
 #define BICTCP_BETA_SCALE    1024	/* Scale factor beta calculation
 					 * max_cwnd = snd_cwnd * beta
 					 */
-#define BICTCP_B		4	 /*
-					  * In binary search,
-					  * go to point (max+min)/N
-					  */
 #define	BICTCP_HZ		10	/* BIC HZ 2^10 = 1024 */
 
 static int fast_convergence __read_mostly = 1;
 static int max_increment __read_mostly = 16;
-static int beta __read_mostly = 819;	/* = 819/1024 (BICTCP_BETA_SCALE) */
+static int beta __read_mostly = 717;	/* = 717/1024 (BICTCP_BETA_SCALE) */
 static int initial_ssthresh __read_mostly;
 static int bic_scale __read_mostly = 41;
 static int tcp_friendliness __read_mostly = 1;
@@ -40,9 +37,7 @@ static u64 cube_factor __read_mostly;
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
@@ -211,19 +206,6 @@ static inline void bictcp_update(struct 
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
@@ -391,4 +373,4 @@ module_exit(cubictcp_unregister);
 MODULE_AUTHOR("Sangtae Ha, Stephen Hemminger");
 MODULE_LICENSE("GPL");
 MODULE_DESCRIPTION("CUBIC TCP");
-MODULE_VERSION("2.1");
+MODULE_VERSION("2.2");
