From: Jens Rosenboom <jens@mcbone.net>
Subject: Re: [PATCH] lib/vsprintf.c: Add "%pI6c" - print pointer as
 compressed ipv6 address
Date: Mon, 17 Aug 2009 17:18:29 +0200
Message-ID: <1250522309.16632.45.camel@fnki-nb00130>
References: <1250230925.6641.92.camel@fnki-nb00130>
	 <20090814.001519.40499255.davem@davemloft.net>
	 <1250237739.16632.12.camel@fnki-nb00130>
	 <20090814.131218.139318801.davem@davemloft.net>
	 <1250349894.4620.5.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, chuck.lever@oracle.com,
	brian.haley@hp.com, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from leia.mcbone.net ([194.97.104.42]:35909 "EHLO leia.mcbone.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756207AbZHQPSm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Aug 2009 11:18:42 -0400
In-Reply-To: <1250349894.4620.5.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2009-08-15 at 08:24 -0700, Joe Perches wrote:
> On Fri, 2009-08-14 at 13:12 -0700, David Miller wrote:
> > I'd say that kernel log messages are OK to tinker with, whereas procfs
> > and sysfs file contents are not.
> 
> Here's a patch to start that tinkering with log messages

Two small optimizations:

diff --git a/lib/vsprintf.c b/lib/vsprintf.c
index 9b79536..a80ef3d 100644
--- a/lib/vsprintf.c
+++ b/lib/vsprintf.c
@@ -677,12 +677,11 @@ static char *ip6_compressed_string(char *p, const
struct in6_addr *addr)
 	int j;
 	int range;
 	unsigned char zerolength[8];
-	int longest = 0;
+	int longest = 1;
 	int colonpos = -1;
 	u16 word;
 	u8 hi;
 	u8 lo;
-	bool printhi;
 	bool needcolon = false;
 	bool useIPv4 = ipv6_addr_v4mapped(addr) || ipv6_addr_is_isatap(addr);
 
@@ -707,8 +706,6 @@ static char *ip6_compressed_string(char *p, const
struct in6_addr *addr)
 			colonpos = i;
 		}
 	}
-	if (colonpos != -1 && zerolength[colonpos] < 2)
-		colonpos = -1;
 
 	for (i = 0; i < range; i++) {
 		if (i == colonpos) {
@@ -729,15 +726,13 @@ static char *ip6_compressed_string(char *p, const
struct in6_addr *addr)
 		word = ntohs(addr->s6_addr16[i]);
 		hi = word >> 8;
 		lo = word & 0xff;
-		printhi = false;
 		if (hi) {
 			if (hi > 0x0f)
 				p = pack_hex_byte(p, hi);
 			else
 				*p++ = hex_asc_lo(hi);
-			printhi = true;
 		}
-		if (printhi || lo > 0x0f)
+		if (hi || lo > 0x0f)
 			p = pack_hex_byte(p, lo);
 		else
 			*p++ = hex_asc_lo(lo);

Also I'm wondering whether it makes sense to pull the format code
checking into all the sub-routines. It might be easier to maintain if it
is all kept together in pointer().

