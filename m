From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 28/58] net: ksz884x: Convert timers to use timer_setup()
Date: Mon, 16 Oct 2017 17:29:12 -0700
Message-ID: <1508200182-104605-29-git-send-email-keescook@chromium.org>
References: <1508200182-104605-1-git-send-email-keescook@chromium.org>
Cc: Kees Cook <keescook@chromium.org>,
        Johannes Berg <johannes.berg@intel.com>,
        Jarod Wilson <jarod@redhat.com>,
        Masahiro Yamada <yamada.masahiro@socionext.com>,
        Philippe Reynes <tremyfr@gmail.com>, netdev@vger.kernel.org,
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
Cc: Johannes Berg <johannes.berg@intel.com>
Cc: Jarod Wilson <jarod@redhat.com>
Cc: Masahiro Yamada <yamada.masahiro@socionext.com>
Cc: Philippe Reynes <tremyfr@gmail.com>
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/net/ethernet/micrel/ksz884x.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/micrel/ksz884x.c b/drivers/net/ethernet/micrel/ksz884x.c
index e798fbe08600..52207508744c 100644
--- a/drivers/net/ethernet/micrel/ksz884x.c
+++ b/drivers/net/ethernet/micrel/ksz884x.c
@@ -4338,11 +4338,11 @@ static void ksz_stop_timer(struct ksz_timer_info *info)
 }
 
 static void ksz_init_timer(struct ksz_timer_info *info, int period,
-	void (*function)(unsigned long), void *data)
+	void (*function)(struct timer_list *))
 {
 	info->max = 0;
 	info->period = period;
-	setup_timer(&info->timer, function, (unsigned long)data);
+	timer_setup(&info->timer, function, 0);
 }
 
 static void ksz_update_timer(struct ksz_timer_info *info)
@@ -6689,9 +6689,9 @@ static void mib_read_work(struct work_struct *work)
 	}
 }
 
-static void mib_monitor(unsigned long ptr)
+static void mib_monitor(struct timer_list *t)
 {
-	struct dev_info *hw_priv = (struct dev_info *) ptr;
+	struct dev_info *hw_priv = from_timer(hw_priv, t, mib_timer_info.timer);
 
 	mib_read_work(&hw_priv->mib_read);
 
@@ -6716,10 +6716,10 @@ static void mib_monitor(unsigned long ptr)
  *
  * This routine is run in a kernel timer to monitor the network device.
  */
-static void dev_monitor(unsigned long ptr)
+static void dev_monitor(struct timer_list *t)
 {
-	struct net_device *dev = (struct net_device *) ptr;
-	struct dev_priv *priv = netdev_priv(dev);
+	struct dev_priv *priv = from_timer(priv, t, monitor_timer_info.timer);
+	struct net_device *dev = priv->mii_if.dev;
 	struct dev_info *hw_priv = priv->adapter;
 	struct ksz_hw *hw = &hw_priv->hw;
 	struct ksz_port *port = &priv->port;
@@ -6789,7 +6789,7 @@ static int __init netdev_init(struct net_device *dev)
 
 	/* 500 ms timeout */
 	ksz_init_timer(&priv->monitor_timer_info, 500 * HZ / 1000,
-		dev_monitor, dev);
+		dev_monitor);
 
 	/* 500 ms timeout */
 	dev->watchdog_timeo = HZ / 2;
@@ -7065,7 +7065,7 @@ static int pcidev_init(struct pci_dev *pdev, const struct pci_device_id *id)
 
 	/* 500 ms timeout */
 	ksz_init_timer(&hw_priv->mib_timer_info, 500 * HZ / 1000,
-		mib_monitor, hw_priv);
+		mib_monitor);
 
 	for (i = 0; i < hw->dev_count; i++) {
 		dev = alloc_etherdev(sizeof(struct dev_priv));
-- 
2.7.4
