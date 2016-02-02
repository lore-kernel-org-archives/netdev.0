From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net-next 2/4] packet: vnet_hdr support for tpacket_rcv
Date: Tue,  2 Feb 2016 10:56:47 -0500
Message-ID: <1454428609-26885-3-git-send-email-willemdebruijn.kernel@gmail.com>
References: <1454428609-26885-1-git-send-email-willemdebruijn.kernel@gmail.com>
Cc: davem@davemloft.net, daniel@iogearbox.net, mst@redhat.com,
	sri@us.ibm.com, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f67.google.com ([209.85.192.67]:36275 "EHLO
	mail-qg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933093AbcBBP4z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 10:56:55 -0500
Received: by mail-qg0-f67.google.com with SMTP id u30so1067309qge.3
        for <netdev@vger.kernel.org>; Tue, 02 Feb 2016 07:56:55 -0800 (PST)
In-Reply-To: <1454428609-26885-1-git-send-email-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Support socket option PACKET_VNET_HDR together with PACKET_RX_RING.
When enabled, a struct virtio_net_hdr will precede the data in the
packet ring slots.

Verified with test program at
github.com/wdebruij/kerneltools/blob/master/tests/psock_rxring_vnet.c

  pkt: 1454269209.798420 len=5066
  vnet: gso_type=tcpv4 gso_size=1448 hlen=66 ecn=off
  csum: start=34 off=16
  eth: proto=0x800
  ip: src=<masked> dst=<masked> proto=6 len=5052

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 net/packet/af_packet.c | 19 +++++++++++++++----
 1 file changed, 15 insertions(+), 4 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index bd3de7b..b26df32 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -2206,7 +2206,9 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev,
 		unsigned int maclen = skb_network_offset(skb);
 		netoff = TPACKET_ALIGN(po->tp_hdrlen +
 				       (maclen < 16 ? 16 : maclen)) +
-			po->tp_reserve;
+				       po->tp_reserve;
+		if (po->has_vnet_hdr)
+			netoff += sizeof(struct virtio_net_hdr);
 		macoff = netoff - maclen;
 	}
 	if (po->tp_version <= TPACKET_V2) {
@@ -2243,7 +2245,7 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev,
 	h.raw = packet_current_rx_frame(po, skb,
 					TP_STATUS_KERNEL, (macoff+snaplen));
 	if (!h.raw)
-		goto ring_is_full;
+		goto drop_n_account;
 	if (po->tp_version <= TPACKET_V2) {
 		packet_increment_rx_head(po, &po->rx_ring);
 	/*
@@ -2262,6 +2264,14 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev,
 	}
 	spin_unlock(&sk->sk_receive_queue.lock);
 
+	if (po->has_vnet_hdr) {
+		if (__packet_rcv_vnet(skb, h.raw + macoff -
+					   sizeof(struct virtio_net_hdr))) {
+			spin_lock(&sk->sk_receive_queue.lock);
+			goto drop_n_account;
+		}
+	}
+
 	skb_copy_bits(skb, 0, h.raw + macoff, snaplen);
 
 	if (!(ts_status = tpacket_get_timestamp(skb, &ts, po->tp_tstamp)))
@@ -2357,7 +2367,7 @@ drop:
 	kfree_skb(skb);
 	return 0;
 
-ring_is_full:
+drop_n_account:
 	po->stats.stats1.tp_drops++;
 	spin_unlock(&sk->sk_receive_queue.lock);
 
@@ -3587,7 +3597,8 @@ packet_setsockopt(struct socket *sock, int level, int optname, char __user *optv
 		}
 		if (optlen < len)
 			return -EINVAL;
-		if (pkt_sk(sk)->has_vnet_hdr)
+		if (pkt_sk(sk)->has_vnet_hdr &&
+		    optname == PACKET_TX_RING)
 			return -EINVAL;
 		if (copy_from_user(&req_u.req, optval, len))
 			return -EFAULT;
-- 
2.7.0.rc3.207.g0ac5344
