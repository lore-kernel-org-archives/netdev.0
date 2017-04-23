From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH net-next 1/1] net sched actions: Complete the JUMPX opcode
Date: Sun, 23 Apr 2017 13:17:28 -0400
Message-ID: <1492967848-10165-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, jiri@resnulli.us, xiyou.wangcong@gmail.com,
        daniel@iogearbox.net, alexei.starovoitov@gmail.com,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:35066 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1162560AbdDWRRn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 23 Apr 2017 13:17:43 -0400
Received: by mail-it0-f65.google.com with SMTP id e132so10700135ite.2
        for <netdev@vger.kernel.org>; Sun, 23 Apr 2017 10:17:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

per discussion at netconf/netdev:
When we have an action that is capable of branching (example a policer),
we can achieve a continuation of the action graph by programming a
"continue" where we find an exact replica of the same filter rule with a lower
priority and the remainder of the action graph. When you have 100s of thousands
of filters which require such a feature it gets very inefficient to do two
lookups.

This patch completes a leftover feature of action codes. Its time has come.

Example below where a user labels packets with a different skbmark on ingress
of a port depending on whether they have/not exceeded the configured rate.
This mark is then used to make further decisions on some egress port.

 #rate control, very low so we can easily see the effect
sudo $TC actions add action police rate 1kbit burst 90k \
conform-exceed pipe/jump 2 index 10
 # skbedit index 11 will be used if the user conforms
sudo $TC actions add action skbedit mark 11 ok index 11
 # skbedit index 12 will be used if the user does not conform
sudo $TC actions add action skbedit mark 12 ok index 12

 #lets bind the user ..
sudo $TC filter add dev $ETH parent ffff: protocol ip prio 8 u32 \
match ip dst 127.0.0.8/32 flowid 1:10 \
action police index 10 \
action skbedit index 11 \
action skbedit index 12

 #run a ping -f and see what happens..
 #
jhs@foobar:~$ sudo $TC -s filter ls dev $ETH parent ffff: protocol ip
filter pref 8 u32
filter pref 8 u32 fh 800: ht divisor 1
filter pref 8 u32 fh 800::800 order 2048 key ht 800 bkt 0 flowid 1:10  (rule hit 2800 success 1005)
  match 7f000008/ffffffff at 16 (success 1005 )
	action order 1:  police 0xa rate 1Kbit burst 23440b mtu 2Kb action pipe/jump 2 overhead 0b
	ref 2 bind 1 installed 207 sec used 122 sec
	Action statistics:
	Sent 84420 bytes 1005 pkt (dropped 0, overlimits 721 requeues 0)
	backlog 0b 0p requeues 0

	action order 2:  skbedit mark 11 pass
	 index 11 ref 2 bind 1 installed 204 sec used 122 sec
 	Action statistics:
	Sent 60564 bytes 721 pkt (dropped 0, overlimits 0 requeues 0)
	backlog 0b 0p requeues 0

	action order 3:  skbedit mark 12 pass
	 index 12 ref 2 bind 1 installed 201 sec used 122 sec
 	Action statistics:
	Sent 23856 bytes 284 pkt (dropped 0, overlimits 0 requeues 0)
	backlog 0b 0p requeues 0

Not bad, about 28% non-conforming packets..

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 net/sched/act_api.c | 25 +++++++++++++++++++++++++
 1 file changed, 25 insertions(+)

diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 257360f..7f2cd70 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -428,24 +428,49 @@ static struct tc_action_ops *tc_lookup_action(struct nlattr *kind)
 	return res;
 }
 
+/*TCA_ACT_MAX_PRIO is 32, there count upto 32 */
+#define TCA_ACT_MAX_PRIO_MASK 0x1FF
 int tcf_action_exec(struct sk_buff *skb, struct tc_action **actions,
 		    int nr_actions, struct tcf_result *res)
 {
 	int ret = -1, i;
+	u32 jmp_prgcnt = 0;
+	u32 jmp_ttl = TCA_ACT_MAX_PRIO; /*matches actions per filter */
 
 	if (skb_skip_tc_classify(skb))
 		return TC_ACT_OK;
 
+restart_act_graph:
 	for (i = 0; i < nr_actions; i++) {
 		const struct tc_action *a = actions[i];
 
+		if (jmp_prgcnt > 0) {
+			jmp_prgcnt -= 1;
+			continue;
+		}
 repeat:
 		ret = a->ops->act(skb, a, res);
 		if (ret == TC_ACT_REPEAT)
 			goto repeat;	/* we need a ttl - JHS */
+
+		if (ret & TC_ACT_JUMP) {
+			jmp_prgcnt = ret & TCA_ACT_MAX_PRIO_MASK;
+			if (!jmp_prgcnt || (jmp_prgcnt > nr_actions)) {
+				/* faulty opcode, stop pipeline */
+				return TC_ACT_OK;
+			} else {
+				jmp_ttl -= 1;
+				if (jmp_ttl > 0)
+					goto restart_act_graph;
+				else /* faulty graph, stop pipeline */
+					return TC_ACT_OK;
+			}
+		}
+
 		if (ret != TC_ACT_PIPE)
 			break;
 	}
+
 	return ret;
 }
 EXPORT_SYMBOL(tcf_action_exec);
-- 
1.9.1
