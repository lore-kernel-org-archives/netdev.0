From: Matti Vaittinen <matti.vaittinen@nsn.com>
Subject: [PATCH RESUBMIT2 net-next 1/2] IPv6 routing, NLM_F_* flag support:
 warn if NEWROUTE lacks of both CREATE and REPLACE flags
Date: Mon, 14 Nov 2011 09:10:11 +0200
Message-ID: <1321254611.23935.15.camel@hakki>
Reply-To: matti.vaittinen@nsn.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from demumfd001.nsn-inter.net ([93.183.12.32]:13150 "EHLO
	demumfd001.nsn-inter.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751384Ab1KNG6X convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2011 01:58:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The support for NLM_F_* flags at IPv6 routing requests.

If RTM_NEWROUTE request, has neither NLM_F_CREATE, nor NLM_F_REPLACE
specified, a warning is printed but no error is returned.

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
+			printk(KERN_WARNING "NLM_F_CREATE should be specified when creating new rt\n");
+			table = fib6_new_table(net, cfg->fc_table);
+		}
+	} else {
+		table = fib6_new_table(net, cfg->fc_table);
+	}
 	if (table == NULL) {
-		err = -ENOBUFS;
 		goto out;
 	}
 
