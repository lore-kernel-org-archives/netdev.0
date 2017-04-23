From: Amir Vadai <amir@vadai.me>
Subject: [PATCH iproute2 net 8/8] tc/pedit: p_udp: introduce pedit udp support
Date: Sun, 23 Apr 2017 15:53:56 +0300
Message-ID: <20170423125356.1298-9-amir@vadai.me>
References: <20170423125356.1298-1-amir@vadai.me>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Amir Vadai <amir@vadai.me>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:33092 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1045427AbdDWMyw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 23 Apr 2017 08:54:52 -0400
Received: by mail-wr0-f196.google.com with SMTP id w50so12968923wrc.0
        for <netdev@vger.kernel.org>; Sun, 23 Apr 2017 05:54:51 -0700 (PDT)
In-Reply-To: <20170423125356.1298-1-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

For example, forward udp traffic destined to port 999 to veth0 and set
tcp port to 888:
$ tc filter add dev enp0s9 protocol ip parent ffff: \
    flower \
      ip_proto udp \
      dst_port 999 \
    action pedit ex munge \
      udp dport set 888 \
    action mirred egress \
      redirect dev veth0

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Amir Vadai <amir@vadai.me>
---
 man/man8/tc-pedit.8 | 18 ++++++++++++++++++
 tc/p_udp.c          | 27 +++++++++++++++++++++++++++
 2 files changed, 45 insertions(+)

diff --git a/man/man8/tc-pedit.8 b/man/man8/tc-pedit.8
index ad1929592660..7f482eafc6c7 100644
--- a/man/man8/tc-pedit.8
+++ b/man/man8/tc-pedit.8
@@ -34,6 +34,8 @@ pedit - generic packet editor action
 .BI ip " EX_IPHDR_FIELD"
 |
 .BI tcp " TCPHDR_FIELD"
+|
+.BI udp " UDPHDR_FIELD"
 .RI } " CMD_SPEC"
 
 .ti -8
@@ -58,6 +60,10 @@ pedit - generic packet editor action
 .BR sport " | " dport " | " flags " }"
 
 .ti -8
+.IR UDPHDR_FIELD " := { "
+.BR sport " | " dport " }"
+
+.ti -8
 .IR CMD_SPEC " := {"
 .BR clear " | " invert " | " set
 .IR VAL " | "
@@ -219,6 +225,18 @@ Source or destination TCP port number, a 16-bit value.
 .B flags
 .RE
 .TP
+.BI udp " UDPHDR_FIELD"
+The supported keywords for
+.I UDPHDR_FIELD
+are:
+.RS
+.TP
+.B sport
+.TQ
+.B dport
+Source or destination TCP port number, a 16-bit value.
+.RE
+.TP
 .B clear
 Clear the addressed data (i.e., set it to zero).
 .TP
diff --git a/tc/p_udp.c b/tc/p_udp.c
index 3a86ba382391..a56a1b519254 100644
--- a/tc/p_udp.c
+++ b/tc/p_udp.c
@@ -28,6 +28,33 @@ parse_udp(int *argc_p, char ***argv_p,
 	  struct m_pedit_sel *sel, struct m_pedit_key *tkey)
 {
 	int res = -1;
+	int argc = *argc_p;
+	char **argv = *argv_p;
+
+	if (argc < 2)
+		return -1;
+
+	tkey->htype = TCA_PEDIT_KEY_EX_HDR_TYPE_UDP;
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
+	return -1;
+
+done:
+	*argc_p = argc;
+	*argv_p = argv;
 	return res;
 }
 
-- 
2.12.0
