From: Amir Vadai <amir@vadai.me>
Subject: [PATCH iproute2 master 4/4] pedit: Introduce ipv6 support
Date: Sun, 14 May 2017 11:17:46 +0300
Message-ID: <20170514081746.9010-5-amir@vadai.me>
References: <20170514081746.9010-1-amir@vadai.me>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Amir Vadai <amir@vadai.me>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35813 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751036AbdENIRy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 14 May 2017 04:17:54 -0400
Received: by mail-wm0-f68.google.com with SMTP id v4so21299897wmb.2
        for <netdev@vger.kernel.org>; Sun, 14 May 2017 01:17:53 -0700 (PDT)
In-Reply-To: <20170514081746.9010-1-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for modifying IPv6 headers using pedit.

Signed-off-by: Amir Vadai <amir@vadai.me>
---
 man/man8/tc-pedit.8 | 30 ++++++++++++++++++
 tc/Makefile         |  1 +
 tc/m_pedit.c        | 43 +++++++++++++++++++++++--
 tc/p_ip.c           | 17 +---------
 tc/p_ip6.c          | 91 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 164 insertions(+), 18 deletions(-)
 create mode 100644 tc/p_ip6.c

diff --git a/man/man8/tc-pedit.8 b/man/man8/tc-pedit.8
index 9c4d57b972cc..82d4217bc958 100644
--- a/man/man8/tc-pedit.8
+++ b/man/man8/tc-pedit.8
@@ -33,6 +33,8 @@ pedit - generic packet editor action
 |
 .BI ip " EX_IPHDR_FIELD"
 |
+.BI ip6 " IP6HDR_FIELD"
+|
 .BI tcp " TCPHDR_FIELD"
 |
 .BI udp " UDPHDR_FIELD"
@@ -55,6 +57,12 @@ pedit - generic packet editor action
 .IR EX_IPHDR_FIELD " := { "
 .BR ttl " }"
 
+
+.ti -8
+.IR IP6HDR_FIELD " := { "
+.BR src " | " dst " | " flow_lbl " | " payload_len " | " nexthdr " |"
+.BR hoplimit " }"
+
 .ti -8
 .IR TCPHDR_FIELD " := { "
 .BR sport " | " dport " | " flags " }"
@@ -211,6 +219,25 @@ are:
 .B ttl
 .RE
 .TP
+.BI ip6 " IP6HDR_FIELD"
+The supported keywords for
+.I IP6HDR_FIELD
+are:
+.RS
+.TP
+.B src
+.TQ
+.B dst
+.TQ
+.B flow_lbl
+.TQ
+.B payload_len
+.TQ
+.B nexthdr
+.TQ
+.B hoplimit
+.RE
+.TP
 .BI tcp " TCPHDR_FIELD"
 The supported keywords for
 .I TCPHDR_FIELD
@@ -331,6 +358,9 @@ tc filter add dev eth0 parent ffff: u32 \\
 	action pedit ex munge ip dst set 192.168.1.199
 tc filter add dev eth0 parent ffff: u32 \\
 	match ip sport 22 0xffff \\
+	action pedit ex munge ip6 dst set fe80::dacb:8aff:fec7:320e
+tc filter add dev eth0 parent ffff: u32 \\
+	match ip sport 22 0xffff \\
 	action pedit ex munge eth dst set 11:22:33:44:55:66
 tc filter add dev eth0 parent ffff: u32 \\
 	match ip dport 23 0xffff \\
diff --git a/tc/Makefile b/tc/Makefile
index 446a11391ad7..9a6bb1ddea57 100644
--- a/tc/Makefile
+++ b/tc/Makefile
@@ -53,6 +53,7 @@ TCMODULES += m_bpf.o
 TCMODULES += m_tunnel_key.o
 TCMODULES += m_sample.o
 TCMODULES += p_ip.o
+TCMODULES += p_ip6.o
 TCMODULES += p_icmp.o
 TCMODULES += p_eth.o
 TCMODULES += p_tcp.o
diff --git a/tc/m_pedit.c b/tc/m_pedit.c
index 9b74c965932e..dfa6b2c4835e 100644
--- a/tc/m_pedit.c
+++ b/tc/m_pedit.c
@@ -257,6 +257,32 @@ static int pack_mac(struct m_pedit_sel *sel, struct m_pedit_key *tkey,
 	return ret;
 }
 
+static int pack_ipv6(struct m_pedit_sel *sel, struct m_pedit_key *tkey,
+		     __u32 *ipv6)
+{
+	int ret = 0;
+	int i;
+
+	if (tkey->off & 0x3) {
+		fprintf(stderr,
+			"pack_ipv6: IPv6 offsets must begin in 32bit boundaries\n");
+		return -1;
+	}
+
+	for (i = 0; i < 4; i++) {
+		tkey->mask = 0;
+		tkey->val = ntohl(ipv6[i]);
+
+		ret = pack_key32(~0, sel, tkey);
+		if (ret)
+			return ret;
+
+		tkey->off += 4;
+	}
+
+	return 0;
+}
+
 int parse_val(int *argc_p, char ***argv_p, __u32 *val, int type)
 {
 	int argc = *argc_p;
@@ -281,8 +307,16 @@ int parse_val(int *argc_p, char ***argv_p, __u32 *val, int type)
 		return 0;
 	}
 
-	if (type == TIPV6)
-		return -1; /* not implemented yet */
+	if (type == TIPV6) {
+		inet_prefix addr;
+
+		if (get_prefix_1(&addr, *argv, AF_INET6))
+			return -1;
+
+		memcpy(val, addr.data, addr.bytelen);
+
+		return 0;
+	}
 
 	if (type == TMAC) {
 #define MAC_ALEN 6
@@ -364,6 +398,11 @@ int parse_cmd(int *argc_p, char ***argv_p, __u32 len, int type, __u32 retain,
 		goto done;
 	}
 
+	if (type == TIPV6) {
+		res = pack_ipv6(sel, tkey, val);
+		goto done;
+	}
+
 	tkey->val = *v;
 	tkey->mask = *m;
 
diff --git a/tc/p_ip.c b/tc/p_ip.c
index 22fe6505e427..0272a6eaaf48 100644
--- a/tc/p_ip.c
+++ b/tc/p_ip.c
@@ -1,5 +1,5 @@
 /*
- * m_pedit.c		packet editor: IPV4/6 header
+ * p_ip.c		packet editor: IPV4 header
  *
  *		This program is free software; you can distribute it and/or
  *		modify it under the terms of the GNU General Public License
@@ -156,23 +156,8 @@ done:
 	return res;
 }
 
-static int
-parse_ip6(int *argc_p, char ***argv_p,
-	  struct m_pedit_sel *sel, struct m_pedit_key *tkey)
-{
-	int res = -1;
-	return res;
-}
-
 struct m_pedit_util p_pedit_ip = {
 	NULL,
 	"ip",
 	parse_ip,
 };
-
-
-struct m_pedit_util p_pedit_ip6 = {
-	NULL,
-	"ip6",
-	parse_ip6,
-};
diff --git a/tc/p_ip6.c b/tc/p_ip6.c
new file mode 100644
index 000000000000..a4824bda90e8
--- /dev/null
+++ b/tc/p_ip6.c
@@ -0,0 +1,91 @@
+/*
+ * p_ip6.c		packet editor: IPV6 header
+ *
+ *		This program is free software; you can distribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:  Amir Vadai <amir@vadai.me>
+ *
+ */
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
+#include "m_pedit.h"
+
+static int
+parse_ip6(int *argc_p, char ***argv_p,
+	  struct m_pedit_sel *sel, struct m_pedit_key *tkey)
+{
+	int res = -1;
+	int argc = *argc_p;
+	char **argv = *argv_p;
+
+	if (argc < 2)
+		return -1;
+
+	if (!sel->extended)
+		return -1;
+
+	tkey->htype = TCA_PEDIT_KEY_EX_HDR_TYPE_IP6;
+
+	if (strcmp(*argv, "src") == 0) {
+		NEXT_ARG();
+		tkey->off = 8;
+		res = parse_cmd(&argc, &argv, 16, TIPV6, RU32, sel, tkey);
+		goto done;
+	}
+	if (strcmp(*argv, "dst") == 0) {
+		NEXT_ARG();
+		tkey->off = 24;
+		res = parse_cmd(&argc, &argv, 16, TIPV6, RU32, sel, tkey);
+		goto done;
+	}
+	if (strcmp(*argv, "flow_lbl") == 0) {
+		NEXT_ARG();
+		tkey->off = 0;
+		res = parse_cmd(&argc, &argv, 4, TU32, 0x0007ffff, sel, tkey);
+		goto done;
+	}
+	if (strcmp(*argv, "payload_len") == 0) {
+		NEXT_ARG();
+		tkey->off = 4;
+		res = parse_cmd(&argc, &argv, 2, TU32, RU16, sel, tkey);
+		goto done;
+	}
+	if (strcmp(*argv, "nexthdr") == 0) {
+		NEXT_ARG();
+		tkey->off = 6;
+		res = parse_cmd(&argc, &argv, 1, TU32, RU8, sel, tkey);
+		goto done;
+	}
+	if (strcmp(*argv, "hoplimit") == 0) {
+		NEXT_ARG();
+		tkey->off = 7;
+		res = parse_cmd(&argc, &argv, 1, TU32, RU8, sel, tkey);
+		goto done;
+	}
+
+	return -1;
+
+done:
+	*argc_p = argc;
+	*argv_p = argv;
+	return res;
+}
+
+struct m_pedit_util p_pedit_ip6 = {
+	NULL,
+	"ipv6",
+	parse_ip6,
+};
-- 
2.12.2
