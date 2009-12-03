From: jamal <hadi@cyberus.ca>
Subject: [PATCH 2/2] iproute2 skbedit: Add support to mark packets
Date: Thu, 03 Dec 2009 08:32:48 -0500
Message-ID: <1259847168.3766.40.camel@bigi>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-ESb+dI9KpbpxRRCsuWMm"
Cc: netdev@vger.kernel.org,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f192.google.com ([209.85.212.192]:38180 "EHLO
	mail-vw0-f192.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755913AbZLCNco (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 08:32:44 -0500
Received: by vws30 with SMTP id 30so600202vws.33
        for <netdev@vger.kernel.org>; Thu, 03 Dec 2009 05:32:50 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-ESb+dI9KpbpxRRCsuWMm
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

I did this originally because i was getting too many support
questions on ipt with mark. It still makes sense since skbedit
seems to be the mother action of skb metadata (should probably
have been called skbmeta).

cheers,
jamal

--=-ESb+dI9KpbpxRRCsuWMm
Content-Disposition: attachment; filename="skbeiprt-mark-p"
Content-Type: text/plain; name="skbeiprt-mark-p"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

commit 90afac29b6e8c62bc1b2a4da7c0dd4407ea9dd3f
Author: Jamal Hadi Salim <hadi@cyberus.ca>
Date:   Thu Dec 3 08:18:41 2009 -0500

    skbedit: Add support to mark packets
    
    This adds support for setting the skb mark.
    
    Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>
    Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>

diff --git a/include/linux/tc_act/tc_skbedit.h b/include/linux/tc_act/tc_skbedit.h
index a14e461..7a2e910 100644
--- a/include/linux/tc_act/tc_skbedit.h
+++ b/include/linux/tc_act/tc_skbedit.h
@@ -26,6 +26,7 @@
 
 #define SKBEDIT_F_PRIORITY		0x1
 #define SKBEDIT_F_QUEUE_MAPPING		0x2
+#define SKBEDIT_F_MARK			0x4
 
 struct tc_skbedit {
 	tc_gen;
@@ -37,6 +38,7 @@ enum {
 	TCA_SKBEDIT_PARMS,
 	TCA_SKBEDIT_PRIORITY,
 	TCA_SKBEDIT_QUEUE_MAPPING,
+	TCA_SKBEDIT_MARK,
 	__TCA_SKBEDIT_MAX
 };
 #define TCA_SKBEDIT_MAX (__TCA_SKBEDIT_MAX - 1)
diff --git a/tc/m_skbedit.c b/tc/m_skbedit.c
index ecb1f2d..623dc53 100644
--- a/tc/m_skbedit.c
+++ b/tc/m_skbedit.c
@@ -31,11 +31,13 @@
 static void
 explain(void)
 {
-	fprintf(stderr, "Usage: ... skbedit <[QM] [PM]>\n"
+	fprintf(stderr, "Usage: ... skbedit <[QM] [PM] [MM]>\n"
 			"QM = queue_mapping QUEUE_MAPPING\n"
 			"PM = priority PRIORITY \n"
+			"MM = mark MARK \n"
 			"QUEUE_MAPPING = device transmit queue to use\n"
-			"PRIORITY = classID to assign to priority field\n");
+			"PRIORITY = classID to assign to priority field\n"
+			"MARK = firewall mark to set\n");
 }
 
 static void
@@ -55,7 +57,7 @@ parse_skbedit(struct action_util *a, int *argc_p, char ***argv_p, int tca_id,
 	struct rtattr *tail;
 	unsigned int tmp;
 	__u16 queue_mapping;
-	__u32 flags = 0, priority;
+	__u32 flags = 0, priority, mark;
 	struct tc_skbedit sel = { 0 };
 
 	if (matches(*argv, "skbedit") != 0)
@@ -81,6 +83,14 @@ parse_skbedit(struct action_util *a, int *argc_p, char ***argv_p, int tca_id,
 				return -1;
 			}
 			ok++;
+		} else if (matches(*argv, "mark") == 0) {
+			flags |= SKBEDIT_F_MARK;
+			NEXT_ARG();
+			if (get_tc_classid(&mark, *argv)) {
+				fprintf(stderr, "Illegal mark\n");
+				return -1;
+			}
+			ok++;
 		} else if (matches(*argv, "help") == 0) {
 			usage();
 		} else {
@@ -138,6 +148,9 @@ parse_skbedit(struct action_util *a, int *argc_p, char ***argv_p, int tca_id,
 	if (flags & SKBEDIT_F_PRIORITY)
 		addattr_l(n, MAX_MSG, TCA_SKBEDIT_PRIORITY,
 			  &priority, sizeof(priority));
+	if (flags & SKBEDIT_F_MARK)
+		addattr_l(n, MAX_MSG, TCA_SKBEDIT_MARK,
+			  &mark, sizeof(mark));
 	tail->rta_len = (char *)NLMSG_TAIL(n) - (char *)tail;
 
 	*argc_p = argc;
@@ -151,6 +164,7 @@ static int print_skbedit(struct action_util *au, FILE *f, struct rtattr *arg)
 	struct rtattr *tb[TCA_SKBEDIT_MAX + 1];
 	SPRINT_BUF(b1);
 	__u32 *priority;
+	__u32 *mark;
 	__u16 *queue_mapping;
 
 	if (arg == NULL)
@@ -175,6 +189,10 @@ static int print_skbedit(struct action_util *au, FILE *f, struct rtattr *arg)
 		priority = RTA_DATA(tb[TCA_SKBEDIT_PRIORITY]);
 		fprintf(f, " priority %s", sprint_tc_classid(*priority, b1));
 	}
+	if (tb[TCA_SKBEDIT_MARK] != NULL) {
+		mark = RTA_DATA(tb[TCA_SKBEDIT_MARK]);
+		fprintf(f, " mark %d", *mark);
+	}
 
 	if (show_stats) {
 		if (tb[TCA_SKBEDIT_TM]) {

--=-ESb+dI9KpbpxRRCsuWMm--

