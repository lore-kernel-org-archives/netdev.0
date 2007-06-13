From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] TCP: remove initial_ssthresh from Cubic
Date: Wed, 13 Jun 2007 10:27:18 -0700
Message-ID: <20070613102718.61d67a36@localhost>
References: <20070612.151258.120619253.davem@davemloft.net>
	<20070612171603.47736395@localhost>
	<20070612233814.4b04db2f.billfink@mindspring.com>
	<20070613.005642.85685043.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: billfink@mindspring.com, sangtae.ha@gmail.com, rhee@eos.ncsu.edu,
	rhee@ncsu.edu, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:34505 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758945AbXFMR1h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2007 13:27:37 -0400
In-Reply-To: <20070613.005642.85685043.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove the initial slow start override from TCP cubic.
The old code caused Cubic to start out in slow start mode, which
is less agressive but caused slow performance.

The administrator can override initial slow start threshold on any
TCP congestion control method via the TCP route metrics.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- a/net/ipv4/tcp_cubic.c	2007-06-13 10:18:38.000000000 -0700
+++ b/net/ipv4/tcp_cubic.c	2007-06-13 10:19:19.000000000 -0700
@@ -29,7 +29,6 @@
 static int fast_convergence __read_mostly = 1;
 static int max_increment __read_mostly = 16;
 static int beta __read_mostly = 819;	/* = 819/1024 (BICTCP_BETA_SCALE) */
-static int initial_ssthresh __read_mostly = 100;
 static int bic_scale __read_mostly = 41;
 static int tcp_friendliness __read_mostly = 1;
 
@@ -44,8 +43,6 @@ module_param(max_increment, int, 0644);
 MODULE_PARM_DESC(max_increment, "Limit on increment allowed during binary search");
 module_param(beta, int, 0444);
 MODULE_PARM_DESC(beta, "beta for multiplicative increase");
-module_param(initial_ssthresh, int, 0644);
-MODULE_PARM_DESC(initial_ssthresh, "initial value of slow start threshold");
 module_param(bic_scale, int, 0444);
 MODULE_PARM_DESC(bic_scale, "scale (scaled by 1024) value for bic function (bic_scale/1024)");
 module_param(tcp_friendliness, int, 0644);
@@ -87,8 +84,6 @@ static inline void bictcp_reset(struct b
 static void bictcp_init(struct sock *sk)
 {
 	bictcp_reset(inet_csk_ca(sk));
-	if (initial_ssthresh)
-		tcp_sk(sk)->snd_ssthresh = initial_ssthresh;
 }
 
 /* calculate the cubic root of x using a table lookup followed by one
