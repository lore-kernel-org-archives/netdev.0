From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [Bugme-new] [Bug 17622] New: snmp trap ALG issue
Date: Thu, 16 Sep 2010 22:39:09 -0700
Message-ID: <20100916223909.68e5c557@nehalam>
References: <20100914163208.2ba165ca.akpm@linux-foundation.org>
	<bug-17622-10286@https.bugzilla.kernel.org/>
	<6029e4.25bb.12b1d97358d.Coremail.wtweeker@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>, kaber@trash.net
To: =?gbk?B?zfXouqOovMbL47v6v8bRp9Gn1LqjqQ==?= <wtweeker@163.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:56234 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754046Ab0IQFjM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Sep 2010 01:39:12 -0400
In-Reply-To: <6029e4.25bb.12b1d97358d.Coremail.wtweeker@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I think the bug should be fixed by removing the potentially buggy
fast_csum() in nf_nat_snmp_basic and just using the existing
generic code. The following is compile tested only..

Subject: [PATCH] nf_nat_snmp: use existing checksum update code

The fast_csum() in NAT code for processing SNMP trap is buggy 
(see https://bugzilla.kernel.org/show_bug.cgi?id=17622)
Replace it by using the existing checksum replacement code;
it means adding a new csum_replace1() inline wrapper.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 include/net/checksum.h                 |    5 +++++
 net/ipv4/netfilter/nf_nat_snmp_basic.c |   31 ++-----------------------------
 2 files changed, 7 insertions(+), 29 deletions(-)

--- a/net/ipv4/netfilter/nf_nat_snmp_basic.c	2010-09-16 22:17:21.660806917 -0700
+++ b/net/ipv4/netfilter/nf_nat_snmp_basic.c	2010-09-16 22:32:52.084075112 -0700
@@ -882,30 +882,6 @@ static unsigned char snmp_request_decode
 }
 
 /*
- * Fast checksum update for possibly oddly-aligned UDP byte, from the
- * code example in the draft.
- */
-static void fast_csum(__sum16 *csum,
-		      const unsigned char *optr,
-		      const unsigned char *nptr,
-		      int offset)
-{
-	unsigned char s[4];
-
-	if (offset & 1) {
-		s[0] = s[2] = 0;
-		s[1] = ~*optr;
-		s[3] = *nptr;
-	} else {
-		s[1] = s[3] = 0;
-		s[0] = ~*optr;
-		s[2] = *nptr;
-	}
-
-	*csum = csum_fold(csum_partial(s, 4, ~csum_unfold(*csum)));
-}
-
-/*
  * Mangle IP address.
  * 	- begin points to the start of the snmp messgae
  *      - addr points to the start of the address
@@ -924,11 +900,8 @@ static inline void mangle_address(unsign
 		*addr = map->to;
 
 		/* Update UDP checksum if being used */
-		if (*check) {
-			fast_csum(check,
-				  &map->from, &map->to, addr - begin);
-
-		}
+		if (*check)
+			csum_replace1(check, map->from, map->to);
 
 		if (debug)
 			printk(KERN_DEBUG "bsalg: mapped %pI4 to %pI4\n",
--- a/include/net/checksum.h	2010-09-16 22:31:27.524503074 -0700
+++ b/include/net/checksum.h	2010-09-16 22:32:09.934282263 -0700
@@ -106,6 +106,11 @@ static inline void csum_replace2(__sum16
 	csum_replace4(sum, (__force __be32)from, (__force __be32)to);
 }
 
+static inline void csum_replace1(__sum16 *sum, __u8 from, __u8 to)
+{
+	csum_replace4(sum, (__force __be32)from, (__force __be32)to);
+}
+
 struct sk_buff;
 extern void inet_proto_csum_replace4(__sum16 *sum, struct sk_buff *skb,
 				     __be32 from, __be32 to, int pseudohdr);
