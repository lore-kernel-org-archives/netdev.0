From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: potential race in virtio ring?
Date: Mon, 14 Jun 2010 16:59:12 +0300
Message-ID: <20100614135912.GA25015@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: virtualization@lists.linux-foundation.org,
	Rusty Russell <rusty@rustcorp.com.au>,
	Jiri Pirko <jpirko@redhat.com>, Shirley Ma <xma@us.ibm.com>,
	netdev@vger.kernel.org, linux-kernel@vge
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!
I was going over the vring code and noticed, that
the ring has this check:

irqreturn_t vring_interrupt(int irq, void *_vq)
{
        struct vring_virtqueue *vq = to_vvq(_vq);
        
        if (!more_used(vq)) {
                pr_debug("virtqueue interrupt with no work for %p\n", vq);
                return IRQ_NONE;


static inline bool more_used(const struct vring_virtqueue *vq)
{               
        return vq->last_used_idx != vq->vring.used->idx;
}               

My concern is that with virtio net, more_used is called
on a CPU different from the one that polls the vq.
This might mean that last_used_idx value might be stale.
Could this lead to a missed interrupt?

Thanks,

-- 
MST
