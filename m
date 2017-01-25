From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH/RFC v3 net] ravb: unmap descriptors when freeing rings
Date: Wed, 25 Jan 2017 17:48:14 +0100
Message-ID: <20170125164814.GC12042@verge.net.au>
References: <1485282073-16662-1-git-send-email-horms+renesas@verge.net.au>
 <db2a9c3a-6b99-769d-4fa2-2d52af631966@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Magnus Damm <magnus.damm@gmail.com>, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <db2a9c3a-6b99-769d-4fa2-2d52af631966@cogentembedded.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 25, 2017 at 07:05:08PM +0300, Sergei Shtylyov wrote:
> Hello.
> 
> On 01/24/2017 09:21 PM, Simon Horman wrote:
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
> >v3 [Simon Horman]
> >* As suggested by Sergei Shtylyov
> >  - consistently use le32_to_cpu(desc->dptr)
> >  - Do not clear desc->ds_cc as it is not used
> >* Paramatise ravb_tx_free() to allow it to free non-transmitted buffers
> >
> >v2 [Simon Horman]
> >* As suggested by Sergei Shtylyov
> >  - Use dma_mapping_error() and rx_desc->ds_cc when unmapping RX descriptors;
> >    this is consistent with the way that they are mapped
> >  - Use ravb_tx_free() to clear TX descriptors
> >* Reduce scope of new local variable
> >
> >v1 [Kazuya Mizuguchi]
> >---
> > drivers/net/ethernet/renesas/ravb_main.c | 113 ++++++++++++++++++-------------
> > 1 file changed, 65 insertions(+), 48 deletions(-)
> >
> >diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
> >index 89ac1e3f6175..57fe1411bb9d 100644
> >--- a/drivers/net/ethernet/renesas/ravb_main.c
> >+++ b/drivers/net/ethernet/renesas/ravb_main.c
> >@@ -179,6 +179,51 @@ static struct mdiobb_ops bb_ops = {
> > 	.get_mdio_data = ravb_get_mdio_data,
> > };
> >
> >+enum ravb_tx_free_mode {
> >+	ravb_tx_free_all,
> >+	ravb_tx_free_txed_only,
> >+};
> >+
> >+/* Free TX skb function for AVB-IP */
> >+static int ravb_tx_free(struct net_device *ndev, int q,
> >+			enum ravb_tx_free_mode free_mode)
> 
>    Hmm... Sorry but this looks over-engineered. A *bool* parameter (named
> e.g 'all) would suffice IMHO.

Ha! The last time I used a bool for something like this I was encouraged
to use an enum, admittedly that was not kernel code but I was unsure
which way to go this time. I'll change things to bool as you sugget.

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
> >+		if (free_mode == ravb_tx_free_txed_only &&
> >+		    desc->die_dt != DT_FEMPTY)
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
> 
>    Hmmm... we shouldn't count the discarded unsent packets/bytes as sent, right?

Yes, I think so. Sorry for missing that.

> [...]
> >@@ -215,12 +262,19 @@ static void ravb_ring_free(struct net_device *ndev, int q)
> > 	}
> >
> > 	if (priv->tx_ring[q]) {
> >+		ravb_tx_free(ndev, q, ravb_tx_free_all);
> >+
> > 		ring_size = sizeof(struct ravb_tx_desc) *
> > 			    (priv->num_tx_ring[q] * NUM_TX_DESC + 1);
> > 		dma_free_coherent(ndev->dev.parent, ring_size, priv->tx_ring[q],
> > 				  priv->tx_desc_dma[q]);
> > 		priv->tx_ring[q] = NULL;
> > 	}
> >+
> >+	/* Free TX skb ringbuffer.
> >+	 * SKBs are freed by ravb_tx_free() call above. */
> 
>    This is not a recommended comment format:
> 
> /* bla
>  * bla
>  */

Thanks, I will fix that.
