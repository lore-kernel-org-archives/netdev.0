From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH V4 net-next 1/3] vhost: better detection of available
 buffers
Date: Tue, 10 Jan 2017 04:57:39 +0200
Message-ID: <20170110045213-mutt-send-email-mst@kernel.org>
References: <1483668797-24112-1-git-send-email-jasowang@redhat.com>
 <1483668797-24112-2-git-send-email-jasowang@redhat.com>
 <20170106214903-mutt-send-email-mst@kernel.org>
 <e09ccb6a-87b8-d2b1-f64d-79ea7ea89954@redhat.com>
 <20170110010957-mutt-send-email-mst@kernel.org>
 <5eb3b349-bbae-6438-d8ea-7df82a7babb4@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
        kvm@vger.kernel.org, stephen@networkplumber.org, wexu@redhat.com,
        stefanha@redhat.com
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49164 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S967986AbdAJC5k (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 9 Jan 2017 21:57:40 -0500
Content-Disposition: inline
In-Reply-To: <5eb3b349-bbae-6438-d8ea-7df82a7babb4@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 10, 2017 at 10:22:42AM +0800, Jason Wang wrote:
> 
> 
> On 2017年01月10日 07:10, Michael S. Tsirkin wrote:
> > On Mon, Jan 09, 2017 at 10:59:16AM +0800, Jason Wang wrote:
> > > 
> > > On 2017年01月07日 03:55, Michael S. Tsirkin wrote:
> > > > On Fri, Jan 06, 2017 at 10:13:15AM +0800, Jason Wang wrote:
> > > > > This patch tries to do several tweaks on vhost_vq_avail_empty() for a
> > > > > better performance:
> > > > > 
> > > > > - check cached avail index first which could avoid userspace memory access.
> > > > > - using unlikely() for the failure of userspace access
> > > > > - check vq->last_avail_idx instead of cached avail index as the last
> > > > >     step.
> > > > > 
> > > > > This patch is need for batching supports which needs to peek whether
> > > > > or not there's still available buffers in the ring.
> > > > > 
> > > > > Reviewed-by: Stefan Hajnoczi <stefanha@redhat.com>
> > > > > Signed-off-by: Jason Wang <jasowang@redhat.com>
> > > > > ---
> > > > >    drivers/vhost/vhost.c | 8 ++++++--
> > > > >    1 file changed, 6 insertions(+), 2 deletions(-)
> > > > > 
> > > > > diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
> > > > > index d643260..9f11838 100644
> > > > > --- a/drivers/vhost/vhost.c
> > > > > +++ b/drivers/vhost/vhost.c
> > > > > @@ -2241,11 +2241,15 @@ bool vhost_vq_avail_empty(struct vhost_dev *dev, struct vhost_virtqueue *vq)
> > > > >    	__virtio16 avail_idx;
> > > > >    	int r;
> > > > > +	if (vq->avail_idx != vq->last_avail_idx)
> > > > > +		return false;
> > > > > +
> > > > >    	r = vhost_get_user(vq, avail_idx, &vq->avail->idx);
> > > > > -	if (r)
> > > > > +	if (unlikely(r))
> > > > >    		return false;
> > > > > +	vq->avail_idx = vhost16_to_cpu(vq, avail_idx);
> > > > > -	return vhost16_to_cpu(vq, avail_idx) == vq->avail_idx;
> > > > > +	return vq->avail_idx == vq->last_avail_idx;
> > > > >    }
> > > > >    EXPORT_SYMBOL_GPL(vhost_vq_avail_empty);
> > > > So again, this did not address the issue I pointed out in v1:
> > > > if we have 1 buffer in RX queue and
> > > > that is not enough to store the whole packet,
> > > > vhost_vq_avail_empty returns false, then we re-read
> > > > the descriptors again and again.
> > > > 
> > > > You have saved a single index access but not the more expensive
> > > > descriptor access.
> > > Looks not, if I understand the code correctly, in this case, get_rx_bufs()
> > > will return zero, and we will try to enable rx kick and exit the loop.
> > > 
> > > Thanks
> > I mean this:
> > 
> >                  while (vhost_can_busy_poll(vq->dev, endtime) &&
> >                         vhost_vq_avail_empty(vq->dev, vq))
> >                          cpu_relax();
> >                  preempt_enable();
> >                  r = vhost_get_vq_desc(vq, vq->iov, ARRAY_SIZE(vq->iov),
> >                                        out_num, in_num, NULL, NULL);
> > 
> > 
> > vhost_vq_avail_empty returns false so we break out of the loop
> > and call vhost_get_vq_desc.
> > 
> > 
> 
> But this is the code for polling tx vq not rx I think?
> 
> Thanks

Oh, right.
I'll re-read this.


-- 
MST
