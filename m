From: Matti Vaittinen <matti.vaittinen@nsn.com>
Subject: [PATCH RESUBMITTED net-next 1/2] IPv6 - support for NLM_F_* flags
 at IPv6 routing requests
Date: Thu, 10 Nov 2011 12:06:58 +0200
Message-ID: <1320919619.17667.0.camel@hakki>
Reply-To: matti.vaittinen@nsn.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: ext David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from demumfd002.nsn-inter.net ([93.183.12.31]:11241 "EHLO
	demumfd002.nsn-inter.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755458Ab1KJJzJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Nov 2011 04:55:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The support for NLM_F_* flags at IPv6 routing requests.

If NLM_F_CREATE flag is not defined for RTM_NEWROUTE request,
warning is printed, but no error is returned. Instead new route is
added.

Exception is when NLM_F_REPLACE flag is given without NLM_F_CREATE, and
no matching route is found. In this case it should be safe to assume
that the request issuer is familiar with NLM_F_* flags, and does really
not want route to be created.

Specifying NLM_F_REPLACE flag will now make the kernel to search for
matching route, and replace it with new one. If no route is found and
NLM_F_CREATE is specified as well, then new route is created.

Also, specifying NLM_F_EXCL will yield returning of error if matching
route
is found.

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
 




-- 
Matti Vaittinen
+358 504863070
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Told a UDP joke the other night...
...but I'm not sure everyone got it...
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
