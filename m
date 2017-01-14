From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH net-next 1/1] net sched actions: Add support for user cookies
Date: Sat, 14 Jan 2017 09:59:18 -0500
Message-ID: <1484405958-24591-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, jiri@mellanox.com, paulb@mellanox.com,
        john.fastabend@gmail.com, simon.horman@netronome.com,
        mrv@mojatatu.com, hadarh@mellanox.com, ogerlitz@mellanox.com,
        roid@mellanox.com, xiyou.wangcong@gmail.com, daniel@iogearbox.net,
        Jamal Hadi Salim <hadi@mojatatu.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:34931 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750963AbdANO7e (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 14 Jan 2017 09:59:34 -0500
Received: by mail-it0-f65.google.com with SMTP id 203so7953606ith.2
        for <netdev@vger.kernel.org>; Sat, 14 Jan 2017 06:59:34 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <hadi@mojatatu.com>

Introduce optional 128-bit action cookie.
Like all other cookie schemes in the networking world (eg in protocols
like http or existing kernel fib protocol field, etc) the idea is to save
user state that when retrieved serves as a correlator. The kernel
_should not_ intepret it.  The user can store whatever they wish in the
128 bits.

Sample exercise(using two 64bit values to represent the 128 bits):

.. create an accept action with cookie 0xA:0xa0a0a0a0a0a0a0
sudo $TC actions add action ok index 1 cookie 0xA 0xa0a0a0a0a0a0a0

.. dump all gact actions..
sudo $TC -s actions ls action gact

	action order 0: gact action pass
	 random type none pass val 0
	 index 1 ref 2 bind 1 installed 1221 sec used 27 sec
 	Action statistics:
	Sent 373248 bytes 5056 pkt (dropped 0, overlimits 0 requeues 0)
	backlog 0b 0p requeues 0
	 cookie(0000000a:00000000:a0a0a0a0:00a0a0a0)

.. bind the accept action to a filter..
sudo $TC filter add dev lo parent ffff: protocol ip prio 1 \
u32 match ip dst 127.0.0.1/32 flowid 1:1 action gact index 1

... send some traffic..
$ ping 127.0.0.1 -c 3
PING 127.0.0.1 (127.0.0.1) 56(84) bytes of data.
64 bytes from 127.0.0.1: icmp_seq=1 ttl=64 time=0.020 ms
64 bytes from 127.0.0.1: icmp_seq=2 ttl=64 time=0.027 ms
64 bytes from 127.0.0.1: icmp_seq=3 ttl=64 time=0.038 ms

--- 127.0.0.1 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2109ms
rtt min/avg/max/mdev = 0.020/0.028/0.038/0.008 ms 1

... show some stats
$ sudo $TC -s actions get  action gact index 1

	action order 1: gact action pass
	 random type none pass val 0
	 index 1 ref 3 bind 1 installed 2182 sec used 1 sec
 	Action statistics:
	Sent 700344 bytes 9486 pkt (dropped 0, overlimits 0 requeues 0)
	backlog 0b 0p requeues 0

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 include/net/act_api.h        |  7 +++++++
 include/uapi/linux/pkt_cls.h |  7 +++++++
 net/sched/act_api.c          | 27 +++++++++++++++++++++++++--
 3 files changed, 39 insertions(+), 2 deletions(-)

diff --git a/include/net/act_api.h b/include/net/act_api.h
index 1d71644..b948db9 100644
--- a/include/net/act_api.h
+++ b/include/net/act_api.h
@@ -20,6 +20,12 @@ struct tcf_hashinfo {
 
 struct tc_action_ops;
 
+union act_cookie {
+	u16 ck16[8];
+	u32 ck32[4];
+	u64 ck64[2];
+};
+
 struct tc_action {
 	const struct tc_action_ops	*ops;
 	__u32				type; /* for backward compat(TCA_OLD_COMPAT) */
@@ -41,6 +47,7 @@ struct tc_action {
 	struct rcu_head			tcfa_rcu;
 	struct gnet_stats_basic_cpu __percpu *cpu_bstats;
 	struct gnet_stats_queue __percpu *cpu_qstats;
+	union act_cookie	*ck;
 };
 #define tcf_head	common.tcfa_head
 #define tcf_index	common.tcfa_index
diff --git a/include/uapi/linux/pkt_cls.h b/include/uapi/linux/pkt_cls.h
index 1e5e1dd..6379af3 100644
--- a/include/uapi/linux/pkt_cls.h
+++ b/include/uapi/linux/pkt_cls.h
@@ -4,6 +4,12 @@
 #include <linux/types.h>
 #include <linux/pkt_sched.h>
 
+union u_act_cookie {
+	__u16 ck16[8];
+	__u32 ck32[4];
+	__u64 ck64[2];
+};
+
 /* Action attributes */
 enum {
 	TCA_ACT_UNSPEC,
@@ -12,6 +18,7 @@ enum {
 	TCA_ACT_INDEX,
 	TCA_ACT_STATS,
 	TCA_ACT_PAD,
+	TCA_ACT_COOKIE,
 	__TCA_ACT_MAX
 };
 
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index f04715a..85e77181 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -33,6 +33,7 @@ static void free_tcf(struct rcu_head *head)
 
 	free_percpu(p->cpu_bstats);
 	free_percpu(p->cpu_qstats);
+	kfree(p->ck);
 	kfree(p);
 }
 
@@ -464,8 +465,8 @@ int tcf_action_destroy(struct list_head *actions, int bind)
 	return a->ops->dump(skb, a, bind, ref);
 }
 
-int
-tcf_action_dump_1(struct sk_buff *skb, struct tc_action *a, int bind, int ref)
+int tcf_action_dump_1(struct sk_buff *skb, struct tc_action *a, int bind,
+		      int ref)
 {
 	int err = -EINVAL;
 	unsigned char *b = skb_tail_pointer(skb);
@@ -475,6 +476,12 @@ int tcf_action_destroy(struct list_head *actions, int bind)
 		goto nla_put_failure;
 	if (tcf_action_copy_stats(skb, a, 0))
 		goto nla_put_failure;
+	if (a->ck) {
+		if (nla_put(skb, TCA_ACT_COOKIE, sizeof(union act_cookie),
+			    a->ck))
+			goto nla_put_failure;
+	}
+
 	nest = nla_nest_start(skb, TCA_OPTIONS);
 	if (nest == NULL)
 		goto nla_put_failure;
@@ -575,6 +582,22 @@ struct tc_action *tcf_action_init_1(struct net *net, struct nlattr *nla,
 	if (err < 0)
 		goto err_mod;
 
+	if (tb[TCA_ACT_COOKIE]) {
+		if (nla_len(tb[TCA_ACT_COOKIE]) != sizeof(union act_cookie)) {
+			err = -EINVAL;
+			goto err_mod;
+		}
+
+		a->ck = kzalloc(sizeof(union act_cookie), GFP_KERNEL);
+		if (unlikely(!a->ck)) {
+			err = -ENOMEM;
+			goto err_mod;
+		}
+
+		memcpy((void *)a->ck, nla_data(tb[TCA_ACT_COOKIE]),
+		       sizeof(union act_cookie));
+	}
+
 	/* module count goes up only when brand new policy is created
 	 * if it exists and is only bound to in a_o->init() then
 	 * ACT_P_CREATED is not returned (a zero is).
-- 
1.9.1
