From: Alex Williamson <alex.williamson@hp.com>
Subject: [PATCH 4/5] virtio_net: Add a MAC filter table
Date: Fri, 16 Jan 2009 14:13:34 -0700
Message-ID: <20090116211334.22836.72681.stgit@debian.lart>
References: <20090116211312.22836.34331.stgit@debian.lart>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: rusty@rustcorp.com.au, markmc@redhat.com, kvm@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20090116211312.22836.34331.stgit@debian.lart>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make use of the MAC_TABLE control virtqueue class to support a
MAC filter table.  The size of the filter table defaults to 16
entries and can be adjusted via the mac_entries module parameter.
Note, the original hardware address does not count towards this.

As with most real hardware, unicast addresses have priority in
the filter table so we can avoid enabling full promiscuous
until both unicast and multicast address overflow.

Signed-off-by: Alex Williamson <alex.williamson@hp.com
---

 drivers/net/virtio_net.c   |   82 +++++++++++++++++++++++++++++++++++++++++++-
 include/linux/virtio_net.h |   20 +++++++++++
 2 files changed, 100 insertions(+), 2 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index da96368..9be0d6a 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -32,6 +32,11 @@ static int csum = 1, gso = 1;
 module_param(csum, bool, 0444);
 module_param(gso, bool, 0444);
 
+static unsigned int mac_entries = 16;
+module_param(mac_entries, uint, 0444);
+MODULE_PARM_DESC(mac_entries,
+	"Number of entries in the MAC filter table.");
+
 /* FIXME: MTU in config. */
 #define MAX_PACKET_LEN (ETH_HLEN+ETH_DATA_LEN)
 #define GOOD_COPY_LEN	128
@@ -667,9 +672,64 @@ static void virtnet_set_rx_mode(struct net_device *dev)
 	if (!vi->cvq)
 		return;
 
-	promisc = ((dev->flags & IFF_PROMISC) != 0 || dev->uc_count > 0);
-	allmulti = ((dev->flags & IFF_ALLMULTI) != 0 || dev->mc_count > 0);
+	promisc = ((dev->flags & IFF_PROMISC) != 0);
+	allmulti = ((dev->flags & IFF_ALLMULTI) != 0);
+
+	if (dev->uc_count > mac_entries)
+		promisc = 1;
+	else if (dev->uc_count + dev->mc_count > mac_entries)
+		allmulti = 1;
+
+	if (!promisc && (dev->uc_count || (dev->mc_count && !allmulti))) {
+		u8 *buf, *cur;
+		int count, i;
+		struct dev_addr_list *uc_ptr, *mc_ptr;
+
+		count = dev->uc_count + (allmulti ? 0 : dev->mc_count);
+
+		buf = kzalloc(count * ETH_ALEN, GFP_ATOMIC);
+		if (!buf) {
+			printk(KERN_WARNING "%s: "
+			       "Failed to alloc MAC table, using promisc.\n", 
+			       dev->name);
+			promisc = 1;
+			goto set_mode;
+		}
+
+		cur = buf;
+		uc_ptr = dev->uc_list;
+		mc_ptr = dev->mc_list;
+
+		for (i = 0; i < dev->uc_count; i++) {
+			memcpy(cur, uc_ptr->da_addr, ETH_ALEN);
+			cur += ETH_ALEN;
+			uc_ptr = uc_ptr->next;
+		}
+		if (!allmulti) {
+			for (i = 0; i < dev->mc_count; i++) {
+				memcpy(cur, mc_ptr->da_addr, ETH_ALEN);
+				cur += ETH_ALEN;
+				mc_ptr = mc_ptr->next;
+			}
+		}
+		if (virtnet_send_command(vi, VIRTIO_NET_CTRL_MAC_TABLE,
+					 VIRTIO_NET_CTRL_MAC_TABLE_SET,
+					 buf, count * ETH_ALEN)) {
+			printk(KERN_WARNING "%s: "
+			       "Failed to set MAC filter, using promisc.\n",
+			       dev->name);
+			promisc = 1;
+		}
+		kfree(buf);
+	} else {
+		/* Set an empty MAC table - disabled */
+		if (virtnet_send_command(vi, VIRTIO_NET_CTRL_MAC_TABLE,
+				VIRTIO_NET_CTRL_MAC_TABLE_SET, NULL, 0))
+			printk(KERN_WARNING "%s: "
+			       "Failed to clear MAC filter.\n", dev->name);
+	}
 
+set_mode:
 	if (virtnet_send_command(vi, VIRTIO_NET_CTRL_RX_MODE,
 				 VIRTIO_NET_CTRL_RX_MODE_PROMISC,
 				 &promisc, sizeof(promisc)))
@@ -801,6 +861,24 @@ static int virtnet_probe(struct virtio_device *vdev)
 	vi->cvq = vdev->config->find_vq(vdev, 2, NULL);
 	if (IS_ERR(vi->cvq))
 		vi->cvq = NULL;
+	else {
+		unsigned int entries;
+
+		/*
+		 * We use a separate stack variable here because the
+		 * data segment for the static variable doesn't translate
+		 * across the virtqueue.
+		 */
+		entries = mac_entries = min(mac_entries,
+					(unsigned int)(PAGE_SIZE / ETH_ALEN));
+		if (virtnet_send_command(vi, VIRTIO_NET_CTRL_MAC_TABLE,
+					 VIRTIO_NET_CTRL_MAC_TABLE_ALLOC,
+					 &entries, sizeof(entries))) {
+			printk(KERN_WARNING "virtio-net: "
+			       "MAC filter table allocation failed.\n");
+			mac_entries = 0;
+		}
+	}
 
 	/* Initialize our empty receive and send queues. */
 	skb_queue_head_init(&vi->recv);
diff --git a/include/linux/virtio_net.h b/include/linux/virtio_net.h
index f8afef3..84086a6 100644
--- a/include/linux/virtio_net.h
+++ b/include/linux/virtio_net.h
@@ -79,4 +79,24 @@ typedef __u8 virtio_net_ctrl_ack;
  #define VIRTIO_NET_CTRL_RX_MODE_PROMISC      0
  #define VIRTIO_NET_CTRL_RX_MODE_ALLMULTI     1
 
+/*
+ * Control the MAC filter table.
+ *
+ * The ALLOC command requires a 4 byte sg entry indicating the size of
+ * the MAC filter table to be allocated in number of entries
+ * (ie. bytes = entries * ETH_ALEN).  The MAC filter table may only be
+ * allocated once after a device reset.  A device reset frees the MAC
+ * filter table, allowing a new ALLOC.  The current implementation limits
+ * the size to a single host page.
+ *
+ * The SET command requires an out sg entry containing a buffer of the
+ * entire MAC filter table.  The format is a simple byte stream
+ * concatenating all of the ETH_ALEN MAC adresses to be inserted into
+ * the table.  Partial updates are not available.  The SET command can
+ * only succeed if there is a table allocated.
+ */
+#define VIRTIO_NET_CTRL_MAC_TABLE  1
+ #define VIRTIO_NET_CTRL_MAC_TABLE_ALLOC      0
+ #define VIRTIO_NET_CTRL_MAC_TABLE_SET        1
+
 #endif /* _LINUX_VIRTIO_NET_H */

