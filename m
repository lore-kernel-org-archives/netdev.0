From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] virtio-net: put virtio net header inline with data
Date: Sun, 9 Jun 2013 09:52:49 +0300
Message-ID: <20130609065249.GB13082@redhat.com>
References: <20130606095456.GA7865@redhat.com>
 <51B14AD1.8000004@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <amwang@redhat.com>, qemu-devel@nongnu.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, Dave Jones <davej@redhat.com>,
	"David S. Miller" <davem@davemloft.net>
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <51B14AD1.8000004@redhat.com>
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

On Fri, Jun 07, 2013 at 10:52:01AM +0800, Jason Wang wrote:
> On 06/06/2013 05:55 PM, Michael S. Tsirkin wrote:
> > For small packets we can simplify xmit processing by linearizing buffers
> > with the header: most packets seem to have enough head room we can use
> > for this purpose.
> >
> > Since some older hypervisors (e.g. qemu before version 1.5)
> > required that header is the first s/g element,
> > we need a feature bit for this.
> >
> > Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> > ---
> 
> Hi Michael:
> 
> The idea looks good, but there are some questions:
> 
> - What if we just use direct descriptors with sgs <=2 and double the
> ring size?

It's not easy to increase the ring size, we have trouble allocating
large rings on some systems as it is.
So far, any attempts to use direct for sg > 1 seem to hurt some
workloads.

> - I believe we may add more things into vnet header in the future, so
> this trick may not work because of limited header room.
> 
> Thanks

Didn't happen in a long while.
We can come up with more tricks when we run against this limit.

> > This is a repost of my old patch, rebased to latest kernel.
> >
> > Before:
> > Thu Jun  6 05:24:59 EDT 2013
> > TCP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
> > 11.0.0.4 (11.0.0.4) port 0 AF_INET : demo
> > Local /Remote
> > Socket Size   Request  Resp.   Elapsed  Trans.
> > Send   Recv   Size     Size    Time     Rate         
> > bytes  Bytes  bytes    bytes   secs.    per sec   
> >
> > 16384  87380  1        1       10.00    12931.13   
> >
> >
> > After:
> > TCP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
> > 11.0.0.4 (11.0.0.4) port 0 AF_INET : demo
> > Local /Remote
> > Socket Size   Request  Resp.   Elapsed  Trans.
> > Send   Recv   Size     Size    Time     Rate         
> > bytes  Bytes  bytes    bytes   secs.    per sec   
> >
> > 16384  87380  1        1       10.00    14151.12
> >
> >
> >  drivers/net/virtio_net.c        | 42 +++++++++++++++++++++++++++++++++--------
> >  include/uapi/linux/virtio_net.h |  6 +++++-
> >  2 files changed, 39 insertions(+), 9 deletions(-)
> >
> > diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> > index c9e0038..d35a097 100644
> > --- a/drivers/net/virtio_net.c
> > +++ b/drivers/net/virtio_net.c
> > @@ -106,6 +106,9 @@ struct virtnet_info {
> >  	/* Has control virtqueue */
> >  	bool has_cvq;
> >  
> > +	/* Host can handle any s/g split between our header and packet data */
> > +	bool any_header_sg;
> > +
> >  	/* enable config space updates */
> >  	bool config_enable;
> >  
> > @@ -668,12 +671,28 @@ static void free_old_xmit_skbs(struct send_queue *sq)
> >  
> >  static int xmit_skb(struct send_queue *sq, struct sk_buff *skb)
> >  {
> > -	struct skb_vnet_hdr *hdr = skb_vnet_hdr(skb);
> > +	struct skb_vnet_hdr *hdr;
> >  	const unsigned char *dest = ((struct ethhdr *)skb->data)->h_dest;
> >  	struct virtnet_info *vi = sq->vq->vdev->priv;
> >  	unsigned num_sg;
> > +	unsigned hdr_len;
> > +	bool can_push;
> >  
> >  	pr_debug("%s: xmit %p %pM\n", vi->dev->name, skb, dest);
> > +	if (vi->mergeable_rx_bufs)
> > +		hdr_len = sizeof hdr->mhdr;
> > +	else
> > +		hdr_len = sizeof hdr->hdr;
> > +
> > +	can_push = vi->any_header_sg &&
> > +		!((unsigned long)skb->data & (__alignof__(*hdr) - 1)) &&
> > +		!skb_header_cloned(skb) && skb_headroom(skb) >= hdr_len;
> > +	/* Even if we can, don't push here yet as this would skew
> > +	 * csum_start offset below. */
> > +	if (can_push)
> > +		hdr = (struct skb_vnet_hdr *)(skb->data - hdr_len);
> > +	else
> > +		hdr = skb_vnet_hdr(skb);
> >  
> >  	if (skb->ip_summed == CHECKSUM_PARTIAL) {
> >  		hdr->hdr.flags = VIRTIO_NET_HDR_F_NEEDS_CSUM;
> > @@ -702,15 +721,18 @@ static int xmit_skb(struct send_queue *sq, struct sk_buff *skb)
> >  		hdr->hdr.gso_size = hdr->hdr.hdr_len = 0;
> >  	}
> >  
> > -	hdr->mhdr.num_buffers = 0;
> > -
> > -	/* Encode metadata header at front. */
> >  	if (vi->mergeable_rx_bufs)
> > -		sg_set_buf(sq->sg, &hdr->mhdr, sizeof hdr->mhdr);
> > -	else
> > -		sg_set_buf(sq->sg, &hdr->hdr, sizeof hdr->hdr);
> > +		hdr->mhdr.num_buffers = 0;
> >  
> > -	num_sg = skb_to_sgvec(skb, sq->sg + 1, 0, skb->len) + 1;
> > +	if (can_push) {
> > +		__skb_push(skb, hdr_len);
> > +		num_sg = skb_to_sgvec(skb, sq->sg, 0, skb->len);
> > +		/* Pull header back to avoid skew in tx bytes calculations. */
> > +		__skb_pull(skb, hdr_len);
> > +	} else {
> > +		sg_set_buf(sq->sg, hdr, hdr_len);
> > +		num_sg = skb_to_sgvec(skb, sq->sg + 1, 0, skb->len) + 1;
> > +	}
> >  	return virtqueue_add_outbuf(sq->vq, sq->sg, num_sg, skb, GFP_ATOMIC);
> >  }
> >  
> > @@ -1554,6 +1576,9 @@ static int virtnet_probe(struct virtio_device *vdev)
> >  	if (virtio_has_feature(vdev, VIRTIO_NET_F_MRG_RXBUF))
> >  		vi->mergeable_rx_bufs = true;
> >  
> > +	if (virtio_has_feature(vdev, VIRTIO_NET_F_ANY_HEADER_SG))
> > +		vi->any_header_sg = true;
> > +
> >  	if (virtio_has_feature(vdev, VIRTIO_NET_F_CTRL_VQ))
> >  		vi->has_cvq = true;
> >  
> > @@ -1729,6 +1754,7 @@ static unsigned int features[] = {
> >  	VIRTIO_NET_F_CTRL_RX, VIRTIO_NET_F_CTRL_VLAN,
> >  	VIRTIO_NET_F_GUEST_ANNOUNCE, VIRTIO_NET_F_MQ,
> >  	VIRTIO_NET_F_CTRL_MAC_ADDR,
> > +	VIRTIO_NET_F_ANY_HEADER_SG,
> >  };
> >  
> >  static struct virtio_driver virtio_net_driver = {
> > diff --git a/include/uapi/linux/virtio_net.h b/include/uapi/linux/virtio_net.h
> > index c520203..9c98b7d 100644
> > --- a/include/uapi/linux/virtio_net.h
> > +++ b/include/uapi/linux/virtio_net.h
> > @@ -55,6 +55,8 @@
> >  					 * Steering */
> >  #define VIRTIO_NET_F_CTRL_MAC_ADDR 23	/* Set MAC address */
> >  
> > +#define VIRTIO_NET_F_ANY_HEADER_SG 25	/* Host can handle any header s/g */
> > +
> >  #define VIRTIO_NET_S_LINK_UP	1	/* Link is up */
> >  #define VIRTIO_NET_S_ANNOUNCE	2	/* Announcement is needed */
> >  
> > @@ -70,7 +72,9 @@ struct virtio_net_config {
> >  	__u16 max_virtqueue_pairs;
> >  } __attribute__((packed));
> >  
> > -/* This is the first element of the scatter-gather list.  If you don't
> > +/* This header comes first in the scatter-gather list.
> > + * If VIRTIO_NET_F_ANY_HEADER_SG is not negotiated, it must
> > + * be the first element of the scatter-gather list.  If you don't
> >   * specify GSO or CSUM features, you can simply ignore the header. */
> >  struct virtio_net_hdr {
> >  #define VIRTIO_NET_HDR_F_NEEDS_CSUM	1	// Use csum_start, csum_offset
