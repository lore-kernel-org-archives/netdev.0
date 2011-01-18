From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH 1/3] vhost-net: check the support of mergeable buffer
 outside the receive loop
Date: Tue, 18 Jan 2011 12:26:17 +0800
Message-ID: <19765.5737.352179.50100@gargle.gargle.HOWL>
References: <20110117081058.18900.67456.stgit@dhcp-91-7.nay.redhat.com.englab.nay.redhat.com>
	<20110117084644.GB23479@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Jason Wang <jasowang@redhat.com>, virtualization@lists.osdl.org,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110117084644.GB23479@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael S. Tsirkin writes:
 > On Mon, Jan 17, 2011 at 04:10:59PM +0800, Jason Wang wrote:
 > > No need to check the support of mergeable buffer inside the recevie
 > > loop as the whole handle_rx()_xx is in the read critical region.  So
 > > this patch move it ahead of the receiving loop.
 > > 
 > > Signed-off-by: Jason Wang <jasowang@redhat.com>
 > 
 > Well feature check is mostly just features & bit
 > so why would it be slower? Because of the rcu
 > adding memory barriers? Do you observe a
 > measureable speedup with this patch?
 > 

I do not measure the performance for just this patch, maybe not obvious. And it
can also help the code unification.

 > Apropos, I noticed that the check in vhost_has_feature
 > is wrong: it uses the same kind of RCU as the
 > private pointer. So we'll have to fix that properly
 > by adding more lockdep classes, but for now
 > we'll need to make
 > the check 1 || lockdep_is_held(&dev->mutex);
 > and add a TODO.
 > 

Not sure, lockdep_is_head(&dev->mutex) maybe not accurate but sufficient, as it
was always held in the read critical region.

 > > ---
 > >  drivers/vhost/net.c |    5 +++--
 > >  1 files changed, 3 insertions(+), 2 deletions(-)
 > > 
 > > diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
 > > index 14fc189..95e49de 100644
 > > --- a/drivers/vhost/net.c
 > > +++ b/drivers/vhost/net.c
 > > @@ -411,7 +411,7 @@ static void handle_rx_mergeable(struct vhost_net *net)
 > >  	};
 > >  
 > >  	size_t total_len = 0;
 > > -	int err, headcount;
 > > +	int err, headcount, mergeable;
 > >  	size_t vhost_hlen, sock_hlen;
 > >  	size_t vhost_len, sock_len;
 > >  	struct socket *sock = rcu_dereference(vq->private_data);
 > > @@ -425,6 +425,7 @@ static void handle_rx_mergeable(struct vhost_net *net)
 > >  
 > >  	vq_log = unlikely(vhost_has_feature(&net->dev, VHOST_F_LOG_ALL)) ?
 > >  		vq->log : NULL;
 > > +	mergeable = vhost_has_feature(&net->dev, VIRTIO_NET_F_MRG_RXBUF);
 > >  
 > >  	while ((sock_len = peek_head_len(sock->sk))) {
 > >  		sock_len += sock_hlen;
 > > @@ -474,7 +475,7 @@ static void handle_rx_mergeable(struct vhost_net *net)
 > >  			break;
 > >  		}
 > >  		/* TODO: Should check and handle checksum. */
 > > -		if (vhost_has_feature(&net->dev, VIRTIO_NET_F_MRG_RXBUF) &&
 > > +		if (likely(mergeable) &&
 > >  		    memcpy_toiovecend(vq->hdr, (unsigned char *)&headcount,
 > >  				      offsetof(typeof(hdr), num_buffers),
 > >  				      sizeof hdr.num_buffers)) {
