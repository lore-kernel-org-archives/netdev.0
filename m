From: Matti Vaittinen <matti.vaittinen@nsn.com>
Subject: [PATCH 1/2] IPv6 - support for NLM_F_* flags at IPv6 routing
 requests
Date: Thu, 03 Nov 2011 09:16:12 +0200
Message-ID: <1320304573.2755.0.camel@lakki>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: davem <davem@davemloft.net>, shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from demumfd001.nsn-inter.net ([93.183.12.32]:10792 "EHLO
	demumfd001.nsn-inter.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754574Ab1KCHRJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2011 03:17:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The support for NLM_F_* flags at IPv6 routing requests.

If NLM_F_CREATE flag is not defined for RTM_NEWROUTE request,
warning is printed, but no error is returned. Instead new route is added.

Exception is when NLM_F_REPLACE flag is given without NLM_F_CREATE, and
no matching route is found. In this case it should be safe to assume
that the request issuer is familiar with NLM_F_* flags, and does really
not want route to be created.

Specifying NLM_F_REPLACE flag will now make the kernel to search for
matching route, and replace it with new one. If no route is found and
NLM_F_CREATE is specified as well, then new route is created.

Also, specifying NLM_F_EXCL will yield returning of error if matching route
is found.

Patch is created against linux-3.1-rc4



Signed-off-by: Matti Vaittinen <Mazziesaccount@gmail.com>


diff -uNr linux-3.1-rc4.orig/net/ipv6/route.c linux-3.1-rc4.new/net/ipv6/route.c
--- linux-3.1-rc4.orig/net/ipv6/route.c	2011-11-01 14:01:55.000000000 +0200
+++ linux-3.1-rc4.new/net/ipv6/route.c	2011-11-03 08:35:32.000000000 +0200
@@ -1223,9 +1223,18 @@
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
 
