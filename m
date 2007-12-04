From: Andreas Henriksson <andreas@fatal.se>
Subject: [PATCH] iproute2: support dotted-quad netmask notation.
Date: Tue, 4 Dec 2007 14:58:18 +0100
Message-ID: <20071204135818.GA24419@scream.fatal.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1-1-1-9a.ghn.gbg.bostream.se ([82.182.69.4]:37156 "EHLO
	scream.fatal.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752049AbXLDO5I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Dec 2007 09:57:08 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Suggested patch for allowing netmask to be specified in dotted quad format.
See http://bugs.debian.org/357172

(Known problem: this will not prevent some invalid syntaxes,
ie. "255.0.255.0" will be treated as "255.255.255.0")

Comments? Suggestions? Improvements?

Signed-off-by: Andreas Henriksson <andreas@fatal.se>


diff --git a/lib/utils.c b/lib/utils.c
index 4c42dfd..277ab45 100644
--- a/lib/utils.c
+++ b/lib/utils.c
@@ -47,6 +47,25 @@ int get_integer(int *val, const char *arg, int base)
 	return 0;
 }
 
+int get_netmask(unsigned *val, const char *arg, int base)
+{
+	inet_prefix addr;
+
+	if (!get_unsigned(val, arg, base))
+		return 0;
+
+	/* try coverting dotted quad to CIDR */
+	if (!get_addr_1(&addr, arg, AF_INET)) {
+		u_int32_t mask;
+		*val=0;
+		for (mask = addr.data[0]; mask; mask >>= 1)
+			(*val)++;
+		return 0;
+	}
+
+	return -1;
+}
+
 int get_unsigned(unsigned *val, const char *arg, int base)
 {
 	unsigned long res;
@@ -304,7 +323,8 @@ int get_prefix_1(inet_prefix *dst, char *arg, int family)
 				dst->bitlen = 32;
 		}
 		if (slash) {
-			if (get_unsigned(&plen, slash+1, 0) || plen > dst->bitlen) {
+			if (get_netmask(&plen, slash+1, 0)
+					|| plen > dst->bitlen) {
 				err = -1;
 				goto done;
 			}

-- 
Regards,
Andreas Henriksson
