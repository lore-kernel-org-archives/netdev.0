From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 2/3] [NET] fib_rules: Mark rules detached from the device
Date: Tue, 27 Mar 2007 01:54:52 +0200
Message-ID: <20070326235713.610933740@lsx.localdomain>
References: <20070326235450.756924134@lsx.localdomain>
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:52606 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933819AbXCZX6j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Mar 2007 19:58:39 -0400
Content-Disposition: inline; filename=rule_detached_flag
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rules which match against device names in their selector can
remain while the device itself disappears, in fact the device
doesn't have to present when the rule is added in the first
place. The device name is resolved by trying when the rule is
added and later by listening to NETDEV_REGISTER/UNREGISTER
notifications.

This patch adds the flag FIB_RULE_DEV_DETACHED which is set
towards userspace when a rule contains a device match which
is unresolved at the moment. This eases spotting the reason
why certain rules seem not to function properly.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.22/include/linux/fib_rules.h
===================================================================
--- net-2.6.22.orig/include/linux/fib_rules.h	2007-03-27 01:43:14.000000000 +0200
+++ net-2.6.22/include/linux/fib_rules.h	2007-03-27 01:45:56.000000000 +0200
@@ -8,6 +8,7 @@
 #define FIB_RULE_PERMANENT	1
 #define FIB_RULE_INVERT		2
 #define FIB_RULE_UNRESOLVED	4
+#define FIB_RULE_DEV_DETACHED	8
 
 struct fib_rule_hdr
 {
Index: net-2.6.22/net/core/fib_rules.c
===================================================================
--- net-2.6.22.orig/net/core/fib_rules.c	2007-03-27 01:43:39.000000000 +0200
+++ net-2.6.22/net/core/fib_rules.c	2007-03-27 01:46:22.000000000 +0200
@@ -450,9 +450,13 @@ static int fib_nl_fill_rule(struct sk_bu
 	if (rule->action == FR_ACT_GOTO && rule->ctarget == NULL)
 		frh->flags |= FIB_RULE_UNRESOLVED;
 
-	if (rule->ifname[0])
+	if (rule->ifname[0]) {
 		NLA_PUT_STRING(skb, FRA_IFNAME, rule->ifname);
 
+		if (rule->ifindex == -1)
+			frh->flags |= FIB_RULE_DEV_DETACHED;
+	}
+
 	if (rule->pref)
 		NLA_PUT_U32(skb, FRA_PRIORITY, rule->pref);
 

--

