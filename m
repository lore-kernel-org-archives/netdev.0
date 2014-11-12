From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 2/4] net: move make_writable helper into common code
Date: Wed, 12 Nov 2014 15:52:28 +0100
Message-ID: <1415803950-9838-2-git-send-email-jiri@resnulli.us>
References: <1415803950-9838-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, pshelar@nicira.com,
	therbert@google.com, edumazet@google.com, willemb@google.com,
	dborkman@redhat.com, mst@redhat.com, fw@strlen.de,
	Paul.Durrant@citrix.com, tgraf@suug.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:38256 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752974AbaKLOwj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2014 09:52:39 -0500
Received: by mail-wi0-f170.google.com with SMTP id r20so5159447wiv.1
        for <netdev@vger.kernel.org>; Wed, 12 Nov 2014 06:52:38 -0800 (PST)
In-Reply-To: <1415803950-9838-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

note that skb_make_writable already exists in net/netfilter/core.c
but does something slightly different.

Suggested-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/linux/skbuff.h    |  1 +
 net/core/skbuff.c         | 12 ++++++++++++
 net/openvswitch/actions.c | 39 ++++++++++++++-------------------------
 3 files changed, 27 insertions(+), 25 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 73c370e..e045516 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2678,6 +2678,7 @@ void skb_scrub_packet(struct sk_buff *skb, bool xnet);
 unsigned int skb_gso_transport_seglen(const struct sk_buff *skb);
 struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features);
 struct sk_buff *skb_vlan_untag(struct sk_buff *skb);
+int skb_ensure_writable(struct sk_buff *skb, int write_len);
 
 struct skb_checksum_ops {
 	__wsum (*update)(const void *mem, int len, __wsum wsum);
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 7001896..d11bbe0 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -4151,6 +4151,18 @@ err_free:
 }
 EXPORT_SYMBOL(skb_vlan_untag);
 
+int skb_ensure_writable(struct sk_buff *skb, int write_len)
+{
+	if (!pskb_may_pull(skb, write_len))
+		return -ENOMEM;
+
+	if (!skb_cloned(skb) || skb_clone_writable(skb, write_len))
+		return 0;
+
+	return pskb_expand_head(skb, 0, 0, GFP_ATOMIC);
+}
+EXPORT_SYMBOL(skb_ensure_writable);
+
 /**
  * alloc_skb_with_frags - allocate skb with page frags
  *
diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 749a301..04c9680 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -119,17 +119,6 @@ static bool is_flow_key_valid(const struct sw_flow_key *key)
 	return !!key->eth.type;
 }
 
-static int make_writable(struct sk_buff *skb, int write_len)
-{
-	if (!pskb_may_pull(skb, write_len))
-		return -ENOMEM;
-
-	if (!skb_cloned(skb) || skb_clone_writable(skb, write_len))
-		return 0;
-
-	return pskb_expand_head(skb, 0, 0, GFP_ATOMIC);
-}
-
 static int push_mpls(struct sk_buff *skb, struct sw_flow_key *key,
 		     const struct ovs_action_push_mpls *mpls)
 {
@@ -171,7 +160,7 @@ static int pop_mpls(struct sk_buff *skb, struct sw_flow_key *key,
 	struct ethhdr *hdr;
 	int err;
 
-	err = make_writable(skb, skb->mac_len + MPLS_HLEN);
+	err = skb_ensure_writable(skb, skb->mac_len + MPLS_HLEN);
 	if (unlikely(err))
 		return err;
 
@@ -201,7 +190,7 @@ static int set_mpls(struct sk_buff *skb, struct sw_flow_key *key,
 	__be32 *stack;
 	int err;
 
-	err = make_writable(skb, skb->mac_len + MPLS_HLEN);
+	err = skb_ensure_writable(skb, skb->mac_len + MPLS_HLEN);
 	if (unlikely(err))
 		return err;
 
@@ -223,7 +212,7 @@ static int __pop_vlan_tci(struct sk_buff *skb, __be16 *current_tci)
 	struct vlan_hdr *vhdr;
 	int err;
 
-	err = make_writable(skb, VLAN_ETH_HLEN);
+	err = skb_ensure_writable(skb, VLAN_ETH_HLEN);
 	if (unlikely(err))
 		return err;
 
@@ -308,7 +297,7 @@ static int set_eth_addr(struct sk_buff *skb, struct sw_flow_key *key,
 			const struct ovs_key_ethernet *eth_key)
 {
 	int err;
-	err = make_writable(skb, ETH_HLEN);
+	err = skb_ensure_writable(skb, ETH_HLEN);
 	if (unlikely(err))
 		return err;
 
@@ -410,8 +399,8 @@ static int set_ipv4(struct sk_buff *skb, struct sw_flow_key *key,
 	struct iphdr *nh;
 	int err;
 
-	err = make_writable(skb, skb_network_offset(skb) +
-				 sizeof(struct iphdr));
+	err = skb_ensure_writable(skb, skb_network_offset(skb) +
+				  sizeof(struct iphdr));
 	if (unlikely(err))
 		return err;
 
@@ -448,8 +437,8 @@ static int set_ipv6(struct sk_buff *skb, struct sw_flow_key *key,
 	__be32 *saddr;
 	__be32 *daddr;
 
-	err = make_writable(skb, skb_network_offset(skb) +
-			    sizeof(struct ipv6hdr));
+	err = skb_ensure_writable(skb, skb_network_offset(skb) +
+				  sizeof(struct ipv6hdr));
 	if (unlikely(err))
 		return err;
 
@@ -491,7 +480,7 @@ static int set_ipv6(struct sk_buff *skb, struct sw_flow_key *key,
 	return 0;
 }
 
-/* Must follow make_writable() since that can move the skb data. */
+/* Must follow skb_ensure_writable() since that can move the skb data. */
 static void set_tp_port(struct sk_buff *skb, __be16 *port,
 			 __be16 new_port, __sum16 *check)
 {
@@ -521,8 +510,8 @@ static int set_udp(struct sk_buff *skb, struct sw_flow_key *key,
 	struct udphdr *uh;
 	int err;
 
-	err = make_writable(skb, skb_transport_offset(skb) +
-				 sizeof(struct udphdr));
+	err = skb_ensure_writable(skb, skb_transport_offset(skb) +
+				  sizeof(struct udphdr));
 	if (unlikely(err))
 		return err;
 
@@ -546,8 +535,8 @@ static int set_tcp(struct sk_buff *skb, struct sw_flow_key *key,
 	struct tcphdr *th;
 	int err;
 
-	err = make_writable(skb, skb_transport_offset(skb) +
-				 sizeof(struct tcphdr));
+	err = skb_ensure_writable(skb, skb_transport_offset(skb) +
+				  sizeof(struct tcphdr));
 	if (unlikely(err))
 		return err;
 
@@ -572,7 +561,7 @@ static int set_sctp(struct sk_buff *skb, struct sw_flow_key *key,
 	int err;
 	unsigned int sctphoff = skb_transport_offset(skb);
 
-	err = make_writable(skb, sctphoff + sizeof(struct sctphdr));
+	err = skb_ensure_writable(skb, sctphoff + sizeof(struct sctphdr));
 	if (unlikely(err))
 		return err;
 
-- 
1.9.3
