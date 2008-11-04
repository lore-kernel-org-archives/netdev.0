From: David Miller <davem@davemloft.net>
Subject: Re: %pI4 vs. NIPQUAD: %pI4 doing it wrong?
Date: Mon, 03 Nov 2008 17:07:46 -0800 (PST)
Message-ID: <20081103.170746.110029074.davem@davemloft.net>
References: <15026.1225760729@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, harvey.harrison@gmail.com
To: fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41186
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752171AbYKDBIK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2008 20:08:10 -0500
In-Reply-To: <15026.1225760729@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Vosburgh <fubar@us.ibm.com>
Date: Mon, 03 Nov 2008 17:05:29 -0800

> 
> 	Running the latest net-next-2.6, I notice that %pI4 is
> apparently printing IPv4 addresses incorrectly (and differently than the
> NIPQUAD it replaced).
> 
> 	The following is excerpted from the bonding driver's
> /proc/net/bonding/bond0 status file:
> 
> [...]
> ARP IP target/s (n.n.n.n form): 01.0.1.1 (10.0.1.1), 01.02.03.04 (10.20.30.40)
> 
> 	The first (incorrect) values are from %pI4, the ones in
> parentheses (which are correct) I added as a check using NIPQUAD with
> this patch:

Harvey posted a fix for this today, which I'll apply soon.

Thanks for checking the archives before reporting a problem.

--------------------

Subject: Re: [PATCH 3/7] net: replace NIPQUAD() in net/netfilter/
From: Harvey Harrison <harvey.harrison@gmail.com>
To: Julius Volz <julius.volz@gmail.com>
Cc: David Miller <davem@davemloft.net>, linux-netdev <netdev@vger.kernel.org>
Date: Mon, 03 Nov 2008 09:43:16 -0800
X-Mailer: Evolution 2.24.1 

On Mon, 2008-11-03 at 17:56 +0100, Julius Volz wrote:
> Hi,
> I just noticed that this breaks IPv4 addresses in IPVS debug output
> (didn't check in other places). It seems that during integer to ASCII
> conversion, the converted digits are output the wrong way around (not
> endianness though). For example, 10.0.0.254 is output as 01.0.0.452.
> Could something be wrong with ip4_addr_string() or put_dec_trunc() in
> lib/vsprintf.c?

Mea Culpa, I was testing with a too-simple case, it does reverse the digits,
can you try this:

From: Harvey Harrison <harvey.harrison@gmail.com>
[PATCH] printk: ipv4 address digits printed in reverse order

put_dec_trunc prints the digits in reverse order and is reversed
inside number(). Continue using put_dec_trunc, but reverse each quad
in ip4_addr_string.

[Noticed by Julius Volz]

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
 lib/vsprintf.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/lib/vsprintf.c b/lib/vsprintf.c
index dd7cc7f..6897724 100644
--- a/lib/vsprintf.c
+++ b/lib/vsprintf.c
@@ -620,11 +620,15 @@ static char *ip4_addr_string(char *buf, char *end, u8 *addr, int field_width,
 			 int precision, int flags)
 {
 	char ip4_addr[4 * 4]; /* (4 * 3 decimal digits), 3 dots and trailing zero */
+	char temp[3];	/* hold each IP quad in reverse order */
 	char *p = ip4_addr;
-	int i;
+	int i, digits;
 
 	for (i = 0; i < 4; i++) {
-		p = put_dec_trunc(p, addr[i]);
+		digits = put_dec_trunc(temp, addr[i]) - temp;
+		/* reverse the digits in the quad */
+		while (digits--)
+			*p++ = temp[digits];
 		if (i != 3)
 			*p++ = '.';
 	}
-- 
1.6.0.3.756.gb776d



