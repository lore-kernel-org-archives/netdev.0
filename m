From: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
Subject: [PATCH net-next 7/7] cxgb4: add support to create hash-filters via tc-flower offload
Date: Wed,  1 Nov 2017 08:53:05 +0530
Message-ID: <c3af19ac3b62319540c2712bd4cd753f44c3a69d.1509505160.git.rahul.lakkireddy@chelsio.com>
References: <cover.1509505160.git.rahul.lakkireddy@chelsio.com>
Cc: davem@davemloft.net, kumaras@chelsio.com, ganeshgr@chelsio.com,
        nirranjan@chelsio.com, indranil@chelsio.com,
        Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:1288 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751958AbdKADZC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 23:25:02 -0400
In-Reply-To: <cover.1509505160.git.rahul.lakkireddy@chelsio.com>
In-Reply-To: <cover.1509505160.git.rahul.lakkireddy@chelsio.com>
References: <cover.1509505160.git.rahul.lakkireddy@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kumar Sanghvi <kumaras@chelsio.com>

Determine whether the flow classifies as exact-match with respect to
4-tuple and configured tuple mask in hw. If successfully classified
as exact-match, offload the flow as hash-filter in hw.

Signed-off-by: Kumar Sanghvi <kumaras@chelsio.com>
Signed-off-by: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.c  | 148 +++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.h  |   2 +
 .../net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.c   |  16 ++-
 3 files changed, 161 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.c
index 9b3ff6209eb5..abab67d52edb 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.c
@@ -31,6 +31,7 @@
  * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  * SOFTWARE.
  */
+#include <net/ipv6.h>
 
 #include "cxgb4.h"
 #include "t4_regs.h"
@@ -765,6 +766,153 @@ static void fill_default_mask(struct ch_filter_specification *fs)
 		fs->mask.fport = ~0;
 }
 
+static bool is_addr_all_mask(u8 *ipmask, int family)
+{
+	if (family == AF_INET) {
+		struct in_addr *addr;
+
+		addr = (struct in_addr *)ipmask;
+		if (addr->s_addr == 0xffffffff)
+			return true;
+	} else if (family == AF_INET6) {
+		struct in6_addr *addr6;
+
+		addr6 = (struct in6_addr *)ipmask;
+		if (addr6->s6_addr32[0] == 0xffffffff &&
+		    addr6->s6_addr32[1] == 0xffffffff &&
+		    addr6->s6_addr32[2] == 0xffffffff &&
+		    addr6->s6_addr32[3] == 0xffffffff)
+			return true;
+	}
+	return false;
+}
+
+static bool is_inaddr_any(u8 *ip, int family)
+{
+	int addr_type;
+
+	if (family == AF_INET) {
+		struct in_addr *addr;
+
+		addr = (struct in_addr *)ip;
+		if (addr->s_addr == htonl(INADDR_ANY))
+			return true;
+	} else if (family == AF_INET6) {
+		struct in6_addr *addr6;
+
+		addr6 = (struct in6_addr *)ip;
+		addr_type = ipv6_addr_type((const struct in6_addr *)
+					   &addr6);
+		if (addr_type == IPV6_ADDR_ANY)
+			return true;
+	}
+	return false;
+}
+
+bool is_filter_exact_match(struct adapter *adap,
+			   struct ch_filter_specification *fs)
+{
+	struct tp_params *tp = &adap->params.tp;
+	u64 hash_filter_mask = tp->hash_filter_mask;
+	u32 mask;
+
+	if (!is_hashfilter(adap))
+		return false;
+
+	if (fs->type) {
+		if (is_inaddr_any(fs->val.fip, AF_INET6) ||
+		    !is_addr_all_mask(fs->mask.fip, AF_INET6))
+			return false;
+
+		if (is_inaddr_any(fs->val.lip, AF_INET6) ||
+		    !is_addr_all_mask(fs->mask.lip, AF_INET6))
+			return false;
+	} else {
+		if (is_inaddr_any(fs->val.fip, AF_INET) ||
+		    !is_addr_all_mask(fs->mask.fip, AF_INET))
+			return false;
+
+		if (is_inaddr_any(fs->val.lip, AF_INET) ||
+		    !is_addr_all_mask(fs->mask.lip, AF_INET))
+			return false;
+	}
+
+	if (!fs->val.lport || fs->mask.lport != 0xffff)
+		return false;
+
+	if (!fs->val.fport || fs->mask.fport != 0xffff)
+		return false;
+
+	if (tp->fcoe_shift >= 0) {
+		mask = (hash_filter_mask >> tp->fcoe_shift) & FT_FCOE_W;
+		if (mask && !fs->mask.fcoe)
+			return false;
+	}
+
+	if (tp->port_shift >= 0) {
+		mask = (hash_filter_mask >> tp->port_shift) & FT_PORT_W;
+		if (mask && !fs->mask.iport)
+			return false;
+	}
+
+	if (tp->vnic_shift >= 0) {
+		mask = (hash_filter_mask >> tp->vnic_shift) & FT_VNIC_ID_W;
+
+		if ((adap->params.tp.ingress_config & VNIC_F)) {
+			if (mask && !fs->mask.pfvf_vld)
+				return false;
+		} else {
+			if (mask && !fs->mask.ovlan_vld)
+				return false;
+		}
+	}
+
+	if (tp->vlan_shift >= 0) {
+		mask = (hash_filter_mask >> tp->vlan_shift) & FT_VLAN_W;
+		if (mask && !fs->mask.ivlan)
+			return false;
+	}
+
+	if (tp->tos_shift >= 0) {
+		mask = (hash_filter_mask >> tp->tos_shift) & FT_TOS_W;
+		if (mask && !fs->mask.tos)
+			return false;
+	}
+
+	if (tp->protocol_shift >= 0) {
+		mask = (hash_filter_mask >> tp->protocol_shift) & FT_PROTOCOL_W;
+		if (mask && !fs->mask.proto)
+			return false;
+	}
+
+	if (tp->ethertype_shift >= 0) {
+		mask = (hash_filter_mask >> tp->ethertype_shift) &
+			FT_ETHERTYPE_W;
+		if (mask && !fs->mask.ethtype)
+			return false;
+	}
+
+	if (tp->macmatch_shift >= 0) {
+		mask = (hash_filter_mask >> tp->macmatch_shift) & FT_MACMATCH_W;
+		if (mask && !fs->mask.macidx)
+			return false;
+	}
+
+	if (tp->matchtype_shift >= 0) {
+		mask = (hash_filter_mask >> tp->matchtype_shift) &
+			FT_MPSHITTYPE_W;
+		if (mask && !fs->mask.matchtype)
+			return false;
+	}
+	if (tp->frag_shift >= 0) {
+		mask = (hash_filter_mask >> tp->frag_shift) &
+			FT_FRAGMENTATION_W;
+		if (mask && !fs->mask.frag)
+			return false;
+	}
+	return true;
+}
+
 static u64 hash_filter_ntuple(struct ch_filter_specification *fs,
 			      struct net_device *dev)
 {
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.h
index 9475abd3384e..8db5fca6dcc9 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.h
@@ -51,4 +51,6 @@ int delete_filter(struct adapter *adapter, unsigned int fidx);
 int writable_filter(struct filter_entry *f);
 void clear_all_filters(struct adapter *adapter);
 int init_hash_filter(struct adapter *adap);
+bool is_filter_exact_match(struct adapter *adap,
+			   struct ch_filter_specification *fs);
 #endif /* __CXGB4_FILTER_H */
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.c
index 3953bc1fdc20..d4a548a6a55c 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.c
@@ -38,6 +38,7 @@
 #include <net/tc_act/tc_vlan.h>
 
 #include "cxgb4.h"
+#include "cxgb4_filter.h"
 #include "cxgb4_tc_flower.h"
 
 #define STATS_CHECK_PERIOD (HZ / 2)
@@ -672,11 +673,16 @@ int cxgb4_tc_flower_replace(struct net_device *dev,
 	cxgb4_process_flow_match(dev, cls, fs);
 	cxgb4_process_flow_actions(dev, cls, fs);
 
-	fidx = cxgb4_get_free_ftid(dev, fs->type ? PF_INET6 : PF_INET);
-	if (fidx < 0) {
-		netdev_err(dev, "%s: No fidx for offload.\n", __func__);
-		ret = -ENOMEM;
-		goto free_entry;
+	fs->hash = is_filter_exact_match(adap, fs);
+	if (fs->hash) {
+		fidx = 0;
+	} else {
+		fidx = cxgb4_get_free_ftid(dev, fs->type ? PF_INET6 : PF_INET);
+		if (fidx < 0) {
+			netdev_err(dev, "%s: No fidx for offload.\n", __func__);
+			ret = -ENOMEM;
+			goto free_entry;
+		}
 	}
 
 	init_completion(&ctx.completion);
-- 
2.14.1
