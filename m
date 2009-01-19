From: Mark McLoughlin <markmc@redhat.com>
Subject: Re: [PATCH 0/5] virtio_net: Add MAC and VLAN filtering
Date: Mon, 19 Jan 2009 08:30:31 +0000
Message-ID: <1232353831.5627.8.camel@blaa>
References: <20090116211312.22836.34331.stgit@debian.lart>
	 <20090118.220528.02874092.davem@davemloft.net>
Reply-To: Mark McLoughlin <markmc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: alex.williamson@hp.com, netdev@vger.kernel.org,
	rusty@rustcorp.com.au, kvm@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20090118.220528.02874092.davem@davemloft.net>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

On Sun, 2009-01-18 at 22:05 -0800, David Miller wrote:
> From: Alex Williamson <alex.williamson@hp.com>
> Date: Fri, 16 Jan 2009 14:13:12 -0700
> 
> > This series enables setting the virtio-net device MAC address, adds
> > infrastructure for the new control virtqueue, and makes use of it
> > to support set_rx_mode, unicast and multicast address lists, and
> > supporting a hypervisor based VLAN filter.  The goal is to make the
> > virtio-net device support more of the features of a physical NIC and
> > allow the hypervisor to discard packets we're not interested in.
> > 
> > This version incorporates the review comments from Mark McLoughlin,
> > specifically, much improved comments and commit logs, verifying the
> > functionality of host not providing a MAC address, moving communication
> > structs into virtio_net.h, adding warnings when things don't work, and
> > making the strings grep'able.  I've left the class/cmd split in the
> > control header rather than consolidating it into a single value, I'm
> > hoping I've made sufficient arguments for that.  Also, I left the
> > error return rather than a BUG_ON in send_command because I can't
> > conditionally enable set_rx_mode as it's in a const struct.  Instead,
> > I've changed the caller to avoid the issue.  Please comment and/or
> > apply.  Thanks,
> 
> I've been watching these patches passively, and it seems that
> there have been some comments that Rusty hasn't submitted
> certain virtio_net patches to me as well.
> 
> Please sort this all out and let me know what to queue up for
> 2.6.30

The missing patch is the link status one which I forwarded from Rusty's
queue (at his request) just before as the merge window closed:

  http://patchwork.ozlabs.org/patch/17500/

Here it is again.

Cheers,
Mark.

From: Mark McLoughlin <markmc@redhat.com>
Date: Tue, 9 Dec 2008 10:19:33 +0000
Subject: [PATCH] virtio_net: add link status handling

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
 2 files changed, 47 insertions(+), 1 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 43f6523..fb78368 100644
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
index cf335fe..7ffc754 100644
--- a/include/linux/virtio_net.h
+++ b/include/linux/virtio_net.h
@@ -23,11 +23,16 @@
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
-- 
1.6.0.6

