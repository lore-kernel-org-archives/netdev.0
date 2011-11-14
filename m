From: Matti Vaittinen <matti.vaittinen@nsn.com>
Subject: [PATCH RESUBMIT3 net-next 1/2] IPv6 routing, NLM_F_* flag support:
 warn if new route is created without NLM_F_CREATE
Date: Mon, 14 Nov 2011 12:14:49 +0200
Message-ID: <1321265689.1858.27.camel@hakki>
Reply-To: matti.vaittinen@nsn.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from demumfd001.nsn-inter.net ([93.183.12.32]:14970 "EHLO
	demumfd001.nsn-inter.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754461Ab1KNKD3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2011 05:03:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



The support for NLM_F_* flags at IPv6 routing requests.

Warn if NLM_F_CREATE flag is not defined for RTM_NEWROUTE request,
creating new table. Later NLM_F_CREATE may be required for
new route creation.

Patch created against linux-3.2-rc1

Signed-off-by: Matti Vaittinen <Mazziesaccount@gmail.com>
--
diff -uNr Linux-3.2-rc1.orig/net/ipv6/route.c Linux-3.2-rc1.new/net/ipv6/route.c
--- Linux-3.2-rc1.orig/net/ipv6/route.c	2011-11-10 08:44:18.000000000 +0200
+++ Linux-3.2-rc1.new/net/ipv6/route.c	2011-11-10 08:46:15.000000000 +0200
@@ -1230,9 +1230,18 @@
 	if (cfg->fc_metric == 0)
 		cfg->fc_metric = IP6_RT_PRIO_USER;
 
-	table = fib6_new_table(net, cfg->fc_table);
+	err = -ENOBUFS;
+	if (NULL != cfg->fc_nlinfo.nlh &&
+	    !(cfg->fc_nlinfo.nlh->nlmsg_flags&NLM_F_CREATE)) {
+		table = fib6_get_table(net, cfg->fc_table);
+		if (table == NULL) {
+			printk(KERN_WARNING "IPv6: NLM_F_CREATE should be specified when creating new route\n");
+			table = fib6_new_table(net, cfg->fc_table);
+		}
+	} else {
+		table = fib6_new_table(net, cfg->fc_table);
+	}
 	if (table == NULL) {
-		err = -ENOBUFS;
 		goto out;
 	}
 
