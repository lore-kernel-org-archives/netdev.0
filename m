From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH net-next v3 1/1] net sched actions: Add support for user cookies
Date: Sun, 15 Jan 2017 09:01:19 -0500
Message-ID: <1484488879-29560-2-git-send-email-jhs@emojatatu.com>
References: <1484488879-29560-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, jiri@mellanox.com, paulb@mellanox.com,
        john.fastabend@gmail.com, simon.horman@netronome.com,
        mrv@mojatatu.com, hadarh@mellanox.com, ogerlitz@mellanox.com,
        roid@mellanox.com, xiyou.wangcong@gmail.com, daniel@iogearbox.net,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:36015 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751053AbdAOOBi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 15 Jan 2017 09:01:38 -0500
Received: by mail-it0-f68.google.com with SMTP id o138so9751901ito.3
        for <netdev@vger.kernel.org>; Sun, 15 Jan 2017 06:01:38 -0800 (PST)
In-Reply-To: <1484488879-29560-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

Introduce optional 128-bit action cookie.
Like all other cookie schemes in the networking world (eg in protocols
like http or existing kernel fib protocol field, etc) the idea is to save
user state that when retrieved serves as a correlator. The kernel
_should not_ intepret it.  The user can store whatever they wish in the
128 bits.

Sample exercise(showing variable length use of cookie)

.. create an accept action with cookie a1b2c3d4
sudo $TC actions add action ok index 1 cookie a1b2c3d4

.. dump all gact actions..
sudo $TC -s actions ls action gact

	action order 0: gact action pass
	 random type none pass val 0
	 index 1 ref 1 bind 0 installed 5 sec used 5 sec
 	Action statistics:
	Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
	backlog 0b 0p requeues 0
	cookie a1b2c3d4

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
$ sudo $TC -s actions get action gact index 1

	action order 1: gact action pass
	 random type none pass val 0
	 index 1 ref 2 bind 1 installed 204 sec used 5 sec
 	Action statistics:
        Sent 12168 bytes 164 pkt (dropped 0, overlimits 0 requeues 0)
	backlog 0b 0p requeues 0
	cookie a1b2c3d4

.. try longer cookie...
$ sudo $TC actions replace action ok index 1 cookie 1234567890abcdef
.. dump..
$ sudo $TC -s actions ls action gact

	action order 1: gact action pass
	 random type none pass val 0
	 index 1 ref 2 bind 1 installed 204 sec used 5 sec
 	Action statistics:
        Sent 12168 bytes 164 pkt (dropped 0, overlimits 0 requeues 0)
	backlog 0b 0p requeues 0
	cookie 1234567890abcdef

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 include/net/act_api.h        |  1 +
 include/net/pkt_cls.h        | 19 +++++++++++++------
 include/uapi/linux/pkt_cls.h |  3 +++
 net/sched/act_api.c          | 29 +++++++++++++++++++++++++++--
 4 files changed, 44 insertions(+), 8 deletions(-)

diff --git a/include/net/act_api.h b/include/net/act_api.h
index 1d71644..0692458 100644
--- a/include/net/act_api.h
+++ b/include/net/act_api.h
@@ -41,6 +41,7 @@ struct tc_action {
 	struct rcu_head			tcfa_rcu;
 	struct gnet_stats_basic_cpu __percpu *cpu_bstats;
 	struct gnet_stats_queue __percpu *cpu_qstats;
+	struct tc_cookie	*act_ck;
 };
 #define tcf_head	common.tcfa_head
 #define tcf_index	common.tcfa_index
diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index f0a0514..f2fafeb 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -24,15 +24,15 @@ struct tcf_walker {
 }
 
 static inline unsigned long
-cls_set_class(struct tcf_proto *tp, unsigned long *clp, 
+cls_set_class(struct tcf_proto *tp, unsigned long *clp,
 	unsigned long cl)
 {
 	unsigned long old_cl;
-	
+
 	tcf_tree_lock(tp);
 	old_cl = __cls_set_class(clp, cl);
 	tcf_tree_unlock(tp);
- 
+
 	return old_cl;
 }
 
@@ -237,7 +237,7 @@ static inline int tcf_em_early_end(struct tcf_ematch *em, int result)
 
 	return 0;
 }
-	
+
 /**
  * struct tcf_ematch_tree - ematch tree handle
  *
@@ -246,8 +246,7 @@ static inline int tcf_em_early_end(struct tcf_ematch *em, int result)
  */
 struct tcf_ematch_tree {
 	struct tcf_ematch_tree_hdr hdr;
-	struct tcf_ematch *	matches;
-	
+	struct tcf_ematch *matches;
 };
 
 /**
@@ -515,4 +514,12 @@ struct tc_cls_bpf_offload {
 	u32 gen_flags;
 };
 
+
+/* This structure holds cookie structure that is passed from user
+ * to the kernel for actions and classifiers
+ */
+struct tc_cookie {
+	unsigned char ck[TC_COOKIE_MAX_SIZE];
+	unsigned char ck_len;
+};
 #endif
diff --git a/include/uapi/linux/pkt_cls.h b/include/uapi/linux/pkt_cls.h
index 1e5e1dd..2d2414e 100644
--- a/include/uapi/linux/pkt_cls.h
+++ b/include/uapi/linux/pkt_cls.h
@@ -4,6 +4,8 @@
 #include <linux/types.h>
 #include <linux/pkt_sched.h>
 
+#define TC_COOKIE_MAX_SIZE 16
+
 /* Action attributes */
 enum {
 	TCA_ACT_UNSPEC,
@@ -12,6 +14,7 @@ enum {
 	TCA_ACT_INDEX,
 	TCA_ACT_STATS,
 	TCA_ACT_PAD,
+	TCA_ACT_COOKIE,
 	__TCA_ACT_MAX
 };
 
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index f04715a..9d05b70 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -24,6 +24,7 @@
 #include <net/net_namespace.h>
 #include <net/sock.h>
 #include <net/sch_generic.h>
+#include <net/pkt_cls.h>
 #include <net/act_api.h>
 #include <net/netlink.h>
 
@@ -33,6 +34,7 @@ static void free_tcf(struct rcu_head *head)
 
 	free_percpu(p->cpu_bstats);
 	free_percpu(p->cpu_qstats);
+	kfree(p->act_ck);
 	kfree(p);
 }
 
@@ -464,8 +466,8 @@ int tcf_action_destroy(struct list_head *actions, int bind)
 	return a->ops->dump(skb, a, bind, ref);
 }
 
-int
-tcf_action_dump_1(struct sk_buff *skb, struct tc_action *a, int bind, int ref)
+int tcf_action_dump_1(struct sk_buff *skb, struct tc_action *a, int bind,
+		      int ref)
 {
 	int err = -EINVAL;
 	unsigned char *b = skb_tail_pointer(skb);
@@ -475,6 +477,12 @@ int tcf_action_destroy(struct list_head *actions, int bind)
 		goto nla_put_failure;
 	if (tcf_action_copy_stats(skb, a, 0))
 		goto nla_put_failure;
+	if (a->act_ck) {
+		if (nla_put(skb, TCA_ACT_COOKIE, a->act_ck->ck_len,
+			    a->act_ck))
+			goto nla_put_failure;
+	}
+
 	nest = nla_nest_start(skb, TCA_OPTIONS);
 	if (nest == NULL)
 		goto nla_put_failure;
@@ -575,6 +583,23 @@ struct tc_action *tcf_action_init_1(struct net *net, struct nlattr *nla,
 	if (err < 0)
 		goto err_mod;
 
+	if (tb[TCA_ACT_COOKIE]) {
+		if (nla_len(tb[TCA_ACT_COOKIE]) > TC_COOKIE_MAX_SIZE) {
+			err = -EINVAL;
+			goto err_mod;
+		}
+
+		a->act_ck = kzalloc(sizeof(*a->act_ck), GFP_KERNEL);
+		if (unlikely(!a->act_ck)) {
+			err = -ENOMEM;
+			goto err_mod;
+		}
+
+		memcpy(a->act_ck->ck, nla_data(tb[TCA_ACT_COOKIE]),
+		       nla_len(tb[TCA_ACT_COOKIE]));
+		a->act_ck->ck_len = nla_len(tb[TCA_ACT_COOKIE]);
+	}
+
 	/* module count goes up only when brand new policy is created
 	 * if it exists and is only bound to in a_o->init() then
 	 * ACT_P_CREATED is not returned (a zero is).
-- 
1.9.1
