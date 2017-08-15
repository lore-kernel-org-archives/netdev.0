From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next 2/4] liquidio: moved liquidio_legacy_intr_handler to
 lio_core.c
Date: Tue, 15 Aug 2017 12:46:11 -0700
Message-ID: <20170815194611.GA2213@felix-thinkpad.cavium.com>
References: <20170815194515.GA2188@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        intiyaz.basha@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0064.outbound.protection.outlook.com ([104.47.40.64]:56240
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752031AbdHOTqO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 15 Aug 2017 15:46:14 -0400
Content-Disposition: inline
In-Reply-To: <20170815194515.GA2188@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Intiyaz Basha <intiyaz.basha@cavium.com>

Moving liquidio_legacy_intr_handler to lio_core.c

Signed-off-by: Intiyaz Basha <intiyaz.basha@cavium.com>
Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@cavium.com>
Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_core.c    | 55 +++++++++++++++++++++
 drivers/net/ethernet/cavium/liquidio/lio_main.c    | 56 ----------------------
 .../net/ethernet/cavium/liquidio/octeon_network.h  |  2 +
 3 files changed, 57 insertions(+), 56 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_core.c b/drivers/net/ethernet/cavium/liquidio/lio_core.c
index 03746d8..5c5f957 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_core.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_core.c
@@ -829,3 +829,58 @@ liquidio_msix_intr_handler(int irq __attribute__((unused)), void *dev)
 
 	return IRQ_HANDLED;
 }
+
+/**
+ * \brief Droq packet processor sceduler
+ * @param oct octeon device
+ */
+static void liquidio_schedule_droq_pkt_handlers(struct octeon_device *oct)
+{
+	struct octeon_device_priv *oct_priv =
+		(struct octeon_device_priv *)oct->priv;
+	struct octeon_droq *droq;
+	u64 oq_no;
+
+	if (oct->int_status & OCT_DEV_INTR_PKT_DATA) {
+		for (oq_no = 0; oq_no < MAX_OCTEON_OUTPUT_QUEUES(oct);
+		     oq_no++) {
+			if (!(oct->droq_intr & BIT_ULL(oq_no)))
+				continue;
+
+			droq = oct->droq[oq_no];
+
+			if (droq->ops.poll_mode) {
+				droq->ops.napi_fn(droq);
+				oct_priv->napi_mask |= (1 << oq_no);
+			} else {
+				tasklet_schedule(&oct_priv->droq_tasklet);
+			}
+		}
+	}
+}
+
+/**
+ * \brief Interrupt handler for octeon
+ * @param irq unused
+ * @param dev octeon device
+ */
+irqreturn_t liquidio_legacy_intr_handler(int irq __attribute__((unused)),
+					 void *dev)
+{
+	struct octeon_device *oct = (struct octeon_device *)dev;
+	irqreturn_t ret;
+
+	/* Disable our interrupts for the duration of ISR */
+	oct->fn_list.disable_interrupt(oct, OCTEON_ALL_INTR);
+
+	ret = oct->fn_list.process_interrupt_regs(oct);
+
+	if (ret == IRQ_HANDLED)
+		liquidio_schedule_droq_pkt_handlers(oct);
+
+	/* Re-enable our interrupts  */
+	if (!(atomic_read(&oct->status) == OCT_DEV_IN_RESET))
+		oct->fn_list.enable_interrupt(oct, OCTEON_ALL_INTR);
+
+	return ret;
+}
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index 045d37d..80a58b9 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -902,62 +902,6 @@ static inline void update_link_status(struct net_device *netdev,
 }
 
 /**
- * \brief Droq packet processor sceduler
- * @param oct octeon device
- */
-static void liquidio_schedule_droq_pkt_handlers(struct octeon_device *oct)
-{
-	struct octeon_device_priv *oct_priv =
-		(struct octeon_device_priv *)oct->priv;
-	u64 oq_no;
-	struct octeon_droq *droq;
-
-	if (oct->int_status & OCT_DEV_INTR_PKT_DATA) {
-		for (oq_no = 0; oq_no < MAX_OCTEON_OUTPUT_QUEUES(oct);
-		     oq_no++) {
-			if (!(oct->droq_intr & BIT_ULL(oq_no)))
-				continue;
-
-			droq = oct->droq[oq_no];
-
-			if (droq->ops.poll_mode) {
-				droq->ops.napi_fn(droq);
-				oct_priv->napi_mask |= (1 << oq_no);
-			} else {
-				tasklet_schedule(&oct_priv->droq_tasklet);
-			}
-		}
-	}
-}
-
-/**
- * \brief Interrupt handler for octeon
- * @param irq unused
- * @param dev octeon device
- */
-static
-irqreturn_t liquidio_legacy_intr_handler(int irq __attribute__((unused)),
-					 void *dev)
-{
-	struct octeon_device *oct = (struct octeon_device *)dev;
-	irqreturn_t ret;
-
-	/* Disable our interrupts for the duration of ISR */
-	oct->fn_list.disable_interrupt(oct, OCTEON_ALL_INTR);
-
-	ret = oct->fn_list.process_interrupt_regs(oct);
-
-	if (ret == IRQ_HANDLED)
-		liquidio_schedule_droq_pkt_handlers(oct);
-
-	/* Re-enable our interrupts  */
-	if (!(atomic_read(&oct->status) == OCT_DEV_IN_RESET))
-		oct->fn_list.enable_interrupt(oct, OCTEON_ALL_INTR);
-
-	return ret;
-}
-
-/**
  * \brief Setup interrupt for octeon device
  * @param oct octeon device
  *
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_network.h b/drivers/net/ethernet/cavium/liquidio/octeon_network.h
index 7454d71..de5eecb 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_network.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_network.h
@@ -172,6 +172,8 @@ int liquidio_setup_io_queues(struct octeon_device *octeon_dev, int ifidx);
 irqreturn_t liquidio_msix_intr_handler(int irq __attribute__((unused)),
 				       void *dev);
 
+irqreturn_t liquidio_legacy_intr_handler(int irq __attribute__((unused)),
+					 void *dev);
 /**
  * \brief Register ethtool operations
  * @param netdev    pointer to network device
-- 
2.9.0
