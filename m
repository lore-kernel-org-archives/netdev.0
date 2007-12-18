From: Simon Horman <horms@verge.net.au>
Subject: Update ip command line processing
Date: Tue, 18 Dec 2007 17:57:32 +0900
Message-ID: <20071218085730.GA10765@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Amos Waterland <apw@us.ibm.com>, David Miller <davem@davemloft.net>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752885AbXLRI5r@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Recently the documentation in Documentation/nfsroot.txt was
update to note that in fact ip=off and ip=::::::off as the
latter is ignored and the default (on) is used.

This was certainly a step in the direction of reducing confusion.
But it seems to me that the code ought to be fixed up so that
ip=::::::off actually turns off ip autoconfiguration.

This patch also notes more specifically that ip=on (aka ip=::::::on)
is the default.

Cc: Amos Waterland <apw@us.ibm.com>
Signed-off-by: Simon Horman <horms@verge.net.au>

Index: net-2.6.25/net/ipv4/ipconfig.c
===================================================================
--- net-2.6.25.orig/net/ipv4/ipconfig.c	2007-12-18 17:45:07.000000000 +0900
+++ net-2.6.25/net/ipv4/ipconfig.c	2007-12-18 17:45:52.000000000 +0900
@@ -1414,9 +1414,16 @@ late_initcall(ip_auto_config);
  */
 static int __init ic_proto_name(char *name)
 {
+	if (!name) {
+		return 1;
+	}
 	if (!strcmp(name, "on") || !strcmp(name, "any")) {
 		return 1;
 	}
+	if (!strcmp(name, "off") || !strcmp(name, "none")) {
+		ic_enable = 0;
+		return 1;
+	}
 #ifdef CONFIG_IP_PNP_DHCP
 	else if (!strcmp(name, "dhcp")) {
 		ic_proto_enabled &= ~IC_RARP;
@@ -1451,12 +1458,6 @@ static int __init ip_auto_config_setup(c
 
 	ic_set_manually = 1;
 
-	ic_enable = (*addrs &&
-		(strcmp(addrs, "off") != 0) &&
-		(strcmp(addrs, "none") != 0));
-	if (!ic_enable)
-		return 1;
-
 	if (ic_proto_name(addrs))
 		return 1;
 
Index: net-2.6.25/Documentation/nfsroot.txt
===================================================================
--- net-2.6.25.orig/Documentation/nfsroot.txt	2007-12-18 17:46:47.000000000 +0900
+++ net-2.6.25/Documentation/nfsroot.txt	2007-12-18 17:48:51.000000000 +0900
@@ -97,10 +97,6 @@ ip=<client-ip>:<server-ip>:<gw-ip>:<netm
   autoconfiguration will take place.  The most common way to use this
   is "ip=dhcp".
 
-  Note that "ip=off" is not the same thing as "ip=::::::off", because in
-  the latter autoconfiguration will take place if any of DHCP, BOOTP or RARP
-  are compiled in the kernel.
