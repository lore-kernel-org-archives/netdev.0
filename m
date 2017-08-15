From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next 1/4] liquidio: moved liquidio_msix_intr_handler to
 lio_core.c
Date: Tue, 15 Aug 2017 12:46:05 -0700
Message-ID: <20170815194605.GA2204@felix-thinkpad.cavium.com>
References: <20170815194515.GA2188@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        intiyaz.basha@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0053.outbound.protection.outlook.com ([104.47.38.53]:23478
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752031AbdHOTqL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 15 Aug 2017 15:46:11 -0400
Content-Disposition: inline
In-Reply-To: <20170815194515.GA2188@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Intiyaz Basha <intiyaz.basha@cavium.com>

Moving common liquidio_msix_intr_handler to lio_core.c

Signed-off-by: Intiyaz Basha <intiyaz.basha@cavium.com>
Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@cavium.com>
Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_core.c    | 41 ++++++++++++++++++++
 drivers/net/ethernet/cavium/liquidio/lio_main.c    | 43 ---------------------
 drivers/net/ethernet/cavium/liquidio/lio_vf_main.c | 45 ----------------------
 drivers/net/ethernet/cavium/liquidio/octeon_main.h |  6 +++
 .../net/ethernet/cavium/liquidio/octeon_network.h  |  3 ++
 5 files changed, 50 insertions(+), 88 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_core.c b/drivers/net/ethernet/cavium/liquidio/lio_core.c
index d20d0eb..03746d8 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_core.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_core.c
@@ -788,3 +788,44 @@ int liquidio_setup_io_queues(struct octeon_device *octeon_dev, int ifidx)
 
 	return 0;
 }
+
+static
+int liquidio_schedule_msix_droq_pkt_handler(struct octeon_droq *droq, u64 ret)
+{
+	struct octeon_device *oct = droq->oct_dev;
+	struct octeon_device_priv *oct_priv =
+	    (struct octeon_device_priv *)oct->priv;
+
+	if (droq->ops.poll_mode) {
+		droq->ops.napi_fn(droq);
+	} else {
+		if (ret & MSIX_PO_INT) {
+			if (OCTEON_CN23XX_VF(oct))
+				dev_err(&oct->pci_dev->dev,
+					"should not come here should not get rx when poll mode = 0 for vf\n");
+			tasklet_schedule(&oct_priv->droq_tasklet);
+			return 1;
+		}
+		/* this will be flushed periodically by check iq db */
+		if (ret & MSIX_PI_INT)
+			return 0;
+	}
+
+	return 0;
+}
+
+irqreturn_t
+liquidio_msix_intr_handler(int irq __attribute__((unused)), void *dev)
+{
+	struct octeon_ioq_vector *ioq_vector = (struct octeon_ioq_vector *)dev;
+	struct octeon_device *oct = ioq_vector->oct_dev;
+	struct octeon_droq *droq = oct->droq[ioq_vector->droq_index];
+	u64 ret;
+
+	ret = oct->fn_list.msix_interrupt_handler(ioq_vector);
+
+	if (ret & MSIX_PO_INT || ret & MSIX_PI_INT)
+		liquidio_schedule_msix_droq_pkt_handler(droq, ret);
+
+	return IRQ_HANDLED;
+}
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index 38b7ea5..045d37d 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -175,12 +175,6 @@ struct handshake {
 	int started_ok;
 };
 
-struct octeon_device_priv {
-	/** Tasklet structures for this device. */
-	struct tasklet_struct droq_tasklet;
-	unsigned long napi_mask;
-};
-
 #ifdef CONFIG_PCI_IOV
 static int liquidio_enable_sriov(struct pci_dev *dev, int num_vfs);
 #endif
@@ -907,27 +901,6 @@ static inline void update_link_status(struct net_device *netdev,
 	}
 }
 
-static
-int liquidio_schedule_msix_droq_pkt_handler(struct octeon_droq *droq, u64 ret)
-{
-	struct octeon_device *oct = droq->oct_dev;
-	struct octeon_device_priv *oct_priv =
-	    (struct octeon_device_priv *)oct->priv;
-
-	if (droq->ops.poll_mode) {
-		droq->ops.napi_fn(droq);
-	} else {
-		if (ret & MSIX_PO_INT) {
-			tasklet_schedule(&oct_priv->droq_tasklet);
-			return 1;
-		}
-		/* this will be flushed periodically by check iq db */
-		if (ret & MSIX_PI_INT)
-			return 0;
-	}
-	return 0;
-}
-
 /**
  * \brief Droq packet processor sceduler
  * @param oct octeon device
@@ -957,22 +930,6 @@ static void liquidio_schedule_droq_pkt_handlers(struct octeon_device *oct)
 	}
 }
 
-static irqreturn_t
-liquidio_msix_intr_handler(int irq __attribute__((unused)), void *dev)
-{
-	u64 ret;
-	struct octeon_ioq_vector *ioq_vector = (struct octeon_ioq_vector *)dev;
-	struct octeon_device *oct = ioq_vector->oct_dev;
-	struct octeon_droq *droq = oct->droq[ioq_vector->droq_index];
-
-	ret = oct->fn_list.msix_interrupt_handler(ioq_vector);
-
-	if ((ret & MSIX_PO_INT) || (ret & MSIX_PI_INT))
-		liquidio_schedule_msix_droq_pkt_handler(droq, ret);
-
-	return IRQ_HANDLED;
-}
-
 /**
  * \brief Interrupt handler for octeon
  * @param irq unused
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
index 2fc2da3..688b438 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
@@ -107,12 +107,6 @@ struct octnic_gather {
 	dma_addr_t sg_dma_ptr;
 };
 
-struct octeon_device_priv {
-	/* Tasklet structures for this device. */
-	struct tasklet_struct droq_tasklet;
-	unsigned long napi_mask;
-};
-
 static int
 liquidio_vf_probe(struct pci_dev *pdev, const struct pci_device_id *ent);
 static void liquidio_vf_remove(struct pci_dev *pdev);
@@ -648,45 +642,6 @@ static void update_link_status(struct net_device *netdev,
 	}
 }
 
-static
-int liquidio_schedule_msix_droq_pkt_handler(struct octeon_droq *droq, u64 ret)
-{
-	struct octeon_device *oct = droq->oct_dev;
-	struct octeon_device_priv *oct_priv =
-	    (struct octeon_device_priv *)oct->priv;
-
-	if (droq->ops.poll_mode) {
-		droq->ops.napi_fn(droq);
-	} else {
-		if (ret & MSIX_PO_INT) {
-			dev_err(&oct->pci_dev->dev,
-				"should not come here should not get rx when poll mode = 0 for vf\n");
-			tasklet_schedule(&oct_priv->droq_tasklet);
-			return 1;
-		}
-		/* this will be flushed periodically by check iq db */
-		if (ret & MSIX_PI_INT)
-			return 0;
-	}
-	return 0;
-}
-
-static irqreturn_t
-liquidio_msix_intr_handler(int irq __attribute__((unused)), void *dev)
-{
-	struct octeon_ioq_vector *ioq_vector = (struct octeon_ioq_vector *)dev;
-	struct octeon_device *oct = ioq_vector->oct_dev;
-	struct octeon_droq *droq = oct->droq[ioq_vector->droq_index];
-	u64 ret;
-
-	ret = oct->fn_list.msix_interrupt_handler(ioq_vector);
-
-	if ((ret & MSIX_PO_INT) || (ret & MSIX_PI_INT))
-		liquidio_schedule_msix_droq_pkt_handler(droq, ret);
-
-	return IRQ_HANDLED;
-}
-
 /**
  * \brief Setup interrupt for octeon device
  * @param oct octeon device
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_main.h b/drivers/net/ethernet/cavium/liquidio/octeon_main.h
index 7ccffbb..32ef3a7 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_main.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_main.h
@@ -35,6 +35,12 @@
 
 #define DRV_NAME "LiquidIO"
 
+struct octeon_device_priv {
+	/** Tasklet structures for this device. */
+	struct tasklet_struct droq_tasklet;
+	unsigned long napi_mask;
+};
+
 /** This structure is used by NIC driver to store information required
  * to free the sk_buff when the packet has been fetched by Octeon.
  * Bytes offset below assume worst-case of a 64-bit system.
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_network.h b/drivers/net/ethernet/cavium/liquidio/octeon_network.h
index d4b3930..7454d71 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_network.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_network.h
@@ -169,6 +169,9 @@ void liquidio_link_ctrl_cmd_completion(void *nctrl_ptr);
 
 int liquidio_setup_io_queues(struct octeon_device *octeon_dev, int ifidx);
 
+irqreturn_t liquidio_msix_intr_handler(int irq __attribute__((unused)),
+				       void *dev);
+
 /**
  * \brief Register ethtool operations
  * @param netdev    pointer to network device
-- 
2.9.0
