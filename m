From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] net: tulip: Convert timers to use timer_setup()
Date: Wed, 4 Oct 2017 17:51:22 -0700
Message-ID: <20171005005122.GA23402@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        David Howells <dhowells@redhat.com>,
        Jarod Wilson <jarod@redhat.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Johannes Berg <johannes.berg@intel.com>,
        Eric Dumazet <edumazet@google.com>,
        Philippe Reynes <tremyfr@gmail.com>,
        "yuval.shaia@oracle.com" <yuval.shaia@oracle.com>,
        netdev@vger.kernel.org, linux-parisc@vger.kernel.org,
        Thomas Gleixner <tglx@linutronix.de>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: David Howells <dhowells@redhat.com>
Cc: Jarod Wilson <jarod@redhat.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: Johannes Berg <johannes.berg@intel.com>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Philippe Reynes <tremyfr@gmail.com>
Cc: "yuval.shaia@oracle.com" <yuval.shaia@oracle.com>
Cc: netdev@vger.kernel.org
Cc: linux-parisc@vger.kernel.org
Cc: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Kees Cook <keescook@chromium.org>
---
This requires commit 686fef928bba ("timer: Prepare to change timer
callback argument type") in v4.14-rc3, but should be otherwise
stand-alone.
---
 drivers/net/ethernet/dec/tulip/de4x5.c       | 13 ++++++-------
 drivers/net/ethernet/dec/tulip/dmfe.c        | 12 +++++-------
 drivers/net/ethernet/dec/tulip/interrupt.c   |  6 +++---
 drivers/net/ethernet/dec/tulip/pnic.c        |  6 +++---
 drivers/net/ethernet/dec/tulip/pnic2.c       |  6 +++---
 drivers/net/ethernet/dec/tulip/timer.c       | 12 ++++++------
 drivers/net/ethernet/dec/tulip/tulip.h       | 12 ++++++------
 drivers/net/ethernet/dec/tulip/tulip_core.c  | 14 ++++++--------
 drivers/net/ethernet/dec/tulip/uli526x.c     | 12 +++++-------
 drivers/net/ethernet/dec/tulip/winbond-840.c | 14 ++++++--------
 10 files changed, 49 insertions(+), 58 deletions(-)

diff --git a/drivers/net/ethernet/dec/tulip/de4x5.c b/drivers/net/ethernet/dec/tulip/de4x5.c
index 0affee9c8aa2..a31b4df3e7ff 100644
--- a/drivers/net/ethernet/dec/tulip/de4x5.c
+++ b/drivers/net/ethernet/dec/tulip/de4x5.c
@@ -912,7 +912,7 @@ static int     de4x5_init(struct net_device *dev);
 static int     de4x5_sw_reset(struct net_device *dev);
 static int     de4x5_rx(struct net_device *dev);
 static int     de4x5_tx(struct net_device *dev);
-static void    de4x5_ast(struct net_device *dev);
+static void    de4x5_ast(struct timer_list *t);
 static int     de4x5_txur(struct net_device *dev);
 static int     de4x5_rx_ovfc(struct net_device *dev);
 
@@ -1147,9 +1147,7 @@ de4x5_hw_init(struct net_device *dev, u_long iobase, struct device *gendev)
 	lp->timeout = -1;
 	lp->gendev = gendev;
 	spin_lock_init(&lp->lock);
-	init_timer(&lp->timer);
-	lp->timer.function = (void (*)(unsigned long))de4x5_ast;
-	lp->timer.data = (unsigned long)dev;
+	timer_setup(&lp->timer, de4x5_ast, 0);
 	de4x5_parse_params(dev);
 
 	/*
@@ -1742,9 +1740,10 @@ de4x5_tx(struct net_device *dev)
 }
 
 static void
-de4x5_ast(struct net_device *dev)
+de4x5_ast(struct timer_list *t)
 {
-	struct de4x5_private *lp = netdev_priv(dev);
+	struct de4x5_private *lp = from_timer(lp, t, timer);
+	struct net_device *dev = dev_get_drvdata(lp->gendev);
 	int next_tick = DE4X5_AUTOSENSE_MS;
 	int dt;
 
@@ -2370,7 +2369,7 @@ autoconf_media(struct net_device *dev)
 	lp->media = INIT;
 	lp->tcount = 0;
 
-	de4x5_ast(dev);
+	de4x5_ast(&lp->timer);
 
 	return lp->media;
 }
diff --git a/drivers/net/ethernet/dec/tulip/dmfe.c b/drivers/net/ethernet/dec/tulip/dmfe.c
index 07e10a45beaa..17ef7a28873d 100644
--- a/drivers/net/ethernet/dec/tulip/dmfe.c
+++ b/drivers/net/ethernet/dec/tulip/dmfe.c
@@ -331,7 +331,7 @@ static void dmfe_phy_write_1bit(void __iomem *, u32);
 static u16 dmfe_phy_read_1bit(void __iomem *);
 static u8 dmfe_sense_speed(struct dmfe_board_info *);
 static void dmfe_process_mode(struct dmfe_board_info *);
-static void dmfe_timer(unsigned long);
+static void dmfe_timer(struct timer_list *);
 static inline u32 cal_CRC(unsigned char *, unsigned int, u8);
 static void dmfe_rx_packet(struct net_device *, struct dmfe_board_info *);
 static void dmfe_free_tx_pkt(struct net_device *, struct dmfe_board_info *);
@@ -596,10 +596,8 @@ static int dmfe_open(struct net_device *dev)
 	netif_wake_queue(dev);
 
 	/* set and active a timer process */
-	init_timer(&db->timer);
+	timer_setup(&db->timer, dmfe_timer, 0);
 	db->timer.expires = DMFE_TIMER_WUT + HZ * 2;
-	db->timer.data = (unsigned long)dev;
-	db->timer.function = dmfe_timer;
 	add_timer(&db->timer);
 
 	return 0;
@@ -1130,10 +1128,10 @@ static const struct ethtool_ops netdev_ethtool_ops = {
  *	Dynamic media sense, allocate Rx buffer...
  */
 
-static void dmfe_timer(unsigned long data)
+static void dmfe_timer(struct timer_list *t)
 {
-	struct net_device *dev = (struct net_device *)data;
-	struct dmfe_board_info *db = netdev_priv(dev);
+	struct dmfe_board_info *db = from_timer(db, t, timer);
+	struct net_device *dev = pci_get_drvdata(db->pdev);
 	void __iomem *ioaddr = db->ioaddr;
 	u32 tmp_cr8;
 	unsigned char tmp_cr12;
diff --git a/drivers/net/ethernet/dec/tulip/interrupt.c b/drivers/net/ethernet/dec/tulip/interrupt.c
index 8df80880ecaa..c1ca0765d56d 100644
--- a/drivers/net/ethernet/dec/tulip/interrupt.c
+++ b/drivers/net/ethernet/dec/tulip/interrupt.c
@@ -102,10 +102,10 @@ int tulip_refill_rx(struct net_device *dev)
 
 #ifdef CONFIG_TULIP_NAPI
 
-void oom_timer(unsigned long data)
+void oom_timer(struct timer_list *t)
 {
-        struct net_device *dev = (struct net_device *)data;
-	struct tulip_private *tp = netdev_priv(dev);
+	struct tulip_private *tp = from_timer(tp, t, oom_timer);
+
 	napi_schedule(&tp->napi);
 }
 
diff --git a/drivers/net/ethernet/dec/tulip/pnic.c b/drivers/net/ethernet/dec/tulip/pnic.c
index 7bcccf5cac7a..3fb39e32e1b4 100644
--- a/drivers/net/ethernet/dec/tulip/pnic.c
+++ b/drivers/net/ethernet/dec/tulip/pnic.c
@@ -84,10 +84,10 @@ void pnic_lnk_change(struct net_device *dev, int csr5)
 	}
 }
 
-void pnic_timer(unsigned long data)
+void pnic_timer(struct timer_list *t)
 {
-	struct net_device *dev = (struct net_device *)data;
-	struct tulip_private *tp = netdev_priv(dev);
+	struct tulip_private *tp = from_timer(tp, t, timer);
+	struct net_device *dev = tp->dev;
 	void __iomem *ioaddr = tp->base_addr;
 	int next_tick = 60*HZ;
 
diff --git a/drivers/net/ethernet/dec/tulip/pnic2.c b/drivers/net/ethernet/dec/tulip/pnic2.c
index 5895fc43f6e0..412adaa7fdf8 100644
--- a/drivers/net/ethernet/dec/tulip/pnic2.c
+++ b/drivers/net/ethernet/dec/tulip/pnic2.c
@@ -76,10 +76,10 @@
 #include <linux/delay.h>
 
 
-void pnic2_timer(unsigned long data)
+void pnic2_timer(struct timer_list *t)
 {
-	struct net_device *dev = (struct net_device *)data;
-	struct tulip_private *tp = netdev_priv(dev);
+	struct tulip_private *tp = from_timer(tp, t, timer);
+	struct net_device *dev = tp->dev;
 	void __iomem *ioaddr = tp->base_addr;
 	int next_tick = 60*HZ;
 
diff --git a/drivers/net/ethernet/dec/tulip/timer.c b/drivers/net/ethernet/dec/tulip/timer.c
index 523d9dde50a2..642e9dfc5451 100644
--- a/drivers/net/ethernet/dec/tulip/timer.c
+++ b/drivers/net/ethernet/dec/tulip/timer.c
@@ -137,10 +137,10 @@ void tulip_media_task(struct work_struct *work)
 }
 
 
-void mxic_timer(unsigned long data)
+void mxic_timer(struct timer_list *t)
 {
-	struct net_device *dev = (struct net_device *)data;
-	struct tulip_private *tp = netdev_priv(dev);
+	struct tulip_private *tp = from_timer(tp, t, timer);
+	struct net_device *dev = tp->dev;
 	void __iomem *ioaddr = tp->base_addr;
 	int next_tick = 60*HZ;
 
@@ -154,10 +154,10 @@ void mxic_timer(unsigned long data)
 }
 
 
-void comet_timer(unsigned long data)
+void comet_timer(struct timer_list *t)
 {
-	struct net_device *dev = (struct net_device *)data;
-	struct tulip_private *tp = netdev_priv(dev);
+	struct tulip_private *tp = from_timer(tp, t, timer);
+	struct net_device *dev = tp->dev;
 	int next_tick = 2*HZ;
 
 	if (tulip_debug > 1)
diff --git a/drivers/net/ethernet/dec/tulip/tulip.h b/drivers/net/ethernet/dec/tulip/tulip.h
index 06660dbc44b7..b458140aeaef 100644
--- a/drivers/net/ethernet/dec/tulip/tulip.h
+++ b/drivers/net/ethernet/dec/tulip/tulip.h
@@ -43,7 +43,7 @@ struct tulip_chip_table {
 	int io_size;
 	int valid_intrs;	/* CSR7 interrupt enable settings */
 	int flags;
-	void (*media_timer) (unsigned long);
+	void (*media_timer) (struct timer_list *);
 	work_func_t media_task;
 };
 
@@ -476,7 +476,7 @@ void t21142_lnk_change(struct net_device *dev, int csr5);
 
 /* PNIC2.c */
 void pnic2_lnk_change(struct net_device *dev, int csr5);
-void pnic2_timer(unsigned long data);
+void pnic2_timer(struct timer_list *t);
 void pnic2_start_nway(struct net_device *dev);
 void pnic2_lnk_change(struct net_device *dev, int csr5);
 
@@ -504,19 +504,19 @@ void tulip_find_mii (struct net_device *dev, int board_idx);
 /* pnic.c */
 void pnic_do_nway(struct net_device *dev);
 void pnic_lnk_change(struct net_device *dev, int csr5);
-void pnic_timer(unsigned long data);
+void pnic_timer(struct timer_list *t);
 
 /* timer.c */
 void tulip_media_task(struct work_struct *work);
-void mxic_timer(unsigned long data);
-void comet_timer(unsigned long data);
+void mxic_timer(struct timer_list *t);
+void comet_timer(struct timer_list *t);
 
 /* tulip_core.c */
 extern int tulip_debug;
 extern const char * const medianame[];
 extern const char tulip_media_cap[];
 extern const struct tulip_chip_table tulip_tbl[];
-void oom_timer(unsigned long data);
+void oom_timer(struct timer_list *t);
 extern u8 t21040_csr13[];
 
 static inline void tulip_start_rxtx(struct tulip_private *tp)
diff --git a/drivers/net/ethernet/dec/tulip/tulip_core.c b/drivers/net/ethernet/dec/tulip/tulip_core.c
index 851b6d1f5a42..00d02a0967d0 100644
--- a/drivers/net/ethernet/dec/tulip/tulip_core.c
+++ b/drivers/net/ethernet/dec/tulip/tulip_core.c
@@ -123,10 +123,10 @@ int tulip_debug = TULIP_DEBUG;
 int tulip_debug = 1;
 #endif
 
-static void tulip_timer(unsigned long data)
+static void tulip_timer(struct timer_list *t)
 {
-	struct net_device *dev = (struct net_device *)data;
-	struct tulip_private *tp = netdev_priv(dev);
+	struct tulip_private *tp = from_timer(tp, t, timer);
+	struct net_device *dev = tp->dev;
 
 	if (netif_running(dev))
 		schedule_work(&tp->media_work);
@@ -505,7 +505,7 @@ static void tulip_up(struct net_device *dev)
 	tp->timer.expires = RUN_AT(next_tick);
 	add_timer(&tp->timer);
 #ifdef CONFIG_TULIP_NAPI
-	setup_timer(&tp->oom_timer, oom_timer, (unsigned long)dev);
+	timer_setup(&tp->oom_timer, oom_timer, 0);
 #endif
 }
 
@@ -780,8 +780,7 @@ static void tulip_down (struct net_device *dev)
 
 	spin_unlock_irqrestore (&tp->lock, flags);
 
-	setup_timer(&tp->timer, tulip_tbl[tp->chip_id].media_timer,
-		    (unsigned long)dev);
+	timer_setup(&tp->timer, tulip_tbl[tp->chip_id].media_timer, 0);
 
 	dev->if_port = tp->saved_if_port;
 
@@ -1470,8 +1469,7 @@ static int tulip_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	tp->csr0 = csr0;
 	spin_lock_init(&tp->lock);
 	spin_lock_init(&tp->mii_lock);
-	setup_timer(&tp->timer, tulip_tbl[tp->chip_id].media_timer,
-		    (unsigned long)dev);
+	timer_setup(&tp->timer, tulip_tbl[tp->chip_id].media_timer, 0);
 
 	INIT_WORK(&tp->media_work, tulip_tbl[tp->chip_id].media_task);
 
diff --git a/drivers/net/ethernet/dec/tulip/uli526x.c b/drivers/net/ethernet/dec/tulip/uli526x.c
index 7fc248efc4ba..488a744084c9 100644
--- a/drivers/net/ethernet/dec/tulip/uli526x.c
+++ b/drivers/net/ethernet/dec/tulip/uli526x.c
@@ -241,7 +241,7 @@ static void phy_write_1bit(struct uli526x_board_info *db, u32);
 static u16 phy_read_1bit(struct uli526x_board_info *db);
 static u8 uli526x_sense_speed(struct uli526x_board_info *);
 static void uli526x_process_mode(struct uli526x_board_info *);
-static void uli526x_timer(unsigned long);
+static void uli526x_timer(struct timer_list *t);
 static void uli526x_rx_packet(struct net_device *, struct uli526x_board_info *);
 static void uli526x_free_tx_pkt(struct net_device *, struct uli526x_board_info *);
 static void uli526x_reuse_skb(struct uli526x_board_info *, struct sk_buff *);
@@ -491,10 +491,8 @@ static int uli526x_open(struct net_device *dev)
 	netif_wake_queue(dev);
 
 	/* set and active a timer process */
-	init_timer(&db->timer);
+	timer_setup(&db->timer, uli526x_timer, 0);
 	db->timer.expires = ULI526X_TIMER_WUT + HZ * 2;
-	db->timer.data = (unsigned long)dev;
-	db->timer.function = uli526x_timer;
 	add_timer(&db->timer);
 
 	return 0;
@@ -1023,10 +1021,10 @@ static const struct ethtool_ops netdev_ethtool_ops = {
  *	Dynamic media sense, allocate Rx buffer...
  */
 
-static void uli526x_timer(unsigned long data)
+static void uli526x_timer(struct timer_list *t)
 {
-	struct net_device *dev = (struct net_device *) data;
-	struct uli526x_board_info *db = netdev_priv(dev);
+	struct uli526x_board_info *db = from_timer(db, t, timer);
+	struct net_device *dev = pci_get_drvdata(db->pdev);
 	struct uli_phy_ops *phy = &db->phy;
 	void __iomem *ioaddr = db->ioaddr;
  	unsigned long flags;
diff --git a/drivers/net/ethernet/dec/tulip/winbond-840.c b/drivers/net/ethernet/dec/tulip/winbond-840.c
index 32d7229544fa..f2e5e8fcb84a 100644
--- a/drivers/net/ethernet/dec/tulip/winbond-840.c
+++ b/drivers/net/ethernet/dec/tulip/winbond-840.c
@@ -327,7 +327,7 @@ static int  mdio_read(struct net_device *dev, int phy_id, int location);
 static void mdio_write(struct net_device *dev, int phy_id, int location, int value);
 static int  netdev_open(struct net_device *dev);
 static int  update_link(struct net_device *dev);
-static void netdev_timer(unsigned long data);
+static void netdev_timer(struct timer_list *t);
 static void init_rxtx_rings(struct net_device *dev);
 static void free_rxtx_rings(struct netdev_private *np);
 static void init_registers(struct net_device *dev);
@@ -655,10 +655,8 @@ static int netdev_open(struct net_device *dev)
 		netdev_dbg(dev, "Done netdev_open()\n");
 
 	/* Set the timer to check for link beat. */
-	init_timer(&np->timer);
-	np->timer.expires = jiffies + 1*HZ;
-	np->timer.data = (unsigned long)dev;
-	np->timer.function = netdev_timer;				/* timer handler */
+	timer_setup(&np->timer, netdev_timer, 0);
+	np->timer.expires = jiffies + 1*HZ;/* timer handler */
 	add_timer(&np->timer);
 	return 0;
 out_err:
@@ -774,10 +772,10 @@ static inline void update_csr6(struct net_device *dev, int new)
 		np->mii_if.full_duplex = 1;
 }
 
-static void netdev_timer(unsigned long data)
+static void netdev_timer(struct timer_list *t)
 {
-	struct net_device *dev = (struct net_device *)data;
-	struct netdev_private *np = netdev_priv(dev);
+	struct netdev_private *np = from_timer(np, t, timer);
+	struct net_device *dev = pci_get_drvdata(np->pci_dev);
 	void __iomem *ioaddr = np->base_addr;
 
 	if (debug > 2)
-- 
2.7.4


-- 
Kees Cook
Pixel Security
