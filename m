From: Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>
Subject: [IPoIB] Identify multicast packets and fix IGMP breakage V2
Date: Thu, 26 Aug 2010 16:31:14 -0500 (CDT)
Message-ID: <alpine.DEB.2.00.1008261629440.24174@router.home>
References: <alpine.DEB.2.00.1008231210010.9840@router.home> <20100823174110.GK26549@obsidianresearch.com> <alpine.DEB.2.00.1008231317150.10719@router.home> <20100823183044.GM26549@obsidianresearch.com> <alpine.DEB.2.00.1008261453510.21466@router.home>
 <adapqx5rtez.fsf@cisco.com> <alpine.DEB.2.00.1008261613160.24174@router.home>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Or Gerlitz <ogerlitz-smomgflXvOZWk0Htik3J/w@public.gmane.org>,
	Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
	Yossi Etigin <yosefe-smomgflXvOZWk0Htik3J/w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Roland Dreier <rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <alpine.DEB.2.00.1008261613160.24174-sBS69tsa9Uj/9pzu0YdTqQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Is this better?


Subject: [IPoIB] Identify Multicast packets and fix IGMP breakage V2

IGMP processing is broken because the IPOIB does not set the
skb->pkt_type the right way for Multicast traffic. All incoming
packets are set to PACKET_HOST which means that the igmp_recv()
function will ignore the IGMP broadcasts/multicasts.

This in turn means that the IGMP timers are firing and are sending
information about multicast subscriptions unnecessarily. In a large
private network this can cause traffic spikes.

Signed-off-by: Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>

---
 drivers/infiniband/ulp/ipoib/ipoib_ib.c |   10 +++++++---
 include/linux/in6.h                     |    3 +++
 2 files changed, 10 insertions(+), 3 deletions(-)

Index: linux-2.6/drivers/infiniband/ulp/ipoib/ipoib_ib.c
===================================================================
--- linux-2.6.orig/drivers/infiniband/ulp/ipoib/ipoib_ib.c	2010-08-26 15:11:34.000000000 -0500
+++ linux-2.6/drivers/infiniband/ulp/ipoib/ipoib_ib.c	2010-08-26 16:29:19.000000000 -0500
@@ -271,6 +271,13 @@ static void ipoib_ib_handle_rx_wc(struct
 	ipoib_ud_dma_unmap_rx(priv, mapping);
 	ipoib_ud_skb_put_frags(priv, skb, wc->byte_len);

+	if ((wc->wc_flags & IB_WC_GRH) &&
+		IN6_IS_ADDR_MULTICAST(&((struct ipv6hdr *)skb->data)->daddr))
+
+		skb->pkt_type = PACKET_MULTICAST;
+	else
+		skb->pkt_type = PACKET_HOST;
+
 	skb_pull(skb, IB_GRH_BYTES);

 	skb->protocol = ((struct ipoib_header *) skb->data)->proto;
@@ -281,9 +288,6 @@ static void ipoib_ib_handle_rx_wc(struct
 	dev->stats.rx_bytes += skb->len;

 	skb->dev = dev;
-	/* XXX get correct PACKET_ type here */
-	skb->pkt_type = PACKET_HOST;
-
 	if (test_bit(IPOIB_FLAG_CSUM, &priv->flags) && likely(wc->csum_ok))
 		skb->ip_summed = CHECKSUM_UNNECESSARY;

Index: linux-2.6/include/linux/in6.h
===================================================================
--- linux-2.6.orig/include/linux/in6.h	2010-08-26 15:11:34.000000000 -0500
+++ linux-2.6/include/linux/in6.h	2010-08-26 16:27:08.000000000 -0500
@@ -53,6 +53,9 @@ extern const struct in6_addr in6addr_lin
 extern const struct in6_addr in6addr_linklocal_allrouters;
 #define IN6ADDR_LINKLOCAL_ALLROUTERS_INIT \
 		{ { { 0xff,2,0,0,0,0,0,0,0,0,0,0,0,0,0,2 } } }
+
+#define IN6_IS_ADDR_MULTICAST(a) ((a)->in6_u.u6_addr8[0] == 0xff)
+
 #endif

 struct sockaddr_in6 {
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
