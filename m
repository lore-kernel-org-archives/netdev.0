From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: [ofa-general] Re: [PATCH 2/9 Rev3] [core] Add skb_blist &
	hard_start_xmit_batch
Date: Thu, 9 Aug 2007 08:39:03 +0530
Message-ID: <OFE8554133.9693A4CA-ON65257332.000F5EB3-65257332.00114F06@in.ibm.com>
References: <20070808120142.GA26884@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: jagana@us.ibm.com, mcarlson@broadcom.com, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, Robert.Olsson@data.slu.se,
	kumarkr@linux.ibm.com, rdreier@cisco.com,
	peter.p.waskiewicz.jr@intel.com, hadi@cyberus.ca,
	kaber@trash.net, jeff@garzik.org, general@lists.openfabrics.org,
	mchan@broadcom.com, tgraf@suug.ch, netdev@vger.kernel.org,
	shemminger@linux-foundation.org, davem@davemloft.net, sri@us.ibm.com
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20070808120142.GA26884@2ka.mipt.ru>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

Hi Evgeniy,

Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote on 08/08/2007 05:31:43 PM:

> > +int dev_change_tx_batch_skb(struct net_device *dev, unsigned long
new_batch_skb)
> > +{
> > +   int ret = 0;
> > +   struct sk_buff_head *blist;
> > +
> > +   if (!dev->hard_start_xmit_batch) {
> > +      /* Driver doesn't support batching skb API */
> > +      ret = -ENOTSUPP;
> > +      goto out;
> > +   }
> > +
> > +   /* Handle invalid argument */
> > +   if (new_batch_skb < 0) {
> > +      ret = -EINVAL;
> > +      goto out;
> > +   }
> It is unsigned, how can it be less than zero?

Yuck, originally I had it as int and changed to ulong and forgot to
remove this check.

> And actually you use it just like a binary flag (casted to/from u32 in
> the code, btw), so why not using ethtool_value directly here?

I still need to check if the value is changing, so the one check is needed.
Later I am using it as a value directly.

> > +   /* Check if new value is same as the current */
> > +   if (!!dev->skb_blist == !!new_batch_skb)
> > +      goto out;
> > +
> > +   if (new_batch_skb &&
> > +       (blist = kmalloc(sizeof *blist, GFP_KERNEL)) == NULL) {
> > +      ret = -ENOMEM;
> > +      goto out;
> > +   }
> > +
> > +   spin_lock(&dev->queue_lock);
> > +   if (new_batch_skb) {
> > +      skb_queue_head_init(blist);
> > +      dev->skb_blist = blist;
> > +   } else
> > +      free_batching(dev);
> > +   spin_unlock(&dev->queue_lock);
>
> This needs bh lock too, since blist is accessed by qdisc_restart.

Yes, had it in the code, put it in the list of changes, but missed it for
some reason :(

> > +int dev_add_skb_to_blist(struct sk_buff *skb, struct net_device *dev)
> > +{
> > +   if (!list_empty(&ptype_all))
> > +      dev_queue_xmit_nit(skb, dev);
> > +
> > +   if (netif_needs_gso(dev, skb)) {
> > +      if (unlikely(dev_gso_segment(skb))) {
> > +         kfree(skb);
> > +         return 0;
> > +      }
> > +
> > +      if (skb->next) {
> > +         int count = 0;
> > +
> > +         do {
> > +            struct sk_buff *nskb = skb->next;
> > +
> > +            skb->next = nskb->next;
> > +            __skb_queue_tail(dev->skb_blist, nskb);
> > +            count++;
> > +         } while (skb->next);
>
> Is it possible to move list without iterating over each entry?

Though I cannot see something obvious to do that, let me see if
something is possible as it will make a good difference.

thanks for your suggestions,

- KK
