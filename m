From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 1/3] l2tp: auto load type modules
Date: Wed, 23 Sep 2015 21:33:34 -0700
Message-ID: <20150924043500.997309588@networkplumber.org>
References: <20150924043333.231895827@networkplumber.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: jchapman@katalix.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:34880 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750835AbbIXEet (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2015 00:34:49 -0400
Received: by pacfv12 with SMTP id fv12so61841593pac.2
        for <netdev@vger.kernel.org>; Wed, 23 Sep 2015 21:34:48 -0700 (PDT)
Content-Disposition: inline; filename=l2tp-eth-alias.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It should not be necessary to do explicit module loading when
configuring L2TP. Modules should be loaded as needed instead
(as is done already with netlink and other tunnel types).

This patch adds a new module alias type and code to load
the sub module on demand.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


--- a/net/l2tp/l2tp_core.h	2015-09-23 21:23:43.324539500 -0700
+++ b/net/l2tp/l2tp_core.h	2015-09-23 21:27:36.049615188 -0700
@@ -321,4 +321,7 @@ do {									\
 #define l2tp_dbg(ptr, type, fmt, ...)					\
 	l2tp_printk(ptr, type, pr_debug, fmt, ##__VA_ARGS__)
 
+#define MODULE_ALIAS_L2TP_PWTYPE(type) \
+	MODULE_ALIAS("net-l2tp-type-" __stringify(type))
+
 #endif /* _L2TP_CORE_H_ */
--- a/net/l2tp/l2tp_eth.c	2015-09-23 21:23:43.324539500 -0700
+++ b/net/l2tp/l2tp_eth.c	2015-09-23 21:23:43.320539481 -0700
@@ -358,3 +358,4 @@ MODULE_LICENSE("GPL");
 MODULE_AUTHOR("James Chapman <jchapman@katalix.com>");
 MODULE_DESCRIPTION("L2TP ethernet pseudowire driver");
 MODULE_VERSION("1.0");
+MODULE_ALIAS_L2TP_PWTYPE(5);
--- a/net/l2tp/l2tp_netlink.c	2015-09-23 21:23:43.324539500 -0700
+++ b/net/l2tp/l2tp_netlink.c	2015-09-23 21:27:47.033665958 -0700
@@ -576,6 +576,13 @@ static int l2tp_nl_cmd_session_create(st
 	if (info->attrs[L2TP_ATTR_MRU])
 		cfg.mru = nla_get_u16(info->attrs[L2TP_ATTR_MRU]);
 
+#ifdef CONFIG_MODULES
+	if (l2tp_nl_cmd_ops[cfg.pw_type] == NULL) {
+		genl_unlock();
+		request_module("net-l2tp-type-%u", cfg.pw_type);
+		genl_lock();
+	}
+#endif
 	if ((l2tp_nl_cmd_ops[cfg.pw_type] == NULL) ||
 	    (l2tp_nl_cmd_ops[cfg.pw_type]->session_create == NULL)) {
 		ret = -EPROTONOSUPPORT;
--- a/net/l2tp/l2tp_ppp.c	2015-09-23 21:23:43.324539500 -0700
+++ b/net/l2tp/l2tp_ppp.c	2015-09-23 21:23:43.320539481 -0700
@@ -1863,3 +1863,4 @@ MODULE_DESCRIPTION("PPP over L2TP over U
 MODULE_LICENSE("GPL");
 MODULE_VERSION(PPPOL2TP_DRV_VERSION);
 MODULE_ALIAS("pppox-proto-" __stringify(PX_PROTO_OL2TP));
+MODULE_ALIAS_L2TP_PWTYPE(11);
