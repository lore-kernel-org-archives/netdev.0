From: Thomas Graf <tgraf@suug.ch>
Subject: [IPROUTE2] Add support for inverted selectors
Date: Thu, 9 Nov 2006 12:38:02 +0100
Message-ID: <20061109113802.GA7556@postel.suug.ch>
References: <20061109112735.577771022@lsx.localdomain> <20061109113246.170519079@lsx.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:13264 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S965559AbWKILhm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Nov 2006 06:37:42 -0500
To: shemminger@osdl.org
Content-Disposition: inline
In-Reply-To: <20061109113246.170519079@lsx.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Index: iproute2.git/include/linux/fib_rules.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ iproute2.git/include/linux/fib_rules.h	2006-11-09 11:48:07.000000000 +0100
@@ -0,0 +1,66 @@
+#ifndef __LINUX_FIB_RULES_H
+#define __LINUX_FIB_RULES_H
+
+#include <linux/types.h>
+#include <linux/rtnetlink.h>
+
+/* rule is permanent, and cannot be deleted */
+#define FIB_RULE_PERMANENT	1
+#define FIB_RULE_INVERT		2
+
+struct fib_rule_hdr
+{
+	__u8		family;
+	__u8		dst_len;
+	__u8		src_len;
+	__u8		tos;
+
+	__u8		table;
+	__u8		res1;	/* reserved */
+	__u8		res2;	/* reserved */
+	__u8		action;
+
+	__u32		flags;
+};
+
+enum
+{
+	FRA_UNSPEC,
+	FRA_DST,	/* destination address */
+	FRA_SRC,	/* source address */
+	FRA_IFNAME,	/* interface name */
+	FRA_UNUSED1,
+	FRA_UNUSED2,
+	FRA_PRIORITY,	/* priority/preference */
+	FRA_UNUSED3,
+	FRA_UNUSED4,
+	FRA_UNUSED5,
+	FRA_FWMARK,	/* mark */
+	FRA_FLOW,	/* flow/class id */
+	FRA_UNUSED6,
+	FRA_UNUSED7,
+	FRA_UNUSED8,
+	FRA_TABLE,	/* Extended table id */
+	FRA_FWMASK,	/* mask for netfilter mark */
+	__FRA_MAX
+};
+
+#define FRA_MAX (__FRA_MAX - 1)
+
+enum
+{
+	FR_ACT_UNSPEC,
+	FR_ACT_TO_TBL,		/* Pass to fixed table */
+	FR_ACT_RES1,
+	FR_ACT_RES2,
+	FR_ACT_RES3,
+	FR_ACT_RES4,
+	FR_ACT_BLACKHOLE,	/* Drop without notification */
+	FR_ACT_UNREACHABLE,	/* Drop with ENETUNREACH */
+	FR_ACT_PROHIBIT,	/* Drop with EACCES */
+	__FR_ACT_MAX,
+};
+
+#define FR_ACT_MAX (__FR_ACT_MAX - 1)
+
+#endif
Index: iproute2.git/ip/iprule.c
===================================================================
--- iproute2.git.orig/ip/iprule.c	2006-11-09 11:46:20.000000000 +0100
+++ iproute2.git/ip/iprule.c	2006-11-09 11:51:35.000000000 +0100
@@ -24,6 +24,7 @@
 #include <netinet/ip.h>
 #include <arpa/inet.h>
 #include <string.h>
+#include <linux/fib_rules.h>
 
 #include "rt_names.h"
 #include "utils.h"
@@ -36,7 +37,7 @@
 static void usage(void)
 {
 	fprintf(stderr, "Usage: ip rule [ list | add | del | flush ] SELECTOR ACTION\n");
-	fprintf(stderr, "SELECTOR := [ from PREFIX ] [ to PREFIX ] [ tos TOS ] [ fwmark FWMARK ]\n");
+	fprintf(stderr, "SELECTOR := [ not ] [ from PREFIX ] [ to PREFIX ] [ tos TOS ] [ fwmark FWMARK ]\n");
 	fprintf(stderr, "            [ dev STRING ] [ pref NUMBER ]\n");
 	fprintf(stderr, "ACTION := [ table TABLE_ID ]\n");
 	fprintf(stderr, "          [ prohibit | reject | unreachable ]\n");
@@ -80,6 +81,9 @@
 	else
 		fprintf(fp, "0:\t");
 
+	if (r->rtm_flags & FIB_RULE_INVERT)
+		fprintf(fp, "not ");
+
 	if (tb[RTA_SRC]) {
 		if (r->rtm_src_len != host_len) {
 			fprintf(fp, "from %s/%u ", rt_addr_n2a(r->rtm_family,
@@ -209,6 +213,7 @@
 	req.r.rtm_scope = RT_SCOPE_UNIVERSE;
 	req.r.rtm_table = 0;
 	req.r.rtm_type = RTN_UNSPEC;
+	req.r.rtm_flags = 0;
 
 	if (cmd == RTM_NEWRULE) {
 		req.n.nlmsg_flags |= NLM_F_CREATE|NLM_F_EXCL;
@@ -216,7 +221,9 @@
 	}
 
 	while (argc > 0) {
-		if (strcmp(*argv, "from") == 0) {
+		if (strcmp(*argv, "not") == 0) {
+			req.r.rtm_flags |= FIB_RULE_INVERT;
+		} else if (strcmp(*argv, "from") == 0) {
 			inet_prefix dst;
 			NEXT_ARG();
 			get_prefix(&dst, *argv, req.r.rtm_family);
