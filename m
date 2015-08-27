From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next v2] net: Add ethernet header for pass through VRF device
Date: Thu, 27 Aug 2015 10:10:50 -0700
Message-ID: <1440695450-30545-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:35711 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751367AbbH0RK4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 13:10:56 -0400
Received: by pacdd16 with SMTP id dd16so31761624pac.2
        for <netdev@vger.kernel.org>; Thu, 27 Aug 2015 10:10:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The change to use a custom dst broke tcpdump captures on the VRF device:

$ tcpdump -n -i vrf10
...
05:32:29.009362 IP 10.2.1.254 > 10.2.1.2: ICMP echo request, id 21989, seq 1, length 64
05:32:29.009855 00:00:40:01:8d:36 > 45:00:00:54:d6:6f, ethertype Unknown (0x0a02), length 84:
	0x0000:  0102 0a02 01fe 0000 9181 55e5 0001 bd11  ..........U.....
	0x0010:  da55 0000 0000 bb5d 0700 0000 0000 1011  .U.....]........
	0x0020:  1213 1415 1617 1819 1a1b 1c1d 1e1f 2021  ...............!
	0x0030:  2223 2425 2627 2829 2a2b 2c2d 2e2f 3031  "#$%&'()*+,-./01
	0x0040:  3233 3435 3637                           234567

Local packets going through the VRF device are missing an ethernet header.
Fix by adding one and then stripping it off before pushing back to the IP
stack. With this patch you get the expected dumps:

...
05:36:15.713944 IP 10.2.1.254 > 10.2.1.2: ICMP echo request, id 23795, seq 1, length 64
05:36:15.714160 IP 10.2.1.2 > 10.2.1.254: ICMP echo reply, id 23795, seq 1, length 64
...

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
v2
- per DaveM's comment modelled after ip_finish_output2 which uses
  dst_neigh_output rather than dev_hard_header

 drivers/net/vrf.c | 48 +++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 45 insertions(+), 3 deletions(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index b3d9c5546c79..e7094fbd7568 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -27,6 +27,7 @@
 #include <linux/hashtable.h>
 
 #include <linux/inetdevice.h>
+#include <net/arp.h>
 #include <net/ip.h>
 #include <net/ip_fib.h>
 #include <net/ip6_route.h>
@@ -219,6 +220,9 @@ static netdev_tx_t vrf_process_v4_outbound(struct sk_buff *skb,
 
 static netdev_tx_t is_ip_tx_frame(struct sk_buff *skb, struct net_device *dev)
 {
+	/* strip the ethernet header added for pass through VRF device */
+	__skb_pull(skb, skb_network_offset(skb));
+
 	switch (skb->protocol) {
 	case htons(ETH_P_IP):
 		return vrf_process_v4_outbound(skb, dev);
@@ -248,9 +252,47 @@ static netdev_tx_t vrf_xmit(struct sk_buff *skb, struct net_device *dev)
 	return ret;
 }
 
-static netdev_tx_t vrf_finish(struct sock *sk, struct sk_buff *skb)
+/* modelled after ip_finish_output2 */
+static int vrf_finish_output(struct sock *sk, struct sk_buff *skb)
 {
-	return dev_queue_xmit(skb);
+	struct dst_entry *dst = skb_dst(skb);
+	struct rtable *rt = (struct rtable *)dst;
+	struct net_device *dev = dst->dev;
+	unsigned int hh_len = LL_RESERVED_SPACE(dev);
+	struct neighbour *neigh;
+	u32 nexthop;
+	int ret = -EINVAL;
+
+	/* Be paranoid, rather than too clever. */
+	if (unlikely(skb_headroom(skb) < hh_len && dev->header_ops)) {
+		struct sk_buff *skb2;
+
+		skb2 = skb_realloc_headroom(skb, LL_RESERVED_SPACE(dev));
+		if (!skb2) {
+			ret = -ENOMEM;
+			goto err;
+		}
+		if (skb->sk)
+			skb_set_owner_w(skb2, skb->sk);
+
+		consume_skb(skb);
+		skb = skb2;
+	}
+
+	rcu_read_lock_bh();
+
+	nexthop = (__force u32)rt_nexthop(rt, ip_hdr(skb)->daddr);
+	neigh = __ipv4_neigh_lookup_noref(dev, nexthop);
+	if (unlikely(!neigh))
+		neigh = __neigh_create(&arp_tbl, &nexthop, dev, false);
+	if (!IS_ERR(neigh))
+		ret = dst_neigh_output(dst, neigh, skb);
+
+	rcu_read_unlock_bh();
+err:
+	if (unlikely(ret < 0))
+		vrf_tx_error(skb->dev, skb);
+	return ret;
 }
 
 static int vrf_output(struct sock *sk, struct sk_buff *skb)
@@ -264,7 +306,7 @@ static int vrf_output(struct sock *sk, struct sk_buff *skb)
 
 	return NF_HOOK_COND(NFPROTO_IPV4, NF_INET_POST_ROUTING, sk, skb,
 			    NULL, dev,
-			    vrf_finish,
+			    vrf_finish_output,
 			    !(IPCB(skb)->flags & IPSKB_REROUTED));
 }
 
-- 
1.9.1
