From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH RFC net-next 2/2] net: Add UDP GRO support for vxlan traffic
Date: Thu,  2 Jan 2014 15:27:56 +0200
Message-ID: <1388669276-6206-2-git-send-email-ogerlitz@mellanox.com>
References: <1388669276-6206-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Or Gerlitz <ogerlitz@mellanox.com>
To: hkchu@google.com, edumazet@google.com, herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:35340 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750740AbaABN2D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Jan 2014 08:28:03 -0500
In-Reply-To: <1388669276-6206-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add GRO handlers for UDP, with the intent of being able to coalesce vxlan
packets which encapsulate packets belonging to the same TCP session.

The UDP GRO handler will only attempt to coalesce packets whose
destination port is used as vxlan listening port. There are two
issues here for which I will be happy to get feedback

1. what is the most efficient way to determine if a udp port is
owned by the vxlan driver, e.g maybe through a bit map exported by
the vxlan driver?

2. how to prevent the host GRO stack from coalescing guest UDP
packets which went through vxlan encapsulation and happen to carry
the same udp destination port as used by the host vxlan driver..

On my setup, which is net-next (now with the mlx4 vxlan offloads patches) -- for
single TCP session that goes through vxlan tunneling I got nice improvement
from 6.8Gbs to 11.7Gbs

--> UDP/VXLAN GRO disabled
$ netperf  -H 192.168.52.147 -c -C
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.52.147 () port 0 AF_INET
Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB   us/KB

 87380  65536  65536    10.00      6821.21   14.99    29.14    0.720   1.400

--> UDP/VXLAN GRO enabled
$ netperf  -H 192.168.52.147 -c -C
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.52.147 () port 0 AF_INET
Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB   us/KB

 87380  65536  65536    10.00      11694.65   24.87    20.71    0.697   0.580

Cc: Jerry Chu <hkchu@google.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 include/linux/netdevice.h |    1 +
 net/core/dev.c            |    2 +-
 net/ipv4/udp_offload.c    |  113 +++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 115 insertions(+), 1 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 88afa80..183fc8a 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1656,6 +1656,7 @@ struct napi_gro_cb {
 };
 
 #define NAPI_GRO_CB(skb) ((struct napi_gro_cb *)(skb)->cb)
+extern struct list_head offload_base __read_mostly;
 
 struct packet_type {
 	__be16			type;	/* This is really htons(ether_type). */
diff --git a/net/core/dev.c b/net/core/dev.c
index 973c236..86e9d87 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -145,7 +145,7 @@ static DEFINE_SPINLOCK(ptype_lock);
 static DEFINE_SPINLOCK(offload_lock);
 struct list_head ptype_base[PTYPE_HASH_SIZE] __read_mostly;
 struct list_head ptype_all __read_mostly;	/* Taps */
-static struct list_head offload_base __read_mostly;
+struct list_head offload_base __read_mostly;
 
 /*
  * The @dev_base_head list is protected by @dev_base_lock and the rtnl
diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
index bd09f65..114655c 100644
--- a/net/ipv4/udp_offload.c
+++ b/net/ipv4/udp_offload.c
@@ -13,6 +13,7 @@
 #include <linux/skbuff.h>
 #include <net/udp.h>
 #include <net/protocol.h>
+#include <net/vxlan.h>
 
 static int udp4_ufo_send_check(struct sk_buff *skb)
 {
@@ -90,10 +91,122 @@ out:
 	return segs;
 }
 
+static struct sk_buff **udp_gro_receive(struct sk_buff **head, struct sk_buff *skb)
+{
+	struct sk_buff *p, **pp = NULL;
+	struct udphdr *uh, *uh2;
+	struct vxlanhdr *vh, *vh2;
+	struct ethhdr *eh;
+	unsigned int hlen, off_udp, off_vxlan, off_eth;
+	struct list_head *offload_head = &offload_base;
+	struct packet_offload *ptype;
+	__be16 type;
+	int flush = 1;
+
+	off_udp = skb_gro_offset(skb);
+	hlen  = off_udp + sizeof(*uh);
+	uh    = skb_gro_header_fast(skb, off_udp);
+	if (skb_gro_header_hard(skb, hlen)) {
+		uh = skb_gro_header_slow(skb, hlen, off_udp);
+		if (unlikely(!uh))
+			goto out;
+	}
+
+#define VXLAN_PORT htons(18313)
+	/* RFC - we want to call something like vxlan_is_rx_port(uh->dest)) */
+	if (uh->dest != VXLAN_PORT || !skb->encapsulation)
+		goto out;
+
+	skb_gro_pull(skb, sizeof(struct udphdr)); /* pull encapsulating udp header */
+
+	off_vxlan = skb_gro_offset(skb);
+	hlen  = off_vxlan + sizeof(*vh);
+	vh    = skb_gro_header_fast(skb, off_vxlan);
+	if (skb_gro_header_hard(skb, hlen)) {
+		vh = skb_gro_header_slow(skb, hlen, off_vxlan);
+		if (unlikely(!vh))
+			goto out;
+	}
+	skb_gro_pull(skb, sizeof(struct vxlanhdr)); /* pull vxlan header */
+	flush = 0;
+
+	for (p = *head; p; p = p->next) {
+		if (!NAPI_GRO_CB(p)->same_flow)
+			continue;
+
+		uh2 = (struct udphdr   *)(p->data + off_udp);
+		vh2 = (struct vxlanhdr *)(p->data + off_vxlan);
+
+		if ((*(u32 *)&uh->source ^ *(u32 *)&uh2->source) |
+		    (vh->vx_vni ^ vh2->vx_vni)) {
+			NAPI_GRO_CB(p)->same_flow = 0;
+			continue;
+		}
+
+		goto found;
+	}
+
+found:
+
+	off_eth = skb_gro_offset(skb);
+	hlen = off_eth + sizeof(*eh);
+	eh   = skb_gro_header_fast(skb, off_eth);
+	if (skb_gro_header_hard(skb, hlen)) {
+		eh = skb_gro_header_slow(skb, hlen, off_eth);
+		if (unlikely(!eh))
+			goto out;
+	}
+	type = eh->h_proto;
+	skb_gro_pull(skb, sizeof(*eh)); /* pull inner eth header */
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(ptype, offload_head, list) {
+		if (ptype->type != type || !ptype->callbacks.gro_receive)
+			continue;
+		pp = ptype->callbacks.gro_receive(head, skb);
+		break;
+	}
+	rcu_read_unlock();
+
+out:
+	NAPI_GRO_CB(skb)->flush |= flush;
+
+	return pp;
+}
+
+static int udp_gro_complete(struct sk_buff *skb, int nhoff)
+{
+	struct list_head *offload_head = &offload_base;
+	__be16 newlen = htons(skb->len - nhoff);
+	struct udphdr *uh = (struct udphdr *)(skb->data + nhoff);
+	struct packet_offload *ptype;
+	__be16 type;
+	/* 22 = 8 bytes for the vlxan header + 14 bytes for the inner eth header */
+	int vxlan_len  = 22;
+	int err = -ENOENT;
+
+	uh->len = newlen;
+	type = ntohs(ETH_P_IP);
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(ptype, offload_head, list) {
+		if (ptype->type != type || !ptype->callbacks.gro_complete)
+			continue;
+		/* vxlan_len  + sizeof(udphdr) will get us upto the inner IP header */
+		err = ptype->callbacks.gro_complete(skb, nhoff + sizeof(struct udphdr) + vxlan_len);
+		break;
+	}
+	rcu_read_unlock();
+
+	return err;
+}
+
 static const struct net_offload udpv4_offload = {
 	.callbacks = {
 		.gso_send_check = udp4_ufo_send_check,
 		.gso_segment = udp4_ufo_fragment,
+		.gro_receive  =	udp_gro_receive,
+		.gro_complete =	udp_gro_complete,
 	},
 };
 
-- 
1.7.1
