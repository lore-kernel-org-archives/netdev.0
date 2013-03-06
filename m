From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] htb: add HTB_DIRECT_QLEN attribute
Date: Wed, 06 Mar 2013 08:49:21 -0800
Message-ID: <1362588561.15793.178.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:33264 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751027Ab3CFQt0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Mar 2013 11:49:26 -0500
Received: by mail-pb0-f47.google.com with SMTP id rp2so6252003pbb.34
        for <netdev@vger.kernel.org>; Wed, 06 Mar 2013 08:49:26 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

HTB uses an internal pfifo queue, which limit is not reported
to userland tools (tc), and value inherited from device tx_queue_len
at setup time.

Introduce TCA_HTB_DIRECT_QLEN attribute to allow finer control.

Remove two obsolete pr_err() calls as well.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
---
 include/uapi/linux/pkt_sched.h |    1 +
 net/sched/sch_htb.c            |   31 ++++++++++++++++---------------
 2 files changed, 17 insertions(+), 15 deletions(-)

diff --git a/include/uapi/linux/pkt_sched.h b/include/uapi/linux/pkt_sched.h
index 32aef0a..dbd71b0 100644
--- a/include/uapi/linux/pkt_sched.h
+++ b/include/uapi/linux/pkt_sched.h
@@ -348,6 +348,7 @@ enum {
 	TCA_HTB_INIT,
 	TCA_HTB_CTAB,
 	TCA_HTB_RTAB,
+	TCA_HTB_DIRECT_QLEN,
 	__TCA_HTB_MAX,
 };
 
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 571f1d2..79b1876 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -981,6 +981,7 @@ static const struct nla_policy htb_policy[TCA_HTB_MAX + 1] = {
 	[TCA_HTB_INIT]	= { .len = sizeof(struct tc_htb_glob) },
 	[TCA_HTB_CTAB]	= { .type = NLA_BINARY, .len = TC_RTAB_SIZE },
 	[TCA_HTB_RTAB]	= { .type = NLA_BINARY, .len = TC_RTAB_SIZE },
+	[TCA_HTB_DIRECT_QLEN] = { .type = NLA_U32 },
 };
 
 static void htb_work_func(struct work_struct *work)
@@ -994,7 +995,7 @@ static void htb_work_func(struct work_struct *work)
 static int htb_init(struct Qdisc *sch, struct nlattr *opt)
 {
 	struct htb_sched *q = qdisc_priv(sch);
-	struct nlattr *tb[TCA_HTB_INIT + 1];
+	struct nlattr *tb[TCA_HTB_MAX + 1];
 	struct tc_htb_glob *gopt;
 	int err;
 	int i;
@@ -1002,20 +1003,16 @@ static int htb_init(struct Qdisc *sch, struct nlattr *opt)
 	if (!opt)
 		return -EINVAL;
 
-	err = nla_parse_nested(tb, TCA_HTB_INIT, opt, htb_policy);
+	err = nla_parse_nested(tb, TCA_HTB_MAX, opt, htb_policy);
 	if (err < 0)
 		return err;
 
-	if (tb[TCA_HTB_INIT] == NULL) {
-		pr_err("HTB: hey probably you have bad tc tool ?\n");
+	if (!tb[TCA_HTB_INIT])
 		return -EINVAL;
-	}
+
 	gopt = nla_data(tb[TCA_HTB_INIT]);
-	if (gopt->version != HTB_VER >> 16) {
-		pr_err("HTB: need tc/htb version %d (minor is %d), you have %d\n",
-		       HTB_VER >> 16, HTB_VER & 0xffff, gopt->version);
+	if (gopt->version != HTB_VER >> 16)
 		return -EINVAL;
-	}
 
 	err = qdisc_class_hash_init(&q->clhash);
 	if (err < 0)
@@ -1027,10 +1024,13 @@ static int htb_init(struct Qdisc *sch, struct nlattr *opt)
 	INIT_WORK(&q->work, htb_work_func);
 	skb_queue_head_init(&q->direct_queue);
 
-	q->direct_qlen = qdisc_dev(sch)->tx_queue_len;
-	if (q->direct_qlen < 2)	/* some devices have zero tx_queue_len */
-		q->direct_qlen = 2;
-
+	if (tb[TCA_HTB_DIRECT_QLEN])
+		q->direct_qlen = nla_get_u32(tb[TCA_HTB_DIRECT_QLEN]);
+	else {
+		q->direct_qlen = qdisc_dev(sch)->tx_queue_len;
+		if (q->direct_qlen < 2)	/* some devices have zero tx_queue_len */
+			q->direct_qlen = 2;
+	}
 	if ((q->rate2quantum = gopt->rate2quantum) < 1)
 		q->rate2quantum = 1;
 	q->defcls = gopt->defcls;
@@ -1056,7 +1056,8 @@ static int htb_dump(struct Qdisc *sch, struct sk_buff *skb)
 	nest = nla_nest_start(skb, TCA_OPTIONS);
 	if (nest == NULL)
 		goto nla_put_failure;
-	if (nla_put(skb, TCA_HTB_INIT, sizeof(gopt), &gopt))
+	if (nla_put(skb, TCA_HTB_INIT, sizeof(gopt), &gopt) ||
+	    nla_put_u32(skb, TCA_HTB_DIRECT_QLEN, q->direct_qlen))
 		goto nla_put_failure;
 	nla_nest_end(skb, nest);
 
@@ -1311,7 +1312,7 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 	struct htb_sched *q = qdisc_priv(sch);
 	struct htb_class *cl = (struct htb_class *)*arg, *parent;
 	struct nlattr *opt = tca[TCA_OPTIONS];
-	struct nlattr *tb[__TCA_HTB_MAX];
+	struct nlattr *tb[TCA_HTB_MAX + 1];
 	struct tc_htb_opt *hopt;
 
 	/* extract all subattrs from opt attr */
