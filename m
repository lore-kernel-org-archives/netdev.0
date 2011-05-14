From: Micha Nelissen <micha@neli.hopto.org>
Subject: [PATCH] output ipconfig info message as one printk
Date: Sat, 14 May 2011 23:45:19 +0200
Message-ID: <1305409519-25404-1-git-send-email-micha@neli.hopto.org>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from edu-smtp-02.edutel.nl ([88.159.1.172]:49128 "EHLO
	edu-smtp-02.edutel.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754722Ab1ENVpm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 May 2011 17:45:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

the "ip-config complete" message with ip address etc is output using
many printks. When using the netconsole, and multiple agents are booting
(and logging their boot) simultaneously, the syslog of the receiving
host gets very messy, as the individual printks are interleaved.
Combining the many printks into one printk improves syslog readability.


Index: atom-linux/net/ipv4/ipconfig.c
===================================================================
--- atom-linux/net/ipv4/ipconfig.c	(revision 1493)
+++ atom-linux/net/ipv4/ipconfig.c	(revision 1494)
@@ -1363,6 +1363,9 @@
 #ifdef IPCONFIG_DYNAMIC
 	int retries = CONF_OPEN_RETRIES;
 #endif
+#ifndef IPCONFIG_SILENT
+	char mtubuf[16];
+#endif
 	int err;
 
 #ifdef CONFIG_PROC_FS
@@ -1477,19 +1480,17 @@
 	/*
 	 * Clue in the operator.
 	 */
-	printk("IP-Config: Complete:");
-	printk("\n     device=%s", ic_dev->name);
-	printk(", addr=%pI4", &ic_myaddr);
-	printk(", mask=%pI4", &ic_netmask);
-	printk(", gw=%pI4", &ic_gateway);
-	printk(",\n     host=%s, domain=%s, nis-domain=%s",
-	       utsname()->nodename, ic_domain, utsname()->domainname);
-	printk(",\n     bootserver=%pI4", &ic_servaddr);
-	printk(", rootserver=%pI4", &root_server_addr);
-	printk(", rootpath=%s", root_server_path);
 	if (ic_dev_mtu)
-		printk(", mtu=%d", ic_dev_mtu);
-	printk("\n");
+		snprintf(mtubuf, sizeof(mtubuf), "mtu=%d, ", ic_dev_mtu);
+	else
+		mtubuf[0] = '\0';
+	printk( "IP-Config: Complete:\n"
+		"     device=%s, addr=%pI4, mask=%pI4, gw=%pI4,\n"
+		"     %shost=%s, domain=%s, nis-domain=%s,\n"
+		"     bootserver=%pI4, rootserver=%pI4, rootpath=%s\n",
+		ic_dev->name, &ic_myaddr, &ic_netmask, &ic_gateway,
+		mtubuf, utsname()->nodename, ic_domain, utsname()->domainname,
+		&ic_servaddr, &root_server_addr, root_server_path);
 #endif /* !SILENT */
 
 	return 0;
