From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: Network performance with small packets - continued
Date: Wed, 9 Mar 2011 18:32:01 +0200
Message-ID: <20110309163201.GC7165@redhat.com>
References: <201103071631.41964.tahm@linux.vnet.ibm.com>
 <20110309071558.GA25757@redhat.com>
 <1299685543.25664.97.camel@localhost.localdomain>
 <20110309161013.GA7165@redhat.com>
 <1299687934.25664.108.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	Krishna Kumar2 <krkumar2@in.ibm.com>,
	David Miller <davem@davemloft.net>, kvm@vger.kernel.org,
	netdev@vger.kernel.org, steved@us.ibm.com,
	Tom Lendacky <tahm@linux.vnet.ibm.com>
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1299687934.25664.108.camel@localhost.localdomain>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 09, 2011 at 08:25:34AM -0800, Shirley Ma wrote:
> On Wed, 2011-03-09 at 18:10 +0200, Michael S. Tsirkin wrote:
> > 
> > diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> > index 82dba5a..4477b9a 100644
> > --- a/drivers/net/virtio_net.c
> > +++ b/drivers/net/virtio_net.c
> > @@ -514,11 +514,11 @@ static unsigned int free_old_xmit_skbs(struct
> > virtnet_info *vi)
> >         struct sk_buff *skb;
> >         unsigned int len, tot_sgs = 0;
> > 
> > -       while ((skb = virtqueue_get_buf(vi->svq, &len)) != NULL) {
> > +       if ((skb = virtqueue_get_buf(vi->svq, &len)) != NULL) {
> >                 pr_debug("Sent skb %p\n", skb);
> >                 vi->dev->stats.tx_bytes += skb->len;
> >                 vi->dev->stats.tx_packets++;
> > -               tot_sgs += skb_vnet_hdr(skb)->num_sg;
> > +               tot_sgs = 2+MAX_SKB_FRAGS;
> >                 dev_kfree_skb_any(skb);
> >         }
> >         return tot_sgs;
> > @@ -576,7 +576,7 @@ static netdev_tx_t start_xmit(struct sk_buff *skb,
> > struct net_device *dev)
> >         struct virtnet_info *vi = netdev_priv(dev);
> >         int capacity;
> > 
> > -       /* Free up any pending old buffers before queueing new ones.
> > */
> > +       /* Free up any old buffers so we can queue new ones. */
> >         free_old_xmit_skbs(vi);
> > 
> >         /* Try to transmit */
> > @@ -605,6 +605,10 @@ static netdev_tx_t start_xmit(struct sk_buff
> > *skb, struct net_device *dev)
> >         skb_orphan(skb);
> >         nf_reset(skb);
> > 
> > +       /* Free up any old buffers so we can queue new ones. */
> > +       if (capacity < 2+MAX_SKB_FRAGS)
> > +               capacity += free_old_xmit_skbs(vi);
> > +
> >         /* Apparently nice girls don't return TX_BUSY; stop the queue
> >          * before it gets out of hand.  Naturally, this wastes
> > entries. */
> >         if (capacity < 2+MAX_SKB_FRAGS) {
> > -- 
> 
> I tried this one as well. It might improve TCP_RR performance but not
> TCP_STREAM. :) Let's wait for Tom's TCP_RR resutls.
> 
> Thanks
> Shirley

I think your issues are with TX overrun.
Besides delaying IRQ on TX, I don't have many ideas.

The one interesting thing is that you see better speed
if you drop packets. netdev crowd says this should not happen,
so could be an indicator of a problem somewhere.


-- 
MST
