From: Andi Kleen <ak@muc.de>
Subject: [PATCH] Remove copied inet_aton code in bond_main.c
Date: Wed, 18 Jun 2003 13:09:46 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030618110946.GA6851@averell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


According to a report the my_inet_aton code in bond_main.c is copied
from 4.4BSD, but it doesn't carry a BSD copyright license. In addition
it is somewhat redundant with the standard in_aton.  Convert it 
to use the linux function.

Error handling is a bit worse than before, but not much.

Patch for 2.5 bonding. The 2.4 version has the same problem, but afaik
it is scheduled to be replaced by the 2.5 codebase anyways.

-Andi

--- linux/drivers/net/bonding/bond_main.c-o	2003-06-14 23:42:51.000000000 +0200
+++ linux/drivers/net/bonding/bond_main.c	2003-06-18 13:03:04.000000000 +0200
@@ -390,6 +390,7 @@
 #include <linux/timer.h>
 #include <linux/socket.h>
 #include <linux/ctype.h>
+#include <linux/inet.h>
 #include <asm/system.h>
 #include <asm/bitops.h>
 #include <asm/io.h>
@@ -2797,84 +2798,6 @@
 	mod_timer(&bond->arp_timer, next_timer);
 }
 
-typedef uint32_t in_addr_t;
-
-int
-my_inet_aton(char *cp, unsigned long *the_addr) {
-	static const in_addr_t max[4] = { 0xffffffff, 0xffffff, 0xffff, 0xff };
-	in_addr_t val;
-	char c;
-	union iaddr {
-	  uint8_t bytes[4];
-	  uint32_t word;
-	} res;
-	uint8_t *pp = res.bytes;
-	int digit,base;
-
-	res.word = 0;
-
-	c = *cp;
-	for (;;) {
-		/*
-		 * Collect number up to ``.''.
-		 * Values are specified as for C:
-		 * 0x=hex, 0=octal, isdigit=decimal.
-		 */
-		if (!isdigit(c)) goto ret_0;
-		val = 0; base = 10; digit = 0;
-		for (;;) {
-			if (isdigit(c)) {
-				val = (val * base) + (c - '0');
-				c = *++cp;
-				digit = 1;
-			} else {
-				break;
-			}
-		}
-		if (c == '.') {
-			/*
-			 * Internet format:
-			 *	a.b.c.d
-			 *	a.b.c	(with c treated as 16 bits)
-			 *	a.b	(with b treated as 24 bits)
-			 */
-			if (pp > res.bytes + 2 || val > 0xff) {
-				goto ret_0;
-			}
-			*pp++ = val;
-			c = *++cp;
-		} else
-			break;
-	}
-	/*
-	 * Check for trailing characters.
-	 */
-	if (c != '\0' && (!isascii(c) || !isspace(c))) {
-		goto ret_0;
-	}
-	/*
-	 * Did we get a valid digit?
-	 */
-	if (!digit) {
-		goto ret_0;
-	}
-
-	/* Check whether the last part is in its limits depending on
-	   the number of parts in total.  */
-	if (val > max[pp - res.bytes]) {
-		goto ret_0;
-	}
-
-	if (the_addr != NULL) {
-		*the_addr = res.word | htonl (val);
-	}
-
-	return (1);
-
-ret_0:
-	return (0);
-}
-
 static int bond_sethwaddr(struct net_device *master, struct net_device *slave)
 {
 #ifdef BONDING_DEBUG
@@ -3958,15 +3881,18 @@
         for (arp_ip_count=0 ;
              (arp_ip_count < MAX_ARP_IP_TARGETS) && arp_ip_target[arp_ip_count];
               arp_ip_count++ ) {
-                /* TODO: check and log bad ip address */
-                if (my_inet_aton(arp_ip_target[arp_ip_count],
-                                 &arp_target[arp_ip_count]) == 0) {
+		/* not complete check, but should be good enough to
+		   catch mistakes */
+		if (!isdigit(arp_ip_target[arp_ip_count][0])) { 
                         printk(KERN_WARNING
                                "bonding_init(): bad arp_ip_target module "
                                "parameter (%s), ARP monitoring will not be "
                                "performed\n",
                                arp_ip_target[arp_ip_count]);
                         arp_interval = 0;
+		} else { 
+			u32 ip = in_aton(arp_ip_target[arp_ip_count]); 
+			*(u32 *)(arp_ip_target[arp_ip_count]) = ip;
 		}
         }
 
