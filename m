From: Shmulik Ladkani <shmulik.ladkani@ravellosystems.com>
Subject: [PATCH iproute2 net-next] tc: m_vlan: Add vlan modify action
Date: Thu, 22 Sep 2016 12:31:10 +0300
Message-ID: <1474536670-2495-1-git-send-email-shmulik.ladkani@gmail.com>
Cc: <netdev@vger.kernel.org>, Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Pirko <jiri@resnulli.us>,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:34420 "EHLO
        mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753183AbcIVJbh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 05:31:37 -0400
Received: by mail-wm0-f41.google.com with SMTP id 197so4464044wmk.1
        for <netdev@vger.kernel.org>; Thu, 22 Sep 2016 02:31:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 'vlan modify' action allows to replace an existing 802.1q tag
according to user provided settings.
It accepts same arguments as the 'vlan push' action.

For example, this replaces vid 6 with vid 5:

 # tc filter add dev veth0 parent ffff: pref 1 protocol 802.1q \
      basic match 'meta(vlan mask 0xfff eq 6)' \
      action vlan modify id 5 continue

Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
---
 include/linux/tc_act/tc_vlan.h |  1 +
 man/man8/tc-vlan.8             | 25 ++++++++++++++++++------
 tc/m_vlan.c                    | 44 +++++++++++++++++++++++++++++++++---------
 3 files changed, 55 insertions(+), 15 deletions(-)

diff --git a/include/linux/tc_act/tc_vlan.h b/include/linux/tc_act/tc_vlan.h
index be72b6e..bddb272 100644
--- a/include/linux/tc_act/tc_vlan.h
+++ b/include/linux/tc_act/tc_vlan.h
@@ -16,6 +16,7 @@
 
 #define TCA_VLAN_ACT_POP	1
 #define TCA_VLAN_ACT_PUSH	2
+#define TCA_VLAN_ACT_MODIFY	3
 
 struct tc_vlan {
 	tc_gen;
diff --git a/man/man8/tc-vlan.8 b/man/man8/tc-vlan.8
index 4d0c5c8..af3de1c 100644
--- a/man/man8/tc-vlan.8
+++ b/man/man8/tc-vlan.8
@@ -6,7 +6,7 @@ vlan - vlan manipulation module
 .in +8
 .ti -8
 .BR tc " ... " "action vlan" " { " pop " |"
-.IR PUSH " } [ " CONTROL " ]"
+.IR PUSH " | " MODIFY " } [ " CONTROL " ]"
 
 .ti -8
 .IR PUSH " := "
@@ -17,22 +17,30 @@ vlan - vlan manipulation module
 .BI id " VLANID"
 
 .ti -8
+.IR MODIFY " := "
+.BR modify " [ " protocol
+.IR VLANPROTO " ]"
+.BR " [ " priority
+.IR VLANPRIO " ] "
+.BI id " VLANID"
+
+.ti -8
 .IR CONTROL " := { "
 .BR reclassify " | " pipe " | " drop " | " continue " | " pass " }"
 .SH DESCRIPTION
 The
 .B vlan
 action allows to perform 802.1Q en- or decapsulation on a packet, reflected by
-the two operation modes
-.IR POP " and " PUSH .
+the operation modes
+.IR POP ", " PUSH " and " MODIFY .
 The
 .I POP
 mode is simple, as no further information is required to just drop the
 outer-most VLAN encapsulation. The
-.I PUSH
-mode on the other hand requires at least a
+.IR PUSH " and " MODIFY
+modes require at least a
 .I VLANID
-and allows to optionally choose the
+and allow to optionally choose the
 .I VLANPROTO
 to use.
 .SH OPTIONS
@@ -45,6 +53,11 @@ Encapsulation mode. Requires at least
 .B id
 option.
 .TP
+.B modify
+Replace mode. Existing 802.1Q tag is replaced. Requires at least
+.B id
+option.
+.TP
 .BI id " VLANID"
 Specify the VLAN ID to encapsulate into.
 .I VLANID
diff --git a/tc/m_vlan.c b/tc/m_vlan.c
index 05a63b4..6de1c49 100644
--- a/tc/m_vlan.c
+++ b/tc/m_vlan.c
@@ -23,6 +23,7 @@ static void explain(void)
 {
 	fprintf(stderr, "Usage: vlan pop\n");
 	fprintf(stderr, "       vlan push [ protocol VLANPROTO ] id VLANID [ priority VLANPRIO ] [CONTROL]\n");
+	fprintf(stderr, "       vlan modify [ protocol VLANPROTO ] id VLANID [ priority VLANPRIO ] [CONTROL]\n");
 	fprintf(stderr, "       VLANPROTO is one of 802.1Q or 802.1AD\n");
 	fprintf(stderr, "            with default: 802.1Q\n");
 	fprintf(stderr, "       CONTROL := reclassify | pipe | drop | continue | pass\n");
@@ -34,6 +35,21 @@ static void usage(void)
 	exit(-1);
 }
 
+static bool has_push_attribs(int action)
+{
+	return action == TCA_VLAN_ACT_PUSH || action == TCA_VLAN_ACT_MODIFY;
+}
+
+static const char *action_name(int action)
+{
+	static const char * const names[] = {
+		[TCA_VLAN_ACT_POP] = "pop",
+		[TCA_VLAN_ACT_PUSH] = "push",
+		[TCA_VLAN_ACT_MODIFY] = "modify",
+	};
+	return names[action];
+}
+
 static int parse_vlan(struct action_util *a, int *argc_p, char ***argv_p,
 		      int tca_id, struct nlmsghdr *n)
 {
@@ -71,9 +87,17 @@ static int parse_vlan(struct action_util *a, int *argc_p, char ***argv_p,
 				return -1;
 			}
 			action = TCA_VLAN_ACT_PUSH;
+		} else if (matches(*argv, "modify") == 0) {
+			if (action) {
+				fprintf(stderr, "unexpected \"%s\" - action already specified\n",
+					*argv);
+				explain();
+				return -1;
+			}
+			action = TCA_VLAN_ACT_MODIFY;
 		} else if (matches(*argv, "id") == 0) {
-			if (action != TCA_VLAN_ACT_PUSH) {
-				fprintf(stderr, "\"%s\" is only valid for push\n",
+			if (!has_push_attribs(action)) {
+				fprintf(stderr, "\"%s\" is only valid for push/modify\n",
 					*argv);
 				explain();
 				return -1;
@@ -83,8 +107,8 @@ static int parse_vlan(struct action_util *a, int *argc_p, char ***argv_p,
 				invarg("id is invalid", *argv);
 			id_set = 1;
 		} else if (matches(*argv, "protocol") == 0) {
-			if (action != TCA_VLAN_ACT_PUSH) {
-				fprintf(stderr, "\"%s\" is only valid for push\n",
+			if (!has_push_attribs(action)) {
+				fprintf(stderr, "\"%s\" is only valid for push/modify\n",
 					*argv);
 				explain();
 				return -1;
@@ -94,8 +118,8 @@ static int parse_vlan(struct action_util *a, int *argc_p, char ***argv_p,
 				invarg("protocol is invalid", *argv);
 			proto_set = 1;
 		} else if (matches(*argv, "priority") == 0) {
-			if (action != TCA_VLAN_ACT_PUSH) {
-				fprintf(stderr, "\"%s\" is only valid for push\n",
+			if (!has_push_attribs(action)) {
+				fprintf(stderr, "\"%s\" is only valid for push/modify\n",
 					*argv);
 				explain();
 				return -1;
@@ -129,8 +153,9 @@ static int parse_vlan(struct action_util *a, int *argc_p, char ***argv_p,
 		}
 	}
 
-	if (action == TCA_VLAN_ACT_PUSH && !id_set) {
-		fprintf(stderr, "id needs to be set for push\n");
+	if (has_push_attribs(action) && !id_set) {
+		fprintf(stderr, "id needs to be set for %s\n",
+			action_name(action));
 		explain();
 		return -1;
 	}
@@ -186,7 +211,8 @@ static int print_vlan(struct action_util *au, FILE *f, struct rtattr *arg)
 		fprintf(f, " pop");
 		break;
 	case TCA_VLAN_ACT_PUSH:
-		fprintf(f, " push");
+	case TCA_VLAN_ACT_MODIFY:
+		fprintf(f, " %s", action_name(parm->v_action));
 		if (tb[TCA_VLAN_PUSH_VLAN_ID]) {
 			val = rta_getattr_u16(tb[TCA_VLAN_PUSH_VLAN_ID]);
 			fprintf(f, " id %u", val);
-- 
1.9.1
