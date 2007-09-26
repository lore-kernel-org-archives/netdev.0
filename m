From: rusty@rustcorp.com.au
Subject: [patch 33/43] lguest: Net driver using virtio
Date: Wed, 26 Sep 2007 16:36:51 +1000
Message-ID: <20070926063651.074168499@rustcorp.com.au>
References: <20070926063618.956228976@rustcorp.com.au>
Cc: virtualization@lists.linux-foundation.org,
	Christian Borntraeger <borntraeger@de.ibm.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: lguest@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:44275 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751416AbXIZG5L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Sep 2007 02:57:11 -0400
Content-Disposition: inline; filename=new-io-net.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The network driver uses two virtqueues: one for input packets and one
for output packets.  This has nice locking properties (ie. we don't do
any for recv vs send).

TODO:
	1) Big packets.
	2) Multi-client devices (maybe separate driver?).
	3) Resolve freeing of old xmit skbs (Christian Borntraeger)

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
Cc: Christian Borntraeger <borntraeger@de.ibm.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: netdev@vger.kernel.org
---
 drivers/net/Kconfig        |    6 
 drivers/net/Makefile       |    2 
 drivers/net/virtio_net.c   |  438 ++++++++++++++++++++++++++++++++++++++++++++
 include/linux/virtio_net.h |   36 +++
 4 files changed, 481 insertions(+), 1 deletion(-)

===================================================================
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2998,4 +2998,10 @@ config NET_POLL_CONTROLLER
 config NET_POLL_CONTROLLER
 	def_bool NETPOLL
 
+config VIRTIO_NET
+	tristate "Virtio network driver (EXPERIMENTAL)"
+	depends on EXPERIMENTAL && VIRTIO
+	---help---
+	  This is the virtual network driver for lguest.  Say Y or M.
+
 endif # NETDEVICES
===================================================================
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -38,7 +38,7 @@ obj-$(CONFIG_SUNVNET) += sunvnet.o
 
 obj-$(CONFIG_MACE) += mace.o
 obj-$(CONFIG_BMAC) += bmac.o
-
+obj-$(CONFIG_VIRTIO_NET) += virtio_net.o
 obj-$(CONFIG_DGRS) += dgrs.o
 obj-$(CONFIG_VORTEX) += 3c59x.o
 obj-$(CONFIG_TYPHOON) += typhoon.o
===================================================================
--- /dev/null
+++ b/drivers/net/virtio_net.c
@@ -0,0 +1,438 @@
+/* A simple network driver using virtio.
+ *
+ * Copyright 2007 Rusty Russell <rusty@rustcorp.com.au> IBM Corporation
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+//#define DEBUG
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/module.h>
+#include <linux/virtio.h>
+#include <linux/virtio_net.h>
+#include <linux/scatterlist.h>
+
+/* FIXME: MTU in config. */
+#define MAX_PACKET_LEN (ETH_HLEN+ETH_DATA_LEN)
+
+struct virtnet_info
+{
+	struct virtio_device *vdev;
+	struct virtqueue *rvq, *svq;
+	struct net_device *dev;
+
+	/* Number of input buffers, and max we've ever had. */
+	unsigned int num, max;
+
+	/* Receive & send queues. */
+	struct sk_buff_head recv;
+	struct sk_buff_head send;
+};
+
+static inline struct virtio_net_hdr *skb_vnet_hdr(struct sk_buff *skb)
+{
+	return (struct virtio_net_hdr *)skb->cb;
+}
+
+static inline void vnet_hdr_to_sg(struct scatterlist *sg, struct sk_buff *skb)
+{
+	sg_init_one(sg, skb_vnet_hdr(skb), sizeof(struct virtio_net_hdr));
+}
+
+static bool skb_xmit_done(struct virtqueue *rvq)
+{
+	struct virtnet_info *vi = rvq->vdev->priv;
+
+	/* In case we were waiting for output buffers. */
+	netif_wake_queue(vi->dev);
+	return true;
+}
+
+static void receive_skb(struct net_device *dev, struct sk_buff *skb,
+			unsigned len)
+{
+	struct virtio_net_hdr *hdr = skb_vnet_hdr(skb);
+
+	if (unlikely(len < sizeof(struct virtio_net_hdr) + ETH_HLEN)) {
+		pr_debug("%s: short packet %i\n", dev->name, len);
+		dev->stats.rx_length_errors++;
+		goto drop;
+	}
+	len -= sizeof(struct virtio_net_hdr);
+	BUG_ON(len > MAX_PACKET_LEN);
+
+	skb_trim(skb, len);
+	skb->protocol = eth_type_trans(skb, dev);
+	pr_debug("Receiving skb proto 0x%04x len %i type %i\n",
+		 ntohs(skb->protocol), skb->len, skb->pkt_type);
+	dev->stats.rx_bytes += skb->len;
+	dev->stats.rx_packets++;
+
+	if (hdr->flags & VIRTIO_NET_HDR_F_NEEDS_CSUM) {
+		pr_debug("Needs csum!\n");
+		skb->ip_summed = CHECKSUM_PARTIAL;
+		skb->csum_start = hdr->csum_start;
+		skb->csum_offset = hdr->csum_offset;
+		if (skb->csum_start > skb->len - 2
+		    || skb->csum_offset > skb->len - 2) {
+			if (net_ratelimit())
+				printk(KERN_WARNING "%s: csum=%u/%u len=%u\n",
+				       dev->name, skb->csum_start,
+				       skb->csum_offset, skb->len);
+			goto frame_err;
+		}
+	}
+
+	if (hdr->gso_type != VIRTIO_NET_HDR_GSO_NONE) {
+		pr_debug("GSO!\n");
+		switch (hdr->gso_type) {
+		case VIRTIO_NET_HDR_GSO_TCPV4:
+			skb_shinfo(skb)->gso_type = SKB_GSO_TCPV4;
+			break;
+		case VIRTIO_NET_HDR_GSO_TCPV4_ECN:
+			skb_shinfo(skb)->gso_type = SKB_GSO_TCP_ECN;
+			break;
+		case VIRTIO_NET_HDR_GSO_UDP:
+			skb_shinfo(skb)->gso_type = SKB_GSO_UDP;
+			break;
+		case VIRTIO_NET_HDR_GSO_TCPV6:
+			skb_shinfo(skb)->gso_type = SKB_GSO_TCPV6;
+			break;
+		default:
+			if (net_ratelimit())
+				printk(KERN_WARNING "%s: bad gso type %u.\n",
+				       dev->name, hdr->gso_type);
+			goto frame_err;
+		}
+
+		skb_shinfo(skb)->gso_size = hdr->gso_size;
+		if (skb_shinfo(skb)->gso_size == 0) {
+			if (net_ratelimit())
+				printk(KERN_WARNING "%s: zero gso size.\n",
+				       dev->name);
+			goto frame_err;
+		}
+
+		/* Header must be checked, and gso_segs computed. */
+		skb_shinfo(skb)->gso_type |= SKB_GSO_DODGY;
+		skb_shinfo(skb)->gso_segs = 0;
+	}
+
+	netif_receive_skb(skb);
+	return;
+
+frame_err:
+	dev->stats.rx_frame_errors++;
+drop:
+	dev_kfree_skb(skb);
+}
+
+static void try_fill_recv(struct virtnet_info *vi)
+{
+	struct sk_buff *skb;
+	struct scatterlist sg[1+MAX_SKB_FRAGS];
+	int num, err;
+
+	for (;;) {
+		skb = netdev_alloc_skb(vi->dev, MAX_PACKET_LEN);
+		if (unlikely(!skb))
+			break;
+
+		skb_put(skb, MAX_PACKET_LEN);
+		vnet_hdr_to_sg(sg, skb);
+		num = skb_to_sgvec(skb, sg+1, 0, skb->len) + 1;
+		skb_queue_head(&vi->recv, skb);
+
+		err = vi->rvq->vq_ops->add_buf(vi->rvq, sg, 0, num, skb);
+		if (err) {
+			skb_unlink(skb, &vi->recv);
+			kfree_skb(skb);
+			break;
+		}
+		vi->num++;
+	}
+	if (unlikely(vi->num > vi->max))
+		vi->max = vi->num;
+	vi->rvq->vq_ops->kick(vi->rvq);
+}
+
+static bool skb_recv_done(struct virtqueue *rvq)
+{
+	struct virtnet_info *vi = rvq->vdev->priv;
+	netif_rx_schedule(vi->dev);
+	/* Suppress further interrupts. */
+	return false;
+}
+
+static int virtnet_poll(struct net_device *dev, int *budget)
+{
+	struct virtnet_info *vi = netdev_priv(dev);
+	struct sk_buff *skb = NULL;
+	unsigned int len, received = 0;
+
+again:
+	while (received < dev->quota &&
+	       (skb = vi->rvq->vq_ops->get_buf(vi->rvq, &len)) != NULL) {
+		__skb_unlink(skb, &vi->recv);
+		receive_skb(vi->dev, skb, len);
+		vi->num--;
+		received++;
+	}
+
+        dev->quota -= received;
+        *budget -= received;
+
+	/* FIXME: If we oom and completely run out of inbufs, we need
+	 * to start a timer trying to fill more. */
+	if (vi->num < vi->max / 2)
+		try_fill_recv(vi);
+
+	/* Still more work to do? */
+	if (skb)
+		return 1; /* not done */
+
+	netif_rx_complete(dev);
+	if (unlikely(!vi->rvq->vq_ops->restart(vi->rvq))
+	    && netif_rx_reschedule(dev, received))
+		goto again;
+
+	return 0;
+}
+
+static void free_old_xmit_skbs(struct virtnet_info *vi)
+{
+	struct sk_buff *skb;
+	unsigned int len;
+
+	while ((skb = vi->svq->vq_ops->get_buf(vi->svq, &len)) != NULL) {
+		pr_debug("Sent skb %p\n", skb);
+		__skb_unlink(skb, &vi->send);
+		vi->dev->stats.tx_bytes += len;
+		vi->dev->stats.tx_packets++;
+		kfree_skb(skb);
+	}
+}
+
+static int start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct virtnet_info *vi = netdev_priv(dev);
+	int num, err;
+	struct scatterlist sg[1+MAX_SKB_FRAGS];
+	struct virtio_net_hdr *hdr;
+	const unsigned char *dest = ((struct ethhdr *)skb->data)->h_dest;
+
+	pr_debug("%s: xmit %p %02x:%02x:%02x:%02x:%02x:%02x\n",
+		 dev->name, skb,
+		 dest[0], dest[1], dest[2], dest[3], dest[4], dest[5]);
+
+	free_old_xmit_skbs(vi);
+
+	/* Encode metadata header at front. */
+	hdr = skb_vnet_hdr(skb);
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
+		hdr->flags = VIRTIO_NET_HDR_F_NEEDS_CSUM;
+		hdr->csum_start = skb->csum_start - skb_headroom(skb);
+		hdr->csum_offset = skb->csum_offset;
+	} else {
+		hdr->flags = 0;
+		hdr->csum_offset = hdr->csum_start = 0;
+	}
+
+	if (skb_is_gso(skb)) {
+		hdr->gso_size = skb_shinfo(skb)->gso_size;
+		if (skb_shinfo(skb)->gso_type & SKB_GSO_TCP_ECN)
+			hdr->gso_type = VIRTIO_NET_HDR_GSO_TCPV4_ECN;
+		else if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV4)
+			hdr->gso_type = VIRTIO_NET_HDR_GSO_TCPV4;
+		else if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6)
+			hdr->gso_type = VIRTIO_NET_HDR_GSO_TCPV6;
+		else if (skb_shinfo(skb)->gso_type & SKB_GSO_UDP)
+			hdr->gso_type = VIRTIO_NET_HDR_GSO_UDP;
+		else
+			BUG();
+	} else {
+		hdr->gso_type = VIRTIO_NET_HDR_GSO_NONE;
+		hdr->gso_size = 0;
+	}
+
+	vnet_hdr_to_sg(sg, skb);
+	num = skb_to_sgvec(skb, sg+1, 0, skb->len) + 1;
+	__skb_queue_head(&vi->send, skb);
+	err = vi->svq->vq_ops->add_buf(vi->svq, sg, num, 0, skb);
+	if (err) {
+		pr_debug("%s: virtio not prepared to send\n", dev->name);
+		skb_unlink(skb, &vi->send);
+		netif_stop_queue(dev);
+		return NETDEV_TX_BUSY;
+	}
+	vi->svq->vq_ops->kick(vi->svq);
+
+	return 0;
+}
+
+static int virtnet_open(struct net_device *dev)
+{
+	struct virtnet_info *vi = netdev_priv(dev);
+
+	try_fill_recv(vi);
+
+	/* If we didn't even get one input buffer, we're useless. */
+	if (vi->num == 0)
+		return -ENOMEM;
+
+	return 0;
+}
+
+static int virtnet_close(struct net_device *dev)
+{
+	struct virtnet_info *vi = netdev_priv(dev);
+	struct sk_buff *skb;
+
+	/* networking core has neutered skb_xmit_done/skb_recv_done, so don't
+	 * worry about races vs. get(). */
+	vi->rvq->vq_ops->shutdown(vi->rvq);
+	while ((skb = __skb_dequeue(&vi->recv)) != NULL) {
+		kfree_skb(skb);
+		vi->num--;
+	}
+	vi->svq->vq_ops->shutdown(vi->svq);
+	while ((skb = __skb_dequeue(&vi->send)) != NULL)
+		kfree_skb(skb);
+
+	BUG_ON(vi->num != 0);
+	return 0;
+}
+
+static int virtnet_probe(struct virtio_device *vdev)
+{
+	int err;
+	unsigned int len;
+	struct net_device *dev;
+	struct virtnet_info *vi;
+	void *token;
+
+	/* Allocate ourselves a network device with room for our info */
+	dev = alloc_etherdev(sizeof(struct virtnet_info));
+	if (!dev)
+		return -ENOMEM;
+
+	/* Set up network device as normal. */
+	SET_MODULE_OWNER(dev);
+	ether_setup(dev);
+	dev->open = virtnet_open;
+	dev->stop = virtnet_close;
+	dev->poll = virtnet_poll;
+	dev->hard_start_xmit = start_xmit;
+	dev->weight = 16;
+	dev->features = NETIF_F_HIGHDMA;
+	SET_NETDEV_DEV(dev, &vdev->dev);
+
+	/* Do we support "hardware" checksums? */
+	token = vdev->config->find(vdev, VIRTIO_CONFIG_NET_F, &len);
+	if (virtio_use_bit(vdev, token, len, VIRTIO_NET_F_NO_CSUM)) {
+		/* This opens up the world of extra features. */
+		dev->features |= NETIF_F_HW_CSUM|NETIF_F_SG|NETIF_F_FRAGLIST;
+		if (virtio_use_bit(vdev, token, len, VIRTIO_NET_F_TSO4))
+			dev->features |= NETIF_F_TSO;
+		if (virtio_use_bit(vdev, token, len, VIRTIO_NET_F_UFO))
+			dev->features |= NETIF_F_UFO;
+		if (virtio_use_bit(vdev, token, len, VIRTIO_NET_F_TSO4_ECN))
+			dev->features |= NETIF_F_TSO_ECN;
+		if (virtio_use_bit(vdev, token, len, VIRTIO_NET_F_TSO6))
+			dev->features |= NETIF_F_TSO6;
+	}
+
+	/* Configuration may specify what MAC to use.  Otherwise random. */
+	token = vdev->config->find(vdev, VIRTIO_CONFIG_NET_MAC_F, &len);
+	if (token) {
+		dev->addr_len = len;
+		vdev->config->get(vdev, token, dev->dev_addr, len);
+	} else
+		random_ether_addr(dev->dev_addr);
+
+	/* Set up our device-specific information */
+	vi = netdev_priv(dev);
+	vi->dev = dev;
+	vi->vdev = vdev;
+
+	/* We expect two virtqueues, receive then send. */
+	vi->rvq = vdev->config->find_vq(vdev, skb_recv_done);
+	if (IS_ERR(vi->rvq)) {
+		err = PTR_ERR(vi->rvq);
+		goto free;
+	}
+
+	vi->svq = vdev->config->find_vq(vdev, skb_xmit_done);
+	if (IS_ERR(vi->svq)) {
+		err = PTR_ERR(vi->svq);
+		goto free_recv;
+	}
+
+	/* Initialize our empty receive and send queues. */
+	skb_queue_head_init(&vi->recv);
+	skb_queue_head_init(&vi->send);
+
+	err = register_netdev(dev);
+	if (err) {
+		pr_debug("virtio_net: registering device failed\n");
+		goto free_send;
+	}
+	pr_debug("virtnet: registered device %s\n", dev->name);
+	vdev->priv = vi;
+	return 0;
+
+free_send:
+	vdev->config->del_vq(vi->svq);
+free_recv:
+	vdev->config->del_vq(vi->rvq);
+free:
+	free_netdev(dev);
+	return err;
+}
+
+static void virtnet_remove(struct virtio_device *vdev)
+{
+	unregister_netdev(vdev->priv);
+	free_netdev(vdev->priv);
+}
+
+static struct virtio_device_id id_table[] = {
+	{ VIRTIO_ID_NET, VIRTIO_DEV_ANY_ID },
+	{ 0 },
+};
+
+static struct virtio_driver virtio_net = {
+	.driver.name =	KBUILD_MODNAME,
+	.driver.owner =	THIS_MODULE,
+	.id_table =	id_table,
+	.probe =	virtnet_probe,
+	.remove =	__devexit_p(virtnet_remove),
+};
+
+static int __init init(void)
+{
+	return register_virtio_driver(&virtio_net);
+}
+
+static void __exit fini(void)
+{
+	unregister_virtio_driver(&virtio_net);
+}
+module_init(init);
+module_exit(fini);
+
+MODULE_DEVICE_TABLE(virtio, id_table);
+MODULE_DESCRIPTION("Virtio network driver");
+MODULE_LICENSE("GPL");
===================================================================
--- /dev/null
+++ b/include/linux/virtio_net.h
@@ -0,0 +1,36 @@
+#ifndef _LINUX_VIRTIO_NET_H
+#define _LINUX_VIRTIO_NET_H
+#include <linux/virtio_config.h>
+
+/* The ID for virtio_net */
+#define VIRTIO_ID_NET	1
+
+/* The bitmap of config for virtio net */
+#define VIRTIO_CONFIG_NET_F	0x40
+#define VIRTIO_NET_F_NO_CSUM	0
+#define VIRTIO_NET_F_TSO4	1
+#define VIRTIO_NET_F_UFO	2
+#define VIRTIO_NET_F_TSO4_ECN	3
+#define VIRTIO_NET_F_TSO6	4
+
+/* The config defining mac address. */
+#define VIRTIO_CONFIG_NET_MAC_F	0x41
+
+/* This is the first element of the scatter-gather list.  If you don't
+ * specify GSO or CSUM features, you can simply ignore the header. */
+struct virtio_net_hdr
+{
+#define VIRTIO_NET_HDR_F_NEEDS_CSUM	1	// Use csum_start, csum_offset
+      __u8 flags;
+#define VIRTIO_NET_HDR_GSO_NONE		0	// Not a GSO frame
+#define VIRTIO_NET_HDR_GSO_TCPV4	1	// GSO frame, IPv4 TCP (TSO)
+/* FIXME: Do we need this?  If they said they can handle ECN, do they care? */
+#define VIRTIO_NET_HDR_GSO_TCPV4_ECN	2	// GSO frame, IPv4 TCP w/ ECN
+#define VIRTIO_NET_HDR_GSO_UDP		3	// GSO frame, IPv4 UDP (UFO)
+#define VIRTIO_NET_HDR_GSO_TCPV6	4	// GSO frame, IPv6 TCP
+      __u8 gso_type;
+      __u16 gso_size;
+      __u16 csum_start;
+      __u16 csum_offset;
+};
+#endif /* _LINUX_VIRTIO_NET_H */

--
   there are those who do and those who hang on and you don't see too
   many doers quoting their contemporaries.  -- Larry McVoy

