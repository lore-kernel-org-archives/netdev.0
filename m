From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: Tree for Aug 7
Date: Wed, 07 Aug 2013 17:13:26 -0700 (PDT)
Message-ID: <20130807.171326.61869230969773998.davem@davemloft.net>
References: <20130807.163621.84433966934449459.davem@davemloft.net>
	<CA+icZUUm2nbmVj_WRznPTjXL0y6pcr1GzLjsL7UMhSGQWSm==g@mail.gmail.com>
	<20130807.170926.319558320779361738.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: phil@nwl.cc, eric.dumazet@gmail.com, johannes@sipsolutions.net,
	sfr@canb.auug.org.au, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	hannes@stressinduktion.org, linux-wireless@vger.kernel.org,
	linville@tuxdriver.com
To: sedat.dilek@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130807.170926.319558320779361738.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Wed, 07 Aug 2013 17:09:26 -0700 (PDT)

> Ok, I'm going to simply revert all of these changes, thanks for testing.

Here is what I just pushed to net-next:

====================
>From 09effa67a18d893fc4e6f81a3659fc9efef1445e Mon Sep 17 00:00:00 2001
From: "David S. Miller" <davem@davemloft.net>
Date: Wed, 7 Aug 2013 17:11:00 -0700
Subject: [PATCH] packet: Revert recent header parsing changes.

This reverts commits:

0f75b09c798ed00c30d7d5551b896be883bc2aeb
cbd89acb9eb257ed3b2be867142583fdcf7fdc5b
c483e02614551e44ced3fe6eedda8e36d3277ccc

Amongst other things, it's modifies the SKB header
to pull the ethernet headers off via eth_type_trans()
on the output path which is bogus.

It's causing serious regressions for people.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/packet/af_packet.c |   53 ++++++++++++++++++++++--------------------------
 1 file changed, 24 insertions(+), 29 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 0c0f6c9..4cb28a7 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -88,7 +88,6 @@
 #include <linux/virtio_net.h>
 #include <linux/errqueue.h>
 #include <linux/net_tstamp.h>
-#include <linux/if_arp.h>
 
 #ifdef CONFIG_INET
 #include <net/inet_common.h>
@@ -1924,7 +1923,7 @@ static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
 		__be16 proto, unsigned char *addr, int hlen)
 {
 	union tpacket_uhdr ph;
-	int to_write, offset, len, tp_len, nr_frags, len_max, max_frame_len;
+	int to_write, offset, len, tp_len, nr_frags, len_max;
 	struct socket *sock = po->sk.sk_socket;
 	struct page *page;
 	void *data;
@@ -1947,6 +1946,10 @@ static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
 		tp_len = ph.h1->tp_len;
 		break;
 	}
+	if (unlikely(tp_len > size_max)) {
+		pr_err("packet size is too long (%d > %d)\n", tp_len, size_max);
+		return -EMSGSIZE;
+	}
 
 	skb_reserve(skb, hlen);
 	skb_reset_network_header(skb);
@@ -2002,25 +2005,10 @@ static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
 		if (unlikely(err))
 			return err;
 
-		if (dev->type == ARPHRD_ETHER)
-			skb->protocol = eth_type_trans(skb, dev);
-
 		data += dev->hard_header_len;
 		to_write -= dev->hard_header_len;
 	}
 
-	max_frame_len = dev->mtu + dev->hard_header_len;
-	if (skb->protocol == htons(ETH_P_8021Q))
-		max_frame_len += VLAN_HLEN;
-
-	if (size_max > max_frame_len)
-		size_max = max_frame_len;
-
-	if (unlikely(tp_len > size_max)) {
-		pr_err("packet size is too long (%d > %d)\n", tp_len, size_max);
-		return -EMSGSIZE;
-	}
-
 	offset = offset_in_page(data);
 	len_max = PAGE_SIZE - offset;
 	len = ((to_write > len_max) ? len_max : to_write);
@@ -2059,7 +2047,7 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 	struct net_device *dev;
 	__be16 proto;
 	bool need_rls_dev = false;
-	int err;
+	int err, reserve = 0;
 	void *ph;
 	struct sockaddr_ll *saddr = (struct sockaddr_ll *)msg->msg_name;
 	int tp_len, size_max;
@@ -2092,6 +2080,8 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 	if (unlikely(dev == NULL))
 		goto out;
 
+	reserve = dev->hard_header_len;
+
 	err = -ENETDOWN;
 	if (unlikely(!(dev->flags & IFF_UP)))
 		goto out_put;
@@ -2099,6 +2089,9 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 	size_max = po->tx_ring.frame_size
 		- (po->tp_hdrlen - sizeof(struct sockaddr_ll));
 
+	if (size_max > dev->mtu + reserve)
+		size_max = dev->mtu + reserve;
+
 	do {
 		ph = packet_current_frame(po, &po->tx_ring,
 				TP_STATUS_SEND_REQUEST);
@@ -2331,20 +2324,22 @@ static int packet_snd(struct socket *sock,
 
 	sock_tx_timestamp(sk, &skb_shinfo(skb)->tx_flags);
 
-	if (dev->type == ARPHRD_ETHER) {
-		skb->protocol = eth_type_trans(skb, dev);
-		if (skb->protocol == htons(ETH_P_8021Q))
-			reserve += VLAN_HLEN;
-	} else {
-		skb->protocol = proto;
-		skb->dev = dev;
-	}
-
 	if (!gso_type && (len > dev->mtu + reserve + extra_len)) {
-		err = -EMSGSIZE;
-		goto out_free;
+		/* Earlier code assumed this would be a VLAN pkt,
+		 * double-check this now that we have the actual
+		 * packet in hand.
+		 */
+		struct ethhdr *ehdr;
+		skb_reset_mac_header(skb);
+		ehdr = eth_hdr(skb);
+		if (ehdr->h_proto != htons(ETH_P_8021Q)) {
+			err = -EMSGSIZE;
+			goto out_free;
+		}
 	}
 
+	skb->protocol = proto;
+	skb->dev = dev;
 	skb->priority = sk->sk_priority;
 	skb->mark = sk->sk_mark;
 
-- 
1.7.10.4
