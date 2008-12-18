From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] netpoll: fix race on poll_list resulting in garbage
	entry
Date: Wed, 17 Dec 2008 20:13:06 -0500
Message-ID: <20081218011306.GA32191@hmsreliant.think-freely.org>
References: <20081211181528.GB10558@hmsendeavour.rdu.redhat.com> <20081211160307.20709435@s6510> <20081212121835.GA2402@hmsreliant.think-freely.org> <20081216.155540.34452478.davem@davemloft.net> <20081217211628.GD7356@hmsreliant.think-freely.org> <20081217133131.44a4f67f@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, jarkao2@gmail.com,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:55586 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750904AbYLRBPd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 20:15:33 -0500
Content-Disposition: inline
In-Reply-To: <20081217133131.44a4f67f@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 17, 2008 at 01:31:31PM -0800, Stephen Hemminger wrote:
> On Wed, 17 Dec 2008 16:16:28 -0500
> Neil Horman <nhorman@tuxdriver.com> wrote:
> 
> > On Tue, Dec 16, 2008 at 03:55:40PM -0800, David Miller wrote:
> > > From: Neil Horman <nhorman@tuxdriver.com>
> > > Date: Fri, 12 Dec 2008 07:18:35 -0500
> > > 
> > > > On Thu, Dec 11, 2008 at 04:03:07PM -0800, Stephen Hemminger wrote:
> > > > > I would ask it the other way. Why is interface an argument to netif_rx_complete
> > > > > if it is never used?  
> > > > > 
> > > > Thats a fair question, and I don't know the answer, Dave?
> > > 
> > > That's just what the old code uses, since the NAPI context
> > > sat inside of the device.  I just never removed it.
> > 
> > 
> > To that end, Dave, I've got a tree with that api fixup complete.  Its on the
> > napi_api_fixup branch of the tree here:
> > http://git.infradead.org/users/nhorman/net-2.6.git?a=shortlog;h=refs/heads/napi_api_fixup
> > 
> > If you'd like to pull it, please go ahead, or I can submit individual patches
> > for it, if you prefer
> > 
> > Regards
> > Neil
> > 
> > > --
> > > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > > the body of a message to majordomo@vger.kernel.org
> > > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > > 
> > 
> 
> Since this a kernel API change, you have to do it as a one big patch
> otherwise the kernel source won't build for the intermediate steps,
> which makes 'git bisect' impossible.  Please merge the patches together.
> 

Ok, here you go, one omnibus patch

Since we migrated the napi polling infrastructure out of the net_device
structure, the netif_rx_[prep|schedule|complete] api has taken a net_device
structure pointer, which in all cases goes unused.  This patch modifies the api
to remove that parameter, and fixes up all the required call sites.

I've obviously not tested it with all available NICS, but I built an
allmodconfig sucessfully with no errors introduced, and booted a kernel with
htis change on a few systems.

Regards
Neil

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>


 drivers/infiniband/hw/nes/nes_hw.c      |    2 +-
 drivers/infiniband/hw/nes/nes_nic.c     |    2 +-
 drivers/infiniband/ulp/ipoib/ipoib_ib.c |    6 +++---
 drivers/net/8139cp.c                    |    6 +++---
 drivers/net/8139too.c                   |    6 +++---
 drivers/net/amd8111e.c                  |    6 +++---
 drivers/net/arm/ep93xx_eth.c            |    6 +++---
 drivers/net/arm/ixp4xx_eth.c            |    6 +++---
 drivers/net/atl1e/atl1e_main.c          |    6 +++---
 drivers/net/b44.c                       |    6 +++---
 drivers/net/bnx2.c                      |   15 ++++++---------
 drivers/net/bnx2x_main.c                |    6 +++---
 drivers/net/cassini.c                   |    8 ++++----
 drivers/net/chelsio/sge.c               |    4 ++--
 drivers/net/cpmac.c                     |   10 +++++-----
 drivers/net/e100.c                      |    7 +++----
 drivers/net/e1000/e1000_main.c          |   10 +++++-----
 drivers/net/e1000e/netdev.c             |   14 +++++++-------
 drivers/net/ehea/ehea_main.c            |    6 +++---
 drivers/net/enic/enic_main.c            |   12 ++++++------
 drivers/net/epic100.c                   |    6 +++---
 drivers/net/forcedeth.c                 |   10 +++++-----
 drivers/net/fs_enet/fs_enet-main.c      |    4 ++--
 drivers/net/gianfar.c                   |    6 +++---
 drivers/net/ibmveth.c                   |    6 +++---
 drivers/net/igb/igb_main.c              |   12 ++++++------
 drivers/net/ixgb/ixgb_main.c            |    6 +++---
 drivers/net/ixgbe/ixgbe_main.c          |   12 ++++++------
 drivers/net/ixp2000/ixpdev.c            |    4 ++--
 drivers/net/jme.c                       |    1 -
 drivers/net/jme.h                       |    6 +++---
 drivers/net/korina.c                    |    4 ++--
 drivers/net/macb.c                      |   10 +++++-----
 drivers/net/mlx4/en_rx.c                |    4 ++--
 drivers/net/myri10ge/myri10ge.c         |    6 +++---
 drivers/net/natsemi.c                   |    6 +++---
 drivers/net/netxen/netxen_nic_main.c    |    2 +-
 drivers/net/niu.c                       |    6 +++---
 drivers/net/pasemi_mac.c                |    6 +++---
 drivers/net/pcnet32.c                   |    6 +++---
 drivers/net/qla3xxx.c                   |    6 +++---
 drivers/net/qlge/qlge_main.c            |    7 +++----
 drivers/net/r6040.c                     |    4 ++--
 drivers/net/r8169.c                     |    6 +++---
 drivers/net/s2io.c                      |    8 ++++----
 drivers/net/sb1250-mac.c                |    6 +++---
 drivers/net/sfc/efx.c                   |    4 ++--
 drivers/net/sfc/efx.h                   |    2 +-
 drivers/net/skge.c                      |    6 +++---
 drivers/net/spider_net.c                |   15 ++++++---------
 drivers/net/starfire.c                  |    6 +++---
 drivers/net/sungem.c                    |    6 +++---
 drivers/net/tc35815.c                   |    6 +++---
 drivers/net/tehuti.c                    |    7 +++----
 drivers/net/tg3.c                       |   14 +++++++-------
 drivers/net/tsi108_eth.c                |    6 +++---
 drivers/net/tulip/interrupt.c           |    8 ++++----
 drivers/net/typhoon.c                   |    7 +++----
 drivers/net/ucc_geth.c                  |    6 +++---
 drivers/net/via-rhine.c                 |    4 ++--
 drivers/net/virtio_net.c                |   12 ++++++------
 drivers/net/xen-netfront.c              |    8 ++++----
 include/linux/netdevice.h               |   26 ++++++++++----------------
 63 files changed, 215 insertions(+), 232 deletions(-)


diff --git a/drivers/infiniband/hw/nes/nes_hw.c b/drivers/infiniband/hw/nes/nes_hw.c
index 7c49cc8..735c125 100644
--- a/drivers/infiniband/hw/nes/nes_hw.c
+++ b/drivers/infiniband/hw/nes/nes_hw.c
@@ -2541,7 +2541,7 @@ static void nes_nic_napi_ce_handler(struct nes_device *nesdev, struct nes_hw_nic
 {
 	struct nes_vnic *nesvnic = container_of(cq, struct nes_vnic, nic_cq);
 
-	netif_rx_schedule(nesdev->netdev[nesvnic->netdev_index], &nesvnic->napi);
+	netif_rx_schedule(&nesvnic->napi);
 }
 
 
diff --git a/drivers/infiniband/hw/nes/nes_nic.c b/drivers/infiniband/hw/nes/nes_nic.c
index 7303586..31ba26b 100644
--- a/drivers/infiniband/hw/nes/nes_nic.c
+++ b/drivers/infiniband/hw/nes/nes_nic.c
@@ -112,7 +112,7 @@ static int nes_netdev_poll(struct napi_struct *napi, int budget)
 	nes_nic_ce_handler(nesdev, nescq);
 
 	if (nescq->cqes_pending == 0) {
-		netif_rx_complete(netdev, napi);
+		netif_rx_complete(napi);
 		/* clear out completed cqes and arm */
 		nes_write32(nesdev->regs+NES_CQE_ALLOC, NES_CQE_ALLOC_NOTIFY_NEXT |
 				nescq->cq_number | (nescq->cqe_allocs_pending << 16));
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_ib.c b/drivers/infiniband/ulp/ipoib/ipoib_ib.c
index 28eb6f0..a192581 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_ib.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_ib.c
@@ -446,11 +446,11 @@ poll_more:
 		if (dev->features & NETIF_F_LRO)
 			lro_flush_all(&priv->lro.lro_mgr);
 
-		netif_rx_complete(dev, napi);
+		netif_rx_complete(napi);
 		if (unlikely(ib_req_notify_cq(priv->recv_cq,
 					      IB_CQ_NEXT_COMP |
 					      IB_CQ_REPORT_MISSED_EVENTS)) &&
-		    netif_rx_reschedule(dev, napi))
+		    netif_rx_reschedule(napi))
 			goto poll_more;
 	}
 
@@ -462,7 +462,7 @@ void ipoib_ib_completion(struct ib_cq *cq, void *dev_ptr)
 	struct net_device *dev = dev_ptr;
 	struct ipoib_dev_priv *priv = netdev_priv(dev);
 
-	netif_rx_schedule(dev, &priv->napi);
+	netif_rx_schedule(&priv->napi);
 }
 
 static void drain_tx_cq(struct net_device *dev)
diff --git a/drivers/net/8139cp.c b/drivers/net/8139cp.c
index 9ba1f0b..1fc5974 100644
--- a/drivers/net/8139cp.c
+++ b/drivers/net/8139cp.c
@@ -605,7 +605,7 @@ rx_next:
 
 		spin_lock_irqsave(&cp->lock, flags);
 		cpw16_f(IntrMask, cp_intr_mask);
-		__netif_rx_complete(dev, napi);
+		__netif_rx_complete(napi);
 		spin_unlock_irqrestore(&cp->lock, flags);
 	}
 
@@ -642,9 +642,9 @@ static irqreturn_t cp_interrupt (int irq, void *dev_instance)
 	}
 
 	if (status & (RxOK | RxErr | RxEmpty | RxFIFOOvr))
-		if (netif_rx_schedule_prep(dev, &cp->napi)) {
+		if (netif_rx_schedule_prep(&cp->napi)) {
 			cpw16_f(IntrMask, cp_norx_intr_mask);
-			__netif_rx_schedule(dev, &cp->napi);
+			__netif_rx_schedule(&cp->napi);
 		}
 
 	if (status & (TxOK | TxErr | TxEmpty | SWInt))
diff --git a/drivers/net/8139too.c b/drivers/net/8139too.c
index 63f906b..1567042 100644
--- a/drivers/net/8139too.c
+++ b/drivers/net/8139too.c
@@ -2129,7 +2129,7 @@ static int rtl8139_poll(struct napi_struct *napi, int budget)
 		 */
 		spin_lock_irqsave(&tp->lock, flags);
 		RTL_W16_F(IntrMask, rtl8139_intr_mask);
-		__netif_rx_complete(dev, napi);
+		__netif_rx_complete(napi);
 		spin_unlock_irqrestore(&tp->lock, flags);
 	}
 	spin_unlock(&tp->rx_lock);
@@ -2179,9 +2179,9 @@ static irqreturn_t rtl8139_interrupt (int irq, void *dev_instance)
 	/* Receive packets are processed by poll routine.
 	   If not running start it now. */
 	if (status & RxAckBits){
-		if (netif_rx_schedule_prep(dev, &tp->napi)) {
+		if (netif_rx_schedule_prep(&tp->napi)) {
 			RTL_W16_F (IntrMask, rtl8139_norx_intr_mask);
-			__netif_rx_schedule(dev, &tp->napi);
+			__netif_rx_schedule(&tp->napi);
 		}
 	}
 
diff --git a/drivers/net/amd8111e.c b/drivers/net/amd8111e.c
index 07a6697..55a343f 100644
--- a/drivers/net/amd8111e.c
+++ b/drivers/net/amd8111e.c
@@ -832,7 +832,7 @@ static int amd8111e_rx_poll(struct napi_struct *napi, int budget)
 	if (rx_pkt_limit > 0) {
 		/* Receive descriptor is empty now */
 		spin_lock_irqsave(&lp->lock, flags);
-		__netif_rx_complete(dev, napi);
+		__netif_rx_complete(napi);
 		writel(VAL0|RINTEN0, mmio + INTEN0);
 		writel(VAL2 | RDMD0, mmio + CMD0);
 		spin_unlock_irqrestore(&lp->lock, flags);
@@ -1171,11 +1171,11 @@ static irqreturn_t amd8111e_interrupt(int irq, void *dev_id)
 
 	/* Check if Receive Interrupt has occurred. */
 	if (intr0 & RINT0) {
-		if (netif_rx_schedule_prep(dev, &lp->napi)) {
+		if (netif_rx_schedule_prep(&lp->napi)) {
 			/* Disable receive interupts */
 			writel(RINTEN0, mmio + INTEN0);
 			/* Schedule a polling routine */
-			__netif_rx_schedule(dev, &lp->napi);
+			__netif_rx_schedule(&lp->napi);
 		} else if (intren0 & RINTEN0) {
 			printk("************Driver bug! \
 				interrupt while in poll\n");
diff --git a/drivers/net/arm/ep93xx_eth.c b/drivers/net/arm/ep93xx_eth.c
index 1267444..8756010 100644
--- a/drivers/net/arm/ep93xx_eth.c
+++ b/drivers/net/arm/ep93xx_eth.c
@@ -300,7 +300,7 @@ poll_some_more:
 		int more = 0;
 
 		spin_lock_irq(&ep->rx_lock);
-		__netif_rx_complete(dev, napi);
+		__netif_rx_complete(napi);
 		wrl(ep, REG_INTEN, REG_INTEN_TX | REG_INTEN_RX);
 		if (ep93xx_have_more_rx(ep)) {
 			wrl(ep, REG_INTEN, REG_INTEN_TX);
@@ -417,9 +417,9 @@ static irqreturn_t ep93xx_irq(int irq, void *dev_id)
 
 	if (status & REG_INTSTS_RX) {
 		spin_lock(&ep->rx_lock);
-		if (likely(netif_rx_schedule_prep(dev, &ep->napi))) {
+		if (likely(netif_rx_schedule_prep(&ep->napi))) {
 			wrl(ep, REG_INTEN, REG_INTEN_TX);
-			__netif_rx_schedule(dev, &ep->napi);
+			__netif_rx_schedule(&ep->napi);
 		}
 		spin_unlock(&ep->rx_lock);
 	}
diff --git a/drivers/net/arm/ixp4xx_eth.c b/drivers/net/arm/ixp4xx_eth.c
index e2d702b..f4de6dd 100644
--- a/drivers/net/arm/ixp4xx_eth.c
+++ b/drivers/net/arm/ixp4xx_eth.c
@@ -498,7 +498,7 @@ static void eth_rx_irq(void *pdev)
 	printk(KERN_DEBUG "%s: eth_rx_irq\n", dev->name);
 #endif
 	qmgr_disable_irq(port->plat->rxq);
-	netif_rx_schedule(dev, &port->napi);
+	netif_rx_schedule(&port->napi);
 }
 
 static int eth_poll(struct napi_struct *napi, int budget)
@@ -526,7 +526,7 @@ static int eth_poll(struct napi_struct *napi, int budget)
 			printk(KERN_DEBUG "%s: eth_poll netif_rx_complete\n",
 			       dev->name);
 #endif
-			netif_rx_complete(dev, napi);
+			netif_rx_complete(napi);
 			qmgr_enable_irq(rxq);
 			if (!qmgr_stat_empty(rxq) &&
 			    netif_rx_reschedule(dev, napi)) {
@@ -1026,7 +1026,7 @@ static int eth_open(struct net_device *dev)
 	}
 	ports_open++;
 	/* we may already have RX data, enables IRQ */
-	netif_rx_schedule(dev, &port->napi);
+	netif_rx_schedule(&port->napi);
 	return 0;
 }
 
diff --git a/drivers/net/atl1e/atl1e_main.c b/drivers/net/atl1e/atl1e_main.c
index 9b60352..368b626 100644
--- a/drivers/net/atl1e/atl1e_main.c
+++ b/drivers/net/atl1e/atl1e_main.c
@@ -1326,9 +1326,9 @@ static irqreturn_t atl1e_intr(int irq, void *data)
 			AT_WRITE_REG(hw, REG_IMR,
 				     IMR_NORMAL_MASK & ~ISR_RX_EVENT);
 			AT_WRITE_FLUSH(hw);
-			if (likely(netif_rx_schedule_prep(netdev,
+			if (likely(netif_rx_schedule_prep(
 				   &adapter->napi)))
-				__netif_rx_schedule(netdev, &adapter->napi);
+				__netif_rx_schedule(&adapter->napi);
 		}
 	} while (--max_ints > 0);
 	/* re-enable Interrupt*/
@@ -1516,7 +1516,7 @@ static int atl1e_clean(struct napi_struct *napi, int budget)
 	/* If no Tx and not enough Rx work done, exit the polling mode */
 	if (work_done < budget) {
 quit_polling:
-		netif_rx_complete(netdev, napi);
+		netif_rx_complete(napi);
 		imr_data = AT_READ_REG(&adapter->hw, REG_IMR);
 		AT_WRITE_REG(&adapter->hw, REG_IMR, imr_data | ISR_RX_EVENT);
 		/* test debug */
diff --git a/drivers/net/b44.c b/drivers/net/b44.c
index c3bda5c..e4ba7c9 100644
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -876,7 +876,7 @@ static int b44_poll(struct napi_struct *napi, int budget)
 	}
 
 	if (work_done < budget) {
-		netif_rx_complete(netdev, napi);
+		netif_rx_complete(napi);
 		b44_enable_ints(bp);
 	}
 
@@ -908,13 +908,13 @@ static irqreturn_t b44_interrupt(int irq, void *dev_id)
 			goto irq_ack;
 		}
 
-		if (netif_rx_schedule_prep(dev, &bp->napi)) {
+		if (netif_rx_schedule_prep(&bp->napi)) {
 			/* NOTE: These writes are posted by the readback of
 			 *       the ISTAT register below.
 			 */
 			bp->istat = istat;
 			__b44_disable_ints(bp);
-			__netif_rx_schedule(dev, &bp->napi);
+			__netif_rx_schedule(&bp->napi);
 		} else {
 			printk(KERN_ERR PFX "%s: Error, poll already scheduled\n",
 			       dev->name);
diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index a1a3d0e..9d24e32 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -3040,7 +3040,6 @@ bnx2_msi(int irq, void *dev_instance)
 {
 	struct bnx2_napi *bnapi = dev_instance;
 	struct bnx2 *bp = bnapi->bp;
-	struct net_device *dev = bp->dev;
 
 	prefetch(bnapi->status_blk.msi);
 	REG_WR(bp, BNX2_PCICFG_INT_ACK_CMD,
@@ -3051,7 +3050,7 @@ bnx2_msi(int irq, void *dev_instance)
 	if (unlikely(atomic_read(&bp->intr_sem) != 0))
 		return IRQ_HANDLED;
 
-	netif_rx_schedule(dev, &bnapi->napi);
+	netif_rx_schedule(&bnapi->napi);
 
 	return IRQ_HANDLED;
 }
@@ -3061,7 +3060,6 @@ bnx2_msi_1shot(int irq, void *dev_instance)
 {
 	struct bnx2_napi *bnapi = dev_instance;
 	struct bnx2 *bp = bnapi->bp;
-	struct net_device *dev = bp->dev;
 
 	prefetch(bnapi->status_blk.msi);
 
@@ -3069,7 +3067,7 @@ bnx2_msi_1shot(int irq, void *dev_instance)
 	if (unlikely(atomic_read(&bp->intr_sem) != 0))
 		return IRQ_HANDLED;
 
-	netif_rx_schedule(dev, &bnapi->napi);
+	netif_rx_schedule(&bnapi->napi);
 
 	return IRQ_HANDLED;
 }
@@ -3079,7 +3077,6 @@ bnx2_interrupt(int irq, void *dev_instance)
 {
 	struct bnx2_napi *bnapi = dev_instance;
 	struct bnx2 *bp = bnapi->bp;
-	struct net_device *dev = bp->dev;
 	struct status_block *sblk = bnapi->status_blk.msi;
 
 	/* When using INTx, it is possible for the interrupt to arrive
@@ -3106,9 +3103,9 @@ bnx2_interrupt(int irq, void *dev_instance)
 	if (unlikely(atomic_read(&bp->intr_sem) != 0))
 		return IRQ_HANDLED;
 
-	if (netif_rx_schedule_prep(dev, &bnapi->napi)) {
+	if (netif_rx_schedule_prep(&bnapi->napi)) {
 		bnapi->last_status_idx = sblk->status_idx;
-		__netif_rx_schedule(dev, &bnapi->napi);
+		__netif_rx_schedule(&bnapi->napi);
 	}
 
 	return IRQ_HANDLED;
@@ -3218,7 +3215,7 @@ static int bnx2_poll_msix(struct napi_struct *napi, int budget)
 		rmb();
 		if (likely(!bnx2_has_fast_work(bnapi))) {
 
-			netif_rx_complete(bp->dev, napi);
+			netif_rx_complete(napi);
 			REG_WR(bp, BNX2_PCICFG_INT_ACK_CMD, bnapi->int_num |
 			       BNX2_PCICFG_INT_ACK_CMD_INDEX_VALID |
 			       bnapi->last_status_idx);
@@ -3251,7 +3248,7 @@ static int bnx2_poll(struct napi_struct *napi, int budget)
 
 		rmb();
 		if (likely(!bnx2_has_work(bnapi))) {
-			netif_rx_complete(bp->dev, napi);
+			netif_rx_complete(napi);
 			if (likely(bp->flags & BNX2_FLAG_USING_MSI_OR_MSIX)) {
 				REG_WR(bp, BNX2_PCICFG_INT_ACK_CMD,
 				       BNX2_PCICFG_INT_ACK_CMD_INDEX_VALID |
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 600210d..1994b58 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -1617,7 +1617,7 @@ static irqreturn_t bnx2x_msix_fp_int(int irq, void *fp_cookie)
 	prefetch(&fp->status_blk->c_status_block.status_block_index);
 	prefetch(&fp->status_blk->u_status_block.status_block_index);
 
-	netif_rx_schedule(dev, &bnx2x_fp(bp, index, napi));
+	netif_rx_schedule(&bnx2x_fp(bp, index, napi));
 
 	return IRQ_HANDLED;
 }
@@ -1656,7 +1656,7 @@ static irqreturn_t bnx2x_interrupt(int irq, void *dev_instance)
 		prefetch(&fp->status_blk->c_status_block.status_block_index);
 		prefetch(&fp->status_blk->u_status_block.status_block_index);
 
-		netif_rx_schedule(dev, &bnx2x_fp(bp, 0, napi));
+		netif_rx_schedule(&bnx2x_fp(bp, 0, napi));
 
 		status &= ~mask;
 	}
@@ -9287,7 +9287,7 @@ static int bnx2x_poll(struct napi_struct *napi, int budget)
 #ifdef BNX2X_STOP_ON_ERROR
 poll_panic:
 #endif
-		netif_rx_complete(bp->dev, napi);
+		netif_rx_complete(napi);
 
 		bnx2x_ack_sb(bp, FP_SB_ID(fp), USTORM_ID,
 			     le16_to_cpu(fp->fp_u_idx), IGU_INT_NOP, 1);
diff --git a/drivers/net/cassini.c b/drivers/net/cassini.c
index 86909cf..a4f4142 100644
--- a/drivers/net/cassini.c
+++ b/drivers/net/cassini.c
@@ -2507,7 +2507,7 @@ static irqreturn_t cas_interruptN(int irq, void *dev_id)
 	if (status & INTR_RX_DONE_ALT) { /* handle rx separately */
 #ifdef USE_NAPI
 		cas_mask_intr(cp);
-		netif_rx_schedule(dev, &cp->napi);
+		netif_rx_schedule(&cp->napi);
 #else
 		cas_rx_ringN(cp, ring, 0);
 #endif
@@ -2558,7 +2558,7 @@ static irqreturn_t cas_interrupt1(int irq, void *dev_id)
 	if (status & INTR_RX_DONE_ALT) { /* handle rx separately */
 #ifdef USE_NAPI
 		cas_mask_intr(cp);
-		netif_rx_schedule(dev, &cp->napi);
+		netif_rx_schedule(&cp->napi);
 #else
 		cas_rx_ringN(cp, 1, 0);
 #endif
@@ -2614,7 +2614,7 @@ static irqreturn_t cas_interrupt(int irq, void *dev_id)
 	if (status & INTR_RX_DONE) {
 #ifdef USE_NAPI
 		cas_mask_intr(cp);
-		netif_rx_schedule(dev, &cp->napi);
+		netif_rx_schedule(&cp->napi);
 #else
 		cas_rx_ringN(cp, 0, 0);
 #endif
@@ -2692,7 +2692,7 @@ rx_comp:
 #endif
 	spin_unlock_irqrestore(&cp->lock, flags);
 	if (enable_intr) {
-		netif_rx_complete(dev, napi);
+		netif_rx_complete(napi);
 		cas_unmask_intr(cp);
 	}
 	return credits;
diff --git a/drivers/net/chelsio/sge.c b/drivers/net/chelsio/sge.c
index 7092df5..e7b054b 100644
--- a/drivers/net/chelsio/sge.c
+++ b/drivers/net/chelsio/sge.c
@@ -1614,7 +1614,7 @@ int t1_poll(struct napi_struct *napi, int budget)
 	int work_done = process_responses(adapter, budget);
 
 	if (likely(work_done < budget)) {
-		netif_rx_complete(dev, napi);
+		netif_rx_complete(napi);
 		writel(adapter->sge->respQ.cidx,
 		       adapter->regs + A_SG_SLEEPING);
 	}
@@ -1634,7 +1634,7 @@ irqreturn_t t1_interrupt(int irq, void *data)
 
 		if (napi_schedule_prep(&adapter->napi)) {
 			if (process_pure_responses(adapter))
-				__netif_rx_schedule(dev, &adapter->napi);
+				__netif_rx_schedule(&adapter->napi);
 			else {
 				/* no data, no NAPI needed */
 				writel(sge->respQ.cidx, adapter->regs + A_SG_SLEEPING);
diff --git a/drivers/net/cpmac.c b/drivers/net/cpmac.c
index 017a536..1a62907 100644
--- a/drivers/net/cpmac.c
+++ b/drivers/net/cpmac.c
@@ -428,7 +428,7 @@ static int cpmac_poll(struct napi_struct *napi, int budget)
 			printk(KERN_WARNING "%s: rx: polling, but no queue\n",
 			       priv->dev->name);
 		spin_unlock(&priv->rx_lock);
-		netif_rx_complete(priv->dev, napi);
+		netif_rx_complete(napi);
 		return 0;
 	}
 
@@ -514,7 +514,7 @@ static int cpmac_poll(struct napi_struct *napi, int budget)
 	if (processed == 0) {
 		/* we ran out of packets to read,
 		 * revert to interrupt-driven mode */
-		netif_rx_complete(priv->dev, napi);
+		netif_rx_complete(napi);
 		cpmac_write(priv->regs, CPMAC_RX_INT_ENABLE, 1);
 		return 0;
 	}
@@ -536,7 +536,7 @@ fatal_error:
 	}
 
 	spin_unlock(&priv->rx_lock);
-	netif_rx_complete(priv->dev, napi);
+	netif_rx_complete(napi);
 	netif_tx_stop_all_queues(priv->dev);
 	napi_disable(&priv->napi);
 
@@ -802,9 +802,9 @@ static irqreturn_t cpmac_irq(int irq, void *dev_id)
 
 	if (status & MAC_INT_RX) {
 		queue = (status >> 8) & 7;
-		if (netif_rx_schedule_prep(dev, &priv->napi)) {
+		if (netif_rx_schedule_prep(&priv->napi)) {
 			cpmac_write(priv->regs, CPMAC_RX_INT_CLEAR, 1 << queue);
-			__netif_rx_schedule(dev, &priv->napi);
+			__netif_rx_schedule(&priv->napi);
 		}
 	}
 
diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index e8bfcce..99cb07b 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -2048,9 +2048,9 @@ static irqreturn_t e100_intr(int irq, void *dev_id)
 	if(stat_ack & stat_ack_rnr)
 		nic->ru_running = RU_SUSPENDED;
 
-	if(likely(netif_rx_schedule_prep(netdev, &nic->napi))) {
+	if(likely(netif_rx_schedule_prep(&nic->napi))) {
 		e100_disable_irq(nic);
-		__netif_rx_schedule(netdev, &nic->napi);
+		__netif_rx_schedule(&nic->napi);
 	}
 
 	return IRQ_HANDLED;
@@ -2059,7 +2059,6 @@ static irqreturn_t e100_intr(int irq, void *dev_id)
 static int e100_poll(struct napi_struct *napi, int budget)
 {
 	struct nic *nic = container_of(napi, struct nic, napi);
-	struct net_device *netdev = nic->netdev;
 	unsigned int work_done = 0;
 
 	e100_rx_clean(nic, &work_done, budget);
@@ -2067,7 +2066,7 @@ static int e100_poll(struct napi_struct *napi, int budget)
 
 	/* If budget not fully consumed, exit the polling mode */
 	if (work_done < budget) {
-		netif_rx_complete(netdev, napi);
+		netif_rx_complete(napi);
 		e100_enable_irq(nic);
 	}
 
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 872799b..27aefd4 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -3707,12 +3707,12 @@ static irqreturn_t e1000_intr_msi(int irq, void *data)
 			mod_timer(&adapter->watchdog_timer, jiffies + 1);
 	}
 
-	if (likely(netif_rx_schedule_prep(netdev, &adapter->napi))) {
+	if (likely(netif_rx_schedule_prep(&adapter->napi))) {
 		adapter->total_tx_bytes = 0;
 		adapter->total_tx_packets = 0;
 		adapter->total_rx_bytes = 0;
 		adapter->total_rx_packets = 0;
-		__netif_rx_schedule(netdev, &adapter->napi);
+		__netif_rx_schedule(&adapter->napi);
 	} else
 		e1000_irq_enable(adapter);
 
@@ -3767,12 +3767,12 @@ static irqreturn_t e1000_intr(int irq, void *data)
 		ew32(IMC, ~0);
 		E1000_WRITE_FLUSH();
 	}
-	if (likely(netif_rx_schedule_prep(netdev, &adapter->napi))) {
+	if (likely(netif_rx_schedule_prep(&adapter->napi))) {
 		adapter->total_tx_bytes = 0;
 		adapter->total_tx_packets = 0;
 		adapter->total_rx_bytes = 0;
 		adapter->total_rx_packets = 0;
-		__netif_rx_schedule(netdev, &adapter->napi);
+		__netif_rx_schedule(&adapter->napi);
 	} else
 		/* this really should not happen! if it does it is basically a
 		 * bug, but not a hard error, so enable ints and continue */
@@ -3814,7 +3814,7 @@ static int e1000_clean(struct napi_struct *napi, int budget)
 	if (work_done < budget) {
 		if (likely(adapter->itr_setting & 3))
 			e1000_set_itr(adapter);
-		netif_rx_complete(poll_dev, napi);
+		netif_rx_complete(napi);
 		e1000_irq_enable(adapter);
 	}
 
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 122539a..1fb888d 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -1181,12 +1181,12 @@ static irqreturn_t e1000_intr_msi(int irq, void *data)
 			mod_timer(&adapter->watchdog_timer, jiffies + 1);
 	}
 
-	if (netif_rx_schedule_prep(netdev, &adapter->napi)) {
+	if (netif_rx_schedule_prep(&adapter->napi)) {
 		adapter->total_tx_bytes = 0;
 		adapter->total_tx_packets = 0;
 		adapter->total_rx_bytes = 0;
 		adapter->total_rx_packets = 0;
-		__netif_rx_schedule(netdev, &adapter->napi);
+		__netif_rx_schedule(&adapter->napi);
 	}
 
 	return IRQ_HANDLED;
@@ -1248,12 +1248,12 @@ static irqreturn_t e1000_intr(int irq, void *data)
 			mod_timer(&adapter->watchdog_timer, jiffies + 1);
 	}
 
-	if (netif_rx_schedule_prep(netdev, &adapter->napi)) {
+	if (netif_rx_schedule_prep(&adapter->napi)) {
 		adapter->total_tx_bytes = 0;
 		adapter->total_tx_packets = 0;
 		adapter->total_rx_bytes = 0;
 		adapter->total_rx_packets = 0;
-		__netif_rx_schedule(netdev, &adapter->napi);
+		__netif_rx_schedule(&adapter->napi);
 	}
 
 	return IRQ_HANDLED;
@@ -1322,10 +1322,10 @@ static irqreturn_t e1000_intr_msix_rx(int irq, void *data)
 		adapter->rx_ring->set_itr = 0;
 	}
 
-	if (netif_rx_schedule_prep(netdev, &adapter->napi)) {
+	if (netif_rx_schedule_prep(&adapter->napi)) {
 		adapter->total_rx_bytes = 0;
 		adapter->total_rx_packets = 0;
-		__netif_rx_schedule(netdev, &adapter->napi);
+		__netif_rx_schedule(&adapter->napi);
 	}
 	return IRQ_HANDLED;
 }
@@ -2031,7 +2031,7 @@ clean_rx:
 	if (work_done < budget) {
 		if (adapter->itr_setting & 3)
 			e1000_set_itr(adapter);
-		netif_rx_complete(poll_dev, napi);
+		netif_rx_complete(napi);
 		if (adapter->msix_entries)
 			ew32(IMS, adapter->rx_ring->ims_val);
 		else
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index 422fcb9..54cb696 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -831,7 +831,7 @@ static int ehea_poll(struct napi_struct *napi, int budget)
 	while ((rx != budget) || force_irq) {
 		pr->poll_counter = 0;
 		force_irq = 0;
-		netif_rx_complete(dev, napi);
+		netif_rx_complete(napi);
 		ehea_reset_cq_ep(pr->recv_cq);
 		ehea_reset_cq_ep(pr->send_cq);
 		ehea_reset_cq_n1(pr->recv_cq);
@@ -860,7 +860,7 @@ static void ehea_netpoll(struct net_device *dev)
 	int i;
 
 	for (i = 0; i < port->num_def_qps; i++)
-		netif_rx_schedule(dev, &port->port_res[i].napi);
+		netif_rx_schedule(&port->port_res[i].napi);
 }
 #endif
 
@@ -868,7 +868,7 @@ static irqreturn_t ehea_recv_irq_handler(int irq, void *param)
 {
 	struct ehea_port_res *pr = param;
 
-	netif_rx_schedule(pr->port->netdev, &pr->napi);
+	netif_rx_schedule(&pr->napi);
 
 	return IRQ_HANDLED;
 }
diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index 180e968..b3249b3 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -409,8 +409,8 @@ static irqreturn_t enic_isr_legacy(int irq, void *data)
 	}
 
 	if (ENIC_TEST_INTR(pba, ENIC_INTX_WQ_RQ)) {
-		if (netif_rx_schedule_prep(netdev, &enic->napi))
-			__netif_rx_schedule(netdev, &enic->napi);
+		if (netif_rx_schedule_prep(&enic->napi))
+			__netif_rx_schedule(&enic->napi);
 	} else {
 		vnic_intr_unmask(&enic->intr[ENIC_INTX_WQ_RQ]);
 	}
@@ -438,7 +438,7 @@ static irqreturn_t enic_isr_msi(int irq, void *data)
 	 * writes).
 	 */
 
-	netif_rx_schedule(enic->netdev, &enic->napi);
+	netif_rx_schedule(&enic->napi);
 
 	return IRQ_HANDLED;
 }
@@ -448,7 +448,7 @@ static irqreturn_t enic_isr_msix_rq(int irq, void *data)
 	struct enic *enic = data;
 
 	/* schedule NAPI polling for RQ cleanup */
-	netif_rx_schedule(enic->netdev, &enic->napi);
+	netif_rx_schedule(&enic->napi);
 
 	return IRQ_HANDLED;
 }
@@ -1066,7 +1066,7 @@ static int enic_poll(struct napi_struct *napi, int budget)
 		if (ENIC_SETTING(enic, LRO))
 			lro_flush_all(&enic->lro_mgr);
 
-		netif_rx_complete(netdev, napi);
+		netif_rx_complete(napi);
 		vnic_intr_unmask(&enic->intr[ENIC_MSIX_RQ]);
 	}
 
@@ -1110,7 +1110,7 @@ static int enic_poll_msix(struct napi_struct *napi, int budget)
 		if (ENIC_SETTING(enic, LRO))
 			lro_flush_all(&enic->lro_mgr);
 
-		netif_rx_complete(netdev, napi);
+		netif_rx_complete(napi);
 		vnic_intr_unmask(&enic->intr[ENIC_MSIX_RQ]);
 	}
 
diff --git a/drivers/net/epic100.c b/drivers/net/epic100.c
index 76118dd..b324c06 100644
--- a/drivers/net/epic100.c
+++ b/drivers/net/epic100.c
@@ -1110,9 +1110,9 @@ static irqreturn_t epic_interrupt(int irq, void *dev_instance)
 
 	if ((status & EpicNapiEvent) && !ep->reschedule_in_poll) {
 		spin_lock(&ep->napi_lock);
-		if (netif_rx_schedule_prep(dev, &ep->napi)) {
+		if (netif_rx_schedule_prep(&ep->napi)) {
 			epic_napi_irq_off(dev, ep);
-			__netif_rx_schedule(dev, &ep->napi);
+			__netif_rx_schedule(&ep->napi);
 		} else
 			ep->reschedule_in_poll++;
 		spin_unlock(&ep->napi_lock);
@@ -1290,7 +1290,7 @@ rx_action:
 
 		more = ep->reschedule_in_poll;
 		if (!more) {
-			__netif_rx_complete(dev, napi);
+			__netif_rx_complete(napi);
 			outl(EpicNapiEvent, ioaddr + INTSTAT);
 			epic_napi_irq_on(dev, ep);
 		} else
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index cc7328b..07447e6 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -1760,7 +1760,7 @@ static void nv_do_rx_refill(unsigned long data)
 	struct fe_priv *np = netdev_priv(dev);
 
 	/* Just reschedule NAPI rx processing */
-	netif_rx_schedule(dev, &np->napi);
+	netif_rx_schedule(&np->napi);
 }
 #else
 static void nv_do_rx_refill(unsigned long data)
@@ -3405,7 +3405,7 @@ static irqreturn_t nv_nic_irq(int foo, void *data)
 
 #ifdef CONFIG_FORCEDETH_NAPI
 		if (events & NVREG_IRQ_RX_ALL) {
-			netif_rx_schedule(dev, &np->napi);
+			netif_rx_schedule(&np->napi);
 
 			/* Disable furthur receive irq's */
 			spin_lock(&np->lock);
@@ -3522,7 +3522,7 @@ static irqreturn_t nv_nic_irq_optimized(int foo, void *data)
 
 #ifdef CONFIG_FORCEDETH_NAPI
 		if (events & NVREG_IRQ_RX_ALL) {
-			netif_rx_schedule(dev, &np->napi);
+			netif_rx_schedule(&np->napi);
 
 			/* Disable furthur receive irq's */
 			spin_lock(&np->lock);
@@ -3680,7 +3680,7 @@ static int nv_napi_poll(struct napi_struct *napi, int budget)
 		/* re-enable receive interrupts */
 		spin_lock_irqsave(&np->lock, flags);
 
-		__netif_rx_complete(dev, napi);
+		__netif_rx_complete(napi);
 
 		np->irqmask |= NVREG_IRQ_RX_ALL;
 		if (np->msi_flags & NV_MSI_X_ENABLED)
@@ -3706,7 +3706,7 @@ static irqreturn_t nv_nic_irq_rx(int foo, void *data)
 	writel(NVREG_IRQ_RX_ALL, base + NvRegMSIXIrqStatus);
 
 	if (events) {
-		netif_rx_schedule(dev, &np->napi);
+		netif_rx_schedule(&np->napi);
 		/* disable receive interrupts on the nic */
 		writel(NVREG_IRQ_RX_ALL, base + NvRegIrqMask);
 		pci_push(base);
diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet/fs_enet-main.c
index a6f49d0..36b1840 100644
--- a/drivers/net/fs_enet/fs_enet-main.c
+++ b/drivers/net/fs_enet/fs_enet-main.c
@@ -209,7 +209,7 @@ static int fs_enet_rx_napi(struct napi_struct *napi, int budget)
 
 	if (received < budget) {
 		/* done */
-		netif_rx_complete(dev, napi);
+		netif_rx_complete(napi);
 		(*fep->ops->napi_enable_rx)(dev);
 	}
 	return received;
@@ -478,7 +478,7 @@ fs_enet_interrupt(int irq, void *dev_id)
 				/* NOTE: it is possible for FCCs in NAPI mode    */
 				/* to submit a spurious interrupt while in poll  */
 				if (napi_ok)
-					__netif_rx_schedule(dev, &fep->napi);
+					__netif_rx_schedule(&fep->napi);
 			}
 		}
 
diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index c4af949..ed966ed 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -1561,12 +1561,12 @@ irqreturn_t gfar_receive(int irq, void *dev_id)
 	 * because of the packets that have already arrived */
 	gfar_write(&priv->regs->ievent, IEVENT_RTX_MASK);
 
-	if (netif_rx_schedule_prep(dev, &priv->napi)) {
+	if (netif_rx_schedule_prep(&priv->napi)) {
 		tempval = gfar_read(&priv->regs->imask);
 		tempval &= IMASK_RTX_DISABLED;
 		gfar_write(&priv->regs->imask, tempval);
 
-		__netif_rx_schedule(dev, &priv->napi);
+		__netif_rx_schedule(&priv->napi);
 	} else {
 		if (netif_msg_rx_err(priv))
 			printk(KERN_DEBUG "%s: receive called twice (%x)[%x]\n",
@@ -1737,7 +1737,7 @@ static int gfar_poll(struct napi_struct *napi, int budget)
 	howmany = gfar_clean_rx_ring(dev, budget);
 
 	if (howmany < budget) {
-		netif_rx_complete(dev, napi);
+		netif_rx_complete(napi);
 
 		/* Clear the halt bit in RSTAT */
 		gfar_write(&priv->regs->rstat, RSTAT_CLEAR_RHALT);
diff --git a/drivers/net/ibmveth.c b/drivers/net/ibmveth.c
index c2d57f8..eba1bd5 100644
--- a/drivers/net/ibmveth.c
+++ b/drivers/net/ibmveth.c
@@ -1029,7 +1029,7 @@ static int ibmveth_poll(struct napi_struct *napi, int budget)
 
 		ibmveth_assert(lpar_rc == H_SUCCESS);
 
-		netif_rx_complete(netdev, napi);
+		netif_rx_complete(napi);
 
 		if (ibmveth_rxq_pending_buffer(adapter) &&
 		    netif_rx_reschedule(netdev, napi)) {
@@ -1048,11 +1048,11 @@ static irqreturn_t ibmveth_interrupt(int irq, void *dev_instance)
 	struct ibmveth_adapter *adapter = netdev->priv;
 	unsigned long lpar_rc;
 
-	if (netif_rx_schedule_prep(netdev, &adapter->napi)) {
+	if (netif_rx_schedule_prep(&adapter->napi)) {
 		lpar_rc = h_vio_signal(adapter->vdev->unit_address,
 				       VIO_IRQ_DISABLE);
 		ibmveth_assert(lpar_rc == H_SUCCESS);
-		__netif_rx_schedule(netdev, &adapter->napi);
+		__netif_rx_schedule(&adapter->napi);
 	}
 	return IRQ_HANDLED;
 }
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 20d27e6..829f76e 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -3340,8 +3340,8 @@ static irqreturn_t igb_msix_rx(int irq, void *data)
 
 	igb_write_itr(rx_ring);
 
-	if (netif_rx_schedule_prep(adapter->netdev, &rx_ring->napi))
-		__netif_rx_schedule(adapter->netdev, &rx_ring->napi);
+	if (netif_rx_schedule_prep(&rx_ring->napi))
+		__netif_rx_schedule(&rx_ring->napi);
 
 #ifdef CONFIG_IGB_DCA
 	if (adapter->flags & IGB_FLAG_DCA_ENABLED)
@@ -3493,7 +3493,7 @@ static irqreturn_t igb_intr_msi(int irq, void *data)
 			mod_timer(&adapter->watchdog_timer, jiffies + 1);
 	}
 
-	netif_rx_schedule(netdev, &adapter->rx_ring[0].napi);
+	netif_rx_schedule(&adapter->rx_ring[0].napi);
 
 	return IRQ_HANDLED;
 }
@@ -3531,7 +3531,7 @@ static irqreturn_t igb_intr(int irq, void *data)
 			mod_timer(&adapter->watchdog_timer, jiffies + 1);
 	}
 
-	netif_rx_schedule(netdev, &adapter->rx_ring[0].napi);
+	netif_rx_schedule(&adapter->rx_ring[0].napi);
 
 	return IRQ_HANDLED;
 }
@@ -3566,7 +3566,7 @@ static int igb_poll(struct napi_struct *napi, int budget)
 	    !netif_running(netdev)) {
 		if (adapter->itr_setting & 3)
 			igb_set_itr(adapter);
-		netif_rx_complete(netdev, napi);
+		netif_rx_complete(napi);
 		if (!test_bit(__IGB_DOWN, &adapter->state))
 			igb_irq_enable(adapter);
 		return 0;
@@ -3592,7 +3592,7 @@ static int igb_clean_rx_ring_msix(struct napi_struct *napi, int budget)
 
 	/* If not enough Rx work done, exit the polling mode */
 	if ((work_done == 0) || !netif_running(netdev)) {
-		netif_rx_complete(netdev, napi);
+		netif_rx_complete(napi);
 
 		if (adapter->itr_setting & 3) {
 			if (adapter->num_rx_queues == 1)
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index be3c7dc..7766904 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -1709,14 +1709,14 @@ ixgb_intr(int irq, void *data)
 		if (!test_bit(__IXGB_DOWN, &adapter->flags))
 			mod_timer(&adapter->watchdog_timer, jiffies);
 
-	if (netif_rx_schedule_prep(netdev, &adapter->napi)) {
+	if (netif_rx_schedule_prep(&adapter->napi)) {
 
 		/* Disable interrupts and register for poll. The flush
 		  of the posted write is intentionally left out.
 		*/
 
 		IXGB_WRITE_REG(&adapter->hw, IMC, ~0);
-		__netif_rx_schedule(netdev, &adapter->napi);
+		__netif_rx_schedule(&adapter->napi);
 	}
 	return IRQ_HANDLED;
 }
@@ -1738,7 +1738,7 @@ ixgb_clean(struct napi_struct *napi, int budget)
 
 	/* If budget not fully consumed, exit the polling mode */
 	if (work_done < budget) {
-		netif_rx_complete(netdev, napi);
+		netif_rx_complete(napi);
 		if (!test_bit(__IXGB_DOWN, &adapter->flags))
 			ixgb_irq_enable(adapter);
 	}
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 5236f63..a1af1d3 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -990,7 +990,7 @@ static irqreturn_t ixgbe_msix_clean_rx(int irq, void *data)
 	rx_ring = &(adapter->rx_ring[r_idx]);
 	/* disable interrupts on this vector only */
 	IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMC, rx_ring->v_idx);
-	netif_rx_schedule(adapter->netdev, &q_vector->napi);
+	netif_rx_schedule(&q_vector->napi);
 
 	return IRQ_HANDLED;
 }
@@ -1031,7 +1031,7 @@ static int ixgbe_clean_rxonly(struct napi_struct *napi, int budget)
 
 	/* If all Rx work done, exit the polling mode */
 	if (work_done < budget) {
-		netif_rx_complete(adapter->netdev, napi);
+		netif_rx_complete(napi);
 		if (adapter->itr_setting & 3)
 			ixgbe_set_itr_msix(q_vector);
 		if (!test_bit(__IXGBE_DOWN, &adapter->state))
@@ -1080,7 +1080,7 @@ static int ixgbe_clean_rxonly_many(struct napi_struct *napi, int budget)
 	rx_ring = &(adapter->rx_ring[r_idx]);
 	/* If all Rx work done, exit the polling mode */
 	if (work_done < budget) {
-		netif_rx_complete(adapter->netdev, napi);
+		netif_rx_complete(napi);
 		if (adapter->itr_setting & 3)
 			ixgbe_set_itr_msix(q_vector);
 		if (!test_bit(__IXGBE_DOWN, &adapter->state))
@@ -1342,13 +1342,13 @@ static irqreturn_t ixgbe_intr(int irq, void *data)
 	if (eicr & IXGBE_EICR_LSC)
 		ixgbe_check_lsc(adapter);
 
-	if (netif_rx_schedule_prep(netdev, &adapter->q_vector[0].napi)) {
+	if (netif_rx_schedule_prep(&adapter->q_vector[0].napi)) {
 		adapter->tx_ring[0].total_packets = 0;
 		adapter->tx_ring[0].total_bytes = 0;
 		adapter->rx_ring[0].total_packets = 0;
 		adapter->rx_ring[0].total_bytes = 0;
 		/* would disable interrupts here but EIAM disabled it */
-		__netif_rx_schedule(netdev, &adapter->q_vector[0].napi);
+		__netif_rx_schedule(&adapter->q_vector[0].napi);
 	}
 
 	return IRQ_HANDLED;
@@ -2205,7 +2205,7 @@ static int ixgbe_poll(struct napi_struct *napi, int budget)
 
 	/* If budget not fully consumed, exit the polling mode */
 	if (work_done < budget) {
-		netif_rx_complete(adapter->netdev, napi);
+		netif_rx_complete(napi);
 		if (adapter->itr_setting & 3)
 			ixgbe_set_itr(adapter);
 		if (!test_bit(__IXGBE_DOWN, &adapter->state))
diff --git a/drivers/net/ixp2000/ixpdev.c b/drivers/net/ixp2000/ixpdev.c
index 7b70c66..faade64 100644
--- a/drivers/net/ixp2000/ixpdev.c
+++ b/drivers/net/ixp2000/ixpdev.c
@@ -143,7 +143,7 @@ static int ixpdev_poll(struct napi_struct *napi, int budget)
 			break;
 	} while (ixp2000_reg_read(IXP2000_IRQ_THD_RAW_STATUS_A_0) & 0x00ff);
 
-	netif_rx_complete(dev, napi);
+	netif_rx_complete(napi);
 	ixp2000_reg_write(IXP2000_IRQ_THD_ENABLE_SET_A_0, 0x00ff);
 
 	return rx;
@@ -206,7 +206,7 @@ static irqreturn_t ixpdev_interrupt(int irq, void *dev_id)
 
 		ixp2000_reg_wrb(IXP2000_IRQ_THD_ENABLE_CLEAR_A_0, 0x00ff);
 		if (likely(napi_schedule_prep(&ip->napi))) {
-			__netif_rx_schedule(dev, &ip->napi);
+			__netif_rx_schedule(&ip->napi);
 		} else {
 			printk(KERN_CRIT "ixp2000: irq while polling!!\n");
 		}
diff --git a/drivers/net/jme.c b/drivers/net/jme.c
index 665e70d..4123173 100644
--- a/drivers/net/jme.c
+++ b/drivers/net/jme.c
@@ -1250,7 +1250,6 @@ static int
 jme_poll(JME_NAPI_HOLDER(holder), JME_NAPI_WEIGHT(budget))
 {
 	struct jme_adapter *jme = jme_napi_priv(holder);
-	struct net_device *netdev = jme->dev;
 	int rest;
 
 	rest = jme_process_receive(jme, JME_NAPI_WEIGHT_VAL(budget));
diff --git a/drivers/net/jme.h b/drivers/net/jme.h
index 3f5d915..206a1ff 100644
--- a/drivers/net/jme.h
+++ b/drivers/net/jme.h
@@ -398,15 +398,15 @@ struct jme_ring {
 #define JME_NAPI_WEIGHT(w) int w
 #define JME_NAPI_WEIGHT_VAL(w) w
 #define JME_NAPI_WEIGHT_SET(w, r)
-#define JME_RX_COMPLETE(dev, napis) netif_rx_complete(dev, napis)
+#define JME_RX_COMPLETE(dev, napis) netif_rx_complete(napis)
 #define JME_NAPI_ENABLE(priv) napi_enable(&priv->napi);
 #define JME_NAPI_DISABLE(priv) \
 	if (!napi_disable_pending(&priv->napi)) \
 		napi_disable(&priv->napi);
 #define JME_RX_SCHEDULE_PREP(priv) \
-	netif_rx_schedule_prep(priv->dev, &priv->napi)
+	netif_rx_schedule_prep(&priv->napi)
 #define JME_RX_SCHEDULE(priv) \
-	__netif_rx_schedule(priv->dev, &priv->napi);
+	__netif_rx_schedule(&priv->napi);
 
 /*
  * Jmac Adapter Private data
diff --git a/drivers/net/korina.c b/drivers/net/korina.c
index e185763..de23a67 100644
--- a/drivers/net/korina.c
+++ b/drivers/net/korina.c
@@ -327,7 +327,7 @@ static irqreturn_t korina_rx_dma_interrupt(int irq, void *dev_id)
 
 	dmas = readl(&lp->rx_dma_regs->dmas);
 	if (dmas & (DMA_STAT_DONE | DMA_STAT_HALT | DMA_STAT_ERR)) {
-		netif_rx_schedule_prep(dev, &lp->napi);
+		netif_rx_schedule_prep(&lp->napi);
 
 		dmasm = readl(&lp->rx_dma_regs->dmasm);
 		writel(dmasm | (DMA_STAT_DONE |
@@ -467,7 +467,7 @@ static int korina_poll(struct napi_struct *napi, int budget)
 
 	work_done = korina_rx(dev, budget);
 	if (work_done < budget) {
-		netif_rx_complete(dev, napi);
+		netif_rx_complete(napi);
 
 		writel(readl(&lp->rx_dma_regs->dmasm) &
 			~(DMA_STAT_DONE | DMA_STAT_HALT | DMA_STAT_ERR),
diff --git a/drivers/net/macb.c b/drivers/net/macb.c
index 01f7a31..0b856a4 100644
--- a/drivers/net/macb.c
+++ b/drivers/net/macb.c
@@ -520,7 +520,7 @@ static int macb_poll(struct napi_struct *napi, int budget)
 		 * this function was called last time, and no packets
 		 * have been received since.
 		 */
-		netif_rx_complete(dev, napi);
+		netif_rx_complete(napi);
 		goto out;
 	}
 
@@ -531,13 +531,13 @@ static int macb_poll(struct napi_struct *napi, int budget)
 		dev_warn(&bp->pdev->dev,
 			 "No RX buffers complete, status = %02lx\n",
 			 (unsigned long)status);
-		netif_rx_complete(dev, napi);
+		netif_rx_complete(napi);
 		goto out;
 	}
 
 	work_done = macb_rx(bp, budget);
 	if (work_done < budget)
-		netif_rx_complete(dev, napi);
+		netif_rx_complete(napi);
 
 	/*
 	 * We've done what we can to clean the buffers. Make sure we
@@ -572,7 +572,7 @@ static irqreturn_t macb_interrupt(int irq, void *dev_id)
 		}
 
 		if (status & MACB_RX_INT_FLAGS) {
-			if (netif_rx_schedule_prep(dev, &bp->napi)) {
+			if (netif_rx_schedule_prep(&bp->napi)) {
 				/*
 				 * There's no point taking any more interrupts
 				 * until we have processed the buffers
@@ -580,7 +580,7 @@ static irqreturn_t macb_interrupt(int irq, void *dev_id)
 				macb_writel(bp, IDR, MACB_RX_INT_FLAGS);
 				dev_dbg(&bp->pdev->dev,
 					"scheduling RX softirq\n");
-				__netif_rx_schedule(dev, &bp->napi);
+				__netif_rx_schedule(&bp->napi);
 			}
 		}
 
diff --git a/drivers/net/mlx4/en_rx.c b/drivers/net/mlx4/en_rx.c
index 6232227..6a2a059 100644
--- a/drivers/net/mlx4/en_rx.c
+++ b/drivers/net/mlx4/en_rx.c
@@ -815,7 +815,7 @@ void mlx4_en_rx_irq(struct mlx4_cq *mcq)
 	struct mlx4_en_priv *priv = netdev_priv(cq->dev);
 
 	if (priv->port_up)
-		netif_rx_schedule(cq->dev, &cq->napi);
+		netif_rx_schedule(&cq->napi);
 	else
 		mlx4_en_arm_cq(priv, cq);
 }
@@ -835,7 +835,7 @@ int mlx4_en_poll_rx_cq(struct napi_struct *napi, int budget)
 		INC_PERF_COUNTER(priv->pstats.napi_quota);
 	else {
 		/* Done for now */
-		netif_rx_complete(dev, napi);
+		netif_rx_complete(napi);
 		mlx4_en_arm_cq(priv, cq);
 	}
 	return done;
diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index b378670..3a83550 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -1516,7 +1516,7 @@ static int myri10ge_poll(struct napi_struct *napi, int budget)
 	work_done = myri10ge_clean_rx_done(ss, budget);
 
 	if (work_done < budget) {
-		netif_rx_complete(netdev, napi);
+		netif_rx_complete(napi);
 		put_be32(htonl(3), ss->irq_claim);
 	}
 	return work_done;
@@ -1534,7 +1534,7 @@ static irqreturn_t myri10ge_intr(int irq, void *arg)
 	/* an interrupt on a non-zero receive-only slice is implicitly
 	 * valid  since MSI-X irqs are not shared */
 	if ((mgp->dev->real_num_tx_queues == 1) && (ss != mgp->ss)) {
-		netif_rx_schedule(ss->dev, &ss->napi);
+		netif_rx_schedule(&ss->napi);
 		return (IRQ_HANDLED);
 	}
 
@@ -1545,7 +1545,7 @@ static irqreturn_t myri10ge_intr(int irq, void *arg)
 	/* low bit indicates receives are present, so schedule
 	 * napi poll handler */
 	if (stats->valid & 1)
-		netif_rx_schedule(ss->dev, &ss->napi);
+		netif_rx_schedule(&ss->napi);
 
 	if (!mgp->msi_enabled && !mgp->msix_enabled) {
 		put_be32(0, mgp->irq_deassert);
diff --git a/drivers/net/natsemi.c b/drivers/net/natsemi.c
index f7fa394..ce2f501 100644
--- a/drivers/net/natsemi.c
+++ b/drivers/net/natsemi.c
@@ -2194,10 +2194,10 @@ static irqreturn_t intr_handler(int irq, void *dev_instance)
 
 	prefetch(&np->rx_skbuff[np->cur_rx % RX_RING_SIZE]);
 
-	if (netif_rx_schedule_prep(dev, &np->napi)) {
+	if (netif_rx_schedule_prep(&np->napi)) {
 		/* Disable interrupts and register for poll */
 		natsemi_irq_disable(dev);
-		__netif_rx_schedule(dev, &np->napi);
+		__netif_rx_schedule(&np->napi);
 	} else
 		printk(KERN_WARNING
 	       	       "%s: Ignoring interrupt, status %#08x, mask %#08x.\n",
@@ -2249,7 +2249,7 @@ static int natsemi_poll(struct napi_struct *napi, int budget)
 		np->intr_status = readl(ioaddr + IntrStatus);
 	} while (np->intr_status);
 
-	netif_rx_complete(dev, napi);
+	netif_rx_complete(napi);
 
 	/* Reenable interrupts providing nothing is trying to shut
 	 * the chip down. */
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 6ef3f0d..120db36 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -1572,7 +1572,7 @@ static int netxen_nic_poll(struct napi_struct *napi, int budget)
 	}
 
 	if ((work_done < budget) && tx_complete) {
-		netif_rx_complete(adapter->netdev, &adapter->napi);
+		netif_rx_complete(&adapter->napi);
 		netxen_nic_enable_int(adapter);
 	}
 
diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 1b6f548..717a9d1 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -3616,7 +3616,7 @@ static int niu_poll(struct napi_struct *napi, int budget)
 	work_done = niu_poll_core(np, lp, budget);
 
 	if (work_done < budget) {
-		netif_rx_complete(np->dev, napi);
+		netif_rx_complete(napi);
 		niu_ldg_rearm(np, lp, 1);
 	}
 	return work_done;
@@ -4035,12 +4035,12 @@ static void __niu_fastpath_interrupt(struct niu *np, int ldg, u64 v0)
 static void niu_schedule_napi(struct niu *np, struct niu_ldg *lp,
 			      u64 v0, u64 v1, u64 v2)
 {
-	if (likely(netif_rx_schedule_prep(np->dev, &lp->napi))) {
+	if (likely(netif_rx_schedule_prep(&lp->napi))) {
 		lp->v0 = v0;
 		lp->v1 = v1;
 		lp->v2 = v2;
 		__niu_fastpath_interrupt(np, lp->ldg_num, v0);
-		__netif_rx_schedule(np->dev, &lp->napi);
+		__netif_rx_schedule(&lp->napi);
 	}
 }
 
diff --git a/drivers/net/pasemi_mac.c b/drivers/net/pasemi_mac.c
index edc0fd5..bb825f3 100644
--- a/drivers/net/pasemi_mac.c
+++ b/drivers/net/pasemi_mac.c
@@ -971,7 +971,7 @@ static irqreturn_t pasemi_mac_rx_intr(int irq, void *data)
 	if (*chan->status & PAS_STATUS_ERROR)
 		reg |= PAS_IOB_DMA_RXCH_RESET_DINTC;
 
-	netif_rx_schedule(dev, &mac->napi);
+	netif_rx_schedule(&mac->napi);
 
 	write_iob_reg(PAS_IOB_DMA_RXCH_RESET(chan->chno), reg);
 
@@ -1011,7 +1011,7 @@ static irqreturn_t pasemi_mac_tx_intr(int irq, void *data)
 
 	mod_timer(&txring->clean_timer, jiffies + (TX_CLEAN_INTERVAL)*2);
 
-	netif_rx_schedule(mac->netdev, &mac->napi);
+	netif_rx_schedule(&mac->napi);
 
 	if (reg)
 		write_iob_reg(PAS_IOB_DMA_TXCH_RESET(chan->chno), reg);
@@ -1640,7 +1640,7 @@ static int pasemi_mac_poll(struct napi_struct *napi, int budget)
 	pkts = pasemi_mac_clean_rx(rx_ring(mac), budget);
 	if (pkts < budget) {
 		/* all done, no more packets present */
-		netif_rx_complete(dev, napi);
+		netif_rx_complete(napi);
 
 		pasemi_mac_restart_rx_intr(mac);
 		pasemi_mac_restart_tx_intr(mac);
diff --git a/drivers/net/pcnet32.c b/drivers/net/pcnet32.c
index ca8c0e0..0826454 100644
--- a/drivers/net/pcnet32.c
+++ b/drivers/net/pcnet32.c
@@ -1398,7 +1398,7 @@ static int pcnet32_poll(struct napi_struct *napi, int budget)
 	if (work_done < budget) {
 		spin_lock_irqsave(&lp->lock, flags);
 
-		__netif_rx_complete(dev, napi);
+		__netif_rx_complete(napi);
 
 		/* clear interrupt masks */
 		val = lp->a.read_csr(ioaddr, CSR3);
@@ -2588,14 +2588,14 @@ pcnet32_interrupt(int irq, void *dev_id)
 				       dev->name, csr0);
 			/* unlike for the lance, there is no restart needed */
 		}
-		if (netif_rx_schedule_prep(dev, &lp->napi)) {
+		if (netif_rx_schedule_prep(&lp->napi)) {
 			u16 val;
 			/* set interrupt masks */
 			val = lp->a.read_csr(ioaddr, CSR3);
 			val |= 0x5f00;
 			lp->a.write_csr(ioaddr, CSR3, val);
 			mmiowb();
-			__netif_rx_schedule(dev, &lp->napi);
+			__netif_rx_schedule(&lp->napi);
 			break;
 		}
 		csr0 = lp->a.read_csr(ioaddr, CSR0);
diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index 508452c..b230ea7 100644
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -2295,7 +2295,7 @@ static int ql_poll(struct napi_struct *napi, int budget)
 
 	if (tx_cleaned + rx_cleaned != budget) {
 		spin_lock_irqsave(&qdev->hw_lock, hw_flags);
-		__netif_rx_complete(ndev, napi);
+		__netif_rx_complete(napi);
 		ql_update_small_bufq_prod_index(qdev);
 		ql_update_lrg_bufq_prod_index(qdev);
 		writel(qdev->rsp_consumer_index,
@@ -2354,8 +2354,8 @@ static irqreturn_t ql3xxx_isr(int irq, void *dev_id)
 		spin_unlock(&qdev->adapter_lock);
 	} else if (value & ISP_IMR_DISABLE_CMPL_INT) {
 		ql_disable_interrupts(qdev);
-		if (likely(netif_rx_schedule_prep(ndev, &qdev->napi))) {
-			__netif_rx_schedule(ndev, &qdev->napi);
+		if (likely(netif_rx_schedule_prep(&qdev->napi))) {
+			__netif_rx_schedule(&qdev->napi);
 		}
 	} else {
 		return IRQ_NONE;
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index b83a9c9..a76914c 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -1649,7 +1649,7 @@ static int ql_napi_poll_msix(struct napi_struct *napi, int budget)
 		rx_ring->cq_id);
 
 	if (work_done < budget) {
-		__netif_rx_complete(qdev->ndev, napi);
+		__netif_rx_complete(napi);
 		ql_enable_completion_interrupt(qdev, rx_ring->irq);
 	}
 	return work_done;
@@ -1735,7 +1735,7 @@ static irqreturn_t qlge_msix_rx_isr(int irq, void *dev_id)
 {
 	struct rx_ring *rx_ring = dev_id;
 	struct ql_adapter *qdev = rx_ring->qdev;
-	netif_rx_schedule(qdev->ndev, &rx_ring->napi);
+	netif_rx_schedule(&rx_ring->napi);
 	return IRQ_HANDLED;
 }
 
@@ -1821,8 +1821,7 @@ static irqreturn_t qlge_isr(int irq, void *dev_id)
 							      &rx_ring->rx_work,
 							      0);
 				else
-					netif_rx_schedule(qdev->ndev,
-							  &rx_ring->napi);
+					netif_rx_schedule(&rx_ring->napi);
 				work_done++;
 			}
 		}
diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index 34fe7ef..1bc7236 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -668,7 +668,7 @@ static int r6040_poll(struct napi_struct *napi, int budget)
 	work_done = r6040_rx(dev, budget);
 
 	if (work_done < budget) {
-		netif_rx_complete(dev, napi);
+		netif_rx_complete(napi);
 		/* Enable RX interrupt */
 		iowrite16(ioread16(ioaddr + MIER) | RX_INTS, ioaddr + MIER);
 	}
@@ -703,7 +703,7 @@ static irqreturn_t r6040_interrupt(int irq, void *dev_id)
 
 		/* Mask off RX interrupt */
 		iowrite16(ioread16(ioaddr + MIER) & ~RX_INTS, ioaddr + MIER);
-		netif_rx_schedule(dev, &lp->napi);
+		netif_rx_schedule(&lp->napi);
 	}
 
 	/* TX interrupt request */
diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 4b7cb38..cbe5be8 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -3566,8 +3566,8 @@ static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance)
 		RTL_W16(IntrMask, tp->intr_event & ~tp->napi_event);
 		tp->intr_mask = ~tp->napi_event;
 
-		if (likely(netif_rx_schedule_prep(dev, &tp->napi)))
-			__netif_rx_schedule(dev, &tp->napi);
+		if (likely(netif_rx_schedule_prep(&tp->napi)))
+			__netif_rx_schedule(&tp->napi);
 		else if (netif_msg_intr(tp)) {
 			printk(KERN_INFO "%s: interrupt %04x in poll\n",
 			       dev->name, status);
@@ -3588,7 +3588,7 @@ static int rtl8169_poll(struct napi_struct *napi, int budget)
 	rtl8169_tx_interrupt(dev, tp, ioaddr);
 
 	if (work_done < budget) {
-		netif_rx_complete(dev, napi);
+		netif_rx_complete(napi);
 		tp->intr_mask = 0xffff;
 		/*
 		 * 20040426: the barrier is not strictly required but the
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 6a1375f..bbc8d9f 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -2851,7 +2851,7 @@ static int s2io_poll_msix(struct napi_struct *napi, int budget)
 	s2io_chk_rx_buffers(nic, ring);
 
 	if (pkts_processed < budget_org) {
-		netif_rx_complete(dev, napi);
+		netif_rx_complete(napi);
 		/*Re Enable MSI-Rx Vector*/
 		addr = (u8 __iomem *)&bar0->xmsi_mask_reg;
 		addr += 7 - ring->ring_no;
@@ -2889,7 +2889,7 @@ static int s2io_poll_inta(struct napi_struct *napi, int budget)
 			break;
 	}
 	if (pkts_processed < budget_org) {
-		netif_rx_complete(dev, napi);
+		netif_rx_complete(napi);
 		/* Re enable the Rx interrupts for the ring */
 		writeq(0, &bar0->rx_traffic_mask);
 		readl(&bar0->rx_traffic_mask);
@@ -4343,7 +4343,7 @@ static irqreturn_t s2io_msix_ring_handle(int irq, void *dev_id)
 		val8 = (ring->ring_no == 0) ? 0x7f : 0xff;
 		writeb(val8, addr);
 		val8 = readb(addr);
-		netif_rx_schedule(dev, &ring->napi);
+		netif_rx_schedule(&ring->napi);
 	} else {
 		rx_intr_handler(ring, 0);
 		s2io_chk_rx_buffers(sp, ring);
@@ -4790,7 +4790,7 @@ static irqreturn_t s2io_isr(int irq, void *dev_id)
 
 		if (config->napi) {
 			if (reason & GEN_INTR_RXTRAFFIC) {
-				netif_rx_schedule(dev, &sp->napi);
+				netif_rx_schedule(&sp->napi);
 				writeq(S2IO_MINUS_ONE, &bar0->rx_traffic_mask);
 				writeq(S2IO_MINUS_ONE, &bar0->rx_traffic_int);
 				readl(&bar0->rx_traffic_int);
diff --git a/drivers/net/sb1250-mac.c b/drivers/net/sb1250-mac.c
index 2615d46..ecbe89a 100644
--- a/drivers/net/sb1250-mac.c
+++ b/drivers/net/sb1250-mac.c
@@ -2039,9 +2039,9 @@ static irqreturn_t sbmac_intr(int irq,void *dev_instance)
 		sbdma_tx_process(sc,&(sc->sbm_txdma), 0);
 
 	if (isr & (M_MAC_INT_CHANNEL << S_MAC_RX_CH0)) {
-		if (netif_rx_schedule_prep(dev, &sc->napi)) {
+		if (netif_rx_schedule_prep(&sc->napi)) {
 			__raw_writeq(0, sc->sbm_imr);
-			__netif_rx_schedule(dev, &sc->napi);
+			__netif_rx_schedule(&sc->napi);
 			/* Depend on the exit from poll to reenable intr */
 		}
 		else {
@@ -2668,7 +2668,7 @@ static int sbmac_poll(struct napi_struct *napi, int budget)
 	sbdma_tx_process(sc, &(sc->sbm_txdma), 1);
 
 	if (work_done < budget) {
-		netif_rx_complete(dev, napi);
+		netif_rx_complete(napi);
 
 #ifdef CONFIG_SBMAC_COALESCE
 		__raw_writeq(((M_MAC_INT_EOP_COUNT | M_MAC_INT_EOP_TIMER) << S_MAC_TX_CH0) |
diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 06ea71c..3c83dfb 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -221,11 +221,11 @@ static int efx_poll(struct napi_struct *napi, int budget)
 
 	if (rx_packets < budget) {
 		/* There is no race here; although napi_disable() will
-		 * only wait for netif_rx_complete(), this isn't a problem
+		 * only wait for netif_rx_complete(this isn't a problem
 		 * since efx_channel_processed() will have no effect if
 		 * interrupts have already been disabled.
 		 */
-		netif_rx_complete(napi_dev, napi);
+		netif_rx_complete(napi);
 		efx_channel_processed(channel);
 	}
 
diff --git a/drivers/net/sfc/efx.h b/drivers/net/sfc/efx.h
index d02937b..518760f 100644
--- a/drivers/net/sfc/efx.h
+++ b/drivers/net/sfc/efx.h
@@ -67,7 +67,7 @@ static inline void efx_schedule_channel(struct efx_channel *channel)
 		  channel->channel, raw_smp_processor_id());
 	channel->work_pending = true;
 
-	netif_rx_schedule(channel->napi_dev, &channel->napi_str);
+	netif_rx_schedule(&channel->napi_str);
 }
 
 #endif /* EFX_EFX_H */
diff --git a/drivers/net/skge.c b/drivers/net/skge.c
index 43f4c73..10efb91 100644
--- a/drivers/net/skge.c
+++ b/drivers/net/skge.c
@@ -3216,7 +3216,7 @@ static int skge_poll(struct napi_struct *napi, int to_do)
 		unsigned long flags;
 
 		spin_lock_irqsave(&hw->hw_lock, flags);
-		__netif_rx_complete(dev, napi);
+		__netif_rx_complete(napi);
 		hw->intr_mask |= napimask[skge->port];
 		skge_write32(hw, B0_IMSK, hw->intr_mask);
 		skge_read32(hw, B0_IMSK);
@@ -3379,7 +3379,7 @@ static irqreturn_t skge_intr(int irq, void *dev_id)
 	if (status & (IS_XA1_F|IS_R1_F)) {
 		struct skge_port *skge = netdev_priv(hw->dev[0]);
 		hw->intr_mask &= ~(IS_XA1_F|IS_R1_F);
-		netif_rx_schedule(hw->dev[0], &skge->napi);
+		netif_rx_schedule(&skge->napi);
 	}
 
 	if (status & IS_PA_TO_TX1)
@@ -3399,7 +3399,7 @@ static irqreturn_t skge_intr(int irq, void *dev_id)
 
 		if (status & (IS_XA2_F|IS_R2_F)) {
 			hw->intr_mask &= ~(IS_XA2_F|IS_R2_F);
-			netif_rx_schedule(hw->dev[1], &skge->napi);
+			netif_rx_schedule(&skge->napi);
 		}
 
 		if (status & IS_PA_TO_RX2) {
diff --git a/drivers/net/spider_net.c b/drivers/net/spider_net.c
index 07599b4..0f39c6e 100644
--- a/drivers/net/spider_net.c
+++ b/drivers/net/spider_net.c
@@ -1302,7 +1302,7 @@ static int spider_net_poll(struct napi_struct *napi, int budget)
 	/* if all packets are in the stack, enable interrupts and return 0 */
 	/* if not, return 1 */
 	if (packets_done < budget) {
-		netif_rx_complete(netdev, napi);
+		netif_rx_complete(napi);
 		spider_net_rx_irq_on(card);
 		card->ignore_rx_ramfull = 0;
 	}
@@ -1529,8 +1529,7 @@ spider_net_handle_error_irq(struct spider_net_card *card, u32 status_reg,
 			spider_net_refill_rx_chain(card);
 			spider_net_enable_rxdmac(card);
 			card->num_rx_ints ++;
-			netif_rx_schedule(card->netdev,
-					  &card->napi);
+			netif_rx_schedule(&card->napi);
 		}
 		show_error = 0;
 		break;
@@ -1550,8 +1549,7 @@ spider_net_handle_error_irq(struct spider_net_card *card, u32 status_reg,
 		spider_net_refill_rx_chain(card);
 		spider_net_enable_rxdmac(card);
 		card->num_rx_ints ++;
-		netif_rx_schedule(card->netdev,
-				  &card->napi);
+		netif_rx_schedule(&card->napi);
 		show_error = 0;
 		break;
 
@@ -1565,8 +1563,7 @@ spider_net_handle_error_irq(struct spider_net_card *card, u32 status_reg,
 		spider_net_refill_rx_chain(card);
 		spider_net_enable_rxdmac(card);
 		card->num_rx_ints ++;
-		netif_rx_schedule(card->netdev,
-				  &card->napi);
+		netif_rx_schedule(&card->napi);
 		show_error = 0;
 		break;
 
@@ -1660,11 +1657,11 @@ spider_net_interrupt(int irq, void *ptr)
 
 	if (status_reg & SPIDER_NET_RXINT ) {
 		spider_net_rx_irq_off(card);
-		netif_rx_schedule(netdev, &card->napi);
+		netif_rx_schedule(&card->napi);
 		card->num_rx_ints ++;
 	}
 	if (status_reg & SPIDER_NET_TXINT)
-		netif_rx_schedule(netdev, &card->napi);
+		netif_rx_schedule(&card->napi);
 
 	if (status_reg & SPIDER_NET_LINKINT)
 		spider_net_link_reset(netdev);
diff --git a/drivers/net/starfire.c b/drivers/net/starfire.c
index 5a40f2d..715ae2d 100644
--- a/drivers/net/starfire.c
+++ b/drivers/net/starfire.c
@@ -1291,8 +1291,8 @@ static irqreturn_t intr_handler(int irq, void *dev_instance)
 		if (intr_status & (IntrRxDone | IntrRxEmpty)) {
 			u32 enable;
 
-			if (likely(netif_rx_schedule_prep(dev, &np->napi))) {
-				__netif_rx_schedule(dev, &np->napi);
+			if (likely(netif_rx_schedule_prep(&np->napi))) {
+				__netif_rx_schedule(&np->napi);
 				enable = readl(ioaddr + IntrEnable);
 				enable &= ~(IntrRxDone | IntrRxEmpty);
 				writel(enable, ioaddr + IntrEnable);
@@ -1541,7 +1541,7 @@ static int netdev_poll(struct napi_struct *napi, int budget)
 		intr_status = readl(ioaddr + IntrStatus);
 	} while (intr_status & (IntrRxDone | IntrRxEmpty));
 
-	netif_rx_complete(dev, napi);
+	netif_rx_complete(napi);
 	intr_status = readl(ioaddr + IntrEnable);
 	intr_status |= IntrRxDone | IntrRxEmpty;
 	writel(intr_status, ioaddr + IntrEnable);
diff --git a/drivers/net/sungem.c b/drivers/net/sungem.c
index fed7eba..f093e75 100644
--- a/drivers/net/sungem.c
+++ b/drivers/net/sungem.c
@@ -922,7 +922,7 @@ static int gem_poll(struct napi_struct *napi, int budget)
 		gp->status = readl(gp->regs + GREG_STAT);
 	} while (gp->status & GREG_STAT_NAPI);
 
-	__netif_rx_complete(dev, napi);
+	__netif_rx_complete(napi);
 	gem_enable_ints(gp);
 
 	spin_unlock_irqrestore(&gp->lock, flags);
@@ -945,7 +945,7 @@ static irqreturn_t gem_interrupt(int irq, void *dev_id)
 
 	spin_lock_irqsave(&gp->lock, flags);
 
-	if (netif_rx_schedule_prep(dev, &gp->napi)) {
+	if (netif_rx_schedule_prep(&gp->napi)) {
 		u32 gem_status = readl(gp->regs + GREG_STAT);
 
 		if (gem_status == 0) {
@@ -955,7 +955,7 @@ static irqreturn_t gem_interrupt(int irq, void *dev_id)
 		}
 		gp->status = gem_status;
 		gem_disable_ints(gp);
-		__netif_rx_schedule(dev, &gp->napi);
+		__netif_rx_schedule(&gp->napi);
 	}
 
 	spin_unlock_irqrestore(&gp->lock, flags);
diff --git a/drivers/net/tc35815.c b/drivers/net/tc35815.c
index df20caf..4654683 100644
--- a/drivers/net/tc35815.c
+++ b/drivers/net/tc35815.c
@@ -1609,8 +1609,8 @@ static irqreturn_t tc35815_interrupt(int irq, void *dev_id)
 	if (!(dmactl & DMA_IntMask)) {
 		/* disable interrupts */
 		tc_writel(dmactl | DMA_IntMask, &tr->DMA_Ctl);
-		if (netif_rx_schedule_prep(dev, &lp->napi))
-			__netif_rx_schedule(dev, &lp->napi);
+		if (netif_rx_schedule_prep(&lp->napi))
+			__netif_rx_schedule(&lp->napi);
 		else {
 			printk(KERN_ERR "%s: interrupt taken in poll\n",
 			       dev->name);
@@ -1919,7 +1919,7 @@ static int tc35815_poll(struct napi_struct *napi, int budget)
 	spin_unlock(&lp->lock);
 
 	if (received < budget) {
-		netif_rx_complete(dev, napi);
+		netif_rx_complete(napi);
 		/* enable interrupts */
 		tc_writel(tc_readl(&tr->DMA_Ctl) & ~DMA_IntMask, &tr->DMA_Ctl);
 	}
diff --git a/drivers/net/tehuti.c b/drivers/net/tehuti.c
index 91f9054..84f0a62 100644
--- a/drivers/net/tehuti.c
+++ b/drivers/net/tehuti.c
@@ -265,8 +265,8 @@ static irqreturn_t bdx_isr_napi(int irq, void *dev)
 		bdx_isr_extra(priv, isr);
 
 	if (isr & (IR_RX_DESC_0 | IR_TX_FREE_0)) {
-		if (likely(netif_rx_schedule_prep(ndev, &priv->napi))) {
-			__netif_rx_schedule(ndev, &priv->napi);
+		if (likely(netif_rx_schedule_prep(&priv->napi))) {
+			__netif_rx_schedule(&priv->napi);
 			RET(IRQ_HANDLED);
 		} else {
 			/* NOTE: we get here if intr has slipped into window
@@ -289,7 +289,6 @@ static irqreturn_t bdx_isr_napi(int irq, void *dev)
 static int bdx_poll(struct napi_struct *napi, int budget)
 {
 	struct bdx_priv *priv = container_of(napi, struct bdx_priv, napi);
-	struct net_device *dev = priv->ndev;
 	int work_done;
 
 	ENTER;
@@ -303,7 +302,7 @@ static int bdx_poll(struct napi_struct *napi, int budget)
 		 * device lock and allow waiting tasks (eg rmmod) to advance) */
 		priv->napi_stop = 0;
 
-		netif_rx_complete(dev, napi);
+		netif_rx_complete(napi);
 		bdx_enable_interrupts(priv);
 	}
 	return work_done;
diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index eb9f8f3..9d7310a 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -4271,7 +4271,7 @@ static int tg3_poll(struct napi_struct *napi, int budget)
 			sblk->status &= ~SD_STATUS_UPDATED;
 
 		if (likely(!tg3_has_work(tp))) {
-			netif_rx_complete(tp->dev, napi);
+			netif_rx_complete(napi);
 			tg3_restart_ints(tp);
 			break;
 		}
@@ -4281,7 +4281,7 @@ static int tg3_poll(struct napi_struct *napi, int budget)
 
 tx_recovery:
 	/* work_done is guaranteed to be less than budget. */
-	netif_rx_complete(tp->dev, napi);
+	netif_rx_complete(napi);
 	schedule_work(&tp->reset_task);
 	return work_done;
 }
@@ -4330,7 +4330,7 @@ static irqreturn_t tg3_msi_1shot(int irq, void *dev_id)
 	prefetch(&tp->rx_rcb[tp->rx_rcb_ptr]);
 
 	if (likely(!tg3_irq_sync(tp)))
-		netif_rx_schedule(dev, &tp->napi);
+		netif_rx_schedule(&tp->napi);
 
 	return IRQ_HANDLED;
 }
@@ -4355,7 +4355,7 @@ static irqreturn_t tg3_msi(int irq, void *dev_id)
 	 */
 	tw32_mailbox(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW, 0x00000001);
 	if (likely(!tg3_irq_sync(tp)))
-		netif_rx_schedule(dev, &tp->napi);
+		netif_rx_schedule(&tp->napi);
 
 	return IRQ_RETVAL(1);
 }
@@ -4397,7 +4397,7 @@ static irqreturn_t tg3_interrupt(int irq, void *dev_id)
 	sblk->status &= ~SD_STATUS_UPDATED;
 	if (likely(tg3_has_work(tp))) {
 		prefetch(&tp->rx_rcb[tp->rx_rcb_ptr]);
-		netif_rx_schedule(dev, &tp->napi);
+		netif_rx_schedule(&tp->napi);
 	} else {
 		/* No work, shared interrupt perhaps?  re-enable
 		 * interrupts, and flush that PCI write
@@ -4443,7 +4443,7 @@ static irqreturn_t tg3_interrupt_tagged(int irq, void *dev_id)
 	tw32_mailbox_f(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW, 0x00000001);
 	if (tg3_irq_sync(tp))
 		goto out;
-	if (netif_rx_schedule_prep(dev, &tp->napi)) {
+	if (netif_rx_schedule_prep(&tp->napi)) {
 		prefetch(&tp->rx_rcb[tp->rx_rcb_ptr]);
 		/* Update last_tag to mark that this status has been
 		 * seen. Because interrupt may be shared, we may be
@@ -4451,7 +4451,7 @@ static irqreturn_t tg3_interrupt_tagged(int irq, void *dev_id)
 		 * if tg3_poll() is not scheduled.
 		 */
 		tp->last_tag = sblk->status_tag;
-		__netif_rx_schedule(dev, &tp->napi);
+		__netif_rx_schedule(&tp->napi);
 	}
 out:
 	return IRQ_RETVAL(handled);
diff --git a/drivers/net/tsi108_eth.c b/drivers/net/tsi108_eth.c
index eb1da6f..0d6ad86 100644
--- a/drivers/net/tsi108_eth.c
+++ b/drivers/net/tsi108_eth.c
@@ -889,7 +889,7 @@ static int tsi108_poll(struct napi_struct *napi, int budget)
 
 	if (num_received < budget) {
 		data->rxpending = 0;
-		netif_rx_complete(dev, napi);
+		netif_rx_complete(napi);
 
 		TSI_WRITE(TSI108_EC_INTMASK,
 				     TSI_READ(TSI108_EC_INTMASK)
@@ -920,7 +920,7 @@ static void tsi108_rx_int(struct net_device *dev)
 	 * from tsi108_check_rxring().
 	 */
 
-	if (netif_rx_schedule_prep(dev, &data->napi)) {
+	if (netif_rx_schedule_prep(&data->napi)) {
 		/* Mask, rather than ack, the receive interrupts.  The ack
 		 * will happen in tsi108_poll().
 		 */
@@ -931,7 +931,7 @@ static void tsi108_rx_int(struct net_device *dev)
 				     | TSI108_INT_RXTHRESH |
 				     TSI108_INT_RXOVERRUN | TSI108_INT_RXERROR |
 				     TSI108_INT_RXWAIT);
-		__netif_rx_schedule(dev, &data->napi);
+		__netif_rx_schedule(&data->napi);
 	} else {
 		if (!netif_running(dev)) {
 			/* This can happen if an interrupt occurs while the
diff --git a/drivers/net/tulip/interrupt.c b/drivers/net/tulip/interrupt.c
index c6bad98..1d7c2aa 100644
--- a/drivers/net/tulip/interrupt.c
+++ b/drivers/net/tulip/interrupt.c
@@ -103,7 +103,7 @@ void oom_timer(unsigned long data)
 {
         struct net_device *dev = (struct net_device *)data;
 	struct tulip_private *tp = netdev_priv(dev);
-	netif_rx_schedule(dev, &tp->napi);
+	netif_rx_schedule(&tp->napi);
 }
 
 int tulip_poll(struct napi_struct *napi, int budget)
@@ -301,7 +301,7 @@ int tulip_poll(struct napi_struct *napi, int budget)
 
          /* Remove us from polling list and enable RX intr. */
 
-         netif_rx_complete(dev, napi);
+         netif_rx_complete(napi);
          iowrite32(tulip_tbl[tp->chip_id].valid_intrs, tp->base_addr+CSR7);
 
          /* The last op happens after poll completion. Which means the following:
@@ -337,7 +337,7 @@ int tulip_poll(struct napi_struct *napi, int budget)
           * before we did netif_rx_complete(). See? We would lose it. */
 
          /* remove ourselves from the polling list */
-         netif_rx_complete(dev, napi);
+         netif_rx_complete(napi);
 
          return work_done;
 }
@@ -521,7 +521,7 @@ irqreturn_t tulip_interrupt(int irq, void *dev_instance)
 			rxd++;
 			/* Mask RX intrs and add the device to poll list. */
 			iowrite32(tulip_tbl[tp->chip_id].valid_intrs&~RxPollInt, ioaddr + CSR7);
-			netif_rx_schedule(dev, &tp->napi);
+			netif_rx_schedule(&tp->napi);
 
 			if (!(csr5&~(AbnormalIntr|NormalIntr|RxPollInt|TPLnkPass)))
                                break;
diff --git a/drivers/net/typhoon.c b/drivers/net/typhoon.c
index 734ce09..b0adf46 100644
--- a/drivers/net/typhoon.c
+++ b/drivers/net/typhoon.c
@@ -1756,7 +1756,6 @@ static int
 typhoon_poll(struct napi_struct *napi, int budget)
 {
 	struct typhoon *tp = container_of(napi, struct typhoon, napi);
-	struct net_device *dev = tp->dev;
 	struct typhoon_indexes *indexes = tp->indexes;
 	int work_done;
 
@@ -1785,7 +1784,7 @@ typhoon_poll(struct napi_struct *napi, int budget)
 	}
 
 	if (work_done < budget) {
-		netif_rx_complete(dev, napi);
+		netif_rx_complete(napi);
 		iowrite32(TYPHOON_INTR_NONE,
 				tp->ioaddr + TYPHOON_REG_INTR_MASK);
 		typhoon_post_pci_writes(tp->ioaddr);
@@ -1808,10 +1807,10 @@ typhoon_interrupt(int irq, void *dev_instance)
 
 	iowrite32(intr_status, ioaddr + TYPHOON_REG_INTR_STATUS);
 
-	if (netif_rx_schedule_prep(dev, &tp->napi)) {
+	if (netif_rx_schedule_prep(&tp->napi)) {
 		iowrite32(TYPHOON_INTR_ALL, ioaddr + TYPHOON_REG_INTR_MASK);
 		typhoon_post_pci_writes(ioaddr);
-		__netif_rx_schedule(dev, &tp->napi);
+		__netif_rx_schedule(&tp->napi);
 	} else {
 		printk(KERN_ERR "%s: Error, poll already scheduled\n",
                        dev->name);
diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index c87747b..b560ebe 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -3592,7 +3592,7 @@ static int ucc_geth_poll(struct napi_struct *napi, int budget)
 		struct ucc_fast_private *uccf;
 		u32 uccm;
 
-		netif_rx_complete(dev, napi);
+		netif_rx_complete(napi);
 		uccf = ugeth->uccf;
 		uccm = in_be32(uccf->p_uccm);
 		uccm |= UCCE_RX_EVENTS;
@@ -3626,10 +3626,10 @@ static irqreturn_t ucc_geth_irq_handler(int irq, void *info)
 
 	/* check for receive events that require processing */
 	if (ucce & UCCE_RX_EVENTS) {
-		if (netif_rx_schedule_prep(dev, &ugeth->napi)) {
+		if (netif_rx_schedule_prep(&ugeth->napi)) {
 			uccm &= ~UCCE_RX_EVENTS;
 			out_be32(uccf->p_uccm, uccm);
-			__netif_rx_schedule(dev, &ugeth->napi);
+			__netif_rx_schedule(&ugeth->napi);
 		}
 	}
 
diff --git a/drivers/net/via-rhine.c b/drivers/net/via-rhine.c
index 5b78700..28292eb 100644
--- a/drivers/net/via-rhine.c
+++ b/drivers/net/via-rhine.c
@@ -588,7 +588,7 @@ static int rhine_napipoll(struct napi_struct *napi, int budget)
 	work_done = rhine_rx(dev, budget);
 
 	if (work_done < budget) {
-		netif_rx_complete(dev, napi);
+		netif_rx_complete(napi);
 
 		iowrite16(IntrRxDone | IntrRxErr | IntrRxEmpty| IntrRxOverflow |
 			  IntrRxDropped | IntrRxNoBuf | IntrTxAborted |
@@ -1312,7 +1312,7 @@ static irqreturn_t rhine_interrupt(int irq, void *dev_instance)
 				  IntrPCIErr | IntrStatsMax | IntrLinkChange,
 				  ioaddr + IntrEnable);
 
-			netif_rx_schedule(dev, &rp->napi);
+			netif_rx_schedule(&rp->napi);
 		}
 
 		if (intr_status & (IntrTxErrSummary | IntrTxDone)) {
diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 0196a0d..f21d046 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -246,9 +246,9 @@ static void skb_recv_done(struct virtqueue *rvq)
 {
 	struct virtnet_info *vi = rvq->vdev->priv;
 	/* Schedule NAPI, Suppress further interrupts if successful. */
-	if (netif_rx_schedule_prep(vi->dev, &vi->napi)) {
+	if (netif_rx_schedule_prep(&vi->napi)) {
 		rvq->vq_ops->disable_cb(rvq);
-		__netif_rx_schedule(vi->dev, &vi->napi);
+		__netif_rx_schedule(&vi->napi);
 	}
 }
 
@@ -274,11 +274,11 @@ again:
 
 	/* Out of packets? */
 	if (received < budget) {
-		netif_rx_complete(vi->dev, napi);
+		netif_rx_complete(napi);
 		if (unlikely(!vi->rvq->vq_ops->enable_cb(vi->rvq))
 		    && napi_schedule_prep(napi)) {
 			vi->rvq->vq_ops->disable_cb(vi->rvq);
-			__netif_rx_schedule(vi->dev, napi);
+			__netif_rx_schedule(napi);
 			goto again;
 		}
 	}
@@ -448,9 +448,9 @@ static int virtnet_open(struct net_device *dev)
 	 * won't get another interrupt, so process any outstanding packets
 	 * now.  virtnet_poll wants re-enable the queue, so we disable here.
 	 * We synchronize against interrupts via NAPI_STATE_SCHED */
-	if (netif_rx_schedule_prep(dev, &vi->napi)) {
+	if (netif_rx_schedule_prep(&vi->napi)) {
 		vi->rvq->vq_ops->disable_cb(vi->rvq);
-		__netif_rx_schedule(dev, &vi->napi);
+		__netif_rx_schedule(&vi->napi);
 	}
 	return 0;
 }
diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 6d017ad..504f992 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -196,7 +196,7 @@ static void rx_refill_timeout(unsigned long data)
 {
 	struct net_device *dev = (struct net_device *)data;
 	struct netfront_info *np = netdev_priv(dev);
-	netif_rx_schedule(dev, &np->napi);
+	netif_rx_schedule(&np->napi);
 }
 
 static int netfront_tx_slot_available(struct netfront_info *np)
@@ -328,7 +328,7 @@ static int xennet_open(struct net_device *dev)
 		xennet_alloc_rx_buffers(dev);
 		np->rx.sring->rsp_event = np->rx.rsp_cons + 1;
 		if (RING_HAS_UNCONSUMED_RESPONSES(&np->rx))
-			netif_rx_schedule(dev, &np->napi);
+			netif_rx_schedule(&np->napi);
 	}
 	spin_unlock_bh(&np->rx_lock);
 
@@ -980,7 +980,7 @@ err:
 
 		RING_FINAL_CHECK_FOR_RESPONSES(&np->rx, more_to_do);
 		if (!more_to_do)
-			__netif_rx_complete(dev, napi);
+			__netif_rx_complete(napi);
 
 		local_irq_restore(flags);
 	}
@@ -1311,7 +1311,7 @@ static irqreturn_t xennet_interrupt(int irq, void *dev_id)
 		xennet_tx_buf_gc(dev);
 		/* Under tx_lock: protects access to rx shared-ring indexes. */
 		if (RING_HAS_UNCONSUMED_RESPONSES(&np->rx))
-			netif_rx_schedule(dev, &np->napi);
+			netif_rx_schedule(&np->napi);
 	}
 
 	spin_unlock_irqrestore(&np->tx_lock, flags);
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index e26f549..d2f692d 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1444,8 +1444,7 @@ static inline u32 netif_msg_init(int debug_value, int default_msg_enable_bits)
 }
 
 /* Test if receive needs to be scheduled but only if up */
-static inline int netif_rx_schedule_prep(struct net_device *dev,
-					 struct napi_struct *napi)
+static inline int netif_rx_schedule_prep(struct napi_struct *napi)
 {
 	return napi_schedule_prep(napi);
 }
@@ -1453,27 +1452,24 @@ static inline int netif_rx_schedule_prep(struct net_device *dev,
 /* Add interface to tail of rx poll list. This assumes that _prep has
  * already been called and returned 1.
  */
-static inline void __netif_rx_schedule(struct net_device *dev,
-				       struct napi_struct *napi)
+static inline void __netif_rx_schedule(struct napi_struct *napi)
 {
 	__napi_schedule(napi);
 }
 
 /* Try to reschedule poll. Called by irq handler. */
 
-static inline void netif_rx_schedule(struct net_device *dev,
-				     struct napi_struct *napi)
+static inline void netif_rx_schedule(struct napi_struct *napi)
 {
-	if (netif_rx_schedule_prep(dev, napi))
-		__netif_rx_schedule(dev, napi);
+	if (netif_rx_schedule_prep(napi))
+		__netif_rx_schedule(napi);
 }
 
 /* Try to reschedule poll. Called by dev->poll() after netif_rx_complete().  */
-static inline int netif_rx_reschedule(struct net_device *dev,
-				      struct napi_struct *napi)
+static inline int netif_rx_reschedule(struct napi_struct *napi)
 {
 	if (napi_schedule_prep(napi)) {
-		__netif_rx_schedule(dev, napi);
+		__netif_rx_schedule(napi);
 		return 1;
 	}
 	return 0;
@@ -1482,8 +1478,7 @@ static inline int netif_rx_reschedule(struct net_device *dev,
 /* same as netif_rx_complete, except that local_irq_save(flags)
  * has already been issued
  */
-static inline void __netif_rx_complete(struct net_device *dev,
-				       struct napi_struct *napi)
+static inline void __netif_rx_complete(struct napi_struct *napi)
 {
 	__napi_complete(napi);
 }
@@ -1493,8 +1488,7 @@ static inline void __netif_rx_complete(struct net_device *dev,
  * it completes the work. The device cannot be out of poll list at this
  * moment, it is BUG().
  */
-static inline void netif_rx_complete(struct net_device *dev,
-				     struct napi_struct *napi)
+static inline void netif_rx_complete(struct napi_struct *napi)
 {
 	unsigned long flags;
 
@@ -1505,7 +1499,7 @@ static inline void netif_rx_complete(struct net_device *dev,
 	if (unlikely(test_bit(NAPI_STATE_NPSVC, &napi->state)))
 		return;
 	local_irq_save(flags);
-	__netif_rx_complete(dev, napi);
+	__netif_rx_complete(napi);
 	local_irq_restore(flags);
 }
 
-- 
/****************************************************
 * Neil Horman <nhorman@tuxdriver.com>
 * Software Engineer, Red Hat
 ****************************************************/
