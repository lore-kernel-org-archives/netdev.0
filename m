From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: Network performance with small packets
Date: Fri, 28 Jan 2011 14:16:16 +0200
Message-ID: <20110128121616.GA8374@redhat.com>
References: <20110127193131.GD5228@redhat.com>
 <1296157547.1640.45.camel@localhost.localdomain>
 <20110127200548.GE5228@redhat.com>
 <20110127.130240.104065182.davem@davemloft.net>
 <1296163838.1640.53.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, steved@us.ibm.com,
	kvm@vger.kernel.org, netdev@vger.kernel.org
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1296163838.1640.53.camel@localhost.localdomain>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 27, 2011 at 01:30:38PM -0800, Shirley Ma wrote:
> On Thu, 2011-01-27 at 13:02 -0800, David Miller wrote:
> > > Interesting. Could this is be a variant of the now famuous
> > bufferbloat then?
> > 
> > Sigh, bufferbloat is the new global warming... :-/ 
> 
> Yep, some places become colder, some other places become warmer; Same as
> BW results, sometimes faster, sometimes slower. :)
> 
> Shirley

OK, so thinking about it more, maybe the issue is this:
tx becomes full. We process one request and interrupt the guest,
then it adds one request and the queue is full again.

Maybe the following will help it stabilize?
By itself it does nothing, but if you set
all the parameters to a huge value we will
only interrupt when we see an empty ring.
Which might be too much: pls try other values
in the middle: e.g. make bufs half the ring,
or bytes some small value, or packets some
small value etc.

Warning: completely untested.

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index aac05bc..6769cdc 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -32,6 +32,13 @@
  * Using this limit prevents one virtqueue from starving others. */
 #define VHOST_NET_WEIGHT 0x80000
 
+int tx_bytes_coalesce = 0;
+module_param(tx_bytes_coalesce, int, 0644);
+int tx_bufs_coalesce = 0;
+module_param(tx_bufs_coalesce, int, 0644);
+int tx_packets_coalesce = 0;
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
+		bufs_coalesced += in;
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
 
+	if (likely(packets_coalesced > tx_packets_coalesce ||
+		   bytes_coalesced > tx_bytes_coalesce ||
+		   bufs_coalesced > tx_bufs_coalesce))
+		vhost_signal(&net->dev, vq);
 	mutex_unlock(&vq->mutex);
 }
 
