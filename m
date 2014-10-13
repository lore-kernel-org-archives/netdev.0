From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next RFC 1/3] virtio: support for urgent descriptors
Date: Mon, 13 Oct 2014 10:16:19 +0300
Message-ID: <20141013071619.GA10178@redhat.com>
References: <1413011806-3813-1-git-send-email-jasowang@redhat.com>
	<1413011806-3813-2-git-send-email-jasowang@redhat.com>
	<20141012092744.GA9567@redhat.com> <543B6F94.2090107@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, linux-api@vger.kernel.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <543B6F94.2090107@redhat.com>
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

On Mon, Oct 13, 2014 at 02:22:12PM +0800, Jason Wang wrote:
> On 10/12/2014 05:27 PM, Michael S. Tsirkin wrote:
> > On Sat, Oct 11, 2014 at 03:16:44PM +0800, Jason Wang wrote:
> >> Below should be useful for some experiments Jason is doing.
> >> I thought I'd send it out for early review/feedback.
> >>
> >> event idx feature allows us to defer interrupts until
> >> a specific # of descriptors were used.
> >> Sometimes it might be useful to get an interrupt after
> >> a specific descriptor, regardless.
> >> This adds a descriptor flag for this, and an API
> >> to create an urgent output descriptor.
> >> This is still an RFC:
> >> we'll need a feature bit for drivers to detect this,
> >> but we've run out of feature bits for virtio 0.X.
> >> For experimentation purposes, drivers can assume
> >> this is set, or add a driver-specific feature bit.
> >>
> >> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> >> Signed-off-by: Jason Wang <jasowang@redhat.com>
> > I see that as compared to my original patch, you have
> > added a new flag: VRING_AVAIL_F_NO_URGENT_INTERRUPT
> > I don't think it's necessary, see below.
> >
> > As such, I think this patch should be split:
> > - original patch adding support for urgent descriptors
> > - a patch adding virtqueue_enable/disable_cb_urgent(_prepare)?
> 
> Not sure this is a good idea, since the api of first patch is in-completed.
> >
> >> ---
> >>  drivers/virtio/virtio_ring.c     | 75 +++++++++++++++++++++++++++++++++++++---
> >>  include/linux/virtio.h           | 14 ++++++++
> >>  include/uapi/linux/virtio_ring.h |  5 ++-
> >>  3 files changed, 89 insertions(+), 5 deletions(-)
> >>
> [...]
> >>  
> >> +unsigned virtqueue_enable_cb_prepare_urgent(struct virtqueue *_vq)
> >> +{
> >> +	struct vring_virtqueue *vq = to_vvq(_vq);
> >> +	u16 last_used_idx;
> >> +
> >> +	START_USE(vq);
> >> +	vq->vring.avail->flags &= ~VRING_AVAIL_F_NO_URGENT_INTERRUPT;
> >> +	last_used_idx = vq->last_used_idx;
> >> +	END_USE(vq);
> >> +	return last_used_idx;
> >> +}
> >> +EXPORT_SYMBOL_GPL(virtqueue_enable_cb_prepare_urgent);
> >> +
> > You can implement virtqueue_enable_cb_prepare_urgent
> > simply by clearing ~VRING_AVAIL_F_NO_INTERRUPT.
> >
> > The effect is same: host sends interrupts only if there
> > is an urgent descriptor.
> 
> Seems not, consider the case when event index was disabled. This will
> turn on all interrupts.

This means that a legacy device without event index support
will get more interrupts.
Sounds reasonable.

-- 
MST
