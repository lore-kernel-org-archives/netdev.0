From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: build_skb() and data corruption
Date: Mon, 13 Jan 2014 14:29:37 +0100
Message-ID: <201401131429.38218.arnd@arndb.de>
References: <CACmBeS35RAEQ+t2vtYtFTKNT-VdQw20hURjTi193Jk8HG7UECA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	bhutchings@solarflare.com, alexander.h.duyck@intel.com,
	Florian Fainelli <florian@openwrt.org>
To: Jonas Jensen <jonas.jensen@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACmBeS35RAEQ+t2vtYtFTKNT-VdQw20hURjTi193Jk8HG7UECA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 13 January 2014, Jonas Jensen wrote:
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
> 
> I currently have two branches with code placed under ifdef USE_BUILD_SKB:
> https://bitbucket.org/Kasreyn/linux-next/src/faa7c408a655fdfd7c383f79259031da5a05d61e/drivers/net/ethernet/moxa/moxart_ether.c#cl-472
> 

The problem appears to be incorrect coherency management of the
dma buffers. You are using the streaming DMA mapping API on a
platform that is not cache coherent, and you are reusing buffers.

The solution to this problem is to add the appropriate
dma_sync_single_for_device() and dma_sync_single_for_cpu()
calls at the point where buffer ownership changes between the
dma master and the CPU. This will flush the caches after the
filling them on the tx path and invalidate caches when the
dma master fills them on rx.

See Documentation/DMA-API-HOWTO.txt for details.

	Arnd
