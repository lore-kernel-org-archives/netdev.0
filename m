From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 2/2] virtio_net: remove send completion interrupts and
 avoid TX queue overrun through packet drop
Date: Tue, 22 Mar 2011 13:36:50 +0200
Message-ID: <20110322113649.GA17071@redhat.com>
References: <20110318133311.GA20623@gondor.apana.org.au>
 <1300498915.3441.21.camel@localhost.localdomain>
 <1300730587.3441.24.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.hengli.com.au>, rusty@rustcorp.com.au,
	davem@davemloft.net, kvm@vger.kernel.org, netdev@vger.kernel.org
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1300730587.3441.24.camel@localhost.localdomain>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 21, 2011 at 11:03:07AM -0700, Shirley Ma wrote:
> On Fri, 2011-03-18 at 18:41 -0700, Shirley Ma wrote:
> > > > +       /* Drop packet instead of stop queue for better
> > performance
> > > */
> > > 
> > > I would like to see some justification as to why this is the right
> > > way to go and not just papering over the real problem. 
> > 
> > Fair. KVM guest virtio_net TX queue stop/restart is pretty expensive,
> > which involves:
> > 
> > 1. Guest enable callback: one memory barrier, interrupt flag set
> 
> Missed this cost: for history reason, it also involves a guest exit from
> I/O write (PCI_QUEUE_NOTIFY).

OK, after some research, it looks like the reason was the tx timer that
qemu used to use. So the hack of avoiding the add_buf call will
avoid this kick and so break these hosts.
I guess we can add a feature bit to detect a new host
and so avoid the kick. We are running low on feature bits
unfortunately, but just fo testing, could you quantify the difference
that this makes using the following patch:


diff --git a/drivers/virtio/virtio_ring.c b/drivers/virtio/virtio_ring.c
index cc2f73e..6106017 100644
--- a/drivers/virtio/virtio_ring.c
+++ b/drivers/virtio/virtio_ring.c
@@ -185,11 +185,6 @@ int virtqueue_add_buf_gfp(struct virtqueue *_vq,
 	if (vq->num_free < out + in) {
 		pr_debug("Can't add buf len %i - avail = %i\n",
 			 out + in, vq->num_free);
-		/* FIXME: for historical reasons, we force a notify here if
-		 * there are outgoing parts to the buffer.  Presumably the
-		 * host should service the ring ASAP. */
-		if (out)
-			vq->notify(&vq->vq);
 		END_USE(vq);
 		return -ENOSPC;
 	}

-- 
MST
