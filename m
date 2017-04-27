From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch iproute2 2/2] tc_gact: introduce support for goto chain action
Date: Thu, 27 Apr 2017 13:15:55 +0200
Message-ID: <1493291755-2215-2-git-send-email-jiri@resnulli.us>
References: <1493291540-2119-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        dsa@cumulusnetworks.com, edumazet@google.com,
        stephen@networkplumber.org, daniel@iogearbox.net,
        alexander.h.duyck@intel.com, mlxsw@mellanox.com,
        simon.horman@netronome.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34484 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754344AbdD0LQA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 07:16:00 -0400
Received: by mail-wm0-f66.google.com with SMTP id z129so3846979wmb.1
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2017 04:15:59 -0700 (PDT)
In-Reply-To: <1493291540-2119-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Allow user to set action "goto" with filter chain index as a parameter.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/linux/pkt_cls.h        |  1 +
 include/linux/tc_act/tc_gact.h |  1 +
 tc/m_gact.c                    | 32 ++++++++++++++++++++++++++++----
 tc/tc_util.c                   |  3 +++
 4 files changed, 33 insertions(+), 4 deletions(-)

diff --git a/include/linux/pkt_cls.h b/include/linux/pkt_cls.h
index 7a69f2a..4f347b0 100644
--- a/include/linux/pkt_cls.h
+++ b/include/linux/pkt_cls.h
@@ -37,6 +37,7 @@ enum {
 #define TC_ACT_QUEUED		5
 #define TC_ACT_REPEAT		6
 #define TC_ACT_REDIRECT		7
+#define TC_ACT_GOTO_CHAIN	8
 #define TC_ACT_JUMP		0x10000000
 
 /* Action type identifiers*/
diff --git a/include/linux/tc_act/tc_gact.h b/include/linux/tc_act/tc_gact.h
index 70b536a..388733d 100644
--- a/include/linux/tc_act/tc_gact.h
+++ b/include/linux/tc_act/tc_gact.h
@@ -26,6 +26,7 @@ enum {
 	TCA_GACT_PARMS,
 	TCA_GACT_PROB,
 	TCA_GACT_PAD,
+	TCA_GACT_CHAIN,
 	__TCA_GACT_MAX
 };
 #define TCA_GACT_MAX (__TCA_GACT_MAX - 1)
diff --git a/tc/m_gact.c b/tc/m_gact.c
index 755a3be..f8d1c1e 100644
--- a/tc/m_gact.c
+++ b/tc/m_gact.c
@@ -43,19 +43,21 @@ static void
 explain(void)
 {
 #ifdef CONFIG_GACT_PROB
-	fprintf(stderr, "Usage: ... gact <ACTION> [RAND] [INDEX]\n");
+	fprintf(stderr, "Usage: ... gact <ACTION> [RAND] [INDEX] [OPTIONS]\n");
 	fprintf(stderr,
-		"Where: \tACTION := reclassify | drop | continue | pass | pipe\n"
+		"Where: \tACTION := reclassify | drop | continue | pass | pipe | goto\n"
 			"\tRAND := random <RANDTYPE> <ACTION> <VAL>\n"
 			"\tRANDTYPE := netrand | determ\n"
 			"\tVAL : = value not exceeding 10000\n"
 			"\tINDEX := index value used\n"
+			"\tOPTIONS: := chain <CHAIN_INDEX>\n"
 			"\n");
 #else
-	fprintf(stderr, "Usage: ... gact <ACTION> [INDEX]\n");
+	fprintf(stderr, "Usage: ... gact <ACTION> [INDEX] [OPTIONS]\n");
 	fprintf(stderr,
-		"Where: \tACTION := reclassify | drop | continue | pass | pipe\n"
+		"Where: \tACTION := reclassify | drop | continue | pass | pipe | goto\n"
 		"\tINDEX := index value used\n"
+		"\tOPTIONS: := chain <CHAIN_INDEX>\n"
 		"\n");
 #endif
 }
@@ -93,6 +95,7 @@ parse_gact(struct action_util *a, int *argc_p, char ***argv_p,
 	int rd = 0;
 	struct tc_gact_p pp;
 #endif
+	__u32 chain_index;
 	struct rtattr *tail;
 
 	if (argc < 0)
@@ -173,6 +176,23 @@ parse_gact(struct action_util *a, int *argc_p, char ***argv_p,
 		}
 	}
 
+	if (ok && action == TC_ACT_GOTO_CHAIN) {
+		if (matches(*argv, "chain") == 0) {
+			NEXT_ARG();
+			if (get_u32(&chain_index, *argv, 10)) {
+				fprintf(stderr, "Illegal \"chain index\"\n");
+				return -1;
+			}
+			argc--;
+			argv++;
+		} else if (matches(*argv, "help") == 0) {
+			usage();
+		} else {
+			fprintf(stderr, "\"chain\" needs to be specified for \"goto\" action\n");
+			return -1;
+		}
+	}
+
 	if (!ok)
 		return -1;
 
@@ -184,6 +204,8 @@ parse_gact(struct action_util *a, int *argc_p, char ***argv_p,
 		addattr_l(n, MAX_MSG, TCA_GACT_PROB, &pp, sizeof(pp));
 	}
 #endif
+	if (action == TC_ACT_GOTO_CHAIN)
+		addattr32(n, MAX_MSG, TCA_GACT_CHAIN, chain_index);
 	tail->rta_len = (void *) NLMSG_TAIL(n) - (void *) tail;
 
 	*argc_p = argc;
@@ -213,6 +235,8 @@ print_gact(struct action_util *au, FILE * f, struct rtattr *arg)
 	p = RTA_DATA(tb[TCA_GACT_PARMS]);
 
 	fprintf(f, "gact action %s", action_n2a(p->action));
+	if (tb[TCA_GACT_CHAIN])
+		fprintf(f, " chain %u", rta_getattr_u32(tb[TCA_GACT_CHAIN]));
 #ifdef CONFIG_GACT_PROB
 	if (tb[TCA_GACT_PROB] != NULL) {
 		pp = RTA_DATA(tb[TCA_GACT_PROB]);
diff --git a/tc/tc_util.c b/tc/tc_util.c
index 24ca1f1..a75367f 100644
--- a/tc/tc_util.c
+++ b/tc/tc_util.c
@@ -428,6 +428,8 @@ const char *action_n2a(int action)
 		return "pipe";
 	case TC_ACT_STOLEN:
 		return "stolen";
+	case TC_ACT_GOTO_CHAIN:
+		return "goto";
 	default:
 		snprintf(buf, 64, "%d", action);
 		buf[63] = '\0';
@@ -459,6 +461,7 @@ int action_a2n(char *arg, int *result, bool allow_num)
 		{"ok", TC_ACT_OK},
 		{"reclassify", TC_ACT_RECLASSIFY},
 		{"pipe", TC_ACT_PIPE},
+		{"goto", TC_ACT_GOTO_CHAIN},
 		{ NULL },
 	}, *iter;
 
-- 
2.7.4
