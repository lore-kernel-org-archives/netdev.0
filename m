From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC iproute2/net-next v2 2/2] tc: flower: allow control of tree traversal on packet parse errors
Date: Fri,  5 May 2017 14:51:25 +0200
Message-ID: <1493988685-7891-3-git-send-email-simon.horman@netronome.com>
References: <1493988685-7891-1-git-send-email-simon.horman@netronome.com>
Cc: Jiri Pirko <jiri@resnulli.us>, Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Dinan Gunawardena <dinan.gunawardena@netronome.com>,
        netdev@vger.kernel.org, oss-drivers@netronome.com,
        Simon Horman <simon.horman@netronome.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:36572 "EHLO
        mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753765AbdEEMvv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 5 May 2017 08:51:51 -0400
Received: by mail-wm0-f48.google.com with SMTP id u65so22978946wmu.1
        for <netdev@vger.kernel.org>; Fri, 05 May 2017 05:51:51 -0700 (PDT)
In-Reply-To: <1493988685-7891-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow control how the tree of qdisc, classes and filters is further
traversed if an error is encountered when parsing the packet in order to
match the cls_flower filters at a particular prio.

By default continue to the next filter, the behaviour without this patch.

A use-case for this is to allow configuration of dropping of packets with
truncated headers.

For example, the following drops IPv4 packets that cannot be parsed by the
flow dissector up to the end of the UDP ports - e.g. because they are
truncated, and instantiates a continue action based on the port for packets
that can be parsed.

 # tc qdisc del dev eth0 ingress; tc qdisc add dev eth0 ingress
 # tc filter add dev eth0 protocol ip parent ffff: flower \
       indev eth0 ip_proto udp dst_port 80 truncated drop action continue

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 man/man8/tc-flower.8 | 29 +++++++++++++++++++++++++++--
 tc/f_flower.c        | 33 +++++++++++++++++++++++++++++++++
 2 files changed, 60 insertions(+), 2 deletions(-)

diff --git a/man/man8/tc-flower.8 b/man/man8/tc-flower.8
index ba290657c224..23b450b193d8 100644
--- a/man/man8/tc-flower.8
+++ b/man/man8/tc-flower.8
@@ -7,6 +7,8 @@ flower \- flow based traffic control filter
 .ti -8
 .BR tc " " filter " ... " flower " [ "
 .IR MATCH_LIST " ] [ "
+.B truncated
+.IR CONTROL " ] [ "
 .B action
 .IR ACTION_SPEC " ] [ "
 .B classid
@@ -64,6 +66,28 @@ action from the generic action framework may be called.
 .BI action " ACTION_SPEC"
 Apply an action from the generic actions framework on matching packets.
 .TP
+.BI truncated " CONTROL"
+Control how the tree of qdisc, classes and filters is further traversed if
+an truncated header is encountered when parsing the packet in order to match
+against the \fIMATCH_LIST\fR.
+.RS
+.TP
+.B drop
+.TQ
+.B shot
+Drop the packet.
+.TP
+.B continue
+Continue classification with the next filter in line.
+.TP
+.B pass
+Finish classification process and return to calling qdisc for further packet
+processing. This is the default.
+.P
+All filters with the same prio must have the same truncated value - drop
+and shot are considered to be the same value.
+.RE
+.TP
 .BI classid " CLASSID"
 Specify a class to pass matching packets on to.
 .I CLASSID
@@ -219,8 +243,9 @@ and finally ICMP matches (\fBcode\fR and \fBtype\fR) depend on
 being set to
 .BR icmp " or " icmpv6.
 .P
-There can be only used one mask per one prio. If user needs to specify different
-mask, he has to use different prio.
+There can be only used one mask and truncated value per one prio.  If user
+needs to specify different mask or truncated value, he has to use different
+prio.
 .SH SEE ALSO
 .BR tc (8),
 .BR tc-flow (8)
diff --git a/tc/f_flower.c b/tc/f_flower.c
index 5aac4a0837f4..7f8a386c1444 100644
--- a/tc/f_flower.c
+++ b/tc/f_flower.c
@@ -43,6 +43,7 @@ static void explain(void)
 	fprintf(stderr,
 		"Usage: ... flower [ MATCH-LIST ]\n"
 		"                  [ skip_sw | skip_hw ]\n"
+		"                  [ truncated CONTROL ]\n"
 		"                  [ action ACTION-SPEC ] [ classid CLASSID ]\n"
 		"\n"
 		"Where: MATCH-LIST := [ MATCH-LIST ] MATCH\n"
@@ -72,6 +73,7 @@ static void explain(void)
 		"       FILTERID := X:Y:Z\n"
 		"       MASKED_LLADDR := { LLADDR | LLADDR/MASK | LLADDR/BITS }\n"
 		"       ACTION-SPEC := ... look at individual actions\n"
+		"       CONTROL := ... drop | shot | continue | pass\n"
 		"\n"
 		"NOTE: CLASSID, IP-PROTO are parsed as hexadecimal input.\n"
 		"NOTE: There can be only used one mask per one prio. If user needs\n"
@@ -507,12 +509,14 @@ static int flower_parse_opt(struct filter_util *qu, char *handle,
 	struct tcmsg *t = NLMSG_DATA(n);
 	struct rtattr *tail;
 	__be16 eth_type = TC_H_MIN(t->tcm_info);
+	int err_action = TC_ACT_UNSPEC;
 	__be16 vlan_ethtype = 0;
 	__u8 ip_proto = 0xff;
 	__u32 flags = 0;
 	__u32 mtf = 0;
 	__u32 mtf_mask = 0;
 
+
 	if (handle) {
 		ret = get_u32(&t->tcm_handle, handle, 0);
 		if (ret) {
@@ -788,6 +792,23 @@ static int flower_parse_opt(struct filter_util *qu, char *handle,
 				return -1;
 			}
 			continue;
+		} else if (matches(*argv, "truncated") == 0) {
+			NEXT_ARG();
+
+			if (!argc || action_a2n(*argv, &err_action, false)) {
+				fprintf(stderr, "Illegal \"truncated\"\n");
+				return -1;
+			}
+
+			switch (err_action) {
+			case TC_ACT_UNSPEC:
+			case TC_ACT_OK:
+			case TC_ACT_SHOT:
+				break;
+			default:
+				fprintf(stderr, "Illegal \"truncated\"\n");
+				return -1;
+			}
 		} else if (strcmp(*argv, "help") == 0) {
 			explain();
 			return -1;
@@ -820,6 +841,12 @@ parse_done:
 			return ret;
 	}
 
+	ret = addattr32(n, MAX_MSG, TCA_FLOWER_META_TRUNCATED,
+			err_action);
+	if (ret)
+		return ret;
+
+
 	tail->rta_len = (((void *)n)+n->nlmsg_len) - (void *)tail;
 
 	return 0;
@@ -1173,6 +1200,12 @@ static int flower_print_opt(struct filter_util *qu, FILE *f,
 			fprintf(f, "\n  skip_sw");
 	}
 
+	if (tb[TCA_FLOWER_META_TRUNCATED]) {
+		int act = rta_getattr_u32(tb[TCA_FLOWER_META_TRUNCATED]);
+
+		fprintf(f, "\n  truncated %s", action_n2a(act));
+	}
+
 	if (tb[TCA_FLOWER_ACT])
 		tc_print_action(f, tb[TCA_FLOWER_ACT]);
 
-- 
2.1.4
