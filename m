From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] tcp_cubic: faster cube root
Date: Tue, 6 Mar 2007 14:47:06 -0800
Message-ID: <20070306144706.4585c079@freekitty>
References: <20070306144529.GA2004@one.firstfloor.org>
	<84C47260-4B57-4568-8197-58F438A6F737@e18.physik.tu-muenchen.de>
	<20070306102941.32471d57@freekitty>
	<20070306.135834.26100913.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: rkuhn@e18.physik.tu-muenchen.de, andi@firstfloor.org,
	dada1@cosmosbay.com, jengelh@linux01.gwdg.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:34536 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932510AbXCFWvH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 17:51:07 -0500
In-Reply-To: <20070306.135834.26100913.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Newton-Raphson method is quadratically convergent so
only a small fixed number of steps are necessary.
Therefore it is faster to unroll the loop. Since div64_64 is no longer
inline it won't cause code explosion.

Also fixes a bug that can occur if x^2 was bigger than 32 bits.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 net/ipv4/tcp_cubic.c |   16 +++++-----------
 1 file changed, 5 insertions(+), 11 deletions(-)

--- net-2.6.22.orig/net/ipv4/tcp_cubic.c	2007-03-06 12:24:34.000000000 -0800
+++ net-2.6.22/net/ipv4/tcp_cubic.c	2007-03-06 14:43:37.000000000 -0800
@@ -96,23 +96,17 @@
  */
 static u32 cubic_root(u64 a)
 {
-	u32 x, x1;
+	u64 x;
 
 	/* Initial estimate is based on:
 	 * cbrt(x) = exp(log(x) / 3)
 	 */
 	x = 1u << (fls64(a)/3);
 
-	/*
-	 * Iteration based on:
-	 *                         2
-	 * x    = ( 2 * x  +  a / x  ) / 3
-	 *  k+1          k         k
-	 */
-	do {
-		x1 = x;
-		x = (2 * x + (uint32_t) div64_64(a, x*x)) / 3;
-	} while (abs(x1 - x) > 1);
+	/* converges to 32 bits in 3 iterations */
+	x = (2 * x + div64_64(a, x*x)) / 3;
+	x = (2 * x + div64_64(a, x*x)) / 3;
+	x = (2 * x + div64_64(a, x*x)) / 3;
 
 	return x;
 }
