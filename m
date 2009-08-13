From: Brian Haley <brian.haley@hp.com>
Subject: Re: [RFC] ipv6: Change %pI6 format to output compacted addresses?
Date: Thu, 13 Aug 2009 12:27:35 -0400
Message-ID: <4A843EF7.4010700@hp.com>
References: <1250091560.6641.48.camel@fnki-nb00130>	 <4A836D6D.1040400@hp.com> <1250174390.6641.89.camel@fnki-nb00130>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Network Developers <netdev@vger.kernel.org>
To: Jens Rosenboom <jens@mcbone.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:22873 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751569AbZHMQ1r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2009 12:27:47 -0400
In-Reply-To: <1250174390.6641.89.camel@fnki-nb00130>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jens Rosenboom wrote:
>> Anyways, can you try this patch, it's less than 40 new lines :)
>> It might be good enough, but could probably use some help.
> 
> For a start, it didn't even compile. ;-)

It did on net-next-2.6 last night, weird.

> Here is a new version that also
> fixes
> 
> - Leave %pi6 alone
> - Don't compress a single :0:
> - Do output 0
> 
> The results and also the remaining issues can be seen with the attached
> test program, that also exposes a bug in glibc for v4-mapped addresses
> from 0/16.
> 
> To fully conform to the cited draft, we would still have to implement
> v4-mapped and also check whether a second run of zeros would be longer
> than the first one, although the draft also suggests that operators
> should avoid using this kind of addresses, so maybe this second issue
> can be neglected.

Yes, the "compress the most zeros" would be harder, and require two
passes over the address.  I had to cut corners somewhere :)

And regarding v4-mapped, the easy fix to that is just detect it and
call the IPv4 routine.  The attached patch does that, but without the
::ffff:

> diff --git a/lib/vsprintf.c b/lib/vsprintf.c
> index 756ccaf..5710c65 100644
> --- a/lib/vsprintf.c
> +++ b/lib/vsprintf.c
> @@ -652,13 +652,53 @@ static char *ip6_addr_string(char *buf, char *end,
> u8 *addr,
>  {
>  	char ip6_addr[8 * 5]; /* (8 * 4 hex digits), 7 colons and trailing
> zero */
>  	char *p = ip6_addr;
> -	int i;
> +	int i, needcolon = 0, printhi;
> +	u16 *addr16 = (u16 *)addr;
> +	enum { DC_START, DC_MIDDLE, DC_DONE } colon = DC_START;
> +
> +	/* omit leading zeros and shorten using "::" */
>  
> -	for (i = 0; i < 8; i++) {
> -		p = pack_hex_byte(p, addr[2 * i]);
> -		p = pack_hex_byte(p, addr[2 * i + 1]);
> -		if (!(spec.flags & SPECIAL) && i != 7)
> +	if (!(spec.flags & SPECIAL)) {
> +		for (i = 0; i < 8; i++) {
> +			if (addr16[i] == 0 && addr16[i+1] == 0 && colon == DC_START) {

This will access the array out-of-bounds when i=7.

Another hack below.

-Brian


diff --git a/lib/vsprintf.c b/lib/vsprintf.c
index 756ccaf..ba70f2a 100644
--- a/lib/vsprintf.c
+++ b/lib/vsprintf.c
@@ -647,25 +647,6 @@ static char *mac_address_string(char *buf, char *end, u8 *addr,
 	return string(buf, end, mac_addr, spec);
 }
 
-static char *ip6_addr_string(char *buf, char *end, u8 *addr,
-				struct printf_spec spec)
-{
-	char ip6_addr[8 * 5]; /* (8 * 4 hex digits), 7 colons and trailing zero */
-	char *p = ip6_addr;
-	int i;
-
-	for (i = 0; i < 8; i++) {
-		p = pack_hex_byte(p, addr[2 * i]);
-		p = pack_hex_byte(p, addr[2 * i + 1]);
-		if (!(spec.flags & SPECIAL) && i != 7)
-			*p++ = ':';
-	}
-	*p = '\0';
-	spec.flags &= ~SPECIAL;
-
-	return string(buf, end, ip6_addr, spec);
-}
-
 static char *ip4_addr_string(char *buf, char *end, u8 *addr,
 				struct printf_spec spec)
 {
@@ -688,6 +669,73 @@ static char *ip4_addr_string(char *buf, char *end, u8 *addr,
 	return string(buf, end, ip4_addr, spec);
 }
 
+static char *ip6_addr_string(char *buf, char *end, u8 *addr,
+				struct printf_spec spec)
+{
+	char ip6_addr[8 * 5]; /* (8 * 4 hex digits), 7 colons and trailing zero */
+	char *p = ip6_addr;
+	int i, needcolon, printhi;
+	u16 *addr16 = (u16 *)addr;
+	u32 *addr32 = (u32 *)addr;
+	enum { DC_START, DC_MIDDLE, DC_DONE } colon = DC_START;
+
+	if (!(spec.flags & SPECIAL)) {
+		/* omit leading zeros and shorten using "::" */
+
+		/* v4mapped */
+		if ((addr32[0] | addr32[1] |
+		    (addr32[2] ^ htonl(0x0000ffff))) == 0)
+			return ip4_addr_string(buf, end, &addr[12], spec);
+
+		needcolon = 0;
+		for (i = 0; i < 8; i++) {
+			if (addr16[i] == 0 && i < 7 && addr16[i+1] == 0 &&
+			    colon == DC_START) {
+				colon = DC_MIDDLE;
+				continue;
+			}
+			if (colon == DC_MIDDLE) {
+				if (addr16[i] == 0)
+					continue;
+				colon = DC_DONE;
+				*p++ = ':';
+				*p++ = ':';
+			}  else if (needcolon)
+				*p++ = ':';
+			printhi = 0;
+			if (addr[2 * i]) {
+				if (addr[2 * i] > 0x0f)
+					p = pack_hex_byte(p, addr[2 * i]);
+				else
+					*p++ = hex_asc_lo(addr[2 * i]);
+				printhi++;
+			}
+			/*
+		 	* If we printed the high-order bits we must print the
+		 	* low-order ones, even if they're all zeros.
+		 	*/
+			if (printhi || addr[2 * i + 1] > 0x0f)
+				p = pack_hex_byte(p, addr[2 * i + 1]);
+			else 
+				*p++ = hex_asc_lo(addr[2 * i + 1]);
+			needcolon++;
+		}
+		if (colon == DC_MIDDLE) {
+			*p++ = ':';
+			*p++ = ':';
+		}
+	} else {
+		for (i = 0; i < 8; i++) {
+			p = pack_hex_byte(p, addr[2 * i]);
+			p = pack_hex_byte(p, addr[2 * i + 1]);
+		}
+	}
+	*p = '\0';
+	spec.flags &= ~SPECIAL;
+
+	return string(buf, end, ip6_addr, spec);
+}
+
 /*
  * Show a '%p' thing.  A kernel extension is that the '%p' is followed
  * by an extra set of alphanumeric characters that are extended format
