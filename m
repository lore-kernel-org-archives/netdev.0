From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH V5 4/6 net-next] vhost: vhost TX zero-copy support
Date: Tue, 17 May 2011 00:27:54 +0300
Message-ID: <20110516212754.GG18148@redhat.com>
References: <1305574484.3456.30.camel@localhost.localdomain>
 <20110516204540.GD18148@redhat.com>
 <1305579414.3456.49.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Avi Kivity <avi@redhat.com>, Arnd Bergmann <arnd@arndb.de>,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1305579414.3456.49.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 16, 2011 at 01:56:54PM -0700, Shirley Ma wrote:
> On Mon, 2011-05-16 at 23:45 +0300, Michael S. Tsirkin wrote:
> > > +/* Since we need to keep the order of used_idx as avail_idx, it's
> > possible that
> > > + * DMA done not in order in lower device driver for some reason. To
> > prevent
> > > + * used_idx out of order, upend_idx is used to track avail_idx
> > order, done_idx
> > > + * is used to track used_idx order. Once lower device DMA done,
> > then upend_idx
> > > + * can move to done_idx.
> > 
> > Could you clarify this please? virtio explicitly allows out of order
> > completion of requests. Does it simplify code that we try to keep
> > used index updates in-order? Because if not, this is not
> > really a requirement.
> 
> Hello Mike,
> 
> Based on my testing, vhost_add_used() must be in order from
> vhost_get_vq_desc(). Otherwise, virtio_net ring seems get double
> freed. I didn't spend time on debugging this.
> 
> in virtqueue_get_buf
> 
>         if (unlikely(!vq->data[i])) {
>                 BAD_RING(vq, "id %u is not a head!\n", i);
>                 return NULL;
>         }
> 
> That's the reason I created the upend_idx and done_idx.
> 
> Thanks
> Shirley

One thing of note: it's possible that this actually works
better than trying to complete out of order, as the
ring just keeps going which should be good for cache
utilization. OTOH, this might explain why
you are over-running the TX ring much more with this patch.

So I don't say this should block merging the patch,
but I very much would like to understand the issue,
and it's interesting to experiment with fixing it
and seeing what it does to performance and to code size.

-- 
MST
