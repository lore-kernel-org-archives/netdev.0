From: Mark McLoughlin <markmc@redhat.com>
Subject: Re: [PATCH] virtio_net: add link status handling
Date: Wed, 10 Dec 2008 18:34:44 +0000
Message-ID: <1228934084.5384.66.camel@blaa>
References: <1228817973.26198.1.camel@blaa> <493EE3DE.7080702@codemonkey.ws>
	 <200812101023.42365.rusty@rustcorp.com.au> <493F336B.5010402@codemonkey.ws>
Reply-To: Mark McLoughlin <markmc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	netdev <netdev@vger.kernel.org>, kvm <kvm@vger.kernel.org>
To: Anthony Liguori <anthony@codemonkey.ws>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:33123 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758120AbYLJSgP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Dec 2008 13:36:15 -0500
In-Reply-To: <493F336B.5010402@codemonkey.ws>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-12-09 at 21:11 -0600, Anthony Liguori wrote:
> Rusty Russell wrote:
> > On Wednesday 10 December 2008 08:02:14 Anthony Liguori wrote:
> >   
> >> Mark McLoughlin wrote:
> >>     
> >>> Allow the host to inform us that the link is down by adding
> >>> a VIRTIO_NET_F_STATUS which indicates that device status is
> >>> available in virtio_net config.
> >>>
> >>> This is currently useful for simulating link down conditions
> >>> (e.g. using proposed qemu 'set_link' monitor command) but
> >>> would also be needed if we were to support device assignment
> >>> via virtio.
> >>>       
> >> It would be nice if the virtio-net card wrote some acknowledgement that 
> >> it has received the link status down/up events.
> >>     
> >
> > How about of every status change event? ie. a generic virtio_pci solution?
> >   
> 
> A really simple way to do it would just be to have another status field 
> that was the guest's status (verses the host requested status which the 
> current field is).  All config reads/writes result in exits so it's easy 
> to track.
> 
> Adding YA virtio event may be a little overkill.

Sounds very reasonable; that and Rusty's "mask out unknown bits"
suggestion in the version below.

Cheers,
Mark.

From: Mark McLoughlin <markmc@redhat.com>
Subject: [PATCH] virtio_net: add link status handling

Allow the host to inform us that the link is down by adding
a VIRTIO_NET_F_STATUS which indicates that device status is
available in virtio_net config.

This is currently useful for simulating link down conditions
(e.g. using proposed qemu 'set_link' monitor command) but
would also be needed if we were to support device assignment
via virtio.

Signed-off-by: Mark McLoughlin <markmc@redhat.com>
---
 drivers/net/virtio_net.c   |   49 +++++++++++++++++++++++++++++++++++++++++++-
 include/linux/virtio_net.h |    8 +++++++
 2 files changed, 56 insertions(+), 1 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 71ca29c..40f02a1 100644
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
@@ -624,6 +626,47 @@ static int virtnet_change_mtu(struct net_device *dev, int new_mtu)
 	return 0;
 }
 
+static void virtnet_update_status(struct virtnet_info *vi)
+{
+	u16 v;
+
+	if (!virtio_has_feature(vi->vdev, VIRTIO_NET_F_STATUS))
+		return;
+
+        vi->vdev->config->get(vi->vdev,
+                              offsetof(struct virtio_net_config, status),
+                              &v, sizeof(v));
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
+
+	/* acknowledge the status change */
+        vi->vdev->config->set(vi->vdev,
+                              offsetof(struct virtio_net_config, status_ack),
+                              &vi->status, sizeof(vi->status));
+
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
@@ -732,6 +775,9 @@ static int virtnet_probe(struct virtio_device *vdev)
 		goto unregister;
 	}
 
+	vi->status = VIRTIO_NET_S_LINK_UP;
+	virtnet_update_status(vi);
+
 	pr_debug("virtnet: registered device %s\n", dev->name);
 	return 0;
 
@@ -787,7 +833,7 @@ static unsigned int features[] = {
 	VIRTIO_NET_F_HOST_TSO4, VIRTIO_NET_F_HOST_UFO, VIRTIO_NET_F_HOST_TSO6,
 	VIRTIO_NET_F_HOST_ECN, VIRTIO_NET_F_GUEST_TSO4, VIRTIO_NET_F_GUEST_TSO6,
 	VIRTIO_NET_F_GUEST_ECN, /* We don't yet handle UFO input. */
-	VIRTIO_NET_F_MRG_RXBUF,
+	VIRTIO_NET_F_MRG_RXBUF, VIRTIO_NET_F_STATUS,
 	VIRTIO_F_NOTIFY_ON_EMPTY,
 };
 
@@ -799,6 +845,7 @@ static struct virtio_driver virtio_net = {
 	.id_table =	id_table,
 	.probe =	virtnet_probe,
 	.remove =	__devexit_p(virtnet_remove),
+	.config_changed = virtnet_config_changed,
 };
 
 static int __init init(void)
diff --git a/include/linux/virtio_net.h b/include/linux/virtio_net.h
index 5cdd0aa..67a37f8 100644
--- a/include/linux/virtio_net.h
+++ b/include/linux/virtio_net.h
@@ -21,11 +21,19 @@
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
+	/* Status supplied by host; see VIRTIO_NET_F_STATUS and VIRTIO_NET_S_*
+	 * bits above */
+	__u16 status;
+	/* The guest acks the status by writing it back here */
+	__u16 status_ack;
 } __attribute__((packed));
 
 /* This is the first element of the scatter-gather list.  If you don't
-- 
1.6.0.3

