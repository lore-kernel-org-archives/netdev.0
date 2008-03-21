From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 7/9] e1000: remove irq_sem
Date: Fri, 21 Mar 2008 11:06:58 -0700
Message-ID: <20080321180658.24164.18376.stgit@localhost.localdomain>
References: <20080321180625.24164.46137.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20080321180625.24164.46137.stgit@localhost.localdomain>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

irq_sem was just a hack to prevent interrupts from being enabled
unexpectedly in deep call paths.  Simply finding those call paths and
fixing them by hand results in a driver that behaves as we expect and
doesn't need the atomic at all.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000.h      |    1 -
 drivers/net/e1000/e1000_main.c |   41 +++++++++++++++-------------------------
 2 files changed, 15 insertions(+), 27 deletions(-)

diff --git a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
index d73a6c1..a05aa51 100644
--- a/drivers/net/e1000/e1000.h
+++ b/drivers/net/e1000/e1000.h
@@ -249,7 +249,6 @@ struct e1000_adapter {
 #ifdef CONFIG_E1000_NAPI
 	spinlock_t tx_queue_lock;
 #endif
-	atomic_t irq_sem;
 	unsigned int total_tx_bytes;
 	unsigned int total_tx_packets;
 	unsigned int total_rx_bytes;
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 37c4655..757d02f 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -347,7 +347,6 @@ static void e1000_free_irq(struct e1000_adapter *adapter)
 static void
 e1000_irq_disable(struct e1000_adapter *adapter)
 {
-	atomic_inc(&adapter->irq_sem);
 	E1000_WRITE_REG(&adapter->hw, IMC, ~0);
 	E1000_WRITE_FLUSH(&adapter->hw);
 	synchronize_irq(adapter->pdev->irq);
@@ -361,10 +360,8 @@ e1000_irq_disable(struct e1000_adapter *adapter)
 static void
 e1000_irq_enable(struct e1000_adapter *adapter)
 {
-	if (likely(atomic_dec_and_test(&adapter->irq_sem))) {
-		E1000_WRITE_REG(&adapter->hw, IMS, IMS_ENABLE_MASK);
-		E1000_WRITE_FLUSH(&adapter->hw);
-	}
+	E1000_WRITE_REG(&adapter->hw, IMS, IMS_ENABLE_MASK);
+	E1000_WRITE_FLUSH(&adapter->hw);
 }
 
 static void
@@ -638,7 +635,6 @@ e1000_down(struct e1000_adapter *adapter)
 
 #ifdef CONFIG_E1000_NAPI
 	napi_disable(&adapter->napi);
-	atomic_set(&adapter->irq_sem, 0);
 #endif
 	e1000_irq_disable(adapter);
 
@@ -1396,7 +1392,6 @@ e1000_sw_init(struct e1000_adapter *adapter)
 #endif
 
 	/* Explicitly disable IRQ since the NIC can be in any state. */
-	atomic_set(&adapter->irq_sem, 0);
 	e1000_irq_disable(adapter);
 
 	spin_lock_init(&adapter->stats_lock);
@@ -3836,11 +3831,8 @@ e1000_intr_msi(int irq, void *data)
 #endif
 	uint32_t icr = E1000_READ_REG(hw, ICR);
 
-#ifdef CONFIG_E1000_NAPI
-	/* read ICR disables interrupts using IAM, so keep up with our
-	 * enable/disable accounting */
-	atomic_inc(&adapter->irq_sem);
-#endif
+	/* in NAPI mode read ICR disables interrupts using IAM */
+
 	if (icr & (E1000_ICR_RXSEQ | E1000_ICR_LSC)) {
 		hw->get_link_status = 1;
 		/* 80003ES2LAN workaround-- For packet buffer work-around on
@@ -3910,12 +3902,8 @@ e1000_intr(int irq, void *data)
 	             !(icr & E1000_ICR_INT_ASSERTED)))
 		return IRQ_NONE;
 
-	/* Interrupt Auto-Mask...upon reading ICR,
-	 * interrupts are masked.  No need for the
-	 * IMC write, but it does mean we should
-	 * account for it ASAP. */
-	if (likely(hw->mac_type >= e1000_82571))
-		atomic_inc(&adapter->irq_sem);
+	/* Interrupt Auto-Mask...upon reading ICR, interrupts are masked.  No
+	 * need for the IMC write */
 #endif
 
 	if (unlikely(icr & (E1000_ICR_RXSEQ | E1000_ICR_LSC))) {
@@ -3939,7 +3927,6 @@ e1000_intr(int irq, void *data)
 #ifdef CONFIG_E1000_NAPI
 	if (unlikely(hw->mac_type < e1000_82571)) {
 		/* disable interrupts, without the synchronize_irq bit */
-		atomic_inc(&adapter->irq_sem);
 		E1000_WRITE_REG(hw, IMC, ~0);
 		E1000_WRITE_FLUSH(hw);
 	}
@@ -3964,10 +3951,8 @@ e1000_intr(int irq, void *data)
 	 * in dead lock. Writing IMC forces 82547 into
 	 * de-assertion state.
 	 */
-	if (hw->mac_type == e1000_82547 || hw->mac_type == e1000_82547_rev_2) {
-		atomic_inc(&adapter->irq_sem);
+	if (hw->mac_type == e1000_82547 || hw->mac_type == e1000_82547_rev_2)
 		E1000_WRITE_REG(hw, IMC, ~0);
-	}
 
 	adapter->total_tx_bytes = 0;
 	adapter->total_rx_bytes = 0;
@@ -5001,7 +4986,8 @@ e1000_vlan_rx_register(struct net_device *netdev, struct vlan_group *grp)
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	uint32_t ctrl, rctl;
 
-	e1000_irq_disable(adapter);
+	if (!test_bit(__E1000_DOWN, &adapter->flags))
+		e1000_irq_disable(adapter);
 	adapter->vlgrp = grp;
 
 	if (grp) {
@@ -5038,7 +5024,8 @@ e1000_vlan_rx_register(struct net_device *netdev, struct vlan_group *grp)
 		}
 	}
 
-	e1000_irq_enable(adapter);
+	if (!test_bit(__E1000_DOWN, &adapter->flags))
+		e1000_irq_enable(adapter);
 }
 
 static void
@@ -5064,9 +5051,11 @@ e1000_vlan_rx_kill_vid(struct net_device *netdev, uint16_t vid)
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	uint32_t vfta, index;
 
-	e1000_irq_disable(adapter);
+	if (!test_bit(__E1000_DOWN, &adapter->flags))
+		e1000_irq_disable(adapter);
 	vlan_group_set_device(adapter->vlgrp, vid, NULL);
-	e1000_irq_enable(adapter);
+	if (!test_bit(__E1000_DOWN, &adapter->flags))
+		e1000_irq_enable(adapter);
 
 	if ((adapter->hw.mng_cookie.status &
 	     E1000_MNG_DHCP_COOKIE_STATUS_VLAN_SUPPORT) &&


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
