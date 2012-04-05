From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [V6 PATCH] virtio-net: send gratuitous packets when needed
Date: Thu, 5 Apr 2012 09:37:56 +0300
Message-ID: <20120405063756.GA25422@redhat.com>
References: <20120328054428.34415.75432.stgit@amd-6168-8-1.englab.nay.redhat.com>
	<20120404074937.GA22658@redhat.com> <4F7D33FF.2060304@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, qemu-devel@nongnu.org, linux-kernel@vger.kernel.org,
	Amit Shah <amit.shah@redhat.com>,
	virtualization@lists.linux-foundation.org, davem@davemloft.net
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <4F7D33FF.2060304@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 05, 2012 at 01:56:15PM +0800, Jason Wang wrote:
> On 04/04/2012 03:49 PM, Michael S. Tsirkin wrote:
> >On Wed, Mar 28, 2012 at 01:44:28PM +0800, Jason Wang wrote:
> >>As hypervior does not have the knowledge of guest network configuration, it's
> >>better to ask guest to send gratuitous packets when needed.
> >>
> >>Guest tests VIRTIO_NET_S_ANNOUNCE bit during config change interrupt and when it
> >>is set, a workqueue is scheduled to send gratuitous packet through
> >>NETDEV_NOTIFY_PEERS. This feature is negotiated through bit
> >>VIRTIO_NET_F_GUEST_ANNOUNCE.
> >>
> >>Changes from v5:
> >>- notify the chain before acking the link annoucement
> >>- ack the link announcement notification through control vq
> >>
> >>Changes from v4:
> >>- typos
> >>- handle workqueue unconditionally
> >>- move VIRTIO_NET_S_ANNOUNCE to bit 8 to separate rw bits from ro bits
> >>
> >>Changes from v3:
> >>- cancel the workqueue during freeze
> >>
> >>Changes from v2:
> >>- fix the race between unregister_dev() and workqueue
> >>
> >>Signed-off-by: Jason Wang<jasowang@redhat.com>
> >I think this needs some fixes. See below.
> >Thanks.
> >
> >>---
> >>  drivers/net/virtio_net.c   |   32 +++++++++++++++++++++++++++++++-
> >>  include/linux/virtio_net.h |   13 +++++++++++++
> >>  2 files changed, 44 insertions(+), 1 deletions(-)
> >>
> >>diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> >>index 4880aa8..0f60da7 100644
> >>--- a/drivers/net/virtio_net.c
> >>+++ b/drivers/net/virtio_net.c
> >>@@ -72,6 +72,9 @@ struct virtnet_info {
> >>  	/* Work struct for refilling if we run low on memory. */
> >>  	struct delayed_work refill;
> >>
> >>+	/* Work struct for sending gratuitous packets. */
> >A bit confusing: it does not send anything itself.
> >A better comment 'for announcing the existence of device
> >on the network'.
> >
> >>+	struct work_struct announce;
> >>+
> >>  	/* Chain pages by the private ptr. */
> >>  	struct page *pages;
> >>
> >>@@ -781,12 +784,30 @@ static bool virtnet_send_command(struct virtnet_info *vi, u8 class, u8 cmd,
> >>  	return status == VIRTIO_NET_OK;
> >>  }
> >>
> >>+static void virtnet_ack_link_announce(struct virtnet_info *vi)
> >>+{
> >>+	if (!virtnet_send_command(vi, VIRTIO_NET_CTRL_ANNOUNCE,
> >>+				  VIRTIO_NET_CTRL_ANNOUNCE_ACK, NULL,
> >>+				  0, 0)) {
> >This can run in parallel with other commands. That's pretty bad -
> >will corrupt the cvq.
> >Take rtnl lock around calls to this function?
> 
> It's only used by callbacks of netif_notify_peers(), so rtnl lock
> have already been hold. Add a comment to clarify this?
> >>+		dev_warn(&vi->dev->dev, "Failed to ack link nnounce.\n");
> >announce
> 
> Sorry for the typos, would double check in the future.
> >>+	}
> >Better to drop {} around a single statement.
> >
> >>+}
> >>+
> >>+static void announce_work(struct work_struct *work)
> >>+{
> >>+	struct virtnet_info *vi = container_of(work, struct virtnet_info,
> >>+					       announce);
> >>+	netif_notify_peers(vi->dev);
> >>+	virtnet_ack_link_announce(vi);
> >>+}
> >>+
> >>  static int virtnet_close(struct net_device *dev)
> >>  {
> >>  	struct virtnet_info *vi = netdev_priv(dev);
> >>
> >>  	/* Make sure refill_work doesn't re-enable napi! */
> >>  	cancel_delayed_work_sync(&vi->refill);
> >>+	cancel_work_sync(&vi->announce);
> >I think that a config change event can trigger after this point,
> >so cancel here won't be effective. But why do it here?
> >virtnet_remove not a better place? We can do it
> >after remove_vq_common.
> 
> Sure.

Except, trying to send a command on cvq after device
has been reset would deadlock. I suspect we'll need
a flag like block has to prevent this.


> >>  	napi_disable(&vi->napi);
> >>
> >>  	return 0;
> >>@@ -962,11 +983,17 @@ static void virtnet_update_status(struct virtnet_info *vi)
> >>  		return;
> >>
> >>  	/* Ignore unknown (future) status bits */
> >>-	v&= VIRTIO_NET_S_LINK_UP;
> >>+	v&= VIRTIO_NET_S_LINK_UP | VIRTIO_NET_S_ANNOUNCE;
> >The announce bit in vi->status is always clear,
> >so this is IMO confusing. I would do:
> >
> >	if (v&  VIRTIO_NET_S_ANNOUNCE) {
> >		schedule
> >	}
> >
> >	v&= VIRTIO_NET_S_LINK_UP;
> >
> >and the rest of the logic is not necessary then.
> >
> >Also, this might run extra ack announce commands after
> >VIRTIO_NET_S_ANNOUNCE bit is clear. The spec
> >isn't clear on whether this is legal.
> >
> >It would be very hard to fix this, so let's add a comment
> >stating that it's legal, and clarify the spec
> >in any case.
> 
> How about delay the clearing of VIRTIO_NET_S_ANNOUNCE bit in the
> workqueue and protect the updating with
> spinlock_irqsave()/spinloc_irqrestore()? Then later notification
> would be suppressed if the sending is not completed.


Not sure what's meant, just make sure we don't lose
these events.

> >>
> >>  	if (vi->status == v)
> >>  		return;
> >>
> >>+	if (v&  VIRTIO_NET_S_ANNOUNCE) {
> >>+		v&= ~VIRTIO_NET_S_ANNOUNCE;
> >>+		if (v&  VIRTIO_NET_S_LINK_UP)
> >>+			schedule_work(&vi->announce);
> >I think we really want an nrt wq here - if this triggers
> >multiple times there's no good reason to try and run
> >the ack command many times in parallel.
> 
> Yes.
> >>+	}
> >>+
> >>  	vi->status = v;
> >>
> >>  	if (vi->status&  VIRTIO_NET_S_LINK_UP) {
> >
> >>@@ -1076,6 +1103,7 @@ static int virtnet_probe(struct virtio_device *vdev)
> >>  		goto free;
> >>
> >>  	INIT_DELAYED_WORK(&vi->refill, refill_work);
> >>+	INIT_WORK(&vi->announce, announce_work);
> >>  	sg_init_table(vi->rx_sg, ARRAY_SIZE(vi->rx_sg));
> >>  	sg_init_table(vi->tx_sg, ARRAY_SIZE(vi->tx_sg));
> >>
> >>@@ -1187,6 +1215,7 @@ static int virtnet_freeze(struct virtio_device *vdev)
> >>  	virtqueue_disable_cb(vi->svq);
> >>  	if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_VQ))
> >>  		virtqueue_disable_cb(vi->cvq);
> >>+	cancel_work_sync(&vi->announce);
> >A config change event can trigger after this point,
> >so cancel here won't be effective.
> >Possibly, we need state like config_enable in the block
> >device.
> 
> Probably needed.
> >
> >Also, what exactly will happen on suspend?
> >As we reset, ANNOUCE bit will be clear so -
> >do we forget to announce? Probably not good ...
> 
> This problem should be the same as normal suspending/resuming, if
> user want to announce the link they should use arp_notify instead.
> >
> >>
> >>  	netif_device_detach(vi->dev);
> >>  	cancel_delayed_work_sync(&vi->refill);
> >>@@ -1233,6 +1262,7 @@ static unsigned int features[] = {
> >>  	VIRTIO_NET_F_GUEST_ECN, VIRTIO_NET_F_GUEST_UFO,
> >>  	VIRTIO_NET_F_MRG_RXBUF, VIRTIO_NET_F_STATUS, VIRTIO_NET_F_CTRL_VQ,
> >>  	VIRTIO_NET_F_CTRL_RX, VIRTIO_NET_F_CTRL_VLAN,
> >>+	VIRTIO_NET_F_GUEST_ANNOUNCE,
> >>  };
> >>
> >>  static struct virtio_driver virtio_net_driver = {
> >>diff --git a/include/linux/virtio_net.h b/include/linux/virtio_net.h
> >>index 970d5a2..383e8a0 100644
> >>--- a/include/linux/virtio_net.h
> >>+++ b/include/linux/virtio_net.h
> >>@@ -49,8 +49,10 @@
> >>  #define VIRTIO_NET_F_CTRL_RX	18	/* Control channel RX mode support */
> >>  #define VIRTIO_NET_F_CTRL_VLAN	19	/* Control channel VLAN filtering */
> >>  #define VIRTIO_NET_F_CTRL_RX_EXTRA 20	/* Extra RX mode control support */
> >>+#define VIRTIO_NET_F_GUEST_ANNOUNCE 21  /* Guest can send gratituous packet */
> >Rusty aligned the comments using tabs so let's do it here too?
> >A better comment 'can announce device on the network'.
> >
> >>
> >>  #define VIRTIO_NET_S_LINK_UP	1	/* Link is up */
> >>+#define VIRTIO_NET_S_ANNOUNCE   2	/* Announcement is needed */
> >why 3 spaces before the value here?
> >
> >>
> >>  struct virtio_net_config {
> >>  	/* The config defining mac address (if VIRTIO_NET_F_MAC) */
> >>@@ -152,4 +154,15 @@ struct virtio_net_ctrl_mac {
> >>   #define VIRTIO_NET_CTRL_VLAN_ADD             0
> >>   #define VIRTIO_NET_CTRL_VLAN_DEL             1
> >>
> >>+/*
> >>+ * Control link announce acknowledgement
> >>+ *
> >>+ * The command VIRTIO_NET_CTRL_ANNOUNCE_ACK is used to indicate that
> >>+ * driver has recevied the notification and device would clear the
> >s/recevied/received/
> >
> >A bit clearer to replace 'and' with ; here.
> >
> >>+ * VIRTIO_NET_S_ANNOUNCE bit in the status filed after it received
> >s/filed/field/
> >s/received/receives/
> >
> >>+ * this command.
> >>+ */
> >>+#define VIRTIO_NET_CTRL_ANNOUNCE       3
> >>+ #define VIRTIO_NET_CTRL_ANNOUNCE_ACK         0
> >>+
> >>  #endif /* _LINUX_VIRTIO_NET_H */
> >>
> >>_______________________________________________
> >>Virtualization mailing list
> >>Virtualization@lists.linux-foundation.org
> >>https://lists.linuxfoundation.org/mailman/listinfo/virtualization
