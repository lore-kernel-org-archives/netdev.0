From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH RFC] ptr_ring: add ptr_ring_unconsume
Date: Tue, 25 Apr 2017 18:35:53 +0300
Message-ID: <20170425182222-mutt-send-email-mst@kernel.org>
References: <1492384496-22644-1-git-send-email-mst@redhat.com>
 <0defb746-3d4b-14b3-1ad7-82842048ebba@redhat.com>
 <20170424022711-mutt-send-email-mst@kernel.org>
 <21a19608-40be-38d4-9843-088a273fd71a@redhat.com>
 <20170424145632-mutt-send-email-mst@kernel.org>
 <91ae69e6-4dac-3db2-4778-c4163dfe6f91@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55724 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1950167AbdDYPf7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 25 Apr 2017 11:35:59 -0400
Content-Disposition: inline
In-Reply-To: <91ae69e6-4dac-3db2-4778-c4163dfe6f91@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 25, 2017 at 12:07:01PM +0800, Jason Wang wrote:
> 
> 
> On 2017年04月24日 20:00, Michael S. Tsirkin wrote:
> > On Mon, Apr 24, 2017 at 07:54:18PM +0800, Jason Wang wrote:
> > > On 2017年04月24日 07:28, Michael S. Tsirkin wrote:
> > > > On Tue, Apr 18, 2017 at 11:07:42AM +0800, Jason Wang wrote:
> > > > > On 2017年04月17日 07:19, Michael S. Tsirkin wrote:
> > > > > > Applications that consume a batch of entries in one go
> > > > > > can benefit from ability to return some of them back
> > > > > > into the ring.
> > > > > > 
> > > > > > Add an API for that - assuming there's space. If there's no space
> > > > > > naturally we can't do this and have to drop entries, but this implies
> > > > > > ring is full so we'd likely drop some anyway.
> > > > > > 
> > > > > > Signed-off-by: Michael S. Tsirkin<mst@redhat.com>
> > > > > > ---
> > > > > > 
> > > > > > Jason, in my mind the biggest issue with your batching patchset is the
> > > > > > backet drops on disconnect.  This API will help avoid that in the common
> > > > > > case.
> > > > > Ok, I will rebase the series on top of this. (Though I don't think we care
> > > > > the packet loss).
> > > > E.g. I care - I often start sending packets to VM before it's
> > > > fully booted. Several vhost resets might follow.
> > > Ok.
> > > 
> > > > > > I would still prefer that we understand what's going on,
> > > > > I try to reply in another thread, does it make sense?
> > > > > 
> > > > > >     and I would
> > > > > > like to know what's the smallest batch size that's still helpful,
> > > > > Yes, I've replied in another thread, the result is:
> > > > > 
> > > > > 
> > > > > no batching   1.88Mpps
> > > > > RX_BATCH=1    1.93Mpps
> > > > > RX_BATCH=4    2.11Mpps
> > > > > RX_BATCH=16   2.14Mpps
> > > > > RX_BATCH=64   2.25Mpps
> > > > > RX_BATCH=256  2.18Mpps
> > > > Essentially 4 is enough, other stuf looks more like noise
> > > > to me. What about 2?
> > > The numbers are pretty stable, so probably not noise. Retested on top of
> > > batch zeroing:
> > > 
> > > no  1.97Mpps
> > > 1   2.09Mpps
> > > 2   2.11Mpps
> > > 4   2.16Mpps
> > > 8   2.19Mpps
> > > 16  2.21Mpps
> > > 32  2.25Mpps
> > > 64  2.30Mpps
> > > 128 2.21Mpps
> > > 256 2.21Mpps
> > > 
> > > 64 performs best.
> > > 
> > > Thanks
> > OK but it might be e.g. a function of the ring size, host cache size or
> > whatever. As we don't really understand the why, if we just optimize for
> > your setup we risk regressions in others.  64 entries is a lot, it
> > increases the queue size noticeably.  Could this be part of the effect?
> > Could you try changing the queue size to see what happens?
> 
> I increase tx_queue_len to 1100, but only see less than 1% improvement on
> pps number (batch = 1) in my machine. If you care about the regression, we
> probably can leave the choice to user through e.g module parameter. But I'm
> afraid we have already had too much choices for them. Or I can test this
> with different CPU types.
> 
> Thanks
> 

I agree here. Let's keep it a constant. Testing on more machines would
be nice but not strictly required.  I just dislike not understanding why
it helps because it means we can easily break it by mistake.  So my only
request really is that you wrap access to this internal buffer in an
API. Let's see - I think we need

struct vhost_net_buf
vhost_net_buf_get_ptr
vhost_net_buf_get_size
vhost_net_buf_is_empty
vhost_net_buf_peek
vhost_net_buf_consume
vhost_net_buf_produce



-- 
MST
