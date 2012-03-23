From: pablo@netfilter.org
Subject: [PATCH 4/5] netfilter: xt_CT: fix assignation of the generic protocol tracker
Date: Fri, 23 Mar 2012 10:34:16 +0100
Message-ID: <1332495257-3149-5-git-send-email-pablo@netfilter.org>
References: <1332495257-3149-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:47840 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757936Ab2CWJel (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Mar 2012 05:34:41 -0400
In-Reply-To: <1332495257-3149-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

`iptables -p all' uses 0 to match all protocols, while the conntrack
subsystem uses 255. We still need `-p all' to attach the custom
timeout policies for the generic protocol tracker.

Moreover, we may use `iptables -p sctp' while the SCTP tracker is
not loaded. In that case, we have to default on the generic protocol
tracker.

Another possibility is `iptables -p ip' that should be supported
as well. This patch makes sure we validate all possible scenarios.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_CT.c |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/xt_CT.c b/net/netfilter/xt_CT.c
index 33a02b4..0c8e438 100644
--- a/net/netfilter/xt_CT.c
+++ b/net/netfilter/xt_CT.c
@@ -14,6 +14,7 @@
 #include <linux/netfilter/x_tables.h>
 #include <linux/netfilter/xt_CT.h>
 #include <net/netfilter/nf_conntrack.h>
+#include <net/netfilter/nf_conntrack_l4proto.h>
 #include <net/netfilter/nf_conntrack_helper.h>
 #include <net/netfilter/nf_conntrack_ecache.h>
 #include <net/netfilter/nf_conntrack_l4proto.h>
@@ -224,6 +225,7 @@ static int xt_ct_tg_check_v1(const struct xt_tgchk_param *par)
 
 		if (timeout_find_get) {
 			const struct ipt_entry *e = par->entryinfo;
+			struct nf_conntrack_l4proto *l4proto;
 
 			if (e->ip.invflags & IPT_INV_PROTO) {
 				ret = -EINVAL;
@@ -245,7 +247,12 @@ static int xt_ct_tg_check_v1(const struct xt_tgchk_param *par)
 					info->timeout, timeout->l3num);
 				goto err4;
 			}
-			if (timeout->l4proto->l4proto != e->ip.proto) {
+			/* Make sure the timeout policy matches any existing
+			 * protocol tracker, otherwise default to generic.
+			 */
+			l4proto = __nf_ct_l4proto_find(par->family,
+						       e->ip.proto);
+			if (timeout->l4proto->l4proto != l4proto->l4proto) {
 				ret = -EINVAL;
 				pr_info("Timeout policy `%s' can only be "
 					"used by L4 protocol number %d\n",
-- 
1.7.2.5
