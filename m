From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 44/58] net: ethernet: sun: Convert timers to use timer_setup()
Date: Mon, 16 Oct 2017 17:29:28 -0700
Message-ID: <1508200182-104605-45-git-send-email-keescook@chromium.org>
References: <1508200182-104605-1-git-send-email-keescook@chromium.org>
Cc: Kees Cook <keescook@chromium.org>,
        Philippe Reynes <tremyfr@gmail.com>,
        Jarod Wilson <jarod@redhat.com>,
        Shannon Nelson <shannon.nelson@oracle.com>,
        Rob Herring <robh@kernel.org>,
        chris hyser <chris.hyser@oracle.com>,
        Tushar Dave <tushar.n.dave@oracle.com>,
        Tobias Klauser <tklauser@distanz.ch>, netdev@vger.kernel.org,
        Thomas Gleixner <tglx@linutronix.de>,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1508200182-104605-1-git-send-email-keescook@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Philippe Reynes <tremyfr@gmail.com>
Cc: Jarod Wilson <jarod@redhat.com>
Cc: Shannon Nelson <shannon.nelson@oracle.com>
Cc: Rob Herring <robh@kernel.org>
Cc: chris hyser <chris.hyser@oracle.com>
Cc: Tushar Dave <tushar.n.dave@oracle.com>
Cc: Tobias Klauser <tklauser@distanz.ch>
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/net/ethernet/sun/cassini.c        |  7 ++++---
 drivers/net/ethernet/sun/ldmvsw.c         |  3 +--
 drivers/net/ethernet/sun/niu.c            | 10 ++++------
 drivers/net/ethernet/sun/sunbmac.c        | 10 ++++------
 drivers/net/ethernet/sun/sungem.c         |  6 +++---
 drivers/net/ethernet/sun/sunhme.c         | 10 ++++------
 drivers/net/ethernet/sun/sunvnet.c        |  3 +--
 drivers/net/ethernet/sun/sunvnet_common.c |  4 ++--
 drivers/net/ethernet/sun/sunvnet_common.h |  2 +-
 9 files changed, 24 insertions(+), 31 deletions(-)

diff --git a/drivers/net/ethernet/sun/cassini.c b/drivers/net/ethernet/sun/cassini.c
index a74d78f64af9..113bd57e2ea0 100644
--- a/drivers/net/ethernet/sun/cassini.c
+++ b/drivers/net/ethernet/sun/cassini.c
@@ -4079,9 +4079,9 @@ static void cas_reset_task(struct work_struct *work)
 #endif
 }
 
-static void cas_link_timer(unsigned long data)
+static void cas_link_timer(struct timer_list *t)
 {
-	struct cas *cp = (struct cas *) data;
+	struct cas *cp = from_timer(cp, t, link_timer);
 	int mask, pending = 0, reset = 0;
 	unsigned long flags;
 
@@ -5039,7 +5039,8 @@ static int cas_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	spin_lock_init(&cp->stat_lock[N_TX_RINGS]);
 	mutex_init(&cp->pm_mutex);
 
-	setup_timer(&cp->link_timer, cas_link_timer, (unsigned long)cp);
+	timer_setup(&cp->link_timer, cas_link_timer, 0);
+
 #if 1
 	/* Just in case the implementation of atomic operations
 	 * change so that an explicit initialization is necessary.
diff --git a/drivers/net/ethernet/sun/ldmvsw.c b/drivers/net/ethernet/sun/ldmvsw.c
index 5feeaa9f0a9e..5ea037672e6f 100644
--- a/drivers/net/ethernet/sun/ldmvsw.c
+++ b/drivers/net/ethernet/sun/ldmvsw.c
@@ -363,8 +363,7 @@ static int vsw_port_probe(struct vio_dev *vdev, const struct vio_device_id *id)
 	list_add_rcu(&port->list, &vp->port_list);
 	spin_unlock_irqrestore(&vp->lock, flags);
 
-	setup_timer(&port->clean_timer, sunvnet_clean_timer_expire_common,
-		    (unsigned long)port);
+	timer_setup(&port->clean_timer, sunvnet_clean_timer_expire_common, 0);
 
 	err = register_netdev(dev);
 	if (err) {
diff --git a/drivers/net/ethernet/sun/niu.c b/drivers/net/ethernet/sun/niu.c
index bde19b307d0d..ab502ee35fb2 100644
--- a/drivers/net/ethernet/sun/niu.c
+++ b/drivers/net/ethernet/sun/niu.c
@@ -2221,9 +2221,9 @@ static int niu_link_status(struct niu *np, int *link_up_p)
 	return err;
 }
 
-static void niu_timer(unsigned long __opaque)
+static void niu_timer(struct timer_list *t)
 {
-	struct niu *np = (struct niu *) __opaque;
+	struct niu *np = from_timer(np, t, timer);
 	unsigned long off;
 	int err, link_up;
 
@@ -6123,7 +6123,7 @@ static int niu_open(struct net_device *dev)
 
 	err = niu_init_hw(np);
 	if (!err) {
-		setup_timer(&np->timer, niu_timer, (unsigned long)np);
+		timer_setup(&np->timer, niu_timer, 0);
 		np->timer.expires = jiffies + HZ;
 
 		err = niu_enable_interrupts(np, 1);
@@ -6773,10 +6773,8 @@ static int niu_change_mtu(struct net_device *dev, int new_mtu)
 
 	err = niu_init_hw(np);
 	if (!err) {
-		init_timer(&np->timer);
+		timer_setup(&np->timer, niu_timer, 0);
 		np->timer.expires = jiffies + HZ;
-		np->timer.data = (unsigned long) np;
-		np->timer.function = niu_timer;
 
 		err = niu_enable_interrupts(np, 1);
 		if (err)
diff --git a/drivers/net/ethernet/sun/sunbmac.c b/drivers/net/ethernet/sun/sunbmac.c
index 3189722110c2..0b1f41f6bceb 100644
--- a/drivers/net/ethernet/sun/sunbmac.c
+++ b/drivers/net/ethernet/sun/sunbmac.c
@@ -523,9 +523,9 @@ static int try_next_permutation(struct bigmac *bp, void __iomem *tregs)
 	return -1;
 }
 
-static void bigmac_timer(unsigned long data)
+static void bigmac_timer(struct timer_list *t)
 {
-	struct bigmac *bp = (struct bigmac *) data;
+	struct bigmac *bp = from_timer(bp, t, bigmac_timer);
 	void __iomem *tregs = bp->tregs;
 	int restart_timer = 0;
 
@@ -613,8 +613,6 @@ static void bigmac_begin_auto_negotiation(struct bigmac *bp)
 	bp->timer_state = ltrywait;
 	bp->timer_ticks = 0;
 	bp->bigmac_timer.expires = jiffies + (12 * HZ) / 10;
-	bp->bigmac_timer.data = (unsigned long) bp;
-	bp->bigmac_timer.function = bigmac_timer;
 	add_timer(&bp->bigmac_timer);
 }
 
@@ -921,7 +919,7 @@ static int bigmac_open(struct net_device *dev)
 		printk(KERN_ERR "BIGMAC: Can't order irq %d to go.\n", dev->irq);
 		return ret;
 	}
-	init_timer(&bp->bigmac_timer);
+	timer_setup(&bp->bigmac_timer, bigmac_timer, 0);
 	ret = bigmac_init_hw(bp, 0);
 	if (ret)
 		free_irq(dev->irq, bp);
@@ -1172,7 +1170,7 @@ static int bigmac_ether_init(struct platform_device *op,
 					      "board-version", 1);
 
 	/* Init auto-negotiation timer state. */
-	init_timer(&bp->bigmac_timer);
+	timer_setup(&bp->bigmac_timer, bigmac_timer, 0);
 	bp->timer_state = asleep;
 	bp->timer_ticks = 0;
 
diff --git a/drivers/net/ethernet/sun/sungem.c b/drivers/net/ethernet/sun/sungem.c
index b75ab8f44968..a7afcee3c5ae 100644
--- a/drivers/net/ethernet/sun/sungem.c
+++ b/drivers/net/ethernet/sun/sungem.c
@@ -1496,9 +1496,9 @@ static int gem_mdio_link_not_up(struct gem *gp)
 	}
 }
 
-static void gem_link_timer(unsigned long data)
+static void gem_link_timer(struct timer_list *t)
 {
-	struct gem *gp = (struct gem *) data;
+	struct gem *gp = from_timer(gp, t, link_timer);
 	struct net_device *dev = gp->dev;
 	int restart_aneg = 0;
 
@@ -2910,7 +2910,7 @@ static int gem_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	gp->msg_enable = DEFAULT_MSG;
 
-	setup_timer(&gp->link_timer, gem_link_timer, (unsigned long)gp);
+	timer_setup(&gp->link_timer, gem_link_timer, 0);
 
 	INIT_WORK(&gp->reset_task, gem_reset_task);
 
diff --git a/drivers/net/ethernet/sun/sunhme.c b/drivers/net/ethernet/sun/sunhme.c
index 9e983e1d8249..0431f1e5f511 100644
--- a/drivers/net/ethernet/sun/sunhme.c
+++ b/drivers/net/ethernet/sun/sunhme.c
@@ -685,9 +685,9 @@ static int is_lucent_phy(struct happy_meal *hp)
 	return ret;
 }
 
-static void happy_meal_timer(unsigned long data)
+static void happy_meal_timer(struct timer_list *t)
 {
-	struct happy_meal *hp = (struct happy_meal *) data;
+	struct happy_meal *hp = from_timer(hp, t, happy_timer);
 	void __iomem *tregs = hp->tcvregs;
 	int restart_timer = 0;
 
@@ -1413,8 +1413,6 @@ happy_meal_begin_auto_negotiation(struct happy_meal *hp,
 
 	hp->timer_ticks = 0;
 	hp->happy_timer.expires = jiffies + (12 * HZ)/10;  /* 1.2 sec. */
-	hp->happy_timer.data = (unsigned long) hp;
-	hp->happy_timer.function = happy_meal_timer;
 	add_timer(&hp->happy_timer);
 }
 
@@ -2819,7 +2817,7 @@ static int happy_meal_sbus_probe_one(struct platform_device *op, int is_qfe)
 	hp->timer_state = asleep;
 	hp->timer_ticks = 0;
 
-	init_timer(&hp->happy_timer);
+	timer_setup(&hp->happy_timer, happy_meal_timer, 0);
 
 	hp->dev = dev;
 	dev->netdev_ops = &hme_netdev_ops;
@@ -3133,7 +3131,7 @@ static int happy_meal_pci_probe(struct pci_dev *pdev,
 	hp->timer_state = asleep;
 	hp->timer_ticks = 0;
 
-	init_timer(&hp->happy_timer);
+	timer_setup(&hp->happy_timer, happy_meal_timer, 0);
 
 	hp->irq = pdev->irq;
 	hp->dev = dev;
diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
index 0b95105f7060..27fb22638885 100644
--- a/drivers/net/ethernet/sun/sunvnet.c
+++ b/drivers/net/ethernet/sun/sunvnet.c
@@ -492,8 +492,7 @@ static int vnet_port_probe(struct vio_dev *vdev, const struct vio_device_id *id)
 	pr_info("%s: PORT ( remote-mac %pM%s )\n",
 		vp->dev->name, port->raddr, switch_port ? " switch-port" : "");
 
-	setup_timer(&port->clean_timer, sunvnet_clean_timer_expire_common,
-		    (unsigned long)port);
+	timer_setup(&port->clean_timer, sunvnet_clean_timer_expire_common, 0);
 
 	napi_enable(&port->napi);
 	vio_port_up(&port->vio);
diff --git a/drivers/net/ethernet/sun/sunvnet_common.c b/drivers/net/ethernet/sun/sunvnet_common.c
index ecf456c7b6d1..8aa3ce46bb81 100644
--- a/drivers/net/ethernet/sun/sunvnet_common.c
+++ b/drivers/net/ethernet/sun/sunvnet_common.c
@@ -1040,9 +1040,9 @@ static inline void vnet_free_skbs(struct sk_buff *skb)
 	}
 }
 
-void sunvnet_clean_timer_expire_common(unsigned long port0)
+void sunvnet_clean_timer_expire_common(struct timer_list *t)
 {
-	struct vnet_port *port = (struct vnet_port *)port0;
+	struct vnet_port *port = from_timer(port, t, clean_timer);
 	struct sk_buff *freeskbs;
 	unsigned pending;
 
diff --git a/drivers/net/ethernet/sun/sunvnet_common.h b/drivers/net/ethernet/sun/sunvnet_common.h
index b20d6fa7ef25..656673c31066 100644
--- a/drivers/net/ethernet/sun/sunvnet_common.h
+++ b/drivers/net/ethernet/sun/sunvnet_common.h
@@ -129,7 +129,7 @@ struct vnet {
 	((__port)->vsw ? (__port)->dev : (__port)->vp->dev)
 
 /* Common funcs */
-void sunvnet_clean_timer_expire_common(unsigned long port0);
+void sunvnet_clean_timer_expire_common(struct timer_list *t);
 int sunvnet_open_common(struct net_device *dev);
 int sunvnet_close_common(struct net_device *dev);
 void sunvnet_set_rx_mode_common(struct net_device *dev, struct vnet *vp);
-- 
2.7.4
