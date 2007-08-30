From: Lucas Nussbaum <lucas.nussbaum@imag.fr>
Subject: [PATCH] [NET_SCHED] sch_prio.c: remove duplicate call of
	tc_classify()
Date: Thu, 30 Aug 2007 09:28:17 +0200
Message-ID: <20070830072817.GA9617@xanadu.blop.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xanadu.blop.info ([80.248.208.235]:42572 "EHLO xanadu.blop.info"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753201AbXH3IGP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Aug 2007 04:06:15 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

When CONFIG_NET_CLS_ACT is enabled, tc_classify() is called twice in
prio_classify(). This causes "interesting" behaviour: with the setup
below, packets are duplicated, sent twice to ifb0, and then loop in and
out of ifb0.

The patch uses the previously calculated return value in the switch,
which is probably what Patrick had in mind in commit
bdba91ec70fb5ccbdeb1c7068319adc6ea9e1a7d -- maybe Patrick can
double-check this?

-- example setup --
ifconfig ifb0 up
tc qdisc add dev ifb0 root netem delay 2s
tc qdisc add dev $ETH root handle 1: prio
tc filter add dev $ETH parent 1: protocol ip prio 10 u32 \
 match ip dst 172.24.110.6/32 flowid 1:1 \
 action mirred egress redirect dev ifb0
ping -c1 172.24.110.6

Signed-off-by: Lucas Nussbaum <lucas.nussbaum@imag.fr>

--- net/sched/sch_prio.c.orig	2007-08-30 07:36:41.000000000 +0200
+++ net/sched/sch_prio.c	2007-08-30 07:37:24.000000000 +0200
@@ -42,11 +42,11 @@
 
 	*qerr = NET_XMIT_BYPASS;
 	if (TC_H_MAJ(skb->priority) != sch->handle) {
 		err = tc_classify(skb, q->filter_list, &res);
 #ifdef CONFIG_NET_CLS_ACT
-		switch (tc_classify(skb, q->filter_list, &res)) {
+		switch (err) {
 		case TC_ACT_STOLEN:
 		case TC_ACT_QUEUED:
 			*qerr = NET_XMIT_SUCCESS;
 		case TC_ACT_SHOT:
 			return NULL;
-- 
| Lucas Nussbaum                        PhD student |
| lucas.nussbaum@imag.fr        LIG / Projet MESCAL |
| jabber: lucas@nussbaum.fr    +33 (0)6 64 71 41 65 |
| homepage:        http://www-id.imag.fr/~nussbaum/ |
