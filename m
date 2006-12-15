From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 3/3] chelsio: more receive cleanup
Date: Fri, 15 Dec 2006 14:55:33 -0800
Message-ID: <20061215145533.4cda3f23@freekitty>
References: <20061215190716.956791000@osdl.org>
	<20061215190813.803776000@osdl.org>
	<20061215201019.GA11385@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:51922 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030329AbWLOW4B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Dec 2006 17:56:01 -0500
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20061215201019.GA11385@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 15 Dec 2006 21:10:19 +0100
Francois Romieu <romieu@fr.zoreil.com> wrote:

> Stephen Hemminger <shemminger@osdl.org> :
> [...]
> > --- linux-2.6.20-rc1.orig/drivers/net/chelsio/sge.c
> > +++ linux-2.6.20-rc1/drivers/net/chelsio/sge.c
> [...]
> > @@ -1059,37 +1062,33 @@ static void recycle_fl_buf(struct freelQ
> >   *	threshold and the packet is too big to copy, or (b) the packet should
> >   *	be copied but there is no memory for the copy.
> >   */
> > -static inline struct sk_buff *get_packet(struct pci_dev *pdev,
> > -					 struct freelQ *fl, unsigned int len,
> > -					 int dma_pad, int skb_pad,
> > -					 unsigned int copy_thres,
> > -					 unsigned int drop_thres)
> > +static inline struct sk_buff *get_packet(struct pci_dev *pdev, struct freelQ *fl,
> > +					 unsigned int len)
> >  {
> >  	struct sk_buff *skb;
> > -	struct freelQ_ce *ce = &fl->centries[fl->cidx];
> > +	const struct freelQ_ce *ce = &fl->centries[fl->cidx];
> > +
> > +	if (len < copybreak) {
> 
> If you are into cleanups, maybe add likely/unlikely (and remove the inline) ?

Why, you can't predict copybreak on off

> 
> > +		skb = alloc_skb(len + 2, GFP_ATOMIC);
> > +		if (!skb)
> > +			goto use_orig_buf;
> >  
> > -	if (len < copy_thres) {
> > -		skb = alloc_skb(len + skb_pad, GFP_ATOMIC);
> > -		if (likely(skb != NULL)) {
> > -			skb_reserve(skb, skb_pad);
> > -			skb_put(skb, len);
> > -			pci_dma_sync_single_for_cpu(pdev,
> > +		skb_reserve(skb, 2);	/* align IP header */
> 
> s/2/NET_IP_ALIGN/

This is wrong, NET_IP_ALIGN is for DMA buffers only. It is defined
as 0 for those platforms where DMA alignment is important. In this
case we are copying, so we want to force 2.

> Btw, since the driver supports netpoll, its blind enabling of interrupts
> in t1_poll() seems old-fashoined (see thread starting at
> http://lkml.org/lkml/2006/12/12/86)
> 


-- 
Stephen Hemminger <shemminger@osdl.org>
