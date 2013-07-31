From: Phil Sutter <phil@nwl.cc>
Subject: [PATCH 2/3] af_packet: fix for sending VLAN frames via packet_mmap
Date: Wed, 31 Jul 2013 19:27:46 +0200
Message-ID: <1375291667-9572-3-git-send-email-phil@nwl.cc>
References: <20130729165357.GA23134@orbit.nwl.cc>
 <1375291667-9572-1-git-send-email-phil@nwl.cc>
 <1375291667-9572-2-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:35663 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752638Ab3GaR2S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Jul 2013 13:28:18 -0400
In-Reply-To: <1375291667-9572-2-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since tpacket_fill_skb() parses the protocol field in ethernet frames'
headers, it's easy to see if any passed frame is a VLAN one and account
for the extended size.

But as the real protocol does not turn up before tpacket_fill_skb()
runs which in turn also checks the frame length, move the max frame
length calculation into the function.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 net/packet/af_packet.c | 25 ++++++++++++++-----------
 1 file changed, 14 insertions(+), 11 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index e549e17..ce7b4f0 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1924,7 +1924,7 @@ static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
 		__be16 proto, unsigned char *addr, int hlen)
 {
 	union tpacket_uhdr ph;
-	int to_write, offset, len, tp_len, nr_frags, len_max;
+	int to_write, offset, len, tp_len, nr_frags, len_max, max_frame_len;
 	struct socket *sock = po->sk.sk_socket;
 	struct page *page;
 	void *data;
@@ -1947,10 +1947,6 @@ static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
 		tp_len = ph.h1->tp_len;
 		break;
 	}
-	if (unlikely(tp_len > size_max)) {
-		pr_err("packet size is too long (%d > %d)\n", tp_len, size_max);
-		return -EMSGSIZE;
-	}
 
 	skb_reserve(skb, hlen);
 	skb_reset_network_header(skb);
@@ -2013,6 +2009,18 @@ static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
 		to_write -= dev->hard_header_len;
 	}
 
+	max_frame_len = dev->mtu + dev->hard_header_len;
+	if (skb->protocol == htons(ETH_P_8021Q))
+		max_frame_len += VLAN_HLEN;
+
+	if (size_max > max_frame_len)
+		size_max = max_frame_len;
+
+	if (unlikely(tp_len > size_max)) {
+		pr_err("packet size is too long (%d > %d)\n", tp_len, size_max);
+		return -EMSGSIZE;
+	}
+
 	offset = offset_in_page(data);
 	len_max = PAGE_SIZE - offset;
 	len = ((to_write > len_max) ? len_max : to_write);
@@ -2051,7 +2059,7 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 	struct net_device *dev;
 	__be16 proto;
 	bool need_rls_dev = false;
-	int err, reserve = 0;
+	int err;
 	void *ph;
 	struct sockaddr_ll *saddr = (struct sockaddr_ll *)msg->msg_name;
 	int tp_len, size_max;
@@ -2084,8 +2092,6 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 	if (unlikely(dev == NULL))
 		goto out;
 
-	reserve = dev->hard_header_len;
-
 	err = -ENETDOWN;
 	if (unlikely(!(dev->flags & IFF_UP)))
 		goto out_put;
@@ -2093,9 +2099,6 @@ static int tpacket_snd(struct packet_sock *po, struct msghdr *msg)
 	size_max = po->tx_ring.frame_size
 		- (po->tp_hdrlen - sizeof(struct sockaddr_ll));
 
-	if (size_max > dev->mtu + reserve)
-		size_max = dev->mtu + reserve;
-
 	do {
 		ph = packet_current_frame(po, &po->tx_ring,
 				TP_STATUS_SEND_REQUEST);
-- 
1.8.1.5
