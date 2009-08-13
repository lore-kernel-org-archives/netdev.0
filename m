From: Brian Haley <brian.haley@hp.com>
Subject: Re: [RFC] ipv6: Change %pI6 format to output compacted addresses?
Date: Wed, 12 Aug 2009 21:33:33 -0400
Message-ID: <4A836D6D.1040400@hp.com>
References: <1250091560.6641.48.camel@fnki-nb00130>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Network Developers <netdev@vger.kernel.org>
To: Jens Rosenboom <jens@mcbone.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:49094 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751696AbZHMBde (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2009 21:33:34 -0400
In-Reply-To: <1250091560.6641.48.camel@fnki-nb00130>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jens Rosenboom wrote:
> Currently the output looks like 2001:0db8:0000:0000:0000:0000:0000:0001
> which might be compacted to 2001:db8::1. The code to do this could be
> adapted from inet_ntop in glibc, which would add about 80 lines to
> lib/vsprintf.c. How do you guys value the tradeoff between more readable
> logging and increased kernel size?
> 
> This was already mentioned in
> http://kerneltrap.org/mailarchive/linux-netdev/2008/11/25/4231684 but
> noone seems to have taken up on it.

I think if any changes are made they should try and follow:

http://www.ietf.org/id/draft-kawamura-ipv6-text-representation-03.txt

For one thing, the code today doesn't print things like the v4-mapped
address correctly.

Anyways, can you try this patch, it's less than 40 new lines :)
It might be good enough, but could probably use some help.

-Brian


diff --git a/lib/vsprintf.c b/lib/vsprintf.c
index 756ccaf..58602ba 100644
--- a/lib/vsprintf.c
+++ b/lib/vsprintf.c
@@ -652,13 +652,46 @@ static char *ip6_addr_string(char *buf, char *end, u8 *addr,
 {
 	char ip6_addr[8 * 5]; /* (8 * 4 hex digits), 7 colons and trailing zero */
 	char *p = ip6_addr;
-	int i;
+	int i, needcolon = 0, printhi;
+	u16 *addr16 = (u16 *)addr;
+	enum { DC_START, DC_MIDDLE, DC_DONE } dcolon = DC_START;
+
+	/* omit leading zeros and shorten using "::" */
 
 	for (i = 0; i < 8; i++) {
-		p = pack_hex_byte(p, addr[2 * i]);
-		p = pack_hex_byte(p, addr[2 * i + 1]);
-		if (!(spec.flags & SPECIAL) && i != 7)
-			*p++ = ':';
+		if (!(spec.flags & SPECIAL)) {
+			if (addr16[i] == 0 && colon < DC_DONE) {
+				colon = DC_MIDDLE;
+				continue;
+			}
+			if (colon == DC_MIDDLE) {
+				colon = DC_DONE;
+				*p++ = ':';
+				*p++ = ':';
+			}  else if (needcolon)
+				*p++ = ':';
+		}
+		printhi = 0;
+		if (addr[2 * i]) {
+			if (addr[2 * i] > 0x0f)
+				p = pack_hex_byte(p, addr[2 * i]);
+			else
+				*p++ = hex_asc_lo(addr[2 * i]);
+			printhi++;
+		}
+		/*
+		 * If we printed the high-order bits we must print the
+		 * low-order ones, even if they're all zeros.
+		 */
+		if (printhi || addr[2 * i + 1] > 0x0f)
+			p = pack_hex_byte(p, addr[2 * i + 1]);
+		else if (addr[2 * i + 1])
+			*p++ = hex_asc_lo(addr[2 * i + 1]);
+		needcolon++;
+	}
+	if (colon == DC_MIDDLE) {
+		*p++ = ':';
+		*p++ = ':';
 	}
 	*p = '\0';
 	spec.flags &= ~SPECIAL;
