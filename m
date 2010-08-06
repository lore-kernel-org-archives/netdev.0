From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH] pkt_sched: Fix sch_sfq vs tcf_bind_filter oops
Date: Fri, 6 Aug 2010 10:22:35 +0000
Message-ID: <20100806102235.GA19305@ff.dom.local>
References: <282881281036255@web101.yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
To: Franchoze Eric <franchoze@yandex.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:35343 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761158Ab0HFKWu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Aug 2010 06:22:50 -0400
Received: by fxm14 with SMTP id 14so3706896fxm.19
        for <netdev@vger.kernel.org>; Fri, 06 Aug 2010 03:22:39 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <282881281036255@web101.yandex.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Franchoze Eric wrote:
> Hello, can somebody follow up with approriate fix for that bug? It's reproducible on the latest 2.6.32.17 kernel with Centos5 user land.
> Script to reproduce is bellow.  I did quick fix for that to show where is the issue.

I can't test it with 2.6.32 now but it seems the patch below should
help. Please send your "Tested-by" if so.

Thanks,
Jarek P.
------------>
Since there was added ->tcf_chain() method without ->bind_tcf() to
sch_sfq class options, there is oops when a filter is added with
the classid parameter.

Fixes commit 7d2681a6ff4f9ab5e48d02550b4c6338f1638998
netdev thread: null pointer at cls_api.c

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
Reported-by: Franchoze Eric <franchoze@yandex.ru>
---

diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index e85352b..534f332 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -513,6 +513,12 @@ static unsigned long sfq_get(struct Qdisc *sch, u32 classid)
 	return 0;
 }
 
+static unsigned long sfq_bind(struct Qdisc *sch, unsigned long parent,
+			      u32 classid)
+{
+	return 0;
+}
+
 static struct tcf_proto **sfq_find_tcf(struct Qdisc *sch, unsigned long cl)
 {
 	struct sfq_sched_data *q = qdisc_priv(sch);
@@ -567,6 +573,7 @@ static void sfq_walk(struct Qdisc *sch, struct qdisc_walker *arg)
 static const struct Qdisc_class_ops sfq_class_ops = {
 	.get		=	sfq_get,
 	.tcf_chain	=	sfq_find_tcf,
+	.bind_tcf	=	sfq_bind,
 	.dump		=	sfq_dump_class,
 	.dump_stats	=	sfq_dump_class_stats,
 	.walk		=	sfq_walk,
