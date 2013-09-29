From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH]: iproute action: Introduce simple action
Date: Sun, 29 Sep 2013 07:33:42 -0400
Message-ID: <52481016.6060004@mojatatu.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020102060009040200010801"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f177.google.com ([209.85.223.177]:40485 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751143Ab3I2Ldp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Sep 2013 07:33:45 -0400
Received: by mail-ie0-f177.google.com with SMTP id qd12so7572343ieb.22
        for <netdev@vger.kernel.org>; Sun, 29 Sep 2013 04:33:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020102060009040200010801
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


I had to explain this to someone after they said it wasnt in
iproute2.

Note: For some reason not all kernel headers are copied. You need
at least have linux/tc_act/tc_defact.h for this to compile.
I could send you a patch - but i think this is something you
should do.

cheers,
jamal

--------------020102060009040200010801
Content-Type: text/plain; charset=UTF-8;
 name="simp-p1"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="simp-p1"

commit ce8f6c550ff714203ca565699e9f332a93704e41
Author: Jamal Hadi Salim <hadi@mojatatu.com>
Date:   Sun Sep 29 07:19:23 2013 -0400

    Simple action is already in the kernel for years now as an
    example. This complements it with user space control.
    
    Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

diff --git a/tc/Makefile b/tc/Makefile
index 1eeabd8..f54a955 100644
--- a/tc/Makefile
+++ b/tc/Makefile
@@ -38,6 +38,7 @@ TCMODULES += m_nat.o
 TCMODULES += m_pedit.o
 TCMODULES += m_skbedit.o
 TCMODULES += m_csum.o
+TCMODULES += m_simple.o
 TCMODULES += p_ip.o
 TCMODULES += p_icmp.o
 TCMODULES += p_tcp.o
diff --git a/tc/m_simple.c b/tc/m_simple.c
new file mode 100644
index 0000000..0224440
--- /dev/null
+++ b/tc/m_simple.c
@@ -0,0 +1,202 @@
+/*
+ * m_simple.c	simple action
+ *
+ *		This program is free software; you can distribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	J Hadi Salim <jhs@mojatatu.com>
+ *
+ * Pedagogical example. Adds a string that will be printed everytime
+ * the simple instance is hit. 
+ * Use this as a skeleton action and keep modifying it to meet your needs.
+ * Look at linux/tc_act/tc_defact.h for the different components ids and
+ * definitions used in  this actions
+ *
+ * example use, yell "Incoming ICMP!" every time you see an incoming ICMP on
+ * eth0. Steps are:
+ * 1) Add an ingress qdisc point to eth0
+ * 2) Start a chain on ingress of eth0 that first matches ICMP then invokes
+ *    the simple action to shout.
+ * 3) display stats and show that no packet has been seen by the action
+ * 4) Send one ping packet to google (expect to receive a response back)
+ * 5) grep the logs to see the logged message
+ * 6) display stats again and observe increment by 1
+ *
+  hadi@noma1:$ tc qdisc add dev eth0 ingress
+  hadi@noma1:$tc filter add dev eth0 parent ffff: protocol ip prio 5 \
+   	 u32 match ip protocol 1 0xff flowid 1:1 action simple "Incoming ICMP"
+  
+  hadi@noma1:$ sudo tc -s filter ls  dev eth0 parent ffff:
+   filter protocol ip pref 5 u32 
+   filter protocol ip pref 5 u32 fh 800: ht divisor 1 
+   filter protocol ip pref 5 u32 fh 800::800 order 2048 key ht 800 bkt 0 flowid 1:1 
+     match 00010000/00ff0000 at 8
+     	action order 1: Simple <Incoming ICMP>
+     	 index 4 ref 1 bind 1 installed 29 sec used 29 sec
+     	 Action statistics:
+     		Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0) 
+     	 	backlog 0b 0p requeues 0 
+  
+  
+  hadi@noma1$ ping -c 1 www.google.ca
+  PING www.google.ca (74.125.225.120) 56(84) bytes of data.
+  64 bytes from ord08s08-in-f24.1e100.net (74.125.225.120): icmp_req=1 ttl=53 time=31.3 ms
+
+  --- www.google.ca ping statistics ---
+  1 packets transmitted, 1 received, 0% packet loss, time 0ms
+  rtt min/avg/max/mdev = 31.316/31.316/31.316/0.000 ms
+
+  hadi@noma1$ dmesg | grep simple
+  [135354.473951] simple: Incoming ICMP_1
+
+  hadi@noma1$ sudo tc/tc -s filter ls  dev eth0 parent ffff:
+  filter protocol ip pref 5 u32 
+  filter protocol ip pref 5 u32 fh 800: ht divisor 1 
+  filter protocol ip pref 5 u32 fh 800::800 order 2048 key ht 800 bkt 0 flowid 1:1 
+    match 00010000/00ff0000 at 8
+	action order 1: Simple <Incoming ICMP>
+	 index 4 ref 1 bind 1 installed 206 sec used 67 sec
+	Action statistics:
+	Sent 84 bytes 1 pkt (dropped 0, overlimits 0 requeues 0) 
+	backlog 0b 0p requeues 0 
+*/
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <unistd.h>
+#include <syslog.h>
+#include <fcntl.h>
+#include <sys/socket.h>
+#include <netinet/in.h>
+#include <arpa/inet.h>
+#include <string.h>
+#include "utils.h"
+#include "tc_util.h"
+#include <linux/tc_act/tc_defact.h>
+
+#ifndef SIMP_MAX_DATA
+#define SIMP_MAX_DATA   32
+#endif
+static void explain(void)
+{
+	fprintf(stderr, "Usage: ... simple STRING\n"
+		"STRING being an arbitrary string\n" 
+		"example: \"simple blah\"\n");
+}
+
+static void usage(void)
+{
+	explain();
+	exit(-1);
+}
+
+static int
+parse_simple(struct action_util *a, int *argc_p, char ***argv_p, int tca_id,
+	     struct nlmsghdr *n)
+{
+	struct tc_defact sel = {};
+	int argc = *argc_p;
+	char **argv = *argv_p;
+	int ok = 0;
+	struct rtattr *tail;
+	char *simpdata = NULL;
+
+
+	while (argc > 0) {
+		if (matches(*argv, "simple") == 0) {
+			NEXT_ARG();
+			simpdata = *argv;
+			ok = 1;
+			argc--;
+			argv++;
+			break;
+		} else if (matches(*argv, "help") == 0) {
+			usage();
+		} else {
+			break;
+		}
+
+	}
+
+	if (!ok) {
+		explain();
+		return -1;
+	}
+
+	if (argc) {
+		if (matches(*argv, "index") == 0) {
+			NEXT_ARG();
+			if (get_u32(&sel.index, *argv, 10)) {
+				fprintf(stderr, "simple: Illegal \"index\"\n");
+				return -1;
+			}
+			argc--;
+			argv++;
+		}
+	}
+
+	if (strlen(simpdata) > (SIMP_MAX_DATA - 1)) {
+		fprintf(stderr, "simple: Illegal string len %ld <%s> \n",
+			strlen(simpdata), simpdata);
+		return -1;
+	}
+
+	sel.action = TC_ACT_PIPE;
+
+	tail = NLMSG_TAIL(n);
+	addattr_l(n, MAX_MSG, tca_id, NULL, 0);
+	addattr_l(n, MAX_MSG, TCA_DEF_PARMS, &sel, sizeof(sel));
+	addattr_l(n, MAX_MSG, TCA_DEF_DATA, simpdata, SIMP_MAX_DATA);
+	tail->rta_len = (char *)NLMSG_TAIL(n) - (char *)tail;
+
+	*argc_p = argc;
+	*argv_p = argv;
+	return 0;
+}
+
+static int print_simple(struct action_util *au, FILE * f, struct rtattr *arg)
+{
+	struct tc_defact *sel;
+	struct rtattr *tb[TCA_DEF_MAX + 1];
+	char *simpdata;
+
+	if (arg == NULL)
+		return -1;
+
+	parse_rtattr_nested(tb, TCA_DEF_MAX, arg);
+
+	if (tb[TCA_DEF_PARMS] == NULL) {
+		fprintf(f, "[NULL simple parameters]");
+		return -1;
+	}
+	sel = RTA_DATA(tb[TCA_DEF_PARMS]);
+
+	if (tb[TCA_DEF_DATA] == NULL) {
+		fprintf(f, "[missing simple string]");
+		return -1;
+	}
+
+	simpdata = RTA_DATA(tb[TCA_DEF_DATA]);
+
+	fprintf(f, "Simple <%s>\n", simpdata);
+	fprintf(f, "\t index %d ref %d bind %d", sel->index,
+		sel->refcnt, sel->bindcnt);
+
+	if (show_stats) {
+		if (tb[TCA_DEF_TM]) {
+			struct tcf_t *tm = RTA_DATA(tb[TCA_DEF_TM]);
+			print_tm(f, tm);
+			fprintf(f, "\n");
+		}
+	}
+
+	return 0;
+}
+
+struct action_util simple_action_util = {
+	.id = "simple",
+	.parse_aopt = parse_simple,
+	.print_aopt = print_simple,
+};

--------------020102060009040200010801--
