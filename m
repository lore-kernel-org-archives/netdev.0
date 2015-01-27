From: Ben Hutchings <ben.hutchings@codethink.co.uk>
Subject: [PATCH kernel 2/4] sh_eth: Ensure DMA engines are stopped before
 freeing buffers
Date: Tue, 27 Jan 2015 00:49:32 +0000
Message-ID: <1422319772.3524.22.camel@xylophone.i.decadent.org.uk>
References: <1422319232.3524.14.camel@xylophone.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@lists.codethink.co.uk,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>,
	Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>,
	Hisashi Nakamura <hisashi.nakamura.ak@renesas.com>,
	Yoshihiro Kaneko <ykaneko0929@gmail.com>
To: "David S.Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ducie-dc1.codethink.co.uk ([185.25.241.215]:50156 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754414AbbA0Ate (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2015 19:49:34 -0500
In-Reply-To: <1422319232.3524.14.camel@xylophone.i.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently we try to clear EDRRR and EDTRR and immediately continue to
free buffers.  This is unsafe because:

- In general, register writes are not serialised with DMA, so we still
  have to wait for DMA to complete somehow
- The R8A7790 (R-Car H2) manual states that the TX running flag cannot
  be cleared by writing to EDTRR
- The same manual states that clearing the RX running flag only stops
  RX DMA at the next packet boundary

I applied this patch to the driver to detect DMA writes to freed
buffers:

> --- a/drivers/net/ethernet/renesas/sh_eth.c
> +++ b/drivers/net/ethernet/renesas/sh_eth.c
> @@ -1098,7 +1098,14 @@ static void sh_eth_ring_free(struct net_device *ndev)
>  	/* Free Rx skb ringbuffer */
>  	if (mdp->rx_skbuff) {
>  		for (i = 0; i < mdp->num_rx_ring; i++)
> +			memcpy(mdp->rx_skbuff[i]->data,
> +			       "Hello, world", 12);
> +		msleep(100);
> +		for (i = 0; i < mdp->num_rx_ring; i++) {
> +			WARN_ON(memcmp(mdp->rx_skbuff[i]->data,
> +				       "Hello, world", 12));
>  			dev_kfree_skb(mdp->rx_skbuff[i]);
> +		}
>  	}
>  	kfree(mdp->rx_skbuff);
>  	mdp->rx_skbuff = NULL;

then ran the loop:

    while ethtool -G eth0 rx 128 ; ethtool -G eth0 rx 64; do echo -n .; done

and 'ping -f' toward the sh_eth port from another machine.  The
warning fired several times a minute.

To fix these issues:

- Deactivate all TX descriptors rather than writing to EDTRR
- As there seems to be no way of telling when RX DMA is stopped,
  perform a soft reset to ensure that both DMA enginess are stopped
- To reduce the possibility of the reset truncating a transmitted
  frame, disable egress and wait a reasonable time to reach a
  packet boundary before resetting
- Update statistics before resetting

(The 'reasonable time' does not allow for CS/CD in half-duplex
mode, but half-duplex no longer seems reasonable!)

Signed-off-by: Ben Hutchings <ben.hutchings@codethink.co.uk>
---
I would prefer to find a way to wait for the DMA engines to stop, so
that it's only necessary to reset if they fail to do so within some time
limit.  But I just don't see it.

Ben.

 drivers/net/ethernet/renesas/sh_eth.c |   39 +++++++++++++++++++++++++++------
 1 file changed, 32 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 3b49375..e43c9ce 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -396,6 +396,9 @@ static const u16 sh_eth_offset_fast_sh3_sh2[SH_ETH_MAX_REGISTER_OFFSET] = {
 	[TSU_ADRL31]	= 0x01fc,
 };
 
+static void sh_eth_rcv_snd_disable(struct net_device *ndev);
+static struct net_device_stats *sh_eth_get_stats(struct net_device *ndev);
+
 static bool sh_eth_is_gether(struct sh_eth_private *mdp)
 {
 	return mdp->reg_offset == sh_eth_offset_gigabit;
@@ -1358,6 +1361,33 @@ static int sh_eth_dev_init(struct net_device *ndev, bool start)
 	return ret;
 }
 
+static void sh_eth_dev_exit(struct net_device *ndev)
+{
+	struct sh_eth_private *mdp = netdev_priv(ndev);
+	int i;
+
+	/* Deactivate all TX descriptors, so DMA should stop at next
+	 * packet boundary if it's currently running
+	 */
+	for (i = 0; i < mdp->num_tx_ring; i++)
+		mdp->tx_ring[i].status &= ~cpu_to_edmac(mdp, TD_TACT);
+
+	/* Disable TX FIFO egress to MAC */
+	sh_eth_rcv_snd_disable(ndev);
+
+	/* Stop RX DMA at next packet boundary */
+	sh_eth_write(ndev, 0, EDRRR);
+
+	/* Aside from TX DMA, we can't tell when the hardware is
+	 * really stopped, so we need to reset to make sure.
+	 * Before doing that, wait for long enough to *probably*
+	 * finish transmitting the last packet and poll stats.
+	 */
+	msleep(2); /* max frame time at 10 Mbps < 1250 us */
+	sh_eth_get_stats(ndev);
+	sh_eth_reset(ndev);
+}
+
 /* free Tx skb function */
 static int sh_eth_txfree(struct net_device *ndev)
 {
@@ -1986,9 +2016,7 @@ static int sh_eth_set_ringparam(struct net_device *ndev,
 		napi_synchronize(&mdp->napi);
 		sh_eth_write(ndev, 0x0000, EESIPR);
 
-		/* Stop the chip's Tx and Rx processes. */
-		sh_eth_write(ndev, 0, EDTRR);
-		sh_eth_write(ndev, 0, EDRRR);
+		sh_eth_dev_exit(ndev);
 
 		/* Free all the skbuffs in the Rx queue. */
 		sh_eth_ring_free(ndev);
@@ -2207,11 +2235,8 @@ static int sh_eth_close(struct net_device *ndev)
 	napi_disable(&mdp->napi);
 	sh_eth_write(ndev, 0x0000, EESIPR);
 
-	/* Stop the chip's Tx and Rx processes. */
-	sh_eth_write(ndev, 0, EDTRR);
-	sh_eth_write(ndev, 0, EDRRR);
+	sh_eth_dev_exit(ndev);
 
-	sh_eth_get_stats(ndev);
 	/* PHY Disconnect */
 	if (mdp->phydev) {
 		phy_stop(mdp->phydev);
-- 
1.7.10.4
