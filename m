From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH] Make virtio_net support carrier detection
Date: Sat, 14 Mar 2009 10:49:42 +1030
Message-ID: <200903141049.43202.rusty@rustcorp.com.au>
References: <20090312.055235.56926675.davem@davemloft.net> <200903131017.11572.rusty@rustcorp.com.au> <20090313.120100.266753164.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: pktoss@gmail.com, dcbw@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:48843 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754132AbZCNAT7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Mar 2009 20:19:59 -0400
In-Reply-To: <20090313.120100.266753164.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 14 March 2009 05:31:00 David Miller wrote:
> You can set netif_carrier_on() until you are blue in the face,
> but until you hook up the ethtool link indication operation
> NetworkManager won't see it.

Um, dude, you already have that patch in your net-next tree.  See below.
This one goes on top.

> I don't understand what all of this hob-knobbing is about,
> Pantelis's patch was perfect, appropriate, and should have
> gone straight in to net-2.6 and probably -stable too.
> 
> Is this some kind of control issue Rusty?  It's the only
> explanation I can come up with :-))

I don't think it was straightforward at all.  Current virtio_net "cards"
don't support carrier detection.  We reported that (correctly) to userspace,
like every other driver which doesn't support carrier detect.

So why is virtio_net different?  Or should all devices which can't detect
carrier set it to on, so older NetworkManagers work?

This may be obvious to you.  It's not to me.
Rusty.

commit 9f4d26d0f3016cf8813977d624751b94465fa317
Author: Mark McLoughlin <markmc@redhat.com>
Date:   Mon Jan 19 17:09:49 2009 -0800

    virtio_net: add link status handling
    
    Allow the host to inform us that the link is down by adding
    a VIRTIO_NET_F_STATUS which indicates that device status is
    available in virtio_net config.
    
    This is currently useful for simulating link down conditions
    (e.g. using proposed qemu 'set_link' monitor command) but
    would also be needed if we were to support device assignment
    via virtio.
    
    Signed-off-by: Mark McLoughlin <markmc@redhat.com>
    Signed-off-by: Rusty Russell <rusty@rustcorp.com.au> (added future masking)
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 30ae6d9..9b33d6e 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -42,6 +42,7 @@ struct virtnet_info
 	struct virtqueue *rvq, *svq;
 	struct net_device *dev;
 	struct napi_struct napi;
+	unsigned int status;
 
 	/* The skb we couldn't send because buffers were full. */
 	struct sk_buff *last_xmit_skb;
@@ -611,6 +612,7 @@ static struct ethtool_ops virtnet_ethtool_ops = {
 	.set_tx_csum = virtnet_set_tx_csum,
 	.set_sg = ethtool_op_set_sg,
 	.set_tso = ethtool_op_set_tso,
+	.get_link = ethtool_op_get_link,
 };
 
 #define MIN_MTU 68
@@ -636,6 +638,41 @@ static const struct net_device_ops virtnet_netdev = {
 #endif
 };
 
+static void virtnet_update_status(struct virtnet_info *vi)
+{
+	u16 v;
+
+	if (!virtio_has_feature(vi->vdev, VIRTIO_NET_F_STATUS))
+		return;
+
+	vi->vdev->config->get(vi->vdev,
+			      offsetof(struct virtio_net_config, status),
+			      &v, sizeof(v));
+
+	/* Ignore unknown (future) status bits */
+	v &= VIRTIO_NET_S_LINK_UP;
+
+	if (vi->status == v)
+		return;
+
+	vi->status = v;
+
+	if (vi->status & VIRTIO_NET_S_LINK_UP) {
+		netif_carrier_on(vi->dev);
+		netif_wake_queue(vi->dev);
+	} else {
+		netif_carrier_off(vi->dev);
+		netif_stop_queue(vi->dev);
+	}
+}
+
+static void virtnet_config_changed(struct virtio_device *vdev)
+{
+	struct virtnet_info *vi = vdev->priv;
+
+	virtnet_update_status(vi);
+}
+
 static int virtnet_probe(struct virtio_device *vdev)
 {
 	int err;
@@ -738,6 +775,9 @@ static int virtnet_probe(struct virtio_device *vdev)
 		goto unregister;
 	}
 
+	vi->status = VIRTIO_NET_S_LINK_UP;
+	virtnet_update_status(vi);
+
 	pr_debug("virtnet: registered device %s\n", dev->name);
 	return 0;
 
@@ -793,7 +833,7 @@ static unsigned int features[] = {
 	VIRTIO_NET_F_HOST_TSO4, VIRTIO_NET_F_HOST_UFO, VIRTIO_NET_F_HOST_TSO6,
 	VIRTIO_NET_F_HOST_ECN, VIRTIO_NET_F_GUEST_TSO4, VIRTIO_NET_F_GUEST_TSO6,
 	VIRTIO_NET_F_GUEST_ECN, /* We don't yet handle UFO input. */
-	VIRTIO_NET_F_MRG_RXBUF,
+	VIRTIO_NET_F_MRG_RXBUF, VIRTIO_NET_F_STATUS,
 	VIRTIO_F_NOTIFY_ON_EMPTY,
 };
 
@@ -805,6 +845,7 @@ static struct virtio_driver virtio_net = {
 	.id_table =	id_table,
 	.probe =	virtnet_probe,
 	.remove =	__devexit_p(virtnet_remove),
+	.config_changed = virtnet_config_changed,
 };
 
 static int __init init(void)
diff --git a/include/linux/virtio_net.h b/include/linux/virtio_net.h
index 5cdd0aa..f76bd4a 100644
--- a/include/linux/virtio_net.h
+++ b/include/linux/virtio_net.h
@@ -21,11 +21,16 @@
 #define VIRTIO_NET_F_HOST_ECN	13	/* Host can handle TSO[6] w/ ECN in. */
 #define VIRTIO_NET_F_HOST_UFO	14	/* Host can handle UFO in. */
 #define VIRTIO_NET_F_MRG_RXBUF	15	/* Host can merge receive buffers. */
+#define VIRTIO_NET_F_STATUS	16	/* virtio_net_config.status available */
+
+#define VIRTIO_NET_S_LINK_UP	1	/* Link is up */
 
 struct virtio_net_config
 {
 	/* The config defining mac address (if VIRTIO_NET_F_MAC) */
 	__u8 mac[6];
+	/* See VIRTIO_NET_F_STATUS and VIRTIO_NET_S_* above */
+	__u16 status;
 } __attribute__((packed));
 
 /* This is the first element of the scatter-gather list.  If you don't
