From: Jason Wang <jasowang@redhat.com>
Subject: [net-next 3/5] packet: set transport header before doing xmit
Date: Tue, 26 Mar 2013 14:19:57 +0800
Message-ID: <1364278799-37285-4-git-send-email-jasowang@redhat.com>
References: <1364278799-37285-1-git-send-email-jasowang@redhat.com>
Cc: mst@redhat.com, Jason Wang <jasowang@redhat.com>,
	Eric Dumazet <edumazet@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1364278799-37285-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Set the transport header for 1) some drivers (e.g ixgbe needs l4 header to do
atr) 2) precise packet length estimation (introduced in 1def9238) needs l4
header to compute header length.

So this patch first tries to get l4 header for packet socket through
skb_flow_dissect(), and pretend no l4 header if skb_flow_dissect() fails.

Cc: Eric Dumazet <edumazet@google.com>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 net/packet/af_packet.c |   21 +++++++++++++++++++++
 1 files changed, 21 insertions(+), 0 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index bd0d14c..83fdd0a 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -88,6 +88,7 @@
 #include <linux/virtio_net.h>
 #include <linux/errqueue.h>
 #include <linux/net_tstamp.h>
+#include <net/flow_keys.h>
 
 #ifdef CONFIG_INET
 #include <net/inet_common.h>
@@ -1412,6 +1413,7 @@ static int packet_sendmsg_spkt(struct kiocb *iocb, struct socket *sock,
 	__be16 proto = 0;
 	int err;
 	int extra_len = 0;
+	struct flow_keys keys;
 
 	/*
 	 *	Get and verify the address.
@@ -1512,6 +1514,11 @@ retry:
 	if (unlikely(extra_len == 4))
 		skb->no_fcs = 1;
 
+	if (skb_flow_dissect(skb, &keys))
+		skb_set_transport_header(skb, keys.thoff);
+	else
+		skb_reset_transport_header(skb);
+
 	dev_queue_xmit(skb);
 	rcu_read_unlock();
 	return len;
@@ -1918,6 +1925,7 @@ static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
 	struct page *page;
 	void *data;
 	int err;
+	struct flow_keys keys;
 
 	ph.raw = frame;
 
@@ -1943,6 +1951,11 @@ static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
 	skb_reserve(skb, hlen);
 	skb_reset_network_header(skb);
 
+	if (skb_flow_dissect(skb, &keys))
+		skb_set_transport_header(skb, keys.thoff);
+	else
+		skb_reset_transport_header(skb);
+
 	if (po->tp_tx_has_off) {
 		int off_min, off_max, off;
 		off_min = po->tp_hdrlen - sizeof(struct sockaddr_ll);
@@ -2199,6 +2212,7 @@ static int packet_snd(struct socket *sock,
 	unsigned short gso_type = 0;
 	int hlen, tlen;
 	int extra_len = 0;
+	struct flow_keys keys;
 
 	/*
 	 *	Get and verify the address.
@@ -2351,6 +2365,13 @@ static int packet_snd(struct socket *sock,
 		len += vnet_hdr_len;
 	}
 
+	if (skb->ip_summed == CHECKSUM_PARTIAL)
+		skb_set_transport_header(skb, skb_checksum_start_offset(skb));
+	else if (skb_flow_dissect(skb, &keys))
+		skb_set_transport_header(skb, keys.thoff);
+	else
+		skb_set_transport_header(skb, reserve);
+
 	if (unlikely(extra_len == 4))
 		skb->no_fcs = 1;
 
-- 
1.7.1
