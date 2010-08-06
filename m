From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] sfq: add dummy bind/unbind handles
Date: Fri, 6 Aug 2010 15:23:13 -0700
Message-ID: <20100806152313.43abc30b@nehalam>
References: <20100806193548.007978639@vyatta.com>
	<20100806193558.580890552@vyatta.com>
	<4C5C7D9F.4040303@gmail.com>
	<20100806145818.66d389eb@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Franchoze Eric <franchoze@yandex.ru>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:39963 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934122Ab0HFXCO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Aug 2010 19:02:14 -0400
In-Reply-To: <20100806145818.66d389eb@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Applying a filter to an SFQ qdisc would cause null dereference
in tcf_bind_filter because although SFQ is classful it didn't
have all the necessary equipment.

Better alternative to changing tcf_bind API is to just fix
SFQ.  This should go to net-2.6 and stable.


Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/sched/sch_sfq.c	2010-08-06 15:07:26.552820159 -0700
+++ b/net/sched/sch_sfq.c	2010-08-06 15:14:24.458287452 -0700
@@ -502,6 +502,10 @@ static unsigned long sfq_get(struct Qdis
 	return 0;
 }
 
+static void sfq_put(struct Qdisc *q, unsigned long cl)
+{
+}
+
 static struct tcf_proto **sfq_find_tcf(struct Qdisc *sch, unsigned long cl)
 {
 	struct sfq_sched_data *q = qdisc_priv(sch);
@@ -511,6 +515,12 @@ static struct tcf_proto **sfq_find_tcf(s
 	return &q->filter_list;
 }
 
+static unsigned long sfq_bind_tcf(struct Qdisc *sch, unsigned long parent,
+				  u32 cl)
+{
+	return 0;
+}
+
 static int sfq_dump_class(struct Qdisc *sch, unsigned long cl,
 			  struct sk_buff *skb, struct tcmsg *tcm)
 {
@@ -556,6 +566,8 @@ static void sfq_walk(struct Qdisc *sch, 
 static const struct Qdisc_class_ops sfq_class_ops = {
 	.get		=	sfq_get,
 	.tcf_chain	=	sfq_find_tcf,
+	.bind_tcf	=	sfq_bind_tcf,
+	.unbind_tcf	=	sfq_put,
 	.dump		=	sfq_dump_class,
 	.dump_stats	=	sfq_dump_class_stats,
