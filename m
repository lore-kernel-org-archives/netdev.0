From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] vlan: mask vlan prio bits
Date: Thu, 18 Jul 2013 07:19:26 -0700
Message-ID: <1374157166.6097.28.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Steinar H. Gunderson" <sesse@google.com>,
	Florian Zumbiehl <florz@florz.de>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:52921 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757741Ab3GROT3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jul 2013 10:19:29 -0400
Received: by mail-pd0-f180.google.com with SMTP id 10so3106569pdi.25
        for <netdev@vger.kernel.org>; Thu, 18 Jul 2013 07:19:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

In commit 48cc32d38a52d0b68f91a171a8d00531edc6a46e
("vlan: don't deliver frames for unknown vlans to protocols")
Florian made sure we set pkt_type to PACKET_OTHERHOST
if the vlan id is set and we could find a vlan device for this
particular id.

But we also have a problem if prio bits are set.

Steinar reported an issue on a router receiving IPv6 frames with a
vlan tag of 4000 (id 0, prio 2), and tunneled into a sit device,
because skb->vlan_tci is set.

Forwarded frame is completely corrupted : We can see (8100:4000)
being inserted in the middle of IPv6 source address :

16:48:00.780413 IP6 2001:16d8:8100:4000:ee1c:0:9d9:bc87 >
9f94:4d95:2001:67c:29f4::: ICMP6, unknown icmp6 type (0), length 64
       0x0000:  0000 0029 8000 c7c3 7103 0001 a0ae e651
       0x0010:  0000 0000 ccce 0b00 0000 0000 1011 1213
       0x0020:  1415 1617 1819 1a1b 1c1d 1e1f 2021 2223
       0x0030:  2425 2627 2829 2a2b 2c2d 2e2f 3031 3233

It seems we are not really ready to properly cope with this right now.

We can probably do better in future kernels : 
vlan_get_ingress_priority() should be a netdev property instead of
a per vlan_dev one.

For stable kernels, lets clear vlan_tci to fix the bugs.

Reported-by: Steinar H. Gunderson <sesse@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/if_vlan.h |    3 +--
 net/8021q/vlan_core.c   |    2 +-
 net/core/dev.c          |   11 +++++++++--
 3 files changed, 11 insertions(+), 5 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index cdcbafa..715c343 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -79,9 +79,8 @@ static inline int is_vlan_dev(struct net_device *dev)
 }
 
 #define vlan_tx_tag_present(__skb)	((__skb)->vlan_tci & VLAN_TAG_PRESENT)
-#define vlan_tx_nonzero_tag_present(__skb) \
-	(vlan_tx_tag_present(__skb) && ((__skb)->vlan_tci & VLAN_VID_MASK))
 #define vlan_tx_tag_get(__skb)		((__skb)->vlan_tci & ~VLAN_TAG_PRESENT)
+#define vlan_tx_tag_get_id(__skb)	((__skb)->vlan_tci & VLAN_VID_MASK)
 
 #if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
 
diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index 8a15eaa..4a78c4d 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -9,7 +9,7 @@ bool vlan_do_receive(struct sk_buff **skbp)
 {
 	struct sk_buff *skb = *skbp;
 	__be16 vlan_proto = skb->vlan_proto;
-	u16 vlan_id = skb->vlan_tci & VLAN_VID_MASK;
+	u16 vlan_id = vlan_tx_tag_get_id(skb);
 	struct net_device *vlan_dev;
 	struct vlan_pcpu_stats *rx_stats;
 
diff --git a/net/core/dev.c b/net/core/dev.c
index a3d8d44..26755dd 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3580,8 +3580,15 @@ ncls:
 		}
 	}
 
-	if (vlan_tx_nonzero_tag_present(skb))
-		skb->pkt_type = PACKET_OTHERHOST;
+	if (unlikely(vlan_tx_tag_present(skb))) {
+		if (vlan_tx_tag_get_id(skb))
+			skb->pkt_type = PACKET_OTHERHOST;
+		/* Note: we might in the future use prio bits
+		 * and set skb->priority like in vlan_do_receive()
+		 * For the time being, just ignore Priority Code Point
+		 */
+		skb->vlan_tci = 0;
+	}
 
 	/* deliver only exact match when indicated */
 	null_or_dev = deliver_exact ? skb->dev : NULL;
