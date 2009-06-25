From: Jens Rosenboom <me@jayr.de>
Subject: PATCH: ipv6: avoid wraparound for expired lifetimes
Date: Thu, 25 Jun 2009 09:39:43 +0200
Message-ID: <20090625073943.GO21357@jayr.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout4.freenet.de ([195.4.92.94]:58445 "EHLO mout4.freenet.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752449AbZFYHjp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Jun 2009 03:39:45 -0400
Received: from [195.4.92.20] (helo=10.mx.freenet.de)
	by mout4.freenet.de with esmtpa (ID exim) (port 25) (Exim 4.69 #92)
	id 1MJjYf-00019k-T8
	for netdev@vger.kernel.org; Thu, 25 Jun 2009 09:39:45 +0200
Received: from v6.beuys.jayr.de ([2001:748:305:1001:290:27ff:fe2d:b4cc]:47374 helo=beuys.jayr.de)
	by 10.mx.freenet.de with esmtps (TLSv1:AES256-SHA:256) (port 25) (Exim 4.69 #79)
	id 1MJjYf-0008NP-LU
	for netdev@vger.kernel.org; Thu, 25 Jun 2009 09:39:45 +0200
Received: from jens by beuys.jayr.de with local (Exim 4.69)
	(envelope-from <jens@jayr.de>)
	id 1MJjYd-0000AG-DI
	for netdev@vger.kernel.org; Thu, 25 Jun 2009 09:39:43 +0200
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the valid or preferred lifetime for an address expires, the kernel
shows huge values for these due to a counter wrap, the following patch
should fix this, at least it did in the test I ran.

--- linux-2.6.30.orig/net/ipv6/addrconf.c	2009-06-10 05:05:27.000000000 +0200
+++ linux-2.6.30/net/ipv6/addrconf.c	2009-06-25 09:33:38.000000000 +0200
@@ -3361,9 +3361,17 @@
 		valid = ifa->valid_lft;
 		if (preferred != INFINITY_LIFE_TIME) {
 			long tval = (jiffies - ifa->tstamp)/HZ;
-			preferred -= tval;
-			if (valid != INFINITY_LIFE_TIME)
-				valid -= tval;
+			if (preferred > tval) {
+				preferred -= tval;
+			} else {
+				preferred = 0;
+			}
+			if (valid != INFINITY_LIFE_TIME) {
+				if (valid > tval) {
+					valid -= tval;
+				} else {
+					valid = 0;
+				}
 		}
 	} else {
 		preferred = INFINITY_LIFE_TIME;
