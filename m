From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 1/2] div64_64 optimization
Date: Wed, 21 Mar 2007 13:15:32 -0700
Message-ID: <20070321131532.66e7f0e1@freekitty>
References: <20070307170731.2b4397e3@freekitty>
	<20070307.185539.48527371.davem@davemloft.net>
	<45EF7EB7.8040806@linux-foundation.org>
	<20070307.195135.74749102.davem@davemloft.net>
	<20070310114826.GB1608@1wt.eu>
	<20070312141156.08e88b0e@freekitty>
	<20070313205020.GA5418@1wt.eu>
	<20070321115419.483a655a@freekitty>
	<20070321191537.GA28914@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: rkuhn@e18.physik.tu-muenchen.de, andi@firstfloor.org,
	dada1@cosmosbay.com, jengelh@linux01.gwdg.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:52119 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964817AbXCUUVk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Mar 2007 16:21:40 -0400
In-Reply-To: <20070321191537.GA28914@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Minor optimization of div64_64.  do_div() already does optimization
for the case of 32 by 32 divide, so no need to do it here.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- net-2.6.22.orig/lib/div64.c	2007-03-21 12:03:59.000000000 -0700
+++ net-2.6.22/lib/div64.c	2007-03-21 12:04:46.000000000 -0700
@@ -61,20 +61,18 @@
 /* 64bit divisor, dividend and result. dynamic precision */
 uint64_t div64_64(uint64_t dividend, uint64_t divisor)
 {
-	uint32_t d = divisor;
+	uint32_t high, d;
 
-	if (divisor > 0xffffffffULL) {
-		unsigned int shift = fls(divisor >> 32);
+	high = divisor >> 32;
+	if (high) {
+		unsigned int shift = fls(high);
 
 		d = divisor >> shift;
 		dividend >>= shift;
-	}
+	} else
+		d = divisor;
 
-	/* avoid 64 bit division if possible */
-	if (dividend >> 32)
-		do_div(dividend, d);
-	else
-		dividend = (uint32_t) dividend / d;
+	do_div(dividend, d);
 
 	return dividend;
 }
