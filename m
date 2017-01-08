From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next] net/sched: cls_flower: Add user specified data
Date: Sun, 8 Jan 2017 18:19:02 +0100
Message-ID: <20170108171902.GH1971@nanopsycho>
References: <1483362833-52114-1-git-send-email-paulb@mellanox.com>
 <14675f63-4212-2f72-da4c-cd24b9d10881@mojatatu.com>
 <586A9A9F.4030002@gmail.com>
 <6b671aaf-d35d-70a5-65e0-40308baeb471@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Fastabend <john.fastabend@gmail.com>,
        Paul Blakey <paulb@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Jiri Pirko <jiri@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>, Roman Mashak <mrv@mojatatu.com>,
        Simon Horman <simon.horman@netronome.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35354 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752750AbdAHRTG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 8 Jan 2017 12:19:06 -0500
Received: by mail-wm0-f68.google.com with SMTP id l2so16709029wml.2
        for <netdev@vger.kernel.org>; Sun, 08 Jan 2017 09:19:05 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <6b671aaf-d35d-70a5-65e0-40308baeb471@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Jan 02, 2017 at 11:21:41PM CET, jhs@mojatatu.com wrote:
>On 17-01-02 01:23 PM, John Fastabend wrote:
>
>> 
>> Additionally I would like to point out this is an arbitrary length binary
>> blob (for undefined use, without even a specified encoding) that gets pushed
>> between user space and hardware ;) This seemed to get folks fairly excited in
>> the past.
>> 
>
>The binary blob size is a little strange - but i think there is value
>in storing some "cookie" field. The challenge is whether the kernel
>gets to intepret it; in which case encoding must be specified. Or
>whether we should leave it up to user space - in which something
>like tc could standardize its own encodings.

This should never be interpreted by kernel. I think this would be good
to make clear in the comment in the code.


>
>> Some questions, exactly what do you mean by "port mappings" above? In
>> general the 'tc' API uses the netdev the netlink msg is processed on as
>> the port mapping. If you mean OVS port to netdev port I think this is
>> a OVS problem and nothing to do with 'tc'. For what its worth there is an
>> existing problem with 'tc' where rules only apply to a single ingress or
>> egress port which is limiting on hardware.
>> 
>
>In our case the desire is to be able to correlate for a system wide
>mostly identity/key mapping.
>
>> The UFID in my ovs code base is defined as best I can tell here,
>> 
>>         [OVS_FLOW_ATTR_UFID] = { .type = NL_A_UNSPEC, .optional = true,
>>                                  .min_len = sizeof(ovs_u128) },
>> 
>> So you need 128 bits if you want a 1:1 mapping onto 'tc'. So rather
>> than an arbitrary blob why not make the case that 'tc' ids need to be
>> 128 bits long? Even if its just initially done in flower call it
>> flower_flow_id and define it so its not opaque and at least at the code
>> level it isn't an arbitrary blob of data.
>> 
>
>I dont know what this UFID is, but do note:
>The idea is not new - the FIB for example has some such cookie
>(albeit a tiny one) which will typically be populated to tell
>you who/what installed the entry.
>I could see f.e use for this cookie to simplify and pretty print in
>a human language for the u32 classifier (i.e user space tc sets
>some fields in the cookie when updating kernel and when user space
>invokes get/dump it uses the cookie to intepret how to pretty print).
>
>I have attached a compile tested version of the cookies on actions
>(flat 64 bit; now that we have experienced the use when we have a
>large number of counters - I would not mind a 128 bit field).
>
>
>cheers,
>jamal
>
>> And what are the "next" uses of this besides OVS. It would be really
>> valuable to see how this generalizes to other usage models. To avoid
>> embedding OVS syntax into 'tc'.
>> 
>> Finally if you want to see an example of binary data encodings look at
>> how drivers/hardware/users are currently using the user defined bits in
>> ethtools ntuple API. Also track down out of tree drivers to see other
>> interesting uses. And that was capped at 64bits :/
>> 
>> Thanks,
>> John
>> 
>> 
>> 
>> 
>> 
>

>diff --git a/include/net/act_api.h b/include/net/act_api.h
>index 1d71644..f299ed3 100644
>--- a/include/net/act_api.h
>+++ b/include/net/act_api.h
>@@ -41,6 +41,7 @@ struct tc_action {
> 	struct rcu_head			tcfa_rcu;
> 	struct gnet_stats_basic_cpu __percpu *cpu_bstats;
> 	struct gnet_stats_queue __percpu *cpu_qstats;
>+	u64	cookie;
> };
> #define tcf_head	common.tcfa_head
> #define tcf_index	common.tcfa_index
>diff --git a/include/uapi/linux/pkt_cls.h b/include/uapi/linux/pkt_cls.h
>index cb4bcdc..2e968ee 100644
>--- a/include/uapi/linux/pkt_cls.h
>+++ b/include/uapi/linux/pkt_cls.h
>@@ -67,6 +67,7 @@ enum {
> 	TCA_ACT_INDEX,
> 	TCA_ACT_STATS,
> 	TCA_ACT_PAD,
>+	TCA_ACT_COOKIE,
> 	__TCA_ACT_MAX
> };
> 
>diff --git a/net/sched/act_api.c b/net/sched/act_api.c
>index 2095c83..97eae6b 100644
>--- a/net/sched/act_api.c
>+++ b/net/sched/act_api.c
>@@ -26,6 +26,7 @@
> #include <net/sch_generic.h>
> #include <net/act_api.h>
> #include <net/netlink.h>
>+#include <net/tc_act/tc_gact.h>
> 
> static void free_tcf(struct rcu_head *head)
> {
>@@ -467,17 +468,21 @@ int tcf_action_destroy(struct list_head *actions, int bind)
> 	return a->ops->dump(skb, a, bind, ref);
> }
> 
>-int
>-tcf_action_dump_1(struct sk_buff *skb, struct tc_action *a, int bind, int ref)
>+int tcf_action_dump_1(struct sk_buff *skb, struct tc_action *a, int bind,
>+		      int ref)
> {
> 	int err = -EINVAL;
> 	unsigned char *b = skb_tail_pointer(skb);
> 	struct nlattr *nest;
>+	u64 cookie = a->cookie;
> 
> 	if (nla_put_string(skb, TCA_KIND, a->ops->kind))
> 		goto nla_put_failure;
> 	if (tcf_action_copy_stats(skb, a, 0))
> 		goto nla_put_failure;
>+	if (nla_put_u64_64bit(skb, TCA_ACT_COOKIE, cookie, TCA_ACT_PAD))
>+		goto nla_put_failure;
>+
> 	nest = nla_nest_start(skb, TCA_OPTIONS);
> 	if (nest == NULL)
> 		goto nla_put_failure;
>@@ -578,6 +583,11 @@ struct tc_action *tcf_action_init_1(struct net *net, struct nlattr *nla,
> 	if (err < 0)
> 		goto err_mod;
> 
>+	if (tb[TCA_ACT_COOKIE])
>+		a->cookie = nla_get_u64(tb[TCA_ACT_COOKIE]);
>+	else
>+		a->cookie = 0; /* kernel uses 0 */
>+
> 	/* module count goes up only when brand new policy is created
> 	 * if it exists and is only bound to in a_o->init() then
> 	 * ACT_P_CREATED is not returned (a zero is).

>commit 0a6fd6b024db77e3a460c22ab8a496a714bc71b7
>Author: Jamal Hadi Salim <hadi@mojatatu.com>
>Date:   Fri Aug 12 06:10:46 2016 -0400
>
>    actions: add support for cookies
>    
>    Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
>
>diff --git a/tc/m_action.c b/tc/m_action.c
>index c416d98..75d1a5a 100644
>--- a/tc/m_action.c
>+++ b/tc/m_action.c
>@@ -137,8 +137,7 @@ noexist:
> 	return a;
> }
> 
>-static int
>-new_cmd(char **argv)
>+static int new_cmd(char **argv)
> {
> 	if ((matches(*argv, "change") == 0) ||
> 		(matches(*argv, "replace") == 0) ||
>@@ -151,8 +150,7 @@ new_cmd(char **argv)
> 
> }
> 
>-int
>-parse_action(int *argc_p, char ***argv_p, int tca_id, struct nlmsghdr *n)
>+int parse_action(int *argc_p, char ***argv_p, int tca_id, struct nlmsghdr *n)
> {
> 	int argc = *argc_p;
> 	char **argv = *argv_p;
>@@ -160,6 +158,7 @@ parse_action(int *argc_p, char ***argv_p, int tca_id, struct nlmsghdr *n)
> 	char k[16];
> 	int ok = 0;
> 	int eap = 0; /* expect action parameters */
>+	__u64 act_ck = 0;
> 
> 	int ret = 0;
> 	int prio = 0;
>@@ -215,13 +214,28 @@ done0:
> 			tail = NLMSG_TAIL(n);
> 			addattr_l(n, MAX_MSG, ++prio, NULL, 0);
> 			addattr_l(n, MAX_MSG, TCA_ACT_KIND, k, strlen(k) + 1);
>-
>-			ret = a->parse_aopt(a, &argc, &argv, TCA_ACT_OPTIONS, n);
>+			ret = a->parse_aopt(a, &argc, &argv, TCA_ACT_OPTIONS,
>+					    n);
> 
> 			if (ret < 0) {
>-				fprintf(stderr, "bad action parsing\n");
>+				fprintf(stderr, "bad action option parsing\n");
> 				goto bad_val;
> 			}
>+
>+			if (*argv && strcmp(*argv, "cookie") == 0) {
>+				NEXT_ARG();
>+				ret = get_u64(&act_ck, *argv, 0);
>+				if (ret) {
>+					fprintf(stderr, "bad cookie <%s>\n",
>+						*argv);
>+					goto bad_val;
>+				}
>+				argc--;
>+				argv++;
>+			}
>+
>+			if (act_ck)
>+				addattr64(n, MAX_MSG, TCA_ACT_COOKIE, act_ck);
> 			tail->rta_len = (void *) NLMSG_TAIL(n) - (void *) tail;
> 			ok++;
> 		}
>@@ -246,8 +260,7 @@ bad_val:
> 	return -1;
> }
> 
>-static int
>-tc_print_one_action(FILE *f, struct rtattr *arg)
>+static int tc_print_one_action(FILE *f, struct rtattr *arg)
> {
> 
> 	struct rtattr *tb[TCA_ACT_MAX + 1];
>@@ -277,6 +290,10 @@ tc_print_one_action(FILE *f, struct rtattr *arg)
> 	if (show_stats && tb[TCA_ACT_STATS]) {
> 		fprintf(f, "\tAction statistics:\n");
> 		print_tcstats2_attr(f, tb[TCA_ACT_STATS], "\t", NULL);
>+		if (tb[TCA_ACT_COOKIE]) {
>+			__u64 acookie = rta_getattr_u64(tb[TCA_ACT_COOKIE]);
>+			fprintf(f, "cookie 0x%llx ",  acookie);
>+		}
> 		fprintf(f, "\n");
> 	}
