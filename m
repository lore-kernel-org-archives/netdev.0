From: Amir Vadai <amir@vadai.me>
Subject: [PATCH iproute2 net 6/8] tc/pedit: p_eth: ETH header editor
Date: Sun, 23 Apr 2017 15:53:54 +0300
Message-ID: <20170423125356.1298-7-amir@vadai.me>
References: <20170423125356.1298-1-amir@vadai.me>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Amir Vadai <amir@vadai.me>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34421 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1045440AbdDWMys (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 23 Apr 2017 08:54:48 -0400
Received: by mail-wm0-f67.google.com with SMTP id z129so12505873wmb.1
        for <netdev@vger.kernel.org>; Sun, 23 Apr 2017 05:54:47 -0700 (PDT)
In-Reply-To: <20170423125356.1298-1-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For example, forward tcp traffic to veth0 and set
destination mac address to 11:22:33:44:55:66 :
$ tc filter add dev enp0s9 protocol ip parent ffff: \
    flower \
      ip_proto tcp \
    action pedit ex munge \
      eth dst set 11:22:33:44:55:66 \
    action mirred egress \
      redirect dev veth0

Signed-off-by: Amir Vadai <amir@vadai.me>
---
 man/man8/tc-pedit.8 | 24 ++++++++++++++++++
 tc/Makefile         |  1 +
 tc/m_pedit.c        | 46 ++++++++++++++++++++++++++++++++++
 tc/m_pedit.h        |  1 +
 tc/p_eth.c          | 72 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 144 insertions(+)
 create mode 100644 tc/p_eth.c

diff --git a/man/man8/tc-pedit.8 b/man/man8/tc-pedit.8
index c98d95cb0021..8febdfe23f6e 100644
--- a/man/man8/tc-pedit.8
+++ b/man/man8/tc-pedit.8
@@ -27,12 +27,18 @@ pedit - generic packet editor action
 
 .ti -8
 .IR EXTENDED_LAYERED_OP " := { "
+.BI eth " ETHHDR_FIELD"
+|
 .BI ip " IPHDR_FIELD"
 |
 .BI ip " EX_IPHDR_FIELD"
 .RI } " CMD_SPEC"
 
 .ti -8
+.IR ETHHDR_FIELD " := { "
+.BR src " | " dst " | " type " }"
+
+.ti -8
 .IR IPHDR_FIELD " := { "
 .BR src " | " dst " | " tos " | " dsfield " | " ihl " | " protocol " |"
 .BR precedence " | " nofrag " | " firstfrag " | " ce " | " df " }"
@@ -103,6 +109,21 @@ and right-shifted by
 before adding it to
 .IR OFFSET .
 .TP
+.BI eth " ETHHDR_FIELD"
+Change an ETH header field. The supported keywords for
+.I ETHHDR_FIELD
+are:
+.RS
+.TP
+.B src
+.TQ
+.B dst
+Source or destination MAC address in the standard format: XX:XX:XX:XX:XX:XX
+.TP
+.B type
+Ether-type in numeric value
+.RE
+.TP
 .BI ip " IPHDR_FIELD"
 Change an IPv4 header field. The supported keywords for
 .I IPHDR_FIELD
@@ -269,6 +290,9 @@ tc filter add dev eth0 parent ffff: u32 \\
 tc filter add dev eth0 parent ffff: u32 \\
 	match ip sport 22 0xffff \\
 	action pedit ex munge ip dst set 192.168.1.199
+tc filter add dev eth0 parent ffff: u32 \\
+	match ip sport 22 0xffff \\
+	action pedit ex munge eth dst set 11:22:33:44:55:66
 .EE
 .RE
 .SH SEE ALSO
diff --git a/tc/Makefile b/tc/Makefile
index 3f7fc939e194..446a11391ad7 100644
--- a/tc/Makefile
+++ b/tc/Makefile
@@ -54,6 +54,7 @@ TCMODULES += m_tunnel_key.o
 TCMODULES += m_sample.o
 TCMODULES += p_ip.o
 TCMODULES += p_icmp.o
+TCMODULES += p_eth.o
 TCMODULES += p_tcp.o
 TCMODULES += p_udp.o
 TCMODULES += em_nbyte.o
diff --git a/tc/m_pedit.c b/tc/m_pedit.c
index d982c91a2585..0be42343ac88 100644
--- a/tc/m_pedit.c
+++ b/tc/m_pedit.c
@@ -28,6 +28,7 @@
 #include "utils.h"
 #include "tc_util.h"
 #include "m_pedit.h"
+#include "rt_names.h"
 
 static struct m_pedit_util *pedit_list;
 static int pedit_debug;
@@ -223,6 +224,38 @@ int pack_key8(__u32 retain, struct m_pedit_sel *sel, struct m_pedit_key *tkey)
 	return pack_key(sel, tkey);
 }
 
+static int pack_mac(struct m_pedit_sel *sel, struct m_pedit_key *tkey,
+		    __u8 *mac)
+{
+	int ret = 0;
+
+	if (!(tkey->off & 0x3)) {
+		tkey->mask = 0;
+		tkey->val = ntohl(*((__u32 *)mac));
+		ret |= pack_key32(~0, sel, tkey);
+
+		tkey->off += 4;
+		tkey->mask = 0;
+		tkey->val = ntohs(*((__u16 *)&mac[4]));
+		ret |= pack_key16(~0, sel, tkey);
+	} else if (!(tkey->off & 0x1)) {
+		tkey->mask = 0;
+		tkey->val = ntohs(*((__u16 *)mac));
+		ret |= pack_key16(~0, sel, tkey);
+
+		tkey->off += 4;
+		tkey->mask = 0;
+		tkey->val = ntohl(*((__u32 *)(mac + 2)));
+		ret |= pack_key32(~0, sel, tkey);
+	} else {
+		fprintf(stderr,
+			"pack_mac: mac offsets must begin in 32bit or 16bit boundaries\n");
+		return -1;
+	}
+
+	return ret;
+}
+
 int parse_val(int *argc_p, char ***argv_p, __u32 *val, int type)
 {
 	int argc = *argc_p;
@@ -250,6 +283,14 @@ int parse_val(int *argc_p, char ***argv_p, __u32 *val, int type)
 	if (type == TIPV6)
 		return -1; /* not implemented yet */
 
+	if (type == TMAC) {
+#define MAC_ALEN 6
+		int ret = ll_addr_a2n((char *)val, MAC_ALEN, *argv);
+
+		if (ret == MAC_ALEN)
+			return 0;
+	}
+
 	return -1;
 }
 
@@ -310,6 +351,11 @@ int parse_cmd(int *argc_p, char ***argv_p, __u32 len, int type, __u32 retain,
 		argv++;
 	}
 
+	if (type == TMAC) {
+		res = pack_mac(sel, tkey, (__u8 *)val);
+		goto done;
+	}
+
 	tkey->val = *v;
 	tkey->mask = *m;
 
diff --git a/tc/m_pedit.h b/tc/m_pedit.h
index e2897b0c9808..ecfb6add0df5 100644
--- a/tc/m_pedit.h
+++ b/tc/m_pedit.h
@@ -32,6 +32,7 @@
 #define TIPV6 2
 #define TINT 3
 #define TU32 4
+#define TMAC 5
 
 #define RU32 0xFFFFFFFF
 #define RU16 0xFFFF
diff --git a/tc/p_eth.c b/tc/p_eth.c
new file mode 100644
index 000000000000..ad3e28f80eb6
--- /dev/null
+++ b/tc/p_eth.c
@@ -0,0 +1,72 @@
+/*
+ * m_pedit_eth.c	packet editor: ETH header
+ *
+ *		This program is free software; you can distribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:  Amir Vadai (amir@vadai.me)
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
+parse_eth(int *argc_p, char ***argv_p,
+	  struct m_pedit_sel *sel, struct m_pedit_key *tkey)
+{
+	int res = -1;
+	int argc = *argc_p;
+	char **argv = *argv_p;
+
+	if (argc < 2)
+		return -1;
+
+	tkey->htype = TCA_PEDIT_KEY_EX_HDR_TYPE_ETH;
+
+	if (strcmp(*argv, "type") == 0) {
+		NEXT_ARG();
+		tkey->off = 12;
+		res = parse_cmd(&argc, &argv, 2, TU32, RU16, sel, tkey);
+		goto done;
+	}
+
+	if (strcmp(*argv, "dst") == 0) {
+		NEXT_ARG();
+		tkey->off = 0;
+		res = parse_cmd(&argc, &argv, 6, TMAC, RU32, sel, tkey);
+		goto done;
+	}
+
+	if (strcmp(*argv, "src") == 0) {
+		NEXT_ARG();
+		tkey->off = 6;
+		res = parse_cmd(&argc, &argv, 6, TMAC, RU32, sel, tkey);
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
+struct m_pedit_util p_pedit_eth = {
+	NULL,
+	"eth",
+	parse_eth,
+};
-- 
2.12.0
