From: Joe Perches <joe@perches.com>
Subject: Re: linux-next: net tree build failure
Date: Mon, 11 Jan 2010 00:16:12 -0800
Message-ID: <1263197772.1907.44.camel@Joe-Laptop.home>
References: <20100111184205.8d53fe5b.Stephen@Rothwell.id.au>
	 <20100111.000205.164473435.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen@Rothwell.id.au, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Maciej W. Rozycki" <macro@linux-mips.org>,
	H Hartley Sweeten <hartleys@visionengravers.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1050 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752018Ab0AKIQO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jan 2010 03:16:14 -0500
In-Reply-To: <20100111.000205.164473435.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-01-11 at 00:02 -0800, David Miller wrote:
> From: Stephen Rothwell <Stephen@Rothwell.id.au>
> Date: Mon, 11 Jan 2010 18:42:05 +1100
> 
> > Hi all,
> > 
> > Today's linux-next build (powerpc_allnoconfig) failed like this:
> > 
> > lib/lib.a(vsprintf.o): In function `pointer':
> > vsprintf.c:(.text+0x21ba): undefined reference to `byte_rev_table'
> > vsprintf.c:(.text+0x21c2): undefined reference to `byte_rev_table'
> > 
> > Caused by commit bc7259a2ce764ea16200eb9e53f6e136e918d065
> > ("lib/vsprintf.c: Add %pMF to format FDDI bit reversed MAC addresses")
> > from the net tree.
> > 
> > I applied the following fixup patch (and can carry it for a while):
> > (BTW after this patch, CONFIG_BITREVERSE appears to not be used anywhere
> > except where is is selected in Kconfig files.)
> > 
> > From: Stephen Rothwell <sfr@canb.auug.org.au>
> > Date: Mon, 11 Jan 2010 18:37:16 +1100
> > Subject: [PATCH] net: vsprintf now depends on the byte_rev_table
> > 
> > Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
> 
> Thanks I'll apply this and then add a commit which kills
> off CONFIG_BITREVERSE.

Perhaps it'd be better to kill off the use of bitrev in
lib/vsprintf as Maciej thinks it broken.

Maybe use something like this?

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/lib/vsprintf.c b/lib/vsprintf.c
index dc48d2b..e83e3e7 100644
--- a/lib/vsprintf.c
+++ b/lib/vsprintf.c
@@ -25,7 +25,6 @@
 #include <linux/kallsyms.h>
 #include <linux/uaccess.h>
 #include <linux/ioport.h>
-#include <linux/bitrev.h>
 #include <net/addrconf.h>
 
 #include <asm/page.h>		/* for PAGE_SIZE */
@@ -682,19 +681,16 @@ static char *mac_address_string(char *buf, char *end, u8 *addr,
 	char mac_addr[sizeof("xx:xx:xx:xx:xx:xx")];
 	char *p = mac_addr;
 	int i;
-	bool bitrev;
 	char separator;
 
 	if (fmt[1] == 'F') {		/* FDDI canonical format */
-		bitrev = true;
 		separator = '-';
 	} else {
-		bitrev = false;
 		separator = ':';
 	}
 
 	for (i = 0; i < 6; i++) {
-		p = pack_hex_byte(p, bitrev ? bitrev8(addr[i]) : addr[i]);
+		p = pack_hex_byte(p, addr[i]);
 		if (fmt[0] == 'M' && i != 5)
 			*p++ = separator;
 	}
@@ -908,9 +904,7 @@ static char *uuid_string(char *buf, char *end, const u8 *addr,
  *       usual colon-separated hex notation
  * - 'm' For a 6-byte MAC address, it prints the hex address without colons
  * - 'MF' For a 6-byte MAC FDDI address, it prints the address
- *       with a dash-separated hex notation with bit reversed bytes
- * - 'mF' For a 6-byte MAC FDDI address, it prints the address
- *       in hex notation without separators with bit reversed bytes
+ *       with a dash-separated hex notation
  * - 'I' [46] for IPv4/IPv6 addresses printed in the usual way
  *       IPv4 uses dot-separated decimal without leading 0's (1.2.3.4)
  *       IPv6 uses colon separated network-order 16 bit hex with leading 0's




