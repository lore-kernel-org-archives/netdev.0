From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 4/9] net: moxart: use correct accessors for DMA memory
Date: Thu, 28 Jan 2016 17:53:43 +0100
Message-ID: <3468358.kXWNPLZEG9@wuerfel>
References: <1453903507-3427225-1-git-send-email-arnd@arndb.de> <1453903507-3427225-5-git-send-email-arnd@arndb.de> <063D6719AE5E284EB5DD2968C1650D6D1CCCEDCE@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: David Laight <David.Laight@aculab.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	=?ISO-8859-1?Q?fran=E7ois?= romieu <romieu@fr.zoreil.com>
To: linux-arm-kernel@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CCCEDCE@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 28 January 2016 12:36:19 David Laight wrote:
> From: Arnd Bergmann
> > Sent: 27 January 2016 14:05
> > The moxart ethernet driver confuses coherent DMA buffers with
> > MMIO registers.
> > 
> > moxart_ether.c: In function 'moxart_mac_setup_desc_ring':
> > moxart_ether.c:146:428: error: passing argument 1 of '__fswab32' makes integer from pointer without a
> > cast [-Werror=int-conversion]
> > moxart_ether.c:74:39: warning: incorrect type in argument 3 (different address spaces)
> > moxart_ether.c:74:39:    expected void *cpu_addr
> > moxart_ether.c:74:39:    got void [noderef] <asn:2>*tx_desc_base
> > 
> > This leaves the basic logic alone and uses normal pointers for
> > the virtual address of the descriptor. As we cannot use readl/writel
> > to access them, we also introduce our own moxart_desc_read
> > moxart_desc_write helpers that perform the same endianess swap
> > as the original code, but without the extra barriers and address
> > space conversion.
> 
> I'm pretty sure you need to add some explicit barriers:
> 
> > @@ -354,8 +364,8 @@ static int moxart_mac_start_xmit(struct sk_buff *skb, struct net_device *ndev)
> >       txdes1 = TX_DESC1_LTS | TX_DESC1_FTS | (len & TX_DESC1_BUF_SIZE_MASK);
> >       if (tx_head == TX_DESC_NUM_MASK)
> >               txdes1 |= TX_DESC1_END;
> > -     writel(txdes1, desc + TX_REG_OFFSET_DESC1);
> > -     writel(TX_DESC0_DMA_OWN, desc + TX_REG_OFFSET_DESC0);
> > +     moxart_desc_write(txdes1, desc + TX_REG_OFFSET_DESC1);
> > +     moxart_desc_write(TX_DESC0_DMA_OWN, desc + TX_REG_OFFSET_DESC0);
> 
> Those last two writes must happen in that order.
> There may be others.

Makes sense. I looked at the ftmac100 driver, which is another driver
for the same hardware, and it's also missing barriers. We should
probably add them for both then.

I think for the SoC that uses this, a barrier() would be sufficient
because of the page flags that dma_alloc_coherent() uses on ARM for
non-coherent platforms, but to be on the safe side we need a full
rmb()/wmb(). Sending a version 2 now.

	Arnd
