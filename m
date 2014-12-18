From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: Bug: mv643xxx fails with highmem
Date: Thu, 18 Dec 2014 00:03:57 +0000
Message-ID: <20141218000357.GX11285@n2100.arm.linux.org.uk>
References: <20141211194920.GR11285@n2100.arm.linux.org.uk>
 <20141211.151055.817876561546126576.davem@davemloft.net>
 <20141211202507.GS11285@n2100.arm.linux.org.uk>
 <5491F342.5090301@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Nimrod Andy <B38611@freescale.com>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	netdev@vger.kernel.org, fugang.duan@freescale.com
To: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-1.arm.linux.org.uk ([78.32.30.217]:37051 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751030AbaLRAEM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2014 19:04:12 -0500
Content-Disposition: inline
In-Reply-To: <5491F342.5090301@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 17, 2014 at 06:18:58PM -0300, Ezequiel Garcia wrote:
> On the other side, I haven't been able to reproduce this on my boards. I
> did try to put a hack to hold most lowmem pages, but it didn't make a
> difference. (In fact, I haven't been able to clearly see how the pages
> for the skbuff are allocated from high memory.)

To be honest, I don't know either.  All that I can do is describe what
happened...

I've been running 3.17 since a week after it came out, and never saw a
problem there.

Then I moved forward to 3.18, and ended up with memory corruption, which
seemed to be the GPU scribbling over kernel text (since the oops revealed
pixel values in the Code: line.)

I thought it was a GPU problem - which seemed a reasonable assumption as
I know that the runtime PM I implemented for the GPU doesn't properly
restore the hardware state yet.  So, I rebooted back into 3.18, this
time with all GPU users disabled, intending to download a kernel with
GPU runtime PM disabled.  I'd also added additional debug to my X DDX
driver which logged the GPU command stream to a file on a NFS mount -
this does open(, O_CREAT|O_WRONLY|O_APPEND), write(), close() each
time it submits a block of commands.

However, while my scripts to download the built kernel to the Cubox
were running, the kernel oopsed in the depths of dma_map_single() - the
kernel was trying to access a struct page for phys address 0x40000000,
which didn't exist.  I decided to go back to 3.17 to get the updated
kernel on it, hoping that would sort it out.

With the updated 3.18 kernel (with GPU runtime PM disabled), I found
that I'd still get oopses in from the network driver while X was starting
up, again from dma_map_single().  So, with all GPU users again disabled,
I set about debugging the this issue.

I added a BUG_ON(!addr) after the page_address(), and that fired.  I
added a BUG_ON(PageHighMem(this_frag->page.p)) and that fired too.
(Each time, I had to boot back to 3.17 in order to download the new
kernel, because very time I tried with 3.18, I'd hit this bug.)

It's then when I reported the issue and asked the questions...

I've since done a simple change, taking advantage that on ARM (or any
asm-generic/dma-mapping-common.h user), dma_unmap_single() and
dma_unmap_page() are the same function:

diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index d44560d1d268..c343ab03ab8b 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -879,10 +879,8 @@ static void txq_submit_frag_skb(struct tx_queue *txq, struct sk_buff *skb)
                skb_frag_t *this_frag;
                int tx_index;
                struct tx_desc *desc;
-               void *addr;

                this_frag = &skb_shinfo(skb)->frags[frag];
-               addr = page_address(this_frag->page.p) + this_frag->page_offset;                tx_index = txq->tx_curr_desc++;
                if (txq->tx_curr_desc == txq->tx_ring_size)
                        txq->tx_curr_desc = 0;
@@ -902,8 +900,9 @@ static void txq_submit_frag_skb(struct tx_queue *txq, struct sk_buff *skb)

                desc->l4i_chk = 0;
                desc->byte_cnt = skb_frag_size(this_frag);
-               desc->buf_ptr = dma_map_single(mp->dev->dev.parent, addr,
-                                              desc->byte_cnt, DMA_TO_DEVICE);
+               desc->buf_ptr = skb_frag_dma_map(mp->dev->dev.parent,
+                                                this_frag, 0,
+                                                desc->byte_cnt, DMA_TO_DEVICE);        }
 }


I've been running that for the last five days, and I've yet to see
/any/ issues what so ever, and that includes running with the GPU
logging all that time:

-rw-r--r-- 1 root root 17113616 Dec 17 23:52 /shared/etnaviv.bin

During that time, I've been using the device over the network, running
various git commands, running builds, running the occasional build
via NFS, etc.

So, for me it was trivially easy to reproduce (without my fix in place)
and all problems have gone away when I've fixed the apparent problem.

However, exactly how it occurs, I don't know.  My understanding from
reading the various feature flags was that NETIF_F_HIGHDMA was required
for highmem (see illegal_highdma()) so as this isn't set, we shouldn't
be seeing highmem fragments - which is why I asked the question in my
original email.

If you want me to revert my fix above, and reproduce again, I can
certainly try that - or put a WARN_ON_ONCE(PageHighMem(this_frag->page.p))
in there, but I seem to remember that it wasn't particularly useful as
the backtrace didn't show where the memory actually came from.

-- 
FTTC broadband for 0.8mile line: currently at 9.5Mbps down 400kbps up
according to speedtest.net.
