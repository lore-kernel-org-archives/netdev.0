From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [V2 PATCH 9/9] vhost: zerocopy: poll vq in zerocopy callback
Date: Wed, 16 May 2012 12:08:23 -0700
Message-ID: <1337195303.10741.37.camel@oc3660625478.ibm.com>
References: <20120502033901.11782.13157.stgit@amd-6168-8-1.englab.nay.redhat.com>
	 <20120502034254.11782.27314.stgit@amd-6168-8-1.englab.nay.redhat.com>
	 <1337100630.8220.4.camel@oc3660625478.ibm.com> <4FB317C8.90002@redhat.com>
	 <1337181027.10741.13.camel@oc3660625478.ibm.com>
	 <20120516151444.GC9934@redhat.com>
	 <1337189525.10741.24.camel@oc3660625478.ibm.com>
	 <20120516183629.GJ10769@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jason Wang <jasowang@redhat.com>, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ebiederm@xmission.com, davem@davemloft.net
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120516183629.GJ10769@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-05-16 at 21:36 +0300, Michael S. Tsirkin wrote:
> On Wed, May 16, 2012 at 10:32:05AM -0700, Shirley Ma wrote:
> > On Wed, 2012-05-16 at 18:14 +0300, Michael S. Tsirkin wrote:
> > > On Wed, May 16, 2012 at 08:10:27AM -0700, Shirley Ma wrote:
> > > > On Wed, 2012-05-16 at 10:58 +0800, Jason Wang wrote:
> > > > > >>   drivers/vhost/vhost.c |    1 +
> > > > > >>   1 files changed, 1 insertions(+), 0 deletions(-)
> > > > > >>
> > > > > >> diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
> > > > > >> index 947f00d..7b75fdf 100644
> > > > > >> --- a/drivers/vhost/vhost.c
> > > > > >> +++ b/drivers/vhost/vhost.c
> > > > > >> @@ -1604,6 +1604,7 @@ void vhost_zerocopy_callback(void
> *arg)
> > > > > >>          struct vhost_ubuf_ref *ubufs = ubuf->arg;
> > > > > >>          struct vhost_virtqueue *vq = ubufs->vq;
> > > > > >>
> > > > > >> +       vhost_poll_queue(&vq->poll);
> > > > > >>          /* set len = 1 to mark this desc buffers done DMA
> */
> > > > > >>          vq->heads[ubuf->desc].len = VHOST_DMA_DONE_LEN;
> > > > > >>          kref_put(&ubufs->kref,
> vhost_zerocopy_done_signal);
> > > > > > Doing so, we might have redundant vhost_poll_queue(). Do you
> > > know in
> > > > > > which scenario there might be missing of adding and
> signaling
> > > during
> > > > > > zerocopy?
> > > > > 
> > > > > Yes, as we only do signaling and adding during tx work, if
> there's
> > > no
> > > > > tx 
> > > > > work when the skb were sent, we may lose the opportunity to
> let
> > > guest 
> > > > > know about the completion. It's easy to be reproduced with
> netperf
> > > > > test. 
> > > > 
> > > > The reason which host signals guest is to free guest tx buffers,
> if
> > > > there is no tx work, then it's not necessary to signal the guest
> > > unless
> > > > guest runs out of memory. The pending buffers will be released
> > > > virtio_net device gone.
> > > > 
> > > > What's the behavior of netperf test when you hit this situation?
> > > > 
> > > > Thanks
> > > > Shirley
> > > 
> > > IIRC guest networking seems to be lost. 
> > 
> > It seems vhost_enable_notify is missing in somewhere else?
> > 
> > Thanks
> > Shirley
> 
> Donnu. I see virtio sending packets but they do not get
> to tun on host. debugging. 

I looked at the code, if (zerocopy) check is needed for below code:

+	if (zerocopy) {
                        num_pends = likely(vq->upend_idx >= vq->done_idx) ?
                                    (vq->upend_idx - vq->done_idx) :
                                    (vq->upend_idx + UIO_MAXIOV - vq->done_idx);
                        if (unlikely(num_pends > VHOST_MAX_PEND)) {
                                tx_poll_start(net, sock);
				vhost_poll_queue
                                set_bit(SOCK_ASYNC_NOSPACE, &sock->flags);
                                break;
                        }
+	}
                        if (unlikely(vhost_enable_notify(&net->dev, vq))) {
                                vhost_disable_notify(&net->dev, vq);
                                continue;
                        }
                        break;


Second, whether it's possible the problem comes from tx_poll_start()? In
some situation, vhost_poll_wakeup() is not being called?

Thanks
Shirley
