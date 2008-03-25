From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] Add support the Korina (IDT RC32434) Ethernet MAC
Date: Tue, 25 Mar 2008 23:45:54 +0100
Message-ID: <20080325224554.GA32429@electric-eye.fr.zoreil.com>
References: <200803052345.06610.florian.fainelli@telecomint.eu> <200803192217.25860.florian.fainelli@telecomint.eu> <20080319215535.GB24710@electric-eye.fr.zoreil.com> <200803252155.56082.florian.fainelli@telecomint.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes@sipsolutions.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Jeff Garzik <jeff@garzik.org>, Felix Fietkau <nbd@openwrt.org>
To: Florian Fainelli <florian.fainelli@telecomint.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:41194 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754527AbYCYXEQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2008 19:04:16 -0400
Content-Disposition: inline
In-Reply-To: <200803252155.56082.florian.fainelli@telecomint.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Fainelli <florian.fainelli@telecomint.eu> :
> Le mercredi 19 mars 2008, Francois Romieu a ?crit?:
[...]
> > If the allocation fails, the driver will have to handle a shorter
> > than expected ring (it is probably ok, I have not checked it). You
> > may consider initializing the link field for each descriptor if
> > possible. See epic_init_ring() for some inspiration.
> 
> That is why I use the i variable such that if a break in the loop happens,
> the ring and last/first decscriptors are properly set.

I was more worried that rx_next_done (in korina_rx) does not seem to
know that the descriptor ring can actually be shorter than expected.

static void korina_alloc_ring(struct net_device *dev)
{
[...]
	for (i = 0; i < KORINA_NUM_RDS; i++) {
                struct sk_buff *skb = lp->rx_skb[i];

                skb = dev_alloc_skb(KORINA_RBSIZE + 2);
                if (!skb)
                        break;
[...]
                lp->rd_ring[i].link = CPHYSADDR(&lp->rd_ring[i+1]);
[...]
static int korina_rx(struct net_device *dev, int limit)
{
[...]
                        rd->control = DMA_COUNT(KORINA_RBSIZE) |
                                DMA_DESC_COD | DMA_DESC_IOD;
                        lp->rd_ring[(lp->rx_next_done - 1) &
                                KORINA_RDS_MASK].control &= ~DMA_DESC_COD;

                        lp->rx_next_done = (lp->rx_next_done + 1) & KORINA_RDS_MASK;

-> Sooner than later, rx_next_done will force the code through a
   descriptor ring entry where rd->link is not set while the
   hardware has already returned to the start of the ring.

-- 
Ueimor
