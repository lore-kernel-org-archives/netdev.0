From: Benjamin Poirier <bpoirier@suse.de>
Subject: Re: [PATCH 2/3] tg3: Fix tx_pending checks for tg3_tso_bug
Date: Wed, 20 Aug 2014 18:23:03 -0700
Message-ID: <20140821012303.GA15440@f1.synalogic.ca>
References: <1408474371-19509-1-git-send-email-bpoirier@suse.de>
 <1408474371-19509-2-git-send-email-bpoirier@suse.de>
 <1408489852.7404.60.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Prashant Sreedharan <prashant@broadcom.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Michael Chan <mchan@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1408489852.7404.60.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2014/08/19 16:10, Michael Chan wrote:
> On Tue, 2014-08-19 at 11:52 -0700, Benjamin Poirier wrote: 
> > @@ -7838,11 +7838,14 @@ static int tg3_tso_bug(struct tg3 *tp, struct tg3_napi *tnapi,
> >                        struct netdev_queue *txq, struct sk_buff *skb)
> >  {
> >         struct sk_buff *segs, *nskb;
> > -       u32 frag_cnt_est = skb_shinfo(skb)->gso_segs * 3;
> >  
> > -       /* Estimate the number of fragments in the worst case */
> > -       if (unlikely(tg3_tx_avail(tnapi) <= frag_cnt_est)) {
> > +       if (unlikely(tg3_tx_avail(tnapi) <= skb_shinfo(skb)->gso_segs)) {
> > +               trace_printk("stopping queue, %d <= %d\n",
> > +                            tg3_tx_avail(tnapi), skb_shinfo(skb)->gso_segs);
> >                 netif_tx_stop_queue(txq);
> > +               trace_printk("stopped queue\n");
> > +               tnapi->wakeup_thresh = skb_shinfo(skb)->gso_segs;
> > +               BUG_ON(tnapi->wakeup_thresh >= tnapi->tx_pending);
> >  
> >                 /* netif_tx_stop_queue() must be done before checking
> >                  * checking tx index in tg3_tx_avail() below, because in 
> 
> I don't quite understand this logic and I must be missing something.
> gso_segs is the number of TCP segments the large packet will be broken
> up into.  If it exceeds dev->gso_max_segs, it means it exceeds
> hardware's capabilty and it will do GSO instead of TSO.  But in this
> case in tg3_tso_bug(), we are doing GSO and we may not have enough DMA
> descriptors to do GSO.  Each gso_seg typically requires 2 DMA
> descriptors.

You're right, I had wrongly assumed that the skbs coming out of
skb_gso_segment() were linear. I'll address that in v2 of the patch by masking
out NETIF_F_SG in tg3_tso_bug().

I noticed another issue that had not occurred to me: when tg3_tso_bug is
submitting a full gso segs sequence to tg3_start_xmit, the code at the end of
that function stops the queue before the end of the sequence because tx_avail
becomes smaller than (MAX_SKB_FRAGS + 1). The transmission actually proceeds
because tg3_tso_bug() does not honour the queue state but it seems rather
unsightly to me. I'm trying different solutions to this and will resubmit.
