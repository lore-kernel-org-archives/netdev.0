From: Joe Perches <joe@perches.com>
Subject: Re: [RFC] ipv6: Change %pI6 format to output compacted addresses?
Date: Thu, 13 Aug 2009 12:05:46 -0700
Message-ID: <1250190346.28285.120.camel@Joe-Laptop.home>
References: <1250091560.6641.48.camel@fnki-nb00130>
	 <4A836D6D.1040400@hp.com> <1250174390.6641.89.camel@fnki-nb00130>
	 <4A843EF7.4010700@hp.com> <1250187034.28285.93.camel@Joe-Laptop.home>
	 <48AAB7CB-8EEC-4E30-B821-3E0D84531AAA@oracle.com>
	 <1250187662.28285.97.camel@Joe-Laptop.home>
	 <5D6A7C11-B300-4E39-BBDF-EF18C4BAE419@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Brian Haley <brian.haley@hp.com>, Jens Rosenboom <jens@mcbone.net>,
	Linux Network Developers <netdev@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.LABridge.com ([206.117.136.22]:4111 "EHLO
	mail.perches.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755383AbZHMTF6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2009 15:05:58 -0400
In-Reply-To: <5D6A7C11-B300-4E39-BBDF-EF18C4BAE419@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-08-13 at 14:39 -0400, Chuck Lever wrote:
> On Aug 13, 2009, at 2:21 PM, Joe Perches wrote:
> > On Thu, 2009-08-13 at 14:15 -0400, Chuck Lever wrote:
> >> On Aug 13, 2009, at 2:10 PM, Joe Perches wrote:
> >>> The patch allows "%p6ic" for compressed and "%p6ic4" for compressed
> >>> with ipv4 last u32.
> >> Why do these need to be separate?
> > Just an option.
> > I think it possible somebody will want "1::" instead of "1::0.0.0.0"
> Hrm.
> With %p6ic4, each call site now has to see that it's an IPv6 address,  
> and then decide if the address is a mapped v4 address or not.  It's  
> the same logic everywhere.

I suppose ipv6_addr_v4mapped(addr) could be tested instead

Perhaps this on top of last:

diff --git a/lib/vsprintf.c b/lib/vsprintf.c
index dd02842..7ce34a7 100644
--- a/lib/vsprintf.c
+++ b/lib/vsprintf.c
@@ -25,6 +25,7 @@
 #include <linux/kallsyms.h>
 #include <linux/uaccess.h>
 #include <linux/ioport.h>
+#include <net/ipv6.h>
 
 #include <asm/page.h>		/* for PAGE_SIZE */
 #include <asm/div64.h>
@@ -701,7 +702,7 @@ static char *ip6_compressed_string(char *buf, char *end, u8 *addr,
 	u16 *addr16 = (u16 *)addr;
 	ip6_colon_t colon = DC_START;
 
-	if (fmt[3] == '4') {		/* use :: and ipv4 */
+	if (ipv6_addr_v4mapped((const struct in6_addr *)addr)) {
 		for (i = 0; i < 6; i++) {
 			p = ip6_compress_u16(p, addr16[i], addr16[i+1],
 					     &colon, &needcolon);
@@ -832,8 +833,7 @@ static char *pointer(const char *fmt, char *buf, char *end, void *ptr,
 					 * Formatted IP supported
 					 * 4:	001.002.003.004
 					 * 6:	0001:0203:...:0708
-					 * 6c:	1::708
-					 * 6c4:	1::1.2.3.4
+					 * 6c:	1::708 or 1::1.2.3.4
 					 */
 	case 'I':			/* Contiguous: */
 		if (fmt[1] == '4' || fmt[1] == '6')



