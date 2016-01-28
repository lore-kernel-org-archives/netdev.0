From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 4/9] net: moxart: use correct accessors for DMA memory
Date: Thu, 28 Jan 2016 12:36:19 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CCCEDCE@AcuExch.aculab.com>
References: <1453903507-3427225-1-git-send-email-arnd@arndb.de>
 <1453903507-3427225-5-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	=?Windows-1252?Q?fran=E7ois_romieu?= <romieu@fr.zoreil.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: 'Arnd Bergmann' <arnd@arndb.de>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1453903507-3427225-5-git-send-email-arnd@arndb.de>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann
> Sent: 27 January 2016 14:05
> The moxart ethernet driver confuses coherent DMA buffers with
> MMIO registers.
> 
> moxart_ether.c: In function 'moxart_mac_setup_desc_ring':
> moxart_ether.c:146:428: error: passing argument 1 of '__fswab32' makes integer from pointer without a
> cast [-Werror=int-conversion]
> moxart_ether.c:74:39: warning: incorrect type in argument 3 (different address spaces)
> moxart_ether.c:74:39:    expected void *cpu_addr
> moxart_ether.c:74:39:    got void [noderef] <asn:2>*tx_desc_base
> 
> This leaves the basic logic alone and uses normal pointers for
> the virtual address of the descriptor. As we cannot use readl/writel
> to access them, we also introduce our own moxart_desc_read
> moxart_desc_write helpers that perform the same endianess swap
> as the original code, but without the extra barriers and address
> space conversion.

I'm pretty sure you need to add some explicit barriers:

> @@ -354,8 +364,8 @@ static int moxart_mac_start_xmit(struct sk_buff *skb, struct net_device *ndev)
>  	txdes1 = TX_DESC1_LTS | TX_DESC1_FTS | (len & TX_DESC1_BUF_SIZE_MASK);
>  	if (tx_head == TX_DESC_NUM_MASK)
>  		txdes1 |= TX_DESC1_END;
> -	writel(txdes1, desc + TX_REG_OFFSET_DESC1);
> -	writel(TX_DESC0_DMA_OWN, desc + TX_REG_OFFSET_DESC0);
> +	moxart_desc_write(txdes1, desc + TX_REG_OFFSET_DESC1);
> +	moxart_desc_write(TX_DESC0_DMA_OWN, desc + TX_REG_OFFSET_DESC0);

Those last two writes must happen in that order.
There may be others.

	David
