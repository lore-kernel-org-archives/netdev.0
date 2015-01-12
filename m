From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] net: sched: fix skb->protocol use in case of accelerated vlan path
Date: Mon, 12 Jan 2015 11:19:35 +0100
Message-ID: <1421057975-1754-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:56828 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752121AbbALKTj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2015 05:19:39 -0500
Received: by mail-wg0-f44.google.com with SMTP id y19so2228253wgg.3
        for <netdev@vger.kernel.org>; Mon, 12 Jan 2015 02:19:37 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tc code implicitly considers skb->protocol even in case of accelerated
vlan paths and expects vlan protocol type here. However, on rx path,
if the vlan header was already stripped, skb->protocol contains value
of next header. Similar situation is on tx path.

So for skbs that use skb->vlan_tci for tagging, use skb->vlan_proto instead.

Reported-by: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Jiri Pirko <jiri@resnulli.us>
Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>
---

Note that this is present since vlan accel was introduced, pre-git times.
Please consider this for stable.

 include/net/pkt_sched.h | 12 ++++++++++++
 net/sched/act_csum.c    |  2 +-
 net/sched/cls_flow.c    |  8 ++++----
 net/sched/em_ipset.c    |  2 +-
 net/sched/em_meta.c     |  2 +-
 net/sched/sch_api.c     |  2 +-
 net/sched/sch_dsmark.c  |  6 +++---
 net/sched/sch_teql.c    |  4 ++--
 8 files changed, 25 insertions(+), 13 deletions(-)

diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index 27a3383..cd590f7 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -3,6 +3,7 @@
 
 #include <linux/jiffies.h>
 #include <linux/ktime.h>
+#include <linux/if_vlan.h>
 #include <net/sch_generic.h>
 
 struct qdisc_walker {
@@ -114,6 +115,17 @@ int tc_classify_compat(struct sk_buff *skb, const struct tcf_proto *tp,
 int tc_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 		struct tcf_result *res);
 
+static inline __be16 tc_skb_protocol(struct sk_buff *skb)
+{
+	/* We need to take extra care in case the skb came via
+	 * vlan accelerated path. In that case, use skb->vlan_proto
+	 * as the original vlan header was already stripped.
+	 */
+	if (vlan_tx_tag_present(skb))
+		return skb->vlan_proto;
+	return skb->protocol;
+}
+
 /* Calculate maximal size of packet seen by hard_start_xmit
    routine of this device.
  */
diff --git a/net/sched/act_csum.c b/net/sched/act_csum.c
index edbf40d..4cd5cf1 100644
--- a/net/sched/act_csum.c
+++ b/net/sched/act_csum.c
@@ -509,7 +509,7 @@ static int tcf_csum(struct sk_buff *skb,
 	if (unlikely(action == TC_ACT_SHOT))
 		goto drop;
 
-	switch (skb->protocol) {
+	switch (tc_skb_protocol(skb)) {
 	case cpu_to_be16(ETH_P_IP):
 		if (!tcf_csum_ipv4(skb, update_flags))
 			goto drop;
diff --git a/net/sched/cls_flow.c b/net/sched/cls_flow.c
index 15d68f2..4614103 100644
--- a/net/sched/cls_flow.c
+++ b/net/sched/cls_flow.c
@@ -77,7 +77,7 @@ static u32 flow_get_dst(const struct sk_buff *skb, const struct flow_keys *flow)
 {
 	if (flow->dst)
 		return ntohl(flow->dst);
-	return addr_fold(skb_dst(skb)) ^ (__force u16)skb->protocol;
+	return addr_fold(skb_dst(skb)) ^ (__force u16) tc_skb_protocol(skb);
 }
 
 static u32 flow_get_proto(const struct sk_buff *skb, const struct flow_keys *flow)
@@ -98,7 +98,7 @@ static u32 flow_get_proto_dst(const struct sk_buff *skb, const struct flow_keys
 	if (flow->ports)
 		return ntohs(flow->port16[1]);
 
-	return addr_fold(skb_dst(skb)) ^ (__force u16)skb->protocol;
+	return addr_fold(skb_dst(skb)) ^ (__force u16) tc_skb_protocol(skb);
 }
 
 static u32 flow_get_iif(const struct sk_buff *skb)
@@ -144,7 +144,7 @@ static u32 flow_get_nfct(const struct sk_buff *skb)
 
 static u32 flow_get_nfct_src(const struct sk_buff *skb, const struct flow_keys *flow)
 {
-	switch (skb->protocol) {
+	switch (tc_skb_protocol(skb)) {
 	case htons(ETH_P_IP):
 		return ntohl(CTTUPLE(skb, src.u3.ip));
 	case htons(ETH_P_IPV6):
@@ -156,7 +156,7 @@ fallback:
 
 static u32 flow_get_nfct_dst(const struct sk_buff *skb, const struct flow_keys *flow)
 {
-	switch (skb->protocol) {
+	switch (tc_skb_protocol(skb)) {
 	case htons(ETH_P_IP):
 		return ntohl(CTTUPLE(skb, dst.u3.ip));
 	case htons(ETH_P_IPV6):
diff --git a/net/sched/em_ipset.c b/net/sched/em_ipset.c
index 5b4a4ef..a3d79c8 100644
--- a/net/sched/em_ipset.c
+++ b/net/sched/em_ipset.c
@@ -59,7 +59,7 @@ static int em_ipset_match(struct sk_buff *skb, struct tcf_ematch *em,
 	struct net_device *dev, *indev = NULL;
 	int ret, network_offset;
 
-	switch (skb->protocol) {
+	switch (tc_skb_protocol(skb)) {
 	case htons(ETH_P_IP):
 		acpar.family = NFPROTO_IPV4;
 		if (!pskb_network_may_pull(skb, sizeof(struct iphdr)))
diff --git a/net/sched/em_meta.c b/net/sched/em_meta.c
index c8f8c39..2159981 100644
--- a/net/sched/em_meta.c
+++ b/net/sched/em_meta.c
@@ -197,7 +197,7 @@ META_COLLECTOR(int_priority)
 META_COLLECTOR(int_protocol)
 {
 	/* Let userspace take care of the byte ordering */
-	dst->value = skb->protocol;
+	dst->value = tc_skb_protocol(skb);
 }
 
 META_COLLECTOR(int_pkttype)
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 76f402e..243b7d1 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -1807,7 +1807,7 @@ done:
 int tc_classify_compat(struct sk_buff *skb, const struct tcf_proto *tp,
 		       struct tcf_result *res)
 {
-	__be16 protocol = skb->protocol;
+	__be16 protocol = tc_skb_protocol(skb);
 	int err;
 
 	for (; tp; tp = rcu_dereference_bh(tp->next)) {
diff --git a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
index 227114f..66700a6 100644
--- a/net/sched/sch_dsmark.c
+++ b/net/sched/sch_dsmark.c
@@ -203,7 +203,7 @@ static int dsmark_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	pr_debug("%s(skb %p,sch %p,[qdisc %p])\n", __func__, skb, sch, p);
 
 	if (p->set_tc_index) {
-		switch (skb->protocol) {
+		switch (tc_skb_protocol(skb)) {
 		case htons(ETH_P_IP):
 			if (skb_cow_head(skb, sizeof(struct iphdr)))
 				goto drop;
@@ -289,7 +289,7 @@ static struct sk_buff *dsmark_dequeue(struct Qdisc *sch)
 	index = skb->tc_index & (p->indices - 1);
 	pr_debug("index %d->%d\n", skb->tc_index, index);
 
-	switch (skb->protocol) {
+	switch (tc_skb_protocol(skb)) {
 	case htons(ETH_P_IP):
 		ipv4_change_dsfield(ip_hdr(skb), p->mask[index],
 				    p->value[index]);
@@ -306,7 +306,7 @@ static struct sk_buff *dsmark_dequeue(struct Qdisc *sch)
 		 */
 		if (p->mask[index] != 0xff || p->value[index])
 			pr_warn("%s: unsupported protocol %d\n",
-				__func__, ntohs(skb->protocol));
+				__func__, ntohs(tc_skb_protocol(skb)));
 		break;
 	}
 
diff --git a/net/sched/sch_teql.c b/net/sched/sch_teql.c
index 6ada423..2ad0c40 100644
--- a/net/sched/sch_teql.c
+++ b/net/sched/sch_teql.c
@@ -249,8 +249,8 @@ __teql_resolve(struct sk_buff *skb, struct sk_buff *skb_res,
 		char haddr[MAX_ADDR_LEN];
 
 		neigh_ha_snapshot(haddr, n, dev);
-		err = dev_hard_header(skb, dev, ntohs(skb->protocol), haddr,
-				      NULL, skb->len);
+		err = dev_hard_header(skb, dev, ntohs(tc_skb_protocol(skb)),
+				      haddr, NULL, skb->len);
 
 		if (err < 0)
 			err = -EINVAL;
-- 
1.9.3
