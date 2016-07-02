From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [iproute2 1/1] actions: skbedit add support for mod-ing skb pkt_type
Date: Sat,  2 Jul 2016 07:14:33 -0400
Message-ID: <1467458073-27857-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, daniel@iogearbox.net,
	xiyou.wangcong@gmail.com, phil@nwl.cc,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:35091 "EHLO
	mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751604AbcGBLOv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jul 2016 07:14:51 -0400
Received: by mail-it0-f65.google.com with SMTP id g127so4564699ith.2
        for <netdev@vger.kernel.org>; Sat, 02 Jul 2016 04:14:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

I'll make a formal submission sans the header when the kernel patches
makes it in. This version is for someone who wants to play around with
the net-next kernel patches i sent

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 include/linux/tc_act/tc_skbedit.h |  2 ++
 man/man8/tc-skbedit.8             |  9 +++++++
 tc/m_skbedit.c                    | 50 ++++++++++++++++++++++++++++++++++-----
 3 files changed, 55 insertions(+), 6 deletions(-)

diff --git a/include/linux/tc_act/tc_skbedit.h b/include/linux/tc_act/tc_skbedit.h
index fecb5cc..a4d00c6 100644
--- a/include/linux/tc_act/tc_skbedit.h
+++ b/include/linux/tc_act/tc_skbedit.h
@@ -27,6 +27,7 @@
 #define SKBEDIT_F_PRIORITY		0x1
 #define SKBEDIT_F_QUEUE_MAPPING		0x2
 #define SKBEDIT_F_MARK			0x4
+#define SKBEDIT_F_PTYPE			0x8
 
 struct tc_skbedit {
 	tc_gen;
@@ -40,6 +41,7 @@ enum {
 	TCA_SKBEDIT_QUEUE_MAPPING,
 	TCA_SKBEDIT_MARK,
 	TCA_SKBEDIT_PAD,
+	TCA_SKBEDIT_PTYPE,
 	__TCA_SKBEDIT_MAX
 };
 #define TCA_SKBEDIT_MAX (__TCA_SKBEDIT_MAX - 1)
diff --git a/man/man8/tc-skbedit.8 b/man/man8/tc-skbedit.8
index e690296..003f05c 100644
--- a/man/man8/tc-skbedit.8
+++ b/man/man8/tc-skbedit.8
@@ -11,6 +11,8 @@ skbedit - SKB editing action
 .IR PRIORITY " ] ["
 .B mark
 .IR MARK " ]"
+.B ptype
+.IR PTYPE " ]"
 .SH DESCRIPTION
 The
 .B skbedit
@@ -52,6 +54,13 @@ Change the packet's firewall mark value.
 is an unsigned 32bit value in automatically detected format (i.e., prefix with
 .RB ' 0x '
 for hexadecimal interpretation, etc.).
+.TP
+.BI ptype " PTYPE"
+Override the packet's type. Useful for setting packet type to host when
+needing to allow ingressing packets with the wrong MAC address but
+correct IP address.
+.I PTYPE
+is one of: host, otherhost, broadcast, multicast
 .SH SEE ALSO
 .BR tc (8),
 .BR tc-pedit (8)
diff --git a/tc/m_skbedit.c b/tc/m_skbedit.c
index 9ba288c..4f6c2b4 100644
--- a/tc/m_skbedit.c
+++ b/tc/m_skbedit.c
@@ -26,14 +26,17 @@
 #include "utils.h"
 #include "tc_util.h"
 #include <linux/tc_act/tc_skbedit.h>
+#include <linux/if_packet.h>
 
-static void
-explain(void)
+static void explain(void)
 {
-	fprintf(stderr, "Usage: ... skbedit <[QM] [PM] [MM]>\n"
+	fprintf(stderr, "Usage: ... skbedit <[QM] [PM] [MM] [PT]>\n"
 		"QM = queue_mapping QUEUE_MAPPING\n"
 		"PM = priority PRIORITY\n"
 		"MM = mark MARK\n"
+		"PT = ptype PACKETYPE\n"
+		"PACKETYPE = is one of:\n"
+		"  host, otherhost, broadcast, multicast\n"
 		"QUEUE_MAPPING = device transmit queue to use\n"
 		"PRIORITY = classID to assign to priority field\n"
 		"MARK = firewall mark to set\n");
@@ -55,7 +58,7 @@ parse_skbedit(struct action_util *a, int *argc_p, char ***argv_p, int tca_id,
 	int ok = 0;
 	struct rtattr *tail;
 	unsigned int tmp;
-	__u16 queue_mapping;
+	__u16 queue_mapping, ptype;
 	__u32 flags = 0, priority, mark;
 	struct tc_skbedit sel = { 0 };
 
@@ -90,6 +93,24 @@ parse_skbedit(struct action_util *a, int *argc_p, char ***argv_p, int tca_id,
 				return -1;
 			}
 			ok++;
+		} else if (matches(*argv, "ptype") == 0) {
+
+			NEXT_ARG();
+			if (matches(*argv, "host") == 0) {
+				ptype = PACKET_HOST;
+			} else if (matches(*argv, "broadcast") == 0) {
+				ptype = PACKET_BROADCAST;
+			} else if (matches(*argv, "multicast") == 0) {
+				ptype = PACKET_MULTICAST;
+			} else if (matches(*argv, "otherhost") == 0) {
+				ptype = PACKET_OTHERHOST;
+			} else {
+				fprintf(stderr, "Illegal ptype (%s)\n",
+					*argv);
+				return -1;
+			}
+			flags |= SKBEDIT_F_PTYPE;
+			ok++;
 		} else if (matches(*argv, "help") == 0) {
 			usage();
 		} else {
@@ -152,6 +173,9 @@ parse_skbedit(struct action_util *a, int *argc_p, char ***argv_p, int tca_id,
 	if (flags & SKBEDIT_F_MARK)
 		addattr_l(n, MAX_MSG, TCA_SKBEDIT_MARK,
 			  &mark, sizeof(mark));
+	if (flags & SKBEDIT_F_PTYPE)
+		addattr_l(n, MAX_MSG, TCA_SKBEDIT_PTYPE,
+			  &ptype, sizeof(ptype));
 	tail->rta_len = (char *)NLMSG_TAIL(n) - (char *)tail;
 
 	*argc_p = argc;
@@ -166,7 +190,7 @@ static int print_skbedit(struct action_util *au, FILE *f, struct rtattr *arg)
 	SPRINT_BUF(b1);
 	__u32 *priority;
 	__u32 *mark;
-	__u16 *queue_mapping;
+	__u16 *queue_mapping, *ptype;
 	struct tc_skbedit *p = NULL;
 
 	if (arg == NULL)
@@ -194,8 +218,22 @@ static int print_skbedit(struct action_util *au, FILE *f, struct rtattr *arg)
 		mark = RTA_DATA(tb[TCA_SKBEDIT_MARK]);
 		fprintf(f, " mark %d", *mark);
 	}
+	if (tb[TCA_SKBEDIT_PTYPE] != NULL) {
+		ptype = RTA_DATA(tb[TCA_SKBEDIT_PTYPE]);
+		if (*ptype == PACKET_HOST)
+			fprintf(f, " ptype host");
+		else if (*ptype == PACKET_BROADCAST)
+			fprintf(f, " ptype broadcast");
+		else if (*ptype == PACKET_MULTICAST)
+			fprintf(f, " ptype multicast");
+		else if (*ptype == PACKET_OTHERHOST)
+			fprintf(f, " ptype otherhost");
+		else
+			fprintf(f, " ptype %d", *ptype);
+	}
 
-	fprintf(f, "\n\t index %d ref %d bind %d", p->index, p->refcnt, p->bindcnt);
+	fprintf(f, "\n\t index %d ref %d bind %d",
+		p->index, p->refcnt, p->bindcnt);
 
 	if (show_stats) {
 		if (tb[TCA_SKBEDIT_TM]) {
-- 
1.9.1
