From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: [PATCH] pkt_sched: act_xt support new Xtables interface
Date: Wed, 19 Dec 2012 16:52:15 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1212191648490.13317@nerf07.vanv.qr>
References: <50C4821D.5090206@gmail.com> <50C9B4BB.9060609@mojatatu.com> <50CCE961.5050204@mojatatu.com> <alpine.LNX.2.01.1212160002330.4901@nerf07.vanv.qr> <CAASe=fQT2pVOK0uctdaKL+aOrF8nYeTMfoF15kmd-rC02+7Vnw@mail.gmail.com> <50CDFB6A.3090806@mojatatu.com>
 <50CE1A04.1000405@mojatatu.com> <alpine.LNX.2.01.1212162003340.27614@nerf07.vanv.qr> <50CE3203.9080007@mojatatu.com> <50CF1071.1050405@mojatatu.com> <CAASe=fRuJdtisEvp7uo=PHwN3nKHqsYDW4Om1gk2MK-vyNvBrA@mail.gmail.com> <50D06177.2090905@mojatatu.com>
 <CAASe=fR6Hm2dxp=1wDchtrzqnaH6qacHpg2wrsqLfmGpPbQ9Fg@mail.gmail.com> <50D1A8A7.1090002@mojatatu.com> <50D1AB7E.5060000@mojatatu.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Hasan Chowdhury <shemonc@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Yury Stankevich <urykhy@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	pablo@netfilter.org, netfilter-devel@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <50D1AB7E.5060000@mojatatu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Wednesday 2012-12-19 12:56, Jamal Hadi Salim wrote:
>
> To be applied pending more testing.
>
> Attached. Sorry, I thought I had sent this out over the weekend.
> I have done basic testing with a single mark and sending pings to
> update stats which can then displayed for the mark.
>
> diffstat xt-p1
> Kconfig  |   15 ++
> Makefile |    1 
> act_xt.c |  324 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
> 3 files changed, 339 insertions(+), 1 deletion(-)

Humm... that's a huge patch for what seems to be equal to act_ipt.c
Let's do a cross-diff:

--- act_ipt.c	2012-10-25 19:49:25.372191795 +0200
+++ act_xt.c	2012-12-19 16:48:22.052419730 +0100
@@ -2 +2 @@
- * net/sched/ipt.c     iptables target interface
+ * net/sched/act_xt.c     iptables target interface
@@ -11 +11 @@
- * Copyright:	Jamal Hadi Salim (2002-4)
+ * Copyright:	Jamal Hadi Salim (2002-12)
@@ -30 +29,0 @@
-
@@ -42 +41,2 @@ static struct tcf_hashinfo ipt_hash_info
-static int ipt_init_target(struct xt_entry_target *t, char *table, unsigned int hook)
+static int ipt_init_target(struct xt_entry_target *t, char *table,
+			   unsigned int hook)
@@ -243,2 +243,2 @@ static int tcf_ipt(struct sk_buff *skb,
-		net_notice_ratelimited("tc filter: Bogus netfilter code %d assume ACCEPT\n",
-				       ret);
+		net_notice_ratelimited
+		    ("tc filter: Bogus netfilter code %d assume ACCEPT\n", ret);
@@ -253 +253,2 @@ static int tcf_ipt(struct sk_buff *skb,
-static int tcf_ipt_dump(struct sk_buff *skb, struct tc_action *a, int bind, int ref)
+static int tcf_ipt_dump(struct sk_buff *skb, struct tc_action *a, int bind,
+			int ref)
@@ -295 +296 @@ static struct tc_action_ops act_ipt_ops
-	.kind		=	"ipt",
+	.kind = "xt",
@@ -308,2 +309,2 @@ static struct tc_action_ops act_ipt_ops
-MODULE_AUTHOR("Jamal Hadi Salim(2002-4)");
-MODULE_DESCRIPTION("Iptables target actions");
+MODULE_AUTHOR("Jamal Hadi Salim(2002-12)");
+MODULE_DESCRIPTION("New Iptables target actions");


Is that [the set of hunks] all? Then I would instead suggest
something like:


diff --git a/net/sched/act_ipt.c b/net/sched/act_ipt.c
index 58fb3c7..f92a007 100644
--- a/net/sched/act_ipt.c
+++ b/net/sched/act_ipt.c
@@ -305,18 +305,43 @@ static struct tc_action_ops act_ipt_ops = {
 	.walk		=	tcf_generic_walker
 };
 
+static struct tc_action_ops act_xt_ops = {
+	.kind		=	"xt",
+	.hinfo		=	&ipt_hash_info,
+	.type		=	TCA_ACT_IPT,
+	.capab		=	TCA_CAP_NONE,
+	.owner		=	THIS_MODULE,
+	.act		=	tcf_ipt,
+	.dump		=	tcf_ipt_dump,
+	.cleanup	=	tcf_ipt_cleanup,
+	.lookup		=	tcf_hash_search,
+	.init		=	tcf_ipt_init,
+	.walk		=	tcf_generic_walker
+};
+
 MODULE_AUTHOR("Jamal Hadi Salim(2002-4)");
 MODULE_DESCRIPTION("Iptables target actions");
 MODULE_LICENSE("GPL");
+MODULE_ALIAS("act_xt");
 
 static int __init ipt_init_module(void)
 {
-	return tcf_register_action(&act_ipt_ops);
+	int ret;
+	ret = tcf_register_action(&act_ipt_ops);
+	if (ret < 0)
+		return ret;
+	ret = tcf_register_action(&xt_ipt_ops);
+	if (ret < 0) {
+		tcf_unregister_action(&act_ipt_ops);
+		return ret;
+	}
+	return 0;
 }
 
 static void __exit ipt_cleanup_module(void)
 {
 	tcf_unregister_action(&act_ipt_ops);
+	tcf_unregister_action(&act_xt_ops);
 }
 
 module_init(ipt_init_module);
