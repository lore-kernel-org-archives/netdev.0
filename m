From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH/RFC v2 net-next] ravb: unmap descriptors when freeing
 rings
Date: Thu, 12 Jan 2017 10:11:16 +0100
Message-ID: <20170112091116.GC7724@verge.net.au>
References: <1483613000-537-1-git-send-email-horms+renesas@verge.net.au>
 <6fcec500-bed6-ffa3-2887-d45b34703682@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        Magnus Damm <magnus.damm@gmail.com>, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:40699 "EHLO
        kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750872AbdALJLX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 04:11:23 -0500
Content-Disposition: inline
In-Reply-To: <6fcec500-bed6-ffa3-2887-d45b34703682@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 06, 2017 at 10:02:36PM +0300, Sergei Shtylyov wrote:
> Hello!
> 
> On 01/05/2017 01:43 PM, Simon Horman wrote:
> 
> >From: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
> >
> >"swiotlb buffer is full" errors occur after repeated initialisation of a
> >device - f.e. suspend/resume or ip link set up/down. This is because memory
> >mapped using dma_map_single() in ravb_ring_format() and ravb_start_xmit()
> >is not released.  Resolve this problem by unmapping descriptors when
> >freeing rings.
> >
> >Note, ravb_tx_free() is moved but not otherwise modified by this patch.
> >
> >Signed-off-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
> >[simon: reworked]
> >Signed-off-by: Simon Horman <horms+renesas@verge.net.au>
> >--
> >v1 [Kazuya Mizuguchi]
> >
> >v2 [Simon Horman]
> >* As suggested by Sergei Shtylyov
> >  - Use dma_mapping_error() and rx_desc->ds_cc when unmapping RX descriptors;
> >    this is consistent with the way that they are mapped
> >  - Use ravb_tx_free() to clear TX descriptors
> 
>    Not sure that was good idea (sorry)... ravb_tx_ring() only unmaps the
> transmitted buffers, while we need to unmap everything...
> 
> >* Reduce scope of new local variable
> >---
> > drivers/net/ethernet/renesas/ravb_main.c | 89 ++++++++++++++++++--------------
> > 1 file changed, 51 insertions(+), 38 deletions(-)
> >
> >diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
> >index 92d7692c840d..1797c48e3176 100644
> >--- a/drivers/net/ethernet/renesas/ravb_main.c
> >+++ b/drivers/net/ethernet/renesas/ravb_main.c
> >@@ -179,6 +179,44 @@ static struct mdiobb_ops bb_ops = {
> > 	.get_mdio_data = ravb_get_mdio_data,
> > };
> >
> >+/* Free TX skb function for AVB-IP */
> >+static int ravb_tx_free(struct net_device *ndev, int q)
> >+{
> >+	struct ravb_private *priv = netdev_priv(ndev);
> >+	struct net_device_stats *stats = &priv->stats[q];
> >+	struct ravb_tx_desc *desc;
> >+	int free_num = 0;
> >+	int entry;
> >+	u32 size;
> >+
> >+	for (; priv->cur_tx[q] - priv->dirty_tx[q] > 0; priv->dirty_tx[q]++) {
> >+		entry = priv->dirty_tx[q] % (priv->num_tx_ring[q] *
> >+					     NUM_TX_DESC);
> >+		desc = &priv->tx_ring[q][entry];
> >+		if (desc->die_dt != DT_FEMPTY)
> 
>    Here, it stop once an untransmitted buffer is encountered...

Yes, I see that now.

I wonder if we should:

a) paramatise ravb_tx_free() so it may either clear all transmitted buffers
   (current behaviour) or all buffers (new behaviour).
b) provide a different version of this loop in ravb_ring_free()

What are your thoughts?

> >+			break;
> >+		/* Descriptor type must be checked before all other reads */
> >+		dma_rmb();
> >+		size = le16_to_cpu(desc->ds_tagl) & TX_DS;
> >+		/* Free the original skb. */
> >+		if (priv->tx_skb[q][entry / NUM_TX_DESC]) {
> >+			dma_unmap_single(ndev->dev.parent, le32_to_cpu(desc->dptr),
> >+					 size, DMA_TO_DEVICE);
> >+			/* Last packet descriptor? */
> >+			if (entry % NUM_TX_DESC == NUM_TX_DESC - 1) {
> >+				entry /= NUM_TX_DESC;
> >+				dev_kfree_skb_any(priv->tx_skb[q][entry]);
> >+				priv->tx_skb[q][entry] = NULL;
> >+				stats->tx_packets++;
> >+			}
> >+			free_num++;
> >+		}
> >+		stats->tx_bytes += size;
> >+		desc->die_dt = DT_EEMPTY;
> >+	}
> >+	return free_num;
> >+}
> >+
> > /* Free skb's and DMA buffers for Ethernet AVB */
> > static void ravb_ring_free(struct net_device *ndev, int q)
> > {
> >@@ -207,6 +245,18 @@ static void ravb_ring_free(struct net_device *ndev, int q)
> > 	priv->tx_align[q] = NULL;
> >
> > 	if (priv->rx_ring[q]) {
> >+		for (i = 0; i < priv->num_rx_ring[q]; i++) {
> >+			struct ravb_ex_rx_desc *rx_desc = &priv->rx_ring[q][i];
> >+
> >+			if (!dma_mapping_error(ndev->dev.parent,
> >+					       rx_desc->dptr)) {
> 
>   You forgot le32_to_cpu() here, we can't use the raw descriptor fields.

Thanks, I will fix that.

> >+				dma_unmap_single(ndev->dev.parent,
> >+						 le32_to_cpu(rx_desc->dptr),
> >+						 PKT_BUF_SZ,
> >+						 DMA_FROM_DEVICE);
> >+				rx_desc->ds_cc = cpu_to_le16(0);
> 
>    You don't check it anyway, not sure what that buys...

Thanks, I will see about dropping that.
