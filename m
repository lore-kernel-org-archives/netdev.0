From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH iproute2 1/1] tc/actions: introduce support for jump action
Date: Sun, 22 Oct 2017 10:48:10 -0400
Message-ID: <1508683690-3440-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, jiri@resnulli.us, xiyou.wangcong@gmail.com,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:48706 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751003AbdJVOsW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 22 Oct 2017 10:48:22 -0400
Received: by mail-io0-f194.google.com with SMTP id j17so17612944iod.5
        for <netdev@vger.kernel.org>; Sun, 22 Oct 2017 07:48:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

Seems like my old patches didnt make it into the tree - so here goes

Sample use case:

... add ingress qdisc
sudo $TC qdisc add dev $ETH ingress

 ... if we exceed rate of 1kbps (burst of 90K), do an absolute jump of 2 actions
sudo $TC actions add action police rate 1kbit burst 90k conform-exceed jump 2 / pipe

sudo $TC -s actions ls action police
---
 action order 0:  police 0x4 rate 1Kbit burst 23440b mtu 2Kb action jump 2/pipe overhead 0b
 ref 1 bind 0 installed 41 sec used 41 sec
 Action statistics:
  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
  backlog 0b 0p requeues 0
--

... lets add a couple of marks so we can use them to mark exceed/not exceed
sudo $TC actions add action skbedit mark 11 ok index 11
sudo $TC actions add action skbedit mark 12 ok index 12

... if we dont exceed our rate we get a mark of 11, else mark of 12
sudo $TC filter add dev $ETH parent ffff: protocol ip prio 8 u32 \
match ip dst 127.0.0.8/32 flowid 1:10 \
action police index 4 \
action skbedit index 11 \
action skbedit index 12

Ok, lets keep this thing a little busy..
sudo ping -f -c 10000 127.0.0.8

... now lets see the filters..
sudo $TC -s filter ls dev $ETH parent ffff: protocol ip

----
filter pref 8 u32 chain 0
filter pref 8 u32 chain 0 fh 800: ht divisor 1
filter pref 8 u32 chain 0 fh 800::800 order 2048 key ht 800 bkt 0 flowid 1:10 not_in_hw  (rule hit 20000 success 10000)
  match 7f000008/ffffffff at 16 (success 10000 )
	action order 1:  police 0x4 rate 1Kbit burst 23440b mtu 2Kb action jump 2/pipe overhead 0b
	ref 2 bind 1 installed 198 sec used 2 sec
	Action statistics:
	Sent 840000 bytes 10000 pkt (dropped 0, overlimits 9721 requeues 0)
	backlog 0b 0p requeues 0

	action order 2:  skbedit mark 11 pass
	 index 11 ref 2 bind 1 installed 127 sec used 2 sec
 	Action statistics:
	Sent 23436 bytes 279 pkt (dropped 0, overlimits 0 requeues 0)
	backlog 0b 0p requeues 0

	action order 3:  skbedit mark 12 pass
	 index 12 ref 2 bind 1 installed 127 sec used 2 sec
 	Action statistics:
	Sent 816564 bytes 9721 pkt (dropped 0, overlimits 0 requeues 0)
	backlog 0b 0p requeues 0
-----

As can be seen 97.21% of the packets were marked as exceeding the allocated
rate; you could do something clever with the skb mark after this.

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 tc/m_gact.c  |  6 ++++--
 tc/tc_util.c | 16 ++++++++++++++++
 2 files changed, 20 insertions(+), 2 deletions(-)

diff --git a/tc/m_gact.c b/tc/m_gact.c
index df143c9..38949e9 100644
--- a/tc/m_gact.c
+++ b/tc/m_gact.c
@@ -46,18 +46,20 @@ explain(void)
 	fprintf(stderr, "Usage: ... gact <ACTION> [RAND] [INDEX]\n");
 	fprintf(stderr,
 		"Where: \tACTION := reclassify | drop | continue | pass | pipe |\n"
-		"       \t          goto chain <CHAIN_INDEX>\n"
+		"       \t          goto chain <CHAIN_INDEX> | jump <JUMP_COUNT>\n"
 			"\tRAND := random <RANDTYPE> <ACTION> <VAL>\n"
 			"\tRANDTYPE := netrand | determ\n"
 			"\tVAL : = value not exceeding 10000\n"
+			"\tJUMP_COUNT := Absolute jump from start of action list\n"
 			"\tINDEX := index value used\n"
 			"\n");
 #else
 	fprintf(stderr, "Usage: ... gact <ACTION> [INDEX]\n");
 	fprintf(stderr,
 		"Where: \tACTION := reclassify | drop | continue | pass | pipe |\n"
-		"       \t          goto chain <CHAIN_INDEX>\n"
+		"       \t          goto chain <CHAIN_INDEX> | jump <JUMP_COUNT>\n"
 		"\tINDEX := index value used\n"
+		"\tJUMP_COUNT := Absolute jump from start of action list\n"
 		"\n");
 #endif
 }
diff --git a/tc/tc_util.c b/tc/tc_util.c
index 50d3550..b39e550 100644
--- a/tc/tc_util.c
+++ b/tc/tc_util.c
@@ -417,6 +417,8 @@ static const char *action_n2a(int action)
 
 	if (TC_ACT_EXT_CMP(action, TC_ACT_GOTO_CHAIN))
 		return "goto";
+	if (TC_ACT_EXT_CMP(action, TC_ACT_JUMP))
+		return "jump";
 	switch (action) {
 	case TC_ACT_UNSPEC:
 		return "continue";
@@ -463,6 +465,7 @@ static int action_a2n(char *arg, int *result, bool allow_num)
 		{"reclassify", TC_ACT_RECLASSIFY},
 		{"pipe", TC_ACT_PIPE},
 		{"goto", TC_ACT_GOTO_CHAIN},
+		{"jump", TC_ACT_JUMP},
 		{"trap", TC_ACT_TRAP},
 		{ NULL },
 	}, *iter;
@@ -510,6 +513,17 @@ static int __parse_action_control(int *argc_p, char ***argv_p, int *result_p,
 		}
 		result |= chain_index;
 	}
+	if (result == TC_ACT_JUMP) {
+		__u32 jump_cnt = 0;
+
+		NEXT_ARG();
+		if (get_u32(&jump_cnt, *argv, 10) ||
+		    jump_cnt > TC_ACT_EXT_VAL_MASK) {
+			fprintf(stderr, "Invalid \"jump count\" (%s)\n", *argv);
+			return -1;
+		}
+		result |= jump_cnt;
+	}
 	NEXT_ARG_FWD();
 	*argc_p = argc;
 	*argv_p = argv;
@@ -637,6 +651,8 @@ void print_action_control(FILE *f, const char *prefix,
 	fprintf(f, "%s%s", prefix, action_n2a(action));
 	if (TC_ACT_EXT_CMP(action, TC_ACT_GOTO_CHAIN))
 		fprintf(f, " chain %u", action & TC_ACT_EXT_VAL_MASK);
+	if (TC_ACT_EXT_CMP(action, TC_ACT_JUMP))
+		fprintf(f, " %u", action & TC_ACT_EXT_VAL_MASK);
 	fprintf(f, "%s", suffix);
 }
 
-- 
1.9.1
