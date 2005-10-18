From: Maxime Bizon <mbizon@freebox.fr>
Subject: [PATCH] ipconfig.c: fix "dhcp server takes precedence over bootp
	header one"
Date: Tue, 18 Oct 2005 19:05:19 +0200
Message-ID: <1129655119.4133.71.camel@sakura.staff.proxad.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hello,

I was unable to use nfs root with a dhcp server that does not fill the
"saddr" field in the bootp header (kernel then tries RPC on 0.0.0.0).

The ipconfig code states that the dhcp server_id takes precedence over
bootp header, but I think the check is misplaced as it is done only for
DHCPOFFER.

The following patch fixes the problem.


Signed-off-by: Maxime Bizon <mbizon@freebox.fr>

--- linux-2.6.13.4/net/ipv4/ipconfig.c.orig	2005-10-18 18:11:54.000000000 +0200
+++ linux-2.6.13.4/net/ipv4/ipconfig.c	2005-10-18 18:22:18.000000000 +0200
@@ -959,13 +959,6 @@
 				printk(" by server %u.%u.%u.%u\n",
 				       NIPQUAD(ic_servaddr));
 #endif
-				/* The DHCP indicated server address takes
-				 * precedence over the bootp header one if
-				 * they are different.
-				 */
-				if ((server_id != INADDR_NONE) &&
-				    (b->server_ip != server_id))
-					b->server_ip = ic_servaddr;
 				break;
 
 			case DHCPACK:
@@ -982,6 +975,14 @@
 				goto drop_unlock;
 			};
 
+			/* The DHCP indicated server address takes
+			 * precedence over the bootp header one if
+			 * they are different.
+			 */
+			if ((server_id != INADDR_NONE) &&
+			    (b->server_ip != server_id))
+				b->server_ip = ic_servaddr;
+
 			ic_dhcp_msgtype = mt;
 
 		}

-- 
Maxime
