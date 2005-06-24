From: Maxime Bizon <mbizon@freebox.fr>
Subject: [PATCH] ipconfig.c: fix dhcp timeout behaviour
Date: Fri, 24 Jun 2005 20:53:09 +0200
Message-ID: <1119639189.14765.154.camel@sakura.staff.proxad.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,

I think there is a small bug in ipconfig.c in case IPCONFIG_DHCP is set
and dhcp is used.

When a DHCPOFFER is received, ip address is kept until we get DHCPACK.
If no ack is received, ic_dynamic() returns negatively, but leaves the
offered ip address in ic_myaddr.

This makes the main loop in ip_auto_config() break and uses the maybe
incomplete configuration.

Not sure if it's the best way to do, but the following trivial patch
correct this. 


Signed-off-by: Maxime Bizon <mbizon@freebox.fr>

--- linux-2.6.12.1/net/ipv4/ipconfig.c.orig	2005-06-22 21:33:05.000000000 +0200
+++ linux-2.6.12.1/net/ipv4/ipconfig.c	2005-06-24 17:55:11.000000000 +0200
@@ -1149,8 +1149,10 @@ static int __init ic_dynamic(void)
 		ic_rarp_cleanup();
 #endif
 
-	if (!ic_got_reply)
+	if (!ic_got_reply) {
+		ic_myaddr = INADDR_NONE;
 		return -1;
+	}
 
 	printk("IP-Config: Got %s answer from %u.%u.%u.%u, ",
 		((ic_got_reply & IC_RARP) ? "RARP" 


-- 
Maxime
