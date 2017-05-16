From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch iproute2 v2 repost 3/3] tc/actions: introduce support for goto chain action
Date: Tue, 16 May 2017 19:29:37 +0200
Message-ID: <20170516172937.1391-3-jiri@resnulli.us>
References: <20170516172802.1317-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        dsa@cumulusnetworks.com, edumazet@google.com,
        stephen@networkplumber.org, daniel@iogearbox.net,
        alexander.h.duyck@intel.com, simon.horman@netronome.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35781 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752420AbdEPR3o (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 13:29:44 -0400
Received: by mail-wm0-f66.google.com with SMTP id v4so39826106wmb.2
        for <netdev@vger.kernel.org>; Tue, 16 May 2017 10:29:42 -0700 (PDT)
In-Reply-To: <20170516172802.1317-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Allow user to set control action "goto" with filter chain index as
a parameter.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/linux/pkt_cls.h | 16 +++++++++++++++-
 man/man8/tc-ife.8       |  2 +-
 man/man8/tc-pedit.8     |  2 +-
 man/man8/tc-police.8    |  2 +-
 man/man8/tc-vlan.8      |  2 +-
 tc/m_connmark.c         |  3 ++-
 tc/m_gact.c             |  6 ++++--
 tc/m_pedit.c            |  3 ++-
 tc/m_police.c           |  6 ++++--
 tc/m_skbmod.c           |  3 ++-
 tc/m_vlan.c             |  3 ++-
 tc/tc_util.c            | 24 +++++++++++++++++++++++-
 12 files changed, 58 insertions(+), 14 deletions(-)

diff --git a/include/linux/pkt_cls.h b/include/linux/pkt_cls.h
index f1129e3..1b9aa9e 100644
--- a/include/linux/pkt_cls.h
+++ b/include/linux/pkt_cls.h
@@ -37,7 +37,21 @@ enum {
 #define TC_ACT_QUEUED		5
 #define TC_ACT_REPEAT		6
 #define TC_ACT_REDIRECT		7
-#define TC_ACT_JUMP		0x10000000
+
+/* There is a special kind of actions called "extended actions",
+ * which need a value parameter. These have a local opcode located in
+ * the highest nibble, starting from 1. The rest of the bits
+ * are used to carry the value. These two parts together make
+ * a combined opcode.
+ */
+#define __TC_ACT_EXT_SHIFT 28
+#define __TC_ACT_EXT(local) ((local) << __TC_ACT_EXT_SHIFT)
+#define TC_ACT_EXT_VAL_MASK ((1 << __TC_ACT_EXT_SHIFT) - 1)
+#define TC_ACT_EXT_CMP(combined, opcode) \
+	(((combined) & (~TC_ACT_EXT_VAL_MASK)) == opcode)
+
+#define TC_ACT_JUMP __TC_ACT_EXT(1)
+#define TC_ACT_GOTO_CHAIN __TC_ACT_EXT(2)
 
 /* Action type identifiers*/
 enum {
diff --git a/man/man8/tc-ife.8 b/man/man8/tc-ife.8
index a8f1f28..24595cc 100644
--- a/man/man8/tc-ife.8
+++ b/man/man8/tc-ife.8
@@ -34,7 +34,7 @@ IFE - encapsulate/decapsulate metadata
 
 .ti -8
 .IR CONTROL " := { "
-.BR reclassify " | " use " | " pipe " | " drop " | " continue " | " ok " }"
+.BR reclassify " | " use " | " pipe " | " drop " | " continue " | " ok " | " goto " " chain " " CHAIN_INDEX " }"
 .SH DESCRIPTION
 The
 .B ife
diff --git a/man/man8/tc-pedit.8 b/man/man8/tc-pedit.8
index 7f482ea..de0d9e9 100644
--- a/man/man8/tc-pedit.8
+++ b/man/man8/tc-pedit.8
@@ -74,7 +74,7 @@ pedit - generic packet editor action
 
 .ti -8
 .IR CONTROL " := {"
-.BR reclassify " | " pipe " | " drop " | " shot " | " continue " | " pass " }"
+.BR reclassify " | " pipe " | " drop " | " shot " | " continue " | " pass " | " goto " " chain " " CHAIN_INDEX " }"
 .SH DESCRIPTION
 The
 .B pedit
diff --git a/man/man8/tc-police.8 b/man/man8/tc-police.8
index 620c288..bcc5f43 100644
--- a/man/man8/tc-police.8
+++ b/man/man8/tc-police.8
@@ -30,7 +30,7 @@ police - policing action
 
 .ti -8
 .IR EXCEEDACT/NOTEXCEEDACT " := { "
-.BR pipe " | " ok " | " reclassify " | " drop " | " continue " }"
+.BR pipe " | " ok " | " reclassify " | " drop " | " continue " | " goto " " chain " " CHAIN_INDEX " }"
 .SH DESCRIPTION
 The
 .B police
diff --git a/man/man8/tc-vlan.8 b/man/man8/tc-vlan.8
index af3de1c..59c81e8 100644
--- a/man/man8/tc-vlan.8
+++ b/man/man8/tc-vlan.8
@@ -26,7 +26,7 @@ vlan - vlan manipulation module
 
 .ti -8
 .IR CONTROL " := { "
-.BR reclassify " | " pipe " | " drop " | " continue " | " pass " }"
+.BR reclassify " | " pipe " | " drop " | " continue " | " pass " | " goto " " chain " " CHAIN_INDEX " }"
 .SH DESCRIPTION
 The
 .B vlan
diff --git a/tc/m_connmark.c b/tc/m_connmark.c
index 3c2274b..37d7185 100644
--- a/tc/m_connmark.c
+++ b/tc/m_connmark.c
@@ -30,7 +30,8 @@ explain(void)
 	fprintf(stderr, "Usage: ... connmark [zone ZONE] [CONTROL] [index <INDEX>]\n");
 	fprintf(stderr, "where :\n"
 		"\tZONE is the conntrack zone\n"
-		"\tCONTROL := reclassify|pipe|drop|continue|ok\n");
+		"\tCONTROL := reclassify | pipe | drop | continue | ok |\n"
+		"\t           goto chain <CHAIN_INDEX>\n");
 }
 
 static void
diff --git a/tc/m_gact.c b/tc/m_gact.c
index 938b6b5..d95aa11 100644
--- a/tc/m_gact.c
+++ b/tc/m_gact.c
@@ -45,7 +45,8 @@ explain(void)
 #ifdef CONFIG_GACT_PROB
 	fprintf(stderr, "Usage: ... gact <ACTION> [RAND] [INDEX]\n");
 	fprintf(stderr,
-		"Where: \tACTION := reclassify | drop | continue | pass | pipe\n"
+		"Where: \tACTION := reclassify | drop | continue | pass | pipe |\n"
+		"       \t          goto chain <CHAIN_INDEX>\n"
 			"\tRAND := random <RANDTYPE> <ACTION> <VAL>\n"
 			"\tRANDTYPE := netrand | determ\n"
 			"\tVAL : = value not exceeding 10000\n"
@@ -54,7 +55,8 @@ explain(void)
 #else
 	fprintf(stderr, "Usage: ... gact <ACTION> [INDEX]\n");
 	fprintf(stderr,
-		"Where: \tACTION := reclassify | drop | continue | pass | pipe\n"
+		"Where: \tACTION := reclassify | drop | continue | pass | pipe |\n"
+		"       \t          goto chain <CHAIN_INDEX>\n"
 		"\tINDEX := index value used\n"
 		"\n");
 #endif
diff --git a/tc/m_pedit.c b/tc/m_pedit.c
index 730a434..cb3bb0e 100644
--- a/tc/m_pedit.c
+++ b/tc/m_pedit.c
@@ -45,7 +45,8 @@ static void explain(void)
 		"\t\tCMD:= clear | invert | set <setval>| add <addval> | retain\n"
 		"\t<LAYERED>:= ip <ipdata> | ip6 <ip6data>\n"
 		" \t\t| udp <udpdata> | tcp <tcpdata> | icmp <icmpdata>\n"
-		"\tCONTROL:= reclassify | pipe | drop | continue | pass\n"
+		"\tCONTROL:= reclassify | pipe | drop | continue | pass |\n"
+		"\t          goto chain <CHAIN_INDEX>\n"
 		"\tNOTE: if 'ex' is set, extended functionality will be supported (kernel >= 4.11)\n"
 		"For Example usage look at the examples directory\n");
 
diff --git a/tc/m_police.c b/tc/m_police.c
index 2b73969..86117db 100644
--- a/tc/m_police.c
+++ b/tc/m_police.c
@@ -41,7 +41,8 @@ static void usage(void)
 	fprintf(stderr, "Where: CONTROL := conform-exceed <EXCEEDACT>[/NOTEXCEEDACT]\n");
 	fprintf(stderr, "                  Define how to handle packets which exceed (<EXCEEDACT>)\n");
 	fprintf(stderr, "                  or conform (<NOTEXCEEDACT>) the configured bandwidth limit.\n");
-	fprintf(stderr, "       EXCEEDACT/NOTEXCEEDACT := { pipe | ok | reclassify | drop | continue }\n");
+	fprintf(stderr, "       EXCEEDACT/NOTEXCEEDACT := { pipe | ok | reclassify | drop | continue |\n");
+	fprintf(stderr, "                                   goto chain <CHAIN_INDEX> }\n");
 	exit(-1);
 }
 
@@ -150,7 +151,8 @@ int act_parse_police(struct action_util *a, int *argc_p, char ***argv_p,
 			   matches(*argv, "shot") == 0 ||
 			   matches(*argv, "continue") == 0 ||
 			   matches(*argv, "pass") == 0 ||
-			   matches(*argv, "pipe") == 0) {
+			   matches(*argv, "pipe") == 0 ||
+			   matches(*argv, "goto") == 0) {
 			if (parse_action_control(&argc, &argv, &p.action, false))
 				return -1;
 		} else if (strcmp(*argv, "conform-exceed") == 0) {
diff --git a/tc/m_skbmod.c b/tc/m_skbmod.c
index 1ccd474..ba79308 100644
--- a/tc/m_skbmod.c
+++ b/tc/m_skbmod.c
@@ -36,7 +36,8 @@ static void skbmod_explain(void)
 		"\tDMAC := 6 byte Destination MAC address\n"
 		"\tSMAC := optional 6 byte Source MAC address\n"
 		"\tETYPE := optional 16 bit ethertype\n"
-		"\tCONTROL := reclassify|pipe|drop|continue|ok\n"
+		"\tCONTROL := reclassify | pipe | drop | continue | ok |\n"
+		"\t           goto chain <CHAIN_INDEX>\n"
 		"\tINDEX := skbmod index value to use\n");
 }
 
diff --git a/tc/m_vlan.c b/tc/m_vlan.c
index 2441b06..cccb499 100644
--- a/tc/m_vlan.c
+++ b/tc/m_vlan.c
@@ -32,7 +32,8 @@ static void explain(void)
 	fprintf(stderr, "       vlan modify [ protocol VLANPROTO ] id VLANID [ priority VLANPRIO ] [CONTROL]\n");
 	fprintf(stderr, "       VLANPROTO is one of 802.1Q or 802.1AD\n");
 	fprintf(stderr, "            with default: 802.1Q\n");
-	fprintf(stderr, "       CONTROL := reclassify | pipe | drop | continue | pass\n");
+	fprintf(stderr, "       CONTROL := reclassify | pipe | drop | continue | pass |\n");
+	fprintf(stderr, "                  goto chain <CHAIN_INDEX>\n");
 }
 
 static void usage(void)
diff --git a/tc/tc_util.c b/tc/tc_util.c
index fd543c5..4f7283d 100644
--- a/tc/tc_util.c
+++ b/tc/tc_util.c
@@ -415,6 +415,8 @@ static const char *action_n2a(int action)
 {
 	static char buf[64];
 
+	if (TC_ACT_EXT_CMP(action, TC_ACT_GOTO_CHAIN))
+		return "goto";
 	switch (action) {
 	case TC_ACT_UNSPEC:
 		return "continue";
@@ -459,6 +461,7 @@ static int action_a2n(char *arg, int *result, bool allow_num)
 		{"ok", TC_ACT_OK},
 		{"reclassify", TC_ACT_RECLASSIFY},
 		{"pipe", TC_ACT_PIPE},
+		{"goto", TC_ACT_GOTO_CHAIN},
 		{ NULL },
 	}, *iter;
 
@@ -498,6 +501,22 @@ int parse_action_control(int *argc_p, char ***argv_p,
 		fprintf(stderr, "Bad action type %s\n", *argv);
 		return -1;
 	}
+	if (result == TC_ACT_GOTO_CHAIN) {
+		__u32 chain_index;
+
+		NEXT_ARG();
+		if (matches(*argv, "chain") != 0) {
+			fprintf(stderr, "\"chain index\" expected\n");
+			return -1;
+		}
+		NEXT_ARG();
+		if (get_u32(&chain_index, *argv, 10) ||
+		    chain_index > TC_ACT_EXT_VAL_MASK) {
+			fprintf(stderr, "Illegal \"chain index\"\n");
+			return -1;
+		}
+		result |= chain_index;
+	}
 	NEXT_ARG_FWD();
 	*argc_p = argc;
 	*argv_p = argv;
@@ -605,7 +624,10 @@ int parse_action_control_slash(int *argc_p, char ***argv_p,
 void print_action_control(FILE *f, const char *prefix,
 			  int action, const char *suffix)
 {
-	fprintf(f, "%s%s%s", prefix, action_n2a(action), suffix);
+	fprintf(f, "%s%s", prefix, action_n2a(action));
+	if (TC_ACT_EXT_CMP(action, TC_ACT_GOTO_CHAIN))
+		fprintf(f, " chain %u", action & TC_ACT_EXT_VAL_MASK);
+	fprintf(f, "%s", suffix);
 }
 
 int get_linklayer(unsigned int *val, const char *arg)
-- 
2.9.3
