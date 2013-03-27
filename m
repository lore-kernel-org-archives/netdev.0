From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next 3/3] net: switch to use skb_probe_transport_header()
Date: Wed, 27 Mar 2013 17:11:22 +0800
Message-ID: <1364375482-7439-3-git-send-email-jasowang@redhat.com>
References: <1364375482-7439-1-git-send-email-jasowang@redhat.com>
Cc: mst@redhat.com, Jason Wang <jasowang@redhat.com>,
	Eric Dumazet <edumazet@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1364375482-7439-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Switch to use the new help skb_probe_transport_header() to do the l4 header
probing for untrusted sources. For packets with partial csum, the header should
already been set by skb_partial_csum_set().

Cc: Eric Dumazet <edumazet@google.com>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/macvtap.c             |    9 +--------
 drivers/net/tun.c                 |   10 +---------
 drivers/net/xen-netback/netback.c |   10 +---------
 net/packet/af_packet.c            |   22 +++-------------------
 4 files changed, 6 insertions(+), 45 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index acf6450..59e9605 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -21,7 +21,6 @@
 #include <net/rtnetlink.h>
 #include <net/sock.h>
 #include <linux/virtio_net.h>
-#include <net/flow_keys.h>
 
 /*
  * A macvtap queue is the central object of this driver, it connects
@@ -646,7 +645,6 @@ static ssize_t macvtap_get_user(struct macvtap_queue *q, struct msghdr *m,
 	int vnet_hdr_len = 0;
 	int copylen = 0;
 	bool zerocopy = false;
-	struct flow_keys keys;
 
 	if (q->flags & IFF_VNET_HDR) {
 		vnet_hdr_len = q->vnet_hdr_sz;
@@ -727,12 +725,7 @@ static ssize_t macvtap_get_user(struct macvtap_queue *q, struct msghdr *m,
 			goto err_kfree;
 	}
 
-	if (skb->ip_summed == CHECKSUM_PARTIAL)
-		skb_set_transport_header(skb, skb_checksum_start_offset(skb));
-	else if (skb_flow_dissect(skb, &keys))
-		skb_set_transport_header(skb, keys.thoff);
-	else
-		skb_set_transport_header(skb, ETH_HLEN);
+	skb_probe_transport_header(skb, ETH_HLEN);
 
 	rcu_read_lock_bh();
 	vlan = rcu_dereference_bh(q->vlan);
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 48cd73a..29538e6 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -70,7 +70,6 @@
 #include <net/sock.h>
 
 #include <asm/uaccess.h>
-#include <net/flow_keys.h>
 
 /* Uncomment to enable debugging */
 /* #define TUN_DEBUG 1 */
@@ -1050,7 +1049,6 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
 	bool zerocopy = false;
 	int err;
 	u32 rxhash;
-	struct flow_keys keys;
 
 	if (!(tun->flags & TUN_NO_PI)) {
 		if ((len -= sizeof(pi)) > total_len)
@@ -1205,13 +1203,7 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
 	}
 
 	skb_reset_network_header(skb);
-
-	if (skb->ip_summed == CHECKSUM_PARTIAL)
-		skb_set_transport_header(skb, skb_checksum_start_offset(skb));
-	else if (skb_flow_dissect(skb, &keys))
-		skb_set_transport_header(skb, keys.thoff);
-	else
-		skb_reset_transport_header(skb);
+	skb_probe_transport_header(skb, 0);
 
 	rxhash = skb_get_rxhash(skb);
 	netif_rx_ni(skb);
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index fc8faa7..83905a9 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -39,7 +39,6 @@
 #include <linux/udp.h>
 
 #include <net/tcp.h>
-#include <net/flow_keys.h>
 
 #include <xen/xen.h>
 #include <xen/events.h>
@@ -1506,14 +1505,7 @@ static void xen_netbk_tx_submit(struct xen_netbk *netbk)
 			continue;
 		}
 
-		if (!skb_transport_header_was_set(skb)) {
-			struct flow_keys keys;
-
-			if (skb_flow_dissect(skb, &keys))
-				skb_set_transport_header(skb, keys.thoff);
-			else
-				skb_reset_transport_header(skb);
-		}
+		skb_probe_transport_header(skb, 0);
 
 		vif->dev->stats.rx_bytes += skb->len;
 		vif->dev->stats.rx_packets++;
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 83fdd0a..8e4644f 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -88,7 +88,6 @@
 #include <linux/virtio_net.h>
 #include <linux/errqueue.h>
 #include <linux/net_tstamp.h>
-#include <net/flow_keys.h>
 
 #ifdef CONFIG_INET
 #include <net/inet_common.h>
@@ -1413,7 +1412,6 @@ static int packet_sendmsg_spkt(struct kiocb *iocb, struct socket *sock,
 	__be16 proto = 0;
 	int err;
 	int extra_len = 0;
-	struct flow_keys keys;
 
 	/*
 	 *	Get and verify the address.
@@ -1514,10 +1512,7 @@ retry:
 	if (unlikely(extra_len == 4))
 		skb->no_fcs = 1;
 
-	if (skb_flow_dissect(skb, &keys))
-		skb_set_transport_header(skb, keys.thoff);
-	else
-		skb_reset_transport_header(skb);
+	skb_probe_transport_header(skb, 0);
 
 	dev_queue_xmit(skb);
 	rcu_read_unlock();
@@ -1925,7 +1920,6 @@ static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
 	struct page *page;
 	void *data;
 	int err;
-	struct flow_keys keys;
 
 	ph.raw = frame;
 
@@ -1950,11 +1944,7 @@ static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
 
 	skb_reserve(skb, hlen);
 	skb_reset_network_header(skb);
-
-	if (skb_flow_dissect(skb, &keys))
-		skb_set_transport_header(skb, keys.thoff);
-	else
-		skb_reset_transport_header(skb);
+	skb_probe_transport_header(skb, 0);
 
 	if (po->tp_tx_has_off) {
 		int off_min, off_max, off;
@@ -2212,7 +2202,6 @@ static int packet_snd(struct socket *sock,
 	unsigned short gso_type = 0;
 	int hlen, tlen;
 	int extra_len = 0;
-	struct flow_keys keys;
 
 	/*
 	 *	Get and verify the address.
@@ -2365,12 +2354,7 @@ static int packet_snd(struct socket *sock,
 		len += vnet_hdr_len;
 	}
 
-	if (skb->ip_summed == CHECKSUM_PARTIAL)
-		skb_set_transport_header(skb, skb_checksum_start_offset(skb));
-	else if (skb_flow_dissect(skb, &keys))
-		skb_set_transport_header(skb, keys.thoff);
-	else
-		skb_set_transport_header(skb, reserve);
+	skb_probe_transport_header(skb, reserve);
 
 	if (unlikely(extra_len == 4))
 		skb->no_fcs = 1;
-- 
1.7.1
