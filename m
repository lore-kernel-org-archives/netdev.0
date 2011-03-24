From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [PATCH 2/2] virtio_net: remove send completion interrupts and
 avoid TX queue overrun through packet drop
Date: Wed, 23 Mar 2011 21:14:32 -0700
Message-ID: <1300940073.3441.42.camel@localhost.localdomain>
References: <20110318133311.GA20623@gondor.apana.org.au>
	 <1300498915.3441.21.camel@localhost.localdomain>
	 <1300730587.3441.24.camel@localhost.localdomain>
	 <20110322113649.GA17071@redhat.com>
	 <1300847204.3441.26.camel@localhost.localdomain>
	 <87r59xbbr6.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>, davem@davemloft.net,
	kvm@vger.kernel.org, netdev@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <87r59xbbr6.fsf@rustcorp.com.au>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2011-03-24 at 11:00 +1030, Rusty Russell wrote:
> > With simply removing the notify here, it does help the case when TX
> > overrun hits too often, for example for 1K message size, the single
> > TCP_STREAM performance improved from 2.xGb/s to 4.xGb/s.
> 
> OK, we'll be getting rid of the "kick on full", so please delete that
> on
> all benchmarks.
> 
> Now, does the capacity check before add_buf() still win anything?  I
> can't see how unless we have some weird bug.
> 
> Once we've sorted that out, we should look at the more radical change
> of publishing last_used and using that to intuit whether interrupts
> should be sent.  If we're not careful with ordering and barriers that
> could introduce more bugs.

Without the kick, it's not necessary for capacity check. I am
regenerating the patch with add_buf check and summit the patch after
passing all tests. 

> Anything else on the optimization agenda I've missed?

Tom found small performance gain with freeing the used buffers when half
of the ring is full in TCP_RR workload. 

I think we need a new API in virtio, which frees all used buffers at
once, I am testing the performance now, the new API looks like:

 drivers/virtio/virtio_ring.c |   40 +++++++++++++++++++++++++++++++++++
 include/linux/virtio.h       |    6 +++++

diff --git a/drivers/virtio/virtio_ring.c b/drivers/virtio/virtio_ring.c
index cc2f73e..6d2dc16 100644
--- a/drivers/virtio/virtio_ring.c
+++ b/drivers/virtio/virtio_ring.c
@@ -329,6 +329,46 @@ void *virtqueue_get_buf(struct virtqueue *_vq, unsigned int *len)
 }
 EXPORT_SYMBOL_GPL(virtqueue_get_buf);
 
+int virtqueue_free_used(struct virtqueue *_vq, void (*free)(void *))
+{
+	struct vring_virtqueue *vq = to_vvq(_vq);
+	unsigned int i;
+	void *buf;
+
+	START_USE(vq);
+
+	if (unlikely(vq->broken)) {
+		END_USE(vq);
+		return NULL;
+	}
+
+	/* Only get used array entries after they have been exposed by host. */
+	virtio_rmb();
+
+	while (vq->last_used_idx != vq->vring.used->idx) {
+		i = vq->vring.used->ring[vq->last_used_idx%vq->vring.num].id;
+
+		if (unlikely(i >= vq->vring.num)) {
+			BAD_RING(vq, "id %u out of range\n", i);
+			return NULL;
+		}
+		if (unlikely(!vq->data[i])) {
+			BAD_RING(vq, "id %u is not a head!\n", i);
+			return NULL;
+		}
+
+		/* detach_buf clears data, so grab it now. */
+		buf = vq->data[i];
+		detach_buf(vq, i);
+		free(buf);
+		vq->last_used_idx++;
+	}
+	END_USE(vq);
+	return vq->num_free;
+}
+
+EXPORT_SYMBOL_GPL(virtqueue_free_used);
+
 void virtqueue_disable_cb(struct virtqueue *_vq)
 {
 	struct vring_virtqueue *vq = to_vvq(_vq);
diff --git a/include/linux/virtio.h b/include/linux/virtio.h
index aff5b4f..19acc66 100644
--- a/include/linux/virtio.h
+++ b/include/linux/virtio.h
@@ -42,6 +42,10 @@ struct virtqueue {
  *	vq: the struct virtqueue we're talking about.
  *	len: the length written into the buffer
  *	Returns NULL or the "data" token handed to add_buf.
+ * virtqueue_free_used: free all used buffers in the queue
+ *	vq: the struct virtqueue we're talking about.
+ *	free: free buf function from caller.
+ *	Returns remaining capacity of the queue.
  * virtqueue_disable_cb: disable callbacks
  *	vq: the struct virtqueue we're talking about.
  *	Note that this is not necessarily synchronous, hence unreliable and only
@@ -82,6 +86,8 @@ void virtqueue_kick(struct virtqueue *vq);
 
 void *virtqueue_get_buf(struct virtqueue *vq, unsigned int *len);
 
+int virtqueue_free_used(struct virtqueue *vq, void (*free)(void *buf));
+
 void virtqueue_disable_cb(struct virtqueue *vq);
 
 bool virtqueue_enable_cb(struct virtqueue *vq);


Thanks
Shirley


