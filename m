From: Mark McLoughlin <markmc@redhat.com>
Subject: Re: [PATCH] virtio_net: add link status handling
Date: Fri, 09 Jan 2009 11:51:33 +0000
Message-ID: <1231501893.4481.81.camel@localhost.localdomain>
References: <1228817973.26198.1.camel@blaa> <493F336B.5010402@codemonkey.ws>
	 <1228934084.5384.66.camel@blaa>  <200812121834.49464.rusty@rustcorp.com.au>
	 <1231352283.5050.76.camel@localhost.localdomain>
Reply-To: Mark McLoughlin <markmc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Anthony Liguori <anthony@codemonkey.ws>,
	netdev <netdev@vger.kernel.org>, kvm <kvm@vger.kernel.org>,
	Rusty Russell <rusty@rustcorp.com.au>
To: David Miller <davem@davemloft.net>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1231352283.5050.76.camel@localhost.localdomain>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

On Wed, 2009-01-07 at 18:18 +0000, Mark McLoughlin wrote:
> On Fri, 2008-12-12 at 18:34 +1030, Rusty Russell wrote:
> > Not quite what I was after.  I've taken the original patch, added the
> > masking change.  I'll test here and feed to DaveM.
> 
> This never got pushed to davem, did it? What you've got in your queue
> looks fine to me ...

Here's a virtio-net patch from Rusty's queue which appears just to have
fallen through the cracks.

Thanks,
Mark.

Subject: virtio_net: add link status handling
Date: Tue, 09 Dec 2008 10:19:33 +0000
From: Mark McLoughlin <markmc@redhat.com>

Allow the host to inform us that the link is down by adding
a VIRTIO_NET_F_STATUS which indicates that device status is
available in virtio_net config.

This is currently useful for simulating link down conditions
(e.g. using proposed qemu 'set_link' monitor command) but
would also be needed if we were to support device assignment
via virtio.

Signed-off-by: Mark McLoughlin <markmc@redhat.com>
Signed-off-by: Rusty Russell <rusty@rustcorp.com.au> (added future masking)
---
 drivers/net/virtio_net.c   |   43 ++++++++++++++++++++++++++++++++++++++++++-
 include/linux/virtio_net.h |    5 +++++
 2 files changed, 47 insertions(+), 1 deletion(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 71ca29c..128c38d 100644
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
@@ -624,6 +626,41 @@ static int virtnet_change_mtu(struct net_device *dev, int new_mtu)
 	return 0;
 }
 
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
@@ -732,6 +766,9 @@ static int virtnet_probe(struct virtio_device *vdev)
 		goto unregister;
 	}
 
+	vi->status = VIRTIO_NET_S_LINK_UP;
+	virtnet_update_status(vi);
+
 	pr_debug("virtnet: registered device %s\n", dev->name);
 	return 0;
 
@@ -787,7 +824,7 @@ static unsigned int features[] = {
 	VIRTIO_NET_F_HOST_TSO4, VIRTIO_NET_F_HOST_UFO, VIRTIO_NET_F_HOST_TSO6,
 	VIRTIO_NET_F_HOST_ECN, VIRTIO_NET_F_GUEST_TSO4, VIRTIO_NET_F_GUEST_TSO6,
 	VIRTIO_NET_F_GUEST_ECN, /* We don't yet handle UFO input. */
-	VIRTIO_NET_F_MRG_RXBUF,
+	VIRTIO_NET_F_MRG_RXBUF, VIRTIO_NET_F_STATUS,
 	VIRTIO_F_NOTIFY_ON_EMPTY,
 };
 
@@ -799,6 +836,7 @@ static struct virtio_driver virtio_net = {
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


