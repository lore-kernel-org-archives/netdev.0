From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] TCP Compound
Date: Thu, 25 May 2006 13:42:31 -0700
Message-ID: <20060525134231.3bfef5a0@localhost.localdomain>
References: <8dd26e70605250420q31d607a9l7a571069b0f73212@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Francesco Vacirca" <francesco@net.infocom.uniroma1.it>,
	"Andrea Baiocchi" <andrea.baiocchi@uniroma1.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:49873 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1030405AbWEYUmq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 May 2006 16:42:46 -0400
To: "Angelo P. Castellani" <angelo.castellani+lkml@gmail.com>
In-Reply-To: <8dd26e70605250420q31d607a9l7a571069b0f73212@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The existing code did a 64 bit divide directly, which won't work on
32 bit platforms.  This is what I am testing, it uses math similar to
TCP CUBIC to do a quad root. It seemed more efficient to just do
one operation rather than two square roots.

---------
diff --git a/net/ipv4/tcp_compound.c b/net/ipv4/tcp_compound.c
index 01048e2..74c26a0 100644
--- a/net/ipv4/tcp_compound.c
+++ b/net/ipv4/tcp_compound.c
@@ -52,8 +52,6 @@
 
 #define TCP_COMPOUND_ALPHA          3U
 #define TCP_COMPOUND_BETA           1U
-#define TCP_COMPOUND_KAPPA_POW      3
-#define TCP_COMPOUND_KAPPA_NSQRT    2
 #define TCP_COMPOUND_GAMMA         30
 #define TCP_COMPOUND_ZETA           1
 
@@ -156,6 +154,58 @@ static void tcp_compound_state(struct so
 		vegas_disable(sk);
 }
 
+
+/* 64bit divisor, dividend and result. dynamic precision */
+static inline u64 div64_64(u64 dividend, u64 divisor)
+{
+	u32 d = divisor;
+
+	if (divisor > 0xffffffffULL) {
+		unsigned int shift = fls(divisor >> 32);
+
+		d = divisor >> shift;
+		dividend >>= shift;
+	}
+
+	/* avoid 64 bit division if possible */
+	if (dividend >> 32)
+		do_div(dividend, d);
+	else
+		dividend = (u32) dividend / d;
+
+	return dividend;
+}
+
+/* calculate the quartic root of "a" using Newton-Raphson */
+static u32 qroot(u64 a)
+{
+	u32 x, x1;
+
+	/* Initial estimate is based on:
+	 * qrt(x) = exp(log(x) / 4)
+	 */
+	x = 1u << (fls64(a) >> 2);
+
+	/*
+	 * Iteration based on:
+	 *                         3
+	 * x    = ( 3 * x  +  a / x  ) / 4
+	 *  k+1          k         k
+	 */
+	do {
+		u64 x3 = x;
+
+		x1 = x;
+		x3 *= x;
+		x3 *= x;
+
+		x = (3 * x + (u32) div64_64(a, x3)) / 4;
+	} while (abs(x1 - x) > 1);
+
+	return x;
+}
+
+
 /*
  * If the connection is idle and we are restarting,
  * then we don't want to do any Vegas calculations
@@ -307,29 +357,23 @@ static void tcp_compound_cong_avoid(stru
 			dwnd = vegas->dwnd;
 
 			if (diff < (TCP_COMPOUND_GAMMA << V_PARAM_SHIFT)) {
-				u32 i, j, x, x2;
-				u64 v;
-
-				v = 1;
-
-				for (i = 0; i < TCP_COMPOUND_KAPPA_POW; i++)
-					v *= old_wnd;
-
-				for (i = 0; i < TCP_COMPOUND_KAPPA_NSQRT; i++) {
-					x = 1;
-					for (j = 0; j < 200; j++) {
-						x2 = (x + v / x) / 2;
-
-						if (x2 == x || !x2)
-							break;
-
-						x = x2;
-					}
-					v = x;
-				}
+				u64 win3;
 
-				x = (u32) v >> TCP_COMPOUND_ALPHA;
+				/*
+				 * The TCP Compound paper describes the choice
+				 * of "k" determines the agressiveness,
+				 * ie. slope of the response function.
+				 *
+				 * For same value as HSTCP would be 0.8
+				 * but for computaional reasons, both the
+				 * original authors and this implementation
+				 * use 0.75.
+				 */
+				win3 = old_wnd;
+				win3 *= old_wnd;
+				win3 *= old_wnd;
 
+				x = qroot(win3) >> TCP_COMPOUND_ALPHA;
 				if (x > 1)
 					dwnd = x - 1;
 				else
