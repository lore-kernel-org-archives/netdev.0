From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [RFC PATCH 1/4] Add a new API to virtio-pci
Date: Thu, 9 Sep 2010 10:53:52 +0530
Message-ID: <OFB29E6C59.96686002-ON65257799.00174D50-65257799.001D6F7B@in.ibm.com>
References: <20100908072859.23769.97363.sendpatchset@krkumar2.in.ibm.com> <20100908072905.23769.10732.sendpatchset@krkumar2.in.ibm.com> <201009091319.40274.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: anthony@codemonkey.ws, davem@davemloft.net, kvm@vger.kernel.org,
	mst@redhat.com, netdev@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <201009091319.40274.rusty@rustcorp.com.au>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rusty Russell <rusty@rustcorp.com.au> wrote on 09/09/2010 09:19:39 AM:

> On Wed, 8 Sep 2010 04:59:05 pm Krishna Kumar wrote:
> > Add virtio_get_queue_index() to get the queue index of a
> > vq.  This is needed by the cb handler to locate the queue
> > that should be processed.
>
> This seems a bit weird.  I mean, the driver used vdev->config->find_vqs
> to find the queues, which returns them (in order).  So, can't you put
this
> into your struct send_queue?

I am saving the vqs in the send_queue, but the cb needs
to locate the device txq from the svq. The only other way
I could think of is to iterate through the send_queue's
and compare svq against sq[i]->svq, but cb's happen quite
a bit. Is there a better way?

static void skb_xmit_done(struct virtqueue *svq)
{
	struct virtnet_info *vi = svq->vdev->priv;
	int qnum = virtio_get_queue_index(svq) - 1;     /* 0 is RX vq */

	/* Suppress further interrupts. */
	virtqueue_disable_cb(svq);

	/* We were probably waiting for more output buffers. */
	netif_wake_subqueue(vi->dev, qnum);
}

> Also, why define VIRTIO_MAX_TXQS?  If the driver can't handle all of
them,
> it should simply not use them...

The main reason was vhost :) Since vhost_net_release
should not fail (__fput can't handle f_op->release()
failure), I needed a maximum number of socks to
clean up:

#define MAX_VQS	(1 + VIRTIO_MAX_TXQS)
static int vhost_net_release(struct inode *inode, struct file *f)
{
	struct vhost_net *n = f->private_data;
	struct vhost_dev *dev = &n->dev;
	struct socket *socks[MAX_VQS];
	int i;

	vhost_net_stop(n, socks);
	vhost_net_flush(n);
	vhost_dev_cleanup(dev);

	for (i = n->dev.nvqs - 1; i >= 0; i--)
		if (socks[i])
			fput(socks[i]->file);
	...
}

Thanks,

- KK

