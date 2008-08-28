From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 2.6.26.y] sch_prio: Fix nla_parse_nested_compat() regression
Date: Thu, 28 Aug 2008 15:03:31 +0200
Message-ID: <20080828130331.GA20815@postel.suug.ch>
References: <20080827144122.GT20815@postel.suug.ch> <20080827.234731.77434405.davem@davemloft.net> <20080828101840.GZ20815@postel.suug.ch> <20080828.031943.114025230.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alexander.duyck@gmail.com, shemminger@vyatta.com,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	alexander.h.duyck@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:33515 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752636AbYH1NDL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Aug 2008 09:03:11 -0400
Content-Disposition: inline
In-Reply-To: <20080828.031943.114025230.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

nla_parse_nested_compat() was used to parse two different message
formats in the netem and prio qdisc, when it was "fixed" to work
with netem, it broke the multi queue support in the prio qdisc.
Since the prio qdisc code in question is already removed in the
development tree, this patch only fixes the regression in the
stable tree.

Based on original patch from Alexander H Duyck <alexander.h.duyck@intel.com>

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: linux-2.6.26.y/net/sched/sch_prio.c
===================================================================
--- linux-2.6.26.y.orig/net/sched/sch_prio.c	2008-08-28 13:24:22.000000000 +0200
+++ linux-2.6.26.y/net/sched/sch_prio.c	2008-08-28 14:16:44.000000000 +0200
@@ -228,14 +228,20 @@
 {
 	struct prio_sched_data *q = qdisc_priv(sch);
 	struct tc_prio_qopt *qopt;
-	struct nlattr *tb[TCA_PRIO_MAX + 1];
+	struct nlattr *tb[TCA_PRIO_MAX + 1] = {0};
 	int err;
 	int i;
 
-	err = nla_parse_nested_compat(tb, TCA_PRIO_MAX, opt, NULL, qopt,
-				      sizeof(*qopt));
-	if (err < 0)
-		return err;
+	qopt = nla_data(opt);
+	if (nla_len(opt) < sizeof(*qopt))
+		return -1;
+
+	if (nla_len(opt) >= sizeof(*qopt) + sizeof(struct nlattr)) {
+		err = nla_parse_nested(tb, TCA_PRIO_MAX,
+				       (struct nlattr *) (qopt + 1), NULL);
+		if (err < 0)
+			return err;
+	}
 
 	q->bands = qopt->bands;
 	/* If we're multiqueue, make sure the number of incoming bands
