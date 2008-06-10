From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver fixes
Date: Tue, 10 Jun 2008 19:19:22 -0400
Message-ID: <20080610231922.GA17011@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:36167 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753429AbYFJXTY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jun 2008 19:19:24 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is for 2.6.26.  The 2.6.27 stuff, including the 8390 fix for
net-next, is coming late tonight.

Please pull from 'davem-fixes' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git davem-fixes

to receive the following updates:

 drivers/net/7990.c                |    6 ++-
 drivers/net/atlx/atl1.c           |   17 --------
 drivers/net/ehea/ehea_main.c      |   16 +++++---
 drivers/net/forcedeth.c           |   20 ++++++++++
 drivers/net/ixgbe/ixgbe_82598.c   |    4 +-
 drivers/net/s2io.c                |   10 +++--
 drivers/net/sfc/falcon.c          |    4 +-
 drivers/net/sky2.c                |    2 +
 drivers/net/virtio_net.c          |   52 ++++++++++++++++++++++---
 drivers/s390/net/qeth_core_main.c |   49 +++++++-----------------
 drivers/s390/net/qeth_core_offl.c |    6 +--
 drivers/s390/net/qeth_core_sys.c  |   12 ------
 drivers/s390/net/qeth_l2_main.c   |   41 ++++++++------------
 drivers/s390/net/qeth_l3_main.c   |   75 ++++++++++++-------------------------
 drivers/s390/net/qeth_l3_sys.c    |   24 ------------
 include/linux/virtio_net.h        |    2 +-
 16 files changed, 151 insertions(+), 189 deletions(-)

Adrian Bunk (1):
      add missing lance_* exports

Al Viro (1):
      s2io iomem annotations

Ayaz Abdulla (1):
      forcedeth: msi interrupts

Ben Hutchings (1):
      sky2: Hold RTNL while calling dev_close()

Cornelia Huck (1):
      qeth: Use ccw_device_get_id().

Frank Blaschka (3):
      qeth: layer 3 Oops in ip event handler
      qeth: reduce number of kernel messages
      qeth: start dev queue after tx drop error

Jan-Bernd Themann (1):
      ehea: set mac address fix

Jay Cliburn (1):
      atl1: fix suspend regression

Jeff Kirsher (1):
      ixgbe: fix typo

Mark McLoughlin (3):
      virtio_net: Fix skb->csum_start computation
      virtio: Fix typo in virtio_net_hdr comments
      virtio: virtio_net free transmit skbs in a timer

Peter Tiedemann (1):
      qeth: Prepare-function to call s390dbf was wrong

Rusty Russell (1):
      virtio: use callback on empty in virtio_net

Steve Hodgson (1):
      sfc: Recover from RX queue flush failure

diff --git a/drivers/net/7990.c b/drivers/net/7990.c
index 750a46f..ad6b8a5 100644
--- a/drivers/net/7990.c
+++ b/drivers/net/7990.c
@@ -506,6 +506,7 @@ int lance_open (struct net_device *dev)
 
 	return res;
 }
+EXPORT_SYMBOL_GPL(lance_open);
 
 int lance_close (struct net_device *dev)
 {
@@ -521,6 +522,7 @@ int lance_close (struct net_device *dev)
 
         return 0;
 }
+EXPORT_SYMBOL_GPL(lance_close);
 
 void lance_tx_timeout(struct net_device *dev)
 {
@@ -529,7 +531,7 @@ void lance_tx_timeout(struct net_device *dev)
 	dev->trans_start = jiffies;
 	netif_wake_queue (dev);
 }
-
+EXPORT_SYMBOL_GPL(lance_tx_timeout);
 
 int lance_start_xmit (struct sk_buff *skb, struct net_device *dev)
 {
@@ -586,6 +588,7 @@ int lance_start_xmit (struct sk_buff *skb, struct net_device *dev)
 
         return 0;
 }
+EXPORT_SYMBOL_GPL(lance_start_xmit);
 
 /* taken from the depca driver via a2065.c */
 static void lance_load_multicast (struct net_device *dev)
@@ -654,6 +657,7 @@ void lance_set_multicast (struct net_device *dev)
 	if (!stopped)
 		netif_start_queue (dev);
 }
+EXPORT_SYMBOL_GPL(lance_set_multicast);
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
 void lance_poll(struct net_device *dev)
diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
index 6ddc911..99e0b4c 100644
--- a/drivers/net/atlx/atl1.c
+++ b/drivers/net/atlx/atl1.c
@@ -637,22 +637,6 @@ static s32 atl1_phy_leave_power_saving(struct atl1_hw *hw)
 }
 
 /*
- * Force the PHY into power saving mode using vendor magic.
- */
-#ifdef CONFIG_PM
-static void atl1_phy_enter_power_saving(struct atl1_hw *hw)
-{
-	atl1_write_phy_reg(hw, MII_DBG_ADDR, 0);
-	atl1_write_phy_reg(hw, MII_DBG_DATA, 0x124E);
-	atl1_write_phy_reg(hw, MII_DBG_ADDR, 2);
-	atl1_write_phy_reg(hw, MII_DBG_DATA, 0x3000);
-	atl1_write_phy_reg(hw, MII_DBG_ADDR, 3);
-	atl1_write_phy_reg(hw, MII_DBG_DATA, 0);
-
-}
-#endif
-
-/*
  * Resets the PHY and make all config validate
  * hw - Struct containing variables accessed by shared code
  *
@@ -2860,7 +2844,6 @@ disable_wol:
 	ctrl |= PCIE_PHYMISC_FORCE_RCV_DET;
 	iowrite32(ctrl, hw->hw_addr + REG_PCIE_PHYMISC);
 	ioread32(hw->hw_addr + REG_PCIE_PHYMISC);
-	atl1_phy_enter_power_saving(hw);
 	hw->phy_configured = false;
 	pci_enable_wake(pdev, pci_choose_state(pdev, state), 0);
 exit:
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index 287a619..faae01d 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -1766,16 +1766,20 @@ static int ehea_set_mac_addr(struct net_device *dev, void *sa)
 	mutex_lock(&ehea_bcmc_regs.lock);
 
 	/* Deregister old MAC in pHYP */
-	ret = ehea_broadcast_reg_helper(port, H_DEREG_BCMC);
-	if (ret)
-		goto out_upregs;
+	if (port->state == EHEA_PORT_UP) {
+		ret = ehea_broadcast_reg_helper(port, H_DEREG_BCMC);
+		if (ret)
+			goto out_upregs;
+	}
 
 	port->mac_addr = cb0->port_mac_addr << 16;
 
 	/* Register new MAC in pHYP */
-	ret = ehea_broadcast_reg_helper(port, H_REG_BCMC);
-	if (ret)
-		goto out_upregs;
+	if (port->state == EHEA_PORT_UP) {
+		ret = ehea_broadcast_reg_helper(port, H_REG_BCMC);
+		if (ret)
+			goto out_upregs;
+	}
 
 	ret = 0;
 
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 9eca97f..2cb2447 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -3273,6 +3273,20 @@ static void nv_link_irq(struct net_device *dev)
 	dprintk(KERN_DEBUG "%s: link change notification done.\n", dev->name);
 }
 
+static void nv_msi_workaround(struct fe_priv *np)
+{
+
+	/* Need to toggle the msi irq mask within the ethernet device,
+	 * otherwise, future interrupts will not be detected.
+	 */
+	if (np->msi_flags & NV_MSI_ENABLED) {
+		u8 __iomem *base = np->base;
+
+		writel(0, base + NvRegMSIIrqMask);
+		writel(NVREG_MSI_VECTOR_0_ENABLED, base + NvRegMSIIrqMask);
+	}
+}
+
 static irqreturn_t nv_nic_irq(int foo, void *data)
 {
 	struct net_device *dev = (struct net_device *) data;
@@ -3295,6 +3309,8 @@ static irqreturn_t nv_nic_irq(int foo, void *data)
 		if (!(events & np->irqmask))
 			break;
 
+		nv_msi_workaround(np);
+
 		spin_lock(&np->lock);
 		nv_tx_done(dev);
 		spin_unlock(&np->lock);
@@ -3410,6 +3426,8 @@ static irqreturn_t nv_nic_irq_optimized(int foo, void *data)
 		if (!(events & np->irqmask))
 			break;
 
+		nv_msi_workaround(np);
+
 		spin_lock(&np->lock);
 		nv_tx_done_optimized(dev, TX_WORK_PER_LOOP);
 		spin_unlock(&np->lock);
@@ -3750,6 +3768,8 @@ static irqreturn_t nv_nic_irq_test(int foo, void *data)
 	if (!(events & NVREG_IRQ_TIMER))
 		return IRQ_RETVAL(0);
 
+	nv_msi_workaround(np);
+
 	spin_lock(&np->lock);
 	np->intr_test = 1;
 	spin_unlock(&np->lock);
diff --git a/drivers/net/ixgbe/ixgbe_82598.c b/drivers/net/ixgbe/ixgbe_82598.c
index 6321b05..2f38e84 100644
--- a/drivers/net/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ixgbe/ixgbe_82598.c
@@ -58,8 +58,8 @@ static s32 ixgbe_reset_hw_82598(struct ixgbe_hw *hw);
 
 static s32 ixgbe_get_invariants_82598(struct ixgbe_hw *hw)
 {
-	hw->mac.num_rx_queues = IXGBE_82598_MAX_TX_QUEUES;
-	hw->mac.num_tx_queues = IXGBE_82598_MAX_RX_QUEUES;
+	hw->mac.num_rx_queues = IXGBE_82598_MAX_RX_QUEUES;
+	hw->mac.num_tx_queues = IXGBE_82598_MAX_TX_QUEUES;
 	hw->mac.num_rx_addrs = IXGBE_82598_RAR_ENTRIES;
 
 	/* PHY ops are filled in by default properly for Fiber only */
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index a20693e..b5c1e66 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -2861,7 +2861,8 @@ static int s2io_poll_msix(struct napi_struct *napi, int budget)
 	struct config_param *config;
 	struct mac_info *mac_control;
 	int pkts_processed = 0;
-	u8 *addr = NULL, val8 = 0;
+	u8 __iomem *addr = NULL;
+	u8 val8 = 0;
 	struct s2io_nic *nic = dev->priv;
 	struct XENA_dev_config __iomem *bar0 = nic->bar0;
 	int budget_org = budget;
@@ -2878,7 +2879,7 @@ static int s2io_poll_msix(struct napi_struct *napi, int budget)
 	if (pkts_processed < budget_org) {
 		netif_rx_complete(dev, napi);
 		/*Re Enable MSI-Rx Vector*/
-		addr = (u8 *)&bar0->xmsi_mask_reg;
+		addr = (u8 __iomem *)&bar0->xmsi_mask_reg;
 		addr += 7 - ring->ring_no;
 		val8 = (ring->ring_no == 0) ? 0x3f : 0xbf;
 		writeb(val8, addr);
@@ -4364,9 +4365,10 @@ static irqreturn_t s2io_msix_ring_handle(int irq, void *dev_id)
 		return IRQ_HANDLED;
 
 	if (sp->config.napi) {
-		u8 *addr = NULL, val8 = 0;
+		u8 __iomem *addr = NULL;
+		u8 val8 = 0;
 
-		addr = (u8 *)&bar0->xmsi_mask_reg;
+		addr = (u8 __iomem *)&bar0->xmsi_mask_reg;
 		addr += (7 - ring->ring_no);
 		val8 = (ring->ring_no == 0) ? 0x7f : 0xff;
 		writeb(val8, addr);
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index d3f749c..790db89 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -733,8 +733,10 @@ void falcon_fini_rx(struct efx_rx_queue *rx_queue)
 			continue;
 		break;
 	}
-	if (rc)
+	if (rc) {
 		EFX_ERR(efx, "failed to flush rx queue %d\n", rx_queue->queue);
+		efx_schedule_reset(efx, RESET_TYPE_INVISIBLE);
+	}
 
 	/* Remove RX descriptor ring from card */
 	EFX_ZERO_OWORD(rx_desc_ptr);
diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 3bb6053..62436b3 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -4404,7 +4404,9 @@ static int sky2_resume(struct pci_dev *pdev)
 			if (err) {
 				printk(KERN_ERR PFX "%s: could not up: %d\n",
 				       dev->name, err);
+				rtnl_lock();
 				dev_close(dev);
+				rtnl_unlock();
 				goto out;
 			}
 		}
diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 5450eac..4452306 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -44,11 +44,15 @@ struct virtnet_info
 	/* The skb we couldn't send because buffers were full. */
 	struct sk_buff *last_xmit_skb;
 
+	/* If we need to free in a timer, this is it. */
+	struct timer_list xmit_free_timer;
+
 	/* Number of input buffers, and max we've ever had. */
 	unsigned int num, max;
 
 	/* For cleaning up after transmission. */
 	struct tasklet_struct tasklet;
+	bool free_in_tasklet;
 
 	/* Receive & send queues. */
 	struct sk_buff_head recv;
@@ -72,7 +76,7 @@ static void skb_xmit_done(struct virtqueue *svq)
 	/* Suppress further interrupts. */
 	svq->vq_ops->disable_cb(svq);
 
-	/* We were waiting for more output buffers. */
+	/* We were probably waiting for more output buffers. */
 	netif_wake_queue(vi->dev);
 
 	/* Make sure we re-xmit last_xmit_skb: if there are no more packets
@@ -94,9 +98,7 @@ static void receive_skb(struct net_device *dev, struct sk_buff *skb,
 	BUG_ON(len > MAX_PACKET_LEN);
 
 	skb_trim(skb, len);
-	skb->protocol = eth_type_trans(skb, dev);
-	pr_debug("Receiving skb proto 0x%04x len %i type %i\n",
-		 ntohs(skb->protocol), skb->len, skb->pkt_type);
+
 	dev->stats.rx_bytes += skb->len;
 	dev->stats.rx_packets++;
 
@@ -106,6 +108,10 @@ static void receive_skb(struct net_device *dev, struct sk_buff *skb,
 			goto frame_err;
 	}
 
+	skb->protocol = eth_type_trans(skb, dev);
+	pr_debug("Receiving skb proto 0x%04x len %i type %i\n",
+		 ntohs(skb->protocol), skb->len, skb->pkt_type);
+
 	if (hdr->gso_type != VIRTIO_NET_HDR_GSO_NONE) {
 		pr_debug("GSO!\n");
 		switch (hdr->gso_type & ~VIRTIO_NET_HDR_GSO_ECN) {
@@ -238,9 +244,25 @@ static void free_old_xmit_skbs(struct virtnet_info *vi)
 	}
 }
 
+/* If the virtio transport doesn't always notify us when all in-flight packets
+ * are consumed, we fall back to using this function on a timer to free them. */
+static void xmit_free(unsigned long data)
+{
+	struct virtnet_info *vi = (void *)data;
+
+	netif_tx_lock(vi->dev);
+
+	free_old_xmit_skbs(vi);
+
+	if (!skb_queue_empty(&vi->send))
+		mod_timer(&vi->xmit_free_timer, jiffies + (HZ/10));
+
+	netif_tx_unlock(vi->dev);
+}
+
 static int xmit_skb(struct virtnet_info *vi, struct sk_buff *skb)
 {
-	int num;
+	int num, err;
 	struct scatterlist sg[2+MAX_SKB_FRAGS];
 	struct virtio_net_hdr *hdr;
 	const unsigned char *dest = ((struct ethhdr *)skb->data)->h_dest;
@@ -283,7 +305,11 @@ static int xmit_skb(struct virtnet_info *vi, struct sk_buff *skb)
 	vnet_hdr_to_sg(sg, skb);
 	num = skb_to_sgvec(skb, sg+1, 0, skb->len) + 1;
 
-	return vi->svq->vq_ops->add_buf(vi->svq, sg, num, 0, skb);
+	err = vi->svq->vq_ops->add_buf(vi->svq, sg, num, 0, skb);
+	if (!err && !vi->free_in_tasklet)
+		mod_timer(&vi->xmit_free_timer, jiffies + (HZ/10));
+
+	return err;
 }
 
 static void xmit_tasklet(unsigned long data)
@@ -295,6 +321,8 @@ static void xmit_tasklet(unsigned long data)
 		vi->svq->vq_ops->kick(vi->svq);
 		vi->last_xmit_skb = NULL;
 	}
+	if (vi->free_in_tasklet)
+		free_old_xmit_skbs(vi);
 	netif_tx_unlock_bh(vi->dev);
 }
 
@@ -435,6 +463,10 @@ static int virtnet_probe(struct virtio_device *vdev)
 	vi->vdev = vdev;
 	vdev->priv = vi;
 
+	/* If they give us a callback when all buffers are done, we don't need
+	 * the timer. */
+	vi->free_in_tasklet = virtio_has_feature(vdev,VIRTIO_F_NOTIFY_ON_EMPTY);
+
 	/* We expect two virtqueues, receive then send. */
 	vi->rvq = vdev->config->find_vq(vdev, 0, skb_recv_done);
 	if (IS_ERR(vi->rvq)) {
@@ -454,6 +486,9 @@ static int virtnet_probe(struct virtio_device *vdev)
 
 	tasklet_init(&vi->tasklet, xmit_tasklet, (unsigned long)vi);
 
+	if (!vi->free_in_tasklet)
+		setup_timer(&vi->xmit_free_timer, xmit_free, (unsigned long)vi);
+
 	err = register_netdev(dev);
 	if (err) {
 		pr_debug("virtio_net: registering device failed\n");
@@ -491,6 +526,9 @@ static void virtnet_remove(struct virtio_device *vdev)
 	/* Stop all the virtqueues. */
 	vdev->config->reset(vdev);
 
+	if (!vi->free_in_tasklet)
+		del_timer_sync(&vi->xmit_free_timer);
+
 	/* Free our skbs in send and recv queues, if any. */
 	while ((skb = __skb_dequeue(&vi->recv)) != NULL) {
 		kfree_skb(skb);
@@ -514,7 +552,7 @@ static struct virtio_device_id id_table[] = {
 static unsigned int features[] = {
 	VIRTIO_NET_F_CSUM, VIRTIO_NET_F_GSO, VIRTIO_NET_F_MAC,
 	VIRTIO_NET_F_HOST_TSO4, VIRTIO_NET_F_HOST_UFO, VIRTIO_NET_F_HOST_TSO6,
-	VIRTIO_NET_F_HOST_ECN,
+	VIRTIO_NET_F_HOST_ECN, VIRTIO_F_NOTIFY_ON_EMPTY,
 };
 
 static struct virtio_driver virtio_net = {
diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index 436bf1f..9a71dae 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -290,9 +290,6 @@ int qeth_set_large_send(struct qeth_card *card,
 			card->dev->features |= NETIF_F_TSO | NETIF_F_SG |
 						NETIF_F_HW_CSUM;
 		} else {
-			PRINT_WARN("TSO not supported on %s. "
-				   "large_send set to 'no'.\n",
-				   card->dev->name);
 			card->dev->features &= ~(NETIF_F_TSO | NETIF_F_SG |
 						NETIF_F_HW_CSUM);
 			card->options.large_send = QETH_LARGE_SEND_NO;
@@ -1407,12 +1404,6 @@ static void qeth_init_func_level(struct qeth_card *card)
 	}
 }
 
-static inline __u16 qeth_raw_devno_from_bus_id(char *id)
-{
-	id += (strlen(id) - 4);
-	return (__u16) simple_strtoul(id, &id, 16);
-}
-
 static int qeth_idx_activate_get_answer(struct qeth_channel *channel,
 		void (*idx_reply_cb)(struct qeth_channel *,
 			struct qeth_cmd_buffer *))
@@ -1439,7 +1430,7 @@ static int qeth_idx_activate_get_answer(struct qeth_channel *channel,
 	spin_unlock_irqrestore(get_ccwdev_lock(channel->ccwdev), flags);
 
 	if (rc) {
-		PRINT_ERR("Error2 in activating channel rc=%d\n", rc);
+		QETH_DBF_MESSAGE(2, "Error2 in activating channel rc=%d\n", rc);
 		QETH_DBF_TEXT_(SETUP, 2, "2err%d", rc);
 		atomic_set(&channel->irq_pending, 0);
 		wake_up(&card->wait_q);
@@ -1468,6 +1459,7 @@ static int qeth_idx_activate_channel(struct qeth_channel *channel,
 	__u16 temp;
 	__u8 tmp;
 	int rc;
+	struct ccw_dev_id temp_devid;
 
 	card = CARD_FROM_CDEV(channel->ccwdev);
 
@@ -1494,8 +1486,8 @@ static int qeth_idx_activate_channel(struct qeth_channel *channel,
 	       &card->token.issuer_rm_w, QETH_MPC_TOKEN_LENGTH);
 	memcpy(QETH_IDX_ACT_FUNC_LEVEL(iob->data),
 	       &card->info.func_level, sizeof(__u16));
-	temp = qeth_raw_devno_from_bus_id(CARD_DDEV_ID(card));
-	memcpy(QETH_IDX_ACT_QDIO_DEV_CUA(iob->data), &temp, 2);
+	ccw_device_get_id(CARD_DDEV(card), &temp_devid);
+	memcpy(QETH_IDX_ACT_QDIO_DEV_CUA(iob->data), &temp_devid.devno, 2);
 	temp = (card->info.cula << 8) + card->info.unit_addr2;
 	memcpy(QETH_IDX_ACT_QDIO_DEV_REALADDR(iob->data), &temp, 2);
 
@@ -1508,7 +1500,8 @@ static int qeth_idx_activate_channel(struct qeth_channel *channel,
 	spin_unlock_irqrestore(get_ccwdev_lock(channel->ccwdev), flags);
 
 	if (rc) {
-		PRINT_ERR("Error1 in activating channel. rc=%d\n", rc);
+		QETH_DBF_MESSAGE(2, "Error1 in activating channel. rc=%d\n",
+			rc);
 		QETH_DBF_TEXT_(SETUP, 2, "1err%d", rc);
 		atomic_set(&channel->irq_pending, 0);
 		wake_up(&card->wait_q);
@@ -1658,7 +1651,6 @@ int qeth_send_control_data(struct qeth_card *card, int len,
 
 	reply = qeth_alloc_reply(card);
 	if (!reply) {
-		PRINT_WARN("Could not alloc qeth_reply!\n");
 		return -ENOMEM;
 	}
 	reply->callback = reply_cb;
@@ -2612,15 +2604,9 @@ void qeth_queue_input_buffer(struct qeth_card *card, int index)
 		if (newcount < count) {
 			/* we are in memory shortage so we switch back to
 			   traditional skb allocation and drop packages */
-			if (!atomic_read(&card->force_alloc_skb) &&
-			    net_ratelimit())
-				PRINT_WARN("Switch to alloc skb\n");
 			atomic_set(&card->force_alloc_skb, 3);
 			count = newcount;
 		} else {
-			if ((atomic_read(&card->force_alloc_skb) == 1) &&
-			    net_ratelimit())
-				PRINT_WARN("Switch to sg\n");
 			atomic_add_unless(&card->force_alloc_skb, -1, 0);
 		}
 
@@ -3034,7 +3020,7 @@ int qeth_get_elements_no(struct qeth_card *card, void *hdr,
 		elements_needed = 1 + (((((unsigned long) hdr) % PAGE_SIZE)
 			+ skb->len) >> PAGE_SHIFT);
 	if ((elements_needed + elems) > QETH_MAX_BUFFER_ELEMENTS(card)) {
-		PRINT_ERR("Invalid size of IP packet "
+		QETH_DBF_MESSAGE(2, "Invalid size of IP packet "
 			"(Number=%d / Length=%d). Discarded.\n",
 			(elements_needed+elems), skb->len);
 		return 0;
@@ -3247,8 +3233,6 @@ int qeth_do_send_packet(struct qeth_card *card, struct qeth_qdio_out_q *queue,
 			 * free buffers) to handle eddp context */
 			if (qeth_eddp_check_buffers_for_context(queue, ctx)
 				< 0) {
-				if (net_ratelimit())
-					PRINT_WARN("eddp tx_dropped 1\n");
 				rc = -EBUSY;
 				goto out;
 			}
@@ -3260,7 +3244,6 @@ int qeth_do_send_packet(struct qeth_card *card, struct qeth_qdio_out_q *queue,
 		tmp = qeth_eddp_fill_buffer(queue, ctx,
 						queue->next_buf_to_fill);
 		if (tmp < 0) {
-			PRINT_ERR("eddp tx_dropped 2\n");
 			rc = -EBUSY;
 			goto out;
 		}
@@ -3602,8 +3585,6 @@ int qeth_snmp_command(struct qeth_card *card, char __user *udata)
 
 	if ((!qeth_adp_supported(card, IPA_SETADP_SET_SNMP_CONTROL)) &&
 	    (!card->options.layer2)) {
-		PRINT_WARN("SNMP Query MIBS not supported "
-			   "on %s!\n", QETH_CARD_IFNAME(card));
 		return -EOPNOTSUPP;
 	}
 	/* skip 4 bytes (data_len struct member) to get req_len */
@@ -3634,7 +3615,7 @@ int qeth_snmp_command(struct qeth_card *card, char __user *udata)
 	rc = qeth_send_ipa_snmp_cmd(card, iob, QETH_SETADP_BASE_LEN + req_len,
 				    qeth_snmp_command_cb, (void *)&qinfo);
 	if (rc)
-		PRINT_WARN("SNMP command failed on %s: (0x%x)\n",
+		QETH_DBF_MESSAGE(2, "SNMP command failed on %s: (0x%x)\n",
 			   QETH_CARD_IFNAME(card), rc);
 	else {
 		if (copy_to_user(udata, qinfo.udata, qinfo.udata_len))
@@ -3807,8 +3788,8 @@ retry:
 	if (mpno)
 		mpno = min(mpno - 1, QETH_MAX_PORTNO);
 	if (card->info.portno > mpno) {
-		PRINT_ERR("Device %s does not offer port number %d \n.",
-			CARD_BUS_ID(card), card->info.portno);
+		QETH_DBF_MESSAGE(2, "Device %s does not offer port number %d"
+			"\n.", CARD_BUS_ID(card), card->info.portno);
 		rc = -ENODEV;
 		goto out;
 	}
@@ -3985,8 +3966,6 @@ struct sk_buff *qeth_core_get_next_skb(struct qeth_card *card,
 	return skb;
 no_mem:
 	if (net_ratelimit()) {
-		PRINT_WARN("No memory for packet received on %s.\n",
-			   QETH_CARD_IFNAME(card));
 		QETH_DBF_TEXT(TRACE, 2, "noskbmem");
 		QETH_DBF_TEXT_(TRACE, 2, "%s", CARD_BUS_ID(card));
 	}
@@ -4004,15 +3983,17 @@ static void qeth_unregister_dbf_views(void)
 	}
 }
 
-void qeth_dbf_longtext(enum qeth_dbf_names dbf_nix, int level, char *text, ...)
+void qeth_dbf_longtext(enum qeth_dbf_names dbf_nix, int level, char *fmt, ...)
 {
 	char dbf_txt_buf[32];
+	va_list args;
 
 	if (level > (qeth_dbf[dbf_nix].id)->level)
 		return;
-	snprintf(dbf_txt_buf, sizeof(dbf_txt_buf), text);
+	va_start(args, fmt);
+	vsnprintf(dbf_txt_buf, sizeof(dbf_txt_buf), fmt, args);
+	va_end(args);
 	debug_text_event(qeth_dbf[dbf_nix].id, level, dbf_txt_buf);
-	
 }
 EXPORT_SYMBOL_GPL(qeth_dbf_longtext);
 
diff --git a/drivers/s390/net/qeth_core_offl.c b/drivers/s390/net/qeth_core_offl.c
index 822df83..452874e 100644
--- a/drivers/s390/net/qeth_core_offl.c
+++ b/drivers/s390/net/qeth_core_offl.c
@@ -122,8 +122,8 @@ int qeth_eddp_fill_buffer(struct qeth_qdio_out_q *queue,
 			if (element == 0)
 				return -EBUSY;
 			else {
-				PRINT_WARN("could only partially fill eddp "
-					   "buffer!\n");
+				QETH_DBF_MESSAGE(2, "could only partially fill"
+					"eddp buffer!\n");
 				goto out;
 			}
 		}
@@ -143,8 +143,6 @@ int qeth_eddp_fill_buffer(struct qeth_qdio_out_q *queue,
 		if (must_refcnt) {
 			must_refcnt = 0;
 			if (qeth_eddp_buf_ref_context(buf, ctx)) {
-				PRINT_WARN("no memory to create eddp context "
-					   "reference\n");
 				goto out_check;
 			}
 		}
diff --git a/drivers/s390/net/qeth_core_sys.c b/drivers/s390/net/qeth_core_sys.c
index 08a50f0..c26e842 100644
--- a/drivers/s390/net/qeth_core_sys.c
+++ b/drivers/s390/net/qeth_core_sys.c
@@ -129,7 +129,6 @@ static ssize_t qeth_dev_portno_store(struct device *dev,
 
 	portno = simple_strtoul(buf, &tmp, 16);
 	if (portno > QETH_MAX_PORTNO) {
-		PRINT_WARN("portno 0x%X is out of range\n", portno);
 		return -EINVAL;
 	}
 
@@ -223,8 +222,6 @@ static ssize_t qeth_dev_prioqing_store(struct device *dev,
 	 * if though we have to permit priority queueing
 	 */
 	if (card->qdio.no_out_queues == 1) {
-		PRINT_WARN("Priority queueing disabled due "
-			   "to hardware limitations!\n");
 		card->qdio.do_prio_queueing = QETH_PRIOQ_DEFAULT;
 		return -EPERM;
 	}
@@ -250,7 +247,6 @@ static ssize_t qeth_dev_prioqing_store(struct device *dev,
 		card->qdio.do_prio_queueing = QETH_NO_PRIO_QUEUEING;
 		card->qdio.default_out_queue = QETH_DEFAULT_QUEUE;
 	} else {
-		PRINT_WARN("Unknown queueing type '%s'\n", tmp);
 		return -EINVAL;
 	}
 	return count;
@@ -291,9 +287,6 @@ static ssize_t qeth_dev_bufcnt_store(struct device *dev,
 		((cnt > QETH_IN_BUF_COUNT_MAX) ? QETH_IN_BUF_COUNT_MAX : cnt);
 	if (old_cnt != cnt) {
 		rc = qeth_realloc_buffer_pool(card, cnt);
-		if (rc)
-			PRINT_WARN("Error (%d) while setting "
-				   "buffer count.\n", rc);
 	}
 	return count;
 }
@@ -355,7 +348,6 @@ static ssize_t qeth_dev_performance_stats_store(struct device *dev,
 		card->perf_stats.initial_rx_packets = card->stats.rx_packets;
 		card->perf_stats.initial_tx_packets = card->stats.tx_packets;
 	} else {
-		PRINT_WARN("performance_stats: write 0 or 1 to this file!\n");
 		return -EINVAL;
 	}
 	return count;
@@ -399,7 +391,6 @@ static ssize_t qeth_dev_layer2_store(struct device *dev,
 		newdis = QETH_DISCIPLINE_LAYER2;
 		break;
 	default:
-		PRINT_WARN("layer2: write 0 or 1 to this file!\n");
 		return -EINVAL;
 	}
 
@@ -463,7 +454,6 @@ static ssize_t qeth_dev_large_send_store(struct device *dev,
 	} else if (!strcmp(tmp, "TSO")) {
 		type = QETH_LARGE_SEND_TSO;
 	} else {
-		PRINT_WARN("large_send: invalid mode %s!\n", tmp);
 		return -EINVAL;
 	}
 	if (card->options.large_send == type)
@@ -503,8 +493,6 @@ static ssize_t qeth_dev_blkt_store(struct qeth_card *card,
 	if (i <= max_value) {
 		*value = i;
 	} else {
-		PRINT_WARN("blkt total time: write values between"
-			   " 0 and %d to this file!\n", max_value);
 		return -EINVAL;
 	}
 	return count;
diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index 86ec50d..f682f7b 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -101,19 +101,16 @@ static struct net_device *qeth_l2_netdev_by_devno(unsigned char *read_dev_no)
 {
 	struct qeth_card *card;
 	struct net_device *ndev;
-	unsigned char *readno;
-	__u16 temp_dev_no, card_dev_no;
-	char *endp;
+	__u16 temp_dev_no;
 	unsigned long flags;
+	struct ccw_dev_id read_devid;
 
 	ndev = NULL;
 	memcpy(&temp_dev_no, read_dev_no, 2);
 	read_lock_irqsave(&qeth_core_card_list.rwlock, flags);
 	list_for_each_entry(card, &qeth_core_card_list.list, list) {
-		readno = CARD_RDEV_ID(card);
-		readno += (strlen(readno) - 4);
-		card_dev_no = simple_strtoul(readno, &endp, 16);
-		if (card_dev_no == temp_dev_no) {
+		ccw_device_get_id(CARD_RDEV(card), &read_devid);
+		if (read_devid.devno == temp_dev_no) {
 			ndev = card->dev;
 			break;
 		}
@@ -134,14 +131,14 @@ static int qeth_l2_send_setgroupmac_cb(struct qeth_card *card,
 	mac = &cmd->data.setdelmac.mac[0];
 	/* MAC already registered, needed in couple/uncouple case */
 	if (cmd->hdr.return_code == 0x2005) {
-		PRINT_WARN("Group MAC %02x:%02x:%02x:%02x:%02x:%02x " \
+		QETH_DBF_MESSAGE(2, "Group MAC %02x:%02x:%02x:%02x:%02x:%02x "
 			  "already existing on %s \n",
 			  mac[0], mac[1], mac[2], mac[3], mac[4], mac[5],
 			  QETH_CARD_IFNAME(card));
 		cmd->hdr.return_code = 0;
 	}
 	if (cmd->hdr.return_code)
-		PRINT_ERR("Could not set group MAC " \
+		QETH_DBF_MESSAGE(2, "Could not set group MAC "
 			  "%02x:%02x:%02x:%02x:%02x:%02x on %s: %x\n",
 			  mac[0], mac[1], mac[2], mac[3], mac[4], mac[5],
 			  QETH_CARD_IFNAME(card), cmd->hdr.return_code);
@@ -166,7 +163,7 @@ static int qeth_l2_send_delgroupmac_cb(struct qeth_card *card,
 	cmd = (struct qeth_ipa_cmd *) data;
 	mac = &cmd->data.setdelmac.mac[0];
 	if (cmd->hdr.return_code)
-		PRINT_ERR("Could not delete group MAC " \
+		QETH_DBF_MESSAGE(2, "Could not delete group MAC "
 			  "%02x:%02x:%02x:%02x:%02x:%02x on %s: %x\n",
 			  mac[0], mac[1], mac[2], mac[3], mac[4], mac[5],
 			  QETH_CARD_IFNAME(card), cmd->hdr.return_code);
@@ -186,10 +183,8 @@ static void qeth_l2_add_mc(struct qeth_card *card, __u8 *mac)
 
 	mc = kmalloc(sizeof(struct qeth_mc_mac), GFP_ATOMIC);
 
-	if (!mc) {
-		PRINT_ERR("no mem vor mc mac address\n");
+	if (!mc)
 		return;
-	}
 
 	memcpy(mc->mc_addr, mac, OSA_ADDR_LEN);
 	mc->mc_addrlen = OSA_ADDR_LEN;
@@ -280,7 +275,7 @@ static int qeth_l2_send_setdelvlan_cb(struct qeth_card *card,
 	QETH_DBF_TEXT(TRACE, 2, "L2sdvcb");
 	cmd = (struct qeth_ipa_cmd *) data;
 	if (cmd->hdr.return_code) {
-		PRINT_ERR("Error in processing VLAN %i on %s: 0x%x. "
+		QETH_DBF_MESSAGE(2, "Error in processing VLAN %i on %s: 0x%x. "
 			  "Continuing\n", cmd->data.setdelvlan.vlan_id,
 			  QETH_CARD_IFNAME(card), cmd->hdr.return_code);
 		QETH_DBF_TEXT_(TRACE, 2, "L2VL%4x", cmd->hdr.command);
@@ -333,8 +328,6 @@ static void qeth_l2_vlan_rx_add_vid(struct net_device *dev, unsigned short vid)
 		spin_lock_bh(&card->vlanlock);
 		list_add_tail(&id->list, &card->vid_list);
 		spin_unlock_bh(&card->vlanlock);
-	} else {
-		PRINT_ERR("no memory for vid\n");
 	}
 }
 
@@ -550,16 +543,15 @@ static int qeth_l2_request_initial_mac(struct qeth_card *card)
 
 	rc = qeth_query_setadapterparms(card);
 	if (rc) {
-		PRINT_WARN("could not query adapter parameters on device %s: "
-			   "x%x\n", CARD_BUS_ID(card), rc);
+		QETH_DBF_MESSAGE(2, "could not query adapter parameters on "
+			"device %s: x%x\n", CARD_BUS_ID(card), rc);
 	}
 
 	if (card->info.guestlan) {
 		rc = qeth_setadpparms_change_macaddr(card);
 		if (rc) {
-			PRINT_WARN("couldn't get MAC address on "
-			   "device %s: x%x\n",
-			   CARD_BUS_ID(card), rc);
+			QETH_DBF_MESSAGE(2, "couldn't get MAC address on "
+				"device %s: x%x\n", CARD_BUS_ID(card), rc);
 			QETH_DBF_TEXT_(SETUP, 2, "1err%d", rc);
 			return rc;
 		}
@@ -585,8 +577,6 @@ static int qeth_l2_set_mac_address(struct net_device *dev, void *p)
 	}
 
 	if (card->info.type == QETH_CARD_TYPE_OSN) {
-		PRINT_WARN("Setting MAC address on %s is not supported.\n",
-			   dev->name);
 		QETH_DBF_TEXT(TRACE, 3, "setmcOSN");
 		return -EOPNOTSUPP;
 	}
@@ -666,7 +656,7 @@ static int qeth_l2_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		ctx = qeth_eddp_create_context(card, new_skb, hdr,
 						skb->sk->sk_protocol);
 		if (ctx == NULL) {
-			PRINT_WARN("could not create eddp context\n");
+			QETH_DBF_MESSAGE(2, "could not create eddp context\n");
 			goto tx_drop;
 		}
 	} else {
@@ -731,6 +721,7 @@ tx_drop:
 	if ((new_skb != skb) && new_skb)
 		dev_kfree_skb_any(new_skb);
 	dev_kfree_skb_any(skb);
+	netif_wake_queue(dev);
 	return NETDEV_TX_OK;
 }
 
@@ -1155,7 +1146,7 @@ static int qeth_osn_send_control_data(struct qeth_card *card, int len,
 			      (addr_t) iob, 0, 0);
 	spin_unlock_irqrestore(get_ccwdev_lock(card->write.ccwdev), flags);
 	if (rc) {
-		PRINT_WARN("qeth_osn_send_control_data: "
+		QETH_DBF_MESSAGE(2, "qeth_osn_send_control_data: "
 			   "ccw_device_start rc = %i\n", rc);
 		QETH_DBF_TEXT_(TRACE, 2, " err%d", rc);
 		qeth_release_buffer(iob->channel, iob);
diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index 94a8ead..999552c 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -311,7 +311,6 @@ static struct qeth_ipaddr *qeth_l3_get_addr_buffer(
 
 	addr = kzalloc(sizeof(struct qeth_ipaddr), GFP_ATOMIC);
 	if (addr == NULL) {
-		PRINT_WARN("Not enough memory to add address\n");
 		return NULL;
 	}
 	addr->type = QETH_IP_TYPE_NORMAL;
@@ -649,15 +648,6 @@ static void qeth_l3_correct_routing_type(struct qeth_card *card,
 		}
 	}
 out_inval:
-	PRINT_WARN("Routing type '%s' not supported for interface %s.\n"
-		   "Router status set to 'no router'.\n",
-		   ((*type == PRIMARY_ROUTER)? "primary router" :
-		    (*type == SECONDARY_ROUTER)? "secondary router" :
-		    (*type == PRIMARY_CONNECTOR)? "primary connector" :
-		    (*type == SECONDARY_CONNECTOR)? "secondary connector" :
-		    (*type == MULTICAST_ROUTER)? "multicast router" :
-		    "unknown"),
-		   card->dev->name);
 	*type = NO_ROUTER;
 }
 
@@ -674,9 +664,9 @@ int qeth_l3_setrouting_v4(struct qeth_card *card)
 				  QETH_PROT_IPV4);
 	if (rc) {
 		card->options.route4.type = NO_ROUTER;
-		PRINT_WARN("Error (0x%04x) while setting routing type on %s. "
-			   "Type set to 'no router'.\n",
-			   rc, QETH_CARD_IFNAME(card));
+		QETH_DBF_MESSAGE(2, "Error (0x%04x) while setting routing type"
+			" on %s. Type set to 'no router'.\n", rc,
+			QETH_CARD_IFNAME(card));
 	}
 	return rc;
 }
@@ -697,9 +687,9 @@ int qeth_l3_setrouting_v6(struct qeth_card *card)
 				  QETH_PROT_IPV6);
 	if (rc) {
 		card->options.route6.type = NO_ROUTER;
-		PRINT_WARN("Error (0x%04x) while setting routing type on %s. "
-			   "Type set to 'no router'.\n",
-			   rc, QETH_CARD_IFNAME(card));
+		QETH_DBF_MESSAGE(2, "Error (0x%04x) while setting routing type"
+			" on %s. Type set to 'no router'.\n", rc,
+			QETH_CARD_IFNAME(card));
 	}
 #endif
 	return rc;
@@ -737,7 +727,6 @@ int qeth_l3_add_ipato_entry(struct qeth_card *card,
 		if (!memcmp(ipatoe->addr, new->addr,
 			    (ipatoe->proto == QETH_PROT_IPV4)? 4:16) &&
 		    (ipatoe->mask_bits == new->mask_bits)) {
-			PRINT_WARN("ipato entry already exists!\n");
 			rc = -EEXIST;
 			break;
 		}
@@ -802,7 +791,6 @@ int qeth_l3_add_vipa(struct qeth_card *card, enum qeth_prot_versions proto,
 		rc = -EEXIST;
 	spin_unlock_irqrestore(&card->ip_lock, flags);
 	if (rc) {
-		PRINT_WARN("Cannot add VIPA. Address already exists!\n");
 		return rc;
 	}
 	if (!qeth_l3_add_ip(card, ipaddr))
@@ -867,7 +855,6 @@ int qeth_l3_add_rxip(struct qeth_card *card, enum qeth_prot_versions proto,
 		rc = -EEXIST;
 	spin_unlock_irqrestore(&card->ip_lock, flags);
 	if (rc) {
-		PRINT_WARN("Cannot add RXIP. Address already exists!\n");
 		return rc;
 	}
 	if (!qeth_l3_add_ip(card, ipaddr))
@@ -1020,23 +1007,23 @@ static int qeth_l3_setadapter_hstr(struct qeth_card *card)
 					IPA_SETADP_SET_BROADCAST_MODE,
 					card->options.broadcast_mode);
 		if (rc)
-			PRINT_WARN("couldn't set broadcast mode on "
+			QETH_DBF_MESSAGE(2, "couldn't set broadcast mode on "
 				   "device %s: x%x\n",
 				   CARD_BUS_ID(card), rc);
 		rc = qeth_l3_send_setadp_mode(card,
 					IPA_SETADP_ALTER_MAC_ADDRESS,
 					card->options.macaddr_mode);
 		if (rc)
-			PRINT_WARN("couldn't set macaddr mode on "
+			QETH_DBF_MESSAGE(2, "couldn't set macaddr mode on "
 				   "device %s: x%x\n", CARD_BUS_ID(card), rc);
 		return rc;
 	}
 	if (card->options.broadcast_mode == QETH_TR_BROADCAST_LOCAL)
-		PRINT_WARN("set adapter parameters not available "
+		QETH_DBF_MESSAGE(2, "set adapter parameters not available "
 			   "to set broadcast mode, using ALLRINGS "
 			   "on device %s:\n", CARD_BUS_ID(card));
 	if (card->options.macaddr_mode == QETH_TR_MACADDR_CANONICAL)
-		PRINT_WARN("set adapter parameters not available "
+		QETH_DBF_MESSAGE(2, "set adapter parameters not available "
 			   "to set macaddr mode, using NONCANONICAL "
 			   "on device %s:\n", CARD_BUS_ID(card));
 	return 0;
@@ -2070,7 +2057,7 @@ static struct qeth_card *qeth_l3_get_card_from_dev(struct net_device *dev)
 		card = netdev_priv(dev);
 	else if (rc == QETH_VLAN_CARD)
 		card = netdev_priv(vlan_dev_info(dev)->real_dev);
-	if (card->options.layer2)
+	if (card && card->options.layer2)
 		card = NULL;
 	QETH_DBF_TEXT_(TRACE, 4, "%d", rc);
 	return card ;
@@ -2182,8 +2169,6 @@ static int qeth_l3_arp_set_no_entries(struct qeth_card *card, int no_entries)
 	if (card->info.guestlan)
 		return -EOPNOTSUPP;
 	if (!qeth_is_supported(card, IPA_ARP_PROCESSING)) {
-		PRINT_WARN("ARP processing not supported "
-			   "on %s!\n", QETH_CARD_IFNAME(card));
 		return -EOPNOTSUPP;
 	}
 	rc = qeth_l3_send_simple_setassparms(card, IPA_ARP_PROCESSING,
@@ -2191,8 +2176,8 @@ static int qeth_l3_arp_set_no_entries(struct qeth_card *card, int no_entries)
 					  no_entries);
 	if (rc) {
 		tmp = rc;
-		PRINT_WARN("Could not set number of ARP entries on %s: "
-			"%s (0x%x/%d)\n", QETH_CARD_IFNAME(card),
+		QETH_DBF_MESSAGE(2, "Could not set number of ARP entries on "
+			"%s: %s (0x%x/%d)\n", QETH_CARD_IFNAME(card),
 			qeth_l3_arp_get_error_cause(&rc), tmp, tmp);
 	}
 	return rc;
@@ -2260,9 +2245,6 @@ static int qeth_l3_arp_query_cb(struct qeth_card *card,
 			qdata->no_entries * uentry_size){
 		QETH_DBF_TEXT_(TRACE, 4, "qaer3%i", -ENOMEM);
 		cmd->hdr.return_code = -ENOMEM;
-		PRINT_WARN("query ARP user space buffer is too small for "
-			   "the returned number of ARP entries. "
-			   "Aborting query!\n");
 		goto out_error;
 	}
 	QETH_DBF_TEXT_(TRACE, 4, "anore%i",
@@ -2324,8 +2306,6 @@ static int qeth_l3_arp_query(struct qeth_card *card, char __user *udata)
 
 	if (!qeth_is_supported(card,/*IPA_QUERY_ARP_ADDR_INFO*/
 			       IPA_ARP_PROCESSING)) {
-		PRINT_WARN("ARP processing not supported "
-			   "on %s!\n", QETH_CARD_IFNAME(card));
 		return -EOPNOTSUPP;
 	}
 	/* get size of userspace buffer and mask_bits -> 6 bytes */
@@ -2344,7 +2324,7 @@ static int qeth_l3_arp_query(struct qeth_card *card, char __user *udata)
 				   qeth_l3_arp_query_cb, (void *)&qinfo);
 	if (rc) {
 		tmp = rc;
-		PRINT_WARN("Error while querying ARP cache on %s: %s "
+		QETH_DBF_MESSAGE(2, "Error while querying ARP cache on %s: %s "
 			"(0x%x/%d)\n", QETH_CARD_IFNAME(card),
 			qeth_l3_arp_get_error_cause(&rc), tmp, tmp);
 		if (copy_to_user(udata, qinfo.udata, 4))
@@ -2375,8 +2355,6 @@ static int qeth_l3_arp_add_entry(struct qeth_card *card,
 	if (card->info.guestlan)
 		return -EOPNOTSUPP;
 	if (!qeth_is_supported(card, IPA_ARP_PROCESSING)) {
-		PRINT_WARN("ARP processing not supported "
-			   "on %s!\n", QETH_CARD_IFNAME(card));
 		return -EOPNOTSUPP;
 	}
 
@@ -2391,10 +2369,9 @@ static int qeth_l3_arp_add_entry(struct qeth_card *card,
 	if (rc) {
 		tmp = rc;
 		qeth_l3_ipaddr4_to_string((u8 *)entry->ipaddr, buf);
-		PRINT_WARN("Could not add ARP entry for address %s on %s: "
-			   "%s (0x%x/%d)\n",
-			   buf, QETH_CARD_IFNAME(card),
-			   qeth_l3_arp_get_error_cause(&rc), tmp, tmp);
+		QETH_DBF_MESSAGE(2, "Could not add ARP entry for address %s "
+			"on %s: %s (0x%x/%d)\n", buf, QETH_CARD_IFNAME(card),
+			qeth_l3_arp_get_error_cause(&rc), tmp, tmp);
 	}
 	return rc;
 }
@@ -2417,8 +2394,6 @@ static int qeth_l3_arp_remove_entry(struct qeth_card *card,
 	if (card->info.guestlan)
 		return -EOPNOTSUPP;
 	if (!qeth_is_supported(card, IPA_ARP_PROCESSING)) {
-		PRINT_WARN("ARP processing not supported "
-			   "on %s!\n", QETH_CARD_IFNAME(card));
 		return -EOPNOTSUPP;
 	}
 	memcpy(buf, entry, 12);
@@ -2433,10 +2408,9 @@ static int qeth_l3_arp_remove_entry(struct qeth_card *card,
 		tmp = rc;
 		memset(buf, 0, 16);
 		qeth_l3_ipaddr4_to_string((u8 *)entry->ipaddr, buf);
-		PRINT_WARN("Could not delete ARP entry for address %s on %s: "
-			   "%s (0x%x/%d)\n",
-			   buf, QETH_CARD_IFNAME(card),
-			   qeth_l3_arp_get_error_cause(&rc), tmp, tmp);
+		QETH_DBF_MESSAGE(2, "Could not delete ARP entry for address %s"
+			" on %s: %s (0x%x/%d)\n", buf, QETH_CARD_IFNAME(card),
+			qeth_l3_arp_get_error_cause(&rc), tmp, tmp);
 	}
 	return rc;
 }
@@ -2456,16 +2430,14 @@ static int qeth_l3_arp_flush_cache(struct qeth_card *card)
 	if (card->info.guestlan || (card->info.type == QETH_CARD_TYPE_IQD))
 		return -EOPNOTSUPP;
 	if (!qeth_is_supported(card, IPA_ARP_PROCESSING)) {
-		PRINT_WARN("ARP processing not supported "
-			   "on %s!\n", QETH_CARD_IFNAME(card));
 		return -EOPNOTSUPP;
 	}
 	rc = qeth_l3_send_simple_setassparms(card, IPA_ARP_PROCESSING,
 					  IPA_CMD_ASS_ARP_FLUSH_CACHE, 0);
 	if (rc) {
 		tmp = rc;
-		PRINT_WARN("Could not flush ARP cache on %s: %s (0x%x/%d)\n",
-			QETH_CARD_IFNAME(card),
+		QETH_DBF_MESSAGE(2, "Could not flush ARP cache on %s: %s "
+			"(0x%x/%d)\n", QETH_CARD_IFNAME(card),
 			qeth_l3_arp_get_error_cause(&rc), tmp, tmp);
 	}
 	return rc;
@@ -2724,7 +2696,7 @@ static int qeth_l3_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		ctx = qeth_eddp_create_context(card, new_skb, hdr,
 						skb->sk->sk_protocol);
 		if (ctx == NULL) {
-			PRINT_WARN("could not create eddp context\n");
+			QETH_DBF_MESSAGE(2, "could not create eddp context\n");
 			goto tx_drop;
 		}
 	} else {
@@ -2792,6 +2764,7 @@ tx_drop:
 	if ((new_skb != skb) && new_skb)
 		dev_kfree_skb_any(new_skb);
 	dev_kfree_skb_any(skb);
+	netif_wake_queue(dev);
 	return NETDEV_TX_OK;
 }
 
diff --git a/drivers/s390/net/qeth_l3_sys.c b/drivers/s390/net/qeth_l3_sys.c
index 08f51fd..ac19937 100644
--- a/drivers/s390/net/qeth_l3_sys.c
+++ b/drivers/s390/net/qeth_l3_sys.c
@@ -85,7 +85,6 @@ static ssize_t qeth_l3_dev_route_store(struct qeth_card *card,
 	} else if (!strcmp(tmp, "multicast_router")) {
 		route->type = MULTICAST_ROUTER;
 	} else {
-		PRINT_WARN("Invalid routing type '%s'.\n", tmp);
 		return -EINVAL;
 	}
 	if (((card->state == CARD_STATE_SOFTSETUP) ||
@@ -137,9 +136,6 @@ static ssize_t qeth_l3_dev_route6_store(struct device *dev,
 		return -EINVAL;
 
 	if (!qeth_is_supported(card, IPA_IPV6)) {
-		PRINT_WARN("IPv6 not supported for interface %s.\n"
-			   "Routing status no changed.\n",
-			   QETH_CARD_IFNAME(card));
 		return -ENOTSUPP;
 	}
 
@@ -179,7 +175,6 @@ static ssize_t qeth_l3_dev_fake_broadcast_store(struct device *dev,
 	if ((i == 0) || (i == 1))
 		card->options.fake_broadcast = i;
 	else {
-		PRINT_WARN("fake_broadcast: write 0 or 1 to this file!\n");
 		return -EINVAL;
 	}
 	return count;
@@ -220,7 +215,6 @@ static ssize_t qeth_l3_dev_broadcast_mode_store(struct device *dev,
 
 	if (!((card->info.link_type == QETH_LINK_TYPE_HSTR) ||
 	      (card->info.link_type == QETH_LINK_TYPE_LANE_TR))) {
-		PRINT_WARN("Device is not a tokenring device!\n");
 		return -EINVAL;
 	}
 
@@ -233,8 +227,6 @@ static ssize_t qeth_l3_dev_broadcast_mode_store(struct device *dev,
 		card->options.broadcast_mode = QETH_TR_BROADCAST_ALLRINGS;
 		return count;
 	} else {
-		PRINT_WARN("broadcast_mode: invalid mode %s!\n",
-			   tmp);
 		return -EINVAL;
 	}
 	return count;
@@ -275,7 +267,6 @@ static ssize_t qeth_l3_dev_canonical_macaddr_store(struct device *dev,
 
 	if (!((card->info.link_type == QETH_LINK_TYPE_HSTR) ||
 	      (card->info.link_type == QETH_LINK_TYPE_LANE_TR))) {
-		PRINT_WARN("Device is not a tokenring device!\n");
 		return -EINVAL;
 	}
 
@@ -285,7 +276,6 @@ static ssize_t qeth_l3_dev_canonical_macaddr_store(struct device *dev,
 			QETH_TR_MACADDR_CANONICAL :
 			QETH_TR_MACADDR_NONCANONICAL;
 	else {
-		PRINT_WARN("canonical_macaddr: write 0 or 1 to this file!\n");
 		return -EINVAL;
 	}
 	return count;
@@ -327,7 +317,6 @@ static ssize_t qeth_l3_dev_checksum_store(struct device *dev,
 	else if (!strcmp(tmp, "no_checksumming"))
 		card->options.checksum_type = NO_CHECKSUMMING;
 	else {
-		PRINT_WARN("Unknown checksumming type '%s'\n", tmp);
 		return -EINVAL;
 	}
 	return count;
@@ -382,8 +371,6 @@ static ssize_t qeth_l3_dev_ipato_enable_store(struct device *dev,
 	} else if (!strcmp(tmp, "0")) {
 		card->ipato.enabled = 0;
 	} else {
-		PRINT_WARN("ipato_enable: write 0, 1 or 'toggle' to "
-			   "this file\n");
 		return -EINVAL;
 	}
 	return count;
@@ -422,8 +409,6 @@ static ssize_t qeth_l3_dev_ipato_invert4_store(struct device *dev,
 	} else if (!strcmp(tmp, "0")) {
 		card->ipato.invert4 = 0;
 	} else {
-		PRINT_WARN("ipato_invert4: write 0, 1 or 'toggle' to "
-			   "this file\n");
 		return -EINVAL;
 	}
 	return count;
@@ -486,13 +471,10 @@ static int qeth_l3_parse_ipatoe(const char *buf, enum qeth_prot_versions proto,
 	/* get address string */
 	end = strchr(start, '/');
 	if (!end || (end - start >= 40)) {
-		PRINT_WARN("Invalid format for ipato_addx/delx. "
-			   "Use <ip addr>/<mask bits>\n");
 		return -EINVAL;
 	}
 	strncpy(buffer, start, end - start);
 	if (qeth_l3_string_to_ipaddr(buffer, proto, addr)) {
-		PRINT_WARN("Invalid IP address format!\n");
 		return -EINVAL;
 	}
 	start = end + 1;
@@ -500,7 +482,6 @@ static int qeth_l3_parse_ipatoe(const char *buf, enum qeth_prot_versions proto,
 	if (!strlen(start) ||
 	    (tmp == start) ||
 	    (*mask_bits > ((proto == QETH_PROT_IPV4) ? 32 : 128))) {
-		PRINT_WARN("Invalid mask bits for ipato_addx/delx !\n");
 		return -EINVAL;
 	}
 	return 0;
@@ -520,7 +501,6 @@ static ssize_t qeth_l3_dev_ipato_add_store(const char *buf, size_t count,
 
 	ipatoe = kzalloc(sizeof(struct qeth_ipato_entry), GFP_KERNEL);
 	if (!ipatoe) {
-		PRINT_WARN("No memory to allocate ipato entry\n");
 		return -ENOMEM;
 	}
 	ipatoe->proto = proto;
@@ -609,8 +589,6 @@ static ssize_t qeth_l3_dev_ipato_invert6_store(struct device *dev,
 	} else if (!strcmp(tmp, "0")) {
 		card->ipato.invert6 = 0;
 	} else {
-		PRINT_WARN("ipato_invert6: write 0, 1 or 'toggle' to "
-			   "this file\n");
 		return -EINVAL;
 	}
 	return count;
@@ -724,7 +702,6 @@ static int qeth_l3_parse_vipae(const char *buf, enum qeth_prot_versions proto,
 		 u8 *addr)
 {
 	if (qeth_l3_string_to_ipaddr(buf, proto, addr)) {
-		PRINT_WARN("Invalid IP address format!\n");
 		return -EINVAL;
 	}
 	return 0;
@@ -891,7 +868,6 @@ static int qeth_l3_parse_rxipe(const char *buf, enum qeth_prot_versions proto,
 		 u8 *addr)
 {
 	if (qeth_l3_string_to_ipaddr(buf, proto, addr)) {
-		PRINT_WARN("Invalid IP address format!\n");
 		return -EINVAL;
 	}
 	return 0;
diff --git a/include/linux/virtio_net.h b/include/linux/virtio_net.h
index 9405aa6..38c0571 100644
--- a/include/linux/virtio_net.h
+++ b/include/linux/virtio_net.h
@@ -38,7 +38,7 @@ struct virtio_net_hdr
 #define VIRTIO_NET_HDR_GSO_ECN		0x80	// TCP has ECN set
 	__u8 gso_type;
 	__u16 hdr_len;		/* Ethernet + IP + tcp/udp hdrs */
-	__u16 gso_size;		/* Bytes to append to gso_hdr_len per frame */
+	__u16 gso_size;		/* Bytes to append to hdr_len per frame */
 	__u16 csum_start;	/* Position to start checksumming from */
 	__u16 csum_offset;	/* Offset after that to place checksum */
 };
