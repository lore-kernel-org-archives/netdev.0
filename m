From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: [PATCH 8/9] staging: slicoss: improve implementation concerning the
 shared memory
Date: Fri, 22 Jul 2016 23:09:18 +0200
Message-ID: <1469221759-17652-9-git-send-email-LinoSanfilippo@gmx.de>
References: <1469221759-17652-1-git-send-email-LinoSanfilippo@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
 Lino Sanfilippo <LinoSanfilippo@gmx.de>, linux-kernel@vger.kernel.org
To: liodot@gmail.com,
	charrer@alacritech.com,
	gregkh@linuxfoundation.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1469221759-17652-1-git-send-email-LinoSanfilippo@gmx.de>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

Remove the volatile specifiers of struct slic_shmem. Furthermore store the
bus addresses for the isr pointer, link status and statistics separately
and access the upper and lower word of these addresses by means of
[lower|upper]_32_bits(). By doing this take the endianness into account.

Signed-off-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>
---
 drivers/staging/slicoss/slic.h    |  18 ++-
 drivers/staging/slicoss/slicoss.c | 267 ++++++++++++++++++--------------------
 2 files changed, 136 insertions(+), 149 deletions(-)

diff --git a/drivers/staging/slicoss/slic.h b/drivers/staging/slicoss/slic.h
index 3bba82a..4ac1fd2 100644
--- a/drivers/staging/slicoss/slic.h
+++ b/drivers/staging/slicoss/slic.h
@@ -351,10 +351,17 @@ struct base_driver {
 	uint                 cardnuminuse[SLIC_MAX_CARDS];
 };
 
-struct slic_shmem {
-	volatile u32          isr;
-	volatile u32          linkstatus;
-	volatile struct slic_stats     inicstats;
+struct slic_shmem_data {
+	u32 isr;
+	u32 lnkstatus;
+	struct slic_stats stats;
+};
+
+struct slic_shmemory {
+	dma_addr_t isr_phaddr;
+	dma_addr_t lnkstatus_phaddr;
+	dma_addr_t stats_phaddr;
+	struct slic_shmem_data __iomem *shmem_data;
 };
 
 struct slic_upr {
@@ -414,9 +421,8 @@ struct adapter {
 	u32             intrregistered;
 	uint                isp_initialized;
 	uint                gennumber;
-	struct slic_shmem      *pshmem;
+	struct slic_shmemory shmem;
 	dma_addr_t          phys_shmem;
-	u32             isrcopy;
 	void __iomem *regs;
 	unsigned char               state;
 	unsigned char               linkstate;
diff --git a/drivers/staging/slicoss/slicoss.c b/drivers/staging/slicoss/slicoss.c
index 8e978e7..9a8c6f9 100644
--- a/drivers/staging/slicoss/slicoss.c
+++ b/drivers/staging/slicoss/slicoss.c
@@ -923,42 +923,34 @@ err_unlock_irq:
 
 static void slic_link_upr_complete(struct adapter *adapter, u32 isr)
 {
-	u32 linkstatus = adapter->pshmem->linkstatus;
+	struct slic_shmemory *sm = &adapter->shmem;
+	struct slic_shmem_data *sm_data = sm->shmem_data;
+	u32 lst = sm_data->lnkstatus;
 	uint linkup;
 	unsigned char linkspeed;
 	unsigned char linkduplex;
 
 	if ((isr & ISR_UPCERR) || (isr & ISR_UPCBSY)) {
-		struct slic_shmem *pshmem;
+		dma_addr_t phaddr = sm->lnkstatus_phaddr;
 
-		pshmem = (struct slic_shmem *)(unsigned long)
-			 adapter->phys_shmem;
-#if BITS_PER_LONG == 64
-		slic_upr_queue_request(adapter,
-				       SLIC_UPR_RLSR,
-				       SLIC_GET_ADDR_LOW(&pshmem->linkstatus),
-				       SLIC_GET_ADDR_HIGH(&pshmem->linkstatus),
+		slic_upr_queue_request(adapter, SLIC_UPR_RLSR,
+				       cpu_to_le32(lower_32_bits(phaddr)),
+				       cpu_to_le32(upper_32_bits(phaddr)),
 				       0, 0);
-#else
-		slic_upr_queue_request(adapter,
-				       SLIC_UPR_RLSR,
-				       (u32)&pshmem->linkstatus,
-				       SLIC_GET_ADDR_HIGH(pshmem), 0, 0);
-#endif
 		return;
 	}
 	if (adapter->state != ADAPT_UP)
 		return;
 
-	linkup = linkstatus & GIG_LINKUP ? LINK_UP : LINK_DOWN;
-	if (linkstatus & GIG_SPEED_1000)
+	linkup = lst & GIG_LINKUP ? LINK_UP : LINK_DOWN;
+	if (lst & GIG_SPEED_1000)
 		linkspeed = LINK_1000MB;
-	else if (linkstatus & GIG_SPEED_100)
+	else if (lst & GIG_SPEED_100)
 		linkspeed = LINK_100MB;
 	else
 		linkspeed = LINK_10MB;
 
-	if (linkstatus & GIG_FULLDUPLEX)
+	if (lst & GIG_FULLDUPLEX)
 		linkduplex = LINK_FULLD;
 	else
 		linkduplex = LINK_HALFD;
@@ -1010,81 +1002,77 @@ static void slic_upr_request_complete(struct adapter *adapter, u32 isr)
 	upr->next = NULL;
 	adapter->upr_busy = 0;
 	switch (upr->upr_request) {
-	case SLIC_UPR_STATS:
-		{
-			struct slic_stats *slicstats =
-			    (struct slic_stats *)&adapter->pshmem->inicstats;
-			struct slic_stats *newstats = slicstats;
-			struct slic_stats  *old = &adapter->inicstats_prev;
-			struct slicnet_stats *stst = &adapter->slic_stats;
-
-			if (isr & ISR_UPCERR) {
-				dev_err(&adapter->netdev->dev,
-					"SLIC_UPR_STATS command failed isr[%x]\n",
-					isr);
-
-				break;
-			}
-			UPDATE_STATS_GB(stst->tcp.xmit_tcp_segs,
-					newstats->xmit_tcp_segs_gb,
-					old->xmit_tcp_segs_gb);
-
-			UPDATE_STATS_GB(stst->tcp.xmit_tcp_bytes,
-					newstats->xmit_tcp_bytes_gb,
-					old->xmit_tcp_bytes_gb);
-
-			UPDATE_STATS_GB(stst->tcp.rcv_tcp_segs,
-					newstats->rcv_tcp_segs_gb,
-					old->rcv_tcp_segs_gb);
-
-			UPDATE_STATS_GB(stst->tcp.rcv_tcp_bytes,
-					newstats->rcv_tcp_bytes_gb,
-					old->rcv_tcp_bytes_gb);
-
-			UPDATE_STATS_GB(stst->iface.xmt_bytes,
-					newstats->xmit_bytes_gb,
-					old->xmit_bytes_gb);
-
-			UPDATE_STATS_GB(stst->iface.xmt_ucast,
-					newstats->xmit_unicasts_gb,
-					old->xmit_unicasts_gb);
-
-			UPDATE_STATS_GB(stst->iface.rcv_bytes,
-					newstats->rcv_bytes_gb,
-					old->rcv_bytes_gb);
-
-			UPDATE_STATS_GB(stst->iface.rcv_ucast,
-					newstats->rcv_unicasts_gb,
-					old->rcv_unicasts_gb);
-
-			UPDATE_STATS_GB(stst->iface.xmt_errors,
-					newstats->xmit_collisions_gb,
-					old->xmit_collisions_gb);
-
-			UPDATE_STATS_GB(stst->iface.xmt_errors,
-					newstats->xmit_excess_collisions_gb,
-					old->xmit_excess_collisions_gb);
-
-			UPDATE_STATS_GB(stst->iface.xmt_errors,
-					newstats->xmit_other_error_gb,
-					old->xmit_other_error_gb);
-
-			UPDATE_STATS_GB(stst->iface.rcv_errors,
-					newstats->rcv_other_error_gb,
-					old->rcv_other_error_gb);
-
-			UPDATE_STATS_GB(stst->iface.rcv_discards,
-					newstats->rcv_drops_gb,
-					old->rcv_drops_gb);
-
-			if (newstats->rcv_drops_gb > old->rcv_drops_gb) {
-				adapter->rcv_drops +=
-				    (newstats->rcv_drops_gb -
-				     old->rcv_drops_gb);
-			}
-			memcpy(old, newstats, sizeof(struct slic_stats));
+	case SLIC_UPR_STATS: {
+		struct slic_shmemory *sm = &adapter->shmem;
+		struct slic_shmem_data *sm_data = sm->shmem_data;
+		struct slic_stats *stats = &sm_data->stats;
+		struct slic_stats *old = &adapter->inicstats_prev;
+		struct slicnet_stats *stst = &adapter->slic_stats;
+
+		if (isr & ISR_UPCERR) {
+			dev_err(&adapter->netdev->dev,
+				"SLIC_UPR_STATS command failed isr[%x]\n", isr);
 			break;
 		}
+
+		UPDATE_STATS_GB(stst->tcp.xmit_tcp_segs,
+				stats->xmit_tcp_segs_gb,
+				old->xmit_tcp_segs_gb);
+
+		UPDATE_STATS_GB(stst->tcp.xmit_tcp_bytes,
+				stats->xmit_tcp_bytes_gb,
+				old->xmit_tcp_bytes_gb);
+
+		UPDATE_STATS_GB(stst->tcp.rcv_tcp_segs,
+				stats->rcv_tcp_segs_gb,
+				old->rcv_tcp_segs_gb);
+
+		UPDATE_STATS_GB(stst->tcp.rcv_tcp_bytes,
+				stats->rcv_tcp_bytes_gb,
+				old->rcv_tcp_bytes_gb);
+
+		UPDATE_STATS_GB(stst->iface.xmt_bytes,
+				stats->xmit_bytes_gb,
+				old->xmit_bytes_gb);
+
+		UPDATE_STATS_GB(stst->iface.xmt_ucast,
+				stats->xmit_unicasts_gb,
+				old->xmit_unicasts_gb);
+
+		UPDATE_STATS_GB(stst->iface.rcv_bytes,
+				stats->rcv_bytes_gb,
+				old->rcv_bytes_gb);
+
+		UPDATE_STATS_GB(stst->iface.rcv_ucast,
+				stats->rcv_unicasts_gb,
+				old->rcv_unicasts_gb);
+
+		UPDATE_STATS_GB(stst->iface.xmt_errors,
+				stats->xmit_collisions_gb,
+				old->xmit_collisions_gb);
+
+		UPDATE_STATS_GB(stst->iface.xmt_errors,
+				stats->xmit_excess_collisions_gb,
+				old->xmit_excess_collisions_gb);
+
+		UPDATE_STATS_GB(stst->iface.xmt_errors,
+				stats->xmit_other_error_gb,
+				old->xmit_other_error_gb);
+
+		UPDATE_STATS_GB(stst->iface.rcv_errors,
+				stats->rcv_other_error_gb,
+				old->rcv_other_error_gb);
+
+		UPDATE_STATS_GB(stst->iface.rcv_discards,
+				stats->rcv_drops_gb,
+				old->rcv_drops_gb);
+
+		if (stats->rcv_drops_gb > old->rcv_drops_gb)
+			adapter->rcv_drops += (stats->rcv_drops_gb -
+					       old->rcv_drops_gb);
+		memcpy_fromio(old, stats, sizeof(*stats));
+		break;
+	}
 	case SLIC_UPR_RLSR:
 		slic_link_upr_complete(adapter, isr);
 		break;
@@ -1682,26 +1670,18 @@ static u32 slic_rcvqueue_reinsert(struct adapter *adapter, struct sk_buff *skb)
 static int slic_link_event_handler(struct adapter *adapter)
 {
 	int status;
-	struct slic_shmem *pshmem;
+	struct slic_shmemory *sm = &adapter->shmem;
+	dma_addr_t phaddr = sm->lnkstatus_phaddr;
+
 
 	if (adapter->state != ADAPT_UP) {
 		/* Adapter is not operational.  Ignore.  */
 		return -ENODEV;
 	}
-
-	pshmem = (struct slic_shmem *)(unsigned long)adapter->phys_shmem;
-
-#if BITS_PER_LONG == 64
-	status = slic_upr_request(adapter,
-				  SLIC_UPR_RLSR,
-				  SLIC_GET_ADDR_LOW(&pshmem->linkstatus),
-				  SLIC_GET_ADDR_HIGH(&pshmem->linkstatus),
-				  0, 0);
-#else
+	/* no 4GB wrap guaranteed */
 	status = slic_upr_request(adapter, SLIC_UPR_RLSR,
-		(u32)&pshmem->linkstatus,	/* no 4GB wrap guaranteed */
-				  0, 0, 0);
-#endif
+				  cpu_to_le32(lower_32_bits(phaddr)),
+				  cpu_to_le32(upper_32_bits(phaddr)), 0, 0);
 	return status;
 }
 
@@ -1711,12 +1691,13 @@ static void slic_init_cleanup(struct adapter *adapter)
 		adapter->intrregistered = 0;
 		free_irq(adapter->netdev->irq, adapter->netdev);
 	}
-	if (adapter->pshmem) {
-		pci_free_consistent(adapter->pcidev,
-				    sizeof(struct slic_shmem),
-				    adapter->pshmem, adapter->phys_shmem);
-		adapter->pshmem = NULL;
-		adapter->phys_shmem = (dma_addr_t)(unsigned long)NULL;
+
+	if (adapter->shmem.shmem_data) {
+		struct slic_shmemory *sm = &adapter->shmem;
+		struct slic_shmem_data *sm_data = sm->shmem_data;
+
+		pci_free_consistent(adapter->pcidev, sizeof(*sm_data), sm_data,
+				    sm->isr_phaddr);
 	}
 
 	if (adapter->pingtimerset) {
@@ -2101,14 +2082,16 @@ static irqreturn_t slic_interrupt(int irq, void *dev_id)
 {
 	struct net_device *dev = dev_id;
 	struct adapter *adapter = netdev_priv(dev);
+	struct slic_shmemory *sm = &adapter->shmem;
+	struct slic_shmem_data *sm_data = sm->shmem_data;
 	u32 isr;
 
-	if ((adapter->pshmem) && (adapter->pshmem->isr)) {
+	if (sm_data->isr) {
 		slic_write32(adapter, SLIC_REG_ICR, ICR_INT_MASK);
 		slic_flush_write(adapter);
 
-		isr = adapter->isrcopy = adapter->pshmem->isr;
-		adapter->pshmem->isr = 0;
+		isr = sm_data->isr;
+		sm_data->isr = 0;
 		adapter->num_isrs++;
 		switch (adapter->card->state) {
 		case CARD_UP:
@@ -2124,7 +2107,6 @@ static irqreturn_t slic_interrupt(int irq, void *dev_id)
 			break;
 		}
 
-		adapter->isrcopy = 0;
 		adapter->all_reg_writes += 2;
 		adapter->isr_reg_writes++;
 		slic_write32(adapter, SLIC_REG_ISR, 0);
@@ -2243,7 +2225,8 @@ static int slic_if_init(struct adapter *adapter, unsigned long *flags)
 {
 	struct sliccard *card = adapter->card;
 	struct net_device *dev = adapter->netdev;
-	struct slic_shmem *pshmem;
+	struct slic_shmemory *sm = &adapter->shmem;
+	struct slic_shmem_data *sm_data = sm->shmem_data;
 	int rc;
 
 	/* adapter should be down at this point */
@@ -2294,21 +2277,13 @@ static int slic_if_init(struct adapter *adapter, unsigned long *flags)
 	if (!adapter->isp_initialized) {
 		unsigned long flags;
 
-		pshmem = (struct slic_shmem *)(unsigned long)
-			 adapter->phys_shmem;
-
 		spin_lock_irqsave(&adapter->bit64reglock, flags);
-
-#if BITS_PER_LONG == 64
 		slic_write32(adapter, SLIC_REG_ADDR_UPPER,
-			     SLIC_GET_ADDR_HIGH(&pshmem->isr));
+			     cpu_to_le32(upper_32_bits(sm->isr_phaddr)));
 		slic_write32(adapter, SLIC_REG_ISP,
-			     SLIC_GET_ADDR_LOW(&pshmem->isr));
-#else
-		slic_write32(adapter, SLIC_REG_ADDR_UPPER, 0);
-		slic_write32(adapter, SLIC_REG_ISP, (u32)&pshmem->isr);
-#endif
+			     cpu_to_le32(lower_32_bits(sm->isr_phaddr)));
 		spin_unlock_irqrestore(&adapter->bit64reglock, flags);
+
 		adapter->isp_initialized = 1;
 	}
 
@@ -2335,8 +2310,7 @@ static int slic_if_init(struct adapter *adapter, unsigned long *flags)
 	/*
 	 *    clear any pending events, then enable interrupts
 	 */
-	adapter->isrcopy = 0;
-	adapter->pshmem->isr = 0;
+	sm_data->isr = 0;
 	slic_write32(adapter, SLIC_REG_ISR, 0);
 	slic_write32(adapter, SLIC_REG_ICR, ICR_INT_ON);
 
@@ -2624,13 +2598,14 @@ static void slic_config_pci(struct pci_dev *pcidev)
 
 static int slic_card_init(struct sliccard *card, struct adapter *adapter)
 {
+	struct slic_shmemory *sm = &adapter->shmem;
+	struct slic_shmem_data *sm_data = sm->shmem_data;
 	struct slic_eeprom *peeprom;
 	struct oslic_eeprom *pOeeprom;
 	dma_addr_t phys_config;
 	u32 phys_configh;
 	u32 phys_configl;
 	u32 i = 0;
-	struct slic_shmem *pshmem;
 	int status;
 	uint macaddrs = card->card_size;
 	ushort eecodesize;
@@ -2671,14 +2646,12 @@ static int slic_card_init(struct sliccard *card, struct adapter *adapter)
 		slic_write32(adapter, SLIC_REG_ICR, ICR_INT_OFF);
 		slic_flush_write(adapter);
 		mdelay(1);
-		pshmem = (struct slic_shmem *)(unsigned long)
-			 adapter->phys_shmem;
 
 		spin_lock_irqsave(&adapter->bit64reglock, flags);
 		slic_write32(adapter, SLIC_REG_ADDR_UPPER,
-			     SLIC_GET_ADDR_HIGH(&pshmem->isr));
+			     cpu_to_le32(upper_32_bits(sm->isr_phaddr)));
 		slic_write32(adapter, SLIC_REG_ISP,
-			     SLIC_GET_ADDR_LOW(&pshmem->isr));
+			     cpu_to_le32(lower_32_bits(sm->isr_phaddr)));
 		spin_unlock_irqrestore(&adapter->bit64reglock, flags);
 
 		status = slic_config_get(adapter, phys_configl, phys_configh);
@@ -2689,9 +2662,9 @@ static int slic_card_init(struct sliccard *card, struct adapter *adapter)
 		}
 
 		for (;;) {
-			if (adapter->pshmem->isr) {
-				if (adapter->pshmem->isr & ISR_UPC) {
-					adapter->pshmem->isr = 0;
+			if (sm_data->isr) {
+				if (sm_data->isr & ISR_UPC) {
+					sm_data->isr = 0;
 					slic_write64(adapter, SLIC_REG_ISP, 0,
 						     0);
 					slic_write32(adapter, SLIC_REG_ISR, 0);
@@ -2701,7 +2674,7 @@ static int slic_card_init(struct sliccard *card, struct adapter *adapter)
 					break;
 				}
 
-				adapter->pshmem->isr = 0;
+				sm_data->isr = 0;
 				slic_write32(adapter, SLIC_REG_ISR, 0);
 				slic_flush_write(adapter);
 			} else {
@@ -2864,6 +2837,9 @@ static int slic_init_adapter(struct net_device *netdev,
 	ushort index;
 	struct slic_handle *pslic_handle;
 	struct adapter *adapter = netdev_priv(netdev);
+	struct slic_shmemory *sm = &adapter->shmem;
+	struct slic_shmem_data *sm_data;
+	dma_addr_t phaddr;
 
 /*	adapter->pcidev = pcidev;*/
 	adapter->vendid = pci_tbl_entry->vendor;
@@ -2898,12 +2874,17 @@ static int slic_init_adapter(struct net_device *netdev,
 		pslic_handle->next = adapter->pfree_slic_handles;
 		adapter->pfree_slic_handles = pslic_handle;
 	}
-	adapter->pshmem = pci_zalloc_consistent(adapter->pcidev,
-						sizeof(struct slic_shmem),
-						&adapter->phys_shmem);
-	if (!adapter->pshmem)
+	sm_data = pci_zalloc_consistent(adapter->pcidev, sizeof(*sm_data),
+					&phaddr);
+	if (!sm_data)
 		return -ENOMEM;
 
+	sm->shmem_data = sm_data;
+	sm->isr_phaddr = phaddr;
+	sm->lnkstatus_phaddr = phaddr + offsetof(struct slic_shmem_data,
+						 lnkstatus);
+	sm->stats_phaddr = phaddr + offsetof(struct slic_shmem_data, stats);
+
 	return 0;
 }
 
-- 
1.9.1
