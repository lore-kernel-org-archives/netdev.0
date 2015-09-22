From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net 1/2] ipv4: send arp replies to the correct tunnel
Date: Tue, 22 Sep 2015 18:12:11 +0200
Message-ID: <cd7f171ada2f0933687fd2a987885aa9af7a7f9c.1442936392.git.jbenc@redhat.com>
References: <cover.1442936392.git.jbenc@redhat.com>
Cc: Thomas Graf <tgraf@suug.ch>,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34020 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758136AbbIVQMe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Sep 2015 12:12:34 -0400
In-Reply-To: <cover.1442936392.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When using ip lwtunnels, the additional data for xmit (basically, the actual
tunnel to use) are carried in ip_tunnel_info either in dst->lwtstate or in
metadata dst. When replying to ARP requests, we need to send the reply to
the same tunnel the request came from. This means we need to construct
proper metadata dst for ARP replies.

We could perform another route lookup to get a dst entry with the correct
lwtstate. However, this won't always ensure that the outgoing tunnel is the
same as the incoming one, and it won't work anyway for IPv4 duplicate
address detection.

The only thing to do is to "reverse" the ip_tunnel_info.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 include/net/ip_tunnels.h  |  2 ++
 net/ipv4/arp.c            | 39 +++++++++++++++++++++++++--------------
 net/ipv4/ip_tunnel_core.c | 28 ++++++++++++++++++++++++++++
 3 files changed, 55 insertions(+), 14 deletions(-)

diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index 9a6a3ba888e8..f6dafec9102c 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -276,6 +276,8 @@ int iptunnel_pull_header(struct sk_buff *skb, int hdr_len, __be16 inner_proto);
 int iptunnel_xmit(struct sock *sk, struct rtable *rt, struct sk_buff *skb,
 		  __be32 src, __be32 dst, u8 proto,
 		  u8 tos, u8 ttl, __be16 df, bool xnet);
+struct metadata_dst *iptunnel_metadata_reply(struct metadata_dst *md,
+					     gfp_t flags);
 
 struct sk_buff *iptunnel_handle_offloads(struct sk_buff *skb, bool gre_csum,
 					 int gso_type_mask);
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 30409b75e925..f03db8b7abee 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -113,6 +113,8 @@
 #include <net/arp.h>
 #include <net/ax25.h>
 #include <net/netrom.h>
+#include <net/dst_metadata.h>
+#include <net/ip_tunnels.h>
 
 #include <linux/uaccess.h>
 
@@ -296,7 +298,8 @@ static void arp_send_dst(int type, int ptype, __be32 dest_ip,
 			 struct net_device *dev, __be32 src_ip,
 			 const unsigned char *dest_hw,
 			 const unsigned char *src_hw,
-			 const unsigned char *target_hw, struct sk_buff *oskb)
+			 const unsigned char *target_hw,
+			 struct dst_entry *dst)
 {
 	struct sk_buff *skb;
 
@@ -309,9 +312,7 @@ static void arp_send_dst(int type, int ptype, __be32 dest_ip,
 	if (!skb)
 		return;
 
-	if (oskb)
-		skb_dst_copy(skb, oskb);
-
+	skb_dst_set(skb, dst);
 	arp_xmit(skb);
 }
 
@@ -333,6 +334,7 @@ static void arp_solicit(struct neighbour *neigh, struct sk_buff *skb)
 	__be32 target = *(__be32 *)neigh->primary_key;
 	int probes = atomic_read(&neigh->probes);
 	struct in_device *in_dev;
+	struct dst_entry *dst = NULL;
 
 	rcu_read_lock();
 	in_dev = __in_dev_get_rcu(dev);
@@ -381,9 +383,10 @@ static void arp_solicit(struct neighbour *neigh, struct sk_buff *skb)
 		}
 	}
 
+	if (skb && !(dev->priv_flags & IFF_XMIT_DST_RELEASE))
+		dst = dst_clone(skb_dst(skb));
 	arp_send_dst(ARPOP_REQUEST, ETH_P_ARP, target, dev, saddr,
-		     dst_hw, dev->dev_addr, NULL,
-		     dev->priv_flags & IFF_XMIT_DST_RELEASE ? NULL : skb);
+		     dst_hw, dev->dev_addr, NULL, dst);
 }
 
 static int arp_ignore(struct in_device *in_dev, __be32 sip, __be32 tip)
@@ -649,6 +652,7 @@ static int arp_process(struct sock *sk, struct sk_buff *skb)
 	int addr_type;
 	struct neighbour *n;
 	struct net *net = dev_net(dev);
+	struct dst_entry *reply_dst = NULL;
 	bool is_garp = false;
 
 	/* arp_rcv below verifies the ARP header and verifies the device
@@ -749,13 +753,18 @@ static int arp_process(struct sock *sk, struct sk_buff *skb)
  *  cache.
  */
 
+	if (arp->ar_op == htons(ARPOP_REQUEST) && skb_metadata_dst(skb))
+		reply_dst = (struct dst_entry *)
+			    iptunnel_metadata_reply(skb_metadata_dst(skb),
+						    GFP_ATOMIC);
+
 	/* Special case: IPv4 duplicate address detection packet (RFC2131) */
 	if (sip == 0) {
 		if (arp->ar_op == htons(ARPOP_REQUEST) &&
 		    inet_addr_type_dev_table(net, dev, tip) == RTN_LOCAL &&
 		    !arp_ignore(in_dev, sip, tip))
-			arp_send(ARPOP_REPLY, ETH_P_ARP, sip, dev, tip, sha,
-				 dev->dev_addr, sha);
+			arp_send_dst(ARPOP_REPLY, ETH_P_ARP, sip, dev, tip,
+				     sha, dev->dev_addr, sha, reply_dst);
 		goto out;
 	}
 
@@ -774,9 +783,10 @@ static int arp_process(struct sock *sk, struct sk_buff *skb)
 			if (!dont_send) {
 				n = neigh_event_ns(&arp_tbl, sha, &sip, dev);
 				if (n) {
-					arp_send(ARPOP_REPLY, ETH_P_ARP, sip,
-						 dev, tip, sha, dev->dev_addr,
-						 sha);
+					arp_send_dst(ARPOP_REPLY, ETH_P_ARP,
+						     sip, dev, tip, sha,
+						     dev->dev_addr, sha,
+						     reply_dst);
 					neigh_release(n);
 				}
 			}
@@ -794,9 +804,10 @@ static int arp_process(struct sock *sk, struct sk_buff *skb)
 				if (NEIGH_CB(skb)->flags & LOCALLY_ENQUEUED ||
 				    skb->pkt_type == PACKET_HOST ||
 				    NEIGH_VAR(in_dev->arp_parms, PROXY_DELAY) == 0) {
-					arp_send(ARPOP_REPLY, ETH_P_ARP, sip,
-						 dev, tip, sha, dev->dev_addr,
-						 sha);
+					arp_send_dst(ARPOP_REPLY, ETH_P_ARP,
+						     sip, dev, tip, sha,
+						     dev->dev_addr, sha,
+						     reply_dst);
 				} else {
 					pneigh_enqueue(&arp_tbl,
 						       in_dev->arp_parms, skb);
diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index 9b97204b8c81..ce3a1e728606 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -46,6 +46,7 @@
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
 #include <net/rtnetlink.h>
+#include <net/dst_metadata.h>
 
 int iptunnel_xmit(struct sock *sk, struct rtable *rt, struct sk_buff *skb,
 		  __be32 src, __be32 dst, __u8 proto,
@@ -119,6 +120,33 @@ int iptunnel_pull_header(struct sk_buff *skb, int hdr_len, __be16 inner_proto)
 }
 EXPORT_SYMBOL_GPL(iptunnel_pull_header);
 
+struct metadata_dst *iptunnel_metadata_reply(struct metadata_dst *md,
+					     gfp_t flags)
+{
+	struct metadata_dst *res;
+	struct ip_tunnel_info *dst, *src;
+
+	if (!md || md->u.tun_info.mode & IP_TUNNEL_INFO_TX)
+		return NULL;
+
+	res = metadata_dst_alloc(0, flags);
+	if (!res)
+		return NULL;
+
+	dst = &res->u.tun_info;
+	src = &md->u.tun_info;
+	dst->key.tun_id = src->key.tun_id;
+	if (src->mode & IP_TUNNEL_INFO_IPV6)
+		memcpy(&dst->key.u.ipv6.dst, &src->key.u.ipv6.src,
+		       sizeof(struct in6_addr));
+	else
+		dst->key.u.ipv4.dst = src->key.u.ipv4.src;
+	dst->mode = src->mode | IP_TUNNEL_INFO_TX;
+
+	return res;
+}
+EXPORT_SYMBOL_GPL(iptunnel_metadata_reply);
+
 struct sk_buff *iptunnel_handle_offloads(struct sk_buff *skb,
 					 bool csum_help,
 					 int gso_type_mask)
-- 
1.8.3.1
