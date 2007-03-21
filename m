From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 2/2] tcp: cubic optimization
Date: Wed, 21 Mar 2007 13:17:21 -0700
Message-ID: <20070321131721.448de522@freekitty>
References: <20070307170731.2b4397e3@freekitty>
	<20070307.185539.48527371.davem@davemloft.net>
	<45EF7EB7.8040806@linux-foundation.org>
	<20070307.195135.74749102.davem@davemloft.net>
	<20070310114826.GB1608@1wt.eu>
	<20070312141156.08e88b0e@freekitty>
	<20070313205020.GA5418@1wt.eu>
	<20070321115419.483a655a@freekitty>
	<20070321191537.GA28914@1wt.eu>
	<20070321131532.66e7f0e1@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Willy Tarreau <w@1wt.eu>, David Miller <davem@davemloft.net>,
	rkuhn@e18.physik.tu-muenchen.de, andi@firstfloor.org,
	dada1@cosmosbay.com, jengelh@linux01.gwdg.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:52118 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964821AbXCUUVi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Mar 2007 16:21:38 -0400
In-Reply-To: <20070321131532.66e7f0e1@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use willy's work in optimizing cube root by having table for small values.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- net-2.6.22.orig/net/ipv4/tcp_cubic.c	2007-03-21 12:57:11.000000000 -0700
+++ net-2.6.22/net/ipv4/tcp_cubic.c	2007-03-21 13:04:59.000000000 -0700
@@ -91,23 +91,51 @@
 		tcp_sk(sk)->snd_ssthresh = initial_ssthresh;
 }
 
-/*
- * calculate the cubic root of x using Newton-Raphson
+/* calculate the cubic root of x using a table lookup followed by one
+ * Newton-Raphson iteration.
+ * Avg err ~= 0.195%
  */
 static u32 cubic_root(u64 a)
 {
-	u32 x;
-
-	/* Initial estimate is based on:
-	 * cbrt(x) = exp(log(x) / 3)
+	u32 x, b, shift;
+	/*
+	 * cbrt(x) MSB values for x MSB values in [0..63].
+	 * Precomputed then refined by hand - Willy Tarreau
+	 *
+	 * For x in [0..63],
+	 *   v = cbrt(x << 18) - 1
+	 *   cbrt(x) = (v[x] + 10) >> 6
 	 */
-	x = 1u << (fls64(a)/3);
+	static const u8 v[] = {
+		/* 0x00 */    0,   54,   54,   54,  118,  118,  118,  118,
+		/* 0x08 */  123,  129,  134,  138,  143,  147,  151,  156,
+		/* 0x10 */  157,  161,  164,  168,  170,  173,  176,  179,
+		/* 0x18 */  181,  185,  187,  190,  192,  194,  197,  199,
+		/* 0x20 */  200,  202,  204,  206,  209,  211,  213,  215,
+		/* 0x28 */  217,  219,  221,  222,  224,  225,  227,  229,
+		/* 0x30 */  231,  232,  234,  236,  237,  239,  240,  242,
+		/* 0x38 */  244,  245,  246,  248,  250,  251,  252,  254,
+	};
+
+	b = fls64(a);
+	if (b < 7) {
+		/* a in [0..63] */
+		return ((u32)v[(u32)a] + 35) >> 6;
+	}
+
+	b = ((b * 84) >> 8) - 1;
+	shift = (a >> (b * 3));
 
-	/* converges to 32 bits in 3 iterations */
-	x = (2 * x + (u32)div64_64(a, (u64)x*(u64)x)) / 3;
-	x = (2 * x + (u32)div64_64(a, (u64)x*(u64)x)) / 3;
-	x = (2 * x + (u32)div64_64(a, (u64)x*(u64)x)) / 3;
+	x = ((u32)(((u32)v[shift] + 10) << b)) >> 6;
 
+	/*
+	 * Newton-Raphson iteration
+	 *                         2
+	 * x    = ( 2 * x  +  a / x  ) / 3
+	 *  k+1          k         k
+	 */
+	x = (2 * x + (u32)div64_64(a, (u64)x * (u64)(x - 1)));
+	x = ((x * 341) >> 10);
 	return x;
 }
 


-- 
Stephen Hemminger <shemminger@linux-foundation.org>
