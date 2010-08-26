From: Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>
Subject: Re: [IPoIB] Identify multicast packets and fix IGMP breakage V3
Date: Thu, 26 Aug 2010 18:26:58 -0500 (CDT)
Message-ID: <alpine.DEB.2.00.1008261825490.26351@router.home>
References: <adapqx5rtez.fsf@cisco.com> <alpine.DEB.2.00.1008261613160.24174@router.home> <alpine.DEB.2.00.1008261629440.24174@router.home> <20100826.151553.242147157.davem@davemloft.net> <20100826222146.GA23025@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ogerlitz-smomgflXvOZWk0Htik3J/w@public.gmane.org,
	yosefe-smomgflXvOZWk0Htik3J/w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100826222146.GA23025-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 26 Aug 2010, Jason Gunthorpe wrote:

> The 40 bytes at this location are defined by the HW specification to
> be an IB GRH which has an identical layout to an IPv6 header. Roland
> is right, it would be clearer to use ib_grh ->dgid

Ok but then we have no nice function that checks for multicast anymore.



Subject: [IPoIB] Identify multicast packets and fix IGMP breakage V3

IGMP processing is broken because the IPOIB does not set the
skb->pkt_type the right way for Multicast traffic. All incoming
packets are set to PACKET_HOST which means that the igmp_recv()
function will ignore the IGMP broadcasts/multicasts.

This in turn means that the IGMP timers are firing and are sending
information about multicast subscriptions unnecessarily. In a large
private network this can cause traffic spikes.

Signed-off-by: Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>

---

Index: linux-2.6/drivers/infiniband/ulp/ipoib/ipoib_ib.c
===================================================================
--- linux-2.6.orig/drivers/infiniband/ulp/ipoib/ipoib_ib.c	2010-08-26 18:24:07.842079559 -0500
+++ linux-2.6/drivers/infiniband/ulp/ipoib/ipoib_ib.c	2010-08-26 18:25:33.859815544 -0500
@@ -271,6 +271,14 @@
 	ipoib_ud_dma_unmap_rx(priv, mapping);
 	ipoib_ud_skb_put_frags(priv, skb, wc->byte_len);

+	/* First byte of dgid signals multicast when 0xff */
+	if ((wc->wc_flags & IB_WC_GRH) &&
+		((struct ib_grh *)skb->data)->dgid.raw[0] == 0xff)
+
+		skb->pkt_type = PACKET_MULTICAST;
+	else
+		skb->pkt_type = PACKET_HOST;
+
 	skb_pull(skb, IB_GRH_BYTES);

 	skb->protocol = ((struct ipoib_header *) skb->data)->proto;
@@ -281,9 +289,6 @@
 	dev->stats.rx_bytes += skb->len;

 	skb->dev = dev;
-	/* XXX get correct PACKET_ type here */
-	skb->pkt_type = PACKET_HOST;
-
 	if (test_bit(IPOIB_FLAG_CSUM, &priv->flags) && likely(wc->csum_ok))
 		skb->ip_summed = CHECKSUM_UNNECESSARY;

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
