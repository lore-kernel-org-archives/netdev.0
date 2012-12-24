From: Felix Fietkau <nbd@openwrt.org>
Subject: Re: [PATCH] pkt_sched: act_xt support new Xtables interface
Date: Mon, 24 Dec 2012 12:49:16 +0100
Message-ID: <50D8413C.8050508@openwrt.org>
References: <50C4821D.5090206@gmail.com> <50C9B4BB.9060609@mojatatu.com> <50CCE961.5050204@mojatatu.com> <alpine.LNX.2.01.1212160002330.4901@nerf07.vanv.qr> <CAASe=fQT2pVOK0uctdaKL+aOrF8nYeTMfoF15kmd-rC02+7Vnw@mail.gmail.com> <50CDFB6A.3090806@mojatatu.com> <50CE1A04.1000405@mojatatu.com> <alpine.LNX.2.01.1212162003340.27614@nerf07.vanv.qr> <50CE3203.9080007@mojatatu.com> <50CF1071.1050405@mojatatu.com> <CAASe=fRuJdtisEvp7uo=PHwN3nKHqsYDW4Om1gk2MK-vyNvBrA@mail.gmail.com> <50D06177.2090905@mojatatu.com> <CAASe=fR6Hm2dxp=1wDchtrzqnaH6qacHpg2wrsqLfmGpPbQ9Fg@mail.gmail.com> <50D1A8A7.1090002@mojatatu.com> <50D1AB7E.5060000@mojatatu.com> <50D2D229.6040802@gmail.com> <50D305FD.7000901@mojatatu.com> <50D327CD.3050904@gmail.com> <50D45E25.7050703@mojatatu.com> <50D46060.2070308@gmail.com> <50D4692
 8.9070809@mojatatu.com> <50D46EC1.2040608@gmail.com> <50D5B366.30005@mojatatu.com> <50D5BC96.9010602@gmail.com> <50D5BF00.7050304@mojatatu.com> <50D83DDB.102@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Yury Stankevich <urykhy@gmail.com>,
	Hasan Chowdhury <shemonc@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Jan Engelhardt <jengelh@inai.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	pablo@netfilter.org, netfilter-devel@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:52287 "EHLO nbd.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752211Ab2LXLtg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Dec 2012 06:49:36 -0500
In-Reply-To: <50D83DDB.102@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2012-12-24 12:34 PM, Jamal Hadi Salim wrote:
> 
> Some good news Yury.
> I am told Felix Fietkau <nbd@openwrt.org> (on CC) actually
> already solved this issue and it is a feature in openwrt. I
> cant find the code.
> 
> Felix - Yury is trying to retrieve skb->mark fields from
> netfilter connmark. My understanding is you have written
> such an action. Can you please point us to it - and any
> reason you havent submitted this for inclusion in kernel
> proper?
After I added it as an experiment, I got distracted with other projects
again and forgot about submitting it. Take a look at the code - if the
approach is reasonable, I'll submit this thing for inclusion soon.

- Felix

--- /dev/null
+++ b/net/sched/act_connmark.c
@@ -0,0 +1,137 @@
+/*
+ * Copyright (c) 2011 Felix Fietkau <nbd@openwrt.org>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, write to the Free Software Foundation, Inc., 59 Temple
+ * Place - Suite 330, Boston, MA 02111-1307 USA.
+ */
+
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/kernel.h>
+#include <linux/skbuff.h>
+#include <linux/rtnetlink.h>
+#include <linux/pkt_cls.h>
+#include <linux/ip.h>
+#include <linux/ipv6.h>
+#include <net/netlink.h>
+#include <net/pkt_sched.h>
+#include <net/act_api.h>
+
+#include <net/netfilter/nf_conntrack.h>
+#include <net/netfilter/nf_conntrack_core.h>
+
+#define TCA_ACT_CONNMARK	20
+
+#define CONNMARK_TAB_MASK     3
+static struct tcf_common *tcf_connmark_ht[CONNMARK_TAB_MASK + 1];
+static u32 connmark_idx_gen;
+static DEFINE_RWLOCK(connmark_lock);
+
+static struct tcf_hashinfo connmark_hash_info = {
+	.htab	=	tcf_connmark_ht,
+	.hmask	=	CONNMARK_TAB_MASK,
+	.lock	=	&connmark_lock,
+};
+
+static int tcf_connmark(struct sk_buff *skb, const struct tc_action *a,
+		       struct tcf_result *res)
+{
+	struct nf_conn *c;
+	enum ip_conntrack_info ctinfo;
+	int proto;
+	int r;
+
+	if (skb->protocol == htons(ETH_P_IP)) {
+		if (skb->len < sizeof(struct iphdr))
+			goto out;
+		proto = PF_INET;
+	} else if (skb->protocol == htons(ETH_P_IPV6)) {
+		if (skb->len < sizeof(struct ipv6hdr))
+			goto out;
+		proto = PF_INET6;
+	} else
+		goto out;
+
+	r = nf_conntrack_in(dev_net(skb->dev), proto, NF_INET_PRE_ROUTING, skb);
+	if (r != NF_ACCEPT)
+		goto out;
+
+	c = nf_ct_get(skb, &ctinfo);
+	if (!c)
+		goto out;
+
+	skb->mark = c->mark;
+	nf_conntrack_put(skb->nfct);
+	skb->nfct = NULL;
+
+out:
+	return TC_ACT_PIPE;
+}
+
+static int tcf_connmark_init(struct nlattr *nla, struct nlattr *est,
+			 struct tc_action *a, int ovr, int bind)
+{
+	struct tcf_common *pc;
+
+	pc = tcf_hash_create(0, est, a, sizeof(*pc), bind,
+			     &connmark_idx_gen, &connmark_hash_info);
+	if (IS_ERR(pc))
+	    return PTR_ERR(pc);
+
+	tcf_hash_insert(pc, &connmark_hash_info);
+
+	return ACT_P_CREATED;
+}
+
+static inline int tcf_connmark_cleanup(struct tc_action *a, int bind)
+{
+	if (a->priv)
+		return tcf_hash_release(a->priv, bind, &connmark_hash_info);
+	return 0;
+}
+
+static inline int tcf_connmark_dump(struct sk_buff *skb, struct tc_action *a,
+				int bind, int ref)
+{
+	return skb->len;
+}
+
+static struct tc_action_ops act_connmark_ops = {
+	.kind		=	"connmark",
+	.hinfo		=	&connmark_hash_info,
+	.type		=	TCA_ACT_CONNMARK,
+	.capab		=	TCA_CAP_NONE,
+	.owner		=	THIS_MODULE,
+	.act		=	tcf_connmark,
+	.dump		=	tcf_connmark_dump,
+	.cleanup	=	tcf_connmark_cleanup,
+	.init		=	tcf_connmark_init,
+	.walk		=	tcf_generic_walker,
+};
+
+MODULE_AUTHOR("Felix Fietkau <nbd@openwrt.org>");
+MODULE_DESCRIPTION("Connection tracking mark restoring");
+MODULE_LICENSE("GPL");
+
+static int __init connmark_init_module(void)
+{
+	return tcf_register_action(&act_connmark_ops);
+}
+
+static void __exit connmark_cleanup_module(void)
+{
+	tcf_unregister_action(&act_connmark_ops);
+}
+
+module_init(connmark_init_module);
+module_exit(connmark_cleanup_module);
--- a/net/sched/Kconfig
+++ b/net/sched/Kconfig
@@ -670,6 +670,19 @@ config NET_ACT_CSUM
 	  To compile this code as a module, choose M here: the
 	  module will be called act_csum.
 
+config NET_ACT_CONNMARK
+        tristate "Connection Tracking Marking"
+        depends on NET_CLS_ACT
+        depends on NF_CONNTRACK
+	 depends on NF_CONNTRACK_MARK
+        ---help---
+	  Say Y here to restore the connmark from a scheduler action
+
+	  If unsure, say N.
+
+	  To compile this code as a module, choose M here: the
+	  module will be called act_connmark.
+
 config NET_CLS_IND
 	bool "Incoming device classification"
 	depends on NET_CLS_U32 || NET_CLS_FW
--- a/net/sched/Makefile
+++ b/net/sched/Makefile
@@ -16,6 +16,7 @@ obj-$(CONFIG_NET_ACT_PEDIT)	+= act_pedit
 obj-$(CONFIG_NET_ACT_SIMP)	+= act_simple.o
 obj-$(CONFIG_NET_ACT_SKBEDIT)	+= act_skbedit.o
 obj-$(CONFIG_NET_ACT_CSUM)	+= act_csum.o
+obj-$(CONFIG_NET_ACT_CONNMARK)	+= act_connmark.o
 obj-$(CONFIG_NET_SCH_FIFO)	+= sch_fifo.o
 obj-$(CONFIG_NET_SCH_CBQ)	+= sch_cbq.o
 obj-$(CONFIG_NET_SCH_HTB)	+= sch_htb.o
