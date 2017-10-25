From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] drivers/net: realtek: Convert timers to use timer_setup()
Date: Wed, 25 Oct 2017 03:53:12 -0700
Message-ID: <20171025105312.GA146589@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Realtek linux nic maintainers <nic_swsd@realtek.com>,
        David Howells <dhowells@redhat.com>,
        Jay Vosburgh <jay.vosburgh@canonical.com>,
        Allen Pais <allen.lkml@gmail.com>,
        Eric Dumazet <edumazet@google.com>,
        Tobias Klauser <tklauser@distanz.ch>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly.

Cc: Realtek linux nic maintainers <nic_swsd@realtek.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: David Howells <dhowells@redhat.com>
Cc: Jay Vosburgh <jay.vosburgh@canonical.com>
Cc: Allen Pais <allen.lkml@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Tobias Klauser <tklauser@distanz.ch>
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/net/ethernet/realtek/atp.c   | 12 +++++++-----
 drivers/net/ethernet/realtek/r8169.c |  7 +++----
 2 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/realtek/atp.c b/drivers/net/ethernet/realtek/atp.c
index bdc3833fab7e..7e011c1c1e6e 100644
--- a/drivers/net/ethernet/realtek/atp.c
+++ b/drivers/net/ethernet/realtek/atp.c
@@ -170,6 +170,7 @@ struct net_local {
     spinlock_t lock;
     struct net_device *next_module;
     struct timer_list timer;	/* Media selection timer. */
+    struct net_device *dev;	/* Timer dev. */
     unsigned long last_rx_time;	/* Last Rx, in jiffies, to handle Rx hang. */
     int saved_tx_size;
     unsigned int tx_unit_busy:1;
@@ -184,7 +185,7 @@ struct net_local {
 #define TIMED_CHECKER (HZ/4)
 #ifdef TIMED_CHECKER
 #include <linux/timer.h>
-static void atp_timed_checker(unsigned long ignored);
+static void atp_timed_checker(struct timer_list *t);
 #endif
 
 /* Index to functions, as function prototypes. */
@@ -438,7 +439,8 @@ static int net_open(struct net_device *dev)
 
 	hardware_init(dev);
 
-	setup_timer(&lp->timer, atp_timed_checker, (unsigned long)dev);
+	lp->dev = dev;
+	timer_setup(&lp->timer, atp_timed_checker, 0);
 	lp->timer.expires = jiffies + TIMED_CHECKER;
 	add_timer(&lp->timer);
 
@@ -708,11 +710,11 @@ static irqreturn_t atp_interrupt(int irq, void *dev_instance)
 #ifdef TIMED_CHECKER
 /* This following code fixes a rare (and very difficult to track down)
    problem where the adapter forgets its ethernet address. */
-static void atp_timed_checker(unsigned long data)
+static void atp_timed_checker(struct timer_list *t)
 {
-	struct net_device *dev = (struct net_device *)data;
+	struct net_local *lp = from_timer(lp, t, timer);
+	struct net_device *dev = lp->dev;
 	long ioaddr = dev->base_addr;
-	struct net_local *lp = netdev_priv(dev);
 	int tickssofar = jiffies - lp->last_rx_time;
 	int i;
 
diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index a3c949ea7d1a..7dc4b6de31e6 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -4401,10 +4401,9 @@ static void rtl_schedule_task(struct rtl8169_private *tp, enum rtl_flag flag)
 		schedule_work(&tp->wk.work);
 }
 
-static void rtl8169_phy_timer(unsigned long __opaque)
+static void rtl8169_phy_timer(struct timer_list *t)
 {
-	struct net_device *dev = (struct net_device *)__opaque;
-	struct rtl8169_private *tp = netdev_priv(dev);
+	struct rtl8169_private *tp = from_timer(tp, t, timer);
 
 	rtl_schedule_task(tp, RTL_FLAG_TASK_PHY_PENDING);
 }
@@ -8454,7 +8453,7 @@ static int rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	tp->opts1_mask = (tp->mac_version != RTL_GIGA_MAC_VER_01) ?
 		~(RxBOVF | RxFOVF) : ~0;
 
-	setup_timer(&tp->timer, rtl8169_phy_timer, (unsigned long)dev);
+	timer_setup(&tp->timer, rtl8169_phy_timer, 0);
 
 	tp->rtl_fw = RTL_FIRMWARE_UNKNOWN;
 
-- 
2.7.4


-- 
Kees Cook
Pixel Security
