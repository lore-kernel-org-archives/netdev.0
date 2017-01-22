From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net] virtio-net: restore VIRTIO_HDR_F_DATA_VALID on
 receiving
Date: Sun, 22 Jan 2017 06:22:33 +0200
Message-ID: <20170122061838-mutt-send-email-mst@kernel.org>
References: <1484893962-7614-1-git-send-email-jasowang@redhat.com>
 <20170120184220-mutt-send-email-mst@kernel.org>
 <268cadeb-433c-7960-5fe6-a06f849493a8@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        virtualization@lists.linux-foundation.org,
        Rolf Neugebauer <rolf.neugebauer@docker.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <268cadeb-433c-7960-5fe6-a06f849493a8@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jan 22, 2017 at 10:41:22AM +0800, Jason Wang wrote:
> 
> 
> On 2017年01月21日 00:45, Michael S. Tsirkin wrote:
> > On Fri, Jan 20, 2017 at 02:32:42PM +0800, Jason Wang wrote:
> > > Commit 501db511397f ("virtio: don't set VIRTIO_NET_HDR_F_DATA_VALID on
> > > xmit") in fact disables VIRTIO_HDR_F_DATA_VALID on receiving path too,
> > > fixing this by adding a hint (has_data_valid) and set it only on the
> > > receiving path.
> > > 
> > > Cc: Rolf Neugebauer<rolf.neugebauer@docker.com>
> > > Signed-off-by: Jason Wang<jasowang@redhat.com>
> > > ---
> > >   drivers/net/macvtap.c      | 2 +-
> > >   drivers/net/tun.c          | 2 +-
> > >   drivers/net/virtio_net.c   | 2 +-
> > >   include/linux/virtio_net.h | 6 +++++-
> > >   net/packet/af_packet.c     | 4 ++--
> > >   5 files changed, 10 insertions(+), 6 deletions(-)
> > > 
> > > diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
> > > index 5c26653..4026185 100644
> > > --- a/drivers/net/macvtap.c
> > > +++ b/drivers/net/macvtap.c
> > > @@ -825,7 +825,7 @@ static ssize_t macvtap_put_user(struct macvtap_queue *q,
> > >   			return -EINVAL;
> > >   		if (virtio_net_hdr_from_skb(skb, &vnet_hdr,
> > > -					    macvtap_is_little_endian(q)))
> > > +					    macvtap_is_little_endian(q), true))
> > >   			BUG();
> > >   		if (copy_to_iter(&vnet_hdr, sizeof(vnet_hdr), iter) !=
> > > diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> > > index cd8e02c..2cd10b2 100644
> > > --- a/drivers/net/tun.c
> > > +++ b/drivers/net/tun.c
> > > @@ -1360,7 +1360,7 @@ static ssize_t tun_put_user(struct tun_struct *tun,
> > >   			return -EINVAL;
> > >   		if (virtio_net_hdr_from_skb(skb, &gso,
> > > -					    tun_is_little_endian(tun))) {
> > > +					    tun_is_little_endian(tun), true)) {
> > >   			struct skb_shared_info *sinfo = skb_shinfo(skb);
> > >   			pr_err("unexpected GSO type: "
> > >   			       "0x%x, gso_size %d, hdr_len %d\n",
> > > diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> > > index 4a10500..3474243 100644
> > > --- a/drivers/net/virtio_net.c
> > > +++ b/drivers/net/virtio_net.c
> > > @@ -1104,7 +1104,7 @@ static int xmit_skb(struct send_queue *sq, struct sk_buff *skb)
> > >   		hdr = skb_vnet_hdr(skb);
> > >   	if (virtio_net_hdr_from_skb(skb, &hdr->hdr,
> > > -				    virtio_is_little_endian(vi->vdev)))
> > > +				    virtio_is_little_endian(vi->vdev), false))
> > >   		BUG();
> > >   	if (vi->mergeable_rx_bufs)
> > > diff --git a/include/linux/virtio_net.h b/include/linux/virtio_net.h
> > > index 5643647..5209b5e 100644
> > > --- a/include/linux/virtio_net.h
> > > +++ b/include/linux/virtio_net.h
> > > @@ -56,7 +56,8 @@ static inline int virtio_net_hdr_to_skb(struct sk_buff *skb,
> > >   static inline int virtio_net_hdr_from_skb(const struct sk_buff *skb,
> > >   					  struct virtio_net_hdr *hdr,
> > > -					  bool little_endian)
> > > +					  bool little_endian,
> > > +					  bool has_data_valid)
> > >   {
> > >   	memset(hdr, 0, sizeof(*hdr));   /* no info leak */
> > I would prefer naming it is_rx. Callers should not know about
> > internal details like data valid, the issue we are trying to fix
> > here is that tx and tx headers are slightly different.
> > 
> 
> Actually, I've considered something like this, but the problem is:
> 
> - tun use this on xmit, so is_rx = true may cause some confusion here

tun is generally weird, yes. how about rx_format?

> - I believe we may want to support DATA_VALID (like xen-netback) on tx
> (probably with a feature) in the future.
> 
> Thanks

We'll put that knowledge within virtio_net_hdr_from_skb not
in the callers I think.

-- 
MST
