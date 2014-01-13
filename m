From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: build_skb() and data corruption
Date: Mon, 13 Jan 2014 13:42:19 +0000
Message-ID: <1389620539.3720.157.camel@deadeye.wl.decadent.org.uk>
References: <CACmBeS35RAEQ+t2vtYtFTKNT-VdQw20hURjTi193Jk8HG7UECA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	<alexander.h.duyck@intel.com>, Arnd Bergmann <arnd@arndb.de>,
	Florian Fainelli <florian@openwrt.org>
To: Jonas Jensen <jonas.jensen@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACmBeS35RAEQ+t2vtYtFTKNT-VdQw20hURjTi193Jk8HG7UECA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2014-01-13 at 12:47 +0100, Jonas Jensen wrote:
> Please help,
> 
> I think I see memory corruption with a driver recently added to linux-next.
> 
> The following error occur downloading a large file with wget (or
> ncftp): "read error: Bad address"
> wget exits and leaves the file unfinished.
> 
> The error goes away when build_skb() is patched out, in this case by
> allocating pages directly in RX loop.

The problem is you're assuming build_skb() does rather more than it
does.

> I currently have two branches with code placed under ifdef USE_BUILD_SKB:
> https://bitbucket.org/Kasreyn/linux-next/src/faa7c408a655fdfd7c383f79259031da5a05d61e/drivers/net/ethernet/moxa/moxart_ether.c#cl-472

Quoting from there:

> #define USE_BUILD_SKB
> #ifdef USE_BUILD_SKB
> 
> 
> 	skb = build_skb(page_address(priv->rx_pages[priv->rx_head]), priv->rx_buf_size);
> 
> 
> 	if (unlikely(!skb)) {
> 		net_info_ratelimited("RX build_skb failed\n");

Don't log; increment the rx_dropped counter.

> 		moxart_rx_drop_packet(ndev, desc0);
> 		return true;
> 	}
>
> 
> 	if (likely(skb))

Redundant condition.

> 		get_page(priv->rx_pages[priv->rx_head]);
> 
> 
> 	skb_put(skb, len);
> 
> 
> #else
> 
> 
> 	dma_unmap_page(&ndev->dev, priv->rx_buf_phys[priv->rx_head], RX_BUF_SIZE, DMA_FROM_DEVICE);

dma_unmap_page() is always needed, so move this above the #ifdef
USE_BUILD_SKB.

> 
> 	skb = netdev_alloc_skb_ip_align(ndev, 128);

Missing check for NULL.

> 	skb_fill_page_desc(skb, 0, priv->rx_pages[priv->rx_head], 0, len);
> 	skb->len += len;
> 	skb->data_len += len;
> 
> 
> 	if (len > 128) {
> 		skb->truesize += PAGE_SIZE;
> 		__pskb_pull_tail(skb, ETH_HLEN);
> 	} else {
> 		__pskb_pull_tail(skb, len);
> 	}
> 
> 
> 	p = priv->rx_pages[priv->rx_head];

Missing check for NULL.

> 	moxart_alloc_rx_page(ndev, priv->rx_head);

New buffer is always required, so move this under the #endif... well,
except that if moxart_alloc_rx_page() fails then things go horribly
wrong as you have.

Best practice is to try allocating the next buffer before passing up the
current one; if that fails then you recycle the current buffer and
increment rx_dropped.

> 
> 
> #endif
[end quoted code]

> If build_skb() is the cause, is there something the driver can do about it?
> 
> A quick search on "build_skb memory corruption" reveals the following
> commit, "igb: Revert support for build_skb in igb"
> f9d40f6a9921cc7d9385f64362314054e22152bd:
[...]

The problem I identified in igb occurs only when splitting a page into
multiple buffers (or when recycling DMA-mapped pages).  build_skb() is
fine to use whenever each RX buffer is a single page (except that that's
memory-inefficient) that's unmapped on completion.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
