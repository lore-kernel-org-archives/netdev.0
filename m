From: Greg KH <gregkh@suse.de>
Subject: [patch 02/12] sky2: reduce impact of watchdog timer
Date: Mon, 8 Oct 2007 11:06:07 -0700
Message-ID: <20071008180607.GC7627@kroah.com>
References: <20071008180406.052382073@mini.kroah.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Justin Forbes <jmforbes@linuxtx.org>,
	Zwane Mwaikambo <zwane@arm.linux.org.uk>,
	Theodore Ts'o <tytso@mit.edu>,
	Randy Dunlap <rdunlap@xenotime.net>,
	Dave Jones <davej@redhat.com>,
	Chuck Wolber <chuckw@quantumlinux.com>,
	Chris Wedgwood <reviews@ml.cw.f00f.org>,
	Michael Krufky <mkrufky@linuxtv.org>,
	Chuck Ebbert <cebbert@redhat.com>,
	Domenico Andreoli <cavokz@gmail.com>,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	alan@lxorguk.ukuu.org.uk, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: linux-kernel@vger.kernel.org, stable@kernel.org,
	Krzysztof Oledzki <olel@ans.pl>, Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:51683 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754268AbXJHSH6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 14:07:58 -0400
Content-Disposition: inline; filename="sky2-hw-watchdog.patch"
In-Reply-To: <20071008180551.GA7627@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>

This is the 2.6.22 version of a regression fix that is already
in 2.6.23.  Change the watchdog timer form 10 per second all the time,
to 1 per second and only if interface is up.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>


---
 drivers/net/sky2.c |   45 ++++++++++++++++++---------------------------
 drivers/net/sky2.h |    2 +-
 2 files changed, 19 insertions(+), 28 deletions(-)

--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -96,10 +96,6 @@ static int disable_msi = 0;
 module_param(disable_msi, int, 0);
 MODULE_PARM_DESC(disable_msi, "Disable Message Signaled Interrupt (MSI)");
 
-static int idle_timeout = 100;
-module_param(idle_timeout, int, 0);
-MODULE_PARM_DESC(idle_timeout, "Watchdog timer for lost interrupts (ms)");
-
 static const struct pci_device_id sky2_id_table[] = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, 0x9000) }, /* SK-9Sxx */
 	{ PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, 0x9E00) }, /* SK-9Exx */
@@ -1693,6 +1689,8 @@ static void sky2_link_up(struct sky2_por
 
 	netif_carrier_on(sky2->netdev);
 
+	mod_timer(&hw->watchdog_timer, jiffies + 1);
+
 	/* Turn on link LED */
 	sky2_write8(hw, SK_REG(port, LNK_LED_REG),
 		    LINKLED_ON | LINKLED_BLINK_OFF | LINKLED_LINKSYNC_OFF);
@@ -2384,25 +2382,25 @@ static void sky2_le_error(struct sky2_hw
 	sky2_write32(hw, Q_ADDR(q, Q_CSR), BMU_CLR_IRQ_CHK);
 }
 
-/* If idle then force a fake soft NAPI poll once a second
- * to work around cases where sharing an edge triggered interrupt.
- */
-static inline void sky2_idle_start(struct sky2_hw *hw)
-{
-	if (idle_timeout > 0)
-		mod_timer(&hw->idle_timer,
-			  jiffies + msecs_to_jiffies(idle_timeout));
-}
-
-static void sky2_idle(unsigned long arg)
+/* Force a fake soft NAPI poll to handle lost IRQ's */
+static void sky2_watchdog(unsigned long arg)
 {
 	struct sky2_hw *hw = (struct sky2_hw *) arg;
 	struct net_device *dev = hw->dev[0];
+	int i, active = 0;
 
 	if (__netif_rx_schedule_prep(dev))
 		__netif_rx_schedule(dev);
 
-	mod_timer(&hw->idle_timer, jiffies + msecs_to_jiffies(idle_timeout));
+	for (i = 0; i < hw->ports; i++) {
+		dev = hw->dev[i];
+		if (!netif_running(dev))
+			continue;
+		++active;
+	}
+
+	if (active)
+		mod_timer(&hw->watchdog_timer, round_jiffies(jiffies + HZ));
 }
 
 /* Hardware/software error handling */
@@ -2692,8 +2690,6 @@ static void sky2_restart(struct work_str
 
 	dev_dbg(&hw->pdev->dev, "restarting\n");
 
-	del_timer_sync(&hw->idle_timer);
-
 	rtnl_lock();
 	sky2_write32(hw, B0_IMSK, 0);
 	sky2_read32(hw, B0_IMSK);
@@ -2722,8 +2718,6 @@ static void sky2_restart(struct work_str
 		}
 	}
 
-	sky2_idle_start(hw);
-
 	rtnl_unlock();
 }
 
@@ -3713,11 +3707,9 @@ static int __devinit sky2_probe(struct p
 			sky2_show_addr(dev1);
 	}
 
-	setup_timer(&hw->idle_timer, sky2_idle, (unsigned long) hw);
+	setup_timer(&hw->watchdog_timer, sky2_watchdog, (unsigned long) hw);
 	INIT_WORK(&hw->restart_work, sky2_restart);
 
-	sky2_idle_start(hw);
-
 	pci_set_drvdata(pdev, hw);
 
 	return 0;
@@ -3752,7 +3744,7 @@ static void __devexit sky2_remove(struct
 	if (!hw)
 		return;
 
-	del_timer_sync(&hw->idle_timer);
+	del_timer_sync(&hw->watchdog_timer);
 
 	flush_scheduled_work();
 
@@ -3796,7 +3788,7 @@ static int sky2_suspend(struct pci_dev *
 	if (!hw)
 		return 0;
 
-	del_timer_sync(&hw->idle_timer);
+	del_timer_sync(&hw->watchdog_timer);
 	netif_poll_disable(hw->dev[0]);
 
 	for (i = 0; i < hw->ports; i++) {
@@ -3862,7 +3854,7 @@ static int sky2_resume(struct pci_dev *p
 	}
 
 	netif_poll_enable(hw->dev[0]);
-	sky2_idle_start(hw);
+
 	return 0;
 out:
 	dev_err(&pdev->dev, "resume failed (%d)\n", err);
@@ -3879,7 +3871,6 @@ static void sky2_shutdown(struct pci_dev
 	if (!hw)
 		return;
 
-	del_timer_sync(&hw->idle_timer);
 	netif_poll_disable(hw->dev[0]);
 
 	for (i = 0; i < hw->ports; i++) {
--- a/drivers/net/sky2.h
+++ b/drivers/net/sky2.h
@@ -1921,7 +1921,7 @@ struct sky2_hw {
 	u32		     st_idx;
 	dma_addr_t   	     st_dma;
 
-	struct timer_list    idle_timer;
+	struct timer_list    watchdog_timer;
 	struct work_struct   restart_work;
 	int		     msi;
 	wait_queue_head_t    msi_wait;

-- 
