From: Andreas Henriksson <andreas@fatal.se>
Subject: Re: [PATCH] iproute2: support dotted-quad netmask notation.
Date: Sat, 08 Dec 2007 00:41:34 +0100
Message-ID: <1197070894.5385.14.camel@localhost.localdomain>
References: <20071204135818.GA24419@scream.fatal.se>
	 <20071206115350.18e9204f@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1-1-1-9a.ghn.gbg.bostream.se ([82.182.69.4]:50587 "EHLO
	scream.fatal.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754667AbXLHBrN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2007 20:47:13 -0500
In-Reply-To: <20071206115350.18e9204f@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On tor, 2007-12-06 at 11:53 -0800, Stephen Hemminger wrote:
> On Tue, 4 Dec 2007 14:58:18 +0100
> Andreas Henriksson <andreas@fatal.se> wrote:
> 
> > Suggested patch for allowing netmask to be specified in dotted quad format.
> > See http://bugs.debian.org/357172
> > 
> > (Known problem: this will not prevent some invalid syntaxes,
> > ie. "255.0.255.0" will be treated as "255.255.255.0")
> > 
> > Comments? Suggestions? Improvements?
> 
> Fix the bug you mentioned?
> 
> [... snip example code ...]

Updated patch, added your netmask validation code but without the check
that made 0.0.0.0 (default) and 255.255.255.255 (one address) invalid
netmasks as they are permitted in CIDR format. 

Signed-off-by: Andreas Henriksson <andreas@fatal.se>

diff --git a/lib/utils.c b/lib/utils.c
index 4c42dfd..b4a6125 100644
--- a/lib/utils.c
+++ b/lib/utils.c
@@ -47,6 +47,41 @@ int get_integer(int *val, const char *arg, int base)
 	return 0;
 }
 
+/* a valid netmask must be 2^n - 1 (n = 1..31) */
+static int is_valid_netmask(const inet_prefix *addr)
+{
+        uint32_t host;
+
+        if (addr->family != AF_INET)
+                return 0;
+
+        host = ~ntohl(addr->data[0]);
+
+        return (host & (host + 1)) == 0;
+}
+
+static int get_netmask(unsigned *val, const char *arg, int base)
+{
+	inet_prefix addr;
+
+	if (!get_unsigned(val, arg, base))
+		return 0;
+
+	/* try coverting dotted quad to CIDR */
+	if (!get_addr_1(&addr, arg, AF_INET)) {
+		u_int32_t mask;
+
+		*val=0;
+		for (mask = addr.data[0]; mask; mask >>= 1)
+			(*val)++;
+
+		if (is_valid_netmask(&addr))
+			return 0;
+	}
+
+	return -1;
+}
+
 int get_unsigned(unsigned *val, const char *arg, int base)
 {
 	unsigned long res;
@@ -304,7 +339,8 @@ int get_prefix_1(inet_prefix *dst, char *arg, int family)
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

