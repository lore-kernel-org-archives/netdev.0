From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 02/19] Cleaning up the IPv6 MTU checking in the IPVS xmit code, by using a common helper function __mtu_check_toobig_v6().
Date: Tue, 28 Aug 2012 23:48:42 +0200
Message-ID: <1346190539-9963-3-git-send-email-kaber@trash.net>
References: <1346190539-9963-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1346190539-9963-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesper Dangaard Brouer <brouer@redhat.com>

The MTU check for tunnel mode can also use this helper as
ntohs(old_iph->payload_len) + sizeof(struct ipv6hdr) is qual to
skb->len.  And the 'mtu' variable have been adjusted before
calling helper.

Notice, this also fixes a bug, as the the MTU check in ip_vs_dr_xmit_v6()
were missing a check for skb_is_gso().

This bug e.g. caused issues for KVM IPVS setups, where different
Segmentation Offloading techniques are utilized, between guests,
via the virtio driver.  This resulted in very bad performance,
due to the ICMPv6 "too big" messages didn't affect the sender.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/ipvs/ip_vs_xmit.c |   21 +++++++++++++++------
 1 files changed, 15 insertions(+), 6 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 543a554..67a3978 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -85,6 +85,15 @@ __ip_vs_dst_check(struct ip_vs_dest *dest, u32 rtos)
 	return dst;
 }
 
+static inline bool
+__mtu_check_toobig_v6(const struct sk_buff *skb, u32 mtu)
+{
+	if (skb->len > mtu && !skb_is_gso(skb)) {
+		return true; /* Packet size violate MTU size */
+	}
+	return false;
+}
+
 /* Get route to daddr, update *saddr, optionally bind route to saddr */
 static struct rtable *do_output_route4(struct net *net, __be32 daddr,
 				       u32 rtos, int rt_mode, __be32 *saddr)
@@ -491,7 +500,7 @@ ip_vs_bypass_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	/* MTU checking */
 	mtu = dst_mtu(&rt->dst);
-	if (skb->len > mtu && !skb_is_gso(skb)) {
+	if (__mtu_check_toobig_v6(skb, mtu)) {
 		if (!skb->dev) {
 			struct net *net = dev_net(skb_dst(skb)->dev);
 
@@ -712,7 +721,7 @@ ip_vs_nat_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	/* MTU checking */
 	mtu = dst_mtu(&rt->dst);
-	if (skb->len > mtu && !skb_is_gso(skb)) {
+	if (__mtu_check_toobig_v6(skb, mtu)) {
 		if (!skb->dev) {
 			struct net *net = dev_net(skb_dst(skb)->dev);
 
@@ -946,8 +955,8 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	if (skb_dst(skb))
 		skb_dst(skb)->ops->update_pmtu(skb_dst(skb), NULL, skb, mtu);
 
-	if (mtu < ntohs(old_iph->payload_len) + sizeof(struct ipv6hdr) &&
-	    !skb_is_gso(skb)) {
+	/* MTU checking: Notice that 'mtu' have been adjusted before hand */
+	if (__mtu_check_toobig_v6(skb, mtu)) {
 		if (!skb->dev) {
 			struct net *net = dev_net(skb_dst(skb)->dev);
 
@@ -1113,7 +1122,7 @@ ip_vs_dr_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	/* MTU checking */
 	mtu = dst_mtu(&rt->dst);
-	if (skb->len > mtu) {
+	if (__mtu_check_toobig_v6(skb, mtu)) {
 		if (!skb->dev) {
 			struct net *net = dev_net(skb_dst(skb)->dev);
 
@@ -1349,7 +1358,7 @@ ip_vs_icmp_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 
 	/* MTU checking */
 	mtu = dst_mtu(&rt->dst);
-	if (skb->len > mtu && !skb_is_gso(skb)) {
+	if (__mtu_check_toobig_v6(skb, mtu)) {
 		if (!skb->dev) {
 			struct net *net = dev_net(skb_dst(skb)->dev);
 
-- 
1.7.1

