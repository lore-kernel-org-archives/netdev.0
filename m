From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next] openvswitch: adjust skb_gso_segment() for rx path
Date: Wed, 30 Jan 2013 16:38:09 +0800
Message-ID: <1359535089-18348-1-git-send-email-amwang@redhat.com>
Cc: Jesse Gross <jesse@nicira.com>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55065 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752950Ab3A3Iic (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jan 2013 03:38:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

skb_gso_segment() is almost always called in tx path,
except for openvswitch. It calls this function when
it receives the packet and tries to queue it to user-space.
In this special case, the ->ip_summed check inside
skb_gso_segment() is no longer true, as ->ip_summed value
has different meanings on rx path.

This patch adjusts skb_gso_segment() so that we can at least
avoid such warnings on checksum.

I am not very sure if this is a real fix or just a workaround,
at least this patch works fine for me, the kernel warning inside
skb_gso_segment() disappears and the traffic is normal too.

(Note I only tested it on 2.6.32, but ->ip_summed has never
been changed since then.)

Cc: Jesse Gross <jesse@nicira.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 net/core/dev.c             |   13 +++++++++++--
 net/openvswitch/datapath.c |    2 +-
 2 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index a87bc74..f6e7b3f 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2302,6 +2302,15 @@ out:
 }
 EXPORT_SYMBOL(skb_checksum_help);
 
+/* openvswitch calls skb_gso_segment() on rx path, but ->ip_summed has
+ * different meanings on rx path with tx path.
+ */
+static inline bool skb_needs_check(struct sk_buff *skb)
+{
+	return (!skb->skb_iif && skb->ip_summed != CHECKSUM_PARTIAL) ||
+	       (skb->skb_iif && skb->ip_summed == CHECKSUM_NONE);
+}
+
 /**
  *	skb_gso_segment - Perform segmentation on skb.
  *	@skb: buffer to segment
@@ -2336,7 +2345,7 @@ struct sk_buff *skb_gso_segment(struct sk_buff *skb,
 	skb->mac_len = skb->network_header - skb->mac_header;
 	__skb_pull(skb, skb->mac_len);
 
-	if (unlikely(skb->ip_summed != CHECKSUM_PARTIAL)) {
+	if (unlikely(skb_needs_check(skb))) {
 		skb_warn_bad_offload(skb);
 
 		if (skb_header_cloned(skb) &&
@@ -2347,7 +2356,7 @@ struct sk_buff *skb_gso_segment(struct sk_buff *skb,
 	rcu_read_lock();
 	list_for_each_entry_rcu(ptype, &offload_base, list) {
 		if (ptype->type == type && ptype->callbacks.gso_segment) {
-			if (unlikely(skb->ip_summed != CHECKSUM_PARTIAL)) {
+			if (unlikely(skb_needs_check(skb))) {
 				err = ptype->callbacks.gso_send_check(skb);
 				segs = ERR_PTR(err);
 				if (err || skb_gso_ok(skb, features))
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index d8c13a9..0b75964 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -302,7 +302,7 @@ static int queue_gso_packets(struct net *net, int dp_ifindex,
 	int err;
 
 	segs = skb_gso_segment(skb, NETIF_F_SG | NETIF_F_HW_CSUM);
-	if (IS_ERR(segs))
+	if (IS_ERR_OR_NULL(segs))
 		return PTR_ERR(segs);
 
 	/* Queue all of the segments. */
-- 
1.7.7.6
