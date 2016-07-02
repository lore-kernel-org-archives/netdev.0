From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH v2 net-next 1/1] net sched actions: mirred add support for setting Dst MAC address
Date: Sat,  2 Jul 2016 10:34:25 -0400
Message-ID: <1467470065-17613-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, daniel@iogearbox.net,
	xiyou.wangcong@gmail.com, nikolay@cumulusnetworks.com,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:34509 "EHLO
	mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751360AbcGBOeh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jul 2016 10:34:37 -0400
Received: by mail-it0-f67.google.com with SMTP id f6so4921392ith.1
        for <netdev@vger.kernel.org>; Sat, 02 Jul 2016 07:34:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

Often redirecting or mirroring requires that we set the dstMAC address
of the target device. While it is possible to pipe to a pedit action,
this patch obsoletes the need for that. This is a justified feature because
the dst MAC addresses rewrite is such a common use case.

Sample usage:
sudo $TC filter add dev $ETH parent 1: protocol ip prio 10 \
u32 match ip protocol 1 0xff flowid 1:2 \
action mirred egress redirect dev $SPANPORT dst 02:15:15:15:15:15

This will match all icmp packets going out on dev $ETH and
redirect them to dev $SPANPORT while setting their dst MAC address
to 02:15:15:15:15:15

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 include/net/tc_act/tc_mirred.h        |  4 +++-
 include/uapi/linux/tc_act/tc_mirred.h |  7 ++++---
 net/sched/act_mirred.c                | 24 +++++++++++++++++++++++-
 3 files changed, 30 insertions(+), 5 deletions(-)

diff --git a/include/net/tc_act/tc_mirred.h b/include/net/tc_act/tc_mirred.h
index e891835..7e8bced 100644
--- a/include/net/tc_act/tc_mirred.h
+++ b/include/net/tc_act/tc_mirred.h
@@ -6,10 +6,12 @@
 
 struct tcf_mirred {
 	struct tcf_common	common;
+	struct net_device __rcu	*tcfm_dev;
 	int			tcfm_eaction;
 	int			tcfm_ifindex;
 	int			tcfm_ok_push;
-	struct net_device __rcu	*tcfm_dev;
+	u8			eth_dst[ETH_ALEN];
+	/* XXX 6 bytes hole here*/
 	struct list_head	tcfm_list;
 };
 #define to_mirred(a) \
diff --git a/include/uapi/linux/tc_act/tc_mirred.h b/include/uapi/linux/tc_act/tc_mirred.h
index 3d7a2b3..aaca1ff 100644
--- a/include/uapi/linux/tc_act/tc_mirred.h
+++ b/include/uapi/linux/tc_act/tc_mirred.h
@@ -9,20 +9,21 @@
 #define TCA_EGRESS_MIRROR 2 /* mirror packet to EGRESS */
 #define TCA_INGRESS_REDIR 3  /* packet redirect to INGRESS*/
 #define TCA_INGRESS_MIRROR 4 /* mirror packet to INGRESS */
-                                                                                
+
 struct tc_mirred {
 	tc_gen;
 	int                     eaction;   /* one of IN/EGRESS_MIRROR/REDIR */
 	__u32                   ifindex;  /* ifindex of egress port */
 };
-                                                                                
+
 enum {
 	TCA_MIRRED_UNSPEC,
 	TCA_MIRRED_TM,
 	TCA_MIRRED_PARMS,
 	TCA_MIRRED_PAD,
+	TCA_MIRRED_DMAC,
 	__TCA_MIRRED_MAX
 };
 #define TCA_MIRRED_MAX (__TCA_MIRRED_MAX - 1)
-                                                                                
+
 #endif
diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index 5b135d3..1cc14f5 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -49,6 +49,7 @@ static void tcf_mirred_release(struct tc_action *a, int bind)
 
 static const struct nla_policy mirred_policy[TCA_MIRRED_MAX + 1] = {
 	[TCA_MIRRED_PARMS]	= { .len = sizeof(struct tc_mirred) },
+	[TCA_MIRRED_DMAC] = { .len = ETH_ALEN},
 };
 
 static int mirred_net_id;
@@ -64,15 +65,24 @@ static int tcf_mirred_init(struct net *net, struct nlattr *nla,
 	struct net_device *dev;
 	int ret, ok_push = 0;
 	bool exists = false;
+	u8 *daddr = NULL;
 
 	if (nla == NULL)
 		return -EINVAL;
+
 	ret = nla_parse_nested(tb, TCA_MIRRED_MAX, nla, mirred_policy);
 	if (ret < 0)
 		return ret;
+
 	if (tb[TCA_MIRRED_PARMS] == NULL)
 		return -EINVAL;
+
 	parm = nla_data(tb[TCA_MIRRED_PARMS]);
+	if (tb[TCA_MIRRED_DMAC]) {
+		daddr = nla_data(tb[TCA_MIRRED_DMAC]);
+		if (is_zero_ether_addr(daddr))
+			return -EINVAL;
+	}
 
 	exists = tcf_hash_check(tn, parm->index, a, bind);
 	if (exists && bind)
@@ -126,6 +136,9 @@ static int tcf_mirred_init(struct net *net, struct nlattr *nla,
 	}
 	m = to_mirred(a);
 
+	if (daddr)
+		ether_addr_copy(m->eth_dst, daddr);
+
 	ASSERT_RTNL();
 	m->tcf_action = parm->action;
 	m->tcfm_eaction = parm->eaction;
@@ -190,6 +203,9 @@ static int tcf_mirred(struct sk_buff *skb, const struct tc_action *a,
 
 	skb2->skb_iif = skb->dev->ifindex;
 	skb2->dev = dev;
+	if (!is_zero_ether_addr(m->eth_dst))
+		ether_addr_copy(eth_hdr(skb2)->h_dest, m->eth_dst);
+
 	err = dev_queue_xmit(skb2);
 
 	if (err) {
@@ -203,7 +219,8 @@ out:
 	return retval;
 }
 
-static int tcf_mirred_dump(struct sk_buff *skb, struct tc_action *a, int bind, int ref)
+static int tcf_mirred_dump(struct sk_buff *skb, struct tc_action *a, int bind,
+			   int ref)
 {
 	unsigned char *b = skb_tail_pointer(skb);
 	struct tcf_mirred *m = a->priv;
@@ -220,6 +237,11 @@ static int tcf_mirred_dump(struct sk_buff *skb, struct tc_action *a, int bind, i
 	if (nla_put(skb, TCA_MIRRED_PARMS, sizeof(opt), &opt))
 		goto nla_put_failure;
 
+	if (!is_zero_ether_addr(m->eth_dst)) {
+		if (nla_put(skb, TCA_MIRRED_DMAC, ETH_ALEN, m->eth_dst))
+			goto nla_put_failure;
+	}
+
 	tcf_tm_dump(&t, &m->tcf_tm);
 	if (nla_put_64bit(skb, TCA_MIRRED_TM, sizeof(t), &t, TCA_MIRRED_PAD))
 		goto nla_put_failure;
-- 
1.9.1
