From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH net-next 6/10] cxgb3: disable high freq non-data interrupts
Date: Fri, 13 Mar 2009 00:14:09 -0700
Message-ID: <20090313071409.21994.98644.stgit@speedy5>
References: <20090313071343.21994.85719.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:27599 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754103AbZCMHOM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2009 03:14:12 -0400
In-Reply-To: <20090313071343.21994.85719.stgit@speedy5>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>

Under RX pressure, The HW might generate a high load of interrupts
to signal mac fifo or free lists overflow.
Disable the interrupts, and poll the relevant status bits
to maintain stats.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/cxgb3_main.c |   50 ++++++++++++++++++++++++++++++++++++++++
 drivers/net/cxgb3/regs.h       |    8 ++++++
 drivers/net/cxgb3/sge.c        |    3 ++
 drivers/net/cxgb3/t3_hw.c      |   30 +++++++++++++++++++++---
 4 files changed, 86 insertions(+), 5 deletions(-)

diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index c32f514..9ff0452 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -2471,6 +2471,8 @@ static void t3_adap_check_task(struct work_struct *work)
 	struct adapter *adapter = container_of(work, struct adapter,
 					       adap_check_task.work);
 	const struct adapter_params *p = &adapter->params;
+	int port;
+	unsigned int v, status, reset;
 
 	adapter->check_task_cnt++;
 
@@ -2489,6 +2491,54 @@ static void t3_adap_check_task(struct work_struct *work)
 	if (p->rev == T3_REV_B2)
 		check_t3b2_mac(adapter);
 
+	/*
+	 * Scan the XGMAC's to check for various conditions which we want to
+	 * monitor in a periodic polling manner rather than via an interrupt
+	 * condition.  This is used for conditions which would otherwise flood
+	 * the system with interrupts and we only really need to know that the
+	 * conditions are "happening" ...  For each condition we count the
+	 * detection of the condition and reset it for the next polling loop.
+	 */
+	for_each_port(adapter, port) {
+		struct cmac *mac =  &adap2pinfo(adapter, port)->mac;
+		u32 cause;
+
+		cause = t3_read_reg(adapter, A_XGM_INT_CAUSE + mac->offset);
+		reset = 0;
+		if (cause & F_RXFIFO_OVERFLOW) {
+			mac->stats.rx_fifo_ovfl++;
+			reset |= F_RXFIFO_OVERFLOW;
+		}
+
+		t3_write_reg(adapter, A_XGM_INT_CAUSE + mac->offset, reset);
+	}
+
+	/*
+	 * We do the same as above for FL_EMPTY interrupts.
+	 */
+	status = t3_read_reg(adapter, A_SG_INT_CAUSE);
+	reset = 0;
+
+	if (status & F_FLEMPTY) {
+		struct sge_qset *qs = &adapter->sge.qs[0];
+		int i = 0;
+
+		reset |= F_FLEMPTY;
+
+		v = (t3_read_reg(adapter, A_SG_RSPQ_FL_STATUS) >> S_FL0EMPTY) &
+		    0xffff;
+
+		while (v) {
+			qs->fl[i].empty += (v & 1);
+			if (i)
+				qs++;
+			i ^= 1;
+			v >>= 1;
+		}
+	}
+
+	t3_write_reg(adapter, A_SG_INT_CAUSE, reset);
+
 	/* Schedule the next check update if any port is active. */
 	spin_lock_irq(&adapter->work_lock);
 	if (adapter->open_device_map & PORT_MASK)
diff --git a/drivers/net/cxgb3/regs.h b/drivers/net/cxgb3/regs.h
index a035d5c..aa08550 100644
--- a/drivers/net/cxgb3/regs.h
+++ b/drivers/net/cxgb3/regs.h
@@ -170,6 +170,10 @@
 
 #define S_RSPQ0DISABLED    8
 
+#define S_FL0EMPTY    16
+#define V_FL0EMPTY(x) ((x) << S_FL0EMPTY)
+#define F_FL0EMPTY    V_FL0EMPTY(1U)
+
 #define A_SG_EGR_RCQ_DRB_THRSH 0x54
 
 #define S_HIRCQDRBTHRSH    16
@@ -258,6 +262,10 @@
 #define V_RSPQCREDITOVERFOW(x) ((x) << S_RSPQCREDITOVERFOW)
 #define F_RSPQCREDITOVERFOW    V_RSPQCREDITOVERFOW(1U)
 
+#define S_FLEMPTY    1
+#define V_FLEMPTY(x) ((x) << S_FLEMPTY)
+#define F_FLEMPTY    V_FLEMPTY(1U)
+
 #define A_SG_INT_ENABLE 0x60
 
 #define A_SG_CMDQ_CREDIT_TH 0x64
diff --git a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
index 7d779d1..a7555cb 100644
--- a/drivers/net/cxgb3/sge.c
+++ b/drivers/net/cxgb3/sge.c
@@ -2725,7 +2725,8 @@ irq_handler_t t3_intr_handler(struct adapter *adap, int polling)
  */
 void t3_sge_err_intr_handler(struct adapter *adapter)
 {
-	unsigned int v, status = t3_read_reg(adapter, A_SG_INT_CAUSE);
+	unsigned int v, status = t3_read_reg(adapter, A_SG_INT_CAUSE) &
+				 ~F_FLEMPTY;
 
 	if (status & SGE_PARERR)
 		CH_ALERT(adapter, "SGE parity error (0x%x)\n",
diff --git a/drivers/net/cxgb3/t3_hw.c b/drivers/net/cxgb3/t3_hw.c
index ac2a974..7c6ee0c 100644
--- a/drivers/net/cxgb3/t3_hw.c
+++ b/drivers/net/cxgb3/t3_hw.c
@@ -1323,7 +1323,7 @@ static int t3_handle_intr_status(struct adapter *adapter, unsigned int reg,
 #define MC7_INTR_MASK (F_AE | F_UE | F_CE | V_PE(M_PE))
 #define XGM_INTR_MASK (V_TXFIFO_PRTY_ERR(M_TXFIFO_PRTY_ERR) | \
 		       V_RXFIFO_PRTY_ERR(M_RXFIFO_PRTY_ERR) | \
-		       F_TXFIFO_UNDERRUN | F_RXFIFO_OVERFLOW)
+		       F_TXFIFO_UNDERRUN)
 #define PCIX_INTR_MASK (F_MSTDETPARERR | F_SIGTARABT | F_RCVTARABT | \
 			F_RCVMSTABT | F_SIGSYSERR | F_DETPARERR | \
 			F_SPLCMPDIS | F_UNXSPLCMP | F_RCVSPLCMPERR | \
@@ -1695,7 +1695,14 @@ static void mc7_intr_handler(struct mc7 *mc7)
 static int mac_intr_handler(struct adapter *adap, unsigned int idx)
 {
 	struct cmac *mac = &adap2pinfo(adap, idx)->mac;
-	u32 cause = t3_read_reg(adap, A_XGM_INT_CAUSE + mac->offset);
+	/*
+	 * We mask out interrupt causes for which we're not taking interrupts.
+	 * This allows us to use polling logic to monitor some of the other
+	 * conditions when taking interrupts would impose too much load on the
+	 * system.
+	 */
+	u32 cause = t3_read_reg(adap, A_XGM_INT_CAUSE + mac->offset) &
+		    ~F_RXFIFO_OVERFLOW;
 
 	if (cause & V_TXFIFO_PRTY_ERR(M_TXFIFO_PRTY_ERR)) {
 		mac->stats.tx_fifo_parity_err++;
@@ -3617,7 +3624,15 @@ int t3_prep_adapter(struct adapter *adapter, const struct adapter_info *ai,
 	adapter->params.info = ai;
 	adapter->params.nports = ai->nports;
 	adapter->params.rev = t3_read_reg(adapter, A_PL_REV);
-	adapter->params.linkpoll_period = 0;
+	/*
+	 * We used to only run the "adapter check task" once a second if
+	 * we had PHYs which didn't support interrupts (we would check
+	 * their link status once a second).  Now we check other conditions
+	 * in that routine which could potentially impose a very high
+	 * interrupt load on the system.  As such, we now always scan the
+	 * adapter state once a second ...
+	 */
+	adapter->params.linkpoll_period = 10;
 	adapter->params.stats_update_period = is_10G(adapter) ?
 	    MAC_STATS_ACCUM_SECS : (MAC_STATS_ACCUM_SECS * 10);
 	adapter->params.pci.vpd_cap_addr =
@@ -3707,7 +3722,14 @@ int t3_prep_adapter(struct adapter *adapter, const struct adapter_info *ai,
 		       ETH_ALEN);
 		init_link_config(&p->link_config, p->phy.caps);
 		p->phy.ops->power_down(&p->phy, 1);
-		if (!(p->phy.caps & SUPPORTED_IRQ))
+
+		/*
+		 * If the PHY doesn't support interrupts for link status
+		 * changes, schedule a scan of the adapter links at least
+		 * once a second.
+		 */
+		if (!(p->phy.caps & SUPPORTED_IRQ) &&
+		    adapter->params.linkpoll_period > 10)
 			adapter->params.linkpoll_period = 10;
 	}
 

