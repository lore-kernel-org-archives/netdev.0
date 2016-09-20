From: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
Subject: [PATCH net-next v3 5/5] cxgb4: add support for drop and redirect actions
Date: Tue, 20 Sep 2016 17:13:10 +0530
Message-ID: <7f567ffa3488f7fd2c6bc9a4260022b6c481b146.1474029678.git.rahul.lakkireddy@chelsio.com>
References: <cover.1474029677.git.rahul.lakkireddy@chelsio.com>
Cc: davem@davemloft.net, hariprasad@chelsio.com, leedom@chelsio.com,
        nirranjan@chelsio.com, indranil@chelsio.com,
        Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:7618 "EHLO
        stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752814AbcITLqx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 07:46:53 -0400
In-Reply-To: <cover.1474029677.git.rahul.lakkireddy@chelsio.com>
In-Reply-To: <cover.1474029677.git.rahul.lakkireddy@chelsio.com>
References: <cover.1474029677.git.rahul.lakkireddy@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for dropping matched packets in hardware.  Also add support
for re-directing matched packets to a specified port in hardware.

Signed-off-by: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.c | 71 +++++++++++++++++++++++
 1 file changed, 71 insertions(+)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.c
index d63b895..49d2deb 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.c
@@ -32,6 +32,9 @@
  * SOFTWARE.
  */
 
+#include <net/tc_act/tc_gact.h>
+#include <net/tc_act/tc_mirred.h>
+
 #include "cxgb4.h"
 #include "cxgb4_tc_u32_parse.h"
 #include "cxgb4_tc_u32.h"
@@ -82,6 +85,67 @@ static int fill_match_fields(struct adapter *adap,
 	return 0;
 }
 
+/* Fill ch_filter_specification with parsed action. */
+static int fill_action_fields(struct adapter *adap,
+			      struct ch_filter_specification *fs,
+			      struct tc_cls_u32_offload *cls)
+{
+	unsigned int num_actions = 0;
+	const struct tc_action *a;
+	struct tcf_exts *exts;
+	LIST_HEAD(actions);
+
+	exts = cls->knode.exts;
+	if (tc_no_actions(exts))
+		return -EINVAL;
+
+	tcf_exts_to_list(exts, &actions);
+	list_for_each_entry(a, &actions, list) {
+		/* Don't allow more than one action per rule. */
+		if (num_actions)
+			return -EINVAL;
+
+		/* Drop in hardware. */
+		if (is_tcf_gact_shot(a)) {
+			fs->action = FILTER_DROP;
+			num_actions++;
+			continue;
+		}
+
+		/* Re-direct to specified port in hardware. */
+		if (is_tcf_mirred_redirect(a)) {
+			struct net_device *n_dev;
+			unsigned int i, index;
+			bool found = false;
+
+			index = tcf_mirred_ifindex(a);
+			for_each_port(adap, i) {
+				n_dev = adap->port[i];
+				if (index == n_dev->ifindex) {
+					fs->action = FILTER_SWITCH;
+					fs->eport = i;
+					found = true;
+					break;
+				}
+			}
+
+			/* Interface doesn't belong to any port of
+			 * the underlying hardware.
+			 */
+			if (!found)
+				return -EINVAL;
+
+			num_actions++;
+			continue;
+		}
+
+		/* Un-supported action. */
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
 int cxgb4_config_knode(struct net_device *dev, __be16 protocol,
 		       struct tc_cls_u32_offload *cls)
 {
@@ -234,6 +298,13 @@ int cxgb4_config_knode(struct net_device *dev, __be16 protocol,
 	if (ret)
 		goto out;
 
+	/* Fill ch_filter_specification action fields to be shipped to
+	 * hardware.
+	 */
+	ret = fill_action_fields(adapter, &fs, cls);
+	if (ret)
+		goto out;
+
 	/* The filter spec has been completely built from the info
 	 * provided from u32.  We now set some default fields in the
 	 * spec for sanity.
-- 
2.5.3
