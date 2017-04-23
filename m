From: Amir Vadai <amir@vadai.me>
Subject: [PATCH iproute2 net 7/8] tc/pedit: p_tcp: introduce pedit tcp support
Date: Sun, 23 Apr 2017 15:53:55 +0300
Message-ID: <20170423125356.1298-8-amir@vadai.me>
References: <20170423125356.1298-1-amir@vadai.me>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Amir Vadai <amir@vadai.me>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:32780 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1045469AbdDWMzT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 23 Apr 2017 08:55:19 -0400
Received: by mail-wm0-f68.google.com with SMTP id y10so1432734wmh.0
        for <netdev@vger.kernel.org>; Sun, 23 Apr 2017 05:54:59 -0700 (PDT)
In-Reply-To: <20170423125356.1298-1-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For example, forward tcp traffic destined to port 80 to veth0 and set
tcp port to 8080:
$ tc filter add dev enp0s9 protocol ip parent ffff: \
    flower \
      ip_proto tcp \
      dst_port 80 \
    action pedit ex munge \
      tcp dport set 8080 \
    action mirred egress \
      redirect dev veth0

Signed-off-by: Amir Vadai <amir@vadai.me>
---
 man/man8/tc-pedit.8 | 23 +++++++++++++++++++++++
 tc/p_tcp.c          | 37 +++++++++++++++++++++++++++++++++++++
 2 files changed, 60 insertions(+)

diff --git a/man/man8/tc-pedit.8 b/man/man8/tc-pedit.8
index 8febdfe23f6e..ad1929592660 100644
--- a/man/man8/tc-pedit.8
+++ b/man/man8/tc-pedit.8
@@ -32,6 +32,8 @@ pedit - generic packet editor action
 .BI ip " IPHDR_FIELD"
 |
 .BI ip " EX_IPHDR_FIELD"
+|
+.BI tcp " TCPHDR_FIELD"
 .RI } " CMD_SPEC"
 
 .ti -8
@@ -52,6 +54,10 @@ pedit - generic packet editor action
 .BR ttl " }"
 
 .ti -8
+.IR TCPHDR_FIELD " := { "
+.BR sport " | " dport " | " flags " }"
+
+.ti -8
 .IR CMD_SPEC " := {"
 .BR clear " | " invert " | " set
 .IR VAL " | "
@@ -199,6 +205,20 @@ are:
 .B ttl
 .RE
 .TP
+.BI tcp " TCPHDR_FIELD"
+The supported keywords for
+.I TCPHDR_FIELD
+are:
+.RS
+.TP
+.B sport
+.TQ
+.B dport
+Source or destination TCP port number, a 16-bit value.
+.TP
+.B flags
+.RE
+.TP
 .B clear
 Clear the addressed data (i.e., set it to zero).
 .TP
@@ -293,6 +313,9 @@ tc filter add dev eth0 parent ffff: u32 \\
 tc filter add dev eth0 parent ffff: u32 \\
 	match ip sport 22 0xffff \\
 	action pedit ex munge eth dst set 11:22:33:44:55:66
+tc filter add dev eth0 parent ffff: u32 \\
+	match ip dport 23 0xffff \\
+	action pedit ex munge tcp dport set 22
 .EE
 .RE
 .SH SEE ALSO
diff --git a/tc/p_tcp.c b/tc/p_tcp.c
index 53ee9842160b..cf14574c9c3e 100644
--- a/tc/p_tcp.c
+++ b/tc/p_tcp.c
@@ -28,6 +28,43 @@ parse_tcp(int *argc_p, char ***argv_p,
 	  struct m_pedit_sel *sel, struct m_pedit_key *tkey)
 {
 	int res = -1;
+	int argc = *argc_p;
+	char **argv = *argv_p;
+
+	if (argc < 2)
+		return -1;
+
+	if (!sel->extended)
+		return -1;
+
+	tkey->htype = TCA_PEDIT_KEY_EX_HDR_TYPE_TCP;
+
+	if (strcmp(*argv, "sport") == 0) {
+		NEXT_ARG();
+		tkey->off = 0;
+		res = parse_cmd(&argc, &argv, 2, TU32, RU16, sel, tkey);
+		goto done;
+	}
+
+	if (strcmp(*argv, "dport") == 0) {
+		NEXT_ARG();
+		tkey->off = 2;
+		res = parse_cmd(&argc, &argv, 2, TU32, RU16, sel, tkey);
+		goto done;
+	}
+
+	if (strcmp(*argv, "flags") == 0) {
+		NEXT_ARG();
+		tkey->off = 13;
+		res = parse_cmd(&argc, &argv, 1, TU32, RU8, sel, tkey);
+		goto done;
+	}
+
+	return -1;
+
+done:
+	*argc_p = argc;
+	*argv_p = argv;
 	return res;
 }
 struct m_pedit_util p_pedit_tcp = {
-- 
2.12.0
