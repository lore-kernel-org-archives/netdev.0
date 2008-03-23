From: Benoit Boissinot <benoit.boissinot@ens-lyon.org>
Subject: [PATCH 1 of 5] IPv6: do not wrap around when the lifetime has expired
Date: Sun, 23 Mar 2008 21:46:09 +0100
Message-ID: <dd125a7f86968371046d.1206305169@pirzuine>
References: <patchbomb.1206305168@pirzuine>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: pekkas@netcore.fi, yoshfuji@linux-ipv6.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp8-g19.free.fr ([212.27.42.65]:38114 "EHLO smtp8-g19.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754550AbYCWUqP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Mar 2008 16:46:15 -0400
In-Reply-To: <patchbomb.1206305168@pirzuine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IPv6: do not wrap around when the lifetime has expired

Instead of reporting overly large lifetimes to userspace,
report a lifetime of 0 when a lifetime has expired.

Signed-off-by: Benoit Boissinot <benoit.boissinot@ens-lyon.org>

diff -r c6c17f6335a1 -r dd125a7f8696 net/ipv6/addrconf.c
--- a/net/ipv6/addrconf.c	Sat Mar 22 14:33:51 2008 +0100
+++ b/net/ipv6/addrconf.c	Sat Mar 22 00:50:21 2008 +0100
@@ -3230,10 +3230,17 @@
 		preferred = ifa->prefered_lft;
 		valid = ifa->valid_lft;
 		if (preferred != INFINITY_LIFE_TIME) {
-			long tval = (jiffies - ifa->tstamp)/HZ;
-			preferred -= tval;
-			if (valid != INFINITY_LIFE_TIME)
-				valid -= tval;
+			unsigned long tval = (jiffies - ifa->tstamp)/HZ;
+			if (tval > preferred)
+				preferred = 0;
+			else
+				preferred -= tval;
+			if (valid != INFINITY_LIFE_TIME) {
+				if (tval > valid)
+					valid = 0;
+				else
+					valid -= tval;
+			}
 		}
 	} else {
 		preferred = INFINITY_LIFE_TIME;
