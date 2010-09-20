From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] nf_nat_snmp: fix checksum calculation (v3)
Date: Mon, 20 Sep 2010 09:44:48 -0700
Message-ID: <20100920094448.67210244@nehalam>
References: <4C938AFB.3050303@trash.net>
	<20100914163208.2ba165ca.akpm@linux-foundation.org>
	<bug-17622-10286@https.bugzilla.kernel.org/>
	<6029e4.25bb.12b1d97358d.Coremail.wtweeker@163.com>
	<20100916223909.68e5c557@nehalam>
	<4C935A58.8040208@trash.net>
	<20100917083125.0d565a2d@nehalam>
	<2a014b7c.92ce.12b293c61ba.Coremail.wtweeker@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Patrick McHardy" <kaber@trash.net>, akpm@linux-foundation.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org
To: =?gbk?B?zfXouqOovMbL47v6v8bRp9Gn1LqjqQ==?= <wtweeker@163.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:44997 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756785Ab0ITQov (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Sep 2010 12:44:51 -0400
In-Reply-To: <2a014b7c.92ce.12b293c61ba.Coremail.wtweeker@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Revised version of the original patch in the bug
  https://bugzilla.kernel.org/show_bug.cgi?id=17622
from clark wang <wtweeker@163.com>

I took the opportunity to do some cleanup here.
 * reorder the assignment to make the byte order clear
 * get rid of unnecessary ref/deref and just pass the bytes
 * use sizeof() instead of hard coding size

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---


--- a/net/ipv4/netfilter/nf_nat_snmp_basic.c	2010-09-20 09:05:11.752067965 -0700
+++ b/net/ipv4/netfilter/nf_nat_snmp_basic.c	2010-09-20 09:38:48.518661840 -0700
@@ -885,24 +885,23 @@ static unsigned char snmp_request_decode
  * Fast checksum update for possibly oddly-aligned UDP byte, from the
  * code example in the draft.
  */
-static void fast_csum(__sum16 *csum,
-		      const unsigned char *optr,
-		      const unsigned char *nptr,
-		      int offset)
+static void fast_csum(__sum16 *csum, __u8 from, __u8 to, int offset)
 {
-	unsigned char s[4];
+	__be16 diff[2];
 
 	if (offset & 1) {
-		s[0] = s[2] = 0;
-		s[1] = ~*optr;
-		s[3] = *nptr;
+		s[0] = ~0;
+		s[1] = ~from;
+		s[2] = 0;
+		s[3] = to;
 	} else {
-		s[1] = s[3] = 0;
-		s[0] = ~*optr;
-		s[2] = *nptr;
+		s[0] = ~from;
+		s[1] = ~0;
+		s[2] = to;
+		s[3] = 0;
 	}
 
-	*csum = csum_fold(csum_partial(s, 4, ~csum_unfold(*csum)));
+	*csum = csum_fold(csum_partial(s, sizeof(s), ~csum_unfold(*csum)));
 }
 
 /*
@@ -924,11 +923,8 @@ static inline void mangle_address(unsign
 		*addr = map->to;
 
 		/* Update UDP checksum if being used */
-		if (*check) {
-			fast_csum(check,
-				  &map->from, &map->to, addr - begin);
-
-		}
+		if (*check)
+			fast_csum(check, map->from, map->to, addr - begin);
 
 		if (debug)
 			printk(KERN_DEBUG "bsalg: mapped %pI4 to %pI4\n",

