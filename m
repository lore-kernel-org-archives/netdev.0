From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v7 1/1] net sched actions: Add support for user
 cookies
Date: Tue, 24 Jan 2017 13:15:20 +0100
Message-ID: <20170124121520.GE1891@nanopsycho>
References: <1485259361-16860-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, jiri@mellanox.com,
        paulb@mellanox.com, john.fastabend@gmail.com,
        simon.horman@netronome.com, mrv@mojatatu.com, hadarh@mellanox.com,
        ogerlitz@mellanox.com, roid@mellanox.com, xiyou.wangcong@gmail.com,
        daniel@iogearbox.net
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35020 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750782AbdAXMPY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 07:15:24 -0500
Received: by mail-wm0-f67.google.com with SMTP id d140so34343423wmd.2
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 04:15:24 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1485259361-16860-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Jan 24, 2017 at 01:02:41PM CET, jhs@mojatatu.com wrote:
>From: Jamal Hadi Salim <jhs@mojatatu.com>
>
>Introduce optional 128-bit action cookie.
>Like all other cookie schemes in the networking world (eg in protocols
>like http or existing kernel fib protocol field, etc) the idea is to save
>user state that when retrieved serves as a correlator. The kernel
>_should not_ intepret it.  The user can store whatever they wish in the
>128 bits.
>
>Sample exercise(showing variable length use of cookie)
>
>.. create an accept action with cookie a1b2c3d4
>sudo $TC actions add action ok index 1 cookie a1b2c3d4
>
>.. dump all gact actions..
>sudo $TC -s actions ls action gact
>
>    action order 0: gact action pass
>     random type none pass val 0
>     index 1 ref 1 bind 0 installed 5 sec used 5 sec
>    Action statistics:
>    Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>    backlog 0b 0p requeues 0
>    cookie a1b2c3d4
>
>.. bind the accept action to a filter..
>sudo $TC filter add dev lo parent ffff: protocol ip prio 1 \
>u32 match ip dst 127.0.0.1/32 flowid 1:1 action gact index 1
>
>... send some traffic..
>$ ping 127.0.0.1 -c 3
>PING 127.0.0.1 (127.0.0.1) 56(84) bytes of data.
>64 bytes from 127.0.0.1: icmp_seq=1 ttl=64 time=0.020 ms
>64 bytes from 127.0.0.1: icmp_seq=2 ttl=64 time=0.027 ms
>64 bytes from 127.0.0.1: icmp_seq=3 ttl=64 time=0.038 ms
>
>--- 127.0.0.1 ping statistics ---
>3 packets transmitted, 3 received, 0% packet loss, time 2109ms
>rtt min/avg/max/mdev = 0.020/0.028/0.038/0.008 ms 1
>
>... show some stats
>$ sudo $TC -s actions get action gact index 1
>
>    action order 1: gact action pass
>     random type none pass val 0
>     index 1 ref 2 bind 1 installed 204 sec used 5 sec
>    Action statistics:
>        Sent 12168 bytes 164 pkt (dropped 0, overlimits 0 requeues 0)
>    backlog 0b 0p requeues 0
>    cookie a1b2c3d4
>
>.. try longer cookie...
>$ sudo $TC actions replace action ok index 1 cookie 1234567890abcdef
>.. dump..
>$ sudo $TC -s actions ls action gact
>
>    action order 1: gact action pass
>     random type none pass val 0
>     index 1 ref 2 bind 1 installed 204 sec used 5 sec
>    Action statistics:
>        Sent 12168 bytes 164 pkt (dropped 0, overlimits 0 requeues 0)
>    backlog 0b 0p requeues 0
>    cookie 1234567890abcdef
>
>Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
>---
>Changes in v7:
> -put guard around freeing cookie (caught by Simon)
> -separate out the creation of the cookie (suggested by Simon)
>
>Changes in v6:
> - fix mem leak caught by Florian
>
>Changes in V5:
> - kill the stylistic changes
> - Adopt a new structure with length-valuepointer representation
> - rename some things
>
>Changes in v4:
> - move stylistic changes out into a separate patch
>   (and add more stylistic changes)
>
>Changes in v3:
> - use TC_ prefix for the max size
> - move the cookie struct so visible only to kernel
> - remove unneeded void * cast
>
>Changes in V2:
> -move from a union to a length-value representation
>
> include/net/act_api.h        |  1 +
> include/net/pkt_cls.h        |  8 ++++++++
> include/uapi/linux/pkt_cls.h |  3 +++
> net/sched/act_api.c          | 45 ++++++++++++++++++++++++++++++++++++++++++++
> 4 files changed, 57 insertions(+)
>
>diff --git a/include/net/act_api.h b/include/net/act_api.h
>index 1d71644..cfa2ae3 100644
>--- a/include/net/act_api.h
>+++ b/include/net/act_api.h
>@@ -41,6 +41,7 @@ struct tc_action {
> 	struct rcu_head			tcfa_rcu;
> 	struct gnet_stats_basic_cpu __percpu *cpu_bstats;
> 	struct gnet_stats_queue __percpu *cpu_qstats;
>+	struct tc_cookie	*act_cookie;
> };
> #define tcf_head	common.tcfa_head
> #define tcf_index	common.tcfa_index
>diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
>index f0a0514..b43077e 100644
>--- a/include/net/pkt_cls.h
>+++ b/include/net/pkt_cls.h
>@@ -515,4 +515,12 @@ struct tc_cls_bpf_offload {
> 	u32 gen_flags;
> };
> 
>+
>+/* This structure holds cookie structure that is passed from user
>+ * to the kernel for actions and classifiers
>+ */
>+struct tc_cookie {
>+	u8  *data;
>+	u32 len;
>+};
> #endif
>diff --git a/include/uapi/linux/pkt_cls.h b/include/uapi/linux/pkt_cls.h
>index fd373eb..345551e 100644
>--- a/include/uapi/linux/pkt_cls.h
>+++ b/include/uapi/linux/pkt_cls.h
>@@ -4,6 +4,8 @@
> #include <linux/types.h>
> #include <linux/pkt_sched.h>
> 
>+#define TC_COOKIE_MAX_SIZE 16
>+
> /* Action attributes */
> enum {
> 	TCA_ACT_UNSPEC,
>@@ -12,6 +14,7 @@ enum {
> 	TCA_ACT_INDEX,
> 	TCA_ACT_STATS,
> 	TCA_ACT_PAD,
>+	TCA_ACT_COOKIE,
> 	__TCA_ACT_MAX
> };
> 
>diff --git a/net/sched/act_api.c b/net/sched/act_api.c
>index cd08df9..3c5e29b 100644
>--- a/net/sched/act_api.c
>+++ b/net/sched/act_api.c
>@@ -24,6 +24,7 @@
> #include <net/net_namespace.h>
> #include <net/sock.h>
> #include <net/sch_generic.h>
>+#include <net/pkt_cls.h>
> #include <net/act_api.h>
> #include <net/netlink.h>
> 
>@@ -33,6 +34,12 @@ static void free_tcf(struct rcu_head *head)
> 
> 	free_percpu(p->cpu_bstats);
> 	free_percpu(p->cpu_qstats);
>+
>+	if (p->act_cookie) {
>+		kfree(p->act_cookie->data);
>+		kfree(p->act_cookie);
>+	}
>+
> 	kfree(p);
> }
> 
>@@ -475,6 +482,12 @@ int tcf_action_destroy(struct list_head *actions, int bind)
> 		goto nla_put_failure;
> 	if (tcf_action_copy_stats(skb, a, 0))
> 		goto nla_put_failure;
>+	if (a->act_cookie) {
>+		if (nla_put(skb, TCA_ACT_COOKIE, a->act_cookie->len,
>+			    a->act_cookie->data))
>+			goto nla_put_failure;
>+	}
>+
> 	nest = nla_nest_start(skb, TCA_OPTIONS);
> 	if (nest == NULL)
> 		goto nla_put_failure;
>@@ -516,6 +529,22 @@ int tcf_action_dump(struct sk_buff *skb, struct list_head *actions,
> 	return err;
> }
> 
>+int nla_memdup_cookie(struct tc_action *a, struct nlattr **tb)
>+{
>+	a->act_cookie = kzalloc(sizeof(*a->act_cookie), GFP_KERNEL);
>+	if (!a->act_cookie)
>+		return -ENOMEM;
>+
>+	a->act_cookie->data = nla_memdup(tb[TCA_ACT_COOKIE], GFP_KERNEL);

you can do just:
	size_t len = nla_len(tb[TCA_ACT_COOKIE];

	a->act_cookie = kzalloc(sizeof(*a->act_cookie) + len, GFP_KERNEL);
	if (!a->act_cookie)
		return -ENOMEM;
	memcpy(a->act_cookie->data, nla_data(tb[TCA_ACT_COOKIE], len));
	a->act_cookie->len = len;
	return 0;

Really see no need to alloc 2 chunks instead of one. But as you like.



>+	if (!a->act_cookie->data) {
>+		kfree(a->act_cookie);
>+		return -ENOMEM;
>+	}
>+	a->act_cookie->len = nla_len(tb[TCA_ACT_COOKIE]);
>+
>+	return 0;
>+}
>+
> struct tc_action *tcf_action_init_1(struct net *net, struct nlattr *nla,
> 				    struct nlattr *est, char *name, int ovr,
> 				    int bind)
>@@ -575,6 +604,22 @@ struct tc_action *tcf_action_init_1(struct net *net, struct nlattr *nla,
> 	if (err < 0)
> 		goto err_mod;
> 
>+	if (tb[TCA_ACT_COOKIE]) {
>+		int cklen = nla_len(tb[TCA_ACT_COOKIE]);
>+
>+		if (cklen > TC_COOKIE_MAX_SIZE) {
>+			err = -EINVAL;
>+			tcf_hash_release(a, bind);
>+			goto err_mod;
>+		}
>+
>+		err = nla_memdup_cookie(a, tb);
>+		if (err < 0) {

You can do just "if (err)", but anyway:

Reviewed-by: Jiri Pirko <jiri@mellanox.com>



>+			tcf_hash_release(a, bind);
>+			goto err_mod;
>+		}
>+	}
>+
> 	/* module count goes up only when brand new policy is created
> 	 * if it exists and is only bound to in a_o->init() then
> 	 * ACT_P_CREATED is not returned (a zero is).
>-- 
>1.9.1
>
