From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 0/5] Pull request for 'davem-next.r8169' branch
Date: Tue, 31 Jan 2012 14:53:24 +0100
Message-ID: <20120131135322.GA18106@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	=?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>,
	Hayes Wang <hayeswang@realtek.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:55975 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752717Ab2AaOEu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2012 09:04:50 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please pull from branch 'davem-next.r8169' in repository

git://violet.fr.zoreil.com/romieu/linux davem-next.r8169

to get the changes below.

Distance from 'davem-next' (aacafba8c2f4e9c9f3f38c60be83b65e69866723)
---------------------------------------------------------------------

6c05d25267ebb371c4311de6904f740342e82f7c
934714d088f35b81edafdce89397969baf77fb8a
6c4a70c5f286077e78b294b3f3a93dc45c40db89
98ddf986fca17840e46e070354b7e2cd2169da15
ae1f23fb433ac0aaff8aeaa5a7b14348e9aa8277

Diffstat
--------

 drivers/net/ethernet/realtek/r8169.c |   61 +++++++++++++++++----------------
 1 files changed, 31 insertions(+), 30 deletions(-)

Shortlog
--------

Francois Romieu (5):
      r8169: fix early queue wake-up.
      r8169: bh locking redux and task scheduling.
      r8169: move task enable boolean to bitfield.
      r8169: avoid a useless work scheduling.
      r8169: spinlock redux.

Patch
-----

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index d039d39..7077422 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -668,6 +668,7 @@ struct rtl8169_counters {
 };
 
 enum rtl_flag {
+	RTL_FLAG_TASK_ENABLED,
 	RTL_FLAG_TASK_SLOW_PENDING,
 	RTL_FLAG_TASK_RESET_PENDING,
 	RTL_FLAG_TASK_PHY_PENDING,
@@ -679,7 +680,6 @@ struct rtl8169_private {
 	struct pci_dev *pci_dev;
 	struct net_device *dev;
 	struct napi_struct napi;
-	spinlock_t lock;
 	u32 msg_enable;
 	u16 txd_version;
 	u16 mac_version;
@@ -725,7 +725,6 @@ struct rtl8169_private {
 		DECLARE_BITMAP(flags, RTL_FLAG_MAX);
 		struct mutex mutex;
 		struct work_struct work;
-		bool enabled;
 	} wk;
 
 	unsigned features;
@@ -1723,9 +1722,7 @@ static void rtl8169_get_regs(struct net_device *dev, struct ethtool_regs *regs,
 		regs->len = R8169_REGS_SIZE;
 
 	rtl_lock_work(tp);
-	spin_lock_bh(&tp->lock);
 	memcpy_fromio(p, tp->mmio_addr, regs->len);
-	spin_unlock_bh(&tp->lock);
 	rtl_unlock_work(tp);
 }
 
@@ -3273,17 +3270,8 @@ out_mod_timer:
 
 static void rtl_schedule_task(struct rtl8169_private *tp, enum rtl_flag flag)
 {
-	spin_lock(&tp->lock);
 	if (!test_and_set_bit(flag, tp->wk.flags))
 		schedule_work(&tp->wk.work);
-	spin_unlock(&tp->lock);
-}
-
-static void rtl_schedule_task_bh(struct rtl8169_private *tp, enum rtl_flag flag)
-{
-	local_bh_disable();
-	rtl_schedule_task(tp, flag);
-	local_bh_enable();
 }
 
 static void rtl8169_phy_timer(unsigned long __opaque)
@@ -3291,7 +3279,7 @@ static void rtl8169_phy_timer(unsigned long __opaque)
 	struct net_device *dev = (struct net_device *)__opaque;
 	struct rtl8169_private *tp = netdev_priv(dev);
 
-	rtl_schedule_task_bh(tp, RTL_FLAG_TASK_PHY_PENDING);
+	rtl_schedule_task(tp, RTL_FLAG_TASK_PHY_PENDING);
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
@@ -4160,7 +4148,6 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		tp->do_ioctl = rtl_xmii_ioctl;
 	}
 
-	spin_lock_init(&tp->lock);
 	mutex_init(&tp->wk.mutex);
 
 	/* Get MAC address */
@@ -4361,7 +4348,7 @@ static int rtl8169_open(struct net_device *dev)
 
 	rtl_lock_work(tp);
 
-	tp->wk.enabled = true;
+	set_bit(RTL_FLAG_TASK_ENABLED, tp->wk.flags);
 
 	napi_enable(&tp->napi);
 
@@ -5559,7 +5546,18 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
 	mmiowb();
 
 	if (TX_BUFFS_AVAIL(tp) < MAX_SKB_FRAGS) {
+		/* Avoid wrongly optimistic queue wake-up: rtl_tx thread must
+		 * not miss a ring update when it notices a stopped queue.
+		 */
+		smp_wmb();
 		netif_stop_queue(dev);
+		/* Sync with rtl_tx:
+		 * - publish queue status and cur_tx ring index (write barrier)
+		 * - refresh dirty_tx ring index (read barrier).
+		 * May the current thread have a pessimistic view of the ring
+		 * status and forget to wake up queue, a racing rtl_tx thread
+		 * can't.
+		 */
 		smp_mb();
 		if (TX_BUFFS_AVAIL(tp) >= MAX_SKB_FRAGS)
 			netif_wake_queue(dev);
@@ -5624,7 +5622,7 @@ static void rtl8169_pcierr_interrupt(struct net_device *dev)
 
 	rtl8169_hw_reset(tp);
 
-	rtl_schedule_task_bh(tp, RTL_FLAG_TASK_RESET_PENDING);
+	rtl_schedule_task(tp, RTL_FLAG_TASK_RESET_PENDING);
 }
 
 static void rtl_tx(struct net_device *dev, struct rtl8169_private *tp)
@@ -5659,6 +5657,13 @@ static void rtl_tx(struct net_device *dev, struct rtl8169_private *tp)
 
 	if (tp->dirty_tx != dirty_tx) {
 		tp->dirty_tx = dirty_tx;
+		/* Sync with rtl8169_start_xmit:
+		 * - publish dirty_tx ring index (write barrier)
+		 * - refresh cur_tx ring index and queue status (read barrier)
+		 * May the current thread miss the stopped queue condition,
+		 * a racing xmit thread can only have a right view of the
+		 * ring status.
+		 */
 		smp_mb();
 		if (netif_queue_stopped(dev) &&
 		    (TX_BUFFS_AVAIL(tp) >= MAX_SKB_FRAGS)) {
@@ -5834,7 +5839,8 @@ static void rtl_slow_event_work(struct rtl8169_private *tp)
 		/* Work around for rx fifo overflow */
 		case RTL_GIGA_MAC_VER_11:
 			netif_stop_queue(dev);
-			rtl_schedule_task_bh(tp, RTL_FLAG_TASK_RESET_PENDING);
+			/* XXX - Hack alert. See rtl_task(). */
+			set_bit(RTL_FLAG_TASK_RESET_PENDING, tp->wk.flags);
 		default:
 			break;
 		}
@@ -5859,6 +5865,7 @@ static void rtl_task(struct work_struct *work)
 		int bitnr;
 		void (*action)(struct rtl8169_private *);
 	} rtl_work[] = {
+		/* XXX - keep rtl_slow_event_work() as first element. */
 		{ RTL_FLAG_TASK_SLOW_PENDING,	rtl_slow_event_work },
 		{ RTL_FLAG_TASK_RESET_PENDING,	rtl_reset_work },
 		{ RTL_FLAG_TASK_PHY_PENDING,	rtl_phy_work }
@@ -5870,16 +5877,14 @@ static void rtl_task(struct work_struct *work)
 
 	rtl_lock_work(tp);
 
-	if (!netif_running(dev) || !tp->wk.enabled)
+	if (!netif_running(dev) ||
+	    !test_bit(RTL_FLAG_TASK_ENABLED, tp->wk.flags))
 		goto out_unlock;
 
 	for (i = 0; i < ARRAY_SIZE(rtl_work); i++) {
 		bool pending;
 
-		spin_lock_bh(&tp->lock);
 		pending = test_and_clear_bit(rtl_work[i].bitnr, tp->wk.flags);
-		spin_unlock_bh(&tp->lock);
-
 		if (pending)
 			rtl_work[i].action(tp);
 	}
@@ -5971,7 +5976,7 @@ static int rtl8169_close(struct net_device *dev)
 	rtl8169_update_counters(dev);
 
 	rtl_lock_work(tp);
-	tp->wk.enabled = false;
+	clear_bit(RTL_FLAG_TASK_ENABLED, tp->wk.flags);
 
 	rtl8169_down(dev);
 	rtl_unlock_work(tp);
@@ -6022,8 +6027,6 @@ static void rtl_set_rx_mode(struct net_device *dev)
 		}
 	}
 
-	spin_lock_bh(&tp->lock);
-
 	tmp = (RTL_R32(RxConfig) & ~RX_CONFIG_ACCEPT_MASK) | rx_mode;
 
 	if (tp->mac_version > RTL_GIGA_MAC_VER_06) {
@@ -6037,8 +6040,6 @@ static void rtl_set_rx_mode(struct net_device *dev)
 	RTL_W32(MAR0 + 0, mc_filter[0]);
 
 	RTL_W32(RxConfig, tmp);
-
-	spin_unlock_bh(&tp->lock);
 }
 
 /**
@@ -6070,7 +6071,7 @@ static void rtl8169_net_suspend(struct net_device *dev)
 
 	rtl_lock_work(tp);
 	napi_disable(&tp->napi);
-	tp->wk.enabled = false;
+	clear_bit(RTL_FLAG_TASK_ENABLED, tp->wk.flags);
 	rtl_unlock_work(tp);
 
 	rtl_pll_power_down(tp);
@@ -6096,9 +6097,9 @@ static void __rtl8169_resume(struct net_device *dev)
 
 	rtl_pll_power_up(tp);
 
-	tp->wk.enabled = true;
+	set_bit(RTL_FLAG_TASK_ENABLED, tp->wk.flags);
 
-	rtl_schedule_task_bh(tp, RTL_FLAG_TASK_RESET_PENDING);
+	rtl_schedule_task(tp, RTL_FLAG_TASK_RESET_PENDING);
 }
 
 static int rtl8169_resume(struct device *device)
-- 
Ueimor
