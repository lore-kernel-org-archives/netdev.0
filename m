From: Scott Wood <scottwood@freescale.com>
Subject: [PATCH] gianfar: Add I/O barriers when touching buffer descriptor
	ownership.
Date: Wed, 16 May 2007 15:06:59 -0500
Message-ID: <20070516200659.GA23548@ld0162-tx32.am.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: jgarzik@pobox.com
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
Content-Disposition: inline
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

The hardware must not see that is given ownership of a buffer until it is
completely written, and when the driver receives ownership of a buffer,
it must ensure that any other reads to the buffer reflect its final
state.  Thus, I/O barriers are added where required.

Without this patch, I have observed GCC reordering the setting of
bdp->length and bdp->status in gfar_new_skb.  Hardware reordering
was also theoretically possible.

Signed-off-by: Scott Wood <scottwood@freescale.com>
---
I've added the requested comments to the source code about
the use of eieio().  Jeff, please consider for 2.6.22, as it
fixes a bug that has been observed.

 drivers/net/gianfar.c |   11 +++++++++++
 1 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index b666a0c..f5b3cba 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -1025,6 +1025,15 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	dev->trans_start = jiffies;
 
+	/* The powerpc-specific eieio() is used, as wmb() has too strong
+	 * semantics (it requires synchronization between cacheable and
+	 * uncacheable mappings, which eieio doesn't provide and which we
+	 * don't need), thus requiring a more expensive sync instruction.  At
+	 * some point, the set of architecture-independent barrier functions
+	 * should be expanded to include weaker barriers.
+	 */
+
+	eieio();
 	txbdp->status = status;
 
 	/* If this was the last BD in the ring, the next one */
@@ -1301,6 +1310,7 @@ struct sk_buff * gfar_new_skb(struct net_device *dev, struct rxbd8 *bdp)
 	bdp->length = 0;
 
 	/* Mark the buffer empty */
+	eieio();
 	bdp->status |= (RXBD_EMPTY | RXBD_INTERRUPT);
 
 	return skb;
@@ -1484,6 +1494,7 @@ int gfar_clean_rx_ring(struct net_device *dev, int rx_work_limit)
 	bdp = priv->cur_rx;
 
 	while (!((bdp->status & RXBD_EMPTY) || (--rx_work_limit < 0))) {
+		rmb();
 		skb = priv->rx_skbuff[priv->skb_currx];
 
 		if (!(bdp->status &
-- 
1.5.0.3
