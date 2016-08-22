From: Hadar Hen Zion <hadarh@mellanox.com>
Subject: [PATCH iproute2 2/2] tc: m_vlan: Add priority option to push vlan action
Date: Mon, 22 Aug 2016 13:24:54 +0300
Message-ID: <1471861494-8299-3-git-send-email-hadarh@mellanox.com>
References: <1471861494-8299-1-git-send-email-hadarh@mellanox.com>
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Jiri Pirko <jiri@mellanox.com>,
        Amir Vadai <amirva@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:49749 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753827AbcHVKZb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 06:25:31 -0400
In-Reply-To: <1471861494-8299-1-git-send-email-hadarh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current vlan push action supports only vid and protocol options.
Add priority option.

Example script that adds vlan push action with vid and priority:

tc filter add dev veth0 protocol ip parent ffff: \
	flower \
	indev veth0 \
	action vlan push id 100 priority 5

Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
---
 include/linux/tc_act/tc_vlan.h |  1 +
 man/man8/tc-vlan.8             |  5 +++++
 tc/m_vlan.c                    | 22 +++++++++++++++++++++-
 3 files changed, 27 insertions(+), 1 deletion(-)

diff --git a/include/linux/tc_act/tc_vlan.h b/include/linux/tc_act/tc_vlan.h
index 26ae695..29e2113 100644
--- a/include/linux/tc_act/tc_vlan.h
+++ b/include/linux/tc_act/tc_vlan.h
@@ -32,6 +32,7 @@ enum {
 	TCA_VLAN_PUSH_VLAN_ID,
 	TCA_VLAN_PUSH_VLAN_PROTOCOL,
 	TCA_VLAN_PAD,
+	TCA_VLAN_PUSH_VLAN_PRIORITY,
 	__TCA_VLAN_MAX,
 };
 #define TCA_VLAN_MAX (__TCA_VLAN_MAX - 1)
diff --git a/man/man8/tc-vlan.8 b/man/man8/tc-vlan.8
index 4bfd72b..4d0c5c8 100644
--- a/man/man8/tc-vlan.8
+++ b/man/man8/tc-vlan.8
@@ -12,6 +12,8 @@ vlan - vlan manipulation module
 .IR PUSH " := "
 .BR push " [ " protocol
 .IR VLANPROTO " ]"
+.BR " [ " priority
+.IR VLANPRIO " ] "
 .BI id " VLANID"
 
 .ti -8
@@ -55,6 +57,9 @@ for hexadecimal interpretation, etc.).
 Choose the VLAN protocol to use. At the time of writing, the kernel accepts only
 .BR 802.1Q " or " 802.1ad .
 .TP
+.BI priority " VLANPRIO"
+Choose the VLAN priority to use. Decimal number in range of 0-7.
+.TP
 .I CONTROL
 How to continue after executing this action.
 .RS
diff --git a/tc/m_vlan.c b/tc/m_vlan.c
index ac63d9e..be2ffd2 100644
--- a/tc/m_vlan.c
+++ b/tc/m_vlan.c
@@ -22,7 +22,7 @@
 static void explain(void)
 {
 	fprintf(stderr, "Usage: vlan pop\n");
-	fprintf(stderr, "       vlan push [ protocol VLANPROTO ] id VLANID [CONTROL]\n");
+	fprintf(stderr, "       vlan push [ protocol VLANPROTO ] id VLANID [ priority VLANPRIO ] [CONTROL]\n");
 	fprintf(stderr, "       VLANPROTO is one of 802.1Q or 802.1AD\n");
 	fprintf(stderr, "            with default: 802.1Q\n");
 	fprintf(stderr, "       CONTROL := reclassify | pipe | drop | continue | pass\n");
@@ -45,6 +45,8 @@ static int parse_vlan(struct action_util *a, int *argc_p, char ***argv_p,
 	int id_set = 0;
 	__u16 proto;
 	int proto_set = 0;
+	__u8 prio;
+	int prio_set = 0;
 	struct tc_vlan parm = { 0 };
 
 	if (matches(*argv, "vlan") != 0)
@@ -91,6 +93,17 @@ static int parse_vlan(struct action_util *a, int *argc_p, char ***argv_p,
 			if (ll_proto_a2n(&proto, *argv))
 				invarg("protocol is invalid", *argv);
 			proto_set = 1;
+		} else if (matches(*argv, "priority") == 0) {
+			if (action != TCA_VLAN_ACT_PUSH) {
+				fprintf(stderr, "\"%s\" is only valid for push\n",
+					*argv);
+				explain();
+				return -1;
+			}
+			NEXT_ARG();
+			if (get_u8(&prio, *argv, 0) || (prio & ~VLAN_PRIO_MASK))
+				invarg("prio is invalid", *argv);
+			prio_set = 1;
 		} else if (matches(*argv, "help") == 0) {
 			usage();
 		} else {
@@ -138,6 +151,9 @@ static int parse_vlan(struct action_util *a, int *argc_p, char ***argv_p,
 
 		addattr_l(n, MAX_MSG, TCA_VLAN_PUSH_VLAN_PROTOCOL, &proto, 2);
 	}
+	if (prio_set)
+		addattr8(n, MAX_MSG, TCA_VLAN_PUSH_VLAN_PRIORITY, prio);
+
 	tail->rta_len = (char *)NLMSG_TAIL(n) - (char *)tail;
 
 	*argc_p = argc;
@@ -180,6 +196,10 @@ static int print_vlan(struct action_util *au, FILE *f, struct rtattr *arg)
 				ll_proto_n2a(rta_getattr_u16(tb[TCA_VLAN_PUSH_VLAN_PROTOCOL]),
 					     b1, sizeof(b1)));
 		}
+		if (tb[TCA_VLAN_PUSH_VLAN_PRIORITY]) {
+			val = rta_getattr_u8(tb[TCA_VLAN_PUSH_VLAN_PRIORITY]);
+			fprintf(f, " priority %u", val);
+		}
 		break;
 	}
 	fprintf(f, " %s", action_n2a(parm->action));
-- 
1.8.3.1
