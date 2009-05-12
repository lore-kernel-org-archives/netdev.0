From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 4/6] rionet: add memory access to simulated Ethernet
 over rapidio
Date: Tue, 12 May 2009 15:10:29 -0700
Message-ID: <20090512151029.bc2c99ac.akpm@linux-foundation.org>
References: <1242117363-14949-1-git-send-email-leoli@freescale.com>
	<1242117363-14949-2-git-send-email-leoli@freescale.com>
	<1242117363-14949-3-git-send-email-leoli@freescale.com>
	<1242117363-14949-4-git-send-email-leoli@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: galak@kernel.crashing.org, davem@davemloft.net,
	mporter@kernel.crashing.org, linux-kernel@vger.kernel.org,
	linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	leoli@freescale.com, zw@zh-kernel.org
To: Li Yang <leoli@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:36346 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752739AbZELWPg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2009 18:15:36 -0400
In-Reply-To: <1242117363-14949-4-git-send-email-leoli@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 12 May 2009 16:36:01 +0800
Li Yang <leoli@freescale.com> wrote:

> Through the newly added IO memory access of RapidIO, sender can
> write directly to recipient's rx buffer, either by cpu or DMA engine.
>
> ...
>
> +/* Definitions for rionet memory map driver */
> +#define RIONET_DRVID		0x101
> +#define RIONET_MAX_SK_DATA_SIZE	0x1000
> +#define RIONET_MEM_RIO_BASE	0x10000000
> +#define RIONET_TX_RX_BUFF_SIZE	(0x1000 * (128 + 128))
> +#define RIONET_QUEUE_NEXT(x)	(((x) < 127) ? ((x) + 1) : 0)

References its arg multiple times, hence is buggy or inefficient when
passed an expression with side-effects.

	static inline int rionet_queue_next(int x)

would be better.  Assuming that some sane identifier is used instead of
"x".

> +#define RIONET_QUEUE_INC(x)	(x = RIONET_QUEUE_NEXT(x))

It's pretty ugly to hide an assignment inside a macro like this.  Why
not do

	foo = rionet_queue_inc(foo);

at the callsites?  It makes it much clearer for the reader.


>
> ...
>
> +#ifdef CONFIG_RIONET_MEMMAP
> +static int rio_send_mem(struct sk_buff *skb,
> +				struct net_device *ndev, struct rio_dev *rdev)
> +{
> +	struct rionet_private *rnet = netdev_priv(ndev);
> +	int enqueue, dequeue;
> +
> +	if (!rdev)
> +		return -EFAULT;

Is that an appropriate error code?

>
> ...
>
