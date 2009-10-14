From: jamal <hadi@cyberus.ca>
Subject: [RFC][PATCH] pkt_sched: skbedit add support for setting mark
Date: Wed, 14 Oct 2009 08:25:14 -0400
Message-ID: <1255523114.21940.14.camel@dogo.mojatatu.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-Wetp2Ij3yT6jY6DArV9I"
Cc: netdev@vger.kernel.org
To: Denys Fedoryschenko <denys@visp.net.lb>,
	Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f172.google.com ([209.85.221.172]:38564 "EHLO
	mail-qy0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755801AbZJNM2w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2009 08:28:52 -0400
Received: by qyk2 with SMTP id 2so9674615qyk.21
        for <netdev@vger.kernel.org>; Wed, 14 Oct 2009 05:28:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Wetp2Ij3yT6jY6DArV9I
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


Here are two patches, one for kernel and one for iproute2.
I have tested it and it works fine. Unless there are objections, I
would like to make a formal submission of this.

cheers,
jamal



--=-Wetp2Ij3yT6jY6DArV9I
Content-Disposition: attachment; filename=skbeiprt-mark
Content-Type: text/plain; name=skbeiprt-mark; charset=UTF-8
Content-Transfer-Encoding: 7bit

commit 2c7524fc3ba82306e9834a22adc731bd563ed158
Author: Jamal Hadi Salim <hadi@cyberus.ca>
Date:   Wed Oct 14 08:09:54 2009 -0400

    skbedit: Add support to mark packets
    
    This adds support for setting the skb mark.
    
    Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

diff --git a/include/linux/tc_act/tc_skbedit.h b/include/linux/tc_act/tc_skbedit.h
index a14e461..7a2e910 100644
--- a/include/linux/tc_act/tc_skbedit.h
+++ b/include/linux/tc_act/tc_skbedit.h
@@ -26,6 +26,7 @@
 
 #define SKBEDIT_F_PRIORITY		0x1
 #define SKBEDIT_F_QUEUE_MAPPING		0x2
+#define SKBEDIT_F_MARK			0x4
 
 struct tc_skbedit {
 	tc_gen;
@@ -37,6 +38,7 @@ enum {
 	TCA_SKBEDIT_PARMS,
 	TCA_SKBEDIT_PRIORITY,
 	TCA_SKBEDIT_QUEUE_MAPPING,
+	TCA_SKBEDIT_MARK,
 	__TCA_SKBEDIT_MAX
 };
 #define TCA_SKBEDIT_MAX (__TCA_SKBEDIT_MAX - 1)
diff --git a/tc/m_skbedit.c b/tc/m_skbedit.c
index ecb1f2d..623dc53 100644
--- a/tc/m_skbedit.c
+++ b/tc/m_skbedit.c
@@ -31,11 +31,13 @@
 static void
 explain(void)
 {
-	fprintf(stderr, "Usage: ... skbedit <[QM] [PM]>\n"
+	fprintf(stderr, "Usage: ... skbedit <[QM] [PM] [MM]>\n"
 			"QM = queue_mapping QUEUE_MAPPING\n"
 			"PM = priority PRIORITY \n"
+			"MM = mark MARK \n"
 			"QUEUE_MAPPING = device transmit queue to use\n"
-			"PRIORITY = classID to assign to priority field\n");
+			"PRIORITY = classID to assign to priority field\n"
+			"MARK = firewall mark to set\n");
 }
 
 static void
@@ -55,7 +57,7 @@ parse_skbedit(struct action_util *a, int *argc_p, char ***argv_p, int tca_id,
 	struct rtattr *tail;
 	unsigned int tmp;
 	__u16 queue_mapping;
-	__u32 flags = 0, priority;
+	__u32 flags = 0, priority, mark;
 	struct tc_skbedit sel = { 0 };
 
 	if (matches(*argv, "skbedit") != 0)
@@ -81,6 +83,14 @@ parse_skbedit(struct action_util *a, int *argc_p, char ***argv_p, int tca_id,
 				return -1;
 			}
 			ok++;
+		} else if (matches(*argv, "mark") == 0) {
+			flags |= SKBEDIT_F_MARK;
+			NEXT_ARG();
+			if (get_tc_classid(&mark, *argv)) {
+				fprintf(stderr, "Illegal mark\n");
+				return -1;
+			}
+			ok++;
 		} else if (matches(*argv, "help") == 0) {
 			usage();
 		} else {
@@ -138,6 +148,9 @@ parse_skbedit(struct action_util *a, int *argc_p, char ***argv_p, int tca_id,
 	if (flags & SKBEDIT_F_PRIORITY)
 		addattr_l(n, MAX_MSG, TCA_SKBEDIT_PRIORITY,
 			  &priority, sizeof(priority));
+	if (flags & SKBEDIT_F_MARK)
+		addattr_l(n, MAX_MSG, TCA_SKBEDIT_MARK,
+			  &mark, sizeof(mark));
 	tail->rta_len = (char *)NLMSG_TAIL(n) - (char *)tail;
 
 	*argc_p = argc;
@@ -151,6 +164,7 @@ static int print_skbedit(struct action_util *au, FILE *f, struct rtattr *arg)
 	struct rtattr *tb[TCA_SKBEDIT_MAX + 1];
 	SPRINT_BUF(b1);
 	__u32 *priority;
+	__u32 *mark;
 	__u16 *queue_mapping;
 
 	if (arg == NULL)
@@ -175,6 +189,10 @@ static int print_skbedit(struct action_util *au, FILE *f, struct rtattr *arg)
 		priority = RTA_DATA(tb[TCA_SKBEDIT_PRIORITY]);
 		fprintf(f, " priority %s", sprint_tc_classid(*priority, b1));
 	}
+	if (tb[TCA_SKBEDIT_MARK] != NULL) {
+		mark = RTA_DATA(tb[TCA_SKBEDIT_MARK]);
+		fprintf(f, " mark %d", *mark);
+	}
 
 	if (show_stats) {
 		if (tb[TCA_SKBEDIT_TM]) {

--=-Wetp2Ij3yT6jY6DArV9I
Content-Disposition: attachment; filename=skbe-mark
Content-Type: text/plain; name=skbe-mark; charset=UTF-8
Content-Transfer-Encoding: 7bit

commit 6da17c574694ad4c02268dd64e85792051946aab
Author: Jamal Hadi Salim <hadi@cyberus.ca>
Date:   Wed Oct 14 08:16:23 2009 -0400

    [PATCH] pkt_sched: skbedit add support for setting mark
    
    This adds support for setting the skb mark.
    
    Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

diff --git a/include/linux/tc_act/tc_skbedit.h b/include/linux/tc_act/tc_skbedit.h
index a14e461..7a2e910 100644
--- a/include/linux/tc_act/tc_skbedit.h
+++ b/include/linux/tc_act/tc_skbedit.h
@@ -26,6 +26,7 @@
 
 #define SKBEDIT_F_PRIORITY		0x1
 #define SKBEDIT_F_QUEUE_MAPPING		0x2
+#define SKBEDIT_F_MARK			0x4
 
 struct tc_skbedit {
 	tc_gen;
@@ -37,6 +38,7 @@ enum {
 	TCA_SKBEDIT_PARMS,
 	TCA_SKBEDIT_PRIORITY,
 	TCA_SKBEDIT_QUEUE_MAPPING,
+	TCA_SKBEDIT_MARK,
 	__TCA_SKBEDIT_MAX
 };
 #define TCA_SKBEDIT_MAX (__TCA_SKBEDIT_MAX - 1)
diff --git a/include/net/tc_act/tc_skbedit.h b/include/net/tc_act/tc_skbedit.h
index 6abb3ed..e103fe0 100644
--- a/include/net/tc_act/tc_skbedit.h
+++ b/include/net/tc_act/tc_skbedit.h
@@ -26,7 +26,9 @@ struct tcf_skbedit {
 	struct tcf_common	common;
 	u32			flags;
 	u32     		priority;
+	u32     		mark;
 	u16			queue_mapping;
+	/* XXX: 16-bit pad here? */
 };
 #define to_skbedit(pc) \
 	container_of(pc, struct tcf_skbedit, common)
diff --git a/net/sched/act_skbedit.c b/net/sched/act_skbedit.c
index 4ab916b..e9607fe 100644
--- a/net/sched/act_skbedit.c
+++ b/net/sched/act_skbedit.c
@@ -54,6 +54,8 @@ static int tcf_skbedit(struct sk_buff *skb, struct tc_action *a,
 	if (d->flags & SKBEDIT_F_QUEUE_MAPPING &&
 	    skb->dev->real_num_tx_queues > d->queue_mapping)
 		skb_set_queue_mapping(skb, d->queue_mapping);
+	if (d->flags & SKBEDIT_F_MARK)
+		skb->mark = d->mark;
 
 	spin_unlock(&d->tcf_lock);
 	return d->tcf_action;
@@ -63,6 +65,7 @@ static const struct nla_policy skbedit_policy[TCA_SKBEDIT_MAX + 1] = {
 	[TCA_SKBEDIT_PARMS]		= { .len = sizeof(struct tc_skbedit) },
 	[TCA_SKBEDIT_PRIORITY]		= { .len = sizeof(u32) },
 	[TCA_SKBEDIT_QUEUE_MAPPING]	= { .len = sizeof(u16) },
+	[TCA_SKBEDIT_MARK]		= { .len = sizeof(u32) },
 };
 
 static int tcf_skbedit_init(struct nlattr *nla, struct nlattr *est,
@@ -72,7 +75,7 @@ static int tcf_skbedit_init(struct nlattr *nla, struct nlattr *est,
 	struct tc_skbedit *parm;
 	struct tcf_skbedit *d;
 	struct tcf_common *pc;
-	u32 flags = 0, *priority = NULL;
+	u32 flags = 0, *priority = NULL, *mark = NULL;
 	u16 *queue_mapping = NULL;
 	int ret = 0, err;
 
@@ -95,6 +98,12 @@ static int tcf_skbedit_init(struct nlattr *nla, struct nlattr *est,
 		flags |= SKBEDIT_F_QUEUE_MAPPING;
 		queue_mapping = nla_data(tb[TCA_SKBEDIT_QUEUE_MAPPING]);
 	}
+
+	if (tb[TCA_SKBEDIT_MARK] != NULL) {
+		flags |= SKBEDIT_F_MARK;
+		mark = nla_data(tb[TCA_SKBEDIT_MARK]);
+	}
+
 	if (!flags)
 		return -EINVAL;
 
@@ -124,6 +133,9 @@ static int tcf_skbedit_init(struct nlattr *nla, struct nlattr *est,
 		d->priority = *priority;
 	if (flags & SKBEDIT_F_QUEUE_MAPPING)
 		d->queue_mapping = *queue_mapping;
+	if (flags & SKBEDIT_F_MARK)
+		d->mark = *mark;
+
 	d->tcf_action = parm->action;
 
 	spin_unlock_bh(&d->tcf_lock);
@@ -161,6 +173,9 @@ static inline int tcf_skbedit_dump(struct sk_buff *skb, struct tc_action *a,
 	if (d->flags & SKBEDIT_F_QUEUE_MAPPING)
 		NLA_PUT(skb, TCA_SKBEDIT_QUEUE_MAPPING,
 			sizeof(d->queue_mapping), &d->queue_mapping);
+	if (d->flags & SKBEDIT_F_MARK)
+		NLA_PUT(skb, TCA_SKBEDIT_MARK, sizeof(d->mark),
+			&d->mark);
 	t.install = jiffies_to_clock_t(jiffies - d->tcf_tm.install);
 	t.lastuse = jiffies_to_clock_t(jiffies - d->tcf_tm.lastuse);
 	t.expires = jiffies_to_clock_t(d->tcf_tm.expires);

--=-Wetp2Ij3yT6jY6DArV9I--

