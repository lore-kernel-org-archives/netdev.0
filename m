From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCHv2 dontapply] vhost-net tx tuning
Date: Tue, 1 Feb 2011 17:52:53 +0200
Message-ID: <20110201155253.GA22959@redhat.com>
References: <OFD293DCD2.7F0260F0-ON86257823.0061DC39-86257823.00743BB3@us.ibm.com>
 <20110126151700.GA14113@redhat.com>
 <1296153874.1640.27.camel@localhost.localdomain>
 <20110127190031.GC5228@redhat.com>
 <1296155340.1640.34.camel@localhost.localdomain>
 <20110127193131.GD5228@redhat.com>
 <1296157547.1640.45.camel@localhost.localdomain>
 <20110127200548.GE5228@redhat.com>
 <1296159305.1640.50.camel@localhost.localdomain>
 <OF381CCA86.B82857CC-ON86257826.00629F88-86257826.006596F5@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mashirle@linux.vnet.ibm.com, kvm@vger.kernel.org,
	netdev@vger.kernel.org
To: Steve Dobbelstein <steved@us.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <OF381CCA86.B82857CC-ON86257826.00629F88-86257826.006596F5@us.ibm.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

OK, so thinking about it more, maybe the issue is this:
tx becomes full. We process one request and interrupt the guest,
then it adds one request and the queue is full again.

Maybe the following will help it stabilize?  By default with it we will
only interrupt when we see an empty ring.
Which is liklely too much: pls try other values
in the middle: e.g. make bufs half the ring,
or bytes some small value like half ring * 200, or packets some
small value etc.

Set any one parameter to 0 to get current
behaviour (interrupt immediately when enabled).

Warning: completely untested.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

---

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index aac05bc..6769cdc 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -32,6 +32,13 @@
  * Using this limit prevents one virtqueue from starving others. */
 #define VHOST_NET_WEIGHT 0x80000
 
+int tx_bytes_coalesce = 1000000000;
+module_param(tx_bytes_coalesce, int, 0644);
+int tx_bufs_coalesce = 1000000000;
+module_param(tx_bufs_coalesce, int, 0644);
+int tx_packets_coalesce = 1000000000;
+module_param(tx_packets_coalesce, int, 0644);
+
 enum {
 	VHOST_NET_VQ_RX = 0,
 	VHOST_NET_VQ_TX = 1,
@@ -127,6 +134,9 @@ static void handle_tx(struct vhost_net *net)
 	int err, wmem;
 	size_t hdr_size;
 	struct socket *sock;
+	int bytes_coalesced = 0;
+	int bufs_coalesced = 0;
+	int packets_coalesced = 0;
 
 	/* TODO: check that we are running from vhost_worker? */
 	sock = rcu_dereference_check(vq->private_data, 1);
@@ -196,14 +206,26 @@ static void handle_tx(struct vhost_net *net)
 		if (err != len)
 			pr_debug("Truncated TX packet: "
 				 " len %d != %zd\n", err, len);
-		vhost_add_used_and_signal(&net->dev, vq, head, 0);
 		total_len += len;
+		packets_coalesced += 1;
+		bytes_coalesced += len;
+		bufs_coalesced += out;
+		if (unlikely(packets_coalesced > tx_packets_coalesce ||
+			     bytes_coalesced > tx_bytes_coalesce ||
+			     bufs_coalesced > tx_bufs_coalesce))
+			vhost_add_used_and_signal(&net->dev, vq, head, 0);
+		else
+			vhost_add_used(vq, head, 0);
 		if (unlikely(total_len >= VHOST_NET_WEIGHT)) {
 			vhost_poll_queue(&vq->poll);
 			break;
 		}
 	}
 
+	if (likely(packets_coalesced &&
+		   bytes_coalesced &&
+		   bufs_coalesced))
+		vhost_signal(&net->dev, vq);
 	mutex_unlock(&vq->mutex);
 }
 
