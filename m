From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH V5 4/6 net-next] vhost: vhost TX zero-copy support
Date: Tue, 17 May 2011 08:55:03 +0300
Message-ID: <20110517055503.GA26989@redhat.com>
References: <1305574484.3456.30.camel@localhost.localdomain>
 <20110516204540.GD18148@redhat.com>
 <1305579414.3456.49.camel@localhost.localdomain>
 <20110516212401.GF18148@redhat.com>
 <1305606683.10756.3.camel@localhost.localdomain>
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
In-Reply-To: <1305606683.10756.3.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 16, 2011 at 09:31:23PM -0700, Shirley Ma wrote:
> On Tue, 2011-05-17 at 00:24 +0300, Michael S. Tsirkin wrote:
> > On Mon, May 16, 2011 at 01:56:54PM -0700, Shirley Ma wrote:
> > > On Mon, 2011-05-16 at 23:45 +0300, Michael S. Tsirkin wrote:
> > > > > +/* Since we need to keep the order of used_idx as avail_idx,
> > it's
> > > > possible that
> > > > > + * DMA done not in order in lower device driver for some
> > reason. To
> > > > prevent
> > > > > + * used_idx out of order, upend_idx is used to track avail_idx
> > > > order, done_idx
> > > > > + * is used to track used_idx order. Once lower device DMA done,
> > > > then upend_idx
> > > > > + * can move to done_idx.
> > > > 
> > > > Could you clarify this please? virtio explicitly allows out of
> > order
> > > > completion of requests. Does it simplify code that we try to keep
> > > > used index updates in-order? Because if not, this is not
> > > > really a requirement.
> > > 
> > > Hello Mike,
> > > 
> > > Based on my testing, vhost_add_used() must be in order from
> > > vhost_get_vq_desc(). Otherwise, virtio_net ring seems get double
> > > freed.
> > 
> > Double-freed or you get NULL below?
> 
> More likely is NULL.
> 
> > > I didn't spend time on debugging this.
> > > 
> > > in virtqueue_get_buf
> > > 
> > >         if (unlikely(!vq->data[i])) {
> > >                 BAD_RING(vq, "id %u is not a head!\n", i);
> > >                 return NULL;
> > >         }
> > 
> > Yes but i used here is the head that we read from the
> > ring, not the ring index itself.
> >         i = vq->vring.used->ring[vq->last_used_idx%vq->vring.num].id
> > we must complete any id only once, but in any order.
> 
> It is in any order of ring id, but must be in the order of "head"
> returns  from  vhost_get_vq_desc(), any clue?
> 
> 
> Thanks
> Shirley


Something in your patch that overwrites the id in vhost
and makes it put the wrong id in the used ring?

By the way, need to keep in mind that a guest can
give us the same head twice, need to make sure this
at least does not corrupt host memory.

-- 
MST
