From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH] virtio_net: use correct accessors for scatterlists
Date: Tue, 27 Jan 2009 15:21:19 +1030
Message-ID: <200901271521.19616.rusty@rustcorp.com.au>
References: <20090124001053.GA20156@ovro.caltech.edu>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Mark McLoughlin <markmc@redhat.com>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Ira Snyder <iws@ovro.caltech.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:59281 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751372AbZA0Ev1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Jan 2009 23:51:27 -0500
In-Reply-To: <20090124001053.GA20156@ovro.caltech.edu>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 24 January 2009 10:40:53 Ira Snyder wrote:
> Without this fix, virtio_net makes incorrect usage of scatterlists. It sets
> the end of the scatterlist chain after the first element, despite the fact
> that more entries come after it.
> 
> If you try to run dma_map_sg() on one of the scatterlists given to you by
> add_buf(), you will get a null pointer oops.
> 
> Signed-off-by: Ira W. Snyder <iws@ovro.caltech.edu>

Thanks, this should go in 2.6.29.  Dave?

Cheers,
Rusty.

Subject: virtio_net: use correct accessors for scatterlists
Date: Fri, 23 Jan 2009 16:10:53 -0800
From: Ira Snyder <iws@ovro.caltech.edu>

Without this fix, virtio_net makes incorrect usage of scatterlists. It sets
the end of the scatterlist chain after the first element, despite the fact
that more entries come after it.

If you try to run dma_map_sg() on one of the scatterlists given to you by
add_buf(), you will get a null pointer oops.

Signed-off-by: Ira W. Snyder <iws@ovro.caltech.edu>
Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
---
 drivers/net/virtio_net.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 43f6523..67ea2cf 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -286,7 +286,7 @@ static void try_fill_recv_maxbufs(struct virtnet_info *vi)
 		skb_put(skb, MAX_PACKET_LEN);
 
 		hdr = skb_vnet_hdr(skb);
-		sg_init_one(sg, hdr, sizeof(*hdr));
+		sg_set_buf(sg, hdr, sizeof(*hdr));
 
 		if (vi->big_packets) {
 			for (i = 0; i < MAX_SKB_FRAGS; i++) {
@@ -487,9 +487,9 @@ static int xmit_skb(struct virtnet_info *vi, struct sk_buff *skb)
 
 	/* Encode metadata header at front. */
 	if (vi->mergeable_rx_bufs)
-		sg_init_one(sg, mhdr, sizeof(*mhdr));
+		sg_set_buf(sg, mhdr, sizeof(*mhdr));
 	else
-		sg_init_one(sg, hdr, sizeof(*hdr));
+		sg_set_buf(sg, hdr, sizeof(*hdr));
 
 	num = skb_to_sgvec(skb, sg+1, 0, skb->len) + 1;
 
