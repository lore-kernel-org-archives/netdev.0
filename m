From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver fixes
Date: Wed, 20 Jun 2007 19:48:40 -0400
Message-ID: <20070620234840.GA27925@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:49411 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752751AbXFTXsl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jun 2007 19:48:41 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Please pull from 'upstream-linus' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-linus

to receive the following updates:

 drivers/net/bonding/bond_3ad.c   |    9 +--
 drivers/net/bonding/bond_main.c  |    2 +-
 drivers/net/bonding/bond_sysfs.c |    2 +-
 drivers/net/bonding/bonding.h    |    4 +-
 drivers/net/cxgb3/ael1002.c      |   10 +++-
 drivers/net/cxgb3/cxgb3_main.c   |   16 ++++-
 drivers/net/cxgb3/regs.h         |    6 ++
 drivers/net/cxgb3/sge.c          |    3 +-
 drivers/net/cxgb3/xgmac.c        |   98 +++++++++++++++++++++++++++----
 drivers/net/forcedeth.c          |    4 +-
 drivers/net/natsemi.c            |    2 +-
 drivers/net/spider_net.c         |  121 +++++++++++++++++++++++++++++++-------
 drivers/net/spider_net.h         |    8 ++-
 drivers/net/spider_net_ethtool.c |   21 +------
 drivers/s390/net/claw.c          |   13 +++--
 drivers/s390/net/netiucv.c       |   23 ++-----
 drivers/s390/net/qeth_eddp.c     |    3 +-
 drivers/s390/net/qeth_main.c     |   52 ++++++++---------
 18 files changed, 273 insertions(+), 124 deletions(-)

Cornelia Huck (1):
      s390: Use ccw_device_get_id() in qeth/claw drivers

Divy Le Ray (5):
      cxgb3 - fix skb->dev dereference
      cxgb3 - fix netpoll hanlder
      cxgb3 - Fix direct XAUI support
      cxgb3 - Stop mac RX when changing MTU
      cxgb3 - MAC watchdog update

Frank Pavlic (1):
      s390: qeth: wrong packet length in qdio header

Gregory Haskins (1):
      natsemi irq flags

Jay Vosburgh (2):
      bonding: Fix use after free in unregister path
      bonding: Fix 802.3ad no carrier on "no partner found" instance

Linas Vepstas (5):
      spidernet: null out skb pointer after its been used.
      spidernet: Cure RX ram full bug
      spidernet: Don't terminate the RX ring
      spidernet: silence the ramfull messages
      spidernet: turn off descriptor chain end interrupt.

Martin Schwidefsky (1):
      s390: netiucv inlining cleanup

Stephen Hemminger (1):
      spidernet: checksum and ethtool

Thomas Gleixner (1):
      s390: netiucv spinlock initializer cleanup

Tim Mann (1):
      forcedeth: use unicast receive mode for WoL

Ursula Braun (4):
      s390: print correct level for HiperSockets devices
      s390: qeth driver does not recover
      s390: avoid inconsistent lock state in qeth
      s390: don't call iucv_path_connect from tasklet context

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 7e03f41..f829e4a 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -2303,19 +2303,18 @@ void bond_3ad_handle_link_change(struct slave *slave, char link)
 }
 
 /*
- * set link state for bonding master: if we have an active partnered
+ * set link state for bonding master: if we have an active 
  * aggregator, we're up, if not, we're down.  Presumes that we cannot
  * have an active aggregator if there are no slaves with link up.
  *
+ * This behavior complies with IEEE 802.3 section 43.3.9.
+ *
  * Called by bond_set_carrier(). Return zero if carrier state does not
  * change, nonzero if it does.
  */
 int bond_3ad_set_carrier(struct bonding *bond)
 {
-	struct aggregator *agg;
-
-	agg = __get_active_agg(&(SLAVE_AD_INFO(bond->first_slave).aggregator));
-	if (agg && MAC_ADDRESS_COMPARE(&agg->partner_system, &null_mac_addr)) {
+	if (__get_active_agg(&(SLAVE_AD_INFO(bond->first_slave).aggregator))) {
 		if (!netif_carrier_ok(bond->dev)) {
 			netif_carrier_on(bond->dev);
 			return 1;
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 223517d..6287ffb 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4345,8 +4345,8 @@ static void bond_free_all(void)
 		bond_mc_list_destroy(bond);
 		/* Release the bonded slaves */
 		bond_release_all(bond_dev);
-		unregister_netdevice(bond_dev);
 		bond_deinit(bond_dev);
+		unregister_netdevice(bond_dev);
 	}
 
 #ifdef CONFIG_PROC_FS
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index a122baa..60cccf2 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -164,9 +164,9 @@ static ssize_t bonding_store_bonds(struct class *cls, const char *buffer, size_t
 				printk(KERN_INFO DRV_NAME
 					": %s is being deleted...\n",
 					bond->dev->name);
-				unregister_netdevice(bond->dev);
 				bond_deinit(bond->dev);
 		        	bond_destroy_sysfs_entry(bond);
+				unregister_netdevice(bond->dev);
 				rtnl_unlock();
 				goto out;
 			}
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 41aa78b..a891021 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -22,8 +22,8 @@
 #include "bond_3ad.h"
 #include "bond_alb.h"
 
-#define DRV_VERSION	"3.1.2"
-#define DRV_RELDATE	"January 20, 2007"
+#define DRV_VERSION	"3.1.3"
+#define DRV_RELDATE	"June 13, 2007"
 #define DRV_NAME	"bonding"
 #define DRV_DESCRIPTION	"Ethernet Channel Bonding Driver"
 
diff --git a/drivers/net/cxgb3/ael1002.c b/drivers/net/cxgb3/ael1002.c
index 73a41e6..ee140e6 100644
--- a/drivers/net/cxgb3/ael1002.c
+++ b/drivers/net/cxgb3/ael1002.c
@@ -219,7 +219,13 @@ static int xaui_direct_get_link_status(struct cphy *phy, int *link_ok,
 		unsigned int status;
 
 		status = t3_read_reg(phy->adapter,
-				     XGM_REG(A_XGM_SERDES_STAT0, phy->addr));
+				     XGM_REG(A_XGM_SERDES_STAT0, phy->addr)) |
+		    t3_read_reg(phy->adapter,
+				XGM_REG(A_XGM_SERDES_STAT1, phy->addr)) |
+		    t3_read_reg(phy->adapter,
+				XGM_REG(A_XGM_SERDES_STAT2, phy->addr)) |
+		    t3_read_reg(phy->adapter,
+				XGM_REG(A_XGM_SERDES_STAT3, phy->addr));
 		*link_ok = !(status & F_LOWSIG0);
 	}
 	if (speed)
@@ -247,5 +253,5 @@ static struct cphy_ops xaui_direct_ops = {
 void t3_xaui_direct_phy_prep(struct cphy *phy, struct adapter *adapter,
 			     int phy_addr, const struct mdio_ops *mdio_ops)
 {
-	cphy_init(phy, adapter, 1, &xaui_direct_ops, mdio_ops);
+	cphy_init(phy, adapter, phy_addr, &xaui_direct_ops, mdio_ops);
 }
diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index 1b20f40..d8a1f54 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -2071,10 +2071,20 @@ static void vlan_rx_register(struct net_device *dev, struct vlan_group *grp)
 static void cxgb_netpoll(struct net_device *dev)
 {
 	struct adapter *adapter = dev->priv;
-	struct sge_qset *qs = dev2qset(dev);
+	struct port_info *pi = netdev_priv(dev);
+	int qidx;
 
-	t3_intr_handler(adapter, qs->rspq.polling) (adapter->pdev->irq,
-						    adapter);
+	for (qidx = pi->first_qset; qidx < pi->first_qset + pi->nqsets; qidx++) {
+		struct sge_qset *qs = &adapter->sge.qs[qidx];
+		void *source;
+		
+		if (adapter->flags & USING_MSIX)
+			source = qs;
+		else
+			source = adapter;
+
+		t3_intr_handler(adapter, qs->rspq.polling) (0, source);
+	}
 }
 #endif
 
diff --git a/drivers/net/cxgb3/regs.h b/drivers/net/cxgb3/regs.h
index e5a5534..020859c 100644
--- a/drivers/net/cxgb3/regs.h
+++ b/drivers/net/cxgb3/regs.h
@@ -1882,6 +1882,10 @@
 #define V_COPYALLFRAMES(x) ((x) << S_COPYALLFRAMES)
 #define F_COPYALLFRAMES    V_COPYALLFRAMES(1U)
 
+#define S_DISBCAST    1
+#define V_DISBCAST(x) ((x) << S_DISBCAST)
+#define F_DISBCAST    V_DISBCAST(1U)
+
 #define A_XGM_RX_HASH_LOW 0x814
 
 #define A_XGM_RX_HASH_HIGH 0x818
@@ -2128,6 +2132,8 @@
 #define F_RESETPLL01    V_RESETPLL01(1U)
 
 #define A_XGM_SERDES_STAT0 0x8f0
+#define A_XGM_SERDES_STAT1 0x8f4
+#define A_XGM_SERDES_STAT2 0x8f8
 
 #define S_LOWSIG0    0
 #define V_LOWSIG0(x) ((x) << S_LOWSIG0)
diff --git a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
index 3666586..a60ec4d 100644
--- a/drivers/net/cxgb3/sge.c
+++ b/drivers/net/cxgb3/sge.c
@@ -1690,8 +1690,8 @@ static void rx_eth(struct adapter *adap, struct sge_rspq *rq,
 	struct port_info *pi;
 
 	skb_pull(skb, sizeof(*p) + pad);
-	skb->dev->last_rx = jiffies;
 	skb->protocol = eth_type_trans(skb, adap->port[p->iff]);
+	skb->dev->last_rx = jiffies;
 	pi = netdev_priv(skb->dev);
 	if (pi->rx_csum_offload && p->csum_valid && p->csum == 0xffff &&
 	    !p->fragment) {
@@ -2217,7 +2217,6 @@ irqreturn_t t3_sge_intr_msix_napi(int irq, void *cookie)
 	struct sge_rspq *q = &qs->rspq;
 
 	spin_lock(&q->lock);
-	BUG_ON(napi_is_scheduled(qs->netdev));
 
 	if (handle_responses(adap, q) < 0)
 		q->unhandled_irqs++;
diff --git a/drivers/net/cxgb3/xgmac.c b/drivers/net/cxgb3/xgmac.c
index a506792..b261be1 100644
--- a/drivers/net/cxgb3/xgmac.c
+++ b/drivers/net/cxgb3/xgmac.c
@@ -231,6 +231,28 @@ int t3_mac_set_num_ucast(struct cmac *mac, int n)
 	return 0;
 }
 
+static void disable_exact_filters(struct cmac *mac)
+{
+	unsigned int i, reg = mac->offset + A_XGM_RX_EXACT_MATCH_LOW_1;
+
+	for (i = 0; i < EXACT_ADDR_FILTERS; i++, reg += 8) {
+		u32 v = t3_read_reg(mac->adapter, reg);
+		t3_write_reg(mac->adapter, reg, v);
+	}
+	t3_read_reg(mac->adapter, A_XGM_RX_EXACT_MATCH_LOW_1);	/* flush */
+}
+
+static void enable_exact_filters(struct cmac *mac)
+{
+	unsigned int i, reg = mac->offset + A_XGM_RX_EXACT_MATCH_HIGH_1;
+
+	for (i = 0; i < EXACT_ADDR_FILTERS; i++, reg += 8) {
+		u32 v = t3_read_reg(mac->adapter, reg);
+		t3_write_reg(mac->adapter, reg, v);
+	}
+	t3_read_reg(mac->adapter, A_XGM_RX_EXACT_MATCH_LOW_1);	/* flush */
+}
+
 /* Calculate the RX hash filter index of an Ethernet address */
 static int hash_hw_addr(const u8 * addr)
 {
@@ -281,6 +303,14 @@ int t3_mac_set_rx_mode(struct cmac *mac, struct t3_rx_mode *rm)
 	return 0;
 }
 
+static int rx_fifo_hwm(int mtu)
+{
+	int hwm;
+
+	hwm = max(MAC_RXFIFO_SIZE - 3 * mtu, (MAC_RXFIFO_SIZE * 38) / 100);
+	return min(hwm, MAC_RXFIFO_SIZE - 8192);
+}
+
 int t3_mac_set_mtu(struct cmac *mac, unsigned int mtu)
 {
 	int hwm, lwm;
@@ -306,11 +336,38 @@ int t3_mac_set_mtu(struct cmac *mac, unsigned int mtu)
 	lwm = min(3 * (int)mtu, MAC_RXFIFO_SIZE / 4);
 
 	v = t3_read_reg(adap, A_XGM_RXFIFO_CFG + mac->offset);
+	if (adap->params.rev == T3_REV_B2 &&
+	    (t3_read_reg(adap, A_XGM_RX_CTRL + mac->offset) & F_RXEN)) {
+		disable_exact_filters(mac);
+		t3_set_reg_field(adap, A_XGM_RXFIFO_CFG + mac->offset,
+				 F_ENHASHMCAST | F_COPYALLFRAMES, F_DISBCAST);
+
+		/* drain rx FIFO */
+		if (t3_wait_op_done(adap,
+				    A_XGM_RX_MAX_PKT_SIZE_ERR_CNT +
+				    mac->offset,
+				    1 << 31, 1, 20, 5)) {
+			t3_write_reg(adap, A_XGM_RXFIFO_CFG + mac->offset, v);
+			enable_exact_filters(mac);
+			return -EIO;
+		}
+		t3_write_reg(adap, A_XGM_RX_MAX_PKT_SIZE + mac->offset, mtu);
+		enable_exact_filters(mac);
+	} else
+		t3_write_reg(adap, A_XGM_RX_MAX_PKT_SIZE + mac->offset, mtu);
+
+	/*
+	 * Adjust the PAUSE frame watermarks.  We always set the LWM, and the
+	 * HWM only if flow-control is enabled.
+	 */
+	hwm = rx_fifo_hwm(mtu);
+	lwm = min(3 * (int)mtu, MAC_RXFIFO_SIZE / 4);
 	v &= ~V_RXFIFOPAUSELWM(M_RXFIFOPAUSELWM);
 	v |= V_RXFIFOPAUSELWM(lwm / 8);
 	if (G_RXFIFOPAUSEHWM(v))
 		v = (v & ~V_RXFIFOPAUSEHWM(M_RXFIFOPAUSEHWM)) |
 		    V_RXFIFOPAUSEHWM(hwm / 8);
+
 	t3_write_reg(adap, A_XGM_RXFIFO_CFG + mac->offset, v);
 
 	/* Adjust the TX FIFO threshold based on the MTU */
@@ -329,7 +386,6 @@ int t3_mac_set_mtu(struct cmac *mac, unsigned int mtu)
 			     (hwm - lwm) * 4 / 8);
 	t3_write_reg(adap, A_XGM_TX_PAUSE_QUANTA + mac->offset,
 		     MAC_RXFIFO_SIZE * 4 * 8 / 512);
-
 	return 0;
 }
 
@@ -357,6 +413,15 @@ int t3_mac_set_speed_duplex_fc(struct cmac *mac, int speed, int duplex, int fc)
 				 V_PORTSPEED(M_PORTSPEED), val);
 	}
 
+	val = t3_read_reg(adap, A_XGM_RXFIFO_CFG + oft);
+	val &= ~V_RXFIFOPAUSEHWM(M_RXFIFOPAUSEHWM);
+	if (fc & PAUSE_TX)
+		val |= V_RXFIFOPAUSEHWM(rx_fifo_hwm(
+						t3_read_reg(adap,
+						A_XGM_RX_MAX_PKT_SIZE
+						+ oft)) / 8);
+	t3_write_reg(adap, A_XGM_RXFIFO_CFG + oft, val);
+
 	t3_set_reg_field(adap, A_XGM_TX_CFG + oft, F_TXPAUSEEN,
 			 (fc & PAUSE_RX) ? F_TXPAUSEEN : 0);
 	return 0;
@@ -436,6 +501,10 @@ int t3b2_mac_watchdog_task(struct cmac *mac)
 	unsigned int rx_xcnt;
 	int status;
 
+	status = 0;
+	tx_xcnt = 1;		/* By default tx_xcnt is making progress */
+	tx_tcnt = mac->tx_tcnt;	/* If tx_mcnt is progressing ignore tx_tcnt */
+	rx_xcnt = 1;		/* By default rx_xcnt is making progress */
 	if (tx_mcnt == mac->tx_mcnt) {
 		tx_xcnt = (G_TXSPI4SOPCNT(t3_read_reg(adap,
 						A_XGM_TX_SPI4_SOP_EOP_CNT +
@@ -446,37 +515,44 @@ int t3b2_mac_watchdog_task(struct cmac *mac)
 			tx_tcnt = (G_TXDROPCNTCH0RCVD(t3_read_reg(adap,
 						      A_TP_PIO_DATA)));
 		} else {
-			mac->toggle_cnt = 0;
-			return 0;
+			goto rxcheck;
 		}
 	} else {
 		mac->toggle_cnt = 0;
-		return 0;
+		goto rxcheck;
 	}
 
 	if (((tx_tcnt != mac->tx_tcnt) &&
 	     (tx_xcnt == 0) && (mac->tx_xcnt == 0)) ||
 	    ((mac->tx_mcnt == tx_mcnt) &&
 	     (tx_xcnt != 0) && (mac->tx_xcnt != 0))) {
-		if (mac->toggle_cnt > 4)
+		if (mac->toggle_cnt > 4) {
 			status = 2;
-		else 
+			goto out;
+		} else {
 			status = 1;
+			goto out;
+		}
 	} else {
 		mac->toggle_cnt = 0;
-		return 0;
+		goto rxcheck;
 	}
 
+rxcheck:
 	if (rx_mcnt != mac->rx_mcnt)
 		rx_xcnt = (G_TXSPI4SOPCNT(t3_read_reg(adap,
 						A_XGM_RX_SPI4_SOP_EOP_CNT +
 						mac->offset)));
-	else 
-		return 0;
+	else
+		goto out;
 
-	if (mac->rx_mcnt != s->rx_frames && rx_xcnt == 0 && mac->rx_xcnt == 0) 
+	if (mac->rx_mcnt != s->rx_frames && rx_xcnt == 0 &&
+	    mac->rx_xcnt == 0) {
 		status = 2;
-	
+		goto out;
+	}
+
+out:
 	mac->tx_tcnt = tx_tcnt;
 	mac->tx_xcnt = tx_xcnt;
 	mac->tx_mcnt = s->tx_frames;
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 32788ca..42ba1c0 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -4825,8 +4825,10 @@ static int nv_close(struct net_device *dev)
 
 	drain_ring(dev);
 
-	if (np->wolenabled)
+	if (np->wolenabled) {
+		writel(NVREG_PFF_ALWAYS|NVREG_PFF_MYADDR, base + NvRegPacketFilterFlags);
 		nv_start_rx(dev);
+	}
 
 	/* FIXME: power down nic */
 
diff --git a/drivers/net/natsemi.c b/drivers/net/natsemi.c
index 4cf0d3f..460a087 100644
--- a/drivers/net/natsemi.c
+++ b/drivers/net/natsemi.c
@@ -690,7 +690,7 @@ static ssize_t natsemi_set_dspcfg_workaround(struct device *dev,
 {
 	struct netdev_private *np = netdev_priv(to_net_dev(dev));
 	int new_setting;
-	u32 flags;
+	unsigned long flags;
 
         /* Find out the new setting */
         if (!strncmp("on", buf, count - 1) || !strncmp("1", buf, count - 1))
diff --git a/drivers/net/spider_net.c b/drivers/net/spider_net.c
index b47ad1d..7a4aa6a 100644
--- a/drivers/net/spider_net.c
+++ b/drivers/net/spider_net.c
@@ -460,13 +460,9 @@ spider_net_prepare_rx_descr(struct spider_net_card *card,
 		hwdescr->dmac_cmd_status = SPIDER_NET_DESCR_NOT_IN_USE;
 	} else {
 		hwdescr->buf_addr = buf;
-		hwdescr->next_descr_addr = 0;
 		wmb();
 		hwdescr->dmac_cmd_status = SPIDER_NET_DESCR_CARDOWNED |
 					 SPIDER_NET_DMAC_NOINTR_COMPLETE;
-
-		wmb();
-		descr->prev->hwdescr->next_descr_addr = descr->bus_addr;
 	}
 
 	return 0;
@@ -541,12 +537,16 @@ spider_net_refill_rx_chain(struct spider_net_card *card)
 static int
 spider_net_alloc_rx_skbs(struct spider_net_card *card)
 {
-	int result;
-	struct spider_net_descr_chain *chain;
+	struct spider_net_descr_chain *chain = &card->rx_chain;
+	struct spider_net_descr *start = chain->tail;
+	struct spider_net_descr *descr = start;
 
-	result = -ENOMEM;
+	/* Link up the hardware chain pointers */
+	do {
+		descr->prev->hwdescr->next_descr_addr = descr->bus_addr;
+		descr = descr->next;
+	} while (descr != start);
 
-	chain = &card->rx_chain;
 	/* Put at least one buffer into the chain. if this fails,
 	 * we've got a problem. If not, spider_net_refill_rx_chain
 	 * will do the rest at the end of this function. */
@@ -563,7 +563,7 @@ spider_net_alloc_rx_skbs(struct spider_net_card *card)
 
 error:
 	spider_net_free_rx_chain_contents(card);
-	return result;
+	return -ENOMEM;
 }
 
 /**
@@ -718,7 +718,7 @@ spider_net_prepare_tx_descr(struct spider_net_card *card,
 			SPIDER_NET_DESCR_CARDOWNED | SPIDER_NET_DMAC_NOCS;
 	spin_unlock_irqrestore(&chain->lock, flags);
 
-	if (skb->protocol == htons(ETH_P_IP) && skb->ip_summed == CHECKSUM_PARTIAL)
+	if (skb->ip_summed == CHECKSUM_PARTIAL)
 		switch (ip_hdr(skb)->protocol) {
 		case IPPROTO_TCP:
 			hwdescr->dmac_cmd_status |= SPIDER_NET_DMAC_TCP;
@@ -1051,6 +1051,66 @@ static void show_rx_chain(struct spider_net_card *card)
 #endif
 
 /**
+ * spider_net_resync_head_ptr - Advance head ptr past empty descrs
+ *
+ * If the driver fails to keep up and empty the queue, then the
+ * hardware wil run out of room to put incoming packets. This
+ * will cause the hardware to skip descrs that are full (instead
+ * of halting/retrying). Thus, once the driver runs, it wil need
+ * to "catch up" to where the hardware chain pointer is at.
+ */
+static void spider_net_resync_head_ptr(struct spider_net_card *card)
+{
+	unsigned long flags;
+	struct spider_net_descr_chain *chain = &card->rx_chain;
+	struct spider_net_descr *descr;
+	int i, status;
+
+	/* Advance head pointer past any empty descrs */
+	descr = chain->head;
+	status = spider_net_get_descr_status(descr->hwdescr);
+
+	if (status == SPIDER_NET_DESCR_NOT_IN_USE)
+		return;
+
+	spin_lock_irqsave(&chain->lock, flags);
+
+	descr = chain->head;
+	status = spider_net_get_descr_status(descr->hwdescr);
+	for (i=0; i<chain->num_desc; i++) {
+		if (status != SPIDER_NET_DESCR_CARDOWNED) break;
+		descr = descr->next;
+		status = spider_net_get_descr_status(descr->hwdescr);
+	}
+	chain->head = descr;
+
+	spin_unlock_irqrestore(&chain->lock, flags);
+}
+
+static int spider_net_resync_tail_ptr(struct spider_net_card *card)
+{
+	struct spider_net_descr_chain *chain = &card->rx_chain;
+	struct spider_net_descr *descr;
+	int i, status;
+
+	/* Advance tail pointer past any empty and reaped descrs */
+	descr = chain->tail;
+	status = spider_net_get_descr_status(descr->hwdescr);
+
+	for (i=0; i<chain->num_desc; i++) {
+		if ((status != SPIDER_NET_DESCR_CARDOWNED) &&
+		    (status != SPIDER_NET_DESCR_NOT_IN_USE)) break;
+		descr = descr->next;
+		status = spider_net_get_descr_status(descr->hwdescr);
+	}
+	chain->tail = descr;
+
+	if ((i == chain->num_desc) || (i == 0))
+		return 1;
+	return 0;
+}
+
+/**
  * spider_net_decode_one_descr - processes an RX descriptor
  * @card: card structure
  *
@@ -1112,7 +1172,7 @@ spider_net_decode_one_descr(struct spider_net_card *card)
 		goto bad_desc;
 	}
 
-	if (hwdescr->dmac_cmd_status & 0xfefe) {
+	if (hwdescr->dmac_cmd_status & 0xfcf4) {
 		pr_err("%s: bad status, cmd_status=x%08x\n",
 			       card->netdev->name,
 			       hwdescr->dmac_cmd_status);
@@ -1131,6 +1191,7 @@ spider_net_decode_one_descr(struct spider_net_card *card)
 
 	/* Ok, we've got a packet in descr */
 	spider_net_pass_skb_up(descr, card);
+	descr->skb = NULL;
 	hwdescr->dmac_cmd_status = SPIDER_NET_DESCR_NOT_IN_USE;
 	return 1;
 
@@ -1174,6 +1235,12 @@ spider_net_poll(struct net_device *netdev, int *budget)
 		}
 	}
 
+	if ((packets_done == 0) && (card->num_rx_ints != 0)) {
+		no_more_packets = spider_net_resync_tail_ptr(card);
+		spider_net_resync_head_ptr(card);
+	}
+	card->num_rx_ints = 0;
+
 	netdev->quota -= packets_done;
 	*budget -= packets_done;
 	spider_net_refill_rx_chain(card);
@@ -1184,6 +1251,7 @@ spider_net_poll(struct net_device *netdev, int *budget)
 	if (no_more_packets) {
 		netif_rx_complete(netdev);
 		spider_net_rx_irq_on(card);
+		card->ignore_rx_ramfull = 0;
 		return 0;
 	}
 
@@ -1417,11 +1485,15 @@ spider_net_handle_error_irq(struct spider_net_card *card, u32 status_reg)
 	case SPIDER_NET_GRFBFLLINT: /* fallthrough */
 	case SPIDER_NET_GRFAFLLINT: /* fallthrough */
 	case SPIDER_NET_GRMFLLINT:
-		if (netif_msg_intr(card) && net_ratelimit())
-			pr_err("Spider RX RAM full, incoming packets "
-			       "might be discarded!\n");
-		spider_net_rx_irq_off(card);
-		netif_rx_schedule(card->netdev);
+		/* Could happen when rx chain is full */
+		if (card->ignore_rx_ramfull == 0) {
+			card->ignore_rx_ramfull = 1;
+			spider_net_resync_head_ptr(card);
+			spider_net_refill_rx_chain(card);
+			spider_net_enable_rxdmac(card);
+			card->num_rx_ints ++;
+			netif_rx_schedule(card->netdev);
+		}
 		show_error = 0;
 		break;
 
@@ -1436,12 +1508,11 @@ spider_net_handle_error_irq(struct spider_net_card *card, u32 status_reg)
 	case SPIDER_NET_GDCDCEINT: /* fallthrough */
 	case SPIDER_NET_GDBDCEINT: /* fallthrough */
 	case SPIDER_NET_GDADCEINT:
-		if (netif_msg_intr(card) && net_ratelimit())
-			pr_err("got descriptor chain end interrupt, "
-			       "restarting DMAC %c.\n",
-			       'D'-(i-SPIDER_NET_GDDDCEINT)/3);
+		spider_net_resync_head_ptr(card);
 		spider_net_refill_rx_chain(card);
 		spider_net_enable_rxdmac(card);
+		card->num_rx_ints ++;
+		netif_rx_schedule(card->netdev);
 		show_error = 0;
 		break;
 
@@ -1450,9 +1521,12 @@ spider_net_handle_error_irq(struct spider_net_card *card, u32 status_reg)
 	case SPIDER_NET_GDCINVDINT: /* fallthrough */
 	case SPIDER_NET_GDBINVDINT: /* fallthrough */
 	case SPIDER_NET_GDAINVDINT:
-		/* could happen when rx chain is full */
+		/* Could happen when rx chain is full */
+		spider_net_resync_head_ptr(card);
 		spider_net_refill_rx_chain(card);
 		spider_net_enable_rxdmac(card);
+		card->num_rx_ints ++;
+		netif_rx_schedule(card->netdev);
 		show_error = 0;
 		break;
 
@@ -1545,6 +1619,7 @@ spider_net_interrupt(int irq, void *ptr)
 	if (status_reg & SPIDER_NET_RXINT ) {
 		spider_net_rx_irq_off(card);
 		netif_rx_schedule(netdev);
+		card->num_rx_ints ++;
 	}
 	if (status_reg & SPIDER_NET_TXINT)
 		netif_rx_schedule(netdev);
@@ -2185,11 +2260,13 @@ spider_net_setup_netdev(struct spider_net_card *card)
 
 	spider_net_setup_netdev_ops(netdev);
 
-	netdev->features = NETIF_F_HW_CSUM | NETIF_F_LLTX;
+	netdev->features = NETIF_F_IP_CSUM | NETIF_F_LLTX;
 	/* some time: NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX |
 	 *		NETIF_F_HW_VLAN_FILTER */
 
 	netdev->irq = card->pdev->irq;
+	card->num_rx_ints = 0;
+	card->ignore_rx_ramfull = 0;
 
 	dn = pci_device_to_OF_node(card->pdev);
 	if (!dn)
diff --git a/drivers/net/spider_net.h b/drivers/net/spider_net.h
index 4a1e0d2..1d054aa 100644
--- a/drivers/net/spider_net.h
+++ b/drivers/net/spider_net.h
@@ -25,7 +25,7 @@
 #ifndef _SPIDER_NET_H
 #define _SPIDER_NET_H
 
-#define VERSION "2.0 A"
+#define VERSION "2.0 B"
 
 #include "sungem_phy.h"
 
@@ -222,6 +222,7 @@ extern char spider_net_driver_name[];
 #define SPIDER_NET_GDTBSTA             0x00000300
 #define SPIDER_NET_GDTDCEIDIS          0x00000002
 #define SPIDER_NET_DMA_TX_VALUE        SPIDER_NET_TX_DMA_EN | \
+                                       SPIDER_NET_GDTDCEIDIS | \
                                        SPIDER_NET_GDTBSTA
 
 #define SPIDER_NET_DMA_TX_FEND_VALUE	0x00030003
@@ -332,8 +333,7 @@ enum spider_net_int2_status {
 	SPIDER_NET_GRISPDNGINT
 };
 
-#define SPIDER_NET_TXINT	( (1 << SPIDER_NET_GDTFDCINT) | \
-                             (1 << SPIDER_NET_GDTDCEINT) )
+#define SPIDER_NET_TXINT	(1 << SPIDER_NET_GDTFDCINT)
 
 /* We rely on flagged descriptor interrupts */
 #define SPIDER_NET_RXINT	( (1 << SPIDER_NET_GDAFDCINT) )
@@ -461,6 +461,8 @@ struct spider_net_card {
 	struct work_struct tx_timeout_task;
 	atomic_t tx_timeout_task_counter;
 	wait_queue_head_t waitq;
+	int num_rx_ints;
+	int ignore_rx_ramfull;
 
 	/* for ethtool */
 	int msg_enable;
diff --git a/drivers/net/spider_net_ethtool.c b/drivers/net/spider_net_ethtool.c
index 6bcf03f..d940474 100644
--- a/drivers/net/spider_net_ethtool.c
+++ b/drivers/net/spider_net_ethtool.c
@@ -134,22 +134,6 @@ spider_net_ethtool_set_rx_csum(struct net_device *netdev, u32 n)
 	return 0;
 }
 
-static uint32_t
-spider_net_ethtool_get_tx_csum(struct net_device *netdev)
-{
-        return (netdev->features & NETIF_F_HW_CSUM) != 0;
-}
-
-static int
-spider_net_ethtool_set_tx_csum(struct net_device *netdev, uint32_t data)
-{
-        if (data)
-                netdev->features |= NETIF_F_HW_CSUM;
-        else
-                netdev->features &= ~NETIF_F_HW_CSUM;
-
-        return 0;
-}
 
 static void
 spider_net_ethtool_get_ringparam(struct net_device *netdev,
@@ -200,11 +184,12 @@ const struct ethtool_ops spider_net_ethtool_ops = {
 	.get_wol		= spider_net_ethtool_get_wol,
 	.get_msglevel		= spider_net_ethtool_get_msglevel,
 	.set_msglevel		= spider_net_ethtool_set_msglevel,
+	.get_link		= ethtool_op_get_link,
 	.nway_reset		= spider_net_ethtool_nway_reset,
 	.get_rx_csum		= spider_net_ethtool_get_rx_csum,
 	.set_rx_csum		= spider_net_ethtool_set_rx_csum,
-	.get_tx_csum		= spider_net_ethtool_get_tx_csum,
-	.set_tx_csum		= spider_net_ethtool_set_tx_csum,
+	.get_tx_csum		= ethtool_op_get_tx_csum,
+	.set_tx_csum		= ethtool_op_set_tx_csum,
 	.get_ringparam          = spider_net_ethtool_get_ringparam,
 	.get_strings		= spider_net_get_strings,
 	.get_stats_count	= spider_net_get_stats_count,
diff --git a/drivers/s390/net/claw.c b/drivers/s390/net/claw.c
index 6dd64d0..348bb7b 100644
--- a/drivers/s390/net/claw.c
+++ b/drivers/s390/net/claw.c
@@ -3912,6 +3912,7 @@ static int
 add_channel(struct ccw_device *cdev,int i,struct claw_privbk *privptr)
 {
 	struct chbk *p_ch;
+	struct ccw_dev_id dev_id;
 
 #ifdef FUNCTRACE
         printk(KERN_INFO "%s:%s Enter\n",cdev->dev.bus_id,__FUNCTION__);
@@ -3921,7 +3922,8 @@ add_channel(struct ccw_device *cdev,int i,struct claw_privbk *privptr)
 	p_ch = &privptr->channel[i];
 	p_ch->cdev = cdev;
 	snprintf(p_ch->id, CLAW_ID_SIZE, "cl-%s", cdev->dev.bus_id);
-	sscanf(cdev->dev.bus_id+4,"%x",&p_ch->devno);
+	ccw_device_get_id(cdev, &dev_id);
+	p_ch->devno = dev_id.devno;
 	if ((p_ch->irb = kmalloc(sizeof (struct irb),GFP_KERNEL)) == NULL) {
 		printk(KERN_WARNING "%s Out of memory in %s for irb\n",
 			p_ch->id,__FUNCTION__);
@@ -3955,6 +3957,7 @@ claw_new_device(struct ccwgroup_device *cgdev)
 	struct claw_env *p_env;
 	struct net_device *dev;
 	int ret;
+	struct ccw_dev_id dev_id;
 
 	pr_debug("%s() called\n", __FUNCTION__);
 	printk(KERN_INFO "claw: add for %s\n",cgdev->cdev[READ]->dev.bus_id);
@@ -3965,10 +3968,10 @@ claw_new_device(struct ccwgroup_device *cgdev)
 	if (!privptr)
 		return -ENODEV;
 	p_env = privptr->p_env;
-	sscanf(cgdev->cdev[READ]->dev.bus_id+4,"%x",
-		&p_env->devno[READ]);
-        sscanf(cgdev->cdev[WRITE]->dev.bus_id+4,"%x",
-		&p_env->devno[WRITE]);
+	ccw_device_get_id(cgdev->cdev[READ], &dev_id);
+	p_env->devno[READ] = dev_id.devno;
+	ccw_device_get_id(cgdev->cdev[WRITE], &dev_id);
+	p_env->devno[WRITE] = dev_id.devno;
 	ret = add_channel(cgdev->cdev[0],0,privptr);
 	if (ret == 0)
 		ret = add_channel(cgdev->cdev[1],1,privptr);
diff --git a/drivers/s390/net/netiucv.c b/drivers/s390/net/netiucv.c
index c358764..3d28e1a 100644
--- a/drivers/s390/net/netiucv.c
+++ b/drivers/s390/net/netiucv.c
@@ -134,18 +134,6 @@ PRINT_##importance(header "%02x %02x %02x %02x  %02x %02x %02x %02x  " \
 		   *(((char*)ptr)+28),*(((char*)ptr)+29), \
 		   *(((char*)ptr)+30),*(((char*)ptr)+31));
 
-static inline void iucv_hex_dump(unsigned char *buf, size_t len)
-{
-	size_t i;
-
-	for (i = 0; i < len; i++) {
-		if (i && !(i % 16))
-			printk("\n");
-		printk("%02x ", *(buf + i));
-	}
-	printk("\n");
-}
-
 #define PRINTK_HEADER " iucv: "       /* for debugging */
 
 static struct device_driver netiucv_driver = {
@@ -212,7 +200,7 @@ struct iucv_connection {
  */
 static struct list_head iucv_connection_list =
 	LIST_HEAD_INIT(iucv_connection_list);
-static rwlock_t iucv_connection_rwlock = RW_LOCK_UNLOCKED;
+static DEFINE_RWLOCK(iucv_connection_rwlock);
 
 /**
  * Representation of event-data for the
@@ -280,7 +268,7 @@ static u8 iucvMagic[16] = {
  *
  * @returns The printable string (static data!!)
  */
-static inline char *netiucv_printname(char *name)
+static char *netiucv_printname(char *name)
 {
 	static char tmp[9];
 	char *p = tmp;
@@ -1315,7 +1303,8 @@ static int netiucv_tx(struct sk_buff *skb, struct net_device *dev)
 	 * and throw away packet.
 	 */
 	if (fsm_getstate(privptr->fsm) != DEV_STATE_RUNNING) {
-		fsm_event(privptr->fsm, DEV_EVENT_START, dev);
+		if (!in_atomic())
+			fsm_event(privptr->fsm, DEV_EVENT_START, dev);
 		dev_kfree_skb(skb);
 		privptr->stats.tx_dropped++;
 		privptr->stats.tx_errors++;
@@ -1729,7 +1718,7 @@ static struct attribute_group netiucv_stat_attr_group = {
 	.attrs = netiucv_stat_attrs,
 };
 
-static inline int netiucv_add_files(struct device *dev)
+static int netiucv_add_files(struct device *dev)
 {
 	int ret;
 
@@ -1743,7 +1732,7 @@ static inline int netiucv_add_files(struct device *dev)
 	return ret;
 }
 
-static inline void netiucv_remove_files(struct device *dev)
+static void netiucv_remove_files(struct device *dev)
 {
 	IUCV_DBF_TEXT(trace, 3, __FUNCTION__);
 	sysfs_remove_group(&dev->kobj, &netiucv_stat_attr_group);
diff --git a/drivers/s390/net/qeth_eddp.c b/drivers/s390/net/qeth_eddp.c
index 4640f32..70108fb 100644
--- a/drivers/s390/net/qeth_eddp.c
+++ b/drivers/s390/net/qeth_eddp.c
@@ -424,8 +424,7 @@ __qeth_eddp_fill_context_tcp(struct qeth_eddp_context *ctx,
 		/* prepare qdio hdr */
 		if (eddp->qh.hdr.l2.id == QETH_HEADER_TYPE_LAYER2){
 			eddp->qh.hdr.l2.pkt_length = data_len + ETH_HLEN +
-						     eddp->nhl + eddp->thl -
-						     sizeof(struct qeth_hdr);
+						     eddp->nhl + eddp->thl;
 #ifdef CONFIG_QETH_VLAN
 			if (eddp->mac.h_proto == __constant_htons(ETH_P_8021Q))
 				eddp->qh.hdr.l2.pkt_length += VLAN_HLEN;
diff --git a/drivers/s390/net/qeth_main.c b/drivers/s390/net/qeth_main.c
index 0b96d49..86b0c44 100644
--- a/drivers/s390/net/qeth_main.c
+++ b/drivers/s390/net/qeth_main.c
@@ -986,15 +986,15 @@ qeth_recover(void *ptr)
 	card->use_hard_stop = 1;
 	__qeth_set_offline(card->gdev,1);
 	rc = __qeth_set_online(card->gdev,1);
+	/* don't run another scheduled recovery */
+	qeth_clear_thread_start_bit(card, QETH_RECOVER_THREAD);
+	qeth_clear_thread_running_bit(card, QETH_RECOVER_THREAD);
 	if (!rc)
 		PRINT_INFO("Device %s successfully recovered!\n",
 			   CARD_BUS_ID(card));
 	else
 		PRINT_INFO("Device %s could not be recovered!\n",
 			   CARD_BUS_ID(card));
-	/* don't run another scheduled recovery */
-	qeth_clear_thread_start_bit(card, QETH_RECOVER_THREAD);
-	qeth_clear_thread_running_bit(card, QETH_RECOVER_THREAD);
 	return 0;
 }
 
@@ -2176,13 +2176,6 @@ qeth_ulp_enable(struct qeth_card *card)
 
 }
 
-static inline __u16
-__raw_devno_from_bus_id(char *id)
-{
-	id += (strlen(id) - 4);
-	return (__u16) simple_strtoul(id, &id, 16);
-}
-
 static int
 qeth_ulp_setup_cb(struct qeth_card *card, struct qeth_reply *reply,
 		  unsigned long data)
@@ -2205,6 +2198,7 @@ qeth_ulp_setup(struct qeth_card *card)
 	int rc;
 	__u16 temp;
 	struct qeth_cmd_buffer *iob;
+	struct ccw_dev_id dev_id;
 
 	QETH_DBF_TEXT(setup,2,"ulpsetup");
 
@@ -2218,8 +2212,8 @@ qeth_ulp_setup(struct qeth_card *card)
 	memcpy(QETH_ULP_SETUP_FILTER_TOKEN(iob->data),
 	       &card->token.ulp_filter_r, QETH_MPC_TOKEN_LENGTH);
 
-	temp = __raw_devno_from_bus_id(CARD_DDEV_ID(card));
-	memcpy(QETH_ULP_SETUP_CUA(iob->data), &temp, 2);
+	ccw_device_get_id(CARD_DDEV(card), &dev_id);
+	memcpy(QETH_ULP_SETUP_CUA(iob->data), &dev_id.devno, 2);
 	temp = (card->info.cula << 8) + card->info.unit_addr2;
 	memcpy(QETH_ULP_SETUP_REAL_DEVADDR(iob->data), &temp, 2);
 	rc = qeth_send_control_data(card, ULP_SETUP_SIZE, iob,
@@ -5850,9 +5844,9 @@ qeth_add_vlan_mc6(struct qeth_card *card)
 		in_dev = in6_dev_get(netdev);
 		if (!in_dev)
 			continue;
-		read_lock(&in_dev->lock);
+		read_lock_bh(&in_dev->lock);
 		qeth_add_mc6(card,in_dev);
-		read_unlock(&in_dev->lock);
+		read_unlock_bh(&in_dev->lock);
 		in6_dev_put(in_dev);
 	}
 #endif /* CONFIG_QETH_VLAN */
@@ -5869,10 +5863,10 @@ qeth_add_multicast_ipv6(struct qeth_card *card)
 	in6_dev = in6_dev_get(card->dev);
 	if (in6_dev == NULL)
 		return;
-	read_lock(&in6_dev->lock);
+	read_lock_bh(&in6_dev->lock);
 	qeth_add_mc6(card, in6_dev);
 	qeth_add_vlan_mc6(card);
-	read_unlock(&in6_dev->lock);
+	read_unlock_bh(&in6_dev->lock);
 	in6_dev_put(in6_dev);
 }
 #endif /* CONFIG_QETH_IPV6 */
@@ -7476,11 +7470,11 @@ qeth_softsetup_card(struct qeth_card *card)
 		QETH_DBF_TEXT_(setup, 2, "1err%d", rc);
 		if (rc == 0xe080){
 			PRINT_WARN("LAN on card %s if offline! "
-				   "Continuing softsetup.\n",
+				   "Waiting for STARTLAN from card.\n",
 				   CARD_BUS_ID(card));
 			card->lan_online = 0;
-		} else
-			return rc;
+		}
+		return rc;
 	} else
 		card->lan_online = 1;
 	if (card->info.type==QETH_CARD_TYPE_OSN)
@@ -7797,15 +7791,17 @@ qeth_print_status_message(struct qeth_card *card)
 		}
 		/* fallthrough */
 	case QETH_CARD_TYPE_IQD:
-		card->info.mcl_level[0] = (char) _ebcasc[(__u8)
-			card->info.mcl_level[0]];
-		card->info.mcl_level[1] = (char) _ebcasc[(__u8)
-			card->info.mcl_level[1]];
-		card->info.mcl_level[2] = (char) _ebcasc[(__u8)
-			card->info.mcl_level[2]];
-		card->info.mcl_level[3] = (char) _ebcasc[(__u8)
-			card->info.mcl_level[3]];
-		card->info.mcl_level[QETH_MCL_LENGTH] = 0;
+		if (card->info.guestlan) {
+			card->info.mcl_level[0] = (char) _ebcasc[(__u8)
+				card->info.mcl_level[0]];
+			card->info.mcl_level[1] = (char) _ebcasc[(__u8)
+				card->info.mcl_level[1]];
+			card->info.mcl_level[2] = (char) _ebcasc[(__u8)
+				card->info.mcl_level[2]];
+			card->info.mcl_level[3] = (char) _ebcasc[(__u8)
+				card->info.mcl_level[3]];
+			card->info.mcl_level[QETH_MCL_LENGTH] = 0;
+		}
 		break;
 	default:
 		memset(&card->info.mcl_level[0], 0, QETH_MCL_LENGTH + 1);
