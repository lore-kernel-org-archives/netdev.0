From: Amir Vadai <amir@vadai.me>
Subject: [PATCH iproute2 net 3/8] tc/pedit: Introduce 'add' operation
Date: Sun, 23 Apr 2017 15:53:51 +0300
Message-ID: <20170423125356.1298-4-amir@vadai.me>
References: <20170423125356.1298-1-amir@vadai.me>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Amir Vadai <amir@vadai.me>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:36581 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1045431AbdDWMyl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 23 Apr 2017 08:54:41 -0400
Received: by mail-wr0-f194.google.com with SMTP id v42so9037996wrc.3
        for <netdev@vger.kernel.org>; Sun, 23 Apr 2017 05:54:41 -0700 (PDT)
In-Reply-To: <20170423125356.1298-1-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This command could be useful to increase/decrease fields value.

Signed-off-by: Amir Vadai <amir@vadai.me>
---
 man/man8/tc-pedit.8 | 13 ++++++++++++-
 tc/m_pedit.c        | 18 +++++++++++++++---
 2 files changed, 27 insertions(+), 4 deletions(-)

diff --git a/man/man8/tc-pedit.8 b/man/man8/tc-pedit.8
index 761d5c8ee2d5..6bba741956f1 100644
--- a/man/man8/tc-pedit.8
+++ b/man/man8/tc-pedit.8
@@ -43,6 +43,8 @@ pedit - generic packet editor action
 .IR CMD_SPEC " := {"
 .BR clear " | " invert " | " set
 .IR VAL " | "
+.BR add
+.IR VAL " | "
 .BR preserve " } [ " retain
 .IR RVAL " ]"
 
@@ -63,7 +65,9 @@ only for IPv4 headers.
 .B ex
 Use extended pedit.
 .I EXTENDED_LAYERED_OP
-is allowed only in this mode.
+and the add
+.I CMD_SPEC
+are allowed only in this mode.
 .TP
 .BI offset " OFFSET " "\fR{ \fBu32 \fR| \fBu16 \fR| \fBu8 \fR}"
 Specify the offset at which to change data.
@@ -173,6 +177,13 @@ keywords in
 or the size of the addressed header field in
 .IR LAYERED_OP .
 .TP
+.BI add " VAL"
+Add the addressed data by a specific value. The size of
+.I VAL
+is defined by the size of the addressed header field in
+.IR EXTENDED_LAYERED_OP .
+This operation is supported only for extended layered op.
+.TP
 .B preserve
 Keep the addressed data as is.
 .TP
diff --git a/tc/m_pedit.c b/tc/m_pedit.c
index a26fd3e5bc5e..7af074a5a97c 100644
--- a/tc/m_pedit.c
+++ b/tc/m_pedit.c
@@ -41,7 +41,7 @@ static void explain(void)
 		"\t\tATC:= at <atval> offmask <maskval> shift <shiftval>\n"
 		"\t\tNOTE: offval is byte offset, must be multiple of 4\n"
 		"\t\tNOTE: maskval is a 32 bit hex number\n \t\tNOTE: shiftval is a shift value\n"
-		"\t\tCMD:= clear | invert | set <setval>| retain\n"
+		"\t\tCMD:= clear | invert | set <setval>| add <addval> | retain\n"
 		"\t<LAYERED>:= ip <ipdata> | ip6 <ip6data>\n"
 		" \t\t| udp <udpdata> | tcp <tcpdata> | icmp <icmpdata>\n"
 		"\tCONTROL:= reclassify | pipe | drop | continue | pass\n"
@@ -276,7 +276,16 @@ int parse_cmd(int *argc_p, char ***argv_p, __u32 len, int type, __u32 retain,
 
 	if (matches(*argv, "invert") == 0) {
 		val = mask = o;
-	} else if (matches(*argv, "set") == 0) {
+	} else if (matches(*argv, "set") == 0 ||
+		   matches(*argv, "add") == 0) {
+		if (matches(*argv, "add") == 0)
+			tkey->cmd = TCA_PEDIT_KEY_EX_CMD_ADD;
+
+		if (!sel->extended && tkey->cmd) {
+			fprintf(stderr, "Non extended mode. only 'set' command is supported\n");
+			return -1;
+		}
+
 		NEXT_ARG();
 		if (parse_val(&argc, &argv, &val, type))
 			return -1;
@@ -690,9 +699,11 @@ int print_pedit(struct action_util *au, FILE *f, struct rtattr *arg)
 		for (i = 0; i < sel->nkeys; i++, key++) {
 			enum pedit_header_type htype =
 				TCA_PEDIT_KEY_EX_HDR_TYPE_NETWORK;
+			enum pedit_cmd cmd = TCA_PEDIT_KEY_EX_CMD_SET;
 
 			if (keys_ex) {
 				htype = key_ex->htype;
+				cmd = key_ex->cmd;
 
 				key_ex++;
 			}
@@ -703,7 +714,8 @@ int print_pedit(struct action_util *au, FILE *f, struct rtattr *arg)
 
 			print_pedit_location(f, htype, key->off);
 
-			fprintf(f, ": val %08x mask %08x",
+			fprintf(f, ": %s %08x mask %08x",
+				cmd ? "add" : "val",
 				(unsigned int)ntohl(key->val),
 				(unsigned int)ntohl(key->mask));
 		}
-- 
2.12.0
