From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: use hardware buffer pool to allocate skb
Date: Thu, 16 Oct 2014 09:57:37 -0700
Message-ID: <1413478657.28798.22.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1413343571-33231-1-git-send-email-Jiafei.Pan@freescale.com>
	 <20141015.002514.384962932982389732.davem@davemloft.net>
	 <c02005b9d8794d14bc2149f468ab571c@BY2PR03MB524.namprd03.prod.outlook.com>
	 <1413364533.12304.44.camel@edumazet-glaptop2.roam.corp.google.com>
	 <524626e093684abeba65839d26e94262@BLUPR03MB517.namprd03.prod.outlook.com>
	 <1413432912.28798.7.camel@edumazet-glaptop2.roam.corp.google.com>
	 <aeef795129504782ae1e9f91467d243e@BLUPR03MB517.namprd03.prod.outlook.com>
	 <543FE413.6030406@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Jiafei.Pan@freescale.com" <Jiafei.Pan@freescale.com>,
	David Miller <davem@davemloft.net>,
	"jkosina@suse.cz" <jkosina@suse.cz>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"LeoLi@freescale.com" <LeoLi@freescale.com>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <543FE413.6030406@redhat.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2014-10-16 at 08:28 -0700, Alexander Duyck wrote:

> I think the part you are not getting is that is how buffers are 
> essentially handled now.  So for example in the case if igb the only 
> part we have copied out is usually the header, or the entire frame in 
> the case of small packets.  This has to happen in order to allow for 
> changes to the header for routing and such.  Beyond that the frags that 
> are passed are the buffers that igb is still holding onto.  So 
> effectively what the other device transmits in a bridging/routing 
> scenario is my own net card specified buffer plus the copied/modified 
> header.
> 
> For a brief period igb used build_skb but that isn't valid on most 
> systems as memory mapped for a device can be overwritten if the page is 
> unmapped resulting in any changes to the header for routing/bridging 
> purposes being invalidated.  Thus we cannot use the buffers for both the 
> skb->data header which may be changed and Rx DMA simultaneously.

This reminds me that igb still has skb->truesize underestimation by 100%

If a fragment is held in some socket receive buffer, a full page is
consumed, not 2048 bytes.

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index a21b14495ebd..56ca6c78985e 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -6586,9 +6586,11 @@ static bool igb_add_rx_frag(struct igb_ring *rx_ring,
 	struct page *page = rx_buffer->page;
 	unsigned int size = le16_to_cpu(rx_desc->wb.upper.length);
 #if (PAGE_SIZE < 8192)
-	unsigned int truesize = IGB_RX_BUFSZ;
+	unsigned int segsize = IGB_RX_BUFSZ;
+	unsigned int truesize = PAGE_SIZE;
 #else
-	unsigned int truesize = ALIGN(size, L1_CACHE_BYTES);
+	unsigned int segsize = ALIGN(size, L1_CACHE_BYTES);
+	unsigned int truesize = segsize;
 #endif
 
 	if ((size <= IGB_RX_HDR_LEN) && !skb_is_nonlinear(skb)) {
@@ -6614,7 +6616,7 @@ static bool igb_add_rx_frag(struct igb_ring *rx_ring,
 	skb_add_rx_frag(skb, skb_shinfo(skb)->nr_frags, page,
 			rx_buffer->page_offset, size, truesize);
 
-	return igb_can_reuse_rx_page(rx_buffer, page, truesize);
+	return igb_can_reuse_rx_page(rx_buffer, page, segsize);
 }
 
 static struct sk_buff *igb_fetch_rx_buffer(struct igb_ring *rx_ring,
 

